package controllers

import (
	"net/http"

	"github.com/PayGidi/AccountService/models"
	"github.com/PayGidi/AccountService/validators"
	"github.com/gin-gonic/gin"
	"github.com/lib/pq"
	"gorm.io/gorm"
)

func UpdateBusinessProfile(c *gin.Context) {
	db := c.MustGet("db").(*gorm.DB)
	user, _ := c.Get("user")
	u := user.(models.User)

	if u.AccountType != "business" {
		c.JSON(http.StatusForbidden, gin.H{"error": "This action is only available for business accounts"})
		return
	}

	validatedBody, _ := c.Get("validatedBody")
	data := validatedBody.(*validators.UpdateBusinessProfileDto)

	var business models.Business
	if err := db.Where("user_id = ?", u.ID).First(&business).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Business profile not found"})
		return
	}

	// Update fields
	if data.Name != "" {
		business.Name = data.Name
	}
	if data.RegistrationNumber != "" {
		business.RegistrationNumber = data.RegistrationNumber
	}
	if data.BusinessType != "" {
		business.Type = data.BusinessType
	}
	if data.Industry != "" {
		business.Industry = data.Industry
	}
	if data.Website != "" {
		business.Website = data.Website
	}
	if data.Instagram != "" {
		business.Instagram = data.Instagram
	}
	if data.Twitter != "" {
		business.Twitter = data.Twitter
	}
	if data.LinkedIn != "" {
		business.LinkedIn = data.LinkedIn
	}
	if data.Facebook != "" {
		business.Facebook = data.Facebook
	}

	if err := db.Save(&business).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update business profile: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Business profile updated successfully",
		"data":    business,
	})
}

func UpdateBusinessDocs(c *gin.Context) {
	db := c.MustGet("db").(*gorm.DB)
	user, _ := c.Get("user")
	u := user.(models.User)

	if u.AccountType != "business" {
		c.JSON(http.StatusForbidden, gin.H{"error": "This action is only available for business accounts"})
		return
	}

	validatedBody, _ := c.Get("validatedBody")
	data := validatedBody.(*validators.UpdateBusinessDocsDto)

	var business models.Business
	if err := db.Where("user_id = ?", u.ID).First(&business).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Business profile not found"})
		return
	}

	if data.RegistrationDoc != "" {
		business.RegistrationDoc = data.RegistrationDoc
	}
	if len(data.AdditionalDocs) > 0 {
		business.AdditionalDocs = pq.StringArray(data.AdditionalDocs)
	}

	if err := db.Save(&business).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update business documents: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Business documents updated successfully",
		"data":    business,
	})
}
func GetBusinessProfile(c *gin.Context) {
	db := c.MustGet("db").(*gorm.DB)
	user, _ := c.Get("user")
	u := user.(models.User)

	var business models.Business
	if err := db.Where("user_id = ?", u.ID).First(&business).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Business profile not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Business profile retrieved successfully",
		"data":    business,
	})
}
