package dto

type CreateWalletDto struct {
	Firstname   string `json:"firstname" validate:"required"`
	Middlename  string `json:"middlename"`
	Lastname    string `json:"lastname" validate:"required"`
	Nin         string `json:"nin" validate:"required,len=11"`
	DateOfBirth string `json:"dateOfBirth" validate:"required,datetime=2006-01-02"`
	Bvn         string `json:"bvn" validate:"omitempty,len=11"`
	Phone       string `json:"phone" validate:"required"`
	Email       string `json:"email" validate:"required,email"`
	Gender      string `json:"gender" validate:"required,oneof=1 2"` // 1 for male, 2 for female (Squad often uses 1/2 or M/F)
	UserID      string `json:"userId" validate:"required"`
	AccountType string `json:"accountType" validate:"omitempty,oneof=individual business"`
	BusinessName string `json:"businessName" validate:"required_if=AccountType business"`
}

type SendMoneyDto struct {
	RecipientPhone string  `json:"recipientPhone" validate:"required,min=10,max=15"`
	Amount         float64 `json:"amount" validate:"required,gt=0"`
}
