package dto

type CreateWalletDto struct {
	// Email    string `json:"email" validate:"required,email"`
	Phone    string `json:"phone" validate:"required,min=10,max=15"`
	Password string `json:"password" validate:"required,min=8,max=100"`
}

type SendMoneyDto struct {
	RecipientPhone string  `json:"recipientPhone" validate:"required,min=10,max=15"`
	Amount         float64 `json:"amount" validate:"required,gt=0"`
}
