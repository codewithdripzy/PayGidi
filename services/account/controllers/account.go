package controllers

import (
	"log"
	"net/http"

	payGidiErrors "github.com/PayGidi/AccountService/core/interfaces/errors"
	"github.com/PayGidi/AccountService/models"
	"github.com/PayGidi/AccountService/services/wallet"
	"github.com/PayGidi/AccountService/utils"
	"github.com/PayGidi/AccountService/validators"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// GetAccountDetails godoc
// @Summary Get account details
// @Description Get the profile details of the authenticated user.
// @Tags Account
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Success 200 {object} map[string]interface{} "Account details"
// @Router /account [get]
func GetAccountDetails(c *gin.Context) {
	user, exists := c.Get("user")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"code":  payGidiErrors.UNAUTHORIZED_ACCESS,
			"error": "User not found in context",
		})
		return
	}

	currentUser := user.(*models.User)

	c.JSON(http.StatusOK, gin.H{
		"message": "Account details retrieved successfully",
		"data": gin.H{
			"userId":      currentUser.UID,
			"username":    currentUser.Username,
			"email":       currentUser.Email,
			"phone":       currentUser.Phone,
			"accountType": currentUser.AccountType,
			"status":      currentUser.Status,
			"person":      currentUser.Person,
			"isFirstTime": currentUser.IsFirstTime,
			"pinSet":      currentUser.Pin != "",
		},
	})
}

// SetPin godoc
// @Summary Set account PIN
// @Description Set a new PIN for the authenticated user. Only works if no PIN is currently set.
// @Tags Account
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param body body validators.SetPinDto true "PIN data"
// @Success 200 {object} map[string]interface{} "PIN set successfully"
// @Router /account/pin [post]
func SetPin(c *gin.Context) {
	db, _ := c.Get("db")
	user, _ := c.Get("user")
	currentUser := user.(*models.User)

	if currentUser.Pin != "" {
		c.JSON(http.StatusConflict, gin.H{
			"code":  payGidiErrors.INVALID_REQUEST_BODY,
			"error": "PIN already set. Use update PIN route instead.",
		})
		return
	}

	validatedBody, _ := c.Get("validatedBody")
	data := validatedBody.(*validators.SetPinDto)

	hashedPin, err := utils.HashPin(data.Pin)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
			"error": "Failed to secure PIN",
		})
		return
	}

	if err := db.(*gorm.DB).Model(currentUser).Update("pin", hashedPin).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
			"error": "Failed to save PIN",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "PIN set successfully",
	})
}

// UpdatePin godoc
// @Summary Update account PIN
// @Description Update the existing PIN for the authenticated user.
// @Tags Account
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param body body validators.UpdatePinDto true "PIN update data"
// @Success 200 {object} map[string]interface{} "PIN updated successfully"
// @Router /account/pin [put]
func UpdatePin(c *gin.Context) {
	db, _ := c.Get("db")
	user, _ := c.Get("user")
	currentUser := user.(*models.User)

	if currentUser.Pin == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":  payGidiErrors.INVALID_REQUEST_BODY,
			"error": "No PIN set. Use set PIN route instead.",
		})
		return
	}

	validatedBody, _ := c.Get("validatedBody")
	data := validatedBody.(*validators.UpdatePinDto)

	// Verify old PIN
	if !utils.VerifyPin(currentUser.Pin, data.OldPin) {
		c.JSON(http.StatusUnauthorized, gin.H{
			"code":  payGidiErrors.UNAUTHORIZED_ACCESS,
			"error": "Incorrect old PIN",
		})
		return
	}

	hashedPin, err := utils.HashPin(data.NewPin)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
			"error": "Failed to secure new PIN",
		})
		return
	}

	if err := db.(*gorm.DB).Model(currentUser).Update("pin", hashedPin).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
			"error": "Failed to update PIN",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "PIN updated successfully",
	})
}

