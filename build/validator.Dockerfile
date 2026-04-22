FROM golang:alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /validator ./cmd/microservices/validator/main.go

FROM alpine:latest
WORKDIR /root/
COPY --from=builder /validator .
EXPOSE 8081
CMD ["./validator"]
