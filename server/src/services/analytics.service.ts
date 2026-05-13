import AnalyticsEventModel from "../models/analytics-event.model";
import AssistantModel from "../models/assistant.model";
import { ApiRequestContext } from "./api.service";
import organizationService from "./organization.service";
import assistantService from "./assistant.service";

class AnalyticsService {
    private static readonly DEFAULT_AVG_CONVERSATION_MINUTES = 6.3;

    private resolveFromDate(range?: string) {
        const now = new Date();
        const days = range === "90d" ? 90 : range === "30d" ? 30 : 7;
        return new Date(now.getTime() - days * 24 * 60 * 60 * 1000);
    }

    private toIdentifier(value: unknown) {
        if (value === null || value === undefined) return null;
        const normalized = String(value).trim();
        return normalized.length ? normalized : null;
    }

    private toFiniteNumber(value: unknown, fallback = 0) {
        const next = Number(value);
        return Number.isFinite(next) ? next : fallback;
    }

    private resolveOrganizationIdentifiers(
        organization?: { _id?: unknown; id?: unknown; uid?: unknown } | null,
        fallback?: string,
    ) {
        const values = [organization?._id, organization?.id, organization?.uid, fallback]
            .map((value) => this.toIdentifier(value))
            .filter((value): value is string => Boolean(value));

        return Array.from(new Set(values));
    }

    private getOrganizationMembersCount(organization: Record<string, unknown>) {
        const members = organization.members;
        if (Array.isArray(members)) return members.length;
        return 0;
    }

    private getOrganizationAssistants(organization: Record<string, unknown>) {
        const assistants = organization.assistants;
        if (Array.isArray(assistants)) {
            return assistants as Array<Record<string, unknown>>;
        }

        return [];
    }

    private buildDailyUsageTimeline(events: Array<{ occurredAt: Date; eventType: string; value?: number }>) {
        const today = new Date();
        const usageByDate = new Map<string, number>();

        for (let i = 6; i >= 0; i -= 1) {
            const date = new Date(today);
            date.setDate(today.getDate() - i);

            const key = date.toISOString().slice(0, 10);
            usageByDate.set(key, 0);
        }

        for (const event of events) {
            const key = new Date(event.occurredAt).toISOString().slice(0, 10);
            if (!usageByDate.has(key)) continue;

            if (event.eventType === "message_received" || event.eventType === "session_started") {
                usageByDate.set(key, (usageByDate.get(key) ?? 0) + this.toFiniteNumber(event.value, 1));
            }
        }

        return Array.from(usageByDate.entries()).map(([date, usage]) => ({
            date,
            day: new Date(date).toLocaleDateString("en-US", { weekday: "short" }),
            usage,
        }));
    }

    private resolveActionLabel(metadata: Record<string, unknown>) {
        return this.toIdentifier(
            metadata.action
            ?? metadata.actionName
            ?? metadata.actionLabel
            ?? metadata.workflow
            ?? metadata.intent
        );
    }

    private resolvePageLabel(metadata: Record<string, unknown>) {
        return this.toIdentifier(
            metadata.page
            ?? metadata.path
            ?? metadata.pagePath
            ?? metadata.route
            ?? metadata.url
        );
    }

    private resolveDurationSeconds(metadata: Record<string, unknown>) {
        const seconds = this.toFiniteNumber(metadata.durationSeconds, NaN);
        if (Number.isFinite(seconds)) return seconds;

        const milliseconds = this.toFiniteNumber(metadata.durationMs, NaN);
        if (Number.isFinite(milliseconds)) return milliseconds / 1000;

        return null;
    }

    async trackFromWidget(payload: {
        widgetKey: string;
        eventType: "session_started" | "message_received" | "message_resolved" | "fallback" | "handoff_requested" | "deployment_view";
        sessionId?: string;
        endUserId?: string;
        value?: number;
        metadata?: Record<string, unknown>;
    }) {
        const assistant = await assistantService.getAssistantByWidgetKey(payload.widgetKey);
        if (!assistant) return null;

        const event = await AnalyticsEventModel.create({
            organization: assistant.organization,
            assistant: assistant._id,
            eventType: payload.eventType,
            sessionId: payload.sessionId ?? null,
            endUserId: payload.endUserId ?? null,
            value: payload.value ?? 1,
            metadata: payload.metadata ?? {},
            occurredAt: new Date(),
        });

        return { event, assistant };
    }

