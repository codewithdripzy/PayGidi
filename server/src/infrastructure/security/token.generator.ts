import jwt from 'jsonwebtoken';

export interface TokenPayload {
  userId: string;
  role: string;
}

export class TokenGenerator {
  private static readonly SECRET = process.env.JWT_SECRET || 'paygidi-super-secret';
  private static readonly EXPIRES_IN = '1d';

  static generate(payload: TokenPayload): string {
    return jwt.sign(payload, this.SECRET, { expiresIn: this.EXPIRES_IN });
  }

  static verify(token: string): TokenPayload {
    return jwt.verify(token, this.SECRET) as TokenPayload;
  }
}
