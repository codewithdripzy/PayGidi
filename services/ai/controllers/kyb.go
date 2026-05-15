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
	PaymentID    uint64 `json:"paymentId" binding:"required" validate:"required"`
	BusinessID   *string `json:"businessId"`
	BusinessName string `json:"businessName" binding:"required" validate:"required"`
	Description  string `json:"description" binding:"required" validate:"required"` // Description of goods/services
	BusinessType models.BusinessType `json:"businessType" binding:"required" validate:"required,oneof=registered unregistered"`

	// Always required identity layer
	NIN string `json:"nin" binding:"required" validate:"required,len=11"`
	SelfieImage string `json:"selfieImage" binding:"required" validate:"required"` // Base64 image for liveness check

	// Optional depending on business type
	Registration *models.BusinessRegistration `json:"registration,omitempty"`

	// Required for informal trust building
	InformalProfile *models.InformalBusinessProfile `json:"informalProfile,omitempty"`

	SocialProfiles []models.SocialProfile `json:"socialProfiles" binding:"required"`

	Contact models.ContactInfo `json:"contact" binding:"required"`

	Metadata models.VerificationMetadata `json:"metadata"`
}

// (Removed redundant PaymentKYBRequest as it's merged above)

// SubmitPaymentKYB godoc
// @Summary Submit Payment KYB
// @Description Submit business details for verification tied to a specific payment.
// @Tags KYB
// @Accept json
// @Produce json
// @Param body body PaymentKYBRequest true "Payment KYB data"
// @Success 202 {object} map[string]interface{} "Analysis started"
// @Failure 400 {object} map[string]interface{} "Bad Request"
// @Router /kyb/payment/submit [post]
func (c *KYBController) SubmitPaymentKYB(ctx *gin.Context) {
	val, exists := ctx.Get("validatedBody")
	if !exists {
		ctx.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Missing validated request payload"})
		return
	}
	req := val.(*PaymentKYBRequest)

	// For Payment KYB, we still run it synchronously or at least return immediately if needed.
	// But usually, payment flow needs the result or a 'pending' state.
	// The Orchestrator already updates the wallet service.
	
	go func() {
		_, err := c.orchestrator.ProcessPaymentKYB(
			context.Background(),
			req.PaymentID,
			req.BusinessID,
			req.BusinessName,
			req.Description,
			req.BusinessType,
			req.NIN,
			req.SelfieImage,
			req.Registration,
			req.InformalProfile,
			req.SocialProfiles,
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

// SubmitKYB godoc
// @Summary Submit General KYB
// @Description Submit business details for general verification.
// @Tags KYB
// @Accept json
// @Produce json
// @Param body body models.Business true "Business data"
// @Success 202 {object} map[string]interface{} "KYB submitted"
// @Failure 400 {object} map[string]interface{} "Bad Request"
// @Router /kyb/submit [post]
func (c *KYBController) SubmitKYB(ctx *gin.Context) {
	val, exists := ctx.Get("validatedBody")
	if !exists {
		ctx.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Missing validated business data"})
		return
	}
	business := val.(*models.Business)

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


// GetKYBStatus godoc
// @Summary Get KYB status
// @Description Retrieve the current status and results of a KYB verification.
// @Tags KYB
// @Produce json
// @Param id query string true "Business ID"
// @Success 200 {object} map[string]interface{} "Success"
// @Failure 400 {object} map[string]interface{} "Bad Request"
// @Failure 404 {object} map[string]interface{} "Not Found"
// @Router /kyb/status [get]
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
