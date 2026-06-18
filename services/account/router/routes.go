package router

import (
	"github.com/PayGidi/AccountService/controllers"
	_ "github.com/PayGidi/AccountService/docs"
	"github.com/PayGidi/AccountService/middlewares"
	"github.com/PayGidi/AccountService/validators"
	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

func SetupRoutes(app *gin.Engine) {
	// Swagger documentation
	app.GET("/docs/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	// health check
	app.GET("/health", controllers.HealthCheck)

	// create a new router group for the API
	api := app.Group("/api/v:version")

	// add middleware to check version
	api.Use(middlewares.VerifyVersion)

	// me route
	api.GET("/me", middlewares.Authenticate(), controllers.Me)

	// auth routes
	api.POST("/auth", middlewares.ValidateDTO(&validators.AuthDto{}), controllers.Auth)
	api.POST("/auth/verify", middlewares.ValidateDTO(&validators.VerifyAuthOtpDto{}), controllers.VerifyAuthOTP)
	api.POST("/auth/complete", middlewares.Authenticate(), middlewares.ValidateDTO(nil), controllers.CompleteAccount)

	api.POST("/auth/verify/nin", middlewares.ValidateDTO(&validators.VerifyNINDto{}), controllers.VerifyNIN)
	api.POST("/auth/verify/bvn-image", middlewares.ValidateDTO(&validators.VerifyBVNImageDto{}), controllers.VerifyBVNImage)
	api.POST("/auth/verify/email", middlewares.ValidateDTO(&validators.VerifyEmailDto{}), controllers.VerifyEmail)

	api.POST("/auth/otp/request/:otpType", middlewares.ValidateDTO(&validators.RequestOTPDto{}), controllers.RequestOTP)
	api.POST("/auth/biometric", middlewares.ValidateDTO(&validators.BiometricAuthDto{}), controllers.BiometricAuth)
	api.POST("/auth/biometric/register", middlewares.Authenticate(), middlewares.ValidateDTO(&validators.RegisterBiometricDto{}), controllers.RegisterBiometric)
	api.POST("/auth/logout", middlewares.Authenticate(), controllers.Logout)

	// business routes
	business := api.Group("/business")
	business.Use(middlewares.Authenticate())
	{
		business.GET("/profile", controllers.GetBusinessProfile)
		business.PUT("/profile", middlewares.ValidateDTO(&validators.UpdateBusinessProfileDto{}), controllers.UpdateBusinessProfile)
		business.PUT("/docs", middlewares.ValidateDTO(&validators.UpdateBusinessDocsDto{}), controllers.UpdateBusinessDocs)
	}

	// me route
	api.GET("/me", middlewares.Authenticate(), controllers.Me)

	// account routes
	account := api.Group("/account")
	account.Use(middlewares.Authenticate())
	{
		account.GET("", controllers.GetAccountDetails)
		account.DELETE("", controllers.DeleteAccount)
		account.POST("/pin", middlewares.ValidateDTO(&validators.SetPinDto{}), controllers.SetPin)
		account.PUT("/pin", middlewares.ValidateDTO(&validators.UpdatePinDto{}), controllers.UpdatePin)
	}

	api.GET("/health", controllers.HealthCheck)
}
