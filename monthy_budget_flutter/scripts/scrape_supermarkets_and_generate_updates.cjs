#!/usr/bin/env node

/*
 Scrapes Portuguese supermarket data and generates SQL updates for Supabase `products` table.
 Sources:
 - Continente (Search-UpdateGrid)
 - Auchan (Search-UpdateGrid)
 - Pingo Doce (Search-ShowAjax)
 - Minipreco (autocompleteSecure JSON)
 - Lidl (embedded Nuxt payload on search page)
 - Aldi (featured products on homepage)
*/

const fs = require('fs');
const path = require('path');

const ROOT = process.cwd();
const PRODUCTS_SQL = path.join(ROOT, 'supabase', 'products.sql');
const OUTPUT_SQL = path.join(ROOT, 'generated', 'product_price_updates.sql');
const OUTPUT_JSON = path.join(ROOT, 'generated', 'product_price_updates_report.json');

const STORE_NAMES = ['Continente', 'Auchan', 'Pingo Doce', 'Minipreco', 'Lidl', 'Aldi'];

const SEARCH_TERMS = [
  'arroz', 'massa', 'esparguete', 'pao', 'leite', 'iogurte', 'queijo', 'manteiga', 'ovos',
  'frango', 'carne', 'bife', 'porco', 'pescada', 'salmao', 'atum', 'camarao',
  'banana', 'maca', 'pera', 'laranja', 'morango', 'uva', 'tomate', 'cebola', 'alho',
  'batata', 'cenoura', 'alface', 'pepino', 'brocolos', 'couve',
  'azeite', 'oleo', 'acucar', 'sal', 'vinagre', 'ketchup', 'maionese',
  'agua', 'sumo', 'cerveja', 'vinho', 'cafe', 'cha',
  'detergente', 'sabonete', 'champo', 'pasta dentes', 'papel higienico', 'toalhas papel'
];

const STOPWORDS = new Set([
  'de', 'da', 'do', 'dos', 'das', 'e', 'a', 'o', 'os', 'as', 'com', 'sem', 'para', 'em',
  'kg', 'g', 'gr', 'ml', 'l', 'lt', 'un', 'pack', 'pacote', 'unidade', 'ud'
]);

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function decodeHtmlEntities(input) {
  if (!input) return '';
  return input
    .replace(/&quot;/g, '"')
    .replace(/&#34;/g, '"')
    .replace(/&#39;/g, "'")
    .replace(/&amp;/g, '&')
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&nbsp;/g, ' ')
    .replace(/&ccedil;/g, 'c')
    .replace(/&atilde;/g, 'a')
    .replace(/&aacute;/g, 'a')
    .replace(/&eacute;/g, 'e')
    .replace(/&ecirc;/g, 'e')
    .replace(/&iacute;/g, 'i')
    .replace(/&oacute;/g, 'o')
    .replace(/&otilde;/g, 'o')
    .replace(/&uacute;/g, 'u')
    .replace(/&uuml;/g, 'u')
    .replace(/&#(\d+);/g, (_, d) => String.fromCharCode(Number(d)));
}

function normalize(text) {
  return (text || '')
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9\s]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

function tokens(text) {
  return normalize(text)
    .split(' ')
    .filter((t) => t.length > 1 && !STOPWORDS.has(t));
}

function similarity(a, b) {
  const ta = tokens(a);
  const tb = tokens(b);
  if (!ta.length || !tb.length) return 0;

  const sa = new Set(ta);
  const sb = new Set(tb);
  let inter = 0;
  for (const t of sa) if (sb.has(t)) inter++;
  const union = sa.size + sb.size - inter;
  const jaccard = union ? inter / union : 0;

  const na = normalize(a);
  const nb = normalize(b);
  const contains = na.includes(nb) || nb.includes(na) ? 0.25 : 0;

  return Math.min(1, jaccard + contains);
}

function parseProductsSql(sqlText) {
  const rows = [];
  const regex = /\('([^']*)',\s*'([^']*)',\s*([0-9]+(?:\.[0-9]+)?),\s*'([^']*)'\)/g;
  let m;
  while ((m = regex.exec(sqlText)) !== null) {
    rows.push({
      name: m[1],
      category: m[2],
      avgPrice: Number(m[3]),
      unit: m[4],
    });
  }
  return rows;
}

async function fetchText(url) {
  const res = await fetch(url, {
    headers: {
      'user-agent': 'Mozilla/5.0 (compatible; monthy-budget-scraper/1.0)'
    }
  });
  if (!res.ok) throw new Error(`HTTP ${res.status} @ ${url}`);
  return res.text();
}

async function fetchJson(url) {
  const res = await fetch(url, {
    headers: {
      'user-agent': 'Mozilla/5.0 (compatible; monthy-budget-scraper/1.0)'
    }
  });
  if (!res.ok) throw new Error(`HTTP ${res.status} @ ${url}`);
  return res.json();
}

function pushItem(items, item) {
  if (!item || !item.name || !Number.isFinite(item.price)) return;
  if (item.price <= 0 || item.price > 999) return;
  items.push(item);
}

async function scrapeContinente(term) {
  const url = `https://www.continente.pt/on/demandware.store/Sites-continente-Site/default/Search-UpdateGrid?cgid=col-produtos&q=${encodeURIComponent(term)}&pmin=0.01&srule=Continente&start=0&sz=35`;
  const html = await fetchText(url);
  const out = [];
  const re = /data-product-tile-impression='([^']+)'/g;
  let m;
  while ((m = re.exec(html)) !== null) {
    try {
      const parsed = JSON.parse(decodeHtmlEntities(m[1]));
      pushItem(out, {
        store: 'Continente',
        name: parsed.name,
        price: Number(parsed.price),
        sourceCategory: parsed.category || '',
        sourceId: parsed.id || '',
        query: term,
      });
    } catch {}
  }
  return out;
}

