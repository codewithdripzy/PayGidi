import { Schema } from "mongoose";

const transactionSchema = new Schema(
    {
        buyerId: {
            type: Schema.Types.ObjectId,
            ref: "User",
            required: true,
        },
        merchantId: {
            type: Schema.Types.ObjectId,
            ref: "User",
            required: true,
        },
        amount: {
            type: Number,
            required: true,
            min: 0,
        },
        status: {
            type: String,
            enum: ["pending", "held", "released", "refunded"],
            default: "pending",
            required: true,
        },
        trustScoreSnapshot: {
            type: Number,
        },
        squadReferenceId: {
            type: String,
            unique: true,
            sparse: true,
        },
    },
    {
        timestamps: true,
    }
);

export default transactionSchema;
