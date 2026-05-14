package kyb

import (
	"context"
	"github.com/PayGidi/AIService/models"
)

type OCRResult struct {
	RegistrationNumber string
	BusinessName      string
	Address           string
	Date              string
	RawText           string
}

type VerificationResult struct {
	IsMatch bool
	Details string
	Score   int
}

type OCRProvider interface {
	ExtractData(ctx context.Context, fileURL string) (*OCRResult, error)
}

type IdentityProvider interface {
	VerifyDirector(ctx context.Context, director *models.Director) (*VerificationResult, error)
	VerifyBusiness(ctx context.Context, business *models.Business) (*VerificationResult, error)
}

type RiskEngine interface {
	ComputeScore(business *models.Business) (int, string)
}

type LLMAnalyzer interface {
	AnalyzeRisk(ctx context.Context, business *models.Business, signals map[string]interface{}) (string, error)
}