async function scrapeAuchan(term) {
  const url = `https://www.auchan.pt/on/demandware.store/Sites-AuchanPT-Site/pt_PT/Search-UpdateGrid?prefn1=soldInStores&prefv1=000&q=${encodeURIComponent(term)}&srule=Mais%20Populares&start=0&sz=24`;
  const html = await fetchText(url);
  const out = [];
  const re = /data-gtm="([^"]+)"/g;
  let m;
  while ((m = re.exec(html)) !== null) {
    try {
      const parsed = JSON.parse(decodeHtmlEntities(m[1]));
      pushItem(out, {
        store: 'Auchan',
        name: parsed.name,
        price: Number(parsed.price),
        sourceCategory: parsed.category || '',
        sourceId: parsed.id || '',
        query: term,
      });
    } catch {}
  }
  return out;
}

async function scrapePingoDoce(term) {
  const url = `https://www.pingodoce.pt/on/demandware.store/Sites-pingo-doce-Site/default/Search-ShowAjax?q=${encodeURIComponent(term)}&pmin=0.04&prefn1=onlineFlag&prefv1=true`;
  const html = await fetchText(url);
  const out = [];
  const re = /data-gtm-info='([^']+)'/g;
  let m;
  while ((m = re.exec(html)) !== null) {
    try {
      const parsed = JSON.parse(decodeHtmlEntities(m[1]));
      const item = parsed.items && parsed.items[0] ? parsed.items[0] : {};
      pushItem(out, {
        store: 'Pingo Doce',
        name: item.item_name,
        price: Number(item.price),
        sourceCategory: item.item_category || '',
        sourceId: item.item_id || '',
        query: term,
      });
    } catch {}
  }
  return out;
}

async function scrapeMinipreco(term) {
  const url = `https://www.minipreco.pt/search/autocompleteSecure?term=${encodeURIComponent(term)}`;
  const data = await fetchJson(url);
  const out = [];
  for (const p of data.lightProducts || []) {
    const price = Number(p?.price?.value);
    pushItem(out, {
      store: 'Minipreco',
      name: p.name,
      price,
      sourceCategory: '',
      sourceId: p.code || '',
      query: term,
    });
  }
  return out;
}

function decodeNuxtPayload(root) {
  const memo = new Map();
  function walk(node) {
    if (typeof node === 'number' && Number.isInteger(node) && node >= 0 && node < root.length) {
      if (memo.has(node)) return memo.get(node);
      const target = root[node];
      if (Array.isArray(target) && typeof target[0] === 'string' && (target[0] === 'Reactive' || target[0] === 'ShallowReactive')) {
        const v = walk(target[1]);
        memo.set(node, v);
        return v;
      }
      if (Array.isArray(target)) {
        const arr = [];
        memo.set(node, arr);
        for (const x of target) arr.push(walk(x));
        return arr;
      }
      if (target && typeof target === 'object') {
        const obj = {};
        memo.set(node, obj);
        for (const [k, v] of Object.entries(target)) obj[k] = walk(v);
        return obj;
      }
      memo.set(node, target);
      return target;
    }
    if (Array.isArray(node)) return node.map(walk);
    if (node && typeof node === 'object') {
      const obj = {};
      for (const [k, v] of Object.entries(node)) obj[k] = walk(v);
      return obj;
    }
    return node;
  }
  return walk(0);
}

