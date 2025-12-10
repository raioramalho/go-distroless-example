#!/bin/bash

# Script de início rápido para testar a aplicação

set -e

echo "🚀 Quick Start - Go Distroless Example"
echo "======================================="
echo ""

# Verificar se Docker está instalado
if ! command -v docker &> /dev/null; then
    echo "❌ Docker não está instalado!"
    echo "Por favor, instale Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

echo "✅ Docker encontrado"
echo ""

# Build da imagem
echo "📦 Construindo imagem Docker..."
docker build -t go-distroless-app:latest .

echo ""
echo "✅ Imagem construída com sucesso!"
echo ""

# Mostrar tamanho da imagem
echo "📊 Tamanho da imagem:"
docker images go-distroless-app:latest --format "{{.Repository}}:{{.Tag}}\t{{.Size}}"
echo ""

# Executar container
echo "🏃 Executando container na porta 8080..."
echo ""
echo "Para parar: Ctrl+C"
echo ""
echo "Endpoints disponíveis:"
echo "  - http://localhost:8080/"
echo "  - http://localhost:8080/health"
echo ""

docker run --rm -p 8080:8080 go-distroless-app:latest

