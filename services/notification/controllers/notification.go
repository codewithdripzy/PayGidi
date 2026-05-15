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

// SendEmailNotification godoc
// @Summary Send email notification
// @Description Send an email via Resend.
// @Tags Notifications
// @Accept json
// @Produce json
// @Param body body dto.SendEmailDTO true "Email data"
// @Success 200 {object} models.Notification
// @Router /notification/email [post]
func (c *NotificationController) SendEmailNotification(payload *dto.SendEmailDTO) (*models.Notification, error) {
	return c.notificationService.SendEmail(payload)
}

// SendSMSNotification godoc
// @Summary Send SMS notification
// @Description Send an SMS via Twilio.
// @Tags Notifications
// @Accept json
// @Produce json
// @Param body body dto.SendSMSDTO true "SMS data"
// @Success 200 {object} models.Notification
// @Router /notification/sms [post]
func (c *NotificationController) SendSMSNotification(payload *dto.SendSMSDTO) (*models.Notification, error) {
	return c.notificationService.SendSMS(payload)
}

// RecordActivity godoc
// @Summary Record user activity
// @Description Log a user activity for audit trails.
// @Tags Activities
// @Accept json
// @Produce json
// @Param body body dto.CreateActivityDTO true "Activity data"
// @Success 200 {object} models.Activity
// @Router /notification/activity [post]
func (c *NotificationController) RecordActivity(payload *dto.CreateActivityDTO, clientIP, userAgent string) (*models.Activity, error) {
	return c.notificationService.RecordActivity(payload, clientIP, userAgent)
}

func (c *NotificationController) GetActivities(filter service.ActivityFilter) ([]models.Activity, error) {
	return c.notificationService.GetActivities(filter)
}
