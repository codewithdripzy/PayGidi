FROM golang:1.26-alpine

WORKDIR /app

# Copy local dependencies
COPY services/notification /app/services/notification

# Copy wallet service source
COPY services/wallet /app/services/wallet

WORKDIR /app/services/wallet

# Download dependencies
RUN go mod download

# Build the application
RUN go build -o service

EXPOSE 50053 8082

CMD ["./service"]