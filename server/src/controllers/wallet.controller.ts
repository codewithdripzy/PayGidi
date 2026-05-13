import { Request, Response } from "express";
import walletService from "../services/wallet.service";
import { HTTP_RESPONSE_CODE } from "../core/constants/values";

export class WalletController {
    async fund(req: Request, res: Response) {
        try {
            const userId = (req as any).user.id;
            const { amount, paymentMethod } = req.body;
            const result = await walletService.fundWallet(userId, amount, paymentMethod);
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
}

export class EscrowController {
    async create(req: Request, res: Response) {
        try {
            const buyerId = (req as any).user.id;
            const { merchantId, amount } = req.body;
            const transaction = await walletService.createEscrow(buyerId, merchantId, amount);
            return res.status(HTTP_RESPONSE_CODE.CREATED).json({
                success: true,
                data: transaction
            });
        } catch (error: any) {
            return res.status(HTTP_RESPONSE_CODE.BAD_REQUEST).json({
                success: false,
                message: error.message
            });
        }
    }

    async release(req: Request, res: Response) {
        try {
            const transaction = await walletService.releaseEscrow(req.params.transactionId);
            return res.status(HTTP_RESPONSE_CODE.OK).json({
                success: true,
                data: transaction
            });
        } catch (error: any) {
            return res.status(HTTP_RESPONSE_CODE.BAD_REQUEST).json({
                success: false,
                message: error.message
            });
        }
    }

    async refund(req: Request, res: Response) {
        try {
            const transaction = await walletService.refundEscrow(req.params.transactionId);
            return res.status(HTTP_RESPONSE_CODE.OK).json({
                success: true,
                data: transaction
            });
        } catch (error: any) {
            return res.status(HTTP_RESPONSE_CODE.BAD_REQUEST).json({
                success: false,
                message: error.message
            });
        }
    }
}

export default {
    wallet: new WalletController(),
    escrow: new EscrowController(),
};
