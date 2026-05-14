package middlewares

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
)

var validate = validator.New()

func ValidateDTO[T any](obj *T) gin.HandlerFunc {
	return func(c *gin.Context) {
		if err := c.ShouldBindJSON(obj); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid JSON format", "details": err.Error()})
			c.Abort()
			return
		}

		if err := validate.Struct(obj); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request", "details": err.Error()})
			c.Abort()
			return
		}

		// Store validated object in context for use in controller
		c.Set("validatedBody", obj)
		c.Next()
	}
}
