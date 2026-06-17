package models

import (
	"time"

	"github.com/lib/pq"
)

type Account struct {
	ID                    uint           `json:"id" gorm:"primaryKey;autoIncrement"`
	UserID                uint           `json:"userId"`                                         // Foreign key to the User model
	User                  User           `gorm:"constraint:OnUpdate:CASCADE,OnDelete:SET NULL;"` // Belongs to User
	Provider              string         `json:"provider"`                                       // Financial service provider or bank name
	ProviderAccountNumber string         `json:"providerAccountNumber"`                         // Account number with the financial service provider or bank
	AccountNumber         string         `json:"accountNumber"`                                  // Official account number assigned by the bank or system
	AccountCategory       string         `json:"accountCategory"`                                // Category of the account (e.g., "personal", "business")
	AccountFeatures       pq.StringArray `gorm:"type:text[]" json:"accountFeatures"`             // Features or flags (e.g., "credit", "debit", "crypto")
	AccountType           string         `json:"accountType"`                                    // Type of account (e.g., "savings", "checking")
	AccountNickname       string         `json:"accountNickname"`                                // User-defined nickname for easier identification
	CurrencyCode          string         `json:"currencyCode"`                                   // Currency code in ISO format (e.g., "USD", "EUR")
	AccountReference      string         `json:"accountReference"`                               // Unique reference code for the account on the provider's system
	CustomerIdentifier    string         `json:"customerIdentifier"`                             // Explicit identifier from Squad (used for transaction history)
	AccountPin            string         `json:"accountPin"`                                     // PIN or security code for account access
	Status                string         `json:"status"`                                         // Status of the account (e.g., "active", "inactive", "suspended")
	CreatedAt             time.Time      `json:"createdAt"`                                      // Timestamp when the account was created
	UpdatedAt             time.Time      `json:"updatedAt"`                                      // Timestamp for last update to the account
	DeletedAt             *time.Time     `json:"deletedAt,omitempty"`                            // Timestamp for soft deletion, nil if active
}

func (Account) TableName() string {
	return "wallet_accounts"
}
