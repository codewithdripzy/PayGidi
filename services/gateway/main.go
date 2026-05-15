package main

import (
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os"

	"github.com/gin-gonic/gin"
)

func main() {
	r := gin.Default()

	// Target URLs from environment variables or defaults
	accountURL := getEnv("ACCOUNT_SERVICE_URL", "http://account-service:8080")
	walletURL := getEnv("WALLET_SERVICE_URL", "http://wallet-service:8082")
	transactionURL := getEnv("TRANSACTION_SERVICE_URL", "http://transaction-service:8081")
	aiURL := getEnv("AI_SERVICE_URL", "http://ai-service:8083")
	notificationURL := getEnv("NOTIFICATION_SERVICE_URL", "http://notification-service:8080")

	// Create reverse proxies
	createProxy := func(target string) *httputil.ReverseProxy {
		proxy := httputil.NewSingleHostReverseProxy(parseURL(target))
		proxy.ErrorHandler = func(w http.ResponseWriter, r *http.Request, err error) {
			log.Printf("Proxy Error (%s): %v", target, err)
			w.WriteHeader(http.StatusBadGateway)
			w.Write([]byte("Bad Gateway: " + err.Error()))
		}
		return proxy
	}

	accountProxy := createProxy(accountURL)
	walletProxy := createProxy(walletURL)
	transactionProxy := createProxy(transactionURL)
	aiProxy := createProxy(aiURL)
	notificationProxy := createProxy(notificationURL)

	// --- Central Swagger UI ---
	// We'll serve a custom HTML page that aggregates all swagger.json files.
	r.GET("/docs", serveSwaggerUI)
	
	// Proxy to each service's swagger.json
	r.GET("/docs/account/swagger.json", gin.WrapH(proxyRewrite(accountProxy, "/docs/doc.json")))
	r.GET("/docs/wallet/swagger.json", gin.WrapH(proxyRewrite(walletProxy, "/docs/doc.json")))
	r.GET("/docs/transaction/swagger.json", gin.WrapH(proxyRewrite(transactionProxy, "/docs/doc.json")))
	r.GET("/docs/ai/swagger.json", gin.WrapH(proxyRewrite(aiProxy, "/docs/doc.json")))
	r.GET("/docs/notification/swagger.json", gin.WrapH(proxyRewrite(notificationProxy, "/docs/doc.json")))


	// --- API Routing ---
	api := r.Group("/api/v1")
	
	// Account Service routes
	api.Any("/auth/*path", gin.WrapH(accountProxy))
	api.Any("/business/*path", gin.WrapH(accountProxy))
	
	// Wallet Service routes
	api.Any("/wallet/*path", gin.WrapH(walletProxy))
	api.Any("/payment/*path", gin.WrapH(walletProxy))
	
	// Transaction Service routes
	api.Any("/transactions/*path", gin.WrapH(transactionProxy))
	
	// AI Service routes
	api.Any("/kyb/*path", gin.WrapH(aiProxy))
	
	// Notification Service routes
	api.Any("/notification/*path", gin.WrapH(notificationProxy))

	// Webhook routes (routed to wallet service)
	api.POST("/webhook/squad", gin.WrapH(walletProxy))

	// Health check
	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"status": "Gateway is healthy"})
	})

	port := getEnv("PORT", "8080")
	log.Printf("Gateway starting on port %s", port)
	r.Run(":" + port)
}

func getEnv(key, fallback string) string {
	if value, exists := os.LookupEnv(key); exists {
		return value
	}
	return fallback
}

func parseURL(rawUrl string) *url.URL {
	u, err := url.Parse(rawUrl)
	if err != nil {
		log.Fatalf("Invalid URL %s: %v", rawUrl, err)
	}
	return u
}

// proxyRewrite creates a handler that rewrites the request path before proxying
func proxyRewrite(proxy *httputil.ReverseProxy, newPath string) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		r.URL.Path = newPath
		proxy.ServeHTTP(w, r)
	})
}

func serveSwaggerUI(c *gin.Context) {
	html := `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>PayGidi API Documentation</title>
  <link rel="stylesheet" type="text/css" href="https://unpkg.com/swagger-ui-dist@5.9.0/swagger-ui.css" >
  <style>
    html { box-sizing: border-box; overflow: -moz-scrollbars-vertical; overflow-y: scroll; }
    *, *:before, *:after { box-sizing: inherit; }
    body { margin: 0; background: #fafafa; }
  </style>
</head>
<body>
  <div id="swagger-ui"></div>
  <script src="https://unpkg.com/swagger-ui-dist@5.9.0/swagger-ui-bundle.js"> </script>
  <script src="https://unpkg.com/swagger-ui-dist@5.9.0/swagger-ui-standalone-preset.js"> </script>
  <script>
    window.onload = function() {
      const ui = SwaggerUIBundle({
        urls: [
          { url: "/docs/account/swagger.json", name: "Account & Auth Service" },
          { url: "/docs/wallet/swagger.json", name: "Wallet & Payments Service" },
          { url: "/docs/transaction/swagger.json", name: "Transaction History Service" },
          { url: "/docs/ai/swagger.json", name: "AI & KYB Verification Service" },
          { url: "/docs/notification/swagger.json", name: "Notification Service" }
        ],
        dom_id: '#swagger-ui',
        deepLinking: true,
        presets: [ SwaggerUIBundle.presets.apis, SwaggerUIStandalonePreset ],
        plugins: [ SwaggerUIBundle.plugins.DownloadUrl ],
        layout: "StandaloneLayout"
      })
      window.ui = ui
    }
  </script>
</body>
</html>`
	c.Data(http.StatusOK, "text/html; charset=utf-8", []byte(html))
}
