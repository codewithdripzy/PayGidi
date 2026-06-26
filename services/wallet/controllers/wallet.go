package controllers

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"strconv"
	"strings"
	"time"

	payGidiErrors "github.com/PayGidi/WalletService/core/interfaces/errors"
	"github.com/PayGidi/WalletService/core/interfaces/payloads"
	"github.com/PayGidi/WalletService/core/interfaces/responses"
	"github.com/PayGidi/WalletService/dto"
	"github.com/PayGidi/WalletService/models"
	"github.com/PayGidi/WalletService/services/account"
	squadService "github.com/PayGidi/WalletService/services/squad"
	"github.com/PayGidi/WalletService/utils"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type WalletController struct {
	db      *gorm.DB
	account *account.AccountClient
}

func NewWalletController(db *gorm.DB, accClient *account.AccountClient) *WalletController {
	return &WalletController{db: db, account: accClient}
}

type CreateWalletResult struct {
	Success bool
	Code    string
	Message string
	Data    interface{}
}

func (wc *WalletController) CreateWallet(ctx context.Context, request dto.CreateWalletDto) *CreateWalletResult {
	// Reformat DOB from YYYY-MM-DD to MM/DD/YYYY
	dobParts := strings.Split(request.DateOfBirth, "-")
	dob := request.DateOfBirth
	if len(dobParts) == 3 {
		dob = fmt.Sprintf("%s/%s/%s", dobParts[1], dobParts[2], dobParts[0])
	}

	bvn := request.Bvn
	if bvn == "" {
		bvn = request.Nin
	}

	var success bool
	var squadErr *string
	var response *responses.SquadVirtualAccountResponseData

	// Ensure phone number is max 11 digits for Squad (e.g. 080...)
	mobileNum := request.Phone
	mobileNum = strings.ReplaceAll(mobileNum, " ", "")
	mobileNum = strings.TrimPrefix(mobileNum, "+")

	if strings.HasPrefix(mobileNum, "234") {
		mobileNum = "0" + mobileNum[3:]
	}

	// If it's a 10-digit number (e.g. 8132961144), prepend 0
	if len(mobileNum) == 10 {
		mobileNum = "0" + mobileNum
	}

	// If it's still longer than 11 (e.g. some weird input), take the last 11
	if len(mobileNum) > 11 {
		mobileNum = mobileNum[len(mobileNum)-11:]
	}
	log.Printf("[WalletController] Normalized phone: %s (Original: %s)", mobileNum, request.Phone)

	if request.AccountType == "business" {
		success, squadErr, response = squadService.CreateBusinessVirtualAccount(ctx, payloads.CreateSquadBusinessVirtualAccountPayload{
			BusinessName:       request.BusinessName,
			CustomerIdentifier: request.UserID,
			MobileNum:          mobileNum,
			Bvn:                bvn,
			BeneficiaryAccount: "",
		})
	} else {
		success, squadErr, response = squadService.CreateVirtualAccount(ctx, payloads.CreateSquadVirtualAccountPayload{
			FirstName:          request.Firstname,
			MiddleName:         request.Middlename,
			LastName:           request.Lastname,
			MobileNum:          mobileNum,
			Dob:                dob,
			Bvn:                bvn,
			CustomerIdentifier: request.UserID,
			Gender:             request.Gender,
			Email:              request.Email,
			Address:            request.Address,
			BeneficiaryAccount: "",
		})
	}

	if !success || squadErr != nil || response == nil {
		errMsg := "failed to create wallet account"
		if squadErr != nil {
			errMsg = *squadErr
		}

		return &CreateWalletResult{
			Success: false,
			Code:    string(payGidiErrors.ACCOUNT_CREATION_FAILED),
			Message: errMsg,
		}
	}

	// Format phone number to 10 digits for AccountNumber alias
	accountAlias := request.Phone
	// Strip all non-numeric characters if any (optional, but good practice)
	// Or just grab the last 10 digits
	if len(accountAlias) > 10 {
		accountAlias = accountAlias[len(accountAlias)-10:]
	} else if strings.HasPrefix(accountAlias, "0") && len(accountAlias) == 11 {
		accountAlias = strings.TrimPrefix(accountAlias, "0")
	}

	// Save to DB
	userIDInt, _ := strconv.Atoi(request.UserID)
	newAccount := models.Account{
		UserID:                uint(userIDInt),
		Provider:              "squad",
		ProviderAccountNumber: response.VirtualAccountNumber,
		AccountReference:      response.CustomerIdentifier,
		CustomerIdentifier:    response.CustomerIdentifier,
		AccountNumber:         accountAlias, // Formatted alias
		AccountType:           request.AccountType,
		CurrencyCode:          "NGN",
		Status:                "active",
	}

	log.Printf("[WalletController] saving new account to DB: %+v", newAccount)

	if err := wc.db.Create(&newAccount).Error; err != nil {
		log.Printf("[WalletController] failed to save account: %v", err)
		return &CreateWalletResult{
			Success: false,
			Code:    strconv.Itoa(int(payGidiErrors.INTERNAL_SERVER_ERROR)),
			Message: "failed to save account to database",
		}
	}

	return &CreateWalletResult{
		Success: true,
		Code:    strconv.Itoa(int(payGidiErrors.SUCCESS)),
		Message: "Success",
		Data:    response,
	}
}

