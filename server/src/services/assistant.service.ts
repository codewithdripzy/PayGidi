import { v4 as uuidv4 } from "uuid";
import AssistantModel from "../models/assistant.model";
import AssistantDeploymentModel from "../models/assistant-deployment.model";
import { ApiRequestContext } from "./api.service";
import organizationService from "./organization.service";
import { generateApiKey } from "../utils/generator";

class AssistantService {
    private resolveOrganizationId(value: unknown, fallback?: string) {
        if (!value || typeof value !== "object") {
            return fallback ?? null;
        }

        const org = value as { _id?: unknown; id?: unknown; uid?: unknown };

        if (typeof org._id === "string" && org._id.trim()) return org._id;
        if (typeof org.id === "string" && org.id.trim()) return org.id;
        if (typeof org.uid === "string" && org.uid.trim()) return org.uid;

        return fallback ?? null;
    }

    private mapKnowledgeSourceType(type: "website" | "file" | "faq" | "document" | "link" | "text") {
        return type;
    }

    private sanitizeKnowledgeValue(value: string, fallback: string) {
        if (!value) return fallback;

        if (value.includes("PK\u0003\u0004") || value.includes("PK\x03\x04")) {
            return fallback;
        }

        if (value.length > 50000) {
            return fallback;
        }

        return value;
    }

    async createAssistant(
        userId: unknown,
        payload: {
            organizationId: string;
            name: string;
            description?: string;
            firstMessage?: string;
            tone?: "formal" | "casual" | "sales" | "support";
            provider?: string;
            model?: string;
            voiceId?: string;
            temperature?: number;
            maxTokens?: number;
            responseStyle?: "short" | "balanced" | "detailed";
            knowledgeBase?: Array<{
                type: "website" | "file" | "faq" | "document" | "link" | "text";
                title: string;
                value: string;
            }>;
            instructions?: string[];
            accessControl?: {
                allowedDomains: string[];
                blockedRoutes: string[];
            };
        },
        context?: ApiRequestContext
    ) {
        const organization = await organizationService.getOrganizationForUser(payload.organizationId, context);
        if (!organization) return null;

        const organizationId = this.resolveOrganizationId(organization, payload.organizationId);
        if (!organizationId) return null;

        const knowledgeBase = (payload.knowledgeBase ?? []).map((item) => {
            const safeValue = this.sanitizeKnowledgeValue(item.value, item.title);

            return {
            uid: uuidv4(),
            sourceType: this.mapKnowledgeSourceType(item.type),
            title: item.title,
            value: safeValue,
            url: item.type === "website" || item.type === "link" ? safeValue : null,
            text: item.type === "text" ? safeValue : null,
            metadata: {},
            };
        });

        const assistant = await AssistantModel.create({
            organization: organizationId,
            createdBy: String(userId),
            name: payload.name,
            description: payload.description ?? "",
            firstMessage: payload.firstMessage ?? "",
            voiceId: payload.voiceId ?? "",
            knowledgeBase,
            metadata: {
                personality: {
                    tone: payload.tone ?? "support",
                    responseStyle: payload.responseStyle ?? "balanced",
                },
                generation: {
                    provider: payload.provider ?? "openai",
                    model: payload.model ?? "gpt-4.1-mini",
                    temperature: payload.temperature ?? 0.2,
                    maxTokens: payload.maxTokens ?? 512,
                },
            },
            instructions: payload.instructions ?? [],
            accessControl: payload.accessControl ?? {
                allowedDomains: ["*"],
                blockedRoutes: [],
            },
            status: "draft",
        });

        await organizationService.addAssistantToOrganization(payload.organizationId, assistant._id);

        return assistant;
    }

    async getAssistantByUid(uid: string) {
        return AssistantModel.findOne({ uid });
    }