    async getOverviewForUser(_userId: unknown, params: { organizationId?: string; range?: string }, context?: ApiRequestContext) {
        let organizationIds: string[] = [];
        let selectedOrganization: Record<string, unknown> | null = null;
        let organizations: Record<string, unknown>[] = [];

        if (params.organizationId) {
            const org = await organizationService.getOrganizationForUser(params.organizationId, context);
            if (!org) return null;

            selectedOrganization = org;

            organizationIds = this.resolveOrganizationIdentifiers(
                org as { _id?: unknown; id?: unknown; uid?: unknown },
                params.organizationId,
            );
        } else {
            const orgResult = await organizationService.listOrganizationsForUser(context);
            organizations = Array.isArray(orgResult)
                ? orgResult
                : orgResult.organizations;

            organizationIds = organizations
                .flatMap((org) => this.resolveOrganizationIdentifiers(org as { _id?: unknown; id?: unknown; uid?: unknown }))
                .filter((id): id is string => Boolean(id));

            selectedOrganization = organizations[0] ?? null;
        }

        if (!organizationIds.length) {
            return {
                totals: {
                    sessions: 0,
                    messages: 0,
                    resolved: 0,
                    fallback: 0,
                    handoff: 0,
                },
                successRate: 0,
                fallbackRate: 0,
                timeline: [],
                overviewCards: {
                    members: 0,
                    agents: 0,
                    liveAgents: 0,
                    liveRate: 0,
                    peopleUsedAgent: 0,
                    totalHoursSpentTalking: 0,
                    issuesAIFound: 0,
                    totalVisitors: 0,
                    averageMinutesPerUser: AnalyticsService.DEFAULT_AVG_CONVERSATION_MINUTES,
                },
                last7DaysUsage: [],
                conversationSummary: {
                    totalConversations: 0,
                    avgConversationLength: AnalyticsService.DEFAULT_AVG_CONVERSATION_MINUTES,
                    unresolvedQueries: 0,
                    successRate: 0,
                    fallbackRate: 0,
                    topIntents: [],
                },
                actionMetrics: [],
                userBehavior: {
                    totalVisitors: 0,
                    topPages: [],
                },
            };
        }

        const fromDate = this.resolveFromDate(params.range);

        const events = await AnalyticsEventModel.find({
            organization: { $in: organizationIds },
            occurredAt: { $gte: fromDate },
        });

        const totals = {
            sessions: 0,
            messages: 0,
            resolved: 0,
            fallback: 0,
            handoff: 0,
        };

        const timelineMap = new Map<string, { date: string; messages: number; resolved: number; fallback: number }>();
        const actionMap = new Map<string, { action: string; triggered: number; completed: number; failed: number; totalDurationSeconds: number; durationSamples: number }>();
        const pageMap = new Map<string, number>();
        const intentMap = new Map<string, number>();

        for (const event of events) {
            const magnitude = Number(event.value ?? 1);
            const metadata = (event.metadata && typeof event.metadata === "object")
                ? (event.metadata as Record<string, unknown>)
                : {};

            if (event.eventType === "session_started") totals.sessions += magnitude;
            if (event.eventType === "message_received") totals.messages += magnitude;
            if (event.eventType === "message_resolved") totals.resolved += magnitude;
            if (event.eventType === "fallback") totals.fallback += magnitude;
            if (event.eventType === "handoff_requested") totals.handoff += magnitude;

            const actionLabel = this.resolveActionLabel(metadata);
            if (actionLabel) {
                const row = actionMap.get(actionLabel) ?? {
                    action: actionLabel,
                    triggered: 0,
                    completed: 0,
                    failed: 0,
                    totalDurationSeconds: 0,
                    durationSamples: 0,
                };

                row.triggered += magnitude;

                if (event.eventType === "message_resolved") {
                    row.completed += magnitude;
                }

                if (event.eventType === "fallback" || event.eventType === "handoff_requested") {
                    row.failed += magnitude;
                }

                const durationSeconds = this.resolveDurationSeconds(metadata);
                if (durationSeconds !== null && Number.isFinite(durationSeconds)) {
                    row.totalDurationSeconds += durationSeconds;
                    row.durationSamples += 1;
                }

                actionMap.set(actionLabel, row);
            }

            const pageLabel = this.resolvePageLabel(metadata);
            if (pageLabel) {
                pageMap.set(pageLabel, (pageMap.get(pageLabel) ?? 0) + magnitude);
            }

            const intentLabel = this.toIdentifier(metadata.intent ?? metadata.intentName ?? metadata.topic);
            if (intentLabel) {
                intentMap.set(intentLabel, (intentMap.get(intentLabel) ?? 0) + magnitude);
            }

            const day = new Date(event.occurredAt).toISOString().slice(0, 10);
            const row = timelineMap.get(day) ?? { date: day, messages: 0, resolved: 0, fallback: 0 };

            if (event.eventType === "message_received") row.messages += magnitude;
            if (event.eventType === "message_resolved") row.resolved += magnitude;
            if (event.eventType === "fallback") row.fallback += magnitude;

            timelineMap.set(day, row);
        }

        const successRate = totals.messages ? Number(((totals.resolved / totals.messages) * 100).toFixed(2)) : 0;
        const fallbackRate = totals.messages ? Number(((totals.fallback / totals.messages) * 100).toFixed(2)) : 0;

        const organizationForCards = selectedOrganization;
        const organizationMembers = organizationForCards
            ? this.getOrganizationMembersCount(organizationForCards)
            : 0;

        const selectedOrganizationIds = this.resolveOrganizationIdentifiers(
            organizationForCards as { _id?: unknown; id?: unknown; uid?: unknown } | null,
            params.organizationId,
        );

        const assistantLookupIds = selectedOrganizationIds.length > 0 ? selectedOrganizationIds : organizationIds;

        const assistants = assistantLookupIds.length > 0
            ? await AssistantModel.find({ organization: { $in: assistantLookupIds } }).select("status")
            : [];

        const agents = assistants.length;
        const liveAgents = assistants.filter((assistant) => {
            const status = this.toIdentifier((assistant as { status?: unknown }).status)?.toLowerCase();
            return status === "live";
        }).length;
        const liveRate = agents > 0 ? Number(((liveAgents / agents) * 100).toFixed(2)) : 0;

        const uniqueUsers = new Set(
            events
                .map((event) => this.toIdentifier(event.endUserId))
                .filter((id): id is string => Boolean(id))
        );

        const peopleUsedAgent = uniqueUsers.size > 0
            ? uniqueUsers.size
            : Math.max(0, totals.sessions || 0);

        const totalHoursSpentTalking = Number(
            ((peopleUsedAgent * AnalyticsService.DEFAULT_AVG_CONVERSATION_MINUTES) / 60).toFixed(1)
        );

        const issuesAIFound = totals.fallback + totals.handoff;
        const totalVisitors = Math.max(peopleUsedAgent, totals.sessions);
        const totalConversations = Math.max(totals.sessions, totals.messages);

        const actionMetrics = Array.from(actionMap.values())
            .map((row) => {
                const completed = Math.min(row.completed, row.triggered);
                const failed = Math.max(row.failed, row.triggered - completed);
                const avgTimeSeconds = row.durationSamples > 0
                    ? Math.round(row.totalDurationSeconds / row.durationSamples)
                    : 0;

                return {
                    action: row.action,
                    triggered: row.triggered,
                    completed,
                    failed,
                    avgTimeSeconds,
                };
            })
            .sort((a, b) => b.triggered - a.triggered)
            .slice(0, 10);

        const topPages = Array.from(pageMap.entries())
            .map(([page, triggers]) => ({ page, triggers }))
            .sort((a, b) => b.triggers - a.triggers)
            .slice(0, 8);

        const topIntents = Array.from(intentMap.entries())
            .map(([name, count]) => ({ name, count }))
            .sort((a, b) => b.count - a.count)
            .slice(0, 6);

        return {
            totals,
            successRate,
            fallbackRate,
            timeline: Array.from(timelineMap.values()).sort((a, b) => a.date.localeCompare(b.date)),
            overviewCards: {
                members: organizationMembers,
                agents,
                liveAgents,
                liveRate,
                peopleUsedAgent,
                totalHoursSpentTalking,
                issuesAIFound,
                totalVisitors,
                averageMinutesPerUser: AnalyticsService.DEFAULT_AVG_CONVERSATION_MINUTES,
            },
            last7DaysUsage: this.buildDailyUsageTimeline(events),
            conversationSummary: {
                totalConversations,
                avgConversationLength: AnalyticsService.DEFAULT_AVG_CONVERSATION_MINUTES,
                unresolvedQueries: issuesAIFound,
                successRate,
                fallbackRate,
                topIntents,
            },
            actionMetrics,
            userBehavior: {
                totalVisitors,
                topPages,
            },
        };
    }

