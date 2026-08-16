// Attribute-derived combat bonuses, saving throws, and percentages.
//
// Loaded as a classic script (both the wizard module and the sheet's plain
// script use it), so it exposes one global: `derive`.
//
// These follow the standard Palladium attribute tables, which are consistent
// across most of the line: a bonus applies from 16 upward, one point per point
// above 15. Where a table is genuinely variable between books the value is a
// documented house rule, same as the XP curve and the point-buy pool. Every
// number here is a DEFAULT — the sheet stores whatever the player saves, so a
// GM ruling always wins.
//
// Not derived, because they depend on rules this app does not model:
//   attacks per melee beyond the base 2 (comes from Hand to Hand skill + level)
//   knockout / critical / death-blow thresholds (hand to hand tables)

(function (global) {
  const above15 = (v) => (typeof v === 'number' && v >= 16 ? v - 15 : 0);
  const n = (v) => (typeof v === 'number' && Number.isFinite(v) ? v : 0);

  // P.P. drives strike, parry, and dodge. P.S. drives damage.
  function deriveCombat(attrs = {}) {
    const pp = above15(attrs.PP);
    return {
      attacks: 2,                    // base; Hand to Hand adds more per level
      initiative: 0,
      strike: pp,
      parry: pp,
      dodge: pp,
      roll: 0,
      damage_bonus: above15(attrs.PS),
      // Spd × 5 yards per melee round is the standard movement rule.
      run_yards_per_melee: n(attrs.Spd) * 5,
    };
  }

  // Psychic tiers, weakest first. The only place the ordering is written down —
  // everything that asks "does this character reach that tier?" goes through
  // meetsTier() rather than comparing the strings itself.
  const TIERS = ['minor', 'major', 'master'];
  const tierRank = (t) => TIERS.indexOf(String(t ?? '').toLowerCase());

  // A character with no tier (not psychic) meets nothing; a requirement of
  // nothing is met by everyone. Both directions matter: NULL min_tier means
  // "no restriction", not "master only".
  function meetsTier(has, needs) {
    if (!needs) return true;
    const need = tierRank(needs);
    if (need < 0) return true;      // an unrecognised requirement gates nothing
    return tierRank(has) >= need;
  }

  // Save vs psionic attack. Major and Master psychics are harder to affect —
  // 12 or better, against 15 for everyone else, non-psychics included: they get
  // attacked by psionics too and still need a number to roll against.
  const PSIONIC_SAVE_STRONG = 12;
  const PSIONIC_SAVE_BASE = 15;
  function psionicSaveTarget(tier) {
    return meetsTier(tier, 'major') ? PSIONIC_SAVE_STRONG : PSIONIC_SAVE_BASE;
  }

  // P.E. covers the body (poison, drugs, coma/death), M.E. the mind
  // (psionics, insanity, possession).
  //
  // `psychicTier` is the character's own tier, used only for the psionic save
  // TARGET — the bonus stays purely M.E.
  function deriveSaves(attrs = {}, psychicTier = null) {
    const pe = above15(attrs.PE);
    const me = above15(attrs.ME);
    return {
      spell_magic: pe,
      ritual_magic: pe,
      psionics: me,
      psionics_target: psionicSaveTarget(psychicTier),
      toxins_poisons: pe,
      harmful_drugs: pe,
      insanity: me,
      possession: me,
      horror_factor: me,
      coma_death_pct: pe * 2,
      pain: pe,
    };
  }

  // M.A. is how far people trust or fear you; P.B. is how far they are charmed.
  // Both tables start at 16 and step 5% a point.
  function deriveBio(attrs = {}) {
    const ma = n(attrs.MA), pb = n(attrs.PB);
    return {
      invoke_trust_pct: ma >= 16 ? 40 + (ma - 16) * 5 : 0,
      charm_impress_pct: pb >= 16 ? 30 + (pb - 16) * 5 : 0,
    };
  }

  // ─── class bonuses ───
  //
  // Three layers, in this order:
  //
  //   1. the attribute tables above
  //   2. what the class grants          ← this
  //   3. whatever a human typed          (still wins, as it always has)
  //
  // Attribute bonuses are kept OUT of the stored attribute: a character's P.S.
  // stays the number that was rolled, and the class's +2 is added on the way
  // past. That keeps the provenance of every number visible, at the cost of
  // needing one funnel — effective() — that everything derived reads through.
  // Nothing should read a raw attribute for a derived value.

  // Everything the class grants by the level reached, folded into one block.
  // at_level entries accumulate: a class granting +1 attack at 5 and again at
  // 10 has given +2 by level 10.
  function classBonuses(cls, level = 1) {
    const src = cls?.bonuses;
    const out = { attributes: {}, combat: {}, saves: {} };
    if (!src) return out;

    const fold = (from) => {
      for (const group of ['attributes', 'combat', 'saves']) {
        for (const [k, v] of Object.entries(from?.[group] || {})) {
          if (typeof v === 'number' && Number.isFinite(v)) {
            out[group][k] = (out[group][k] || 0) + v;
          }
        }
      }
    };
    fold(src);
    for (const step of src.at_level || []) {
      if (typeof step?.level === 'number' && step.level <= n(level)) fold(step);
    }
    return out;
  }

  // The attribute values every table should be read against: rolled plus what
  // the class grants. A bonus to an attribute the character does not have is
  // ignored rather than conjuring the attribute from nothing.
  function effective(attrs = {}, bonuses = null) {
    const add = bonuses?.attributes;
    if (!add) return { ...attrs };
    const out = { ...attrs };
    for (const [k, v] of Object.entries(add)) {
      if (typeof v === 'number' && typeof out[k] === 'number') out[k] = out[k] + v;
    }
    return out;
  }

  function addBonus(derived, block) {
    if (!block) return derived;
    const out = { ...derived };
    for (const [k, v] of Object.entries(block)) {
      if (typeof v !== 'number' || !Number.isFinite(v)) continue;
      out[k] = (typeof out[k] === 'number' ? out[k] : 0) + v;
    }
    return out;
  }

  // Stored values win over derived ones; a blank/absent field falls back to the
  // derived default so a sheet is useful the moment it is created.
  function merge(derived, stored) {
    const out = { ...derived };
    for (const [k, v] of Object.entries(stored || {})) {
      if (v !== null && v !== undefined && v !== '') out[k] = v;
    }
    return out;
  }

  global.derive = {
    // `bonuses` is optional throughout — a call that omits it behaves exactly
    // as it did before class bonuses existed.
    combat: (attrs, stored, bonuses) =>
      merge(addBonus(deriveCombat(effective(attrs, bonuses)), bonuses?.combat), stored),
    // psychicTier is optional — callers that do not know it get the 15+ target,
    // which is correct for a non-psychic.
    saves: (attrs, stored, psychicTier, bonuses) =>
      merge(addBonus(deriveSaves(effective(attrs, bonuses), psychicTier), bonuses?.saves), stored),
    bio: (attrs, stored, bonuses) => merge(deriveBio(effective(attrs, bonuses)), stored),

    classBonuses,
    effective,

    // What made a number what it is, for the sheet's hover text: how much came
    // from the attribute tables and how much from the class. Without this the
    // only honest thing a tooltip could say is the total.
    parts(kind, attrs, bonuses, psychicTier) {
      const eff = effective(attrs, bonuses);
      const table = kind === 'saves' ? deriveSaves(eff, psychicTier)
        : kind === 'bio' ? deriveBio(eff)
        : deriveCombat(eff);
      // The attribute half of a class bonus shows up inside `table`, because the
      // table was read against the boosted attribute — so compare against the
      // same table read against the raw one to separate them.
      const raw = kind === 'saves' ? deriveSaves(attrs, psychicTier)
        : kind === 'bio' ? deriveBio(attrs)
        : deriveCombat(attrs);
      const direct = (kind === 'combat' ? bonuses?.combat : kind === 'saves' ? bonuses?.saves : null) || {};
      const out = {};
      for (const k of Object.keys(table)) {
        const fromAttrs = typeof raw[k] === 'number' ? raw[k] : 0;
        const viaAttrBonus = (typeof table[k] === 'number' ? table[k] : 0) - fromAttrs;
        out[k] = {
          attrs: fromAttrs,
          from_class: viaAttrBonus + (typeof direct[k] === 'number' ? direct[k] : 0),
        };
      }
      return out;
    },
    // Shared so the powers picker gates on the same ordering the saves use.
    meetsTier,
    tiers: TIERS,
    // Which keys came from the tables rather than being typed in — the sheet
    // marks these so it is obvious what is calculated.
    isDerived: (stored, key) => {
      const v = stored?.[key];
      return v === null || v === undefined || v === '';
    },
  };
})(globalThis);
