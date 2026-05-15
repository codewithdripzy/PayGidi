package config

import (
	"fmt"

	"github.com/PayGidi/TransactionService/core/constants"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func GetDBConnection() (*gorm.DB, error) {
	dsn := fmt.Sprintf("host=%s user=%s dbname=%s password=%s sslmode=disable",
		constants.DB_HOST, constants.DB_USER, constants.DB_NAME, constants.DB_PASSWORD)
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})

	return db, err
}
