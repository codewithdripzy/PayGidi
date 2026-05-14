package utils

import (
	"errors"
)

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
