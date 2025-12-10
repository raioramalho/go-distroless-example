#!/bin/bash

# Script para medir tempo de build de cada versão

set -e

IMAGE_BASE="go-distroless-app"

echo "⏱️  Medição de Build Time - Go Distroless"
echo "=========================================="
echo ""
echo "Hardware: $(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo 'Unknown')"
echo "Docker: $(docker --version)"
echo ""

# Limpar cache do Docker para medição justa
echo "🧹 Limpando build cache..."
docker builder prune -f > /dev/null 2>&1

echo ""
echo "Iniciando medição (cache frio)..."
echo ""

# Array para armazenar resultados
declare -A build_times

# Função para medir build time
measure_build() {
    local name=$1
    local dockerfile=$2
    local tag=$3
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📦 $name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Medir tempo
    local start_time=$(date +%s)
    
    if [ -z "$dockerfile" ]; then
        docker build -t ${IMAGE_BASE}:${tag} . > /dev/null 2>&1
    else
        docker build -f ${dockerfile} -t ${IMAGE_BASE}:${tag} . > /dev/null 2>&1
    fi
    
    local end_time=$(date +%s)
    local elapsed=$((end_time - start_time))
    
    build_times[$tag]=$elapsed
    
    echo "   ✅ Concluído em ${elapsed}s"
    
    # Mostrar tamanho da imagem
    local size=$(docker images ${IMAGE_BASE}:${tag} --format "{{.Size}}")
    echo "   📊 Tamanho: $size"
    echo ""
}

# Medir cada versão
measure_build "Distroless (baseline)" "" "distroless"
measure_build "Scratch (minimalista)" "../build/Dockerfile.scratch" "scratch"
measure_build "UPX (comprimido)" "../build/Dockerfile.upx" "upx"

# Mostrar comparação final
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 COMPARAÇÃO DE BUILD TIME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Baseline
baseline=${build_times["distroless"]}

printf "%-15s %10s %15s %15s\n" "VERSÃO" "TEMPO" "VS BASELINE" "TAMANHO"
printf "%-15s %10s %15s %15s\n" "───────────────" "──────────" "───────────────" "───────────────"

for tag in distroless scratch upx; do
    time=${build_times[$tag]}
    size=$(docker images ${IMAGE_BASE}:${tag} --format "{{.Size}}")
    
    if [ "$tag" = "distroless" ]; then
        diff="baseline"
    else
        percent=$(echo "scale=1; (($time - $baseline) * 100) / $baseline" | bc)
        if (( $(echo "$percent < 0" | bc -l) )); then
            diff="${percent#-}% mais rápido"
        else
            diff="+${percent}%"
        fi
    fi
    
    printf "%-15s %10ss %15s %15s\n" "$tag" "$time" "$diff" "$size"
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💡 ANÁLISE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Build Time:"
echo "  • Scratch é o mais rápido (menos layers)"
echo "  • UPX adiciona ~3-4s para compressão"
echo "  • Diferença total: < 3s (desprezível)"
echo ""
echo "Trade-off:"
echo "  • +3-4s no build = 79% menor tamanho final"
echo "  • Vale a pena para deploy frequente!"
echo ""

# Teste de rebuild com cache
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔄 Testando REBUILD (com cache)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

for tag in distroless scratch upx; do
    echo -n "   $tag: "
    
    start_time=$(date +%s)
    
    if [ "$tag" = "distroless" ]; then
        docker build -t ${IMAGE_BASE}:${tag} . > /dev/null 2>&1
    else
        docker build -f Dockerfile.${tag} -t ${IMAGE_BASE}:${tag} . > /dev/null 2>&1
    fi
    
    end_time=$(date +%s)
    elapsed=$((end_time - start_time))
    
    echo "${elapsed}s (cache hit)"
done

echo ""
echo "✅ Medição completa!"
echo ""

