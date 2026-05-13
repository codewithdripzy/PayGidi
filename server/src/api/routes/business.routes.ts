import { Router } from 'express';
import { businessController } from '../controllers/business.controller';
import { authenticate } from '../middlewares/auth.middleware';
import { validate } from '../middlewares/validate.middleware';
import { onboardSchema } from '../validators/business.validator';

const router = Router();

router.post('/onboard', authenticate, validate(onboardSchema), businessController.onboard);
router.get('/profile', authenticate, businessController.getProfile);

export default router;
