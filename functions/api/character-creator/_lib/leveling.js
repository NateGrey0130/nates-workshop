// XP curve + level-up diff calculation (Phase 4).
//
// Default XP table is a house rule — Palladium's ~20 per-class charts are
// content work for later. A class file can override it without any schema
// change by adding frontmatter `xp_table: [0, 2100, ...]` (cumulative XP
// required for level index+1). Doubling to level 5, then flattening,
// roughly tracking the shape of the official charts. Max level 15.

import { evalDice } from '../../../../apps/character-creator/js/dice.js';

export const DEFAULT_XP_TABLE = [
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
export function perLevelDiceOf(formula) {
  const m = String(formula ?? '').match(/(\d+\s*d\s*\d+(?:\s*x\s*\d+)?)\s*(?:per level|per lvl|\/\s*(?:level|lvl))/i);
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
  const schedule = Array.isArray(related?.schedule) ? related.schedule : [];
  const categories = Array.isArray(related?.categories) && related.categories.length
    ? related.categories
    : null;

  return schedule
    .filter((e) => Number.isFinite(e?.level) && e.level > fromLevel && e.level <= toLevel)
    .map((e) => ({
      level: e.level,
      count: Number.isFinite(e.count) && e.count > 0 ? e.count : 1,
      // Copied, not referenced: the class can be re-imported with different
      // categories later, and what this level-up granted should not change.
      categories,
    }))
    .sort((a, b) => a.level - b.level);
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
    if (!s.pct || !s.per_level) continue; // non-percentile skills and frozen secondaries don't advance
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
  return proposal;
}
