package config

import (
	"errors"
	"strings"

	"github.com/PayGidi/AIService/models"
	"github.com/jackc/pgx/v5/pgconn"
	"gorm.io/gorm"
)

func RunAutoMigrations(db *gorm.DB) error {
	// Run auto migrations for all models
	if err := db.AutoMigrate(
		&models.Business{},
		&models.Director{},
		&models.Document{},
		&models.Analysis{},
	); err != nil {
		var pgErr *pgconn.PgError
		if (errors.As(err, &pgErr) && pgErr.Code == "42P07") || strings.Contains(err.Error(), "SQLSTATE 42P07") {
			return nil
		}
		return err
	}
	return nil
}