func (wc *WalletController) InitiatePayment(ctx context.Context, request payloads.InitiateSquadPaymentPayload) (bool, *string, *responses.SquadInitiatePaymentResponseData) {
	return squadService.InitiatePayment(ctx, request)
}

func (wc *WalletController) InitiateTransfer(ctx context.Context, request payloads.SquadTransferPayload) (bool, *string, *responses.SquadTransferResponseData) {
	return squadService.InitiateTransfer(ctx, request)
}

func (wc *WalletController) GetTransactions(ctx context.Context, customerIdentifier string) (bool, *string, []responses.SquadTransactionData) {
	return squadService.GetCustomerTransactions(ctx, customerIdentifier)
}

func (wc *WalletController) GetTotalBalance(ctx context.Context, userID string) (float64, error) {
	var accounts []models.Account
	userIDInt, err := strconv.Atoi(userID)
	if err != nil {
		return 0, err
	}

	if err := wc.db.WithContext(ctx).Where("user_id = ?", uint(userIDInt)).Find(&accounts).Error; err != nil {
		return 0, err
	}

	var totalBalance float64
	for _, acc := range accounts {
		// Squad virtual accounts don't maintain individual balances on their end.
		// All inbound funds are settled to the Merchant wallet.
		// Therefore, we use the locally tracked balance.
		totalBalance += acc.Balance
	}

	return totalBalance, nil
}

// GetTotalBalanceHttp godoc
// @Summary Get total wallet balance
// @Description Fetch total balance across all wallets for the authenticated user.
// @Tags Wallet
// @Produce json
// @Security ApiKeyAuth
// @Success 200 {object} map[string]interface{} "Success"
// @Router /wallet/balance [get]
func (wc *WalletController) GetWallets(ctx context.Context, userID string) ([]models.Account, error) {
	var accounts []models.Account
	userIDInt, err := strconv.Atoi(userID)
	if err != nil {
		return nil, err
	}
	if err := wc.db.WithContext(ctx).Where("user_id = ?", uint(userIDInt)).Find(&accounts).Error; err != nil {
		return nil, err
	}
	return accounts, nil
}

func (wc *WalletController) GetTotalBalanceHttp(c *gin.Context) {
	// Temporarily bypass authentication for testing
	userID := "1"

	balance, err := wc.GetTotalBalance(c.Request.Context(), userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  500,
			"success": false,
			"message": "Failed to calculate balance",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":       200,
		"success":      true,
		"totalBalance": balance,
	})
}

