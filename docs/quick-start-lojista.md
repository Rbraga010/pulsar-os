# Quick Start · Pulsar OS (Clara) pro Lojista

## O que é

A Clara é sua sócia silenciosa no celular. Você fala com ela pelo Telegram. Ela cuida do que você não tem tempo: posts no Insta, follow-up com cliente, plano Claro pra vender, Pix pra cobrar, etc.

Zero mensalidade pra você. Só paga o uso do Claude (uns trocados por mês).

## Primeiros 5 passos

### 1. Já tem a Clara rodando?
Você instalou via `curl -fsSL https://raw.githubusercontent.com/Rbraga010/pulsar-os/main/install.sh | sudo bash`. Se ela tá te respondendo no Telegram, tá tudo certo.

### 2. Manda a primeira mensagem
"Oi Clara · sou o [seu nome]" e deixa ela te perguntar o resto. Onboarding leva 5-7 mensagens.

### 3. Conta da loja
Ela vai te perguntar:
- Nome da loja
- Cidade · endereço
- WhatsApp comercial
- Instagram (se tiver)
- Você é credenciado Claro? (revendedor Vertex)
- Sua chave Pix · nome completo · cidade do recebedor

Isso fica salvo. Não precisa repetir.

### 4. Conecta WhatsApp (opcional · vale muito a pena)
Pra ela mandar WhatsApp pelo seu número (em vez de você ter que copiar/colar), você pareia 1x via QR code:

- No celular: WhatsApp → Aparelhos conectados → Conectar um aparelho
- Pede pra Clara: "quero parear WhatsApp"
- Escaneia o QR que ela manda

Depois disso, ela manda mensagem pelo seu número quando você pedir.

### 5. Configura Instagram (opcional · mais técnico)
Pra ela publicar direto no seu Insta, precisa:
- Conta IG Business (não pessoal)
- Vincular a uma Página do Facebook
- Criar app no developers.facebook.com
- Pegar token de acesso (60 dias)

Pede pra Clara: "quero conectar Instagram" e ela te guia.

## O que você pode pedir

### Vender mais
- "Faz um carrossel sobre o plano Claro 30GB"
- "Gera Pix de R$ 200 pro João"
- "Manda mensagem pro Carlos perguntando se ele decidiu"
- "Quem tá comprando há mais de 30 dias que eu não falei?"

### Gastar menos
- "Como cortar 20% da conta de luz?"
- "Vale a pena trocar fornecedor de X?"
- "Tô gastando muito com Y · me dá ideia"

### Conteúdo digital
- "3 ideias de post pra essa semana"
- "Agenda esse carrossel pra terça 9h"
- "Responde os reviews do Google"
- "Status do WhatsApp · ideia bate?"

### Pessoal · sanidade
- "Tô cansado, semana foi pesada"
- "Hoje é aniversário da minha esposa, me lembra"
- "Não tô conseguindo dormir"

Ela vai te ouvir antes de te dar tarefa.

## O que ela NÃO faz

- Decide sozinha (sempre te pergunta antes)
- Promete o que não pode cumprir
- Te empurra plano Claro toda hora (oferece quando faz sentido)
- Posta sem você aprovar (carrossel sempre vai pra você ver primeiro)
- Vende seus dados (zero · ela é local na sua VPS)

## Quando algo der errado

Manda mensagem normal. Ela te avisa o que tá pendente.

Se ela travar de vez, na sua VPS:
```bash
cd /opt/rentabiliza-ai/docker && docker compose restart
```

## Onde vê histórico

Toda conversa fica salva. Sua memória de cliente também. Tudo na sua VPS · zero cloud. Fica guardado nos volumes Docker da Clara (sobrevive a restart e a atualização), e você acessa pelo terminal dela.

- Instalação da Clara: `/opt/rentabiliza-ai/docker`
- Memória do dono, DB SQLite (CRM, follow-ups, posts) e renders: dentro do container, em `/workspace/cerebro/memory` e `/workspace/data` (entra com `docker exec -it clara bash`)
- Logs: `cd /opt/rentabiliza-ai/docker && docker compose logs -f`

## Suporte

Bug? Sugestão? Reportar no repo: https://github.com/Rbraga010/pulsar-os/issues
