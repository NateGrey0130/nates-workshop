#!/usr/bin/env node
// Extract one O.C.C./R.C.C. from a book's OCR cache into a draft markdown file.
//
//   node scripts/extract-class.mjs --book ww --pages 64-65 --out draft.md
//   node scripts/extract-class.mjs --book ww --pages 55,57,59 --like apok,monk
//   node scripts/extract-class.mjs --book ww --pages 64-65 --dry-run
//
// This is the BACKEND half of what `import.html` used to do in the browser,
// and it exists because the in-app importer never ran once against production:
// `import_sessions` and `import_staged` are empty, and of 23 `claude_usage`
// rows not one is an import. Every catalog row this repo has came from a data
// script.
//
// WHAT THIS DOES DIFFERENTLY, and why each one is deliberate:
//
//   * IT SENDS CACHED TEXT, NOT A PDF SLICE. The route sent the page image
//     because "layout-preserving text extraction splices neighbouring columns
//     together mid-line". That was true of pdftotext and it is NOT true of
//     this cache: ocr-book.py and read-columns.py resolve the columns
//     GEOMETRICALLY before anything is written. So the premise that justified
//     the expensive path is gone - no PDF slicing by hand (the manual step
//     F11 is about), no image tokens, and the model reads the same bytes a
//     human reviewer reads.
//
//   * IT REFUSES ART PAGES. A page whose cached text is a handful of bytes is
//     a full-page illustration, not a page that failed to OCR. Wormwood's
//     printed 56 and 58 are 16 and 9 bytes, they sit inside the Apok's own
//     cited range, and sending them as though they were text is how a class
//     silently loses a third of itself. The Apok's text runs 55 -> 57 -> 59.
//     This refuses and names the pages instead of guessing.
//
//   * IT METERS. The importer's one real achievement was F7: the cost of a
//     book became a query rather than an estimate. Moving extraction to a
//     script would have thrown that away, so this writes the same
//     `claude_usage` row the route did - BEFORE parsing, because a failed
//     extraction still spent the input tokens.
//
//   * IT NAMES ITS FORMAT EXAMPLES. `getExamples` fed the model the two
//     OLDEST published classes on every call, forever (F16). Here the examples
//     are `--like <id,id>`, defaulting to the two most RECENTLY published
//     classes of the same system, which is as close as this repo gets to "the
//     house style as it currently stands".
//
// WHAT THE FIRST REAL RUN PRODUCED, so nobody expects more of this than it
// gives. Extracting the Apok from printed 55, 57 and 59 cost 21,581 input and
// 4,940 output tokens and came back structurally sound - right id, right name,
// the right `p.55-59` citation, spells and psionics and restrictions all
// clean. `class-check --remote` then rejected it for two things:
//
//   * FOUR SKILLS BY THE BOOK'S NAME, NOT THE CATALOG'S - Lore: Monsters &
//     Demons, Language: American, Literacy: American, Math: Basic. Every one
//     of those is a known rename.
//   * FIVE INVENTED GEAR SLUGS, from issuing the Weapons line as equipment.
//
// The first of those is the one worth knowing about, because THE FORMAT
// EXAMPLES DID NOT PREVENT IT. That run was given the shipped Apok as an
// example, so the correct catalog names were in the prompt - and so were notes
// saying in words that the book prints the other spelling. It used the book's
// name anyway, every time. Examples teach SHAPE; they do not teach naming.
//
// So the renames are not something a better example fixes, and they are not
// something to solve by feeding the whole catalog into the prompt. They are
// what `class-check --remote` is for, which is why it is the required next
// step rather than an optional one.
//
// It writes a draft and stops. It does not touch a catalog, and the next step
// is always `class-check`, then a hand-written data script. Nothing here
// publishes anything.
import { existsSync, readFileSync, readdirSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { loadBookRegistry } from './books-lib.mjs';
import { offsetForPrintedPage } from './class-check-lib.mjs';
import { SYSTEM_PROMPT_CACHE, buildUserPrompt, buildUserPromptParts } from './extraction-prompt.mjs';
import { DB, d1Query, repoRoot } from './d1-query-lib.mjs';

const DEFAULT_MODEL = 'claude-sonnet-5';
const ALLOWED_MODELS = ['claude-sonnet-5', 'claude-opus-5'];
const MAX_TOKENS = 12000;

// Below this many bytes a cached page is art, a folio and OCR noise - not
// text. Wormwood p056 is 16 bytes and p058 is 9; the smallest REAL page in
// that book is p074 at 744, which is the Hospitaller's code of chivalry set in
// a sparse single column. 400 sits between them with room either side.
const ART_PAGE_BYTES = 400;

const die = (msg) => { console.error(msg); process.exit(1); };

// ── arguments ───────────────────────────────────────────────────────────────
const argv = process.argv.slice(2);
const flag = (name, fallback = null) => {
  const i = argv.indexOf(`--${name}`);
  return i >= 0 && argv[i + 1] && !argv[i + 1].startsWith('--') ? argv[i + 1] : fallback;
};
const has = (name) => argv.includes(`--${name}`);

if (has('help') || !argv.length) {
  console.log(readFileSync(new URL(import.meta.url)).toString()
    .split('\n').slice(1, 46).map((l) => l.replace(/^\/\/ ?/, '')).join('\n'));
  process.exit(0);
}

const bookArg = flag('book') ?? die('--book <slug> is required (see scripts/books.json)');
const pagesArg = flag('pages') ?? die('--pages <N-M or N,M,O> is required, in PRINTED folios');
const model = flag('model', DEFAULT_MODEL);
if (!ALLOWED_MODELS.includes(model)) die(`--model must be one of ${ALLOWED_MODELS.join(', ')}`);
const outPath = flag('out', null);
const dryRun = has('dry-run');
const allowShort = has('allow-short');
const target = has('local') ? '--local' : '--remote';

// ── the book, and the pages it means ────────────────────────────────────────
const registry = loadBookRegistry();
const slug = registry[bookArg]
  ? bookArg
  : Object.keys(registry).find((s) => registry[s].title.toLowerCase() === bookArg.toLowerCase());
if (!slug) {
  die(`no book "${bookArg}" in scripts/books.json. Known slugs: ${Object.keys(registry).join(', ')}`);
}
const entry = registry[slug];

// Printed folios in, cache file numbers out. The offset is READ from the
// registry rather than re-derived, and it is read PER PAGE, because `pf` does
// not paginate constantly - that is F4, and this script would reintroduce the
// bug it fixed if it took one offset for a whole range.
const printedPages = [];
for (const part of pagesArg.split(',')) {
  const m = part.trim().match(/^(\d+)(?:\s*-\s*(\d+))?$/);
  if (!m) die(`cannot read "${part}" as a page or a page range`);
  const first = Number(m[1]);
  const last = m[2] ? Number(m[2]) : first;
  if (last < first) die(`page range "${part}" runs backwards`);
  for (let p = first; p <= last; p++) printedPages.push(p);
}
if (!printedPages.length) die('no pages resolved from --pages');

const txtDir = join(repoRoot, '.cache', 'books', slug, 'txt');
if (!existsSync(txtDir)) {
  die(`no OCR cache for "${slug}" on this machine (${txtDir}).\n`
    + `Build one with scripts/ocr-book.py; the caches are gitignored, and\n`
    + `scripts/books.json records where its source PDF was read from.`);
}

const pages = [];
const missing = [];
const artPages = [];
for (const printed of printedPages) {
  const off = offsetForPrintedPage(printed, entry);
  if (!off || !Number.isInteger(off.offset)) {
    die(`scripts/books.json records no page_offset for ${slug}, so printed ${printed} cannot be located.`);
  }
  const fileNo = printed + off.offset;
  const file = join(txtDir, `p${String(fileNo).padStart(3, '0')}.txt`);
  if (!existsSync(file)) { missing.push(`printed ${printed} (expected p${String(fileNo).padStart(3, '0')}.txt)`); continue; }
  const text = readFileSync(file, 'utf8');
  if (text.trim().length < ART_PAGE_BYTES) {
    artPages.push({ printed, fileNo, bytes: text.trim().length });
    if (!allowShort) continue;
  }
  pages.push({ printed, fileNo, text });
}

if (missing.length) {
  die(`these pages are not in the ${slug} cache:\n  ${missing.join('\n  ')}\n`
    + `The cache holds ${readdirSync(txtDir).filter((f) => /^p\d+\.txt$/.test(f)).length} pages.`);
}

if (artPages.length && !allowShort) {
  console.error(`\nREFUSING ${artPages.length} page(s) that hold no text:\n`);
  for (const a of artPages) {
    console.error(`  printed ${a.printed} (p${String(a.fileNo).padStart(3, '0')}.txt) — ${a.bytes} bytes`);
  }
  console.error(`\nA page this short is a FULL-PAGE ILLUSTRATION, not a failed OCR run. It is`);
  console.error(`also the trap that hides a third of a class: Wormwood's Apok is cited pp.55-58,`);
  console.error(`printed 56 and 58 are art, and the rest of the class is on printed 59.`);
  console.error(`\nCheck what the class actually spans and re-run with the real pages.`);
  console.error(`--allow-short sends them anyway, which is almost never what you want.\n`);
  if (!pages.length) process.exit(1);
  process.exit(1);
}
if (!pages.length) die('no readable pages in that range');

const corpus = pages
  .map((p) => `=== printed page ${p.printed} ===\n\n${p.text.trim()}`)
  .join('\n\n');

// ── format examples ─────────────────────────────────────────────────────────
// The repo's own helper, not a hand-rolled spawn. execFileSync with
// shell:true does not quote the arguments it joins, so the SQL loses its
// spaces and wrangler reports twenty unknown arguments - drift-check.mjs's
// header is thirty lines about this exact failure. One command string, SQL
// quoted inside it.
const d1 = (sql) => d1Query(sql, { target, db: DB });

const likeArg = flag('like', null);
let examples;
try {
  examples = likeArg
    ? d1(`SELECT class_id, name, markdown FROM imported_classes WHERE class_id IN (`
        + likeArg.split(',').map((s) => `'${s.trim().replace(/'/g, "''")}'`).join(', ') + `)`)
    : d1(`SELECT class_id, name, markdown FROM imported_classes WHERE deleted_at IS NULL `
        + `AND status = 'published' ORDER BY id DESC LIMIT 2`);
} catch (e) {
  die(`could not read format examples from D1 (${target}): ${e.message}`);
}
if (!examples.length) die(`no format examples found${likeArg ? ` for --like ${likeArg}` : ''}`);

const exampleObjs = examples.map((e) => ({ name: e.name, text: e.markdown }));
const hints = `${entry.title}, printed pages ${printedPages.join(', ')}.\n\n${corpus}`;
const { stable, varying } = buildUserPromptParts(exampleObjs, hints);
const userPrompt = stable + varying;

// The split must not change a byte of what the model reads. If this ever
// fails, the cache boundary has moved the prompt rather than only cutting it.
if (userPrompt !== buildUserPrompt(exampleObjs, hints)) {
  die('the cached/varying split does not reassemble into the original prompt');
}

// ── report before spending anything ─────────────────────────────────────────
console.log(`book:      ${entry.title} (${slug})`);
console.log(`pages:     printed ${printedPages.join(', ')} -> `
  + pages.map((p) => `p${String(p.fileNo).padStart(3, '0')}`).join(', '));
console.log(`text:      ${corpus.length.toLocaleString()} chars`);
console.log(`examples:  ${examples.map((e) => e.class_id).join(', ')}`
  + (likeArg ? ' (--like)' : ` (two most recently published, from ${target})`));
console.log(`model:     ${model}, max_tokens ${MAX_TOKENS}, thinking disabled`);
console.log(`cached:    ${stable.length.toLocaleString()} chars of stable prefix, `
  + `${varying.length.toLocaleString()} chars of page text sent fresh`);
if (artPages.length) console.log(`WARNING:   ${artPages.length} short page(s) sent anyway (--allow-short)`);

if (dryRun) {
  console.log(`\n--dry-run: nothing sent, nothing metered, nothing written.`);
  console.log(`system prompt ${SYSTEM_PROMPT_CACHE.length} chars, user prompt ${userPrompt.length} chars.`);
  console.log(`cache breakpoint after ${stable.length} of those ${userPrompt.length}.`);
  process.exit(0);
}

// ── the call ────────────────────────────────────────────────────────────────
let apiKey = process.env.ANTHROPIC_API_KEY;
if (!apiKey && existsSync(join(repoRoot, '.dev.vars'))) {
  const m = readFileSync(join(repoRoot, '.dev.vars'), 'utf8').match(/^ANTHROPIC_API_KEY\s*=\s*"?([^"\r\n]+)"?/m);
  if (m) apiKey = m[1];
}
if (!apiKey) die('no ANTHROPIC_API_KEY in the environment or in .dev.vars');