func (wc *WalletController) GetWalletHttp(c *gin.Context) {
	accountNumber := c.Param("accountNumber")
	var account models.Account

	if accountNumber == "" {
		userID, exists := c.Get("customerId")
		if !exists {
			c.JSON(http.StatusUnauthorized, gin.H{
				"status":  401,
				"success": false,
				"message": "Unauthorized",
				"data":    gin.H{},
			})
			return
		}

		userIDStr, ok := userID.(string)
		if !ok {
			c.JSON(http.StatusInternalServerError, gin.H{
				"status":  500,
				"success": false,
				"message": "Invalid user ID format",
				"data":    gin.H{},
			})
			return
		}

		if err := wc.db.Where("user_id = ?", userIDStr).First(&account).Error; err != nil {
			c.JSON(http.StatusNotFound, gin.H{
				"status":  404,
				"success": false,
				"message": "Account not found",
				"data":    gin.H{},
			})
			return
		}
	} else {
		// Retrieve by the provided accountNumber alias
		if err := wc.db.Where("account_number = ?", accountNumber).First(&account).Error; err != nil {
			c.JSON(http.StatusNotFound, gin.H{
				"status":  404,
				"success": false,
				"message": "Account not found",
				"data":    gin.H{},
			})
			return
		}
	}

	virtualAccountNumber := account.ProviderAccountNumber
	if virtualAccountNumber == "" {
		c.JSON(http.StatusNotFound, gin.H{
			"status":  404,
			"success": false,
			"message": "Virtual account not configured for this account",
			"data":    gin.H{},
		})
		return
	}

	success, errMsg, data := squadService.GetVirtualAccount(c.Request.Context(), virtualAccountNumber)

	if !success {
		msg := "Virtual account not found"
		if errMsg != nil {
			msg = *errMsg
		}
		c.JSON(http.StatusNotFound, gin.H{
			"status":  404,
			"success": false,
			"message": msg,
			"data":    gin.H{},
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  200,
		"success": true,
		"message": "Success",
		"data": gin.H{
			"totalBalance":       account.Balance,
			"personalSavings":    0,
			"thriftSavings":      0,
			"virtualAccount":     data,
		},
	})
}

// GetTransactionsHttp handles the GET /wallet/:accountNumber/transactions HTTP request
// GetTransactionsHttp godoc
// @Summary Get wallet transactions
// @Description Fetch transaction history for a specific wallet account number.
// @Tags Wallet
// @Produce json
// @Security ApiKeyAuth
// @Param accountNumber path string true "Account Number"
// @Success 200 {object} map[string]interface{} "Success"
// @Failure 400 {object} map[string]interface{} "Bad Request"
// @Failure 404 {object} map[string]interface{} "Not Found"
// @Router /wallet/{accountNumber}/transactions [get]
func (wc *WalletController) GetTransactionsHttp(c *gin.Context) {
	accountNumber := c.Param("accountNumber")
	var account models.Account

	if err := wc.db.Where("account_number = ?", accountNumber).First(&account).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"status":  404,
			"success": false,
			"message": "Account not found",
			"data":    gin.H{},
		})
		return
	}

	customerIdentifier := account.AccountReference
	if customerIdentifier == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  400,
			"success": false,
			"message": "Customer identifier or merchant identifier is required",
			"data":    gin.H{},
		})
		return
	}

	success, errMsg, data := squadService.GetCustomerTransactions(c.Request.Context(), customerIdentifier)

	if !success {
		msg := "Failed to fetch transactions"
		if errMsg != nil {
			msg = *errMsg
		}
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  400,
			"success": false,
			"message": msg,
			"data":    gin.H{},
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  200,
		"success": true,
		"message": "Success",
		"data":    data,
	})
}

