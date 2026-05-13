# PayGidi

pay smart. trust first. trade safe.

PayGidi is a modern Nigerian fintech platform that combines escrow payments, AI-powered trust scoring, and KYB verification into a single mobile-first infrastructure product.

The platform helps buyers and businesses transact safely by holding payments securely until trust and verification conditions are met.

---

## overview

Traditional digital commerce across Africa still struggles with:

- fraud
- fake businesses
- payment disputes
- low buyer trust
- weak verification systems

PayGidi solves this by introducing:

- escrow-powered payments
- merchant trust scoring
- behavioral fraud detection
- KYB verification
- conditional fund release

Instead of instantly releasing funds, PayGidi intelligently evaluates trust and risk before payouts occur.

---

# core concept

Buyer sends payment → funds held securely → merchant verification + AI trust analysis → payout released conditionally.

PayGidi is not a bank.

Funds are orchestrated through secure payment infrastructure and conditional release logic.

---

# key features

## escrow payments

- secure transaction holding
- conditional fund release
- transaction state tracking
- buyer protection layer

---

## AI trust scoring

Dynamic merchant trust scoring based on:

- KYB completion
- transaction history
- payout behavior
- dispute frequency
- device consistency
- account age
- behavioral anomalies
- location mismatch

Trust scores update continuously over time.

---

## KYB verification

Merchant verification flow includes:

- CAC verification
- selfie verification
- identity validation
- bank account checks
- business information review

---

## dispute management

- buyer dispute system
- merchant response workflow
- fund locking during investigation
- manual admin review support

---

## wallet infrastructure

- wallet funding
- escrow balance management
- payout tracking
- transaction history

---

# architecture

## frontend

- Flutter mobile application
- role-based conditional rendering
- single app for buyers and merchants

---

## backend services

### payment orchestrator
Handles:
- wallet funding
- transfers
- payout execution
- escrow states

### escrow engine
Handles:
- payment lifecycle
- release conditions
- hold logic
- dispute locking

### trust engine
Handles:
- AI trust scoring
- fraud analysis
- risk classification
- behavioral intelligence

### KYB service
Handles:
- document verification
- business validation
- identity verification

---

# tech stack

## mobile
- Flutter

## backend
- Node.js

## database
- MongoDB or PostgreSQL

## cache
- Redis

## payments
- Squad API

## storage
- Cloudinary

## AI / risk analysis
- Python services
- rule engine + anomaly detection

---

# product principles

- trust before money moves
- explain every hold or delay
- clarity over complexity
- minimal fintech UX
- infrastructure-grade reliability
- african-first but globally competitive

---

# design system

PayGidi follows a clean fintech design language inspired by Squad by GTCO.

## design rules

- lowercase-first typography
- no heavy shadows
- no glow effects
- moderate border radius
- flat clean UI
- minimal gradients
- calm institutional feel

---

## brand gradient

```css
linear-gradient(45deg, #fe4b1f, #9d0063)
```