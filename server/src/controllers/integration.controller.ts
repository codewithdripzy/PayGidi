import { Request, Response } from "express";
import { HTTP_RESPONSE_CODE } from "../core/constants/values";
import integrationService from "../services/integration.service";

const ListIntegrationsController = async (_req: Request, res: Response) => {
    try {
        const integrations = integrationService.listIntegrations();

        return res.status(HTTP_RESPONSE_CODE.OK).json({
            message: `Integrations fetched successfully - (${integrations.length}) row(s)`,
            data: integrations,
            success: true,
        });
    } catch (error) {
        console.error("ListIntegrationsController error:", error);

        return res.status(HTTP_RESPONSE_CODE.INTERNAL_SERVER_ERROR).json({
            message: "Unable to fetch integrations",
            success: false,
        });
    }
};

export { ListIntegrationsController };