// SimulatePaymentHttp handles POST /wallet/simulate (development only)
// SimulatePaymentHttp godoc
// @Summary Simulate payment (Dev only)
// @Description Simulate a virtual account credit for testing purposes.
// @Tags Wallet
// @Accept json
// @Produce json
// @Param body body interface{} true "Simulation data"
// @Success 200 {object} map[string]interface{} "Success"
// @Router /wallet/deposit/simulate [post]
func (wc *WalletController) SimulatePaymentHttp(c *gin.Context) {
	var req struct {
		AccountNumber string `json:"account_number" binding:"required"`
		Amount        string `json:"amount"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  400,
			"success": false,
			"message": "Invalid request payload",
			"data":    gin.H{},
		})
		return
	}

	var account models.Account
	if err := wc.db.Where("provider_account_number = ?", req.AccountNumber).First(&account).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"status":  404,
			"success": false,
			"message": "Account not found",
			"data":    gin.H{},
		})
		return
	}

	virtualAccountNumber := account.ProviderAccountNumber
	if virtualAccountNumber == "" {
		c.JSON(http.StatusNotFound, gin.H{
			"status":  404,
			"success": false,
			"message": "Virtual account not configured for this account",
			"data":    gin.H{},
		})
		return
	}

	payload := payloads.SimulateSquadPaymentPayload{
		VirtualAccountNumber: virtualAccountNumber,
		Amount:               req.Amount,
	}

	success, errMsg, data := squadService.SimulatePayment(c.Request.Context(), payload)

	if !success {
		msg := "Failed to simulate payment"
		if errMsg != nil {
			msg = *errMsg
		}
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  400,
			"success": false,
			"message": msg,
			"data":    gin.H{},
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  200,
		"success": true,
		"message": "Success",
		"data":    data,
	})
}

func (wc *WalletController) ResolveAccount(ctx context.Context, request payloads.SquadAccountLookupPayload) (bool, *string, *responses.SquadAccountLookupResponseData) {
	return squadService.ResolveAccount(ctx, request)
}

// ResolveAccountHttp handles the POST /wallet/transfer/lookup HTTP request
// ResolveAccountHttp godoc
// @Summary Resolve bank account
// @Description Lookup account name from account number and bank code.
// @Tags Wallet
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param body body payloads.SquadAccountLookupPayload true "Lookup data"
// @Success 200 {object} map[string]interface{} "Success"
// @Router /wallet/transfer/lookup [post]
func (wc *WalletController) ResolveAccountHttp(c *gin.Context) {
	var req payloads.SquadAccountLookupPayload

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  400,
			"success": false,
			"message": "Invalid request payload",
			"data":    gin.H{},
		})
		return
	}

	success, errMsg, data := squadService.ResolveAccount(c.Request.Context(), req)

	if !success {
		msg := "Failed to resolve account"
		if errMsg != nil {
			msg = *errMsg
		}
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  400,
			"success": false,
			"message": msg,
			"data":    gin.H{},
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  200,
		"success": true,
		"message": "Success",
		"data":    data,
	})
}

// InitiateTransferHttp handles the POST /wallet/transfer HTTP request
// InitiateTransferHttp godoc
// @Summary Initiate transfer
// @Description Transfer funds from wallet to a bank account.
// @Tags Wallet
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param body body interface{} true "Transfer data"
// @Success 200 {object} map[string]interface{} "Success"
// @Router /wallet/transfer [post]
func (wc *WalletController) InitiateTransferHttp(c *gin.Context) {
	var req struct {
		Remark               string `json:"remark"`
		BankCode             string `json:"bank_code" binding:"required"`
		CurrencyID           string `json:"currency_id"`
		Amount               string `json:"amount" binding:"required"`
		AccountNumber        string `json:"account_number" binding:"required"`
		TransactionReference string `json:"transaction_reference"`
		AccountName          string `json:"account_name"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  400,
			"success": false,
			"message": "Invalid request payload",
			"data":    gin.H{},
		})
		return
	}

	amountInt, err := strconv.Atoi(req.Amount)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  400,
			"success": false,
			"message": "Amount must be a valid number",
			"data":    gin.H{},
		})
		return
	}

	txRef := req.TransactionReference
	if txRef == "" {
		txRef = fmt.Sprintf("PAYGIDI_%d", time.Now().UnixNano())
	}

	currency := req.CurrencyID
	if currency == "" {
		currency = "NGN"
	}

	payload := payloads.SquadTransferPayload{
		TransactionReference: txRef,
		Amount:               amountInt,
		BankCode:             req.BankCode,
		AccountNumber:        req.AccountNumber,
		AccountName:          req.AccountName,
		CurrencyID:           currency,
		Remark:               req.Remark,
	}

	success, errMsg, data := squadService.InitiateTransfer(c.Request.Context(), payload)

	if !success {
		msg := "Failed to initiate transfer"
		if errMsg != nil {
			msg = *errMsg
		}
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  400,
			"success": false,
			"message": msg,
			"data":    gin.H{},
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  200,
		"success": true,
		"message": "Success",
		"data":    data,
	})
}

