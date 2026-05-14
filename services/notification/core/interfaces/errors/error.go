package payGidiErrors

type payGidiErrors string

const (
	INVALID_API_VERSION   payGidiErrors = "INVALID_API_VERSION"
	INVALID_REQUEST_BODY  payGidiErrors = "INVALID_REQUEST_BODY"
	RESOURCE_NOT_FOUND    payGidiErrors = "RESOURCE_NOT_FOUND"
	INTERNAL_SERVER_ERROR payGidiErrors = "INTERNAL_SERVER_ERROR"
	DELIVERY_FAILED       payGidiErrors = "DELIVERY_FAILED"
	SUCCESS               payGidiErrors = "SUCCESS"
)
