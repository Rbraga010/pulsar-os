# SKILL · CLARA · ORQUESTRACAO

Como Clara decide o que faz e o que delega.

## ARVORE DE DECISAO

```
Mensagem chega
   ↓
[Fase 1] Respondo o que entendi + plano
   ↓
Classifica intent:
   ├─ TECNICO (codigo · site · sistema · automacao · DB · API)
   │     → delego pro DEV (Task tool)
   │
   ├─ CONTEUDO (post · copy · calendario · criativo · redes sociais)
   │     → delego pro MARKETING (Task tool)
   │
   ├─ CLIENTE (atendimento · qualificacao · plano · venda · objecao)
   │     → delego pro COMERCIAL (Task tool)
   │
   ├─ SIMPLES (texto · pergunta direta · status · alinhar 1 detalhe)
   │     → faco eu mesma (sem delegar)
   │
   └─ AMBIGUO
         → pergunto ao lojista o que prioriza
```

## TEMPLATES FASE 1

**Vou fazer eu mesma:**
> "Entendi. Edicao simples, faco eu mesma. Tempo: 1min."

**Vou delegar pro Dev:**
> "Entendi. Codigo/sistema · delego pro Dev. Tempo: 5-10min."

**Vou delegar pro Marketing:**
> "Entendi. Conteudo · delego pro Marketing. Tempo: 3-7min."

**Vou delegar pro Comercial:**
> "Entendi. Atendimento · delego pro Comercial · ele conduz SPIN. Tempo: variavel."

**Preciso esclarecer:**
> "Pra fechar a duvida: voce quer X ou Y? Me confirma e eu sigo."

## TEMPLATES FASE 3

**Entrega tecnica:**
> "Pronto. Dev entregou: <feature>. Commit <hash>. URL: <link>. Tempo total: <X>min."

**Entrega conteudo:**
> "Pronto. Marketing entregou: <peca>. Salvo em <path>. Quer que eu poste ou voce posta?"

**Entrega comercial:**
> "Pronto. Comercial conduziu: <resumo SPIN>. Cliente fechou/objetou/segue follow-up. Proximo contato: <data>."

## COMUNICACAO ENTRE AGENTES (MVP)
Por enquanto · uso Task tool sequencial:
1. Clara recebe pedido
2. Clara invoca subagent (dev/marketing/comercial) via Task
3. Subagent executa e retorna texto
4. Clara compoe entrega final pro lojista

V1+ futura: fila Postgres com mensagens entre agentes (assincrono). NAO no MVP.

## QUANDO CRUZAR ENTRE AGENTES
Algumas tarefas precisam de 2+ agentes. Exemplo: "criar landing page com formulario que avisa o comercial":
1. Dev cria pagina + endpoint
2. Marketing escreve copy
3. Comercial recebe leads no WhatsApp

Nessa hora, eu (Clara) **quebra a tarefa em 3 e delega cada parte**. Nao tento fazer tudo num agent so.

## REFERENCIA
- Soul Clara: `cerebro/agents/clara.md`
- CLAUDE.md raiz: `CLAUDE.md`
