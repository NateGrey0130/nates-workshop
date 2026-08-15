// GET  /api/character-creator/characters/:id/picks — unspent skill picks.
// POST /api/character-creator/characters/:id/picks — spend some.
//      Body: { picks: [{ name, override? }] }
//
// The other half of the level-up picker: a grant skipped at level-up waits here
// until the player comes back to it. Owner/GM only, same as any character write.

import { getUserEmail, unauthorized, json, forbidden, characterAccess, readJson } from '../../_lib/auth.js';
import { listPending, resolvePicks, claimStatements, pickErrors } from '../../_lib/skill-picks.js';

export async function onRequestGet({ request, env, params }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();
  const access = await characterAccess(env, params.id, email);
  if (!access.found) return json({ error: 'Character not found' }, 404);

  const pending = await listPending(env, params.id);
  return json({
    pending,
    total: pending.reduce((n, g) => n + g.count, 0),
    can_write: access.canWrite,
  });
}

export async function onRequestPost({ request, env, params }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();
  const access = await characterAccess(env, params.id, email);
  if (!access.found) return json({ error: 'Character not found' }, 404);
  if (!access.canWrite) return forbidden();

  const b = await readJson(request);
  if (!b || !Array.isArray(b.picks) || !b.picks.length) {
    return json({ error: 'picks must be a non-empty array' }, 400);
  }

  const pending = await listPending(env, params.id);
  const allowance = pending.reduce((n, g) => n + g.count, 0);
  if (!allowance) return json({ error: 'No unspent picks' }, 400);

  // One unrestricted grant makes the whole remaining allowance unrestricted,
  // matching how level-confirm combines them.
  const categories = pending.some((g) => !g.categories)
    ? null
    : [...new Set(pending.flatMap((g) => g.categories || []))];

  const character = await env.DB.prepare('SELECT level, skills FROM characters WHERE id = ?')
    .bind(params.id).first();
  let skills = [];
  try { skills = JSON.parse(character.skills); } catch { /* leave empty */ }

  const picked = await resolvePicks(env, {
    picks: b.picks,
    existingSkills: skills,
    allowance,
    categories,
    // A pick spent later still belongs to the level the character is now.
    level: character.level,
  });
  if (picked.errors?.length) return pickErrors(picked.errors);
  if (!picked.skills.length) return json({ error: 'Nothing to apply' }, 400);

  // Skills and the claim in one batch: a pick that consumed its grant without
  // landing on the sheet would be silently lost.
  await env.DB.batch([
    env.DB.prepare("UPDATE characters SET skills = ?, updated_at = datetime('now') WHERE id = ?")
      .bind(JSON.stringify(skills.concat(picked.skills)), params.id),
    ...claimStatements(env, pending, picked.skills.length),
  ]);

  const left = await listPending(env, params.id);
  return json({
    ok: true,
    applied: picked.skills.map((s) => ({ name: s.name, pct: s.pct, override: !!s.override })),
    pending: left,
    remaining: left.reduce((n, g) => n + g.count, 0),
  });
}
