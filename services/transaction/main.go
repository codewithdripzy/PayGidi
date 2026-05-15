package main

import (
	"log"
	"net"

	"github.com/PayGidi/TransactionService/config"
	"github.com/PayGidi/TransactionService/core/constants"
	"github.com/PayGidi/TransactionService/router"
	_ "github.com/PayGidi/TransactionService/docs"
	"github.com/gin-gonic/gin"
	"google.golang.org/grpc"
)

// @title PayGidi Transaction Service API
// @version 1.0
// @description This is the transaction service for PayGidi.
// @termsOfService http://swagger.io/terms/

// @contact.name API Support
// @contact.url http://www.swagger.io/support
// @contact.email support@swagger.io

// @license.name Apache 2.0
// @license.url http://www.apache.org/licenses/LICENSE-2.0.html

// @host localhost:8080
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

	// Run automigrations if in development mode
	if constants.IsDevMode() {
		if err := config.RunAutoMigrations(db); err != nil {
			panic("Error running auto migrations: " + err.Error())
		}
		log.Println("Running TransactionService in development mode")
		gin.SetMode(gin.DebugMode)
	} else {
		log.Println("Running TransactionService in production mode")
		gin.SetMode(gin.ReleaseMode)
	}

	// Setup routes
	router.SetupRoutes(app)

	// Start gRPC server in a separate goroutine
	go func() {
		lis, err := net.Listen("tcp", ":50053")
		if err != nil {
			log.Fatalf("failed to listen: %v", err)
		}

		grpcServer := grpc.NewServer()

		log.Println("gRPC server listening on :50053")
		if err := grpcServer.Serve(lis); err != nil {
			log.Fatalf("failed to serve: %v", err)
		}
	}()

	// Start HTTP server
	log.Println("HTTP server listening on :8080")
	if err := app.Run(":8080"); err != nil {
		log.Fatalf("failed to run HTTP server: %v", err)
	}
}
