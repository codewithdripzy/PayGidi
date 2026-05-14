package squad

import (
	"context"
	"fmt"
	"log"
	"os"
	"strings"

	"github.com/PayGidi/TransactionService/core/interfaces/responses"
	httpclient "github.com/PayGidi/TransactionService/utils/http"
)

var client = httpclient.New("").WithHeader("Accept", "application/json")

func refreshSquadClient() {
	squadKey := strings.TrimSpace(os.Getenv("SQUAD_SECRET_KEY"))
	client = client.WithHeader("Authorization", "Bearer "+squadKey)
	apiURL := strings.TrimSpace(os.Getenv("SQUAD_API_URL"))
	if apiURL != "" {
		client = client.WithBaseURL(apiURL)
	}
}

// GetCustomerTransactions fetches the transactions for a specific customer identifier from Squad.
func GetCustomerTransactions(ctx context.Context, customerIdentifier string) (bool, *string, []responses.SquadCustomerTransaction) {
	refreshSquadClient()
	var response responses.SquadResponse[[]responses.SquadCustomerTransaction]

	path := fmt.Sprintf("/virtual-account/customer/transactions/%s", customerIdentifier)
	_, err := httpclient.Get(client, ctx, path, &response)
	if err != nil {
		log.Printf("[Squad][GetCustomerTransactions] request failed: %v", err)
		errMsg := err.Error()
		return false, &errMsg, nil
	}

	if !response.Success {
		return false, &response.Message, nil
	}

	return true, nil, response.Data
}
