package config

import (
	"github.com/PayGidi/NotificationService/models"
	"gorm.io/gorm"
)

func RunAutoMigrations(db *gorm.DB) error {
	return db.AutoMigrate(
		&models.Notification{},
		&models.Activity{},
	)
}
