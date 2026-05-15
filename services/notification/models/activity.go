package models

import "time"

type Activity struct {
	ID         uint       `json:"id" gorm:"primaryKey;autoIncrement"`
	UserID     string     `json:"userId" gorm:"index;not null"`
	Action     string     `json:"action" gorm:"index;not null"`
	EntityType string     `json:"entityType" gorm:"index;default:notification"`
	EntityID   string     `json:"entityId,omitempty" gorm:"index"`
	Details    string     `json:"details" gorm:"type:text"`
	IPAddress  string     `json:"ipAddress,omitempty"`
	UserAgent  string     `json:"userAgent,omitempty"`
	CreatedAt  time.Time  `json:"createdAt"`
	UpdatedAt  time.Time  `json:"updatedAt"`
	DeletedAt  *time.Time `json:"deletedAt,omitempty"`
}

func (Activity) TableName() string {
	return "notification_activities"
}
