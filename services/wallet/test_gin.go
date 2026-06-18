package main

import (
	"log"
	"net/http"
	"github.com/gin-gonic/gin"
)

func main() {
	r := gin.Default()
	api := r.Group("/api")
	api.GET("/public", func(c *gin.Context) {
		c.String(200, "public")
	})
	api.Use(func(c *gin.Context) {
		log.Println("Middleware executed")
		c.Next()
	})
	api.GET("/private", func(c *gin.Context) {
		c.String(200, "private")
	})
    // Start temporarily and make requests
	go r.Run(":9999")
}
