package config

import (
	"github.com/PayGidi/AccountService/models"
	"gorm.io/gorm"
)

func RunAutoMigrations(db *gorm.DB) error {
	// Drop all old un-prefixed tables to clean up the database
	oldTables := []string{
		"users",
		"auth_info",
		"activities",
		"businesses",
		"contact_info",
		"kyc",
		"otps",
		"persons",
		"preferences",
		"roles",
		"sessions",
		"permissions",
		"accounts", // from wallet service originally
		"payments", // from wallet service originally
	}
	
	for _, table := range oldTables {
		if db.Migrator().HasTable(table) {
			if err := db.Migrator().DropTable(table); err != nil {
				// Log the error but continue trying to drop others
				continue
			}
		}
	}

	// Run auto migrations for all models
	if err := db.AutoMigrate(
		&models.User{},
		&models.Person{},
		&models.Session{},
		&models.AuthInfo{},
		&models.Activity{},
		&models.Business{},
		&models.Preference{},
		&models.Role{},
		&models.Permission{},
		&models.ContactInfo{},
		&models.KYC{},
		&models.OTP{},
	); err != nil {
		return err
	}
	return nil
}
