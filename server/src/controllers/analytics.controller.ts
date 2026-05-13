import { Request, Response } from "express";
import { HTTP_RESPONSE_CODE } from "../core/constants/values";
import analyticsService from "../services/analytics.service";

const resolveBearerToken = (rawToken?: string) => {
    if (!rawToken || typeof rawToken !== "string") return undefined;

    const normalized = rawToken.trim();
    if (!normalized) return undefined;

    const tokenValue = normalized.toLowerCase().startsWith("bearer ")
        ? normalized.slice(7).trim()
        : normalized;

    if (!tokenValue || tokenValue === "undefined" || tokenValue === "null") {
        return undefined;
    }

    return `Bearer ${tokenValue}`;
};

const getRequestToken = (req: Request) => {
    const authHeaderToken = resolveBearerToken(req.headers.authorization);
    if (authHeaderToken) return authHeaderToken;

    return resolveBearerToken(req.cookies?.accessToken);
};

const TrackAnalyticsEventController = async (req: Request, res: Response) => {
    try {
        const result = await analyticsService.trackFromWidget(req.body);
        if (!result) {
            return res.status(HTTP_RESPONSE_CODE.NOT_FOUND).json({ message: "Assistant deployment key not found" });
        }

        return res.status(HTTP_RESPONSE_CODE.CREATED).json({
            message: "Event tracked",
            success: true,
        });
    } catch (error) {
        console.error("TrackAnalyticsEventController error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ message: "Unable to track event" });
    }
};

const GetAnalyticsOverviewController = async (req: Request, res: Response) => {
    try {
        const user = req.user;
        if (!user) {
            return res.status(HTTP_RESPONSE_CODE.UNAUTHORIZED).json({ message: "Your session has expired, login to continue" });
        }

        const params = {
            organizationId: req.query.organizationId as string | undefined,
            range: req.query.range as string | undefined,
        };

        const overview = await analyticsService.getOverviewForUser(user._id, params, {
            token: getRequestToken(req),
            cookie: req.headers.cookie,
        });
        if (!overview) {
            return res.status(HTTP_RESPONSE_CODE.NOT_FOUND).json({ message: "Organization not found or access denied" });
        }

        return res.status(HTTP_RESPONSE_CODE.OK).json({
            message: "Analytics overview fetched successfully",
            data: overview,
            success: true,
        });
    } catch (error) {
        console.error("GetAnalyticsOverviewController error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ message: "Unable to fetch analytics" });
    }
};

const GetAssistantAnalyticsController = async (req: Request, res: Response) => {
    try {
        const user = req.user;
        if (!user) {
            return res.status(HTTP_RESPONSE_CODE.UNAUTHORIZED).json({ message: "Your session has expired, login to continue" });
        }

        const { assistantId } = req.params;
        const range = req.query.range as string | undefined;

        const analytics = await analyticsService.getAssistantAnalytics(user._id, assistantId, range, {
            token: getRequestToken(req),
            cookie: req.headers.cookie,
        });
        if (!analytics) {
            return res.status(HTTP_RESPONSE_CODE.NOT_FOUND).json({ message: "Assistant not found or access denied" });
        }

        return res.status(HTTP_RESPONSE_CODE.OK).json({
            message: "Assistant analytics fetched successfully",
            data: analytics,
            success: true,
        });
    } catch (error) {
        console.error("GetAssistantAnalyticsController error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ message: "Unable to fetch assistant analytics" });
    }
};

export { TrackAnalyticsEventController, GetAnalyticsOverviewController, GetAssistantAnalyticsController };
