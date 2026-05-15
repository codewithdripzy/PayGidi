package controllers

import (
	"fmt"
	"net/http"
	"time"

	payGidiErrors "github.com/PayGidi/AccountService/core/interfaces/errors"
	"github.com/PayGidi/AccountService/models"
	userService "github.com/PayGidi/AccountService/services/user"
	walletService "github.com/PayGidi/AccountService/services/wallet"
	"github.com/PayGidi/AccountService/utils"
	"github.com/PayGidi/AccountService/validators"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// VerifyEmail godoc
// @Summary Verify email OTP
// @Description Verify the OTP sent to the user's email address.
// @Tags Auth
// @Accept json
// @Produce json
// @Param body body validators.VerifyEmailDto true "Email verification data"
// @Success 200 {object} map[string]interface{} "Email verified successfully"
// @Failure 400 {object} map[string]interface{} "Invalid OTP or expired"
// @Failure 404 {object} map[string]interface{} "User or OTP not found"
// @Router /auth/verify/email [post]
func VerifyEmail(c *gin.Context) {
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
			"code":  payGidiErrors.PHONE_OR_PASSWORD_MISSING,
			"error": "Please provide phone and password",
		})
		return
	}

	verifyData, ok := validatedBody.(*validators.VerifyEmailDto)
	if !ok {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":  payGidiErrors.INVALID_REQUEST_BODY,
			"error": "Email or OTP is not valid",
		})
		return
	}

	exists, data, err := userService.EmailExists(db.(*gorm.DB), verifyData.Email)

	// handle error
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
			"error": "An error occurred: " + err.Error() + " Please try again later or contact support if the issue persists.",
		})
		return
	}

	// handle user not found
	if !exists || data == nil {
		c.JSON(http.StatusNotFound, gin.H{
			"code":  payGidiErrors.EMAIL_NOT_FOUND,
			"error": "No account found with this email address, Try registering first",
		})
		return
	}

	// check for the OTP
	if len(data.OTPs) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":  payGidiErrors.OTP_NOT_FOUND,
			"error": "Incorrect OTP, Perhaps you have not requested an OTP yet, Please request a new OTP",
		})
		return
	}

	// check if the OTP exists and is not expired
	otp, err := userService.GetOTPByCode(db.(*gorm.DB), data.ID, verifyData.Code, verifyData.ForWhat, "email")

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
			"error": "An error occurred while fetching the OTP: " + err.Error() + " Please try again later or contact support if the issue persists.",
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

	// check if the OTP is expired
	if otp.ExpiresAt.Before(time.Now()) {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":  payGidiErrors.EXPIRED_TOKEN,
			"error": "OTP has expired, Please request a new OTP",
		})
		return
	}

	// check if the OTP is verified
	if otp.Verified {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":  payGidiErrors.OTP_ALREADY_VERIFIED,
			"error": "OTP has already been used, OTP has expired, Please request a new OTP",
		})
		return
	}

	// verify the OTP
	if otp.Code != verifyData.Code {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":  payGidiErrors.INVALID_CREDENTIALS,
			"error": "Invalid OTP, Please try again",
		})
		return
	}

	// mark the OTP as verified
	otp.Verified = true
	otp.ExpiresAt = time.Now() // Set the expiration time to now to prevent reuse

	if err := userService.UpdateOTP(db.(*gorm.DB), otp.UserID, otp, "email"); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
			"error": "Failed to verify OTP: " + err.Error() + " Please try again later or contact support if the issue persists.",
		})
		return
	}

	// check forWhat
	if otp.ForWhat != "completeRegister" {
		// update the user's phone verification status
		if err := db.(*gorm.DB).Model(&models.User{}).Where("id = ?", data.ID).Update("phone_verified", true).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
				"error": "Failed to update phone verification status: " + err.Error(),
			})
			return
		}
	}

	// generate JWT tokens for the user
	token, refreshToken, err := utils.GenerateJWTtokens(data.ID, data.Email)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
			"error": "Failed to generate tokens: " + err.Error() + " Please try again later or contact support if the issue persists.",
		})
		return
	}

	message := "Welcome back 👋🏽, " + data.Person.FirstName
	if data.IsFirstTime {
		message = "Welcome to SpiritPay! Please change your password to continue."

		data.IsFirstTime = false // Update the user's first-time login status
		if err := db.(*gorm.DB).Model(&models.User{}).Where("id = ?", data.ID).Update("is_first_time", false).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
				"error": "Something went wrong, " + err.Error(),
			})
			return
		}
	}

	utils.SendUserNotification(
		data.ID,
		"Email Verified",
		"Your email verification was completed successfully.",
		"in_app",
		data.Email,
		"security",
	)

	// Send a login notification email to the user
	// if err := utils.SendEmail(data.Email, "Login Notification", message); err != nil {
	// 	c.JSON(http.StatusInternalServerError, gin.H{
	// 		"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
	// 		"error": "Failed to send email notification: " + err.Error() + " Please try again later or contact support if the issue persists.",
	// 	})
	// 	return
	// }

	// If the last login was more than 24 hours ago and two factor auth is enabled, send an OTP to the user's phone
	if data.AuthInfo.LastLoginAt.Before(time.Now().Add(-24*time.Hour)) && data.TwoFactorEnabled {
		otp := utils.GenerateOTPCode(5)

		// add a new OTP to the user's auth info
		newOTP := models.OTP{
			Code:      otp,
			UserID:    data.ID,
			ForWhat:   "login",
			Via:       "sms",
			Verified:  false,
			ExpiresAt: time.Now().Add(5 * time.Minute), // OTP expires in 5 minutes
		}

		// Save the OTP to the database
		if err := userService.AddOTP(db.(*gorm.DB), data, &newOTP); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
				"error": "Failed to save OTP: " + err.Error() + " Please try again later or contact support if the issue persists.",
			})
			return
		}

		// Send the OTP to the user's phone
		// if err := utils.SendSMS(data.Phone, "Your OTP code is: "+otp); err != nil {
		// 	c.JSON(http.StatusInternalServerError, gin.H{
		// 		"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
		// 		"error": "Failed to send OTP: " + err.Error() + " Please try again later or contact support if the issue persists.",
		// 	})
		// 	return
		// }

		// print the OTP to the console for now
		fmt.Println("Your OTP code is:", otp)

		utils.SendUserNotification(
			data.ID,
			"Two-Factor Authentication OTP",
			"An OTP has been generated for your login verification.",
			"sms",
			data.Phone,
			"otp",
		)

		// Update the user's last login time and OTP in the database
		if err := userService.UpdateUserLastLogin(db.(*gorm.DB), data.ID); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
				"error": "Failed to update last login time: " + err.Error() + " Please try again later or contact support if the issue persists.",
			})
			return
		}

		// send a response indicating that an OTP has been sent
		c.JSON(http.StatusOK, gin.H{
			"message": "An OTP has been sent to your email. Please verify to continue.",
			"data": gin.H{
				"createdAt":      data.CreatedAt,
				"firstName":      data.Person.FirstName,
				"lastName":       data.Person.LastName,
				"userId":         data.UID,
				"phone":          data.Phone,
				"email":          data.Email,
				"lastLoginAt":    data.AuthInfo.LastLoginAt,
				"requiredAction": "twoFactorAuth",
			},
		})
	}

	// If the login is successful, return a success response with the user data and tokens
	c.JSON(http.StatusOK, gin.H{
		"message": message,
		"data": gin.H{
			"createdAt":    data.CreatedAt,
			"userId":       data.UID,
			"firstName":    data.Person.FirstName,
			"lastName":     data.Person.LastName,
			"phone":        data.Phone,
			"email":        data.Email,
			"lastLoginAt":  data.AuthInfo.LastLoginAt,
			"refreshToken": refreshToken,
			"token":        token,
			"updatedAt":    data.UpdatedAt,
		},
	})
}

