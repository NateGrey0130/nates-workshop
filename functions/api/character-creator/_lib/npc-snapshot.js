// A statted NPC as a snapshot, and back again - the NPC library's two moves.
//
// A sheet is more than its `characters` row: the picks it has not spent yet,
// the grants the G.M. gave it, the gear it carries and the vehicles it owns are
// rows of their own. A snapshot takes all of them, so a library copy pulled
// into another campaign is the same NPC and not a row missing its inventory.
// What it leaves out on purpose: level_history and play_events (a copy starts
// with no past), the dossier's portrait (on `npcs`, not the sheet), and any
// item or vehicle already removed.
//
// COLUMNS ARE READ, NOT LISTED. The character's columns come from the row
// itself, and a restore writes only the columns the table has today - so a
// column added to `characters` later is carried by snapshots taken after it,
// and a snapshot taken before it restores without it, rather than either one
// failing on a name.

const SNAPSHOT_VERSION = 1;

// Columns that belong to where a row lives, not to the NPC.
const PLACE_COLS = new Set(['id', 'campaign_id', 'player_email', 'kind', 'created_at', 'updated_at']);

// The child tables, and the columns of each that travel.
const CHILDREN = {
  skill_picks: { table: 'pending_skill_picks', where: 'claimed_at IS NULL',
    cols: ['granted_at_level', 'count', 'categories', 'kind'] },
  power_picks: { table: 'pending_power_picks', where: 'claimed_at IS NULL',
    cols: ['granted_at_level', 'count', 'kind', 'spell_levels', 'spell_traditions', 'categories', 'slot',
      'from_names', 'note'] },
  grants: { table: 'character_grants', where: '1',
    cols: ['kind', 'name', 'value', 'detail', 'reason', 'granted_by', 'granted_at_level', 'claimed_at'] },
  items: { table: 'character_items', where: 'removed_at IS NULL',
    cols: ['gear_slug', 'custom_name', 'qty', 'equipped', 'notes', 'enchantments'] },
  vehicles: { table: 'character_vehicles', where: 'removed_at IS NULL',
    cols: ['vehicle_slug', 'custom_name', 'nickname', 'mdc_current', 'notes'] },
};

async function snapshotCharacter(env, characterId) {
  const row = await env.DB.prepare('SELECT * FROM characters WHERE id = ?').bind(characterId).first();
  if (!row) return null;
  const character = Object.fromEntries(Object.entries(row).filter(([k]) => !PLACE_COLS.has(k)));
  const out = { version: SNAPSHOT_VERSION, character };
  const reads = await env.DB.batch(Object.values(CHILDREN).map((c) =>
    env.DB.prepare(`SELECT ${c.cols.join(', ')} FROM ${c.table} WHERE character_id = ? AND ${c.where} ORDER BY id`)
      .bind(characterId)));
  Object.keys(CHILDREN).forEach((k, i) => { out[k] = reads[i].results || []; });
  return out;
}

/**
 * Write a snapshot back as a new statted NPC in a campaign: a kind = 'npc'
 * characters row owned by `email`, and its child rows. Returns the new id.
 * `notes` REPLACES the sheet's notes when given (the caller appends to them).
 */
export async function restoreSnapshot(env, snap, { campaignId, email, name = null, notes = undefined }) {
  const { results: info } = await env.DB.prepare('SELECT name FROM pragma_table_info(\'characters\')').all();
  const has = new Set((info || []).map((c) => c.name));
  const fields = { ...snap.character };
  if (name) fields.name = name;
  if (notes !== undefined) fields.notes = notes;
  const cols = Object.keys(fields).filter((k) => has.has(k) && !PLACE_COLS.has(k));
  const all = ['campaign_id', 'player_email', 'kind', ...cols];
  const row = await env.DB.prepare(
    `INSERT INTO characters (${all.join(', ')}) VALUES (${all.map(() => '?').join(', ')}) RETURNING id`
  ).bind(campaignId, email, 'npc', ...cols.map((k) => fields[k] ?? null)).first();
  const id = row.id;
  const writes = [];
  for (const [key, c] of Object.entries(CHILDREN)) {
    for (const r of snap[key] || []) {
      const cs = c.cols.filter((k) => k in r);
      writes.push(env.DB.prepare(
        `INSERT INTO ${c.table} (character_id, ${cs.join(', ')}) VALUES (?, ${cs.map(() => '?').join(', ')})`
      ).bind(id, ...cs.map((k) => r[k] ?? null)));
    }
  }
  if (writes.length) {
    try { await env.DB.batch(writes); }
    catch (e) {
      // Half a copy is worse than none: take the row back out, and say why.
      await env.DB.prepare('DELETE FROM characters WHERE id = ?').bind(id).run();
      throw e;
    }
  }
  return id;
}

// What a list shows without shipping every sheet: from the snapshot's row.
export function summary(entry) {
  let c = {};
  try { c = JSON.parse(entry.sheet).character || {}; } catch { /* shown bare */ }
  return {
    id: entry.id, name: entry.name, system: entry.system, source: entry.source, notes: entry.notes,
    class_id: c.class_id ?? null, occ_class_id: c.occ_class_id ?? null, level: c.level ?? null,
    created_at: entry.created_at, updated_at: entry.updated_at,
  };
}

/**
 * Save a campaign's statted NPC into its G.M.'s library. The caller has
 * already established that `email` is that campaign's G.M.
 */
export async function saveToLibrary(env, characterId, email, source) {
  const snap = await snapshotCharacter(env, characterId);
  if (!snap) return null;
  const camp = await env.DB.prepare(
    'SELECT campaigns.system FROM characters JOIN campaigns ON campaigns.id = characters.campaign_id WHERE characters.id = ?'
  ).bind(characterId).first();
  const row = await env.DB.prepare(
    `INSERT INTO npc_library (owner_email, name, system, sheet, source) VALUES (?, ?, ?, ?, ?)
     RETURNING id, name, system, source, created_at`
  ).bind(email, snap.character.name, camp?.system ?? null, JSON.stringify(snap), source).first();
  return row;
}

// "Roll straight into the library": the roller made a campaign row by the same
// path it always takes; keep a copy in the library and take the row back out.
export async function moveToLibrary(env, characterId, email, source) {
  const saved = await saveToLibrary(env, characterId, email, source);
  if (saved) await env.DB.prepare('DELETE FROM characters WHERE id = ?').bind(characterId).run();
  return saved;
}
