package kyb

import (
	"strings"

	"github.com/PayGidi/AIService/models"
)

type DefaultRiskEngine struct{}

func NewRiskEngine() RiskEngine {
	return &DefaultRiskEngine{}
}

func (e *DefaultRiskEngine) ComputeScore(business *models.Business) (int, models.TrustTier, string) {
	score := 0
	var observations []string
	tier := models.Tier0Unverified

	// 1. Identity Trust (Weight: 30)
	identityScore := 0
	allDirectorsVerified := true
	hasDirectors := len(business.Directors) > 0
	if hasDirectors {
		for _, d := range business.Directors {
			if d.IsVerified {
				identityScore += 15 // Up to 30 for multiple directors
			} else {
				allDirectorsVerified = false
			}
		}
	} else {
		allDirectorsVerified = false
	}

	if identityScore > 30 {
		identityScore = 30
	}
	score += identityScore
	if identityScore >= 15 {
		tier = models.Tier1Identity
		if allDirectorsVerified {
			observations = append(observations, "All directors' identities verified via NIN/BVN.")
		} else {
			observations = append(observations, "Partial director identity verification completed.")
		}
	}

	// 2. Social Trust (Weight: 20)
	socialScore := 0
	if business.InstagramHandle != "" || business.FacebookHandle != "" || business.TikTokHandle != "" {
		socialScore += 10
		if business.EngagementScore > 0 {
			socialScore += 10
		}
		observations = append(observations, "Active social media presence detected.")
	}
	score += socialScore
	if socialScore >= 15 && tier < models.Tier2Social {
		tier = models.Tier2Social
	}

	// 3. Commerce & Behavioral Trust (Weight: 30)
	commerceScore := 0
	if business.DeliverySuccessRate > 0.8 {
		commerceScore += 20
		observations = append(observations, "High delivery success rate.")
	} else if business.DeliverySuccessRate > 0.5 {
		commerceScore += 10
		observations = append(observations, "Moderate delivery history.")
	}

	if business.DisputeRate < 0.05 {
		commerceScore += 10
		observations = append(observations, "Low dispute rate.")
	}
	score += commerceScore

	// 4. Business Trust (Weight: 20)
	businessScore := 0
	if business.RegistrationNumber != "" && business.VerificationStatus == models.StatusApproved {
		businessScore += 20
		tier = models.Tier3Registered
		observations = append(observations, "Official CAC registration verified.")
	}
	score += businessScore

	// CAP at 100 and Floor at 0
	if score > 100 {
		score = 100
	}
	if score < 0 {
		score = 0
	}

	summary := strings.Join(observations, " ")
	if summary == "" {
		summary = "No significant trust signals found."
	}

	return score, tier, summary
}
