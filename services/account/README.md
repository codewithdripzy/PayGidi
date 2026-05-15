# Account Service

The Account Service is the core identity and profile management module for the PayGidi ecosystem. It handles user authentication, business registration, profile management, and identity verification (KYC/KYB).

## Technical Stack
- **Language**: Go (Golang)
- **Web Framework**: Gin Gonic
- **Database**: PostgreSQL (GORM)
- **Communication**: gRPC (for internal service calls), REST (for client communication)
- **Documentation**: Swagger/OpenAPI

## Core Responsibilities
1. **Authentication**: OTP-based authentication (Email/Phone).
2. **Identity Verification**: Integration with NIN and BVN verification systems.
3. **Profile Management**: Handling both Individual and Business account profiles.
4. **Session Management**: JWT-based stateless authentication.
5. **Business Compliance**: Tracking business registration documents and KYB status.

## Architecture
The service follows a modular structure:
- `controllers/`: Handles incoming HTTP requests and validates input.
- `services/`: Contains core business logic (e.g., Auth logic, verification logic).
- `models/`: Defines database schemas and GORM models.
- `proto/`: Contains gRPC service definitions and generated code.
- `validators/`: Input validation DTOs using Gin's binding.
- `middlewares/`: Custom middlewares for authentication, versioning, and validation.

## Key Features

### 1. OTP Authentication Flow
PayGidi uses a secure OTP flow for both registration and login:
- `/auth`: Initiates login/registration by sending an OTP.
- `/auth/verify`: Verifies the OTP and returns a JWT session.
- `/auth/complete`: Finalizes account setup for new users.

### 2. Identity Verification
The service provides endpoints for multi-factor identity verification:
- **NIN Verification**: Validating National Identity Numbers.
- **BVN Image Verification**: Face matching against BVN records.
- **Email Verification**: Standard email confirmation via OTP.

### 3. Business Profiles
Specialized routes for managing business-specific data:
- Profile updates (industry, registration number, etc.).
- Document uploads for KYB compliance.

## gRPC Service
The Account Service exposes an `AuthService` gRPC server to allow other microservices (like Wallet or Transaction) to:
- Retrieve user profile information.
- Validate authentication tokens.
- Check user verification status.

## Environment Variables
Refer to `.env.example` for the required configurations, including:
- `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`
- `JWT_SECRET`
- `HTTP_PORT`, `GRPC_PORT`
- `SQUAD_SECRET_KEY` (for verification integrations)

## API Documentation
The interactive Swagger documentation is available at:
`http://api.paygidi.site/docs/account/swagger.json` (via Gateway)
or `/docs/index.html` when running the service directly.
