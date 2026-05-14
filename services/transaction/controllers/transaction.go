package controllers

import (
	"net/http"

	"github.com/PayGidi/TransactionService/services/squad"
	"github.com/gin-gonic/gin"
)

// GetCustomerTransactions fetches the transactions for a customer identifier.
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

	c.JSON(http.StatusOK, gin.H{
		"status":  200,
		"success": true,
		"message": "Success",
		"data":    data,
	})
}
