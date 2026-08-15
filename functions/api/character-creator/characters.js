// POST /api/character-creator/characters — save a finished level-1 character.
// Body: { campaign_id, name, class_id, attributes{}, skills[], powers[],
//         pools{hp,sdc,mdc,ppe,isp}, items[{item_id|custom_name, qty, equipped, notes}], notes }
// Skill counts, category restrictions and attribute minimums are checked here
// as well as in the wizard — the wizard's checks are a convenience that avoids a
// round trip, this is the boundary.

import { getUserEmail, unauthorized, json, readJson } from './_lib/auth.js';
import { paging, pagedQuery } from './_lib/paging.js';
import { loadClass } from './_lib/class-loader.js';
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

  // The wizard enforces these too; this is the boundary. A class that cannot be
  // resolved skips the check rather than blocking the save.
  const cls = await loadClass(env, request.url, b.class_id);
  const { violations } = validateCharacter({
    character: { level: 1 },
    cls,
    skills: b.skills || [],
    attributes: b.attributes || {},
    catalog: cls ? await loadSkillCategories(env) : null,
  });
  if (violations.length) {
    return json({ error: 'This character breaks its class rules', violations }, 422);
  }

  const p = b.pools || {};
  const row = await env.DB.prepare(
    `INSERT INTO characters (
       campaign_id, player_email, name, class_id, level, xp,
       attributes, skills, powers,
       hp_max, hp_current, sdc_max, sdc_current, mdc_max, mdc_current,
       ppe_max, ppe_current, isp_max, isp_current,
       bio, combat, saves, armor, notes
     ) VALUES (?, ?, ?, ?, 1, 0, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
     RETURNING id`
  ).bind(
    b.campaign_id, email, b.name, b.class_id,
    JSON.stringify(b.attributes || {}), JSON.stringify(b.skills || []), JSON.stringify(b.powers || []),
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
