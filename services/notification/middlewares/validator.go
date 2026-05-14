package middlewares

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
)

var validate = validator.New()

func ValidateDTO[T any]() gin.HandlerFunc {
	return func(c *gin.Context) {
		payload := new(T)

		if err := c.ShouldBindJSON(payload); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{
				"error":   "invalid JSON format",
				"details": err.Error(),
			})
			c.Abort()
			return
		}

		if err := validate.Struct(payload); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{
				"error":   "invalid request",
				"details": err.Error(),
			})
			c.Abort()
			return
		}

		c.Set("validatedBody", payload)
		c.Next()
	}
}
