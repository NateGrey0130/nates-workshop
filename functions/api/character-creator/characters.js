// POST /api/character-creator/characters — save a finished level-1 character.
// Body: { campaign_id, name, class_id, attributes{}, skills[], powers[],
//         pools{hp,sdc,mdc,ppe,isp}, items[{item_id|custom_name, qty, equipped, notes}], notes }
// Skill counts, category restrictions and attribute minimums are checked here
// as well as in the wizard — the wizard's checks are a convenience that avoids a
// round trip, this is the boundary.

import { getUserEmail, unauthorized, json, readJson, campaignAccess } from './_lib/auth.js';
import { paging, pagedQuery, pageBody } from './_lib/paging.js';
import { loadCharacterClass } from './_lib/class-loader.js';
import { validateCharacter, loadSkillCategories } from './_lib/validate-character.js';
import { xpTableFor, thresholdFor, skillGrantsFor } from './_lib/leveling.js';
import { insertGrantStatements, remainingGrants } from './_lib/skill-picks.js';
import { parseClassMarkdown, occAllowedForRace, raceAllowedForOcc } from '../../../apps/character-creator/js/parser.js';

// GET /api/character-creator/characters — list for linking to sheets.
// ?campaign_id= filters; ?limit= and ?offset= page (default 200, max 500).
export async function onRequestGet({ request, env }) {
  if (!getUserEmail(request)) return unauthorized();
  const campaignId = new URL(request.url).searchParams.get('campaign_id');
  const { limit, offset } = paging(request);

  const base = `SELECT characters.id, characters.name, characters.class_id, characters.occ_class_id, characters.level,
                       characters.xp, characters.player_email, characters.campaign_id,
                       characters.hp_current, characters.hp_max, characters.sdc_current, characters.sdc_max,
                       characters.mdc_current, characters.mdc_max, characters.ppe_current, characters.ppe_max,
                       characters.isp_current, characters.isp_max,
                       campaigns.name AS campaign_name, campaigns.system AS campaign_system
                FROM characters JOIN campaigns ON campaigns.id = characters.campaign_id`;
  const where = campaignId ? ' WHERE campaign_id = ?' : '';
  const binds = campaignId ? [campaignId] : [];

  const page = await pagedQuery(env, {
    countSql: `SELECT count(*) AS n FROM characters${campaignId ? ' WHERE campaign_id = ?' : ''}`,
    countBinds: binds,
    rowsSql: base + where + ' ORDER BY characters.id DESC',
    rowsBinds: binds,
    limit, offset,
  });

  return json(pageBody('characters', page));
}

// Whether a race may take an occupation, read off the two class rows.
//
// Returns null when either side cannot be resolved or the race states no
// restriction - the same "cannot check, do not block" rule the class resolution
// above follows. A missing class must not become a refusal.
async function occRestrictionFor(env, raceId, occId) {
  const { results } = await env.DB.prepare(
    "SELECT class_id, markdown FROM imported_classes WHERE class_id IN (?, ?) AND status = 'published'"
  ).bind(raceId, occId).all();
  const md = Object.fromEntries((results || []).map((r) => [r.class_id, r.markdown]));
  if (!md[raceId] || !md[occId]) return null;
  const race = parseClassMarkdown(md[raceId])?.data;
  const occ = parseClassMarkdown(md[occId])?.data;
  if (!race || !occ) return null;
  // Both directions, and either may refuse: the race bars the occupation, or
  // the occupation bars the race.
  const byRace = occAllowedForRace(race, occ);
  return byRace.allowed ? raceAllowedForOcc(occ, race) : byRace;
}

