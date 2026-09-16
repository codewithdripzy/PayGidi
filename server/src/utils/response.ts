import { Response } from 'express';
export const ok = (
  res: Response,
  data: unknown = {},
  message = 'Success',
  status = 200,
) => res.status(status).json({ status, success: true, message, data });
export const fail = (
  res: Response,
  message: string,
  status = 400,
  data: unknown = {},
) => res.status(status).json({ status, success: false, message, data });
