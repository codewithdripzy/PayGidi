import { Document } from "mongoose";
import { AssistantStatus} from "../enums/enum";

interface BaseDocument  {
    uid: string;
    deletedAt: Date;
    createdAt: Date;
    updatedAt: Date;
}

export interface AssistantDocument extends BaseDocument, Document {
    name: string;
    description: string;
    organization: String;
    createdBy?: String;
    type: "public" | "private";
    instructions?: string[];
    rules?: string[];
    knowledgeBase?: string[];
    metadata?: {
        personality?: {
            tone?: "formal" | "casual" | "sales" | "support";
            responseStyle?: "short" | "balanced" | "detailed";
        };
        ai?: {
            provider?: string;
            model?: string;
            systemPrompt?: string;
            temperature?: number;
            maxTokens?: number;
        };
    };
    deployment?: {
        isDeployed?: boolean;
        provider?: string | null;
        environment?: "development" | "staging" | "production";
        widgetKey?: string | null;
        widgetScript?: string | null;
        deployedAt?: Date | null;
        lastDeployedBy?: string | null;
    };
    status: AssistantStatus;
    createdAt: Date;
    updatedAt: Date;
}
