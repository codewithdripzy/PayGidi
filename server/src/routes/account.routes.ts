import { Router } from 'express';
import * as accountController from '../controllers/account.controller';
import { authenticate } from '../middleware/auth.middleware';
import { requireBodyFields } from '../middleware/validation.middleware';
const accountRouter = Router();
accountRouter.post('/auth', requireBodyFields('phone'), accountController.auth);
accountRouter.post(
  '/auth/verify',
  requireBodyFields('phone', 'otp', 'forWhat'),
  accountController.verifyAuthOTP,
);
accountRouter.post(
  '/auth/complete',
  authenticate,
  accountController.completeAccount,
);
accountRouter.post('/auth/verify/nin', accountController.verifyNIN);
accountRouter.post('/auth/verify/bvn-image', accountController.verifyBVNImage);
accountRouter.post('/auth/verify/email', accountController.verifyEmail);
accountRouter.post(
  '/auth/otp/request/:otpType',
  requireBodyFields('forWhat'),
  accountController.requestOTP,
);
accountRouter.post('/auth/biometric', accountController.biometric);
accountRouter.post(
  '/auth/biometric/register',
  authenticate,
  accountController.registerBiometric,
);
accountRouter.post('/auth/logout', authenticate, accountController.logout);
const accountProtectedRouter = Router();
accountProtectedRouter.use(authenticate);
accountProtectedRouter.get('/', accountController.accountDetails);
accountProtectedRouter.delete('/', accountController.deleteAccount);
accountProtectedRouter.get('/me', accountController.me);
accountProtectedRouter.post('/pin', accountController.setPin);
accountProtectedRouter.put('/pin', accountController.updatePin);
accountProtectedRouter.post('/block', accountController.block);
accountProtectedRouter.post('/unblock', accountController.unblock);
accountProtectedRouter.post('/report', accountController.report);
accountProtectedRouter.get('/devices', accountController.devices);
accountProtectedRouter.delete('/devices/:id', accountController.removeDevice);
accountProtectedRouter.get('/referral', accountController.referral);
accountRouter.use('/account', accountProtectedRouter);
const businessRouter = Router();
businessRouter.use(authenticate);
businessRouter.get('/profile', accountController.businessProfile);
businessRouter.put('/profile', accountController.updateBusiness);
businessRouter.put('/docs', accountController.updateBusinessDocs);
accountRouter.use('/business', businessRouter);
export default accountRouter;
