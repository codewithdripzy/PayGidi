package middlewares

import (
	"net/http"
	"reflect"

	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
)

var validate = validator.New()

// ValidateDTO is a middleware that validates the request body against a DTO
func ValidateDTO(dto interface{}) gin.HandlerFunc {
	return func(c *gin.Context) {
		// Create a new instance of the DTO
		val := reflect.New(reflect.TypeOf(dto).Elem()).Interface()

		// Bind the request body to the DTO
		if err := c.ShouldBindJSON(val); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{
				"success": false,
				"message": "Invalid request payload",
				"error":   err.Error(),
			})
			c.Abort()
			return
		}

		// Validate the DTO
		if err := validate.Struct(val); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{
				"success": false,
				"message": "Validation failed",
				"error":   err.Error(),
			})
			c.Abort()
			return
		}

		// Set the validated DTO in the context
		c.Set("validatedBody", val)
		c.Next()
	}
}