    async getAssistantForUser(uid: string, userId: unknown, context?: ApiRequestContext) {
        const assistant = await AssistantModel.findOne({ uid });
        if (!assistant) return null;

        const org = await organizationService.getOrganizationForUser(String(assistant.organization), context);
        if (!org) return null;

        return assistant;
    }

    async listAssistantsForOrganization(organizationUid: string, userId: unknown, context?: ApiRequestContext) {
        const organization = await organizationService.getOrganizationForUser(organizationUid, context);
        if (!organization) return null;

        const organizationId = this.resolveOrganizationId(organization, organizationUid);
        if (!organizationId) return { organization, assistants: [] };

        const assistants = await AssistantModel.find({ organization: organizationId }).sort({ createdAt: -1 });
        return { organization, assistants };
    }

    async updateAssistant(
        uid: string,
        userId: unknown,
        payload: Partial<{
            name: string;
            description: string;
            firstMessage: string;
            voiceId: string;
            provider: string;
            tone: "formal" | "casual" | "sales" | "support";
            model: string;
            temperature: number;
            maxTokens: number;
            responseStyle: "short" | "balanced" | "detailed";
            status: "draft" | "live" | "archived";
            instructions: string[];
            accessControl: {
                allowedDomains: string[];
                blockedRoutes: string[];
            };
        }>,
        context?: ApiRequestContext
    ) {
        const assistant = await this.getAssistantForUser(uid, userId, context);
        if (!assistant) return null;

        if (payload.name !== undefined) assistant.name = payload.name;
        if (payload.description !== undefined) assistant.description = payload.description;
        if (payload.firstMessage !== undefined) assistant.firstMessage = payload.firstMessage;
        if (payload.voiceId !== undefined) assistant.voiceId = payload.voiceId;
        if (payload.status !== undefined) assistant.status = payload.status;
        
        if (payload.instructions !== undefined) {
            (assistant as any).instructions = payload.instructions;
        }

        if (payload.accessControl !== undefined) {
            (assistant as any).accessControl = payload.accessControl;
        }

        if (payload.tone !== undefined) {
            assistant.set("metadata.personality.tone", payload.tone);
        }
        if (payload.responseStyle !== undefined) {
            assistant.set("metadata.personality.responseStyle", payload.responseStyle);
        }
        if (payload.provider !== undefined) {
            assistant.set("metadata.generation.provider", payload.provider);
        }
        if (payload.model !== undefined) {
            assistant.set("metadata.generation.model", payload.model);
        }
        if (payload.temperature !== undefined) {
            assistant.set("metadata.generation.temperature", payload.temperature);
        }
        if (payload.maxTokens !== undefined) {
            assistant.set("metadata.generation.maxTokens", payload.maxTokens);
        }

        await assistant.save();
        return assistant;
    }

    async addKnowledgeBaseItem(
        uid: string,
        userId: unknown,
        payload: {
            type: "website" | "file" | "faq" | "document" | "link" | "text";
            title: string;
            value?: string;
            fileName?: string;
            metadata?: Record<string, unknown>;
        },
        context?: ApiRequestContext
    ) {
        const assistant = await this.getAssistantForUser(uid, userId, context);
        if (!assistant) return null;

        const rawValue = payload.value ?? "";
        const fallback = payload.fileName?.trim() || payload.title;
        const safeValue = this.sanitizeKnowledgeValue(rawValue, fallback);

        assistant.knowledgeBase.push({
            uid: uuidv4(),
            sourceType: payload.type,
            title: payload.title,
            value: safeValue || null,
            url: payload.type === "website" || payload.type === "link" ? safeValue : null,
            text: payload.type === "text" ? safeValue : null,
            metadata: payload.metadata ?? {},
        });

        await assistant.save();
        return assistant;
    }

    async removeKnowledgeBaseItem(uid: string, userId: unknown, knowledgeUid: string, context?: ApiRequestContext) {
        const assistant = await this.getAssistantForUser(uid, userId, context);
        if (!assistant) return null;

        assistant.knowledgeBase = assistant.knowledgeBase.filter((item: { uid: string }) => item.uid !== knowledgeUid);
        await assistant.save();

        return assistant;
    }

