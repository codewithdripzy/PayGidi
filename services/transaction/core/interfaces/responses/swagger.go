package responses

import "time"

// ApiResponse defines a generic API response structure for Swagger documentation.
type ApiResponse struct {
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
	Error   string      `json:"error,omitempty"`
}

type Transaction struct {
	ID               string    `json:"id"`
	Reference        string    `json:"reference"`
	Type             string    `json:"type"`
	Currency         string    `json:"currency"`
	Amount           float64   `json:"amount"`
	Fee              float64   `json:"fee"`
	Narration        string    `json:"narration"`
	Description      string    `json:"description"`
	Status           string    `json:"status"`
	Metadata         string    `json:"metadata"`
	Channel          string    `json:"channel"`
	Source           string    `json:"source"`
	BeneficiaryID    string    `json:"beneficiaryId"`
	BeneficiaryEmail string    `json:"beneficiaryEmail"`
	InitiatedBy      string    `json:"initiatedBy"`
	CompletedBy      string    `json:"completedBy"`
	ExternalRef      string    `json:"externalRef"`
	IsReconciled     bool      `json:"isReconciled"`
	IsReversal       bool      `json:"isReversal"`
	CreatedAt        time.Time `json:"createdAt"`
	UpdatedAt        time.Time `json:"updatedAt"`
	CompletedAt      time.Time `json:"completedAt"`
}

type ListTransactionsResponse struct {
	Transactions []Transaction `json:"transactions"`
	TotalCount   int           `json:"totalCount"`
	Limit        int           `json:"limit"`
	Offset       int           `json:"offset"`
	MoreRecords  bool          `json:"moreRecords"`
}

type CreateTransactionResponse struct {
	Transaction `json:"transaction"`
}

type GetTransactionResponse struct {
	Transaction `json:"transaction"`
}

type TransactionSummary struct {
	TotalCount     int64  `json:"totalCount"`
	CompletedCount int64  `json:"completedCount"`
	FailedCount    int64  `json:"failedCount"`
	PendingCount   int64  `json:"pendingCount"`
	TotalVolume    string `json:"totalVolume"`
	TotalFee       string `json:"totalFee"`
	Date           string `json:"date"`
	Filters        string `json:"filters"`
}

type ListTransactionSummaryResponse struct {
	TransactionSummary `json:"summary"`
}

type CreateTransactionSummaryResponse struct {
	TransactionSummary `json:"summary"`
}
