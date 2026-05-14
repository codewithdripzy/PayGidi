package main

import (
	"log"
	"net"

	"github.com/PayGidi/NotificationService/config"
	grpcserver "github.com/PayGidi/NotificationService/connection/grpc"
	"github.com/PayGidi/NotificationService/controllers"
	"github.com/PayGidi/NotificationService/core/constants"
	notificationpb "github.com/PayGidi/NotificationService/proto/notificationpb"
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

	log.Printf("Notification gRPC service listening on :%s", constants.GRPC_PORT)
	if err := grpcServer.Serve(listener); err != nil {
		log.Fatalf("failed to start gRPC server: %v", err)
	}
}
