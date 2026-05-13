export enum UserStatus {
    ACTIVE = "active",
    INACTIVE = "inactive",
    SUSPENDED = "suspended",
    TEMPORARILY_BANNED = "temporarily-banned",
    PERMERNENTLY_BANNED = "permanently-banned"
}

export enum OrganizationStatus {
    ACTIVE = "active",
    INACTIVE = "inactive",
    SUSPENDED = "suspended",
    TEMPORARILY_BANNED = "temporarily-banned",
    PERMERNENTLY_BANNED = "permanently-banned"
}

export enum AssistantStatus {
    DRAFT = "draft",
    ACTIVE = "live",
    INACTIVE = "inactive",
    ARCHIVED = "archived",
    SUSPENDED = "suspended",
}

export enum AppType {
    FIRST_PARTY = "first_party",
    THIRD_PARTY = "third_party",
    SERVICE = "service",
    CLOUD_AGENT = "cloud_agent",
}

export enum AppStatus {
    PENDING_VERIFICATION = "pending-verification",
    ACTIVE = "active",
    INACTIVE = "inactive",
    SUSPENDED = "suspended",
    ACTION_REQUIRED = "action-required",
    TEMP_BANNED = "temporarily-banned",
    PERM_BANNED = "permanently-banned",
}

export enum InviteStatus {
    PENDING = "pending",
    ACCEPTED = "accepted",
    REJECTED = "rejected",
}

export enum MessageSender {
    USER = "user",
    AGENT = "agent",
}

export enum MediaType {
    IMAGE = "image",
    VIDEO = "video",
    AUDIO = "audio",
    FILE = "file",
}

export enum PlanType {
    FREE = "free",
    PRO = "pro",
    PREMIUM = "premium",
}

export enum SubscriptionStatus {
    ACTIVE = "active",
    INACTIVE = "inactive",
    SUSPENDED = "suspended",
}

export enum BillingStatus {
    PAID = "paid",
    UNPAID = "unpaid",
}