package payloads

type CreateSquadVirtualAccountPayload struct {
	FirstName          string `json:"first_name"`
	LastName           string `json:"last_name"`
	MiddleName         string `json:"middle_name,omitempty"`
	MobileNum          string `json:"mobile_num"`
	Dob                string `json:"dob"` // mm/dd/yyyy
	Bvn                string `json:"bvn"`
	CustomerIdentifier string `json:"customer_identifier"`
	Gender             string `json:"gender"`
	Email              string `json:"email"`
	Address            string `json:"address"`
}

type SquadAccountLookupPayload struct {
	BankCode      string `json:"bank_code"`
	AccountNumber string `json:"account_number"`
}

type CreateSquadBusinessVirtualAccountPayload struct {
	BusinessName       string `json:"business_name"`
	CustomerIdentifier string `json:"customer_identifier"`
	MobileNum          string `json:"mobile_num"`
	Bvn                string `json:"bvn"`
	BeneficiaryAccount string `json:"beneficiary_account,omitempty"`
}

type CreateSquadDynamicVirtualAccountPayload struct {
	Amount               int    `json:"amount"` // in kobo
	TransactionReference string `json:"transaction_reference"`
	CustomerEmail        string `json:"customer_email"`
	CustomerName         string `json:"customer_name"`
	Duration             string `json:"duration"` // e.g. "10m"
}

type InitiateSquadPaymentPayload struct {
	Amount       int    `json:"amount"` // in kobo
	Email        string `json:"email"`
	Currency     string `json:"currency"`
	InitiateType string `json:"initiate_type"` // "inline"
	CallbackURL  string `json:"callback_url"`
	Metadata     any    `json:"metadata,omitempty"`
}

type SquadTransferPayload struct {
	TransactionReference string `json:"transaction_reference"`
	Amount               int    `json:"amount"` // in kobo
	BankCode             string `json:"bank_code"`
	AccountNumber        string `json:"account_number"`
	AccountName          string `json:"account_name"`
	CurrencyID           string `json:"currency_id"` // "NGN"
	Remark               string `json:"remark"`
}

type SimulateSquadPaymentPayload struct {
	VirtualAccountNumber string `json:"virtual_account_number"`
	Amount               string `json:"amount,omitempty"`
}

type ResolveDisputePayload struct {
	Action   string `json:"action"`
	FileName string `json:"file_name"`
}

type SquadRequeryTransferPayload struct {
	TransactionReference string `json:"transaction_reference"`
}
