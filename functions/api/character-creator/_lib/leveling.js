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
  return proposal;
}
