package vfd

import (
	"net/url"
	"os"
	"strings"

	"github.com/PayGidi/AccountService/core/interfaces/payloads"
	"github.com/PayGidi/AccountService/core/interfaces/responses"
	"github.com/PayGidi/AccountService/utils"
	httpclient "github.com/PayGidi/AccountService/utils/http"
	"github.com/gin-gonic/gin"
)

var apiURL = strings.TrimSpace(os.Getenv("VFD_API_URL"))
var client = httpclient.New("").WithHeader("Accept", "application/json")

func GenerateAccessToken(c *gin.Context) (token *string, errMsg *string) {
	authURL := strings.TrimSpace(os.Getenv("VFD_AUTH_URL"))
	consumerKey := strings.TrimSpace(os.Getenv("VFD_CONSUMER_KEY"))
	consumerSecret := strings.TrimSpace(os.Getenv("VFD_CONSUMER_SECRET"))

	if authURL == "" || consumerKey == "" || consumerSecret == "" {
		errMsg := "VFD credentials are not fully configured"
		return nil, &errMsg
	}

	payload := map[string]string{
		"consumerKey":    consumerKey,
		"consumerSecret": consumerSecret,
		"validityTime":   "-1",
	}

	var response responses.VfdResponse[responses.GenerateAccessTokenResponseData]

	resp, err := httpclient.PostJSON(client, c.Request.Context(), authURL, payload, &response)
	if err != nil {
		if resp != nil {
			return nil, &response.Message
		}

		errMsg := "failed to connect to VFD auth service"
		return nil, &errMsg
	}

	if response.Status != "00" {
		return nil, &response.Message
	}

	return &response.Data.AccessToken, nil
}

func CreateNewAcccount(c *gin.Context, data payloads.CreateClientPayload) (success bool, errMsg *string, responseData *responses.CreateClientResponseData) {
	nin := data.Nin
	dateOfBirth := data.DateOfBirth

	if nin == "" || dateOfBirth == "" {
		errMsg := "NIN and Date of Birth are required to create an account"
		return false, &errMsg, nil
	}

	if apiURL == "" {
		errMsg := "VFD credentials are not fully configured"
		return false, &errMsg, nil
	}

	formattedDate, err := utils.FormatToVfdDate(dateOfBirth)
	if err != nil {
		errMsg := "failed to format date of birth"
		return false, &errMsg, nil
	}

	base, _ := url.Parse(apiURL)
	base.Path += "/client/tiers/individual"

	query := base.Query()

	query.Set("nin", nin)
	query.Set("dateOfBirth", formattedDate)

	base.RawQuery = query.Encode()

	accountCreationURL := base.String()

	payload := map[string]string{}

	var response responses.VfdResponse[responses.CreateClientResponseData]

	resp, err := httpclient.PostJSON(client, c.Request.Context(), accountCreationURL, payload, &response)
	if err != nil {
		if resp != nil {
			return false, &response.Message, nil
		}

		errMsg := "failed to connect to VFD auth service"
		return false, &errMsg, nil
	}

	if response.Status != "00" {
		return false, &response.Message, nil
	}

	return true, nil, &response.Data
}

func CheckAccountByBVN(c *gin.Context, bvn string) (exists bool, errMsg *string) {
	bvn = strings.TrimSpace(bvn)
	if bvn == "" {
		errMsg := "BVN is required"
		return false, &errMsg
	}

	if apiURL == "" {
		errMsg := "VFD credentials are not fully configured"
		return false, &errMsg
	}

	base, _ := url.Parse(apiURL)
	base.Path += "/client"

	query := base.Query()

	query.Set("bvn", bvn)

	base.RawQuery = query.Encode()
	checkClientURL := base.String()

	var response responses.VfdResponse[*responses.HasAccountResponseData]

	resp, err := httpclient.Get(client, c.Request.Context(), checkClientURL, &response)
	if err != nil {
		if resp != nil {
			// Try to decode error body to extract VFD's message when available.
			_ = resp.JSON(&response)
			if response.Message != "" {
				return false, &response.Message
			}

			errMsg := "failed to check account by BVN"
			return false, &errMsg
		}

		errMsg := "failed to connect to VFD service"
		return false, &errMsg
	}

	if response.Status != "00" {
		return false, nil
	}

	if response.Data == nil {
		return false, nil
	}

	return true, nil
}

