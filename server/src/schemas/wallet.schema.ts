import { Schema } from "mongoose";

const walletSchema = new Schema(
    {
        userId: {
            type: Schema.Types.ObjectId,
            ref: "User",
            required: true,
            unique: true,
        },
        balance: {
            type: Number,
            default: 0,
            min: 0,
        },
        escrowBalance: {
            type: Number,
            default: 0,
            min: 0,
        },
        currency: {
            type: String,
            default: "NGN",
            required: true,
        },
    },
    {
        timestamps: true,
    }
);

export default walletSchema;
