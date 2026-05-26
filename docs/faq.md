# FAQ · Clara · Pulsar OS

## Geral

### A Clara é uma IA?
É um sistema que usa modelo de linguagem (Claude). Pra você ela é UMA pessoa: sua sócia silenciosa. Tecnicamente, ela orquestra 3 sub-agents internos (Dev, Marketing, Comercial), mas você nunca precisa saber disso.

### É de graça?
Sim, o software. Você só paga o uso do modelo (Claude · uns trocados por mês · vai depender de quanto conversa com ela). Zero mensalidade pra mim.

### Roda onde?
Na sua VPS. Tudo isolado. Sua memória, suas conversas, seu CRM, seus posts ficam na SUA máquina. Zero cloud externo.

### Meus dados ficam seguros?
- Tudo local na sua VPS
- Banco SQLite ali no diretório
- Zero envio pra terceiros
- Token do Telegram fica no `.env` (não exposto)
- WhatsApp pareado via Baileys (mesmo método dos clones oficiais)

## Setup

### Quanto tempo demora pra rodar?
- Bot Telegram: 5 minutos (token + chat ID)
- Conexão WhatsApp: +5 minutos (escanear QR no celular)
- Instagram OAuth: +30-60 minutos (criar app no Facebook · obter token)
- Google Meu Negócio: +1-5 dias (esperar aprovação Google)

Vendas Claro + carrossel + Pix funcionam de cara, sem setup adicional.

### Preciso de VPS própria?
Sim. A Clara é self-hosted. Se você não tem VPS, recomendamos Hetzner (€4/mês) ou Contabo (€5/mês).

### Quanto custa por mês mesmo?
- VPS: €4-5
- Claude API: ~$10-30/mês (varia uso · mensagem leve = poucos centavos)
- Domínio (opcional): R$ 40/ano
Total: R$ 80-200/mês dependendo de uso.

## Uso diário

### Quantas mensagens posso mandar por dia?
Sem limite técnico. Limite prático é o custo de token. Conversa normal (20-50 mensagens/dia) custa < R$ 1/dia.

### Ela trabalha 24h?
Sim, fica online. Mas ela não te incomoda fora do horário comercial a não ser que você programe.

### Ela aprende com o tempo?
Sim. A cada conversa, ela atualiza a memória do dono (`memory/dono.md`), da loja, dos clientes, das metas. Próxima conversa começa do ponto que parou.

### Posso ter mais de uma Clara?
Sim. Cada VPS = 1 Clara = 1 lojista. Multi-tenancy não é compartilhado (zero risco de cruzar dados).

## Recursos

### Quais tools ela tem?
Hoje (v0.1):
1. carousel-renderer (Instagram 1080x1350)
2. ocr-panfleto (Tesseract)
3. pix-qr (BR Code BACEN)
4. whatsapp-baileys (envia · status · stub)
5. ig-graph (publica Insta · stub OAuth)
6. gmb (Google Meu Negócio · stub OAuth)
7. scheduler (calendário editorial)
8. db (SQLite local · CRM)

Roadmap (v0.2):
- Catálogo público (vitrine HTML estática)
- Etiquetas WhatsApp Business automatizadas
- Reels Remotion (vídeo curto)
- Stories interativos (enquetes · cta)

### Posso adicionar tool minha?
Sim. Cria `tools/<nome>/`, README + invocação Bash. Adiciona linha em `cerebro/skills/clara-tools.md`. Clara passa a invocar.

### Funciona sem internet?
Não 100%. Tesseract OCR, Pix QR, DB SQLite funcionam offline. Mas Claude API (cérebro) precisa internet. E claro Instagram/WhatsApp/GMB precisam internet.

## Problemas comuns

### Ela não responde
1. Checa systemctl: `systemctl status clone-clara-telegram-bot.service`
2. Reinicia: `systemctl restart clone-clara-telegram-bot.service`
3. Logs: `tail -50 /opt/clones/clara/bot/logs/bot.log`

Se persistir, abre issue no GitHub com snippet do log.

### Carrossel sai feio · texto cortado
- Copy muito longo no JSON · reduzir
- Ou criar template novo com tamanho de fonte ajustado
- Templates vivem em `tools/carousel-renderer/templates/`

### WhatsApp desconecta sozinho
- Sessão Baileys expira eventualmente
- Re-pareia: `node tools/whatsapp-baileys/pair.js`
- Não automatiza esse pareamento (não é seguro)

### Instagram dá erro ao publicar
- Token Page Access expira em 60 dias
- Renovar via Facebook Developer
- Pôr o novo no `.env` · reiniciar Clara

### Não posso publicar GMB
- API requer aprovação Google (até 5 dias úteis)
- Form: https://developers.google.com/my-business/content/prereqs
- Enquanto não aprovado · use GMB no app/web manualmente

## Negócio

### Posso usar pra mais de uma loja?
Cada loja = 1 instância Clara = 1 VPS = 1 install. Multi-loja exige multi-VPS (ou containers separados na mesma VPS). Cross-contamination = zero.

### Posso revender Clara pra outros lojistas?
Sim · open source. Mas o cliente é seu, não nosso. Você instala na VPS dele, configura, cobra como achar melhor. PulsarH não cobra royalty.

### Garantia de quanto vou faturar a mais?
Zero. Ferramenta é ferramenta. Quem vende é você. A Clara só remove obstáculos (tempo, processo, conteúdo manual). O esforço comercial é seu.

Mas: lojistas mentorados Pulsar reportam +20-40% follow-up sucedido após 30 dias usando.

### A Clara conhece meu produto/serviço?
No início, não. Ela aprende durante onboarding e ao longo das conversas. Pra acelerar, conta tudo da loja no primeiro contato: produtos, ticket, perfil de cliente, sazonalidade.

## Suporte

### Onde reportar bug?
GitHub Issues: https://github.com/Rbraga010/pulsar-os/issues

### Onde sugerir feature?
Mesmo lugar · com label `enhancement`.

### Tem grupo de mentorados?
Sim. Acesso liberado por Rodrigo via Zoom (mentoria mensal).
