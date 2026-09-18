// Roll a complete NPC from a composed class: attributes, pools, skills, and the
// levels above one - the whole of what the wizard asks a player to decide, with
// every decision made at random and every one of them legal.
//
// Phase 1 of the NPC / bestiary work (migration 070). A G.M. wants "a 4th-level
// Brodkil raider, now", and the wizard is the only thing that builds a
// character - five thousand lines of state, client-side, one step at a time.
// This is the same build with the player taken out, as a PURE function: it
// reads a class and a catalog and returns the body POST /characters accepts. So
// the endpoint can run it, and so can a test that sweeps every published class
// and counts how many produce a character the validator accepts.
//
// IT SENDS ITS RESULT THROUGH THE SAME VALIDATOR a player's character goes
// through. Nothing here is trusted: a pick this module thinks is legal and the
// validator does not is a 422, which is the point - the two cannot quietly
// disagree about what a character is allowed to hold.
//
// ── Refuse, never pad ──
// Nate's decision (2026-09-17): when a pick cannot be made legally, NAME THE
// GAP and stop. Every other generator here returns wrong items when a category
// runs dry rather than fewer ones, and a wrong skill on an NPC looks exactly
// like a right one. So an allowance this module cannot fill from the class's
// own categories throws an NpcGap naming the class and the category, and a
// class feature it does not know how to choose for yet - a Morphus, an M.O.S.,
// a totem, abilities to pick - throws one naming the feature. Refusing is a
// finished answer; a guess is not.
//
// ── What it deliberately does NOT choose: powers ──
// Spells, psionic powers and Talents a class picks are BANKED, not chosen - the
// create path writes them to pending_power_picks and the sheet's banked-picks
// panel spends them. That panel already enforces every list, tier, level cap
// and tradition rule the validator knows, which is a surface this module would
// otherwise have to duplicate to pick a mage's spells at random. A G.M. choosing
// an NPC's spells is also usually the point. See bankedPowerGrants below.

import { rollAttribute, rollPoolFormula, evalDice } from './dice.js';
import { skillBase } from './skill-base.js';
import { isChoiceGroup, isAbilityChoice, categoryAllows, categoryBonus, categoryName,
         relatedFloorStatus } from './parser.js';
import { relatedAllowance, secondaryAllowance, skillGrantsFor, convertedPools, buildProposal,
         startingPicksFor } from './leveling.js';
import { isHandToHand } from './hand-to-hand.js';
import { isFamilyName, isRepeatableRow, otherRowFor } from './language-skills.js';

const ATTRS = ['IQ', 'ME', 'MA', 'PS', 'PP', 'PE', 'PB', 'Spd'];
const SKILL_PCT_CAP = 98;          // p.22, the same cap the wizard applies
// Re-rolls allowed to meet an attribute minimum. Large on purpose: the
// Berserker needs P.S. 16 AND P.E. 16 on 3D6, about one set in five hundred,
// and a re-roll is a few microseconds. A class whose minimum the dice truly
// cannot reach still fails fast enough to be a 422 rather than a hang.
const ATTRIBUTE_ATTEMPTS = 20000;

// A refusal: `code` says which kind, `detail` says exactly what. The endpoint
// turns this into a 422, and the class sweep counts them by code.
export class NpcGap extends Error {
  constructor(code, message, detail = {}) {
    super(message);
    this.name = 'NpcGap';
    this.code = code;
    this.detail = detail;
  }
}

const norm = (s) => String(s ?? '').trim().toLowerCase();

/**
 * Build one NPC.
 *
 * cls      the COMPOSED class, variant and occupation already folded in - the
 *          same object the create endpoint validates against.
 * level    the level to build at; clamped by the caller to the class's XP table.
 * catalog  skill rows { name, category, base, base_formula, per_level, systems },
 *          with the campaign's system bases already applied.
 * derive   the attribute-chart module (js/derive.js installs it as a global).
 * system   the campaign's game, for skills a single game prints.
 * random   injectable, so a test can make a run repeatable.
 */
