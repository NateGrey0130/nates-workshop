// PATCH  /api/character-creator/characters/:id/items/:itemId — qty / equipped /
//        notes / enchantments (owner/GM)
// DELETE /api/character-creator/characters/:id/items/:itemId — soft-remove: sets
//        removed_at so inventory history survives (never hard-deletes).

import { getUserEmail, unauthorized, json, forbidden, characterAccess } from '../../../_lib/auth.js';

async function guard(env, params, email) {
  const access = await characterAccess(env, params.id, email);
  if (!access.found) return { err: json({ error: 'Character not found' }, 404) };
  if (!access.canWrite) return { err: forbidden() };
  const row = await env.DB.prepare(
    'SELECT * FROM character_items WHERE id = ? AND character_id = ?'
  ).bind(params.itemId, params.id).first();
  if (!row) return { err: json({ error: 'Inventory row not found' }, 404) };
  return { row };
}

// What may be instilled in THIS item, checked server-side because the sheet is
// not the only caller and a stored slug that resolves to nothing renders as a
// slug forever.
//
// Three rules, all the book's:
//   * an armour feature goes in armour and a weapon property in a weapon;
//   * a charm power goes in "rings, bracelets, charms, and medallions" and the
//     book says outright it "cannot be instilled in weapons";
//   * four features to a suit, three to a weapon, three to a ring - carried on
//     the enchantment row as max_per_item rather than hardcoded here.
//
// A FREEFORM item (item_id NULL) has no category to check against, so the
// family rule is skipped for it rather than guessed at - a GM who writes in
// "silver signet ring" should be able to enchant it. The cap still applies.
async function validateEnchantments(env, row, value) {
  if (value === null || value === undefined) return { slugs: [] };
  if (!Array.isArray(value)) return { error: 'enchantments must be an array of slugs' };
  const slugs = [...new Set(value.map((v) => String(v || '').trim()).filter(Boolean))];
  if (!slugs.length) return { slugs: [] };

  const placeholders = slugs.map(() => '?').join(', ');
  const { results } = await env.DB.prepare(
    `SELECT slug, name, applies_to, max_per_item FROM enchantments WHERE slug IN (${placeholders})`
  ).bind(...slugs).all();

  const found = new Map((results || []).map((r) => [r.slug, r]));
  const missing = slugs.filter((sl) => !found.has(sl));
  if (missing.length) return { error: `No enchantment called ${missing.join(', ')}` };

  const families = new Set([...found.values()].map((r) => r.applies_to));
  if (families.size > 1) {
    return { error: `One item cannot mix ${[...families].join(' and ')} enchantments` };
  }
  const family = [...families][0];
  const cap = Math.min(...[...found.values()].map((r) => r.max_per_item || Infinity));
  if (Number.isFinite(cap) && slugs.length > cap) {
    return { error: `Only ${cap} ${family} enchantments fit in one item; ${slugs.length} given` };
  }

  // The gear row's category is what says whether this is armour or a weapon.
  if (row.item_id) {
    const item = await env.DB.prepare('SELECT category, name FROM gear WHERE id = ?')
      .bind(row.item_id).first();
    const category = item?.category || null;
    if (family === 'armor' && category !== 'armor') {
      return { error: `An armour feature needs a suit of armour, and ${item?.name || 'this item'} is ${category || 'uncategorised'}` };
    }
    if (family === 'weapon' && category !== 'weapon') {
      return { error: `A weapon property needs a weapon, and ${item?.name || 'this item'} is ${category || 'uncategorised'}` };
    }
    if (family === 'charm' && category === 'weapon') {
      return { error: 'A charm power cannot be instilled in a weapon' };
    }
  }
  return { slugs };
}

export async function onRequestPatch({ request, env, params }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();
  const { err, row } = await guard(env, params, email);
  if (err) return err;

  const b = await request.json();
  const sets = [], binds = [];
  if ('qty' in b) {
    const qty = parseInt(b.qty, 10);
    if (!Number.isFinite(qty) || qty < 1) return json({ error: 'qty must be a positive number' }, 400);
    sets.push('qty = ?'); binds.push(qty);
  }
  if ('equipped' in b) { sets.push('equipped = ?'); binds.push(b.equipped ? 1 : 0); }
  if ('notes' in b) { sets.push('notes = ?'); binds.push(b.notes ?? null); }
  if ('enchantments' in b) {
    const checked = await validateEnchantments(env, row, b.enchantments);
    if (checked.error) return json({ error: checked.error }, 400);
    sets.push('enchantments = ?'); binds.push(JSON.stringify(checked.slugs));
  }
  if (!sets.length) return json({ error: 'No editable fields in body' }, 400);

  await env.DB.prepare(`UPDATE character_items SET ${sets.join(', ')} WHERE id = ?`)
    .bind(...binds, params.itemId).run();
  return json({ ok: true });
}

export async function onRequestDelete({ request, env, params }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();
  const { err } = await guard(env, params, email);
  if (err) return err;

  await env.DB.prepare(
    "UPDATE character_items SET removed_at = datetime('now') WHERE id = ? AND removed_at IS NULL"
  ).bind(params.itemId).run();
  return json({ ok: true });
}
