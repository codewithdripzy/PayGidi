package router

import (
	"github.com/PayGidi/AIService/controllers"
	"github.com/PayGidi/AIService/middlewares"
	"github.com/PayGidi/AIService/services/kyb"
	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
	"gorm.io/gorm"
)

func SetupRoutes(r *gin.Engine, db *gorm.DB, orch *kyb.Orchestrator) {
	// Swagger documentation
	r.GET("/docs/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	kybController := controllers.NewKYBController(db, orch)

	api := r.Group("/api/v1")
	{
		kybGroup := api.Group("/kyb")
		{
			kybGroup.POST("/submit", kybController.SubmitKYB)
			kybGroup.POST("/payment/submit", kybController.SubmitPaymentKYB)
			kybGroup.GET("/status", kybController.GetKYBStatus)
		}
	}
}
