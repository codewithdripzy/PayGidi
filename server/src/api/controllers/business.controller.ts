import { Request, Response, NextFunction } from 'express';
import { businessApplicationService } from '../../application/services/business.application.service';
import { UnauthorizedError } from '../../core/errors/app-error';

export class BusinessController {
  async onboard(req: Request, res: Response, next: NextFunction) {
    try {
      const user = (req as any).user;
      if (!user) throw new UnauthorizedError();

      const business = await businessApplicationService.onboard(user.userId, req.body);
      
      return res.status(201).json({
        success: true,
        data: business
      });
    } catch (error) {
      next(error);
    }
  }

  async getProfile(req: Request, res: Response, next: NextFunction) {
    try {
      const user = (req as any).user;
      if (!user) throw new UnauthorizedError();

      const business = await businessApplicationService.getBusinessProfile(user.userId);
      
      return res.status(200).json({
        success: true,
        data: business
      });
    } catch (error) {
      next(error);
    }
  }
}

export const businessController = new BusinessController();