export function generateNpc({ cls, level = 1, catalog, derive, system = null, random = Math.random, name = null,
                              chosen = { mos: null, abilities: [], totem: null }, powerCatalog = null,
                              gameSkills = null }) {
  if (!cls) throw new NpcGap('class_unknown', 'That class could not be loaded');
  refuseWhatWeCannotChoose(cls, chosen);

  const shuffle = (arr) => {
    const a = [...arr];
    for (let i = a.length - 1; i > 0; i--) {
      const j = Math.floor(random() * (i + 1));
      [a[i], a[j]] = [a[j], a[i]];
    }
    return a;
  };

  // ── attributes ──
  // Rolled as the wizard rolls them, exceptional die and all. A class that
  // sets a minimum is re-rolled until it is met rather than bumped to it: a
  // bumped attribute is a number no dice produced.
  const attributes = rollAttributesMeeting(cls);

  // The class's DICE bonuses, rolled once - a race's +1D4 P.S. The race and the
  // occupation are already one composed class here, so there is one roll where
  // the wizard makes two; the totals are the same dice either way.
  const rolled = rollDiceBonuses(cls, derive);

  // ── pools ──
  const pb = cls.bonuses?.pools || {};
  const pools = convertedPools(cls, {
    hp: rollPoolFormula(cls.hit_points_base, attributes, pb.hp),
    sdc: rollPoolFormula(cls.sdc_base, attributes, pb.sdc),
    mdc: rollPoolFormula(cls.mdc_base, attributes, pb.mdc),
    ppe: rollPoolFormula(cls.ppe_base, attributes, pb.ppe),
    isp: cls.psionics ? rollPoolFormula(cls.psionics.isp_base, attributes, pb.isp) : null,
  }, attributes);

  // ── skills at level one ──
  const rows = usableCatalog(catalog, system);
  // What a RANDOM pick DRAWS FROM FIRST: the skills this game's own classes name
  // (skillsNamedByClasses). A preference, not a filter - every candidate is
  // still legal either way, and a hard filter starved rules the class itself
  // states: the Nightbane Sorcerer must take two Science skills and Nightbane's
  // classes name one. So a pick takes an in-game skill whenever one fits, and
  // reaches past the game only for what the class requires and the game's
  // classes do not name. Class-stated skills and choice groups are the class's
  // own words and are never reordered by this.
  const inGame = (r) => !gameSkills || gameSkills.has(norm(r.name));
  const preferInGame = (list) => [...shuffle(list.filter(inGame)),
                                  ...shuffle(list.filter((r) => !inGame(r)))];
  const byName = new Map(rows.map((r) => [norm(r.name), r]));
  const iq = derive?.bio?.(attributes, null, derive.classBonuses?.(cls, 1, rolled))?.iq_skill_bonus_pct || 0;
  const taken = new Set();
  const skills = [];

  const withIq = (row) => (row.pct
    ? { ...row, pct: Math.min(SKILL_PCT_CAP, row.pct + iq), iq_bonus: iq }
    : { ...row, iq_bonus: 0 });

  // The class's own fixed skills, at the percentages the class or the catalog
  // states - resolveSkill() in the wizard, rule for rule.
  //
  // A name the class lists TWICE is taken once. Body Fixer's own entry does
  // this ("duplicate listing in source"), and a second row is a duplicate_skill
  // violation the validator refuses - the wizard included.
  const occ = cls.skills?.occ_skills || [];
  for (const s of occ) {
    if (isChoiceGroup(s) || !s?.name || taken.has(norm(s.name))) continue;
    const r = resolve(s.name, s, byName, attributes);
    skills.push(withIq({ name: s.name, category: 'Class', pct: r.base, per_level: r.per_level, type: 'occ' }));
    taken.add(norm(s.name));
  }

  // Choice groups: "pick two of these". The group's own base and bonus ride
  // along, as the wizard stores them.
  occ.forEach((group, gi) => {
    if (!isChoiceGroup(group)) return;
    const want = parseInt(group.choose, 10);
    if (!Number.isFinite(want) || want <= 0) return;
    // A group of Hand to Hand styles IS the class choosing its one style
    // ("Hand to Hand: Basic or Expert"), so a style is offered here - but only
    // while the character holds none, and only one is ever taken.
    const holdsStyle = [...taken].some(isHandToHand);
    const all = groupOptions(group, rows);
    const options = all.filter((n) => !taken.has(norm(n))
      && (!isHandToHand(n) || (!holdsStyle && want === 1)));
    // Options the character already HOLDS count toward the group: a class that
    // grants Horsemanship outright and also says "pick one Horsemanship" has
    // nothing left to choose, and holds what the book asked for. Nothing is
    // invented by accepting that; refusing it would refuse a correct character.
    const alreadyHeld = all.filter((n) => taken.has(norm(n))).length;
    if (options.length + alreadyHeld >= want && options.length < want) {
      for (const n of options) {
        const r = resolve(n, group, byName, attributes);
        skills.push(withIq({ name: n, category: 'Class', pct: r.base, per_level: r.per_level, type: 'occ' }));
        taken.add(norm(n));
      }
      return;
    }
    if (options.length < want) {
      throw new NpcGap('choice_group',
        `${cls.name || 'This class'} picks ${want} from ${describeGroup(group)}, and only `
        + `${options.length} can be taken that the character does not already hold`,
        { group: gi, want, have: options.length });
    }
    for (const n of shuffle(options).slice(0, want)) {
      const r = resolve(n, group, byName, attributes);
      skills.push(withIq({ name: n, category: 'Class', pct: r.base, per_level: r.per_level, type: 'occ' }));
      taken.add(norm(n));
    }
  });

  // Related skills, bounded by the class's categories, FLOORS FIRST: "at least
  // two from Espionage" is met before the free picks are spent, so a floor can
  // never be starved by the random ones.
  const relatedCats = cls.skills?.occ_related_skills?.categories || [];
  const relatedAt1 = relatedAllowance(cls, 1);
  const relatedPool = rows.filter((r) => pickable(r, taken) && categoryAllows(relatedCats, r));
  const relatedChosen = [];
  const floors = relatedFloorStatus(cls, [], relatedAt1).floors || [];
  for (const f of floors) {
    const wanted = new Set(f.categories.map(norm));
    const pool = preferInGame(relatedPool.filter((r) => wanted.has(norm(r.category)) && !taken.has(norm(r.name))));
    if (pool.length < f.count) {
      throw new NpcGap('related_floor',
        `${cls.name || 'This class'} needs ${f.count} related skills from ${f.categories.join(' or ')}, `
        + `and the catalog offers ${pool.length} it can take`, { floor: f.categories, want: f.count, have: pool.length });
    }
    for (const r of pool.slice(0, f.count)) { relatedChosen.push(r); taken.add(norm(r.name)); }
  }
  fill(relatedChosen, relatedAt1, relatedPool, 'related', relatedCats);
  for (const r of relatedChosen) {
    const base = skillBase(r, attributes) || 0;
    skills.push(withIq({ name: r.name, category: r.category,
      pct: base ? base + categoryBonus(relatedCats, r) : 0, per_level: r.per_level || 0, type: 'related' }));
  }

  // Secondary skills: unrestricted by category, the validator's reading.
  const secondaryAt1 = secondaryAllowance(cls, 1);
  const secondaryPool = rows.filter((r) => pickable(r, taken));
  const secondaryChosen = [];
  fill(secondaryChosen, secondaryAt1, secondaryPool, 'secondary', null);
  for (const r of secondaryChosen) {
    skills.push(withIq({ name: r.name, category: r.category,
      pct: skillBase(r, attributes) || 0, per_level: r.per_level || 0, type: 'secondary' }));
  }

  // ── the levels above one ──
  // The engine the live level-up and the wizard's Advancement step both use:
  // pools grow by the class's per-level dice, skills held since level one by
  // their per-level step, and every skill pick the levels grant is CHOSEN here -
  // at its catalog base, because a skill learned at level five is new.
  const pools1 = { hp_max: pools.hp, sdc_max: pools.sdc, mdc_max: pools.mdc, ppe_max: pools.ppe, isp_max: pools.isp };
  let finalSkills = skills;
  let picksSpent = 0;
  if (level > 1) {
    const proposal = buildProposal({ level: 1, skills, ...pools1 }, cls, level);
    for (const [field, change] of Object.entries(proposal.pools || {})) pools1[field] = change.to;
    const advanced = new Map((proposal.skills || []).map((s) => [norm(s.name), s.to]));
    finalSkills = skills.map((s) => (advanced.has(norm(s.name)) ? { ...s, pct: advanced.get(norm(s.name)) } : s));

    for (const g of skillGrantsFor(cls, 1, level)) {
      const cats = g.kind === 'secondary' ? null : g.categories;
      const pool = rows.filter((r) => pickable(r, taken) && (!cats || categoryAllows(cats, r)));
      const chosen = [];
      fill(chosen, g.count, pool, g.kind, cats, g.level);
      for (const r of chosen) {
        const base = skillBase(r, attributes) || 0;
        const bonus = g.kind === 'secondary' ? 0 : categoryBonus(cats || [], r);
        finalSkills.push(withIq({ name: r.name, category: r.category, pct: base ? base + bonus : 0,
          per_level: r.per_level || 0, type: g.kind === 'secondary' ? 'secondary' : 'related',
          gained_at_level: g.level }));
        picksSpent += 1;
      }
    }
  }

  return {
    name: name || `${cls.name || 'NPC'} (level ${level})`,
    level,
    attributes,
    attribute_bonuses: rolled.attributes,
    rolled_bonuses: { combat: rolled.combat, saves: rolled.saves },
    skills: finalSkills,
    powers: grantedPowers(cls, powerCatalog),
    // Not a POST /characters field: what the caller banks to pending_power_picks
    // after the insert. See bankedPowerGrants.
    banked_powers: bankedPowerGrants(cls),
    abilities: chosen.abilities || [],
    mos: chosen.mos ?? undefined,
    totem: chosen.totem ?? undefined,
    pools: { hp: pools1.hp_max, sdc: pools1.sdc_max, mdc: pools1.mdc_max, ppe: pools1.ppe_max, isp: pools1.isp_max },
    picks_spent: picksSpent,
    // No alignment: the book gives a class a range, not one, and choosing is
    // the G.M.'s. Money is rolled from the class's own formula, as the wizard does.
    bio: { money: rollMoney(cls, attributes) },
  };

  // Spend `count` picks from `pool` at random, or refuse naming what ran dry.
  // Adds to `taken` so no later pick can repeat one.
  function fill(into, count, pool, kind, cats, atLevel = 1) {
    const need = count - into.length;
    if (need <= 0) return;
    const open = preferInGame(pool.filter((r) => !taken.has(norm(r.name))));
    if (open.length < need) {
      const where = cats && cats.length ? cats.map(categoryName).join(', ') : 'any category';
      throw new NpcGap('pool_exhausted',
        `${cls.name || 'This class'} is owed ${count} ${kind} skill${count === 1 ? '' : 's'} at level ${atLevel} `
        + `from ${where}, and only ${into.length + open.length} can be taken`,
        { kind, level: atLevel, categories: (cats || []).map(categoryName), want: count, have: into.length + open.length });
    }
    for (const r of open.slice(0, need)) { into.push(r); taken.add(norm(r.name)); }
  }

  function rollAttributesMeeting(c) {
    // Read exactly as validate-character.js reads them: "none", null and
    // anything unparseable are no requirement.
    const mins = {};
    for (const [a, v] of Object.entries(c.attribute_requirements || {})) {
      if (v == null || norm(v) === 'none') continue;
      const n = parseInt(v, 10);
      if (Number.isFinite(n)) mins[a] = n;
    }
    for (let attempt = 0; attempt < ATTRIBUTE_ATTEMPTS; attempt++) {
      const out = {};
      for (const a of ATTRS) {
        const r = rollAttribute(c.attribute_dice?.[a] || '3d6');
        out[a] = r ? r.total : null;
      }
      const short = Object.entries(mins).find(([a, v]) => (out[a] ?? -1) < v);
      if (!short) return out;
    }
    throw new NpcGap('attribute_minimum',
      `${c.name || 'This class'} requires attributes its dice did not reach in ${ATTRIBUTE_ATTEMPTS} rolls`,
      { requirements: mins });
  }
}

