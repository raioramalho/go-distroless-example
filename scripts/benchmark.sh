#!/bin/bash

# Script de benchmark para comparar performance das diferentes versões

set -e

IMAGE_BASE="go-distroless-app"
ITERATIONS=100
PORT_BASE=8090

echo "⚡ Benchmark - Performance das Imagens Docker"
echo "=============================================="
echo ""
echo "Configuração:"
echo "  - Iterações: $ITERATIONS requisições por versão"
echo "  - Métricas: Startup time, Response time, Memory usage"
echo ""

# Função para medir startup time
measure_startup() {
    local image=$1
    local port=$2
    
    echo -n "   Iniciando container..."
    local start_time=$(date +%s%N)
    local container_id=$(docker run -d -p ${port}:8080 ${image} 2>/dev/null)
    
    # Aguardar até o container responder
    local ready=false
    local timeout=30
    local elapsed=0
    
    while [ "$ready" = false ] && [ $elapsed -lt $timeout ]; do
        if curl -s http://localhost:${port}/health > /dev/null 2>&1; then
            ready=true
        else
            sleep 0.1
            elapsed=$((elapsed + 1))
        fi
    done
    
    local end_time=$(date +%s%N)
    local startup_ms=$(( (end_time - start_time) / 1000000 ))
    
    echo " ✅ Pronto em ${startup_ms}ms"
    echo $container_id
}

# Função para medir response time
measure_response_time() {
    local port=$1
    local iterations=$2
    
    echo -n "   Medindo response time ($iterations requisições)..."
    
    local total_time=0
    for i in $(seq 1 $iterations); do
        local response_time=$(curl -w "%{time_total}" -o /dev/null -s http://localhost:${port}/)
        # Converter para ms (multiplicar por 1000)
        local ms=$(echo "$response_time * 1000" | bc)
        total_time=$(echo "$total_time + $ms" | bc)
    done
    
    local avg_time=$(echo "scale=2; $total_time / $iterations" | bc)
    echo " ✅ Média: ${avg_time}ms"
    echo $avg_time
}

# Função para medir uso de memória
measure_memory() {
    local container_id=$1
    
    echo -n "   Medindo uso de memória..."
    sleep 2  # Aguardar estabilizar
    
    local mem_usage=$(docker stats $container_id --no-stream --format "{{.MemUsage}}" | awk '{print $1}')
    echo " ✅ Uso: ${mem_usage}"
    echo $mem_usage
}

# Função para medir throughput
measure_throughput() {
    local port=$1
    local duration=10
    
    echo -n "   Medindo throughput (${duration}s)..."
    
    # Instalar ab se necessário (comentado para não pedir permissão)
    # which ab > /dev/null || (echo "Instalando apache-bench..." && brew install apache-bench)
    
    if which ab > /dev/null 2>&1; then
        local result=$(ab -t $duration -c 10 -q http://localhost:${port}/ 2>&1 | grep "Requests per second" | awk '{print $4}')
        echo " ✅ ${result} req/s"
        echo $result
    else
        # Fallback manual se ab não estiver disponível
        local count=0
        local start_time=$(date +%s)
        local end_time=$((start_time + duration))
        
        while [ $(date +%s) -lt $end_time ]; do
            curl -s http://localhost:${port}/health > /dev/null 2>&1 && count=$((count + 1))
        done
        
        local rps=$(echo "scale=2; $count / $duration" | bc)
        echo " ✅ ~${rps} req/s (aproximado)"
        echo $rps
    fi
}

# Array para armazenar resultados
declare -A results

# Testar cada versão
for tag in distroless scratch upx; do
    echo ""
    echo "📊 Testando: ${IMAGE_BASE}:${tag}"
    echo "──────────────────────────────────────"
    
    # Verificar se imagem existe
    if ! docker images ${IMAGE_BASE}:${tag} | grep -q ${tag}; then
        echo "   ⚠️  Imagem não encontrada. Build com: make docker-build-${tag}"
        continue
    fi
    
    port=$((PORT_BASE++))
    
    # 1. Startup time
    container_id=$(measure_startup ${IMAGE_BASE}:${tag} $port)
    startup_time=$?
    
    if [ -z "$container_id" ]; then
        echo "   ❌ Falha ao iniciar container"
        continue
    fi
    
    # 2. Response time
    response_time=$(measure_response_time $port 50)
    
    # 3. Memory usage
    memory=$(measure_memory $container_id)
    
    # 4. Throughput
    throughput=$(measure_throughput $port)
    
    # Limpar
    echo "   🧹 Limpando..."
    docker stop $container_id > /dev/null 2>&1
    docker rm $container_id > /dev/null 2>&1
    
    # Armazenar resultados
    results["${tag}_startup"]=$startup_time
    results["${tag}_response"]=$response_time
    results["${tag}_memory"]=$memory
    results["${tag}_throughput"]=$throughput
done

# Mostrar comparação final
echo ""
echo ""
echo "🏆 RESUMO DA PERFORMANCE"
echo "════════════════════════════════════════════════════"
echo ""
printf "%-15s %-15s %-15s %-15s\n" "VERSÃO" "STARTUP" "RESPONSE" "MEMÓRIA"
printf "%-15s %-15s %-15s %-15s\n" "───────────────" "───────────────" "───────────────" "───────────────"

for tag in distroless scratch upx; do
    if [ ! -z "${results[${tag}_startup]}" ]; then
        printf "%-15s %-15s %-15s %-15s\n" \
            "$tag" \
            "${results[${tag}_startup]}ms" \
            "${results[${tag}_response]}ms" \
            "${results[${tag}_memory]}"
    fi
done

echo ""
echo "📝 Notas:"
echo "  • Startup: Tempo até primeira resposta"
echo "  • Response: Tempo médio de resposta"
echo "  • Memória: Uso de RAM do container"
echo ""
echo "💡 Interpretação:"
echo "  ✅ Distroless/Scratch: Performance similar"
echo "  ⚠️  UPX: Startup ~100-300ms mais lento (descompressão)"
echo "  ✅ UPX: Response time idêntico após startup"
echo ""

