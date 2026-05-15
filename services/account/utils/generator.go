package utils

import (
	"math/rand"

	"github.com/google/uuid"
)

func GenerateOTPCode(length int) string {
	const charset = "0123456789"
	otp := make([]byte, length)

	for i := range otp {
		otp[i] = charset[rand.Intn(len(charset))]
	}

	return string(otp)
}

func GenerateAlphaNumOTPCode(length int) string {
	const charset = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	otp := make([]byte, length)

	for i := range otp {
		otp[i] = charset[rand.Intn(len(charset))]
	}

	return string(otp)
}
func GenerateUID() string {
	id := uuid.New()
	return id.String()
}
