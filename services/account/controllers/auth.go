package controllers

import (
	"fmt"
	"net/http"
	"os"
	"time"

	payGidiErrors "github.com/PayGidi/AccountService/core/interfaces/errors"
	"github.com/PayGidi/AccountService/models"
	userService "github.com/PayGidi/AccountService/services/user"
	"github.com/PayGidi/AccountService/utils"
	"github.com/PayGidi/AccountService/validators"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// Auth godoc
// @Summary Initiate authentication
// @Description Initiate authentication (registration or login) via phone number. Sends an OTP.
// @Tags Auth
// @Accept json
// @Produce json
// @Param body body validators.AuthDto true "Authentication data"
// @Success 200 {object} map[string]interface{} "OTP sent successfully"
// @Failure 400 {object} map[string]interface{} "Invalid request"
// @Failure 404 {object} map[string]interface{} "User not found (if accountType missing)"
// @Failure 409 {object} map[string]interface{} "User already exists (if accountType provided)"
// @Failure 429 {object} map[string]interface{} "Too many OTP requests"
// @Router /auth [post]
func Auth(c *gin.Context) {
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
			"code":  payGidiErrors.PHONE_NUMBER_MISSING,
			"error": "Please provide phone number",
		})
		return
	}

	authData, ok := validatedBody.(*validators.AuthDto)
	if !ok {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":  payGidiErrors.INVALID_REQUEST_BODY,
			"error": "Phone Number is not valid",
		})
		return
	}

	exists, data, err := userService.PhoneExists(db.(*gorm.DB), authData.Phone)

	// handle error
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
			"error": "An error occurred: " + err.Error() + " Please try again later or contact support if the issue persists.",
		})
		return
	}

	// handle user existence and account type
	if !exists || data == nil {
		if authData.AccountType == "" {
			c.JSON(http.StatusNotFound, gin.H{
				"code":  payGidiErrors.USER_NOT_FOUND,
				"error": "Account not found. Please provide an account type to register.",
			})
			return
		}

		// If user doesn't exist, this is a registration initiation
		uid := utils.GenerateUID()
		data = &models.User{
			UID:         uid,
			Phone:       authData.Phone,
			Username:    "user_" + uid, // Temporary unique username
			AccountType: authData.AccountType,
			IsFirstTime: true,
			Status:      "pending",
		}

		if err := db.(*gorm.DB).Create(data).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
				"error": "Failed to initiate registration: " + err.Error(),
			})
			return
		}

		// Also create default AuthInfo
		authInfo := models.AuthInfo{
			UserID: data.ID,
		}
		if err := db.(*gorm.DB).Create(&authInfo).Error; err != nil {
			fmt.Printf("Failed to create default auth info: %v\n", err)
		}
		data.AuthInfo = authInfo
	} else {
		if authData.AccountType != "" {
			c.JSON(http.StatusConflict, gin.H{
				"code":  payGidiErrors.USER_ALREADY_EXISTS,
				"error": "An account with this phone number already exists. Please login instead.",
			})
			return
		}
	}

	// Rate limiting check for OTP requests
	if data.AuthInfo.OTPCooldownUntil != nil && data.AuthInfo.OTPCooldownUntil.After(time.Now()) {
		ttl := int(time.Until(*data.AuthInfo.OTPCooldownUntil).Seconds())
		c.JSON(http.StatusTooManyRequests, gin.H{
			"code":  payGidiErrors.OTP_REQUEST_LIMIT_REACHED,
			"error": fmt.Sprintf("Too many OTP requests. Please try again after %d seconds.", ttl),
			"data": gin.H{
				"ttl": ttl,
			},
		})
		return
	}

	// Increment the OTP request count
	currentCount := data.AuthInfo.OTPRequestCount
	if data.AuthInfo.OTPCooldownUntil != nil && data.AuthInfo.OTPCooldownUntil.Before(time.Now()) {
		currentCount = 0 // Reset count if cooldown has passed
	}

	if currentCount >= 5 {
		cooldown := time.Now().Add(5 * time.Minute)
		if err := userService.UpdateOTPCooldown(db.(*gorm.DB), data.ID, 0, &cooldown); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
				"error": "Failed to update OTP cooldown: " + err.Error(),
			})
			return
		}
		c.JSON(http.StatusTooManyRequests, gin.H{
			"code":  payGidiErrors.OTP_REQUEST_LIMIT_REACHED,
			"error": "Too many OTP requests. Please try again after 5 minutes.",
			"data": gin.H{
				"ttl": 300,
			},
		})
		return
	}

	if err := userService.UpdateOTPCooldown(db.(*gorm.DB), data.ID, currentCount+1, nil); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
			"error": "Failed to update OTP request count: " + err.Error(),
		})
		return
	}

	// Generate an OTP for verification
	otp := utils.GenerateOTPCode(5)

	// add a new OTP to the user's auth info
	newOTP := models.OTP{
		UserID:    data.ID,
		Code:      otp,
		ForWhat:   "login",
		Via:       "sms",
		Verified:  false,
		ExpiresAt: time.Now().Add(10 * time.Minute), // OTP expires in 10 minutes
	}

	// Save the OTP to the database
	if err := userService.AddOTP(db.(*gorm.DB), data, &newOTP); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
			"error": "Failed to save OTP: " + err.Error() + " Please try again later or contact support if the issue persists.",
		})
		return
	}

	// print the OTP to the console in development enviroment
	if os.Getenv("APP_ENV") == "development" {
		fmt.Println("Your login OTP code is:", otp)
	}

	// send the OTP to the user's phone number
	utils.SendUserNotification(
		data.ID,
		"Login Verification OTP",
		fmt.Sprintf("Your OTP code is %s. It expires in 10 minutes.", otp),
		"sms",
		data.Phone,
		"otp",
	)

	// send a response indicating that an OTP has been sent
	c.JSON(http.StatusOK, gin.H{
		"message": "An OTP has been sent to your phone. Please verify to continue.",
		"data": gin.H{
			"createdAt":        data.CreatedAt,
			"firstName":        data.Person.FirstName,
			"lastName":         data.Person.LastName,
			"phone":            data.Phone,
			"lastLoginAt":      data.AuthInfo.LastLoginAt,
			"requiredAction":   "login",
			"requiredActionAt": time.Now().Add(10 * time.Minute),
		},
	})
}