/**
 * The catalog skills one game's classes NAME, lower-cased - what a random pick
 * for an NPC in that game may draw from.
 *
 * WHY THIS EXISTS: it was written while `skills.systems` was NULL on every
 * catalog row, when a random roller gave a Palladium Fantasy mercenary W.P.
 * Heavy Military Weapons, Demolitions and Language: Gargoyle. The catalog is
 * tagged now (zzzzzzzzzzzzzzzz-tag-skill-systems.sql), and `usableCatalog`
 * below already drops another game's skills. This stays as the NARROWER
 * preference inside that: a game's tag also counts the skills its core skill
 * list prints, and an NPC reads more like its book when it takes the ones the
 * game's own classes actually name.
 *
 * Read as QUOTED strings, one regex pass, because class frontmatter quotes the
 * skills it names. A bare substring search reads prose too - "truck", "art" and
 * "law" inside notes - and costs 390 scans of every class. Measured over the 337
 * published classes: Rifts 302 skills, Palladium Fantasy 105, Heroes Unlimited
 * 108, Nightbane 56, in about 7 ms for all of them.
 *
 * markdowns  the raw markdown of that game's published classes.
 * catalog    skill rows ({ name }).
 */
export function skillsNamedByClasses(markdowns, catalog) {
  const known = new Set((catalog || []).map((r) => norm(r.name)));
  const out = new Set();
  for (const md of markdowns || []) {
    for (const m of String(md).matchAll(/"([^"\n]{2,80})"/g)) {
      const n = norm(m[1]);
      if (known.has(n)) out.add(n);
    }
  }
  return out;
}