    async updateKnowledgeBaseItem(
        uid: string,
        userId: unknown,
        knowledgeUid: string,
        payload: {
            title?: string;
            value?: string;
            fileName?: string;
            metadata?: Record<string, unknown>;
        },
        context?: ApiRequestContext
    ) {
        const assistant = await this.getAssistantForUser(uid, userId, context);
        if (!assistant) return null;

        const knowledgeItem = assistant.knowledgeBase.find((item: { uid: string }) => item.uid === knowledgeUid) as {
            uid: string;
            sourceType: "website" | "file" | "faq" | "document" | "link" | "text";
            title: string;
            value?: string | null;
            url?: string | null;
            text?: string | null;
            metadata?: Record<string, unknown>;
        } | undefined;
        if (!knowledgeItem) return null;

        if (payload.title !== undefined) {
            knowledgeItem.title = payload.title;
        }

        if (payload.value !== undefined) {
            const fallback = payload.fileName?.trim() || knowledgeItem.title;
            const safeValue = this.sanitizeKnowledgeValue(payload.value, fallback).trim();

            knowledgeItem.value = safeValue.length > 0 ? safeValue : null;
            knowledgeItem.url = knowledgeItem.sourceType === "website" || knowledgeItem.sourceType === "link"
                ? (safeValue.length > 0 ? safeValue : null)
                : null;
            knowledgeItem.text = knowledgeItem.sourceType === "text"
                ? (safeValue.length > 0 ? safeValue : null)
                : null;
        }

        if (payload.metadata !== undefined) {
            knowledgeItem.metadata = payload.metadata;
        }

        await assistant.save();
        return assistant;
    }

    async deleteAssistant(uid: string, userId: unknown, context?: ApiRequestContext) {
        const assistant = await this.getAssistantForUser(uid, userId, context);
        if (!assistant) return null;

        await AssistantDeploymentModel.deleteMany({ assistant: assistant._id });
        await AssistantModel.deleteOne({ _id: assistant._id });

        return assistant;
    }

    async deployAssistant(
        uid: string,
        userId: unknown,
        payload: { provider?: string; environment?: "development" | "staging" | "production"; cdnUrl?: string },
        context?: ApiRequestContext
    ) {
        const assistant = await this.getAssistantForUser(uid, userId, context);
        if (!assistant) return null;

        const widgetKey = assistant.deployment.widgetKey || generateApiKey();
        const cdnUrl = payload.cdnUrl ?? "https://cdn.orello.ai/widget.js";
        const widgetScript = `<script src="${cdnUrl}" data-key="${widgetKey}"></script>`;

        assistant.deployment = {
            isDeployed: true,
            provider: payload.provider ?? "widget",
            environment: payload.environment ?? "production",
            widgetKey,
            widgetScript,
            deployedAt: new Date(),
            lastDeployedBy: userId,
        };
        assistant.status = "live";
        await assistant.save();

        await AssistantDeploymentModel.create({
            assistant: assistant._id,
            organization: assistant.organization,
            deployedBy: userId,
            provider: assistant.deployment.provider,
            environment: assistant.deployment.environment,
            widgetKey,
            widgetScript,
            status: "deployed",
        });

        return assistant;
    }

