# 🔐 Variáveis de Ambiente

Configuração das variáveis de ambiente do projeto.

## 📋 Variáveis Disponíveis

| Variável | Descrição | Padrão | Obrigatório |
|----------|-----------|--------|-------------|
| `PORT` | Porta da aplicação | `8080` | Não |
| `GO_ENV` | Ambiente de execução | `development` | Não |
| `LOG_LEVEL` | Nível de log | `info` | Não |

## 🚀 Quick Start

```bash
# 1. Copiar arquivo de exemplo
cp .env.example .env

# 2. Editar variáveis
vim .env

# 3. Iniciar aplicação
make dev
```

## 📄 Arquivo .env.example

```env
# Porta da aplicação
PORT=8080

# Ambiente (development, staging, production)
GO_ENV=development

# Nível de log (debug, info, warn, error)
LOG_LEVEL=info
```

## 🐳 Docker Compose

O Docker Compose carrega automaticamente o arquivo `.env`:

```yaml
# docker-compose.yml
services:
  app:
    env_file:
      - .env
    environment:
      - PORT=${PORT:-8080}
      - GO_ENV=${GO_ENV:-production}
```

## 💻 Desenvolvimento vs Produção

### Desenvolvimento

```env
# .env para desenvolvimento
PORT=8080
GO_ENV=development
LOG_LEVEL=debug
```

### Produção

```env
# .env para produção
PORT=8080
GO_ENV=production
LOG_LEVEL=info
```

## 🔒 Segurança

⚠️ **IMPORTANTE:**

1. **NUNCA** commite o arquivo `.env` no Git
2. O arquivo `.env` está no `.gitignore`
3. Use `.env.example` como template
4. Em produção, use variáveis de ambiente do sistema ou secrets manager

### Práticas Recomendadas

```bash
# ✅ Correto
cp .env.example .env
vim .env  # Edite localmente

# ❌ Errado
git add .env  # NUNCA faça isso!
```

## 🔧 Código Go

O projeto usa `godotenv` para carregar o `.env`:

```go
import "github.com/joho/godotenv"

func init() {
    // Carrega .env se existir
    if err := godotenv.Load(); err != nil {
        log.Println("Arquivo .env não encontrado")
    }
}

func main() {
    port := getEnv("PORT", "8080")
    // ...
}

func getEnv(key, defaultValue string) string {
    if value := os.Getenv(key); value != "" {
        return value
    }
    return defaultValue
}
```

## 📦 Dependência

```go
// go.mod
require github.com/joho/godotenv v1.5.1
```

## 🐳 Em Containers

### Com Docker Run

```bash
docker run -e PORT=3000 -e GO_ENV=production go-distroless-app
```

### Com Docker Compose

```bash
# Usa .env automaticamente
docker-compose up
```

### Em Kubernetes

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  PORT: "8080"
  GO_ENV: "production"
---
apiVersion: apps/v1
kind: Deployment
spec:
  template:
    spec:
      containers:
      - name: app
        envFrom:
        - configMapRef:
            name: app-config
```

## 🔄 Ordem de Precedência

1. **Variável de ambiente do sistema** (maior prioridade)
2. **Arquivo .env**
3. **Valor padrão no código** (menor prioridade)

```go
// Exemplo: PORT
// 1. Se PORT existe no sistema → usa
// 2. Se PORT existe no .env → usa
// 3. Senão → usa "8080"
```

---

**Autor:** Alan Ramalho ([@raioramalho](https://github.com/raioramalho))

