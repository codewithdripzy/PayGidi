package controllers

import (
	"crypto/hmac"
	"crypto/sha512"
	"encoding/hex"
	"encoding/json"
	"io"
	"log"
	"net/http"
	"os"
	"strings"

	"github.com/PayGidi/WalletService/models"
	"github.com/gin-gonic/gin"
)

type SquadWebhookPayload struct {
	Event string `json:"event"`
	Data  struct {
		TransactionReference string  `json:"transaction_reference"`
		Amount               float64 `json:"amount"`
		GatewayReference     string  `json:"gateway_reference"`
		VirtualAccountNumber string  `json:"virtual_account_number"`
		CustomerIdentifier   string  `json:"customer_identifier"`
	} `json:"data"`
}

func (wc *WalletController) HandleSquadWebhook(c *gin.Context) {
	secretKey := os.Getenv("SQUAD_SECRET_KEY")
	signature := c.GetHeader("x-squad-signature")

	body, err := io.ReadAll(c.Request.Body)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "failed to read body"})
		return
	}

	// Verify Signature
	if !verifySquadSignature(body, signature, secretKey) {
		log.Printf("[Webhook] Invalid signature received")
		c.JSON(http.StatusUnauthorized, gin.H{"message": "invalid signature"})
		return
	}

	var payload SquadWebhookPayload
	if err := json.Unmarshal(body, &payload); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "invalid json"})
		return
	}

	log.Printf("[Webhook] Received event: %s for ref: %s", payload.Event, payload.Data.TransactionReference)

	if payload.Event == "virtual_account_credited" {
		// Handle funding of wallet
		var account models.Account
		if err := wc.db.Where("provider_account_number = ?", payload.Data.VirtualAccountNumber).First(&account).Error; err == nil {
			// Update balance or log transaction
			log.Printf("[Webhook] Crediting account: %s with %f", account.AccountNumber, payload.Data.Amount)
			
			// Here you would typically update the account balance or create a transaction record
			// For PayGidi, we might also want to check if this is tied to a specific 'Payment' record
		}
	}

	c.JSON(http.StatusOK, gin.H{"message": "ok"})
}

func verifySquadSignature(body []byte, signature, secretKey string) bool {
	h := hmac.New(sha512.New, []byte(secretKey))
	h.Write(body)
	expectedSignature := hex.EncodeToString(h.Sum(nil))
	return strings.EqualFold(expectedSignature, signature)
}
