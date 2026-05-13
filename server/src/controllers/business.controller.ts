import { Request, Response } from "express";
import businessService from "../services/business.service";
import { HTTP_RESPONSE_CODE } from "../core/constants/values";

export class BusinessController {
    async onboard(req: Request, res: Response) {
        try {
            // Assuming user is attached by auth middleware
            const userId = (req as any).user.id;
            const business = await businessService.onboard(userId, req.body);
            return res.status(HTTP_RESPONSE_CODE.CREATED).json({
                success: true,
                data: business
            });
        } catch (error: any) {
            return res.status(HTTP_RESPONSE_CODE.BAD_REQUEST).json({
                success: false,
                message: error.message
            });
        }
    }

    async getBusiness(req: Request, res: Response) {
        try {
            const business = await businessService.getBusiness(req.params.id);
            return res.status(HTTP_RESPONSE_CODE.OK).json({
                success: true,
                data: business
            });
        } catch (error: any) {
            return res.status(HTTP_RESPONSE_CODE.NOT_FOUND).json({
                success: false,
                message: error.message
            });
        }
    }

    async getTrustScore(req: Request, res: Response) {
        try {
            const trustData = await businessService.getTrustScore(req.params.id);
            return res.status(HTTP_RESPONSE_CODE.OK).json({
                success: true,
                data: trustData
            });
        } catch (error: any) {
            return res.status(HTTP_RESPONSE_CODE.NOT_FOUND).json({
                success: false,
                message: error.message
            });
        }
    }
}

export default new BusinessController();
