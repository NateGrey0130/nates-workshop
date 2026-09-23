// The Ultimate Powers Book's seven steps, as one pure function.
//
// A hero is build(data, { seeds, picks }). `seeds` holds one seed per step, so
// rerolling a step is a new seed for that step and nothing else, and locking a
// step is keeping its seed. `picks` is what the player chose instead of
// rolling: a body type, an origin, a rank for an ability, which abilities a
// body type's free +1CS goes to. Everything the page shows is derived here, so
// the same seeds and picks always give the same hero - the smoke suite pins
// that.
//
// Rules the book leaves open are the README's rulings (R12-R18), cited where
// they bite.

import { rng, newSeed, d100, die, pick } from './dice.js';

export const PRIMARY = ['fighting', 'agility', 'strength', 'endurance', 'reason', 'intuition', 'psyche'];
export const STEPS = ['body', 'origin', 'abilities', 'weakness', 'counts', 'powers', 'talents'];
const POWER_RANK_COLUMN = '4';     // PB p.9: every hero's Power ranks roll on column 4
const SAFETY = 200;                 // attempts before a reroll loop gives up

export function newSeeds() {
  return Object.fromEntries(STEPS.map((s) => [s, newSeed()]));
}

export function makeGenerator(data) {
  const ladder = data.ranks.ranks;
  const idx = Object.fromEntries(ladder.map((r, i) => [r.id, i]));
  const rankById = Object.fromEntries(ladder.map((r) => [r.id, r]));
  const types = data['body-types'].types;
  const typeById = Object.fromEntries(types.map((t) => [t.id, t]));
  const powerByCode = Object.fromEntries(data.powers.powers.map((p) => [p.code, p]));
  const tables = data['power-tables'];
  const talents = data.talents.talents;

  const numberOf = (id) => (id === 'shift-0' ? 0 : rankById[id].initial ?? rankById[id].min);
  const shiftRank = (id, cs, lo = 'shift-0', hi = 'beyond') =>
    ladder[Math.max(idx[lo], Math.min(idx[hi], idx[id] + cs))].id;
  const rollRank = (next, column) => {
    const roll = d100(next);
    return { roll, rank: pick(data['random-ranks'].columns[column], roll).rank };
  };

  // ------------------------------------------------------------ 1. body
  // A type and its variant, merged: the variant's fields add to the type's.
  function merged(type, variantId) {
    const v = (type.variants || []).find((x) => x.id === variantId) || null;
    const add = (a = {}, b = {}) => {
      const out = { ...a };
      for (const [k, n] of Object.entries(b)) out[k] = (out[k] || 0) + n;
      return out;
    };
    return {
      type, variant: v,
      column: v?.column ?? type.column,
      shift: add(type.shift, v?.shift),
      set: { ...(type.set || {}), ...(v?.set || {}) },
      choose_shift: type.choose_shift || null,
      powers: type.powers || 0,
      bonus_powers: [...(type.bonus_powers || []), ...(v?.bonus_powers || [])],
      contacts: type.contacts || null,
      health_multiplier: type.health_multiplier || 1,
      notes: [...(type.notes || []), ...(v?.notes || [])],
    };
  }

  function stepBody(next, picks) {
    let roll = null, type;
    if (picks.body) type = typeById[picks.body];
    else {
      // Compound and Changeling arrive in the next update; until then a roll
      // that lands on them rolls again.
      for (let i = 0; i < SAFETY; i++) {
        roll = d100(next);
        type = pick(types, roll);
        if (!type.special) break;
      }
    }
    // R15: a type with two kinds - the player's pick, or even odds.
    let variant = null;
    if (type.variants) {
      variant = picks.variant && type.variants.some((v) => v.id === picks.variant)
        ? picks.variant : type.variants[die(next, type.variants.length) - 1].id;
    }
    return { roll, id: type.id, variant };
  }

  // ------------------------------------------------------------ 2. origin
  function stepOrigin(next, picks) {
    if (picks.origin) return { roll: null, id: picks.origin };
    const roll = d100(next);
    return { roll, id: pick(data.origins.origins, roll).id };
  }

  // ------------------------------------------------------------ 3. abilities
  // The d100s are kept, not the ranks: change the body type and the same dice
  // are read again on the new type's column.
  function stepAbilityDice(next) {
    return Object.fromEntries([...PRIMARY, 'resources', 'popularity'].map((a) => [a, d100(next)]));
  }

  function abilities(body, dice, picks) {
    const col = data['random-ranks'].columns[body.column];
    const out = {};
    for (const a of [...PRIMARY, 'resources', 'popularity']) {
      // UPB p.11: Primary Abilities, Resources and Popularity all roll on the
      // Random Ranks Table - on the body type's column.
      const rolled = picks.ranks?.[a] || pick(col, dice[a]).rank;
      out[a] = { roll: picks.ranks?.[a] ? null : dice[a], rolled, rank: rolled, picked: !!picks.ranks?.[a] };
    }
    // The free +1CS a type grants (Induced Mutant, Android, Humanoid): the
    // player's choice, or the dice's.
    const chosen = [];
    if (body.choose_shift) {
      const pool = body.choose_shift.from === 'any' ? [...PRIMARY, 'resources', 'popularity'] : PRIMARY;
      const want = (picks.choose || []).filter((a) => pool.includes(a)).slice(0, body.choose_shift.count);
      const pr = rng(Object.values(dice).reduce((s, d) => (s * 31 + d) >>> 0, 7));
      while (want.length < body.choose_shift.count) {
        const a = pool[die(pr, pool.length) - 1];
        if (!want.includes(a)) want.push(a);
      }
      chosen.push(...want);
    }
    for (const a of Object.keys(out)) {
      let r = out[a].rank;
      if (body.set[a]) r = body.set[a];
      const cs = (body.shift[a] || 0) + (chosen.includes(a) ? body.choose_shift.amount : 0);
      // R18: PB p.6 - an ability modifier moves no Primary Ability below
      // Feeble or above Monstrous. Resources and Popularity may reach zero.
      if (cs) r = PRIMARY.includes(a) ? shiftRank(r, cs, 'feeble', 'monstrous') : shiftRank(r, cs, 'shift-0', 'monstrous');
      out[a].rank = r;
      out[a].cs = cs;
      out[a].set = !!body.set[a];
      out[a].number = numberOf(r);
    }
    return { abilities: out, chosen };
  }

  // ------------------------------------------------------------ 4. weakness
  function stepWeakness(next, picks) {
    const w = data.weakness;
    const one = (part) => {
      if (picks.weakness?.[part]) return { roll: null, id: picks.weakness[part] };
      const roll = d100(next);
      return { roll, id: pick(w[part], roll).id };
    };
    return { stimulus: one('stimulus'), effect: one('effect'), duration: one('duration') };
  }

  // ------------------------------------------------------------ 5. counts
  function stepCounts(next) {
    const rows = data.counts.rows;
    const one = (kind) => { const roll = d100(next); return { roll, ...pick(rows, roll)[kind] }; };
    return { powers: one('powers'), talents: one('talents'), contacts: one('contacts') };
  }

  // ------------------------------------------------------------ 6. powers
  function rollPowerCode(next, cls = null) {
    const c = cls || pick(tables.classes, d100(next)).code;
    return pick(tables.tables[c], d100(next)).code;
  }

  function stepPowers(next, body, slotsTotal, picks) {
    const list = [];
    const has = (code) => list.some((p) => p.code === code);
    const used = () => list.filter((p) => p.source !== 'body').reduce((s, p) => s + p.slots, 0);
    const rank = (fixed) => fixed ? { rank: fixed, roll: null } : rollRank(next, POWER_RANK_COLUMN);

    // R17: Powers a body type grants come with the body and take no slot.
    for (const b of body.bonus_powers) {
      let code = b.code, tries = 0;
      while (!code || has(code)) { code = rollPowerCode(next, b.class); if (++tries > SAFETY) break; }
      if (!has(code)) list.push({ code, ...rank(b.rank), slots: 0, source: 'body' });
    }
    // The player's own picks come first, then the dice fill what is left.
    for (const code of picks.powers || []) {
      const p = powerByCode[code];
      if (!p || has(code)) continue;
      const slots = p.double ? 2 : 1;
      if (used() + slots > slotsTotal) break;
      list.push({ code, ...rank(null), slots, source: 'picked' });
    }
    let guard = 0;
    while (used() < slotsTotal && guard++ < SAFETY) {
      const code = rollPowerCode(next);
      const p = powerByCode[code];
      const slots = p.double ? 2 : 1;
      // UPB p.14: a double Power with no room is discarded and rolled again.
      if (has(code) || used() + slots > slotsTotal) continue;
      // UPB p.13 (addenda): a Bonus Power the listing names must be taken and
      // fills a slot; with no slot for it, the Power it came with goes instead.
      const bonus = (p.bonus || []).filter((b) => typeof b === 'string' && powerByCode[b] && !has(b) && b !== code);
      const bonusSlots = bonus.reduce((s, b) => s + (powerByCode[b].double ? 2 : 1), 0);
      if (used() + slots + bonusSlots > slotsTotal) continue;
      list.push({ code, ...rank(null), slots, source: 'rolled' });
      for (const b of bonus) list.push({ code: b, ...rank(null), slots: powerByCode[b].double ? 2 : 1, source: 'bonus', of: code });
    }
    return list;
  }

  // ------------------------------------------------------------ 7. talents
  function stepTalents(next, count, picks) {
    const list = [];
    const used = () => list.reduce((s, t) => s + t.slots, 0);
    for (const id of picks.talents || []) {
      const t = talents.find((x) => x.id === id);
      if (!t || list.some((x) => x.id === id)) continue;
      if (used() + (t.double ? 2 : 1) > count) break;
      list.push({ id, slots: t.double ? 2 : 1, source: 'picked' });
    }
    let guard = 0;
    while (used() < count && guard++ < SAFETY) {
      const group = pick(data.talents.groups, d100(next)).id;
      const roll = die(next, 10);
      const hits = talents.filter((t) => t.group === group && roll >= t.roll[0] && roll <= t.roll[1]);
      const t = hits[die(next, hits.length) - 1];
      const slots = t.double ? 2 : 1;
      if (list.some((x) => x.id === t.id) || used() + slots > count) continue;
      list.push({ id: t.id, slots, source: 'rolled' });
    }
    return list;
  }

  // ------------------------------------------------------------ the hero
  function build({ seeds, picks = {} }) {
    const R = (step) => rng(seeds[step]);
    const b = stepBody(R('body'), picks);
    const body = merged(typeById[b.id], b.variant);
    const origin = stepOrigin(R('origin'), picks);
    const { abilities: ab, chosen } = abilities(body, stepAbilityDice(R('abilities')), picks);
    const weakness = stepWeakness(R('weakness'), picks);
    const counts = stepCounts(R('counts'));

    // Buying extra Powers, Talents and Contacts with Resources, up to each
    // maximum (UPB p.14): -2CS a Power, -1CS a Talent or Contact, never below
    // Feeble (PB p.7).
    const bought = { powers: 0, talents: 0, contacts: 0, ...(picks.bought || {}) };
    for (const k of ['powers', 'talents', 'contacts']) {
      bought[k] = Math.max(0, Math.min(bought[k] | 0, counts[k].max - counts[k].initial));
    }
    const cost = bought.powers * 2 + bought.talents + bought.contacts;
    const resourcesBefore = ab.resources.rank;
    if (cost) {
      ab.resources.rank = shiftRank(ab.resources.rank, -cost, 'feeble', 'beyond');
      ab.resources.number = numberOf(ab.resources.rank);
    }
    const slots = Math.max(0, counts.powers.initial + body.powers + bought.powers);
    const powers = stepPowers(R('powers'), body, slots, picks);
    const talentSlots = counts.talents.initial + bought.talents;
    const talentList = stepTalents(R('talents'), talentSlots, picks);

    let contactSlots = counts.contacts.initial + bought.contacts;
    const c = body.contacts;
    if (c?.exact !== undefined) contactSlots = c.exact;
    else {
      if (c?.min !== undefined) contactSlots = Math.max(contactSlots, c.min);
      if (c?.max !== undefined) contactSlots = Math.min(contactSlots, c.max);
    }

    const sum = (keys) => keys.reduce((s, k) => s + ab[k].number, 0);
    const health = sum(['fighting', 'agility', 'strength', 'endurance']) * body.health_multiplier;
    const karma = sum(['reason', 'intuition', 'psyche']);
    // UPB p.12: with every Power Remarkable or lower, a Fatal Weakness may be
    // taken as Incapacitation instead.
    const fatalMayConvert = weakness.effect.id === 'fatal'
      && powers.every((p) => idx[p.rank] <= idx.remarkable);

    return {
      seeds: { ...seeds }, picks,
      body: { ...b, column: body.column, name: body.type.name, variantName: body.variant?.name ?? null, notes: body.notes },
      origin, abilities: ab, chosen, health, karma, weakness, fatalMayConvert,
      counts, bought, resourcesBefore,
      slots: { powers: slots, talents: talentSlots, contacts: contactSlots,
        max: { powers: counts.powers.max, talents: counts.talents.max, contacts: counts.contacts.max } },
      powers, talents: talentList, contacts: { slots: contactSlots, rule: c },
    };
  }

  return { build, merged, numberOf, types, typeById, powerByCode, ladder };
}
