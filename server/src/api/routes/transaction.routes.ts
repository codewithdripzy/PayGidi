import { Router } from 'express';
import { transactionController } from '../controllers/transaction.controller';
import { authenticate } from '../middlewares/auth.middleware';

const router = Router();

router.get('/my', authenticate, transactionController.getMyTransactions);
router.get('/:id', authenticate, transactionController.getDetails);

export default router;
