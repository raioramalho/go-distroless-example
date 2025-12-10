#!/bin/bash

# Script para build multi-arquitetura usando Docker Buildx
# Suporta ARM64 e AMD64

set -e

IMAGE_NAME="go-distroless-app"
TAG="latest"

echo "🏗️  Build Multi-Arquitetura - Go Distroless"
echo "==========================================="
echo ""

# Verificar se buildx está disponível
if ! docker buildx version &> /dev/null; then
    echo "❌ Docker Buildx não está disponível!"
    echo "Por favor, atualize o Docker para a versão mais recente."
    exit 1
fi

echo "✅ Docker Buildx encontrado"
echo ""

# Criar builder se não existir
if ! docker buildx inspect multiarch-builder &> /dev/null; then
    echo "📦 Criando builder multi-arquitetura..."
    docker buildx create --name multiarch-builder --use --platform linux/arm64,linux/amd64
    echo "✅ Builder criado"
else
    echo "📦 Usando builder existente"
    docker buildx use multiarch-builder
fi

echo ""
echo "🔨 Construindo para ARM64 e AMD64..."
echo ""

# Build para múltiplas plataformas
docker buildx build \
    --platform linux/arm64,linux/amd64 \
    -t ${IMAGE_NAME}:${TAG} \
    -f Dockerfile.multiarch \
    --load \
    .

echo ""
echo "✅ Build concluído com sucesso!"
echo ""
echo "📊 Imagem criada:"
docker images ${IMAGE_NAME}:${TAG} --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}"
echo ""
echo "🚀 Para executar:"
echo "   docker run --rm -p 8080:8080 ${IMAGE_NAME}:${TAG}"

