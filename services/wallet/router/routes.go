package router

import (
	"github.com/PayGidi/WalletService/controllers"
	"github.com/PayGidi/WalletService/core/constants"
	_ "github.com/PayGidi/WalletService/docs"
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

	// Public endpoints - defined outside the authenticated group
	walletGroup.GET("/banks", walletController.GetBanksHttp)
	walletGroup.GET("/payments/:payment_id", walletController.GetPaymentHttp)
	walletGroup.POST("/webhook/squad", walletController.HandleSquadWebhook)

	// Authenticated endpoints
	authGroup := walletGroup.Group("")
	authGroup.Use(middlewares.Authenticate())
	{
		authGroup.GET("", walletController.GetWalletHttp)
		authGroup.GET("/:accountNumber", walletController.GetWalletHttp)
		authGroup.GET("/:accountNumber/transactions", walletController.GetTransactionsHttp)

		// Transfers
		authGroup.POST("/transfer/lookup", walletController.ResolveAccountHttp)
		authGroup.POST("/transfer", walletController.InitiateTransferHttp)
		authGroup.GET("/transfer/list", walletController.GetAllTransfersHttp)
		authGroup.POST("/transfer/requery", walletController.RequeryTransferHttp)

		// Disputes
		authGroup.GET("/disputes", walletController.GetAllDisputesHttp)
		authGroup.GET("/disputes/upload-url/:ticketId/:fileName", walletController.GetDisputeUploadURLHttp)
		authGroup.POST("/disputes/:ticketId/resolve", walletController.ResolveDisputeHttp)

		// Create Wallet
		authGroup.POST("/create", walletController.CreateWalletHttp)

		// Balance
		authGroup.GET("/balance", walletController.GetTotalBalanceHttp)

		// Payments (KYB Trust Layer integration)
		authGroup.POST("/payments/new", walletController.CreatePaymentHttp)

		if constants.IsDevMode() {
			authGroup.POST("/deposit/simulate", walletController.SimulatePaymentHttp)
		}
	}

}
