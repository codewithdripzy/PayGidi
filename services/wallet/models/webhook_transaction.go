package models

import (
	"time"
)

type WebhookTransactionStatus string

const (
	WebhookStatusPending    WebhookTransactionStatus = "pending"
	WebhookStatusProcessing WebhookTransactionStatus = "processing"
	WebhookStatusCompleted  WebhookTransactionStatus = "completed"
	WebhookStatusFailed     WebhookTransactionStatus = "failed"
)

// WebhookTransaction records an incoming Squad payment webhook for reliable processing.
// The status field acts as a durable queue — a background worker picks up "pending" records.
type WebhookTransaction struct {
	ID                   uint                      `json:"id" gorm:"primaryKey;autoIncrement"`
	TransactionReference string                    `json:"transactionReference" gorm:"uniqueIndex;size:100"`
	VirtualAccountNumber string                    `json:"virtualAccountNumber"`
	PrincipalAmount      float64                   `json:"principalAmount"`
	SettledAmount        float64                   `json:"settledAmount"`
	FeeCharged           float64                   `json:"feeCharged"`
	Currency             string                    `json:"currency"`
	CustomerIdentifier   string                    `json:"customerIdentifier"`
	SenderName           string                    `json:"senderName"`
	TransactionDate      string                    `json:"transactionDate"`
	Channel              string                    `json:"channel"`
	Remarks              string                    `json:"remarks"`
	TransactionUUID      string                    `json:"transactionUuid"`
	RawPayload           string                    `json:"rawPayload" gorm:"type:text"`
	Status               WebhookTransactionStatus  `json:"status" gorm:"default:pending;index"`
	AccountID            *uint                     `json:"accountId" gorm:"index"` // The wallet account that was credited
	FailureReason        string                    `json:"failureReason" gorm:"type:text"`
	ProcessedAt          *time.Time                `json:"processedAt"`
	CreatedAt            time.Time                 `json:"createdAt"`
	UpdatedAt            time.Time                 `json:"updatedAt"`
}

func (WebhookTransaction) TableName() string {
	return "webhook_transactions"
}
