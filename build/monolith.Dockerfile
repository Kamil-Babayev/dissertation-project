FROM golang:alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /monolith ./cmd/monolith/main.go

FROM alpine:latest
WORKDIR /root/
COPY --from=builder /monolith .
EXPOSE 8080
CMD ["./monolith"]
