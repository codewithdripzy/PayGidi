package utils

import (
	"errors"
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func CheckDBInitialized(c *gin.Context) (db *gorm.DB, ok bool) {
	dbVal, exists := c.Get("db")
	if !exists {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database connection not found"})
		return nil, false
	}

	// Check if the database connection is valid
	db, ok = dbVal.(*gorm.DB)
	if !ok {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Invalid database connection"})
		return nil, false
	}

	return db, true
}

func GetValidatedBody(c *gin.Context) (interface{}, bool) {
	validatedBody, exists := c.Get("validatedBody")
	if !exists {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
		return nil, false
	}

	return validatedBody, true
}

func StoreDBInContext(app *gin.Engine, db *gorm.DB) error {
	if db == nil {
		return nil
	}

	app.Use(func(c *gin.Context) {
		c.Set("db", db)
	})

	return nil
}

func CreateAccountNumberFromPhone(phone string) (string, error) {
	// Remove any non-digit characters (optional, depends on your input)
	cleaned := ""
	
	for _, r := range phone {
		if r >= '0' && r <= '9' {
			cleaned += string(r)
		}
	}

	if len(cleaned) == 0 {
		return "", errors.New("invalid phone number")
	}

	// If phone number is shorter than 10 digits, pad with leading zeros
	if len(cleaned) < 10 {
		padding := 10 - len(cleaned)
		for i := 0; i < padding; i++ {
			cleaned = "0" + cleaned
		}
	} else if len(cleaned) > 10 {
		// If longer than 10 digits, use the last 10 digits
		cleaned = cleaned[len(cleaned)-10:]
	}

	return cleaned, nil
}
