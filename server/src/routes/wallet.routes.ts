import { Router } from 'express';
import * as walletController from '../controllers/wallet.controller';
import { authenticate } from '../middleware/auth.middleware';
import {
  positiveAmount,
  requireBodyFields,
} from '../middleware/validation.middleware';
const walletRouter = Router();
walletRouter.get('/banks', walletController.banks);
walletRouter.post(
  '/transfer/lookup',
  requireBodyFields('bank_code', 'account_number'),
  walletController.lookup,
);
walletRouter.get('/payments/:payment_id', walletController.payment);
walletRouter.post('/webhook/squad', walletController.webhook);
walletRouter.use(authenticate);
walletRouter.get('/', walletController.getWallet);
walletRouter.post(
  '/transfer',
  requireBodyFields('bank_code', 'account_number', 'amount'),
  walletController.transfer,
);
walletRouter.get('/transfer/list', walletController.transferList);
walletRouter.post('/transfer/requery', walletController.requery);
walletRouter.get('/disputes', walletController.disputes);
walletRouter.get(
  '/disputes/upload-url/:ticketId/:fileName',
  walletController.disputeUpload,
);
walletRouter.post(
  '/disputes/:ticketId/resolve',
  walletController.resolveDispute,
);
walletRouter.post('/create', walletController.createWallet);
walletRouter.get('/balance', walletController.balance);
walletRouter.post(
  '/payments/new',
  positiveAmount,
  requireBodyFields('accountNumber', 'bank', 'merchantPhoneNumber', 'email'),
  walletController.newPayment,
);
walletRouter.get('/finance/summary', walletController.financeSummary);
walletRouter.get('/finance/savings', walletController.listSavings);
walletRouter.post('/finance/savings', walletController.createSavings);
walletRouter.put('/finance/savings/:id', walletController.updateSavings);
walletRouter.delete('/finance/savings/:id', walletController.deleteSavings);
walletRouter.get('/finance/thrifts', walletController.listThrifts);
walletRouter.post('/finance/thrifts', walletController.createThrift);
walletRouter.post('/finance/thrifts/:id/join', walletController.joinThrift);
walletRouter.post(
  '/deposit/simulate',
  positiveAmount,
  walletController.simulateDeposit,
);
walletRouter.get(
  '/:accountNumber/transactions',
  walletController.getTransactions,
);
walletRouter.get('/:accountNumber', walletController.getWallet);
export default walletRouter;
