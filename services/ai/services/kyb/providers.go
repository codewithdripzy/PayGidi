package kyb

import (
	"context"
	"fmt"
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

type MockNINProvider struct{}

func (p *MockNINProvider) VerifyNIN(ctx context.Context, nin string) (string, error) {
	return fmt.Sprintf("NIN %s verified: Valid Nigerian Citizen", nin), nil
}

type MockSocialMediaProvider struct{}

func (p *MockSocialMediaProvider) AnalyzeInstagram(ctx context.Context, handle string) (*SocialMediaResult, error) {
	if handle == "" {
		return nil, fmt.Errorf("no handle provided")
	}
	return &SocialMediaResult{
		AccountAgeMonths: 36,
		EngagementRate:   4.5,
		FollowerCount:    12500,
		IsAuthentic:      true,
		PostFrequency:    "daily",
		CustomerFeedback: "Excellent service, fast delivery mentioned in comments.",
		SentimentScore:   0.88,
	}, nil
}

func (p *MockSocialMediaProvider) AnalyzeFacebook(ctx context.Context, handle string) (*SocialMediaResult, error) {
	return &SocialMediaResult{
		AccountAgeMonths: 48,
		EngagementRate:   2.1,
		FollowerCount:    5000,
		IsAuthentic:      true,
		PostFrequency:    "weekly",
		CustomerFeedback: "Active community group, many tagged buyers.",
		SentimentScore:   0.75,
	}, nil
}

func (p *MockSocialMediaProvider) AnalyzeTikTok(ctx context.Context, handle string) (*SocialMediaResult, error) {
	return &SocialMediaResult{
		AccountAgeMonths: 12,
		EngagementRate:   8.2,
		FollowerCount:    20000,
		IsAuthentic:      true,
		PostFrequency:    "daily",
		CustomerFeedback: "Viral product demos, high engagement.",
		SentimentScore:   0.92,
	}, nil
}

func (p *MockSocialMediaProvider) AnalyzeLinkedIn(ctx context.Context, handle string) (*SocialMediaResult, error) {
	return &SocialMediaResult{
		AccountAgeMonths: 24,
		EngagementRate:   1.5,
		FollowerCount:    800,
		IsAuthentic:      true,
		PostFrequency:    "monthly",
		CustomerFeedback: "Professional profile, business connections verified.",
		SentimentScore:   0.65,
	}, nil
}

type MockReputationProvider struct{}

func (p *MockReputationProvider) GetCustomerReputation(ctx context.Context, businessName string) (float64, string, error) {
	return 0.95, "Highly trusted merchant with 95% positive delivery feedback across 500+ orders.", nil
}
