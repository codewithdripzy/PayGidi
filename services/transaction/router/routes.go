package router

import (
	_ "github.com/PayGidi/TransactionService/docs"
	"github.com/PayGidi/TransactionService/controllers"
	"github.com/PayGidi/TransactionService/middlewares"
	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

func SetupRoutes(app *gin.Engine) {
	// Swagger documentation
	app.GET("/docs/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	// health check
	app.GET("/health", controllers.HealthCheck)

	// create a new router group for the API
	api := app.Group("/api/v:version")

	// add middleware to check version
	api.Use(middlewares.VerifyVersion)

	// transactions
	api.GET("/transactions", middlewares.Authenticate(), controllers.GetCustomerTransactions)

	api.GET("/health", controllers.HealthCheck)
}
