import BusinessModel from '../../models/business.model';
import { BadRequestError, NotFoundError } from '../../core/errors/app-error';
import logger from '../../infrastructure/logging/logger';

export class BusinessApplicationService {
  async onboard(userId: string, data: any) {
    const existingBusiness = await BusinessModel.findOne({ userId });
    if (existingBusiness) {
      throw new BadRequestError('Business profile already exists for this user');
    }

    const business = await BusinessModel.create({
      userId,
      ...data,
      verificationStatus: 'pending',
      trustScore: 50, // Default starting score
      riskLevel: 'medium',
    });

    logger.info(`Business onboarded: ${business.businessName} for user ${userId}`);
    return business;
  }

  async getBusinessProfile(userId: string) {
    const business = await BusinessModel.findOne({ userId });
    if (!business) {
      throw new NotFoundError('Business profile not found');
    }
    return business;
  }

  async updateTrustScore(businessId: string, newScore: number) {
    const business = await BusinessModel.findById(businessId);
    if (!business) {
      throw new NotFoundError('Business not found');
    }

    business.trustScore = newScore;
    business.riskLevel = newScore >= 80 ? 'low' : newScore >= 50 ? 'medium' : 'high';
    
    await business.save();
    logger.info(`Trust score updated for ${businessId}: ${newScore}`);
    return business;
  }
}

export const businessApplicationService = new BusinessApplicationService();
