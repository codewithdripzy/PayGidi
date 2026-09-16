import { Request, Response, NextFunction } from 'express';
import User from '../models/user.model';
import { verifyToken } from '../utils/auth';
export type AuthRequest = Request & {
  user?: any;
  userId?: string;
};
export async function authenticate(
  req: AuthRequest,
  res: Response,
  next: NextFunction,
) {
  try {
    const raw =
      req.headers.authorization?.replace(/^Bearer\s+/i, '') ||
      req.cookies?.accessToken;
    if (!raw)
      return res
        .status(401)
        .json({ success: false, error: 'Authorization header is missing' });
    const payload = verifyToken(raw);
    const user = await User.findById(payload.userId);
    if (!user || user.blocked || user.status === 'blocked')
      return res
        .status(401)
        .json({ success: false, error: 'Invalid or expired token' });
    req.user = user;
    req.userId = String(user._id);
    next();
  } catch {
    return res
      .status(401)
      .json({ success: false, error: 'Invalid or expired token' });
  }
}
