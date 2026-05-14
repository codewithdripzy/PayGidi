package dto

type CreateAccountDto struct {
	AccountCategory string `json:"accountCategory" validate:"required,oneof=personal business"`
	Currency        string `json:"currency" validate:"required,len=3"`
	Bvn             string `json:"bvn" validate:"omitempty,len=11"`
	DateOfBirth  string `json:"dateOfBirth" validate:"omitempty,datetime=2006-01-02"`
}

type SetAccountPin struct {
	Pin string `json:"pin" validate:"required,len=4,numeric"`
}

type UpdateAccountPin struct {
	OldPin string `json:"oldPin" validate:"required,len=4,numeric"`
	NewPin string `json:"newPin" validate:"required,len=4,numeric,nefield=OldPin"`
}
