// GET  /api/character-creator/characters/:id/grants — what a table has handed
//      this character outside its class schedule.
// POST /api/character-creator/characters/:id/grants — add one.
//      Body: { kind, name, reason }. Only `kind: 'skill'` is live.
//
// Owner OR G.M., the same guard as any character write, and deliberately so:
// the G.M. says the grant out loud at the table and the player types it in.
// Nothing here is gated to the G.M., so the record carries the weight instead
// — hence a required `reason`, a stored `granted_by`, and a play_event.

import { json, readJson, requireCharacter } from '../../_lib/auth.js';
import { loadCharacter } from '../../_lib/character-json.js';
import { listGrants, findSkillRow, skillEntryFor, grantEventStatement,
         readGrantBody, grantError } from '../../_lib/grants.js';

export async function onRequestGet({ request, env, params }) {
  const guard = await requireCharacter(request, env, params.id, { write: false });
  if (guard.res) return guard.res;
  const grants = await listGrants(env, params.id);
  return json({ grants, total: grants.length, can_write: guard.access.canWrite });
}

export async function onRequestPost({ request, env, params }) {
  const guard = await requireCharacter(request, env, params.id);
  if (guard.res) return guard.res;
  const { email } = guard;

  const body = await readJson(request);
  if (!body) return json({ error: 'Invalid JSON body' }, 400);
  const parsed = readGrantBody(body);
  if (parsed.error) return json({ error: parsed.error }, 400);

  const character = await loadCharacter(env, params.id, ['id', 'level', 'skills', 'attributes']);
  const skills = Array.isArray(character.skills) ? character.skills : [];

  const row = await findSkillRow(env, parsed.name);
  if (!row) return grantError(`No skill called "${parsed.name}" in the catalog`);

  // A skill is learned once, whoever granted it — the same rule that counts
  // repeats across player and G.M. abilities. Refused here, with the name it
  // collided with, rather than quietly appending a second row the sheet would
  // show twice.
  if (skills.some((s) => String(s.name).toLowerCase() === row.name.toLowerCase())) {
    return grantError(`${row.name} is already on this sheet`);
  }

  const entry = skillEntryFor(row, { level: character.level, attributes: character.attributes });
  const merged = skills.concat(entry);

  // One batch: the row that explains the skill and the skill itself land
  // together or not at all. Apart, a failed UPDATE leaves a grant nothing on
  // the sheet corresponds to, and nothing would report it.
  const [inserted] = await env.DB.batch([
    env.DB.prepare(
      `INSERT INTO character_grants
         (character_id, kind, name, detail, reason, granted_by, granted_at_level)
       VALUES (?, 'skill', ?, ?, ?, ?, ?)`
    ).bind(params.id, entry.name,
      JSON.stringify({ category: entry.category, pct: entry.pct, per_level: entry.per_level }),
      parsed.reason, email, character.level),
    env.DB.prepare("UPDATE characters SET skills = ?, updated_at = datetime('now') WHERE id = ?")
      .bind(JSON.stringify(merged), params.id),
    grantEventStatement(env, params.id, email, `granted skill: ${entry.name} — ${parsed.reason}`),
  ]);

  return json({
    ok: true,
    grant: {
      id: inserted?.meta?.last_row_id ?? null,
      kind: 'skill', name: entry.name, reason: parsed.reason,
      granted_by: email, granted_at_level: character.level,
    },
    skills: merged,
  });
}