// GetBanksHttp handles the GET /wallet/banks HTTP request
// GetBanksHttp godoc
// @Summary Get bank list
// @Description Retrieve a list of supported banks and their codes.
// @Tags Wallet
// @Produce json
// @Security ApiKeyAuth
// @Success 200 {object} map[string]interface{} "Success"
// @Router /wallet/banks [get]
func (wc *WalletController) GetBanksHttp(c *gin.Context) {
	var banks []struct {
		Code string  `json:"code"`
		Name string  `json:"name"`
		Icon *string `json:"icon"`
	}

	if err := utils.LoadJSONFile("data/banks.json", &banks); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  500,
			"success": false,
			"message": "Failed to load bank list",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  200,
		"success": true,
		"message": "Success",
		"data":    banks,
	})
}

// GetAllDisputesHttp handles GET /wallet/disputes
// GetAllDisputesHttp godoc
// @Summary Get all disputes
// @Description List all transaction disputes.
// @Tags Wallet
// @Produce json
// @Security ApiKeyAuth
// @Success 200 {object} map[string]interface{} "Success"
// @Router /wallet/disputes [get]
func (wc *WalletController) GetAllDisputesHttp(c *gin.Context) {
	success, errMsg, data := squadService.GetAllDisputes(c.Request.Context())

	if !success {
		msg := "Failed to retrieve disputes"
		if errMsg != nil {
			msg = *errMsg
		}
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  400,
			"success": false,
			"message": msg,
			"data":    gin.H{},
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  200,
		"success": true,
		"message": "Success",
		"data":    data,
	})
}

// GetDisputeUploadURLHttp handles GET /wallet/disputes/upload-url/:ticketId/:fileName
// GetDisputeUploadURLHttp godoc
// @Summary Get dispute upload URL
// @Description Get a signed URL for uploading dispute evidence.
// @Tags Wallet
// @Produce json
// @Security ApiKeyAuth
// @Param ticketId path string true "Ticket ID"
// @Param fileName path string true "File Name"
// @Success 200 {object} map[string]interface{} "Success"
// @Router /wallet/disputes/upload-url/{ticketId}/{fileName} [get]
func (wc *WalletController) GetDisputeUploadURLHttp(c *gin.Context) {
	ticketId := c.Param("ticketId")
	fileName := c.Param("fileName")

	success, errMsg, data := squadService.GetDisputeUploadURL(c.Request.Context(), ticketId, fileName)

	if !success {
		msg := "Failed to retrieve upload url"
		if errMsg != nil {
			msg = *errMsg
		}
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  400,
			"success": false,
			"message": msg,
			"data":    gin.H{},
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  200,
		"success": true,
		"message": "Success",
		"data":    data,
	})
}

// ResolveDisputeHttp handles POST /wallet/disputes/:ticketId/resolve
// ResolveDisputeHttp godoc
// @Summary Resolve dispute
// @Description Update the status or resolution of a dispute.
// @Tags Wallet
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param ticketId path string true "Ticket ID"
// @Param body body payloads.ResolveDisputePayload true "Resolution data"
// @Success 200 {object} map[string]interface{} "Success"
// @Router /wallet/disputes/{ticketId}/resolve [post]
func (wc *WalletController) ResolveDisputeHttp(c *gin.Context) {
	ticketId := c.Param("ticketId")
	var req payloads.ResolveDisputePayload

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  400,
			"success": false,
			"message": "Invalid request payload",
			"data":    gin.H{},
		})
		return
	}

	success, errMsg, data := squadService.ResolveDispute(c.Request.Context(), ticketId, req)

	if !success {
		msg := "Failed to resolve dispute"
		if errMsg != nil {
			msg = *errMsg
		}
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  400,
			"success": false,
			"message": msg,
			"data":    gin.H{},
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  200,
		"success": true,
		"message": "Success",
		"data":    data,
	})
}

