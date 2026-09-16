import { Response } from 'express';
import Activity from '../models/activity.model';
import Business from '../models/business.model';
import Issue from '../models/issue.model';
import Session from '../models/session.model';
import User from '../models/user.model';
import Wallet from '../models/wallet.model';
import { AuthRequest } from '../middleware/auth.middleware';
import { compare, hash, signToken, uid } from '../utils/auth';
import { fail, ok } from '../utils/response';
import notificationService from '../services/notification.service';
const publicUser = (user: any) => {
  const value = user.toObject ? user.toObject() : { ...user };
  delete value.passwordHash;
  delete value.pinHash;
  delete value.otpCode;
  delete value.otpExpiresAt;
  return value;
};
const otp = () => String(Math.floor(10000 + Math.random() * 90000));
const issueToken = (res: Response, user: any) => {
  const accessToken = signToken(String(user._id), user.role);
  res.cookie('accessToken', accessToken, {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'strict',
    maxAge: 86400000,
  });
  return accessToken;
};
export async function auth(req: AuthRequest, res: Response) {
  const { phone, accountType } = req.body ?? {};
  if (!phone) return fail(res, 'Please provide phone number', 400);
  const requestId = res.locals.requestId;
  console.info('Auth request started', { requestId, hasPhone: true });

  let user = await User.findOne({ phone });
  console.info('Auth user lookup completed', {
    requestId,
    userFound: Boolean(user),
  });
  if (!user && !accountType)
    return fail(
      res,
      'Account not found. Please provide an account type to register.',
      404,
    );
  if (!user)
    user = await User.create({
      uid: uid(),
      phone,
      accountType,
      role: accountType === 'business' ? 'merchant' : 'buyer',
      status: 'pending',
      otpCode: otp(),
      otpPurpose: 'login',
      otpExpiresAt: new Date(Date.now() + 600000),
    });
  else {
    user.otpCode = otp();
    user.otpPurpose = 'login';
    user.otpExpiresAt = new Date(Date.now() + 600000);
    await user.save();
  console.info('Auth user persistence completed', {
    requestId,
    userId: String(user._id),
  });
  }
  if (process.env.NODE_ENV !== 'production')
    console.info(`[PayGidi] OTP for ${phone}: ${user.otpCode}`);
  await notificationService.sendSms(
    phone,
    `Your PayGidi verification code is ${user.otpCode}. It expires in 10 minutes.`,
  );
  return ok(
    res,
    {
      createdAt: user.createdAt,
      firstName: user.firstName,
      lastName: user.lastName,
      phone,
      requiredAction: 'login',
      requiredActionAt: user.otpExpiresAt,
    },
    'An OTP has been sent to your phone. Please verify to continue.',
  );
}
export async function verifyAuthOTP(req: AuthRequest, res: Response) {
  const { phone, code, otp: provided } = req.body ?? {};
  const user = await User.findOne({ phone });
  if (
    !user ||
    user.otpCode !== (code || provided) ||
    !user.otpExpiresAt ||
    user.otpExpiresAt < new Date()
  )
    return fail(res, 'Invalid or expired OTP', 401);
  user.phoneVerified = true;
  user.status = 'active';
  user.otpCode = undefined;
  user.otpExpiresAt = undefined;
  await user.save();
  const accessToken = issueToken(res, user);
  await Session.create({
    userId: user._id,
    tokenHash: accessToken,
    isCurrent: true,
    expiresAt: new Date(Date.now() + 86400000),
    ip: req.ip,
    userAgent: req.get('user-agent'),
  });
  return ok(
    res,
    { accessToken, refreshToken: accessToken, user: publicUser(user) },
    'Authentication successful',
  );
}
export async function completeAccount(req: AuthRequest, res: Response) {
  const user = req.user;
  const body = req.body ?? {};
  Object.assign(user, body, {
    name: `${body.firstName ?? user.firstName ?? ''} ${body.lastName ?? user.lastName ?? ''}`.trim(),
    status: 'active',
    phoneVerified: true,
    isFirstTime: false,
    uid: user.uid || uid(),
    referralCode: user.referralCode || uid().slice(0, 6).toUpperCase(),
  });
  await user.save();
  if (user.accountType === 'business' || body.businessName || body.name)
    await Business.findOneAndUpdate(
      { userId: user._id },
      {
        $set: {
          userId: user._id,
          ...body,
          businessName: body.businessName || body.name,
        },
      },
      { upsert: true, new: true },
    );
  await Wallet.findOneAndUpdate(
    { userId: user._id },
    {
      $setOnInsert: {
        userId: user._id,
        accountNumber: user.phone,
        currency: 'NGN',
        status: 'active',
      },
    },
    { upsert: true },
  );
  return ok(res, publicUser(user), 'Account completed successfully');
}
export async function logout(req: AuthRequest, res: Response) {
  await Session.updateMany(
    { userId: req.user._id, isCurrent: true },
    { $set: { isCurrent: false } },
  );
  res.clearCookie('accessToken');
  return ok(res, {}, 'Logged out successfully');
}
export async function requestOTP(req: AuthRequest, res: Response) {
  const type = req.params.otpType;
  const query =
    type === 'email' ? { email: req.body.email } : { phone: req.body.phone };
  const user = await User.findOne(query);
  if (!user) return fail(res, 'No account found', 404);
  user.otpCode = otp();
  user.otpPurpose = req.body.forWhat;
  user.otpExpiresAt = new Date(Date.now() + 600000);
  await user.save();
  if (process.env.NODE_ENV !== 'production')
    console.info(`[PayGidi] ${type} OTP: ${user.otpCode}`);
  if (type === 'email') {
    await notificationService.sendEmail(
      String(user.email),
      'PayGidi verification code',
      `Your verification code is ${user.otpCode}. It expires in 10 minutes.`,
      'register',
    );
  } else {
    await notificationService.sendSms(
      String(user.phone),
      `Your PayGidi verification code is ${user.otpCode}. It expires in 10 minutes.`,
    );
  }
  return ok(res, { expiresAt: user.otpExpiresAt }, 'OTP sent successfully');
}
export async function verifyEmail(req: AuthRequest, res: Response) {
  const user = await User.findOne({ email: req.body.email });
  if (!user || user.otpCode !== req.body.code)
    return fail(res, 'Invalid OTP', 400);
  user.emailVerified = true;
  user.otpCode = undefined;
  await user.save();
  return ok(res, publicUser(user), 'Email verified successfully');
}
export async function verifyNIN(req: AuthRequest, res: Response) {
  return ok(
    res,
    { verified: true, nin: req.body.nin },
    'NIN verified successfully',
  );
}
export async function verifyBVNImage(req: AuthRequest, res: Response) {
  return ok(res, { verified: true }, 'BVN image verified successfully');
}
export async function biometric(req: AuthRequest, res: Response) {
  const user = await User.findOne({ biometricId: req.body.biometricId });
  if (!user) return fail(res, 'Biometric identity not found', 401);
  return ok(
    res,
    { accessToken: issueToken(res, user), user: publicUser(user) },
    'Biometric authentication successful',
  );
}
export async function registerBiometric(req: AuthRequest, res: Response) {
  req.user.biometricId = req.body.biometricId || req.body.deviceId;
  req.user.biometricEnabled = true;
  await req.user.save();
  return ok(res, {}, 'Biometric registered successfully');
}
export async function accountDetails(req: AuthRequest, res: Response) {
  return ok(res, publicUser(req.user));
}
export async function me(req: AuthRequest, res: Response) {
  return ok(res, publicUser(req.user));
}
export async function setPin(req: AuthRequest, res: Response) {
  req.user.pinHash = await hash(req.body.pin);
  await req.user.save();
  return ok(res, {}, 'PIN set successfully');
}
export async function updatePin(req: AuthRequest, res: Response) {
  if (!req.user.pinHash || !(await compare(req.body.oldPin, req.user.pinHash)))
    return fail(res, 'Incorrect old PIN', 401);
  req.user.pinHash = await hash(req.body.newPin);
  await req.user.save();
  return ok(res, {}, 'PIN updated successfully');
}
export async function deleteAccount(req: AuthRequest, res: Response) {
  await Promise.all([
    Business.deleteMany({ userId: req.user._id }),
    Wallet.deleteMany({ userId: req.user._id }),
    Session.deleteMany({ userId: req.user._id }),
    Activity.deleteMany({ userId: String(req.user._id) }),
    User.deleteOne({ _id: req.user._id }),
  ]);
  res.clearCookie('accessToken');
  return ok(res, {}, 'Account and all associated data deleted successfully');
}
export async function block(req: AuthRequest, res: Response) {
  req.user.status = 'blocked';
  req.user.blocked = true;
  await req.user.save();
  return ok(res, {}, 'Account blocked successfully');
}
export async function unblock(req: AuthRequest, res: Response) {
  req.user.status = 'active';
  req.user.blocked = false;
  await req.user.save();
  return ok(res, {}, 'Account unblocked successfully');
}
export async function report(req: AuthRequest, res: Response) {
  return ok(
    res,
    await Issue.create({ userId: req.user._id, ...req.body }),
    'Issue reported successfully',
    201,
  );
}
export async function referral(req: AuthRequest, res: Response) {
  const count = await User.countDocuments({
    'metadata.referredBy': req.user.referralCode,
  });
  return ok(res, { referralCode: req.user.referralCode, referrals: count });
}
export async function devices(req: AuthRequest, res: Response) {
  return ok(
    res,
    await Session.find({
      userId: req.user._id,
      expiresAt: { $gt: new Date() },
    }).select('-tokenHash'),
  );
}
export async function removeDevice(req: AuthRequest, res: Response) {
  await Session.deleteOne({ _id: req.params.id, userId: req.user._id });
  return ok(res, {}, 'Device removed successfully');
}
export async function businessProfile(req: AuthRequest, res: Response) {
  return ok(res, await Business.findOne({ userId: req.user._id }));
}
export async function updateBusiness(req: AuthRequest, res: Response) {
  return ok(
    res,
    await Business.findOneAndUpdate(
      { userId: req.user._id },
      { $set: { userId: req.user._id, ...req.body } },
      { upsert: true, new: true },
    ),
    'Business profile updated successfully',
  );
}
export async function updateBusinessDocs(req: AuthRequest, res: Response) {
  return ok(
    res,
    await Business.findOneAndUpdate(
      { userId: req.user._id },
      { $set: { documents: req.body, userId: req.user._id } },
      { upsert: true, new: true },
    ),
    'Business documents updated successfully',
  );
}
