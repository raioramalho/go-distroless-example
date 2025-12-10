# Go + Distroless Example
# Ultra-lightweight Go application with distroless containers
#
# Author: Alan Ramalho (@raioramalho)
# Email: ramalho.sit@gmail.com
# Role: Sênior Solutions Architect
# License: MIT
# Repository: https://github.com/raioramalho/go-distroless-example

.PHONY: build run docker-build docker-run docker-debug clean size

# Nome da imagem
IMAGE_NAME := go-distroless-app
TAG := latest

# Build local para ARM64
build:
	CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -ldflags="-w -s" -o app ./src

# Run local
run: build
	./app

# Build da imagem Docker para ARM64 (distroless - balanceado)
docker-build:
	docker build -t $(IMAGE_NAME):$(TAG) .

# Build com scratch (50% menor - ~6MB)
docker-build-scratch:
	docker build -f build/Dockerfile.scratch -t $(IMAGE_NAME):scratch .

# Build com UPX (80% menor - ~2.6MB)
docker-build-upx:
	docker build -f build/Dockerfile.upx -t $(IMAGE_NAME):upx .

# Comparar todas as otimizações
compare-optimizations:
	@./scripts/compare-optimizations.sh

# Benchmark de performance
benchmark:
	@./scripts/benchmark.sh

# Medir build time
measure-build-time:
	@./scripts/measure-build-time.sh

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 🔥 DESENVOLVIMENTO (Hot-reload)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Iniciar ambiente de desenvolvimento com hot-reload
dev:
	@./scripts/dev.sh

# Parar ambiente de desenvolvimento
dev-down:
	docker-compose -f docker-compose.dev.yml down

# Ver logs do ambiente de desenvolvimento
dev-logs:
	docker-compose -f docker-compose.dev.yml logs -f

# Rebuild da imagem de desenvolvimento
dev-rebuild:
	docker-compose -f docker-compose.dev.yml build --no-cache

# Build multi-arquitetura (ARM64 + AMD64)
docker-build-multiarch:
	docker buildx build \
		--platform linux/arm64,linux/amd64 \
		-t $(IMAGE_NAME):$(TAG) \
		--load \
		.

# Run da imagem Docker
docker-run: docker-build
	docker run --rm -p 8080:8080 $(IMAGE_NAME):$(TAG)

# Build imagem de debug (com shell)
docker-debug:
	docker build -t $(IMAGE_NAME):debug \
		--target builder .

# Executar container com shell (debug)
docker-shell:
	docker run --rm -it --entrypoint=/bin/sh $(IMAGE_NAME):debug

# Ver tamanho da imagem
size: docker-build
	@echo "Tamanho da imagem:"
	@docker images $(IMAGE_NAME):$(TAG) --format "{{.Repository}}:{{.Tag}}\t{{.Size}}"

# Comparar tamanhos
compare: docker-build
	@echo "\nComparação de tamanhos:"
	@echo "Builder (golang:1.21-alpine):"
	@docker images golang:1.21-alpine --format "{{.Repository}}:{{.Tag}}\t{{.Size}}"
	@echo "\nFinal (distroless):"
	@docker images $(IMAGE_NAME):$(TAG) --format "{{.Repository}}:{{.Tag}}\t{{.Size}}"

# Limpar arquivos
clean:
	rm -f app
	docker rmi -f $(IMAGE_NAME):$(TAG) 2>/dev/null || true
	docker rmi -f $(IMAGE_NAME):debug 2>/dev/null || true

# Test
test:
	go test -v ./src/tests/...

# Docker compose up
compose-up:
	docker-compose up --build

# Docker compose down
compose-down:
	docker-compose down

# Build com versão debug (com shell)
docker-build-debug:
	docker build -f build/Dockerfile.debug -t $(IMAGE_NAME):debug .

# Entrar no container debug com shell
debug-shell: docker-build-debug
	docker run --rm -it --entrypoint=/busybox/sh $(IMAGE_NAME):debug


