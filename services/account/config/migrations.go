package config

import (
	"github.com/PayGidi/AccountService/models"
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
	// 	&models.Account{},
	// 	&models.ContactInfo{},
	// 	&models.KYC{},
	// 	&models.OTP{},
	// ); err != nil {
	// 	return err
	// }

	// Run auto migrations for all models
	if err := db.AutoMigrate(
		&models.User{},
		&models.Person{},
		&models.Session{},
		&models.AuthInfo{},
		// &models.Activity{},
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
