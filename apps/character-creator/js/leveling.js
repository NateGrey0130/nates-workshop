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

import { evalDice, rollPoolFormula, poolFormulaBounds, diceBounds } from './dice.js';

const DEFAULT_XP_TABLE = [
  0, 2000, 4000, 8000, 16000, 25000, 35000, 50000,
  70000, 95000, 125000, 160000, 200000, 250000, 300000,
];

// Related-skill allowance grows with level: the class's starting count plus
// every scheduled grant the character has reached. Without this, any character
// who levelled up and spent a pick would read as over their limit.
//
// LIVES HERE, NOT IN THE SERVER VALIDATOR, since RETRO-AUDIT R18. The wizard
// and the validator have to agree about whether a character is legal, and the
// wizard cannot import from `functions/` - there is no build step. Keeping it
// beside `skillGrantsFor`, which is the only thing it needs, is what makes one
// implementation reachable from both sides; `validate-character.js` re-exports
// it so every existing server import is unchanged.
export function relatedAllowance(cls, level) {
  const base = cls?.skills?.occ_related_skills?.count ?? 0;
  // Only related-kind grants. A class can schedule secondary picks too, and
  // counting those here would let a character hold more related skills than the
  // class ever allowed.
  const granted = skillGrantsFor(cls, 1, level)
    .filter((g) => g.kind !== 'secondary')
    .reduce((n, g) => n + g.count, 0);
  return base + granted;
}

// The same for secondary skills, which can also arrive on a schedule - the Long
// Bowman gets one more at levels 4, 7, 10 and 13. Without this the class's
// starting count was the permanent ceiling, so spending a pick the class had
// just granted failed validation.
export function secondaryAllowance(cls, level) {
  const base = cls?.skills?.secondary_skills?.count ?? 0;
  const granted = skillGrantsFor(cls, 1, level)
    .filter((g) => g.kind === 'secondary')
    .reduce((n, g) => n + g.count, 0);
  return base + granted;
}

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

  // Slots are assigned AFTER the sort, so a grant's identity is stable: two
  // grants can share a level - a related and a secondary pick both land at 3 on
  // some classes - and `slot` is what tells them apart. Same counter
  // perLevelGrants uses for spells and psionics, so all three families key the
  // same way. BOOK-INGEST-AUDIT.md F72.
  const sorted = [...from(related?.schedule, relatedCats, 'related'),
                  ...from(secondary?.schedule, null, 'secondary')]
    .sort((a, b) => a.level - b.level);
  const slots = new Map();
  for (const g of sorted) {
    const slot = slots.get(g.level) ?? 0;
    slots.set(g.level, slot + 1);
    g.slot = slot;
  }
  return sorted;
}

