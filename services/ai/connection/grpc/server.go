package grpc

import (
	"context"

	"github.com/PayGidi/AIService/proto/connection/aipb"
	"github.com/PayGidi/AIService/services/kyb"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type AIServer struct {
	orchestrator *kyb.Orchestrator
	aipb.UnimplementedAIServiceServer
}

func NewAIServer(orch *kyb.Orchestrator) *AIServer {
	return &AIServer{orchestrator: orch}
}

func (s *AIServer) HealthCheck(ctx context.Context, req *aipb.HealthCheckRequest) (*aipb.HealthCheckResponse, error) {
	return &aipb.HealthCheckResponse{Status: "ok"}, nil
}

func (s *AIServer) ProcessKYB(ctx context.Context, req *aipb.ProcessKYBRequest) (*aipb.ProcessKYBResponse, error) {
	if req == nil || req.BusinessId == "" {
		return nil, status.Error(codes.InvalidArgument, "business_id is required")
	}

	err := s.orchestrator.ProcessKYB(ctx, req.BusinessId)
	if err != nil {
		return &aipb.ProcessKYBResponse{
			Success: false,
			Message: "KYB processing failed: " + err.Error(),
			Status:  "failed",
		}, nil
	}

	return &aipb.ProcessKYBResponse{
		Success: true,
		Message: "KYB processed successfully",
		Status:  "completed",
	}, nil
}

