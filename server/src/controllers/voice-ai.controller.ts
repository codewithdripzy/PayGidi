import { Request, Response } from "express";
import fs from "fs";
import path from "path";
import { HTTP_RESPONSE_CODE } from "../core/constants/values";
import voiceAiService from "../services/voice-ai.service";

const ListAiProvidersController = async (req: Request, res: Response) => {
    try {
        const providersPath = path.join(__dirname, "../data/providers.json");
        const providers = JSON.parse(fs.readFileSync(providersPath, "utf8"));
        
        return res.status(HTTP_RESPONSE_CODE.OK).json({
            message: "AI Providers fetched successfully",
            data: providers,
            success: true,
        });
    } catch (error) {
        console.error("ListAiProvidersController error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ 
            message: "Unable to fetch AI Providers",
            success: false 
        });
    }
};

const GetVoiceAiConfigController = async (req: Request, res: Response) => {
    try {
        const { organizationId } = req.params;
        const config = await voiceAiService.getConfig(organizationId);
        
        return res.status(HTTP_RESPONSE_CODE.OK).json({
            message: "Voice & AI configuration fetched successfully",
            data: config,
            success: true,
        });
    } catch (error) {
        console.error("GetVoiceAiConfigController error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ 
            message: "Unable to fetch Voice & AI configuration",
            success: false 
        });
    }
};

const UpdateVoiceAiConfigController = async (req: Request, res: Response) => {
    try {
        const { organizationId } = req.params;
        const config = await voiceAiService.updateConfig(organizationId, req.body);
        
        return res.status(HTTP_RESPONSE_CODE.OK).json({
            message: "Voice & AI configuration updated successfully",
            data: config,
            success: true,
        });
    } catch (error) {
        console.error("UpdateVoiceAiConfigController error:", error);
        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({ 
            message: "Unable to update Voice & AI configuration",
            success: false 
        });
    }
};

export {
    ListAiProvidersController,
    GetVoiceAiConfigController,
    UpdateVoiceAiConfigController,
};