// Sonnet 5 thinks by default, and max_tokens caps thinking and text TOGETHER -
// one extraction burned all 12,000 tokens on a thinking block and produced no
// text at all. Transcription wants the budget for output.
const body = {
  model,
  max_tokens: MAX_TOKENS,
  thinking: { type: 'disabled' },
  system: SYSTEM_PROMPT_CACHE,
  // ONE cache breakpoint, at the end of the stable prefix (F23 step 2). The
  // cached span runs from the start of the request through this block, so it
  // covers the system prompt, the schema and the format examples; the page
  // text follows in its own uncached block.
  //
  // Ephemeral is the 5-MINUTE tier, and that is the whole bet: a hit costs
  // 0.1x a normal input token and a WRITE costs 1.25x, so extracting a book's
  // classes back to back is ~83% cheaper on the prefix while extractions more
  // than five minutes apart cost ~25% MORE than sending it uncached. F23's
  // posture said a miss was free; it is not. Batch the extractions.
  messages: [{
    role: 'user',
    content: [
      { type: 'text', text: stable, cache_control: { type: 'ephemeral' } },
      ...(varying ? [{ type: 'text', text: varying }] : []),
    ],
  }],
};

console.log('\ncalling the API...');
const res = await fetch('https://api.anthropic.com/v1/messages', {
  method: 'POST',
  headers: { 'content-type': 'application/json', 'x-api-key': apiKey, 'anthropic-version': '2023-06-01' },
  body: JSON.stringify(body),
});
const raw = await res.text();

