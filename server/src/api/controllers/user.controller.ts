import { Request, Response, NextFunction } from 'express';
import { userApplicationService } from '../../application/services/user.application.service';
import { UnauthorizedError } from '../../core/errors/app-error';

export class UserController {
  async getMe(req: Request, res: Response, next: NextFunction) {
    try {
      const user = (req as any).user;
      if (!user) throw new UnauthorizedError();

      const profile = await userApplicationService.getUserProfile(user.userId);
      
      return res.status(200).json({
        success: true,
        data: profile
      });
    } catch (error) {
      next(error);
    }
  }

  async updateMe(req: Request, res: Response, next: NextFunction) {
    try {
      const user = (req as any).user;
      if (!user) throw new UnauthorizedError();

      const profile = await userApplicationService.updateProfile(user.userId, req.body);
      
      return res.status(200).json({
        success: true,
        data: profile
      });
    } catch (error) {
      next(error);
    }
  }
}

export const userController = new UserController();
