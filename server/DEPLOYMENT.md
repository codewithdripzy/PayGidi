# PayGidi server deployment

## Environment separation

Use separate PostgreSQL databases and credentials for staging and production. Never point staging at the production database.

Create these local files from the committed templates:

```bash
cp .env.staging.example .env.staging
cp .env.production.example .env.production
```

Keep both files out of git. In Vercel, create separate projects or separate environment variable sets for Preview/Staging and Production.

## Required environment variables

Set `DATABASE_URL` to the PostgreSQL connection string. The server also accepts the Go service variables (`DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, and `DB_NAME`) and builds a connection string from them when `DATABASE_URL` is absent.

Set `JWT_SECRET`, `ALLOWED_ORIGINS`, and the provider variables required by the features being enabled. Resend is used for email when `RESEND_API_KEY` is present. Termii is used for SMS when `TERMII_API_KEY` is present; `TERMII_SENDER_ID` defaults to `Termii` and can be overridden later.

For OTP delivery, configure an approved Termii sender ID. The default channel is `generic`; switch `TERMII_CHANNEL` to `dnd` only after DND has been enabled for the account. Termii requires Nigerian phone numbers in international format and accepts SMS messages through `POST /api/sms/send`.

Do not deploy repository `.env` files. Set these values in Vercel project settings or the deployment secret manager.

## First deployment

```bash
pnpm install
pnpm db:generate
pnpm db:deploy:staging
pnpm build
```

Run `pnpm db:deploy:staging` against staging first. Run `pnpm db:deploy:production` from a trusted production deployment job only after the staging migration and application checks pass. Do not run `prisma migrate dev` against either shared environment.

If the target PostgreSQL database already contains the Go service tables, inspect and reconcile the schema before applying the initial migration. Once it matches this Prisma schema, baseline the migration with `prisma migrate resolve --applied 20260916000000_init` instead of trying to recreate existing tables.

## Health and documentation

- `GET /health` — liveness check
- `GET /api/v1/health` — API liveness check
- `GET /api/v1/ready` — PostgreSQL readiness check
- `GET /docs` — Swagger UI
- `GET /docs/openapi.json` — OpenAPI document

After deployment, verify `/api/v1/ready`, `/docs/openapi.json`, authentication, an email delivery, an SMS delivery, and the Squad webhook signature before accepting real payments.
