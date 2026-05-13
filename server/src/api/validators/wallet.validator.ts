import Joi from 'joi';

export const fundSchema = Joi.object({
  amount: Joi.number().positive().required(),
});

export const createEscrowSchema = Joi.object({
  merchantId: Joi.string().required(),
  amount: Joi.number().positive().required(),
});
