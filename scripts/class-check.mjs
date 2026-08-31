#!/usr/bin/env node
// Validate a class before it goes near the database.
//
//   node scripts/class-check.mjs apps/character-creator/db/add-mystic-class.sql
//   node scripts/class-check.mjs draft.md
//   node scripts/class-check.mjs draft.md --remote
//   node scripts/class-check.mjs draft.md --no-catalog
//   node scripts/class-check.mjs draft.md --field-sources [--book <slug>] [--offset <n>]
//   node scripts/class-check.mjs draft.md --emit-script <id> > apps/character-creator/db/add-<id>-class.sql
//
// This is the CLI half of what `import/recheck` already does in the browser:
// parse the markdown through the REAL parser, cross-reference it against the
// REAL catalogs, and say what is wrong in one pass. Transcribing a class used
// to mean writing the whole data script, applying it, reading a SQLite error
// and guessing — a loop that re-derived the frontmatter contract every time
// round. The point of this script is that the loop happens here instead, for
// free, before a single row is written.
//
// It imports the shipped modules rather than reimplementing them. A checker
// that agreed with the app most of the time would be worse than no checker:
// you would iterate against it, get a clean run, and still fail on Confirm.
//
// Three kinds of finding, and the difference between them matters:
//
//   ERRORS       the parser rejects the file. Fix before applying.
//   WARNINGS     it parses, and does something you may not have meant.
//   UNMODELLED   a top-level key nothing in the app reads — see the note in
//                class-check-lib.mjs. A decision to make, not a defect.
//
// Exit code is 1 for errors and pre-flight failures only. Warnings and
// unmodelled keys are judgement calls, and a script that exited non-zero on
// them would train you to stop reading the output.
//
// Unlike d1-apply.mjs this DOES default a target (--local). That script refuses
// to guess because an accidental --remote writes to production; every query
// here is a read.

