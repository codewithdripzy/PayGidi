package utils

import (
	"errors"
	"log"
	"strings"

	notificationService "github.com/PayGidi/AccountService/services/notification"
)

func SendUserNotification(userID uint, title string, message string, channel string, recipient string, notificationType string) {
	err := notificationService.SendUserNotification(userID, title, message, channel, recipient, notificationType)
	if err != nil {
		log.Printf("failed to create notification: %v", err)
	}
}

func CreateAccountNumberFromPhone(phone string) (string, error) {
	// Remove any non-digit characters (optional, depends on your input)
	cleaned := ""

	for _, r := range phone {
		if r >= '0' && r <= '9' {
			cleaned += string(r)
		}
	}

	if len(cleaned) == 0 {
		return "", errors.New("invalid phone number")
	}

	// If phone number is shorter than 10 digits, pad with leading zeros
	if len(cleaned) < 10 {
		padding := 10 - len(cleaned)
		for i := 0; i < padding; i++ {
			cleaned = "0" + cleaned
		}
	} else if len(cleaned) > 10 {
		// If longer than 10 digits, use the last 10 digits
		cleaned = cleaned[len(cleaned)-10:]
	}

	return cleaned, nil
}

func NormalizePhoneNumber(phone string) (string, error) {
	trimmed := strings.TrimSpace(phone)
	if trimmed == "" {
		return "", errors.New("phone number is required")
	}

	cleaned := ""
	for _, r := range trimmed {
		if r >= '0' && r <= '9' {
			cleaned += string(r)
		}
	}

	switch {
	case len(cleaned) == 13 && strings.HasPrefix(cleaned, "234"):
		return cleaned, nil
	case len(cleaned) == 11 && strings.HasPrefix(cleaned, "0"):
		return "234" + cleaned[1:], nil
	case len(cleaned) == 10:
		return "234" + cleaned, nil
	default:
		return "", errors.New("invalid phone number format")
	}
}

func Sanitized(phone string) (string, error) {
	return NormalizePhoneNumber(phone)
}
