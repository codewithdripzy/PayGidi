package controllers

import (
	"net/http"

	userService "github.com/PayGidi/AccountService/services/user"
	"github.com/PayGidi/AccountService/utils"
	"github.com/PayGidi/AccountService/validators"
	"github.com/gin-gonic/gin"
)

func Register(c *gin.Context) {
	db, exists := utils.CheckDBInitialized(c)

	if !exists {
		return
	}

	validatedBody, exists := utils.GetValidatedBody(c)

	if !exists {
		return
	}

	registerData, ok := validatedBody.(*validators.RegisterDto)
	if !ok {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid request",
		})
		return
	}

	if registerData.Password != registerData.ConfirmPassword {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Passwords do not match, Check and try again",
		})
		return
	}

	// check if phone number aleady exists
	phoneExists, _, existserr := userService.PhoneExists(db, registerData.Phone)

	if existserr != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "An error occurred: " + existserr.Error() + " Please try again later or contact support if the issue persists.",
		})
		return
	}

	if phoneExists {
		c.JSON(http.StatusConflict, gin.H{
			"error": "An account with this phone number already exists. Please try logging in or use a different Phone Number.",
		})
		return
	}

	// check if Email Address aleady exists
	exists, _, err := userService.EmailExists(db, registerData.Email)

	// handle error
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "An error occurred: " + err.Error() + " Please try again later or contact support if the issue persists.",
		})
		return
	}

	if exists {
		c.JSON(http.StatusConflict, gin.H{
			"error": "An account with this email address already exists. Please try logging in or use a different email address.",
		})
		return
	}

	// hash the password
	hashedPassword, err := utils.HashPassword(registerData.Password)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "An error occurred while hashing the password: " + err.Error() + " Please try again later or contact support if the issue persists.",
		})
		return
	}

	registerData.Password = hashedPassword

	user, err := userService.RegisterUser(db, registerData)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "An error occurred while registering the user: " + err.Error() + " Please try again later or contact support if the issue persists.",
		})
		return
	}

	if user == nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Something went wrong, Please contact support if the issue persists.",
		})
		return
	}

	// generate OTP and send it to the user
	err = userService.GenerateAndSendSMSOTP(db, user.ID, registerData.Phone)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "An error occurred while sending the OTP: " + err.Error() + " Please try again later or contact support if the issue persists.",
		})
		return
	}

	// Respond with success
	c.JSON(http.StatusOK, gin.H{
		"message": "User registered successfully. An OTP has been sent to your phone number. Please verify your phone number to complete the registration process.",
		"phone":   registerData.Phone,
	})
}
