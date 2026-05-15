package payGidiErrors

type payGidiErrors string
type PayGidiHTTPStatus int

const (
	// General Errors
	INVALID_API_VERSION  payGidiErrors = "INVALID_API_VERSION"
	INVALID_REQUEST_BODY payGidiErrors = "INVALID_REQUEST_BODY"
	UNAUTHORIZED_ACCESS  payGidiErrors = "UNAUTHORIZED_ACCESS"
	RESOURCE_NOT_FOUND   payGidiErrors = "RESOURCE_NOT_FOUND"
	VALIDATION_ERROR     payGidiErrors = "VALIDATION_ERROR"

	// Authentication Errors
	PHONE_NUMBER_MISSING      payGidiErrors = "PHONE_NUMBER_MISSING"
	PHONE_OR_PIN_MISSING payGidiErrors = "NO_PHONE_OR_PIN_MISSING"

	// Authentication and User Management Errors
	INCORRECT_PHONE_OR_PIN payGidiErrors = "INCORRECT_PHONE_OR_PIN"
	INCORRECT_EMAIL_OR_PIN payGidiErrors = "INCORRECT_EMAIL_OR_PIN"
	EMAIL_NOT_FOUND             payGidiErrors = "EMAIL_NOT_FOUND"
	PHONE_NOT_FOUND             payGidiErrors = "PHONE_NOT_FOUND"
	INVALID_TOKEN               payGidiErrors = "INVALID_TOKEN"
	USER_NOT_FOUND              payGidiErrors = "USER_NOT_FOUND"
	USER_ALREADY_EXISTS         payGidiErrors = "USER_ALREADY_EXISTS"
	EMAIL_ALREADY_EXISTS        payGidiErrors = "EMAIL_ALREADY_EXISTS"
	PHONE_ALREADY_EXISTS        payGidiErrors = "PHONE_ALREADY_EXISTS"
	USER_CREATION_FAILED        payGidiErrors = "USER_CREATION_FAILED"
	PIN_MISMATCH           payGidiErrors = "PIN_MISMATCH"
	EMAIL_NOT_VERIFIED          payGidiErrors = "EMAIL_NOT_VERIFIED"
	PHONE_NOT_VERIFIED          payGidiErrors = "PHONE_NOT_VERIFIED"
	SESSION_EXPIRED             payGidiErrors = "SESSION_EXPIRED"
	INVALID_CREDENTIALS         payGidiErrors = "INVALID_CREDENTIALS"
	ACCOUNT_LOCKED              payGidiErrors = "ACCOUNT_LOCKED"
	TOO_MANY_REQUESTS           payGidiErrors = "TOO_MANY_REQUESTS"
	EXPIRED_TOKEN               payGidiErrors = "EXPIRED_TOKEN"
	OTP_NOT_FOUND               payGidiErrors = "OTP_NOT_FOUND"
	OTP_ALREADY_VERIFIED        payGidiErrors = "OTP_ALREADY_VERIFIED"
	OTP_REQUEST_LIMIT_REACHED   payGidiErrors = "OTP_REQUEST_LIMIT_REACHED"

	// Account Errors
	ACCOUNT_NOT_FOUND       payGidiErrors = "ACCOUNT_NOT_FOUND"
	ACCOUNT_CREATION_FAILED payGidiErrors = "ACCOUNT_CREATION_FAILED"
	ACCOUNT_ALREADY_EXISTS  payGidiErrors = "ACCOUNT_ALREADY_EXISTS"

	// HTTP Status Codes
	SUCCESS               PayGidiHTTPStatus = 200
	CREATED               PayGidiHTTPStatus = 201
	BAD_REQUEST           PayGidiHTTPStatus = 400
	UNAUTHORIZED          PayGidiHTTPStatus = 401
	FORBIDDEN             PayGidiHTTPStatus = 403
	NOT_FOUND             PayGidiHTTPStatus = 404
	INTERNAL_SERVER_ERROR PayGidiHTTPStatus = 500

	// Other specific errors can be added here as needed
	VFD_SERVICE_ERROR payGidiErrors = "VFD_SERVICE_ERROR"
	INVALID_NIN       payGidiErrors = "INVALID_NIN"
)
