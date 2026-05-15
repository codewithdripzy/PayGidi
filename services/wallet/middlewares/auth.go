package middlewares

import (
	"net/http"
	"strings"

	payGidiErrors "github.com/PayGidi/WalletService/core/interfaces/errors"
	"github.com/PayGidi/WalletService/utils"
	"github.com/gin-gonic/gin"
)

// Authenticate is a middleware that checks if the user is authenticated
func Authenticate() gin.HandlerFunc {
	return func(c *gin.Context) {
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

		// Validate the token
		claims, err := utils.VerifyJWT(tokenString)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{
				"code":  payGidiErrors.UNAUTHORIZED,
				"error": "Invalid or expired token",
			})
			c.Abort()
			return
		}

		userIDFloat, ok := claims["user_id"].(float64)
		if !ok {
			c.JSON(http.StatusUnauthorized, gin.H{
				"code":  payGidiErrors.UNAUTHORIZED,
				"error": "Invalid token format",
			})
			c.Abort()
			return
		}
		userID := uint(userIDFloat)

		// Set user ID in context
		c.Set("userID", userID)

		// Call the next handler in the chain
		c.Next()
	}
}
