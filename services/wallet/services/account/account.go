package account

import (
	"context"

	"github.com/PayGidi/WalletService/proto/connection/pb"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

type AccountClient struct {
	client pb.AuthServiceClient
}

func NewAccountClient(addr string) (*AccountClient, error) {
	conn, err := grpc.NewClient(addr, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		return nil, err
	}
	return &AccountClient{client: pb.NewAuthServiceClient(conn)}, nil
}

func (c *AccountClient) GetUser(ctx context.Context, userID string) (*pb.UserData, error) {
	resp, err := c.client.GetUser(ctx, &pb.GetUserRequest{UserId: userID})
	if err != nil {
		return nil, err
	}
	if !resp.Success {
		return nil, nil
	}
	return resp.UserData, nil
}
