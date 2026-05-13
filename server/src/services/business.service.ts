import BusinessModel from "../models/business.model";
import TrustScoreLogModel from "../models/trust-score-log.model";

export class BusinessService {
    async onboard(userId: string, data: { businessName: string; cacNumber: string; metadata?: any }) {
        const business = await BusinessModel.create({
            userId,
            ...data,
            verificationStatus: "pending",
            trustScore: 50,
            riskLevel: "medium",
        });
        return business;
    }

    async getBusiness(id: string) {
        return BusinessModel.findById(id);
    }

    async getTrustScore(businessId: string) {
        const business = await BusinessModel.findById(businessId);
        if (!business) throw new Error("Business not found");
        return {
            trustScore: business.trustScore,
            riskLevel: business.riskLevel,
        };
    }

    async updateVerificationStatus(businessId: string, status: "pending" | "verified" | "rejected") {
        return BusinessModel.findByIdAndUpdate(businessId, { verificationStatus: status }, { new: true });
    }
}

export default new BusinessService();
