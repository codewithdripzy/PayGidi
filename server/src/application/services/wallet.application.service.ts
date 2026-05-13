import WalletModel from '../../models/wallet.model';
import TransactionModel from '../../models/transaction.model';
import BusinessModel from '../../models/business.model';
import { squadService } from '../../infrastructure/payments/squad.service';
import { BadRequestError, NotFoundError } from '../../core/errors/app-error';
import logger from '../../infrastructure/logging/logger';

export class WalletApplicationService {
  async initiateFunding(userId: string, email: string, amount: number) {
    const transactionRef = `WAL-${userId}-${Date.now()}`;
    
    try {
      const squadData = await squadService.initiateTransaction({
        amount,
        email,
        currency: 'NGN',
        transaction_ref: transactionRef,
      });

      return {
        transactionRef,
        checkoutUrl: squadData.checkout_url,
      };
    } catch (error: any) {
      logger.error(`Failed to initiate funding for user ${userId}`, error);
      throw new BadRequestError('Could not initiate payment. Please try again later.');
    }
  }

  async createEscrow(buyerId: string, merchantId: string, amount: number) {
    const wallet = await WalletModel.findOne({ userId: buyerId });
    if (!wallet || wallet.balance < amount) {
      throw new BadRequestError('Insufficient balance in wallet');
    }

    // Atomically lock funds (simplified for now, ideally use mongo transactions)
    wallet.balance -= amount;
    wallet.escrowBalance += amount;
    await wallet.save();

    const merchantBusiness = await BusinessModel.findOne({ userId: merchantId });
    const trustScoreSnapshot = merchantBusiness?.trustScore || 0;

    const transaction = await TransactionModel.create({
      buyerId,
      merchantId,
      amount,
      status: 'pending',
      trustScoreSnapshot,
    });

    logger.info(`Escrow created: ${transaction._id} for buyer ${buyerId}`);
    return transaction;
  }

  async releaseEscrow(transactionId: string) {
    const transaction = await TransactionModel.findById(transactionId);
    if (!transaction || transaction.status !== 'pending') {
      throw new BadRequestError('Invalid transaction or status');
    }

    const buyerWallet = await WalletModel.findOne({ userId: transaction.buyerId });
    let merchantWallet = await WalletModel.findOne({ userId: transaction.merchantId });

    if (!buyerWallet || buyerWallet.escrowBalance < transaction.amount) {
      throw new Error('Invalid wallet state: buyer escrow balance mismatch');
    }

    if (!merchantWallet) {
      merchantWallet = await WalletModel.create({ 
        userId: transaction.merchantId, 
        balance: 0, 
        escrowBalance: 0 
      });
    }

    // Release funds
    buyerWallet.escrowBalance -= transaction.amount;
    merchantWallet.balance += transaction.amount;

    await buyerWallet.save();
    await merchantWallet.save();

    transaction.status = 'released';
    await transaction.save();

    logger.info(`Escrow released: ${transactionId} to merchant ${transaction.merchantId}`);
    return transaction;
  }
}

export const walletApplicationService = new WalletApplicationService();
