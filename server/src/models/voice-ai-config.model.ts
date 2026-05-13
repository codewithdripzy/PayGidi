import { model, models } from "mongoose";
import voiceAiConfigSchema from "../schemas/voice-ai-config.schema";

const VoiceAiConfigModel = models.VoiceAiConfig || model("VoiceAiConfig", voiceAiConfigSchema, "voice_ai_configs");

export default VoiceAiConfigModel;
