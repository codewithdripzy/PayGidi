package router

import (
	"github.com/PayGidi/WalletService/controllers"
	"github.com/PayGidi/WalletService/middlewares"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func SetupRoutes(r *gin.Engine, db *gorm.DB) {
	walletController := controllers.NewWalletHTTPController(db)

	walletGroup := r.Group("/wallet")
	walletGroup.Use(middlewares.Authenticate())
	{
		walletGroup.GET("", walletController.GetWallet)
		walletGroup.GET("/balance", walletController.GetWalletBalance)
	}
}
