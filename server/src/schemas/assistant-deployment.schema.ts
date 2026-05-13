import { Schema } from "mongoose";
import { v4 as uuidv4 } from "uuid";

const assistantDeploymentSchema = new Schema(
    {
        uid: {
            type: String,
            default: uuidv4,
            unique: true,
            required: true,
        },
        assistant: {
            type: Schema.Types.ObjectId,
            ref: "AssistantCore",
            required: true,
        },
        organization: {
            type: String,
            required: true,
        },
        deployedBy: {
            type: Schema.Types.ObjectId,
            ref: "User",
            required: true,
        },
        provider: {
            type: String,
            default: "widget",
            required: true,
        },
        environment: {
            type: String,
            enum: ["development", "staging", "production"],
            default: "production",
            required: true,
        },
        widgetKey: {
            type: String,
            required: true,
        },
        widgetScript: {
            type: String,
            required: true,
        },
        status: {
            type: String,
            enum: ["deployed", "undeployed"],
            default: "deployed",
            required: true,
        },
    },
    { timestamps: true }
);

assistantDeploymentSchema.set("toJSON", {
    transform: (_doc, ret) => {
        const serialized = ret as Record<string, unknown>;
        serialized.id = serialized._id;
        Reflect.deleteProperty(serialized, "_id");
        Reflect.deleteProperty(serialized, "__v");
    },
});

export default assistantDeploymentSchema;
