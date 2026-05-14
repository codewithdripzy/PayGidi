package controllers

import (
	"github.com/PayGidi/NotificationService/dto"
	"github.com/PayGidi/NotificationService/models"
	service "github.com/PayGidi/NotificationService/services/notification"
	"gorm.io/gorm"
)

type NotificationController struct {
	notificationService *service.NotificationService
}

func NewNotificationController(db *gorm.DB) *NotificationController {
	return &NotificationController{
		notificationService: service.NewNotificationService(db),
	}
}

func (c *NotificationController) CreateNotification(payload *dto.CreateNotificationDTO) (*models.Notification, error) {
	return c.notificationService.CreateNotification(payload)
}

func (c *NotificationController) GetNotifications(filter service.NotificationFilter) ([]models.Notification, error) {
	return c.notificationService.GetNotifications(filter)
}

func (c *NotificationController) GetNotification(id string) (*models.Notification, error) {
	return c.notificationService.GetNotificationByID(id)
}

func (c *NotificationController) MarkNotificationRead(id string) (*models.Notification, error) {
	return c.notificationService.MarkNotificationRead(id)
}

func (c *NotificationController) ArchiveNotification(id string) (*models.Notification, error) {
	return c.notificationService.ArchiveNotification(id)
}

func (c *NotificationController) DeleteNotification(id string) error {
	return c.notificationService.DeleteNotification(id)
}

func (c *NotificationController) SendEmailNotification(payload *dto.SendEmailDTO) (*models.Notification, error) {
	return c.notificationService.SendEmail(payload)
}

func (c *NotificationController) SendSMSNotification(payload *dto.SendSMSDTO) (*models.Notification, error) {
	return c.notificationService.SendSMS(payload)
}

func (c *NotificationController) RecordActivity(payload *dto.CreateActivityDTO, clientIP, userAgent string) (*models.Activity, error) {
	return c.notificationService.RecordActivity(payload, clientIP, userAgent)
}

func (c *NotificationController) GetActivities(filter service.ActivityFilter) ([]models.Activity, error) {
	return c.notificationService.GetActivities(filter)
}
