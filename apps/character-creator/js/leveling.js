// XP curve + level-up diff calculation.
//
// Lives in the app rather than under functions/ because BOTH sides need it:
// the API levels a character up, and the wizard now builds one that starts
// above level 1 and has to compute the same diff before the character exists.
// `functions/api/character-creator/_lib/leveling.js` re-exports this file, so
// every server import is unchanged and there is one engine, not two.
//
// Same arrangement as js/dice.js and js/parser.js, and for the same reason.
//
// Default XP table is a house rule — Palladium's ~20 per-class charts are
// content work for later. A class file can override it without any schema
// change by adding frontmatter `xp_table: [0, 2100, ...]` (cumulative XP
// required for level index+1). Doubling to level 5, then flattening,
// roughly tracking the shape of the official charts. Max level 15.

import { evalDice } from './dice.js';

const DEFAULT_XP_TABLE = [
  0, 2000, 4000, 8000, 16000, 25000, 35000, 50000,
  70000, 95000, 125000, 160000, 200000, 250000, 300000,
];

export function xpTableFor(cls) {
  const t = cls?.xp_table;
  const valid = Array.isArray(t) && t.length >= 2 && t.every((x) => typeof x === 'number') &&
    t.every((x, i) => i === 0 || x > t[i - 1]);
  return valid ? t : DEFAULT_XP_TABLE;
}

export function levelForXp(table, xp) {
  let level = 1;
  for (let i = 0; i < table.length; i++) if (xp >= table[i]) level = i + 1;
  return level;
}

// Cumulative XP required to be `level`, or null past the cap.
export function thresholdFor(table, level) {
  return level >= 1 && level <= table.length ? table[level - 1] : null;
}

// "P.E. + 1d6 per level" / "1d6/level" → "1d6"; null when a formula has no
// per-level component (those pools don't grow automatically on level-up).
//
// The trailing modifier is part of the capture, because a major psionic gains
// "1d6+1 per level" — matching only the dice silently dropped the +1 and cost
// the character a point of I.S.P. at every level for the life of the character.
export function perLevelDiceOf(formula) {
  const m = String(formula ?? '')
    .match(/(\d+\s*d\s*\d+(?:\s*x\s*\d+)?(?:\s*[+-]\s*\d+)?)\s*(?:per level|per lvl|\/\s*(?:level|lvl))/i);
  return m ? m[1] : null;
}

const SKILL_PCT_CAP = 98; // Palladium convention: 98% is the practical ceiling

// Extra skill picks the class grants for crossing levels, from
// skills.occ_related_skills.schedule — a different thing from
// level_progression[].grants, which is free text for display.
//
// Every threshold strictly above fromLevel and up to toLevel counts, so a jump
// from 2 to 7 collects both the level-3 and the level-6 grants, itemised by the
// level that earned them rather than merged into one pool.
export function skillGrantsFor(cls, fromLevel, toLevel) {
  const related = cls?.skills?.occ_related_skills;
  const secondary = cls?.skills?.secondary_skills;

  // Related picks are bounded by the class's categories; secondary picks are
  // not — the books draw them "from the previous list" without restriction, and
  // the validator has always treated them as unbounded.
  const relatedCats = Array.isArray(related?.categories) && related.categories.length
    ? related.categories
    : null;

  const from = (schedule, categories, kind) =>
    (Array.isArray(schedule) ? schedule : [])
      .filter((e) => Number.isFinite(e?.level) && e.level > fromLevel && e.level <= toLevel)
      .map((e) => ({
        level: e.level,
        count: Number.isFinite(e.count) && e.count > 0 ? e.count : 1,
        // Copied, not referenced: the class can be re-imported with different
        // categories later, and what this level-up granted should not change.
        categories,
        kind,
      }));

  return [...from(related?.schedule, relatedCats, 'related'),
          ...from(secondary?.schedule, null, 'secondary')]
    .sort((a, b) => a.level - b.level);
}

