# ---- Builder ----
FROM golang:1.26-alpine AS builder

WORKDIR /app
RUN apk add --no-cache git

COPY go.mod go.sum ./
RUN rm -rf /go/pkg/mod && go clean -modcache && go mod download

COPY . .

ARG TARGETOS
ARG TARGETARCH

RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH \
    go build -ldflags="-s -w" -o xray-knife

# ---- Runtime ----
FROM alpine:latest

RUN apk add --no-cache ca-certificates
WORKDIR /app

COPY --from=builder /app/xray-knife /usr/local/bin/xray-knife

ENTRYPOINT ["xray-knife"]