/**
 * The choices a class makes BEFORE its skills can be known: an M.O.S. (which
 * adds skills), the abilities it picks (which can add pools, psionics, magic),
 * and a totem animal (which adds skills and bonuses). Each changes the composed
 * class, so the caller composes once, calls this, and composes again with the
 * answer before calling generateNpc - the order composeClass itself imposes.
 *
 * Every pick is uniform over what the class offers. An ability that names the
 * occupations it grants (`occ_options` - the Godling's Magic Powers) is left
 * out: taking it means composing in a second occupation, which is a decision
 * about the whole NPC rather than one pick, and the G.M. can make it by asking
 * for that occupation directly.
 *
 * totems  rows of the `totems` table ({ slug, ... }).
 */
export function chooseClassOptions(cls, { totems = [], random = Math.random } = {}) {
  const shuffle = (arr) => {
    const a = [...arr];
    for (let i = a.length - 1; i > 0; i--) {
      const j = Math.floor(random() * (i + 1));
      [a[i], a[j]] = [a[j], a[i]];
    }
    return a;
  };
  const who = cls?.name || 'This class';
  const out = { mos: null, abilities: [], totem: null };

  const mos = cls?.skills?.mos;
  if (mos && Array.isArray(mos.options) && mos.options.length) {
    const want = Math.max(1, parseInt(mos.choose, 10) || 1);
    const ids = shuffle(mos.options).slice(0, want).map((o) => String(o.id || o.name));
    out.mos = want > 1 ? ids : ids[0];
  }

  const defs = new Map((cls?.special_abilities || [])
    .filter((e) => e && typeof e.name === 'string' && !isAbilityChoice(e))
    .map((e) => [norm(e.name), e]));
  const bringsAnOccupation = (opt) => {
    const d = (opt && typeof opt === 'object') ? opt : defs.get(norm(opt));
    return Array.isArray(d?.occ_options) && d.occ_options.length > 0;
  };
  for (const g of (cls?.special_abilities || []).filter(isAbilityChoice)) {
    const want = parseInt(g.choose, 10) || 0;
    if (want <= 0) continue;
    const opts = (g.from || []).filter((o) => !bringsAnOccupation(o))
      .map((o) => (typeof o === 'string' ? o : o?.name)).filter(Boolean);
    if (opts.length < want) {
      throw new NpcGap('abilities',
        `${who} picks ${want} abilit${want === 1 ? 'y' : 'ies'} from a list offering ${opts.length} `
        + 'that do not bring an occupation with them', { want, have: opts.length });
    }
    out.abilities.push(...shuffle(opts).slice(0, want));
  }

  if (cls?.totem) {
    if (!totems.length) throw new NpcGap('totem', `${who} picks a totem animal, and the totem catalog is empty`);
    out.totem = String(shuffle(totems)[0].slug).toLowerCase();
  }
  return out;
}

