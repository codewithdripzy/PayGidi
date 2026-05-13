# PayGidi

AI-powered escrow and trust infrastructure for African commerce.

---

## OVERVIEW

PayGidi is a fintech infrastructure system that secures payments between buyers and merchants using escrow logic and AI-driven trust scoring.

Funds are only released when merchants pass verification and risk evaluation.

---

## CORE IDEA

Instead of sending money directly to businesses:

Buyer → Escrow → Trust Engine → Merchant payout

---

## WHY THIS EXISTS

Online commerce in emerging markets suffers from:

- fraud
- fake merchants
- unreliable vendors
- lack of trust infrastructure

PayGidi solves this by introducing:

- escrow-backed payments
- AI trust scoring
- KYB verification
- fraud prediction system

---

## SYSTEM ARCHITECTURE

Backend:

- Node.js (Express)
- TypeScript
- MongoDB

External:

- Squad Payment API (payments + transfers)

Core Services:

- Auth Service
- KYB Verification Service
- Escrow Engine
- Trust Scoring Engine
- Transaction Service

---

## KEY FEATURES

## 1. Escrow Payments

Funds are held until trust conditions are met.

## 2. KYB Verification

Businesses must verify identity before receiving payouts.

## 3. AI Trust Scoring

Every merchant has a dynamic trust score.

## 4. Fraud Detection

Behavioral + transactional anomaly detection.

## 5. Conditional Payouts

Funds released based on trust + rules.

---

## TRUST SCORE MODEL

Trust score is computed using:

- KYB strength
- transaction behavior
- account age
- device consistency
- location stability
- dispute history

Score range:

- 0–100

---

## API BASE URL

https://api.paygidi.app/

