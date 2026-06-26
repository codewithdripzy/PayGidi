package utils

import (
	"crypto/sha256"
	"fmt"
	"time"

	"github.com/PayGidi/AccountService/models"
	"gorm.io/gorm"
)

// CreateSession creates a new session record in the database with device info.
func CreateSession(db *gorm.DB, userID uint, tokenString string, deviceInfo *models.DeviceInfo, ip string, userAgent string) (*models.Session, error) {
	// Hash the token so we never store the raw JWT
	tokenHash := hashToken(tokenString)

	// Mark all existing sessions as not current
	db.Model(&models.Session{}).Where("user_id = ?", userID).Update("is_current", false)

	session := models.Session{
		UserID:           userID,
		LastKnownIP:      ip,
		LastUserAgent:    userAgent,
		CurrentSessionID: tokenHash,
		IsCurrent:        true,
		ExpiresAt:        time.Now().Add(24 * time.Hour), // Match JWT expiry
	}

	if deviceInfo != nil {
		session.DeviceName = deviceInfo.DeviceName
		session.DeviceType = deviceInfo.DeviceType
		session.DeviceOS = deviceInfo.DeviceOS
	}

	if err := db.Create(&session).Error; err != nil {
		return nil, err
	}

	return &session, nil
}

// LookupSessionByToken finds a session by the hashed token.
func LookupSessionByToken(db *gorm.DB, tokenString string) (*models.Session, error) {
	tokenHash := hashToken(tokenString)

	var session models.Session
	if err := db.Where("current_session_id = ?", tokenHash).First(&session).Error; err != nil {
		return nil, err
	}

	return &session, nil
}

// DeleteSession deletes a session by its ID (for remote logout)
func DeleteSession(db *gorm.DB, sessionID uint, userID uint) error {
	return db.Where("id = ? AND user_id = ?", sessionID, userID).Delete(&models.Session{}).Error
}

// DeleteCurrentSession deletes the session associated with the given token
func DeleteCurrentSession(db *gorm.DB, tokenString string) error {
	tokenHash := hashToken(tokenString)
	return db.Where("current_session_id = ?", tokenHash).Delete(&models.Session{}).Error
}

// DeleteAllUserSessions deletes all sessions for a user
func DeleteAllUserSessions(db *gorm.DB, userID uint) error {
	return db.Where("user_id = ?", userID).Delete(&models.Session{}).Error
}

func hashToken(token string) string {
	h := sha256.Sum256([]byte(token))
	return fmt.Sprintf("%x", h)
}
