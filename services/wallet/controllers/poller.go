package controllers

import (
	"context"
	"encoding/json"
	"log"
	"time"

	squadService "github.com/PayGidi/WalletService/services/squad"
	"gorm.io/gorm"
)

// StartMissedWebhookPoller launches a background goroutine that periodically
// fetches missed webhooks from Squad's error log API and processes them.
func StartMissedWebhookPoller(db *gorm.DB, pollInterval time.Duration) {
	go func() {
		log.Printf("[WebhookPoller] started (poll interval: %s)", pollInterval)

		// Give the app a moment to stabilize on startup
		time.Sleep(10 * time.Second)

		ticker := time.NewTicker(pollInterval)
		defer ticker.Stop()

		// Run once immediately
		fetchAndProcessMissedWebhooks(db)

		for range ticker.C {
			fetchAndProcessMissedWebhooks(db)
		}
	}()
}

func fetchAndProcessMissedWebhooks(db *gorm.DB) {
	log.Printf("[WebhookPoller] fetching missed webhooks from Squad...")

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	success, errMsg, entries := squadService.GetWebhookErrorLog(ctx)
	if !success {
		if errMsg != nil {
			log.Printf("[WebhookPoller] failed to fetch error log: %s", *errMsg)
		}
		return
	}

	if len(entries) == 0 {
		log.Printf("[WebhookPoller] no missed webhooks")
		return
	}

	log.Printf("[WebhookPoller] processing %d missed webhook(s)", len(entries))

	for _, entry := range entries {
		processMissedWebhookEntry(db, entry)
	}
}

func processMissedWebhookEntry(db *gorm.DB, entry squadService.WebhookErrorLogEntry) {
	// Deduplicate
	if dedupByReference(db, entry.TransactionReference) {
		log.Printf("[WebhookPoller] duplicate ref=%s — skipping and deleting from error log", entry.TransactionReference)
		deleteFromErrorLog(entry.TransactionReference)
		return
	}

	// Convert the error log entry into a SquadWebhookDataV3
	data := SquadWebhookDataV3{
		TransactionReference: entry.TransactionReference,
		VirtualAccountNumber: entry.VirtualAccountNumber,
		PrincipalAmount:      entry.PrincipalAmount,
		SettledAmount:        entry.SettledAmount,
		FeeCharged:           entry.FeeCharged,
		TransactionDate:      entry.TransactionDate,
		CustomerIdentifier:   entry.CustomerIdentifier,
		Remarks:              entry.Remarks,
		Currency:             entry.Currency,
		Channel:              entry.Channel,
		SenderName:           entry.SenderName,
		TransactionUUID:      entry.TransactionUUID,
	}

	rawBody, _ := json.Marshal(entry)

	record, queued, err := enqueueWebhookRecord(db, data, rawBody)
	if err != nil {
		log.Printf("[WebhookPoller] failed to enqueue ref=%s: %v", entry.TransactionReference, err)
		return
	}

	if queued {
		log.Printf("[WebhookPoller] enqueued missed webhook ref=%s id=%d", record.TransactionReference, record.ID)
		// Delete from Squad's error log so it doesn't reappear
		deleteFromErrorLog(entry.TransactionReference)
	}
}

func deleteFromErrorLog(transactionReference string) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	success, errMsg := squadService.DeleteWebhookErrorLog(ctx, transactionReference)
	if !success {
		if errMsg != nil {
			log.Printf("[WebhookPoller] failed to delete error log entry %s: %s", transactionReference, *errMsg)
		}
		return
	}

	log.Printf("[WebhookPoller] deleted error log entry %s", transactionReference)
}
