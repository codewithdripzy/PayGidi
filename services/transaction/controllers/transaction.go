package controllers

import (
	"net/http"
	"sort"
	"time"

	"github.com/PayGidi/TransactionService/core/interfaces/responses"
	"github.com/PayGidi/TransactionService/models"
	"github.com/PayGidi/TransactionService/services/squad"
	"github.com/PayGidi/TransactionService/utils"
	"github.com/gin-gonic/gin"
	"github.com/patrickmn/go-cache"
	"gorm.io/gorm"
)

// GetCustomerTransactions godoc
// @Summary Get customer transactions
// @Description Fetch transaction history for all wallet accounts of the authenticated customer using the Squad API.
// @Tags Transactions
// @Accept json
// @Produce json
// @Security BearerAuth
// @Success 200 {object} map[string]interface{} "Success"
// @Failure 400 {object} map[string]interface{} "Bad Request"
// @Router /transactions [get]
func GetCustomerTransactions(c *gin.Context) {
	// Get user from context (set by Authenticate middleware)
	userVal, exists := c.Get("user")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"status":  401,
			"success": false,
			"message": "User not authenticated",
			"data":    gin.H{},
		})
		return
	}

	user, ok := userVal.(models.User)
	if !ok {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  500,
			"success": false,
			"message": "Invalid user data in context",
			"data":    gin.H{},
		})
		return
	}

	dbVal, exists := c.Get("db")
	if !exists {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  500,
			"success": false,
			"message": "Database connection not found",
			"data":    gin.H{},
		})
		return
	}
	db := dbVal.(*gorm.DB)

	// Fetch user from DB to get the ID (primary key)
	var dbUser models.User
	if err := db.Where("uid = ?", user.UID).First(&dbUser).Error; err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{
			"status":  401,
			"success": false,
			"message": "User not found in database: " + err.Error(),
			"data":    gin.H{},
		})
		return
	}

	// Fetch all accounts associated with the user
	var accounts []models.Account
	if err := db.Where("user_id = ?", dbUser.ID).Find(&accounts).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  500,
			"success": false,
			"message": "Failed to fetch user accounts",
			"data":    gin.H{},
		})
		return
	}

	if len(accounts) == 0 {
		c.JSON(http.StatusOK, gin.H{
			"status":  200,
			"success": true,
			"message": "No accounts found for this user",
			"data":    []interface{}{},
		})
		return
	}

	// Check Cache using UID as key
	cacheKey := "transactions:" + user.UID
	if cachedData, found := utils.AppCache.Get(cacheKey); found {
		c.JSON(http.StatusOK, gin.H{
			"status":  200,
			"success": true,
			"message": "Success (from cache)",
			"data":    cachedData,
		})
		return
	}

	var allTransactions []responses.SquadCustomerTransaction
	seenRefs := make(map[string]bool)

	for _, acc := range accounts {
		if acc.CustomerIdentifier == "" {
			continue
		}

		success, _, data := squad.GetCustomerTransactions(c.Request.Context(), acc.CustomerIdentifier)
		if success && data != nil {
			for _, tx := range data {
				if !seenRefs[tx.TransactionReference] {
					allTransactions = append(allTransactions, tx)
					seenRefs[tx.TransactionReference] = true
				}
			}
		}
	}

	// Sort transactions by date descending
	sort.Slice(allTransactions, func(i, j int) bool {
		t1, err1 := time.Parse(time.RFC3339, allTransactions[i].TransactionDate)
		t2, err2 := time.Parse(time.RFC3339, allTransactions[j].TransactionDate)
		if err1 != nil || err2 != nil {
			return false
		}
		return t1.After(t2)
	})

	// Store in Cache (Expires in 5 minutes)
	utils.AppCache.Set(cacheKey, allTransactions, cache.DefaultExpiration)

	c.JSON(http.StatusOK, gin.H{
		"status":  200,
		"success": true,
		"message": "Success",
		"data":    allTransactions,
	})
}
