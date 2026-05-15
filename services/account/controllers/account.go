package controllers

import (
	"net/http"

	payGidiErrors "github.com/PayGidi/AccountService/core/interfaces/errors"
	"github.com/PayGidi/AccountService/models"
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
			"userId":       currentUser.UID,
			"username":     currentUser.Username,
			"email":        currentUser.Email,
			"phone":        currentUser.Phone,
			"accountType":  currentUser.AccountType,
			"status":       currentUser.Status,
			"person":       currentUser.Person,
			"isFirstTime":  currentUser.IsFirstTime,
			"pinSet":       currentUser.Pin != "",
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
