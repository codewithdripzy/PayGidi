FROM golang:1.26-alpine

WORKDIR /app

# Copy go.mod and go.sum
COPY go.mod go.sum ./

# Copy the vendor directory
COPY vendor/ ./vendor/

# Copy the rest of the source code
COPY . .

# Build using the vendor directory
RUN go build -mod=vendor -o service

EXPOSE 50053 8082

CMD ["./service"]