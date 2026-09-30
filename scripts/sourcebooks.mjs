#!/usr/bin/env node
// The Sourcebooks pages' lists: every book whose data is in the app, per
// system, built from what already records it. Nothing here is typed by hand.
//
//   node scripts/sourcebooks.mjs            write both lists
//   node scripts/sourcebooks.mjs --check    exit 1 if either committed list is stale
//
// Writes apps/sourcebooks/palladium/books.json and apps/sourcebooks/marvel/books.json.
// Each is owned by its group (groups.json), so a book's own PR rebuilds its own
// list, and each group's smoke suite fails when a book PR forgets to
// (apps/character-creator/test/checks/sourcebooks-list.mjs, and the Marvel suite).
//
// PALLADIUM / RIFTS. A book is listed when its survey's `**Status:**` line
// says `imported` or `backfilled` (apps/character-creator/docs/surveys/, the
// statuses docs/surveys/README.md defines): its data is in the app. `excluded`
// and a registry entry with no survey are not. The title is the registry's
// (scripts/books.json); the catalog cites a book by title and records no
// product number, so its code is the app's own short name for it, the slug.
// What it added is the survey's `**Rows citing this book:**` line, the count
// test/regression.mjs pins; the date is the one the Status line ends with,
// which is when that status was recorded - not always when the import
// finished (a 2026-09-24 sweep re-recorded most), so the page says so.
//
// MARVEL. A book is listed when data/npcs.json has characters from it, in
// registry order (scripts/msh/books.json). Its code is TSR's; what it added is
// counted from the committed data files and the survey's Rows line (the
// msh_book_text rows read back from production); the date is that read-back's.

import { readFileSync, readdirSync, writeFileSync, existsSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { parseRowsLine } from './book-rows-lib.mjs';

export const repoRoot = join(dirname(fileURLToPath(import.meta.url)), '..');
export const OUT = {
  palladium: 'apps/sourcebooks/palladium/books.json',
  marvel: 'apps/sourcebooks/marvel/books.json',
};

const LISTED = ['imported', 'backfilled'];
const TABLE_NAME = { notable_npcs: 'Notable NPCs', npcs: 'NPCs', occ: 'O.C.C.s', rcc: 'R.C.C.s' };
const tableName = (t) => TABLE_NAME[t] || (t.charAt(0).toUpperCase() + t.slice(1)).replace(/_/g, ' ');
const json = (root, p) => JSON.parse(readFileSync(join(root, p), 'utf8'));

export function buildPalladium(root = repoRoot) {
  const registry = json(root, 'scripts/books.json').books;
  const dir = join(root, 'apps/character-creator/docs/surveys');
  const books = [];
  for (const f of readdirSync(dir).filter((n) => n.endsWith('.md') && n !== 'README.md').sort()) {
    const slug = f.slice(0, -3);
    const text = readFileSync(join(dir, f), 'utf8');
    const status = /^\*\*Status:\*\* `([a-z-]+)`/m.exec(text)?.[1];
    if (!LISTED.includes(status)) continue;
    const line = /^\*\*Status:\*\*.*$/m.exec(text)[0];
    const dates = [...line.matchAll(/\((\d{4}-\d{2}-\d{2})\)/g)];
    const rows = parseRowsLine(text) || {};
    if (!registry[slug]) throw new Error(`${f} has a survey but scripts/books.json has no ${slug}`);
    books.push({
      slug, title: registry[slug].title, code: slug, status,
      date: dates.length ? dates[dates.length - 1][1] : null,
      added: Object.entries(rows).sort(([a], [b]) => a.localeCompare(b)).map(([t, n]) => [tableName(t), n]),
      total: Object.values(rows).reduce((s, n) => s + n, 0),
    });
  }
  // numeric, so World Book 2 comes before World Book 10
  books.sort((a, b) => a.title.localeCompare(b.title, 'en', { numeric: true }));
  return {
    system: 'palladium', title: 'Palladium / Rifts sourcebooks',
    about: 'Every Palladium and Rifts book whose data is in the app: imported from a full survey of the book, or backfilled from rows that arrived before surveys existed and were given their pages later. Each count is the rows in the app that cite that book.',
    unit: 'rows',
    books,
  };
}

export function buildMarvel(root = repoRoot) {
  const registry = json(root, 'scripts/msh/books.json').books;
  const data = (f, key) => json(root, `apps/marvel-heroes/data/${f}`)[key];
  const chars = data('npcs.json', 'characters');
  const items = data('items.json', 'items');
  const books = [];
  for (const [slug, b] of Object.entries(registry)) {
    const mine = chars.filter((c) => c.book === slug);
    if (!mine.length) continue;
    const survey = join(root, `apps/marvel-heroes/docs/surveys/${slug}.md`);
    const text = existsSync(survey) ? readFileSync(survey, 'utf8') : '';
    const m = /^\*\*Rows citing this book:\*\* (\d[\d,]*) `msh_book_text` rows[\s\S]*?read back (\d{4}-\d{2}-\d{2})/m.exec(text);
    const added = [
      ['Characters', mine.length],
      ['Items and locations', items.filter((i) => i.book === slug).length],
      ['Rows of the book\'s text', m ? Number(m[1].replace(/,/g, '')) : 0],
    ].filter(([, n]) => n);
    books.push({
      slug, title: b.title, code: b.code, status: 'imported', date: m ? m[2] : null,
      added, total: mine.length,
    });
  }
  return {
    system: 'marvel', title: 'Marvel Super Heroes sourcebooks',
    about: 'Every Marvel Super Heroes book whose characters are in the Codex and the GM tools, with what else it brought: its items and locations, and the rows of its own text the cards show.',
    unit: 'characters',
    books,
  };
}

export const BUILD = { palladium: buildPalladium, marvel: buildMarvel };
export const render = (list) => JSON.stringify(list, null, 1) + '\n';

// The committed list against a fresh build: null when they agree, else why not.
export function stale(system, root = repoRoot) {
  const path = join(root, OUT[system]);
  const want = render(BUILD[system](root));
  if (!existsSync(path)) return `${OUT[system]} is missing`;
  return readFileSync(path, 'utf8').replace(/\r\n/g, '\n') === want ? null
    : `${OUT[system]} is stale; run node scripts/sourcebooks.mjs and commit it`;
}

if (process.argv[1] && fileURLToPath(import.meta.url) === process.argv[1]) {
  if (process.argv.includes('--check')) {
    const bad = Object.keys(OUT).map((s) => stale(s)).filter(Boolean);
    for (const b of bad) console.log(b);
    process.exit(bad.length ? 1 : 0);
  }
  for (const [system, p] of Object.entries(OUT)) {
    const list = BUILD[system]();
    writeFileSync(join(repoRoot, p), render(list));
    console.log(`${p}: ${list.books.length} books`);
  }
}
