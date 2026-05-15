package validators

type AuthDto struct {
	Phone       string `json:"phone" validate:"required,min=10,max=15"`
	AccountType string `json:"accountType" validate:"omitempty,oneof=individual business"`
}

type VerifyAuthOtpDto struct {
	Phone string `json:"phone" validate:"required,min=10,max=15"`
	Code  string `json:"otp" validate:"required,len=5"`
}

type IndividualCompleteAccountDto struct {
	FirstName       string `json:"firstName" validate:"required,min=2,max=30"`
	LastName        string `json:"lastName" validate:"required,min=2,max=30"`
	DateOfBirth     string `json:"dateOfBirth" validate:"required,datetime=2006-01-02"`
	Email           string `json:"email" validate:"required,email"`
	NIN             string `json:"nin" validate:"required,len=10"`
	BVN             string `json:"bvn" validate:"omitempty,len=11"`
	ReferralCode    string `json:"referralCode" validate:"omitempty,len=6"`
	Gender          string `json:"gender" validate:"required,oneof=1 2"`
}

type BusinessCompleteAccountDto struct {
	Name               string                       `json:"name" validate:"required,min=2,max=100"`
	RegistrationNumber string                       `json:"registrationNumber" validate:"required,min=5,max=50"`
	BusinessType       string                       `json:"businessType" validate:"required"`
	Industry           string                       `json:"industry" validate:"required"`
	Website            string                       `json:"website" validate:"omitempty,url"`
	OwnerInfo          IndividualCompleteAccountDto `json:"ownerInfo" validate:"required"`
}

type VerifyEmailDto struct {
	ForWhat string `json:"forWhat" validate:"required,oneof=completeRegister login resetPassword twoFactorAuth"`
	Email   string `json:"email" validate:"required,email"`
	Code    string `json:"otp" validate:"required,min=4"`
}

type RequestOTPDto struct {
	ForWhat string `json:"forWhat" validate:"required,oneof=completeRegister login resetPassword twoFactorAuth"`
	Phone   string `json:"phone" validate:"omitempty,min=10,max=15"`
	Email   string `json:"email" validate:"omitempty,email"`
}

type VerifyNINDto struct {
	NIN string `json:"nin" validate:"required,min=10"`
}

type VerifyBVNImageDto struct {
	BVN         string `json:"bvn" validate:"required,len=11"`
	Base64Image string `json:"base64Image" validate:"required"`
}
