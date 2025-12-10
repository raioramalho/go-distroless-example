# 🔥 Desenvolvimento vs Produção

Comparação entre ambientes de desenvolvimento e produção.

## 📊 Comparação Rápida

| Feature | Desenvolvimento | Produção |
|---------|----------------|----------|
| **Comando** | `make dev` | `make docker-run` |
| **Dockerfile** | `build/Dockerfile.dev` | `Dockerfile` |
| **Imagem base** | `golang:1.21-alpine` (~400MB) | `distroless/static` (2.67-12.5MB) |
| **Hot-reload** | ✅ Sim (Air) | ❌ Não |
| **Shell** | ✅ Sim | ❌ Não |
| **Debug tools** | ✅ Sim | ❌ Não |
| **Volumes** | ✅ Sim (código montado) | ❌ Não (código copiado) |
| **Rebuild** | ~1-2s (hot-reload) | ~15-18s (docker build) |
| **Segurança** | Média | Alta |
| **Performance** | Boa | Ótima |
| **Uso** | Local apenas | Deploy em produção |

## 🔥 Desenvolvimento

### Características

```yaml
# docker-compose.dev.yml
services:
  app-dev:
    build:
      dockerfile: build/Dockerfile.dev
    volumes:
      - ./src:/app/src:cached      # 🔥 Hot-reload
    environment:
      - GO_ENV=development
```

### Quando usar

- ✅ Desenvolvimento local
- ✅ Testar mudanças rapidamente
- ✅ Debugging
- ✅ Aprendizado
- ✅ Prototipagem

### Vantagens

1. **Hot-reload** - Veja mudanças instantaneamente
2. **Debug fácil** - Shell disponível, logs verbosos
3. **Rápido** - Não precisa rebuild
4. **Confortável** - Ferramentas de dev incluídas

### Desvantagens

1. **Grande** - ~400MB vs 2.67MB em prod
2. **Menos seguro** - Tem shell e ferramentas
3. **Não otimizado** - Build debug, não release

## 🚀 Produção

### Características

```dockerfile
# Dockerfile
FROM golang:1.21-alpine AS builder
# ... build ...

FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=builder /app/app /app
ENTRYPOINT ["/app"]
```

### Quando usar

- ✅ Deploy em servidores
- ✅ Kubernetes / Cloud Run
- ✅ Ambientes de staging/produção
- ✅ Performance crítica
- ✅ Segurança crítica

### Vantagens

1. **Ultra-leve** - 2.67MB a 12.5MB
2. **Seguro** - Sem shell, sem package manager
3. **Rápido** - Binário otimizado
4. **Imutável** - Código copiado, não montado

### Desvantagens

1. **Rebuild lento** - ~15s a cada mudança
2. **Debug difícil** - Sem shell (use `:debug` se necessário)
3. **Menos flexível** - Precisa rebuild para mudanças

## 🔄 Workflow Recomendado

### Durante Desenvolvimento

```bash
# 1. Iniciar ambiente dev
make dev

# 2. Desenvolver com hot-reload
vim src/main.go
# Salvar = reload automático! 🔥

# 3. Rodar testes
make test

# 4. Quando satisfeito, testar build de produção
make docker-build
```

### Antes de Deploy

```bash
# 1. Parar ambiente dev
make dev-down

# 2. Build de produção
make docker-build

# 3. Testar localmente
make docker-run
curl http://localhost:8080

# 4. Verificar tamanho
docker images go-distroless-app:latest

# 5. Se tudo OK, fazer push
docker push registry/go-distroless-app:latest
```

## 🐳 Dockerfiles Lado a Lado

### Desenvolvimento (`build/Dockerfile.dev`)

```dockerfile
FROM golang:1.21-alpine

# Ferramentas de dev
RUN apk add --no-cache git make curl
RUN go install github.com/cosmtrek/air@latest

WORKDIR /app

# Módulos
COPY go.mod go.sum* ./
RUN go mod download

# Código (será montado via volume)
COPY src/ ./src/

# Hot-reload com Air
CMD ["air", "-c", ".air.toml"]
```

**Tamanho:** ~400MB  
**Build time:** ~30s (primeira vez)  
**Rebuild:** ~1-2s (hot-reload)

