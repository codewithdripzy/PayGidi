import { Router } from 'express';
import { newPayment, payment } from '../controllers/wallet.controller';
import { authenticate } from '../middleware/auth.middleware';
import { positiveAmount } from '../middleware/validation.middleware';
import { requireBodyFields } from '../middleware/validation.middleware';

const paymentRouter = Router();

paymentRouter.get('/:payment_id', payment);
paymentRouter.post(
  '/new',
  authenticate,
  positiveAmount,
  requireBodyFields('accountNumber', 'bank', 'merchantPhoneNumber', 'email'),
  newPayment,
);

export default paymentRouter;
