package controllers

import (
	"context"
	"fmt"
	"net/http"
	"strconv"
	"strings"
	"time"

	payGidiErrors "github.com/PayGidi/WalletService/core/interfaces/errors"
	"github.com/PayGidi/WalletService/core/interfaces/payloads"
	"github.com/PayGidi/WalletService/core/interfaces/responses"
	"github.com/PayGidi/WalletService/dto"
	"github.com/PayGidi/WalletService/models"
	squadService "github.com/PayGidi/WalletService/services/squad"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type WalletController struct {
	db *gorm.DB
}

type CreateWalletResult struct {
	Success bool
	Code    string
	Message string
	Data    *responses.CreateClientResponseData
}

func NewWalletController(db *gorm.DB) *WalletController {
	return &WalletController{db: db}
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

	if request.AccountType == "business" {
		success, squadErr, response = squadService.CreateBusinessVirtualAccount(ctx, payloads.CreateSquadBusinessVirtualAccountPayload{
			BusinessName:       request.BusinessName,
			CustomerIdentifier: request.UserID,
			MobileNum:          request.Phone,
			Bvn:                bvn,
		})
	} else {
		success, squadErr, response = squadService.CreateVirtualAccount(ctx, payloads.CreateSquadVirtualAccountPayload{
			FirstName:          request.Firstname,
			LastName:           request.Lastname,
			MobileNum:          request.Phone,
			Dob:                dob,
			Bvn:                bvn,
			CustomerIdentifier: request.UserID,
			Gender:             request.Gender,
			Email:              request.Email,
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
		ProviderAccountNumber: response.BankAccountNumber,
		AccountReference:      response.CustomerIdentifier,
		AccountNumber:         accountAlias, // Formatted alias
		AccountType:           request.AccountType,
		CurrencyCode:          "NGN",
		Status:                "active",
	}

	if err := wc.db.Create(&newAccount).Error; err != nil {
		return &CreateWalletResult{
			Success: false,
			Code:    string(payGidiErrors.INTERNAL_SERVER_ERROR),
			Message: "failed to save account to database",
		}
	}

	// Map Squad response to existing CreateClientResponseData for backward compatibility
	mappedResponse := &responses.CreateClientResponseData{
		Firstname: response.FirstName,
		Lastname:  response.LastName,
		AccountNo: newAccount.AccountNumber,
	}

	return &CreateWalletResult{
		Success: true,
		Code:    strconv.Itoa(int(payGidiErrors.SUCCESS)),
		Message: "wallet account created successfully",
		Data:    mappedResponse,
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

func (wc *WalletController) ResolveAccount(ctx context.Context, request payloads.SquadAccountLookupPayload) (bool, *string, *responses.SquadAccountLookupResponseData) {
	return squadService.ResolveAccount(ctx, request)
}

// GetWalletHttp handles the GET /wallet HTTP request to fetch virtual account details
func (wc *WalletController) GetWalletHttp(c *gin.Context) {
	accountNumber := c.Param("accountNumber")
	var account models.Account

	if accountNumber == "" {
		// Try from authenticated user
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

		if err := wc.db.Where("user_id = ?", userID).First(&account).Error; err != nil {
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
		"data":    data,
	})
}

// GetTransactionsHttp handles the GET /wallet/:accountNumber/transactions HTTP request
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
	if err := wc.db.Where("account_number = ?", req.AccountNumber).First(&account).Error; err != nil {
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

// ResolveAccountHttp handles the POST /wallet/transfer/lookup HTTP request
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
