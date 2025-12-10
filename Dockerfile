# Go + Distroless Example
# Ultra-lightweight Go application with distroless containers
#
# Author: Alan Ramalho (@raioramalho)
# Email: ramalho.sit@gmail.com
# Role: Sênior Solutions Architect
# License: MIT

# Stage 1: Build
FROM --platform=$BUILDPLATFORM golang:1.21-alpine AS builder

ARG TARGETOS=linux
ARG TARGETARCH

WORKDIR /app

# Copiar go.mod
COPY go.mod ./

# Copiar código fonte
COPY src/ ./src/

# Baixar dependências e gerar go.sum
RUN go mod tidy && go mod download

# Build do binário estático para arquitetura alvo
# CGO_ENABLED=0 - desabilita CGO para binário totalmente estático
# -ldflags="-w -s" - remove informações de debug, reduz tamanho
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build \
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


