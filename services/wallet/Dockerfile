FROM golang:1.26-alpine

WORKDIR /app

# Copy go.mod and go.sum
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy the rest of the source code
COPY . .

# Build the application
RUN go build -o service

EXPOSE 50053 8082

CMD ["./service"]