### Produção (`Dockerfile`)

```dockerfile
# Build stage
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.mod go.sum* ./
RUN go mod download
COPY src/ ./src/
RUN CGO_ENABLED=0 go build -ldflags="-w -s" -o app ./src

# Runtime stage
FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=builder /app/app /app
USER nonroot:nonroot
ENTRYPOINT ["/app"]
```

**Tamanho:** 2.67-12.5MB  
**Build time:** ~15-18s  
**Rebuild:** ~15-18s (sem cache)

## 📈 Métricas de Performance

### Startup Time

```
Desenvolvimento:  ~2-3s   (Go runtime + Air)
Produção:         ~0.7-1s (binário direto)
```

### Rebuild Time

```
Desenvolvimento:  ~1-2s   (hot-reload)
Produção:         ~15s    (docker build completo)
```

### Uso de Memória

```
Desenvolvimento:  ~50-80MB  (Go runtime + Air + app)
Produção:         ~8-11MB   (apenas app)
```

### Uso de Disco

```
Desenvolvimento:  ~400MB
Produção:         ~2.67MB (UPX) a 12.5MB (distroless)
```

## 🎯 Casos de Uso

### Caso 1: Desenvolvimento de Feature

```bash
# Use ambiente dev
make dev

# Desenvolva com hot-reload
vim src/handlers.go

# Teste instantaneamente
curl http://localhost:8080/nova-rota
```

**Tempo economizado:** 15s por mudança vs rebuild completo

### Caso 2: Debugging de Bug

```bash
# Use ambiente dev com logs
make dev

# Adicione prints de debug
log.Printf("Debug: %+v", data)

# Veja logs em tempo real
make dev-logs
```

### Caso 3: Teste de Performance

```bash
# Use imagem de produção
make docker-build

# Benchmark
make benchmark

# Comparar otimizações
make compare-optimizations
```

### Caso 4: Deploy em Produção

```bash
# Build versão otimizada
make docker-build-upx

# Verificar segurança
trivy image go-distroless-app:latest

# Deploy
kubectl apply -f k8s/deployment.yml
```

## 🔧 Configuração por Ambiente

### Variáveis de Ambiente

**Desenvolvimento:**
```yaml
# docker-compose.dev.yml
environment:
  - GO_ENV=development
  - DEBUG=true
  - LOG_LEVEL=debug
```

**Produção:**
```yaml
# docker-compose.yml
environment:
  - GO_ENV=production
  - LOG_LEVEL=info
```

### Flags de Build

**Desenvolvimento:**
```bash
# Build rápido, com debug info
go build -o app ./src
```

**Produção:**
```bash
# Build otimizado, sem debug info
go build -ldflags="-w -s" -trimpath -o app ./src
```

## 🚨 Quando NÃO Usar Cada Ambiente

### ❌ NÃO use DEV para:

- Deploy em servidor de produção
- Testes de performance definitivos
- Validação de segurança
- Deploy em cloud

### ❌ NÃO use PRODUÇÃO para:

- Desenvolvimento diário
- Debugging interativo
- Testes rápidos locais
- Aprendizado

## 💡 Dicas

### 1. Mantenha ambos atualizados

Quando mudar dependências:

```bash
# Atualizar dev
make dev-rebuild

# Atualizar produção
make docker-build
```

### 2. Use `.env` files

```bash
# .env.development
GO_ENV=development
DEBUG=true

# .env.production
GO_ENV=production
LOG_LEVEL=info
```

### 3. Automatize com CI/CD

```yaml
# .github/workflows/ci.yml
- name: Test with dev
  run: docker-compose -f docker-compose.dev.yml up -d
  
- name: Build prod
  run: make docker-build
```

## 📚 Recursos

- [Air Documentation](https://github.com/cosmtrek/air)
- [Distroless Images](https://github.com/GoogleContainerTools/distroless)
- [Multi-stage Builds](https://docs.docker.com/build/building/multi-stage/)
- [Go Build Flags](https://pkg.go.dev/cmd/go)

---

**Resumo:** Use **DEV** para desenvolver rapidamente, **PRODUÇÃO** para deploy otimizado e seguro! 🚀

