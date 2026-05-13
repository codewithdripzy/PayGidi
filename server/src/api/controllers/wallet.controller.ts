import { Request, Response, NextFunction } from 'express';
import { walletApplicationService } from '../../application/services/wallet.application.service';
import { UnauthorizedError } from '../../core/errors/app-error';

export class WalletController {
  async fund(req: Request, res: Response, next: NextFunction) {
    try {
      const { amount } = req.body;
      const user = (req as any).user;

      if (!user) throw new UnauthorizedError();

      const result = await walletApplicationService.initiateFunding(user.userId, user.email, amount);
      
      return res.status(200).json({
        success: true,
        data: result
      });
    } catch (error) {
      next(error);
    }
  }

  async createEscrow(req: Request, res: Response, next: NextFunction) {
    try {
      const { merchantId, amount } = req.body;
      const user = (req as any).user;

      if (!user) throw new UnauthorizedError();

      const transaction = await walletApplicationService.createEscrow(user.userId, merchantId, amount);
      
      return res.status(201).json({
        success: true,
        data: transaction
      });
    } catch (error) {
      next(error);
    }
  }

  async releaseEscrow(req: Request, res: Response, next: NextFunction) {
    try {
      const { transactionId } = req.params;
      
      const transaction = await walletApplicationService.releaseEscrow(transactionId);
      
      return res.status(200).json({
        success: true,
        data: transaction
      });
    } catch (error) {
      next(error);
    }
  }
}

export const walletController = new WalletController();
