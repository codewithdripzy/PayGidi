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
	sentiment  SentimentProvider
	wallet     *wallet.WalletClient
}

func NewOrchestrator(db *gorm.DB, ocr OCRProvider, identity IdentityProvider, risk RiskEngine, llm LLMAnalyzer, nin NINProvider, sentiment SentimentProvider, wallet *wallet.WalletClient) *Orchestrator {
	return &Orchestrator{
		db:         db,
		ocr:        ocr,
		identity:   identity,
		riskEngine: risk,
		llm:        llm,
		nin:        nin,
		sentiment:  sentiment,
		wallet:     wallet,
	}
}

func (o *Orchestrator) ProcessKYB(ctx context.Context, businessID string) error {
	var business models.Business
	if err := o.db.Preload("Directors").Preload("Documents").First(&business, "id = ?", businessID).Error; err != nil {
		return err
	}

	// STEP 1: Input Validation (already assumed done via API layer)

	// STEP 2: Document OCR + Extraction
	for i, doc := range business.Documents {
		res, err := o.ocr.ExtractData(ctx, doc.FileURL)
		if err == nil {
			business.Documents[i].ExtractedData = res.RawText
			// Compare extracted CAC number with submitted one
			if res.RegistrationNumber != "" && res.RegistrationNumber != business.RegistrationNumber {
				// Potential mismatch
				fmt.Printf("Mismatch: Submitted %s, Extracted %s\n", business.RegistrationNumber, res.RegistrationNumber)
			}
		}
	}

	// STEP 3: Government / Registry Verification
	res, err := o.identity.VerifyBusiness(ctx, &business)
	if err == nil && res.IsMatch {
		business.VerificationStatus = models.StatusApproved
	} else {
		business.VerificationStatus = models.StatusReview
	}

	// STEP 4: Director Verification (Face match / Liveness)
	for i, director := range business.Directors {
		res, err := o.identity.VerifyDirector(ctx, &director)
		if err == nil && res.IsMatch {
			business.Directors[i].IsVerified = true
		}
	}

	// STEP 5: Risk Scoring Engine
	score, summary := o.riskEngine.ComputeScore(&business)
	business.TrustScore = score

	// STEP 6: LLM Analysis Layer (Optional but helpful)
	if o.llm != nil {
		analysis, err := o.llm.AnalyzeRisk(ctx, &business, map[string]interface{}{"summary": summary})
		if err == nil {
			business.RiskAnalysis = analysis
		}
	} else {
		business.RiskAnalysis = summary
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
		for _, doc := range business.Documents {
			if err := tx.Save(&doc).Error; err != nil {
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
	_ = o.wallet.UpdatePaymentStatus(ctx, paymentID, "in_progress", 0, "AI Analysis has started...")

	// 2. Perform Verifications
	
	// NIN Verification
	ninSummary, err := o.nin.VerifyNIN(ctx, nin)
	if err != nil {
		ninSummary = "NIN Verification failed: " + err.Error()
	}

	// Sentiment Analysis
	sentimentSummary, err := o.sentiment.AnalyzeSocialSentiment(ctx, socialHandle)
	if err != nil {
		sentimentSummary = "Sentiment Analysis failed: " + err.Error()
	}

	// Mock Business model for Risk Engine (backward compatibility)
	mockBusiness := &models.Business{
		Name:               businessName,
		RegistrationNumber: cacNumber,
		SocialLinks:        socialHandle,
	}
	
	// CAC / Identity Verification
	identityRes, err := o.identity.VerifyBusiness(ctx, mockBusiness)
	var identitySummary string
	if err == nil {
		identitySummary = identityRes.Details
		if identityRes.IsMatch {
			mockBusiness.VerificationStatus = models.StatusApproved
		}
	} else {
		identitySummary = "CAC Verification failed: " + err.Error()
	}

	// 3. Compute Score
	score, riskSummary := o.riskEngine.ComputeScore(mockBusiness)
	
	// Bonus score for NIN and Sentiment
	if !strings.Contains(ninSummary, "failed") {
		score += 10
	}
	if !strings.Contains(sentimentSummary, "failed") {
		score += 5
	}
	
	if score > 100 {
		score = 100
	}

	finalSummary := fmt.Sprintf("Analysis for %s (Payment #%d):\n- %s\n- %s\n- %s\n- Risk Engine Result: %s", 
		businessName, paymentID, ninSummary, sentimentSummary, identitySummary, riskSummary)

	// 4. Save Analysis
	analysis := &models.Analysis{
		PaymentID:       paymentID,
		BusinessName:    businessName,
		Summary:         finalSummary,
		TrustScore:      score,
		NINData:         ninSummary,
		CACData:         identitySummary,
		SocialSentiment: sentimentSummary,
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
	if score < 70 {
		finalStatus = "action_required"
	}
	_ = o.wallet.UpdatePaymentStatus(ctx, paymentID, finalStatus, float64(score), finalSummary)

	return analysis, nil
}
