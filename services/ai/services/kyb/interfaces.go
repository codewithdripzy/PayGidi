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

type SocialMediaResult struct {
	AccountAgeMonths int
	EngagementRate   float64
	FollowerCount    int
	IsAuthentic      bool
	PostFrequency    string // "daily", "weekly", etc.
	CustomerFeedback string // Summary of comments
	SentimentScore   float64
}

type CommerceSignals struct {
	DeliveryEvidence []string
	RefundHistory    string
	PaymentHistory   string
}

type OCRProvider interface {
	ExtractData(ctx context.Context, fileURL string) (*OCRResult, error)
}

type IdentityProvider interface {
	VerifyDirector(ctx context.Context, director *models.Director) (*VerificationResult, error)
	VerifyBusiness(ctx context.Context, business *models.Business) (*VerificationResult, error)
}

type RiskEngine interface {
	ComputeScore(business *models.Business) (int, models.TrustTier, string)
}

type LLMAnalyzer interface {
	AnalyzeRisk(ctx context.Context, business *models.Business, signals map[string]interface{}) (string, error)
}

type NINProvider interface {
	VerifyNIN(ctx context.Context, nin string) (string, error)
}

type SocialMediaProvider interface {
	AnalyzeInstagram(ctx context.Context, handle string) (*SocialMediaResult, error)
	AnalyzeFacebook(ctx context.Context, handle string) (*SocialMediaResult, error)
	AnalyzeTikTok(ctx context.Context, handle string) (*SocialMediaResult, error)
	AnalyzeLinkedIn(ctx context.Context, handle string) (*SocialMediaResult, error)
}

type ReputationProvider interface {
	GetCustomerReputation(ctx context.Context, businessName string) (float64, string, error)
}
