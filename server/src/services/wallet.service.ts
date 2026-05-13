import WalletModel from "../models/wallet.model";
import TransactionModel from "../models/transaction.model";
import BusinessModel from "../models/business.model";
import axios from "axios";

export class WalletService {
    private readonly squadSecretKey = process.env.SQUAD_SECRET_KEY;
    private readonly squadBaseUrl = "https://sandbox-api-d.squadco.com"; // Default to sandbox

    async fundWallet(userId: string, amount: number, paymentMethod: string) {
        // Here we would call Squad API to initiate payment
        // For now, let's mock it
        const reference = `WAL-${Date.now()}`;
        
        // Mocking Squad API call
        /*
        const response = await axios.post(`${this.squadBaseUrl}/transaction/initiate`, {
            amount: amount * 100, // Squad uses kobo
            email: userEmail,
            currency: "NGN",
            initiate_type: "inline",
            transaction_ref: reference
        }, {
            headers: { Authorization: `Bearer ${this.squadSecretKey}` }
        });
        */

        return {
            reference,
            paymentUrl: "https://checkout.squadco.com/pay/mock-url",
        };
    }

    async createEscrow(buyerId: string, merchantId: string, amount: number) {
        const wallet = await WalletModel.findOne({ userId: buyerId });
        if (!wallet || wallet.balance < amount) {
            throw new Error("Insufficient balance in wallet");
        }

        // Lock funds
        wallet.balance -= amount;
        wallet.escrowBalance += amount;
        await wallet.save();

        const merchantBusiness = await BusinessModel.findOne({ userId: merchantId });
        const trustScoreSnapshot = merchantBusiness?.trustScore || 0;

        const transaction = await TransactionModel.create({
            buyerId,
            merchantId,
            amount,
            status: "pending",
            trustScoreSnapshot,
        });

        return transaction;
    }

    async releaseEscrow(transactionId: string) {
        const transaction = await TransactionModel.findById(transactionId);
        if (!transaction || transaction.status !== "pending") {
            throw new Error("Invalid transaction or status");
        }

        const buyerWallet = await WalletModel.findOne({ userId: transaction.buyerId });
        const merchantWallet = await WalletModel.findOne({ userId: transaction.merchantId });

        if (!buyerWallet || buyerWallet.escrowBalance < transaction.amount) {
            throw new Error("Invalid wallet state");
        }

        if (!merchantWallet) {
            // Create merchant wallet if it doesn't exist
            await WalletModel.create({ userId: transaction.merchantId, balance: 0, escrowBalance: 0 });
        }

        // Release funds
        buyerWallet.escrowBalance -= transaction.amount;
        merchantWallet!.balance += transaction.amount;

        await buyerWallet.save();
        await merchantWallet!.save();

        transaction.status = "released";
        await transaction.save();

        return transaction;
    }

    async refundEscrow(transactionId: string) {
        const transaction = await TransactionModel.findById(transactionId);
        if (!transaction || transaction.status !== "pending") {
            throw new Error("Invalid transaction or status");
        }

        const buyerWallet = await WalletModel.findOne({ userId: transaction.buyerId });
        if (!buyerWallet || buyerWallet.escrowBalance < transaction.amount) {
            throw new Error("Invalid wallet state");
        }

        // Refund funds
        buyerWallet.escrowBalance -= transaction.amount;
        buyerWallet.balance += transaction.amount;

        await buyerWallet.save();

        transaction.status = "refunded";
        await transaction.save();

        return transaction;
    }
}

export default new WalletService();