// The class features this module does not choose for yet, refused by name so
// the G.M. is told which one rather than handed a character missing it. An
// M.O.S., abilities and a totem are chosen by chooseClassOptions; arriving here
// unchosen means the caller skipped it, which is refused rather than ignored.
function refuseWhatWeCannotChoose(cls, chosen) {
  const who = cls.name || 'This class';
  if (cls.second_form) {
    throw new NpcGap('second_form', `${who} has a second form (a Morphus), which the NPC generator does not roll yet`);
  }
  if ((cls.special_abilities || []).some((e) => isAbilityChoice(e) && Number(e.choose) > 0)
      && !chosen.abilities?.length) {
    throw new NpcGap('abilities', `${who} has abilities to choose, and none were chosen`);
  }
  if (cls.skills?.mos && !chosen.mos) {
    throw new NpcGap('mos', `${who} takes a Military Occupational Specialty, and none was chosen`);
  }
  if (cls.totem && !chosen.totem) {
    throw new NpcGap('totem', `${who} picks a totem animal, and none was chosen`);
  }
  if (cls.skills?.skill_programs) {
    throw new NpcGap('skill_programs', `${who} takes skill programs, which the NPC generator does not pick yet`);
  }
  // Super abilities cannot be banked - pending_power_picks has no 'super' kind,
  // and a CHECK is a table rebuild to widen - so a class that PICKS them is
  // refused rather than built without its powers. Granted ones are fine.
  const supers = startingPicksFor(cls, 'super');
  if (supers.applicable && supers.total > 0) {
    throw new NpcGap('super_abilities', `${who} picks super abilities, which the NPC generator does not choose yet`);
  }
}

