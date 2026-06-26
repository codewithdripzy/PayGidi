package controllers

import (
	"log"
	"math"
	"strconv"
	"time"

	"github.com/PayGidi/WalletService/models"
	"gorm.io/gorm"
)

// processWebhookJob processes a pending webhook transaction:
// 1. Matches the virtual account to a local wallet account
// 2. Credits the balance
// 3. Marks the record as completed (or failed)
func processWebhookJob(db *gorm.DB, tx *models.WebhookTransaction) {
	if tx.Status == models.WebhookStatusCompleted {
		return
	}

	tx.Status = models.WebhookStatusProcessing
	db.Save(tx)

	// Find the wallet account by virtual account number
	var account models.Account
	if err := db.Where("provider_account_number = ?", tx.VirtualAccountNumber).First(&account).Error; err != nil {
		tx.Status = models.WebhookStatusFailed
		tx.FailureReason = "no matching wallet account found: " + err.Error()
		db.Save(tx)
		log.Printf("[WebhookProcessor] %s: %s", tx.TransactionReference, tx.FailureReason)
		return
	}

	// Credit the account balance
	account.Balance = math.Round((account.Balance+tx.SettledAmount)*100) / 100
	if err := db.Save(&account).Error; err != nil {
		tx.Status = models.WebhookStatusFailed
		tx.FailureReason = "failed to credit balance: " + err.Error()
		db.Save(tx)
		log.Printf("[WebhookProcessor] %s: %s", tx.TransactionReference, tx.FailureReason)
		return
	}

	now := time.Now()
	tx.AccountID = &account.ID
	tx.Status = models.WebhookStatusCompleted
	tx.ProcessedAt = &now
	db.Save(tx)

	log.Printf("[WebhookProcessor] credited account %s (ID:%d) with %.2f — ref: %s",
		account.AccountNumber, account.ID, tx.SettledAmount, tx.TransactionReference)
}

// StartWebhookWorker launches a background goroutine that periodically polls
// for unprocessed webhook transactions and processes them.
func StartWebhookWorker(db *gorm.DB, pollInterval time.Duration) {
	go func() {
		log.Printf("[WebhookWorker] started (poll interval: %s)", pollInterval)

		// On startup, re-process any pending/failed records from before a restart
		recoverStuckRecords(db)

		ticker := time.NewTicker(pollInterval)
		defer ticker.Stop()

		for range ticker.C {
			pollPendingRecords(db)
		}
	}()
}

// recoverStuckRecords processes any records that were left in pending/processing
// state after a restart.
func recoverStuckRecords(db *gorm.DB) {
	var stuck []models.WebhookTransaction
	db.Where("status IN ?", []models.WebhookTransactionStatus{
		models.WebhookStatusPending,
		models.WebhookStatusProcessing,
	}).Find(&stuck)

	if len(stuck) > 0 {
		log.Printf("[WebhookWorker] recovering %d stuck records", len(stuck))
		for i := range stuck {
			processWebhookJob(db, &stuck[i])
		}
	}
}

// pollPendingRecords fetches and processes pending webhook records.
func pollPendingRecords(db *gorm.DB) {
	var pending []models.WebhookTransaction
	db.Where("status = ?", models.WebhookStatusPending).
		Order("created_at asc").
		Limit(10).
		Find(&pending)

	for i := range pending {
		processWebhookJob(db, &pending[i])
	}
}

// enqueueWebhookRecord creates a persistent webhook transaction record
// and immediately attempts to process it. Returns the created record.
func enqueueWebhookRecord(db *gorm.DB, data SquadWebhookDataV3, rawBody []byte) (*models.WebhookTransaction, bool, error) {
	principal := parseAmount(data.PrincipalAmount)
	settled := parseAmount(data.SettledAmount)
	fee := parseAmount(data.FeeCharged)

	tx := models.WebhookTransaction{
		TransactionReference: data.TransactionReference,
		VirtualAccountNumber: data.VirtualAccountNumber,
		PrincipalAmount:      principal,
		SettledAmount:        settled,
		FeeCharged:           fee,
		Currency:             data.Currency,
		CustomerIdentifier:   data.CustomerIdentifier,
		SenderName:           data.SenderName,
		TransactionDate:      data.TransactionDate,
		Channel:              data.Channel,
		Remarks:              data.Remarks,
		TransactionUUID:      data.TransactionUUID,
		RawPayload:           string(rawBody),
		Status:               models.WebhookStatusPending,
	}

	if err := db.Create(&tx).Error; err != nil {
		return nil, false, err
	}

	// Process immediately in a goroutine so Squad gets a quick 200
	go processWebhookJob(db, &tx)

	return &tx, true, nil
}

// parseAmount converts a string amount to float64, defaulting to 0.
func parseAmount(s string) float64 {
	if s == "" {
		return 0
	}
	f, err := strconv.ParseFloat(s, 64)
	if err != nil {
		return 0
	}
	return f
}

// dedupByReference checks if a webhook transaction reference was already recorded.
func dedupByReference(db *gorm.DB, ref string) bool {
	var count int64
	db.Model(&models.WebhookTransaction{}).
		Where("transaction_reference = ?", ref).
		Count(&count)
	return count > 0
}
