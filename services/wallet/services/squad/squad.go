package squad

import (
	"context"
	"fmt"
	"log"
	"os"
	"strings"

	"github.com/PayGidi/WalletService/core/constants"
	"github.com/PayGidi/WalletService/core/interfaces/payloads"
	"github.com/PayGidi/WalletService/core/interfaces/responses"
	httpclient "github.com/PayGidi/WalletService/utils/http"
)

var client *httpclient.Client

func init() {
	refreshSquadClient()
}

func refreshSquadClient() {
	baseURL := strings.TrimSpace(constants.SQUAD_API_URL)
	if baseURL == "" {
		baseURL = strings.TrimSpace(os.Getenv("SQUAD_API_URL"))
	}
	secretKey := strings.TrimSpace(constants.SQUAD_SECRET_KEY)
	if secretKey == "" {
		secretKey = strings.TrimSpace(os.Getenv("SQUAD_SECRET_KEY"))
	}

	client = httpclient.New(baseURL).
		WithHeader("Accept", "application/json").
		WithBearerToken(secretKey)
}

// CreateVirtualAccount creates a static virtual account for holding user funds.
func CreateVirtualAccount(ctx context.Context, payload payloads.CreateSquadVirtualAccountPayload) (bool, *string, *responses.SquadVirtualAccountResponseData) {
	refreshSquadClient()
	if payload.BeneficiaryAccount == "" {
		payload.BeneficiaryAccount = constants.SQUAD_BENEFICIARY_ACCOUNT
	}
	log.Printf("[Squad][CreateVirtualAccount] using beneficiary account: %s", payload.BeneficiaryAccount)
	var response responses.SquadResponse[responses.SquadVirtualAccountResponseData]

	_, err := httpclient.PostJSON(client, ctx, "/virtual-account", payload, &response)
	if err != nil {
		log.Printf("[Squad][CreateVirtualAccount] request failed: %v", err)
		errMsg := err.Error()
		return false, &errMsg, nil
	}

	return true, nil, &response.Data
}

// CreateBusinessVirtualAccount creates a static virtual account for businesses.
func CreateBusinessVirtualAccount(ctx context.Context, payload payloads.CreateSquadBusinessVirtualAccountPayload) (bool, *string, *responses.SquadVirtualAccountResponseData) {
	refreshSquadClient()
	if payload.BeneficiaryAccount == "" {
		payload.BeneficiaryAccount = constants.SQUAD_BENEFICIARY_ACCOUNT
	}
	log.Printf("[Squad][CreateBusinessVirtualAccount] using beneficiary account: %s", payload.BeneficiaryAccount)
	var response responses.SquadResponse[responses.SquadVirtualAccountResponseData]

	_, err := httpclient.PostJSON(client, ctx, "/virtual-account/business", payload, &response)
	if err != nil {
		log.Printf("[Squad][CreateBusinessVirtualAccount] request failed: %v", err)
		errMsg := err.Error()
		return false, &errMsg, nil
	}

	if !response.Success {
		log.Printf("[Squad][CreateBusinessVirtualAccount] provider error: %s", response.Message)
		return false, &response.Message, nil
	}

	return true, nil, &response.Data
}

// CreateDynamicVirtualAccount creates a dynamic virtual account for creating a specific payment.
func CreateDynamicVirtualAccount(ctx context.Context, payload payloads.CreateSquadDynamicVirtualAccountPayload) (bool, *string, *responses.SquadVirtualAccountResponseData) {
	refreshSquadClient()
	var response responses.SquadResponse[responses.SquadVirtualAccountResponseData]

	_, err := httpclient.PostJSON(client, ctx, "/virtual-account/create-dynamic-virtual-account", payload, &response)
	if err != nil {
		log.Printf("[Squad][CreateDynamicVirtualAccount] request failed: %v", err)
		errMsg := err.Error()
		return false, &errMsg, nil
	}

	if !response.Success {
		log.Printf("[Squad][CreateDynamicVirtualAccount] provider error: %s", response.Message)
		return false, &response.Message, nil
	}

	return true, nil, &response.Data
}

