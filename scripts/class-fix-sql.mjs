#!/usr/bin/env node
// Turn finished class markdown into ONE data script that REPLACES each class's
// stored markdown whole, guarded so it cannot fire against a row edited since.
//
//   node scripts/class-fix-sql.mjs <fix-dir> <out.sql> [--title "..."] [--notes <file>] [--remote]
//   node scripts/class-fix-sql.mjs --self-test
//
// BOOK-INGEST-AUDIT F124, the shape scripts/bestiary-sql.mjs took under F112.
// The retrospective's two percentile-table scripts rewrote thirteen classes
// whole, from a generator in a session scratchpad; this is that generator,
// tracked. A small correction is still a hand-written `replace()` in a `fix-`
// script (class-import -> Correcting a class that already shipped); this is
// for the edit too large for that - a prose table turned into a pick group.
// OPT-IN: no check requires it, and it refuses to overwrite a file that exists.
//
// INPUT. <fix-dir> holds `fixes.json` and one `<class_id>.md` per entry:
//
//   [ { "class_id": "amphib",
//       "guard": "Rolled on a percentile table, and it changes real numbers.",
//       "old_length": 9883,
//       "proof": "Appearance (01-20): Perfect Human" } ]
//
//   guard       a sentence of the OLD markdown that the new one no longer has.
//               The UPDATE fires only on a row that still holds it, so a re-run
//               is a no-op and a row edited since is left alone.
//   guard_absent  INSTEAD of guard, for a class whose old text has no sentence
//               to name: a string the OLD markdown LACKS and the new one has
//               ("special_abilities:" for a class gaining its first block).
//               The UPDATE fires only while it is still absent. One of the two
//               is required, never both.
//   old_length  length(markdown) of the row being replaced. THE STORED TRAILING
//               NEWLINE COUNTS (the ledger's lesson from #1657): ask the
//               database, do not measure a file. `--remote` asks production
//               and fills it in, and checks the guard is really there.
//   proof       a string only the NEW markdown has. The read-back looks for it.
//
// WHAT IT REFUSES, all of it reported in one pass, and nothing is written:
//   - a markdown file that fails `parseClassMarkdown`, or whose `id` is not
//     the entry's class_id - a class that fails to parse vanishes from every
//     picker, so a broken one never reaches a script;
//   - a guard the new markdown still contains, a proof it lacks, or a proof
//     the guard contains;
//   - a missing old_length (without --remote), or with --remote a class
//     production does not hold, or whose stored markdown lacks the guard;
//   - a CR, or any character outside printable ASCII, in the markdown.
//
// OUTPUT. One UPDATE per class with its two guards, then read-backs - every
// class carries its proof, none still carries its guard, none holds a CR -
// then the `data_script_runs` line. A guard that matched nothing fails the
// first read-back rather than passing silently.

