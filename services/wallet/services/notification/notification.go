package notification

import (
	"context"
	"fmt"
	"strings"
	"time"

	notificationpb "github.com/PayGidi/NotificationService/proto/notificationpb"
	"github.com/PayGidi/WalletService/core/constants"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

type NotificationService struct {
	conn   *grpc.ClientConn
	client notificationpb.NotificationServiceClient
}

func NewNotificationService(address string) (*NotificationService, error) {
	if address == "" {
		address = constants.NOTIFICATION_SERVICE_ADDR
	}

	conn, err := grpc.NewClient(
		address,
		grpc.WithTransportCredentials(insecure.NewCredentials()),
	)
	if err != nil {
		return nil, err
	}

	return &NotificationService{
		conn:   conn,
		client: notificationpb.NewNotificationServiceClient(conn),
	}, nil
}

func (s *NotificationService) Close() error {
	if s == nil || s.conn == nil {
		return nil
	}

	return s.conn.Close()
}

func SendWalletNotification(userID string, recipient string, title string, message string) error {
	userID = strings.TrimSpace(userID)
	recipient = strings.TrimSpace(recipient)
	title = strings.TrimSpace(title)
	message = strings.TrimSpace(message)

	if userID == "" {
		return fmt.Errorf("user_id is required")
	}

	if title == "" {
		title = "Wallet Notification"
	}

	if message == "" {
		message = "A wallet event occurred. Please check your activity for details."
	}

	client, err := NewNotificationService("")
	if err != nil {
		return err
	}
	defer client.Close()

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	_, err = client.client.CreateNotification(ctx, &notificationpb.CreateNotificationRequest{
		UserId:    userID,
		Title:     title,
		Message:   message,
		Type:      "wallet",
		Channel:   "in_app",
		Recipient: recipient,
	})
	return err
}
