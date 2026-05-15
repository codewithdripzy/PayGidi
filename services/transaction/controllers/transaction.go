package controllers

import (
	"net/http"

	"github.com/PayGidi/TransactionService/services/squad"
	"github.com/PayGidi/TransactionService/utils"
	"github.com/gin-gonic/gin"
	"github.com/patrickmn/go-cache"
)

// GetCustomerTransactions godoc
// @Summary Get customer transactions
// @Description Fetch transaction history for a specific customer identifier using the Squad API.
// @Tags Transactions
// @Accept json
// @Produce json
// @Param customerIdentifier path string true "Customer Identifier (e.g. email or UID)"
// @Success 200 {object} map[string]interface{} "Success"
// @Failure 400 {object} map[string]interface{} "Bad Request"
// @Router /transactions/{customerIdentifier} [get]
func GetCustomerTransactions(c *gin.Context) {
	customerIdentifier := c.Param("customerIdentifier")
	if customerIdentifier == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  400,
			"success": false,
			"message": "Customer identifier is required",
			"data":    gin.H{},
		})
		return
	}

	// Check Cache
	cacheKey := "transactions:" + customerIdentifier
	if cachedData, found := utils.AppCache.Get(cacheKey); found {
		c.JSON(http.StatusOK, gin.H{
			"status":  200,
			"success": true,
			"message": "Success (from cache)",
			"data":    cachedData,
		})
		return
	}

	success, errMsg, data := squad.GetCustomerTransactions(c.Request.Context(), customerIdentifier)

	if !success {
		msg := "Failed to fetch customer transactions"
		if errMsg != nil {
			msg = *errMsg
		}
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  400,
			"success": false,
			"message": msg,
			"data":    gin.H{},
		})
		return
	}

	// Store in Cache (Expires in 5 minutes)
	utils.AppCache.Set(cacheKey, data, cache.DefaultExpiration)

	c.JSON(http.StatusOK, gin.H{
		"status":  200,
		"success": true,
		"message": "Success",
		"data":    data,
	})
}
