import express from 'express';
import { randomUUID } from 'crypto';
import cors from 'cors';
import cookieParser from 'cookie-parser';
import morgan from 'morgan';
import rateLimit from 'express-rate-limit';
import accountRoutes from './routes/account.routes';
import walletRoutes from './routes/wallet.routes';
import transactionRoutes from './routes/transaction.routes';
import aiRoutes from './routes/ai.routes';
import notificationRoutes from './routes/notification.routes';
import paymentRoutes from './routes/payment.routes';
import { webhook } from './controllers/wallet.controller';
import database from './config/database';
import { wrapRouter } from './utils/async-router';
import docsRoutes from './routes/docs.routes';
const app = express();

const publicErrorMessage = (error: any) => {
  if (process.env.EXPOSE_ERROR_DETAILS === 'true' && error?.message)
    return error.message;

  if (error?.name?.startsWith('PrismaClient'))
    return 'The database request failed. Verify DATABASE_URL and Prisma migrations.';

  switch (error?.code) {
    case 'P1001':
    case 'P1002':
    case 'P1017':
      return 'The database is unavailable. Verify DATABASE_URL and database connectivity.';
    case 'P2021':
    case 'P2022':
      return 'The production database schema is not up to date. Run Prisma migrations.';
    case 'P2002':
      return 'A record with these details already exists.';
    case 'P2025':
      return 'The requested record was not found.';
    default:
      if (error?.message?.includes('Termii'))
        return 'The OTP SMS provider failed. Verify the Termii production configuration.';
      return 'The request could not be completed. Check the server logs using the request ID.';
  }
};

app.use((request, response, next) => {
  const requestId = request.get('x-request-id') || randomUUID();
  response.setHeader('x-request-id', requestId);
  response.locals.requestId = requestId;
  next();
});

// Vercel and other reverse proxies provide the client IP in X-Forwarded-For.
// Trust the single platform proxy so express-rate-limit can safely identify it.
const configuredProxyHops = Number.parseInt(
  process.env.TRUST_PROXY_HOPS || '1',
  10,
);
const trustProxyHops = Number.isInteger(configuredProxyHops)
  ? configuredProxyHops
  : 1;
app.set('trust proxy', trustProxyHops);

const apiRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 300,
  standardHeaders: 'draft-7',
  legacyHeaders: false,
  message: { success: false, message: 'Too many requests. Try again later.' },
});

const authRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 20,
  standardHeaders: 'draft-7',
  legacyHeaders: false,
  message: {
    success: false,
    message: 'Too many authentication attempts. Try again later.',
  },
});

const allowedOrigins = (process.env.ALLOWED_ORIGINS || '')
  .split(',')
  .map((origin) => origin.trim())
  .filter(Boolean);

app.use(
  cors({
    credentials: true,
    origin: (origin, callback) => {
      if (
        !origin ||
        allowedOrigins.length === 0 ||
        allowedOrigins.includes(origin)
      ) {
        return callback(null, true);
      }

      return callback(new Error('Origin is not allowed'));
    },
  }),
);
app.use(apiRateLimiter);
app.use(cookieParser());
app.use(
  express.json({
    limit: '10mb',
    verify: (request, _response, buffer) => {
      (request as express.Request & { rawBody?: Buffer }).rawBody =
        Buffer.from(buffer);
    },
  }),
);
app.use(express.urlencoded({ extended: true }));
app.use(morgan('combined'));
app.get('/health', (_req, res) => res.json({ status: 'Gateway is healthy' }));
app.get('/api/v1/health', (_req, res) =>
  res.json({ status: 'Service is healthy' }),
);
app.get('/api/v1/ready', async (_request, response) => {
  try {
    await database.checkHealth();
    return response.json({ status: 'ready', database: 'connected' });
  } catch {
    return response
      .status(503)
      .json({ status: 'not_ready', database: 'unavailable' });
  }
});
app.use('/docs', docsRoutes);
app.use('/api/v1/auth', authRateLimiter);

app.use(async (_request, _response, next) => {
  try {
    await database.getConnection();
    next();
  } catch (error) {
    next(error);
  }
});

app.use('/api/v1', wrapRouter(accountRoutes));
app.use('/api/v1/wallet', wrapRouter(walletRoutes));
app.use('/api/v1/payment', wrapRouter(paymentRoutes));
app.post('/api/v1/webhook/squad', (request, response, next) => {
  Promise.resolve(webhook(request as any, response)).catch(next);
});
app.use('/api/v1/transactions', wrapRouter(transactionRoutes));
app.use('/api/v1/kyb', wrapRouter(aiRoutes));
app.use('/api/v1/notification', wrapRouter(notificationRoutes));
app.use((request, response) =>
  response.status(404).json({
    success: false,
    message: `No route found for ${request.method} ${request.originalUrl}`,
    error: {
      code: 'ROUTE_NOT_FOUND',
      message: `No route found for ${request.method} ${request.originalUrl}`,
      requestId: response.locals.requestId,
    },
  }),
);
app.use(
  (
    error: any,
    request: express.Request,
    response: express.Response,
    _next: express.NextFunction,
  ) => {
    console.error('Unhandled request error', {
      method: request.method,
      path: request.originalUrl,
      requestId: response.locals.requestId,
      code: error?.code,
      status: error?.statusCode || error?.status,
      message: error?.message,
      details: error?.response?.data || error?.meta,
      stack: error?.stack,
    });

    return response
      .status(
        error?.code === 'P2002'
          ? 409
          : error?.code === 'P2025'
            ? 404
            : error?.statusCode || error?.status || 500,
      )
      .json({
        success: false,
        message: publicErrorMessage(error),
        error: {
          code:
            error?.code === 'P2002'
              ? 'RESOURCE_CONFLICT'
              : error?.code === 'P2025'
                ? 'RESOURCE_NOT_FOUND'
                : error?.statusCode || error?.status
                  ? 'REQUEST_ERROR'
                  : 'INTERNAL_SERVER_ERROR',
          message: publicErrorMessage(error),
          requestId: response.locals.requestId,
        },
      });
  },
);
export default app;
