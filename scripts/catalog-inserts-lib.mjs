// A catalog row inserted by two data scripts with different content.
//
// Every catalog table here has a UNIQUE key (a gear slug, a spell name), so of
// two scripts inserting the same key only one row survives. A plain INSERT of a
// duplicate fails the build and is caught. `INSERT OR IGNORE` is not: the later
// script's row is dropped without a word, and `OR REPLACE` drops the earlier
// one. When the two rows carry the same values nothing is lost, and that is a
// deliberate pattern here - class scripts each insert the stub gear their kit
// names, idempotently. When the values DIFFER, one script's row, typically its
// citation, never reaches the database while its PR passes every check.
//
// Two book sessions in parallel is where that stops being rare. Each surveys
// the catalog, finds the same missing item, and writes it; whichever script
// sorts later loses its row.
//
// The comparison is textual, over the columns both inserts name. It reads
// `INSERT [OR IGNORE|OR REPLACE] INTO <table> (<cols>) VALUES (...), (...)`,
// the form every catalog import here uses. `INSERT ... SELECT` is not read.
//
// The gate is in apps/character-creator/test/checks/catalog-data.mjs, section
// "Catalog rows inserted by two scripts", which carries the baseline of keys
// that already conflicted when it was written.

import { statements } from './sql-statements.mjs';

// The UNIQUE key of each catalog table, read from db/schema.sql on 2026-09-24.
const CATALOG_KEYS = {
  gear: ['slug'], vehicles: ['slug'], creatures: ['slug'], notable_npcs: ['slug'],
  enchantments: ['slug'], totems: ['slug'],
  skills: ['name'], spells: ['name'], psionic_powers: ['name'],
  super_abilities: ['name'], talents: ['name'],
  morphus_characteristics: ['key'],
  skill_system_bases: ['skill_name', 'system'],
};

// The rows of one `INSERT ... VALUES` statement, as { table, mode, cols, rows }
// with each row an array of raw value texts (string literals unquoted), or null
// when the statement is not that shape.
function insertRows(stmt) {
  const head = /^\s*INSERT\s+(?:OR\s+(IGNORE|REPLACE)\s+)?INTO\s+([A-Za-z_]+)\s*\(([^)]*)\)\s*VALUES\s*/i.exec(stmt);
  if (!head) return null;
  const cols = head[3].split(',').map((c) => c.trim().toLowerCase());
  const rows = [];
  let depth = 0, inStr = false, cur = '', vals = [];
  for (let i = head[0].length; i < stmt.length; i++) {
    const c = stmt[i];
    if (inStr) {
      if (c === "'") {
        if (stmt[i + 1] === "'") { cur += "'"; i++; } else inStr = false;
      } else cur += c;
      continue;
    }
    if (c === "'") { inStr = true; continue; }
    if (c === '(') {
      depth++;
      if (depth === 1) { vals = []; cur = ''; continue; }
    } else if (c === ')') {
      depth--;
      if (depth === 0) { vals.push(cur.trim()); rows.push(vals); cur = ''; continue; }
    } else if (c === ',' && depth === 1) { vals.push(cur.trim()); cur = ''; continue; }
    if (depth >= 1) cur += c;
  }
  return { table: head[2].toLowerCase(), mode: (head[1] || 'plain').toLowerCase(), cols, rows };
}

// { 'table|key': [{ file, values: {col: text} }, ...] } over a set of files.
export function catalogInserts(files) {
  const out = {};
  for (const { name, sql } of files) {
    for (const stmt of statements(sql)) {
      const ins = insertRows(stmt);
      if (!ins || !CATALOG_KEYS[ins.table]) continue;
      const keyCols = CATALOG_KEYS[ins.table];
      if (!keyCols.every((k) => ins.cols.includes(k))) continue;
      for (const row of ins.rows) {
        const values = Object.fromEntries(ins.cols.map((c, i) => [c, row[i]]));
        const k = ins.table + '|' + keyCols.map((c) => values[c]).join('|');
        (out[k] ??= []).push({ file: name, values });
      }
    }
  }
  return out;
}

// The keys inserted by two or more FILES whose values differ on a column both
// name. Re-inserting the same values from a second file loses nothing.
export function conflictingInserts(inserts) {
  const out = [];
  for (const [k, list] of Object.entries(inserts)) {
    if (new Set(list.map((x) => x.file)).size < 2) continue;
    let differs = [];
    for (let i = 0; i < list.length; i++) {
      for (let j = i + 1; j < list.length; j++) {
        if (list[i].file === list[j].file) continue;
        for (const c of Object.keys(list[i].values)) {
          if (c in list[j].values && list[i].values[c] !== list[j].values[c]) differs.push(c);
        }
      }
    }
    if (differs.length) out.push({ key: k, files: [...new Set(list.map((x) => x.file))], columns: [...new Set(differs)] });
  }
  return out;
}
