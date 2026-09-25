// How many rows cite each book, per table - the count a survey pins.
//
// Each survey carries one line under its status:
//
//   **Rows citing this book:** classes 8, gear 40, creatures 25
//
// and test/regression.mjs checks it against a database built from nothing.
// That replaced the clean-run TOTALS in docs/operations.md (2026-09-24). A
// total moved with every import, so two book sessions in parallel both edited
// the same line and the second to merge was always wrong. A book's own line
// moves only with that book. Rows whose book has no survey - no source_book,
// a not-a-book marker, a registry-only slug - are one shared count, and the
// two together still account for every counted row.
//
// The tables are every one in db/schema.sql with a `source_book` column, read
// from the schema rather than listed here, plus published classes, whose
// source_book is in their markdown frontmatter. source-coverage.mjs keeps its
// own hand-written list of the same tables; this does not add a third.

import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { resolveBookSlug } from './class-check-lib.mjs';

// The class's source_book is a frontmatter line, sliced out in SQL, exactly as
// source-coverage.mjs does it.
const FRONTMATTER = "trim(replace(substr(markdown, instr(markdown, 'source_book:') + 12, "
  + "instr(substr(markdown, instr(markdown, 'source_book:') + 12), char(10)) - 1), char(13), ''))";

export function citingTables(repoRoot) {
  const schema = readFileSync(join(repoRoot, 'db', 'schema.sql'), 'utf8');
  const out = [];
  for (const m of schema.matchAll(/CREATE TABLE IF NOT EXISTS (\w+) \(([\s\S]*?)\n\);/g)) {
    if (/^\s*source_book\b/m.test(m[2])) out.push(m[1]);
  }
  return out;
}

// One --command, so a caller that pays for a wrangler spawn pays once. It is
// several statements, though, because D1 refuses a compound SELECT of more
// than FIVE terms ("too many terms in compound SELECT"), measured 2026-09-24.
// Node's own SQLite takes all fifteen in one, which is why a build with
// rebuild-local.mjs is no test of this. wrangler returns one result block per
// statement, and both readers flatten them.
const MAX_TERMS = 5;
export function bookRowsSql(tables) {
  const terms = [
    `SELECT 'classes' AS t, ${FRONTMATTER} AS sb FROM imported_classes `
      + "WHERE deleted_at IS NULL AND status = 'published'",
    ...tables.map((t) => `SELECT '${t}' AS t, source_book AS sb FROM ${t}`),
  ];
  const statements = [];
  for (let i = 0; i < terms.length; i += MAX_TERMS) statements.push(terms.slice(i, i + MAX_TERMS).join(' UNION ALL '));
  return statements.join('; ');
}

// rows: [{ t, sb }]. surveyed: the slugs that have a survey.
// Returns { perBook: { slug: { table: n } }, unsurveyed: n }.
export function countRowsPerBook(rows, { registry, notBooks = [], surveyed }) {
  const books = Object.keys(registry).map((slug) => ({ slug, sourcePdf: registry[slug]?.source_pdf ?? null }));
  const memo = new Map();
  const perBook = {};
  let unsurveyed = 0;
  for (const { t, sb } of rows) {
    if (!memo.has(sb)) memo.set(sb, sb ? resolveBookSlug(sb, books, registry, notBooks) : null);
    const slug = memo.get(sb);
    if (!slug || !surveyed.includes(slug)) { unsurveyed++; continue; }
    const b = (perBook[slug] ??= {});
    b[t] = (b[t] ?? 0) + 1;
  }
  return { perBook, unsurveyed };
}

// The survey line's text, tables in a fixed order: classes first, then the
// order the schema declares them in.
export function formatRowsLine(counts, tables) {
  const order = ['classes', ...tables];
  const parts = order.filter((t) => counts[t]).map((t) => `${t} ${counts[t]}`);
  return `**Rows citing this book:** ${parts.length ? parts.join(', ') : 'none'}`;
}

// { table: n } from a survey's text, {} for `none`, null when the line is absent.
export function parseRowsLine(text) {
  const m = /^\*\*Rows citing this book:\*\* (.+)$/m.exec(text);
  if (!m) return null;
  const body = m[1].trim();
  if (body === 'none') return {};
  const out = {};
  for (const part of body.split(',')) {
    const pm = /^\s*([a-z_]+) (\d+)\s*$/.exec(part);
    if (!pm) return null;
    out[pm[1]] = Number(pm[2]);
  }
  return out;
}
