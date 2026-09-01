// Grants: things a table hands out that no class schedule granted.
//
// A patron teaches a skill, an artefact confers a power, an implant adds
// S.D.C. The G.M. usually says so out loud mid-session, so the PLAYER types it
// in on their own sheet — which is why nothing here is G.M.-only and why
// `reason` is required. The person entering a grant is usually its
// beneficiary, and the reason is the only thing between a record and an
// unfalsifiable claim.
//
// See apps/character-creator/docs/plans/19-gm-grants.md. This file implements
// the `skill` kind; the other seven are named in the schema's CHECK because
// SQLite cannot alter one, not because they work yet.
//
// WHERE THE EFFECT LIVES, and why it is not always here. A granted skill is
// written into `characters.skills` as a `type: 'gm'` entry, and the
// `character_grants` row is its provenance. It is stored rather than composed
// on read because `js/leveling.js` advances every skill carrying a `pct` and a
// `per_level` straight off that array — so a stored grant improves on level-up
// with no help, and a composed one would not advance at all unless every
// writer learned to strip it back out first.
//
// `type: 'gm'` is also what keeps the validator quiet: it counts `related` and
// `secondary` against the class allowance and checks categories on related
// only, so a granted skill is invisible to every one of those checks without a
// line being written there. That is deliberate and it is the doctrine this
// repo already had — `validate-character.js` calls a `{ name, gm: true }`
// ability "a ruling, not a pick".

import { json } from './auth.js';
import { safeParse } from './character-json.js';
import { isFamilyName, otherRowFor } from '../../../../apps/character-creator/js/language-skills.js';
import { skillBase } from '../../../../apps/character-creator/js/skill-base.js';

const GRANT_KINDS = ['skill', 'spell', 'psionic', 'ability',
                     'attribute', 'pool', 'combat', 'save'];

// Implemented today. A kind in the schema but not here is refused with a
// message saying so, rather than accepted into a column nothing reads.
const LIVE_KINDS = new Set(['skill']);

const REASON_MAX = 500;

export async function listGrants(env, characterId) {
  const { results } = await env.DB.prepare(
    `SELECT id, kind, name, value, detail, reason, granted_by, granted_at_level,
            claimed_at, created_at
     FROM character_grants WHERE character_id = ? ORDER BY id`
  ).bind(characterId).all();
  return (results || []).map((r) => ({ ...r, detail: r.detail ? safeParse(r.detail) : null }));
}

// The catalog row for a granted skill name.
//
// The language and literacy families fall back to their `Other` row the same
// way a spent pick does, keeping the name they were given — "Language:
// Dragonese" is a legitimate thing for a patron to teach and is not in the
// catalog by that name.
export async function findSkillRow(env, name) {
  const wanted = [name];
  if (isFamilyName(name)) wanted.push(String(otherRowFor(name)));
  const { results } = await env.DB.prepare(
    `SELECT name, category, base, base_formula, per_level FROM skills
     WHERE name COLLATE NOCASE IN (${wanted.map(() => '?').join(',')})`
  ).bind(...wanted).all();
  const byName = new Map((results || []).map((r) => [r.name.toLowerCase(), r]));
  const exact = byName.get(name.toLowerCase());
  if (exact) return exact;
  if (!isFamilyName(name)) return null;
  const other = byName.get(String(otherRowFor(name)).toLowerCase());
  // Keep the name the grant asked for; take the numbers from the family row.
  return other ? { ...other, name } : null;
}

// What a granted skill looks like on the character.
//
// The percentage comes from skillBase(), which is the only place `base` and
// `base_formula` are chosen between — a skill whose starting value is derived
// from an attribute (Zero Gravity Movement & Combat is P.P. x5) would
// otherwise arrive at 0 and be indistinguishable from a W.P.
//
// No category bonus is applied. The class's per-category percentage is for
// related SELECTIONS, and a grant is not one — the same reading that denies it
// to an out-of-category pick spent as a secondary skill.
export function skillEntryFor(row, { level, attributes }) {
  return {
    name: row.name,
    category: row.category,
    pct: skillBase(row, attributes || {}),
    per_level: row.per_level ?? 0,
    type: 'gm',
    gained_at_level: level,
  };
}

// A play_event for a grant. Deliberately carries NO `changes`.
//
// `events/undo` reverses the latest not-undone event that has them, by writing
// the stored from/to values back through the character — and it knows nothing
// about `character_grants`. An event with changes would let undo restore a
// number while leaving the row that justifies it in place. A roll is recorded
// the same way and for the same reason: a pure record.
export function grantEventStatement(env, characterId, actorEmail, note) {
  return env.DB.prepare(
    'INSERT INTO play_events (character_id, actor_email, kind, payload) VALUES (?, ?, ?, ?)'
  ).bind(characterId, actorEmail, 'grant', JSON.stringify({ note }));
}

// Shape checks shared by every kind, so a new kind cannot skip them.
export function readGrantBody(body) {
  const kind = String(body?.kind || '').trim();
  if (!GRANT_KINDS.includes(kind)) {
    return { error: `kind must be one of ${GRANT_KINDS.join(', ')}` };
  }
  if (!LIVE_KINDS.has(kind)) {
    return { error: `${kind} grants are not implemented yet — only ${[...LIVE_KINDS].join(', ')}` };
  }
  const name = String(body?.name || '').trim();
  if (!name) return { error: 'name is required' };
  const reason = String(body?.reason || '').trim();
  if (!reason) return { error: 'reason is required — say why the table gave this' };
  if (reason.length > REASON_MAX) {
    return { error: `reason is ${reason.length} characters; the limit is ${REASON_MAX}` };
  }
  return { kind, name, reason };
}

export function grantError(message, status = 422) {
  return json({ error: message }, status);
}
