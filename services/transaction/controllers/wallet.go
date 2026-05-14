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

func CreateWallet(c *gin.Context) {
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

	loginData, ok := validatedBody.(*validators.LoginDto)
	if !ok {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":  payGidiErrors.INVALID_REQUEST_BODY,
			"error": "Phone Number or Password is not valid",
		})
		return
	}

	exists, data, err := userService.PhoneExists(db.(*gorm.DB), loginData.Phone)

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

	// check the password against a hashed password stored in the database.
	if err := utils.ComparePasswords(data.Password, loginData.Password); err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{
			"code":  payGidiErrors.INCORRECT_PHONE_OR_PASSWORD,
			"error": "Invalid phone number or password",
		})
		return
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
	if !data.PhoneVerified {
		otp := utils.GenerateOTPCode(5)
		// add a new OTP to the user's auth info
		newOTP := models.OTP{
			Code:      otp,
			UserID:    data.ID,
			ForWhat:   "completeRegister",
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
				"firstName":      data.Person.FirstName,
				"lastName":       data.Person.LastName,
				"phone":          data.Phone,
				"email":          data.Email,
				"lastLoginAt":    data.AuthInfo.LastLoginAt,
				"requiredAction": "completeRegister",
			},
		})
		return
	}

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
				"firstName":      data.Person.FirstName,
				"lastName":       data.Person.LastName,
				"phone":          data.Phone,
				"email":          data.Email,
				"lastLoginAt":    data.AuthInfo.LastLoginAt,
				"requiredAction": "verifyOTP",
			},
		})
	}

	// If the login is successful, return a success response with the user data and tokens
	c.JSON(http.StatusOK, gin.H{
		"message": message,
		"data": gin.H{
			"createdAt": data.CreatedAt,
			// "userId":       data.ID,
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

func SendMoney(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"message": "Send money endpoint is working",
	})
}
