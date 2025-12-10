# Go + Distroless Example 🥑

> Exemplo de aplicação Go usando imagens **distroless** para máxima segurança e tamanho mínimo.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Go Version](https://img.shields.io/badge/Go-1.21-00ADD8?logo=go)](https://go.dev/)
[![Docker](https://img.shields.io/badge/Docker-Multi--stage-2496ED?logo=docker)](Dockerfile)
[![Architecture](https://img.shields.io/badge/Arch-ARM64%20%7C%20AMD64-green)]()
[![Image Size](https://img.shields.io/badge/Size-2.67MB%20to%2012.5MB-blue)]()

**Características principais:**
- 🔒 **Ultra-seguro** - Sem shell, sem package manager
- 🪶 **Ultra-leve** - De 2.67MB a 12.5MB (3 versões)
- 🚀 **Alta performance** - Binário Go estático otimizado
- 💪 **ARM64 nativo** - Otimizado para Apple Silicon
- 📦 **Multi-stage build** - Build isolado do runtime
- ✅ **Pronto para produção** - Testado e documentado

## 📊 Resultados

### Comparação de Tamanhos

| Versão | Tamanho | Redução | Recomendação |
|--------|---------|---------|--------------|
| **Distroless** (padrão) | 12.5 MB | baseline | ⭐ Produção (balanceado) |
| **Scratch** | 6.26 MB | 50% ↓ | ⚡ Minimalista |
| **UPX** | 2.67 MB | 79% ↓ | 🔥 Ultra-otimizado |

### Características

- **Arquitetura**: ARM64 (Apple Silicon, Raspberry Pi, etc)
- **Sem shell, sem package manager** - superfície de ataque mínima
- **Usuário não-root** - segurança adicional (distroless)
- **Build multi-stage** - build isolado do runtime
- **Suporte multi-arch** - ARM64 + AMD64 disponível

### ⚡ Impacto de Performance

**TL;DR:** Build time similar, performance de runtime idêntica!

| Métrica | Distroless | Scratch | UPX |
|---------|-----------|---------|-----|
| **Build Time** | 17.8s | 15.6s ✅ | 17.6s |
| **Image Size** | 12.5MB | 6.26MB | 2.67MB ✅ |
| **Cold Start** | 800ms | 700ms ✅ | 1100ms ⚠️ |
| **Runtime** | 0.5ms | 0.5ms | 0.5ms ✅ |
| **Throughput** | 10k/s | 10k/s | 10k/s ✅ |

📖 **Análise completa:** Veja [`docs/PERFORMANCE.md`](docs/PERFORMANCE.md)

## 🚀 Quick Start

### Desenvolvimento (com hot-reload 🔥)

```bash
# Ambiente de desenvolvimento com hot-reload automático
make dev

# Edite arquivos em src/ e veja as mudanças instantaneamente!
# Aplicação em: http://localhost:8080
```

### Produção

```bash
# Maneira mais rápida - script automatizado
./scripts/quick-start.sh
```

## 🛠️ Como usar

### Build e executar local

```bash
# Build
make build

# Executar
make run

# Ou manualmente
go run main.go
```

### Build e executar com Docker

```bash
# Build padrão - Distroless (12.5MB - recomendado)
make docker-build

# Build com Scratch (6.26MB - 50% menor)
make docker-build-scratch

# Build com UPX (2.67MB - 79% menor!)
make docker-build-upx

# Comparar todas as versões
make compare-optimizations
# ou
./scripts/compare-optimizations.sh

# Build multi-arquitetura (ARM64 + AMD64)
make docker-build-multiarch
# ou
./scripts/build-multiarch.sh

# Executar container
make docker-run

# Acessar aplicação
curl http://localhost:8080
curl http://localhost:8080/health
```

### Usando Docker Compose

```bash
# Subir aplicação
make compose-up
# ou
docker-compose up --build

# Parar aplicação
make compose-down
# ou
docker-compose down
```

### Comandos úteis

```bash
# Ver tamanho da imagem
make size

# Comparar tamanhos (builder vs final)
make compare

# Comparar diferentes bases (scratch, alpine, distroless)
./scripts/compare-sizes.sh

# Limpar arquivos e imagens
make clean
```

## 📝 Estrutura do Projeto

```
.
├── src/                         # 🚀 Código fonte
│   ├── main.go                  # Aplicação principal
│   └── tests/                   # Testes
│       └── main_test.go         # Testes unitários
│
├── build/                       # 🐳 Dockerfiles
│   ├── Dockerfile.dev           # 🔥 Desenvolvimento (hot-reload)
│   ├── Dockerfile.debug         # Com shell (debug)
│   ├── Dockerfile.multiarch     # Multi-arquitetura
│   ├── Dockerfile.scratch       # Minimalista (6.26MB)
│   └── Dockerfile.upx           # Ultra-otimizado (2.67MB)
│
├── docs/                        # 📚 Documentação
│   ├── ARCHITECTURE.md          # Arquitetura do projeto
│   ├── OPTIMIZATION.md          # Guia de otimização
│   ├── PERFORMANCE.md           # Análise de performance
│   └── PERFORMANCE-SUMMARY.txt  # Resumo visual
│
├── scripts/                     # 🔧 Scripts de automação
│   ├── quick-start.sh           # Início rápido
│   ├── compare-sizes.sh         # Comparar tamanhos
│   ├── compare-optimizations.sh # Comparar otimizações
│   ├── benchmark.sh             # Benchmark
│   ├── measure-build-time.sh    # Medir build time
│   └── build-multiarch.sh       # Build multi-arch
│
├── go.mod                       # 📦 Dependências
├── Dockerfile                   # 🐳 Dockerfile principal
├── docker-compose.yml           # 🐙 Docker Compose (produção)
├── docker-compose.dev.yml       # 🔥 Docker Compose (desenvolvimento)
├── .air.toml                    # ⚙️ Configuração do Air (hot-reload)
├── Makefile                     # ⚙️  Comandos
├── README.md                    # 📖 Este arquivo
├── LICENSE                      # ⚖️  Licença MIT
├── .gitignore                   # Git ignore
├── .dockerignore                # Docker ignore
└── .editorconfig                # Configuração de editor
```

## 🔒 Características de Segurança

1. **Imagem distroless/static** - apenas o essencial
2. **Binário estático** - sem dependências externas
3. **Usuário não-root** - executa como UID 65532
4. **Build flags** - `-ldflags="-w -s"` remove símbolos de debug
5. **CGO desabilitado** - binário totalmente portável
6. **Arquitetura ARM64** - otimizado para Apple Silicon e ARM servers

## 🐛 Debug

Se precisar debugar a aplicação dentro do container:

**Opção 1: Usando imagem debug-nonroot**
```bash
# Build com versão debug
make docker-build-debug

# Entrar no container com shell busybox
make debug-shell
```

**Opção 2: Usando build/Dockerfile.debug**
```bash
docker build -f build/Dockerfile.debug -t go-distroless-app:debug .
docker run --rm -it --entrypoint=/busybox/sh go-distroless-app:debug
```

## 🧪 Testes

```bash
# Executar testes
make test

# Ou manualmente
go test -v ./...
```

## 📦 Versões

- **Go**: 1.21
- **Distroless**: static-debian12
- **Base image**: gcr.io/distroless/static-debian12:nonroot
- **Arquitetura**: ARM64 (com suporte multi-arch disponível)
- **Plataformas suportadas**: 
  - linux/arm64 (Apple Silicon M1/M2/M3, Raspberry Pi 4+, AWS Graviton)
  - linux/amd64 (Intel/AMD x86_64)

## 📚 Documentação Completa

- 📖 [**README.md**](README.md) - Você está aqui!
- 🔥 [**DEVELOPMENT.md**](docs/DEVELOPMENT.md) - Guia de desenvolvimento com hot-reload
- 🏗️ [**ARCHITECTURE.md**](docs/ARCHITECTURE.md) - Arquitetura e decisões técnicas
- 🔬 [**OPTIMIZATION.md**](docs/OPTIMIZATION.md) - Guia detalhado de otimização
- ⚡ [**PERFORMANCE.md**](docs/PERFORMANCE.md) - Análise completa de performance
- 📊 [**PERFORMANCE-SUMMARY.txt**](docs/PERFORMANCE-SUMMARY.txt) - Resumo visual
- 🤝 [**CONTRIBUTING.md**](docs/CONTRIBUTING.md) - Como contribuir

## 🔗 Links Úteis

- [Distroless GitHub](https://github.com/GoogleContainerTools/distroless)
- [Go Docker Best Practices](https://docs.docker.com/language/golang/)
- [Multi-stage builds](https://docs.docker.com/build/building/multi-stage/)

## 📄 Licença

MIT - Veja [LICENSE](LICENSE) para detalhes