// New spells and psionic powers a class learns for crossing levels.
//
// THE DATA FOR THIS MOSTLY DOES NOT EXIST YET. `magic.spells_starting` and
// `psionics.powers_starting` are level-1 counts, and until these keys were
// added nothing in a class definition said what is learned per level. The books
// do state it — a Ley Line Walker learns new spells at every level — so the
// honest answer for a class that has not been re-imported is "not recorded",
// which is why `unknown` is a distinct result from an empty list.
//
// Inventing a number here instead would be the exact failure the import rules
// exist to prevent: see "A field the prompt does not mention is a field that
// never arrives" in the README.
//
//   applicable: false  the class has no magic / no psionics at all
//   unknown:    true   it has them, and states no per-level rule
//   grants:     [{ level, count }] itemised by the level that earned each
//
// A `*_schedule` is the COMPLETE statement when present and a flat
// `*_per_level` is ignored alongside it — two keys that combine is a rule
// nobody remembers correctly six months later.
function perLevelGrants(block, flatKey, scheduleKey, fromLevel, toLevel) {
  if (!block) return { applicable: false, unknown: false, grants: [], total: 0 };

  const schedule = block[scheduleKey];
  const flat = block[flatKey];
  const hasSchedule = Array.isArray(schedule) && schedule.length > 0;
  const hasFlat = Number.isFinite(flat) && flat > 0;
  if (!hasSchedule && !hasFlat) {
    return { applicable: true, unknown: true, grants: [], total: 0 };
  }

  const grants = [];
  if (hasSchedule) {
    // Every threshold strictly above fromLevel and up to toLevel, the same rule
    // skillGrantsFor applies — a jump from 2 to 7 collects both a level-3 and a
    // level-6 grant rather than only the highest.
    //
    // SEVERAL ENTRIES MAY SHARE A LEVEL. The Shifter gains three spells at each
    // level and each comes from a different place: one from its named list, one
    // Protection or Summoning spell from that list, and one of any kind capped
    // at its own level. Those are three grants, not one of three, because a
    // grant carries its own restriction — so `slot` distinguishes them and is
    // what everything downstream keys on alongside the level.
    const slots = new Map();
    for (const e of schedule) {
      if (!Number.isFinite(e?.level) || e.level <= fromLevel || e.level > toLevel) continue;
      const slot = slots.get(e.level) ?? 0;
      slots.set(e.level, slot + 1);
      grants.push({
        level: e.level,
        slot,
        count: Number.isFinite(e.count) && e.count > 0 ? e.count : 1,
        // Carried through rather than looked up later: a banked grant keeps the
        // restriction it was granted with, and the class can be re-imported.
        ...(Array.isArray(e.from) && e.from.length ? { from: e.from.map(String) } : {}),
        ...(typeof e.note === 'string' && e.note.trim() ? { note: e.note.trim() } : {}),
      });
    }
  } else {
    for (let level = fromLevel + 1; level <= toLevel; level++) {
      grants.push({ level, slot: 0, count: flat });
    }
  }
  grants.sort((a, b) => a.level - b.level || a.slot - b.slot);
  return { applicable: true, unknown: false, grants, total: grants.reduce((n, g) => n + g.count, 0) };
}

// Which SPELL levels the spells gained AT `level` may be drawn from.
//
// A separate question from `spell_levels_allowed`, which governs the starting
// selection and is a fixed list. The Ley Line Walker learns "2 additional
// spells per level of experience, equal to or lower than their current level of
// experience" - a cap that tracks the character rather than a list, and one
// that is STRICTER than the starting list at low levels: a fresh walker picks
// 12 spells from levels 1-4, and the two gained at level 2 may only be levels
// 1-2.
//
//   'up_to_character_level'  spell level <= the level that earned the grant
//   [1, 2]                   an explicit list, when a book states one
//   absent                   falls back to spell_levels_allowed
//
// null means unrestricted, which is what a class stating neither means.
//
// A SCHEDULE ENTRY MAY OVERRIDE ALL OF IT. Some books vary the cap per level
// rather than by one rule: the Mystic gains four spells at level 2 from spell
// levels 1-3 and three at level 3 from levels 1-4, then two per level from its
// own level downward. The first two are the character's level PLUS ONE and the
// rest are the character's level, which no single rule expresses — so the entry
// that states the count states the cap with it, and the class-wide rule is what
// entries without one fall back to.
export function spellLevelsForGrant(cls, level, slot = 0) {
  const magic = cls?.magic;
  if (!magic) return null;

  // Matched by level AND slot, because several entries can share a level and
  // each carries its own cap — the Shifter's third slot is capped at its own
  // level while the first two are not capped at all.
  const entry = entryAt(magic.spells_schedule, level, slot);
  if (entry && Array.isArray(entry.spell_levels) && entry.spell_levels.length) {
    return entry.spell_levels;
  }
  // A slot bounded by a NAMED LIST is not also bounded by a spell level: the
  // Shifter's list slots are bounded by the list, and only its third slot is
  // capped at the character's own level.
  if (entry && ((Array.isArray(entry.from) && entry.from.length) || entry.from_list)) return null;

  const rule = magic.spells_per_level_levels;
  if (rule === 'up_to_character_level') {
    return Array.from({ length: Math.max(0, level) }, (_, i) => i + 1);
  }
  if (Array.isArray(rule) && rule.length) return rule;
  return Array.isArray(magic.spell_levels_allowed) && magic.spell_levels_allowed.length
    ? magic.spell_levels_allowed
    : null;
}

