package utils

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func CheckDBInitialized(c *gin.Context) (db *gorm.DB, ok bool) {
	dbVal, exists := c.Get("db")
	if !exists {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "database connection not found"})
		return nil, false
	}

	db, ok = dbVal.(*gorm.DB)
	if !ok {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "invalid database connection"})
		return nil, false
	}

	return db, true
}

func GetValidatedBody(c *gin.Context) (interface{}, bool) {
	validatedBody, exists := c.Get("validatedBody")
	if !exists {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid request"})
		return nil, false
	}

	return validatedBody, true
}

func DefaultString(value, fallback string) string {
	if value == "" {
		return fallback
	}

	return value
}
