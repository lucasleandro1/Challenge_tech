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

### Testando com Postman

O arquivo `postman_collection.json` na raiz do repositório pode ser importado diretamente no Postman.

### Credenciais de teste

Email  `admin@dimensa.com`
Senha  `senha123`

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

## Funcionamento

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
