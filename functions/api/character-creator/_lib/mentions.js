// `@Name` in a note, and the dossier rows it links to.
//
// The primary path into an NPC dossier, and deliberately the DETERMINISTIC one:
// typing @Kevik links that entry to Kevik, for free, instantly, and under the
// writer's control. The Claude sweep beside it is a safety net for the people
// nobody tagged, not the mechanism.

import { selectInChunks } from './sql-chunk.js';

// Mentions are stored as plain `@Name` text in the body, NOT as ids.
//
// The body stays readable text that survives a rename and reads correctly in a
// plain-text export, and resolution happens against the name index at write
// time. The alternative - rewriting the body to `@[12]` on save - makes the
// stored note depend on a table to be legible at all.
//
// A name runs until something that cannot be part of one. Two words are
// allowed, because "@Lord Coake" is one person and stopping at the space would
// link to a Lord nobody has met; three are not, because at that point the
// pattern starts swallowing sentences. Trailing punctuation is trimmed, so
// "@Kevik," and "@Kevik." are the same person as "@Kevik".
const MENTION = /@([\p{Lu}][\p{L}'’-]*(?:\s+[\p{Lu}][\p{L}'’-]*)?)/gu;

export function parseMentions(body) {
  const names = new Map(); // lower-cased key → the spelling as typed
  for (const m of String(body || '').matchAll(MENTION)) {
    const name = m[1].replace(/['’-]+$/, '').trim();
    if (!name || name.length > 60) continue;
    const key = name.toLowerCase();
    if (!names.has(key)) names.set(key, name);
  }
  return [...names.values()];
}

// Reconcile one entry's mentions with what its body now says.
//
// Returns the statements rather than running them, so the caller can batch this
// with the write that changed the body. An entry whose body was edited to
// remove a name should stop being listed under that NPC — a mention list that
// only ever grows is a mention list that lies about the current text.
//
// Only `source = 'mention'` rows are reconciled. A link the sweep made is the
// model's reading of an entry that never contained an @, and rewriting the body
// must not silently delete it.
export function reconcileStatements(env, { entryId, npcIdsByName, existingMentionNpcIds }) {
  const wanted = new Set(npcIdsByName.values());
  const have = new Set(existingMentionNpcIds);
  const statements = [];

  for (const npcId of wanted) {
    if (have.has(npcId)) continue;
    statements.push(env.DB.prepare(
      `INSERT OR IGNORE INTO npc_mentions (npc_id, journal_entry_id, source)
       VALUES (?, ?, 'mention')`
    ).bind(npcId, entryId));
  }
  for (const npcId of have) {
    if (wanted.has(npcId)) continue;
    statements.push(env.DB.prepare(
      `DELETE FROM npc_mentions WHERE npc_id = ? AND journal_entry_id = ? AND source = 'mention'`
    ).bind(npcId, entryId));
  }
  return statements;
}

// Resolve mentioned names to dossier ids, creating a dossier for any name the
// campaign has not seen before.
//
// Creating on first mention rather than offering to: the writer already
// committed by typing the @, and a confirmation step there would mean the note
// posts with a dangling reference while somebody decides. A dossier created this
// way holds only a name — status 'unknown', no description — which is exactly
// what is actually known about it.
export async function resolveMentions(env, { campaignId, names, email }) {
  const byName = new Map();
  if (!names.length) return byName;

  // COLLATE NOCASE matches the unique index, so lookup and insert agree about
  // what a duplicate is.
  // Chunked: D1 binds at most 100 parameters per statement, and a long session
  // note can name more than a hundred people.
  const results = await selectInChunks(names, (batch) => env.DB.prepare(
    `SELECT id, name FROM npcs WHERE campaign_id = ? AND name COLLATE NOCASE IN (${batch.map(() => '?').join(', ')})`
  ).bind(campaignId, ...batch));
  for (const row of results) byName.set(row.name.toLowerCase(), row.id);

  for (const name of names) {
    if (byName.has(name.toLowerCase())) continue;
    // ON CONFLICT rather than a check-then-insert: two people posting notes
    // naming the same new NPC at once would both see "not there" and one insert
    // would fail the unique index.
    const row = await env.DB.prepare(
      `INSERT INTO npcs (campaign_id, name, created_by) VALUES (?, ?, ?)
       ON CONFLICT (campaign_id, name COLLATE NOCASE) DO UPDATE SET name = name
       RETURNING id`
    ).bind(campaignId, name, email).first();
    byName.set(name.toLowerCase(), row.id);
  }
  return byName;
}

// Everything the reconcile needs, for one entry.
export async function existingMentions(env, entryId) {
  const { results } = await env.DB.prepare(
    `SELECT npc_id FROM npc_mentions WHERE journal_entry_id = ? AND source = 'mention'`
  ).bind(entryId).all();
  return results.map((r) => r.npc_id);
}
