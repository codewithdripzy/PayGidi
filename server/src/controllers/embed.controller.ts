import { Request, Response } from "express";
import { HTTP_RESPONSE_CODE } from "../core/constants/values";
import { verifyApiKey } from "../utils/generator";
import assistantService from "../services/assistant.service";
import apiKeyService from "../services/api-key.service";
import voiceAiService from "../services/voice-ai.service";

const GetPublicAssistantController = async (req: Request, res: Response) => {
    try {
        const { assistantId } = req.params;
        const assistant = await assistantService.getAssistantByWidgetKey(assistantId);
        if (!assistant) {
            return res.status(HTTP_RESPONSE_CODE.NOT_FOUND).json({
                message: "Assistant not found",
                success: false,
            });
        }

        const voiceAiConfig = await voiceAiService.getConfig(String(assistant.organization));

        const safeAssistant = {
            uid: assistant.uid,
            name: assistant.name,
            description: assistant.description,
            firstMessage: assistant.firstMessage,
            voiceId: assistant.voiceId,
            status: assistant.status,
            metadata: {
                personality: assistant.metadata?.personality ?? {
                    tone: "support",
                    responseStyle: "balanced",
                },
                ai: assistant.metadata?.generation ?? {
                    provider: "openai",
                    model: "gpt-4o",
                },
                voiceAiConfig: voiceAiConfig ? {
                    voiceProviders: voiceAiConfig.voiceProviders,
                    aiProviders: voiceAiConfig.aiProviders,
                } : undefined,
            },
            accessControl: assistant.accessControl ?? {
                allowedDomains: ["*"],
                blockedRoutes: [],
            },
            deployment: {
                widgetKey: assistant.deployment?.widgetKey,
            },
            organizationId: assistant.organization,
        };

        return res.status(HTTP_RESPONSE_CODE.OK).json({
            message: "Assistant details fetched successfully",
            data: safeAssistant,
            success: true,
        });
    } catch (error) {
        console.error("GetPublicAssistantController error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({
            message: "Unable to fetch assistant details",
            success: false,
        });
    }
};

const VerifyEmbedController = async (req: Request, res: Response) => {
    try {
        const assistantId = (req.params.assistantId || req.body.assistantId || req.query.assistantId) as string;
        const apiKey = (req as any).apiKey;

        if (!assistantId) {
            return res.status(HTTP_RESPONSE_CODE.BAD_REQUEST).json({
                message: "Assistant ID is required",
                success: false
            });
        }

        const decoded = verifyApiKey(apiKey);
        if (!decoded) {
            return res.status(HTTP_RESPONSE_CODE.UNAUTHORIZED).json({
                message: "Invalid API key format",
                success: false
            });
        }

        // Verify the key exists and is active in the database
        const dbKey = await apiKeyService.getApiKeyByKey(apiKey);
        if (!dbKey) {
            return res.status(HTTP_RESPONSE_CODE.UNAUTHORIZED).json({
                message: "API key is revoked or does not exist",
                success: false
            });
        }

        // Update last used at
        await apiKeyService.recordKeyUsage(apiKey);

        const assistant = await assistantService.getPublicAssistantByUidAndOrg(assistantId, dbKey.organization);
        if (!assistant) {
            return res.status(HTTP_RESPONSE_CODE.NOT_FOUND).json({
                message: "Assistant not found or inactive",
                success: false
            });
        }

        const voiceAiConfig = await voiceAiService.getConfig(String(assistant.organization));

        return res.status(HTTP_RESPONSE_CODE.OK).json({
            message: "Embedding is valid",
            data: {
                ...assistant.toJSON(),
                voiceAiConfig: voiceAiConfig ? {
                    voiceProviders: voiceAiConfig.voiceProviders,
                    aiProviders: voiceAiConfig.aiProviders,
                } : undefined
            },
            success: true,
        });
    } catch (error) {
        console.error("VerifyEmbedController error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({
            message: "Unable to verify embedding",
            success: false
        });
    }
};

export {
    GetPublicAssistantController,
    VerifyEmbedController,
};
