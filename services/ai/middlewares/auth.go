package middlewares

import (
	"net/http"
	"strings"

	"github.com/PayGidi/AIService/models"
	"github.com/PayGidi/AIService/utils"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// Authenticate is a middleware that checks if the user is authenticated
func Authenticate() gin.HandlerFunc {
	return func(c *gin.Context) {
		db, exists := c.Get("db")
		if !exists {
			c.JSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"message": "Database not initialized",
			})
			c.Abort()
			return
		}
		gormDB := db.(*gorm.DB)

		// Extract the token from the Authorization header
		var tokenString string
		authHeader := c.GetHeader("Authorization")

		if authHeader != "" {
			tokenString = strings.TrimPrefix(authHeader, "Bearer ")
			if tokenString == authHeader {
				c.JSON(http.StatusUnauthorized, gin.H{
					"success": false,
					"message": "Bearer token is missing",
				})
				c.Abort()
				return
			}
		} else {
			// Try to get token from cookie
			cookie, err := c.Cookie("auth_token")
			if err != nil {
				c.JSON(http.StatusUnauthorized, gin.H{
					"success": false,
					"message": "Authentication required",
				})
				c.Abort()
				return
			}
			tokenString = cookie
		}

		// Validate the token
		claims, err := utils.VerifyJWT(tokenString)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{
				"success": false,
				"message": "Invalid or expired token",
			})
			c.Abort()
			return
		}

		// Get user ID from claims
		userID, ok := claims["user_id"].(float64)
		if !ok {
			c.JSON(http.StatusUnauthorized, gin.H{
				"success": false,
				"message": "Invalid token claims",
			})
			c.Abort()
			return
		}

		// Get the user info from db
		var user models.User
		if err := gormDB.Where("id = ?", uint(userID)).First(&user).Error; err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{
				"success": false,
				"message": "User not found",
			})
			c.Abort()
			return
		}

		// Set user info in context
		c.Set("user", user)
		c.Set("userID", uint(userID))

		c.Next()
	}
}