// METERED HERE, before the parse and the status check - a call that failed
// after the tokens were spent is exactly the call worth having a number for.
// Fail-open: a metering problem must not lose the extraction that was paid for.
let payload = null;
try { payload = JSON.parse(raw); } catch { /* reported below */ }
try {
  const u = payload?.usage ?? {};
  const esc = (v) => (v == null ? 'NULL' : `'${String(v).replace(/'/g, "''")}'`);

  // WITH CACHING, `usage.input_tokens` COUNTS ONLY THE UNCACHED PART. The
  // cached span comes back as cache_creation_input_tokens (a write) or
  // cache_read_input_tokens (a hit) instead. Recording input_tokens alone
  // would have dropped this row from 21,581 to ~5,600 the moment the
  // breakpoint was added - a silent 74% undercount in the ledger F23 used to
  // justify the breakpoint in the first place.
  //
  // So the column keeps meaning what it has always meant: input tokens this
  // call processed. It is NOT a cost - a cached read is billed at 0.1x and a
  // write at 1.25x - and claude_usage has no column for that split. The run
  // prints it; the table cannot hold it yet.
  const nz = (v) => (Number.isInteger(v) ? v : 0);
  const cacheWrite = nz(u.cache_creation_input_tokens);
  const cacheRead = nz(u.cache_read_input_tokens);
  const inputTotal = Number.isInteger(u.input_tokens)
    ? u.input_tokens + cacheWrite + cacheRead
    : null;

  d1(`INSERT INTO claude_usage (email, endpoint, model, input_tokens, output_tokens, status) `
    + `VALUES (NULL, 'cc-extract-class', ${esc(model)}, `
    + `${inputTotal === null ? 'NULL' : inputTotal}, `
    + `${Number.isInteger(u.output_tokens) ? u.output_tokens : 'NULL'}, ${res.status})`);
  console.log(`metered:   cc-extract-class -> claude_usage (${target})`);
  console.log(`tokens:    ${inputTotal ?? '?'} in / ${u.output_tokens ?? '?'} out`
    + `  [fresh ${nz(u.input_tokens)}, cache write ${cacheWrite}, cache read ${cacheRead}]`);
  if (cacheWrite && !cacheRead) {
    console.log(`           cache MISS - this call paid 1.25x on ${cacheWrite} tokens to fill it.`);
    console.log(`           The next extraction within 5 minutes reads them at 0.1x.`);
  } else if (cacheRead) {
    console.log(`           cache HIT on ${cacheRead} tokens, billed at 0.1x.`);
  }
} catch (e) {
  console.error(`WARNING: could not write the claude_usage row: ${e.message}`);
}

