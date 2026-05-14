package grpcserver

import (
	"context"
	"errors"

	"github.com/PayGidi/NotificationService/controllers"
	"github.com/PayGidi/NotificationService/dto"
	"github.com/PayGidi/NotificationService/models"
	notificationpb "github.com/PayGidi/NotificationService/proto/notificationpb"
	service "github.com/PayGidi/NotificationService/services/notification"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"gorm.io/gorm"
)

type NotificationGRPCServer struct {
	notificationpb.UnimplementedNotificationServiceServer
	controller *controllers.NotificationController
}

func NewNotificationGRPCServer(controller *controllers.NotificationController) *NotificationGRPCServer {
	return &NotificationGRPCServer{controller: controller}
}

func (s *NotificationGRPCServer) CreateNotification(_ context.Context, req *notificationpb.CreateNotificationRequest) (*notificationpb.CreateNotificationResponse, error) {
	if req.GetUserId() == "" || req.GetTitle() == "" || req.GetMessage() == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id, title and message are required")
	}

	notification, err := s.controller.CreateNotification(&dto.CreateNotificationDTO{
		UserID:    req.GetUserId(),
		Title:     req.GetTitle(),
		Message:   req.GetMessage(),
		Type:      req.GetType(),
		Channel:   req.GetChannel(),
		Recipient: req.GetRecipient(),
		Metadata:  req.GetMetadata(),
	})
	if err != nil {
		return nil, status.Error(codes.Internal, "failed to create notification")
	}

	return &notificationpb.CreateNotificationResponse{Notification: toPBNotification(notification)}, nil
}

func (s *NotificationGRPCServer) GetNotifications(_ context.Context, req *notificationpb.GetNotificationsRequest) (*notificationpb.GetNotificationsResponse, error) {
	filter := service.NotificationFilter{
		UserID:  req.GetUserId(),
		Channel: req.GetChannel(),
		Type:    req.GetType(),
		Status:  req.GetStatus(),
	}

	if req.Read != nil {
		v := req.GetRead()
		filter.Read = &v
	}
	if req.Archived != nil {
		v := req.GetArchived()
		filter.Archived = &v
	}

	notifications, err := s.controller.GetNotifications(filter)
	if err != nil {
		return nil, status.Error(codes.Internal, "failed to fetch notifications")
	}

	response := &notificationpb.GetNotificationsResponse{Notifications: make([]*notificationpb.Notification, 0, len(notifications))}
	for i := range notifications {
		response.Notifications = append(response.Notifications, toPBNotification(&notifications[i]))
	}

	return response, nil
}

func (s *NotificationGRPCServer) MarkAsRead(_ context.Context, req *notificationpb.MarkAsReadRequest) (*notificationpb.MarkAsReadResponse, error) {
	notification, err := s.controller.MarkNotificationRead(req.GetId())
	if err != nil {
		return nil, mapError(err, "notification not found")
	}

	return &notificationpb.MarkAsReadResponse{Notification: toPBNotification(notification)}, nil
}

func (s *NotificationGRPCServer) ArchiveNotification(_ context.Context, req *notificationpb.ArchiveNotificationRequest) (*notificationpb.ArchiveNotificationResponse, error) {
	notification, err := s.controller.ArchiveNotification(req.GetId())
	if err != nil {
		return nil, mapError(err, "notification not found")
	}

	return &notificationpb.ArchiveNotificationResponse{Notification: toPBNotification(notification)}, nil
}

func (s *NotificationGRPCServer) DeleteNotification(_ context.Context, req *notificationpb.DeleteNotificationRequest) (*notificationpb.DeleteNotificationResponse, error) {
	if err := s.controller.DeleteNotification(req.GetId()); err != nil {
		return nil, mapError(err, "notification not found")
	}

	return &notificationpb.DeleteNotificationResponse{Deleted: true}, nil
}

func toPBNotification(notification *models.Notification) *notificationpb.Notification {
	if notification == nil {
		return nil
	}

	return &notificationpb.Notification{
		Id:        uint32(notification.ID),
		UserId:    notification.UserID,
		Title:     notification.Title,
		Message:   notification.Message,
		Type:      notification.Type,
		Channel:   notification.Channel,
		Status:    notification.Status,
		Read:      notification.Read,
		Archived:  notification.Archived,
		Recipient: notification.Recipient,
		Metadata:  notification.Metadata,
		CreatedAt: notification.CreatedAt.Unix(),
		UpdatedAt: notification.UpdatedAt.Unix(),
	}
}

func mapError(err error, notFoundMessage string) error {
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return status.Error(codes.NotFound, notFoundMessage)
	}

	return status.Error(codes.Internal, err.Error())
}
