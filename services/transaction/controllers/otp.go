package controllers

import (
	"fmt"
	"net/http"

	"github.com/PayGidi/AccountService/utils"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

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
			"code":  payGidiErrors.PHONE_OR_PASSWORD_MISSING,
			"error": "Please provide phone and password",
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
			"code":  payGidiErrors.PHONE_OR_PASSWORD_MISSING,
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

		// If the user account is not verified, send an OTP to the user's phone
		if !exists || data == nil {
			c.JSON(http.StatusNotFound, gin.H{
				"code":  payGidiErrors.PHONE_NOT_FOUND,
				"error": "No account found with this phone number, Try registering first",
			})
			return
		}

		hasReachLimit, err := userService.CheckOTPRequestLimit(db.(*gorm.DB), data.ID, verifyData.ForWhat, "email")

		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
				"error": "An error occurred: " + err.Error() + " Please try again later or contact support if the issue persists.",
			})
			return
		}

		if !hasReachLimit {
			c.JSON(http.StatusTooManyRequests, gin.H{
				"code":  payGidiErrors.OTP_REQUEST_LIMIT_REACHED,
				"error": "You have reached the maximum number of OTP requests. Please try again later.",
			})
			return
		}

		// Generate a new OTP code
		code := utils.GenerateOTPCode(5)

		// Request OTP via phone
		if _, err := userService.RequestNewOTPCode(db.(*gorm.DB), data.ID, code, verifyData.ForWhat, "sms"); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
				"error": "Failed to request OTP: " + err.Error() + " Please try again later or contact support if the issue persists.",
			})
			return
		}

		// Send the OTP to the user's phone
		// if err := utils.SendSMS(verifyData.Phone, "Your OTP code is: "+otp.Code); err != nil {
		// 	c.JSON(http.StatusInternalServerError, gin.H{
		// 		"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
		// 		"error": "Failed to send OTP: " + err.Error() + " Please try again later or contact support if the issue persists.",
		// 	})
		// 	return
		// }

		// print the OTP to the console for now
		fmt.Println("Your OTP code is:", code)

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
				"error": "An error occurred: " + err.Error() + " Please try again later or contact support if the issue persists.",
			})
			return
		}

		// If the user account is not verified, send an OTP to the user's email
		if !exists || data == nil {
			c.JSON(http.StatusNotFound, gin.H{
				"code":  payGidiErrors.EMAIL_NOT_FOUND,
				"error": "No account found with this email address, Try registering first",
			})
			return
		}

		hasReachLimit, err := userService.CheckOTPRequestLimit(db.(*gorm.DB), data.ID, verifyData.ForWhat, "email")

		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
				"error": "An error occurred: " + err.Error() + " Please try again later or contact support if the issue persists.",
			})
			return
		}

		if !hasReachLimit {
			c.JSON(http.StatusTooManyRequests, gin.H{
				"code":  payGidiErrors.OTP_REQUEST_LIMIT_REACHED,
				"error": "You have reached the maximum number of OTP requests. Please try again later.",
			})
			return
		}

		// Generate a new OTP code
		code := utils.GenerateOTPCode(5)

		// Request OTP via email
		if _, err := userService.RequestNewOTPCode(db.(*gorm.DB), data.ID, code, verifyData.ForWhat, "email"); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
				"error": "An error occurred: " + err.Error() + " Please try again later or contact support if the issue persists.",
			})
			return
		}

		// Send the OTP to the user's email
		// if err := utils.SendEmail(verifyData.Email, "Your OTP code is: "+otp.Code); err != nil {
		// 	c.JSON(http.StatusInternalServerError, gin.H{
		// 		"code":  payGidiErrors.INTERNAL_SERVER_ERROR,
		// 		"error": "Failed to send OTP: " + err.Error() + " Please try again later or contact support if the issue persists.",
		// 	})
		// 	return
		// }

		// print the OTP to the console for now
		fmt.Println("Your OTP code is:", code)

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
