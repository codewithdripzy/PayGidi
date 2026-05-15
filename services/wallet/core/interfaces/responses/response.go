package responses

type VfdResponse[T any] struct {
	Status  string `json:"status"`
	Message string `json:"message"`
	Data    T      `json:"data"`
}

type GenerateAccessTokenResponseData struct {
	AccessToken string `json:"access_token"`
	Scope       string `json:"scope"`
	TokenType   string `json:"token_type"`
	ExpiresIn   int64  `json:"expires_in"`
}

type HasAccountResponseData struct {
	Firstname   string `json:"firstname"`
	Middlename  string `json:"middlename"`
	Lastname    string `json:"lastname"`
	Gender      string `json:"gender"`
	DateOfBirth string `json:"dateOfBirth"`
	PhoneNo     string `json:"phoneNo"`
	Picture     string `json:"pixBase64"`
}

type CreateClientResponseData struct {
	Firstname  string `json:"firstname"`
	Middlename string `json:"middlename"`
	Lastname   string `json:"lastname"`
	CurrenTier string `json:"currentTier"`
	AccountNo  string `json:"accountNo"`
}

type UpgradeClientResponseData struct {
	Firstname       string `json:"firstname"`
	Middlename      string `json:"middlename"`
	Lastname        string `json:"lastname"`
	CurrentTier     string `json:"currentTier"`
	BvnVerification string `json:"bvnVerification"`
	NinVerification string `json:"ninVerification"`
}

type GetAccountDetailsResponseData struct {
	AccountNo          string `json:"accountNo"`
	AccountBalance     string `json:"accountBalance"`
	AccountId          string `json:"accountId"`
	Client             string `json:"client"`
	ClientId           string `json:"clientId"`
	SavingsProductName string `json:"savingsProductName"`
}

type GetAccountBalanceResponseData struct {
	AccountNo          string `json:"accountNo"`
	AccountBalance     string `json:"accountBalance"`
	AccountId          string `json:"accountId"`
	Client             string `json:"client"`
	ClientId           string `json:"clientId"`
	SavingsProductName string `json:"savingsProductName"`
}

type GetRecipientDetailsResponseData struct {
	Name     string `json:"name"`
	ClientId string `json:"clientId"`
	Bvn      string `json:"bvn"`
	Account  struct {
		Number string `json:"number"`
		Id     string `json:"id"`
	}
	Status   string `json:"status"`
	Currency string `json:"currency"`
	Bank     string `json:"bank"`
}

type BankListResponse struct {
}

type SendMoneyResponseData struct {
	TxnId     string  `json:"txnId"`
	SessionId *string `json:"sessionId"`
	Reference *string `json:"reference"`
}

type GetTransactionStatusResponseData struct {
	TxnId             string `json:"txnId"`
	Amount            string `json:"amount"`
	AccountNo         string `json:"accountNo"`
	FromAccountNo     string `json:"fromAccountNo"`
	TransactionStatus string `json:"transactionStatus"`
	TransactionDate   string `json:"transactionDate"`
	ToBank            string `json:"toBank"`
	FromBank          string `json:"fromBank"`
	SessionId         string `json:"sessionId"`
	BankTransactionId string `json:"bankTransactionId"`
	TransactionType   string `json:"transactionType"`
}

type UpgradeAccountTierResponseData struct {
	Firstname       string `json:"firstname"`
	Middlename      string `json:"middlename"`
	Lastname        string `json:"lastname"`
	CurrentTier     string `json:"currentTier"`
	BvnVerification string `json:"bvnVerification"`
	NinVerification string `json:"ninVerification"`
}

type UpdateTransactionLimitResponseData struct {
}

type GetBankTransactionsResponseData struct {
	Content       []BankTransactionData `json:"content"`
	TotalElements int                   `json:"totalElements"`
	TotalPages    int                   `json:"totalPages"`
}

type GetWalletTransactionsResponseData struct {
	Content       []WalletTransactionData `json:"content"`
	TotalElements int                     `json:"totalElements"`
	TotalPages    int                     `json:"totalPages"`
}

