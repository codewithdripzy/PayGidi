package controllers

import (
	"github.com/gin-gonic/gin"
)

func Logout(c *gin.Context) {
	var json map[string]interface{}
	if err := c.ShouldBindJSON(&json); err != nil {
		c.JSON(400, gin.H{"error": err.Error()})
		return
	}
	c.JSON(200, json)
}
