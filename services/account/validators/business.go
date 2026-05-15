package validators

type UpdateBusinessProfileDto struct {
	Name               string   `json:"name" validate:"omitempty,min=2,max=100"`
	RegistrationNumber string   `json:"registrationNumber" validate:"omitempty,min=5,max=50"`
	BusinessType       string   `json:"businessType" validate:"omitempty"`
	Industry           string   `json:"industry" validate:"omitempty"`
	Website            string   `json:"website" validate:"omitempty,url"`
	Instagram          string   `json:"instagram" validate:"omitempty"`
	Twitter            string   `json:"twitter" validate:"omitempty"`
	LinkedIn           string   `json:"linkedIn" validate:"omitempty"`
	Facebook           string   `json:"facebook" validate:"omitempty"`
}

type UpdateBusinessDocsDto struct {
	RegistrationDoc string   `json:"registrationDoc" validate:"omitempty"`
	AdditionalDocs  []string `json:"additionalDocs" validate:"omitempty"`
}
