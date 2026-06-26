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

// GenerateReferralCode generates a random 6-character alphanumeric referral code.
func GenerateReferralCode() string {
	const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	code := make([]byte, 6)
	for i := range code {
		code[i] = chars[rand.Intn(len(chars))]
	}
	return string(code)
}
