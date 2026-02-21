# ---- Base builder ----
FROM golang:1.26-alpine AS builder

WORKDIR /app

# Install dependencies
RUN apk add --no-cache git bash

# Copy source code and build script
COPY go.mod go.sum ./
COPY main.go ./
COPY build.sh ./

# Make build.sh executable
RUN chmod +x build.sh

# Build for a single target architecture (passed as ARG)
ARG TARGETOS=linux
ARG TARGETARCH=amd64
RUN ./build.sh $TARGETOS $TARGETARCH

# ---- Optional: minimal runtime image ----
FROM alpine:3.21 AS runtime
WORKDIR /app
COPY --from=builder /app/build/xray-knife-linux-$TARGETARCH /app/xray-knife
ENTRYPOINT ["./xray-knife"]
