package payload

type WalletAccountPayload struct {
	UserID                uint
	Provider              string
	ProviderAccountNumber string
	AccountNumber         string
	AccountCategory       string
	AccountFeatures       []string
	AccountType           string
	CurrencyCode          string
	AccountReference      string
	Status                string
}
