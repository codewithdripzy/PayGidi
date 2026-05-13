import TransactionModel from '../../models/transaction.model';
import { NotFoundError } from '../../core/errors/app-error';

export class TransactionApplicationService {
  async getTransactionDetails(transactionId: string) {
    const transaction = await TransactionModel.findById(transactionId)
      .populate('buyerId', 'name email')
      .populate('merchantId', 'name email');
      
    if (!transaction) {
      throw new NotFoundError('Transaction not found');
    }
    return transaction;
  }

  async getUserTransactions(userId: string) {
    return TransactionModel.find({
      $or: [{ buyerId: userId }, { merchantId: userId }]
    }).sort({ createdAt: -1 });
  }

  async getPendingAdminTransactions() {
    return TransactionModel.find({ status: 'pending' })
      .populate('buyerId', 'name email')
      .populate('merchantId', 'name email');
  }
}

export const transactionApplicationService = new TransactionApplicationService();
