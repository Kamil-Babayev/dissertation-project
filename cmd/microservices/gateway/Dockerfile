FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /gateway ./cmd/microservices/gateway/main.go

FROM alpine:latest
WORKDIR /root/
COPY --from=builder /gateway .
EXPOSE 8080
CMD ["./gateway"]