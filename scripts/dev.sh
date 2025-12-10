#!/bin/bash

# Script para iniciar ambiente de desenvolvimento com hot-reload

set -e

echo "🔥 Iniciando ambiente de desenvolvimento com hot-reload"
echo "========================================================="
echo ""

# Verificar se Docker está rodando
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker não está rodando!"
    echo "   Por favor, inicie o Docker Desktop."
    exit 1
fi

echo "✅ Docker está rodando"
echo ""

# Criar diretório tmp se não existir
mkdir -p tmp

# Adicionar tmp ao .gitignore se não estiver
if ! grep -q "^tmp/$" .gitignore 2>/dev/null; then
    echo "tmp/" >> .gitignore
    echo "✅ Adicionado tmp/ ao .gitignore"
fi

echo "📦 Construindo imagem de desenvolvimento..."
docker-compose -f docker-compose.dev.yml build

echo ""
echo "🚀 Iniciando container de desenvolvimento..."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🔥 Hot-reload ATIVADO!"
echo "  📝 Edite arquivos em src/ e veja as mudanças automaticamente"
echo "  🌐 Aplicação: http://localhost:8080"
echo "  ❤️  Health: http://localhost:8080/health"
echo ""
echo "  Para parar: Ctrl+C ou 'docker-compose -f docker-compose.dev.yml down'"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Iniciar em modo attached para ver logs
docker-compose -f docker-compose.dev.yml up

# Cleanup ao sair
echo ""
echo "🧹 Limpando..."
docker-compose -f docker-compose.dev.yml down

