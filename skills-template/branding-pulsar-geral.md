---
slug: branding-pulsar-geral
title: Branding {{tenant.empresa.nome}} — Manifesto, Arquitetura, Voz da Marca
category: reference
agent: alfredo
sortOrder: 2
version: 1.0-template
---

# Branding — Esqueleto Universal

> **Como funciona:** este e o ESQUELETO core do Pulsar OS. Manifesto, ICPs, vozes, vocabulario sao slots `{{tenant.X}}` preenchidos pelo Pulse no onboarding. Nada PulsarH-especifico aqui.
>
> Para inspiracao, peca ao Pulse exemplos preenchidos durante o onboarding.

---

## REGRAS INVIOLAVEIS DE COPY DE LP (universais — diagnostico Jonathan/Avalanche, mantidas como core)

Aplicar em TODA copy de LP/VSL/manifesto/awareness:

1. **UMA persona-mae por LP.** Nunca dois caminhos visiveis no hero conectados por "ou". Unificar por identidade (dentro), nao por badge (fora).
2. **Acentuacao PT-BR completa.** Sem excecao. Title, meta, OG, body, badges, botoes, FAQ, footer.
3. **Sujeito = leitor.** "Voce ja sabe..." > "A formacao prepara o profissional...". Inverter sujeito e 70% do trabalho.
4. **Filtro negativo cirurgico.** Vem DEPOIS da promessa, nao contradiz avatar convidado antes.
5. **Ordem: dor → promessa → prova → oferta → curriculo → garantia → CTA.** Curriculo NUNCA vende, so tranquiliza.
6. **Prova social obrigatoria.** Numeros do mentor + depoimentos de turma anterior + screenshot. Sem isso ticket >R$1k nao converte.
7. **NUNCA "consultor"** em CTA/copy. Use nome humano ou "atendimento". CTA primario sempre com PRECO pra ticket direto.
8. **Zero travessao longo (—).** Trocar por ponto, virgula ou parenteses.
9. **Nomes vendaveis nos modulos.** Beneficio > numeracao seca.
10. **Urgencia REAL e datada.** Vagas restantes + data fechamento + proxima turma.

---

## 01 · A TESE — manifesto da casa

Pulse co-cria com o Founder no onboarding. Estrutura padrao em 3 atos:

> {{tenant.brand.tese.frase_1}}
> {{tenant.brand.tese.frase_2}}
> {{tenant.brand.tese.frase_3}}

Em seguida, 2-3 paragrafos que explicam o "porque agora", a dor real do mercado, e o que so esta marca resolve.

**Fechamento da tese:** {{tenant.empresa.nome}} existe pra resolver {{tenant.brand.problema_resolvido}}. Como {{tenant.brand.modelo_entrega}} (curso, mentoria, produto, servico instalado, etc).

---

## 02 · A FORMULA — sistema operacional da marca

Toda marca forte tem uma formula nomeada que explica o jeito de fazer. Ex: "PULSAR+H = PULSAR (gestao) + H (humanizacao) + AI (acelerador)".

**Formula da casa:** {{tenant.brand.formula}}

**Camadas da formula:**
- {{tenant.brand.camada_1}}
- {{tenant.brand.camada_2}}
- {{tenant.brand.camada_3}}

> **Regra inviolavel:** toda peca (post, LP, ad, email) tem que aterrar a formula. Conceito sem ROI ancorado nao converte. Resultado tem que cair no bolso do cliente.

---

## 03 · ICPs OFICIAIS

> **REGRA DE OURO:** Maximo 2 avatares amplos. Subsets so existem pra peca de funil cold (IG/email nicho). NUNCA inventa avatar — Pulse pergunta e o Founder valida.

### Avatar primario
**{{tenant.icp.primary.nome}}** — {{tenant.icp.primary.descricao}}
- Faixa etaria: {{tenant.icp.primary.idade}}
- Faixa de receita: {{tenant.icp.primary.receita}}
- Dor primaria: {{tenant.icp.primary.dor}}
- O que a casa entrega: {{tenant.icp.primary.entrega}}
- Vocabulario que ele usa: {{tenant.icp.primary.vocab}}

### Avatar secundario
**{{tenant.icp.secondary.nome}}** — {{tenant.icp.secondary.descricao}}
- Faixa etaria: {{tenant.icp.secondary.idade}}
- Faixa de receita: {{tenant.icp.secondary.receita}}
- Dor primaria: {{tenant.icp.secondary.dor}}
- O que a casa entrega: {{tenant.icp.secondary.entrega}}
- Vocabulario que ele usa: {{tenant.icp.secondary.vocab}}

