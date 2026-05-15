package router

import (
	_ "github.com/PayGidi/WalletService/docs"
	"github.com/PayGidi/WalletService/controllers"
	"github.com/PayGidi/WalletService/core/constants"
	"github.com/PayGidi/WalletService/middlewares"
	"github.com/PayGidi/WalletService/services/account"
	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
	"gorm.io/gorm"
)

func SetupRoutes(r *gin.Engine, db *gorm.DB, accClient *account.AccountClient) {
	// Swagger documentation
	r.GET("/docs/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	// health check
	r.GET("/health", controllers.HealthCheck)

	walletController := controllers.NewWalletController(db, accClient)

	api := r.Group("/api/v1")
	walletGroup := api.Group("/wallet")
	// Public endpoints
	walletGroup.GET("/payments/:payment_id", walletController.GetPaymentHttp)
	walletGroup.POST("/webhook/squad", walletController.HandleSquadWebhook)
	
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

		// Payments (KYB Trust Layer integration)
		walletGroup.POST("/payments/new", walletController.CreatePaymentHttp)

		if constants.IsDevMode() {
			walletGroup.POST("/deposit/simulate", walletController.SimulatePaymentHttp)
		}
	}
}
