package config

import (
	"errors"
	"strings"

	"github.com/PayGidi/WalletService/models"
	"github.com/jackc/pgx/v5/pgconn"
	"gorm.io/gorm"
)

func RunAutoMigrations(db *gorm.DB) error {
	// delete all existing tables
	// if err := db.Migrator().DropTable(
	// 	&models.User{},
	// 	&models.Person{},
	// 	&models.Activity{},
	// 	&models.Session{},
	// 	&models.AuthInfo{},
	// 	&models.Preference{},
	// 	&models.Role{},
	// 	&models.Permission{},
	// &models.Account{},
	// 	&models.ContactInfo{},
	// 	&models.KYC{},
	// 	&models.OTP{},
	// ); err != nil {
	// return err
	// }

	// Run auto migrations for all models
	if err := db.AutoMigrate(
		&models.Account{},
	); err != nil {
		var pgErr *pgconn.PgError
		if (errors.As(err, &pgErr) && pgErr.Code == "42P07") || strings.Contains(err.Error(), "SQLSTATE 42P07") {
			return nil
		}
		return err
	}
	return nil
}
