# db · SQLite local Clara

Estado persistente de cada install Clara. **1 DB por lojista** · isolamento total.

## Stack

- **SQLite 3** + WAL mode (concurrency leve · zero servidor)
- Path do DB: `/opt/clones/clara/workspace/data/clara.db`

## Schema

7 tabelas + 2 views:

| Tabela | O que guarda |
|--------|--------------|
| `lojista` | Dono (1 linha) · nome · loja · WhatsApp · Pix · endereço |
| `produtos_loja` | Catálogo do lojista (não-Claro · produtos próprios) |
| `claro_canon_local` | Cache local do claro-canon (sync da skill) |
| `clientes` | CRM básico (nome · WA · ticket · origem) |
| `follow_ups` | Próximas ações por cliente (prazo · canal · motivo) |
| `posts_agendados` | Calendário editorial (post · canal · template · status) |
| `eventos` | Log de tudo que Clara fez (auditoria leve) |

| View | Pra que serve |
|------|---------------|
| `v_followups_pendentes` | Follow-ups vencendo nas próximas 24h |
| `v_posts_proximos` | Posts em janela de publicação ou rendering |

## Setup

```bash
bash init.sh
```

Cria o DB se não existir + aplica schema. Idempotente (pode rodar várias vezes). Faz backup se já existir.

## Uso (helper Python)

```bash
# Query select tabular
python3 query.py "SELECT id, nome, whatsapp FROM clientes LIMIT 5"

# Query JSON (Clara consome)
python3 query.py --json "SELECT * FROM v_followups_pendentes"

# Exec INSERT/UPDATE/DELETE
python3 query.py --exec "INSERT INTO clientes (nome, whatsapp) VALUES ('Fulano', '5515999999999')"
```

## Como Clara invoca

Quando lojista fala:
- **"cliente João comprou hoje, R$ 200, peça pra ele voltar em 30 dias"**
  → Clara cria/atualiza `clientes` + insere `follow_ups (motivo='volta_30d', prazo=hoje+30d)`
- **"qual cliente preciso ligar essa semana?"**
  → Clara consulta `v_followups_pendentes`
- **"quero agendar carrossel pra terça 9h"**
  → Clara insere em `posts_agendados (agendado_para='2026-05-27T09:00:00', canal='instagram', ...)`

## Backup

`init.sh` faz backup automático ao re-aplicar schema. Backup manual:
```bash
cp /opt/clones/clara/workspace/data/clara.db /opt/clones/clara/workspace/data/backup-$(date +%F).db
```

WAL files (`*-wal`, `*-shm`) também devem ser copiados pra backup íntegro.

## Anti-padrões

- Não usar Postgres pra 1 lojista só (overkill · SQLite é mais leve, mais rápido em single-writer)
- Não compartilhar DB entre lojistas (1 DB por install · evita cross-contamination)
- Não fazer query direta sem helper · sempre via `query.py` (logs · errors padronizados)