// DeleteAccount godoc
// @Summary Delete account
// @Description Delete the authenticated user's account and all associated data.
// @Tags Account
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Success 200 {object} map[string]interface{} "Account deleted successfully"
// @Router /account [delete]
func DeleteAccount(c *gin.Context) {
	db := c.MustGet("db").(*gorm.DB)
	user, exists := c.Get("user")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"code":  payGidiErrors.UNAUTHORIZED_ACCESS,
			"error": "User not found in context",
		})
		return
	}

	currentUser := user.(*models.User)

	tx := db.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	// List of tables to delete from based on UserID (uint)
	userID := currentUser.ID
	uid := currentUser.UID

	tablesByUserID := []string{
		"account_persons",
		"account_kycs",
		"account_contact_info",
		"account_auth_info",
		"account_businesses",
		"account_sessions",
		"account_activities",
		"account_preferences",
		"account_otps",
		"wallet_accounts",
	}

	for _, table := range tablesByUserID {
		// Check if table exists before trying to delete from it to avoid errors if some services are not fully migrated
		if tx.Migrator().HasTable(table) {
			if err := tx.Exec("DELETE FROM "+table+" WHERE user_id = ?", userID).Error; err != nil {
				tx.Rollback()
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete data from " + table})
				return
			}
		}
	}

	// Delete from join tables
	joinTables := []string{"user_roles"}
	for _, table := range joinTables {
		if tx.Migrator().HasTable(table) {
			if err := tx.Exec("DELETE FROM "+table+" WHERE user_id = ?", userID).Error; err != nil {
				tx.Rollback()
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete from join table " + table})
				return
			}
		}
	}

	// Delete from tables where UserID is a string (using UID)
	tablesByUID := []string{
		"wallet_payments",
		"notifications",
	}

	for _, table := range tablesByUID {
		if tx.Migrator().HasTable(table) {
			if err := tx.Exec("DELETE FROM "+table+" WHERE user_id = ?", uid).Error; err != nil {
				tx.Rollback()
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete data from " + table})
				return
			}
		}
	}

	// Finally delete the user
	if err := tx.Unscoped().Delete(currentUser).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete user account"})
		return
	}

	if err := tx.Commit().Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to commit transaction"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Account and all associated data deleted successfully",
	})
}

// Me godoc
// @Summary Get current user
// @Description Fetch the profile details and associations of the authenticated user.
// @Tags Account
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Success 200 {object} responses.ApiResponse{data=map[string]interface{}} "Current user details with wallets"
// @Failure 401 {object} responses.ApiResponse "Unauthorized"
// @Failure 500 {object} responses.ApiResponse "Internal Server Error"
// @Router /me [get]
func Me(c *gin.Context) {
	log.Printf("Me controller called for path: %s", c.Request.URL.Path)
	dbVal, _ := c.Get("db")
	db := dbVal.(*gorm.DB)
	user, exists := c.Get("user")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"code":  payGidiErrors.UNAUTHORIZED_ACCESS,
			"error": "User not found in context",
		})
		return
	}

	currentUser := user.(models.User)

	// Preload associations
	var fullUser models.User
	if err := db.Preload("Person").Preload("Contact").Preload("AuthInfo").Preload("Preferences").Preload("Roles").First(&fullUser, currentUser.ID).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
			"error": "Failed to fetch user associations",
		})
		return
	}

	// Fetch wallets via gRPC
	walletClient, err := wallet.NewWalletService("")
	var wallets interface{}
	if err == nil {
		defer walletClient.Close()
		resp, err := walletClient.GetWalletsForUser(c.Request.Context(), currentUser.UID)
		if err == nil && resp.Success {
			wallets = resp.Wallets
		} else {
			log.Printf("[Me] failed to fetch wallets: %v", err)
		}
	} else {
		log.Printf("[Me] failed to create wallet service client: %v", err)
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "User details retrieved successfully",
		"data": gin.H{
			"user":    fullUser,
			"wallets": wallets,
		},
	})
}
