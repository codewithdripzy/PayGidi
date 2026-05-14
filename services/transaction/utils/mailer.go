package utils

import (
	"net/smtp"
	"os"
)

// SendEmail sends an email using SMTP
func SendEmail(to, subject, body string) error {
	from := os.Getenv("SMTP_FROM")
	password := os.Getenv("SMTP_PASSWORD")
	smtpHost := os.Getenv("SMTP_HOST")
	smtpPort := os.Getenv("SMTP_PORT")

	// Set up authentication information.
	auth := smtp.PlainAuth("", from, password, smtpHost)

	// Set up the email message.
	msg := []byte("To: " + to + "\r\n" +
		"Subject: " + subject + "\r\n" +
		"\r\n" +
		body + "\r\n")

	// Connect to the SMTP server and send the email.
	return smtp.SendMail(smtpHost+":"+smtpPort, auth, from, []string{to}, msg)
}
