package main

import (
	"log"
	"net"

	"github.com/PayGidi/WalletService/config"
	grpcserver "github.com/PayGidi/WalletService/connection/grpc"
	"github.com/PayGidi/WalletService/core/constants"
	"github.com/PayGidi/WalletService/proto/connection/pb"
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

	log.Printf("Wallet gRPC service listening on :%s", constants.GRPC_PORT)
	if err := grpcSrv.Serve(lis); err != nil {
		log.Fatalf("failed to start gRPC server: %v", err)
	}
}
