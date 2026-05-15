package errors

import "strings"

func HandleVfdTransferError(errCode *string) (code string, message string) {
	if errCode == nil {
		return "UNKNOWN", "An error occurred while processing the transfer. Please try again later."
	}

	normalizedCode := strings.TrimSpace(*errCode)
	if normalizedCode == "" {
		return "UNKNOWN", "An error occurred while processing the transfer. Please try again later."
	}

	switch normalizedCode {
	case "00", "26":
		return normalizedCode, "Approved or completed successfully."
	case "01", "02":
		return normalizedCode, "Status unknown. Please wait for settlement report."
	case "03":
		return normalizedCode, "Invalid sender."
	case "05":
		return normalizedCode, "Do not honor."
	case "06":
		return normalizedCode, "Dormant account."
	case "07":
		return normalizedCode, "Invalid account."
	case "08":
		return normalizedCode, "Account name mismatch."
	case "09":
		return normalizedCode, "Request processing in progress."
	case "12":
		return normalizedCode, "Invalid transaction."
	case "13":
		return normalizedCode, "Invalid amount."
	case "14":
		return normalizedCode, "Invalid batch number."
	case "15":
		return normalizedCode, "Invalid session or record ID."
	case "16":
		return normalizedCode, "Unknown bank code."
	case "17":
		return normalizedCode, "Invalid channel."
	case "18":
		return normalizedCode, "Wrong method call."
	case "21":
		return normalizedCode, "Failed with reversal."
	case "25":
		return normalizedCode, "Unable to locate record."
	case "30":
		return normalizedCode, "Format error."
	case "34":
		return normalizedCode, "Suspected fraud."
	case "35":
		return normalizedCode, "Contact sending bank."
	case "51":
		return normalizedCode, "No sufficient funds."
	case "57":
		return normalizedCode, "Transaction not permitted to sender."
	case "58":
		return normalizedCode, "Transaction not permitted on channel."
	case "61":
		return normalizedCode, "Transaction limit exceeded."
	case "63":
		return normalizedCode, "Security violation."
	case "65":
		return normalizedCode, "Exceeds withdrawal frequency."
	case "68":
		return normalizedCode, "Response received too late."
	case "69", "70":
		return normalizedCode, "Unsuccessful account/amount block."
	case "71":
		return normalizedCode, "Empty mandate reference number."
	case "81":
		return normalizedCode, "Transaction failed."
	case "91":
		return normalizedCode, "Beneficiary bank not available."
	case "92":
		return normalizedCode, "Routing error."
	case "94":
		return normalizedCode, "Duplicate transaction."
	case "96":
		return normalizedCode, "System malfunction."
	case "97":
		return normalizedCode, "Timeout waiting for response from destination."
	case "98":
		return normalizedCode, "Transaction exists."
	case "99":
		return normalizedCode, "Transaction failed."
	case "500":
		return normalizedCode, "Internal server error."
	case "null":
		return normalizedCode, "Failed with reversal."
	default:
		return normalizedCode, "An error occurred while processing the transfer. Please try again later."
	}
}

// func HandleVfdError(errCode *string) (code string, message string) {
// 	if errCode == nil {
// 		return "UNKNOWN", "An error occurred while processing the request. Please try again later."
// 	}

// 	normalizedCode := strings.TrimSpace(*errCode)
// 	if normalizedCode == "" {
// 		return "UNKNOWN", "An error occurred while processing the request. Please try again later."
// 	}

// 	switch normalizedCode {
// 	case "00":
// 		return normalizedCode, "Approved or completed successfully."