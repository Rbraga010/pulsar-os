# Pulsar OS · Clara

**Sua sócia agêntica que rentabiliza a sua loja · vender mais e gastar menos do produto que você já vende · com ÊNFASE em Plano Controle Claro como alavanca extra de receita.**

Pulsar OS distribui a **Clara** · uma sócia que mora no seu Telegram e cuida do corre completo da sua loja:

- **Vende mais o produto que você JÁ vende** (roupa, calçado, padaria, autopeças, o que for) · carrossel, reel, follow-up, presença digital
- **Faz você gastar menos** · negociação, corte de gordura, fornecedor
- **Tem ênfase brutal em Plano Controle Claro** · scripts, campanhas, material de venda, calculadora de economia, argumentos Ookla 2026 · alavanca de receita recorrente de alta margem
- **Tira a parte chata de cima de você** · Pix Copia-e-Cola, follow-up WhatsApp, post no GMB, resposta de review

Hierarquia: **loja primeiro** · Controle Claro segundo (mas com ênfase brutal). A Clara nunca esquece que a loja é SUA · Claro é receita extra fortíssima · não substituto.

Zero mensalidade pra você. Você usa sua conta de **Claude Max** ou **ChatGPT Plus/Pro** que já paga · custo zero adicional.

---

## Instalar em 1 comando

```bash
curl -fsSL https://raw.githubusercontent.com/Rbraga010/pulsar-os/main/install.sh | sudo bash
```

O wizard pede só 3 coisas:
1. Token do bot Telegram (1 min no `@BotFather`)
2. Seu chat_id (1 min no `@userinfobot`)
3. Sua região Claro (pra puxar o book de varejo certo)

Depois:
1. Pull da imagem (1-2 min · `ghcr.io/rbraga010/clara:latest`)
2. `docker exec -it clara claude login` (1x · OAuth Claude Max)
3. Abre Telegram · manda "oi Clara" · onboarding começa

**Pré-requisitos (produção):** VPS Linux (Ubuntu/Debian/Fedora). 2GB RAM. Root. Por que VPS? Clara precisa estar ativa **24/7** pra responder cliente · notebook que desliga = Clara dorme. VPS na Hetzner/Digital Ocean/Vultr custa ~R$ 30/mês.

> 💡 **Quer testar antes de comprar VPS?** Funciona em Mac e Windows também via Docker Desktop · ver [docs/teste-mac-windows.md](docs/teste-mac-windows.md). Lembra: Clara só responde enquanto o computador estiver ligado.

---

## O que a Clara faz

### Vender mais o produto da sua loja (prioridade 1)
- Carrossel/reel/panfleto do que você quer empurrar essa semana
- Follow-up de cliente que entrou e não fechou
- Presença digital constante (Instagram, GMB, WhatsApp Status)
- Calendário editorial automático (post agendado roda sozinho)
- OCR de panfleto da concorrência (Tesseract · você manda foto, ela lê)
- Resposta automática de review no Google (no seu tom · depois de você aprovar)

### Vender mais Plano Controle Claro (ênfase brutal)
- Conhece os planos vigentes (book oficial varejo 13/05/2026 + scrape semanal Vertex)
- Faz SPIN simplificado pra qualificar prospect
- Monta carrossel do plano com calculadora de economia (R$ 343,40 streamings avulsos vs R$ 134,90 no Box)
- Roteiro de abordagem WhatsApp pra portabilidade · upgrade · combo Multi
- Argumentos Ookla 2026: 5G mais rápido · Wi-Fi mais rápido · 5G iPhone
- Identifica cliente do balcão como potencial Controle e te avisa

### Operação do dia a dia (tira a parte chata)
- Gera Pix Copia-e-Cola + QR Code (BACEN · 0 taxa)
- Manda WhatsApp em seu nome (após você aprovar)
- Agenda post (scheduler em systemd · roda 24/7)
- CRM SQLite local: quem comprou, quando, o que · pra você nunca perder cliente

