// Step 3 — how to determine psionics. Palladium Fantasy RPG 2nd Ed., p.20–21.
//
// An ES module rather than a classic script, unlike rules.js: the Workers
// runtime needs this too, because a character's rolled tier has to be folded
// into the class object the API returns. The sheet does not import it — it
// reads the tier off that composed class, exactly as it always has.

// Two routes to psychic powers, and they are alternatives rather than
// cumulative: take a psychic O.C.C., or roll percentile here. A class that
// already declares psionics has answered the question and does not roll.
//
// Master is deliberately unreachable: "A master psionic ... is available only
// from one of the psychic character classes."
//
// Ranges are the book's, read as "roll <= max, first match wins".
const PSIONIC_TABLE = [
  { max: 9, tier: 'major' },     // 01-09
  { max: 25, tier: 'minor' },    // 10-25
  { max: 100, tier: null },      // 26-00 — no psionics, and much the likeliest
];

export function psionicTierForRoll(roll) {
  const n = Number(roll);
  if (!Number.isFinite(n) || n < 1 || n > 100) return null;
  return (PSIONIC_TABLE.find((r) => n <= r.max) || {}).tier ?? null;
}

export function rollPsionics() {
  const roll = 1 + Math.floor(Math.random() * 100);
  return { roll, tier: psionicTierForRoll(roll) };
}

// The three categories a rolled psychic may draw from. Super is absent because
// it is master-only, and rolling cannot reach master.
export const PSIONIC_CATEGORIES = ['Healing', 'Physical', 'Sensitive'];

// What each tier gets. `shapes` is the choice the book offers: a minor psychic
// has one, a major psychic picks between depth and breadth.
//
// `categories: 1` means every power is drawn from a single category the player
// chooses; `categories: 3` means they may come from any of the three.
//
// The per-level clause is part of isp_base because that is the string the
// level-up flow parses — a major psychic gains 1d6+1 an experience level, not
// the 1d6 a minor one gets.
export const PSIONIC_TIER_RULES = {
  minor: {
    isp_base: 'M.E. + 2d6, +1d6 per level',
    shapes: [{ id: 'focused', count: 2, categories: 1, label: '2 powers from one category' }],
  },
  major: {
    isp_base: 'M.E. + 4d6, +1d6+1 per level',
    shapes: [
      { id: 'focused', count: 8, categories: 1, label: '8 powers, all from one category' },
      { id: 'broad', count: 6, categories: 3, label: '6 powers from any of the three' },
    ],
  },
};

// An unknown shape falls back to the tier's first, so a stale or hand-edited
// value cannot leave a character with no power allowance at all.
export function psionicShape(tier, shapeId) {
  const shapes = PSIONIC_TIER_RULES[tier]?.shapes;
  if (!shapes) return null;
  return shapes.find((s) => s.id === shapeId) || shapes[0];
}

// Psionics rolled on the table belong to the CHARACTER, not to either of its
// classes — that is the point of the table. Folding them into the class-shaped
// object means the save targets, the power gating and the level-up I.S.P.
// growth all keep reading one place, exactly as they do for a Mind Mage that
// was born psychic.
//
// The class wins where it has an opinion. A psychic O.C.C. never rolls, so a
// tier on the character alongside a tier on the class would be a contradiction,
// and the class is the one the books wrote down.
export function withRolledPsionics(cls, character) {
  const tier = character?.psychic_tier;
  if (!tier || !cls || cls.psionics) return cls;
  const spec = PSIONIC_TIER_RULES[tier];
  if (!spec) return cls;
  const shape = psionicShape(tier, character.psychic_shape);
  const out = {
    ...cls,
    psionics: {
      type: tier,
      isp_base: spec.isp_base,
      powers_starting: shape.count,
      categories_allowed: PSIONIC_CATEGORIES,
      from_roll: true,
    },
  };

  // What a major psionic pays for those powers (p.21): "all skill bonuses are
  // reduced by half (round down fractions) and the number of 'other' skills are
  // also reduced by half. Secondary skills are not affected."
  //
  // Only the starting related count is halved. The rule sits in the paragraph
  // describing what the character starts with; the scheduled grants at later
  // levels are a separate sentence about advancement, and secondary skills the
  // book excludes by name.
  //
  // The other half of the sentence — halving the skill BONUSES — is still not
  // expressible: a class skill stores one `base` with the O.C.C. parenthetical
  // bonus already folded in, so there is no separable bonus to halve.
  if (tier === 'major') {
    const related = out.skills?.occ_related_skills;
    if (related && Number.isFinite(related.count) && related.count > 0) {
      out.skills = {
        ...out.skills,
        occ_related_skills: {
          ...related,
          count: Math.floor(related.count / 2),
          halved_for_major_psionic: true,
        },
      };
    }
  }
  return out;
}

// Some races have no psychic potential at all — troll and orc are named (p.21).
// A class saying so skips Step 3 entirely rather than rolling and discarding.
export const rollsForPsionics = (cls) => !cls?.psionics && cls?.psionics_allowed !== false;