// VerifyAuthOTP godoc
// @Summary Verify authentication OTP
// @Description Verify the OTP sent to the user's phone number and return JWT tokens.
// @Tags Auth
// @Accept json
// @Produce json
// @Param body body validators.VerifyAuthOtpDto true "OTP verification data"
// @Success 200 {object} map[string]interface{} "Login successful"
// @Failure 400 {object} map[string]interface{} "Invalid OTP or expired"
// @Failure 404 {object} map[string]interface{} "OTP or User not found"
// @Router /auth/verify [post]
func VerifyAuthOTP(c *gin.Context) {

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
			"code":  payGidiErrors.INVALID_REQUEST_BODY,
			"error": "Please provide phone number and OTP",
		})
		return
	}

	verifyData, ok := validatedBody.(*validators.VerifyAuthOtpDto)
	if !ok {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":  payGidiErrors.INVALID_REQUEST_BODY,
			"error": "Invalid request data",
		})
		return
	}

	exists, data, err := userService.PhoneExists(db.(*gorm.DB), verifyData.Phone)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
			"error": "An error occurred: " + err.Error(),
		})
		return
	}

	if !exists || data == nil {
		c.JSON(http.StatusNotFound, gin.H{
			"code":  payGidiErrors.PHONE_NOT_FOUND,
			"error": "No account found with this phone number",
		})
		return
	}

	// Fetch the OTP from the database
	otp, err := userService.GetOTPByCode(db.(*gorm.DB), data.ID, verifyData.Code, "login", "sms")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
			"error": "An error occurred while fetching the OTP: " + err.Error(),
		})
		return
	}

	if otp == nil {
		c.JSON(http.StatusNotFound, gin.H{
			"code":  payGidiErrors.OTP_NOT_FOUND,
			"error": "Invalid OTP, Please request a new OTP",
		})
		return
	}

	if otp.ExpiresAt.Before(time.Now()) {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":  payGidiErrors.EXPIRED_TOKEN,
			"error": "OTP has expired, Please request a new OTP",
		})
		return
	}

	if otp.Verified {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":  payGidiErrors.OTP_ALREADY_VERIFIED,
			"error": "OTP has already been used",
		})
		return
	}

	// Mark the OTP as verified
	otp.Verified = true
	otp.ExpiresAt = time.Now()

	if err := userService.UpdateOTP(db.(*gorm.DB), otp.UserID, otp, "sms"); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
			"error": "Failed to verify OTP: " + err.Error(),
		})
		return
	}

	// Update phone verified status
	if err := db.(*gorm.DB).Model(data).Update("phone_verified", true).Error; err != nil {
		fmt.Printf("Failed to update phone verification status: %v\n", err)
	}

	// Generate JWT tokens
	token, refreshToken, err := utils.GenerateJWTtokens(data.ID, data.Email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
			"error": "Failed to generate tokens: " + err.Error(),
		})
		return
	}

	// Set auth token in cookie for web clients
	secure := os.Getenv("APP_ENV") == "production"
	c.SetSameSite(http.SameSiteLaxMode)
	c.SetCookie("auth_token", token, 3600*24*7, "/", "", secure, true)

	// Update last login time
	if err := userService.UpdateUserLastLogin(db.(*gorm.DB), data.ID); err != nil {
		// Log error but don't fail the request
		fmt.Printf("Failed to update last login time: %v\n", err)
	}

	// Reset OTP request count on successful login
	if err := userService.UpdateOTPCooldown(db.(*gorm.DB), data.ID, 0, nil); err != nil {
		fmt.Printf("Failed to reset OTP request count: %v\n", err)
	}

	utils.SendUserNotification(
		data.ID,
		"Login Successful",
		"You have successfully logged into your account.",
		"in_app",
		data.Email,
		"security",
	)

	message := "Login successful 👋🏽"
	if data.Person.FirstName != "" {
		message += ", " + data.Person.FirstName
	}

	c.JSON(http.StatusOK, gin.H{
		"message": message,
		"data": gin.H{
			"createdAt":       data.CreatedAt,
			"userId":          data.UID,
			"firstName":       data.Person.FirstName,
			"lastName":        data.Person.LastName,
			"phone":           data.Phone,
			"email":           data.Email,
			"accountType":     data.AccountType,
			"needsOnboarding": data.Status == "pending",
			"lastLoginAt":     data.AuthInfo.LastLoginAt,
			"refreshToken":    refreshToken,
			"token":           token,
			"updatedAt":       data.UpdatedAt,
		},
	})
}

