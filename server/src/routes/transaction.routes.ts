import { Router } from 'express';
import { customerTransactions } from '../controllers/transaction.controller';
import { authenticate } from '../middleware/auth.middleware';
const transactionRouter = Router();
transactionRouter.get('/', authenticate, customerTransactions);
export default transactionRouter;
