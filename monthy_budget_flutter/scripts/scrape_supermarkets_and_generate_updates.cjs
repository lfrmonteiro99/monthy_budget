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

// Stricter matching profile:
// - higher similarity threshold for matches
// - existing product updates require at least 2 stores
// - new products require multi-store consensus
const MATCH_MIN_SCORE = 0.6;
const UPDATE_MIN_STORES = 2;
const UPDATE_MIN_AVG_SCORE = 0.68;
const NEW_PRODUCT_EXISTING_MAX_SIM = 0.52;
const NEW_PRODUCT_MIN_STORES = 2;

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
    .replace(/&Oacute;/g, 'O')
    .replace(/&otilde;/g, 'o')
    .replace(/&Ocirc;/g, 'O')
    .replace(/&uacute;/g, 'u')
    .replace(/&Uacute;/g, 'U')
    .replace(/&Aacute;/g, 'A')
    .replace(/&Acirc;/g, 'A')
    .replace(/&Eacute;/g, 'E')
    .replace(/&Ecirc;/g, 'E')
    .replace(/&Iacute;/g, 'I')
    .replace(/&atilde;/g, 'a')
    .replace(/&uuml;/g, 'u')
    .replace(/&Atilde;/g, 'A')
    .replace(/&auml;/g, 'a')
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

function tokenIntersectionCount(a, b) {
  const sa = new Set(tokens(a));
  const sb = new Set(tokens(b));
  let inter = 0;
  for (const t of sa) if (sb.has(t)) inter++;
  return inter;
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

function canonicalKey(name) {
  const t = tokens(name).filter((x) => x.length >= 3);
  return t.slice(0, 4).join(' ');
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
  const t = new Set(tokens(`${name} ${sourceCategory}`));
  const hasAny = (words) => words.some((w) => t.has(w));
  if (hasAny(['detergente', 'amaciador', 'papel', 'higienico', 'toalhas', 'sacos', 'esponjas', 'desinfetante'])) return 'Limpeza';
  if (hasAny(['sabonete', 'champo', 'champ', 'champoo', 'condicionador', 'gel', 'banho', 'pasta', 'dentes', 'desodorizante'])) return 'Higiene';
  if (hasAny(['maca', 'banana', 'laranja', 'pera', 'uva', 'morango', 'kiwi', 'manga', 'abacate'])) return 'Frutas';
  if (hasAny(['tomate', 'cebola', 'alho', 'batata', 'cenoura', 'alface', 'pepino', 'brocolo', 'brocolos', 'couve', 'espinafre'])) return 'Legumes';
  if (hasAny(['frango', 'carne', 'porco', 'bife', 'chourico', 'fiambre', 'peru'])) return 'Carnes';
  if (hasAny(['peixe', 'atum', 'bacalhau', 'salmao', 'camarao', 'sardinha', 'pescada'])) return 'Peixe';
  if (hasAny(['leite', 'iogurte', 'queijo', 'manteiga', 'requeijao', 'mozzarella'])) return 'Laticinios';
  if (hasAny(['arroz', 'massa', 'pao', 'farinha', 'aveia', 'cereal', 'granola'])) return 'Pao e Cereais';
  if (hasAny(['azeite', 'oleo', 'sal', 'acucar', 'ketchup', 'maionese', 'mostarda', 'oregao', 'vinagre'])) return 'Azeite e Condimentos';
  if (hasAny(['agua', 'sumo', 'refrigerante', 'cerveja', 'vinho', 'cafe', 'cha'])) return 'Bebidas';
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
    if (score < MATCH_MIN_SCORE) continue;
    if (tokenIntersectionCount(productName, it.name) < 1) continue;
    const current = byStore.get(it.store);
    if (!current || score > current.score) byStore.set(it.store, { ...it, score });
  }
  return [...byStore.values()];
}

function pickNewProducts(existingProducts, scrapedItems) {
  const existingNames = existingProducts.map((p) => p.name);

  const grouped = new Map();
  for (const it of scrapedItems) {
    const key = canonicalKey(it.name);
    if (!key || key.length < 6) continue;
    const g = grouped.get(key) || { items: [], stores: new Set() };
    g.items.push(it);
    g.stores.add(it.store);
    grouped.set(key, g);
  }

  const candidates = [];
  for (const [, g] of grouped) {
    if (g.stores.size < NEW_PRODUCT_MIN_STORES) continue;
    const rep = g.items[0];
    const name = rep.name;
    const tok = tokens(name);
    if (tok.length < 2) continue;

    let bestExisting = 0;
    for (const existing of existingNames) {
      const s = similarity(existing, name);
      if (s > bestExisting) bestExisting = s;
      if (bestExisting >= 0.8) break;
    }
    if (bestExisting >= NEW_PRODUCT_EXISTING_MAX_SIM) continue;

    const avg = g.items.reduce((acc, x) => acc + x.price, 0) / g.items.length;
    candidates.push({
      ...rep,
      price: Number(avg.toFixed(2)),
      support_stores: [...g.stores],
      support_count: g.stores.size,
    });
  }

  const seen = new Set();
  const deduped = [];
  for (const it of candidates.sort((a, b) => b.support_count - a.support_count)) {
    const key = normalize(it.name);
    if (seen.has(key)) continue;
    seen.add(key);
    deduped.push(it);
  }
  return deduped.slice(0, 60);
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
    if (matches.length < UPDATE_MIN_STORES) continue;
    const avgScore = matches.reduce((acc, x) => acc + x.score, 0) / matches.length;
    if (avgScore < UPDATE_MIN_AVG_SCORE) continue;
    const avg = matches.reduce((acc, x) => acc + x.price, 0) / matches.length;
    updates.push({
      name: p.name,
      oldPrice: p.avgPrice,
      newPrice: Number(avg.toFixed(2)),
      avgScore: Number(avgScore.toFixed(3)),
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
    strict_profile: {
      match_min_score: MATCH_MIN_SCORE,
      update_min_stores: UPDATE_MIN_STORES,
      update_min_avg_score: UPDATE_MIN_AVG_SCORE,
      new_product_existing_max_similarity: NEW_PRODUCT_EXISTING_MAX_SIM,
      new_product_min_stores: NEW_PRODUCT_MIN_STORES,
    },
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
