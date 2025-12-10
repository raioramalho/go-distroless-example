#!/bin/bash

# Script para comparar diferentes níveis de otimização

set -e

IMAGE_BASE="go-distroless-app"

echo "🔬 Comparação de Otimizações - Docker Images"
echo "============================================="
echo ""

# 1. Build versão atual (distroless)
echo "1️⃣  Build com Distroless (versão atual)..."
docker build -t ${IMAGE_BASE}:distroless -f Dockerfile . > /dev/null 2>&1
echo "   ✅ Concluído"

# 2. Build com scratch
echo "2️⃣  Build com Scratch (sem runtime)..."
docker build -t ${IMAGE_BASE}:scratch -f ../build/Dockerfile.scratch . > /dev/null 2>&1
echo "   ✅ Concluído"

# 3. Build com UPX
echo "3️⃣  Build com UPX (compressão)..."
docker build -t ${IMAGE_BASE}:upx -f Dockerfile.upx . > /dev/null 2>&1
echo "   ✅ Concluído"

echo ""
echo "📊 Comparação de Tamanhos:"
echo "=========================="
echo ""

# Função para obter tamanho em bytes
get_size_bytes() {
    docker images $1 --format "{{.Size}}" | sed 's/MB//' | awk '{print $1}'
}

# Mostrar tamanhos formatados
printf "%-30s %10s %15s\n" "IMAGEM" "TAMANHO" "REDUÇÃO"
printf "%-30s %10s %15s\n" "------------------------------" "----------" "---------------"

# Distroless (baseline)
DIST_SIZE=$(docker images ${IMAGE_BASE}:distroless --format "{{.Size}}")
printf "%-30s %10s %15s\n" "Distroless (atual)" "$DIST_SIZE" "baseline"

# Scratch
SCRATCH_SIZE=$(docker images ${IMAGE_BASE}:scratch --format "{{.Size}}")
printf "%-30s %10s %15s\n" "Scratch" "$SCRATCH_SIZE" "↓"

# UPX
UPX_SIZE=$(docker images ${IMAGE_BASE}:upx --format "{{.Size}}")
printf "%-30s %10s %15s\n" "UPX Comprimido" "$UPX_SIZE" "↓↓"

echo ""
echo "🏆 Recomendações:"
echo "================="
echo ""
echo "1. UPX: Menor tamanho, mas startup um pouco mais lento"
echo "2. Scratch: Muito leve, mas sem certificados CA ou arquivos de sistema"
echo "3. Distroless: Balanço ideal entre tamanho, segurança e funcionalidade"
echo ""
echo "💡 Para produção recomendamos: Distroless ou Scratch"
echo "   (UPX pode ter problemas com alguns scanners de segurança)"
echo ""

# Testar se as imagens funcionam
echo "🧪 Testando funcionalidade..."
echo ""

for tag in distroless scratch upx; do
    echo -n "   Testando ${IMAGE_BASE}:${tag}... "
    CONTAINER_ID=$(docker run -d -p 8081:8080 ${IMAGE_BASE}:${tag} 2>/dev/null)
    sleep 2
    
    if curl -s http://localhost:8081/health > /dev/null 2>&1; then
        echo "✅ OK"
    else
        echo "❌ FALHOU"
    fi
    
    docker stop $CONTAINER_ID > /dev/null 2>&1
    docker rm $CONTAINER_ID > /dev/null 2>&1
done

echo ""
echo "🧹 Para limpar as imagens de teste:"
echo "   docker rmi ${IMAGE_BASE}:distroless ${IMAGE_BASE}:scratch ${IMAGE_BASE}:upx"

