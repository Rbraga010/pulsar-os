# scheduler

Daemon que executa o calendário editorial do lojista. Varre `posts_agendados` no SQLite, renderiza o carrossel (via `carousel-renderer`), e publica no canal certo (IG / WhatsApp Status / GMB).

## Stack

- Python stdlib + sqlite3
- Loop de polling simples (default 60s) · pra latência menor diminui `--interval`
- Não precisa de APScheduler (loop puro · menos dependência)

> *Nota:* a apscheduler **está** instalada no sistema (`pip3 install apscheduler`) caso futuramente queira jobs cron-like, mas a versão atual usa loop simples por ser mais previsível em SQLite single-file.

## Uso

### Loop infinito (default · ideal pra systemd)

```bash
python3 scheduler.py --interval=60
```

### Tick único (debug)

```bash
python3 scheduler.py --once
```

### Dry-run (não publica · só mostra o que faria)

```bash
python3 scheduler.py --once --dry-run
```

## Instalar como systemd service (opcional)

```bash
sudo cp /opt/clones/clara/workspace/tools/scheduler/clara-scheduler.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now clara-scheduler.service
sudo systemctl status clara-scheduler.service
```

Logs vão pra `/opt/clones/clara/workspace/logs/scheduler.log`.

## Fluxo de um post agendado

```
[lojista pede no Telegram: "agenda carrossel pra terça 9h"]
       ↓
Clara INSERT em posts_agendados (status='agendado')
       ↓
... terça 9h chega ...
       ↓
scheduler.tick() pega post devido
       ↓
1. UPDATE status='rendering'
2. Roda carousel-renderer/render.js
3. UPDATE midias_paths=[...] status='pronto'
4. publish() pro canal (IG/WA/GMB)
5. UPDATE status='publicado' + posted_media_id
```

## Tabela `posts_agendados` (recap)

| Coluna | Exemplo |
|--------|---------|
| `agendado_para` | `2026-05-27T09:00:00` (ISO 8601 · local) |
| `canal` | `instagram` / `whatsapp_status` / `gmb` |
| `tipo` | `carrossel` / `foto` / `story` |
| `template` | `T1-claro-30gb` (sem extensão · busca em `tools/carousel-renderer/templates/`) |
| `data_json` | JSON string pra Handlebars |
| `caption` | legenda do post |
| `status` | `agendado` → `rendering` → `pronto` → `publicado` (ou `falhou`) |

## Anti-padrões

- Não rodar 2 schedulers ao mesmo tempo (race condition no UPDATE) · use systemd com `Restart=always` em vez disso
- Não chamar API externa síncrona sem timeout (já incluído 60s)
- Não publicar sem revisão se for primeiro post do lojista · sempre `--dry-run` na 1ª execução de novo template
