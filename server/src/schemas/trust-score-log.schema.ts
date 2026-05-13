import { Schema } from "mongoose";

const trustScoreLogSchema = new Schema(
    {
        businessId: {
            type: Schema.Types.ObjectId,
            ref: "Business",
            required: true,
        },
        score: {
            type: Number,
            required: true,
            min: 0,
            max: 100,
        },
        factors: {
            deviceRisk: { type: Number },
            locationRisk: { type: Number },
            transactionBehavior: { type: Number },
            KYBStrength: { type: Number },
            disputeHistory: { type: Number },
        },
    },
    {
        timestamps: true,
    }
);

export default trustScoreLogSchema;