// InitiatePayment generates a checkout link that the customer can share to the merchant.
func InitiatePayment(ctx context.Context, payload payloads.InitiateSquadPaymentPayload) (bool, *string, *responses.SquadInitiatePaymentResponseData) {
	refreshSquadClient()
	var response responses.SquadResponse[responses.SquadInitiatePaymentResponseData]

	_, err := httpclient.PostJSON(client, ctx, "/transaction/initiate", payload, &response)
	if err != nil {
		log.Printf("[Squad][InitiatePayment] request failed: %v", err)
		errMsg := err.Error()
		return false, &errMsg, nil
	}

	if !response.Success {
		log.Printf("[Squad][InitiatePayment] provider error: %s", response.Message)
		return false, &response.Message, nil
	}

	return true, nil, &response.Data
}

// InitiateTransfer moves funds from the static to the dynamic account, or to an external account.
func InitiateTransfer(ctx context.Context, payload payloads.SquadTransferPayload) (bool, *string, *responses.SquadTransferResponseData) {
	refreshSquadClient()
	var response responses.SquadResponse[responses.SquadTransferResponseData]

	// Ensure amount is in kobo (if it's not already handled by the caller)
	_, err := httpclient.PostJSON(client, ctx, "/payout", payload, &response)
	if err != nil {
		log.Printf("[Squad][InitiateTransfer] request failed: %v", err)
		errMsg := err.Error()
		return false, &errMsg, nil
	}

	if !response.Success {
		log.Printf("[Squad][InitiateTransfer] provider error: %s", response.Message)
		return false, &response.Message, nil
	}

	return true, nil, &response.Data
}

// ResolveAccount performs beneficiary name inquiry.
func ResolveAccount(ctx context.Context, payload payloads.SquadAccountLookupPayload) (bool, *string, *responses.SquadAccountLookupResponseData) {
	refreshSquadClient()
	var response responses.SquadResponse[responses.SquadAccountLookupResponseData]

	_, err := httpclient.PostJSON(client, ctx, "/payout/account/lookup", payload, &response)
	if err != nil {
		log.Printf("[Squad][ResolveAccount] request failed: %v", err)
		errMsg := err.Error()
		return false, &errMsg, nil
	}

	if !response.Success {
		return false, &response.Message, nil
	}

	return true, nil, &response.Data
}

// GetCustomerTransactions retrieves transaction history for a specific customer identifier.
func GetCustomerTransactions(ctx context.Context, customerIdentifier string) (bool, *string, []responses.SquadTransactionData) {
	refreshSquadClient()
	var response responses.SquadResponse[[]responses.SquadTransactionData]

	path := fmt.Sprintf("/virtual-account/customer/transactions/%s", customerIdentifier)
	_, err := httpclient.Get(client, ctx, path, &response)
	if err != nil {
		log.Printf("[Squad][GetCustomerTransactions] request failed: %v", err)
		errMsg := err.Error()
		return false, &errMsg, nil
	}

	if !response.Success {
		log.Printf("[Squad][GetCustomerTransactions] provider error: %s", response.Message)
		return false, &response.Message, nil
	}

	return true, nil, response.Data
}

// GetVirtualAccount retrieves virtual account details from Squad API by virtual account number.
func GetVirtualAccount(ctx context.Context, virtualAccountNumber string) (bool, *string, *responses.SquadVirtualAccountResponseData) {
	refreshSquadClient()
	var response responses.SquadResponse[responses.SquadVirtualAccountResponseData]

	path := fmt.Sprintf("/virtual-account/customer/%s", virtualAccountNumber)
	_, err := httpclient.Get(client, ctx, path, &response)
	if err != nil {
		log.Printf("[Squad][GetVirtualAccount] request failed: %v", err)
		errMsg := err.Error()
		return false, &errMsg, nil
	}

	if !response.Success {
		log.Printf("[Squad][GetVirtualAccount] provider error: %s", response.Message)
		return false, &response.Message, nil
	}

	return true, nil, &response.Data
}

// SimulatePayment simulates a payment to a virtual account.
func SimulatePayment(ctx context.Context, payload payloads.SimulateSquadPaymentPayload) (bool, *string, any) {
	refreshSquadClient()
	var response responses.SquadResponse[any]

	_, err := httpclient.PostJSON(client, ctx, "/virtual-account/simulate/payment", payload, &response)
	if err != nil {
		log.Printf("[Squad][SimulatePayment] request failed: %v", err)
		errMsg := err.Error()
		return false, &errMsg, nil
	}

	if !response.Success {
		log.Printf("[Squad][SimulatePayment] provider error: %s", response.Message)
		return false, &response.Message, nil
	}

	return true, nil, response.Data
}

