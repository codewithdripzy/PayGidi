package main

import (
	"log"
	"net"
	"net/http"

	"github.com/PayGidi/NotificationService/config"
	grpcserver "github.com/PayGidi/NotificationService/connection/grpc"
	"github.com/PayGidi/NotificationService/controllers"
	"github.com/PayGidi/NotificationService/core/constants"
	_ "github.com/PayGidi/NotificationService/docs"
	"github.com/PayGidi/NotificationService/dto"
	notificationpb "github.com/PayGidi/NotificationService/proto/notificationpb"
	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
	"google.golang.org/grpc"
)

// @title PayGidi Notification Service API
// @version 1.0
// @description This is the notification service for PayGidi, handling emails, SMS, and activity logs.
// @host api.paygidi.site
// @BasePath /api/v1
func main() {
	if err := constants.ConfigDotenv(); err != nil {
		log.Fatalf("failed to load configuration: %v", err)
	}

	db, err := config.GetDBConnection()
	if err != nil {
		log.Fatalf("failed to connect to database: %v", err)
	}

	if err := config.RunAutoMigrations(db); err != nil {
		log.Fatalf("failed to run migrations: %v", err)
	}

	if constants.IsDevMode() {
		log.Println("Notification service running in development mode")
	} else {
		log.Println("Notification service running in production mode")
	}

	listener, err := net.Listen("tcp", ":"+constants.GRPC_PORT)
	if err != nil {
		log.Fatalf("failed to open gRPC listener: %v", err)
	}

	grpcServer := grpc.NewServer()

	notificationController := controllers.NewNotificationController(db)
	notificationpb.RegisterNotificationServiceServer(grpcServer, grpcserver.NewNotificationGRPCServer(notificationController))

	// Start HTTP server for health check and swagger in a goroutine
	go func() {
		r := gin.Default()

		// Swagger documentation
		r.GET("/docs/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

		// Health check
		r.GET("/health", controllers.HealthCheck)

		// Notification routes
		notification := r.Group("/notification")
		{
			notification.POST("/email", func(c *gin.Context) {
				var req dto.SendEmailDTO
				if err := c.ShouldBindJSON(&req); err != nil {
					c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
					return
				}
				resp, err := notificationController.SendEmailNotification(&req)
				if err != nil {
					c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
					return
				}
				c.JSON(http.StatusOK, resp)
			})
			notification.POST("/sms", func(c *gin.Context) {
				var req dto.SendSMSDTO
				if err := c.ShouldBindJSON(&req); err != nil {
					c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
					return
				}
				resp, err := notificationController.SendSMSNotification(&req)
				if err != nil {
					c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
					return
				}
				c.JSON(http.StatusOK, resp)
			})
			notification.POST("/activity", func(c *gin.Context) {
				var req dto.CreateActivityDTO
				if err := c.ShouldBindJSON(&req); err != nil {
					c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
					return
				}
				resp, err := notificationController.RecordActivity(&req, c.ClientIP(), c.Request.UserAgent())
				if err != nil {
					c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
					return
				}
				c.JSON(http.StatusOK, resp)
			})
		}

		log.Printf("Notification HTTP service listening on :%s", constants.APP_PORT)
		if err := r.Run(":" + constants.APP_PORT); err != nil {
			log.Printf("failed to start HTTP server: %v", err)
		}
	}()

	log.Printf("Notification gRPC service listening on :%s", constants.GRPC_PORT)
	if err := grpcServer.Serve(listener); err != nil {
		log.Fatalf("failed to start gRPC server: %v", err)
	}
}