import { readFileSync, readdirSync, existsSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

import { parseClassMarkdown } from '../apps/character-creator/js/parser.js';
import { isAttributeExpr } from '../apps/character-creator/js/dice.js';
import { crossReference, buildStubStatements, restrictionNames } from '../functions/api/character-creator/_lib/catalog.js';
import {
  extractClassMarkdown, unmodelledKeys, crossCategoryRestrictions, unclosedFlowLines,
  parseSourcePages, resolveBookSlug, registryBookSlug, detectPageOffset,
  detectPageOffsetRegions, offsetForPrintedPage, freeTextFields,
  fieldTokens, fieldSourceSpans, bestMatchingPages,
} from './class-check-lib.mjs';
import { loadBookRegistry } from './books-lib.mjs';

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');

const args = process.argv.slice(2);

function die(msg) {
  console.error('\nclass-check: ' + msg);
  process.exit(1);
}

// The two value-taking flags come out first, so their values are not read as
// file arguments.
function takeValue(flag) {
  const i = args.indexOf(flag);
  if (i < 0) return null;
  const v = args[i + 1];
  if (v === undefined || v.startsWith('--')) die(`${flag} needs a value`);
  args.splice(i, 2);
  return v;
}

const bookFlag = takeValue('--book');
const offsetFlag = takeValue('--offset');
if (offsetFlag !== null && !/^-?\d+$/.test(offsetFlag)) die('--offset takes an integer');
const emitScript = takeValue('--emit-script');
const fieldSources = args.includes('--field-sources');
const remote = args.includes('--remote');
const noCatalog = args.includes('--no-catalog');
const files = args.filter((a) => !a.startsWith('--'));

// --emit-script writes a data script to STDOUT and nothing else, because the
// documented use is `... --emit-script <id> > add-<id>-class.sql`. The human
// report still has to be visible, so it goes to stderr for this run only. It
// writes no file and applies nothing: turning a validated draft into SQL is
// worth automating, deciding to ship it is not.
if (emitScript !== null) {
  if (!/^[a-z0-9][a-z0-9-]*$/.test(emitScript)) {
    die('--emit-script takes a kebab-case class id');
  }
  // Without the catalog pass there are no stub rows, and a data script missing
  // the stubs its class references applies cleanly and leaves the class
  // pointing at nothing. Refuse rather than emit a script that is quietly short.
  if (noCatalog) die('--emit-script needs the catalog pass; drop --no-catalog');
  if (fieldSources) die('--field-sources is offline, so it cannot produce stub rows; run it separately');
  console.log = (...a) => console.error(...a);
}

if (files.length !== 1) die('give exactly one .md or .sql file');
const file = files[0];
if (!existsSync(file)) die(`${file}: no such file`);

const raw = readFileSync(file);
const isSql = file.toLowerCase().endsWith('.sql');

let markdown;
if (isSql) {
  try {
    markdown = extractClassMarkdown(raw.toString('utf8'));
  } catch (e) {
    die(`${file}: ${e.message}`);
  }
  if (markdown === null) die(`${file}: no INSERT INTO imported_classes found`);
} else {
  markdown = raw.toString('utf8');
}

console.log(`class-check: ${file}`);
if (isSql) console.log('  markdown read from the imported_classes INSERT');

// ── the same pre-flight d1-apply runs, run early ──
// Finding this at apply time means coming back to the file cold. Finding it
// here means fixing it inside the edit you are already making.
const preflight = [];
if (isSql) {
  if (raw.includes(0x0d)) {
    preflight.push('contains CR — a CRLF checkout changes the bytes that reach the '
      + 'database (see .gitattributes and PR #93). Re-checkout the file');
  }
  const bad = raw.findIndex((b) => b > 0x7f);
  if (bad >= 0) {
    preflight.push(`non-ASCII byte at offset ${bad} — wrangler on Windows has turned these `
      + 'into mojibake in production. Splice it in with char(N)');
  }
}

const { ok, data, errors, warnings } = parseClassMarkdown(markdown);

// `source_book` is free text, and the vocabulary in production is one book
// spelled five different ways. WARN, do not block: a spelling the registry has
// never seen is far more often a genuinely new book than a typo, and a checker
// that refused the ninth book would be a wall across the only path to it. What
// it buys is that the fifth spelling of a book already in there gets noticed
// on the way in rather than after 312 rows cite it.
const bookRegistry = loadBookRegistry();
if (data?.source_book && !registryBookSlug(data.source_book, bookRegistry)) {
  warnings.push(`source_book "${data.source_book}" matches no title or alias in `
    + 'scripts/books.json. If this is a book already in there, use its canonical '
    + 'spelling or add this one to its `aliases`; if it is a new book, add an entry.');
}

// Every attribute_dice value must parse as ONE of the two grammars the app
// reads — dice, or a fixed number (BOOK-INGEST-AUDIT.md F8). Anything else is
// SILENTLY replaced by 3d6 at roll time, with the notation rewritten to match,
// so the class ships looking complete and describes a different creature.
//
// This is the half of F8 that would have caught the Holy Terror. An ERROR
// rather than a warning: there is no reading under which an unparseable
// attribute is what the author meant. The app will substitute a value either
// way, and the only question is whether anyone is told.
for (const [attr, expr] of Object.entries(data?.attribute_dice ?? {})) {
  if (isAttributeExpr(expr)) continue;
  errors.push(`attribute_dice.${attr} is "${expr}", which parses as neither dice `
    + '(3d6, 4d6+4, 2d4x10) nor a fixed number (50). rollAttribute would discard it, '
    + 'roll 3d6 instead, and report the notation as 3d6.');
}

const list = (label, items) => {
  if (!items.length) return;
  console.log(`\n${label} (${items.length})`);
  for (const i of items) console.log(`  - ${i}`);
};

console.log(`\nPARSE            ${ok ? 'ok' : 'FAILED'}`);
if (data) {
  console.log(`  ${data.category ?? '?'} "${data.name ?? '?'}" (${data.id ?? '?'}) — ${data.system ?? '?'}`);
  if (data.source_book) console.log(`  ${data.source_book}`);
}
list('ERRORS', errors);
list('WARNINGS', warnings);
list('SQL PRE-FLIGHT', preflight);

// The parser reads inline [...] / {...} on ONE line only. A flow list wrapped
// across lines parses the opener as a scalar and fails later with a shape
// error that points nowhere near the cause — so name the line here, where the
// fix is one edit away.
const unclosed = unclosedFlowLines(markdown);
if (unclosed.length) {
  console.log(`\nUNCLOSED FLOW (${unclosed.length})`);
  for (const u of unclosed) console.log(`  - line ${u.line}: ${u.text}`);
  console.log('  An inline [...] or {...} must close on the SAME line. Put the whole');
  console.log('  value on one line, however long, or use a block sequence under the');
  console.log('  key — wrapped across lines, the parser reads the opener as text and');
  console.log('  the failure surfaces later as a misleading shape error.');
}

const unmodelled = unmodelledKeys(data);
if (unmodelled.length) {
  console.log(`\nUNMODELLED (${unmodelled.length})`);
  for (const k of unmodelled) {
    console.log(`  - \`${k}\` is read by nothing. It will be stored and silently ignored.`);
  }
  console.log('  Either model it — parser.js, validate-character.js, the wizard and');
  console.log('  the sheet — or move it into the body as prose so the class can ship');
  console.log('  now. See "When a class needs the app to change" in the class-import');
  console.log('  skill.');
}

// ── field sources ──
// The free-text fields no test pins, traced back to the OCR-cache lines they
// were drawn from. The rule that earns the mode its place: whenever a source
// span ends near the bottom of its page, the first lines of the NEXT page are
// printed too — the two starting_money figures that shipped wrong (PR #280)
// were both paragraphs that continued past a page break the reading stopped
// at. Entirely offline: the cache is local text, so this mode skips D1.
if (fieldSources && data) {
  const booksDir = path.join(repoRoot, '.cache', 'books');
  if (!existsSync(booksDir)) {
    die('no OCR cache at .cache/books — --field-sources reads the cached page text '
      + 'the class was transcribed from, and this machine has none');
  }
  const books = readdirSync(booksDir, { withFileTypes: true })
    .filter((d) => d.isDirectory() && existsSync(path.join(booksDir, d.name, 'txt')))
    .map((d) => {
      const mf = path.join(booksDir, d.name, 'manifest.json');
      let manifest = null;
      if (existsSync(mf)) {
        try { manifest = JSON.parse(readFileSync(mf, 'utf8')); } catch { /* a broken manifest still leaves the slug route */ }
      }
      return { slug: d.name, sourcePdf: manifest?.source_pdf ?? null, manifest };
    });
  if (!books.length) die('no cached books under .cache/books');

  const slug = bookFlag ?? resolveBookSlug(data.source_book, books, bookRegistry);
  if (!slug || !books.some((b) => b.slug === slug)) {
    const known = registryBookSlug(data.source_book, bookRegistry);
    die(`cannot match source_book "${data.source_book ?? ''}" to a cached book — `
      + (known
        ? `scripts/books.json calls that "${slug ?? known}", and it has no cache here. `
          + 'Cache it (scripts/ocr-book.py) or pass --book <slug>. '
        : 'pass --book <slug>. ')
      + `Cached: ${books.map((b) => b.slug).join(', ')}`);
  }

  const range = parseSourcePages(data.source_book);
  if (!range) {
    die(`source_book "${data.source_book ?? ''}" names no pages — the field-source `
      + 'window comes from its p.N or p.N-M suffix');
  }

  const txtDir = path.join(booksDir, slug, 'txt');
  const pages = readdirSync(txtDir)
    .map((f) => f.match(/^p(\d+)\.txt$/))
    .filter(Boolean)
    .map((m) => ({
      page: Number(m[1]),
      lines: readFileSync(path.join(txtDir, m[0]), 'utf8').split(/\r?\n/),
    }))
    .sort((a, b) => a.page - b.page);
  const byPage = new Map(pages.map((p) => [p.page, p.lines]));

  // WHERE THE OFFSET COMES FROM, in order. It used to be live majority vote
  // and nothing else: computed by a human at survey time, discarded, and
  // re-derived here every run. It is a per-book constant that is free to
  // record once and costs a wrong page read every time it is guessed.
  //
  //   --offset            the human overrides everything
  //   scripts/books.json  the durable, hand-checked copy, PER PRINTED PAGE
  //   the manifest        what ocr-book.py measured when it built this cache
  //   live detection      the old route, still here for an unregistered book
  //   0                   and it SAYS so, rather than quietly using it
  //
  // The registry outranks the manifest for the same reason F3 gives: a number
  // read out of the cache cannot judge the cache. The registry is also the
  // only one of the three that can express `pf`, whose offset is +1 for
  // printed 1-16 and +2 after -- a majority vote cannot see that at all,
  // because the minority region is 11 pages against 287.
  const registryEntry = bookRegistry[slug];
  const det = detectPageOffset(pages);
  const trustedLive = det && det.votes >= 3 && det.votes * 2 > det.sampled ? det : null;
  const regions = detectPageOffsetRegions(pages);

  let offset = 0;
  let offsetHow = 'default 0 — nothing records one and the cache shows none';
  if (offsetFlag !== null) {
    offset = Number(offsetFlag);
    offsetHow = 'from --offset';
  } else {
    const fromRegistry = offsetForPrintedPage(range.first, registryEntry);
    const manifestOffset = books.find((b) => b.slug === slug)?.manifest?.page_offset;
    if (fromRegistry) {
      offset = fromRegistry.offset;
      offsetHow = `scripts/books.json, ${fromRegistry.from}`;
    } else if (Number.isInteger(manifestOffset)) {
      offset = manifestOffset;
      offsetHow = `the ${slug} manifest`;
    } else if (trustedLive) {
      offset = trustedLive.offset;
      offsetHow = `detected from ${trustedLive.votes} printed page numbers`
        + ' — not recorded anywhere; add it to scripts/books.json';
    }
  }

  const pdfFirst = range.first + offset;
  const pdfLast = range.last + offset;
  const windowPages = pages.filter((p) => p.page >= pdfFirst && p.page <= pdfLast);

  console.log(`\nFIELD SOURCES (${slug} p.${range.first}`
    + (range.last !== range.first ? `-${range.last}` : '')
    + ` -> files p${pdfFirst}-p${pdfLast}; offset ${offset >= 0 ? '+' : ''}${offset}, ${offsetHow})`);

  // ADVISORY, never the exit code. A disagreement between what is recorded and
  // what the pages say is the signature of a re-cached book, a duplicated
  // page, or a non-constant offset — and the recorded value can be the right
  // one while the cache is newly partial, so this prints and moves on.
  const offsetNotes = [];
  if (offsetFlag === null && trustedLive && trustedLive.offset !== offset) {
    const vote = `${trustedLive.offset >= 0 ? '+' : ''}${trustedLive.offset} `
      + `(${trustedLive.votes}/${trustedLive.sampled})`;
    const used = `${offset >= 0 ? '+' : ''}${offset}`;
    // An EXPECTED disagreement when the page is inside a recorded exception:
    // the whole-book vote is by definition the majority region's, and this
    // page is deliberately not in it. Say which, or the note reads as a fault.
    offsetNotes.push(offsetHow.startsWith('scripts/books.json, printed')
      ? `the whole-book vote is ${vote}; this page is inside the recorded ${used} `
        + 'region, which is why they differ'
      : `the pages themselves vote ${vote}, not ${used}`);
  }
  // A split book is only worth reporting when the registry does NOT already
  // describe it. `pf` splits on every single run, and a note that fires every
  // time is one nobody reads — the check is whether what is recorded RESOLVES
  // each detected region to the offset that region actually shows.
  const unrecorded = regions.filter((r) => 
    offsetForPrintedPage(r.fromPrinted, registryEntry)?.offset !== r.offset
    || offsetForPrintedPage(r.toPrinted, registryEntry)?.offset !== r.offset);
  if (regions.length > 1 && unrecorded.length) {
    offsetNotes.push('this cache paginates in '
      + `${regions.length} ways and scripts/books.json does not say so: `
      + regions.map((r) => `${r.offset >= 0 ? '+' : ''}${r.offset} over printed `
        + `${r.fromPrinted}-${r.toPrinted} (${r.votes})`).join(', '));
    offsetNotes.push(`add \`page_offset_exceptions\` to ${slug} — a majority vote `
      + 'cannot see a minority region, and every lookup inside one lands on the '
      + 'wrong page');
  }
  if (!trustedLive && offsetFlag === null) {
    offsetNotes.push(offsetHow.startsWith('default 0')
      ? 'no printed page number survives anywhere in this cache, and '
        + `scripts/books.json has no page_offset for ${slug} — the window below is a guess`
      : `nothing in the ${slug} cache confirms this offset — no page in it shows a `
        + 'printed folio, so the recorded value is the only evidence there is');
  }
  if (offsetNotes.length) {
    console.log(`  OFFSET (${offsetNotes.length})`);
    for (const n of offsetNotes) console.log(`  ? ${n}`);
    console.log('  Advisory: it does not change the exit code. Check the folio printed');
    console.log('  on the page the window landed on before trusting what follows.');
  }

  if (!windowPages.length) {
    die(`pages p${pdfFirst}-p${pdfLast} are not in the ${slug} cache `
      + `(it holds p${pages[0].page}-p${pages[pages.length - 1].page})`);
  }

  const fields = freeTextFields(data);
  if (!fields.length) {
    console.log('  no free-text fields to trace (no starting_money, no equipment_starting)');
  }

  const clip = (s) => {
    const t = s.replace(/\s+$/, '');
    return t.length > 96 ? t.slice(0, 93) + '...' : t;
  };

  for (const { field, value } of fields) {
    const tokens = fieldTokens(field, value);
    const spans = fieldSourceSpans(tokens, windowPages, { lookup: (n) => byPage.get(n) ?? null });
    console.log(`\n  ${field}: ${clip(value)}`);
    if (!spans.length) {
      console.log(`      no matching lines in p${pdfFirst}-p${pdfLast}`);
      const hints = bestMatchingPages(tokens, pages);
      if (hints.length) {
        console.log('      strongest matches elsewhere: '
          + hints.map((h) => `p${h.page} (score ${h.score})`).join(', '));
        console.log('      if those are the right pages, the printed-page offset is off — pass --offset <n>');
      }
      continue;
    }
    const shown = spans.slice(0, 4);
    for (const s of shown) {
      for (let i = 0; i < s.lines.length; i++) {
        console.log(`      p${s.page}:${String(s.start + i).padStart(3)}  ${clip(s.lines[i])}`);
      }
      if (s.continuation) {
        console.log(`      -- span ends near the bottom of the page -- first lines of p${s.continuation.page}:`);
        if (s.continuation.lines === null) {
          console.log(`      p${s.continuation.page} is not in the cache — the paragraph may continue on a page never read`);
        } else {
          for (const l of s.continuation.lines) console.log(`      p${s.continuation.page}:      ${clip(l)}`);
        }
      }
    }
    if (spans.length > shown.length) {
      console.log(`      (${spans.length - shown.length} weaker span${spans.length - shown.length === 1 ? '' : 's'} not shown)`);
    }
  }
}

// ── catalog cross-reference ──
// Runs the same crossReference() the Confirm endpoint calls, through a shim
// giving it the env.DB shape over `wrangler d1 execute`. Reusing the function
// rather than rewriting its queries is why a clean run here means a clean run
// in the app.
const npxCli = path.join(path.dirname(process.execPath), 'node_modules', 'npm', 'bin', 'npx-cli.js');
const npxCliFound = existsSync(npxCli);

// Same spawn dance as d1-apply.mjs, and for the same reason: Windows npx is a
// .cmd, Node refuses to spawn one unshelled, and `shell: true` concatenates
// argv instead of escaping it. Calling npm's npx-cli.js with this Node keeps a
// real argv array, which matters here because the SQL argument contains spaces
// and quotes.
function wrangler(cliArgs) {
  const opts = { encoding: 'utf8', cwd: repoRoot, maxBuffer: 64 * 1024 * 1024 };
  const r = npxCliFound
    ? spawnSync(process.execPath, [npxCli, ...cliArgs], opts)
    : spawnSync('npx', cliArgs, { ...opts, shell: true });
  return { code: r.status ?? 1, out: (r.stdout || '') + (r.stderr || '') };
}

// D1 has no CLI parameter binding, so the shim inlines the values itself.
// Only ever reached with names out of parsed class data, and only ever inside a
// SELECT, but quoted properly regardless — an apostrophe in a skill name is
// completely ordinary (Sailor's Knots).
const quote = (v) => (v == null ? 'NULL' : `'${String(v).replace(/'/g, "''")}'`);

function inline(sql, params) {
  let out = '';
  let n = 0;
  let inStr = false;
  for (let i = 0; i < sql.length; i++) {
    const c = sql[i];
    if (inStr) {
      out += c;
      if (c === "'") inStr = false;
      continue;
    }
    if (c === "'") { inStr = true; out += c; continue; }
    out += c === '?' ? quote(params[n++]) : c;
  }
  return out;
}

function query(sql) {
  const r = wrangler(['wrangler', 'd1', 'execute', 'DB', remote ? '--remote' : '--local',
    '--json', '--command', sql.replace(/\s+/g, ' ').trim()]);
  if (r.code !== 0) {
    die(`d1 query failed (${remote ? 'remote' : 'local'}).\n${r.out.trim()}\n\n`
      + 'If the local database has never been built:\n'
      + '  node scripts/d1-apply.mjs --local db/schema.sql');
  }
  // wrangler prints human lines around the JSON payload.
  const start = r.out.indexOf('[');
  const end = r.out.lastIndexOf(']');
  if (start < 0 || end < 0) die('could not find JSON in the d1 output:\n' + r.out.trim());
  try {
    return JSON.parse(r.out.slice(start, end + 1))[0]?.results ?? [];
  } catch (e) {
    die('could not parse the d1 JSON output: ' + e.message);
  }
}

// Enough of the D1 binding for catalog.js: prepare().bind().all(), plus the
// prepare() buildStubStatements uses to describe writes this never runs.
const env = {
  DB: {
    prepare(sql) {
      return {
        _sql: sql,
        _args: [],
        bind(...a) { this._args = a; return this; },
        async all() { return { results: query(inline(this._sql, this._args)) }; },
        toSql() { return inline(this._sql, this._args); },
      };
    },
  },
};

const plural = (n, word) => `${n} ${word}${n === 1 ? '' : 's'}`;

// Collected during the catalog pass so --emit-script can reuse exactly the
// statements the report printed, rather than recomputing them differently.
const stubSql = [];
const stubSlugs = [];

if (noCatalog || fieldSources) {
  console.log(`\nCATALOG          skipped (${noCatalog ? '--no-catalog' : '--field-sources is offline'})`);
} else if (!data) {
  console.log('\nCATALOG          skipped (nothing parsed)');
} else {
  const missing = await crossReference(env, null, data);
  const counts = ['items', 'skills', 'spells', 'psionics'].map((k) => [k, missing[k].length]);
  const total = counts.reduce((s, [, n]) => s + n, 0);

  console.log(`\nCATALOG (${remote ? 'REMOTE' : 'local'})`);
  for (const [k, n] of counts) {
    console.log(`  ${k.padEnd(14)} ${n === 0 ? 'ok' : `${plural(n, 'row')} missing`}`);
    for (const name of missing[k]) console.log(`      ${name}`);
  }

  // The quiet one. `categoryAllows` compares literal names, so a restriction
  // naming a skill the catalog spells differently makes an `except` exclude
  // NOTHING — it fails open, offering skills the book forbids, and says so
  // nowhere.
  const restrictions = missing.restrictions;
  if (restrictions.length) {
    console.log(`  ${'restrictions'.padEnd(14)} ${plural(restrictions.length, 'name')}`
      + ` match${restrictions.length === 1 ? 'es' : ''} no skill row`);
    for (const r of restrictions) console.log(`      ${r.category} ${r.kind}: "${r.name}"`);
    console.log('      These do nothing as written. An unmatched `except` excludes');
    console.log('      NOTHING, so the class offers skills the book forbids.');
  } else {
    console.log(`  ${'restrictions'.padEnd(14)} ok`);
  }

  // Restriction names that DO resolve, but to a row in another category. The
  // missing-row check above cannot see these - the name matches a skill, so it
  // stays quiet - yet they are the same kind of silent failure.
  const wanted = restrictionNames(data);
  if (wanted.length) {
    const names = [...new Set(wanted.map((w) => w.name))];
    const rows = query('SELECT name, category FROM skills WHERE name IN ('
      + names.map((n) => quote(n)).join(',') + ')');
    const categoryOf = new Map(rows.map((r) => [String(r.name).trim().toLowerCase(), r.category]));
    const { granted, unreachable, noop } = crossCategoryRestrictions(data, categoryOf);

    // The defect. categoryAllows admits a cross-category `only` ONLY when the
    // class also lists the skill's real category, so without it the class
    // grants a skill nobody can take.
    if (unreachable.length) {
      console.log(`
  ${'unreachable'.padEnd(14)} ${plural(unreachable.length, 'name')} granted but not takeable`);
      for (const u of unreachable) {
        console.log(`      ${u.category} only: "${u.name}" - the catalog files it under `
          + `${u.actual ?? 'no category'}, which this class does not grant`);
      }
      console.log('      A cross-category `only` is admitted only when the class also');
      console.log("      lists that skill's real category. Add it, or drop the name.");
    }

    if (granted.length) {
      console.log(`
  ${'cross-category'.padEnd(14)} ${plural(granted.length, 'name')} granted from another category`);
      for (const g of granted) {
        console.log(`      ${g.category} only: "${g.name}" - the catalog files it under ${g.actual ?? 'no category'}`);
      }
      console.log('      These work: the class lists that category too, so the name');
      console.log('      match is admitted - which is what the book means.');
    }

    if (noop.length) {
      console.log(`
  ${'no-op except'.padEnd(14)} ${plural(noop.length, 'name')} excluded from the wrong category`);
      for (const n of noop) {
        console.log(`      ${n.category} except: "${n.name}" - the catalog files it under ${n.actual ?? 'no category'}`);
      }
      console.log('      These exclude NOTHING - the skill was never offered in that');
      console.log('      category. Harmless, but the category is probably wrong.');
    }
  }

  // The stub rows the class needs, as SQL to paste into the data script. The
  // app creates these itself on Confirm; a data script has to carry its own,
  // and writing them by hand is where the STUB marker and the char(8212) splice
  // get forgotten.
  if (total) {
    const { statements } = buildStubStatements(env, missing, {
      system: data.system,
      sourceBook: data.source_book ?? null,
    });
    for (const s of statements) {
      stubSql.push(s.toSql().replace(/\s+/g, ' ').trim()
        .replace(/'STUB — /, "'STUB ' || char(8212) || ' ") + ';');
    }
    console.log('\nSTUB SQL — paste above the imported_classes INSERT');
    console.log('(em-dash spliced with char(8212), per the ASCII-only rule)\n');
    for (const s of stubSql) console.log('  ' + s);
    stubSlugs.push(...missing.items);
  }
}

const blocking = errors.length + preflight.length;
console.log(`\nclass-check: ${blocking ? 'NOT ready' : 'ready'} — `
  + `${plural(errors.length, 'error')}, ${plural(warnings.length, 'warning')}`
  + (preflight.length ? `, ${plural(preflight.length, 'pre-flight failure')}` : '')
  + (unmodelled.length ? `, ${plural(unmodelled.length, 'unmodelled key')}` : '')
  + (unclosed.length ? `, ${plural(unclosed.length, 'unclosed flow value')}` : ''));

// ── --emit-script: the validated draft, as the data script that ships ──
//
// INGESTION-AUDIT F15 part 2. What is worth automating here is the ESCAPING,
// not the decision to ship: copying markdown into the template by hand is
// where the doubled apostrophe and the char() splice get forgotten, once per
// class. So this writes to stdout, writes no file, and applies nothing, and
// running class-check on the resulting .sql stays a separate step - the
// ASCII/CRLF pre-flight has to fire against the real artifact, not against
// this function's intentions.
if (emitScript !== null) {
  if (blocking) {
    die(`refusing to emit a script from a draft with ${plural(blocking, 'blocking finding')}`);
  }
  if (data.id !== emitScript) {
    die(`--emit-script says "${emitScript}" and the frontmatter says "${data.id}"`);
  }

  // Every apostrophe doubled, every non-ASCII codepoint spliced out with
  // char(). The whole emitted file has to be pure ASCII: the smoke suite reads
  // the RAW BYTES of every data script - comments included, not just the
  // executable SQL - and d1-apply refuses a file with a high byte in it,
  // because wrangler on Windows has turned those into mojibake in production.
  const literal = (s) => {
    const parts = [];
    let lit = '';
    const flush = () => {
      if (lit !== '') { parts.push("'" + lit.replace(/'/g, "''") + "'"); lit = ''; }
    };
    for (const ch of s) {
      if (ch.codePointAt(0) > 0x7f) { flush(); parts.push(`char(${ch.codePointAt(0)})`); }
      else lit += ch;
    }
    flush();
    return parts.length ? parts.join(' || ') : "''";
  };

  // A CR reaching the stored markdown is the bug the readback SELECT at the
  // bottom of every one of these scripts exists to catch. The draft is often
  // CRLF on this machine, so strip it here rather than emitting a file that
  // fails its own readback.
  const md = markdown.replace(/\r\n/g, '\n').replace(/\r/g, '\n');
  const filename = `add-${emitScript}-class.sql`;
  const kind = data.category === 'rcc' ? 'R.C.C.' : 'O.C.C.';
  const out = [];

  out.push(`-- The ${data.name} ${kind}, ${data.source_book ?? 'source book not stated'}.`);
  out.push('--');
  out.push('-- One-off data script, run once per environment. NOT a migration - it adds');
  out.push('-- rows, not schema.');
  out.push('--');
  out.push(`--   node scripts/d1-apply.mjs --local apps/character-creator/db/${filename}`);
  out.push('--');
  out.push('-- Generated by scripts/class-check.mjs --emit-script from a validated draft.');
  out.push('-- Apostrophes are doubled and non-ASCII is spliced with char(); CR is stripped.');
  out.push('-- Run class-check on THIS file before applying - the ASCII/CRLF pre-flight only');
  out.push('-- fires against the real artifact.');
  out.push('');

  if (stubSql.length) {
    out.push('');
    out.push('-- Stub rows for anything the class references that the catalog lacks.');
    out.push('-- The "STUB" marker is load-bearing: it is how the gear importer later');
    out.push('-- recognises a row as still needing stats.');
    for (const s of stubSql) out.push(s);
    out.push('');
  }

  out.push('');
  out.push('-- The class itself. INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE,');
  out.push('-- so re-running the script is a no-op instead of a silent partial write.');
  out.push('INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)');
  out.push(`SELECT ${literal(data.id)}, ${literal(data.name)}, ${literal(data.system)}, ${literal(md)}, 'published', 'data-script'`);
  out.push(`WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = ${literal(data.id)});`);
  out.push('');
  out.push('');
  out.push('-- Read the result back rather than trusting the exit code. d1-apply prints');
  out.push('-- these, and a CR in the stored markdown means the checkout mangled the file.');
  out.push('SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr');
  out.push(`  FROM imported_classes WHERE class_id = ${literal(data.id)};`);
  if (stubSlugs.length) {
    out.push(`SELECT count(*) AS stub_gear FROM gear WHERE slug IN (${stubSlugs.map(literal).join(', ')});`);
  }
  out.push('');
  out.push('-- Records this run. REQUIRED: the smoke test fails a data script that has no');
  out.push('-- footer, or whose footer names a different file.');
  out.push(`INSERT INTO data_script_runs (filename) VALUES ('${filename}');`);
  out.push('');

  // \n, never the platform newline: .gitattributes pins *.sql to LF and a CR
  // in here would fail the pre-flight this script itself runs.
  process.stdout.write(out.join('\n'));
  console.log(`\nclass-check: emitted ${filename} to stdout `
    + `(${plural(stubSql.length, 'stub statement')}, nothing written, nothing applied)`);
}

process.exit(blocking ? 1 : 0);
