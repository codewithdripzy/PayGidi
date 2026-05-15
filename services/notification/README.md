# Notification Service

The Notification Service is the communication engine of the PayGidi platform. It handles the delivery of messages across multiple channels, ensuring users are alerted about important account activities, security events, and transaction updates.

## Technical Stack
- **Language**: Go (Golang)
- **Web Framework**: Gin Gonic
- **Communication**: gRPC (for high-speed internal alerts), REST (for secondary triggers).
- **Integrations**: Support for external Email (SMTP/SES) and SMS providers (Termii/Twilio).

## Core Responsibilities
1. **Multi-Channel Messaging**: Sending notifications via Email, SMS, and in-app activity logs.
2. **Template Management**: Managing message templates for consistent branding and communication.
3. **Internal Alerts**: Exposing a gRPC interface for other services to trigger notifications instantly (e.g., Auth OTPs, Transaction alerts).
4. **Activity Logging**: Recording user actions for audit and security purposes.

## Architecture
- `controllers/`: Handles HTTP requests for sending ad-hoc notifications.
- `connection/grpc/`: Implementation of the gRPC server that listens for notification requests from other microservices.
- `services/notification/`: Core logic for dispatching messages to various providers.
- `models/`: Database schemas for tracking sent notifications and user activities.

## Key Features

### 1. gRPC-First Communication
The service is designed to be the primary target for all internal messaging needs. Services like `Account` and `Wallet` call this service via gRPC to send:
- Verification OTPs.
- Transaction success/failure alerts.
- Security warnings.

### 2. Multi-Channel Support
- **Email**: Integration for sending HTML and text-based emails.
- **SMS**: Integration for sending time-sensitive verification codes and alerts via SMS.
- **Activity Logs**: Every notification can be optionally logged as an "Activity" for the user to view in their history.

### 3. REST API
Provides endpoints for:
- `/notification/email`: Send a custom email.
- `/notification/sms`: Send a custom SMS.
- `/notification/activity`: Manually record a user activity.

## Environment Variables
- `DB_HOST`, `DB_PORT`, etc.
- `SMTP_HOST`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASS`: For email delivery.
- `TERMII_API_KEY`: For SMS delivery in the Nigerian market.
- `GRPC_PORT`, `APP_PORT`: Ports for internal and external communication.

## API Documentation
The interactive Swagger documentation is available at:
`http://api.paygidi.site/docs/notification/swagger.json` (via Gateway)
