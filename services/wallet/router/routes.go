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
		walletGroup.GET("/banks", walletController.GetBanksHttp)
		walletGroup.GET("", walletController.GetWalletHttp)
		walletGroup.GET("/:accountNumber", walletController.GetWalletHttp)
		walletGroup.GET("/:accountNumber/transactions", walletController.GetTransactionsHttp)

		// Transfers
		walletGroup.POST("/transfer/lookup", walletController.ResolveAccountHttp)
		walletGroup.POST("/transfer", walletController.InitiateTransferHttp)
		walletGroup.GET("/transfer/list", walletController.GetAllTransfersHttp)
		walletGroup.POST("/transfer/requery", walletController.RequeryTransferHttp)

		// Disputes
		walletGroup.GET("/disputes", walletController.GetAllDisputesHttp)
		walletGroup.GET("/disputes/upload-url/:ticketId/:fileName", walletController.GetDisputeUploadURLHttp)
		walletGroup.POST("/disputes/:ticketId/resolve", walletController.ResolveDisputeHttp)

		// Create Wallet
		walletGroup.POST("/create", walletController.CreateWalletHttp)

		if constants.IsDevMode() {
			walletGroup.POST("/deposit/simulate", walletController.SimulatePaymentHttp)
		}
	}
}
