package kyb

import (
	"context"
	"github.com/PayGidi/AIService/models"
)

type MockOCRProvider struct{}

func (p *MockOCRProvider) ExtractData(ctx context.Context, fileURL string) (*OCRResult, error) {
	// In a real implementation, this would call Google Vision / Textract
	return &OCRResult{
		RegistrationNumber: "RC123456",
		BusinessName:      "PayGidi Mock Ltd",
		Address:           "123 Mock Street, Lagos",
		RawText:           "Full OCR text content would go here...",
	}, nil
}

type MockIdentityProvider struct{}

func (p *MockIdentityProvider) VerifyDirector(ctx context.Context, director *models.Director) (*VerificationResult, error) {
	// In a real implementation, this would call Smile Identity / Dojah
	return &VerificationResult{
		IsMatch: true,
		Details: "Face matched against NIN records.",
		Score:   95,
	}, nil
}

func (p *MockIdentityProvider) VerifyBusiness(ctx context.Context, business *models.Business) (*VerificationResult, error) {
	// In a real implementation, this would call CAC registry via a provider
	return &VerificationResult{
		IsMatch: true,
		Details: "Business found in CAC registry.",
		Score:   100,
	}, nil
}