if (!payload) die(`Anthropic returned a non-JSON response (status ${res.status}):\n${raw.slice(0, 400)}`);
if (res.status !== 200) die(`extraction failed: ${payload.error?.message || `status ${res.status}`}`);

const blocks = Array.isArray(payload.content) ? payload.content : [];
const text = blocks.filter((c) => c.type === 'text').map((c) => c.text).join('\n').trim();
if (!text) {
  die(`extraction produced no usable text.\n  stop_reason: ${payload.stop_reason ?? '?'}\n`
    + `  blocks: ${blocks.map((c) => c.type).join(', ') || 'none'}\n`
    + `  usage: ${JSON.stringify(payload.usage ?? null)}`);
}
// A truncated reply must never be treated as a complete one: half a class that
// parses is worse than a failure, because it is reviewed as though it were whole.
if (payload.stop_reason === 'max_tokens') {
  die(`the reply hit the output limit, so those pages were only partly read.\n`
    + `Narrow the page range and try again. (${payload.usage?.output_tokens ?? '?'} output tokens)`);
}

// Claude occasionally wraps the file in a fence despite instructions, and has
// been seen to open frontmatter with `---` and never close it. Both repairs are
// deterministic and lifted from the route they were learned in.
const stripFences = (s) => {
  const t = s.trim();
  const fenced = t.match(/^```(?:markdown|md|yaml)?\s*\n([\s\S]*?)\n```$/);
  return (fenced ? fenced[1] : t).trim();
};
// OBSERVED ON THE FIRST REAL RUN, and not a failure mode the PDF route ever
// hit: the model wrote a line of commentary ABOVE the frontmatter - a note
// about one of the format EXAMPLES, not about the class it had extracted - and
// the parser then reported "No YAML frontmatter block found" on a file whose
// frontmatter was perfectly good three lines down.
//
// Deterministic and narrow: only fires when the text does NOT already start
// with the delimiter, and only when the first bare `---` is followed within a
// few lines by an `id:` key. That is a frontmatter block with rubbish in front
// of it; anything else is left exactly as it came back.
const stripPreamble = (md) => {
  if (md.startsWith('---')) return md;
  const lines = md.split('\n');
  const open = lines.findIndex((l) => l.trim() === '---');
  if (open < 1) return md;
  const looksLikeFrontmatter = lines.slice(open + 1, open + 6)
    .some((l) => /^id:\s*[a-z0-9-]+\s*$/.test(l.trim()));
  return looksLikeFrontmatter ? lines.slice(open).join('\n') : md;
};

const repairFrontmatter = (md) => {
  if (!md.startsWith('---')) return md;
  const lines = md.split('\n');
  const delims = lines.reduce((a, l, i) => (l.trim() === '---' ? [...a, i] : a), []);
  if (delims.length !== 1 || delims[0] !== 0) return md;
  const heading = lines.findIndex((l) => /^##\s/.test(l));
  if (heading < 1) return md;
  lines.splice(heading, 0, '---', '');
  return lines.join('\n');
};

const markdown = repairFrontmatter(stripPreamble(stripFences(text)));
const idMatch = markdown.match(/^id:\s*([a-z0-9-]+)\s*$/m);
const out = outPath ?? `${idMatch ? idMatch[1] : 'draft'}.md`;
writeFileSync(out, markdown);

console.log(`tokens:    ${payload.usage?.input_tokens ?? '?'} in, ${payload.usage?.output_tokens ?? '?'} out`);
console.log(`written:   ${out} (${markdown.length.toLocaleString()} chars)`);
console.log(`\nNEXT: node scripts/class-check.mjs ${out} --remote`);
console.log(`      then --field-sources, then wrap it in a data script by hand.`);
console.log(`      Nothing has been written to a catalog. This is a draft.`);
