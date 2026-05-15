package middlewares

import (
	"net/http"
	"strings"

	payGidiErrors "github.com/PayGidi/AccountService/core/interfaces/errors"
	"github.com/PayGidi/AccountService/models"
	"github.com/PayGidi/AccountService/utils"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// Authenticate is a middleware that checks if the user is authenticated
func Authenticate() gin.HandlerFunc {
	return func(c *gin.Context) {
		db := c.MustGet("db").(*gorm.DB)
		if db == nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
				"error": "Database not initialized",
			})
			c.Abort()
			return
		}

		// Extract the token from the Authorization header or Cookie
		var tokenString string
		authHeader := c.GetHeader("Authorization")

		if authHeader != "" {
			tokenString = strings.TrimPrefix(authHeader, "Bearer ")
			if tokenString == authHeader {
				c.JSON(http.StatusUnauthorized, gin.H{
					"code":  payGidiErrors.UNAUTHORIZED,
					"error": "Bearer token is missing",
				})
				c.Abort()
				return
			}
		} else {
			// Try to get token from cookie
			cookie, err := c.Cookie("auth_token")
			if err != nil {
				c.JSON(http.StatusUnauthorized, gin.H{
					"code":  payGidiErrors.UNAUTHORIZED,
					"error": "Authentication required. Please provide a token via Authorization header or Cookie.",
				})
				c.Abort()
				return
			}
			tokenString = cookie
		}

		// Validate the token (implementation depends on your auth logic)
		userID, err := utils.VerifyJWT(tokenString)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{
				"code":  payGidiErrors.UNAUTHORIZED,
				"error": "Invalid or expired token",
			})
			c.Abort()
			return
		}

		// Get the user info from db
		var user models.User

		if err := db.Where("id = ?", userID).First(&user).Error; err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{
				"code":  payGidiErrors.UNAUTHORIZED,
				"error": "User not found",
			})
			c.Abort()
			return
		}

		// Set user info in context
		c.Set("user", user)
		c.Set("userID", userID)

		// Call the next handler in the chain
		c.Next()
	}
}
