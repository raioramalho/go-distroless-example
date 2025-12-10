# 🔥 Guia de Desenvolvimento

Como desenvolver com hot-reload e ambiente containerizado.

## 🚀 Quick Start

### Opção 1: Makefile (Recomendado)

```bash
# Iniciar ambiente de desenvolvimento
make dev

# A aplicação estará rodando em http://localhost:8080
# Edite arquivos em src/ e veja as mudanças automaticamente! 🔥
```

### Opção 2: Script direto

```bash
./scripts/dev.sh
```

### Opção 3: Docker Compose manual

```bash
docker-compose -f docker-compose.dev.yml up
```

## 🔥 Hot-Reload

O ambiente de desenvolvimento usa **Air** para recarregar automaticamente quando você faz mudanças no código.

### Como funciona:

1. Você edita um arquivo `.go` em `src/`
2. Air detecta a mudança
3. Recompila o código automaticamente
4. Reinicia a aplicação
5. Pronto! ✨

**Tempo de reload:** ~1-2 segundos

## 📁 Estrutura de Desenvolvimento

```
.
├── src/                    # 📝 Edite seus arquivos aqui
│   ├── main.go
│   └── tests/
├── tmp/                    # 🗑️ Binários temporários (ignorado)
├── .air.toml               # ⚙️ Configuração do Air
├── build/Dockerfile.dev    # 🐳 Dockerfile de desenvolvimento
└── docker-compose.dev.yml  # 🐙 Compose de desenvolvimento
```

## 🛠️ Comandos Úteis

### Desenvolvimento

```bash
# Iniciar ambiente dev
make dev

# Ver logs
make dev-logs

# Parar ambiente
make dev-down

# Rebuild completo (limpa cache)
make dev-rebuild
```

### Testes durante desenvolvimento

```bash
# Em outro terminal, enquanto o dev está rodando
make test

# Ou executar Go test diretamente
go test -v ./src/tests/...
```

### Acessar o container

```bash
# Executar shell no container dev
docker exec -it go-distroless-dev sh

# Verificar processos
docker exec -it go-distroless-dev ps aux

# Ver variáveis de ambiente
docker exec -it go-distroless-dev env
```

## 🔧 Configuração do Air

O arquivo `.air.toml` controla o comportamento do hot-reload:

```toml
[build]
  cmd = "go build -o ./tmp/main ./src"  # Comando de build
  bin = "./tmp/main"                     # Binário gerado
  delay = 1000                           # Delay antes de rebuild (ms)
  include_dir = ["src"]                  # Diretórios a monitorar
  exclude_regex = ["_test.go"]           # Ignorar testes
```

### Customizar Air

Edite `.air.toml` para:
- Mudar diretórios monitorados
- Ajustar delay de rebuild
- Adicionar comandos pré/pós build
- Customizar cores dos logs

## 🐛 Debugging

### Adicionar prints de debug

```go
// src/main.go
import "log"

func handleRoot(w http.ResponseWriter, r *http.Request) {
    log.Printf("🔍 Request: %s %s", r.Method, r.URL.Path)
    // ... resto do código
}
```

### Ver logs em tempo real

```bash
make dev-logs
```

### Usar delve (debugger Go)

Para debugging avançado, modifique `build/Dockerfile.dev`:

```dockerfile
# Instalar delve
RUN go install github.com/go-delve/delve/cmd/dlv@latest

# Mudar CMD para usar delve
CMD ["dlv", "debug", "./src", "--headless", "--listen=:2345", "--api-version=2"]
```

Então conecte seu IDE na porta 2345.

## 📊 Performance

### Otimizar tempo de rebuild

**1. Use volumes cached:**
```yaml
volumes:
  - ./src:/app/src:cached  # ✅ Já configurado
```

**2. Cache de módulos Go:**
```yaml
volumes:
  - go-modules:/go/pkg/mod  # ✅ Já configurado
```

