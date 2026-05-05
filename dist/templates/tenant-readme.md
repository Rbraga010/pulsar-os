# /tenant — território da sua empresa

Esta pasta é seu território. O Pulse escreve aqui durante o ritual de onboarding e ao longo da operação:

- `onboarding-answers.json` — suas 12-13 respostas da entrevista
- `CLAUDE.md` — instruções operacionais finais geradas pra sua empresa (renderizada a partir do template em /core/)
- `agents-config.json` — configuração final dos agentes (override do default)
- `backlog-onboarding.md` — pendências e próximas missões
- `.env.local` — variáveis específicas do seu tenant
- `brand/` (opcional) — overrides visuais (logo, cores extras). Paleta base, tipografia e vórtice permanecem invioláveis.

**Não copie estes arquivos pra outro lugar — o Pulse precisa achar tudo aqui.**

`git pull` em /core/ não toca em /tenant/.

## Backup

Periodicamente:

```
pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB" > tenant/backup-db-$(date +%Y%m%d).sql
# Variaveis vem de /tenant/.env.local
tar -czf tenant-backup-$(date +%Y%m%d).tar.gz tenant/
```

Guarde em local externo (S3, Drive, disco separado).
