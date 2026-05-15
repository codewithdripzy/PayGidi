package middlewares

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"reflect"
	"strings"

	"github.com/PayGidi/AccountService/models"
	"github.com/PayGidi/AccountService/validators"
	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
)

var validate = validator.New()

func ValidateDTO(dto interface{}) gin.HandlerFunc {
	return func(c *gin.Context) {
		var requestDTO interface{}

		if dto == nil {
			// Dynamic DTO based on account type
			user, exists := c.Get("user")
			if !exists {
				c.JSON(http.StatusUnauthorized, gin.H{
					"status":  false,
					"message": "Authentication required for dynamic validation",
				})
				c.Abort()
				return
			}

			u := user.(models.User)
			if u.AccountType == "business" {
				requestDTO = new(validators.BusinessCompleteAccountDto)
			} else {
				requestDTO = new(validators.IndividualCompleteAccountDto)
			}
		} else {
			// Use the provided DTO type
			t := reflect.TypeOf(dto)
			if t.Kind() == reflect.Ptr {
				t = t.Elem()
			}
			requestDTO = reflect.New(t).Interface()
		}

		rawBody, err := c.GetRawData()
		if err != nil {
			log.Printf("[ValidateDTO] failed to read request body path=%s err=%v", c.Request.URL.Path, err)
			c.JSON(http.StatusBadRequest, gin.H{
				"status":  false,
				"message": "Unable to read request payload. Please try again.",
			})
			c.Abort()
			return
		}

		if len(rawBody) > 0 {
			log.Printf("[ValidateDTO] incoming payload path=%s payload=%s", c.Request.URL.Path, sanitizePayloadForLog(rawBody))
		}

		c.Request.Body = io.NopCloser(bytes.NewBuffer(rawBody))

		if err := c.ShouldBindJSON(requestDTO); err != nil {
			log.Printf("[ValidateDTO] invalid json path=%s err=%v", c.Request.URL.Path, err)
			c.JSON(http.StatusBadRequest, gin.H{
				"status":  false,
				"message": "Invalid request payload. Please send valid JSON.",
				"errors":  []string{err.Error()},
			})
			c.Abort()
			return
		}

		if err := validate.Struct(requestDTO); err != nil {
			log.Printf("[ValidateDTO] validation failed path=%s err=%v", c.Request.URL.Path, err)

			validationErrors, ok := err.(validator.ValidationErrors)
			if !ok {
				c.JSON(http.StatusBadRequest, gin.H{
					"status":  false,
					"message": "Invalid request. Please check your input and try again.",
					"errors":  []string{err.Error()},
				})
				c.Abort()
				return
			}

			friendlyErrors := make([]string, 0, len(validationErrors))
			for _, fieldErr := range validationErrors {
				friendlyErrors = append(friendlyErrors, formatValidationMessage(fieldErr, requestDTO))
			}

			c.JSON(http.StatusBadRequest, gin.H{
				"status":  false,
				"message": "Some fields are missing or invalid. Please review and try again.",
				"errors":  friendlyErrors,
			})
			c.Abort()
			return
		}

		// Store validated object in context for use in controller
		c.Set("validatedBody", requestDTO)
		c.Next()
	}
}

func sanitizePayloadForLog(raw []byte) string {
	if len(raw) == 0 {
		return "{}"
	}

	var payload map[string]interface{}
	if err := json.Unmarshal(raw, &payload); err != nil {
		return "<non-json-payload>"
	}

	sensitiveKeys := map[string]struct{}{
		"pin":          {},
		"oldPin":       {},
		"newPin":       {},
		"confirmPin":   {},
		"token":        {},
		"accessToken":     {},
		"refreshToken":    {},
		"base64Image":     {},
	}

	for key := range payload {
		if _, ok := sensitiveKeys[key]; ok {
			payload[key] = "<redacted>"
		}
	}

	masked, err := json.Marshal(payload)
	if err != nil {
		return "<payload-redaction-failed>"
	}

	return string(masked)
}

func formatValidationMessage(fieldErr validator.FieldError, dto interface{}) string {
	field := jsonFieldName(dto, fieldErr.StructField())

	switch fieldErr.Tag() {
	case "required":
		return fmt.Sprintf("%s is required", field)
	case "email":
		return fmt.Sprintf("%s must be a valid email address", field)
	case "min":
		return fmt.Sprintf("%s must be at least %s characters", field, fieldErr.Param())
	case "max":
		return fmt.Sprintf("%s must be at most %s characters", field, fieldErr.Param())
	case "len":
		return fmt.Sprintf("%s must be exactly %s characters", field, fieldErr.Param())
	case "eqfield":
		related := jsonFieldName(dto, fieldErr.Param())
		return fmt.Sprintf("%s must match %s", field, related)
	case "datetime":
		return fmt.Sprintf("%s must use date format YYYY-MM-DD", field)
	case "oneof":
		return fmt.Sprintf("%s must be one of: %s", field, strings.ReplaceAll(fieldErr.Param(), " ", ", "))
	default:
		return fmt.Sprintf("%s is invalid", field)
	}
}

func jsonFieldName(dto interface{}, structField string) string {
	if dto == nil {
		return strings.ToLower(structField)
	}

	t := reflect.TypeOf(dto)
	if t.Kind() == reflect.Ptr {
		t = t.Elem()
	}

	if t.Kind() != reflect.Struct {
		return strings.ToLower(structField)
	}

	if field, ok := t.FieldByName(structField); ok {
		jsonTag := field.Tag.Get("json")
		if jsonTag != "" {
			name := strings.Split(jsonTag, ",")[0]
			if name != "" && name != "-" {
				return name
			}
		}
	}

	return strings.ToLower(structField)
}
