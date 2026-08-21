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
    for (const e of schedule) {
      if (!Number.isFinite(e?.level) || e.level <= fromLevel || e.level > toLevel) continue;
      grants.push({ level: e.level, count: Number.isFinite(e.count) && e.count > 0 ? e.count : 1 });
    }
  } else {
    for (let level = fromLevel + 1; level <= toLevel; level++) grants.push({ level, count: flat });
  }
  grants.sort((a, b) => a.level - b.level);
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
export function spellLevelsForGrant(cls, level) {
  const magic = cls?.magic;
  if (!magic) return null;

  const entry = (Array.isArray(magic.spells_schedule) ? magic.spells_schedule : [])
    .find((e) => e?.level === level && Array.isArray(e.spell_levels) && e.spell_levels.length);
  if (entry) return entry.spell_levels;

  const rule = magic.spells_per_level_levels;
  if (rule === 'up_to_character_level') {
    return Array.from({ length: Math.max(0, level) }, (_, i) => i + 1);
  }
  if (Array.isArray(rule) && rule.length) return rule;
  return Array.isArray(magic.spell_levels_allowed) && magic.spell_levels_allowed.length
    ? magic.spell_levels_allowed
    : null;
}

export function spellGrantsFor(cls, fromLevel, toLevel) {
  return perLevelGrants(cls?.magic, 'spells_per_level', 'spells_schedule', fromLevel, toLevel);
}

export function psionicGrantsFor(cls, fromLevel, toLevel) {
  return perLevelGrants(cls?.psionics, 'powers_per_level', 'powers_schedule', fromLevel, toLevel);
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
