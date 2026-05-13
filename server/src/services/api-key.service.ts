import ApiKeyModel from "../models/api-key.model";
import { generateApiKey } from "../utils/generator";

class ApiKeyService {
    async createApiKey(organizationId: string, name: string, userId: string) {
        const key = generateApiKey();
        
        const apiKey = await ApiKeyModel.create({
            organization: organizationId,
            name,
            key,
            createdBy: userId,
        });

        return apiKey;
    }

    async listApiKeys(organizationId: string) {
        const keys = await ApiKeyModel.find({ organization: organizationId, status: "active" }).sort({ createdAt: -1 }).lean();
        return keys.map(k => ({
            ...k,
            key: `${k.key.slice(0, 8)}${"•".repeat(12)}${k.key.slice(-4)}`,
        }));
    }

    async revokeApiKey(uid: string, organizationId: string) {
        return ApiKeyModel.findOneAndUpdate(
            { uid, organization: organizationId },
            { status: "revoked" },
            { new: true }
        );
    }

    async getApiKeyByKey(key: string) {
        return ApiKeyModel.findOne({ key, status: "active" });
    }

    async recordKeyUsage(key: string) {
        return ApiKeyModel.updateOne({ key }, { $set: { lastUsedAt: new Date() } });
    }
}

const apiKeyService = new ApiKeyService();
export default apiKeyService;
