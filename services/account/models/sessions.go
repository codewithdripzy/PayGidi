package models

import (
	"time"
)

// DeviceInfo contains information about a device used to access the account.
type DeviceInfo struct {
	DeviceName string `json:"deviceName"`
	DeviceType string `json:"deviceType"` // mobile, desktop, tablet
	DeviceOS   string `json:"deviceOs"`
}

type Session struct {
	ID               uint      `json:"id" gorm:"primaryKey;autoIncrement"`
	UserID           uint      `json:"userId"`                                         // Reference to the user associated with the session
	User             User      `gorm:"constraint:OnUpdate:CASCADE,OnDelete:SET NULL;"` // Belongs to User
	LastKnownIP      string    `json:"lastKnownIp"`                                    // Last known IP address of the user
	LastUserAgent    string    `json:"lastUserAgent"`                                  // User agent string for the session
	DeviceName       string    `json:"deviceName"`                                     // e.g. "iPhone 15 Pro"
	DeviceType       string    `json:"deviceType"`                                     // e.g. "mobile", "desktop", "tablet"
	DeviceOS         string    `json:"deviceOs"`                                       // e.g. "iOS 18.0", "Android 14"
	CurrentSessionID string    `json:"currentSessionID"`                               // Hashed JWT token for the session
	IsCurrent        bool      `json:"isCurrent" gorm:"default:false"`                 // Marks the current active session
	CreatedAt        time.Time `json:"createdAt"`
	UpdatedAt        time.Time `json:"updatedAt"`
	ExpiresAt        time.Time `json:"expiresAt"` // Expiration time for the session
}

func (Session) TableName() string {
	return "account_sessions"
}
