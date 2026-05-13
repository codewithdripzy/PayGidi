import { Request, Response, NextFunction } from 'express';
import { TokenGenerator } from '../../infrastructure/security/token.generator';
import logger from '../../infrastructure/logging/logger';
import UserModel from '../../models/user.model';

export const authenticate = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const token = req.cookies?.accessToken || req.headers.authorization?.split(' ')[1];

    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'No token provided, authorization denied',
        code: 'UNAUTHORIZED'
      });
    }

    const decoded = TokenGenerator.verify(token);
    const user = await UserModel.findById(decoded.userId).select('-passwordHash');

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'User not found or token invalid',
        code: 'UNAUTHORIZED'
      });
    }

    (req as any).user = {
      userId: user._id,
      role: user.role,
      email: user.email,
      phoneNumber: user.phoneNumber,
      isPhoneVerified: user.isPhoneVerified
    };

    next();
  } catch (error) {
    logger.error('Authentication middleware error:', error);
    return res.status(401).json({
      success: false,
      message: 'Token is not valid',
      code: 'INVALID_TOKEN'
    });
  }
};

export const authorize = (roles: string[]) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const user = (req as any).user;
    if (!user || !roles.includes(user.role)) {
      return res.status(403).json({
        success: false,
        message: 'You do not have permission to perform this action',
        code: 'FORBIDDEN'
      });
    }
    next();
  };
};
