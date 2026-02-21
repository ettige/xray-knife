# Dockerfile
# Multi-arch builder for xray-knife

# Base Go image
FROM golang:1.25-alpine AS builder

WORKDIR /app

# Install git & bash for build.sh
RUN apk add --no-cache git bash

# Copy go modules and download dependencies first for caching
COPY go.mod go.sum ./
RUN go mod download

# Copy source code and build script
COPY . .

RUN chmod +x build.sh

# Accept build args from GitHub Actions / docker buildx
ARG TARGETOS=linux
ARG TARGETARCH=amd64

# Run build.sh with correct platform/arch
RUN ./build.sh $TARGETOS $TARGETARCH

# Minimal runtime image
FROM alpine:3.22 AS runtime
WORKDIR /app

# Copy the built binary from builder
COPY --from=builder /app/build/xray-knife-$TARGETARCH /app/xray-knife

ENTRYPOINT ["./xray-knife"]