// GetBanks retrieves the list of supported banks for transfer.
func GetBanks(ctx context.Context) (bool, *string, []responses.SquadBankData) {
	refreshSquadClient()
	var response responses.SquadResponse[[]responses.SquadBankData]

	// The endpoint for fetching bank list in Squad is typically /payout/banks
	_, err := httpclient.Get(client, ctx, "/payout/banks", &response)
	if err != nil {
		log.Printf("[Squad][GetBanks] request failed: %v", err)
		errMsg := err.Error()
		return false, &errMsg, nil
	}

	if !response.Success {
		return false, &response.Message, nil
	}

	return true, nil, response.Data
}

// GetAllDisputes retrieves all disputes raised on your transactions.
func GetAllDisputes(ctx context.Context) (bool, *string, any) {
	refreshSquadClient()
	var response responses.SquadResponse[any]

	_, err := httpclient.Get(client, ctx, "/dispute", &response)
	if err != nil {
		log.Printf("[Squad][GetAllDisputes] request failed: %v", err)
		errMsg := err.Error()
		return false, &errMsg, nil
	}

	if !response.Success {
		return false, &response.Message, nil
	}

	return true, nil, response.Data
}

// GetDisputeUploadURL retrieves a unique URL to upload evidence for a dispute.
func GetDisputeUploadURL(ctx context.Context, ticketId, fileName string) (bool, *string, any) {
	refreshSquadClient()
	var response responses.SquadResponse[any]

	path := fmt.Sprintf("/dispute/upload-url/%s/%s", ticketId, fileName)
	_, err := httpclient.Get(client, ctx, path, &response)
	if err != nil {
		log.Printf("[Squad][GetDisputeUploadURL] request failed: %v", err)
		errMsg := err.Error()
		return false, &errMsg, nil
	}

	if !response.Success {
		return false, &response.Message, nil
	}

	return true, nil, response.Data
}

// ResolveDispute resolves a dispute by accepting or rejecting it.
func ResolveDispute(ctx context.Context, ticketId string, payload payloads.ResolveDisputePayload) (bool, *string, any) {
	refreshSquadClient()
	var response responses.SquadResponse[any]

	path := fmt.Sprintf("/dispute/%s/resolve", ticketId)
	_, err := httpclient.PostJSON(client, ctx, path, payload, &response)
	if err != nil {
		log.Printf("[Squad][ResolveDispute] request failed: %v", err)
		errMsg := err.Error()
		return false, &errMsg, nil
	}

	if !response.Success {
		return false, &response.Message, nil
	}

	return true, nil, response.Data
}

// GetAllTransfers retrieves the details of all transfers done from your Squad Wallet.
func GetAllTransfers(ctx context.Context) (bool, *string, []responses.SquadTransferRecord) {
	refreshSquadClient()
	var response responses.SquadResponse[[]responses.SquadTransferRecord]

	_, err := httpclient.Get(client, ctx, "/payout/list", &response)
	if err != nil {
		log.Printf("[Squad][GetAllTransfers] request failed: %v", err)
		errMsg := err.Error()
		return false, &errMsg, nil
	}

	if !response.Success {
		return false, &response.Message, nil
	}

	return true, nil, response.Data
}

// RequeryTransfer allows you to re-query the status of a transfer.
func RequeryTransfer(ctx context.Context, transactionReference string) (bool, *string, any) {
	refreshSquadClient()
	var response responses.SquadResponse[any]

	payload := payloads.SquadRequeryTransferPayload{
		TransactionReference: transactionReference,
	}

	_, err := httpclient.PostJSON(client, ctx, "/payout/requery", payload, &response)
	if err != nil {
		log.Printf("[Squad][RequeryTransfer] request failed: %v", err)
		errMsg := err.Error()
		return false, &errMsg, nil
	}

	if !response.Success {
		return false, &response.Message, nil
	}

	return true, nil, response.Data
}
