package models

import (
	"time"

	"gorm.io/gorm"
)

type SavingsGoal struct {
	ID            uint           `gorm:"primaryKey" json:"id"`
	UserID        uint           `gorm:"index;not null" json:"userId"`
	Name          string         `gorm:"not null" json:"name"`
	TargetAmount  float64        `gorm:"not null" json:"targetAmount"`
	CurrentAmount float64        `gorm:"default:0" json:"currentAmount"`
	Currency      string         `gorm:"default:'NGN'" json:"currency"`
	Status        string         `gorm:"default:'active'" json:"status"`
	CreatedAt     time.Time      `json:"createdAt"`
	UpdatedAt     time.Time      `json:"updatedAt"`
	DeletedAt     gorm.DeletedAt `gorm:"index" json:"-"`
}

func (SavingsGoal) TableName() string {
	return "savings_goals"
}
