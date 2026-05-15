FROM golang:1.26-alpine

WORKDIR /app

# Copy notification service source
COPY services/notification /app/services/notification

WORKDIR /app/services/notification

# Download dependencies
RUN go mod download

# Build the application
RUN go build -o service

EXPOSE 50052 8084

CMD ["./service"]