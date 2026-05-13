import { Schema } from "mongoose";

import { v4 as uuidv4 } from "uuid";
import { AssistantStatus } from "../core/enums/enum";

const knowledgeBaseSchema = new Schema(
    {
        uid: {
            type: String,
            default: uuidv4,
            required: true,
        },
        sourceType: {
            type: String,
            enum: ["faq", "document", "link", "text", "website", "file"],
            required: true,
        },
        title: {
            type: String,
            required: true,
        },
        value: {
            type: String,
            default: null,
        },
        url: {
            type: String,
            default: null,
        },
        text: {
            type: String,
            default: null,
        },
        metadata: {
            type: Schema.Types.Mixed,
            default: {},
        },
    },
    { _id: false }
);

const deploymentSchema = new Schema(
    {
        isDeployed: {
            type: Boolean,
            default: false,
            required: true,
        },
        provider: {
            type: String,
            default: null,
        },
        environment: {
            type: String,
            enum: ["development", "staging", "production"],
            default: "production",
            required: true,
        },
        widgetKey: {
            type: String,
            default: undefined,
        },
        widgetScript: {
            type: String,
            default: null,
        },
        deployedAt: {
            type: Date,
            default: null,
        },
        lastDeployedBy: {
            type: String,
            default: null,
        },
    },
    { _id: false }
);

const assistantMetadataSchema = new Schema(
    {
        personality: {
            tone: {
                type: String,
                enum: ["formal", "casual", "sales", "support"],
                default: "support",
                required: true,
            },
            responseStyle: {
                type: String,
                enum: ["short", "balanced", "detailed"],
                default: "balanced",
                required: true,
            },
        },
        generation: {
            provider: {
                type: String,
                default: "openai",
                required: true,
            },
            model: {
                type: String,
                default: "gpt-4.1-mini",
                required: true,
            },
            systemPrompt: {
                type: String,
                default: "",
            },
            temperature: {
                type: Number,
                default: 0.2,
                min: 0,
                max: 2,
            },
            maxTokens: {
                type: Number,
                default: 512,
                min: 32,
            },
        },
    },
    { _id: false }
);

const assistantSchema = new Schema({
    uid: {
        type: String,
        default: uuidv4,
        unique: true,
        required: true,
    },
    sites: {
        type: [
            {
                baseUrl: { type: String, required: true },
                lastCrawledAt: { type: Date, default: null },
                context: {
                    sitemap: {
                        type: [
                            {
                                path: { type: String, required: true },
                                title: { type: String, default: "" },
                                intent: { type: String, default: "" },
                                summary: { type: String, default: "" },
                                actions: { type: [String], default: [] },
                                entities: { type: [String], default: [] },
                                linksTo: { type: [String], default: [] },
                            },
                        ],
                        default: [],
                    },
                    summary: { type: String, default: null },
                },
            },
        ],
        default: [],
    },
    name: {
        type: String,
        required: true,
    },
    description: {
        type: String,
        required: false,
        default: "",
    },
    firstMessage: {
        type: String,
        required: false,
        default: "",
    },
    voiceId: {
        type: String,
        required: false,
        default: "",
    },
    organization: {
        type: String,
        required: true,
    },
    createdBy: {
        type: String,
        required: true,
    },
    instructions: {
        type: [String],
        required: false,
        default: [],
    },
    rules: {
        type: [String],
        required: false,
        default: [],
    },
    knowledgeBase: {
        type: [knowledgeBaseSchema],
        required: false,
        default: [],
    },
    metadata: {
        type: assistantMetadataSchema,
        default: {
            personality: {
                tone: "support",
                responseStyle: "balanced",
            },
            generation: {
                provider: "openai",
                model: "gpt-4.1-mini",
                systemPrompt: "",
                temperature: 0.2,
                maxTokens: 512,
            },
        },
    },
    accessControl: {
        allowedDomains: {
            type: [String],
            default: ["*"],
        },
        blockedRoutes: {
            type: [String],
            default: [],
        },
    },
    deployment: {
        type: deploymentSchema,
        default: {
            isDeployed: false,
            environment: "production",
        },
    },
    status: {
        type: String,
        enum: Object.values(AssistantStatus),
        default: AssistantStatus.ACTIVE,
    },
}, { timestamps: true });

assistantSchema.set("toJSON", {
    transform: (_doc, ret) => {
        const serialized = ret as Record<string, unknown>;
        serialized.id = serialized._id;
        Reflect.deleteProperty(serialized, "_id");
        Reflect.deleteProperty(serialized, "__v");
    },
});

assistantSchema.index(
    { "deployment.widgetKey": 1 },
    {
        unique: true,
        partialFilterExpression: {
            "deployment.widgetKey": { $type: "string" },
        },
    }
);

export default assistantSchema;