type BankTransactionData struct {
	AccountNo       string `json:"accountNo"`
	ReceiptNumber   string `json:"receiptNumber"`
	Amount          string `json:"amount"`
	Remarks         string `json:"remarks"`
	CreatedDate     string `json:"createdDate"`
	TransactionType string `json:"transactionType"`
	RunningBalance  string `json:"runningBalance"`
	CurrencyCode    string `json:"currencyCode"`
	Id              string `json:"id"`
}

type WalletTransactionData struct {
	Time                string `json:"time"`
	TransactionType     string `json:"transactionType"`
	TransactionId       string `json:"transactionId"`
	WalletName          string `json:"walletName"`
	Amount              string `json:"amount"`
	ToAccountNo         string `json:"toAccountNo"`
	TransactionResponse string `json:"transactionResponse"`
	FromBank            string `json:"fromBank"`
	FromAccountNo       string `json:"fromAccountNo"`
	ToBank              string `json:"toBank"`
	SessionId           string `json:"sessionId"`
}

type CheckNINValidityResponseData struct {
	Valid          bool   `json:"valid"`
	IdNumber       string `json:"idNumber"`
	Gender         string `json:"gender"`
	PhoneNumber    string `json:"phoneNumber"`
	FullName       string `json:"fullName"`
	FirstName      string `json:"firstName"`
	LastName       string `json:"lastName"`
	MiddleName     string `json:"middleName"`
	DateOfBirth    string `json:"dateOfBirth"`
	Address        string `json:"address"`
	ExpiryDate     string `json:"expiryDate"`
	Photo          string `json:"photo"`
	Available      bool   `json:"available"`
	FirstNameMatch bool   `json:"firstNameMatch"`
	LastNameMatch  bool   `json:"lastNameMatch"`
	DobMatch       bool   `json:"dobMatch"`
}

type ImageMatchResponseData struct {
	Match   *bool `json:"match"`
	IsMatch *bool `json:"isMatch"`
	Matched *bool `json:"matched"`
}

type SquadResponse[T any] struct {
	Status  int    `json:"status"`
	Success bool   `json:"success"`
	Message string `json:"message"`
	Data    T      `json:"data"`
}

type SquadVirtualAccountResponseData struct {
	FirstName            string `json:"first_name"`
	LastName             string `json:"last_name"`
	BankAccountNumber    string `json:"bank_account_number"`
	VirtualAccountNumber string `json:"virtual_account_number"`
	BankName             string `json:"bank_name"`
	CustomerIdentifier   string `json:"customer_identifier"`
	MobileNum            string `json:"mobile_num"`
	Email                string `json:"email"`
}

type SquadInitiatePaymentResponseData struct {
	CheckoutURL string `json:"checkout_url"`
}

type SquadTransferResponseData struct {
	TransactionReference string `json:"transaction_reference"`
	Status               string `json:"status"`
}

type SquadTransactionData struct {
	Amount             int    `json:"amount"`
	TransactionRef     string `json:"transaction_ref"`
	GatewayRef         string `json:"gateway_ref"`
	TransactionType    string `json:"transaction_type"`
	CreatedAt          string `json:"created_at"`
	AccountName        string `json:"account_name"`
	BankAccountNumber  string `json:"bank_account_number"`
	SettlementAmount   int    `json:"settlement_amount"`
	Status             string `json:"status"`
}

type SquadAccountLookupResponseData struct {
	AccountNumber string `json:"account_number"`
	AccountName   string `json:"account_name"`
}

type SquadBankData struct {
	BankName string `json:"bank_name"`
	BankCode string `json:"bank_code"`
}

type SquadTransferRecord struct {
	AccountNumberCredited string `json:"account_number_credited"`
	AmountDebited         string `json:"amount_debited"`
	TotalAmountDebited    string `json:"total_amount_debited"`
	Success               bool   `json:"success"`
	Recipient             string `json:"recipient"`
	BankCode              string `json:"bank_code"`
	TransactionReference  string `json:"transaction_reference"`
	TransactionStatus     string `json:"transaction_status"`
	SwitchTransaction     any    `json:"switch_transaction"`
}
