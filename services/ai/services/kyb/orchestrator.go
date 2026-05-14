package kyb

import (
	"context"
	"fmt"
	"github.com/PayGidi/AIService/models"
	"gorm.io/gorm"
)

type Orchestrator struct {
	db          *gorm.DB
	ocr         OCRProvider
	identity    IdentityProvider
	riskEngine  RiskEngine
	llm         LLMAnalyzer
}

func NewOrchestrator(db *gorm.DB, ocr OCRProvider, identity IdentityProvider, risk RiskEngine, llm LLMAnalyzer) *Orchestrator {
	return &Orchestrator{
		db:         db,
		ocr:        ocr,
		identity:   identity,
		riskEngine: risk,
		llm:        llm,
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