async function scrapeLidl(term) {
  const url = `https://www.lidl.pt/q/search?q=${encodeURIComponent(term)}`;
  const html = await fetchText(url);

  const blocks = [...html.matchAll(/<script[^>]*>\s*(\[[\s\S]*?\])\s*<\/script>/g)].map((m) => m[1]);
  const payload = blocks.find((b) => b.includes('assortment=PT') && b.includes('searchTrackingQuery'));
  if (!payload) return [];

  let root;
  try {
    root = JSON.parse(payload);
  } catch {
    return [];
  }

  const decoded = decodeNuxtPayload(root);
  const items = decoded?.data?.$9oi58Bxyeo?.items || [];

  const out = [];
  for (const entry of items) {
    const data = entry?.gridbox?.data || {};
    pushItem(out, {
      store: 'Lidl',
      name: data.fullTitle || data.title,
      price: Number(data?.price?.price),
      sourceCategory: data.category || '',
      sourceId: data.erpNumber || entry.code || '',
      query: term,
    });
  }
  return out;
}

async function scrapeAldiHomepage() {
  const html = await fetchText('https://www.aldi.pt/');
  const out = [];
  const re = /data-analytics="([^"]+)"/g;
  let m;
  while ((m = re.exec(html)) !== null) {
    const raw = decodeHtmlEntities(m[1]);
    if (!raw.includes('productInfo') || !raw.includes('priceWithTax')) continue;
    try {
      const parsed = JSON.parse(raw);
      const p = parsed?.productInfo || {};
      pushItem(out, {
        store: 'Aldi',
        name: p.productName,
        price: Number(p.priceWithTax),
        sourceCategory: parsed?.productCategory?.primaryCategory || '',
        sourceId: p.productID || '',
        query: 'homepage',
      });
    } catch {}
  }
  return out;
}

function dedupeItems(items) {
  const map = new Map();
  for (const it of items) {
    const key = `${it.store}|${normalize(it.name)}`;
    if (!map.has(key)) {
      map.set(key, it);
      continue;
    }
    const prev = map.get(key);
    if (it.price < prev.price) map.set(key, it);
  }
  return [...map.values()];
}

function categoryFromSource(name, sourceCategory) {
  const text = `${name} ${sourceCategory}`.toLowerCase();
  if (/maca|banana|laranja|pera|uva|morango|kiwi|manga|abacate/.test(text)) return 'Frutas';
  if (/tomate|cebola|alho|batata|cenoura|alface|pepino|brocolo|couve|espinafre/.test(text)) return 'Legumes';
  if (/frango|carne|porco|bife|chourico|fiambre|peru/.test(text)) return 'Carnes';
  if (/peixe|atum|bacalhau|salmao|camarao|sardinha|pescada/.test(text)) return 'Peixe';
  if (/leite|iogurte|queijo|manteiga|requeijao|mozzarella/.test(text)) return 'Laticinios';
  if (/arroz|massa|pao|farinha|aveia|cereal|granola/.test(text)) return 'Pao e Cereais';
  if (/azeite|oleo|sal|acucar|ketchup|maionese|mostarda|oregao|vinagre/.test(text)) return 'Azeite e Condimentos';
  if (/agua|sumo|refrigerante|cerveja|vinho|cafe|cha/.test(text)) return 'Bebidas';
  if (/detergente|amaciador|papel higienico|toalhas|sacos|esponjas|desinfetante/.test(text)) return 'Limpeza';
  if (/sabonete|champo|gel de banho|pasta de dentes|desodorizante|creme/.test(text)) return 'Higiene';
  return 'Mercearia';
}

function unitFromName(name) {
  const n = normalize(name);
  if (/\bkg\b|quilo|saco/.test(n)) return 'kg';
  if (/\bl\b| litro|lt\b/.test(n)) return 'L';
  if (/pack|pack\b|caixa|saquetas/.test(n)) return 'pack';
  return 'un';
}

function bestMatchesForProduct(productName, scrapedItems) {
  const byStore = new Map();
  for (const it of scrapedItems) {
    const score = similarity(productName, it.name);
    if (score < 0.45) continue;
    const current = byStore.get(it.store);
    if (!current || score > current.score) byStore.set(it.store, { ...it, score });
  }
  return [...byStore.values()];
}

function pickNewProducts(existingProducts, scrapedItems) {
  const existingNames = existingProducts.map((p) => p.name);
  const out = [];
  for (const it of scrapedItems) {
    let best = 0;
    for (const name of existingNames) {
      const s = similarity(name, it.name);
      if (s > best) best = s;
      if (best >= 0.78) break;
    }
    if (best < 0.62) out.push(it);
  }

  const seen = new Set();
  const deduped = [];
  for (const it of out) {
    const key = normalize(it.name);
    if (key.length < 4 || seen.has(key)) continue;
    seen.add(key);
    deduped.push(it);
  }
  return deduped.slice(0, 80);
}

