package auth

import (
	"context"
	"time"

	"fmt"

	"github.com/PayGidi/AccountService/config"
	"github.com/PayGidi/AccountService/models"
	"github.com/PayGidi/AccountService/proto/connection/pb"
	userService "github.com/PayGidi/AccountService/services/user"
	"github.com/PayGidi/AccountService/utils"
	accountUtils "github.com/PayGidi/AccountService/utils"
	"github.com/gin-gonic/gin"
	"github.com/patrickmn/go-cache"
)

type AuthServer struct {
	pb.UnimplementedAuthServiceServer
	App *gin.Engine
}

// convertRolesToPb converts a slice of roles to the protobuf representation
func convertRolesToPb(roles []string) []*pb.Role {
	rolePb := make([]*pb.Role, len(roles))
	for i, role := range roles {
		rolePb[i] = &pb.Role{
			Name: role,
		}
	}
	return rolePb
}

func (s *AuthServer) GetUser(ctx context.Context, req *pb.GetUserRequest) (*pb.GetUserResponse, error) {
	// Check Cache
	cacheKey := "user:" + req.UserId
	if cached, found := accountUtils.AppCache.Get(cacheKey); found {
		return cached.(*pb.GetUserResponse), nil
	}

	db, err := config.GetDBConnection()
	if err != nil {
		return nil, err
	}

	var uID uint
	_, err = fmt.Sscanf(req.UserId, "%d", &uID)
	if err != nil {
		return &pb.GetUserResponse{Success: false, Message: "Invalid user ID format"}, nil
	}

	user, err := userService.GetUserById(db, uID)
	if err != nil {
		return nil, err
	}
	if user == nil {
		return &pb.GetUserResponse{Success: false, Message: "User not found"}, nil
	}

	res := &pb.GetUserResponse{
		Success:  true,
		UserData: mapUserData(user),
	}

	// Store in Cache (Expires in 5 minutes)
	accountUtils.AppCache.Set(cacheKey, res, cache.DefaultExpiration)

	return res, nil
}

func mapUserData(userData *models.User) *pb.UserData {
	return &pb.UserData{
		Email:      userData.Email,
		Phone:      userData.Phone,
		Username:   userData.Username,
		ProfilePic: userData.ProfilePic,
		PersonData: &pb.PersonData{
			FirstName: userData.Person.FirstName,
			LastName:  userData.Person.LastName,
		},
		TwoFactorEnabled: userData.TwoFactorEnabled,
		IsFirstTime:      userData.IsFirstTime,
		TwoFactorMethod:  userData.TwoFactorMethod,
		EmailVerified:    userData.EmailVerified,
		PhoneVerified:    userData.PhoneVerified,
		Preference: &pb.Preference{
			Theme:    userData.Preferences.Theme,
			Language: userData.Preferences.Language,
		},
		Roles: convertRolesToPb(func(roles []models.Role) []string {
			roleNames := make([]string, len(roles))
			for i, r := range roles {
				roleNames[i] = r.Name
			}
			return roleNames
		}(userData.Roles)),
		Status:    userData.Status,
		LastLogin: userData.AuthInfo.LastLoginAt.String(),
		CreatedAt: userData.CreatedAt.String(),
		UpdatedAt: userData.UpdatedAt.String(),
	}
}

func (s *AuthServer) ValidateToken(ctx context.Context, req *pb.ValidateTokenRequest) (*pb.ValidateTokenResponse, error) {
	// Check Cache
	cacheKey := "token:" + req.Token
	if cached, found := accountUtils.AppCache.Get(cacheKey); found {
		return cached.(*pb.ValidateTokenResponse), nil
	}

	// Initialize database connection
	db, err := config.GetDBConnection()
	if err != nil {
		panic("Error connecting to database: " + err.Error())
	}

	userID, err := utils.VerifyJWT(req.Token)

	if err != nil {
		return &pb.ValidateTokenResponse{
			Valid: false,
			Error: "Invalid token: " + err.Error(),
		}, nil
	}

	// get the userData from the userModel
	userData, err := userService.GetUserById(db, userID)
	if err != nil {
		return nil, err
	}

	if userData == nil {
		return &pb.ValidateTokenResponse{
			Valid: false,
			Error: "Account not found",
		}, nil
	}

	// Token parsing logic
	res := &pb.ValidateTokenResponse{
		Valid:    true,
		UserId:   userData.UID,
		Email:    userData.Email,
		UserData: mapUserData(userData),
	}

	// Store in Cache (Short lived - 1 minute)
	accountUtils.AppCache.Set(cacheKey, res, 1*time.Minute)

	return res, nil
}
