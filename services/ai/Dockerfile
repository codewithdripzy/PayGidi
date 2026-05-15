FROM golang:1.26-alpine

WORKDIR /app

# Copy local dependencies
COPY services/notification /app/services/notification

# Copy AI service source
COPY services/ai /app/services/ai

WORKDIR /app/services/ai

# Download dependencies
RUN go mod download

# Build the application
RUN go build -o service

EXPOSE 50054 8083

CMD ["./service"]