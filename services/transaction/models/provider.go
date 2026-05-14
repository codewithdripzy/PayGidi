package models

import (
	"time"
)

type Provider struct {
	ID           uint     `json:"id" gorm:"primaryKey;autoIncrement"`
	UserID       uint     `json:"userId"`              // Reference to the user associated with the provider
	ExternalID   string     `json:"externalId"`          // Unique identifier from the external provider
	ProviderType string     `json:"providerType"`        // Type of the provider (e.g., "google", "facebook")
	AccessToken  string     `json:"accessToken"`         // Access token for the provider
	RefreshToken string     `json:"refreshToken"`        // Refresh token for the provider
	ExpiresAt    time.Time  `json:"expiresAt"`           // Expiration time for the access token
	CreatedAt    time.Time  `json:"createdAt"`           // Timestamp when the provider was created
	UpdatedAt    time.Time  `json:"updatedAt"`           // Timestamp when the provider was last updated
	DeletedAt    *time.Time `json:"deletedAt,omitempty"` // Nullable for soft deletes
}
