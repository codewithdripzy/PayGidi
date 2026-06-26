package models

import "time"

// Referral tracks when a user is referred by another user via referral code.
type Referral struct {
	ID          uint      `json:"id" gorm:"primaryKey;autoIncrement"`
	ReferrerID  uint      `json:"referrerId" gorm:"index"`                            // The user who referred
	Referrer    User      `gorm:"constraint:OnUpdate:CASCADE,OnDelete:SET NULL;"`
	ReferredID  uint      `json:"referredId" gorm:"index;unique"`                     // The new user who was referred
	Referred    User      `gorm:"constraint:OnUpdate:CASCADE,OnDelete:SET NULL;"`
	BonusPaid   bool      `json:"bonusPaid" gorm:"default:false"`                     // Whether the referral bonus has been paid out
	BonusAmount float64   `json:"bonusAmount" gorm:"default:0"`                       // Amount of bonus paid (e.g., N2000 per 3 referrals)
	CreatedAt   time.Time `json:"createdAt"`
	UpdatedAt   time.Time `json:"updatedAt"`
}

func (Referral) TableName() string {
	return "referrals"
}
