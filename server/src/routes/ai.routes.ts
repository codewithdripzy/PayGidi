import { Router } from 'express';
import * as c from '../controllers/ai.controller';
const aiRouter = Router();
aiRouter.post('/submit', c.submitKYB);
aiRouter.post('/payment/submit', c.submitPaymentKYB);
aiRouter.get('/status', c.kybStatus);
export default aiRouter;