    async undeployAssistant(uid: string, userId: unknown, context?: ApiRequestContext) {
        const assistant = await this.getAssistantForUser(uid, userId, context);
        if (!assistant) return null;

        if (!assistant.deployment.widgetKey) {
            return assistant;
        }

        await AssistantDeploymentModel.create({
            assistant: assistant._id,
            organization: assistant.organization,
            deployedBy: userId,
            provider: assistant.deployment.provider ?? "widget",
            environment: assistant.deployment.environment ?? "production",
            widgetKey: assistant.deployment.widgetKey,
            widgetScript: assistant.deployment.widgetScript ?? "",
            status: "undeployed",
        });

        assistant.deployment = {
            isDeployed: false,
            provider: assistant.deployment.provider,
            environment: assistant.deployment.environment ?? "production",
            widgetKey: assistant.deployment.widgetKey,
            widgetScript: assistant.deployment.widgetScript,
            deployedAt: assistant.deployment.deployedAt,
            lastDeployedBy: userId,
        };
        assistant.status = "draft";

        await assistant.save();
        return assistant;
    }

    async listDeployments(uid: string, userId: unknown, context?: ApiRequestContext) {
        const assistant = await this.getAssistantForUser(uid, userId, context);
        if (!assistant) return null;

        const deployments = await AssistantDeploymentModel.find({ assistant: assistant._id }).sort({ createdAt: -1 });
        return { assistant, deployments };
    }

    async getAssistantByWidgetKey(widgetKey: string) {
        return AssistantModel.findOne({ "deployment.widgetKey": widgetKey });
    }

    async getAssistantByBaseUrl(baseUrl: string) {
        // Normalize baseUrl for consistent searching
        const normalized = baseUrl.replace(/\/$/, "").toLowerCase();
        return AssistantModel.findOne({ 
            $or: [
                { "sites.baseUrl": normalized },
                { "knowledgeBase.url": { $regex: new RegExp(`^${normalized}`, "i") } }
            ]
        });
    }

    async updateCrawlStatus(uid: string, baseUrl: string, lastCrawledAt: Date, context?: { sitemap?: any; summary?: string }) {
        const normalized = baseUrl.replace(/\/$/, "").toLowerCase();
        
        const updateFields: any = { 
            "sites.$.lastCrawledAt": lastCrawledAt 
        };

        if (context) {
            if (context.sitemap !== undefined) updateFields["sites.$.context.sitemap"] = context.sitemap;
            if (context.summary !== undefined) updateFields["sites.$.context.summary"] = context.summary;
        }

        // Try to update existing site in the array
        let assistant = await AssistantModel.findOneAndUpdate(
            { uid, "sites.baseUrl": normalized },
            { $set: updateFields },
            { new: true }
        );

        // If site doesn't exist in the array, push it
        if (!assistant) {
            assistant = await AssistantModel.findOneAndUpdate(
                { uid },
                { 
                    $push: { 
                        sites: { 
                            baseUrl: normalized, 
                            lastCrawledAt,
                            context: context ?? { sitemap: null, summary: null }
                        } 
                    } 
                },
                { new: true }
            );
        }

        return assistant;
    }

    async getPublicAssistantByUid(widgetKey: string) {
        return AssistantModel.findOne({
            "deployment.widgetKey": widgetKey,
            "deployment.isDeployed": true,
        });
    }

    async getPublicAssistantByUidAndOrg(uid: string, organizationId: string) {
        return AssistantModel.findOne({
            uid,
            organization: organizationId,
            "deployment.isDeployed": true,
        });
    }
    async regenerateWidgetKey(uid: string, userId: unknown, context?: ApiRequestContext) {
        const assistant = await this.getAssistantForUser(uid, userId, context);
        if (!assistant) return null;

        const widgetKey = generateApiKey();

        assistant.deployment.widgetKey = widgetKey;
        
        // Update widget script with new key
        if (assistant.deployment.widgetScript) {
            assistant.deployment.widgetScript = assistant.deployment.widgetScript.replace(/data-key="[^"]*"/, `data-key="${widgetKey}"`);
        }

        await assistant.save();

        // Also update any deployment records if necessary
        await AssistantDeploymentModel.updateMany(
            { assistant: assistant._id, status: "deployed" },
            { $set: { widgetKey, widgetScript: assistant.deployment.widgetScript } }
        );

        return assistant;
    }
}

const assistantService = new AssistantService();

export default assistantService;
