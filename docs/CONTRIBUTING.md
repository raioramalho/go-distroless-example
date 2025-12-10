# 🤝 Guia de Contribuição

> **Mantido por:** Alan Ramalho ([@raioramalho](https://github.com/raioramalho))  
> **Contato:** ramalho.sit@gmail.com

Obrigado por considerar contribuir com este projeto! Este documento fornece diretrizes para contribuições.

## 📋 Como Contribuir

### 1. Fork e Clone

```bash
# Fork no GitHub, então clone seu fork
git clone https://github.com/SEU-USERNAME/go-distroless-example.git
cd go-distroless-example
```

### 2. Criar Branch

```bash
# Crie uma branch para sua feature/fix
git checkout -b feature/minha-feature
# ou
git checkout -b fix/meu-fix
```

### 3. Fazer Mudanças

- Siga o estilo de código existente
- Adicione testes se aplicável
- Atualize a documentação

### 4. Testar

```bash
# Rodar testes
go test -v ./...

# Build e testar Docker
make docker-build
docker run --rm -p 8080:8080 go-distroless-app:latest

# Benchmark (opcional)
make benchmark
```

### 5. Commit

Siga o padrão de commits convencionais:

```bash
# Exemplos de mensagens
git commit -m "feat: adiciona nova rota /api/users"
git commit -m "fix: corrige memory leak no handler"
git commit -m "docs: atualiza README com novos exemplos"
git commit -m "perf: melhora tempo de build em 20%"
git commit -m "refactor: reorganiza estrutura de pastas"
```

**Tipos de commit:**
- `feat`: Nova funcionalidade
- `fix`: Correção de bug
- `docs`: Mudanças na documentação
- `style`: Formatação, sem mudança de código
- `refactor`: Refatoração de código
- `perf`: Melhorias de performance
- `test`: Adição ou correção de testes
- `chore`: Tarefas de manutenção

### 6. Push e Pull Request

```bash
git push origin feature/minha-feature
```

Então abra um Pull Request no GitHub com:
- Descrição clara do que foi mudado
- Referência a issues relacionadas
- Screenshots se aplicável

## 🎯 Áreas para Contribuir

### Ideias de Contribuições

#### 🐳 Docker / Build
- [ ] Adicionar suporte para novas arquiteturas (arm/v7, s390x)
- [ ] Otimizações adicionais de tamanho
- [ ] Novos Dockerfiles para casos de uso específicos
- [ ] Melhorias no tempo de build

#### 🚀 Aplicação
- [ ] Adicionar métricas (Prometheus)
- [ ] Adicionar tracing (OpenTelemetry)
- [ ] Adicionar logging estruturado
- [ ] Adicionar graceful shutdown
- [ ] Adicionar rate limiting

#### 📚 Documentação
- [ ] Traduzir documentação para outros idiomas
- [ ] Adicionar mais exemplos de uso
- [ ] Criar tutoriais em vídeo
- [ ] Melhorar diagramas e visualizações

#### 🧪 Testes
- [ ] Aumentar cobertura de testes
- [ ] Adicionar testes de integração
- [ ] Adicionar testes de carga
- [ ] Adicionar testes de segurança

#### ⚙️ CI/CD
- [ ] Configurar GitHub Actions
- [ ] Adicionar builds automatizados
- [ ] Adicionar releases automatizadas
- [ ] Adicionar scans de segurança

#### 🔧 Ferramentas
- [ ] Melhorar scripts de benchmark
- [ ] Adicionar mais automação
- [ ] Criar CLI tool
- [ ] Adicionar pre-commit hooks

## 📝 Padrões de Código

### Go

```go
// Use gofmt
go fmt ./...

// Use golint
golint ./...

// Use go vet
go vet ./...
```

### Estilo

- Siga as convenções Go padrão
- Use nomes descritivos
- Escreva comentários úteis
- Mantenha funções pequenas e focadas

### Exemplo de Código Bom

```go
// handleHealth retorna o status de saúde da aplicação.
// Retorna sempre 200 OK se o servidor está respondendo.
func handleHealth(w http.ResponseWriter, r *http.Request) {
    w.WriteHeader(http.StatusOK)
    fmt.Fprintf(w, "OK")
}
```

## 🐛 Reportar Bugs

### Antes de Reportar

1. Verifique se já existe uma issue aberta
2. Teste na versão mais recente
3. Colete informações do sistema

### Template de Bug Report

```markdown
## Descrição
Descrição clara e concisa do bug.

## Para Reproduzir
1. Execute '...'
2. Acesse '....'
3. Veja erro

## Comportamento Esperado
O que deveria acontecer.

## Screenshots
Se aplicável, adicione screenshots.

## Ambiente
- OS: [ex: macOS 14.0, Ubuntu 22.04]
- Docker: [ex: 24.0.7]
- Arquitetura: [ex: ARM64, AMD64]
- Versão da imagem: [ex: latest, v1.2.3]

## Informações Adicionais
Qualquer outra informação relevante.
```

## ✨ Sugerir Features

### Template de Feature Request

```markdown
## Problema
Descrição clara do problema que a feature resolve.

## Solução Proposta
Como você imagina que isso funcione.

## Alternativas Consideradas
Outras soluções que você considerou.

## Informações Adicionais
Contexto adicional, mockups, exemplos.
```

## 🔍 Code Review

Pull Requests serão revisadas considerando:

- ✅ Código funciona conforme esperado
- ✅ Testes foram adicionados/atualizados
- ✅ Documentação foi atualizada
- ✅ Segue padrões de código
- ✅ Não quebra funcionalidade existente
- ✅ Performance não foi degradada

## 📞 Dúvidas?

- Abra uma Discussion no GitHub
- Crie uma issue com label `question`

## 🙏 Agradecimentos

Toda contribuição é valiosa, seja:
- Código
- Documentação
- Bug reports
- Sugestões
- Feedback

**Obrigado por contribuir!** 🎉

