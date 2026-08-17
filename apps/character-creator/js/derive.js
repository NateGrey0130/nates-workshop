// Attribute-derived combat bonuses, saving throws, and percentages.
//
// Loaded as a classic script (both the wizard module and the sheet's plain
// script use it), so it exposes one global: `derive`.
//
// The numbers come from the Attribute Bonus Chart, Palladium Fantasy RPG 2nd
// Edition p.16, transcribed row by row below. Every number here is a DEFAULT —
// the sheet stores whatever the player saves, so a GM ruling always wins.
//
// Not derived, because they depend on rules this app does not model:
//   attacks per melee beyond the base 2 (comes from Hand to Hand skill + level)
//   knockout / critical / death-blow thresholds (hand to hand tables)

(function (global) {
  const n = (v) => (typeof v === 'number' && Number.isFinite(v) ? v : 0);

  // ─── the attribute bonus chart ───
  //
  // Each row holds the book's printed values for attributes 16 through 30;
  // index 0 is 16, and anything below 16 gets nothing.
  //
  // The rows are NOT one formula. P.S. damage does gain a point per point, but
  // strike, parry, dodge and most saves gain one per TWO points, and the two
  // percentile rows flatten near the top. This file used to apply `v - 15` to
  // every row and call it "the standard Palladium tables", which left every
  // parry, dodge, strike and save at roughly double the printed value, and let
  // M.A. and P.B. climb past 100%.
  //
  // `per`/`gain` continue a row above 30, where the book stops and dragons do
  // not: each `per` points beyond 30 adds `gain`, following the step the row
  // ends on. That extension is a house rule — everything at 30 and below is
  // the printed chart. `cap` bounds the two percentile rows at the same 98%
  // ceiling the skill percentages use.
  const CHART_MIN = 16, CHART_MAX = 30;
  const row = (values, per, gain, cap = null) => ({ values, per, gain, cap });

  const CHART = {
    //                16  17  18  19  20  21  22  23  24  25  26  27  28  29  30
    iq_skills:   row([ 2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16], 1, 1),
    me_psionic:  row([ 1,  1,  2,  2,  3,  3,  4,  4,  5,  5,  6,  6,  7,  7,  8], 2, 1),
    me_insanity: row([ 1,  1,  2,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13], 1, 1),
    ps_damage:   row([ 1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15], 1, 1),
    pp_combat:   row([ 1,  1,  2,  2,  3,  3,  4,  4,  5,  5,  6,  6,  7,  7,  8], 2, 1),
    pe_magic:    row([ 1,  1,  2,  2,  3,  3,  4,  4,  5,  5,  6,  6,  7,  7,  8], 2, 1),
    // Percentages, not flat bonuses.
    pe_coma_pct: row([ 4,  5,  6,  8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30], 1, 2),
    ma_trust:    row([40, 45, 50, 55, 60, 65, 70, 75, 80, 84, 88, 92, 94, 96, 97], 1, 1, 98),
    pb_charm:    row([30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 83, 86, 90, 92], 1, 2, 98),
  };

  function chart(name, v) {
    const r = CHART[name];
    if (!r || typeof v !== 'number' || !Number.isFinite(v) || v < CHART_MIN) return 0;
    let out = r.values[Math.min(v, CHART_MAX) - CHART_MIN];
    if (v > CHART_MAX) out += Math.floor((v - CHART_MAX) / r.per) * r.gain;
    return r.cap == null ? out : Math.min(out, r.cap);
  }

  // P.P. drives strike, parry, and dodge. P.S. drives damage.
  function deriveCombat(attrs = {}) {
    const pp = chart('pp_combat', attrs.PP);
    return {
      attacks: 2,                    // base; Hand to Hand adds more per level
      initiative: 0,
      strike: pp,
      parry: pp,
      dodge: pp,
      roll: 0,
      // Pull punch is in the Hand to Hand tables (p.49) and in three class
      // entries, but on no attribute row — it is trained, not innate. Zero
      // until a class or a human says otherwise.
      pull_punch: 0,
      damage_bonus: chart('ps_damage', attrs.PS),
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
  // The chart names only four saves: M.E. vs psionic attack, M.E. vs insanity,
  // P.E. vs coma/death, and P.E. vs magic/poison. Possession, horror factor,
  // pain, illusionary magic and mind control are not on it, so each borrows the
  // printed row for its own attribute — a house rule, and the reason they are
  // grouped rather than given rows above.
  //
  // Illusionary magic borrows the magic/poison row because it IS magic; mind
  // control borrows the psionic row because the books call it "psionic and
  // chemical". Both exist because real classes grant bonuses to them — the
  // adult Chiang-Ku is +3 to save vs illusionary magic, the Juicer +6 vs mind
  // control — and until there was a key, writing either did nothing at all.
  //
  // `psychicTier` is the character's own tier, used only for the psionic save
  // TARGET — the bonus stays purely M.E.
  function deriveSaves(attrs = {}, psychicTier = null) {
    const peMagic = chart('pe_magic', attrs.PE);
    const mePsionic = chart('me_psionic', attrs.ME);
    return {
      spell_magic: peMagic,
      ritual_magic: peMagic,
      psionics: mePsionic,
      psionics_target: psionicSaveTarget(psychicTier),
      toxins_poisons: peMagic,
      harmful_drugs: peMagic,
      insanity: chart('me_insanity', attrs.ME),
      possession: mePsionic,
      horror_factor: mePsionic,
      illusionary_magic: peMagic,
      mind_control: mePsionic,
      coma_death_pct: chart('pe_coma_pct', attrs.PE),
      pain: peMagic,
    };
  }

  // M.A. is how far people trust or fear you; P.B. is how far they are charmed.
  // The I.Q. row is a one-time bonus added to every skill percentage — exposed
  // here so the chart is complete in one place; applying it to a skill list is
  // the skill sheet's job, not this file's.
  function deriveBio(attrs = {}) {
    return {
      invoke_trust_pct: chart('ma_trust', attrs.MA),
      charm_impress_pct: chart('pb_charm', attrs.PB),
      iq_skill_bonus_pct: chart('iq_skills', attrs.IQ),
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
  // `rolled` is the character's stored attribute_bonuses: the result of rolling
  // the class's dice bonuses once at creation. A book that says "add 2D6 to
  // P.S." cannot be re-evaluated on every render, so the class states the dice
  // and the character remembers what they came up. An unrolled dice bonus
  // contributes nothing rather than guessing an average.
  function classBonuses(cls, level = 1, rolled = null) {
    const src = cls?.bonuses;
    const out = { attributes: {}, combat: {}, saves: {}, attribute_minimums: {} };
    if (!src) return out;

    const fold = (from) => {
      for (const group of ['attributes', 'combat', 'saves']) {
        for (const [k, v] of Object.entries(from?.[group] || {})) {
          const val = typeof v === 'number' ? v
            : (group === 'attributes' && typeof v === 'string' ? n(rolled?.[k]) : NaN);
          if (Number.isFinite(val)) out[group][k] = (out[group][k] || 0) + val;
        }
      }
    };
    fold(src);
    for (const step of src.at_level || []) {
      if (typeof step?.level === 'number' && step.level <= n(level)) fold(step);
    }
    // A floor the class guarantees, applied by effective() once the bonus has
    // landed. The stricter of any two wins, as attribute requirements do.
    for (const [k, v] of Object.entries(src.attribute_minimums || {})) {
      if (typeof v === 'number' && Number.isFinite(v)) {
        out.attribute_minimums[k] = Math.max(out.attribute_minimums[k] ?? 0, v);
      }
    }
    return out;
  }

  // Which attributes a class rolls a bonus for, and the dice for each. The
  // wizard rolls these once at creation; nothing else needs them.
  function diceBonuses(cls) {
    const out = {};
    const src = cls?.bonuses;
    if (!src) return out;
    for (const block of [src, ...(src.at_level || [])]) {
      for (const [k, v] of Object.entries(block?.attributes || {})) {
        if (typeof v === 'string' && v.trim()) out[k] = v.trim();
      }
    }
    return out;
  }

  // The attribute values every table should be read against: rolled plus what
  // the class grants. A bonus to an attribute the character does not have is
  // ignored rather than conjuring the attribute from nothing.
  function effective(attrs = {}, bonuses = null) {
    const add = bonuses?.attributes;
    const floors = bonuses?.attribute_minimums;
    if (!add && !floors) return { ...attrs };
    const out = { ...attrs };
    for (const [k, v] of Object.entries(add || {})) {
      if (typeof v === 'number' && typeof out[k] === 'number') out[k] = out[k] + v;
    }
    // "Minimum P.S. is 22; if lower, adjust up." Applied after the bonus, and
    // only to an attribute the character actually has — a floor must not
    // conjure an attribute from nothing any more than a bonus does.
    for (const [k, v] of Object.entries(floors || {})) {
      if (typeof v === 'number' && typeof out[k] === 'number' && out[k] < v) out[k] = v;
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
    diceBonuses,
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
