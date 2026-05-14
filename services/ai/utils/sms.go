package utils

import (
	"os"

	"github.com/twilio/twilio-go"
	openapi "github.com/twilio/twilio-go/rest/api/v2010"
)

// SendSMS sends an SMS using an external service
func SendSMS(to, message string) error {
	client := twilio.NewRestClientWithParams(twilio.ClientParams{
		Username: os.Getenv("TWILIO_SID"),
		Password: os.Getenv("TWILIO_AUTH_TOKEN"),
	})

	params := &openapi.CreateMessageParams{}
	params.SetTo(to)
	params.SetFrom(os.Getenv("TWILIO_PHONE")) // Your Twilio phone number
	params.SetBody(message)

	_, err := client.Api.CreateMessage(params)
	return err
}
