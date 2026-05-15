# PayGidi Technical Documentation

Welcome to the technical documentation for PayGidi, a microservices-based trust and payment infrastructure.

## System Architecture

PayGidi is built using a microservices architecture to ensure scalability, resilience, and modularity. The services communicate via **gRPC** for internal low-latency calls and expose **REST APIs** through a centralized **Gateway**.

### Core Services

| Service | Responsibility | Documentation |
| ------- | -------------- | ------------- |
| **Gateway** | Entry point, routing, and doc aggregation | [README](file:///Users/user/Dev/Squad/PayGidi/services/gateway/README.md) |
| **Account** | Identity, Auth (OTP), and Profiles | [README](file:///Users/user/Dev/Squad/PayGidi/services/account/README.md) |
| **Wallet** | Balances, Transfers, and Escrow | [README](file:///Users/user/Dev/Squad/PayGidi/services/wallet/README.md) |
| **AI (KYB)** | AI-driven verification and Trust Scoring | [README](file:///Users/user/Dev/Squad/PayGidi/services/ai/README.md) |
| **Transaction**| Historical data and Audit logs | [README](file:///Users/user/Dev/Squad/PayGidi/services/transaction/README.md) |
| **Notification**| Multi-channel messaging (Email/SMS) | [README](file:///Users/user/Dev/Squad/PayGidi/services/notification/README.md) |

## High-Level Data Flow

1. **Authentication**: Handled by `Account Service` via OTP. JWTs are issued for stateless session management.
2. **Payments**: Initiated via `Wallet Service`, which interfaces with `Squad` (GTBank) for virtual accounts and transfers.
3. **Verification**: When a business registers or a high-value payment is made, the `AI Service` analyzes documents and assigns a trust score.
4. **Notifications**: Every significant event triggers a gRPC call to the `Notification Service` to alert the user.

## Infrastructure & DevOps

### Local Development
The entire stack can be run locally using Docker Compose:
```bash
docker-compose up --build
```

### CI/CD
We use **GitHub Actions** for automated testing and deployment. Each service has its own workflow to enable independent scaling and updates.

### Monitoring & Observability
- **Health Checks**: Every service exposes a `/health` endpoint.
- **Centralized Logs**: Services log to standard output, which is aggregated by the container orchestrator (ECS/CloudWatch).
- **API Docs**: Centralized Swagger UI at `http://api.paygidi.site/docs`.

## Security Patterns
- **JWT Authentication**: Secure, stateless tokens for all API requests.
- **Least Privilege**: Services communicate via private networks; only the Gateway is exposed publicly.
- **Secret Management**: API keys and DB credentials are managed via environment variables and AWS Secrets Manager.
- **Idempotency**: Critical financial operations (transfers, funding) use idempotency keys to prevent duplicate transactions.

---

For more details on the deployment architecture, see [ARCHITECTURE.md](file:///Users/user/Dev/Squad/PayGidi/services/ARCHITECTURE.md).