function sqlEscape(v) {
  return String(v).replace(/'/g, "''");
}

async function main() {
  if (!fs.existsSync(PRODUCTS_SQL)) {
    throw new Error(`Missing file: ${PRODUCTS_SQL}`);
  }

  const existingProducts = parseProductsSql(fs.readFileSync(PRODUCTS_SQL, 'utf8'));
  if (!existingProducts.length) {
    throw new Error('Could not parse existing products from supabase/products.sql');
  }

  const scraped = [];
  const errors = [];

  for (const term of SEARCH_TERMS) {
    const jobs = [
      ['Continente', () => scrapeContinente(term)],
      ['Auchan', () => scrapeAuchan(term)],
      ['Pingo Doce', () => scrapePingoDoce(term)],
      ['Minipreco', () => scrapeMinipreco(term)],
      ['Lidl', () => scrapeLidl(term)],
    ];

    for (const [store, fn] of jobs) {
      try {
        const items = await fn();
        scraped.push(...items);
      } catch (err) {
        errors.push({ store, term, error: String(err.message || err) });
      }
      await sleep(120);
    }
  }

  try {
    scraped.push(...(await scrapeAldiHomepage()));
  } catch (err) {
    errors.push({ store: 'Aldi', term: 'homepage', error: String(err.message || err) });
  }

  const cleaned = dedupeItems(scraped);

  const updates = [];
  for (const p of existingProducts) {
    const matches = bestMatchesForProduct(p.name, cleaned);
    if (!matches.length) continue;
    const avg = matches.reduce((acc, x) => acc + x.price, 0) / matches.length;
    updates.push({
      name: p.name,
      oldPrice: p.avgPrice,
      newPrice: Number(avg.toFixed(2)),
      matchedStores: matches.map((m) => ({ store: m.store, price: m.price, sourceName: m.name, score: Number(m.score.toFixed(3)) })),
    });
  }

  const newProductCandidates = pickNewProducts(existingProducts, cleaned);

  const sqlLines = [];
  sqlLines.push('-- Generated by scripts/scrape_supermarkets_and_generate_updates.js');
  sqlLines.push(`-- Generated at ${new Date().toISOString()}`);
  sqlLines.push('-- IMPORTANT: Review before executing in production.');
  sqlLines.push('begin;');
  sqlLines.push('');

  sqlLines.push('-- 1) Update avg_price for existing products');
  for (const u of updates) {
    sqlLines.push(`update products set avg_price = ${u.newPrice.toFixed(2)} where name = '${sqlEscape(u.name)}';`);
  }

  sqlLines.push('');
  sqlLines.push('-- 2) Insert newly discovered products that are not yet in products table');
  for (const np of newProductCandidates) {
    const category = categoryFromSource(np.name, np.sourceCategory);
    const unit = unitFromName(np.name);
    sqlLines.push(
      `insert into products (name, category, avg_price, unit) ` +
      `select '${sqlEscape(np.name)}', '${sqlEscape(category)}', ${Number(np.price).toFixed(2)}, '${sqlEscape(unit)}' ` +
      `where not exists (select 1 from products where lower(name) = lower('${sqlEscape(np.name)}'));`
    );
  }

  sqlLines.push('');
  sqlLines.push('commit;');
  sqlLines.push('');

  fs.writeFileSync(OUTPUT_SQL, sqlLines.join('\n'), 'utf8');

  const report = {
    generated_at: new Date().toISOString(),
    search_terms: SEARCH_TERMS,
    stores_targeted: STORE_NAMES,
    scraped_items_total: scraped.length,
    scraped_items_deduped: cleaned.length,
    updates_count: updates.length,
    new_products_count: newProductCandidates.length,
    errors,
    updates,
    new_products: newProductCandidates,
  };
  fs.writeFileSync(OUTPUT_JSON, JSON.stringify(report, null, 2), 'utf8');

  console.log(`Scraped raw items: ${scraped.length}`);
  console.log(`Scraped deduped items: ${cleaned.length}`);
  console.log(`Existing product price updates: ${updates.length}`);
  console.log(`New product candidates: ${newProductCandidates.length}`);
  console.log(`SQL output: ${OUTPUT_SQL}`);
  console.log(`Report output: ${OUTPUT_JSON}`);
  if (errors.length) console.log(`Completed with ${errors.length} scrape errors (see report).`);
}

main().catch((err) => {
  console.error(err.stack || String(err));
  process.exit(1);
});
