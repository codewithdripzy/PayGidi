package models

import (
	"time"
)

// User represents a user in the system.
type AuthInfo struct {
	ID     uint   `json:"id" gorm:"primaryKey;autoIncrement"`
	UserID string `json:"userID"` // Unique identifier for the user
	// User            User       `gorm:"constraint:OnUpdate:CASCADE,OnDelete:SET NULL;"` // Belongs to User
	LastLoginAt     time.Time  `json:"lastLoginAt"`   // Timestamp of the last login
	LoginAttempts   int        `json:"loginAttempts"` // Number of login attempts
	LockedReason    string     `json:"lockedReason,omitempty"`
	LockedUntil     *time.Time `json:"lockedUntil,omitempty"`     // Timestamp until which the user is locked out
	PasswordResetAt *time.Time `json:"passwordResetAt,omitempty"` // Timestamp of the last password reset
	CreatedAt       time.Time  `json:"createdAt"`
	UpdatedAt       time.Time  `json:"updatedAt"`
	DeletedAt       *time.Time `json:"deletedAt,omitempty"`
}

func (AuthInfo) TableName() string {
	return "auth_info"
}
