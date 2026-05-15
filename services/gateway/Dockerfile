FROM golang:1.26-alpine

WORKDIR /app

# Copy gateway service source
COPY services/gateway /app/services/gateway

WORKDIR /app/services/gateway

# Download dependencies
RUN go mod download

# Build the application
RUN go build -o service

EXPOSE 8080

CMD ["./service"]
