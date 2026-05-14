package dto

type CreateNotificationDTO struct {
	UserID    string `json:"userId" validate:"required"`
	Title     string `json:"title" validate:"required,min=3,max=150"`
	Message   string `json:"message" validate:"required,min=3,max=5000"`
	Type      string `json:"type" validate:"omitempty,max=50"`
	Channel   string `json:"channel" validate:"omitempty,oneof=in_app email sms"`
	Recipient string `json:"recipient" validate:"omitempty,max=255"`
	Metadata  string `json:"metadata" validate:"omitempty,max=5000"`
}

type SendEmailDTO struct {
	To      string `json:"to" validate:"required,email"`
	Subject string `json:"subject" validate:"required,min=3,max=150"`
	Body    string `json:"body" validate:"required,min=3,max=5000"`
	UserID  string `json:"userId" validate:"omitempty"`
	Type    string `json:"type" validate:"omitempty,max=50"`
}

type SendSMSDTO struct {
	To      string `json:"to" validate:"required,min=7,max=25"`
	Message string `json:"message" validate:"required,min=3,max=1000"`
	UserID  string `json:"userId" validate:"omitempty"`
}

type CreateActivityDTO struct {
	UserID     string `json:"userId" validate:"required"`
	Action     string `json:"action" validate:"required,min=2,max=100"`
	EntityType string `json:"entityType" validate:"omitempty,max=100"`
	EntityID   string `json:"entityId" validate:"omitempty,max=100"`
	Details    string `json:"details" validate:"omitempty,max=5000"`
	IPAddress  string `json:"ipAddress" validate:"omitempty,max=64"`
	UserAgent  string `json:"userAgent" validate:"omitempty,max=512"`
}