// RegisterBiometric godoc
// @Summary Enable biometric authentication
// @Description Link a biometric ID to the authenticated user's account.
// @Tags Auth
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param body body validators.RegisterBiometricDto true "Biometric registration data"
// @Success 200 {object} map[string]interface{} "Biometrics enabled successfully"
// @Router /auth/biometric/register [post]
func RegisterBiometric(c *gin.Context) {
	db, _ := c.Get("db")
	user, _ := c.Get("user")
	currentUser := user.(*models.User)

	validatedBody, _ := c.Get("validatedBody")
	data := validatedBody.(*validators.RegisterBiometricDto)

	if err := db.(*gorm.DB).Model(currentUser).Updates(map[string]interface{}{
		"biometric_enabled": true,
		"biometric_id":      data.BiometricID,
	}).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
			"error": "Failed to enable biometrics: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Biometric authentication enabled successfully",
	})
}

// BiometricAuth godoc
// @Summary Authenticate via biometrics
// @Description Exchange a biometric ID for a new JWT token.
// @Tags Auth
// @Accept json
// @Produce json
// @Param body body validators.BiometricAuthDto true "Biometric authentication data"
// @Success 200 {object} map[string]interface{} "Login successful"
// @Router /auth/biometric [post]
func BiometricAuth(c *gin.Context) {
	db, _ := c.Get("db")
	validatedBody, _ := c.Get("validatedBody")
	authData := validatedBody.(*validators.BiometricAuthDto)

	var user models.User
	if err := db.(*gorm.DB).Preload("Person").Preload("AuthInfo").Where("phone = ? AND biometric_id = ? AND biometric_enabled = ?", authData.Phone, authData.BiometricID, true).First(&user).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusUnauthorized, gin.H{
				"code":  payGidiErrors.UNAUTHORIZED_ACCESS,
				"error": "Biometric authentication failed or not enabled for this device",
			})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{
				"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
				"error": "An error occurred: " + err.Error(),
			})
		}
		return
	}

	// Generate JWT tokens
	token, refreshToken, err := utils.GenerateJWTtokens(user.ID, user.Email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
			"error": "Failed to generate tokens: " + err.Error(),
		})
		return
	}

	// Update last login time
	userService.UpdateUserLastLogin(db.(*gorm.DB), user.ID)

	c.JSON(http.StatusOK, gin.H{
		"message": "Biometric login successful 👋🏽",
		"data": gin.H{
			"userId":       user.UID,
			"firstName":    user.Person.FirstName,
			"lastName":     user.Person.LastName,
			"phone":        user.Phone,
			"email":        user.Email,
			"token":        token,
			"refreshToken": refreshToken,
		},
	})
}
