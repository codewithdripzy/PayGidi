package wallet

import (
	"context"
	"fmt"
	"strconv"

	"github.com/PayGidi/AccountService/core/constants"
	walletpb "github.com/PayGidi/WalletService/proto/connection/pb"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/metadata"
)

func CheckNINValidity(ctx context.Context, nin string) (bool, *string) {
	fmt.Println("[VerifyNIN][account-wallet-client] opening wallet grpc client")
	client, err := NewWalletService("")
	if err != nil {
		fmt.Println("[VerifyNIN][account-wallet-client] failed to create wallet client:", err)
		errMsg := err.Error()
		return false, &errMsg
	}
	defer client.Close()

	fmt.Println("[VerifyNIN][account-wallet-client] sending VerifyNIN request; nin length:", len(nin))

	response, err := client.client.VerifyNIN(ctx, &walletpb.VerifyNINRequest{Nin: nin})
	if err != nil {
		fmt.Println("[VerifyNIN][account-wallet-client] grpc VerifyNIN error:", err)
		errMsg := err.Error()
		return false, &errMsg
	}

	if response == nil {
		fmt.Println("[VerifyNIN][account-wallet-client] grpc VerifyNIN response is nil")
		errMsg := "empty response from wallet service"
		return false, &errMsg
	}

	fmt.Println("[VerifyNIN][account-wallet-client] grpc VerifyNIN response success:", response.Success, "isValid:", response.IsValid)

	if !response.Success {
		errMsg := response.Message
		if errMsg == "" {
			errMsg = "nin verification failed"
		}
		return false, &errMsg
	}

	return response.IsValid, nil
}

func VerifyBVNImage(ctx context.Context, bvn string, base64Image string) (bool, *string) {
	client, err := NewWalletService("")
	if err != nil {
		errMsg := err.Error()
		return false, &errMsg
	}
	defer client.Close()

	response, err := client.client.VerifyBVNImage(ctx, &walletpb.VerifyBVNImageRequest{
		Bvn:         bvn,
		Base64Image: base64Image,
	})
	if err != nil {
		errMsg := err.Error()
		return false, &errMsg
	}

	if response == nil {
		errMsg := "empty response from wallet service"
		return false, &errMsg
	}

	if !response.Success {
		errMsg := response.Message
		if errMsg == "" {
			errMsg = "bvn image verification failed"
		}
		return false, &errMsg
	}

	return response.ImageMatched, nil
}

type WalletService struct {
	conn   *grpc.ClientConn
	client walletpb.WalletServiceClient
}

func NewWalletService(address string) (*WalletService, error) {
	if address == "" {
		address = constants.WALLET_SERVICE_ADDR
	}

	conn, err := grpc.NewClient(
		address,
		grpc.WithTransportCredentials(insecure.NewCredentials()),
	)
	if err != nil {
		return nil, err
	}

	return &WalletService{
		conn:   conn,
		client: walletpb.NewWalletServiceClient(conn),
	}, nil
}

func (s *WalletService) Close() error {
	if s == nil || s.conn == nil {
		return nil
	}

	return s.conn.Close()
}

func (s *WalletService) CreateWalletForUser(ctx context.Context, req *walletpb.CreateWalletRequest, userID uint, recipient string) (*walletpb.CreateWalletResponse, error) {
	md := metadata.Pairs("x-user-id", strconv.FormatUint(uint64(userID), 10))
	if recipient != "" {
		md.Append("x-recipient", recipient)
	}

	ctx = metadata.NewOutgoingContext(ctx, md)
	fmt.Printf("[Account-WalletClient] calling client.CreateWallet on %s\n", constants.WALLET_SERVICE_ADDR)
	return s.client.CreateWallet(ctx, req)
}

func (s *WalletService) CreateWallet(ctx context.Context, req *walletpb.CreateWalletRequest) (*walletpb.CreateWalletResponse, error) {
	return s.client.CreateWallet(ctx, req)
}
