# Comandos rápidos pra Clara

A Clara entende linguagem natural. Você não precisa decorar comando. Mas se quiser ir direto, esses são os atalhos que ela reconhece bem.

## Vendas · Claro

| O que falar | O que ela faz |
|-------------|---------------|
| "carrossel claro 30gb" | Renderiza 6 slides da oferta âncora · você aprova · ela publica/agenda |
| "carrossel prezão" | Mesma coisa pra Prezão R$ 30 |
| "qual plano pro [perfil]?" | Recomenda 1-2 planos do canon atual (SPIN + perfil) |
| "script pra vender controle" | Te manda SPIN curto pra usar no balcão |

## CRM · Cliente

| O que falar | O que ela faz |
|-------------|---------------|
| "cliente novo [nome] [whatsapp]" | INSERT em `clientes` · pergunta origem (balcão / Insta / indicação) |
| "[nome] comprou [valor]" | UPDATE ticket_total · INSERT em `eventos` · sugere follow-up |
| "quem comprou faz mais de [N] dias?" | Lista de clientes pra reativar |
| "lembra de cobrar [nome] [quando]" | INSERT em `follow_ups` |
| "follow-ups pra hoje" | Lista `v_followups_pendentes` |

## Pix · Cobrança

| O que falar | O que ela faz |
|-------------|---------------|
| "gera pix [valor] [nome do cliente]" | Gera Copia-e-Cola + QR PNG (usando sua chave Pix da memória) |
| "pix sem valor" | Gera Pix em branco (cliente preenche valor) |

## Conteúdo · Insta · WhatsApp · GMB

| O que falar | O que ela faz |
|-------------|---------------|
| "agenda esse carrossel pra [dia] [hora]" | INSERT em `posts_agendados` · scheduler publica na hora |
| "calendário dessa semana" | Lista `v_posts_proximos` |
| "publica no insta" | Invoca `ig-graph` (precisa OAuth feito) |
| "status whatsapp [imagem]" | Posta no Status WA (precisa pareamento feito) |
| "responde os reviews do google" | Lista reviews · gera resposta no seu tom · pede aprovação · responde |

## Panfleto · OCR

| O que falar | O que ela faz |
|-------------|---------------|
| (manda foto sem texto) | Roda OCR · compara com oferta sua · sugere contra-oferta |
| "lê esse panfleto da [concorrente]" + foto | Mesma coisa + análise específica |

## Memória · Loja

| O que falar | O que ela faz |
|-------------|---------------|
| "atualiza meu whatsapp pra [novo]" | UPDATE `lojista.whatsapp` |
| "minha chave pix agora é [X]" | UPDATE `lojista.chave_pix` |
| "endereço da loja mudou pra [X]" | UPDATE `lojista.endereco` |
| "mostra meu cadastro" | Mostra resumo do `lojista` table |

## Sanidade · Humano

| O que falar | O que ela faz |
|-------------|---------------|
| "tô cansado" / "semana puxada" | Acolhe · zero tarefa · pergunta natural |
| "[familiar] aniversário em [data]" | Salva na memória · vai te lembrar quando chegar |
| "dormi mal" | Adapta tom · prioridades só do essencial naquela conversa |

## Sistema

| O que falar | O que ela faz |
|-------------|---------------|
| "status da clara" | Mostra: sessão ativa · DB ok · tools ok · WhatsApp pareado sim/não · IG conectado sim/não |
| "logs últimas horas" | Resumo das atividades dela hoje |
| "memória do que aprendeu" | Lista os últimos itens salvos na memória |

## Anti-comandos (ela não faz mesmo se você pedir)

- Mandar SPAM em massa pelo WhatsApp (limita 50/dia, delay humano)
- Postar sem você aprovar (sempre pede confirmação no 1º uso de template novo)
- Decidir contrato/venda grande sozinha (te pergunta primeiro)
- Compartilhar dado seu com qualquer um fora da sua VPS
