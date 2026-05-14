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

func VerifyPhone(c *gin.Context) {
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

	verifyData, ok := validatedBody.(*validators.VerifyPhoneDto)
	if !ok {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":  payGidiErrors.INVALID_REQUEST_BODY,
			"error": "Phone Number or OTP is not valid",
		})
		return
	}

	exists, data, err := userService.PhoneExists(db.(*gorm.DB), verifyData.Phone)

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
			"code":  payGidiErrors.PHONE_NOT_FOUND,
			"error": "No account found with this phone number, Try registering first",
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
	otp, err := userService.GetOTPByCode(db.(*gorm.DB), data.ID, verifyData.Code, verifyData.ForWhat, "sms")

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

	if err := userService.UpdateOTP(db.(*gorm.DB), otp.UserID, otp, "sms"); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
			"error": "Failed to verify OTP: " + err.Error() + " Please try again later or contact support if the issue persists.",
		})
		return
	}

	// check forWhat
	if otp.ForWhat != "completeRegister" {
		// update the user's phone verification status
		if err := userService.UpdateUserPhoneVerification(db.(*gorm.DB), data.ID, true); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
				"error": "Failed to update phone verification status: " + err.Error() + " Please try again later or contact support if the issue persists.",
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
		if err := userService.UpdateUserFirstTimeLogin(db.(*gorm.DB), data.ID, false); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
				"error": "Something went wrong, " + err.Error() + " Please try again later or contact support if the issue persists.",
			})
			return
		}
	}

	// Send a login notification email to the user
	// if err := utils.SendEmail(data.Email, "Login Notification", message); err != nil {
	// 	c.JSON(http.StatusInternalServerError, gin.H{
	// 		"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
	// 		"error": "Failed to send email notification: " + err.Error() + " Please try again later or contact support if the issue persists.",
	// 	})
	// 	return
	// }

	// If the user account is not verified, send an OTP to the user's phone
	// if !data.PhoneVerified {
	// 	otp := utils.GenerateOTPCode(5)
	// 	// add a new OTP to the user's auth info
	// 	newOTP := models.OTP{
	// 		Code:      otp,
	// 		UserID:    data.ID,
	// 		ForWhat:   "completeRegister",
	// 		Via:       "sms",
	// 		Verified:  false,
	// 		ExpiresAt: time.Now().Add(5 * time.Minute), // OTP expires in 5 minutes
	// 	}

	// 	// Save the OTP to the database
	// 	if err := userService.AddOTP(db.(*gorm.DB), data, &newOTP); err != nil {
	// 		c.JSON(http.StatusInternalServerError, gin.H{
	// 			"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
	// 			"error": "Failed to save OTP: " + err.Error() + " Please try again later or contact support if the issue persists.",
	// 		})
	// 		return
	// 	}

	// 	// Send the OTP to the user's phone
	// 	// if err := utils.SendSMS(data.Phone, "Your OTP code is: "+otp); err != nil {
	// 	// 	c.JSON(http.StatusInternalServerError, gin.H{
	// 	// 		"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
	// 	// 		"error": "Failed to send OTP: " + err.Error() + " Please try again later or contact support if the issue persists.",
	// 	// 	})
	// 	// 	return
	// 	// }

	// 	// print the OTP to the console for now
	// 	fmt.Println("Your OTP code is:", otp)

	// 	// Update the user's last login time and OTP in the database
	// 	if err := userService.UpdateUserLastLogin(db.(*gorm.DB), data.ID); err != nil {
	// 		c.JSON(http.StatusInternalServerError, gin.H{
	// 			"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
	// 			"error": "Failed to update last login time: " + err.Error() + " Please try again later or contact support if the issue persists.",
	// 		})
	// 		return
	// 	}

	// 	// send a response indicating that an OTP has been sent
	// 	c.JSON(http.StatusOK, gin.H{
	// 		"message": "An OTP has been sent to your phone. Please verify to continue.",
	// 		"data": gin.H{
	// 			"createdAt":      data.CreatedAt,
	// 			"firstName":      data.Person.FirstName,
	// 			"lastName":       data.Person.LastName,
	// 			"phone":          data.Phone,
	// 			"email":          data.Email,
	// 			"lastLoginAt":    data.AuthInfo.LastLoginAt,
	// 			"requiredAction": "completeRegister",
	// 		},
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
			"message": "An OTP has been sent to your phone. Please verify to continue.",
			"data": gin.H{
				"createdAt":      data.CreatedAt,
				"userId":         data.ID,
				"firstName":      data.Person.FirstName,
				"lastName":       data.Person.LastName,
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
		if err := userService.UpdateUserPhoneVerification(db.(*gorm.DB), data.ID, true); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
				"error": "Failed to update phone verification status: " + err.Error() + " Please try again later or contact support if the issue persists.",
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
		if err := userService.UpdateUserFirstTimeLogin(db.(*gorm.DB), data.ID, false); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
				"error": "Something went wrong, " + err.Error() + " Please try again later or contact support if the issue persists.",
			})
			return
		}
	}

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
