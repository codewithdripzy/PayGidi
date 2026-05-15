package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type BusinessType string

const (
	SoleProprietorship BusinessType = "sole_proprietorship"
	LLC               BusinessType = "llc"
	Partnership        BusinessType = "partnership"
	Informal           BusinessType = "informal" // Added for non-CAC businesses
)

type VerificationStatus string

const (
	StatusPending   VerificationStatus = "pending"
	StatusReview    VerificationStatus = "review"
	StatusApproved  VerificationStatus = "approved"
	StatusRejected  VerificationStatus = "rejected"
)

type TrustTier int

const (
	Tier0Unverified TrustTier = 0
	Tier1Identity   TrustTier = 1
	Tier2Social     TrustTier = 2
	Tier3Registered TrustTier = 3
)

type Business struct {
	ID                uuid.UUID      `gorm:"type:uuid;primaryKey" json:"id"`
	Name              string         `gorm:"not null" json:"name"`
	RegistrationNumber string         `gorm:"unique" json:"registration_number"` // Optional for Informal
	Type              BusinessType   `gorm:"not null" json:"type"`
	Category          string         `json:"category"`
	Country           string         `gorm:"default:'Nigeria'" json:"country"`
	Address           string         `json:"address"`
	Phone             string         `json:"phone"`
	Email             string         `json:"email"`
	Website           string         `json:"website"`
	SocialLinks       string         `json:"social_links"` // JSON: {"instagram": "@handle", "facebook": "page", ...}
	DateFounded       time.Time      `json:"date_founded"`
	TIN               string         `json:"tin"`
	
	// Verification Data
	VerificationStatus VerificationStatus `gorm:"default:'pending'" json:"verification_status"`
	TrustScore         int                `gorm:"default:0" json:"trust_score"`
	TrustTier          TrustTier          `gorm:"default:0" json:"trust_tier"`
	RiskAnalysis       string             `gorm:"type:text" json:"risk_analysis"` 
	
	// Social Proof & Activity Signals
	InstagramHandle    string `json:"instagram_handle"`
	FacebookHandle     string `json:"facebook_handle"`
	TikTokHandle       string `json:"tiktok_handle"`
	LinkedInHandle     string `json:"linkedin_handle"`
	WhatsAppBusiness   bool   `json:"whatsapp_business"`
	
	AccountAgeScore    int `json:"account_age_score"`
	EngagementScore    int `json:"engagement_score"`
	DeliverySuccessRate float64 `json:"delivery_success_rate"`
	DisputeRate        float64 `json:"dispute_rate"`
	
	CreatedAt         time.Time      `json:"created_at"`
	UpdatedAt         time.Time      `json:"updated_at"`
	DeletedAt         gorm.DeletedAt `gorm:"index" json:"-"`
	
	Directors         []Director     `gorm:"foreignKey:BusinessID" json:"directors"`
	Documents         []Document     `gorm:"foreignKey:BusinessID" json:"documents"`
}

type Director struct {
	ID            uuid.UUID `gorm:"type:uuid;primaryKey" json:"id"`
	BusinessID    uuid.UUID `gorm:"type:uuid;index" json:"business_id"`
	FullName      string    `gorm:"not null" json:"full_name"`
	BVN           string    `json:"bvn"`
	NIN           string    `json:"nin"`
	IDType        string    `json:"id_type"`
	IDNumber      string    `json:"id_number"`
	ResidentialAddr string  `json:"residential_address"`
	Phone         string    `json:"phone"`
	Email         string    `json:"email"`
	OwnershipPercentage float64 `json:"ownership_percentage"`
	
	// Liveness & Identity
	IsVerified    bool      `gorm:"default:false" json:"is_verified"`
	LivenessScore float64   `json:"liveness_score"`
	FaceMatchScore float64  `json:"face_match_score"`
	
	CreatedAt     time.Time `json:"created_at"`
	UpdatedAt     time.Time `json:"updated_at"`
}

type Document struct {
	ID          uuid.UUID `gorm:"type:uuid;primaryKey" json:"id"`
	BusinessID  uuid.UUID `gorm:"type:uuid;index" json:"business_id"`
	Type        string    `json:"type"` // CAC_CERT, TIN_CERT, UTILITY_BILL, NIN_SLIP, etc.
	FileURL     string    `json:"file_url"`
	ExtractedData string  `gorm:"type:text" json:"extracted_data"`
	IsVerified  bool      `gorm:"default:false" json:"is_verified"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

func (b *Business) BeforeCreate(tx *gorm.DB) (err error) {
	b.ID = uuid.New()
	return
}

func (d *Director) BeforeCreate(tx *gorm.DB) (err error) {
	d.ID = uuid.New()
	return
}

func (doc *Document) BeforeCreate(tx *gorm.DB) (err error) {
	doc.ID = uuid.New()
	return
}

type Analysis struct {
	ID              uuid.UUID      `gorm:"type:uuid;primaryKey" json:"id"`
	PaymentID       uint64         `gorm:"index;not null" json:"paymentId"`
	BusinessID      *uuid.UUID     `gorm:"type:uuid;index" json:"businessId"`
	BusinessName    string         `json:"businessName"`
	Summary         string         `gorm:"type:text" json:"summary"`
	TrustScore      int            `json:"trustScore"`
	TrustTier       TrustTier      `json:"trustTier"`
	NINData         string         `gorm:"type:text" json:"ninData"`
	CACData         string         `gorm:"type:text" json:"cacData"`
	SocialSentiment string         `gorm:"type:text" json:"socialSentiment"`
	CreatedAt       time.Time      `json:"created_at"`
	UpdatedAt       time.Time      `json:"updated_at"`
	DeletedAt       gorm.DeletedAt `gorm:"index" json:"-"`
}

func (a *Analysis) BeforeCreate(tx *gorm.DB) (err error) {
	a.ID = uuid.New()
	return
}
