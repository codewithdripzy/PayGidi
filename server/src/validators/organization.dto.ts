import Joi from "joi";

const createOrganizationDto = Joi.object({
    name: Joi.string().trim().min(2).max(100).required(),
    description: Joi.string().allow("").max(1000).optional(),
    type: Joi.string().valid("public", "private").default("private"),
});

const inviteOrganizationMemberDto = Joi.object({
    email: Joi.string().email().required(),
    role: Joi.string().valid("admin", "member").default("member"),
});

export { createOrganizationDto, inviteOrganizationMemberDto };
