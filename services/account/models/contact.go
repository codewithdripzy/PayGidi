package models

type ContactInfo struct {
	ID         uint `json:"id" gorm:"primaryKey;autoIncrement"`
	UserID     uint   `json:"userId"`
	User       User   `gorm:"constraint:OnUpdate:CASCADE,OnDelete:SET NULL;"` // Belongs to User
	Address    string `json:"address"`
	Country    string `json:"country"`
	State      string `json:"state"`
	City       string `json:"city"`
	PostalCode string `json:"postalCode"`
}

func (ContactInfo) TableName() string {
	return "account_contact_info"
}
