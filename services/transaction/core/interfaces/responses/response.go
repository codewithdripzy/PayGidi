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
