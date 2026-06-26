package controllers

import (
	"net/http"
	"strconv"

	"github.com/PayGidi/WalletService/models"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type FinanceController struct {
	db *gorm.DB
}

func NewFinanceController(db *gorm.DB) *FinanceController {
	return &FinanceController{db: db}
}

// ListSavingsGoals retrieves all savings goals for the authenticated user
func (fc *FinanceController) ListSavingsGoals(c *gin.Context) {
	userID, _ := c.Get("userID")
	var goals []models.SavingsGoal

	if err := fc.db.Where("user_id = ?", userID).Order("created_at desc").Find(&goals).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  500,
			"success": false,
			"message": "Failed to fetch savings goals",
			"data":    gin.H{},
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  200,
		"success": true,
		"message": "Success",
		"data":    goals,
	})
}

// CreateSavingsGoal creates a new savings goal
func (fc *FinanceController) CreateSavingsGoal(c *gin.Context) {
	userID, _ := c.Get("userID")

	var req struct {
		Name         string  `json:"name" binding:"required"`
		TargetAmount float64 `json:"targetAmount" binding:"required,gt=0"`
		Currency     string  `json:"currency"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  400,
			"success": false,
			"message": "Invalid request payload",
			"data":    gin.H{},
		})
		return
	}

	goal := models.SavingsGoal{
		UserID:       userID.(uint),
		Name:         req.Name,
		TargetAmount: req.TargetAmount,
		Currency:     req.Currency,
	}

	if goal.Currency == "" {
		goal.Currency = "NGN"
	}

	if err := fc.db.Create(&goal).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  500,
			"success": false,
			"message": "Failed to create savings goal",
			"data":    gin.H{},
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  200,
		"success": true,
		"message": "Savings goal created successfully",
		"data":    goal,
	})
}

// UpdateSavingsGoal updates an existing savings goal
func (fc *FinanceController) UpdateSavingsGoal(c *gin.Context) {
	userID, _ := c.Get("userID")
	goalID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  400,
			"success": false,
			"message": "Invalid goal ID",
			"data":    gin.H{},
		})
		return
	}

	var goal models.SavingsGoal
	if err := fc.db.Where("id = ? AND user_id = ?", uint(goalID), userID).First(&goal).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"status":  404,
			"success": false,
			"message": "Savings goal not found",
			"data":    gin.H{},
		})
		return
	}

	var req struct {
		Name         *string  `json:"name"`
		TargetAmount *float64 `json:"targetAmount"`
		CurrentAmount *float64 `json:"currentAmount"`
		Status       *string  `json:"status"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  400,
			"success": false,
			"message": "Invalid request payload",
			"data":    gin.H{},
		})
		return
	}

	updates := map[string]interface{}{}
	if req.Name != nil {
		updates["name"] = *req.Name
	}
	if req.TargetAmount != nil {
		updates["target_amount"] = *req.TargetAmount
	}
	if req.CurrentAmount != nil {
		updates["current_amount"] = *req.CurrentAmount
	}
	if req.Status != nil {
		updates["status"] = *req.Status
	}

	if err := fc.db.Model(&goal).Updates(updates).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  500,
			"success": false,
			"message": "Failed to update savings goal",
			"data":    gin.H{},
		})
		return
	}

	fc.db.First(&goal, goal.ID)

	c.JSON(http.StatusOK, gin.H{
		"status":  200,
		"success": true,
		"message": "Savings goal updated successfully",
		"data":    goal,
	})
}

// DeleteSavingsGoal deletes a savings goal
func (fc *FinanceController) DeleteSavingsGoal(c *gin.Context) {
	userID, _ := c.Get("userID")
	goalID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  400,
			"success": false,
			"message": "Invalid goal ID",
			"data":    gin.H{},
		})
		return
	}

	result := fc.db.Where("id = ? AND user_id = ?", uint(goalID), userID).Delete(&models.SavingsGoal{})
	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  500,
			"success": false,
			"message": "Failed to delete savings goal",
			"data":    gin.H{},
		})
		return
	}
	if result.RowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{
			"status":  404,
			"success": false,
			"message": "Savings goal not found",
			"data":    gin.H{},
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  200,
		"success": true,
		"message": "Savings goal deleted successfully",
		"data":    gin.H{},
	})
}

// ListThrifts retrieves thrifts - user's joined thrifts and public thrifts
func (fc *FinanceController) ListThrifts(c *gin.Context) {
	userID, _ := c.Get("userID")

	type ThriftWithMembership struct {
		models.Thrift
		IsMember bool `json:"isMember"`
	}

	var memberThriftIDs []uint
	fc.db.Model(&models.ThriftMember{}).Where("user_id = ? AND status = ?", userID, "active").Pluck("thrift_id", &memberThriftIDs)

	var thrifts []models.Thrift
	if err := fc.db.Where("is_public = ? OR id IN ?", true, memberThriftIDs).Order("created_at desc").Find(&thrifts).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  500,
			"success": false,
			"message": "Failed to fetch thrifts",
			"data":    gin.H{},
		})
		return
	}

	memberSet := make(map[uint]bool)
	for _, id := range memberThriftIDs {
		memberSet[id] = true
	}

	result := make([]ThriftWithMembership, len(thrifts))
	for i, t := range thrifts {
		result[i] = ThriftWithMembership{
			Thrift:   t,
			IsMember: memberSet[t.ID],
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  200,
		"success": true,
		"message": "Success",
		"data":    result,
	})
}

