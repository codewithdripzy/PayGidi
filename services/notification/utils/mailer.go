package utils

import (
	"errors"
	"fmt"
	"net/smtp"
	"os"
)

func SendEmail(to, subject, body string) error {
	from := os.Getenv("SMTP_FROM")
	password := os.Getenv("SMTP_PASSWORD")
	smtpHost := os.Getenv("SMTP_HOST")
	smtpPort := os.Getenv("SMTP_PORT")

	if from == "" || password == "" || smtpHost == "" || smtpPort == "" {
		return errors.New("smtp credentials are not fully configured")
	}

	auth := smtp.PlainAuth("", from, password, smtpHost)
	msg := []byte(fmt.Sprintf("To: %s\r\nSubject: %s\r\n\r\n%s\r\n", to, subject, body))

	return smtp.SendMail(smtpHost+":"+smtpPort, auth, from, []string{to}, msg)
}
