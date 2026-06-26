package controllers

// SquadWebhookDataV3 matches the full Squad virtual-account webhook payload.
type SquadWebhookDataV3 struct {
	TransactionReference string `json:"transaction_reference"`
	VirtualAccountNumber string `json:"virtual_account_number"`
	PrincipalAmount      string `json:"principal_amount"`
	SettledAmount        string `json:"settled_amount"`
	FeeCharged           string `json:"fee_charged"`
	TransactionDate      string `json:"transaction_date"`
	CustomerIdentifier   string `json:"customer_identifier"`
	TransactionIndicator string `json:"transaction_indicator"`
	Remarks              string `json:"remarks"`
	Currency             string `json:"currency"`
	Channel              string `json:"channel"`
	SenderName           string `json:"sender_name"`
	TransactionUUID      string `json:"transaction_uuid"`
	EncryptedBody        string `json:"encrypted_body"`
}

// SquadWebhookPayloadV3 is the top-level Squad webhook structure.
type SquadWebhookPayloadV3 struct {
	Event string             `json:"event"`
	Data  SquadWebhookDataV3 `json:"data"`
}
