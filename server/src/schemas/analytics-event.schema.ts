import { Schema } from "mongoose";
import { v4 as uuidv4 } from "uuid";

const analyticsEventSchema = new Schema(
    {
        uid: {
            type: String,
            default: uuidv4,
            unique: true,
            required: true,
        },
        organization: {
            type: String,
            required: true,
        },
        assistant: {
            type: Schema.Types.ObjectId,
            ref: "AssistantCore",
            default: null,
        },
        eventType: {
            type: String,
            enum: [
                "session_started",
                "message_received",
                "message_resolved",
                "fallback",
                "handoff_requested",
                "deployment_view"
            ],
            required: true,
        },
        sessionId: {
            type: String,
            default: null,
        },
        endUserId: {
            type: String,
            default: null,
        },
        value: {
            type: Number,
            default: 1,
        },
        metadata: {
            type: Schema.Types.Mixed,
            default: {},
        },
        occurredAt: {
            type: Date,
            required: true,
            default: Date.now,
        },
    },
    { timestamps: true }
);

analyticsEventSchema.index({ organization: 1, occurredAt: -1 });
analyticsEventSchema.index({ assistant: 1, occurredAt: -1 });

analyticsEventSchema.set("toJSON", {
    transform: (_doc, ret) => {
        const serialized = ret as Record<string, unknown>;
        serialized.id = serialized._id;
        Reflect.deleteProperty(serialized, "_id");
        Reflect.deleteProperty(serialized, "__v");
    },
});

export default analyticsEventSchema;