// A skill the generator may pick at random: not already held, not a Hand to
// Hand style (a character holds exactly one, and the class's own is the one it
// keeps - #1148), and not a repeatable family row like Language: Other, which
// only means something once a real language is named.
function pickable(row, taken) {
  return !taken.has(norm(row.name)) && !isHandToHand(row.name) && !isRepeatableRow(row.name);
}

// The catalog as this game offers it. `systems` NULL means every game.
function usableCatalog(catalog, system) {
  return (catalog || []).filter((r) => {
    if (!r?.name) return false;
    if (!system || r.systems == null) return true;
    let list = r.systems;
    if (typeof list === 'string') { try { list = JSON.parse(list); } catch { return true; } }
    return !Array.isArray(list) || !list.length || list.includes(system);
  });
}

// resolveSkill() in the wizard: an explicit base wins, a group's bonus adds to
// the catalog's, and a family member with no row takes its Other row's numbers.
function resolve(name, explicit, byName, attributes) {
  const cat = byName.get(norm(name))
    || (isFamilyName(name) ? (byName.get(norm(otherRowFor(name))) || {}) : {});
  const catBase = skillBase(cat, attributes);
  const base = explicit.base ?? (explicit.bonus && catBase ? catBase + explicit.bonus : catBase);
  return { base: base || 0, per_level: explicit.per_level ?? cat.per_level ?? 0 };
}

// Members of a repeatable family the catalog NAMES - "Language: Dragonese",
// "Literacy: Euro" - which is what a "Language: Other" pick becomes. The wizard
// asks the player to type a language; an NPC takes one the catalog already
// holds, so the name is a real row rather than one this module made up. Rows
// that are not a particular language are left out: the character's own native
// tongue is granted separately, and "All (magical)" is a spell, not a pick.
const NOT_A_LANGUAGE = /native|all \(magical\)/i;
function namedFamilyMembers(otherRow, rows) {
  const prefix = norm(String(otherRow).split(':')[0]) + ':';
  return rows.filter((r) => norm(r.name).startsWith(prefix) && !isRepeatableRow(r.name)
    && !NOT_A_LANGUAGE.test(r.name)).map((r) => r.name);
}

// A choice group's candidates as names. A from-list is read literally, with
// "Piloting: any" meaning every skill with that prefix and "Language: Other"
// meaning any language the catalog names; a category group offers every
// catalog skill in those categories.
function groupOptions(group, rows) {
  if (Array.isArray(group.from)) {
    const out = [];
    for (const n of group.from) {
      const m = String(n).match(/^(.*?):\s*any$/i);
      if (m) {
        const prefix = norm(m[1]) + ':';
        for (const r of rows) if (norm(r.name).startsWith(prefix) && !isRepeatableRow(r.name)) out.push(r.name);
      } else if (isRepeatableRow(n)) {
        out.push(...namedFamilyMembers(n, rows));
      } else {
        out.push(n);
      }
    }
    return [...new Set(out)];
  }
  if (Array.isArray(group.categories)) {
    const cats = new Set(group.categories.map((c) => norm(categoryName(c))));
    return rows.filter((r) => cats.has(norm(r.category)) && !isRepeatableRow(r.name)).map((r) => r.name);
  }
  return [];
}

