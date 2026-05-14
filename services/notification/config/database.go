package config

import (
	"fmt"

	"github.com/PayGidi/NotificationService/core/constants"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func GetDBConnection() (*gorm.DB, error) {
	dsn := fmt.Sprintf(
		"host=%s port=%s user=%s dbname=%s password=%s sslmode=%s TimeZone=UTC",
		constants.DB_HOST,
		constants.DB_PORT,
		constants.DB_USER,
		constants.DB_NAME,
		constants.DB_PASSWORD,
		constants.DB_SSL_MODE,
	)

	return gorm.Open(postgres.Open(dsn), &gorm.Config{})
}
