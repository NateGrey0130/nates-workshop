// What the wizard saves of the pools and the powers: the two payload builders
// that read nothing but the wizard's state, the composed class and the four
// power catalogs it holds.
//
// Moved out of app.js as they stood - same names, same bodies - so they are
// importable without a DOM. They still read the wizard's one S rather than
// taking the state as an argument; the builders that reach into the rest of
// app.js (skills, equipment, the second form, the save body) stayed there.
import { S } from './wizard-state.js';
import { withRolledPsionics } from './psionics.js';

// The class as this character actually plays it, once a rolled tier is folded
// in. Everything on this step reads THIS rather than S.cls, so a rolled psychic
// and a born one go down exactly the same path — the alternative was a second
// parallel set of branches for "psionics, but from the table".
export function psiClass() {
  return withRolledPsionics(S.cls, { psychic_tier: S.psiRoll?.tier, psychic_shape: S.psiShape });
}

// The pools as saved: the level-1 roll plus every level's growth. Kept apart in
// state — S.pools is what the class rolled, S.levelPools is what the levels
// added — so Review's reroll button can re-roll one, the other, or both without
// either having to be reconstructed by subtraction.
export function poolsPayload() {
  const base = S.pools || {};
  const add = {};
  for (const per of Object.values(S.levelPools || {})) {
    for (const [f, v] of Object.entries(per)) add[f] = (add[f] || 0) + v;
  }
  const out = {};
  for (const [key, field] of [['hp', 'hp_max'], ['sdc', 'sdc_max'], ['mdc', 'mdc_max'],
                              ['ppe', 'ppe_max'], ['isp', 'isp_max']]) {
    out[key] = base[key] == null ? base[key] : base[key] + (add[field] || 0);
  }
  return out;
}

export function powersPayload() {
  // Powers and spells the CLASS grants outright, as opposed to the ones the
  // player picked. They used to reach the character as nothing at all: the
  // wizard saved only S.spells and S.psi, so a Mind Melter's four automatic
  // powers and a Shifter's twenty known spells were listed by the class and
  // held by nobody. Granted ones come first and a pick that duplicates one
  // is dropped, so the list stays a set.
  const cls = psiClass();
  const auto = (list) => (list || []).filter((n) => typeof n === 'string' && n.trim()).map((n) => n.trim());
  const autoSpells = auto(cls?.magic?.spells);
  const autoPsi = auto(cls?.psionics?.powers);
  const autoSuper = auto(cls?.super_abilities?.abilities);
  const autoTalents = auto(cls?.talents?.talents);
  const held = (a, b) => {
    const seen = new Set(a.map((n) => n.toLowerCase()));
    return [...a, ...b.filter((n) => !seen.has(String(n).toLowerCase()))];
  };
  // Four sources, in order of how the character came by them: granted by the
  // class, chosen at level 1, then learned on the way up. `held` keeps the list
  // a set, so a spell learned later that the class already granted is dropped
  // rather than listed twice.
  //
  // The level-1 picks arrive from two places, and exactly one of them is ever
  // non-empty: the flat list when the class has a single starting group, the
  // per-group lists when it splits them. Concatenating both means neither the
  // reader nor the writer has to know which shape this class used.
  const flat = (byGroup) => Object.values(byGroup).flat().filter(Boolean);
  const startSpells = [...S.spells, ...flat(S.spellGroups)];
  const startPsi = [...S.psi, ...flat(S.psiGroups)];
  const startSuper = [...S.supers, ...flat(S.superGroups)];
  const startTalents = [...S.talents, ...flat(S.talentGroups)];
  const spellNames = held(held(autoSpells, startSpells), flat(S.levelSpells));
  const psiNames = held(held(autoPsi, startPsi), flat(S.levelPsi));
  const superNames = held(held(autoSuper, startSuper), flat(S.levelSupers));
  const talentNames = held(held(autoTalents, startTalents), flat(S.levelTalents));
  return [
    ...spellNames.map((n) => {
      const sp = S.spellCatalog.find((x) => x.name === n);
      return { type: 'spell', name: n, level: sp?.level, cost: sp?.ppe,
               ...(sp?.ppe_note ? { cost_note: sp.ppe_note } : {}) };
    }),
    ...psiNames.map((n) => {
      const p = S.psiCatalog.find((x) => x.name === n);
      // cost_note marks a variable cost: `cost` is the minimum, and the sheet's
      // use button deducts it while the note says how the real spend grows.
      return { type: 'psionic', name: n, category: p?.category, cost: p?.isp,
               ...(p?.isp_note ? { cost_note: p.isp_note } : {}) };
    }),
    // NO `cost` AND NO `level`, and neither is an omission: a super ability is
    // permanent and free, which is why `super_abilities` is its own table with
    // neither column. `category` carries the tier so the sheet can group them
    // the way it groups psionics, rather than inventing a third grouping key.
    ...superNames.map((n) => {
      const a = S.superCatalog.find((x) => x.name === n);
      return { type: 'super', name: n, category: a?.tier };
    }),
    // BOTH costs, which is what makes a Talent a Talent. `cost` is the
    // activation minimum - the same field a spell and a psionic power use, so
    // the sheet's use button works unchanged - and `acquire_cost` is the
    // permanent expenditure that bought it. `category` carries the tier, the
    // way the super-ability line above does, rather than inventing a fourth
    // grouping key for the sheet.
    ...talentNames.map((n) => {
      const t = S.talentCatalog.find((x) => x.name === n);
      return { type: 'talent', name: n, category: t?.tier, cost: t?.ppe,
               acquire_cost: t?.acquire_ppe,
               ...(t?.ppe_note ? { cost_note: t.ppe_note } : {}),
               ...(t?.form_required ? { form_required: t.form_required } : {}) };
    }),
  ];
}
