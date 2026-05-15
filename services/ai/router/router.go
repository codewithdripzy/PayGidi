package router

import (
	"github.com/PayGidi/AIService/controllers"
	"github.com/PayGidi/AIService/services/kyb"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func SetupRoutes(r *gin.Engine, db *gorm.DB, orch *kyb.Orchestrator) {
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
