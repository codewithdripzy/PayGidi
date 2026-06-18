package wallet

import (
	"context"

	walletpb "github.com/PayGidi/AIService/proto/connection/walletpb"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

type WalletClient struct {
	client walletpb.WalletServiceClient
}

func NewWalletClient(addr string) (*WalletClient, error) {
	conn, err := grpc.NewClient(addr, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		return nil, err
	}
	return &WalletClient{client: walletpb.NewWalletServiceClient(conn)}, nil
}

func (w *WalletClient) GetPayment(ctx context.Context, paymentID uint64) (*walletpb.PaymentData, error) {
	resp, err := w.client.GetPayment(ctx, &walletpb.GetPaymentRequest{PaymentId: paymentID})
	if err != nil {
		return nil, err
	}
	if !resp.Success {
		return nil, nil
	}
	return resp.Data, nil
}

func (w *WalletClient) UpdatePaymentStatus(ctx context.Context, paymentID uint64, status string, trustScore float64, summary string) error {
	resp, err := w.client.UpdatePaymentStatus(ctx, &walletpb.UpdatePaymentStatusRequest{
		PaymentId:  paymentID,
		Status:     status,
		TrustScore: trustScore,
		Summary:    summary,
	})
	if err != nil {
		return err
	}
	if !resp.Success {
		return nil
	}
	return nil
}
