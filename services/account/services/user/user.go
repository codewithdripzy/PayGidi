package userService

import (
	"errors"
	"os"
	"time"

	"github.com/PayGidi/AccountService/models"
	"github.com/PayGidi/AccountService/utils"
	"gorm.io/gorm"
)

// EmailExists checks if a user with the given email exists in the database.
func EmailExists(db *gorm.DB, email string) (bool, *models.User, error) {
	var user models.User
	result := db.
		Preload("Preferences").
		Preload("Person").
		Preload("Activities").
		Preload("OTPs").
		Preload("KYCs").
		Preload("Contact").
		Preload("AuthInfo").
		Preload("Sessions").
		Preload("Roles").
		Preload("Business").
		Where("email = ?", email).
		First(&user)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return false, nil, nil
		}
		return false, nil, result.Error
	}

	return true, &user, nil
}

func PhoneExists(db *gorm.DB, phone string) (bool, *models.User, error) {
	var user models.User
	result := db.
		Preload("Preferences").
		Preload("Person").
		Preload("Activities").
		Preload("OTPs").
		Preload("KYCs").
		Preload("Contact").
		Preload("AuthInfo").
		Preload("Sessions").
		Preload("Roles").
		Preload("Business").
		Where("phone = ?", phone).
		First(&user)

	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return false, nil, nil
		}
		return false, nil, result.Error
	}

	return true, &user, nil
}

func NINExists(db *gorm.DB, nin string) (bool, *models.User, error) {
	// get the salt value from the environment variable or configuration
	salt := os.Getenv("NIN_HASH_SALT")
	if salt == "" {
		salt = "" // Use a default salt if not set in environment variables
	}

	var user models.User
	result := db.
		Preload("Preferences").
		Preload("Person").
		Preload("Activities").
		Preload("OTPs").
		Preload("KYCs").
		Preload("Contact").
		Preload("AuthInfo").
		Preload("Sessions").
		Preload("Roles").
		Preload("Business").
		Where("hashed_nin = ?", utils.HashNIN(nin, salt)).
		First(&user)

	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return false, nil, nil
		}
		return false, nil, result.Error
	}

	return true, &user, nil
}

func GetUserById(db *gorm.DB, userID uint) (*models.User, error) {
	var user models.User
	result := db.
		Preload("Preferences").
		Preload("Person").
		Preload("Activities").
		Preload("OTPs").
		Preload("KYCs").
		Preload("Contact").
		Preload("AuthInfo").
		Preload("Sessions").
		Preload("Roles").
		Where("id = ?", userID).
		First(&user)

	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, nil // User not found
		}
		return nil, result.Error // Other error
	}

	return &user, nil
}

func GetOTPByCode(db *gorm.DB, userId uint, code string, forWhat string, via string) (*models.OTP, error) {
	var otp models.OTP
	result := db.
		Where("user_id = ? AND code = ? AND for_what = ? AND via = ?", userId, code, forWhat, via).
		First(&otp)

	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, nil // OTP not found
		}
		return nil, result.Error // Other error
	}

	return &otp, nil
}

func AddOTP(db *gorm.DB, user *models.User, otp *models.OTP) error {
	return db.Model(user).Association("OTPs").Append(otp)
}

func UpdateUserLastLogin(db *gorm.DB, userID uint) error {
	return db.Model(&models.AuthInfo{}).Where("user_id = ?", userID).Update("last_login_at", time.Now()).Error
}

func UpdateOTPCooldown(db *gorm.DB, userID uint, count int, cooldown *time.Time) error {
	return db.Model(&models.AuthInfo{}).Where("user_id = ?", userID).Updates(map[string]interface{}{
		"otp_request_count":  count,
		"otp_cooldown_until": cooldown,
	}).Error
}

func UpdateOTP(db *gorm.DB, userId uint, otp *models.OTP, via string) error {
	return db.Model(&models.OTP{}).
		Where("user_id = ? AND via = ? AND code = ?", userId, via, otp.Code).
		Updates(map[string]interface{}{
			"verified":   otp.Verified,
			"expires_at": otp.ExpiresAt,
		}).Error
}
