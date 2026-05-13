import { Router } from 'express';
import { walletController } from '../controllers/wallet.controller';
import { authenticate } from '../middlewares/auth.middleware';
import { escrowLimiter } from '../middlewares/rate-limit.middleware';
import { validate } from '../middlewares/validate.middleware';
import { fundSchema, createEscrowSchema } from '../validators/wallet.validator';

const router = Router();

router.post('/fund', authenticate, validate(fundSchema), walletController.fund);
router.post('/escrow/create', authenticate, escrowLimiter, validate(createEscrowSchema), walletController.createEscrow);
router.post('/escrow/release/:transactionId', authenticate, walletController.releaseEscrow);

export default router;
