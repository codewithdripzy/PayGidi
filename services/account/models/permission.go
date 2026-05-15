package models

import (
	"time"
)


type Permission struct {
	ID        uint      `json:"id" gorm:"primaryKey;autoIncrement"`
	Name      string    `json:"name" gorm:"uniqueIndex;not null"` // e.g., "read_account", "edit_user"
	CreatedAt time.Time `json:"createdAt"`
	UpdatedAt time.Time `json:"updatedAt"`
}

func (Permission) TableName() string {
	return "account_permissions"
}
