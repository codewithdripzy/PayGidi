package kyb

import (
	"context"
	"fmt"
	"strings"
	"github.com/PayGidi/AIService/models"
	"github.com/PayGidi/AIService/services/wallet"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Orchestrator struct {
	db         *gorm.DB
	ocr        OCRProvider
	identity   IdentityProvider
	riskEngine RiskEngine
	llm        LLMAnalyzer
	nin        NINProvider
	socialMedia SocialMediaProvider
	reputation ReputationProvider
	wallet     *wallet.WalletClient
}

func NewOrchestrator(db *gorm.DB, ocr OCRProvider, identity IdentityProvider, risk RiskEngine, llm LLMAnalyzer, nin NINProvider, social SocialMediaProvider, rep ReputationProvider, wallet *wallet.WalletClient) *Orchestrator {
	return &Orchestrator{
		db:          db,
		ocr:         ocr,
		identity:    identity,
		riskEngine:  risk,
		llm:         llm,
		nin:         nin,
		socialMedia: social,
		reputation:  rep,
		wallet:      wallet,
	}
}

func (o *Orchestrator) ProcessKYB(ctx context.Context, businessID string) error {
	var business models.Business
	if err := o.db.Preload("Directors").Preload("Documents").First(&business, "id = ?", businessID).Error; err != nil {
		return err
	}

	// Update status to in_progress
	o.db.Model(&business).Update("verification_status", models.StatusPending)

	// PIPELINE START
	
	// STEP 1: Identity Verification (Tier 1)
	// BVN/NIN and Selfie/Liveness for Directors
	identityMatched := true
	for i, director := range business.Directors {
		res, err := o.identity.VerifyDirector(ctx, &director)
		if err == nil && res.IsMatch {
			business.Directors[i].IsVerified = true
			business.Directors[i].LivenessScore = float64(res.Score)
		} else {
			identityMatched = false
		}
	}
	
	if identityMatched {
		business.TrustTier = models.Tier1Identity
	}

	// STEP 2: Social Presence Analysis (Tier 2)
	socialScore := 0
	platformsFound := 0
	
	if business.InstagramHandle != "" {
		res, err := o.socialMedia.AnalyzeInstagram(ctx, business.InstagramHandle)
		if err == nil && res.IsAuthentic {
			socialScore += int(res.SentimentScore * 25)
			platformsFound++
		}
	}
	
	if business.FacebookHandle != "" {
		res, err := o.socialMedia.AnalyzeFacebook(ctx, business.FacebookHandle)
		if err == nil && res.IsAuthentic {
			socialScore += int(res.SentimentScore * 15)
			platformsFound++
		}
	}

	if business.TikTokHandle != "" {
		res, err := o.socialMedia.AnalyzeTikTok(ctx, business.TikTokHandle)
		if err == nil && res.IsAuthentic {
			socialScore += int(res.SentimentScore * 15)
			platformsFound++
		}
	}

	if business.LinkedInHandle != "" {
		res, err := o.socialMedia.AnalyzeLinkedIn(ctx, business.LinkedInHandle)
		if err == nil && res.IsAuthentic {
			socialScore += int(res.SentimentScore * 10)
			platformsFound++
		}
	}

	if platformsFound > 0 {
		business.TrustTier = models.Tier2Social
		business.EngagementScore = socialScore
	}

	// STEP 3: Commerce & Reputation Signals
	repScore, repSummary, err := o.reputation.GetCustomerReputation(ctx, business.Name)
	if err == nil {
		business.DeliverySuccessRate = repScore
	}

	// STEP 4: Registered Business Check (Tier 3)
	if business.RegistrationNumber != "" {
		res, err := o.identity.VerifyBusiness(ctx, &business)
		if err == nil && res.IsMatch {
			business.TrustTier = models.Tier3Registered
		}
	}

	// STEP 5: Final Risk Scoring Engine
	score, tier, riskSummary := o.riskEngine.ComputeScore(&business)
	business.TrustScore = score
	business.TrustTier = tier

	// STEP 6: LLM Contextual Summary
	signals := map[string]interface{}{
		"reputation_summary": repSummary,
		"social_platforms": platformsFound,
		"identity_verified": identityMatched,
	}
	
	if o.llm != nil {
		analysis, err := o.llm.AnalyzeRisk(ctx, &business, signals)
		if err == nil {
			business.RiskAnalysis = analysis
		}
	} else {
		business.RiskAnalysis = riskSummary
	}

	// STEP 7: Final Status Determination
	if business.TrustScore >= 70 {
		business.VerificationStatus = models.StatusApproved
	} else if business.TrustScore >= 40 {
		business.VerificationStatus = models.StatusReview
	} else {
		business.VerificationStatus = models.StatusRejected
	}

	// Save all changes
	return o.db.Transaction(func(tx *gorm.DB) error {
		if err := tx.Save(&business).Error; err != nil {
			return err
		}
		for _, d := range business.Directors {
			if err := tx.Save(&d).Error; err != nil {
				return err
			}
		}
		return nil
	})
}

func (o *Orchestrator) ProcessPaymentKYB(ctx context.Context, paymentID uint64, businessID *string, businessName, nin, cacNumber, socialHandle string) (*models.Analysis, error) {
	// 1. Fetch Payment info from Wallet Service via gRPC
	paymentData, err := o.wallet.GetPayment(ctx, paymentID)
	if err != nil {
		return nil, fmt.Errorf("failed to fetch payment data from wallet service: %w", err)
	}
	if paymentData == nil {
		return nil, fmt.Errorf("payment with ID %d not found in wallet service", paymentID)
	}

	// Notify Wallet service that analysis is starting
	_ = o.wallet.UpdatePaymentStatus(ctx, paymentID, "in_progress", 0, "AI Multi-Tier Trust Analysis has started...")

	// 2. Perform Verifications
	
	// NIN Verification
	ninSummary, err := o.nin.VerifyNIN(ctx, nin)
	if err != nil {
		ninSummary = "NIN Verification failed: " + err.Error()
	}

	// Social Media Analysis (Assume Instagram by default if only one handle)
	socialSummary := "No social handle provided"
	var socialResult *SocialMediaResult
	if socialHandle != "" {
		socialResult, err = o.socialMedia.AnalyzeInstagram(ctx, socialHandle)
		if err == nil {
			socialSummary = fmt.Sprintf("Instagram: %d followers, %v%% engagement, %s", 
				socialResult.FollowerCount, socialResult.EngagementRate, socialResult.CustomerFeedback)
		} else {
			socialSummary = "Social Analysis failed: " + err.Error()
		}
	}

	// Mock Business model for Risk Engine
	mockBusiness := &models.Business{
		Name:               businessName,
		RegistrationNumber: cacNumber,
		InstagramHandle:    socialHandle,
	}
	
	// Identity matched if NIN is valid
	if !strings.Contains(ninSummary, "failed") {
		mockBusiness.Directors = []models.Director{{IsVerified: true}}
	}
	
	// Social match
	if socialResult != nil && socialResult.IsAuthentic {
		mockBusiness.EngagementScore = int(socialResult.SentimentScore * 100)
	}

	// CAC Verification if provided
	if cacNumber != "" {
		identityRes, err := o.identity.VerifyBusiness(ctx, mockBusiness)
		if err == nil && identityRes.IsMatch {
			mockBusiness.VerificationStatus = models.StatusApproved
		}
	}

	// 3. Compute Score & Tier
	score, tier, riskSummary := o.riskEngine.ComputeScore(mockBusiness)
	
	finalSummary := fmt.Sprintf("Trust Analysis for %s (Payment #%d):\n- %s\n- %s\n- Risk Result: %s", 
		businessName, paymentID, ninSummary, socialSummary, riskSummary)

	// 4. Save Analysis
	analysis := &models.Analysis{
		PaymentID:       paymentID,
		BusinessName:    businessName,
		Summary:         finalSummary,
		TrustScore:      score,
		TrustTier:       tier,
		NINData:         ninSummary,
		CACData:         riskSummary,
		SocialSentiment: socialSummary,
	}

	if businessID != nil && *businessID != "" {
		bID, err := uuid.Parse(*businessID)
		if err == nil {
			analysis.BusinessID = &bID
		}
	}

	if err := o.db.Create(analysis).Error; err != nil {
		return nil, fmt.Errorf("failed to save analysis to database: %w", err)
	}

	// Update Wallet service with final result
	finalStatus := "pending"
	if score >= 70 {
		finalStatus = "approved" // If high trust, we might approve automatically or move to next step
	} else if score < 40 {
		finalStatus = "action_required"
	}
	_ = o.wallet.UpdatePaymentStatus(ctx, paymentID, finalStatus, float64(score), finalSummary)

	return analysis, nil
}

