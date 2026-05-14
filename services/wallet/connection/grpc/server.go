package grpc

import (
	"context"
	"strings"

	"github.com/PayGidi/WalletService/controllers"
	"github.com/PayGidi/WalletService/core/interfaces/payloads"
	"github.com/PayGidi/WalletService/dto"
	"github.com/PayGidi/WalletService/proto/connection/pb"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"gorm.io/gorm"
)

type WalletServer struct {
	walletController *controllers.WalletController
	pb.UnimplementedWalletServiceServer
}

func NewWalletServer(db *gorm.DB) *WalletServer {
	return &WalletServer{walletController: controllers.NewWalletController(db)}
}

func (s *WalletServer) HealthCheck(context.Context, *pb.HealthCheckRequest) (*pb.HealthCheckResponse, error) {
	return &pb.HealthCheckResponse{Status: "ok"}, nil
}

func (s *WalletServer) CreateWallet(ctx context.Context, req *pb.CreateWalletRequest) (*pb.CreateWalletResponse, error) {
	if req == nil {
		return nil, status.Error(codes.InvalidArgument, "request body is required")
	}

	if strings.TrimSpace(req.Firstname) == "" || strings.TrimSpace(req.Lastname) == "" || strings.TrimSpace(req.Nin) == "" || strings.TrimSpace(req.DateOfBirth) == "" {
		return nil, status.Error(codes.InvalidArgument, "firstname, lastname, nin and dateOfBirth are required")
	}

	result := s.walletController.CreateWallet(ctx, dto.CreateWalletDto{
		Firstname:   req.Firstname,
		Middlename:  req.Middlename,
		Lastname:    req.Lastname,
		Nin:         req.Nin,
		DateOfBirth: req.DateOfBirth,
		Bvn:         req.Bvn,
		Phone:       req.Phone,
		Email:       req.Email,
		Gender:      req.Gender,
		UserID:      req.UserId,
		AccountType: req.AccountType,
		BusinessName: req.BusinessName,
	})

	if result == nil {
		return nil, status.Error(codes.Internal, "wallet controller returned empty response")
	}

	if !result.Success || result.Data == nil {
		return &pb.CreateWalletResponse{
			Success: false,
			Code:    result.Code,
			Message: result.Message,
		}, nil
	}

	return &pb.CreateWalletResponse{
		Success:     true,
		Code:        result.Code,
		Message:     result.Message,
		Firstname:   result.Data.Firstname,
		Middlename:  result.Data.Middlename,
		Lastname:    result.Data.Lastname,
		AccountNo:   result.Data.AccountNo,
		CurrentTier: result.Data.CurrenTier,
	}, nil
}

func (s *WalletServer) InitiatePayment(ctx context.Context, req *pb.InitiatePaymentRequest) (*pb.InitiatePaymentResponse, error) {
	if req == nil {
		return nil, status.Error(codes.InvalidArgument, "request body is required")
	}

	success, errMsg, data := s.walletController.InitiatePayment(ctx, payloads.InitiateSquadPaymentPayload{
		Amount:       int(req.Amount),
		Email:        req.Email,
		Currency:     req.Currency,
		InitiateType: "inline",
	})

	if !success || data == nil {
		message := "failed to initiate payment"
		if errMsg != nil {
			message = *errMsg
		}
		return &pb.InitiatePaymentResponse{
			Success: false,
			Message: message,
		}, nil
	}

	return &pb.InitiatePaymentResponse{
		Success:     true,
		Message:     "payment initiated successfully",
		CheckoutUrl: data.CheckoutURL,
	}, nil
}

func (s *WalletServer) InitiateTransfer(ctx context.Context, req *pb.InitiateTransferRequest) (*pb.InitiateTransferResponse, error) {
	if req == nil {
		return nil, status.Error(codes.InvalidArgument, "request body is required")
	}

	success, errMsg, data := s.walletController.InitiateTransfer(ctx, payloads.SquadTransferPayload{
		TransactionReference: req.TransactionReference,
		Amount:               int(req.Amount),
		BankCode:             req.BankCode,
		AccountNumber:        req.AccountNumber,
		AccountName:          req.AccountName,
		Remark:               req.Remark,
		CurrencyID:           "NGN",
	})

	if !success || data == nil {
		message := "failed to initiate transfer"
		if errMsg != nil {
			message = *errMsg
		}
		return &pb.InitiateTransferResponse{
			Success: false,
			Message: message,
		}, nil
	}

	return &pb.InitiateTransferResponse{
		Success:              true,
		Message:              "transfer initiated successfully",
		TransactionReference: data.TransactionReference,
	}, nil
}

func (s *WalletServer) GetTransactions(ctx context.Context, req *pb.GetTransactionsRequest) (*pb.GetTransactionsResponse, error) {
	if req == nil {
		return nil, status.Error(codes.InvalidArgument, "request body is required")
	}

	success, errMsg, data := s.walletController.GetTransactions(ctx, req.CustomerIdentifier)

	if !success {
		message := "failed to retrieve transactions"
		if errMsg != nil {
			message = *errMsg
		}
		return &pb.GetTransactionsResponse{
			Success: false,
			Message: message,
		}, nil
	}

	transactions := make([]*pb.TransactionData, 0)
	for _, t := range data {
		transactions = append(transactions, &pb.TransactionData{
			Amount:          int64(t.Amount),
			TransactionRef:  t.TransactionRef,
			GatewayRef:      t.GatewayRef,
			TransactionType: t.TransactionType,
			CreatedAt:       t.CreatedAt,
			Status:          t.Status,
		})
	}

	return &pb.GetTransactionsResponse{
		Success:      true,
		Message:      "transactions retrieved successfully",
		Transactions: transactions,
	}, nil
}

func (s *WalletServer) ResolveAccount(ctx context.Context, req *pb.ResolveAccountRequest) (*pb.ResolveAccountResponse, error) {
	if req == nil {
		return nil, status.Error(codes.InvalidArgument, "request body is required")
	}

	success, errMsg, data := s.walletController.ResolveAccount(ctx, payloads.SquadAccountLookupPayload{
		BankCode:      req.BankCode,
		AccountNumber: req.AccountNumber,
	})

	if !success || data == nil {
		message := "failed to resolve account"
		if errMsg != nil {
			message = *errMsg
		}
		return &pb.ResolveAccountResponse{
			Success: false,
			Message: message,
		}, nil
	}

	return &pb.ResolveAccountResponse{
		Success:       true,
		Message:       "account resolved successfully",
		AccountName:   data.AccountName,
		AccountNumber: data.AccountNumber,
	}, nil
}
