CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE "users" (
  "id" UUID NOT NULL DEFAULT gen_random_uuid(), "uid" TEXT, "phone" TEXT, "email" TEXT,
  "username" TEXT, "first_name" TEXT, "last_name" TEXT, "middle_name" TEXT, "name" TEXT,
  "password_hash" TEXT, "account_type" TEXT NOT NULL DEFAULT 'individual', "role" TEXT NOT NULL DEFAULT 'buyer',
  "status" TEXT NOT NULL DEFAULT 'pending', "is_first_time" BOOLEAN NOT NULL DEFAULT true,
  "phone_verified" BOOLEAN NOT NULL DEFAULT false, "email_verified" BOOLEAN NOT NULL DEFAULT false,
  "pin_hash" TEXT, "referral_code" TEXT, "blocked" BOOLEAN NOT NULL DEFAULT false, "otp_code" TEXT,
  "otp_purpose" TEXT, "otp_expires_at" TIMESTAMP(3), "otp_requests" INTEGER NOT NULL DEFAULT 0,
  "biometric_id" TEXT, "biometric_enabled" BOOLEAN NOT NULL DEFAULT false, "metadata" JSONB NOT NULL DEFAULT '{}',
  "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, "updated_at" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "users_uid_key" ON "users"("uid"); CREATE UNIQUE INDEX "users_phone_key" ON "users"("phone"); CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

CREATE TABLE "wallets" (
  "id" UUID NOT NULL DEFAULT gen_random_uuid(), "user_id" UUID NOT NULL, "provider" TEXT,
  "provider_account_number" TEXT, "account_number" TEXT, "account_type" TEXT, "currency" TEXT NOT NULL DEFAULT 'NGN',
  "balance" DECIMAL(20,2) NOT NULL DEFAULT 0, "escrow_balance" DECIMAL(20,2) NOT NULL DEFAULT 0,
  "status" TEXT NOT NULL DEFAULT 'active', "customer_identifier" TEXT, "account_reference" TEXT,
  "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, "updated_at" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "wallets_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "wallets_user_id_account_number_key" ON "wallets"("user_id", "account_number");

CREATE TABLE "businesses" ("id" UUID NOT NULL DEFAULT gen_random_uuid(), "user_id" UUID, "name" TEXT, "business_name" TEXT, "registration_number" TEXT, "cac_number" TEXT, "type" TEXT, "category" TEXT, "industry" TEXT, "website" TEXT, "address" TEXT, "phone" TEXT, "email" TEXT, "verification_status" TEXT NOT NULL DEFAULT 'pending', "trust_score" DECIMAL NOT NULL DEFAULT 0, "trust_tier" INTEGER NOT NULL DEFAULT 0, "risk_analysis" TEXT, "metadata" JSONB, "directors" JSONB, "documents" JSONB, "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, "updated_at" TIMESTAMP(3) NOT NULL, CONSTRAINT "businesses_pkey" PRIMARY KEY ("id"));
CREATE TABLE "payments" ("id" UUID NOT NULL DEFAULT gen_random_uuid(), "user_id" UUID, "amount" DECIMAL(20,2), "account_number" TEXT, "bank" TEXT, "merchant_phone_number" TEXT, "merchant_email" TEXT, "advance_options" TEXT, "status" TEXT NOT NULL DEFAULT 'pending', "summary" TEXT, "trust_score" DECIMAL, "expires_at" TIMESTAMP(3), "transaction_reference" TEXT, "metadata" JSONB, "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, "updated_at" TIMESTAMP(3) NOT NULL, CONSTRAINT "payments_pkey" PRIMARY KEY ("id"));
CREATE UNIQUE INDEX "payments_transaction_reference_key" ON "payments"("transaction_reference");
CREATE TABLE "transactions" ("id" UUID NOT NULL DEFAULT gen_random_uuid(), "user_id" UUID, "buyer_id" UUID, "merchant_id" UUID, "amount" DECIMAL(20,2), "type" TEXT, "status" TEXT NOT NULL DEFAULT 'pending', "reference" TEXT, "metadata" JSONB, "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, "updated_at" TIMESTAMP(3) NOT NULL, CONSTRAINT "transactions_pkey" PRIMARY KEY ("id"));
CREATE UNIQUE INDEX "transactions_reference_key" ON "transactions"("reference");
CREATE TABLE "savings_goals" ("id" UUID NOT NULL DEFAULT gen_random_uuid(), "user_id" UUID NOT NULL, "name" TEXT, "target_amount" DECIMAL(20,2), "current_amount" DECIMAL(20,2) NOT NULL DEFAULT 0, "currency" TEXT NOT NULL DEFAULT 'NGN', "status" TEXT NOT NULL DEFAULT 'active', "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, "updated_at" TIMESTAMP(3) NOT NULL, CONSTRAINT "savings_goals_pkey" PRIMARY KEY ("id"));
CREATE TABLE "thrifts" ("id" UUID NOT NULL DEFAULT gen_random_uuid(), "creator_id" UUID NOT NULL, "name" TEXT, "description" TEXT, "contribution_amount" DECIMAL(20,2), "contribution_frequency" TEXT NOT NULL DEFAULT 'monthly', "max_members" INTEGER, "current_members" INTEGER NOT NULL DEFAULT 1, "is_public" BOOLEAN NOT NULL DEFAULT false, "status" TEXT NOT NULL DEFAULT 'active', "members" JSONB NOT NULL DEFAULT '[]', "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, "updated_at" TIMESTAMP(3) NOT NULL, CONSTRAINT "thrifts_pkey" PRIMARY KEY ("id"));
CREATE TABLE "notifications" ("id" UUID NOT NULL DEFAULT gen_random_uuid(), "user_id" UUID, "title" TEXT, "message" TEXT, "type" TEXT, "channel" TEXT, "status" TEXT, "read" BOOLEAN NOT NULL DEFAULT false, "archived" BOOLEAN NOT NULL DEFAULT false, "recipient" TEXT, "metadata" JSONB, "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, "updated_at" TIMESTAMP(3) NOT NULL, CONSTRAINT "notifications_pkey" PRIMARY KEY ("id"));
CREATE TABLE "activities" ("id" UUID NOT NULL DEFAULT gen_random_uuid(), "user_id" UUID, "action" TEXT, "entity_type" TEXT, "entity_id" TEXT, "details" TEXT, "ip_address" TEXT, "user_agent" TEXT, "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, "updated_at" TIMESTAMP(3) NOT NULL, CONSTRAINT "activities_pkey" PRIMARY KEY ("id"));
CREATE TABLE "issues" ("id" UUID NOT NULL DEFAULT gen_random_uuid(), "user_id" UUID NOT NULL, "title" TEXT, "description" TEXT, "status" TEXT NOT NULL DEFAULT 'open', "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, "updated_at" TIMESTAMP(3) NOT NULL, CONSTRAINT "issues_pkey" PRIMARY KEY ("id"));
CREATE TABLE "sessions" ("id" UUID NOT NULL DEFAULT gen_random_uuid(), "user_id" UUID NOT NULL, "token_hash" TEXT, "device_name" TEXT, "device_type" TEXT, "device_os" TEXT, "ip" TEXT, "user_agent" TEXT, "expires_at" TIMESTAMP(3), "is_current" BOOLEAN NOT NULL DEFAULT true, "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, "updated_at" TIMESTAMP(3) NOT NULL, CONSTRAINT "sessions_pkey" PRIMARY KEY ("id"));
CREATE TABLE "webhook_transactions" ("id" UUID NOT NULL DEFAULT gen_random_uuid(), "transaction_reference" TEXT NOT NULL, "virtual_account_number" TEXT, "customer_identifier" TEXT, "principal_amount" DECIMAL(20,2), "settled_amount" DECIMAL(20,2), "fee_charged" DECIMAL(20,2), "currency" TEXT, "sender_name" TEXT, "transaction_date" TEXT, "channel" TEXT, "remarks" TEXT, "transaction_uuid" TEXT, "raw_payload" JSONB, "status" TEXT NOT NULL DEFAULT 'pending', "failure_reason" TEXT, "processed_at" TIMESTAMP(3), "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, "updated_at" TIMESTAMP(3) NOT NULL, CONSTRAINT "webhook_transactions_pkey" PRIMARY KEY ("id"));
CREATE UNIQUE INDEX "webhook_transactions_transaction_reference_key" ON "webhook_transactions"("transaction_reference");

ALTER TABLE "wallets" ADD CONSTRAINT "wallets_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "businesses" ADD CONSTRAINT "businesses_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "savings_goals" ADD CONSTRAINT "savings_goals_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "thrifts" ADD CONSTRAINT "thrifts_creator_id_fkey" FOREIGN KEY ("creator_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "issues" ADD CONSTRAINT "issues_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "sessions" ADD CONSTRAINT "sessions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
