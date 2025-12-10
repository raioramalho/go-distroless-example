#!/bin/bash

# Script para comparar tamanhos de diferentes imagens base

set -e

echo "📊 Comparação de Tamanhos de Imagens Docker"
echo "==========================================="
echo ""

# Build com distroless/static (imagem atual)
echo "1️⃣  Construindo com gcr.io/distroless/static-debian12:nonroot..."
docker build -t go-app:distroless-static . > /dev/null 2>&1

# Build com distroless/base
echo "2️⃣  Construindo com gcr.io/distroless/base-debian12:nonroot..."
cat > ../build/Dockerfile.tmp << 'EOF'
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.mod go.sum* ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -a -installsuffix cgo -o app .

FROM gcr.io/distroless/base-debian12:nonroot
COPY --from=builder /app/app /app
USER nonroot:nonroot
EXPOSE 8080
ENTRYPOINT ["/app"]
EOF
docker build -f ../build/Dockerfile.tmp -t go-app:distroless-base . > /dev/null 2>&1

# Build com Alpine
echo "3️⃣  Construindo com alpine:latest..."
cat > ../build/Dockerfile.tmp << 'EOF'
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.mod go.sum* ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -a -installsuffix cgo -o app .

FROM alpine:latest
RUN apk --no-cache add ca-certificates
RUN addgroup -g 65532 -S nonroot && adduser -u 65532 -S nonroot -G nonroot
COPY --from=builder /app/app /app
USER nonroot:nonroot
EXPOSE 8080
ENTRYPOINT ["/app"]
EOF
docker build -f ../build/Dockerfile.tmp -t go-app:alpine . > /dev/null 2>&1

# Build com scratch
echo "4️⃣  Construindo com scratch..."
cat > ../build/Dockerfile.tmp << 'EOF'
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.mod go.sum* ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -a -installsuffix cgo -o app .

FROM scratch
COPY --from=builder /app/app /app
EXPOSE 8080
ENTRYPOINT ["/app"]
EOF
docker build -f ../build/Dockerfile.tmp -t go-app:scratch . > /dev/null 2>&1

echo ""
echo "✅ Todas as imagens construídas!"
echo ""
echo "📊 Comparação de Tamanhos:"
echo "=========================="

# Função para formatar tamanho
format_size() {
    docker images $1 --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}"
}

# Mostrar tamanhos
echo ""
format_size "go-app:scratch" | tail -n 1
format_size "go-app:distroless-static" | tail -n 1
format_size "go-app:distroless-base" | tail -n 1
format_size "go-app:alpine" | tail -n 1

echo ""
echo "🏆 Vencedor: scratch ou distroless/static"
echo "   (distroless adiciona segurança e certificados CA)"
echo ""

# Limpar
rm -f ../build/Dockerfile.tmp

echo "🧹 Limpeza..."
echo "Para remover as imagens de teste:"
echo "  docker rmi go-app:distroless-static go-app:distroless-base go-app:alpine go-app:scratch"