// VerifyNIN godoc
// @Summary Verify NIN
// @Description Verify a user's National Identification Number (NIN).
// @Tags Auth
// @Accept json
// @Produce json
// @Param body body validators.VerifyNINDto true "NIN data"
// @Success 200 {object} map[string]interface{} "NIN verified successfully"
// @Failure 400 {object} map[string]interface{} "Invalid NIN"
// @Failure 502 {object} map[string]interface{} "Service error"
// @Router /auth/verify/nin [post]
func VerifyNIN(c *gin.Context) {
	fmt.Println("[VerifyNIN][account] request received")

	validatedBody, exists := c.Get("validatedBody")
	if !exists {
		fmt.Println("[VerifyNIN][account] validatedBody missing in context")
		c.JSON(http.StatusBadRequest, gin.H{
			"code":  payGidiErrors.INVALID_REQUEST_BODY,
			"error": "Invalid request body",
		})
		return
	}

	dto, ok := validatedBody.(*validators.VerifyNINDto)
	if !ok {
		fmt.Println("[VerifyNIN][account] validatedBody has unexpected type")
		c.JSON(http.StatusBadRequest, gin.H{
			"code":  payGidiErrors.INVALID_REQUEST_BODY,
			"error": "Invalid request body",
		})
		return
	}

	fmt.Println("[VerifyNIN][account] calling wallet service with NIN length:", len(dto.NIN))

	isValid, errMsg := walletService.CheckNINValidity(c.Request.Context(), dto.NIN)
	if errMsg != nil {
		fmt.Println("[VerifyNIN][account] wallet service returned error:", *errMsg)
		c.JSON(http.StatusBadGateway, gin.H{
			"code":  payGidiErrors.VFD_SERVICE_ERROR,
			"error": *errMsg,
		})
		return
	}

	fmt.Println("NIN validity result:", isValid)

	if !isValid {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":  payGidiErrors.INVALID_NIN,
			"error": "The provided NIN is invalid. Please check the number and try again.",
		})
		return
	}

	// // Update the user's NIN verification status in the database
	// if err := userService.UpdateUserNINVerification(db.(*gorm.DB), userID, true); err != nil {
	// 	c.JSON(http.StatusInternalServerError, gin.H{
	// 		"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
	// 		"error": "Failed to update NIN verification status: " + err.Error() + " Please try again later or contact support if the issue persists.",
	// 	})
	// 	return
	// }

	// utils.SendUserNotification(
	// 	userID,
	// 	"NIN Verified",
	// 	"Your NIN verification was completed successfully.",
	// 	"in_app",
	// 	"",
	// 	"security",
	// )

	c.JSON(http.StatusOK, gin.H{
		"code":    payGidiErrors.SUCCESS,
		"message": "NIN verified successfully",
	})
}

