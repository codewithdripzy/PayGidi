package main

import (
	"log"
	"net"

	"github.com/PayGidi/WalletService/config"
	grpcserver "github.com/PayGidi/WalletService/connection/grpc"
	"github.com/PayGidi/WalletService/core/constants"
	_ "github.com/PayGidi/WalletService/docs"
	"github.com/PayGidi/WalletService/proto/connection/pb"
	"github.com/PayGidi/WalletService/services/account"
	"github.com/gin-gonic/gin"
	"google.golang.org/grpc"
)

// @title PayGidi Wallet Service API
// @version 1.0
// @description This is the wallet service for PayGidi.
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
		log.Fatalf("Error loading .env file: %v", err)
	}

	// Initialize database connection
	db, err := config.GetDBConnection()
	if err != nil {
		log.Fatalf("Error connecting to database: %v", err)
	}

	// Run automigrations
	if err := config.RunAutoMigrations(db); err != nil {
		log.Fatalf("Error running auto migrations: %v", err)
	}

	// Initialize Account Client
	accClient, err := account.NewAccountClient(constants.ACCOUNT_SERVICE_ADDR)
	if err != nil {
		log.Fatalf("failed to initialize account client: %v", err)
	}

	// Middleware to inject db into context
	app.Use(func(c *gin.Context) {
		log.Printf("Incoming request: %s %s", c.Request.Method, c.Request.URL.Path)
		c.Set("db", db)
		c.Next()
	})

	if constants.IsDevMode() {
		log.Println("Wallet service running in development mode")
		gin.SetMode(gin.DebugMode)
	} else {
		log.Println("Wallet service running in production mode")
		gin.SetMode(gin.ReleaseMode)
	}

	// Setup routes
	// router.SetupRoutes(app, db, accClient)

	// Start gRPC server in a separate goroutine
	go func() {
		lis, err := net.Listen("tcp", ":"+constants.GRPC_PORT)
		if err != nil {
			log.Fatalf("failed to listen: %v", err)
		}

		grpcServer := grpc.NewServer()
		walletServer := grpcserver.NewWalletServer(db, accClient)
		pb.RegisterWalletServiceServer(grpcServer, walletServer)

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
