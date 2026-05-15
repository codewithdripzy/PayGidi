package utils

import (
	"crypto/sha256"
	"encoding/hex"
)

func HashNIN(nin string, salt string) string {
	hash := sha256.New()
	hash.Write([]byte(nin + salt))
	return hex.EncodeToString(hash.Sum(nil))
}
