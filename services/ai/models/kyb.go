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
)

type VerificationStatus string

const (
	StatusPending   VerificationStatus = "pending"
	StatusReview    VerificationStatus = "review"
	StatusApproved  VerificationStatus = "approved"
	StatusRejected  VerificationStatus = "rejected"
)

type Business struct {
	ID                uuid.UUID      `gorm:"type:uuid;primaryKey" json:"id"`
	Name              string         `gorm:"not null" json:"name"`
	RegistrationNumber string         `gorm:"unique;not null" json:"registration_number"` // CAC number
	Type              BusinessType   `gorm:"not null" json:"type"`
	Category          string         `json:"category"`
	Country           string         `gorm:"default:'Nigeria'" json:"country"`
	Address           string         `json:"address"`
	Phone             string         `json:"phone"`
	Email             string         `json:"email"`
	Website           string         `json:"website"`
	SocialLinks       string         `json:"social_links"` // JSON string or array
	DateFounded       time.Time      `json:"date_founded"`
	TIN               string         `json:"tin"`
	
	// Verification Data
	VerificationStatus VerificationStatus `gorm:"default:'pending'" json:"verification_status"`
	TrustScore         int                `gorm:"default:0" json:"trust_score"`
	RiskAnalysis       string             `gorm:"type:text" json:"risk_analysis"` // LLM summary
	
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
	
	IsVerified    bool      `gorm:"default:false" json:"is_verified"`
	CreatedAt     time.Time `json:"created_at"`
	UpdatedAt     time.Time `json:"updated_at"`
}

type Document struct {
	ID          uuid.UUID `gorm:"type:uuid;primaryKey" json:"id"`
	BusinessID  uuid.UUID `gorm:"type:uuid;index" json:"business_id"`
	Type        string    `json:"type"` // CAC_CERT, TIN_CERT, UTILITY_BILL, etc.
	FileURL     string    `json:"file_url"`
	ExtractedData string  `gorm:"type:text" json:"extracted_data"` // OCR results
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
