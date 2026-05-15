package models

import (
	"time"

	"github.com/lib/pq"
)

type Account struct {
	ID                    uint                   `json:"id" gorm:"primaryKey;autoIncrement"`
	UserID                uint                   `json:"userId"`                                         // Foreign key to the User model
	// User                  map[string]interface{} `gorm:"constraint:OnUpdate:CASCADE,OnDelete:SET NULL;"` // Belongs to User
	Provider              string                 `json:"provider"`
	ProviderAccountNumber string                 `json:"providerAccountNumber"` // Account number with the financial service provider or bank
	AccountNumber         string                 `json:"accountNumber"`
	AccountCategory       string                 `json:"accountCategory"`                    // Category of the account (e.g., "personal", "business")
	AccountFeatures       pq.StringArray         `gorm:"type:text[]" json:"accountFeatures"` // Features or flags (e.g., "credit", "debit", "crypto")
	AccountType           string                 `json:"accountType"`                        // Type of account (e.g., "savings", "checking")
	AccountNickname       string                 `json:"accountNickname"`                    // User-defined nickname for easier identification
	CurrencyCode          string                 `json:"currencyCode"`                       // Currency code in ISO format (e.g., "USD", "EUR")
	AccountReference      string                 `json:"accountReference"`                   // Unique reference code for the account on the provider's system
	AccountPin            string                 `json:"accountPin"`                         // PIN or security code for account access
	Status                string                 `json:"status"`
	Tier                  string                 `json:"tier"`                // Unique identifier for the account on the provider's system
	CreatedAt             time.Time              `json:"createdAt"`           // Timestamp when the account was created
	UpdatedAt             time.Time              `json:"updatedAt"`           // Timestamp for last update to the account
	DeletedAt             *time.Time             `json:"deletedAt,omitempty"` // Timestamp for soft deletion, nil if active
}

func (Account) TableName() string {
	return "wallet_accounts"
}
