#!/usr/bin/env node
/**
 * Clara · Carousel Renderer
 * CLI: node render.js <template.html> <data.json> <out-dir>
 *
 * Renderiza um arquivo HTML contendo N <section class="slide"> num conjunto
 * de PNGs 1080x1350 (formato Instagram retrato).
 *
 * Dependências: handlebars (compilação) + puppeteer-core (screenshot via
 * Chromium do sistema · zero download de chromium).
 *
 * Princípio: gratuito · local · auditável · zero serviço externo.
 */

const fs = require('fs');
const path = require('path');
const handlebars = require('handlebars');
const puppeteer = require('puppeteer-core');

const SLIDE_W = 1080;
const SLIDE_H = 1350;

const CHROMIUM_CANDIDATES = [
  process.env.PUPPETEER_EXECUTABLE_PATH,
  '/usr/bin/chromium-browser',
  '/usr/bin/chromium',
  '/usr/bin/google-chrome',
  '/snap/bin/chromium',
].filter(Boolean);

function resolveChromium() {
  for (const c of CHROMIUM_CANDIDATES) {
    if (fs.existsSync(c)) return c;
  }
  throw new Error(
    'Chromium não encontrado. Defina PUPPETEER_EXECUTABLE_PATH ou instale chromium-browser.'
  );
}

async function main() {
  const [templatePath, dataPath, outDir] = process.argv.slice(2);

  if (!templatePath || !dataPath || !outDir) {
    console.error('Uso: node render.js <template.html> <data.json> <out-dir>');
    process.exit(2);
  }

  if (!fs.existsSync(templatePath)) {
    console.error(`Template não encontrado: ${templatePath}`);
    process.exit(3);
  }
  if (!fs.existsSync(dataPath)) {
    console.error(`Data não encontrado: ${dataPath}`);
    process.exit(3);
  }

  fs.mkdirSync(outDir, { recursive: true });

  const templateSource = fs.readFileSync(templatePath, 'utf-8');
  const data = JSON.parse(fs.readFileSync(dataPath, 'utf-8'));

  // resolve CSS shared (mesmo dir do template)
  const templateDir = path.dirname(path.resolve(templatePath));
  data.__cssPath = path.join(templateDir, 'shared.css');
  data.__cssInline = fs.existsSync(data.__cssPath)
    ? fs.readFileSync(data.__cssPath, 'utf-8')
    : '';

  // converte paths de imagem (file:// ou path absoluto/relativo) pra data URI base64
  // assim o puppeteer.setContent() consegue renderizar sem precisar de file:// access.
  const dataDir = path.dirname(path.resolve(dataPath));
  const MIME = { '.png': 'image/png', '.jpg': 'image/jpeg', '.jpeg': 'image/jpeg', '.webp': 'image/webp', '.svg': 'image/svg+xml' };
  for (const [k, v] of Object.entries(data)) {
    if (typeof v !== 'string') continue;
    let p = null;
    if (v.startsWith('file://')) p = v.replace('file://', '');
    else if (/\.(png|jpe?g|webp|svg)$/i.test(v) && !v.startsWith('http')) {
      p = path.isAbsolute(v) ? v : path.join(dataDir, v);
    }
    if (!p || !fs.existsSync(p)) continue;
    const ext = path.extname(p).toLowerCase();
    const mime = MIME[ext] || 'application/octet-stream';
    const b64 = fs.readFileSync(p).toString('base64');
    data[k] = `data:${mime};base64,${b64}`;
    console.error(`[render] embed ${k} (${(b64.length / 1024).toFixed(0)}kb)`);
  }

  const template = handlebars.compile(templateSource, { noEscape: false });
  const html = template(data);

  const chromium = resolveChromium();
  console.error(`[render] usando chromium: ${chromium}`);

  const browser = await puppeteer.launch({
    executablePath: chromium,
    headless: 'new',
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--disable-dev-shm-usage',
      '--disable-gpu',
      '--font-render-hinting=none',
    ],
  });

  try {
    const page = await browser.newPage();
    await page.setViewport({ width: SLIDE_W, height: SLIDE_H, deviceScaleFactor: 1 });

    await page.setContent(html, { waitUntil: 'networkidle0' });

    // tenta esperar fontes carregarem (Google Fonts via @import no CSS)
    await page.evaluate(() => document.fonts.ready);

    const slideHandles = await page.$$('section.slide');
    if (slideHandles.length === 0) {
      throw new Error('Nenhum <section class="slide"> encontrado no template.');
    }

    const outputs = [];
    for (let i = 0; i < slideHandles.length; i++) {
      const slide = slideHandles[i];
      const outPath = path.join(outDir, `slide-${i + 1}.png`);
      await slide.screenshot({
        path: outPath,
        type: 'png',
        omitBackground: false,
      });
      outputs.push(outPath);
      console.error(`[render] slide ${i + 1}/${slideHandles.length} → ${outPath}`);
    }

    // metadata pra Clara consumir o resultado
    const manifest = {
      template: path.basename(templatePath),
      data_file: path.basename(dataPath),
      slides: outputs,
      width: SLIDE_W,
      height: SLIDE_H,
      generated_at: new Date().toISOString(),
    };
    const manifestPath = path.join(outDir, 'manifest.json');
    fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2));
    console.error(`[render] manifest → ${manifestPath}`);

    // stdout = lista pura de paths (1 por linha) pra Clara consumir
    console.log(outputs.join('\n'));
  } finally {
    await browser.close();
  }
}

main().catch((err) => {
  console.error(`[render] ERRO: ${err.message}`);
  console.error(err.stack);
  process.exit(1);
});
