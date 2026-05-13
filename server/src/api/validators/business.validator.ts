import Joi from 'joi';

export const onboardSchema = Joi.object({
  businessName: Joi.string().required(),
  cacNumber: Joi.string().required(),
  metadata: Joi.object().optional(),
});
