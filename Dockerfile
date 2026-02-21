FROM golang:1.26-alpine AS builder

WORKDIR /app

RUN apk add --no-cache git bash

# Copy dependencies first
COPY go.mod go.sum ./
RUN go mod download

# Copy full source
COPY . .

# Make build script executable
RUN chmod +x build.sh

# Accept build args
ARG TARGETOS=linux
ARG TARGETARCH=amd64

# Build binary for this platform
RUN ./build.sh $TARGETOS $TARGETARCH

# Minimal runtime image
FROM alpine:3.21 AS runtime
WORKDIR /app
COPY --from=builder /app/build/xray-knife-linux-$TARGETARCH /app/xray-knife
ENTRYPOINT ["./xray-knife"]
