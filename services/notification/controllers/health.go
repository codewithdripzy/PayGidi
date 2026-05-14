package controllers

import (
	"net/http"

	"github.com/PayGidi/NotificationService/core/constants"
	"github.com/gin-gonic/gin"
)

func HealthCheck(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"status":  "ok",
		"service": constants.ServiceName,
		"version": constants.ServiceVersion,
	})
}
