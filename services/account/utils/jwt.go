package utils

import (
	"encoding/json"
	"time"

	"database/sql"

	"github.com/golang-jwt/jwt/v5"
	"github.com/PayGidi/AccountService/core/constants"
)

var db *sql.DB

// GenerateJWT generates a JWT token for the given user ID and email
func GenerateJWTtokens(userID uint, email string) (string, string, error) {
	jwtSecret := constants.JWT_SECRET
	jwtRefreshSecret := constants.JWT_REFRESH_SECRET

	if jwtSecret == "" {
		// return "", jwt.ErrMissingKey
	}

	if jwtRefreshSecret == "" {
		// return "", jwt.ErrMissingKey
	}

	// Define the token claims
	claims := jwt.MapClaims{
		"user_id":  userID,
		"email":    email,
		"exp":      time.Now().Add(time.Hour * 24).Unix(), // Token expires in 24 hours
		"loggedIn": true,
	}

	// Create a new token with the claims
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)

	// Sign the token with a secret key
	tokenString, err := token.SignedString([]byte(jwtSecret))
	if err != nil {
		return "", "", err
	}

	refreshClaims := jwt.MapClaims{
		"token": tokenString,
		"exp":   time.Now().Add(time.Hour * 24 * 7).Unix(), // Refresh token expires in 7 days
		"iss":   constants.JWT_REFRESH_ISSUER,
	}

	refreshToken := jwt.NewWithClaims(jwt.SigningMethodHS256, refreshClaims)
	refreshTokenString, err := refreshToken.SignedString([]byte(jwtRefreshSecret))

	if err != nil {
		return "", "", err
	}

	return tokenString, refreshTokenString, nil
}

func VerifyJWT(tokenString string) (jwt.MapClaims, error) {
	jwtSecret := constants.JWT_SECRET

	// Parse the token
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, jwt.ErrSignatureInvalid
		}
		return []byte(jwtSecret), nil
	})

	if err != nil || !token.Valid {
		return nil, err
	}

	claims, err := VerifyJWT(tokenString)
	if err != nil {
		return nil, err
	}

	// Serialize to JSON before storing
	claimsJSON, err := json.Marshal(claims)
	if err != nil {
		return nil, err
	}

	// Now store claimsJSON in a database column of type TEXT or JSONB
	_, err = db.Exec("INSERT INTO sessions (claims) VALUES ($1)", claimsJSON)
	if err != nil {
		return nil, err
	}

	return nil, jwt.ErrTokenMalformed
}

func VerifyRefreshJWT(tokenString string) (jwt.MapClaims, error) {
	jwtRefreshSecret := constants.JWT_REFRESH_SECRET

	// Parse the refresh token
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, jwt.ErrSignatureInvalid
		}
		return []byte(jwtRefreshSecret), nil
	})

	if err != nil || !token.Valid {
		return nil, err
	}

	// Extract claims
	if claims, ok := token.Claims.(jwt.MapClaims); ok {
		return claims, nil
	}

	return nil, jwt.ErrTokenMalformed
}
