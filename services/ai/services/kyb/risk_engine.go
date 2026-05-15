package kyb

import (
	"fmt"
	"strings"
	"github.com/PayGidi/AIService/models"
)

type DefaultRiskEngine struct{}

func NewRiskEngine() RiskEngine {
	return &DefaultRiskEngine{}
}

func (e *DefaultRiskEngine) ComputeScore(business *models.Business) (int, string) {
	score := 50 // Start with a neutral score
	var observations []string

	// CAC Verification (+30)
	if business.VerificationStatus == models.StatusApproved {
		score += 30
		observations = append(observations, "CAC registration verified.")
	} else if business.VerificationStatus == models.StatusRejected {
		score -= 50
		observations = append(observations, "CAC registration verification failed.")
	}

	// Director Verification
	allDirectorsVerified := true
	for _, d := range business.Directors {
		if !d.IsVerified {
			allDirectorsVerified = false
			break
		}
	}
	if allDirectorsVerified && len(business.Directors) > 0 {
		score += 20
		observations = append(observations, "All directors' identities verified.")
	} else if len(business.Directors) > 0 {
		score += 5
		observations = append(observations, "Some directors verified.")
	} else {
		score -= 10
		observations = append(observations, "No directors provided or verified.")
	}

	// Document Checks
	if len(business.Documents) > 0 {
		score += 10
		observations = append(observations, fmt.Sprintf("%d documents submitted.", len(business.Documents)))
	}

	// Website/Social Presence
	if business.Website != "" {
		score += 5
		observations = append(observations, "Business has a website.")
	}
	if business.SocialLinks != "" {
		score += 5
		observations = append(observations, "Social presence detected.")
	}

	// CAP at 100 and Floor at 0
	if score > 100 {
		score = 100
	}
	if score < 0 {
		score = 0
	}

	summary := strings.Join(observations, " ")
	return score, summary
}
