package router

import (
	"github.com/PayGidi/TransactionService/controllers"
	"github.com/PayGidi/TransactionService/middlewares"
	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

func SetupRoutes(app *gin.Engine) {
	// Swagger documentation
	app.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))
	// create a new router group for the API
	api := app.Group("/api/v:version")

	// add middleware to check version
	api.Use(middlewares.VerifyVersion)

	// transactions
	api.GET("/transactions/:customerIdentifier", middlewares.Authenticate(), controllers.GetCustomerTransactions)

	api.GET("/health", controllers.HealthCheck)
}
