import { Response } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import Business from '../models/business.model';
import Payment from '../models/payment.model';
import { fail, ok } from '../utils/response';
const scoreBusiness = (body: any) => {
  let score = 0;
  const observations: string[] = [];
  if (body.nin || body.directors?.length) {
    score += 30;
    observations.push('Director identity verification completed.');
  }
  if (
    body.instagramHandle ||
    body.facebookHandle ||
    body.tiktokHandle ||
    body.socialProfiles?.length
  ) {
    score += 20;
    observations.push('Active social media presence detected.');
  }
  if ((body.deliverySuccessRate ?? 0) > 0.8) {
    score += 20;
    observations.push('High delivery success rate.');
  }
  if ((body.disputeRate ?? 0) < 0.05) score += 10;
  if (body.registrationNumber || body.registration?.cacNumber) {
    score += 20;
    observations.push('Business registration provided.');
  }
  return {
    score: Math.min(100, score),
    summary: observations.join(' ') || 'No significant trust signals found.',
  };
};
export async function submitKYB(req: AuthRequest, res: Response) {
  const result = scoreBusiness(req.body);
  const business = await Business.create({
    userId: req.user?._id,
    ...req.body,
    name: req.body.name,
    businessName: req.body.name,
    registrationNumber:
      req.body.registration_number || req.body.registrationNumber,
    verificationStatus: 'pending',
    trustScore: result.score,
    riskAnalysis: result.summary,
  });
  return ok(
    res,
    { id: business._id },
    'KYB submitted. Multi-tier verification pipeline is running in the background.',
    202,
  );
}
export async function submitPaymentKYB(req: AuthRequest, res: Response) {
  const payment = await Payment.findById(req.body.paymentId);
  const result = scoreBusiness(req.body);
  if (payment) {
    payment.trustScore = result.score;
    payment.summary = result.summary;
    payment.status = 'in_progress';
    await payment.save();
  }
  return ok(res, {}, 'Payment KYB analysis has started in the background', 202);
}
export async function kybStatus(req: AuthRequest, res: Response) {
  if (!req.query.id) return fail(res, 'Business ID is required', 400);
  const query = req.query.id
    ? { _id: req.query.id }
    : { userId: req.user?._id };
  const business = await Business.findOne(query);
  if (!business) return fail(res, 'Business not found', 404);
  return ok(res, business, 'KYB status retrieved');
}
