import { Response } from 'express';
import Activity from '../models/activity.model';
import Notification from '../models/notification.model';
import { AuthRequest } from '../middleware/auth.middleware';
import { ok } from '../utils/response';
import notificationService from '../services/notification.service';
const store = async (body: any, channel: string) =>
  Notification.create({
    userId: body.userId || body.to,
    title: body.subject || `${channel.toUpperCase()} notification`,
    message: body.body || body.message,
    type: body.type || 'message',
    channel,
    status: 'stored',
    recipient: body.to,
    metadata: body.metadata,
  });
export async function email(req: AuthRequest, res: Response) {
  const item: any = await store(req.body, 'email');
  await notificationService.sendEmail(
    req.body.to,
    req.body.subject,
    req.body.body,
    'notification',
  );
  item.status = 'sent';
  await item.save();
  return ok(res, item);
}
export async function sms(req: AuthRequest, res: Response) {
  const item: any = await store(req.body, 'sms');
  await notificationService.sendSms(req.body.to, req.body.message);
  item.status = 'sent';
  await item.save();
  return ok(res, item);
}
export async function activity(req: AuthRequest, res: Response) {
  return ok(
    res,
    await Activity.create({
      ...req.body,
      userId: req.body.userId || String(req.user?._id),
      ipAddress: req.ip,
      userAgent: req.get('user-agent'),
    }),
  );
}
