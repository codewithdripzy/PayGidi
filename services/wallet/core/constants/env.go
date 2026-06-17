package constants

import (
	"fmt"
	"log"
	"os"
	"strings"

	"github.com/joho/godotenv"
)

var (
	DB_HOST     string
	DB_PORT     string
	DB_USER     string
	DB_PASSWORD string
	DB_NAME     string

	// Squad constants
	SQUAD_API_URL             string
	SQUAD_SECRET_KEY          string
	SQUAD_BENEFICIARY_ACCOUNT string

	// JWT constants
	JWT_SECRET         string
	JWT_REFRESH_SECRET string
	JWT_REFRESH_ISSUER string = "paygidi_refresh"

	// Application mode
	APP_ENV   string = "development"
	GRPC_PORT string = "50053"
	HTTP_PORT string = "8082"

	NOTIFICATION_SERVICE_ADDR string = "localhost:50052"
	ACCOUNT_SERVICE_ADDR      string = "localhost:50051"
)

func ConfigDotenv() error {
	// Attempt to load .env.production, then .env
	_ = godotenv.Load(".env.production")
	_ = godotenv.Load()

	// Allow explicit env file selection (e.g. ENV_FILE=.env.production).
	if envFile := strings.TrimSpace(os.Getenv("ENV_FILE")); envFile != "" {
		_ = godotenv.Overload(envFile)
	} else {
		// Load environment-specific file if APP_ENV is already exported.
		if env := strings.TrimSpace(os.Getenv("APP_ENV")); env != "" {
			_ = godotenv.Overload(".env." + env)
		}
	}

	// Safety fallback for deployments
	if strings.TrimSpace(os.Getenv("SQUAD_SECRET_KEY")) == "" {
		_ = godotenv.Overload(".env.production")
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

	if env := os.Getenv("APP_ENV"); env != "" {
		APP_ENV = env
	} else {
		return fmt.Errorf("APP_ENV is not set in the environment variables")
	}

	if squadApiUrl := os.Getenv("SQUAD_API_URL"); squadApiUrl != "" {
		SQUAD_API_URL = squadApiUrl
	}
	log.Printf("[ConfigDotenv] Loaded SQUAD_API_URL: %s", SQUAD_API_URL)

	if squadSecretKey := os.Getenv("SQUAD_SECRET_KEY"); squadSecretKey != "" {
		SQUAD_SECRET_KEY = squadSecretKey
	}
	// Redact secret key in logs for security
	if SQUAD_SECRET_KEY != "" {
		log.Printf("[ConfigDotenv] Loaded SQUAD_SECRET_KEY: [REDACTED]")
	} else {
		log.Printf("[ConfigDotenv] SQUAD_SECRET_KEY is empty")
	}

	if squadBeneficiaryAccount := os.Getenv("SQUAD_BENEFICIARY_ACCOUNT"); squadBeneficiaryAccount != "" {
		SQUAD_BENEFICIARY_ACCOUNT = squadBeneficiaryAccount
	}
	log.Printf("[ConfigDotenv] Loaded SQUAD_BENEFICIARY_ACCOUNT: %s", SQUAD_BENEFICIARY_ACCOUNT)

	if jwtSecret := os.Getenv("JWT_SECRET"); jwtSecret != "" {
		JWT_SECRET = jwtSecret
	}

	if jwtRefreshSecret := os.Getenv("JWT_REFRESH_SECRET"); jwtRefreshSecret != "" {
		JWT_REFRESH_SECRET = jwtRefreshSecret
	}

	if jwtRefreshIssuer := os.Getenv("JWT_REFRESH_ISSUER"); jwtRefreshIssuer != "" {
		JWT_REFRESH_ISSUER = jwtRefreshIssuer
	}

	if port := os.Getenv("GRPC_PORT"); port != "" {
		GRPC_PORT = port
	}

	if port := os.Getenv("HTTP_PORT"); port != "" {
		HTTP_PORT = port
	}

	if notificationAddress := os.Getenv("NOTIFICATION_SERVICE_ADDR"); notificationAddress != "" {
		NOTIFICATION_SERVICE_ADDR = notificationAddress
	}

	if accountAddress := os.Getenv("ACCOUNT_SERVICE_ADDR"); accountAddress != "" {
		ACCOUNT_SERVICE_ADDR = accountAddress
	}

	return nil
}

func IsDevMode() bool {
	// Check if the application is running in development mode
	return os.Getenv("APP_ENV") == "development"
}