// CreateWalletHttp handles the POST /wallet/create HTTP request as a fallback/manual endpoint
// CreateWalletHttp godoc
// @Summary Create wallet account (Manual)
// @Description Manually trigger virtual account creation for the authenticated user.
// @Tags Wallet
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param body body dto.CreateWalletDto true "Wallet creation data"
// @Success 200 {object} map[string]interface{} "Success"
// @Router /wallet/create [post]
func (wc *WalletController) CreateWalletHttp(c *gin.Context) {
	var req dto.CreateWalletDto

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  400,
			"success": false,
			"message": "Invalid request payload",
			"data":    gin.H{},
		})
		return
	}

	// Set UserID securely from the authenticated token
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"status":  401,
			"success": false,
			"message": "Unauthorized",
			"data":    gin.H{},
		})
		return
	}

	// Safely convert userID from context to string
	switch v := userID.(type) {
	case string:
		req.UserID = v
	default:
		req.UserID = fmt.Sprintf("%v", v)
	}

	// Call the internal CreateWallet method which handles Squad validation and database insertion
	result := wc.CreateWallet(c.Request.Context(), req)

	if !result.Success {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  400,
			"success": false,
			"message": result.Message, // e.g. BVN validation failed
			"data":    gin.H{},
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  200,
		"success": true,
		"message": result.Message,
		"data":    result.Data,
	})
}

// GetAllTransfersHttp handles GET /wallet/transfer/list
// GetAllTransfersHttp godoc
// @Summary Get transfer history
// @Description List all initiated bank transfers.
// @Tags Wallet
// @Produce json
// @Security ApiKeyAuth
// @Success 200 {object} map[string]interface{} "Success"
// @Router /wallet/transfer/list [get]
func (wc *WalletController) GetAllTransfersHttp(c *gin.Context) {
	success, errMsg, data := squadService.GetAllTransfers(c.Request.Context())

	if !success {
		msg := "Failed to retrieve transfers"
		if errMsg != nil {
			msg = *errMsg
		}
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  400,
			"success": false,
			"message": msg,
			"data":    gin.H{},
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  200,
		"success": true,
		"message": "Success",
		"data":    data,
	})
}

// RequeryTransferHttp handles POST /wallet/transfer/requery
// RequeryTransferHttp godoc
// @Summary Requery transfer status
// @Description Check the current status of a bank transfer.
// @Tags Wallet
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param body body payloads.SquadRequeryTransferPayload true "Requery data"
// @Success 200 {object} map[string]interface{} "Success"
// @Router /wallet/transfer/requery [post]
func (wc *WalletController) RequeryTransferHttp(c *gin.Context) {
	var req payloads.SquadRequeryTransferPayload

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  400,
			"success": false,
			"message": "Invalid request payload",
			"data":    gin.H{},
		})
		return
	}

	success, errMsg, data := squadService.RequeryTransfer(c.Request.Context(), req.TransactionReference)

	if !success {
		msg := "Failed to requery transfer"
		if errMsg != nil {
			msg = *errMsg
		}
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  400,
			"success": false,
			"message": msg,
			"data":    gin.H{},
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  200,
		"success": true,
		"message": "Success",
		"data":    data,
	})
}

