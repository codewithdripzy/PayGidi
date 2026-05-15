package models

import (
	"time"
)

// KYC represents the Know Your Customer (KYC) information for a user.
type KYC struct {
	ID        uint    `json:"id" gorm:"primaryKey;autoIncrement"`
	UserID    uint    `json:"userId" gorm:"not null;index"` // remove uniqueIndex, keep index for performance
	KycType   string    `json:"kycType" gorm:"not null"`      // e.g., "passport", "nationalID"
	Document  string    `json:"document" gorm:"not null"`     // base64 or URL to document
	Status    string    `json:"status" gorm:"not null"`       // "pending", "approved", "rejected"
	CreatedAt time.Time `json:"createdAt" gorm:"autoCreateTime"`
	UpdatedAt time.Time `json:"updatedAt" gorm:"autoUpdateTime"`
}

func (KYC) TableName() string {
	return "account_kycs"
}
