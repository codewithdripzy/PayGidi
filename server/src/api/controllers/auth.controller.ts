import { Request, Response, NextFunction } from 'express';
import { authApplicationService } from '../../application/services/auth.application.service';
import logger from '../../infrastructure/logging/logger';
import { BadRequestError, UnauthorizedError } from '../../core/errors/app-error';

export class AuthController {
  async register(req: Request, res: Response, next: NextFunction) {
    try {
      const result = await authApplicationService.register(req.body);
      
      res.cookie('accessToken', result.accessToken, {
        httpOnly: true,
        secure: process.env.NODE_ENV === 'production',
        sameSite: 'strict',
        maxAge: 24 * 60 * 60 * 1000,
      });

      return res.status(201).json({
        success: true,
        message: 'Account created successfully. Please verify your phone number.',
        data: result
      });
    } catch (error) {
      next(error);
    }
  }

  async verifyPhone(req: Request, res: Response, next: NextFunction) {
    try {
      const { code } = req.body;
      const userId = (req as any).user?.userId;

      if (!userId) {
        throw new UnauthorizedError();
      }

      const result = await authApplicationService.verifyPhone(userId, code);
      return res.status(200).json({
        success: true,
        message: result.message
      });
    } catch (error) {
      next(error);
    }
  }

  async login(req: Request, res: Response, next: NextFunction) {
    try {
      const result = await authApplicationService.login(req.body);

      res.cookie('accessToken', result.accessToken, {
        httpOnly: true,
        secure: process.env.NODE_ENV === 'production',
        sameSite: 'strict',
        maxAge: 24 * 60 * 60 * 1000,
      });

      return res.status(200).json({
        success: true,
        message: 'Login successful',
        data: result
      });
    } catch (error) {
      next(error);
    }
  }

  async logout(req: Request, res: Response) {
    res.clearCookie('accessToken');
    return res.status(200).json({
      success: true,
      message: 'Logged out successfully'
    });
  }
}

export const authController = new AuthController();
