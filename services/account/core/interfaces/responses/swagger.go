package responses

// ApiResponse defines a generic API response structure for Swagger documentation.
type ApiResponse struct {
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
	Error   string      `json:"error,omitempty"`
}
