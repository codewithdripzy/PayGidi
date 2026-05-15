package utils

import (
	"crypto/sha256"
	"encoding/hex"

	"golang.org/x/crypto/bcrypt"
)

func HashNIN(nin string, salt string) string {
	hash := sha256.New()
	hash.Write([]byte(nin + salt))
	return hex.EncodeToString(hash.Sum(nil))
}

func HashPin(pin string) (string, error) {
	hashedPin, err := bcrypt.GenerateFromPassword([]byte(pin), bcrypt.DefaultCost)
	if err != nil {
		return "", err
	}
	return string(hashedPin), nil
}

func VerifyPin(hashedPin, pin string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(hashedPin), []byte(pin))
	return err == nil
}
