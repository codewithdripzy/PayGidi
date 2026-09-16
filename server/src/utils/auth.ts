import jwt from 'jsonwebtoken';
import bcrypt from 'bcrypt';
import { randomUUID } from 'crypto';
const secret = () => {
  const value = process.env.JWT_SECRET || process.env.ACCESS_TOKEN_SECRET;
  if (!value && process.env.NODE_ENV === 'production') {
    throw new Error('JWT_SECRET is required in production');
  }
  return value || 'paygidi-development-secret';
};
export const signToken = (userId: string, role = 'user') =>
  jwt.sign({ userId, role }, secret(), { expiresIn: '1d' });
export const verifyToken = (token: string) =>
  jwt.verify(token, secret()) as {
    userId: string;
    role: string;
  };
export const hash = (value: string) => bcrypt.hash(value, 12);
export const compare = (value: string, digest: string) =>
  bcrypt.compare(value, digest);
export const uid = () => randomUUID();
