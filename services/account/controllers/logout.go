package controllers

import (
	"net/http"
	"os"
	"strings"

	"github.com/PayGidi/AccountService/utils"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// Logout godoc
// @Summary User logout
// @Description Logs out the current user by clearing the auth cookie and removing the current session.
// @Tags Auth
// @Produce json
// @Security ApiKeyAuth
// @Success 200 {object} map[string]string "Logged out successfully"
// @Failure 401 {object} map[string]string "Unauthorized"
// @Router /auth/logout [post]
func Logout(c *gin.Context) {
	db, exists := c.Get("db")
	if !exists {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database not found"})
		return
	}

	// Extract the token from the Authorization header or Cookie
	var tokenString string
	authHeader := c.GetHeader("Authorization")

	if authHeader != "" {
		tokenString = strings.TrimPrefix(authHeader, "Bearer ")
		if tokenString == authHeader {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Bearer token is missing"})
			return
		}
	} else {
		cookie, err := c.Cookie("auth_token")
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Authentication required"})
			return
		}
		tokenString = cookie
	}

	// Clear the auth_token cookie
	secure := os.Getenv("APP_ENV") == "production"
	c.SetSameSite(http.SameSiteLaxMode)
	c.SetCookie("auth_token", "", -1, "/", "", secure, true)

	// Remove the current session only (instead of all user sessions)
	if err := utils.DeleteCurrentSession(db.(*gorm.DB), tokenString); err != nil {
		// Log the error but don't fail the logout
		c.JSON(http.StatusOK, gin.H{
			"message": "Logged out successfully",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Logged out successfully",
	})
}
