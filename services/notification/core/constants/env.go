package constants

import (
	"os"

	"github.com/joho/godotenv"
)

var (
	DB_HOST     = "localhost"
	DB_PORT     = "5432"
	DB_USER     = "postgres"
	DB_PASSWORD = "postgres"
	DB_NAME     = "spirit"
	DB_SSL_MODE = "disable"
	APP_ENV     = "development"
	APP_PORT    = "8080"
	GRPC_PORT   = "50052"
	ACCOUNT_SERVICE_ADDR = "localhost:50051"
)

func ConfigDotenv() error {
	// Attempt to load .env.production, then .env
	_ = godotenv.Load(".env.production")
	_ = godotenv.Load()

	// Prioritize environment variables injected by Docker/Compose
	if value := os.Getenv("DB_HOST"); value != "" {
		DB_HOST = value
	}
	if value := os.Getenv("DB_PORT"); value != "" {
		DB_PORT = value
	}
	if value := os.Getenv("DB_USER"); value != "" {
		DB_USER = value
	}
	if value := os.Getenv("DB_PASSWORD"); value != "" {
		DB_PASSWORD = value
	}
	if value := os.Getenv("DB_NAME"); value != "" {
		DB_NAME = value
	}
	if value := os.Getenv("DB_SSL_MODE"); value != "" {
		DB_SSL_MODE = value
	}
	if value := os.Getenv("APP_ENV"); value != "" {
		APP_ENV = value
	}
	if value := os.Getenv("APP_PORT"); value != "" {
		APP_PORT = value
	}
	if value := os.Getenv("GRPC_PORT"); value != "" {
		GRPC_PORT = value
	}
	if value := os.Getenv("ACCOUNT_SERVICE_ADDR"); value != "" {
		ACCOUNT_SERVICE_ADDR = value
	}

	return nil
}

func IsDevMode() bool {
	return APP_ENV == "development"
}