// VerifyBVNImage godoc
// @Summary Verify BVN Image
// @Description Verify a user's face image against their BVN record.
// @Tags Auth
// @Accept json
// @Produce json
// @Param body body validators.VerifyBVNImageDto true "BVN and Image data"
// @Success 200 {object} map[string]interface{} "BVN image verified successfully"
// @Failure 400 {object} map[string]interface{} "Image mismatch"
// @Failure 502 {object} map[string]interface{} "Service error"
// @Router /auth/verify/bvn-image [post]
func VerifyBVNImage(c *gin.Context) {
	validatedBody, exists := c.Get("validatedBody")
	if !exists {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":  payGidiErrors.INVALID_REQUEST_BODY,
			"error": "Invalid request body",
		})
		return
	}

	dto, ok := validatedBody.(*validators.VerifyBVNImageDto)
	if !ok {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":  payGidiErrors.INVALID_REQUEST_BODY,
			"error": "Invalid request body",
		})
		return
	}

	matched, errMsg := walletService.VerifyBVNImage(c.Request.Context(), dto.BVN, dto.Base64Image)
	if errMsg != nil {
		c.JSON(http.StatusBadGateway, gin.H{
			"code":  payGidiErrors.VFD_SERVICE_ERROR,
			"error": *errMsg,
		})
		return
	}

	if !matched {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":  payGidiErrors.INVALID_NIN,
			"error": "Face image does not match BVN record.",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    payGidiErrors.SUCCESS,
		"message": "BVN image verified successfully",
	})
}
