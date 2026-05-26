#!/usr/bin/env node
/**
 * scrape-claro.mjs · scrape focado em planos CONTROLE + PRÉ-PAGO Claro.
 * Foco do Pulsar OS pra lojista varejo BR · resto é contexto.
 *
 * Roda semanalmente (cron domingo 6h BRT) ou on-demand.
 *
 * Output: /opt/clones/clara/workspace/cerebro/skills/claro-canon.md
 */

import puppeteer from "/root/pulsarh-war-room/scripts/flavio-google/node_modules/puppeteer-core/lib/esm/puppeteer/puppeteer-core.js";
import { writeFileSync, mkdirSync } from "node:fs";
import { dirname } from "node:path";

const CHROMIUM = "/usr/bin/chromium-browser";
const OUTPUT = "/opt/clones/clara/workspace/cerebro/skills/claro-canon.md";
const RAW_DIR = "/tmp/claro-scrape";

// Rotas FOCADAS · Controle + Pré-pago são prioritárias
const ROTAS = [
  { slug: "controle-30gb", url: "https://meuplanoclaro.com.br/controle/", foco: "CONTROLE" },
  { slug: "prezao", url: "https://meuplanoclaro.com.br/prezao/", foco: "PRE-PAGO" },
  { slug: "flex", url: "https://meuplanoclaro.com.br/flex/", foco: "PRE-PAGO" },
  // Secundários (contexto · sem foco)
  { slug: "pos", url: "https://meuplanoclaro.com.br/pos/", foco: "secundario" },
  { slug: "residencial", url: "https://meuplanoclaro.com.br/residencial/", foco: "secundario" },
  { slug: "box-tv", url: "https://meuplanoclaro.com.br/box-tv/", foco: "secundario" },
];

mkdirSync(RAW_DIR, { recursive: true });

const browser = await puppeteer.launch({
  executablePath: CHROMIUM,
  headless: "new",
  args: ["--no-sandbox", "--disable-setuid-sandbox", "--disable-dev-shm-usage"],
});

const results = [];

for (const r of ROTAS) {
  console.error(`[scrape] ${r.slug} · ${r.url}`);
  try {
    const page = await browser.newPage();
    await page.setUserAgent("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36");
    await page.goto(r.url, { waitUntil: "networkidle2", timeout: 45000 });
    await new Promise((res) => setTimeout(res, 3000));
    // Scroll pra puxar lazy
    await page.evaluate(() => window.scrollTo(0, document.body.scrollHeight));
    await new Promise((res) => setTimeout(res, 2000));
    const html = await page.content();
    const text = await page.evaluate(() => document.body.innerText.replace(/\n{3,}/g, "\n\n"));
    writeFileSync(`${RAW_DIR}/${r.slug}.html`, html);
    writeFileSync(`${RAW_DIR}/${r.slug}.txt`, text);
    results.push({ ...r, text: text.slice(0, 4000) });
    await page.close();
    await new Promise((res) => setTimeout(res, 2000));
  } catch (e) {
    console.error(`[scrape] ERROR ${r.slug}: ${e.message}`);
    results.push({ ...r, text: `ERRO scrape: ${e.message}` });
  }
}

await browser.close();

// Build skill canon · FOCO em controle + pré-pago
const now = new Date().toISOString();
const focoEmReal = results.filter((r) => r.foco === "CONTROLE" || r.foco === "PRE-PAGO");
const secundarios = results.filter((r) => r.foco === "secundario");

const md = `---
slug: claro-canon
title: Catálogo oficial Claro · FOCO controle + pré-pago · fonte de verdade pra todos agentes
category: vendas
agent: all
version: v2.0
scraped_at: ${now}
source: meuplanoclaro.com.br
foco: CONTROLE + PRE-PAGO (resto é contexto)
operador_legal: Vertex/Vertice CNPJ 26.930.573/0001-08
---

# Claro Canon · Fonte de Verdade

## ⭐ FOCO CENTRAL · CONTROLE + PRÉ-PAGO

Pulsar OS prioriza venda de Plano Controle e Pré-pago Claro pelo lojista pequeno BR. Resto (Pós · NET · TV) é contexto secundário · oferece se cliente puxar.

${focoEmReal.map((r) => `

## ${r.slug.toUpperCase()} · ${r.foco}

URL: ${r.url}

\`\`\`
${r.text}
\`\`\`
`).join("\n")}

## 📚 SECUNDÁRIOS (Pós · NET · TV)

Mantidos pra responder pergunta solta do cliente. NÃO é foco de venda do lojista Pulsar OS.

${secundarios.map((r) => `

### ${r.slug} (resumo)

URL: ${r.url}

\`\`\`
${r.text.slice(0, 800)}
\`\`\`
`).join("\n")}

## ⚖️ POLÍTICAS

- **Fidelidade**: Controle 12 meses · Flex/Box TV/Prezão sem fidelidade · Pós e Residencial não declarados publicamente.
- **Pagamento**: Prezão crédito/Pix · Controle débito automático · Flex cartão/débito Caixa/recarga.
- **LGPD**: política cookies via meuplanoclaro.com.br/controle-politica/
- **Operador legal**: Vertex/Vertice CNPJ 26.930.573/0001-08

## 🚫 ANTI-PADRÕES (NUNCA prometer)

1. Não prometer preço que não está nesta skill
2. Não prometer cobertura sem consultar (varia por CEP)
3. Não prometer comissão pro lojista sem confirmar (varia)
4. Não usar promoções expiradas (ex: Flex R$39,90 expirou 2023)
5. Não vender NET Fibra com preço (pendente · só por CEP)
6. Não dizer "ilimitado" sem especificar (todo plano tem fair use)
7. Não comparar diretamente com TIM/Vivo de forma desabonatória
8. Não oferecer Pós sem qualificar perfil (R$120+ não é pra todos)
9. Não usar dados de plano expirado/encerrado
10. Não inventar regra de cobertura local
11. Não prometer portabilidade automática (cliente faz)
12. Não cravar prazo de ativação (depende SVA)
13. Sempre dizer "consultar plano vigente no app Claro" quando dúvida

## 🔄 ATUALIZAÇÃO

- Re-scrape automático: **domingo 6h BRT** via cron \`/opt/clones/clara/workspace/scripts/scrape-claro-weekly.sh\`
- Manual: \`node /opt/clones/clara/workspace/scripts/scrape-claro.mjs\`
- Fonte: meuplanoclaro.com.br (rotas controle · prezao · flex prioritárias)
- Último scrape: ${now}

## 📋 INFO PENDENTE (Rodrigo precisa enviar)

- Preços oficiais Controle 35GB · GeForce
- Multas rescisão por plano
- Programa formal de revenda (comissões · regras pagamento)
- Catálogo NET Fibra completo (preços por velocidade)
- Mapa cobertura por região
- Documentos exigidos por produto
- Ofertas exclusivas CNPJ
- Valor hardware Box TV
- Países do Passaporte Claro
- Catálogo apps Box TV completo

Quando Rodrigo enviar PDFs · atualizar este arquivo manualmente OU rodar parser de PDFs.
`;

writeFileSync(OUTPUT, md);
console.error(`[scrape] DONE · ${OUTPUT} (${md.length} chars · ${md.split("\n").length} linhas)`);
console.error(JSON.stringify({ ok: true, scraped: results.length, output: OUTPUT, ts: now }));
