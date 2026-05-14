package notification

import (
	"github.com/PayGidi/NotificationService/dto"
	"github.com/PayGidi/NotificationService/models"
	"github.com/PayGidi/NotificationService/utils"
	"gorm.io/gorm"
)

type NotificationService struct {
	DB *gorm.DB
}

type NotificationFilter struct {
	UserID   string
	Channel  string
	Type     string
	Status   string
	Read     *bool
	Archived *bool
}

type ActivityFilter struct {
	UserID     string
	Action     string
	EntityType string
}

func NewNotificationService(db *gorm.DB) *NotificationService {
	return &NotificationService{DB: db}
}

func (s *NotificationService) CreateNotification(payload *dto.CreateNotificationDTO) (*models.Notification, error) {
	notification := &models.Notification{
		UserID:    payload.UserID,
		Title:     payload.Title,
		Message:   payload.Message,
		Type:      utils.DefaultString(payload.Type, "general"),
		Channel:   utils.DefaultString(payload.Channel, "in_app"),
		Status:    "stored",
		Recipient: payload.Recipient,
		Metadata:  payload.Metadata,
	}

	if err := s.DB.Create(notification).Error; err != nil {
		return nil, err
	}

	return notification, nil
}

func (s *NotificationService) GetNotifications(filter NotificationFilter) ([]models.Notification, error) {
	var notifications []models.Notification
	query := s.DB.Order("created_at desc")

	if filter.UserID != "" {
		query = query.Where("user_id = ?", filter.UserID)
	}
	if filter.Channel != "" {
		query = query.Where("channel = ?", filter.Channel)
	}
	if filter.Type != "" {
		query = query.Where("\"type\" = ?", filter.Type)
	}
	if filter.Status != "" {
		query = query.Where("status = ?", filter.Status)
	}
	if filter.Read != nil {
		query = query.Where("\"read\" = ?", *filter.Read)
	}
	if filter.Archived != nil {
		query = query.Where("archived = ?", *filter.Archived)
	}

	if err := query.Find(&notifications).Error; err != nil {
		return nil, err
	}

	return notifications, nil
}

func (s *NotificationService) GetNotificationByID(id string) (*models.Notification, error) {
	var notification models.Notification
	if err := s.DB.First(&notification, id).Error; err != nil {
		return nil, err
	}

	return &notification, nil
}

func (s *NotificationService) MarkNotificationRead(id string) (*models.Notification, error) {
	notification, err := s.GetNotificationByID(id)
	if err != nil {
		return nil, err
	}

	notification.Read = true
	notification.Status = "read"

	if err := s.DB.Save(notification).Error; err != nil {
		return nil, err
	}

	return notification, nil
}

func (s *NotificationService) ArchiveNotification(id string) (*models.Notification, error) {
	notification, err := s.GetNotificationByID(id)
	if err != nil {
		return nil, err
	}

	notification.Archived = true
	if err := s.DB.Save(notification).Error; err != nil {
		return nil, err
	}

	return notification, nil
}

func (s *NotificationService) DeleteNotification(id string) error {
	notification, err := s.GetNotificationByID(id)
	if err != nil {
		return err
	}

	return s.DB.Delete(notification).Error
}

func (s *NotificationService) SendEmail(payload *dto.SendEmailDTO) (*models.Notification, error) {
	if err := utils.SendEmail(payload.To, payload.Subject, payload.Body); err != nil {
		return nil, err
	}

	notification := &models.Notification{
		UserID:    utils.DefaultString(payload.UserID, payload.To),
		Title:     payload.Subject,
		Message:   payload.Body,
		Type:      "message",
		Channel:   "email",
		Status:    "sent",
		Recipient: payload.To,
	}

	if err := s.DB.Create(notification).Error; err != nil {
		return nil, err
	}

	return notification, nil
}

func (s *NotificationService) SendSMS(payload *dto.SendSMSDTO) (*models.Notification, error) {
	if err := utils.SendSMS(payload.To, payload.Message); err != nil {
		return nil, err
	}

	notification := &models.Notification{
		UserID:    utils.DefaultString(payload.UserID, payload.To),
		Title:     "SMS notification",
		Message:   payload.Message,
		Type:      "message",
		Channel:   "sms",
		Status:    "sent",
		Recipient: payload.To,
	}

	if err := s.DB.Create(notification).Error; err != nil {
		return nil, err
	}

	return notification, nil
}

func (s *NotificationService) RecordActivity(payload *dto.CreateActivityDTO, clientIP string, userAgent string) (*models.Activity, error) {
	activity := &models.Activity{
		UserID:     payload.UserID,
		Action:     payload.Action,
		EntityType: utils.DefaultString(payload.EntityType, "notification"),
		EntityID:   payload.EntityID,
		Details:    payload.Details,
		IPAddress:  utils.DefaultString(payload.IPAddress, clientIP),
		UserAgent:  utils.DefaultString(payload.UserAgent, userAgent),
	}

	if err := s.DB.Create(activity).Error; err != nil {
		return nil, err
	}

	return activity, nil
}

func (s *NotificationService) GetActivities(filter ActivityFilter) ([]models.Activity, error) {
	var activities []models.Activity
	query := s.DB.Order("created_at desc")

	if filter.UserID != "" {
		query = query.Where("user_id = ?", filter.UserID)
	}
	if filter.Action != "" {
		query = query.Where("action = ?", filter.Action)
	}
	if filter.EntityType != "" {
		query = query.Where("entity_type = ?", filter.EntityType)
	}

	if err := query.Find(&activities).Error; err != nil {
		return nil, err
	}

	return activities, nil
}
