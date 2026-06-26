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

	"github.com/gin-gonic/gin"
)

func (wc *WalletController) HandleSquadWebhook(c *gin.Context) {
	secretKey := os.Getenv("SQUAD_SECRET_KEY")
	signature := c.GetHeader("x-squad-signature")

	body, err := io.ReadAll(c.Request.Body)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "failed to read body"})
		return
	}

	// Verify HMAC-SHA512 signature
	if !verifySquadSignature(body, signature, secretKey) {
		log.Printf("[Webhook] Invalid signature received")
		c.JSON(http.StatusUnauthorized, gin.H{"message": "invalid signature"})
		return
	}

	var payload SquadWebhookPayloadV3
	if err := json.Unmarshal(body, &payload); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "invalid json"})
		return
	}

	data := payload.Data
	log.Printf("[Webhook] event=%s ref=%s va=%s amount=%s sender=%s",
		payload.Event, data.TransactionReference, data.VirtualAccountNumber,
		data.SettledAmount, data.SenderName)

	if payload.Event != "virtual_account_credited" {
		c.JSON(http.StatusOK, gin.H{"message": "ignored"})
		return
	}

	// Deduplicate by transaction reference
	if dedupByReference(wc.db, data.TransactionReference) {
		log.Printf("[Webhook] duplicate ref=%s — skipping", data.TransactionReference)
		c.JSON(http.StatusOK, gin.H{"message": "duplicate"})
		return
	}

	// Enqueue to the persistent queue (DB-backed) and process async
	record, queued, err := enqueueWebhookRecord(wc.db, data, body)
	if err != nil {
		log.Printf("[Webhook] failed to enqueue ref=%s: %v", data.TransactionReference, err)
		c.JSON(http.StatusInternalServerError, gin.H{"message": "failed to record transaction"})
		return
	}

	if queued {
		log.Printf("[Webhook] enqueued ref=%s id=%d", record.TransactionReference, record.ID)
	}

	c.JSON(http.StatusOK, gin.H{"message": "ok"})
}

func verifySquadSignature(body []byte, signature, secretKey string) bool {
	h := hmac.New(sha512.New, []byte(secretKey))
	h.Write(body)
	expectedSignature := hex.EncodeToString(h.Sum(nil))
	return strings.EqualFold(expectedSignature, signature)
}
