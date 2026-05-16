package controllers

import (
	"context"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/PayGidi/AccountService/core/constants"
	"github.com/PayGidi/AccountService/models"
	walletService "github.com/PayGidi/AccountService/services/wallet"
	"github.com/PayGidi/AccountService/utils"
	"github.com/PayGidi/AccountService/validators"
	walletpb "github.com/PayGidi/WalletService/proto/connection/pb"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func maskPhoneForLog(phone string) string {
	if len(phone) <= 4 {
		return "****"
	}

	return "****" + phone[len(phone)-4:]
}

func maskEmailForLog(email string) string {
	for i := 0; i < len(email); i++ {
		if email[i] == '@' {
			if i <= 2 {
				return "***" + email[i:]
			}

			return email[:2] + "***" + email[i:]
		}
	}

	return "***"
}

// CompleteAccount godoc
// @Summary Complete account registration
// @Description Finalize user or business account setup after phone verification.
// @Tags Auth
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param body body interface{} true "Account data (either IndividualCompleteAccountDto or BusinessCompleteAccountDto)"
// @Success 200 {object} map[string]interface{} "Account completed successfully"
// @Failure 401 {object} map[string]interface{} "Unauthorized"
// @Failure 500 {object} map[string]interface{} "Internal server error"
// @Router /auth/complete [post]
func CompleteAccount(c *gin.Context) {
	start := time.Now()
	log.Printf("[CompleteAccount] start request method=%s path=%s ip=%s", c.Request.Method, c.Request.URL.Path, c.ClientIP())

	db := c.MustGet("db").(*gorm.DB)
	user, _ := c.Get("user")
	u := user.(models.User)

	validatedBody, _ := c.Get("validatedBody")

	tx := db.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	var email string
	var firstName string
	var lastName string
	var middleName string
	var address string
	var dob string
	var nin string
	var bvn string
	var gender string

	if u.AccountType == "business" {
		data := validatedBody.(*validators.BusinessCompleteAccountDto)
		email = data.OwnerInfo.Email
		firstName = data.OwnerInfo.FirstName
		lastName = data.OwnerInfo.LastName
		middleName = data.OwnerInfo.MiddleName
		address = data.OwnerInfo.Address
		dob = data.OwnerInfo.DateOfBirth
		nin = data.OwnerInfo.NIN
		bvn = data.OwnerInfo.BVN
		gender = data.OwnerInfo.Gender

		business := models.Business{
			UserID:             u.ID,
			Name:               data.Name,
			RegistrationNumber: data.RegistrationNumber,
			Type:               data.BusinessType,
			Industry:           data.Industry,
			Website:            data.Website,
		}
		if err := tx.Create(&business).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save business info: " + err.Error()})
			return
		}
	} else {
		data := validatedBody.(*validators.IndividualCompleteAccountDto)
		email = data.Email
		firstName = data.FirstName
		lastName = data.LastName
		middleName = data.MiddleName
		address = data.Address
		dob = data.DateOfBirth
		nin = data.NIN
		bvn = data.BVN
		gender = data.Gender
	}

	// Common updates for both types
	person := models.Person{
		UserID:      u.ID,
		FirstName:   firstName,
		LastName:    lastName,
		MiddleName:  middleName,
		Address:     address,
		DateOfBirth: dob,
		Gender:      gender,
	}
	if err := tx.Create(&person).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save personal info: " + err.Error()})
		return
	}

	salt := os.Getenv("NIN_HASH_SALT")
	updates := map[string]interface{}{
		"email":          email,
		"hashed_nin":     utils.HashNIN(nin, salt),
		"status":         "active",
		"is_first_time":  true,
		"phone_verified": true, // Since they verified via OTP to get here
	}

	if err := tx.Model(&u).Updates(updates).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update user status: " + err.Error()})
		return
	}

	var businessName string
	if u.AccountType == "business" {
		businessName = validatedBody.(*validators.BusinessCompleteAccountDto).Name
	}

	// Create wallet for all accounts (Synchronously as requested)
	walletClient, err := walletService.NewWalletService(constants.WALLET_SERVICE_ADDR)
	if err != nil {
		tx.Rollback()
		log.Printf("[CompleteAccount] failed to connect to wallet service: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to connect to wallet service. Account not created."})
		return
	}
	defer walletClient.Close()

	ctx, cancel := context.WithTimeout(context.Background(), 45*time.Second) // Squad can be slow
	defer cancel()

	log.Printf("[CompleteAccount] calling CreateWalletForUser at %s", constants.WALLET_SERVICE_ADDR)
	resp, err := walletClient.CreateWalletForUser(ctx, &walletpb.CreateWalletRequest{
		Firstname:    firstName,
		Middlename:   middleName,
		Lastname:     lastName,
		Nin:          nin,
		DateOfBirth:  dob,
		Bvn:          bvn,
		Phone:        u.Phone,
		Email:        email,
		Gender:       gender,
		UserId:       u.UID,
		AccountType:  u.AccountType,
		BusinessName: businessName,
		Address:      address,
	}, u.ID, u.Phone)

	if err != nil {
		tx.Rollback()
		log.Printf("[CompleteAccount] wallet creation failed: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Wallet creation failed: " + err.Error() + ". Account registration rolled back."})
		return
	}

	if err := tx.Commit().Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to finalize account: " + err.Error()})
		return
	}

	log.Printf("[CompleteAccount] wallet created successfully: %s", resp.AccountNo)

	c.JSON(http.StatusOK, gin.H{
		"message": "Account completed successfully",
		"data": gin.H{
			"type":      u.AccountType,
			"firstName": firstName,
			"lastName":  lastName,
			"email":     email,
			"accountNo": resp.AccountNo,
		},
	})

	log.Printf("[CompleteAccount] completed successfully userID=%d durationMs=%d", u.ID, time.Since(start).Milliseconds())
}
