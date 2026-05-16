package grpc

import (
	"context"
	"log"
	"strings"

	"time"

	"github.com/PayGidi/WalletService/controllers"
	"github.com/PayGidi/WalletService/core/interfaces/payloads"
	"github.com/PayGidi/WalletService/dto"
	"github.com/PayGidi/WalletService/models"
	"github.com/PayGidi/WalletService/proto/connection/pb"
	"github.com/PayGidi/WalletService/services/account"
	"github.com/PayGidi/WalletService/utils"
	"github.com/patrickmn/go-cache"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"gorm.io/gorm"
)

type WalletServer struct {
	walletController *controllers.WalletController
	pb.UnimplementedWalletServiceServer
}

func NewWalletServer(db *gorm.DB, accClient *account.AccountClient) *WalletServer {
	return &WalletServer{walletController: controllers.NewWalletController(db, accClient)}
}

func (s *WalletServer) HealthCheck(context.Context, *pb.HealthCheckRequest) (*pb.HealthCheckResponse, error) {
	return &pb.HealthCheckResponse{Status: "ok"}, nil
}

func (s *WalletServer) CreateWallet(ctx context.Context, req *pb.CreateWalletRequest) (*pb.CreateWalletResponse, error) {
	log.Printf("[WalletServer] CreateWallet request for UserID: %s, Phone: %s", req.UserId, req.Phone)

	if req == nil {
		log.Printf("[WalletServer] Error: request body is nil")
		return nil, status.Error(codes.InvalidArgument, "request body is required")
	}

	if strings.TrimSpace(req.Firstname) == "" || strings.TrimSpace(req.Lastname) == "" || strings.TrimSpace(req.Nin) == "" || strings.TrimSpace(req.DateOfBirth) == "" {
		log.Printf("[WalletServer] Error: missing required fields")
		return nil, status.Error(codes.InvalidArgument, "firstname, lastname, nin and dateOfBirth are required")
	}

	result := s.walletController.CreateWallet(ctx, dto.CreateWalletDto{
		Firstname:    req.Firstname,
		Middlename:   req.Middlename,
		Lastname:     req.Lastname,
		Nin:          req.Nin,
		DateOfBirth:  req.DateOfBirth,
		Bvn:          req.Bvn,
		Phone:        req.Phone,
		Email:        req.Email,
		Gender:       req.Gender,
		UserID:       req.UserId,
		AccountType:  req.AccountType,
		BusinessName: req.BusinessName,
		Address:      req.Address,
	})

	if result == nil {
		log.Printf("[WalletServer] Error: wallet controller returned nil")
		return nil, status.Error(codes.Internal, "wallet controller returned empty response")
	}

	if !result.Success || result.Data == nil {
		log.Printf("[WalletServer] Wallet creation failed: %s (Code: %s)", result.Message, result.Code)
		return &pb.CreateWalletResponse{
			Success: false,
			Code:    result.Code,
			Message: result.Message,
		}, nil
	}

	log.Printf("[WalletServer] Wallet created successfully for UserID: %s, AccountNo: %s", req.UserId, result.Data.AccountNo)
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

	// Check Cache
	cacheKey := "transactions:" + req.CustomerIdentifier
	if cached, found := utils.AppCache.Get(cacheKey); found {
		return cached.(*pb.GetTransactionsResponse), nil
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

	res := &pb.GetTransactionsResponse{
		Success:      true,
		Message:      "transactions retrieved successfully",
		Transactions: transactions,
	}

	// Store in Cache (5 minutes)
	utils.AppCache.Set(cacheKey, res, cache.DefaultExpiration)

	return res, nil
}

func (s *WalletServer) ResolveAccount(ctx context.Context, req *pb.ResolveAccountRequest) (*pb.ResolveAccountResponse, error) {
	if req == nil {
		return nil, status.Error(codes.InvalidArgument, "request body is required")
	}

	// Check Cache
	cacheKey := "resolve:" + req.BankCode + ":" + req.AccountNumber
	if cached, found := utils.AppCache.Get(cacheKey); found {
		return cached.(*pb.ResolveAccountResponse), nil
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

	res := &pb.ResolveAccountResponse{
		Success:       true,
		Message:       "account resolved successfully",
		AccountName:   data.AccountName,
		AccountNumber: data.AccountNumber,
	}

	// Store in Cache (1 hour - bank accounts don't change names often)
	utils.AppCache.Set(cacheKey, res, 1*time.Hour)

	return res, nil
}

func (s *WalletServer) GetPayment(ctx context.Context, req *pb.GetPaymentRequest) (*pb.GetPaymentResponse, error) {
	if req == nil {
		return nil, status.Error(codes.InvalidArgument, "request body is required")
	}

	payment, err := s.walletController.GetPaymentByID(ctx, uint(req.PaymentId))
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return &pb.GetPaymentResponse{
				Success: false,
				Message: "payment not found",
			}, nil
		}
		return &pb.GetPaymentResponse{
			Success: false,
			Message: err.Error(),
		}, nil
	}

	var trustScore float64
	if payment.TrustScore != nil {
		trustScore = *payment.TrustScore
	}

	var expiresAt string
	if payment.ExpiresAt != nil {
		expiresAt = payment.ExpiresAt.Format(time.RFC3339)
	}

	return &pb.GetPaymentResponse{
		Success: true,
		Message: "payment retrieved successfully",
		Data: &pb.PaymentData{
			Id:                  uint64(payment.ID),
			UserId:              payment.UserID,
			Amount:              payment.Amount,
			AccountNumber:       payment.AccountNumber,
			Bank:                payment.Bank,
			MerchantPhoneNumber: payment.MerchantPhoneNumber,
			MerchantEmail:       payment.MerchantEmail,
			AdvanceOptions:      payment.AdvanceOptions,
			Status:              string(payment.Status),
			TrustScore:          trustScore,
			ExpiresAt:           expiresAt,
			CreatedAt:           payment.CreatedAt.Format(time.RFC3339),
		},
	}, nil
}

func (s *WalletServer) UpdatePaymentStatus(ctx context.Context, req *pb.UpdatePaymentStatusRequest) (*pb.UpdatePaymentStatusResponse, error) {
	if req == nil {
		return nil, status.Error(codes.InvalidArgument, "request body is required")
	}

	err := s.walletController.UpdatePaymentStatus(ctx, uint(req.PaymentId), models.PaymentStatus(req.Status), &req.TrustScore, req.Summary)
	if err != nil {
		return &pb.UpdatePaymentStatusResponse{
			Success: false,
			Message: err.Error(),
		}, nil
	}

	return &pb.UpdatePaymentStatusResponse{
		Success: true,
		Message: "payment status updated successfully",
	}, nil
}
