import { Request, Response } from "express";
import trustService from "../services/trust.service";
import { HTTP_RESPONSE_CODE } from "../core/constants/values";

export class TrustController {
    async evaluate(req: Request, res: Response) {
        try {
            const result = await trustService.evaluateBusiness(req.params.businessId);
            return res.status(HTTP_RESPONSE_CODE.OK).json({
                success: true,
                data: result
            });
        } catch (error: any) {
            return res.status(HTTP_RESPONSE_CODE.BAD_REQUEST).json({
                success: false,
                message: error.message
            });
        }
    }

    async getHistory(req: Request, res: Response) {
        try {
            const history = await trustService.getTrustHistory(req.params.businessId);
            return res.status(HTTP_RESPONSE_CODE.OK).json({
                success: true,
                data: history
            });
        } catch (error: any) {
            return res.status(HTTP_RESPONSE_CODE.NOT_FOUND).json({
                success: false,
                message: error.message
            });
        }
    }
}

export default new TrustController();
