package models

import (
	"time"
)

// User represents a user in the system.
type User struct {
	ID               uint          `json:"id" gorm:"primaryKey;autoIncrement"`
	UID              string        `json:"uid"`
	Phone            string        `json:"phone"`
	Email            string        `json:"email" validate:"required,email"`
	Username         string        `json:"username" validate:"required,min=3,max=30" gorm:"uniqueIndex"`
	Password         string        `json:"-" validate:"required,min=8,max=100"`
	Person           Person        `gorm:"foreignKey:UserID"`                    // One-to-one link
	KYCs             []KYC         `json:"kycs" gorm:"foreignKey:UserID"`        // List of KYC documents associated with the user
	Accounts         []Account     `json:"accounts" gorm:"foreignKey:UserID"`    // List of accounts associated with the user
	Contact          []ContactInfo `json:"contact" gorm:"foreignKey:UserID"`     // Contact information for the user
	ProfilePic       string        `json:"profile_pic,omitempty"`                // URL to the user's profile picture
	TwoFactorEnabled bool          `json:"twoFactorEnabled"`                     // Indicates if two-factor authentication is enabled
	IsFirstTime      bool          `json:"isFirstTime"`                          // Indicates if this is the user's first login
	TwoFactorSecret  string        `json:"twoFactorSecret,omitempty"`            // Secret for two-factor authentication
	TwoFactorMethod  string        `json:"twoFactorMethod,omitempty"`            // Method of two-factor authentication (e.g., "sms", "email", "app")
	EmailVerified    bool          `json:"emailVerified"`                        // Indicates if the user's email is verified
	PhoneVerified    bool          `json:"phoneVerified"`                        // Indicates if the user's phone number is verified
	AuthInfo         AuthInfo      `json:"authInfo" gorm:"foreignKey:UserID"`    // Authentication-related information
	Sessions         []Session     `json:"sessions" gorm:"foreignKey:UserID"`    // List of active sessions for the user
	Activities       []Activity    `json:"activities" gorm:"foreignKey:UserID"`  // List of activities performed by the user
	Preferences      Preference    `json:"preferences" gorm:"foreignKey:UserID"` // User preferences
	Roles            []Role        `json:"roles" gorm:"many2many:user_roles;"`
	Status           string        `json:"status"`                        // e.g., "active", "inactive", etc.
	OTPs             []OTP         `json:"otps" gorm:"foreignKey:UserID"` // List of OTPs associated with the user
	CreatedAt        time.Time     `json:"createdAt"`
	UpdatedAt        time.Time     `json:"updatedAt"`
	DeletedAt        *time.Time    `json:"deletedAt,omitempty"`
}

func (User) TableName() string {
	return "users"
}
