import { Schema } from "mongoose";
import { v4 as uuidv4 } from "uuid";

const apiKeySchema = new Schema(
    {
        uid: { type: String, default: () => uuidv4(), unique: true, index: true },
        organization: { type: String, required: true, index: true },
        name: { type: String, required: true },
        key: { type: String, required: true, unique: true },
        status: { type: String, enum: ["active", "revoked"], default: "active" },
        createdBy: { type: String, required: true },
        lastUsedAt: { type: Date },
    },
    { timestamps: true }
);

export default apiKeySchema;
