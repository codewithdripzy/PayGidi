import { Request, Response, NextFunction } from 'express';

const missing = (request: Request, fields: string[]) =>
  fields.filter((field) => {
    const value = request.body?.[field];
    return value === undefined || value === null || String(value).trim() === '';
  });

export function requireBodyFields(...fields: string[]) {
  return (request: Request, response: Response, next: NextFunction) => {
    const missingFields = missing(request, fields);
    if (missingFields.length > 0) {
      return response.status(400).json({
        success: false,
        message: `Missing required fields: ${missingFields.join(', ')}`,
      });
    }
    return next();
  };
}

export function positiveAmount(
  request: Request,
  response: Response,
  next: NextFunction,
) {
  const amount = Number(request.body?.amount);
  if (!Number.isFinite(amount) || amount <= 0)
    return response
      .status(400)
      .json({ success: false, message: 'Amount must be greater than zero' });
  return next();
}

export function validEmailNotification(
  request: Request,
  response: Response,
  next: NextFunction,
) {
  const email = String(request.body?.to || '');
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email))
    return response
      .status(400)
      .json({ success: false, message: 'A valid recipient email is required' });
  return next();
}
