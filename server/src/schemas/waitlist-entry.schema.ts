import { Schema } from "mongoose";

const waitlistEntrySchema = new Schema(
    {
        email: {
            type: String,
            required: true,
            unique: true,
            lowercase: true,
            trim: true,
        },
        name: {
            type: String,
            default: "",
            trim: true,
        },
        source: {
            type: String,
            default: "landing-page",
            trim: true,
        },
    },
    { timestamps: true }
);

waitlistEntrySchema.set("toJSON", {
    transform: (_doc, ret) => {
        const serialized = ret as Record<string, unknown>;
        serialized.id = serialized._id;
        Reflect.deleteProperty(serialized, "_id");
        Reflect.deleteProperty(serialized, "__v");
    },
});

export default waitlistEntrySchema;
