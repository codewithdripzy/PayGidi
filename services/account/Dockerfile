FROM golang:1.26-alpine

WORKDIR /app

# Copy local dependencies first
COPY services/notification /app/services/notification
COPY services/wallet /app/services/wallet

# Copy account service source
COPY services/account /app/services/account

WORKDIR /app/services/account

# Download dependencies
RUN go mod download

# Build the application
RUN go build -o service

EXPOSE 50051 8080

CMD ["./service"]