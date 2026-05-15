package main

import (
	// "os"

	"log"
	"net"

	"github.com/PayGidi/AccountService/config"
	"github.com/PayGidi/AccountService/core/constants"
	"github.com/PayGidi/AccountService/proto/connection/pb"
	"github.com/PayGidi/AccountService/router"
	"github.com/PayGidi/AccountService/services/auth"
	"github.com/gin-gonic/gin"
	"google.golang.org/grpc"
	// "google.golang.org/grpc/grpclog"
)

// @title PayGidi Account Service API
// @version 1.0
// @description This is the account service for PayGidi.
// @termsOfService http://swagger.io/terms/

// @contact.name API Support
// @contact.url http://www.swagger.io/support
// @contact.email support@swagger.io

// @license.name Apache 2.0
// @license.url http://www.apache.org/licenses/LICENSE-2.0.html

// @host api.paygidi.site
// @BasePath /api/v1
func main() {

	app := gin.Default()

	// Load environment variables
	if err := constants.ConfigDotenv(); err != nil {
		panic("Error loading .env file: " + err.Error())
	}

	// Initialize database connection
	db, err := config.GetDBConnection()
	if err != nil {
		panic("Error connecting to database: " + err.Error())
	}

	// Middleware to inject db into context
	app.Use(func(c *gin.Context) {
		c.Set("db", db)
		c.Next()
	})

	// Run automigrations
	if err := config.RunAutoMigrations(db); err != nil {
		panic("Error running auto migrations: " + err.Error())
	}

	// Setup routes
	router.SetupRoutes(app)

	// Start gRPC server in a separate goroutine
	go func() {
		lis, err := net.Listen("tcp", ":"+constants.GRPC_PORT)
		if err != nil {
			log.Fatalf("failed to listen: %v", err)
		}

		grpcServer := grpc.NewServer()
		authServer := &auth.AuthServer{
			App: app,
		}
		pb.RegisterAuthServiceServer(grpcServer, authServer)

		log.Println("gRPC server listening on :" + constants.GRPC_PORT)
		if err := grpcServer.Serve(lis); err != nil {
			log.Fatalf("failed to serve: %v", err)
		}
	}()

	// Start HTTP server
	log.Println("HTTP server listening on :" + constants.HTTP_PORT)
	if err := app.Run(":" + constants.HTTP_PORT); err != nil {
		log.Fatalf("failed to run HTTP server: %v", err)
	}
}
