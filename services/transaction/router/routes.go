package router

import (
	"github.com/PayGidi/AccountService/controllers"
	"github.com/PayGidi/AccountService/dto"
	"github.com/PayGidi/AccountService/middlewares"
	"github.com/gin-gonic/gin"
)

func SetupRoutes(app *gin.Engine) {
	// create a new router group for the API
	api := app.Group("/api/v:version")

	// add middleware to check version
	api.Use(middlewares.VerifyVersion)

	api.POST("/account/new", middlewares.ValidateDTO(&dto.CreateAccountDto{}), controllers.CreateAccount)

	// wallet routes
	api.POST("/wallet/new", middlewares.Authenticate(), middlewares.ValidateDTO(&dto.CreateWalletDto{}), controllers.CreateWallet)
	api.POST("/wallet/send", middlewares.Authenticate(), middlewares.ValidateDTO(&dto.SendMoneyDto{}), controllers.SendMoney)

	api.GET("/health", controllers.HealthCheck)
}
