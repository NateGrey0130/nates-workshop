// Marvel Heroes campaign notes and People: @mentions, dossier fields, and the
// full-text query. Marvel's own copy of what the Palladium suite keeps in
// functions/api/character-creator/_lib/mentions.js and its search endpoint,
// written against the msh_ tables: each group's server code reaches only its
// own database (groups.json), so the two share the rule, not the code.
//
// @Name in a note links it to that person's dossier, creating one on first
// mention (status 'unknown', nothing else known, which is the truth). Mentions
// are stored as the note's own text, never rewritten to ids, and resolved at
// write time. A name is one or two capitalised words; trailing punctuation is
// trimmed, so "@Kingpin," is the Kingpin - and so is "@Kingpin's men": a
// possessive 's comes off, or it would make a second dossier called
// "Kingpin's". An apostrophe INSIDE a name stays, so @O'Brien is O'Brien.
// (Found driving this endpoint on 2026-09-28; the Palladium copy of the rule,
// functions/api/character-creator/_lib/mentions.js, still has it.)

const MENTION = /@([\p{Lu}][\p{L}'\u2019-]*(?:\s+[\p{Lu}][\p{L}'\u2019-]*)?)/gu;
const CHUNK = 90;   // D1 binds at most 100 parameters a statement

export function parseMentions(body) {
  const names = new Map();
  for (const m of String(body || '').matchAll(MENTION)) {
    const name = m[1].replace(/['\u2019]s$/i, '').replace(/['\u2019-]+$/, '').trim();
    if (!name || name.length > 60) continue;
    const key = name.toLowerCase();
    if (!names.has(key)) names.set(key, name);
  }
  return [...names.values()];
}

// Names to dossier ids in this campaign, creating any the campaign has not met.
export async function resolveMentions(db, { campaignId, names, email }) {
  const byName = new Map();
  for (let i = 0; i < names.length; i += CHUNK) {
    const batch = names.slice(i, i + CHUNK);
    const { results } = await db.prepare(`SELECT id, name FROM msh_npcs WHERE campaign_id = ?
      AND name COLLATE NOCASE IN (${batch.map(() => '?').join(', ')})`).bind(campaignId, ...batch).all();
    for (const r of results) byName.set(r.name.toLowerCase(), r.id);
  }
  for (const name of names) {
    if (byName.has(name.toLowerCase())) continue;
    // ON CONFLICT, not check-then-insert: two notes naming one new person at
    // once would both see "not there" and one insert would fail the index.
    const row = await db.prepare(`INSERT INTO msh_npcs (campaign_id, name, created_by) VALUES (?, ?, ?)
      ON CONFLICT (campaign_id, name COLLATE NOCASE) DO UPDATE SET name = name RETURNING id`)
      .bind(campaignId, name, email).first();
    byName.set(name.toLowerCase(), row.id);
  }
  return byName;
}

// The statements that make one note's mentions match its body now. Only the
// rows a person typed ('mention') are reconciled.
export async function reconcileMentions(db, { entryId, campaignId, body, email }) {
  const wanted = new Set((await resolveMentions(db, { campaignId, names: parseMentions(body), email })).values());
  const { results } = await db.prepare(`SELECT npc_id FROM msh_npc_mentions WHERE journal_entry_id = ? AND source = 'mention'`)
    .bind(entryId).all();
  const have = new Set(results.map((r) => r.npc_id));
  const out = [];
  for (const id of wanted) if (!have.has(id)) {
    out.push(db.prepare(`INSERT OR IGNORE INTO msh_npc_mentions (npc_id, journal_entry_id, source) VALUES (?, ?, 'mention')`).bind(id, entryId));
  }
  for (const id of have) if (!wanted.has(id)) {
    out.push(db.prepare(`DELETE FROM msh_npc_mentions WHERE npc_id = ? AND journal_entry_id = ? AND source = 'mention'`).bind(id, entryId));
  }
  return out;
}

// A typed query as FTS5 terms: every run of letters and digits quoted, so an
// apostrophe or hyphen is never syntax. AND for the search box, with the last
// word a prefix; OR for Ask, because a question is not a set of required terms.
export function toMatchQuery(raw, { join = 'AND' } = {}) {
  const terms = String(raw || '').match(/[\p{L}\p{N}]+/gu);
  if (!terms || !terms.length) return null;
  return terms.map((t, i) => (join === 'AND' && i === terms.length - 1 ? `"${t}"*` : `"${t}"`)).join(` ${join} `);
}

export const STATUSES = ['alive', 'dead', 'unknown', 'never-met'];
export const trim = (v) => (typeof v === 'string' && v.trim() ? v.trim() : null);

export function serialiseAliases(v) {
  const list = (Array.isArray(v) ? v : String(v ?? '').split(','))
    .map((x) => String(x).trim()).filter(Boolean).slice(0, 20);
  return list.length ? JSON.stringify(list) : null;
}
export function parseAliases(v) {
  if (!v) return [];
  try { const p = JSON.parse(v); return Array.isArray(p) ? p : []; } catch { return []; }
}

// A dossier as its reader may see it. `sheet_id` says the GM has statted this
// person, which is exactly what a hidden NPC sheet keeps from the players, so
// it leaves every response but the GM's.
export function dossierFor(row, isGm) {
  if (!row) return row;
  row.aliases = parseAliases(row.aliases);
  if (!isGm) delete row.sheet_id;
  return row;
}
