package router

import (
	"github.com/PayGidi/WalletService/controllers"
	"github.com/PayGidi/WalletService/core/constants"
	"github.com/PayGidi/WalletService/middlewares"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func SetupRoutes(r *gin.Engine, db *gorm.DB) {
	walletController := controllers.NewWalletController(db)

	walletGroup := r.Group("/wallet")
	walletGroup.Use(middlewares.Authenticate())
	{
		walletGroup.GET("", walletController.GetWalletHttp)
		walletGroup.GET("/:accountNumber", walletController.GetWalletHttp)
		walletGroup.GET("/:accountNumber/transactions", walletController.GetTransactionsHttp)

		// Transfers
		walletGroup.POST("/transfer/lookup", walletController.ResolveAccountHttp)
		walletGroup.POST("/transfer", walletController.InitiateTransferHttp)

		if constants.IsDevMode() {
			walletGroup.POST("/deposit/simulate", walletController.SimulatePaymentHttp)
		}
	}
}
