package models

import (
	"time"
)

type Role struct {
	ID          uint         `json:"id" gorm:"primaryKey;autoIncrement"`
	Name        string       `json:"name" gorm:"uniqueIndex;not null"` // e.g., "admin", "user"
	Description string       `json:"description" gorm:"not null"`      // Description of the role
	Permissions []Permission `json:"permissions" gorm:"many2many:role_permissions;"`
	CreatedAt   time.Time    `json:"createdAt"`
	UpdatedAt   time.Time    `json:"updatedAt"`
}

func (Role) TableName() string {
	return "roles"
}
