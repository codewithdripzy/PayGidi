package controllers

import (
	"context"
	"log"
	"net/http"

	"github.com/PayGidi/AIService/models"
	"github.com/PayGidi/AIService/services/kyb"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type KYBController struct {
	db           *gorm.DB
	orchestrator *kyb.Orchestrator
}

func NewKYBController(db *gorm.DB, orch *kyb.Orchestrator) *KYBController {
	return &KYBController{
		db:           db,
		orchestrator: orch,
	}
}

type PaymentKYBRequest struct {
	PaymentID    uint64  `json:"paymentId" binding:"required"`
	BusinessID   *string `json:"businessId"`
	BusinessName string  `json:"businessName" binding:"required"`
	NIN          string  `json:"nin" binding:"required"`
	CACNumber    string  `json:"cacNumber"` // Optional for Informal
	SocialHandle string  `json:"socialHandle" binding:"required"`
}

func (c *KYBController) SubmitPaymentKYB(ctx *gin.Context) {
	var req PaymentKYBRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Invalid request payload: " + err.Error()})
		return
	}

	// For Payment KYB, we still run it synchronously or at least return immediately if needed.
	// But usually, payment flow needs the result or a 'pending' state.
	// The Orchestrator already updates the wallet service.
	
	go func() {
		_, err := c.orchestrator.ProcessPaymentKYB(
			context.Background(),
			req.PaymentID,
			req.BusinessID,
			req.BusinessName,
			req.NIN,
			req.CACNumber,
			req.SocialHandle,
		)
		if err != nil {
			log.Printf("Background Payment KYB failed for Payment %d: %v", req.PaymentID, err)
		}
	}()

	ctx.JSON(http.StatusAccepted, gin.H{
		"success": true,
		"message": "Payment KYB analysis has started in the background",
	})
}

func (c *KYBController) SubmitKYB(ctx *gin.Context) {
	var business models.Business
	if err := ctx.ShouldBindJSON(&business); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Invalid request payload"})
		return
	}

	if err := c.db.Create(&business).Error; err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Failed to save business data"})
		return
	}

	// Run PIPELINE in background
	go func(bID string) {
		log.Printf("Starting Multi-Tier Verification Pipeline for Business: %s", bID)
		err := c.orchestrator.ProcessKYB(context.Background(), bID)
		if err != nil {
			log.Printf("Background KYB Pipeline failed for Business %s: %v", bID, err)
		} else {
			log.Printf("Background KYB Pipeline completed successfully for Business %s", bID)
		}
	}(business.ID.String())

	ctx.JSON(http.StatusAccepted, gin.H{
		"success": true, 
		"message": "KYB submitted. Multi-tier verification pipeline is running in the background.", 
		"data": gin.H{"id": business.ID},
	})
}


func (c *KYBController) GetKYBStatus(ctx *gin.Context) {
	idStr := ctx.Query("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Invalid business ID"})
		return
	}

	var business models.Business
	if err := c.db.Preload("Directors").Preload("Documents").First(&business, "id = ?", id).Error; err != nil {
		ctx.JSON(http.StatusNotFound, gin.H{"success": false, "message": "Business not found"})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{"success": true, "message": "KYB status retrieved", "data": business})
}
