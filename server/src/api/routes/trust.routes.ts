import { Router } from 'express';
import { trustController } from '../controllers/trust.controller';
import { authenticate, authorize } from '../middlewares/auth.middleware';

const router = Router();

// Only admins can trigger evaluation or view full history for any business
router.post('/evaluate/:businessId', authenticate, authorize(['admin']), trustController.evaluate);
router.get('/history/:businessId', authenticate, trustController.getHistory);

export default router;
