package models

import (
	"time"
)

type Business struct {
	ID                 uint      `json:"id" gorm:"primaryKey;autoIncrement"`
	UserID             uint      `json:"userId" gorm:"uniqueIndex"`
	Name               string    `json:"name"`
	RegistrationNumber string    `json:"registrationNumber"`
	Type               string    `json:"type"` // e.g., "LLC", "Sole Proprietorship"
	Industry           string    `json:"industry"`
	Website            string    `json:"website,omitempty"`
	Instagram          string    `json:"instagram,omitempty"`
	Twitter            string    `json:"twitter,omitempty"`
	LinkedIn           string    `json:"linkedIn,omitempty"`
	Facebook           string    `json:"facebook,omitempty"`
	RegistrationDoc    string    `json:"registrationDoc,omitempty"` // URL to the document
	AdditionalDocs     []string  `json:"additionalDocs" gorm:"type:text[]"`
	CreatedAt          time.Time `json:"createdAt"`
	UpdatedAt          time.Time `json:"updatedAt"`
}

func (Business) TableName() string {
	return "account_businesses"
}