**3. Reduzir diretórios monitorados:**

No `.air.toml`:
```toml
include_dir = ["src"]           # Apenas src/
exclude_dir = ["src/tests"]     # Ignorar testes
```

### Tempo de rebuild esperado

- **Primeira vez:** 5-10s (download de deps)
- **Rebuilds seguintes:** 1-2s
- **Mudanças simples:** < 1s

## 🔒 Diferenças vs Produção

| Feature | Development | Production |
|---------|------------|------------|
| **Imagem base** | golang:1.21-alpine | distroless/static |
| **Tamanho** | ~400MB | 2.67-12.5MB |
| **Hot-reload** | ✅ Sim (Air) | ❌ Não |
| **Debug tools** | ✅ Sim | ❌ Não |
| **Shell** | ✅ Sim | ❌ Não |
| **Performance** | Bom | Ótimo |
| **Segurança** | Médio | Alto |

## 💡 Dicas

### 1. Múltiplas instâncias

```bash
# Terminal 1: Aplicação
make dev

# Terminal 2: Testes em watch mode
go test -v ./src/tests/... -count=1 -watch
```

### 2. Variáveis de ambiente

Edite `docker-compose.dev.yml`:

```yaml
environment:
  - PORT=8080
  - GO_ENV=development
  - DEBUG=true              # Adicione suas vars aqui
  - API_KEY=dev-key-123
```

### 3. Adicionar dependências

```bash
# Adicionar nova dependência
go get github.com/pkg/errors

# O Air detectará go.mod e reconstruirá
```

### 4. Ver mudanças em tempo real

```bash
# Terminal 1: Logs do Air
make dev-logs

# Terminal 2: Edite arquivo
vim src/main.go

# Veja o rebuild acontecer automaticamente!
```

## 🐳 Volumes Docker

O ambiente dev usa volumes para hot-reload:

```yaml
volumes:
  - ./src:/app/src:cached          # Código fonte
  - ./go.mod:/app/go.mod:cached    # Dependências
  - go-modules:/go/pkg/mod         # Cache de módulos
  - ./tmp:/app/tmp:cached          # Binários temporários
```

**Benefícios:**
- Mudanças refletidas instantaneamente
- Cache de módulos Go entre rebuilds
- Não precisa rebuild da imagem a cada mudança

## 🚨 Troubleshooting

### Problema: Air não detecta mudanças

**Solução:**
```bash
# Rebuild completo
make dev-rebuild

# Verificar permissões
ls -la src/

# Verificar logs do Air
make dev-logs
```

### Problema: Porta 8080 já em uso

**Solução:**
```bash
# Parar container existente
make dev-down

# Ou mudar porta em docker-compose.dev.yml
ports:
  - "8081:8080"  # Use 8081 no host
```

### Problema: Mudanças muito lentas

**Solução:**
1. Reduzir diretórios monitorados no `.air.toml`
2. Aumentar `delay` no `.air.toml`
3. Usar SSD (se possível)
4. Excluir mais diretórios

### Problema: Go modules download lento

**Solução:**
```bash
# Usar proxy Go brasileiro
export GOPROXY=https://proxy.golang.org,direct

# Ou usar cache local
docker volume inspect go-distroless-example_go-modules
```

## 📚 Recursos

- [Air GitHub](https://github.com/cosmtrek/air)
- [Docker Compose Docs](https://docs.docker.com/compose/)
- [Go Best Practices](https://go.dev/doc/effective_go)
- [Delve Debugger](https://github.com/go-delve/delve)

## 🎯 Próximos Passos

1. **Configurar seu IDE** para conectar ao container
2. **Adicionar mais features** à aplicação
3. **Escrever testes** enquanto desenvolve
4. **Usar debugging** quando necessário

---

**Dica:** Mantenha o ambiente dev sempre rodando durante desenvolvimento. É rápido, eficiente e você verá mudanças instantaneamente! 🔥

