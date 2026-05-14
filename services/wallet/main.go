package main

import (
	"log"
	"net"

	"github.com/PayGidi/WalletService/config"
	grpcserver "github.com/PayGidi/WalletService/connection/grpc"
	"github.com/PayGidi/WalletService/core/constants"
	"github.com/PayGidi/WalletService/proto/connection/pb"
	"github.com/PayGidi/WalletService/router"
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
		log.Println("Wallet service running in development mode")
	} else {
		log.Println("Wallet service running in production mode")
	}

	lis, err := net.Listen("tcp", ":"+constants.GRPC_PORT)
	if err != nil {
		log.Fatalf("failed to open gRPC listener: %v", err)
	}

	grpcSrv := grpc.NewServer()
	pb.RegisterWalletServiceServer(grpcSrv, grpcserver.NewWalletServer(db))

	// Start Gin HTTP server
	r := gin.Default()
	router.SetupRoutes(r, db)
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
