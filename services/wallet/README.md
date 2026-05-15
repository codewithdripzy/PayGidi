# Wallet Service

The Wallet Service is the financial heart of PayGidi. It manages user balances, virtual accounts, transfers, and the trust-based payment system (escrow-like logic).

## Technical Stack
- **Language**: Go (Golang)
- **Web Framework**: Gin Gonic
- **Database**: PostgreSQL (GORM)
- **External Integration**: Squad (by GTBank) for virtual accounts and transfers.
- **Internal Communication**: gRPC (client for Account Service).

## Core Responsibilities
1. **Wallet Management**: Creation and tracking of user wallets and balances.
2. **Virtual Accounts**: Generation of dynamic virtual accounts for funding via Squad.
3. **Fund Transfers**: Processing inter-bank transfers and account lookups.
4. **Trust Payments**: A specialized payment layer where funds are held until conditions are met (integration with KYB service).
5. **Webhooks**: Handling payment notifications from Squad.
6. **Dispute Management**: Tracking and resolving transaction-related disputes.

## Architecture
- `controllers/`: Contains the `WalletController` which coordinates between the DB, external providers, and internal gRPC clients.
- `providers/`: abstraction layer for external payment providers (currently Squad).
- `services/account/`: gRPC client to interact with the Account Service for user verification.
- `models/`: Defines `Wallet`, `Payment`, and `KYC` schemas.
- `dto/`: Data Transfer Objects for API requests and responses.

## Key Features

### 1. Wallet Lifecycle
- **Creation**: Wallets are automatically initialized with virtual account details provided by Squad.
- **Funding**: Users fund wallets via bank transfers to their virtual accounts.
- **Balance Tracking**: Real-time balance updates powered by a transactional ledger.

### 2. Transfers & Payments
- **Account Lookup**: Resolve bank account details before initiating transfers.
- **Transfer Initiation**: Securely send funds to any Nigerian bank.
- **Payment Request**: Create unique payment links for business transactions.

### 3. Trust Layer (Escrow Logic)
The service implements a trust-based payment flow:
1. Funds are authorized from the sender's wallet.
2. Funds are held in a pending state.
3. Funds are released only after the trust conditions (KYB/Verification) are satisfied.

### 4. Squad Integration
- **Virtual Accounts**: Mapping users to Squad's virtual account infrastructure.
- **Webhook Handling**: Verifying and processing inbound payment signals from Squad to update wallet balances.

## Environment Variables
- `DB_HOST`, `DB_PORT`, etc.
- `SQUAD_SECRET_KEY`: Private key for Squad API.
- `ACCOUNT_SERVICE_URL`: gRPC address of the Account Service.
- `JWT_SECRET`: Shared secret for token validation.

## API Documentation
The interactive Swagger documentation is available at:
`http://api.paygidi.site/docs/wallet/swagger.json` (via Gateway)
