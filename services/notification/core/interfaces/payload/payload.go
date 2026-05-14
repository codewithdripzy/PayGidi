package payload

import "gorm.io/gorm"

type NotificationService struct {
	DB *gorm.DB
}

type NotificationFilter struct {
	UserID   string
	Channel  string
	Type     string
	Status   string
	Read     *bool
	Archived *bool
}

type ActivityFilter struct {
	UserID     string
	Action     string
	EntityType string
}