func UpgradeAccountTier(c *gin.Context, tier int, data payloads.UpgradeAccountTierPayload) (success bool, errMsg *string) {
	accountNo := data.AccountNo
	bvn := data.BVN
	address := data.Address

	if tier != 2 && tier != 3 {
		errMsg := "Invalid tier specified. Only tier 2 and tier 3 upgrades are supported."
		return false, &errMsg
	}

	if accountNo == "" {
		errMsg := "Account Number, BVN and Address are required to upgrade"
		return false, &errMsg
	}

	if tier == 2 && bvn == nil {
		errMsg := "BVN is required to upgrade to tier two"
		return false, &errMsg
	}

	if tier == 3 && address == nil {
		errMsg := "Address is required to upgrade to tier three"
		return false, &errMsg
	}

	if apiURL == "" {
		errMsg := "VFD credentials are not fully configured"
		return false, &errMsg
	}

	if tier == 2 && bvn != nil {
		formattedBVN := strings.TrimSpace(*bvn)
		if formattedBVN == "" {
			errMsg := "BVN cannot be empty when upgrading to tier two"
			return false, &errMsg
		}

		// Check if BVN has been used by another account before attempting upgrade
		exists, checkErrMsg := CheckAccountByBVN(c, formattedBVN)
		if checkErrMsg != nil {
			return false, checkErrMsg
		}

		if exists {
			errMsg := "The provided BVN is already associated with another account. Check again or contact support if you believe this is an error."
			return false, &errMsg
		}
	}

	base, _ := url.Parse(apiURL)
	base.Path += "/client/update"

	payload := map[string]string{}

	payload["accountNo"] = accountNo

	if tier == 2 {
		payload["bvn"] = *bvn
	}

	if tier == 3 {
		payload["address"] = *address
	}

	accountUpgradeURL := base.String()

	var response responses.VfdResponse[responses.UpgradeClientResponseData]

	resp, err := httpclient.PostJSON(client, c.Request.Context(), accountUpgradeURL, payload, &response)
	if err != nil {
		if resp != nil {
			return false, &response.Message
		}

		errMsg := "failed to connect to VFD service"
		return false, &errMsg
	}

	if response.Status != "00" {
		return false, &response.Message
	}

	return true, nil
}

func GetAccountDetails(c *gin.Context, accountNo string) (data *responses.GetAccountDetailsResponseData, errMsg *string) {
	if apiURL == "" {
		errMsg := "VFD credentials are not fully configured"
		return nil, &errMsg
	}

	base, _ := url.Parse(apiURL)
	base.Path += "/account/enquiry"

	query := base.Query()

	query.Set("accountNo", accountNo)

	base.RawQuery = query.Encode()
	balanceURL := base.String()

	var response responses.VfdResponse[responses.GetAccountDetailsResponseData]

	resp, err := httpclient.Get(client, c.Request.Context(), balanceURL, &response)
	if err != nil {
		if resp != nil {
			return nil, &response.Message
		}

		errMsg := "failed to connect to VFD service"
		return nil, &errMsg
	}

	if response.Status != "00" {
		return nil, &response.Message
	}

	return &response.Data, nil
}

func GetAccountBalance(c *gin.Context, accountNo string) (balance *string, errMsg *string) {
	if apiURL == "" {
		errMsg := "VFD credentials are not fully configured"
		return nil, &errMsg
	}

	base, _ := url.Parse(apiURL)
	base.Path += "/account/enquiry"

	query := base.Query()

	query.Set("accountNo", accountNo)

	base.RawQuery = query.Encode()
	balanceURL := base.String()

	var response responses.VfdResponse[responses.GetAccountBalanceResponseData]

	resp, err := httpclient.Get(client, c.Request.Context(), balanceURL, &response)
	if err != nil {
		if resp != nil {
			return nil, &response.Message
		}

		errMsg := "failed to connect to VFD service"
		return nil, &errMsg
	}

	if response.Status != "00" {
		return nil, &response.Message
	}

	return &response.Data.AccountBalance, nil
}

