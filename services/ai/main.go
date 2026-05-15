package main

import (
	"log"
	"net"

	"github.com/PayGidi/AIService/config"
	grpcserver "github.com/PayGidi/AIService/connection/grpc"
	"github.com/PayGidi/AIService/core/constants"
	"github.com/PayGidi/AIService/proto/connection/pb"
	"github.com/PayGidi/AIService/router"
	"github.com/PayGidi/AIService/services/kyb"
	"github.com/PayGidi/AIService/services/wallet"
	"github.com/gin-gonic/gin"
	"google.golang.org/grpc"
)



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
		&kyb.MockSentimentProvider{},
		walletClient,
	)

	// Start Gin HTTP server
	r := gin.Default()
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
	pb.RegisterAIServiceServer(grpcSrv, grpcserver.NewAIServer(orch))

	log.Printf("AI gRPC service listening on :%s", constants.GRPC_PORT)
	if err := grpcSrv.Serve(lis); err != nil {
		log.Fatalf("failed to start gRPC server: %v", err)
	}
}

