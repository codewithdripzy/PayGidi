import Joi from "joi";

const createWaitlistEntryDto = Joi.object({
    email: Joi.string().email().required(),
    name: Joi.string().trim().allow("").max(120).optional(),
    source: Joi.string().trim().allow("").max(120).optional(),
});

export { createWaitlistEntryDto };