// CreateThrift creates a new thrift group
func (fc *FinanceController) CreateThrift(c *gin.Context) {
	userID, _ := c.Get("userID")

	var req struct {
		Name                 string  `json:"name" binding:"required"`
		Description          string  `json:"description"`
		ContributionAmount   float64 `json:"contributionAmount" binding:"required,gt=0"`
		ContributionFrequency string `json:"contributionFrequency"`
		MaxMembers           int     `json:"maxMembers"`
		IsPublic             bool    `json:"isPublic"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  400,
			"success": false,
			"message": "Invalid request payload",
			"data":    gin.H{},
		})
		return
	}

	if req.ContributionFrequency == "" {
		req.ContributionFrequency = "monthly"
	}

	thrift := models.Thrift{
		CreatorID:            userID.(uint),
		Name:                 req.Name,
		Description:          req.Description,
		ContributionAmount:   req.ContributionAmount,
		ContributionFrequency: req.ContributionFrequency,
		MaxMembers:           req.MaxMembers,
		CurrentMembers:       1,
		IsPublic:             req.IsPublic,
	}

	if err := fc.db.Create(&thrift).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  500,
			"success": false,
			"message": "Failed to create thrift",
			"data":    gin.H{},
		})
		return
	}

	member := models.ThriftMember{
		ThriftID: thrift.ID,
		UserID:   userID.(uint),
		Status:   "active",
	}
	fc.db.Create(&member)

	c.JSON(http.StatusOK, gin.H{
		"status":  200,
		"success": true,
		"message": "Thrift created successfully",
		"data":    thrift,
	})
}

// JoinThrift allows a user to join a public thrift
func (fc *FinanceController) JoinThrift(c *gin.Context) {
	userID, _ := c.Get("userID")
	thriftID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  400,
			"success": false,
			"message": "Invalid thrift ID",
			"data":    gin.H{},
		})
		return
	}

	var thrift models.Thrift
	if err := fc.db.First(&thrift, uint(thriftID)).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"status":  404,
			"success": false,
			"message": "Thrift not found",
			"data":    gin.H{},
		})
		return
	}

	if !thrift.IsPublic {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  400,
			"success": false,
			"message": "This thrift is not open for public joining",
			"data":    gin.H{},
		})
		return
	}

	if thrift.MaxMembers > 0 && thrift.CurrentMembers >= thrift.MaxMembers {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  400,
			"success": false,
			"message": "Thrift is full",
			"data":    gin.H{},
		})
		return
	}

	var existing models.ThriftMember
	if err := fc.db.Where("thrift_id = ? AND user_id = ?", uint(thriftID), userID).First(&existing).Error; err == nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  400,
			"success": false,
			"message": "Already a member of this thrift",
			"data":    gin.H{},
		})
		return
	}

	member := models.ThriftMember{
		ThriftID: uint(thriftID),
		UserID:   userID.(uint),
		Status:   "active",
	}
	if err := fc.db.Create(&member).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  500,
			"success": false,
			"message": "Failed to join thrift",
			"data":    gin.H{},
		})
		return
	}

	fc.db.Model(&thrift).UpdateColumn("current_members", gorm.Expr("current_members + 1"))

	c.JSON(http.StatusOK, gin.H{
		"status":  200,
		"success": true,
		"message": "Successfully joined thrift",
		"data":    member,
	})
}

// GetFinanceSummary returns the user's finance summary
func (fc *FinanceController) GetFinanceSummary(c *gin.Context) {
	userID, _ := c.Get("userID")

	type Summary struct {
		TotalSavings    float64 `json:"totalSavings"`
		PersonalSavings float64 `json:"personalSavings"`
		ThriftSavings   float64 `json:"thriftSavings"`
	}

	var summary Summary

	fc.db.Model(&models.SavingsGoal{}).
		Select("COALESCE(SUM(current_amount), 0)").
		Where("user_id = ? AND status = 'active'", userID).
		Scan(&summary.PersonalSavings)

	// Calculate thrift savings from thrift memberships
	fc.db.Raw(`
		SELECT COALESCE(SUM(t.contribution_amount), 0)
		FROM thrift_members tm
		JOIN thrifts t ON t.id = tm.thrift_id
		WHERE tm.user_id = ? AND tm.status = 'active' AND t.status = 'active'
	`, userID).Scan(&summary.ThriftSavings)

	summary.TotalSavings = summary.PersonalSavings + summary.ThriftSavings

	c.JSON(http.StatusOK, gin.H{
		"status":  200,
		"success": true,
		"message": "Success",
		"data":    summary,
	})
}
