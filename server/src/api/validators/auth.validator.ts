import Joi from 'joi';

export const registerSchema = Joi.object({
  name: Joi.string().min(2).required().messages({
    'string.min': 'Name must be at least 2 characters',
  }),
  email: Joi.string().email().required().messages({
    'string.email': 'Invalid email address',
  }),
  password: Joi.string().min(8).required().messages({
    'string.min': 'Password must be at least 8 characters',
  }),
  phoneNumber: Joi.string().pattern(/^\+?[1-9]\d{1,14}$/).required().messages({
    'string.pattern.base': 'Invalid phone number format',
  }),
});

export const loginSchema = Joi.object({
  email: Joi.string().email().required().messages({
    'string.email': 'Invalid email address',
  }),
  password: Joi.string().required(),
});

export const verifyPhoneSchema = Joi.object({
  code: Joi.string().length(6).required().messages({
    'string.length': 'Verification code must be 6 digits',
  }),
});
