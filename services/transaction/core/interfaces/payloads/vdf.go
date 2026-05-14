package payloads

type GenerateAccessTokenPayload struct {
	ClientID     string `json:"clientId" validate:"required"`
	ClientSecret string `json:"clientSecret" validate:"required"`
}

type CreateClientPayload struct {
	Firstname  string `json:"firstname" validate:"required"`
	Middlename string `json:"middlename"`
	Lastname   string `json:"lastname" validate:"required"`
	Nin        string `json:"nin" validate:"required,len=11"`
	DateOfBirth  string `json:"dateOfBirth" validate:"required,datetime=2006-01-02"`
}

type UpgradeAccountTierPayload struct {
	AccountNo       string  `json:"accountNo" validate:"required"`
	BVN             *string `json:"bvn" validate:"omitempty,len=12"`
	Address         *string `json:"address" validate:"omitempty"`
}

type HasAccountPayload struct {
	BVN string `json:"bvn" validate:"required,len=11"`
}

type SendMoneyPayload struct {
	FromAccount string `json:"fromAccount" validate:"required"`
	UniqueSenderAccountId string `json:"uniqueSenderAccountId"`
	FromClientId string `json:"fromClientId" validate:"required"`
	FromClient string `json:"fromClient" validate:"required"`
	FromSavingsId string `json:"fromSavingsId"`
	FromBvn string `json:"fromBvn"`

	ToClientId string `json:"toClientId" validate:"required"`
	ToClient string `json:"toClient" validate:"required"`
	ToSavingsId string `json:"toSavingsId"`
	ToSession string `json:"toSession"`
	ToBvn string `json:"toBvn"`
	ToBank string `json:"toBank"`

	Signature string `json:"signature" validate:"required"`
	Amount      string `json:"amount" validate:"required"`
	Remark      string `json:"remark"`
	TransferType string `json:"transferType" validate:"required,oneof=intra inter"`
	Reference   string `json:"reference" validate:"required"`
}