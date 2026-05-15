FROM golang:1.26-alpine

WORKDIR /app

# Copy transaction service source
COPY services/transaction /app/services/transaction

WORKDIR /app/services/transaction

# Download dependencies
RUN go mod download

# Build the application
RUN go build -o service

EXPOSE 50055 8085

CMD ["./service"]