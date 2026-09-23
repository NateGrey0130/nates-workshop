// GET    /api/character-creator/npc-library/:id  - one entry, its whole sheet
// PATCH  /api/character-creator/npc-library/:id  {name?, notes?}
// DELETE /api/character-creator/npc-library/:id
//
// OWNER ONLY, and anyone else gets 404 - not 403. A refusal that differs from
// "missing" would tell a stranger probing ids which ones are real, the reason
// isHiddenNpc answers 404 for a G.M.'s NPC too.
//
// Editing is the name and the G.M.'s notes on the entry. The sheet itself is
// edited where sheets are edited - pull it into a campaign, change it there,
// and keep the new version.

import { getUserEmail, unauthorized, json, readJson } from '../_lib/auth.js';

async function own(request, env, id) {
  const email = getUserEmail(request);
  if (!email) return { res: unauthorized() };
  const row = await env.DB.prepare('SELECT * FROM npc_library WHERE id = ?').bind(id).first();
  if (!row || row.owner_email !== email) return { res: json({ error: 'Not found' }, 404) };
  return { email, row };
}

export async function onRequestGet({ request, env, params }) {
  const g = await own(request, env, params.id);
  if (g.res) return g.res;
  const { owner_email: _o, sheet, ...rest } = g.row;
  let parsed = null;
  try { parsed = JSON.parse(sheet); } catch { /* shown as missing */ }
  return json({ entry: { ...rest, sheet: parsed } });
}

export async function onRequestPatch({ request, env, params }) {
  const g = await own(request, env, params.id);
  if (g.res) return g.res;
  const b = await readJson(request);
  if (!b) return json({ error: 'Invalid JSON body' }, 400);
  const sets = [], binds = [];
  if ('name' in b) {
    const name = typeof b.name === 'string' ? b.name.trim() : '';
    if (!name) return json({ error: 'A name cannot be blank' }, 400);
    sets.push('name = ?'); binds.push(name);
  }
  if ('notes' in b) {
    if (b.notes != null && typeof b.notes !== 'string') return json({ error: 'notes must be text' }, 400);
    sets.push('notes = ?'); binds.push((b.notes || '').trim() || null);
  }
  if (!sets.length) return json({ error: 'name and notes are the editable fields' }, 400);
  const row = await env.DB.prepare(
    `UPDATE npc_library SET ${sets.join(', ')}, updated_at = datetime('now') WHERE id = ? RETURNING id, name, notes, updated_at`
  ).bind(...binds, params.id).first();
  return json({ entry: row });
}

export async function onRequestDelete({ request, env, params }) {
  const g = await own(request, env, params.id);
  if (g.res) return g.res;
  await env.DB.prepare('DELETE FROM npc_library WHERE id = ?').bind(params.id).run();
  return json({ ok: true });
}