// A grant's IDENTITY, and the thing every level-up pick is stored under.
//
// It is deliberately the same string the live level-up path already puts on the
// wire - sheet.js builds it and functions/api/character-creator/characters/
// [id]/level-confirm.js reads it - so the wizard and the sheet name a grant the
// same way instead of the wizard using its position in a list.
//
// Position was the bug: the list is derived from the composed class, so
// changing an occupation or an ability re-derives it and index 0 can come to
// mean a different grant. BOOK-INGEST-AUDIT.md F72.
export function grantKey(kind, g) {
  return `${kind}:${g?.level ?? 0}:${g?.slot ?? 0}`;
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
        //
        // A `from_list` is RESOLVED here into its names (BOOK-INGEST-AUDIT F61).
        // Only an inline `from` used to ride along, so the sheet's live level-up
        // picker - which reads `from` off the grant, being unable to import this
        // module - had no list at all for a from_list grant and offered every
        // spell in the system, while level-confirm refused anything off the list.
        ...(() => {
          const names = Array.isArray(e.from) && e.from.length ? e.from.map(String)
            : typeof e.from_list === 'string' && Array.isArray(block.spell_lists?.[e.from_list])
              && block.spell_lists[e.from_list].length ? block.spell_lists[e.from_list].map(String)
              : e.from_list === true && Array.isArray(block.spells_per_level_from)
                && block.spells_per_level_from.length ? block.spells_per_level_from.map(String)
                : null;
          return names ? { from: names } : {};
        })(),
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
  // The same rule the class-wide key takes, stated on ONE entry - and the way a
  // list-bound entry keeps a cap as well as its list (BOOK-INGEST-AUDIT F61).
  if (entry && entry.spell_levels === 'up_to_character_level') {
    return Array.from({ length: Math.max(0, level) }, (_, i) => i + 1);
  }
  // Otherwise a slot bounded by a NAMED LIST is not also bounded by a spell
  // level: the Shifter's list slots are bounded by the list alone, and only its
  // third slot is capped at the character's own level. A book that bounds a
  // pick by both - the Plant, Animal and Elemental Shamans - says so above.
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

// WHICH SPELL TRADITIONS A LEVEL-GATED POOL MAY REACH. BOOK-INGEST-AUDIT F57.
//
// A pool stated only as spell levels used to admit every leveled spell in the
// catalog, whatever tradition it belonged to: a new Ley Line Walker, whose pool
// is levels 1-4, was offered 150 warlock spells, 12 Ocean and 5 Dolphin ones
// beside the invocations its book grants (measured --remote, 2026-09-10).
//
// `spells.tradition` now names the family a spell belongs to - warlock, ocean,
// dolphin, spellsong, cloud, shaman - and NULL for a general invocation. A
// level-gated pick reaches a tradition's spells only when the class names it in
// `magic.spell_traditions_allowed`. A NAMED LIST IS UNTOUCHED: it already
// replaces the level gate, and a class that names a warlock spell gets it.
//
// `traditions` is the allowed list for one pick, lower-cased. [] means "general
// spells only". NULL means NO RESTRICTION, and exists for one case only: a
// level-up banked before this column did (pending_power_picks.spell_traditions
// NULL), which keeps the reach it was granted with - the same reading a NULL
// spell_levels already gets.
//
// One rule, and every pool builder asks it: the wizard's starting and level-up
// pickers, the server's creation validator and level-up claims. The sheet
// cannot import this module and inlines the same test.
export function spellTraditionsAllowed(cls) {
  const list = cls?.magic?.spell_traditions_allowed;
  return Array.isArray(list)
    ? [...new Set(list.map((t) => String(t).trim().toLowerCase()).filter(Boolean))]
    : [];
}

export function spellTraditionAllowed(spell, traditions) {
  const t = spell?.tradition ? String(spell.tradition).trim().toLowerCase() : '';
  if (!t) return true;
  if (traditions == null) return true;
  return traditions.some((x) => String(x).trim().toLowerCase() === t);
}

// A restriction the CATALOG CANNOT ENFORCE, shown to the player instead.
//
// Spells carry no category — only a name, a level, a cost and, since F57, the
// tradition a prefixed family belongs to (above) — so
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

// What a character may pick AT CREATION, as a list of pick-groups.
//
// Creation is not a level-up and never has been: `perLevelGrants` skips every
// schedule entry at or below `fromLevel`, and creation asks from level 1, so a
// level-1 schedule entry does not fire. That makes this the only place a
// STARTING pick's restriction can be stated, and until now it could hold only
// one count and one gate. Three books say otherwise:
//
//   - the Elemental Fusionist picks its first spell from an 18-name list,
//   - the Delphi Juicer starts with 3 Physical + 1 Super psionic powers, and
//   - the Mind Mage with three from each of four categories.
//
// The first had no way to name its list at all; the other two were stored as
// one open count over every category they touch, which let a player take four
// Super where the book grants one (CLASS-AUDIT.md S1 and S9).
//
// So this returns an ARRAY, the same shape `powerGrantsFor` already returns for
// level-up grants — and everything downstream of the two builders already
// handles several groups carrying different gates.
//
// `spells_starting` / `powers_starting` keep their meaning as the TOTAL, so a
// class stating only a number is unaffected and everything reading the total
// still reads one number. `*_starting_groups` splits that total across
// restrictions.
//
// A group's own restriction REPLACES the block's rather than narrowing it —
// the rule `spellNamesForGrant` and `psionicCategoriesForGrant` already apply
// to level-up grants, and for the same reason: a book naming Super for one slot
// is granting an exception to the class's categories, and intersecting would
// throw that away. A group naming nothing inherits the block's.
//
// A named `from` list is the tightest restriction there is and replaces the
// spell-level cap or the category gate outright, exactly as it does on a grant.
// `lists` is the block key `from_list` names, and only the spell side has one.
// A starting group may say `from_list: "A"` exactly as a schedule entry does —
// see the note on `from_list` in startingGroups below for why it did not, and
// what that cost.
const STARTING_SPEC = {
  spell: { block: 'magic', count: 'spells_starting', groups: 'spells_starting_groups',
           from: 'spells_from', gate: 'spell_levels_allowed', gateKey: 'spell_levels',
           granted: 'spells', schedule: 'spells_schedule', lists: 'spell_lists' },
  psionic: { block: 'psionics', count: 'powers_starting', groups: 'powers_starting_groups',
             from: 'powers_from', gate: 'categories_allowed', gateKey: 'categories',
             granted: 'powers', schedule: 'powers_schedule', lists: null },
};

const nonEmpty = (v) => (Array.isArray(v) && v.length ? v : null);

export function startingGroups(cls, kind) {
  const spec = STARTING_SPEC[kind];
  const block = spec && cls?.[spec.block];
  if (!block) return [];

  const blockFrom = nonEmpty(block[spec.from])?.map(String) ?? null;
  const blockGate = blockFrom ? null : nonEmpty(block[spec.gate]);
  // Which spell traditions a level-gated pick may reach - class-wide, the same
  // for every group. A named `from` still wins; see spellTraditionAllowed.
  const blockTraditions = kind === 'spell' ? spellTraditionsAllowed(cls) : null;
  const shape = (count, from, gate, note) => ({
    count,
    spell_levels: kind === 'spell' ? (from ? null : gate) : null,
    categories: kind === 'psionic' ? (from ? null : gate) : null,
    traditions: blockTraditions,
    from,
    ...(note ? { note } : {}),
  });

  // `from_list: "A"` names an entry in the block's `spell_lists`, exactly as it
  // does on a schedule entry. It resolves here since RETRO-AUDIT R11.
  //
  // BEFORE THAT IT WAS SILENTLY IGNORED, and the failure was invisible in every
  // direction: the group kept the block's `spell_levels_allowed` instead, so a
  // `from_list: "A"` on the Ley Line Rifter — whose List A is spell level 4 and
  // up — rendered a picker of level-1 and level-2 spells containing NONE of the
  // list. No error, no violation, nothing logged, and `class-check` cannot see
  // it either: `KNOWN_KEYS` validates top-level frontmatter only and never
  // inspects inside `magic`.
  //
  // It cost something before it was found. `add-warlock-*-class.sql` writes its
  // starting groups with inline `from`, duplicating lists that `spell_lists`
  // declares four lines below, because whoever wrote it hit this limit and
  // worked around it rather than reading why.
  const namedList = (key) => {
    if (typeof key !== 'string' || !spec.lists) return null;
    return nonEmpty(block[spec.lists]?.[key])?.map(String) ?? null;
  };

  const groups = nonEmpty(block[spec.groups]);
  if (groups) {
    const split = groups
      .filter((g) => Number(g?.count) > 0)
      .map((g) => {
        const from = nonEmpty(g.from)?.map(String) ?? namedList(g.from_list) ?? blockFrom;
        return shape(Number(g.count), from, nonEmpty(g[spec.gateKey]) ?? blockGate,
                     typeof g.note === 'string' && g.note.trim() ? g.note.trim() : null);
      });

    // THE COUNT CAN BE HIGHER THAN THE GROUPS, and only composition makes it so.
    //
    // `combineClasses` takes the HIGHER of the race's and the occupation's
    // `powers_starting` on purpose (parser.js) — the rule that stops a psychic
    // dragon hatchling being cut to one starting power for studying as a Dog
    // Boy. But the groups themselves are carried by a plain spread, so the
    // OCCUPATION's win outright, and reading only them threw that rule away: a
    // 7-power race taking a 5-power occupation with groups silently got 5.
    //
    // So whatever the composed count has over the groups comes back as one more
    // pick under the block's own gate. A class whose groups already sum to its
    // count — every class that states both — is untouched, because the
    // remainder is zero.
    const declared = Number(block[spec.count]);
    const summed = split.reduce((n, g) => n + g.count, 0);
    if (Number.isFinite(declared) && declared > summed) {
      split.push(shape(declared - summed, blockFrom, blockGate,
        'From the racial class, which grants more than the occupation splits.'));
    }
    return split;
  }

  const count = Number(block[spec.count]);
  if (!(count > 0)) return [];
  return [shape(count, blockFrom, blockGate, null)];
}

// WHAT AN EMPTY STARTING PICK MEANS — the three states `perLevelGrants` draws
// one level up, drawn here too.
//
// `startingGroups` returns [] for four different situations and the Powers step
// rendered all four the same way: the heading "Spells — 0/0", a filter box, and
// 543 checkbox rows, every one disabled because the allowance was zero. That is
// precisely the conflation the per-level side exists to avoid — "not recorded"
// is a different answer from "none", and a picker that cannot be used is
// neither.
//
//   applicable: false  no magic / no psionics at all, `type: "none"` included
//   unknown:    true   it has them and states no starting count
//   groups:     [...]  a real pick, one entry per group
//
// A STATED ZERO IS AN ANSWER. Five dragon hatchlings carry `spells_starting: 0`
// because their books say a hatchling "knows NO spells at first level" and
// learns them by the usual means from second level. Those read applicable,
// known, and empty — there is nothing missing from them.
//
// `granted` is what a class knows OUTRIGHT rather than picks: the Shifter's
// twenty spells, the Techno-Wizard's twenty-five. Those already reach the
// character — `powersPayload` folds them in, because before it did they were
// listed by the class and held by nobody — but the step that ought to show them
// never did, and a class whose spells are all granted has nothing to pick and
// is not missing a count either.
//
// `misfiled` counts picks written as a LEVEL-1 SCHEDULE ENTRY, which fires
// nowhere: creation asks `perLevelGrants` from level 1 and it skips every entry
// at or below `fromLevel` by design, and creation's own reader is this one,
// which reads the `*_starting` keys. The Wizard states six spells that way — two
// from spell level one, two from two, one each from three and four — and they
// are stated where nothing reads them. Counted and reported rather than
// honoured: honouring them would make a schedule a second way to say a starting
// pick, and one way is the whole reason the `*_starting` keys exist.
export function startingPicksFor(cls, kind) {
  const spec = STARTING_SPEC[kind];
  const block = spec && cls?.[spec.block];
  // `type: "none"` is a block that says the class is not a caster — the
  // Godling's, whose magic comes from the O.C.C. it picks alongside.
  if (!block || block.type === 'none') {
    return { applicable: false, unknown: false, groups: [], total: 0, granted: [], misfiled: 0 };
  }

  const granted = (Array.isArray(block[spec.granted]) ? block[spec.granted] : [])
    .filter((n) => typeof n === 'string' && n.trim()).map((n) => n.trim());
  const misfiled = (Array.isArray(block[spec.schedule]) ? block[spec.schedule] : [])
    .filter((e) => e?.level === 1)
    .reduce((n, e) => n + (Number.isFinite(e.count) && e.count > 0 ? e.count : 1), 0);

  const groups = startingGroups(cls, kind);
  const stated = block[spec.count] != null || Array.isArray(block[spec.groups]);
  return {
    applicable: true,
    unknown: !groups.length && !stated && !granted.length,
    groups,
    total: groups.reduce((n, g) => n + g.count, 0),
    granted,
    misfiled,
  };
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

// A MEGA-DAMAGE CONVERSION - BOOK-INGEST-AUDIT F62. The Totem Warrior's
// supernatural P.E. "turns the warrior into a mega-damage creature. Simply
// change his combined S.D.C. and hit points into an M.D.C. total. This is a
// constant state of being, even when in human form" (Spirit West printed 42).
// `mdc_from_hp_sdc: true` says so: hit points and S.D.C. are rolled from the
// formulas the class - or compose.js's core defaults - state, and their SUM is
// the M.D.C. maximum.
//
// OPT-IN, and it yields to a stated `mdc_base`: an M.D.C. race composed with a
// converting occupation keeps its own pool. One definition, read by the
// wizard's roll, the validator's bounds and the level-up proposal, so the three
// cannot disagree. NOT for a temporary conversion - the Psycho-Stalker spends
// I.S.P. to become M.D.C. for a minute, and stays an S.D.C. being.
export function convertsToMdc(cls) {
  return cls?.mdc_from_hp_sdc === true && cls.mdc_base == null;
}

// The wizard's rolled pools, converted: hit points and S.D.C. become one M.D.C.
// maximum, plus any `bonuses.pools.mdc`, and the two are left EMPTY - the sheet
// already hides a null pool and damageCascade already sends damage to M.D.C.
// when there is one. An unflagged class comes back exactly as it went in.
export function convertedPools(cls, pools, attrs = {}) {
  if (!convertsToMdc(cls) || !pools) return pools;
  if (pools.hp == null && pools.sdc == null) return pools;
  return { ...pools, hp: null, sdc: null,
    mdc: rollPoolFormula((pools.hp ?? 0) + (pools.sdc ?? 0), attrs, cls.bonuses?.pools?.mdc ?? null) };
}

// The range that converted maximum can legitimately hold at `level`: both
// formulas' bounds with their own pool bonuses and their per-level dice for
// each level after the first, plus the M.D.C. bonus. null when a formula cannot
// be read - an unreadable formula is a note, not a bound, as the validator has
// it for every other pool.
export function convertedMdcBounds(cls, attrs = {}, level = 1) {
  if (!convertsToMdc(cls)) return null;
  let min = 0;
  let max = 0;
  let any = false;
  for (const [formula, key] of [[cls.hit_points_base, 'hp'], [cls.sdc_base, 'sdc']]) {
    if (formula == null) continue;
    const b = poolFormulaBounds(formula, attrs, cls.bonuses?.pools?.[key] ?? null);
    if (!b) return null;
    const per = perLevelDiceOf(formula);
    const perB = per ? diceBounds(per) : null;
    min += b.min + (perB ? perB.min * (level - 1) : 0);
    max += b.max + (perB ? perB.max * (level - 1) : 0);
    any = true;
  }
  if (!any) return null;
  const bonus = poolFormulaBounds(0, attrs, cls.bonuses?.pools?.mdc ?? null);
  return { min: min + (bonus?.min ?? 0), max: max + (bonus?.max ?? 0) };
}

// Proposed (not yet applied) diff for character reaching toLevel.
// `character` must carry parsed skills and the pool max columns.
export function buildProposal(character, cls, toLevel) {
  const fromLevel = character.level;
  const gained = toLevel - fromLevel;
  const proposal = { from_level: fromLevel, to_level: toLevel, pools: {}, skills: [], grants: [] };

  const convert = convertsToMdc(cls);
  const poolFormulas = {
    hp_max: convert ? null : cls.hit_points_base,
    sdc_max: convert ? null : cls.sdc_base,
    mdc_max: convert ? null : cls.mdc_base,
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
  // A converted class grows its M.D.C. by what hit points and S.D.C. would have
  // grown by (F62). Those two pools are empty and a null `mdc_base` has no
  // per-level dice of its own, so without this the M.D.C. never grew at all.
  if (convert && character.mdc_max != null) {
    let add = 0;
    for (const formula of [cls.hit_points_base, cls.sdc_base]) {
      const dice = perLevelDiceOf(formula);
      if (dice) for (let i = 0; i < gained; i++) add += evalDice(dice);
    }
    if (add) proposal.pools.mdc_max = { from: character.mdc_max, to: character.mdc_max + add };
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
