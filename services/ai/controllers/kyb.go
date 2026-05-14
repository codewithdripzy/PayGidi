package controllers

import (
	"context"
	"net/http"

	"github.com/PayGidi/AIService/models"
	"github.com/PayGidi/AIService/services/kyb"
	"github.com/PayGidi/AIService/utils"
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

func (c *KYBController) SubmitKYB(w http.ResponseWriter, r *http.Request) {
	var business models.Business
	if err := utils.DecodeJSON(r, &business); err != nil {
		utils.ErrorResponse(w, http.StatusBadRequest, "Invalid request payload")
		return
	}

	if err := c.db.Create(&business).Error; err != nil {
		utils.ErrorResponse(w, http.StatusInternalServerError, "Failed to save business data")
		return
	}

	// Trigger verification in background or foreground
	// For now, let's do it synchronously to show it works
	err := c.orchestrator.ProcessKYB(context.Background(), business.ID.String())
	if err != nil {
		utils.ErrorResponse(w, http.StatusInternalServerError, "Verification failed: "+err.Error())
		return
	}

	// Reload to get updated status/score
	c.db.Preload("Directors").Preload("Documents").First(&business, "id = ?", business.ID)

	utils.SuccessResponse(w, http.StatusCreated, "KYB submitted and processed", business)
}

func (c *KYBController) GetKYBStatus(w http.ResponseWriter, r *http.Request) {
	idStr := r.URL.Query().Get("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		utils.ErrorResponse(w, http.StatusBadRequest, "Invalid business ID")
		return
	}

	var business models.Business
	if err := c.db.Preload("Directors").Preload("Documents").First(&business, "id = ?", id).Error; err != nil {
		utils.ErrorResponse(w, http.StatusNotFound, "Business not found")
		return
	}

	utils.SuccessResponse(w, http.StatusOK, "KYB status retrieved", business)
}
