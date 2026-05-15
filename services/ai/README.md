# AI Service (KYB Verification)

The AI Service is the trust engine of PayGidi. It leverages Large Language Models (LLMs) and computer vision to perform automated Know Your Business (KYB) verifications, document analysis, and risk assessment.

## Technical Stack
- **Language**: Go (Golang)
- **Web Framework**: Gin Gonic
- **AI/ML**: Integration with Gemini (Google AI) and other OCR tools.
- **Database**: PostgreSQL (GORM)
- **Communication**: gRPC (server for cross-service verification).

## Core Responsibilities
1. **Document Analysis**: Automated extraction of data from business registration documents (CAC, Tax IDs, etc.).
2. **Business Verification**: Matching submitted business data against official records.
3. **Trust Scoring**: Generating a numerical trust score for businesses based on document validity and historical data.
4. **KYB Orchestration**: Managing the multi-step verification pipeline for onboarding.
5. **Payment KYB**: Specialized verification for high-value or suspicious payments to ensure compliance.

## Architecture
- `controllers/`: Handles submission of KYB documents and status queries.
- `services/kyb/`: The `Orchestrator` that coordinates document processing, AI analysis, and database updates.
- `providers/ai/`: Abstraction for AI models (Gemini, etc.) used for document parsing.
- `models/`: Defines the `Business`, `Director`, and `Document` schemas used for verification tracking.

## Key Features

### 1. Automated Document Parsing
Using advanced AI prompts, the service can parse various document types:
- Certificate of Incorporation.
- Memorandum and Articles of Association.
- Proof of Address and Director IDs.

### 2. KYB Pipeline
1. **Submission**: User uploads business documents.
2. **Analysis**: AI extracts key information (Registration Number, Incorporation Date, Directors).
3. **Cross-Reference**: Data is validated against user-provided profile info.
4. **Scoring**: A trust score is calculated based on consistency and data confidence.

### 3. Payment-Level Verification
For transactions requiring extra trust, the AI service analyzes the context of the payment to flag potential fraud or compliance issues.

## Prompts & AI Logic
The `PROMPTS.txt` file contains the specialized instructions given to the AI models to ensure accurate extraction and classification of business documents.

## Environment Variables
- `GEMINI_API_KEY`: API key for Google AI services.
- `DB_HOST`, `DB_PORT`, etc.
- `JWT_SECRET`: For authenticated status checks.

## API Documentation
The interactive Swagger documentation is available at:
`http://api.paygidi.site/docs/ai/swagger.json` (via Gateway)