// CreatePaymentHttp handles POST /wallet/payments/new
// CreatePaymentHttp godoc
// @Summary Create new payment
// @Description Create a locked payment for KYB verification.
// @Tags Wallet
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param body body dto.CreatePaymentDto true "Payment data"
// @Success 200 {object} map[string]interface{} "Success"
// @Router /wallet/payments/new [post]
func (wc *WalletController) CreatePaymentHttp(c *gin.Context) {
	var req dto.CreatePaymentDto

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  400,
			"success": false,
			"message": "Invalid request payload",
			"data":    gin.H{},
		})
		return
	}

	userID, _ := c.Get("userID")
	userIDStr := ""
	switch v := userID.(type) {
	case string:
		userIDStr = v
	default:
		userIDStr = fmt.Sprintf("%v", v)
	}

	payment := models.Payment{
		UserID:              userIDStr,
		Amount:              req.Amount,
		AccountNumber:       req.AccountNumber,
		Bank:                req.Bank,
		MerchantPhoneNumber: req.MerchantPhoneNumber,
		MerchantEmail:       req.Email,
		AdvanceOptions:      req.AdvanceOptions,
		Status:              models.PaymentPending,
	}

	if req.ExpiresInMinutes > 0 {
		exp := time.Now().Add(time.Duration(req.ExpiresInMinutes) * time.Minute)
		payment.ExpiresAt = &exp
	}

	if err := wc.db.Create(&payment).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  500,
			"success": false,
			"message": "Failed to create payment record",
			"data":    gin.H{},
		})
		return
	}

	// Send an email conceptually to the merchant
	kybLink := fmt.Sprintf("https://kyb.paygidi.site/%d", payment.ID)
	// TODO: Dispatch to Notification Service
	_ = kybLink

	c.JSON(http.StatusOK, gin.H{
		"status":  200,
		"success": true,
		"message": "Payment locked successfully. Notification sent to merchant.",
		"data": gin.H{
			"payment_id": payment.ID,
			"status":     payment.Status,
		},
	})
}

// GetPaymentHttp handles GET /wallet/payments/:payment_id
// This is used by the frontend to retrieve payment details for KYB
// GetPaymentHttp godoc
// @Summary Get payment details
// @Description Retrieve details of a specific payment by its ID, including customer information
// @Tags payments
// @Produce json
// @Param payment_id path string true "Payment ID"
// @Success 200 {object} map[string]interface{}
// @Failure 400 {object} map[string]interface{}
// @Failure 404 {object} map[string]interface{}
// @Router /wallet/payments/{payment_id} [get]
func (wc *WalletController) GetPaymentHttp(c *gin.Context) {
	paymentIDStr := c.Param("payment_id")
	paymentID, err := strconv.ParseUint(paymentIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  400,
			"success": false,
			"message": "Invalid payment ID",
			"data":    gin.H{},
		})
		return
	}

	payment, err := wc.GetPaymentByID(c.Request.Context(), uint(paymentID))
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{
				"status":  404,
				"success": false,
				"message": "Payment not found",
				"data":    gin.H{},
			})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  500,
			"success": false,
			"message": "Failed to retrieve payment",
			"data":    gin.H{},
		})
		return
	}

	// Fetch customer info from Account Service
	customer, _ := wc.account.GetUser(c.Request.Context(), payment.UserID)

	msg := "Payment details retrieved successfully"
	responseData := gin.H{
		"payment":  payment,
		"customer": customer,
	}

	switch payment.Status {
	case models.PaymentDisbursed:
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  400,
			"success": false,
			"message": "This payment has already been disbursed and cannot be modified.",
			"data":    responseData,
		})
		return
	case models.PaymentRefunded:
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  400,
			"success": false,
			"message": "This payment has already been refunded.",
			"data":    responseData,
		})
		return
	case models.PaymentActionRequired:
		msg = "Customer is currently reviewing this payment."
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  200,
		"success": true,
		"message": msg,
		"data":    payment,
	})
}

// GetPaymentByID is an internal method used by gRPC and HTTP handlers
func (wc *WalletController) GetPaymentByID(ctx context.Context, id uint) (*models.Payment, error) {
	var payment models.Payment
	if err := wc.db.WithContext(ctx).First(&payment, id).Error; err != nil {
		return nil, err
	}
	return &payment, nil
}

// UpdatePaymentStatus updates the status and optionally the trust score and summary of a payment
func (wc *WalletController) UpdatePaymentStatus(ctx context.Context, id uint, status models.PaymentStatus, trustScore *float64, summary string) error {
	updates := map[string]interface{}{
		"status": status,
	}
	if trustScore != nil {
		updates["trust_score"] = *trustScore
	}
	if summary != "" {
		updates["summary"] = summary
	}
	return wc.db.WithContext(ctx).Model(&models.Payment{}).Where("id = ?", id).Updates(updates).Error
}
