package controllers

import (
	"net/http"
	"os"

	"github.com/PayGidi/AccountService/models"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func Logout(c *gin.Context) {
	db, exists := c.Get("db")
	if !exists {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database not found"})
		return
	}

	user, exists := c.Get("user")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}
	u := user.(models.User)

	// Clear the auth_token cookie
	secure := os.Getenv("APP_ENV") == "production"
	c.SetSameSite(http.SameSiteLaxMode)
	c.SetCookie("auth_token", "", -1, "/", "", secure, true)

	// Invalidate the session in the database
	// Assuming the token is stored in CurrentSessionID or we just clear all sessions for the user
	// If we want to be specific, we need the token from the request
	if err := db.(*gorm.DB).Where("user_id = ?", u.ID).Delete(&models.Session{}).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to invalidate sessions: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Logged out successfully",
	})
}
