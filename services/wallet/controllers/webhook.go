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

	var data SquadWebhookDataV3
	if err := json.Unmarshal(body, &data); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "invalid json"})
		return
	}

	// Verify HMAC-SHA512 signature — try V3 pipe-delimited first, fallback to V1 full-body
	if !verifySquadSignatureV3(data, signature, secretKey) &&
		!verifySquadSignatureV1(body, signature, secretKey) {
		log.Printf("[Webhook] Invalid signature received")
		c.JSON(http.StatusUnauthorized, gin.H{"message": "invalid signature"})
		return
	}

	log.Printf("[Webhook] ref=%s va=%s amount=%s sender=%s",
		data.TransactionReference, data.VirtualAccountNumber,
		data.SettledAmount, data.SenderName)

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

// verifySquadSignatureV1 verifies HMAC-SHA512 of the entire request body (V1 method).
func verifySquadSignatureV1(body []byte, signature, secretKey string) bool {
	h := hmac.New(sha512.New, []byte(secretKey))
	h.Write(body)
	expectedSignature := hex.EncodeToString(h.Sum(nil))
	return strings.EqualFold(expectedSignature, signature)
}

// verifySquadSignatureV3 verifies HMAC-SHA512 of pipe-delimited fields (V2/V3 method).
// Fields: transaction_reference|virtual_account_number|currency|principal_amount|settled_amount|customer_identifier
func verifySquadSignatureV3(data SquadWebhookDataV3, signature, secretKey string) bool {
	dataToHash := strings.Join([]string{
		data.TransactionReference,
		data.VirtualAccountNumber,
		data.Currency,
		data.PrincipalAmount,
		data.SettledAmount,
		data.CustomerIdentifier,
	}, "|")
	h := hmac.New(sha512.New, []byte(secretKey))
	h.Write([]byte(dataToHash))
	expectedSignature := hex.EncodeToString(h.Sum(nil))
	return strings.EqualFold(expectedSignature, signature)
}
