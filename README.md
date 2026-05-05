# Pulsar OS v1.0

> *Instituto operacional de IA dentro da sua empresa. Em 90 minutos.*

Você acabou de comprar a estrutura organizacional inteira de uma empresa amplificada por IA: **CEO digital + Secretária Executiva + 6 Vice-Presidentes + ~25 heads especializados**. Tudo conectado ao seu Telegram. Tudo rodando no seu servidor.

---

## 3 caminhos para começar

### `01 · estou empolgado, quero rodar agora`

```bash
unzip pulsar-os-v1.0.0.zip && cd pulsar-os-v1.0.0/
bash installer/install.sh
```

A instalação leva 12-18 min. Quando terminar, você cola um único prompt no Claude Code e o **Pulse** te chama no Telegram.

### `02 · quero entender antes de instalar`

Leia, nesta ordem:

1. **[`docs/JORNADA.md`](docs/JORNADA.md)** — as 9 etapas que o Pulse vai conduzir com você (90 min)
2. **[`installer/README.md`](installer/README.md)** — pré-requisitos detalhados e o que o instalador faz
3. **[`docs/ESTRUTURA.md`](docs/ESTRUTURA.md)** — `core/` vs `tenant/` (o que atualiza, o que é seu)
4. **[`GARANTIA.md`](GARANTIA.md)** — 7 dias para validar, reembolso 100% se Pulse não despertar

### `03 · prefiro com apoio na instalação (R$ 1.297)`

Manda email para `rodrigo@pulsarh.ai` com assunto **"PULSAR OS — QUERO BUMP"** e o comprovante da compra. Em até 24h um operador do instituto agenda uma sessão de 60min com você na frente do computador. Ele instala, você só responde a entrevista do Pulse. **Tudo rodando ao final da call.**

---

## O que você precisa antes de instalar

| Item | Para quê | Como obter |
|---|---|---|
| **VPS Linux** Ubuntu 22+ root SSH | Casa do instituto | Hostinger, DigitalOcean, Hetzner — mín. 2GB RAM, 5GB disco |
| **Claude Code** instalado na VPS | Cérebro dos agentes | [docs.anthropic.com/claude-code](https://docs.anthropic.com/claude-code) |
| **Assinatura Claude Max** | Combustível | [anthropic.com/pricing](https://www.anthropic.com/pricing) |
| **Conta Vercel** | Sobe seu War Room | [vercel.com](https://vercel.com) — anota o email exato |
| **Domínio** com DNS apontando pra IP da VPS | URL do War Room | Registro.br, Cloudflare |
| **2 bots Telegram** | Pulse + Donna falam com você | Vamos criar juntos no passo 3 do install |

> *Se você não tem essa stack, considere o caminho 03 (R$1.297 com apoio) — vamos montar tudo junto.*

---

## A jornada de instalação (~90 min · você na frente)

```
0  PULSE BOAS-VINDAS                            ~5 min
   Pulse se apresenta · mostra organograma     
   explica a ordem de nascimento dos agentes

1  SIMON NASCE PRIMEIRO  ──  RH e Cultura      ~15 min
   Pulse pergunta: nome empresa · founder      
   setor · tom da cultura · vocabulário        
   → Simon herda identidade da empresa
   → Os outros 7 VPs vão herdar de Simon

2  FALCONI + WAR ROOM  ──  Operações           ~20 min
   Provisiona Postgres · sobe War Room        
   no seu domínio · MCP Server                 
   → Telegram bots conectados

3  PROJETO ZERO  ──  Levantar a empresa        ~10 min
   Pulse pergunta: faturamento atual           
   meta 90 dias · principais bloqueios         
   → Cria projeto SMART no War Room

4  FLÁVIA  ──  Produtos                        ~8 min
   Catálogo · tickets · margens

5  ALFREDO  ──  Marketing                      ~10 min
   Brand kit · ICP · voz da marca

6  CAIO  ──  Comercial                         ~8 min
   Hunter ICP · playbook de fechamento

7  DALIO  ──  Financeiro                       ~7 min
   DRE · KPIs · alertas de margem
   → Conecta às metas do Projeto ZERO

8  DONNA  ──  Chefe de Gabinete                ~5 min
   Nasce por último · vê o time inteiro       
   → Vira o filtro entre você e o caos

9  PRIMEIRA TAREFA REAL                        ~5 min
   Pulse executa algo de verdade               
   → Manda Telegram: "Sua operação tá no ar"
```

---

## Estrutura do zip

```
pulsar-os-v1.0.0/
├── README.md             ← você está aqui
├── GARANTIA.md           ← 7 dias para validar, reembolso 100%
├── LICENSE.md            ← 1 empresa por compra, sem revenda
├── installer/            ← scripts de instalação (não modifique)
│   ├── install.sh        ← entrypoint
│   ├── README.md         ← detalhes técnicos
│   └── lib/              ← preflight, postgres, vercel, mcp, tenant
├── core/                 ← atualiza via `git pull`. NÃO modifique.
│   ├── agents-template/  ← os 8 SOULs (Pulseh, Donna, Alfredo, ...)
│   ├── skills-template/  ← skills genéricas (~22)
│   ├── onboarding/       ← welcome, entrevista, apresentação
│   └── bootstrap/        ← prompt que desperta o Pulse
└── tenant/               ← seu território. Pulse escreve aqui.
    └── (vazio até a instalação)
```

**Regra de ouro:** mexa só em `tenant/`. `core/` é atualizado via `git pull` futuro.

---

## Pulse não despertou? Não funcionou?

1. **Releia `installer/README.md`** — a maioria dos problemas é pré-requisito faltando (Claude Max sem Max, DNS não propagado, Vercel email errado)
2. **Cheque `tenant/.install-state`** — diz exatamente em que passo travou
3. **Comunidade DIY**: [link Discord]
4. **Garantia ativa**: leia [`GARANTIA.md`](GARANTIA.md). 7 dias para validar.
5. **Quer apoio agora**: email `rodrigo@pulsarh.ai` assunto **"PULSAR OS — QUERO BUMP"** (R$1.297). Em até 24h alguém te chama.

---

## Atualizações futuras

Quando sair Pulsar OS v1.x:

```bash
cd ~/pulsar-os
git pull origin main
bash installer/upgrade.sh
```

Apenas `core/` é atualizado. Tudo em `tenant/` (sua identidade, conversas, histórico) permanece intocado.

---

## Licença

1 empresa por compra. Sem revenda. Sem white-label. Detalhes em [`LICENSE.md`](LICENSE.md).

---

> *Pulsar não vende, ilumina.*
>
> **— construído pelo instituto pulsarh.ai · com curadoria humana e amplificação por IA**
