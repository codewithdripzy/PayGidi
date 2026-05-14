# Notification Service

This service provides:

- in-app notification creation and retrieval
- email delivery with SMTP
- SMS delivery with Twilio
- activity recording and retrieval

## Endpoints

- `GET /api/v1/health`
- `GET /api/v1/notifications`
- `GET /api/v1/notifications/:id`
- `POST /api/v1/notifications`
- `PATCH /api/v1/notifications/:id/read`
- `POST /api/v1/notifications/email`
- `POST /api/v1/notifications/sms`
- `GET /api/v1/activities`
- `POST /api/v1/activities`

## Environment

Optional database settings:

- `DB_HOST`
- `DB_PORT`
- `DB_USER`
- `DB_PASSWORD`
- `DB_NAME`
- `DB_SSL_MODE`
- `APP_ENV`
- `APP_PORT`

Email delivery requires:

- `SMTP_FROM`
- `SMTP_PASSWORD`
- `SMTP_HOST`
- `SMTP_PORT`

SMS delivery requires:

- `TWILIO_SID`
- `TWILIO_AUTH_TOKEN`
- `TWILIO_PHONE`
