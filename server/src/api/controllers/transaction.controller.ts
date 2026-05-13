import { Request, Response, NextFunction } from 'express';
import { transactionApplicationService } from '../../application/services/transaction.application.service';
import { UnauthorizedError } from '../../core/errors/app-error';

export class TransactionController {
  async getDetails(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const transaction = await transactionApplicationService.getTransactionDetails(id);
      
      return res.status(200).json({
        success: true,
        data: transaction
      });
    } catch (error) {
      next(error);
    }
  }

  async getMyTransactions(req: Request, res: Response, next: NextFunction) {
    try {
      const user = (req as any).user;
      if (!user) throw new UnauthorizedError();

      const transactions = await transactionApplicationService.getUserTransactions(user.userId);
      
      return res.status(200).json({
        success: true,
        data: transactions
      });
    } catch (error) {
      next(error);
    }
  }
}

export const transactionController = new TransactionController();
