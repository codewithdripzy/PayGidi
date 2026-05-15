package main

import (
	"log"
	"net"

	"github.com/PayGidi/AIService/config"
	grpcserver "github.com/PayGidi/AIService/connection/grpc"
	"github.com/PayGidi/AIService/core/constants"
	"github.com/PayGidi/AIService/proto/connection/aipb"
	"github.com/PayGidi/AIService/router"
	_ "github.com/PayGidi/AIService/docs"
	"github.com/PayGidi/AIService/services/kyb"
	"github.com/PayGidi/AIService/services/wallet"
	"github.com/gin-gonic/gin"
	"google.golang.org/grpc"
)

// @title PayGidi AI Service API
// @version 1.0
// @description This is the AI orchestration service for PayGidi KYB.
// @termsOfService http://swagger.io/terms/

// @contact.name API Support
// @contact.url http://www.swagger.io/support
// @contact.email support@swagger.io

// @license.name Apache 2.0
// @license.url http://www.apache.org/licenses/LICENSE-2.0.html

// @host localhost:8083
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
		log.Println("AI service running in development mode")
	} else {
		log.Println("AI service running in production mode")
	}

	// Initialize Wallet gRPC Client
	walletClient, err := wallet.NewWalletClient(constants.WALLET_SERVICE_ADDR)
	if err != nil {
		log.Printf("Warning: Failed to connect to Wallet service: %v", err)
	}

	// Initialize KYB Orchestrator with providers
	orch := kyb.NewOrchestrator(
		db,
		&kyb.MockOCRProvider{},
		&kyb.MockIdentityProvider{},
		&kyb.DefaultRiskEngine{},
		nil, // LLM is optional
		&kyb.MockNINProvider{},
		&kyb.MockSocialMediaProvider{},
		&kyb.MockReputationProvider{},
		walletClient,
	)

	// Start Gin HTTP server
	r := gin.Default()

	// Middleware to inject db into context
	r.Use(func(c *gin.Context) {
		c.Set("db", db)
		c.Next()
	})

	if constants.IsDevMode() {
		gin.SetMode(gin.DebugMode)
	} else {
		gin.SetMode(gin.ReleaseMode)
	}

	router.SetupRoutes(r, db, orch)
	go func() {
		log.Printf("AI HTTP service listening on :%s", constants.HTTP_PORT)
		if err := r.Run(":" + constants.HTTP_PORT); err != nil {
			log.Fatalf("failed to start HTTP server: %v", err)
		}
	}()

	lis, err := net.Listen("tcp", ":"+constants.GRPC_PORT)
	if err != nil {
		log.Fatalf("failed to open gRPC listener: %v", err)
	}

	grpcSrv := grpc.NewServer()
	aipb.RegisterAIServiceServer(grpcSrv, grpcserver.NewAIServer(orch))

	log.Printf("AI gRPC service listening on :%s", constants.GRPC_PORT)
	if err := grpcSrv.Serve(lis); err != nil {
		log.Fatalf("failed to start gRPC server: %v", err)
	}
}
