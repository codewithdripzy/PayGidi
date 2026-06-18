package middlewares

import (
	"log"
	"net/http"

	payGidiErrors "github.com/PayGidi/AccountService/core/interfaces/errors"
	"github.com/gin-gonic/gin"
	// "github.com/PayGidi/AccountService/utils"
)

// VerifyVersion is a middleware that checks if the API version is valid
func VerifyVersion(c *gin.Context) {
	log.Printf("VerifyVersion middleware called for path: %s", c.Request.URL.Path)
	// Get the version from the URL
	version := c.Param("version")

	// Check if the version is valid
	if version != "1" {
		c.JSON(int(http.StatusForbidden), gin.H{
			"code":  payGidiErrors.INVALID_API_VERSION,
			"error": "You are not allowed to access this API version, refer to the documentation for more information.",
		})
		c.Abort()
		return
	}

	// Set the version in the context for later use
	c.Set("version", version)

	// Call the next handler in the chain
	c.Next()
}
