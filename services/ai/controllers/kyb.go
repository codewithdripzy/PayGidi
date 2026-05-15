package controllers

import (
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
	CACNumber    string  `json:"cacNumber" binding:"required"`
	SocialHandle string  `json:"socialHandle" binding:"required"`
}

func (c *KYBController) SubmitPaymentKYB(ctx *gin.Context) {
	var req PaymentKYBRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Invalid request payload: " + err.Error()})
		return
	}

	analysis, err := c.orchestrator.ProcessPaymentKYB(
		ctx.Request.Context(),
		req.PaymentID,
		req.BusinessID,
		req.BusinessName,
		req.NIN,
		req.CACNumber,
		req.SocialHandle,
	)

	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": err.Error()})
		return
	}

	ctx.JSON(http.StatusCreated, gin.H{
		"success": true,
		"message": "Payment KYB analysis completed",
		"data":    analysis,
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

	err := c.orchestrator.ProcessKYB(ctx.Request.Context(), business.ID.String())
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Verification failed: " + err.Error()})
		return
	}

	c.db.Preload("Directors").Preload("Documents").First(&business, "id = ?", business.ID)
	ctx.JSON(http.StatusCreated, gin.H{"success": true, "message": "KYB submitted and processed", "data": business})
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
