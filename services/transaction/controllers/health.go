package controllers;

import (
	"net/http"
	"github.com/gin-gonic/gin"
)

// HealthCheck godoc
// @Summary Health Check
// @Description Check the health of the service
// @Tags Health
// @Accept json
// @Produce json
// @Success 200 {object} map[string]string "Service is healthy"
// @Router /health [get]
func HealthCheck(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"status": "Service is healthy",
	})
}