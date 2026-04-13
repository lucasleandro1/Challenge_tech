# Challenge Tech — Dimensa

API REST para busca de frases por tag, com cache em MongoDB e atualização automática via Sidekiq.

## Tecnologias

- Ruby on Rails 8 (API-only)
- MongoDB + Mongoid 9
- Sidekiq + sidekiq-cron
- Devise (autenticação de senha)
- HTTParty + Nokogiri (web crawler)
- Docker + docker-compose
- RSpec

---

## Como executar

### Pré-requisitos

- Docker
- Docker Compose

### Passos

```bash
# 1. Clone o repositório
git clone https://github.com/lucasleandro1/Challenge_tech.git
cd Challenge_tech

# 2. Suba os containers
docker compose up --build

# 3. A API estará disponível em http://localhost:3000
```

O seed roda automaticamente na inicialização criando um usuário e um cache de exemplo.

### Credenciais de teste

| Campo | Valor |
|---|---|
| Email | `admin@dimensa.com` |
| Senha | `senha123` |

### Tag com cache pré-carregado

A tag `inspirational` já vem com 3 frases salvas no banco, útil para testar o retorno do cache sem precisar esperar o crawler.

Os serviços iniciados são:

| Serviço | Descrição |
|---|---|
| `app` | Rails API na porta 3000 |
| `mongo` | MongoDB na porta 27017 |
| `redis` | Redis (interno) |
| `sidekiq` | Worker para jobs em background |

---

## Endpoints

### Autenticação

#### Cadastro
```
POST /api/v1/auth/sign_up
Content-Type: application/json

{
  "email": "usuario@email.com",
  "password": "senha123"
}
```

Resposta `201`:
```json
{ "token": "abc123..." }
```

#### Login
```
POST /api/v1/auth/sign_in
Content-Type: application/json

{
  "email": "usuario@email.com",
  "password": "senha123"
}
```

Resposta `200`:
```json
{ "token": "abc123..." }
```

### Quotes

#### Buscar frases por tag
```
GET /api/v1/quotes/:tag
Authorization: Bearer <token>
```

Resposta `200`:
```json
{
  "quotes": [
    {
      "quote": "It is better to be hated for what you are than to be loved for what you are not.",
      "author": "André Gide",
      "author_about": "http://quotes.toscrape.com/author/Andre-Gide",
      "tags": ["life", "love"]
    }
  ]
}
```

Sem token — resposta `401`:
```json
{ "error": "Unauthorized" }
```

---

## Funcionamento

### Fluxo de uma requisição

```
GET /api/v1/quotes/love
       │
       ▼
ApplicationController#authenticate_user!
  → verifica Bearer token no header
  → retorna 401 se inválido
       │
       ▼
QuotesController#show
       │
       ▼
QuoteFetcherService#call
  ┌────────────────────────────────────┐
  │ Tag existe no MongoDB com quotes?  │
  │   Sim → retorna do cache           │
  │   Não → chama CrawlerService       │
  │         salva no MongoDB           │
  │         retorna os resultados      │
  └────────────────────────────────────┘
       │
       ▼
QuoteSerializer
  → formata cada quote para o JSON esperado
```

### Cache

O MongoDB funciona como cache de tags. Cada documento `TagCache` armazena:

- `name` — a tag pesquisada (ex: `"love"`)
- `quotes` — array com todas as frases encontradas

Se a tag já tiver resultados salvos, os dados são retornados diretamente do banco sem nenhuma requisição ao site externo.

Se a tag existir no banco mas sem resultados (o site não retornou nada na última busca), o crawler é chamado novamente para verificar se houve atualizações.

### Job automático

O `RefreshQuotesJob` é executado automaticamente duas vezes ao dia (meia-noite e meio-dia) via `sidekiq-cron`.

Ele percorre todas as tags salvas no banco, consulta o site novamente e salva apenas as frases novas — sem duplicar as já existentes. A comparação é feita pelo texto da frase.

---

## Solução adotada

### Autenticação por Bearer token

A autenticação foi implementada com token gerado via `SecureRandom` e armazenado no MongoDB. Cada login gera um novo token. O `ApplicationController` valida o token no header `Authorization: Bearer <token>` antes de qualquer ação protegida.

### Services

Os controllers não contêm lógica de negócio. Cada service tem uma responsabilidade clara:

- `CrawlerService` — faz a requisição HTTP e parseia o HTML
- `QuoteFetcherService` — decide entre cache ou crawl
- `QuoteSerializer` — formata a saída JSON

Isso facilita testes unitários e manutenção isolada de cada parte.

---

## Testes

```bash
# Rodar os testes dentro do Docker (MongoDB disponível)
docker compose exec app bundle exec rspec
```

A suíte cobre:

- Autenticação (token válido, inválido, ausente)
- `QuoteFetcherService` (cache hit, cache miss, re-crawl de tag vazia)
- `RefreshQuotesJob` (atualização sem duplicatas)
- Modelo `User` (validações, geração de token)
