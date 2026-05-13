import { Schema } from "mongoose";
import { v4 as uuidv4 } from "uuid";

const voiceAiConfigSchema = new Schema({
    uid: {
        type: String,
        default: uuidv4,
        unique: true,
        required: true,
    },
    organization: {
        type: String,
        required: true,
        index: true,
    },
    voiceProviders: {
        elevenlabs: {
            apiKey: { type: String, default: "" },
            model: { type: String, default: "eleven_multilingual_v2" },
        },
        playht: {
            apiKey: { type: String, default: "" },
            userId: { type: String, default: "" },
            model: { type: String, default: "" },
        }
    },
    aiProviders: {
        openai: {
            apiKey: { type: String, default: "" },
            model: { type: String, default: "gpt-4o" },
        },
        anthropic: {
            apiKey: { type: String, default: "" },
            model: { type: String, default: "claude-3-5-sonnet-20240620" },
        },
        google: {
            apiKey: { type: String, default: "" },
            model: { type: String, default: "gemini-2.5-flash" },
        },
        xai: {
            apiKey: { type: String, default: "" },
            model: { type: String, default: "grok-beta" },
        }
    }
}, { timestamps: true });

voiceAiConfigSchema.set("toJSON", {
    transform: (_doc, ret) => {
        const serialized = ret as Record<string, unknown>;
        serialized.id = serialized._id;
        Reflect.deleteProperty(serialized, "_id");
        Reflect.deleteProperty(serialized, "__v");
    },
});

export default voiceAiConfigSchema;
