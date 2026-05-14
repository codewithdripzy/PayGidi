package router

import (
	"github.com/PayGidi/TransactionService/controllers"
	"github.com/PayGidi/TransactionService/middlewares"
	"github.com/gin-gonic/gin"
)

func SetupRoutes(app *gin.Engine) {
	// create a new router group for the API
	api := app.Group("/api/v:version")

	// add middleware to check version
	api.Use(middlewares.VerifyVersion)

	// transactions
	api.GET("/transactions/:customerIdentifier", middlewares.Authenticate(), controllers.GetCustomerTransactions)

	api.GET("/health", controllers.HealthCheck)
}
