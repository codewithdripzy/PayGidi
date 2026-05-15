package utils

import (
	"time"

	"github.com/patrickmn/go-cache"
)

var (
	// Global cache instance: 5 minutes default TTL, 10 minutes cleanup interval
	AppCache = cache.New(5*time.Minute, 10*time.Minute)
)
