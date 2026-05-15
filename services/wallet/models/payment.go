package models

import (
	"time"

	"gorm.io/gorm"
)

type PaymentStatus string

const (
	PaymentPending        PaymentStatus = "pending"
	PaymentDisbursed      PaymentStatus = "disbursed"
	PaymentRefunded       PaymentStatus = "refunded"
	PaymentActionRequired PaymentStatus = "action_required"
	PaymentRejected       PaymentStatus = "rejected"
	PaymentInProgress     PaymentStatus = "in_progress"
)

type Payment struct {
	ID                  uint          `gorm:"primaryKey" json:"id"`
	UserID              string        `gorm:"index;not null" json:"userId"` // The buyer who initiated this
	Amount              float64       `gorm:"not null" json:"amount"`
	AccountNumber       string        `gorm:"not null" json:"accountNumber"`
	Bank                string        `gorm:"not null" json:"bank"`
	MerchantPhoneNumber string        `gorm:"not null" json:"merchantPhoneNumber"`
	MerchantEmail       string        `gorm:"not null" json:"merchantEmail"`
	AdvanceOptions      string        `gorm:"type:text" json:"advanceOptions"` // JSON string for options/purchases
	Status              PaymentStatus `gorm:"type:varchar(20);default:'pending'" json:"status"`
	Summary             string        `gorm:"type:text" json:"summary"` // Analysis summary
	TrustScore          *float64      `json:"trustScore"` // Score populated by AI later
	ExpiresAt           *time.Time    `json:"expiresAt"`
	CreatedAt           time.Time     `json:"createdAt"`
	UpdatedAt           time.Time     `json:"updatedAt"`
	DeletedAt           gorm.DeletedAt `gorm:"index" json:"-"`
}

func (Payment) TableName() string {
	return "wallet_payments"
}
