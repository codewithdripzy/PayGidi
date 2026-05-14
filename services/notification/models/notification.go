package models

import "time"

type Notification struct {
	ID        uint       `json:"id" gorm:"primaryKey;autoIncrement"`
	UserID    string     `json:"userId" gorm:"index;not null"`
	Title     string     `json:"title" gorm:"not null"`
	Message   string     `json:"message" gorm:"type:text;not null"`
	Type      string     `json:"type" gorm:"index;default:general"`
	Channel   string     `json:"channel" gorm:"index;default:in_app"`
	Status    string     `json:"status" gorm:"index;default:queued"`
	Read      bool       `json:"read" gorm:"default:false"`
	Archived  bool       `json:"archived" gorm:"default:false"`
	Recipient string     `json:"recipient,omitempty"`
	Metadata  string     `json:"metadata,omitempty" gorm:"type:text"`
	CreatedAt time.Time  `json:"createdAt"`
	UpdatedAt time.Time  `json:"updatedAt"`
	DeletedAt *time.Time `json:"deletedAt,omitempty"`
}

func (Notification) TableName() string {
	return "notifications"
}
