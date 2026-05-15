package models

import (
	"time"
)

type Session struct {
	ID               uint    `json:"id" gorm:"primaryKey;autoIncrement"`
	UserID           uint    `json:"userId"`                                         // Reference to the user associated with the session
	User             User      `gorm:"constraint:OnUpdate:CASCADE,OnDelete:SET NULL;"` // Belongs to User
	LastKnownIP      string    `json:"lastKnownIp"`                                    // Last known IP address of the user
	LastUserAgent    string    `json:"lastUserAgent"`                                  // User agent string for the session
	CurrentSessionID string    `json:"currentSessionID"`                               // Token for the current session
	CreatedAt        time.Time `json:"createdAt"`
	UpdatedAt        time.Time `json:"updatedAt"`
	ExpiresAt        time.Time `json:"expiresAt"` // Expiration time for the session
}

func (Session) TableName() string {
	return "account_sessions"
}