function describeGroup(group) {
  if (Array.isArray(group.from)) return group.from.join(' / ');
  if (Array.isArray(group.categories)) return group.categories.map(categoryName).join(' / ') + ' skills';
  return 'the listed options';
}

// rollDiceBonusesOf() in the wizard.
function rollDiceBonuses(cls, derive) {
  const roll = (dice) => {
    const rolls = [dice].flat().map((d) => (typeof d === 'number' ? d : evalDice(d))).filter((v) => v != null);
    return rolls.length ? rolls.reduce((a, b) => a + b, 0) : null;
  };
  const out = { attributes: {}, combat: {}, saves: {} };
  if (!derive) return out;
  const byGroup = derive.diceBonusesByGroup(cls);
  for (const g of ['combat', 'saves']) {
    for (const [k, dice] of Object.entries(byGroup[g] || {})) {
      const v = roll(dice);
      if (v != null) out[g][k] = v;
    }
  }
  for (const [attr, dice] of Object.entries(derive.diceBonuses(cls))) {
    const v = roll(dice);
    if (v != null) out.attributes[attr] = v;
  }
  return out;
}

// The powers a class grants OUTRIGHT, held from the start - powersPayload() in
// the wizard, row for row, including the catalog fields the sheet's use button
// reads. `powerCatalog` is what _lib/power-picks.js loadPowerCatalog returns;
// without it the names are still held, with no cost to spend.
function grantedPowers(cls, powerCatalog) {
  const auto = (list) => [...new Set((list || []).filter((n) => typeof n === 'string' && n.trim())
    .map((n) => n.trim()))];
  const row = (kind, n) => powerCatalog?.[kind]?.get(n.toLowerCase());
  return [
    ...auto(cls?.magic?.spells).map((n) => {
      const sp = row('spell', n);
      return { type: 'spell', name: n, level: sp?.level, cost: sp?.ppe,
               ...(sp?.ppe_note ? { cost_note: sp.ppe_note } : {}) };
    }),
    ...auto(cls?.psionics?.powers).map((n) => {
      const p = row('psionic', n);
      return { type: 'psionic', name: n, category: p?.category, cost: p?.isp,
               ...(p?.isp_note ? { cost_note: p.isp_note } : {}) };
    }),
    ...auto(cls?.super_abilities?.abilities).map((n) => ({ type: 'super', name: n, category: row('super', n)?.tier })),
    ...auto(cls?.talents?.talents).map((n) => {
      const t = row('talent', n);
      return { type: 'talent', name: n, category: t?.tier, cost: t?.ppe, acquire_cost: t?.acquire_ppe,
               ...(t?.ppe_note ? { cost_note: t.ppe_note } : {}),
               ...(t?.form_required ? { form_required: t.form_required } : {}) };
    }),
  ];
}

// The spells, psionic powers and Talents the class lets the NPC choose AT
// LEVEL ONE, as grants in the shape _lib/power-picks.js
// insertPowerGrantStatements banks. The sheet's banked-picks panel spends them
// against every list, level cap, tradition and category rule the validator
// knows - which is why this module banks them rather than guessing a mage's
// spells.
//
// Level one ONLY. What the levels above one earn is banked by the caller
// through powerGrantsFor(cls, 1, level), which resolves each grant's level cap
// and traditions at the level that earned it - the same function a live
// level-up uses, so a generated level-5 NPC is owed exactly what one levelled
// by hand would be. Talent PURCHASES are the create path's own, for every
// character, and are not repeated here.
function bankedPowerGrants(cls) {
  const out = [];
  for (const kind of ['spell', 'psionic', 'talent']) {
    const start = startingPicksFor(cls, kind);
    if (!start.applicable) continue;
    start.groups.forEach((g, slot) => {
      out.push({ kind, level: 1, slot, count: g.count,
        spell_levels: g.spell_levels ?? null, traditions: g.traditions ?? null,
        categories: g.categories ?? null, from: g.from ?? null, note: g.note ?? null });
    });
  }
  return out;
}

function rollMoney(cls, attributes) {
  const money = rollPoolFormula(cls.starting_money, attributes);
  return money == null ? undefined : String(money);
}
