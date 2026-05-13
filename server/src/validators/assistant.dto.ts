import Joi from "joi";

const knowledgeBaseItemDto = Joi.object({
    type: Joi.string().valid("website", "file", "faq", "document", "link", "text").required(),
    title: Joi.string().trim().min(1).max(300).required(),
    value: Joi.string().trim().allow("").optional(),
    fileName: Joi.string().trim().allow("").optional(),
}).custom((item, helpers) => {
    const candidate = item as { type?: string; value?: string; fileName?: string };

    if (candidate.type === "file") {
        const hasValue = typeof candidate.value === "string" && candidate.value.trim().length > 0;
        const hasFileName = typeof candidate.fileName === "string" && candidate.fileName.trim().length > 0;

        if (!hasValue && !hasFileName) {
            return helpers.error("any.invalid");
        }
    }

    return item;
});

const knowledgeBaseDto = Joi.alternatives().try(
    Joi.array().items(knowledgeBaseItemDto),
    Joi.string().custom((value, helpers) => {
        try {
            const parsed = JSON.parse(value) as unknown;
            const { error } = Joi.array().items(knowledgeBaseItemDto).validate(parsed);
            if (error) {
                return helpers.error("any.invalid");
            }
            return parsed;
        } catch {
            return helpers.error("any.invalid");
        }
    })
);

const createAssistantDto = Joi.object({
    organizationId: Joi.string().required(),
    name: Joi.string().trim().min(2).max(120).required(),
    description: Joi.string().allow("").optional(),
    firstMessage: Joi.string().allow("").optional(),
    voiceId: Joi.string().allow("").optional(),
    tone: Joi.string().valid("formal", "casual", "sales", "support").default("support"),
    provider: Joi.string().trim().default("openai"),
    model: Joi.string().default("gpt-4.1-mini"),
    temperature: Joi.number().min(0).max(2).default(0.2),
    maxTokens: Joi.number().integer().min(32).max(8192).default(512),
    responseStyle: Joi.string().valid("short", "balanced", "detailed").default("balanced"),
    instructions: Joi.alternatives().try(
        Joi.array().items(Joi.string().trim().allow("")),
        Joi.string().custom((value, helpers) => {
            try {
                const parsed = JSON.parse(value);
                if (Array.isArray(parsed)) return parsed;
                return [value];
            } catch {
                return [value];
            }
        })
    ).default([]),
    knowledgeBase: knowledgeBaseDto.default([]),
}).unknown(true);

const accessControlDto = Joi.alternatives().try(
    Joi.object({
        allowedDomains: Joi.array().items(Joi.string().trim()).optional(),
        blockedRoutes: Joi.array().items(Joi.string().trim()).optional(),
    }),
    Joi.string().custom((value, helpers) => {
        try {
            const parsed = JSON.parse(value) as unknown;
            const { error } = Joi.object({
                allowedDomains: Joi.array().items(Joi.string().trim()).optional(),
                blockedRoutes: Joi.array().items(Joi.string().trim()).optional(),
            }).validate(parsed);
            if (error) return helpers.error("any.invalid");
            return parsed;
        } catch {
            return helpers.error("any.invalid");
        }
    })
).optional();

const updateAssistantDto = Joi.object({
    name: Joi.string().trim().min(2).max(120).optional(),
    description: Joi.string().allow("").optional(),
    firstMessage: Joi.string().allow("").optional(),
    voiceId: Joi.string().allow("").optional(),
    provider: Joi.string().trim().optional(),
    tone: Joi.string().valid("formal", "casual", "sales", "support").optional(),
    model: Joi.string().trim().empty("").optional(),
    temperature: Joi.number().min(0).max(2).optional(),
    maxTokens: Joi.number().integer().min(32).max(8192).optional(),
    responseStyle: Joi.string().valid("short", "balanced", "detailed").optional(),
    status: Joi.string().valid("draft", "live", "archived").optional(),
    accessControl: accessControlDto,
    instructions: Joi.alternatives().try(
        Joi.array().items(Joi.string().trim().allow("")),
        Joi.string().custom((value, helpers) => {
            try {
                const parsed = JSON.parse(value);
                if (Array.isArray(parsed)) return parsed;
                return [value];
            } catch {
                return [value];
            }
        })
    ).optional(),
}).min(1);

const addKnowledgeBaseItemDto = Joi.object({
    type: Joi.string().valid("website", "file", "faq", "document", "link", "text").required(),
    title: Joi.string().trim().min(1).max(300).required(),
    value: Joi.string().allow("").optional(),
    fileName: Joi.string().allow("").optional(),
    metadata: Joi.object().unknown(true).optional(),
});

const updateKnowledgeBaseItemDto = Joi.object({
    title: Joi.string().trim().min(1).max(300).optional(),
    value: Joi.string().allow("").optional(),
    fileName: Joi.string().allow("").optional(),
    metadata: Joi.object().unknown(true).optional(),
}).min(1);

const removeKnowledgeBaseItemDto = Joi.object({
    knowledgeUid: Joi.string().trim().min(1).required(),
});

const deployAssistantDto = Joi.object({
    provider: Joi.string().default("widget"),
    environment: Joi.string().valid("development", "staging", "production").default("production"),
    cdnUrl: Joi.string().uri().optional(),
});

export {
    createAssistantDto,
    updateAssistantDto,
    addKnowledgeBaseItemDto,
    updateKnowledgeBaseItemDto,
    removeKnowledgeBaseItemDto,
    deployAssistantDto,
};