// The nth entry at a given level. Schedule order is the slot order, which is
// how the book reads: the Shifter's first slot is its named list, its second is
// the Protection-or-Summoning one, its third is the level-capped free choice.
function entryAt(schedule, level, slot) {
  if (!Array.isArray(schedule)) return null;
  const atLevel = schedule.filter((e) => e?.level === level);
  return atLevel[slot] ?? null;
}

// The names a grant may be drawn from, when a book gives a list rather than a
// rule. null means "not restricted to a list" — which is different from an
// empty list, and is why this returns null rather than [].
export function spellNamesForGrant(cls, level, slot = 0) {
  const magic = cls?.magic;
  const entry = entryAt(magic?.spells_schedule, level, slot);
  if (!entry) return null;
  if (Array.isArray(entry.from) && entry.from.length) return entry.from.map(String);
  // `from_list` points at a list declared ONCE rather than repeated on every
  // entry - a thirty-four name list written out fourteen times would make one
  // correction fourteen edits.
  //
  // Two forms, because a class can have one list or several. The Shifter draws
  // from a single list, so `from_list: true` reads `spells_per_level_from`. The
  // Ley Line Rifter learns one spell from List A AND one from List B at every
  // level, so `from_list: "A"` names an entry in `spell_lists`.
  if (typeof entry.from_list === 'string') {
    const named = magic?.spell_lists?.[entry.from_list];
    return Array.isArray(named) && named.length ? named.map(String) : null;
  }
  if (entry.from_list === true && Array.isArray(magic?.spells_per_level_from)
      && magic.spells_per_level_from.length) {
    return magic.spells_per_level_from.map(String);
  }
  return null;
}

// A restriction the CATALOG CANNOT ENFORCE, shown to the player instead.
//
// Spells carry no category or tag — only a name, a level and a cost — so
// "non-dimension related or control based" and "any Summoning spell" have
// nothing to filter on. Inventing a classification for three hundred spells by
// reading their names would be exactly the guessing the import rules forbid, so
// the rule is stated where the choice is made and the player honours it.
//
// This is the skill-category posture, not the psychic-tier one: a restriction
// the app cannot check is one it should be honest about rather than silently
// drop or silently enforce wrongly.
export function grantNote(cls, kind, level, slot = 0) {
  const schedule = kind === 'psionic' ? cls?.psionics?.powers_schedule : cls?.magic?.spells_schedule;
  const entry = entryAt(schedule, level, slot);
  return entry && typeof entry.note === 'string' && entry.note.trim() ? entry.note.trim() : null;
}

export function spellGrantsFor(cls, fromLevel, toLevel) {
  return perLevelGrants(cls?.magic, 'spells_per_level', 'spells_schedule', fromLevel, toLevel);
}

export function psionicGrantsFor(cls, fromLevel, toLevel) {
  return perLevelGrants(cls?.psionics, 'powers_per_level', 'powers_schedule', fromLevel, toLevel);
}

