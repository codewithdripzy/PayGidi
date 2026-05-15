package notification

import (
	"context"
	"strconv"
	"time"

	notificationpb "github.com/PayGidi/NotificationService/proto/notificationpb"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

const defaultNotificationAddress = "localhost:50052"

type NotificationService struct {
	conn   *grpc.ClientConn
	client notificationpb.NotificationServiceClient
}

func NewNotificationService(address string) (*NotificationService, error) {
	if address == "" {
		address = defaultNotificationAddress
	}

	conn, err := grpc.NewClient(
		address,
		grpc.WithTransportCredentials(insecure.NewCredentials()),
		// grpc.WithBlock(),
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

func (s *NotificationService) CreateNotification(ctx context.Context, req *notificationpb.CreateNotificationRequest) (*notificationpb.CreateNotificationResponse, error) {
	return s.client.CreateNotification(ctx, req)
}

func (s *NotificationService) GetNotifications(ctx context.Context, req *notificationpb.GetNotificationsRequest) (*notificationpb.GetNotificationsResponse, error) {
	return s.client.GetNotifications(ctx, req)
}

func (s *NotificationService) MarkAsRead(ctx context.Context, req *notificationpb.MarkAsReadRequest) (*notificationpb.MarkAsReadResponse, error) {
	return s.client.MarkAsRead(ctx, req)
}

func (s *NotificationService) ArchiveNotification(ctx context.Context, req *notificationpb.ArchiveNotificationRequest) (*notificationpb.ArchiveNotificationResponse, error) {
	return s.client.ArchiveNotification(ctx, req)
}

func (s *NotificationService) DeleteNotification(ctx context.Context, req *notificationpb.DeleteNotificationRequest) (*notificationpb.DeleteNotificationResponse, error) {
	return s.client.DeleteNotification(ctx, req)
}

func SendUserNotification(userID uint, title string, message string, channel string, recipient string, notificationType string) error {
	client, err := NewNotificationService("")
	if err != nil {
		return err
	}
	defer client.Close()

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	_, err = client.CreateNotification(ctx, &notificationpb.CreateNotificationRequest{
		UserId:    strconv.FormatUint(uint64(userID), 10),
		Title:     title,
		Message:   message,
		Type:      notificationType,
		Channel:   channel,
		Recipient: recipient,
	})

	return err
}
