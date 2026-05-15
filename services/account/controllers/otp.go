package controllers

import (
	"fmt"
	"net/http"
	"time"

	payGidiErrors "github.com/PayGidi/AccountService/core/interfaces/errors"
	"github.com/PayGidi/AccountService/models"
	userService "github.com/PayGidi/AccountService/services/user"
	"github.com/PayGidi/AccountService/utils"
	"github.com/PayGidi/AccountService/validators"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// RequestOTP godoc
// @Summary Request OTP
// @Description Request an OTP to be sent via email or SMS.
// @Tags Auth
// @Accept json
// @Produce json
// @Param otpType path string true "OTP type (email or phone)"
// @Param body body validators.RequestOTPDto true "OTP request data"
// @Success 200 {object} map[string]interface{} "OTP sent successfully"
// @Failure 400 {object} map[string]interface{} "Invalid request"
// @Failure 404 {object} map[string]interface{} "User not found"
// @Router /auth/otp/request/{otpType} [post]
func RequestOTP(c *gin.Context) {
	db, exists := c.Get("db")
	if !exists {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
			"error": "Database connection not found",
		})
		return
	}

	validatedBody, exists := c.Get("validatedBody")
	if !exists {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":  payGidiErrors.PHONE_OR_PIN_MISSING,
			"error": "Please provide phone and PIN",
		})
		return
	}

	// check if the request type in the param is email or phone
	otpType := c.Param("otpType")
	if otpType != "email" && otpType != "phone" {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":  payGidiErrors.INVALID_REQUEST_BODY,
			"error": "Invalid OTP type, must be either 'email' or 'phone'",
		})
		return
	}

	verifyData, ok := validatedBody.(*validators.RequestOTPDto)
	if !ok {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":  payGidiErrors.INVALID_REQUEST_BODY,
			"error": "Phone Number or OTP is not valid",
		})
		return
	}

	if otpType == "phone" && verifyData.Phone == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":  payGidiErrors.PHONE_OR_PIN_MISSING,
			"error": "Phone number is required for phone OTP requests",
		})
		return
	}

	if otpType == "email" && verifyData.Email == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":  payGidiErrors.EMAIL_NOT_FOUND,
			"error": "Email is required for email OTP requests",
		})
		return
	}

	if verifyData.ForWhat == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":  payGidiErrors.VALIDATION_ERROR,
			"error": "ForWhat field is required for phone OTP requests",
		})
		return
	}

	if otpType == "phone" {
		// Check if the phone number exists in the database
		exists, data, err := userService.PhoneExists(db.(*gorm.DB), verifyData.Phone)

		// handle error
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
				"error": "An error occurred: " + err.Error() + " Please try again later or contact support if the issue persists.",
			})
			return
		}

		// If the user account is not found
		if !exists || data == nil {
			c.JSON(http.StatusNotFound, gin.H{
				"code":  payGidiErrors.PHONE_NOT_FOUND,
				"error": "No account found with this phone number",
			})
			return
		}

		// Rate limiting check
		if data.AuthInfo.OTPCooldownUntil != nil && data.AuthInfo.OTPCooldownUntil.After(time.Now()) {
			ttl := int(time.Until(*data.AuthInfo.OTPCooldownUntil).Seconds())
			c.JSON(http.StatusTooManyRequests, gin.H{
				"code":  payGidiErrors.OTP_REQUEST_LIMIT_REACHED,
				"error": fmt.Sprintf("Too many OTP requests. Please try again after %d seconds.", ttl),
				"data": gin.H{"ttl": ttl},
			})
			return
		}

		currentCount := data.AuthInfo.OTPRequestCount
		if data.AuthInfo.OTPCooldownUntil != nil && data.AuthInfo.OTPCooldownUntil.Before(time.Now()) {
			currentCount = 0
		}

		if currentCount >= 5 {
			cooldown := time.Now().Add(5 * time.Minute)
			userService.UpdateOTPCooldown(db.(*gorm.DB), data.ID, 0, &cooldown)
			c.JSON(http.StatusTooManyRequests, gin.H{
				"code":  payGidiErrors.OTP_REQUEST_LIMIT_REACHED,
				"error": "Too many OTP requests. Please try again after 5 minutes.",
				"data": gin.H{"ttl": 300},
			})
			return
		}

		// Increment count
		userService.UpdateOTPCooldown(db.(*gorm.DB), data.ID, currentCount+1, nil)

		// Generate a new OTP code
		code := utils.GenerateOTPCode(5)

		// Save the OTP to the database
		newOTP := models.OTP{
			UserID:    data.ID,
			Code:      code,
			ForWhat:   verifyData.ForWhat,
			Via:       "sms",
			Verified:  false,
			ExpiresAt: time.Now().Add(10 * time.Minute),
		}

		if err := db.(*gorm.DB).Create(&newOTP).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
				"error": "Failed to request OTP: " + err.Error(),
			})
			return
		}

		// print the OTP to the console for now
		fmt.Println("Your OTP code is:", code)

		utils.SendUserNotification(
			data.ID,
			"OTP Requested",
			"A new OTP has been requested for your account.",
			"sms",
			data.Phone,
			"otp",
		)

		c.JSON(http.StatusOK, gin.H{
			"message": "An OTP has been sent to your phone. Please verify to continue.",
			"data": gin.H{
				"createdAt":      data.CreatedAt,
				"firstName":      data.Person.FirstName,
				"lastName":       data.Person.LastName,
				"phone":          data.Phone,
				"email":          data.Email,
				"lastLoginAt":    data.AuthInfo.LastLoginAt,
				"requiredAction": verifyData.ForWhat,
			},
		})
		return
	} else if otpType == "email" {
		exists, data, err := userService.EmailExists(db.(*gorm.DB), verifyData.Email)

		// handle error
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
				"error": "An error occurred: " + err.Error(),
			})
			return
		}

		// If the user account is not found
		if !exists || data == nil {
			c.JSON(http.StatusNotFound, gin.H{
				"code":  payGidiErrors.EMAIL_NOT_FOUND,
				"error": "No account found with this email address",
			})
			return
		}

		// Rate limiting check
		if data.AuthInfo.OTPCooldownUntil != nil && data.AuthInfo.OTPCooldownUntil.After(time.Now()) {
			ttl := int(time.Until(*data.AuthInfo.OTPCooldownUntil).Seconds())
			c.JSON(http.StatusTooManyRequests, gin.H{
				"code":  payGidiErrors.OTP_REQUEST_LIMIT_REACHED,
				"error": fmt.Sprintf("Too many OTP requests. Please try again after %d seconds.", ttl),
				"data": gin.H{"ttl": ttl},
			})
			return
		}

		currentCount := data.AuthInfo.OTPRequestCount
		if data.AuthInfo.OTPCooldownUntil != nil && data.AuthInfo.OTPCooldownUntil.Before(time.Now()) {
			currentCount = 0
		}

		if currentCount >= 5 {
			cooldown := time.Now().Add(5 * time.Minute)
			userService.UpdateOTPCooldown(db.(*gorm.DB), data.ID, 0, &cooldown)
			c.JSON(http.StatusTooManyRequests, gin.H{
				"code":  payGidiErrors.OTP_REQUEST_LIMIT_REACHED,
				"error": "Too many OTP requests. Please try again after 5 minutes.",
				"data": gin.H{"ttl": 300},
			})
			return
		}

		// Increment count
		userService.UpdateOTPCooldown(db.(*gorm.DB), data.ID, currentCount+1, nil)

		// Generate a new OTP code
		code := utils.GenerateOTPCode(5)

		// Save the OTP to the database
		newOTP := models.OTP{
			UserID:    data.ID,
			Code:      code,
			ForWhat:   verifyData.ForWhat,
			Via:       "email",
			Verified:  false,
			ExpiresAt: time.Now().Add(10 * time.Minute),
		}

		if err := db.(*gorm.DB).Create(&newOTP).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
				"error": "An error occurred: " + err.Error(),
			})
			return
		}

		// print the OTP to the console for now
		fmt.Println("Your OTP code is:", code)

		utils.SendUserNotification(
			data.ID,
			"OTP Requested",
			"A new OTP has been requested for your account.",
			"email",
			data.Email,
			"otp",
		)

		c.JSON(http.StatusOK, gin.H{
			"message": "An OTP has been sent to your email. Please verify to continue.",
			"data": gin.H{
				"createdAt":      data.CreatedAt,
				"firstName":      data.Person.FirstName,
				"lastName":       data.Person.LastName,
				"phone":          data.Phone,
				"email":          data.Email,
				"lastLoginAt":    data.AuthInfo.LastLoginAt,
				"requiredAction": verifyData.ForWhat,
			},
		})
		return
	}
}
