# Transaction Service

The Transaction Service is the specialized historical data and audit logging module for the PayGidi platform. It provides a centralized view of all financial activities and user interactions across the ecosystem.

## Technical Stack
- **Language**: Go (Golang)
- **Web Framework**: Gin Gonic
- **Database**: PostgreSQL (GORM)
- **Communication**: REST (for historical queries).

## Core Responsibilities
1. **Transaction History**: Aggregating and serving transaction records for individual and business customers.
2. **Audit Logging**: Tracking sensitive activities (logins, profile changes, fund movements).
3. **Filtering & Reporting**: Providing query capabilities to filter transactions by date, type, status, and amount.
4. **Data Consistency**: Synchronizing with other services to ensure a complete and accurate historical ledger.

## Architecture
- `controllers/`: Handles requests for customer transaction history.
- `models/`: Mirroring core data schemas to facilitate complex historical queries.
- `middlewares/`: Security layers including authentication and version validation.

## Key Features

### 1. Unified Transaction View
Allows users to view a consolidated list of all their financial interactions, including:
- Wallet funding (deposits).
- Inter-bank transfers (payouts).
- Trust payments (escrowed funds).

### 2. Customer Identification
The service uses a flexible identifier system to retrieve records for both individuals and businesses:
- `GET /api/v1/transactions/:customerIdentifier`: Fetches all transactions associated with a specific customer.

## Environment Variables
- `DB_HOST`, `DB_PORT`, etc.
- `JWT_SECRET`: For authenticated history checks.
- `HTTP_PORT`: Port on which the service listens for requests.

## API Documentation
The interactive Swagger documentation is available at:
`http://api.paygidi.site/docs/transaction/swagger.json` (via Gateway)
