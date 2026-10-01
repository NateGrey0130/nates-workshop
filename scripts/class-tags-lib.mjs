// The pure half of class-tags.mjs, split out so the smoke suite can call it
// without wrangler: the review table's writer and reader, and the data script
// it becomes.
//
// THE REVIEW TABLE IS THE HAND-OFF. `--suggest` writes one row per class with
// its guessed tags in the last column; a person edits that column; `--emit`
// reads it back. A markdown table rather than JSON because it is read and
// edited by a person first and a program second.

import { CLASS_TAGS, MAX_AUTHORED_TAGS, classTags, suggestClassTags } from '../apps/character-creator/js/parser.js';

const AUTHORED = new Set(CLASS_TAGS.filter((t) => t.kind === 'authored').map((t) => t.id));
// The most classes one script may tag. d1-apply replays a file's trailing
// SELECTs as ONE --command, and on Windows that line is capped at 8,191
// characters once cmd.exe has escaped it (READBACK_BUDGET there, 7,900). A
// read-back naming all 373 tagged Rifts classes passed it, so the assertions
// went unevaluated after the apply had landed. A hundred ids is about 4,000.
export const MAX_ROWS_PER_SCRIPT = 100;

/**
 * A large system's rows as several scripts on consecutive tilde numbers:
 * `~048-class-tags-rifts.sql` with 373 rows becomes `~048-class-tags-rifts-1`
 * through `~051-class-tags-rifts-4`. Returns [{ filename, rows }].
 */
export function splitScripts(rows, filename) {
  const m = filename.match(/^~(\d{3})-(.+)\.sql$/);
  if (!m) throw new Error(`${filename}: a class-tags script is a ~NNN-<slug>.sql script`);
  if (rows.length <= MAX_ROWS_PER_SCRIPT) return [{ filename, rows }];
  const parts = Math.ceil(rows.length / MAX_ROWS_PER_SCRIPT);
  const size = Math.ceil(rows.length / parts);
  return Array.from({ length: parts }, (_, i) => ({
    filename: `~${String(Number(m[1]) + i).padStart(3, '0')}-${m[2]}-${i + 1}.sql`,
    rows: rows.slice(i * size, (i + 1) * size),
  }));
}
const DERIVED = new Set(CLASS_TAGS.filter((t) => t.kind === 'derived').map((t) => t.id));
const COLUMNS = ['class_id', 'name', 'category', 'source_book', 'derived', 'tags'];

const cell = (v) => String(v ?? '').replace(/\|/g, '/').replace(/\s+/g, ' ').trim();

/**
 * The review table for a list of parsed classes. A class that already carries
 * authored tags shows those rather than a guess, so re-running a review over a
 * half-tagged system does not propose changes nobody asked for.
 */
export function reviewTable(classes, { system } = {}) {
  const rows = [...classes].sort((a, b) =>
    String(a.source_book || '').localeCompare(String(b.source_book || ''))
    || String(a.name || '').localeCompare(String(b.name || '')));
  const lines = [
    `# Class tags review${system ? `: ${system}` : ''}`,
    '',
    'Edit the **tags** column only: comma-separated, at most '
      + `${MAX_AUTHORED_TAGS}, from: ${[...AUTHORED].join(', ')}.`,
    'Empty the cell to leave a class untagged. **derived** is computed and is shown only',
    'so you do not repeat it. A derived tag the column lacks may be written for a class',
    'whose book grants it without the block (Heroes Unlimited Magic).',
    '',
    `| ${COLUMNS.join(' | ')} |`,
    `|${COLUMNS.map(() => '---').join('|')}|`,
  ];
  for (const c of rows) {
    const authored = Array.isArray(c.tags) ? c.tags : suggestClassTags(c);
    const derived = classTags({ ...c, tags: [] });
    lines.push(`| ${[c.id, c.name, c.category, c.source_book, derived.join(', '), authored.join(', ')]
      .map(cell).join(' | ')} |`);
  }
  return lines.join('\n') + '\n';
}

/**
 * The review table read back: `{ rows: [{ class_id, category, tags }], errors }`.
 * Every tag is checked against the vocabulary HERE, before any SQL exists,
 * because the parser's refusal of a bad tag would otherwise surface as a class
 * missing from production's picker.
 */