    async getAssistantAnalytics(userId: unknown, assistantUid: string, range?: string, context?: ApiRequestContext) {
        const assistant = await assistantService.getAssistantForUser(assistantUid, userId, context);
        if (!assistant) return null;

        const fromDate = this.resolveFromDate(range);
        const events = await AnalyticsEventModel.find({
            assistant: assistant._id,
            occurredAt: { $gte: fromDate },
        }).sort({ occurredAt: 1 });

        const byType: Record<string, number> = {
            session_started: 0,
            message_received: 0,
            message_resolved: 0,
            fallback: 0,
            handoff_requested: 0,
            deployment_view: 0,
        };

        for (const event of events) {
            const magnitude = Number(event.value ?? 1);
            byType[event.eventType] = (byType[event.eventType] ?? 0) + magnitude;
        }

        const totalMessages = byType.message_received ?? 0;
        const resolved = byType.message_resolved ?? 0;
        const fallback = byType.fallback ?? 0;

        return {
            assistant: {
                uid: assistant.uid,
                name: assistant.name,
                status: assistant.status,
                deployment: assistant.deployment,
            },
            byType,
            metrics: {
                successRate: totalMessages ? Number(((resolved / totalMessages) * 100).toFixed(2)) : 0,
                fallbackRate: totalMessages ? Number(((fallback / totalMessages) * 100).toFixed(2)) : 0,
            },
            totalEvents: events.length,
        };
    }
}

const analyticsService = new AnalyticsService();

export default analyticsService;
