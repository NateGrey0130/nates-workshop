// GET  /api/character-creator/characters/:id/power-picks — unspent spell and
//      psionic grants.
// POST /api/character-creator/characters/:id/power-picks — spend some.
//      Body: { picks: [{ kind, name, granted_at_level }] }
//
// The other half of the level-up power picker, mirroring `picks.js` for skills:
// a grant skipped at level-up waits here until the player comes back to it.
// Without this endpoint the banking is a dead end, which is the same silent
// loss as not banking at all, just deferred.
//
// The cap travels with the grant rather than being recomputed from the class.
// A Ley Line Walker's level-4 pair stays capped at spell level 4 even if the
// class is re-imported with a different rule in between — what a character was
// granted cannot change retroactively.

import { json, readJson, requireCharacter } from '../../_lib/auth.js';
import { listPendingPowers, resolvePowerPicks, powerPickErrors } from '../../_lib/power-picks.js';
import { loadCharacter } from '../../_lib/character-json.js';

export async function onRequestGet({ request, env, params }) {
  const guard = await requireCharacter(request, env, params.id, { write: false });
  if (guard.res) return guard.res;
  const pending = await listPendingPowers(env, params.id);
  return json({
    pending,
    total: pending.reduce((n, g) => n + g.count, 0),
    can_write: guard.access.canWrite,
  });
}

export async function onRequestPost({ request, env, params }) {
  const guard = await requireCharacter(request, env, params.id);
  if (guard.res) return guard.res;

  const b = await readJson(request);
  if (!b || !Array.isArray(b.picks) || !b.picks.length) {
    return json({ error: 'picks is required' }, 400);
  }

  const pending = await listPendingPowers(env, params.id);
  if (!pending.length) return json({ error: 'This character has no unspent power picks' }, 400);

  const character = await loadCharacter(env, params.id);
  const campaign = await env.DB.prepare('SELECT system FROM campaigns WHERE id = ?')
    .bind(character.campaign_id).first();

  // The banked rows ARE the grants, so what was stored is what is spent
  // against — including the cap each one carried.
  const grants = pending.map((g) => ({
    level: g.granted_at_level, count: g.count, kind: g.kind, spell_levels: g.spell_levels,
  }));

  const resolved = await resolvePowerPicks(env, {
    picks: b.picks,
    grants,
    existingPowers: character.powers,
    system: campaign?.system ?? null,
  });
  if (resolved.errors?.length) return powerPickErrors(resolved.errors);
  if (!resolved.powers.length) return json({ error: 'Nothing to spend' }, 400);

  // Consume from the earliest row of the right kind and level, decrementing
  // rather than deleting so a grant only PARTLY spent keeps its remainder and
  // its cap. A row that reaches zero is marked claimed rather than removed, so
  // the history of what was granted survives.
  const statements = [];
  const spent = new Map();
  for (const p of resolved.powers) {
    const key = `${p.type === 'psionic' ? 'psionic' : 'spell'}:${p.gained_at_level}`;
    spent.set(key, (spent.get(key) || 0) + 1);
  }
  for (const g of pending) {
    const key = `${g.kind}:${g.granted_at_level}`;
    const take = Math.min(g.count, spent.get(key) || 0);
    if (!take) continue;
    spent.set(key, (spent.get(key) || 0) - take);
    const left = g.count - take;
    statements.push(left > 0
      ? env.DB.prepare('UPDATE pending_power_picks SET count = ? WHERE id = ?').bind(left, g.id)
      : env.DB.prepare("UPDATE pending_power_picks SET count = 0, claimed_at = datetime('now') WHERE id = ?").bind(g.id));
  }

  const powers = character.powers.concat(resolved.powers);
  statements.unshift(env.DB.prepare(
    "UPDATE characters SET powers = ?, updated_at = datetime('now') WHERE id = ?"
  ).bind(JSON.stringify(powers), params.id));

  // One batch: a power written without its grant consumed can be claimed twice,
  // and a grant consumed without the power written is simply lost.
  await env.DB.batch(statements);

  const left = await listPendingPowers(env, params.id);
  return json({
    ok: true,
    gained: resolved.powers.map((p) => ({ type: p.type, name: p.name, level: p.gained_at_level })),
    pending_total: left.reduce((n, g) => n + g.count, 0),
  });
}
