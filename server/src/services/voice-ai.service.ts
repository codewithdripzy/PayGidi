import VoiceAiConfigModel from "../models/voice-ai-config.model";

class VoiceAiService {
    async getConfig(organizationId: string) {
        let config = await VoiceAiConfigModel.findOne({ organization: organizationId });
        
        if (!config) {
            // Return a default config object if none exists yet
            return {
                organization: organizationId,
                voiceProviders: {
                    elevenlabs: { apiKey: "", model: "eleven_multilingual_v2" },
                    playht: { apiKey: "", userId: "", model: "" }
                },
                aiProviders: {
                    openai: { apiKey: "", model: "gpt-4o" },
                    anthropic: { apiKey: "", model: "claude-3-5-sonnet-20240620" },
                    google: { apiKey: "", model: "gemini-2.5-flash" },
                    xai: { apiKey: "", model: "grok-beta" }
                }
            };
        }
        
        return config;
    }

    async updateConfig(organizationId: string, payload: any) {
        const config = await VoiceAiConfigModel.findOneAndUpdate(
            { organization: organizationId },
            { $set: payload },
            { new: true, upsert: true }
        );
        return config;
    }
}

const voiceAiService = new VoiceAiService();
export default voiceAiService;
