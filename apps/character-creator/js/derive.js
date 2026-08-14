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

  // P.E. covers the body (poison, drugs, coma/death), M.E. the mind
  // (psionics, insanity, possession).
  function deriveSaves(attrs = {}) {
    const pe = above15(attrs.PE);
    const me = above15(attrs.ME);
    return {
      spell_magic: pe,
      ritual_magic: pe,
      psionics: me,
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
    combat: (attrs, stored) => merge(deriveCombat(attrs), stored),
    saves: (attrs, stored) => merge(deriveSaves(attrs), stored),
    bio: (attrs, stored) => merge(deriveBio(attrs), stored),
    // Which keys came from the tables rather than being typed in — the sheet
    // marks these so it is obvious what is calculated.
    isDerived: (stored, key) => {
      const v = stored?.[key];
      return v === null || v === undefined || v === '';
    },
  };
})(globalThis);
