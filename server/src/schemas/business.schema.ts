import { Schema } from "mongoose";

const businessSchema = new Schema(
    {
        userId: {
            type: Schema.Types.ObjectId,
            ref: "User",
            required: true,
        },
        businessName: {
            type: String,
            required: true,
            trim: true,
        },
        cacNumber: {
            type: String,
            required: true,
            trim: true,
        },
        verificationStatus: {
            type: String,
            enum: ["pending", "verified", "rejected"],
            default: "pending",
            required: true,
        },
        trustScore: {
            type: Number,
            default: 50,
            min: 0,
            max: 100,
        },
        riskLevel: {
            type: String,
            enum: ["low", "medium", "high"],
            default: "medium",
        },
        metadata: {
            type: Schema.Types.Mixed,
            default: {},
        },
    },
    {
        timestamps: true,
    }
);

export default businessSchema;