export function parseReview(text) {
  const errors = [];
  const rows = [];
  let header = null;
  for (const [i, raw] of String(text).split(/\r?\n/).entries()) {
    const line = raw.trim();
    if (!line.startsWith('|')) continue;
    const cells = line.replace(/^\||\|$/g, '').split('|').map((s) => s.trim());
    if (!header) { header = cells; continue; }
    if (cells.every((c) => /^-+$/.test(c))) continue;
    const r = Object.fromEntries(header.map((h, k) => [h, cells[k] ?? '']));
    const where = `line ${i + 1} (${r.class_id || '?'})`;
    if (!/^[a-z0-9][a-z0-9-]*$/.test(r.class_id || '')) { errors.push(`${where}: no class_id`); continue; }
    if (!['occ', 'rcc'].includes(r.category)) { errors.push(`${where}: category must be occ or rcc`); continue; }
    const tags = String(r.tags || '').split(',').map((s) => s.trim()).filter(Boolean);
    // A derived tag is refused only where the derived column already has it:
    // the parser draws the same line, and refuses it there (CLASS_TAGS).
    const derivedHere = String(r.derived || '').split(',').map((x) => x.trim());
    const bad = tags.filter((t) => !AUTHORED.has(t) && !DERIVED.has(t));
    if (bad.length) errors.push(`${where}: not a class tag: ${bad.join(', ')}`);
    const repeated = tags.filter((t) => DERIVED.has(t) && derivedHere.includes(t));
    if (repeated.length) errors.push(`${where}: already derived, never written: ${repeated.join(', ')}`);
    if (new Set(tags).size !== tags.length) errors.push(`${where}: a tag is repeated`);
    if (tags.length > MAX_AUTHORED_TAGS) errors.push(`${where}: ${tags.length} tags, at most ${MAX_AUTHORED_TAGS}`);
    if (tags.length) rows.push({ class_id: r.class_id, category: r.category, tags });
  }
  if (!header) errors.push('no table found');
  else if (!COLUMNS.every((c) => header.includes(c))) errors.push(`the table needs the columns ${COLUMNS.join(', ')}`);
  return { rows, errors };
}

/**
 * The data script. Each class gets its `tags:` line after its `category:`
 * line, GUARDED on having no `tags:` line yet: in production a second run, or
 * a run after someone tagged a class by hand, changes nothing. The filename
 * must be a tilde script, which sorts after every `fix-` - seven of those
 * rewrite a class's whole markdown and would erase the line on a rebuild.
 */
export function emitSql(rows, { filename, system }) {
  if (!/^~\d{3}-/.test(filename)) throw new Error(`${filename}: a class-tags script is a ~NNN- script`);
  if (rows.length > MAX_ROWS_PER_SCRIPT) {
    throw new Error(`${rows.length} classes in one script; at most ${MAX_ROWS_PER_SCRIPT}, or its `
      + 'read-back passes the Windows command line d1-apply replays it over (splitScripts)');
  }
  const nl = "char(10)";
  const out = [
    `-- Authored class tags for ${system || 'these'} classes, one line each, from a reviewed`,
    '-- scripts/class-tags.mjs table. Derived tags (magic, psionics, mega-damage,',
    '-- horror-factor) are computed from the class and never written.',
    '--',
    '-- One-off data script, run once per environment. NOT a migration.',
    '--',
    `--   node scripts/d1-apply.mjs --local apps/character-creator/db/${filename}`,
    '--',
    '-- A TILDE SCRIPT ON PURPOSE: seven fix- scripts rewrite a class\'s whole',
    '-- markdown, and any that sorted after this file would erase the tags on a',
    '-- rebuild. Guarded on the class having no tags line, so a re-run is a no-op.',
    '-- The tilde number is claimed at merge.',
    '',
  ];
  for (const r of rows) {
    const cat = `'category: ${r.category}'`;
    out.push(`UPDATE imported_classes SET markdown = replace(markdown, ${nl} || ${cat} || ${nl}, `
      + `${nl} || ${cat} || ${nl} || 'tags: [${r.tags.join(', ')}]' || ${nl}), updated_at = datetime('now') `
      + `WHERE class_id = '${r.class_id}' AND instr(markdown, ${nl} || 'tags:') = 0;`);
  }
  const ids = rows.map((r) => `'${r.class_id}'`).join(', ');
  out.push('',
    `SELECT 'the ${rows.length} reviewed classes carry a tags line' AS assertion, count(*) AS got, ${rows.length} AS want `
      + `FROM imported_classes WHERE class_id IN (${ids}) AND instr(markdown, ${nl} || 'tags: [') > 0;`,
    '',
    '-- Records this run. See db/migrations/024-data-script-runs.sql.',
    `INSERT INTO data_script_runs (filename) VALUES ('${filename}');`,
    '');
  return out.join('\n');
}
