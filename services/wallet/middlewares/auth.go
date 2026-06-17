package middlewares

import (
	"context"
	"log"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/PayGidi/WalletService/core/constants"
	payGidiErrors "github.com/PayGidi/WalletService/core/interfaces/errors"
	pb "github.com/PayGidi/WalletService/proto/connection/pb"
	"github.com/gin-gonic/gin"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

// Authenticate is a middleware that checks if the user is authenticated by calling Account Service via gRPC
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

		// Dial Account Service
		conn, err := grpc.Dial(constants.ACCOUNT_SERVICE_ADDR, grpc.WithTransportCredentials(insecure.NewCredentials()))
		if err != nil {
			log.Printf("Failed to connect to Account Service: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{
				"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
				"error": "Authentication service unavailable",
			})
			c.Abort()
			return
		}
		defer conn.Close()

		client := pb.NewAuthServiceClient(conn)
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()

		resp, err := client.ValidateToken(ctx, &pb.ValidateTokenRequest{
			Token: tokenString,
		})

		if err != nil {
			log.Printf("Error validating token via gRPC: %v", err)
			c.JSON(http.StatusUnauthorized, gin.H{
				"code":  payGidiErrors.UNAUTHORIZED,
				"error": "Invalid or expired token",
			})
			c.Abort()
			return
		}

		if !resp.Valid {
			c.JSON(http.StatusUnauthorized, gin.H{
				"code":  payGidiErrors.UNAUTHORIZED,
				"error": resp.Error,
			})
			c.Abort()
			return
		}

		// Parse userID to uint for Wallet's internal use
		userIDUint64, _ := strconv.ParseUint(resp.UserId, 10, 32)
		userID := uint(userIDUint64)

		// Set info in context
		c.Set("userID", userID)
		c.Set("customerId", resp.UserId)
		c.Set("email", resp.Email)
		c.Set("userData", resp.UserData)

		// Call the next handler in the chain
		c.Next()
	}
}
