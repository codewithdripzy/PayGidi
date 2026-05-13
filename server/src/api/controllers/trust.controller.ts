import { Request, Response, NextFunction } from 'express';
import { trustApplicationService } from '../../application/services/trust.application.service';

export class TrustController {
  async evaluate(req: Request, res: Response, next: NextFunction) {
    try {
      const { businessId } = req.params;
      const result = await trustApplicationService.evaluateBusiness(businessId);
      
      return res.status(200).json({
        success: true,
        data: result
      });
    } catch (error) {
      next(error);
    }
  }

  async getHistory(req: Request, res: Response, next: NextFunction) {
    try {
      const { businessId } = req.params;
      const history = await trustApplicationService.getTrustHistory(businessId);
      
      return res.status(200).json({
        success: true,
        data: history
      });
    } catch (error) {
      next(error);
    }
  }
}

export const trustController = new TrustController();
