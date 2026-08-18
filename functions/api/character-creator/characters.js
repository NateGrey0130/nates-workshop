// POST /api/character-creator/characters — save a finished level-1 character.
// Body: { campaign_id, name, class_id, attributes{}, skills[], powers[],
//         pools{hp,sdc,mdc,ppe,isp}, items[{item_id|custom_name, qty, equipped, notes}], notes }
// Skill counts, category restrictions and attribute minimums are checked here
// as well as in the wizard — the wizard's checks are a convenience that avoids a
// round trip, this is the boundary.

import { getUserEmail, unauthorized, json, readJson } from './_lib/auth.js';
import { paging, pagedQuery } from './_lib/paging.js';
import { loadCharacterClass } from './_lib/class-loader.js';
import { validateCharacter, loadSkillCategories } from './_lib/validate-character.js';

// GET /api/character-creator/characters — list for linking to sheets.
// ?campaign_id= filters; ?limit= and ?offset= page (default 200, max 500).
export async function onRequestGet({ request, env }) {
  if (!getUserEmail(request)) return unauthorized();
  const campaignId = new URL(request.url).searchParams.get('campaign_id');
  const { limit, offset } = paging(request);

  const base = `SELECT characters.id, characters.name, characters.class_id, characters.level,
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

  return json({ characters: page.results, total: page.total, limit: page.limit, offset: page.offset });
}

export async function onRequestPost({ request, env }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();

  const b = await readJson(request);
  if (!b) return json({ error: 'Invalid JSON body' }, 400);
  for (const field of ['campaign_id', 'name', 'class_id']) {
    if (!b[field]) return json({ error: `Missing required field: ${field}` }, 400);
  }
  const campaign = await env.DB.prepare('SELECT id FROM campaigns WHERE id = ?').bind(b.campaign_id).first();
  if (!campaign) return json({ error: 'Campaign not found' }, 404);

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
  // A class that grants psionics has already answered the question, so a rolled
  // tier is not recorded alongside it — the two would contradict each other.
  const tier = cls?.psionics?.from_roll ? rolledTier : null;
  const { violations } = validateCharacter({
    character: { level: 1 },
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
       psychic_tier, psychic_shape, level, xp,
       attributes, attribute_bonuses, rolled_bonuses, skills, powers, abilities,
       hp_max, hp_current, sdc_max, sdc_current, mdc_max, mdc_current,
       ppe_max, ppe_current, isp_max, isp_current,
       bio, combat, saves, armor, notes
     ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 1, 0, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
     RETURNING id`
  ).bind(
    b.campaign_id, email, b.name, b.class_id, variant, occId, occVariant, tier, tier ? psychicShape : null,
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
  if (items.length) {
    await env.DB.batch(items.map((it) =>
      env.DB.prepare(
        'INSERT INTO character_items (character_id, item_id, custom_name, qty, equipped, notes) VALUES (?, ?, ?, ?, ?, ?)'
      ).bind(row.id, it.item_id ?? null, it.custom_name ?? null, it.qty || 1, it.equipped ? 1 : 0, it.notes ?? null)
    ));
  }
  return json({ id: row.id }, 201);
}