### Conteúdo digital
- Carrossel 6 slides (Instagram 1080x1350) renderizado em PNG
- Reel 1080x1920 15s (Remotion · 100% local)
- Imagem por prompt (Imagen 4 grátis · API key opcional)
- Áudio TTS PT-BR feminino (Google TTS 4M chars/mês grátis · OpenAI fallback)
- OCR de panfleto da concorrência (Tesseract)

### Pessoal · sanidade
- Lembra dos filhos · cônjuge · datas importantes
- Acolhe cansaço antes de empurrar tarefa
- Te puxa pra rotina saudável (família > venda)

---

## Arquitetura

```
sua VPS
├── docker compose
│   └── clara container
│       ├── Claude CLI ou Codex CLI (o "cérebro")
│       ├── Plugin Telegram nativo do Claude (canal de comunicação)
│       ├── workspace/cerebro/skills/* (especialista Claro · personas · tools)
│       ├── workspace/data/claro-docs/ (book oficial varejo · PDF)
│       └── workspace/tools/* (carrossel · Pix · WhatsApp · IG · GMB · scheduler)
└── volumes persistentes
    ├── /root/.claude (sessão login · sobrevive a restart)
    ├── /workspace/cerebro/memory (dono · loja · metas · histórico)
    └── /workspace/data (DB SQLite · renders · book Claro)
```

### Skills da Clara (cérebro especialista Claro)
- `claro-canon.md` · catálogo Claro · fonte de verdade · book oficial 13/05/2026 + scrape semanal Vertex
- `comercial-spin-claro.md` · SPIN simplificado pra venda Claro
- `comercial-planos-claro.md` · catálogo planos + objeções comuns
- `clara-comportamento.md` · voz · formato · 18 regras (sócia, não bot)
- `clara-orquestracao.md` · árvore de decisão intent → tool
- `clara-onboarding.md` · 4 perguntas obrigatórias (apelido · loja · família · rotina)
- `clara-tools.md` · mapa das 13 ferramentas locais
- `clara-seguranca.md` · LGPD · guard rails · TABU
- `clara-memoria-cliente.md` · padrão CRM cliente

### Cérebro de inteligência (você escolhe na instalação)
- **Claude Max** (Anthropic) · recomendado · você já paga · login `claude login`
- **Codex** (OpenAI ChatGPT Plus/Pro) · alternativa · login `codex login`

### APIs auxiliares opcionais
Só preenche quando for usar (tudo grátis em tier inicial):
- `GOOGLE_AI_API_KEY` · gerar imagem (Imagen 4)
- `GOOGLE_APPLICATION_CREDENTIALS` ou `OPENAI_API_KEY` · TTS (áudio)
- `BRAVE_SEARCH_API_KEY` · busca premium (DuckDuckGo grátis sem)
- Google OAuth · Calendar + Gmail

Detalhes: `workspace/cerebro/skills/clara-tools-setup.md` (dentro do container).

---

## Comandos do dia a dia

| Ação | Comando |
|---|---|
| Ver se tá rodando | `cd /opt/pulsar-os/docker && docker compose ps` |
| Logs em tempo real | `cd /opt/pulsar-os/docker && docker compose logs -f` |
| Reiniciar | `cd /opt/pulsar-os/docker && docker compose restart` |
| Parar | `cd /opt/pulsar-os/docker && docker compose down` |
| Atualizar versão | `cd /opt/pulsar-os/docker && docker compose pull && docker compose up -d` |
| Terminal da Clara | `docker exec -it clara bash` |

---

## Documentação

- `docs/quick-start-lojista.md` · primeiros passos do lojista
- `docs/comandos-clara.md` · o que pedir pra Clara
- `docs/faq.md` · perguntas frequentes
- `docker/README.md` · instalação manual passo a passo (sem wizard)

---

## Licença

Ver `LICENSE.md`.

## Suporte

Bug, sugestão ou pedido de feature: https://github.com/Rbraga010/pulsar-os/issues
