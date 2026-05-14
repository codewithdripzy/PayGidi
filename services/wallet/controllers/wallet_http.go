package controllers

import (
	"net/http"

	payGidiErrors "github.com/PayGidi/WalletService/core/interfaces/errors"
	"github.com/PayGidi/WalletService/models"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type WalletHTTPController struct {
	db *gorm.DB
}

func NewWalletHTTPController(db *gorm.DB) *WalletHTTPController {
	return &WalletHTTPController{db: db}
}

// GetWallet retrieves the user's wallet details
func (wc *WalletHTTPController) GetWallet(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	var account models.Account
	if err := wc.db.Where("user_id = ?", userID).First(&account).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"error": "Wallet not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code": payGidiErrors.SUCCESS,
		"data": account,
	})
}

// GetWalletBalance retrieves the user's wallet balance
func (wc *WalletHTTPController) GetWalletBalance(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}
	
	// Check if account exists
	var account models.Account
	if err := wc.db.Where("user_id = ?", userID).First(&account).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"error": "Wallet not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code": payGidiErrors.SUCCESS,
		"data": gin.H{
			"accountNo": account.AccountNumber,
			"accountBalance": "0.00", // TODO: Implement actual balance fetching logic from Squad or local ledger
			"currencyCode": account.CurrencyCode,
		},
	})
}
