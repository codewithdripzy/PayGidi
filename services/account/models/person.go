package models

import "github.com/lib/pq"

type Person struct {
	ID          uint           `json:"id" gorm:"primaryKey;autoIncrement"`
	FirstName   string         `json:"firstName"`
	LastName    string         `json:"lastName"`
	MiddleName  string         `json:"middleName"`
	Address     string         `json:"address"`
	OtherNames  pq.StringArray `gorm:"type:text[]" json:"otherNames"`
	Gender      string         `json:"gender"`
	DateOfBirth string         `json:"dateOfBirth"`
	Country     string         `json:"country"`
	State       string         `json:"state"`
	City        string         `json:"city"`
	PostalCode  string         `json:"postalCode"`
	UserID      uint           `gorm:"uniqueIndex"` // Make sure only one Person per User
	// User        User     `gorm:"constraint:OnUpdate:CASCADE,OnDelete:SET NULL;"` // Belongs to User
}

func (Person) TableName() string {
	return "account_persons"
}
