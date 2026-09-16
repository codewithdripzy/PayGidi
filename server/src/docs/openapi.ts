const jsonResponse = {
  '200': { description: 'Successful response' },
  '400': { description: 'Invalid request' },
  '401': { description: 'Authentication required' },
  '500': { description: 'Internal server error' },
};

const requestBody = (
  properties: Record<string, unknown>,
  required: string[] = [],
) => ({
  required: true,
  content: {
    'application/json': {
      schema: {
        type: 'object',
        properties,
        required,
      },
    },
  },
});

const protectedPost = (summary: string) => ({
  post: {
    summary,
    security: [{ bearerAuth: [] }],
    responses: jsonResponse,
  },
});

export const openApiDocument = {
  openapi: '3.0.3',
  info: {
    title: 'PayGidi API',
    version: '1.0.0',
    description: 'PayGidi fintech monolith API.',
  },
  servers: [{ url: '/api/v1', description: 'Current server' }],
  tags: [
    { name: 'Health' },
    { name: 'Account' },
    { name: 'Wallet' },
    { name: 'Payments' },
    { name: 'Transactions' },
    { name: 'KYB' },
    { name: 'Notifications' },
  ],
  paths: {
    '/health': {
      get: {
        tags: ['Health'],
        summary: 'Liveness check',
        responses: jsonResponse,
      },
    },
    '/ready': {
      get: {
        tags: ['Health'],
        summary: 'Database readiness check',
        responses: jsonResponse,
      },
    },
    '/auth': {
      post: {
        tags: ['Account'],
        summary: 'Request login OTP',
        requestBody: requestBody(
          {
            phone: {
              type: 'string',
              example: '+2348012345678',
              description: 'User phone number.',
            },
            accountType: {
              type: 'string',
              enum: ['individual', 'business'],
              example: 'individual',
              description: 'Required when registering a new account.',
            },
          },
          ['phone'],
        ),
        responses: jsonResponse,
      },
    },
    '/auth/verify': {
      post: {
        tags: ['Account'],
        summary: 'Verify login OTP',
        requestBody: requestBody(
          {
            phone: { type: 'string', example: '+2348012345678' },
            otp: { type: 'string', example: '12345' },
            forWhat: { type: 'string', example: 'login' },
          },
          ['phone', 'otp', 'forWhat'],
        ),
        responses: jsonResponse,
      },
    },
    '/auth/complete': {
      post: {
        tags: ['Account'],
        summary: 'Complete account profile',
        security: [{ bearerAuth: [] }],
        requestBody: requestBody({
          firstName: { type: 'string', example: 'Ada' },
          lastName: { type: 'string', example: 'Lovelace' },
          email: {
            type: 'string',
            format: 'email',
            example: 'ada@example.com',
          },
          accountType: { type: 'string', enum: ['individual', 'business'] },
          businessName: { type: 'string', example: 'Ada Ventures' },
        }),
        responses: jsonResponse,
      },
    },
    '/auth/verify/nin': {
      post: {
        tags: ['Account'],
        summary: 'Verify NIN',
        requestBody: requestBody(
          { nin: { type: 'string', example: '12345678901' } },
          ['nin'],
        ),
        responses: jsonResponse,
      },
    },
    '/auth/verify/bvn-image': {
      post: {
        tags: ['Account'],
        summary: 'Verify BVN image',
        requestBody: requestBody({
          bvn: { type: 'string', example: '12345678901' },
        }),
        responses: jsonResponse,
      },
    },
    '/auth/verify/email': {
      post: {
        tags: ['Account'],
        summary: 'Verify email OTP',
        requestBody: requestBody(
          {
            email: {
              type: 'string',
              format: 'email',
              example: 'ada@example.com',
            },
            code: { type: 'string', example: '12345' },
          },
          ['email', 'code'],
        ),
        responses: jsonResponse,
      },
    },
    '/auth/otp/request/{otpType}': {
      post: {
        tags: ['Account'],
        summary: 'Request email or phone OTP',
        parameters: [
          {
            name: 'otpType',
            in: 'path',
            required: true,
            schema: { type: 'string' },
          },
        ],
        requestBody: requestBody(
          {
            phone: { type: 'string', example: '+2348012345678' },
            email: {
              type: 'string',
              format: 'email',
              example: 'ada@example.com',
            },
            forWhat: { type: 'string', example: 'verification' },
          },
          ['forWhat'],
        ),
        responses: jsonResponse,
      },
    },
    '/auth/biometric': {
      post: {
        tags: ['Account'],
        summary: 'Authenticate with biometrics',
        requestBody: requestBody(
          { biometricId: { type: 'string', example: 'device-biometric-id' } },
          ['biometricId'],
        ),
        responses: jsonResponse,
      },
    },
    '/auth/biometric/register': protectedPost('Register biometric identity'),
    '/auth/logout': protectedPost('Log out'),
    '/account': {
      get: {
        tags: ['Account'],
        summary: 'Get account',
        security: [{ bearerAuth: [] }],
        responses: jsonResponse,
      },
      delete: {
        tags: ['Account'],
        summary: 'Delete account',
        security: [{ bearerAuth: [] }],
        responses: jsonResponse,
      },
    },
    '/account/me': {
      get: {
        tags: ['Account'],
        summary: 'Get current user',
        security: [{ bearerAuth: [] }],
        responses: jsonResponse,
      },
    },
    '/account/pin': {
      post: protectedPost('Set PIN').post,
      put: protectedPost('Update PIN').post,
    },
    '/account/devices': {
      get: {
        tags: ['Account'],
        summary: 'List devices',
        security: [{ bearerAuth: [] }],
        responses: jsonResponse,
      },
    },
    '/business/profile': {
      get: {
        tags: ['Account'],
        summary: 'Get business profile',
        security: [{ bearerAuth: [] }],
        responses: jsonResponse,
      },
      put: protectedPost('Update business profile').post,
    },
    '/business/docs': { put: protectedPost('Update business documents').post },
    '/wallet': {
      get: {
        tags: ['Wallet'],
        summary: 'Get wallet',
        security: [{ bearerAuth: [] }],
        responses: jsonResponse,
      },
    },
    '/wallet/create': protectedPost('Create virtual wallet'),
    '/wallet/balance': {
      get: {
        tags: ['Wallet'],
        summary: 'Get wallet balance',
        security: [{ bearerAuth: [] }],
        responses: jsonResponse,
      },
    },
    '/wallet/banks': {
      get: { tags: ['Wallet'], summary: 'List banks', responses: jsonResponse },
    },
    '/wallet/transfer': protectedPost('Initiate transfer'),
    '/wallet/transfer/lookup': {
      post: {
        tags: ['Wallet'],
        summary: 'Resolve bank account',
        responses: jsonResponse,
      },
    },
    '/wallet/transfer/list': {
      get: {
        tags: ['Wallet'],
        summary: 'List transfers',
        security: [{ bearerAuth: [] }],
        responses: jsonResponse,
      },
    },
    '/wallet/transfer/requery': protectedPost('Requery transfer'),
    '/wallet/disputes': {
      get: {
        tags: ['Wallet'],
        summary: 'List disputes',
        security: [{ bearerAuth: [] }],
        responses: jsonResponse,
      },
    },
    '/wallet/payments/new': protectedPost('Create payment'),
    '/wallet/finance/summary': {
      get: {
        tags: ['Wallet'],
        summary: 'Get finance summary',
        security: [{ bearerAuth: [] }],
        responses: jsonResponse,
      },
    },
    '/wallet/finance/savings': {
      get: {
        tags: ['Wallet'],
        summary: 'List savings goals',
        security: [{ bearerAuth: [] }],
        responses: jsonResponse,
      },
      post: protectedPost('Create savings goal').post,
    },
    '/wallet/finance/thrifts': {
      get: {
        tags: ['Wallet'],
        summary: 'List thrifts',
        security: [{ bearerAuth: [] }],
        responses: jsonResponse,
      },
      post: protectedPost('Create thrift').post,
    },
    '/payment/new': protectedPost('Create payment'),
    '/payment/{payment_id}': {
      get: {
        tags: ['Payments'],
        summary: 'Get payment',
        parameters: [
          {
            name: 'payment_id',
            in: 'path',
            required: true,
            schema: { type: 'string' },
          },
        ],
        responses: jsonResponse,
      },
    },
    '/transactions': {
      get: {
        tags: ['Transactions'],
        summary: 'List customer transactions',
        security: [{ bearerAuth: [] }],
        responses: jsonResponse,
      },
    },
    '/kyb/submit': {
      post: {
        tags: ['KYB'],
        summary: 'Submit business KYB',
        responses: jsonResponse,
      },
    },
    '/kyb/payment/submit': {
      post: {
        tags: ['KYB'],
        summary: 'Submit payment KYB',
        responses: jsonResponse,
      },
    },
    '/kyb/status': {
      get: {
        tags: ['KYB'],
        summary: 'Get KYB status',
        responses: jsonResponse,
      },
    },
    '/notification/email': {
      post: {
        tags: ['Notifications'],
        summary: 'Send email notification',
        responses: jsonResponse,
      },
    },
    '/notification/sms': {
      post: {
        tags: ['Notifications'],
        summary: 'Send SMS notification',
        responses: jsonResponse,
      },
    },
    '/notification/activity': protectedPost('Record activity'),
    '/webhook/squad': {
      post: {
        tags: ['Wallet'],
        summary: 'Receive Squad webhook',
        responses: jsonResponse,
      },
    },
  },
  components: {
    securitySchemes: {
      bearerAuth: { type: 'http', scheme: 'bearer', bearerFormat: 'JWT' },
    },
  },
};
