import BusinessModel from '../../models/business.model';
import TrustScoreLogModel from '../../models/trust-score-log.model';
import { NotFoundError } from '../../core/errors/app-error';
import logger from '../../infrastructure/logging/logger';

export class TrustApplicationService {
  async evaluateBusiness(businessId: string) {
    const business = await BusinessModel.findById(businessId);
    if (!business) throw new NotFoundError('Business not found');

    // Simulated AI factors
    const factors = {
      deviceRisk: Math.floor(Math.random() * 20),
      locationRisk: Math.floor(Math.random() * 20),
      transactionBehavior: Math.floor(Math.random() * 20),
      KYBStrength: business.verificationStatus === 'verified' ? 30 : 10,
      disputeHistory: 10,
    };

    const totalScore = Object.values(factors).reduce((a, b) => a + b, 0);
    
    business.trustScore = totalScore;
    business.riskLevel = totalScore >= 80 ? 'low' : (totalScore >= 50 ? 'medium' : 'high');
    await business.save();

    const log = await TrustScoreLogModel.create({
      businessId,
      score: totalScore,
      factors,
    });

    logger.info(`Trust evaluation completed for ${businessId}: Score ${totalScore}`);
    
    return {
      trustScore: totalScore,
      riskLevel: business.riskLevel,
      factors,
    };
  }

  async getTrustHistory(businessId: string) {
    return TrustScoreLogModel.find({ businessId }).sort({ createdAt: -1 });
  }
}

export const trustApplicationService = new TrustApplicationService();