// Which psionic CATEGORIES the powers gained AT `level` may come from.
//
// The same shape as spellLevelsForGrant, and it exists for the same reason: the
// restriction on what a level EARNS is not always the restriction on what the
// class started with. The Mystic starts with Sensitive and Healing powers and
// gains a SUPER one at levels 4 and 8 - a category a major psychic could not
// otherwise take at all.
//
// That last part is why this overrides rather than narrows. Tier is enforced by
// category here (every catalogued power has a NULL min_tier, so the per-power
// gate never fires), which means a grant naming Super IS the book granting an
// exception to the tier. Intersecting it with the class's own categories would
// throw the exception away and leave an empty picker.
//
// null means unrestricted, which is what a class stating neither means.
export function psionicCategoriesForGrant(cls, level, slot = 0) {
  const psi = cls?.psionics;
  if (!psi) return null;

  const entry = entryAt(psi.powers_schedule, level, slot);
  if (entry && Array.isArray(entry.categories) && entry.categories.length) return entry.categories;

  return Array.isArray(psi.categories_allowed) && psi.categories_allowed.length
    ? psi.categories_allowed
    : null;
}

// Proposed (not yet applied) diff for character reaching toLevel.
// `character` must carry parsed skills and the pool max columns.
export function buildProposal(character, cls, toLevel) {
  const fromLevel = character.level;
  const gained = toLevel - fromLevel;
  const proposal = { from_level: fromLevel, to_level: toLevel, pools: {}, skills: [], grants: [] };

  const poolFormulas = {
    hp_max: cls.hit_points_base,
    sdc_max: cls.sdc_base,
    mdc_max: cls.mdc_base,
    ppe_max: cls.ppe_base,
    isp_max: cls.psionics?.isp_base,
  };
  for (const [field, formula] of Object.entries(poolFormulas)) {
    const dice = perLevelDiceOf(formula);
    if (!dice || character[field] == null) continue;
    let add = 0;
    for (let i = 0; i < gained; i++) add += evalDice(dice);
    proposal.pools[field] = { from: character[field], to: character[field] + add };
  }

  for (const s of Array.isArray(character.skills) ? character.skills : []) {
    // A skill with no percentage (W.P.s, hand to hand) or no per-level step
    // does not advance. Secondary skills used to land here because the wizard
    // wrote per_level 0 on every one of them — the book gives them no O.C.C.
    // bonus, but they still "increase as the character grows in experience".
    if (!s.pct || !s.per_level) continue;
    proposal.skills.push({
      name: s.name, type: s.type,
      from: s.pct, to: Math.min(SKILL_PCT_CAP, s.pct + s.per_level * gained),
    });
  }

  for (const lp of cls.level_progression || []) {
    if (lp.level > fromLevel && lp.level <= toLevel) {
      proposal.grants.push({ level: lp.level, grants: lp.grants || [] });
    }
  }

  // Mechanical bonuses the class grants for crossing these levels, as opposed
  // to `grants` above, which is the book's wording and display-only.
  //
  // Reported, not written. Bonuses are applied by reading the class at render
  // time — derive.classBonuses(cls, level) — so crossing the level IS applying
  // them, and nothing needs to be stored on the character. This is here so the
  // level-up diff can say what is about to change rather than having a number
  // move on its own.
  proposal.bonuses = (cls.bonuses?.at_level || [])
    .filter((step) => typeof step?.level === 'number' && step.level > fromLevel && step.level <= toLevel)
    .map((step) => ({
      level: step.level,
      attributes: step.attributes || {},
      combat: step.combat || {},
      saves: step.saves || {},
    }));

  // Claimable skill picks, as opposed to `grants` above, which is advisory text.
  proposal.skill_picks = skillGrantsFor(cls, fromLevel, toLevel);
  proposal.skill_picks_total = proposal.skill_picks.reduce((n, g) => n + g.count, 0);

  // Spells and psionic powers the levels earn. Reported, and applied only by
  // the WIZARD's Advancement step — the sheet's live level-up renders named
  // fields and ignores these, so nothing there promises what it cannot deliver.
  // Applying them on a live level-up is a follow-up, not this change.
  proposal.spell_picks = spellGrantsFor(cls, fromLevel, toLevel);
  proposal.psionic_picks = psionicGrantsFor(cls, fromLevel, toLevel);
  return proposal;
}
