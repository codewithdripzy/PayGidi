# API Gateway

The API Gateway is the single entry point for all client-facing requests in the PayGidi microservice ecosystem. It handles request routing, documentation aggregation, and acts as a reverse proxy for the internal services.

## Technical Stack
- **Language**: Go (Golang)
- **Web Framework**: Gin Gonic
- **Reverse Proxy**: `net/http/httputil`

## Core Responsibilities
1. **Request Routing**: Forwarding inbound traffic to the appropriate microservice based on path prefixes.
2. **Centralized Documentation**: Aggregating Swagger/OpenAPI specifications from all services into a single UI.
3. **Health Monitoring**: Providing a unified health check endpoint for the entire system.
4. **Environment Abstraction**: Mapping internal service URLs (Docker-based) to external client-facing routes.

## Architecture
The Gateway uses a lightweight Gin server to define proxies:
- `/api/v1/auth/*` -> Account Service
- `/api/v1/wallet/*` -> Wallet Service
- `/api/v1/transactions/*` -> Transaction Service
- `/api/v1/kyb/*` -> AI Service
- `/api/v1/notification/*` -> Notification Service

## Key Features

### 1. Centralized Swagger UI
Instead of visiting each service's documentation separately, the Gateway hosts a custom Swagger UI at `/docs`. This UI dynamically fetches the `swagger.json` from each microservice, allowing developers to explore the entire API from one place.

### 2. Reverse Proxy with Path Rewriting
The Gateway handles complex path mappings. For example, it can proxy `/api/v1/auth/login` to `account-service:8080/auth/login` while preserving headers and request bodies.

### 3. Error Handling
The Gateway includes custom error handlers to manage service timeouts or "Bad Gateway" (502) errors, ensuring a consistent error format for clients.

## Routing Table

| Path Prefix | Target Service | Purpose |
| ----------- | -------------- | ------- |
| `/api/v1/auth` | Account Service | User registration & login |
| `/api/v1/business` | Account Service | Business profile management |
| `/api/v1/wallet` | Wallet Service | Balance & virtual accounts |
| `/api/v1/payment` | Wallet Service | Trust-based payments |
| `/api/v1/transactions` | Transaction Service | History & audit logs |
| `/api/v1/kyb` | AI Service | Business verification |
| `/api/v1/notification`| Notification Service| Ad-hoc messaging |
| `/docs` | (Internal) | Centralized Swagger UI |

## Environment Variables
- `PORT`: The port on which the Gateway listens (default 8080).
- `ACCOUNT_SERVICE_URL`, `WALLET_SERVICE_URL`, etc.: Internal URLs of the microservices.

## API Documentation
The primary documentation portal is available at:
`http://api.paygidi.site/docs`
