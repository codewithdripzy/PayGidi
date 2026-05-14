package controllers

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	payGidiErrors "github.com/PayGidi/AccountService/core/interfaces/errors"
	"github.com/PayGidi/AccountService/dto"
	"github.com/PayGidi/AccountService/models"
	"github.com/PayGidi/AccountService/providers"
	"github.com/PayGidi/AccountService/utils"
)

func CreateAccount(c *gin.Context) {
	db := c.MustGet("db").(*gorm.DB)
	var dto dto.CreateAccountDto

	if err := c.ShouldBindJSON(&dto); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":  payGidiErrors.INVALID_REQUEST_BODY,
			"error": "Invalid request data",
		})
		return
	}

	// get the user ID from the context
	userID := c.MustGet("userID").(string)

	// check if account already exists
	var existingAccount models.Account
	if err := db.Where("user_id = ?", userID).First(&existingAccount).Error; err == nil {
		c.JSON(http.StatusConflict, gin.H{
			"code":  payGidiErrors.ACCOUNT_ALREADY_EXISTS,
			"error": "Account already exists for this user",
		})
		return
	}

	// Get user details from the context
	user := c.MustGet("user").(models.User)
	accountNumber, err := utils.CreateAccountNumberFromPhone(user.Phone)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":  payGidiErrors.INVALID_REQUEST_BODY,
			"error": "Unable to create account, change your phone number or contact support if the issue persists.",
		})
		return
	}

	// make a request to create account with monnify
	account, err := providers.CreateAccount(providers.AccountData{
		FirstName:      user.Person.FirstName,
		LastName:       user.Person.LastName,
		Email:          user.Email,
		Bvn:            dto.Bvn,
		BvnDateOfBirth: dto.BvnDateOfBirth,
		AccountNumber:  accountNumber,
	})

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":  payGidiErrors.ACCOUNT_CREATION_FAILED,
			"error": "Failed to create account, please try again later or contact support if the issue persists.",
		})
		return
	}

	// create account record in the database
	newAccount := models.Account{
		User:             user,
		UserID:           user.ID,
		AccountNumber:    accountNumber,               // This should come from the provider response
		AccountFeatures:  []string{"debit", "credit"}, // Example features
		AccountCategory:  dto.AccountCategory,         // Example category
		AccountType:      "savings",                   // Example type
		AccountNickname:  "",
		AccountReference: account.AccountReference, // This should come from the provider response
		CurrencyCode:     dto.Currency,
		Provider:         "Monnify",
		Status:           "active",
		CreatedAt:        time.Now(),
		UpdatedAt:        time.Now(),
	}

	if err := db.Create(&newAccount).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":  payGidiErrors.ACCOUNT_CREATION_FAILED,
			"error": "Failed to save account details, contact support to resolve the issue.",
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"code":    payGidiErrors.SUCCESS,
		"message": "Your Account was created successfully, Cheers 🎉",
		"account": account,
	})
}
func GetAccount(c *gin.Context) {
	// db := c.MustGet("db").(*gorm.DB)
	// userID := c.MustGet("userID").(string)

	// var account models.Account
	// if err := db.Where("user_id = ?", userID).First(&account).Error; err != nil {
	// 	c.JSON(http.StatusNotFound, gin.H{
	// 		"code":  payGidiErrors.ACCOUNT_NOT_FOUND,
	// 		"error": "Account not found",
	// 	})
	// 	return
	// }

	// c.JSON(http.StatusOK, gin.H{
	// 	"code":    payGidiErrors.SUCCESS,
	// 	"account": account,
	// })
}

func SetAccountPin(c *gin.Context) {
	// Placeholder for setting account PIN logic
	c.JSON(http.StatusNotImplemented, gin.H{
		"code":    payGidiErrors.ACCOUNT_ALREADY_EXISTS,
		"message": "SetAccountPin functionality is not implemented yet.",
	})
}
