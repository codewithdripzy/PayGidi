package providers

import (
	"context"
	"errors"
	"os"
	"strings"

	httpclient "github.com/PayGidi/AccountService/utils/http"
)

// interface for account data
type AccountData struct {
	FirstName      string
	LastName       string
	Email          string
	Bvn            string
	BvnDateOfBirth string
	AccountNumber  string
	// add other necessary fields
}

type BvnDetails struct {
	Bvn            string `json:"bvn"`
	BvnDateOfBirth string `json:"bvnDateOfBirth"`
}

type AccountProviderResponse struct {
	AccountReference string `json:"accountReference"`
	AccountNumber    string `json:"accountNumber"`
}

func CreateAccount(accountData AccountData) (AccountProviderResponse, error) {
	bearerToken := firstNonEmpty(
		os.Getenv("MONNIFY_TOKEN"),
		os.Getenv("MONNIFY_SECRET_KEY"),
		os.Getenv("MONNIFY_ACCESS_TOKEN"),
	)
	if bearerToken == "" {
		return AccountProviderResponse{}, errors.New("monnify bearer token is not configured")
	}

	reqBody := map[string]any{
		"walletReference": accountData.AccountNumber,
		"walletName":      accountData.FirstName + " " + accountData.LastName,
		"currencyCode":    "NGN",
		"customerEmail":   accountData.Email,
		"customerName":    accountData.FirstName + " " + accountData.LastName,
		"bvnDetails":      BvnDetails{Bvn: accountData.Bvn, BvnDateOfBirth: accountData.BvnDateOfBirth},
	}

	var response AccountProviderResponse
	client := httpclient.New("https://sandbox.monnify.com").WithBearerToken(bearerToken)
	_, err := httpclient.PostJSON(client, context.Background(), "/api/v1/disbursements/wallet", reqBody, &response)
	if err != nil {
		return AccountProviderResponse{}, err
	}

	return response, nil
}

func firstNonEmpty(values ...string) string {
	for _, value := range values {
		if strings.TrimSpace(value) != "" {
			return value
		}
	}

	return ""
}
