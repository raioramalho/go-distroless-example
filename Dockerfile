# Go + Distroless Example
# Ultra-lightweight Go application with distroless containers
#
# Author: Alan Ramalho (@raioramalho)
# Email: ramalho.sit@gmail.com
# Role: Sênior Solutions Architect
# License: MIT

# Stage 1: Build
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Copiar arquivos de dependências
COPY go.mod go.sum* ./

# Download de dependências (se existir go.sum)
RUN go mod download

# Copiar código fonte
COPY src/ ./src/

# Build do binário estático para ARM64
# CGO_ENABLED=0 - desabilita CGO para binário totalmente estático
# -ldflags="-w -s" - remove informações de debug, reduz tamanho
# GOARCH=arm64 - compila para arquitetura ARM64
RUN CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build \
    -ldflags="-w -s" \
    -a -installsuffix cgo \
    -o app \
    ./src

# Stage 2: Runtime (imagem distroless mais leve)
FROM gcr.io/distroless/static-debian12:nonroot

# Copiar binário do stage de build
COPY --from=builder /app/app /app

# Usar usuário não-root (segurança)
USER nonroot:nonroot

# Expor porta
EXPOSE 8080

# Executar aplicação (formato vetorial obrigatório)
ENTRYPOINT ["/app"]


