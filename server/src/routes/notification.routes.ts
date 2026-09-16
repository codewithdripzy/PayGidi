import { Router } from 'express';
import * as c from '../controllers/notification.controller';
import {
  requireBodyFields,
  validEmailNotification,
} from '../middleware/validation.middleware';
const notificationRouter = Router();
notificationRouter.post(
  '/email',
  validEmailNotification,
  requireBodyFields('subject', 'body'),
  c.email,
);
notificationRouter.post('/sms', requireBodyFields('to', 'message'), c.sms);
notificationRouter.post(
  '/activity',
  requireBodyFields('userId', 'action'),
  c.activity,
);
export default notificationRouter;
