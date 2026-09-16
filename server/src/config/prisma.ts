import 'dotenv/config';

// eslint-disable-next-line @typescript-eslint/no-var-requires
const { PrismaClient } = require('@prisma/client');

if (!process.env.DATABASE_URL && process.env.DB_HOST) {
  const user = encodeURIComponent(process.env.DB_USER || 'postgres');
  const password = encodeURIComponent(process.env.DB_PASSWORD || 'postgres');
  const host = process.env.DB_HOST;
  const port = process.env.DB_PORT || '5432';
  const database = encodeURIComponent(process.env.DB_NAME || 'paygidi');
  const sslMode = process.env.DB_SSL === 'false' ? '' : '?sslmode=require';
  process.env.DATABASE_URL = `postgresql://${user}:${password}@${host}:${port}/${database}${sslMode}`;
}

const globalForPrisma = globalThis as unknown as { prisma?: any };
const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: process.env.NODE_ENV === 'development' ? ['warn', 'error'] : ['error'],
  });

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma;

export default prisma;
