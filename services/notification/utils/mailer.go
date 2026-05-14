package utils

import (
	"errors"
	"os"

	"github.com/resend/resend-go/v3"
)

func SendEmail(to, subject, body, emailType string) error {
	apiKey := os.Getenv("RESEND_API_KEY")
	var from string

	switch emailType {
	case "register":
		from = os.Getenv("RESEND_REGISTER_FROM_EMAIL")
	case "notification":
		from = os.Getenv("RESEND_NOTIFICATION_FROM_EMAIL")
	default:
		from = os.Getenv("RESEND_DEFAULT_FROM_EMAIL")
	}

	if from == "" {
		from = os.Getenv("RESEND_DEFAULT_FROM_EMAIL")
	}

	if from == "" {
		from = "PayGidi <noreply@send.paygidi.site>"
	}

	if apiKey == "" {
		return errors.New("RESEND_API_KEY is not configured")
	}

	client := resend.NewClient(apiKey)

	params := &resend.SendEmailRequest{
		From:    from,
		To:      []string{to},
		Html:    body,
		Subject: subject,
	}

	_, err := client.Emails.Send(params)
	if err != nil {
		return err
	}

	return nil
}
