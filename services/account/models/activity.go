package models

import (
	"time"
)

type Activity struct {
	ID        uint       `json:"id" gorm:"primaryKey;autoIncrement"`             // Unique identifier for the activity
	UserID    uint       `json:"userId"`                                         // Reference to the user associated with the activity
	User      User       `gorm:"constraint:OnUpdate:CASCADE,OnDelete:SET NULL;"` // Belongs to User
	Type      string     `json:"type"`                                           // Type of activity (e.g., "login", "logout", "update_profile")
	Details   string     `json:"details"`                                        // Additional details about the activity
	IPAddress string     `json:"ipAddress"`                                      // IP address from which the activity was performed
	UserAgent string     `json:"userAgent"`                                      // User agent string for the activity
	CreatedAt time.Time  `json:"createdAt"`
	UpdatedAt time.Time  `json:"updatedAt"`
	DeletedAt *time.Time `json:"deletedAt,omitempty"` // Nullable for soft deletes
}

func (Activity) TableName() string {
	return "activities"
}