export async function onRequestPost({ request, env }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();

  const b = await readJson(request);
  if (!b) return json({ error: 'Invalid JSON body' }, 400);
  for (const field of ['campaign_id', 'name', 'class_id']) {
    if (!b[field]) return json({ error: `Missing required field: ${field}` }, 400);
  }
  const campaign = await env.DB.prepare('SELECT id, open FROM campaigns WHERE id = ?').bind(b.campaign_id).first();
  if (!campaign) return json({ error: 'Campaign not found' }, 404);

  // Creating a character in a campaign is how you JOIN it — membership is
  // "owns a character here", so an ungated create was an ungated door onto the
  // campaign's notes, stash and ledger. A closed campaign admits only its GM
  // and the people already in it; who counts as "in" stays campaignAccess's
  // question, the one place that knows. Open (the default) is the original
  // open-table behaviour, unchanged.
  if (!campaign.open) {
    const access = await campaignAccess(env, b.campaign_id, email);
    if (!access.isMember) {
      return json({ error: 'This campaign is closed to new characters — ask its GM to open it' }, 403);
    }
  }

  // Which stage of the class this is — a Dragon hatchling rather than an adult.
  // Blank means the class as written, which is right for every class that has
  // no variants.
  const variant = typeof b.class_variant === 'string' && b.class_variant.trim()
    ? b.class_variant.trim() : null;

  // The O.C.C. taken alongside an R.C.C. Optional: most characters have one
  // class, and every character created before this had exactly one.
  const occId = typeof b.occ_class_id === 'string' && b.occ_class_id.trim() ? b.occ_class_id.trim() : null;
  const occVariant = typeof b.occ_class_variant === 'string' && b.occ_class_variant.trim()
    ? b.occ_class_variant.trim() : null;
  // Which Military Occupational Specialty was taken. Stored as the id the class
  // declares, exactly like a variant - the granted skills are already in
  // `skills`, but which package produced them is not recoverable from that.
  const mos = typeof b.mos === 'string' && b.mos.trim() ? b.mos.trim() : null;

  // Psionics rolled on the table (p.21). Only 'minor' and 'major' are reachable
  // by rolling — master comes from a psychic O.C.C., so anything else is
  // discarded rather than trusted from the client. A class that grants its own
  // psionics never rolls, so a tier arriving alongside one is ignored too.
  const rolledTier = ['minor', 'major'].includes(b.psychic_tier) ? b.psychic_tier : null;
  const psychicShape = rolledTier && typeof b.psychic_shape === 'string' && b.psychic_shape.trim()
    ? b.psychic_shape.trim() : null;

  // The wizard enforces these too; this is the boundary. A class that cannot be
  // resolved skips the check rather than blocking the save.
  const cls = await loadCharacterClass(env, request.url, {
    class_id: b.class_id, class_variant: variant,
    occ_class_id: occId, occ_class_variant: occVariant,
    psychic_tier: rolledTier, psychic_shape: psychicShape,
  });
  // A race may bar an occupation outright: a dwarf takes no magic O.C.C., a
  // kobold no knight or palladin. The wizard disables those options, and a
  // disabled <option> is a hint rather than a rule - this is the boundary.
  //
  // Refused rather than warned, because unlike most of what the validator says
  // this one is not a judgement call: the race's own page prints the list. The
  // two classes are fetched raw, since the COMPOSED class has already merged
  // them and no longer knows which half was which.
  if (occId && b.class_id && occId !== b.class_id) {
    const verdict = await occRestrictionFor(env, b.class_id, occId);
    if (verdict && !verdict.allowed) return json({ error: verdict.reason }, 400);
  }

  // A class that grants psionics has already answered the question, so a rolled
  // tier is not recorded alongside it — the two would contradict each other.
  const tier = cls?.psionics?.from_roll ? rolledTier : null;
  // A character may START above level 1 - a player joining an established
  // party, or one built to match the table. Bounded by the class's own XP
  // table, so a class whose curve stops at 10 cannot be asked for 12, and
  // floored at 1 because there is no level 0.
  const xpTable = xpTableFor(cls);
  const level = Math.max(1, Math.min(
    Number.isFinite(Number(b.level)) ? Math.trunc(Number(b.level)) : 1,
    xpTable.length));

  // XP is the level's own threshold rather than zero. A level-6 character with
  // 0 XP reads as under-levelled to the XP endpoint, and the very next award
  // proposes a level-up the character has already had.
  const xp = thresholdFor(xpTable, level) ?? 0;

  // Validated at the level being CREATED, not at 1: the related and secondary
  // allowances grow with level, and judging a level-6 character against a
  // level-1 allowance refuses skills the class legitimately granted.
  const { violations } = validateCharacter({
    character: { level },
    cls,
    skills: b.skills || [],
    abilities: b.abilities || [],
    attributes: b.attributes || {},
    catalog: cls ? await loadSkillCategories(env) : null,
  });
  if (violations.length) {
    return json({ error: 'This character breaks its class rules', violations }, 422);
  }

  const p = b.pools || {};
  const row = await env.DB.prepare(
    `INSERT INTO characters (
       campaign_id, player_email, name, class_id, class_variant, occ_class_id, occ_class_variant,
       mos, psychic_tier, psychic_shape, level, xp,
       attributes, attribute_bonuses, rolled_bonuses, skills, powers, abilities,
       hp_max, hp_current, sdc_max, sdc_current, mdc_max, mdc_current,
       ppe_max, ppe_current, isp_max, isp_current,
       bio, combat, saves, armor, notes
     ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
     RETURNING id`
  ).bind(
    b.campaign_id, email, b.name, b.class_id, variant, occId, occVariant, mos, tier, tier ? psychicShape : null,
    level, xp,
    JSON.stringify(b.attributes || {}), JSON.stringify(b.attribute_bonuses || {}),
    JSON.stringify(b.rolled_bonuses || {}),
    JSON.stringify(b.skills || []), JSON.stringify(b.powers || []),
    JSON.stringify(b.abilities || []),
    p.hp ?? null, p.hp ?? null, p.sdc ?? null, p.sdc ?? null, p.mdc ?? null, p.mdc ?? null,
    p.ppe ?? null, p.ppe ?? null, p.isp ?? null, p.isp ?? null,
    JSON.stringify(b.bio || {}), JSON.stringify(b.combat || {}),
    JSON.stringify(b.saves || {}), JSON.stringify(b.armor || []), b.notes ?? null
  ).first();

  const items = (b.items || []).filter((it) => it.item_id || it.custom_name);
  const statements = items.map((it) =>
    env.DB.prepare(
      'INSERT INTO character_items (character_id, item_id, custom_name, qty, equipped, notes) VALUES (?, ?, ?, ?, ?, ?)'
    ).bind(row.id, it.item_id ?? null, it.custom_name ?? null, it.qty || 1, it.equipped ? 1 : 0, it.notes ?? null));

  // Skill picks the levels above 1 earned and the player did not spend. The
  // wizard says how many it spent; what it cannot do is grant itself more than
  // the class allows, so the allowance is recomputed here and the claim is
  // clamped to it.
  //
  // Banked rather than required, the same rule a live level-up follows:
  // creating a character is never blocked on choosing a skill.
  let pending = 0;
  if (level > 1 && cls) {
    const grants = skillGrantsFor(cls, 1, level);
    const allowance = grants.reduce((n, g) => n + g.count, 0);
    const spent = Math.max(0, Math.min(allowance,
      Number.isFinite(Number(b.picks_spent)) ? Math.trunc(Number(b.picks_spent)) : 0));
    const remaining = remainingGrants(grants, spent);
    pending = remaining.reduce((n, g) => n + g.count, 0);
    statements.push(...insertGrantStatements(env, row.id, remaining));
  }

  if (statements.length) await env.DB.batch(statements);
  return json({ id: row.id, level, xp, picks_pending: pending }, 201);
}
