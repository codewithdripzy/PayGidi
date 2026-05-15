package models

import (
	"time"
)

// User represents a user in the system.
type Preference struct {
	ID                   uint       `json:"id" gorm:"primaryKey;autoIncrement"` // Unique identifier for the preference
	UserID               uint       `json:"userId"`
	Theme                string     `json:"theme"`                // e.g., "light", "dark"
	Language             string     `json:"language"`             // e.g., "en", "fr", etc.
	Timezone             string     `json:"timezone"`             // e.g., "UTC", "America/New_York"
	NotificationsEnabled bool       `json:"notificationsEnabled"` // Indicates if notifications are enabled
	CreatedAt            time.Time  `json:"createdAt"`
	UpdatedAt            time.Time  `json:"updatedAt"`
	DeletedAt            *time.Time `json:"deletedAt,omitempty"` // Nullable for soft deletes
}

func (Preference) TableName() string {
	return "account_preferences"
}
