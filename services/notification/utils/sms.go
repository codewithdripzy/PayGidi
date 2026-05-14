package utils

import (
	"errors"
	"os"

	"github.com/twilio/twilio-go"
	openapi "github.com/twilio/twilio-go/rest/api/v2010"
)

func SendSMS(to, message string) error {
	sid := os.Getenv("TWILIO_SID")
	token := os.Getenv("TWILIO_AUTH_TOKEN")
	from := os.Getenv("TWILIO_PHONE")

	if sid == "" || token == "" || from == "" {
		return errors.New("twilio credentials are not fully configured")
	}

	client := twilio.NewRestClientWithParams(twilio.ClientParams{
		Username: sid,
		Password: token,
	})

	params := &openapi.CreateMessageParams{}
	params.SetTo(to)
	params.SetFrom(from)
	params.SetBody(message)

	_, err := client.Api.CreateMessage(params)
	return err
}
