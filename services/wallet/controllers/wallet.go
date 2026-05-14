package controllers

import (
	"context"
	"fmt"
	"strconv"
	"strings"

	payGidiErrors "github.com/PayGidi/WalletService/core/interfaces/errors"
	"github.com/PayGidi/WalletService/core/interfaces/payloads"
	"github.com/PayGidi/WalletService/core/interfaces/responses"
	"github.com/PayGidi/WalletService/dto"
	squadService "github.com/PayGidi/WalletService/services/squad"
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

	// Map Squad response to existing CreateClientResponseData for backward compatibility
	mappedResponse := &responses.CreateClientResponseData{
		Firstname: response.FirstName,
		Lastname:  response.LastName,
		AccountNo: response.BankAccountNumber,
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
