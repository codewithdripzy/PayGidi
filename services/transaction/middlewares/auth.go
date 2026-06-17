package middlewares

import (
	"context"
	"log"
	"net/http"
	"strings"
	"time"

	"github.com/PayGidi/TransactionService/core/constants"
	payGidiErrors "github.com/PayGidi/TransactionService/core/interfaces/errors"
	"github.com/PayGidi/TransactionService/models"
	pb "github.com/PayGidi/TransactionService/proto/connection/pb"
	"github.com/gin-gonic/gin"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

// Authenticate is a middleware that checks if the user is authenticated by calling Account Service via gRPC
func Authenticate() gin.HandlerFunc {
	return func(c *gin.Context) {
		// Extract the token from the Authorization header
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.JSON(http.StatusUnauthorized, gin.H{
				"code":  payGidiErrors.UNAUTHORIZED,
				"error": "Authorization header is missing",
			})
			c.Abort()
			return
		}

		tokenString := strings.TrimPrefix(authHeader, "Bearer ")
		if tokenString == authHeader {
			c.JSON(http.StatusUnauthorized, gin.H{
				"code":  payGidiErrors.UNAUTHORIZED,
				"error": "Bearer token is missing",
			})
			c.Abort()
			return
		}

		// Dial Account Service
		conn, err := grpc.NewClient(constants.ACCOUNT_SERVICE_ADDR, grpc.WithTransportCredentials(insecure.NewCredentials()))
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

		// Map pb.UserData to models.User
		user := models.User{
			UID:      resp.UserId,
			Email:    resp.Email,
			Username: resp.UserData.GetUsername(),
			Phone:    resp.UserData.GetPhone(),
			Status:   resp.UserData.GetStatus(),
		}

		// If person data exists, map it
		if resp.UserData.GetPersonData() != nil {
			user.Person = models.Person{
				FirstName: resp.UserData.GetPersonData().GetFirstName(),
				LastName:  resp.UserData.GetPersonData().GetLastName(),
			}
		}

		// Set user info in context
		c.Set("user", user)
		c.Set("userID", resp.UserId)
		c.Set("customerId", resp.UserId)

		// Call the next handler in the chain
		c.Next()
	}
}
