package constants

import (
	"fmt"
	"os"

	"github.com/joho/godotenv"
)

var (
	DB_HOST     string
	DB_PORT     string
	DB_USER     string
	DB_PASSWORD string
	DB_NAME     string

	WALLET_SERVICE_ADDR string = "localhost:50053"

	// JWT constants
	JWT_SECRET             string
	JWT_EXPIRATION         string = "24h" // Default JWT expiration time
	JWT_ISSUER             string = "spiritpay"
	JWT_REFRESH_SECRET     string
	JWT_REFRESH_EXPIRATION string = "7d" // Default JWT refresh token expiration time
	JWT_REFRESH_ISSUER     string = "spiritpay_refresh"

	// Application mode
	APP_ENV   string = "development" // Default to development mode
	GRPC_PORT string = "50051"
	HTTP_PORT string = "8080"
)

func ConfigDotenv() error {
	// Load environment variables from .env file
	if err := godotenv.Load(); err != nil {
		return fmt.Errorf("error loading .env file: %w", err)
	}

	// Override constants with environment variables if they exist
	if host := os.Getenv("DB_HOST"); host != "" {
		DB_HOST = host
	}
	if port := os.Getenv("DB_PORT"); port != "" {
		DB_PORT = port
	}
	if user := os.Getenv("DB_USER"); user != "" {
		DB_USER = user
	}
	if password := os.Getenv("DB_PASSWORD"); password != "" {
		DB_PASSWORD = password
	}
	if name := os.Getenv("DB_NAME"); name != "" {
		DB_NAME = name
	}
	if secret := os.Getenv("JWT_SECRET"); secret != "" {
		JWT_SECRET = secret
	} else {
		return fmt.Errorf("JWT_SECRET is not set in the environment variables")
	}

	if env := os.Getenv("APP_ENV"); env != "" {
		APP_ENV = env
	} else {
		return fmt.Errorf("APP_ENV is not set in the environment variables")
	}

	if refreshSecret := os.Getenv("JWT_REFRESH_SECRET"); refreshSecret != "" {
		JWT_REFRESH_SECRET = refreshSecret
	} else {
		return fmt.Errorf("JWT_REFRESH_SECRET is not set in the environment variables")
	}

	// Set JWT expiration and refresh expiration from environment variables if they exist
	if expiration := os.Getenv("JWT_EXPIRATION"); expiration != "" {
		JWT_EXPIRATION = expiration
	}
	if refreshExpiration := os.Getenv("JWT_REFRESH_EXPIRATION"); refreshExpiration != "" {
		JWT_REFRESH_EXPIRATION = refreshExpiration
	}

	// Set JWT issuer from environment variables if it exists
	if issuer := os.Getenv("JWT_ISSUER"); issuer != "" {
		JWT_ISSUER = issuer
	}

	if refreshIssuer := os.Getenv("JWT_REFRESH_ISSUER"); refreshIssuer != "" {
		JWT_REFRESH_ISSUER = refreshIssuer
	}

	if walletServiceAddr := os.Getenv("WALLET_SERVICE_ADDR"); walletServiceAddr != "" {
		WALLET_SERVICE_ADDR = walletServiceAddr
	}

	if grpcPort := os.Getenv("GRPC_PORT"); grpcPort != "" {
		GRPC_PORT = grpcPort
	}

	if httpPort := os.Getenv("HTTP_PORT"); httpPort != "" {
		HTTP_PORT = httpPort
	}

	return nil
}

func IsDevMode() bool {
	// Check if the application is running in development mode
	return os.Getenv("APP_ENV") == "development"
}
