import { Request, Response } from "express";
import { HTTP_RESPONSE_CODE } from "../core/constants/values";
import apiKeyService from "../services/api-key.service";

const ListOrganizationApiKeysController = async (req: Request, res: Response) => {
    try {
        const user = req.user;
        if (!user) {
            return res.status(HTTP_RESPONSE_CODE.UNAUTHORIZED).json({ message: "Your session has expired", success: false });
        }

        const { organizationId } = req.params;
        const apiKeys = await apiKeyService.listApiKeys(organizationId);

        return res.status(HTTP_RESPONSE_CODE.OK).json({
            message: "API keys fetched successfully",
            data: apiKeys,
            success: true,
        });
    } catch (error) {
        console.error("ListOrganizationApiKeysController error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ message: "Unable to fetch API keys", success: false });
    }
};

const CreateOrganizationApiKeyController = async (req: Request, res: Response) => {
    try {
        const user = req.user;
        if (!user) {
            return res.status(HTTP_RESPONSE_CODE.UNAUTHORIZED).json({ message: "Your session has expired", success: false });
        }

        const { organizationId } = req.params;
        const { name } = req.body;

        if (!name) {
            return res.status(HTTP_RESPONSE_CODE.BAD_REQUEST).json({ message: "API key name is required", success: false });
        }

        const apiKey = await apiKeyService.createApiKey(organizationId, name, user._id as string);

        return res.status(HTTP_RESPONSE_CODE.CREATED).json({
            message: "API key created successfully",
            data: apiKey,
            success: true,
        });
    } catch (error) {
        console.error("CreateOrganizationApiKeyController error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ message: "Unable to create API key", success: false });
    }
};

const RevokeOrganizationApiKeyController = async (req: Request, res: Response) => {
    try {
        const user = req.user;
        if (!user) {
            return res.status(HTTP_RESPONSE_CODE.UNAUTHORIZED).json({ message: "Your session has expired", success: false });
        }

        const { organizationId, keyUid } = req.params;
        await apiKeyService.revokeApiKey(keyUid, organizationId);

        return res.status(HTTP_RESPONSE_CODE.OK).json({
            message: "API key revoked successfully",
            success: true,
        });
    } catch (error) {
        console.error("RevokeOrganizationApiKeyController error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ message: "Unable to revoke API key", success: false });
    }
};

export {
    ListOrganizationApiKeysController,
    CreateOrganizationApiKeyController,
    RevokeOrganizationApiKeyController,
};