func GetRecipientDetails(c *gin.Context, accountNo string, bankCode string) (data *responses.GetRecipientDetailsResponseData, errMsg *string) {
	if apiURL == "" {
		errMsg := "VFD credentials are not fully configured"
		return nil, &errMsg
	}

	base, _ := url.Parse(apiURL)
	base.Path += "/transfer/recipient"

	query := base.Query()

	query.Set("accountNo", accountNo)
	query.Set("bank", bankCode)
	query.Set("transfer_type", "intra")

	base.RawQuery = query.Encode()
	resolveURL := base.String()

	var response responses.VfdResponse[responses.GetRecipientDetailsResponseData]

	resp, err := httpclient.Get(client, c.Request.Context(), resolveURL, &response)
	if err != nil {
		if resp != nil {
			return nil, &response.Message
		}

		errMsg := "failed to connect to VFD service"
		return nil, &errMsg
	}

	if response.Status != "00" {
		return nil, &response.Message
	}

	return &response.Data, nil
}

func GetBanks(c *gin.Context) (success bool, errMsg *string, responseData *responses.BankListResponse) {
	if apiURL == "" {
		errMsg := "VFD credentials are not fully configured"
		return false, &errMsg, nil
	}

	base, _ := url.Parse(apiURL)
	base.Path += "/bank"

	banksURL := base.String()

	var response responses.VfdResponse[responses.BankListResponse]

	resp, err := httpclient.Get(client, c.Request.Context(), banksURL, &response)
	if err != nil {
		if resp != nil {
			_ = resp.JSON(&response)
			if response.Message != "" {
				return false, &response.Message, nil
			}

			errMsg := "failed to fetch banks"
			return false, &errMsg, nil
		}

		errMsg := "failed to connect to VFD service"
		return false, &errMsg, nil
	}

	if response.Status != "00" {
		return false, &response.Message, nil
	}

	return true, nil, &response.Data

}

func SendMoney(c *gin.Context, data payloads.SendMoneyPayload) (success bool, errMsg *string) {
	if apiURL == "" {
		errMsg := "VFD credentials are not fully configured"
		return false, &errMsg
	}

	base, _ := url.Parse(apiURL)
	base.Path += "/transfer"

	transactionURL := base.String()

	// 	payload := map[string]string{}

	var response responses.VfdResponse[responses.SendMoneyResponseData]

	resp, err := httpclient.PostJSON(client, c.Request.Context(), transactionURL, data, &response)
	if err != nil {
		if resp != nil {
			return false, &response.Message
		}

		errMsg := "failed to connect to VFD transaction service"
		return false, &errMsg
	}

	if response.Status != "00" {
		// handle transfer error response from VFD

		return false, &response.Message
	}

	return true, nil
}

func GetTransactionStatus(c *gin.Context, transactionRef string) (data *responses.GetTransactionStatusResponseData, errMsg *string) {
	if apiURL == "" {
		errMsg := "VFD credentials are not fully configured"
		return nil, &errMsg
	}

	base, _ := url.Parse(apiURL)
	base.Path += "/transfer/status"

	query := base.Query()

	query.Set("reference", transactionRef)

	base.RawQuery = query.Encode()
	statusURL := base.String()

	var response responses.VfdResponse[responses.GetTransactionStatusResponseData]

	resp, err := httpclient.Get(client, c.Request.Context(), statusURL, &response)
	if err != nil {
		if resp != nil {
			return nil, &response.Message
		}

		errMsg := "failed to connect to VFD service"
		return nil, &errMsg
	}

	if response.Status != "00" {
		return nil, &response.Message
	}

	return &response.Data, nil
}
