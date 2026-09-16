import { Response } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import Transaction from '../models/transaction.model';
import Wallet from '../models/wallet.model';
import { ok } from '../utils/response';
import axios from 'axios';
export async function customerTransactions(req: AuthRequest, res: Response) {
  const wallets: any[] = await Wallet.find({ userId: req.user._id });
  const local = await Transaction.find({
    $or: [
      { userId: String(req.user._id) },
      { buyerId: String(req.user._id) },
      { merchantId: String(req.user._id) },
    ],
  }).sort({ createdAt: -1 });
  const customerIds = wallets.map((w) => w.customerIdentifier).filter(Boolean);
  if (!customerIds.length || !process.env.SQUAD_SECRET_KEY)
    return ok(res, local);
  try {
    const base =
      process.env.SQUAD_API_URL || 'https://sandbox-api-d.squadco.com';
    const responses = await Promise.all(
      customerIds.map((id) =>
        axios
          .get(`${base}/virtual-account/customer/transactions/${id}`, {
            headers: {
              Authorization: `Bearer ${process.env.SQUAD_SECRET_KEY}`,
            },
          })
          .then((r) => r.data?.data || [])
          .catch(() => []),
      ),
    );
    return ok(res, responses.flat(), 'Success');
  } catch {
    return ok(res, local);
  }
}
