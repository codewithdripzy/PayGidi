package middlewares

import (
	"net/http"

	payGidiErrors "github.com/PayGidi/NotificationService/core/interfaces/errors"
	"github.com/gin-gonic/gin"
)

func VerifyVersion(c *gin.Context) {
	version := c.Param("version")
	if version != "1" {
		c.JSON(http.StatusForbidden, gin.H{
			"code":  payGidiErrors.INVALID_API_VERSION,
			"error": "unsupported API version",
		})
		c.Abort()
		return
	}

	c.Set("version", version)
	c.Next()
}
