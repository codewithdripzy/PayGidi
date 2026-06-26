package models

import "time"

type AccountIssue struct {
	ID        uint       `json:"id" gorm:"primaryKey;autoIncrement"`
	UserID    uint       `json:"userId"`
	Subject   string     `json:"subject" validate:"required,min=3,max=200"`
	Message   string     `json:"message" validate:"required,min=10"`
	Status    string     `json:"status" gorm:"default:pending"` // pending, resolved, closed
	CreatedAt time.Time  `json:"createdAt"`
	UpdatedAt time.Time  `json:"updatedAt"`
	DeletedAt *time.Time `json:"deletedAt,omitempty"`
}

func (AccountIssue) TableName() string {
	return "account_issues"
}