### Subsets cold (uso restrito)
{{tenant.icp.subsets}}

> **Frase proibida em qualquer copy:** {{tenant.brand.frases_proibidas}}

---

## 04 · VOZ DA MARCA

**Tom:** {{tenant.brand.voz.tom}}
**Pace:** {{tenant.brand.voz.pace}}
**Postura:** {{tenant.brand.voz.postura}}

**Faz:**
- {{tenant.brand.voz.faz_1}}
- {{tenant.brand.voz.faz_2}}
- {{tenant.brand.voz.faz_3}}

**Nao faz:**
- {{tenant.brand.voz.nao_faz_1}}
- {{tenant.brand.voz.nao_faz_2}}
- {{tenant.brand.voz.nao_faz_3}}

---

## 05 · VOCABULARIO PROPRIO

Toda marca forte tem 5-15 palavras que nao se troca. Sao identidade.

| Use | Em vez de |
|---|---|
| {{tenant.brand.vocab.use_1}} | {{tenant.brand.vocab.evita_1}} |
| {{tenant.brand.vocab.use_2}} | {{tenant.brand.vocab.evita_2}} |
| {{tenant.brand.vocab.use_3}} | {{tenant.brand.vocab.evita_3}} |
| {{tenant.brand.vocab.use_4}} | {{tenant.brand.vocab.evita_4}} |
| {{tenant.brand.vocab.use_5}} | {{tenant.brand.vocab.evita_5}} |

---

## 06 · ESTEIRA DE PRODUTOS

| Nivel | Produto | Preco | Promessa |
|---|---|---|---|
| Gratis / atrativo | {{tenant.produtos.gratis}} | R$0 | {{tenant.produtos.gratis_promessa}} |
| Entrada | {{tenant.produtos.entrada}} | {{tenant.produtos.entrada_preco}} | {{tenant.produtos.entrada_promessa}} |
| Core | {{tenant.produtos.principal}} | {{tenant.produtos.principal_preco}} | {{tenant.produtos.principal_promessa}} |
| High-ticket | {{tenant.produtos.high}} | {{tenant.produtos.high_preco}} | {{tenant.produtos.high_promessa}} |

---

## 07 · IDENTIDADE VISUAL

A identidade visual core (paleta, tipografia, sistema) e definida pelo Brand v1.0 Half-Light do Pulsar OS — assinatura do produto.

O que varia por tenant:
- Logo da marca: `tenant/public/logo.svg`
- Foto do Founder pra CTAs: `tenant/public/founder-cta.jpg`
- Eventuais cores secundarias do cliente: `tenant/brand/accent.json`

> Brand v1.0 Half-Light NUNCA e modificado — se o tenant quiser identidade radicalmente diferente, esse e um tema pro Founder + Pulse decidirem fora do produto.

---

## 08 · ATIVACAO INTERNA

Quem na hierarquia carrega a marca em cada peca:
- **Pulseh (CEO):** garante que toda decisao de comunicacao passa pelo filtro tese.
- **Donna (Secretaria):** garante consistencia de tom em mensagens curtas (Telegram, email triagem).
- **Alfredo (VP Comercial):** dono do funil — Betina (copy), Mauricio (design), Leo Dias (intel) executam.
- **Simon (VP People):** garante que o Founder e o time falam com a mesma voz por dentro.

---

## 09 · CHECKLIST DE PECA (toda copy passa por isso)

- [ ] Tese da casa aterrada na peca?
- [ ] Avatar unico identificado e nomeado?
- [ ] Voz da marca respeitada (tom, pace, postura)?
- [ ] Vocabulario proprio usado (nao terms genericos)?
- [ ] CTA com preco e urgencia datada?
- [ ] Brand v1.0 Half-Light respeitado (paleta, tipografia, dourado e evento)?
- [ ] Sem frases proibidas?
- [ ] Prova social obrigatoria presente (se ticket >R$1k)?

---

> **Fontes do tenant para popular este esqueleto:** `tenant/manifesto.md`, `tenant/icp.json`, `tenant/brand/voz.md`, `tenant/produtos/catalogo.json`. Pulse coleta tudo na entrevista 10-etapas via Telegram.
