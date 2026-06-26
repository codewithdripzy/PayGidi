package models

import (
	"time"

	"gorm.io/gorm"
)

type Thrift struct {
	ID                   uint           `gorm:"primaryKey" json:"id"`
	CreatorID            uint           `gorm:"index;not null" json:"creatorId"`
	Name                 string         `gorm:"not null" json:"name"`
	Description          string         `gorm:"type:text" json:"description"`
	ContributionAmount   float64        `gorm:"not null" json:"contributionAmount"`
	ContributionFrequency string        `gorm:"default:'monthly'" json:"contributionFrequency"`
	MaxMembers           int            `gorm:"default:0" json:"maxMembers"`
	CurrentMembers       int            `gorm:"default:1" json:"currentMembers"`
	IsPublic             bool           `gorm:"default:false" json:"isPublic"`
	Status               string         `gorm:"default:'active'" json:"status"`
	CreatedAt            time.Time      `json:"createdAt"`
	UpdatedAt            time.Time      `json:"updatedAt"`
	DeletedAt            gorm.DeletedAt `gorm:"index" json:"-"`
}

func (Thrift) TableName() string {
	return "thrifts"
}

type ThriftMember struct {
	ID       uint      `gorm:"primaryKey" json:"id"`
	ThriftID uint      `gorm:"index;not null" json:"thriftId"`
	UserID   uint      `gorm:"index;not null" json:"userId"`
	Status   string    `gorm:"default:'active'" json:"status"`
	JoinedAt time.Time `gorm:"autoCreateTime" json:"joinedAt"`
}

func (ThriftMember) TableName() string {
	return "thrift_members"
}
