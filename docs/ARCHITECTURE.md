# 🏗️ Arquitetura do Projeto

> **Autor:** Alan Ramalho ([@raioramalho](https://github.com/raioramalho))  
> **Role:** Sênior Solutions Architect

Visão geral da estrutura e decisões arquiteturais do projeto.

## 📐 Estrutura de Diretórios

```
go-distroless-example/
│
├── src/                         # Código fonte
│   ├── main.go                  # Aplicação Go principal
│   └── tests/                   # Testes
│       └── main_test.go         # Testes unitários
│
├── build/                       # Dockerfiles e configurações de build
│   ├── Dockerfile.debug         # Imagem com shell (debug)
│   ├── Dockerfile.multiarch     # Build multi-arquitetura
│   ├── Dockerfile.scratch       # Imagem minimalista (6.26MB)
│   └── Dockerfile.upx           # Imagem ultra-comprimida (2.67MB)
│
├── docs/                        # Documentação do projeto
│   ├── ARCHITECTURE.md          # Este arquivo
│   ├── OPTIMIZATION.md          # Guia de otimização
│   ├── PERFORMANCE.md           # Análise de performance
│   └── PERFORMANCE-SUMMARY.txt  # Resumo visual
│
├── scripts/                     # Scripts de automação
│   ├── benchmark.sh             # Benchmark de performance
│   ├── build-multiarch.sh       # Build multi-arquitetura
│   ├── compare-optimizations.sh # Comparar otimizações
│   ├── compare-sizes.sh         # Comparar tamanhos
│   ├── measure-build-time.sh    # Medir tempo de build
│   └── quick-start.sh           # Início rápido
│
├── go.mod                       # Dependências Go
├── Dockerfile                   # Dockerfile principal (Distroless)
├── docker-compose.yml           # Configuração Docker Compose
├── Makefile                     # Comandos de automação
├── README.md                    # Documentação principal
├── LICENSE                      # Licença MIT
├── .gitignore                   # Git ignore
├── .dockerignore                # Docker ignore
└── .editorconfig                # Configuração de editor

```

## 🎯 Decisões Arquiteturais

### 1. **Linguagem e Runtime**

**Escolha:** Go 1.21
- ✅ Compilação para binário estático
- ✅ Sem dependências de runtime
- ✅ Perfeito para containers minimalistas
- ✅ Excelente performance

### 2. **Estratégia de Containerização**

**Multi-stage Build:**
```dockerfile
FROM golang:1.21-alpine AS builder  # Stage 1: Build
FROM gcr.io/distroless/static       # Stage 2: Runtime
```

**Benefícios:**
- Separação de build e runtime
- Imagem final não contém toolchain
- Redução drástica de tamanho
- Melhor segurança

### 3. **Imagens Base**

Oferecemos 4 opções conforme caso de uso:

| Imagem | Tamanho | Segurança | Uso |
|--------|---------|-----------|-----|
| **Distroless** | 12.5MB | ⭐⭐⭐⭐⭐ | Produção web |
| **Scratch** | 6.26MB | ⭐⭐⭐⭐ | Serverless |
| **UPX** | 2.67MB | ⭐⭐⭐ | IoT/Edge |
| **Debug** | 12.5MB+ | ⭐⭐⭐⭐ | Desenvolvimento |

### 4. **Arquitetura ARM64**

**Target primário:** ARM64
- Apple Silicon (M1/M2/M3/M4)
- AWS Graviton
- Raspberry Pi 4+
- Suporte multi-arch disponível

### 5. **Otimizações de Build**

**Flags de compilação:**
```bash
CGO_ENABLED=0          # Binário estático
GOARCH=arm64           # Arquitetura ARM
-ldflags="-w -s"       # Remove debug info
-trimpath              # Remove paths absolutos
-tags netgo,osusergo   # Pure Go networking
```

## 🔒 Segurança

### Camadas de Segurança

1. **Imagem Distroless**
   - Sem shell
   - Sem package manager
   - Apenas runtime essencial
   - Mantida pelo Google

2. **Usuário não-root**
   ```dockerfile
   USER nonroot:nonroot  # UID/GID 65532
   ```

3. **Binário estático**
   - Sem dependências dinâmicas
   - Sem vulnerabilidades de libs externas

4. **Imagens assinadas**
   - Verificáveis com cosign
   - Supply chain security

### Scan de Vulnerabilidades

```bash
# Scan com Trivy
trivy image go-distroless-app:latest

# Resultado esperado: 0 vulnerabilidades críticas
```

## 📊 Performance

### Características

| Métrica | Valor | Nota |
|---------|-------|------|
| **Cold Start** | 700-1100ms | Varia por versão |
| **Response Time** | 0.5ms | Todas as versões |
| **Throughput** | 10k req/s | Apple M1 |
| **Memória** | 8-11MB | Em idle |
| **CPU** | ~1% | Sob carga |

### Trade-offs

- **Distroless:** Melhor balanço
- **Scratch:** Cold start mais rápido
- **UPX:** Menor tamanho, startup +300ms

## 🔄 Pipeline de Build

### Local Development

```
Developer
    ↓
make docker-build
    ↓
Build com cache
    ↓
Imagem local
```

### CI/CD Flow

```
Git Push
    ↓
GitHub Actions/CI
    ↓
make test
    ↓
make docker-build
    ↓
docker push registry
    ↓
Deploy (K8s/Cloud Run/etc)
```

## 🌍 Deploy Targets

### Kubernetes

```yaml
apiVersion: apps/v1
kind: Deployment
spec:
  containers:
  - name: app
    image: go-distroless-app:latest
    resources:
      limits:
        memory: "64Mi"
        cpu: "100m"
```

### Cloud Run / Cloud Functions

- Recomendado: **Scratch** (cold start otimizado)
- Startup rápido é crítico

### Edge / IoT

- Recomendado: **UPX** (menor bandwidth)
- Startup único, roda por meses

### Traditional VM/VPS

- Recomendado: **Distroless** (segurança máxima)
- Long-running, startup irrelevante

## 🧪 Testing Strategy

### 1. Unit Tests
```bash
go test -v ./...
```

### 2. Integration Tests
```bash
docker-compose up -d
curl http://localhost:8080/health
```

### 3. Performance Tests
```bash
make benchmark
```

### 4. Build Time Tests
```bash
make measure-build-time
```

## 📦 Distribuição

### Container Registry

Opções suportadas:
- Docker Hub
- GitHub Container Registry (ghcr.io)
- Google Container Registry (gcr.io)
- AWS ECR
- Azure ACR

### Versionamento

```bash
# Tag por versão semântica
docker tag app:latest app:v1.2.3

# Tag por commit
docker tag app:latest app:$(git rev-parse --short HEAD)

# Tag por data
docker tag app:latest app:$(date +%Y%m%d)
```

## 🔧 Extensibilidade

### Adicionar Nova Rota

```go
// main.go
http.HandleFunc("/api/v1/users", handleUsers)
```

### Adicionar Nova Otimização

1. Criar `build/Dockerfile.newopt`
2. Adicionar target no `Makefile`
3. Adicionar no script de comparação
4. Documentar em `docs/OPTIMIZATION.md`

### Adicionar Nova Arquitetura

```bash
# Dockerfile.multiarch
--platform linux/arm64,linux/amd64,linux/arm/v7
```

## 🚀 Escalabilidade

### Horizontal Scaling

```yaml
# Kubernetes HPA
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
spec:
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

### Vertical Scaling

Aplicação é stateless e leve:
- Pode rodar com 32MB RAM
- CPU < 1% em idle
- Escala linearmente

## 📝 Manutenção

### Atualizações de Dependências

```bash
# Atualizar Go modules
go get -u ./...
go mod tidy

# Atualizar imagens base
docker pull golang:1.21-alpine
docker pull gcr.io/distroless/static-debian12
```

### Monitoramento

Métricas recomendadas:
- Response time (p50, p95, p99)
- Request rate
- Error rate
- CPU/Memory usage
- Container restart count

## 🎓 Recursos de Aprendizado

### Conceitos Aplicados

1. **Multi-stage builds**
2. **Distroless containers**
3. **ARM64 compilation**
4. **Go static binaries**
5. **Container optimization**
6. **Performance benchmarking**

### Para Saber Mais

- [Distroless GitHub](https://github.com/GoogleContainerTools/distroless)
- [Go Build Modes](https://pkg.go.dev/cmd/go)
- [Docker Multi-stage](https://docs.docker.com/build/building/multi-stage/)
- [ARM64 Go](https://go.dev/doc/install/source#environment)

---

**Última atualização:** Dezembro 2025  
**Versão:** 1.0.0

