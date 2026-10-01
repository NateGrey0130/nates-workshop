#!/usr/bin/env node
// Backfill authored class tags, one system at a time.
//
//   node scripts/class-tags.mjs --suggest --system rifts --out <review.md> [--local]
//   node scripts/class-tags.mjs --emit <review.md> --out apps/character-creator/db/~NNN-class-tags-rifts.sql
//
// --suggest reads the published classes of one system - from PRODUCTION unless
// --local is passed, because production wins on a value (F105) - and writes a
// review table with a guessed `tags` column. A person edits that column.
// --emit turns the edited table into a guarded ~NNN- data script, refusing any
// tag the vocabulary in js/parser.js does not hold. It reads no database.
//
// The guesses come from suggestClassTags() in js/parser.js. They are a starting
// point: a table emitted unread ships the heuristics as if they were the book.

import { readFileSync, writeFileSync } from 'node:fs';
import { basename, dirname, join } from 'node:path';
import { parseClassMarkdown } from '../apps/character-creator/js/parser.js';
import { d1Query, targetFromArgv } from './d1-query-lib.mjs';
import { reviewTable, parseReview, emitSql, splitScripts } from './class-tags-lib.mjs';

const argv = process.argv.slice(2);
const arg = (name) => {
  const i = argv.indexOf(name);
  return i >= 0 ? argv[i + 1] : undefined;
};
const die = (msg) => { console.error(`class-tags: ${msg}`); process.exit(1); };

const out = arg('--out');
if (!out) die('--out <path> is required');

if (argv.includes('--suggest')) {
  const system = arg('--system');
  if (!system || !/^[a-z-]+$/.test(system)) die('--suggest needs --system <rifts|palladium-fantasy|heroes-unlimited|nightbane>');
  const target = targetFromArgv(process.argv);
  const rows = d1Query(
    `SELECT class_id, markdown FROM imported_classes WHERE status = 'published' AND deleted_at IS NULL AND system = '${system}'`,
    { target });
  const classes = [];
  for (const r of rows) {
    const p = parseClassMarkdown(r.markdown);
    if (p.ok) classes.push(p.data);
    else console.error(`  skipped ${r.class_id}: ${p.errors[0]}`);
  }
  if (!classes.length) die(`no published ${system} classes on ${target}`);
  writeFileSync(out, reviewTable(classes, { system }));
  const tagged = classes.filter((c) => Array.isArray(c.tags)).length;
  console.log(`${classes.length} ${system} classes from ${target} -> ${out}`
    + (tagged ? ` (${tagged} already carry tags, shown as they are)` : ''));
} else if (arg('--emit')) {
  const { rows, errors } = parseReview(readFileSync(arg('--emit'), 'utf8'));
  if (errors.length) die(`the review table has ${errors.length} problem(s):\n  ${errors.join('\n  ')}`);
  if (!rows.length) die('no row carries a tag; nothing to emit');
  const system = arg('--system') || (basename(out).match(/class-tags-([a-z-]+)\.sql$/) || [])[1];
  // More than MAX_ROWS_PER_SCRIPT rows go out as several scripts on
  // consecutive tilde numbers, each with a read-back short enough to replay.
  const parts = splitScripts(rows, basename(out));
  for (const p of parts) {
    const path = join(dirname(out), p.filename);
    writeFileSync(path, emitSql(p.rows, { filename: p.filename, system }));
    console.log(`${p.rows.length} classes -> ${path}`);
  }
  console.log(`${rows.length} classes in ${parts.length} script(s). Apply with d1-apply.mjs, --local first; `
    + 'each tilde number is claimed at merge.');
} else {
  die('pass --suggest or --emit');
}
