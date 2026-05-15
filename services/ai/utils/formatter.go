package utils

import (
	"fmt"
	"strings"
	"time"
)

func parseSupportedDate(dateStr string) (time.Time, error) {
	dateStr = strings.TrimSpace(dateStr)
	layouts := []string{
		"2006-01-02",
		"02-Jan-2006",
		time.RFC3339,
		"2006-01-02T15:04:05",
	}

	for _, layout := range layouts {
		parsedDate, err := time.Parse(layout, dateStr)
		if err == nil {
			return parsedDate, nil
		}
	}

	return time.Time{}, fmt.Errorf("invalid date format: expected YYYY-MM-DD")
}

func FormatToVfdDate(dateStr string) (string, error) {
	parsedDate, err := parseSupportedDate(dateStr)
	if err != nil {
		return "", err
	}

	return parsedDate.Format("2006-01-02"), nil
}

func FormatToVfdDateWithBVN(dateStr string) (string, error) {
	parsedDate, err := parseSupportedDate(dateStr)
	if err != nil {
		return "", err
	}

	return parsedDate.Format("02-Jan-2006"), nil
}
