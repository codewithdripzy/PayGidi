import { Response } from 'express';
import Payment from '../models/payment.model';
import SavingsGoal from '../models/savings-goal.model';
import Thrift from '../models/thrift.model';
import Transaction from '../models/transaction.model';
import Wallet from '../models/wallet.model';
import WebhookTransaction from '../models/webhook-transaction.model';
import { AuthRequest } from '../middleware/auth.middleware';
import { fail, ok } from '../utils/response';
import squadService from '../services/squad.service';
import crypto from 'crypto';
const userId = (req: AuthRequest) => req.user._id;
const providerData = (value: any) => value?.data ?? value;
export async function getWallet(req: AuthRequest, res: Response) {
  const query: any = { userId: userId(req) };
  if (req.params.accountNumber) query.accountNumber = req.params.accountNumber;
  const wallet = await Wallet.findOne(query);
  if (!wallet) return fail(res, 'Account not found', 404);

  if (!wallet.providerAccountNumber)
    return fail(res, 'Virtual account not configured', 404);

  try {
    const providerWallet = await squadService.getVirtualAccount(
      wallet.providerAccountNumber,
    );
    return ok(res, providerData(providerWallet));
  } catch (error: any) {
    return fail(res, error.message, error.statusCode || 502);
  }
}
export async function getTransactions(req: AuthRequest, res: Response) {
  const wallet: any = await Wallet.findOne({
    userId: userId(req),
    accountNumber: req.params.accountNumber,
  });
  if (!wallet) return fail(res, 'Account not found', 404);
  try {
    return ok(
      res,
      await squadService.getCustomerTransactions(wallet.customerIdentifier),
    );
  } catch (error: any) {
    return fail(res, error.message, error.statusCode || 502);
  }
}
export async function balance(req: AuthRequest, res: Response) {
  const wallets = await Wallet.find({ userId: userId(req) });
  return ok(res, {
    totalBalance: wallets.reduce((sum, w: any) => sum + (w.balance || 0), 0),
    currency: 'NGN',
  });
}
export async function createWallet(req: AuthRequest, res: Response) {
  const existing = await Wallet.findOne({ userId: userId(req) });
  if (existing) return ok(res, existing, 'Wallet already exists');

  const body = req.body || {};
  const phone = String(body.phone || req.user.phone || '')
    .replace(/\s/g, '')
    .replace(/^\+/, '');
  const mobileNumber = phone.startsWith('234')
    ? `0${phone.slice(3)}`
    : phone.length === 10
      ? `0${phone}`
      : phone.slice(-11);
  const payload = {
    first_name: body.firstName || body.firstname || req.user.firstName || '',
    middle_name:
      body.middleName || body.middlename || req.user.middleName || '',
    last_name: body.lastName || body.lastname || req.user.lastName || '',
    mobile_num: mobileNumber,
    dob: body.dateOfBirth || '',
    bvn: body.bvn || body.nin || '',
    customer_identifier: String(userId(req)),
    gender: body.gender || '',
    email: body.email || req.user.email || '',
    address: body.address || '',
    beneficiary_account: process.env.SQUAD_BENEFICIARY_ACCOUNT || '',
  };
  const data = providerData(
    req.user.accountType === 'business'
      ? await squadService.createBusinessVirtualAccount({
          business_name: body.businessName || req.user.name,
          customer_identifier: String(userId(req)),
          mobile_num: mobileNumber,
          bvn: payload.bvn,
          beneficiary_account: payload.beneficiary_account,
        })
      : await squadService.createVirtualAccount(payload),
  );
  const wallet = await Wallet.create({
    userId: userId(req),
    provider: 'squad',
    providerAccountNumber: data.virtual_account_number,
    accountNumber: mobileNumber.slice(-10),
    accountType: req.user.accountType,
    currency: 'NGN',
    status: 'active',
    customerIdentifier: data.customer_identifier,
    accountReference: data.customer_identifier,
  });
  return ok(res, wallet, 'Wallet created successfully', 201);
}
export async function banks(_req: AuthRequest, res: Response) {
  return ok(res, await squadService.getBanks());
}
export async function lookup(req: AuthRequest, res: Response) {
  try {
    return ok(
      res,
      await squadService.resolveAccount({
        bank_code: req.body.bank_code,
        account_number: req.body.account_number,
      }),
      'Success',
    );
  } catch (error: any) {
    return fail(res, error.message, error.statusCode || 502);
  }
}
export async function newPayment(req: AuthRequest, res: Response) {
  const payment = await Payment.create({
    ...req.body,
    userId: String(userId(req)),
    amount: Number(req.body.amount),
    status: 'pending',
    expiresAt: req.body.expiresInMinutes
      ? new Date(Date.now() + Number(req.body.expiresInMinutes) * 60000)
      : undefined,
  });
  return ok(
    res,
    { payment_id: payment._id, status: payment.status },
    'Payment locked successfully. Notification sent to merchant.',
    201,
  );
}
export async function payment(req: AuthRequest, res: Response) {
  const item = await Payment.findById(req.params.payment_id);
  if (!item) return fail(res, 'Payment not found', 404);
  return ok(res, item);
}
export async function simulateDeposit(req: AuthRequest, res: Response) {
  const wallet = await Wallet.findOne({ userId: userId(req) });
  if (!wallet) return fail(res, 'Wallet not found', 404);
  const result = await squadService.simulatePayment({
    virtual_account_number: wallet.providerAccountNumber,
    amount: String(req.body.amount || ''),
  });
  return ok(res, result, 'Payment simulated successfully');
}
export async function transfer(req: AuthRequest, res: Response) {
  const reference = req.body.transactionReference || `TRF-${Date.now()}`;
  try {
    return ok(
      res,
      await squadService.initiateTransfer({
        ...req.body,
        transaction_reference: reference,
        currency_id: req.body.currency_id || 'NGN',
      }),
      'Transfer initiated',
      202,
    );
  } catch (error: any) {
    return fail(res, error.message, error.statusCode || 502);
  }
}
export async function transferList(_req: AuthRequest, res: Response) {
  return ok(res, await squadService.getTransfers());
}
export async function requery(req: AuthRequest, res: Response) {
  try {
    return ok(
      res,
      await squadService.requeryTransfer(req.body.transactionReference),
    );
  } catch (error: any) {
    return fail(res, error.message, error.statusCode || 502);
  }
}
export async function disputes(_req: AuthRequest, res: Response) {
  return ok(res, await squadService.getDisputes());
}
export async function disputeUpload(req: AuthRequest, res: Response) {
  try {
    return ok(
      res,
      await squadService.getDisputeUploadUrl(
        req.params.ticketId,
        req.params.fileName,
      ),
    );
  } catch (error: any) {
    return fail(res, error.message, error.statusCode || 502);
  }
}
export async function resolveDispute(req: AuthRequest, res: Response) {
  try {
    return ok(
      res,
      await squadService.resolveDispute(req.params.ticketId, req.body),
    );
  } catch (error: any) {
    return fail(res, error.message, error.statusCode || 502);
  }
}
export async function webhook(req: AuthRequest, res: Response) {
  const rawBody = (req as AuthRequest & { rawBody?: Buffer }).rawBody;
  const signature = String(req.headers['x-squad-signature'] || '');
  const secret = process.env.SQUAD_SECRET_KEY || '';

  if (!rawBody || !secret || !signature)
    return fail(res, 'Invalid webhook signature', 401);

  const payload = req.body as Record<string, string>;
  const v1 = crypto.createHmac('sha512', secret).update(rawBody).digest('hex');
  const v3Payload = [
    payload.transaction_reference,
    payload.virtual_account_number,
    payload.currency,
    payload.principal_amount,
    payload.settled_amount,
    payload.customer_identifier,
  ].join('|');
  const v3 = crypto
    .createHmac('sha512', secret)
    .update(v3Payload)
    .digest('hex');
  const isValid = [v1, v3].some(
    (expected) =>
      expected.length === signature.length &&
      crypto.timingSafeEqual(Buffer.from(expected), Buffer.from(signature)),
  );
  if (!isValid) return fail(res, 'Invalid webhook signature', 401);

  const reference = payload.transaction_reference;
  if (!reference) return fail(res, 'Transaction reference is required');
  let record: any;

  try {
    record = await WebhookTransaction.create({
      transactionReference: reference,
      virtualAccountNumber: payload.virtual_account_number,
      customerIdentifier: payload.customer_identifier,
      principalAmount: Number(payload.principal_amount || 0),
      settledAmount: Number(payload.settled_amount || 0),
      feeCharged: Number(payload.fee_charged || 0),
      currency: payload.currency,
      senderName: payload.sender_name,
      transactionDate: payload.transaction_date,
      channel: payload.channel,
      remarks: payload.remarks,
      transactionUuid: payload.transaction_uuid,
      rawPayload: payload,
    });
  } catch (error: any) {
    if (error?.code === 11000)
      return ok(res, { received: true, duplicate: true }, 'duplicate');
    throw error;
  }

  const wallet = await Wallet.findOne({
    providerAccountNumber: record.virtualAccountNumber,
  });
  if (!wallet) {
    record.status = 'failed';
    record.failureReason = 'No matching wallet account found';
    await record.save();
    return fail(res, 'Wallet account not found', 404);
  }

  record.status = 'processing';
  await record.save();
  await Wallet.updateOne(
    { _id: wallet._id },
    { $inc: { balance: Math.round(record.settledAmount * 100) / 100 } },
  );
  record.status = 'completed';
  record.processedAt = new Date();
  await record.save();
  return ok(res, { received: true }, 'ok');
}
export async function financeSummary(req: AuthRequest, res: Response) {
  const [wallet, savings, thrifts] = await Promise.all([
    Wallet.find({ userId: userId(req) }),
    SavingsGoal.find({ userId: userId(req) }),
    Thrift.find({
      $or: [{ creatorId: userId(req) }, { 'members.userId': userId(req) }],
    }),
  ]);
  return ok(res, {
    balance: wallet.reduce((n: number, w: any) => n + (w.balance || 0), 0),
    savings,
    thrifts,
  });
}
export async function listSavings(req: AuthRequest, res: Response) {
  return ok(
    res,
    await SavingsGoal.find({ userId: userId(req) }).sort({ createdAt: -1 }),
  );
}
export async function createSavings(req: AuthRequest, res: Response) {
  return ok(
    res,
    await SavingsGoal.create({
      ...req.body,
      userId: userId(req),
      currency: req.body.currency || 'NGN',
    }),
    'Savings goal created successfully',
    201,
  );
}
export async function updateSavings(req: AuthRequest, res: Response) {
  const item = await SavingsGoal.findOneAndUpdate(
    { _id: req.params.id, userId: userId(req) },
    { $set: req.body },
    { new: true },
  );
  return item
    ? ok(res, item, 'Savings goal updated successfully')
    : fail(res, 'Savings goal not found', 404);
}
export async function deleteSavings(req: AuthRequest, res: Response) {
  const result = await SavingsGoal.deleteOne({
    _id: req.params.id,
    userId: userId(req),
  });
  return result.deletedCount
    ? ok(res, {})
    : fail(res, 'Savings goal not found', 404);
}
export async function listThrifts(req: AuthRequest, res: Response) {
  return ok(
    res,
    await Thrift.find({
      $or: [
        { creatorId: userId(req) },
        { isPublic: true },
        { 'members.userId': userId(req) },
      ],
    }).sort({ createdAt: -1 }),
  );
}
export async function createThrift(req: AuthRequest, res: Response) {
  return ok(
    res,
    await Thrift.create({
      ...req.body,
      creatorId: userId(req),
      currentMembers: 1,
      members: [
        { userId: userId(req), status: 'active', joinedAt: new Date() },
      ],
    }),
    'Thrift created successfully',
    201,
  );
}
export async function joinThrift(req: AuthRequest, res: Response) {
  const thrift: any = await Thrift.findById(req.params.id);
  if (!thrift) return fail(res, 'Thrift not found', 404);
  if (thrift.maxMembers && thrift.currentMembers >= thrift.maxMembers)
    return fail(res, 'Thrift is full');
  thrift.members.push({
    userId: userId(req),
    status: 'active',
    joinedAt: new Date(),
  });
  thrift.currentMembers += 1;
  await thrift.save();
  return ok(res, thrift, 'Joined thrift successfully');
}
