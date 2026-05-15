# Core Architecture

```text
Business submits data
        ↓
Structured validation
        ↓
Document verification
        ↓
Identity verification
        ↓
External data checks
        ↓
Risk scoring engine
        ↓
LLM analysis layer (optional)
        ↓
Approve / Review / Reject
```

The LLM is only:

* summarizing inconsistencies
* extracting fields
* generating fraud insights
* explaining risk

NOT deciding trust alone.

---

# What Businesses Should Provide for KYB

You need different tiers.

# 1. Basic Business Information

This is the minimum onboarding layer.

## Required

* Business name
* CAC/registration number
* Business type

  * Sole proprietorship
  * LLC
  * Partnership
* Business category
* Country
* Business address
* Phone number
* Email
* Website/social links
* Date founded

---

# 2. Owner / Director Verification

This is critical.

Fraud usually hides behind fake businesses.

## Required

For each major owner/director:

* Full legal name
* BVN/NIN (Nigeria)
* Government ID
* Selfie/liveness
* Residential address
* Phone/email
* Percentage ownership

You are actually verifying:

* the humans behind the business
* whether they are real
* whether they are linked to fraud

---

# 3. Business Documents

## Nigeria-specific

You’ll usually need:

### CAC Documents

* Certificate of incorporation
* CAC status report
* BN/RC registration

### Tax

* TIN
* Tax certificate (optional early stage)

### Banking

* Bank account name
* Account number
* Bank verification

### Proof of Address

* Utility bill
* Bank statement
* Lease agreement

---

# 4. Operational Signals

THIS is where your startup becomes powerful.

Most KYB systems stop at documents.

You should verify:

* is this business actually alive?
* is it active?
* is it trustworthy?

## Signals

### Social Presence

* Instagram
* Twitter/X
* TikTok
* LinkedIn

### Activity Signals

* Post frequency
* Followers
* Engagement
* Website age
* Traffic estimate
* Google Maps presence

### Commerce Signals

* Existing payment processor
* Average transaction volume
* Refund rate
* Chargeback history

### Reputation Signals

* Complaints online
* Scam reports
* Reviews

---

# Verification Pipeline

This is the important part.

# STEP 1 — Input Validation

Before AI.

Validate:

* fields exist
* formats are correct
* CAC format valid
* email valid
* phone valid

Pure backend logic.

---

# STEP 2 — Document OCR + Extraction

Now AI helps.

Use:

* OCR
* document parsers
* computer vision

Extract:

* CAC number
* names
* dates
* addresses

Then compare extracted values against submitted data.

Example:

```text
Submitted business name:
"PayGidi Ltd"

CAC document says:
"PayGidi Technologies Ltd"

→ mismatch flag
```

This is deterministic verification.

Not vibes.

---

# STEP 3 — Government / Registry Verification

This is the strongest layer.

For Nigeria:

* CAC verification
* NIN/BVN verification partners
* bank account validation

Possible providers:

* Smile Identity
* Dojah
* Mono
* Prembly
* VerifyMe

You check:

* does this entity exist?
* do names match?
* are directors real?

This matters WAY more than AI.

---

# STEP 4 — Selfie + Liveness

Prevent:

* stolen IDs
* fake directors
* impersonation

Use:

* selfie capture
* liveness challenge
* face match against ID

---

# STEP 5 — Risk Engine

THIS is your actual moat.

You compute a trust score.

Example:

| Signal            | Weight |
| ----------------- | ------ |
| CAC verified      | +30    |
| BVN verified      | +25    |
| Address verified  | +10    |
| Website exists    | +5     |
| Social active     | +5     |
| New domain (<30d) | -10    |
| Scam complaints   | -30    |
| ID mismatch       | -50    |

Final score:

```text
82/100 = Trusted
```

This should be code/rules-based first.

Not AI-generated.

---

# STEP 6 — LLM Analysis Layer

Now the LLM becomes useful.

It can:

* summarize risks
* explain anomalies
* detect suspicious patterns
* generate compliance notes
* help manual reviewers

Example:

> “Business address differs across submitted utility bill and CAC filing. Social accounts were created within the last 7 days. Domain age is recent and ownership hidden.”

That’s useful.

But the LLM should NEVER be:

```text
trust_business = GPT says yes
```

---

# STEP 7 — Human Review Queue

For edge cases:

* mismatched names
* suspicious docs
* high-value merchants
* unusual behavior

You need:

```text
AUTO APPROVE
AUTO REJECT
MANUAL REVIEW
```

---

# Recommended Architecture for PayGidi

This is probably your strongest setup:

```text
Frontend
    ↓
Verification API
    ↓
Verification Orchestrator
    ├── CAC verifier
    ├── ID verifier
    ├── OCR service
    ├── Face match service
    ├── Fraud signals engine
    ├── Risk scoring engine
    └── LLM analysis service
```

---

# Tech Stack Suggestions

## Backend

* Go
* PostgreSQL
* Redis

## OCR

* Google Vision
* AWS Textract
* Tesseract (cheap)

## Face Verification

* Smile Identity
* AWS Rekognition

## Rules Engine

* Plain Go logic initially

Do NOT overcomplicate with ML early.

---

# Biggest Mistake To Avoid

Most hackathon teams build:

```text
Upload docs → AI says legit
```

Investors/judges immediately know:

* it’s unreliable
* not auditable
* easy to exploit

The stronger story is:

> “We built a programmable trust infrastructure combining deterministic verification, government checks, fraud scoring, and AI-assisted risk analysis.”

That sounds like real fintech infrastructure.
