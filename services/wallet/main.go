package main

import (
	"log"
	"net"

	"github.com/PayGidi/WalletService/config"
	grpcserver "github.com/PayGidi/WalletService/connection/grpc"
	"github.com/PayGidi/WalletService/core/constants"
	_ "github.com/PayGidi/WalletService/docs"
	"github.com/PayGidi/WalletService/proto/connection/pb"
	"github.com/PayGidi/WalletService/router"
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
	log.Println("[WalletService] Starting main...")
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

	// Initialize Account Client
	accClient, err := account.NewAccountClient(constants.ACCOUNT_SERVICE_ADDR)
	if err != nil {
		log.Fatalf("failed to initialize account client: %v", err)
	}

	if constants.IsDevMode() {
		log.Println("Wallet service running in development mode")
	} else {
		log.Println("Wallet service running in production mode")
	}

	lis, err := net.Listen("tcp", ":"+constants.GRPC_PORT)
	if err != nil {
		log.Fatalf("failed to open gRPC listener: %v", err)
	}

	grpcSrv := grpc.NewServer()
	pb.RegisterWalletServiceServer(grpcSrv, grpcserver.NewWalletServer(db, accClient))

	// Start Gin HTTP server
	r := gin.Default()
	router.SetupRoutes(r, db, accClient)
	go func() {
		log.Printf("Wallet HTTP service listening on :%s", constants.HTTP_PORT)
		if err := r.Run(":" + constants.HTTP_PORT); err != nil {
			log.Fatalf("failed to start HTTP server: %v", err)
		}
	}()

	log.Printf("Wallet gRPC service listening on :%s", constants.GRPC_PORT)
	if err := grpcSrv.Serve(lis); err != nil {
		log.Fatalf("failed to start gRPC server: %v", err)
	}
}
