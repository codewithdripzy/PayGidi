import { Request, Response, NextFunction } from 'express';
import { AppError, ErrorCode } from '../../core/errors/app-error';
import logger from '../../infrastructure/logging/logger';

export const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  if (err instanceof AppError) {
    logger.warn(`${err.code}: ${err.message}`, {
      path: req.path,
      method: req.method,
      userId: (req as any).user?.userId,
    });

    return res.status(err.statusCode).json({
      success: false,
      message: err.message,
      code: err.code,
    });
  }

  // Handle mongoose validation errors
  if (err.name === 'ValidationError') {
    return res.status(400).json({
      success: false,
      message: err.message,
      code: ErrorCode.VALIDATION_ERROR,
    });
  }

  // Unexpected errors
  logger.error('Unhandled Error:', err);

  return res.status(500).json({
    success: false,
    message: process.env.NODE_ENV === 'production' 
      ? 'An unexpected error occurred' 
      : err.message,
    code: ErrorCode.INTERNAL_ERROR,
  });
};