import { readFileSync, writeFileSync, existsSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { parseClassMarkdown } from '../apps/character-creator/js/parser.js';
import { sqlLiteral, inList, footer, asciiProblem, noteLines, outNameProblem, scriptProblem, titleProblem, parseArgs } from './sql-gen-lib.mjs';

// `stored` maps class_id -> production's markdown, when --remote was asked.
function buildFixes(entries, markdownOf, stored = null) {
  const refusals = [];
  const fixes = [];
  const seen = new Set();
  if (!Array.isArray(entries) || !entries.length) return { fixes, refusals: ['fixes.json must be a non-empty list'] };
  for (const e of entries) {
    const id = e?.class_id;
    const where = `${id ?? '(no class_id)'}`;
    if (typeof id !== 'string' || !/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(id)) { refusals.push(`${where}: class_id must be a kebab-case slug`); continue; }
    if (seen.has(id)) refusals.push(`${where}: listed twice`);
    seen.add(id);
    let md = markdownOf(id);
    if (md == null) { refusals.push(`${where}: no ${id}.md beside fixes.json`); continue; }
    if (md.includes('\r')) refusals.push(`${where}: the markdown holds a CR - save it with LF endings`);
    md = md.replace(/\r\n/g, '\n');
    const bad = md.split('\n').map((l, i) => [i + 1, asciiProblem(l)]).find(([, p]) => p);
    if (bad) refusals.push(`${where}: line ${bad[0]} holds a character outside printable ASCII (${bad[1]})`);
    const parsed = parseClassMarkdown(md);
    if (!parsed.ok) refusals.push(`${where}: the new markdown does not parse - ${parsed.errors.slice(0, 3).join('; ')}`);
    else if (parsed.data.id !== id) refusals.push(`${where}: the markdown's id is "${parsed.data.id}"`);

    const guard = typeof e.guard === 'string' ? e.guard : '';
    const absent = typeof e.guard_absent === 'string' ? e.guard_absent : '';
    const proof = typeof e.proof === 'string' ? e.proof : '';
    if (guard.trim() && absent.trim()) refusals.push(`${where}: state guard or guard_absent, not both`);
    else if (!guard.trim() && !absent.trim()) {
      refusals.push(`${where}: guard is required - a sentence of the OLD markdown - or guard_absent, a string it lacks`);
    } else if (guard.trim() && md.includes(guard)) {
      refusals.push(`${where}: the new markdown still contains the guard, so a re-run would fire again`);
    } else if (absent.trim() && !md.includes(absent)) {
      refusals.push(`${where}: the new markdown does not contain guard_absent, so a re-run would fire again`);
    }
    if (!proof.trim()) refusals.push(`${where}: proof is required - a string only the NEW markdown has`);
    else if (!md.includes(proof)) refusals.push(`${where}: the new markdown does not contain the proof`);
    else if (guard && guard.includes(proof)) refusals.push(`${where}: the guard contains the proof, so the read-back could not tell old from new`);
    for (const [k, v] of [['guard', guard], ['guard_absent', absent], ['proof', proof]]) {
      const p = asciiProblem(v);
      if (p) refusals.push(`${where}: ${k} holds a character outside printable ASCII (${p})`);
    }

    let oldLength = e.old_length;
    if (stored) {
      const held = stored.get(id);
      if (held == null) refusals.push(`${where}: production holds no such class`);
      else {
        if (guard && !held.includes(guard)) refusals.push(`${where}: production's markdown does not contain the guard`);
        if (absent && held.includes(absent)) refusals.push(`${where}: production's markdown already contains guard_absent`);
        if (proof && held.includes(proof)) refusals.push(`${where}: production's markdown already contains the proof, so the read-back could not tell old from new`);
        if (oldLength !== undefined && oldLength !== held.length) {
          refusals.push(`${where}: old_length says ${oldLength} and production's row is ${held.length}`);
        }
        oldLength = held.length;
      }
    }
    if (!Number.isInteger(oldLength) || oldLength < 1) {
      refusals.push(`${where}: old_length is required - length(markdown) of the stored row, trailing newline included (or pass --remote)`);
    }
    fixes.push({ class_id: id, markdown: md, guard, guard_absent: absent, proof, old_length: oldLength });
  }
  return { fixes, refusals };
}

function renderScript({ title, fileName, fixes, notes }) {
  const ids = fixes.map((f) => f.class_id);
  const L = [];
  L.push(`-- ${title}`);
  L.push(`-- ${fixes.length} class${fixes.length === 1 ? '' : 'es'}, each replaced whole: ${ids.join(', ')}.`);
  L.push('--');
  L.push('-- One-off data script, run once per environment. NOT a migration - it changes');
  L.push('-- rows, not schema.');
  L.push('--');
  L.push(`--   node scripts/d1-apply.mjs --local apps/character-creator/db/${fileName}`);
  L.push('--');
  L.push('-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence');
  L.push('-- of the text it replaces (or on the absence of a string only the new text');
  L.push('-- has) AND on the old text\'s exact length, so it cannot fire');
  L.push('-- against a row edited since, and a second run is a no-op. Every markdown');
  L.push('-- parsed clean before this was written.');
  for (const n of notes) L.push(n);
  L.push('');
  for (const f of fixes) {
    L.push(`-- == ${f.class_id} ==`);
    L.push('UPDATE imported_classes');
    L.push(`   SET markdown = ${sqlLiteral(f.markdown)},`);
    L.push("       updated_at = datetime('now')");
    L.push(` WHERE class_id = ${sqlLiteral(f.class_id)}`);
    L.push(f.guard ? `   AND instr(markdown, ${sqlLiteral(f.guard)}) > 0`
      : `   AND instr(markdown, ${sqlLiteral(f.guard_absent)}) = 0`);
    L.push(`   AND length(markdown) = ${f.old_length};`);
    L.push('');
  }
  const each = (list, pick) => list.map((f, i) => `${i ? '    OR ' : ' WHERE '}(class_id = ${sqlLiteral(f.class_id)} AND instr(markdown, ${sqlLiteral(pick(f))}) > 0)`);
  L.push('-- Read the result back. A guard that matched nothing must fail here, not pass.');
  L.push(`SELECT ${sqlLiteral(`all ${fixes.length} classes carry their new text`)} AS assertion, count(*) AS got, ${fixes.length} AS want`);
  L.push('  FROM imported_classes');
  const proofs = each(fixes, (f) => f.proof); proofs[proofs.length - 1] += ';';
  L.push(...proofs);
  // Only the classes guarded on a sentence have one to look for; a class
  // guarded on an absence is proved by its proof alone.
  const sentenced = fixes.filter((f) => f.guard);
  if (sentenced.length) {
    L.push("SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want");
    L.push('  FROM imported_classes');
    const guards = each(sentenced, (f) => f.guard); guards[guards.length - 1] += ';';
    L.push(...guards);
  }
  L.push("SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want");
  L.push('  FROM imported_classes');
  L.push(` WHERE class_id IN ${inList(ids)} AND instr(markdown, char(13)) > 0;`);
  L.push('');
  L.push(...footer(fileName));
  return L.join('\n') + '\n';
}

function selfTest() {
  const md = (id, body) => ['---', `id: ${id}`, 'name: Test', 'system: rifts', 'source_book: Test Book p.1',
    'category: rcc', 'tags: []', 'men_of_arms: false', '---', '', '## Lore', '', body, ''].join('\n');
  const fine = { class_id: 'test-race', guard: 'The old sentence.', proof: 'The new sentence.', old_length: 120 };
  const files = { 'test-race': md('test-race', 'The new sentence.') };
  const run = (entries, f = files, stored = null) => buildFixes(entries, (id) => f[id] ?? null, stored);
  const cases = [
    ['a clean fix is accepted', [fine], files, null, (r) => r.refusals.length === 0 && r.fixes[0].old_length === 120],
    ['markdown that does not parse is refused', [fine], { 'test-race': 'no frontmatter here' }, null,
      (r) => r.refusals.some((x) => x.includes('does not parse'))],
    ['markdown for another class is refused', [fine], { 'test-race': md('someone-else', 'The new sentence.') }, null,
      (r) => r.refusals.some((x) => x.includes('the markdown\'s id is "someone-else"'))],
    ['a guard the new text still holds is refused', [{ ...fine, guard: 'The new sentence.' }], files, null,
      (r) => r.refusals.some((x) => x.includes('still contains the guard'))],
    ['a proof the new text lacks is refused', [{ ...fine, proof: 'Nowhere.' }], files, null,
      (r) => r.refusals.some((x) => x.includes('does not contain the proof'))],
    ['a missing old_length is refused', [{ ...fine, old_length: undefined }], files, null,
      (r) => r.refusals.some((x) => x.includes('old_length is required'))],
    ['a CR in the markdown is refused', [fine], { 'test-race': md('test-race', 'The new sentence.').replace(/\n/g, '\r\n') }, null,
      (r) => r.refusals.some((x) => x.includes('holds a CR'))],
    ['a non-ASCII character is refused', [fine], { 'test-race': md('test-race', 'The new sentence — dashed.') }, null,
      (r) => r.refusals.some((x) => x.includes('outside printable ASCII'))],
    ['a class listed twice is refused', [fine, fine], files, null,
      (r) => r.refusals.some((x) => x.includes('listed twice'))],
    ['with production in hand, the stored length is the one used, trailing newline and all',
      [{ ...fine, old_length: undefined }], files, new Map([['test-race', 'x'.repeat(40) + 'The old sentence.\n']]),
      (r) => r.refusals.length === 0 && r.fixes[0].old_length === 58],
    ['a guard production does not hold is refused', [fine], files, new Map([['test-race', 'something else entirely\n']]),
      (r) => r.refusals.some((x) => x.includes('does not contain the guard'))],
    ['an old_length that disagrees with production is refused', [fine], files,
      new Map([['test-race', 'The old sentence.\n']]),
      (r) => r.refusals.some((x) => x.includes('old_length says 120 and production\'s row is 18'))],
    ['a class production does not hold is refused', [fine], files, new Map(),
      (r) => r.refusals.some((x) => x.includes('production holds no such class'))],
    ['a class may be guarded on an ABSENCE instead, a string only the new text has',
      [{ class_id: 'test-race', guard_absent: 'The new sentence.', proof: 'category: rcc', old_length: 50 }], files, null,
      (r) => r.refusals.length === 0 && r.fixes[0].guard === '' && r.fixes[0].guard_absent === 'The new sentence.'],
    ['an absence guard the new text lacks is refused',
      [{ class_id: 'test-race', guard_absent: 'Nowhere.', proof: 'The new sentence.', old_length: 50 }], files, null,
      (r) => r.refusals.some((x) => x.includes('does not contain guard_absent'))],
    ['both guards at once, or neither, is refused',
      [{ ...fine, guard_absent: 'The new sentence.' }], files, null,
      (r) => r.refusals.some((x) => x.includes('not both'))],
    ['a proof production already holds is refused', [fine], files,
      new Map([['test-race', 'The old sentence. The new sentence.' + 'x'.repeat(85)]]),
      (r) => r.refusals.some((x) => x.includes('already contains the proof'))],
  ];
  let failed = 0;
  for (const [name, entries, f, stored, ok] of cases) {
    const pass = ok(run(entries, f, stored));
    if (!pass) failed++;
    console.log(`  ${pass ? 'ok  ' : 'FAIL'} ${name}`);
  }
  const sql = renderScript({ title: 'Self-test.', fileName: '~999-self-test.sql', fixes: run([fine]).fixes, notes: [] });
  const shape = [
    ['the UPDATE is guarded on the old sentence and on the exact length',
      sql.includes("AND instr(markdown, 'The old sentence.') > 0") && sql.includes('AND length(markdown) = 120;')],
    ['the read-backs ask for the proof, the absence of the guard, and no CR',
      sql.includes("instr(markdown, 'The new sentence.') > 0)") && sql.includes('none still carries the sentence it replaced')
      && sql.includes('instr(markdown, char(13)) > 0;')],
    ['the script records its run', sql.trimEnd().endsWith("INSERT INTO data_script_runs (filename) VALUES ('~999-self-test.sql');")],
    ['in pure ASCII with no CR', scriptProblem(sql) === null],
    ['an absence-guarded class is updated on = 0 and left out of the sentence read-back', (() => {
      const mixed = renderScript({ title: 't', fileName: '~999-self-test.sql', notes: [],
        fixes: [...run([fine]).fixes,
          { class_id: 'other-race', markdown: 'x', guard: '', guard_absent: 'special_abilities:', proof: 'Y', old_length: 9 }] });
      return mixed.includes("AND instr(markdown, 'special_abilities:') = 0")
        && !mixed.includes("(class_id = 'other-race' AND instr(markdown, '') > 0)")
        && mixed.includes("(class_id = 'other-race' AND instr(markdown, 'Y') > 0)");
    })()],
  ];
  for (const [name, pass] of shape) { if (!pass) failed++; console.log(`  ${pass ? 'ok  ' : 'FAIL'} ${name}`); }
  console.log(failed ? `\nclass-fix-sql self-test FAILED (${failed})` : '\nclass-fix-sql self-test passed');
  process.exit(failed ? 1 : 0);
}

async function main(argv) {
  const { flags, rest } = parseArgs(argv, ['--title', '--notes']);
  if (flags['--self-test']) return selfTest();
  const [dir, out] = rest;
  if (!dir || !out) {
    console.error('usage: node scripts/class-fix-sql.mjs <fix-dir> <out.sql> [--title "..."] [--notes <file>] [--remote]\n'
      + '       node scripts/class-fix-sql.mjs --self-test');
    process.exit(2);
  }
  const fileName = path.basename(out);
  const nameBad = outNameProblem(fileName) || titleProblem(flags['--title']);
  if (nameBad) { console.error(`class-fix-sql: ${nameBad}`); process.exit(2); }
  if (existsSync(out)) { console.error(`class-fix-sql: ${out} exists - this never overwrites a data script`); process.exit(2); }
  const manifest = path.join(dir, 'fixes.json');
  if (!existsSync(manifest)) { console.error(`class-fix-sql: ${manifest} does not exist`); process.exit(2); }
  const entries = JSON.parse(readFileSync(manifest, 'utf8'));
  const markdownOf = (id) => {
    const f = path.join(dir, `${id}.md`);
    return existsSync(f) ? readFileSync(f, 'utf8') : null;
  };
  let stored = null;
  if (flags['--remote']) {
    const { d1Query } = await import('./d1-query-lib.mjs');
    const ids = (Array.isArray(entries) ? entries : []).map((e) => e?.class_id).filter((id) => typeof id === 'string');
    const rows = d1Query(`SELECT class_id, markdown FROM imported_classes WHERE class_id IN ${inList(ids)}`, { target: '--remote' });
    stored = new Map(rows.map((r) => [r.class_id, r.markdown]));
  }
  const built = buildFixes(entries, markdownOf, stored);
  if (built.refusals.length) {
    console.error(`class-fix-sql: ${built.refusals.length} refusal(s), nothing written:`);
    for (const r of built.refusals) console.error(`  - ${r}`);
    process.exit(1);
  }
  const sql = renderScript({ title: flags['--title'] || `Whole-markdown fixes for ${built.fixes.length} class(es).`,
    fileName, fixes: built.fixes, notes: noteLines(flags['--notes']) });
  const bad = scriptProblem(sql);
  if (bad) { console.error(`class-fix-sql: ${bad}; nothing written`); process.exit(1); }
  writeFileSync(out, sql);
  console.log(`class-fix-sql: wrote ${out} - ${built.fixes.length} class(es)${stored ? ', lengths read from production' : ''}. `
    + 'Check where it sorts, run class-check on each <class_id>.md (it does not read this kind of script), '
    + 'then apply it --local.');
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  main(process.argv.slice(2));
}
