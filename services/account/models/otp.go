package models

import (
	"time"
)

// OTP represents a one-time password for user verification.
type OTP struct {
	ID        uint      `json:"id" gorm:"primaryKey;autoIncrement"`
	UserID    uint      `json:"userId" gorm:"not null;index"`
	ForWhat   string    `json:"forWhat"` // e.g., "register", "login", "resetPassword"
	Via       string    `json:"via"`     // sms, email, whatsapp
	Code      string    `json:"code"`
	Verified  bool      `json:"verified" gorm:"default:false"`
	CreatedAt time.Time `json:"createdAt"`
	ExpiresAt time.Time `json:"expiresAt"`
}

func (OTP) TableName() string {
	return "otps"
}
