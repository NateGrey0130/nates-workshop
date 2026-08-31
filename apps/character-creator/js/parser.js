import { diceBounds, isAbsentAttribute } from './dice.js';

// RCC/OCC markdown parser — YAML frontmatter → structured data, body → lore sections.
// Zero dependencies; runs in the browser, Node, and Cloudflare Pages Functions.
//
// Supported YAML subset (all the class files need, nothing more):
//   - key: scalar          (strings, numbers, booleans; quoted or bare)
//   - key:                 (nested map or list on following lines, 2-space indent)
//   - - scalar             (list of scalars)
//   - - { k: v, k2: v2 }   (list of inline objects)
//   - - key: v             (list of maps in block form, 2-space indent)
//   - [a, "b", c]          (inline arrays)
//   - # comments

const VALID_SYSTEMS = ['rifts', 'palladium-fantasy'];
const VALID_CATEGORIES = ['rcc', 'occ'];

// YAML block scalar introducers: | and > with optional chomping/indent modifiers.
const BLOCK_SCALAR = /^[|>][-+]?\d*$/;

// A "pick N from this list" entry inside occ_skills, as opposed to a fixed skill.
// A choice-group has no name of its own — it is "pick N from these". A named
// entry that also carries `choose` is a fixed skill taken N times (e.g.
// "Play Musical Instrument, select two instruments"), not a group.
// A catalog row can satisfy a choice group more than once when it stands in for
// a whole FAMILY: "Language: Other" for every language the books never print,
// "Literacy: Other" for every written one. A character takes either ONCE PER
// LANGUAGE, each pick a separate skill named for what it is. So
// `{ choose: 3, from: ["Language: Other"] }` is three languages, not an
// over-asking group, and the count check has to know that or the classes whose
// books say "three languages of choice" cannot say it.
//
// The name is duplicated rather than imported from js/language-skills.js on
// purpose: parser.js is loaded by the Workers runtime through several paths and
// is deliberately dependency-free apart from dice.js. One string, pinned by the
// smoke test against the module that owns it.
const REPEATABLE_SKILLS = ['language: other', 'literacy: other'];
const hasRepeatable = (from) =>
  (from || []).some((n) => REPEATABLE_SKILLS.includes(String(n?.name ?? n).trim().toLowerCase()));

export function isChoiceGroup(entry) {
  return !!entry && typeof entry === 'object' && !entry.name &&
    (entry.choose !== undefined || entry.from !== undefined || entry.categories !== undefined);
}

// ─── class variants ───
//
// Several RCCs come in stages rather than as one statblock: a Dragon is a
// hatchling, then young, then adult, sharing lore, natural abilities and skills
// while differing in attribute dice, M.D.C. and what the class grants. Four
// unrelated class files means maintaining the shared 90% four times.
//
// A variant may override ONLY these. Skills, abilities, lore and equipment stay
// shared on purpose: a variant that could override anything is not a variant,
// it is a second class wearing the first one's name, and the inheritance would
// obscure rather than explain.
export const VARIANT_OVERRIDES = [
  'attribute_dice', 'attribute_requirements',
  'hit_points_base', 'sdc_base', 'mdc_base', 'ppe_base',
  'starting_money',
  'bonuses',
  // NOT the skills block. `skill_overrides` below restates numbers on skills
  // the class already grants, which is a different and much smaller power.
  'skill_overrides',
];

// These two are flat maps of INDEPENDENT per-attribute values, so a variant
// naming one attribute is saying something about that attribute and nothing
// about the other seven. Replacing them wholesale meant an adult dragon that
// overrode only P.S. silently lost the base's I.Q. dice and rolled a plain 3d6.
//
// Everything else replaces. A scalar has nothing to merge, and `bonuses` is a
// nested structure where merging would raise "which half won" on every key —
// a variant's bonuses ARE its bonuses.
const VARIANT_MERGED = ['attribute_dice', 'attribute_requirements'];

// The class as this variant plays it. Returns the class unchanged when there is
// no variant, so every caller can apply it unconditionally.
export function applyVariant(cls, variantId) {
  if (!cls || !variantId || !Array.isArray(cls.variants)) return cls;
  const v = cls.variants.find((x) => x?.id === variantId);
  if (!v) return cls;

  const out = { ...cls };
  for (const key of VARIANT_OVERRIDES) {
    if (v[key] === undefined) continue;
    out[key] = VARIANT_MERGED.includes(key) && cls[key] && typeof cls[key] === 'object'
      ? { ...cls[key], ...v[key] }
      : v[key];
  }
  // Skills a stage holds at a different percentage. A Chiang-Ku hatchling
  // starts its advanced math and domestic skills at first-level proficiency
  // where the adult has them at 96% and 80%.
  //
  // Restating a number, not restructuring the list: an override names a skill
  // the class already grants and may change only its base and per-level step.
  // Naming anything else is a validation error rather than a way to smuggle a
  // skill in, which keeps the rule that a variant cannot rewrite what the class
  // teaches.
  if (Array.isArray(v.skill_overrides) && v.skill_overrides.length && out.skills?.occ_skills) {
    const byName = new Map(v.skill_overrides
      .filter((o) => o && typeof o.name === 'string')
      .map((o) => [o.name.trim().toLowerCase(), o]));
    out.skills = {
      ...out.skills,
      occ_skills: out.skills.occ_skills.map((s) => {
        const o = s?.name ? byName.get(s.name.trim().toLowerCase()) : null;
        if (!o) return s;
        return {
          ...s,
          ...(o.base !== undefined ? { base: o.base } : {}),
          ...(o.per_level !== undefined ? { per_level: o.per_level } : {}),
        };
      }),
    };
  }
  delete out.skill_overrides;

  // The variant's own name replaces the class's for display — "Dragon
  // Hatchling", not "Dragon" — while class_id keeps pointing at the one class.
  if (v.name) out.name = v.name;
  out.variant_id = v.id;
  return out;
}

// An override restates a number on a skill the class already grants. Naming
// anything else is an error rather than a silent no-op: it is either a typo or
// an attempt to add a skill, and both should be said out loud.
// One skill-entry shape, validated in one place. An entry is either a fixed
// skill ({name, base, per_level}) or a choice group ({choose, from|categories}).
// occ_skills uses it and so does every MOS option, because a book that says
// "gain all skills under that MOS" is describing the same list in a smaller box.
export function validateSkillEntries(where, entries, errors, warnings) {
  for (const s of entries || []) {
    if (!s || typeof s !== 'object') { errors.push(`${where} entries must be objects`); continue; }
    if (isChoiceGroup(s)) {
      // Two flavours: an enumerated `from` list, or `categories` when the book
      // says "any N skills from <category>" (e.g. "two piloting skills of choice").
      if (typeof s.choose !== 'number' || s.choose < 1) errors.push(`${where} choice-group needs a numeric choose >= 1`);
      const hasFrom = Array.isArray(s.from) && s.from.length > 0;
      const hasCats = Array.isArray(s.categories) && s.categories.length > 0;
      if (!hasFrom && !hasCats) {
        errors.push(`${where} choice-group needs a non-empty from list or categories list`);
      } else if (hasFrom && !hasCats && s.choose > s.from.length && !hasRepeatable(s.from)) {
        errors.push(`${where} choice-group asks for ${s.choose} of only ${s.from.length} options`);
      }
      // `base` fixes the percentage; `bonus` adds to whatever each pick's own
      // base is. Both at once has no single reading, and a group spanning a
      // category almost always wants the second: the members start at
      // different percentages, so one number cannot express "+30%".
      if (s.base !== undefined && s.bonus !== undefined) {
        errors.push(`${where} choice-group sets both base and bonus; use one`);
      }
      if (s.bonus !== undefined && (typeof s.bonus !== 'number' || !Number.isFinite(s.bonus))) {
        errors.push(`${where} choice-group bonus must be a number`);
      }
    } else if (!s.name) {
      errors.push(`${where} entries need a name (or choose/from for a choice-group)`);
    } else {
      // A FIXED skill takes its numbers one of two ways, and the distinction is
      // the one the books draw. "Language: Native Tongue at 96%" is a `base`:
      // the printed figure replaces the catalog row. "Chemistry (+10%)" is a
      // `bonus`: the O.C.C. adds ten points to whatever Chemistry starts at.
      //
      // Storing the second as the first is how the Cyber-Doc ended up with
      // Computer Operation at 5% where the catalog row is 40% - 48 skills
      // across 6 classes read that way. `resolveSkill` has always summed
      // `bonus` onto the catalog base; only this validator disagreed, warning
      // that a bonus-carrying entry "has no numeric base %".
      if (s.base !== undefined && s.bonus !== undefined) {
        errors.push(`${where} "${s.name}" sets both base and bonus; use one`);
      } else if (s.bonus !== undefined
                 && (typeof s.bonus !== 'number' || !Number.isFinite(s.bonus))) {
        errors.push(`${where} "${s.name}" bonus must be a number`);
      } else if (s.base === undefined && s.bonus === undefined) {
        warnings.push(`${where} "${s.name}" has no numeric base % or bonus`);
      } else if (s.base !== undefined && typeof s.base !== 'number') {
        warnings.push(`${where} "${s.name}" has no numeric base %`);
      }
    }
  }
}

// skills.mos - a Military Occupational Specialty.
//
//   mos:
//     choose: 1
//     note: "Gains all skills under that MOS."
//     options:
//       - { id: "communications", name: "Communications MOS", skills: [ ... ] }
//
// The Coalition Technical Officer offers seven, the Merc Soldier seven and the
// Robot Pilot two. The skills
// are granted IN ADDITION to the class's own occ_skills, which is what makes
// this a different thing from `variants` - a variant REPLACES, and
// VARIANT_OVERRIDES excludes the skills block on purpose.
export function validateMos(mos, errors, warnings) {
  if (mos === undefined || mos === null) return;
  if (typeof mos !== 'object' || Array.isArray(mos)) {
    errors.push('skills.mos must be a map');
    return;
  }
  if (mos.choose !== undefined && (typeof mos.choose !== 'number' || mos.choose < 1)) {
    errors.push('skills.mos.choose must be a number >= 1');
  }
  if (!Array.isArray(mos.options) || !mos.options.length) {
    errors.push('skills.mos needs a non-empty options list');
    return;
  }
  // Picking more specialties than exist is the same error an over-asking
  // choice group makes, and fails the same way: silently short.
  const want = mos.choose ?? 1;
  if (want > mos.options.length) {
    errors.push(`skills.mos asks for ${want} of only ${mos.options.length} options`);
  }
  const ids = new Set();
  for (const o of mos.options) {
    if (!o || typeof o !== 'object') { errors.push('skills.mos options must be objects'); continue; }
    if (!o.name) errors.push('skills.mos options need a name');
    // The id is what a character stores. Without one, a renamed option would
    // orphan every character that picked it.
    const id = o.id || o.name;
    if (id && ids.has(String(id).toLowerCase())) {
      errors.push(`skills.mos has two options called "${id}"`);
    }
    if (id) ids.add(String(id).toLowerCase());
    if (!Array.isArray(o.skills) || !o.skills.length) {
      errors.push(`skills.mos option "${o.name || id}" grants no skills`);
      continue;
    }
    validateSkillEntries(`skills.mos["${o.name || id}"]`, o.skills, errors, warnings);
  }
}

function validateSkillOverrides(v, granted, errors) {
  if (v.skill_overrides === undefined) return;
  if (!Array.isArray(v.skill_overrides)) {
    errors.push(`variant "${v.id}".skill_overrides must be a list`);
    return;
  }
  for (const o of v.skill_overrides) {
    if (!o || typeof o !== 'object' || typeof o.name !== 'string' || !o.name.trim()) {
      errors.push(`variant "${v.id}".skill_overrides entries need a name`);
      continue;
    }
    for (const key of ['base', 'per_level']) {
      if (o[key] !== undefined && (typeof o[key] !== 'number' || !Number.isFinite(o[key]))) {
        errors.push(`variant "${v.id}".skill_overrides.${o.name}.${key} must be a number`);
      }
    }
    if (o.base === undefined && o.per_level === undefined) {
      errors.push(`variant "${v.id}".skill_overrides.${o.name} changes nothing`);
    }
    if (granted && !granted.has(o.name.trim().toLowerCase())) {
      errors.push(`variant "${v.id}".skill_overrides names "${o.name}", which this class does not grant`);
    }
  }
}

function validateVariants(variants, errors, warnings, granted = null) {
  if (!Array.isArray(variants)) {
    errors.push('variants must be a list');
    return;
  }
  if (!variants.length) warnings.push('variants is empty and will be ignored');

  const seen = new Set();
  for (const v of variants) {
    if (!v || typeof v !== 'object') { errors.push('variants entries must be objects'); continue; }
    if (typeof v.id !== 'string' || !v.id.trim()) { errors.push('variants entries need an id'); continue; }
    if (seen.has(v.id)) errors.push(`variants has two entries with id "${v.id}"`);
    seen.add(v.id);
    if (!v.name) warnings.push(`variant "${v.id}" has no name and will display as the class name`);
    if (v.bonuses) validateBonuses(v.bonuses, errors, warnings);
    validateSkillOverrides(v, granted, errors);

    // A field a variant cannot override would silently do nothing, which is
    // exactly the confusion this list exists to prevent.
    for (const key of Object.keys(v)) {
      if (key === 'id' || key === 'name' || VARIANT_OVERRIDES.includes(key)) continue;
      warnings.push(`variant "${v.id}" sets ${key}, which a variant cannot override — it will be ignored`);
    }
  }
}

// ─── an R.C.C. and an O.C.C. together ───
//
// Palladium characters routinely have both. A Chiang-Ku Dragon who studies
// wizardry is a dragon AND a wizard, and the two contribute different halves:
// the race sets the body, the occupation sets what was learned.
//
// Composed into ONE class-shaped object rather than threaded through the app as
// a pair. Every consumer — the validator, the level-up diff, derive's bonuses,
// the sheet — reads `cls.skills`, `cls.bonuses`, the pool bases and so on, and
// none of them has to know a second class exists. The same trick applyVariant
// uses, one layer out.
//
// Weakest first. Duplicated from derive.js's ordering, which answers a
// different question (the psionic save TARGET) — keep the two in step.
// The only thing this file imports. `dice.js` imports nothing, so the edge is
// one-way and there is no cycle to reason about. F11 needs to compare two
// attribute dice expressions and say which is higher.
//
// NOT `attributeCeiling`, which was the obvious reuse and is WRONG for this.
// It adds the exceptional-dice chain, and that chain only applies to a plain
// 2d6 or 3d6 - so a bare `3d6` scores 18 + 12 while `4d6+4` scores 28 with no
// chain at all, and the weaker dice win. Measured before the swap: 41 of the 57
// races beat the Cosmo-Knight's printed M.E. that way.
//
// The mean is the comparison, from the dice bounds: it is what "these dice are
// higher than those" means, and it is stable where a ceiling is not - 1d20 and
// 3d6+2 share a ceiling of 20 and are not the same offer.
// How high an attribute expression reaches on average, for the one comparison
// this file makes (F11). Null when there is nothing to compare: an ABSENT
// attribute (F5) has no value, and an unreadable expression has no opinion -
// both lose to a side that does have one.
function attrReach(expr) {
  const s = String(expr ?? '').trim();
  if (!s || isAbsentAttribute(s)) return null;
  // A FIXED value is its own reach (F8).
  if (/^\d+$/.test(s)) return Number(s);
  const b = diceBounds(s);
  return b ? (b.min + b.max) / 2 : null;
}

const PSI_TIERS = ['minor', 'major', 'master'];
const tierRank = (t) => PSI_TIERS.indexOf(String(t ?? '').toLowerCase());

// Two lists into one, keeping the first spelling of anything named twice.
// Entries are either bare strings or objects with a `name`, which is every
// shape the granted-power, category and spell lists use.
//
// Shared by the psionics and magic merges (F10, F14). They ask the same
// question of different columns and one answer is easier to keep right than
// two - the pair that drifts is the pair that was written twice.
function unionByName(a, b) {
  const seen = new Set();
  const merged = [];
  for (const x of [...(a || []), ...(b || [])]) {
    const key = normName(typeof x === 'string' ? x : x?.name);
    if (!key || seen.has(key)) continue;
    seen.add(key);
    merged.push(x);
  }
  return merged;
}

// Fold two psionics blocks into one. BOOK-INGEST-AUDIT.md F10.
//
// This used to CHOOSE between them - the stronger tier took the whole block and
// the other was discarded entire. The premise was right about the TIER and
// wrong about everything else: a race states what a member of that race is born
// with, an occupation states what training adds, and the two are not rival
// answers to one question. Nothing about the noro being a major psychic means a
// noro psychic should not learn the twelve powers its own page grants.
//
// Measured over the live catalog before the change: 19 races and 19 occupations
// state psionics, and in 113 of their 361 pairings the occupation's block was
// thrown away with content in it. EVERY ONE of the nineteen occupations lost
// its block to at least one race. Two shipped classes had never composed
// correctly in the only pairing their own book sanctions - noro + noro-psychic
// and noro + noro-mystic-warrior are both `major`, so the tie went to the race.
//
// `born` is the race (or the class as already composed); `trained` is the
// occupation (or an ability the player took). The names matter, because the
// rules below are not symmetric.
function mergePsionics(born, trained) {
  if (!born) return trained;
  if (!trained) return born;

  // Spread first, so a key neither this function nor F10 knows about survives
  // rather than being silently dropped. The corpus uses nine, and `powers_from`
  // appears exactly once - which is the argument for not enumerating.
  const out = { ...born };
  for (const [k, v] of Object.entries(trained)) if (v !== undefined) out[k] = v;

  // A LADDER keeps the occupation's where it states one, falling back to the
  // race's - which is what the spread above already did. `powers_schedule` and
  // `powers_starting_groups` are per-level grants, and running both ladders
  // would fire both sets of grants at every threshold, which really would
  // over-grant. The occupation's is the career one.

  // A COUNT TAKES THE HIGHER, WHICH F10 DOES NOT ASK FOR. The finding says to
  // prefer the occupation's single count, reasoning that it is the number
  // written for a character who also has the race. That is true of a
  // specialisation like the noro psychic and false of an occupation a strong
  // psychic race merely takes: 165 of the 361 pairs state `powers_starting` on
  // both sides, and in 89 of them - the MAJORITY - the occupation's figure is
  // LOWER. Implemented as written, the change meant to stop a psychic losing
  // what it was born with would have cut a psychic dragon hatchling from eight
  // starting powers to one for studying as a Dog Boy. The higher of the two
  // never weakens anyone and never exceeds what a book states on its own, which
  // adding them would.
  for (const k of ['powers_starting', 'powers_per_level']) {
    const a = born[k], b = trained[k];
    if (Number.isFinite(a) && Number.isFinite(b)) out[k] = Math.max(a, b);
  }

  // The tier is the one thing the old comment was right about, and the I.S.P.
  // formula travels with it: one pool, one formula, belonging to whichever
  // block sets the tier. A TIE goes to the occupation, which is where all three
  // known ties are also the richer formula - the noro psychic's 3d6x10 against
  // the noro's 1d4x10, the mystic warrior's 4d6x10, the phase adept's 1d4x100
  // against the promethean's M.E. x5.
  //
  // F10 asks for "the higher isp_base" and that is NOT COMPUTABLE HERE.
  // Composition runs before attributes are rolled, and 7 of the 33 formulas in
  // the catalog lead with the M.E. term - `poolFormulaBounds` returns null for
  // every one of them without an attribute to substitute, and reads several of
  // the others as their leading dice alone. Choosing on a comparison that is
  // silently wrong is worse than choosing on a rule that is written down.
  const stronger = tierRank(trained.type) >= tierRank(born.type) ? trained : born;
  out.type = stronger.type;
  const isp = stronger.isp_base ?? born.isp_base ?? trained.isp_base;
  if (isp !== undefined) out.isp_base = isp;

  // A LIST is additive, and these two are the whole point of the finding.
  // Deduplicated by name because 66 of the pairs grant a power both sides also
  // grant - the entrancer and the noro psychic share three - and a character
  // must not hold the same power twice.
  const powers = unionByName(born.powers, trained.powers);
  if (powers.length) out.powers = powers;

  // `categories_allowed` IS UNIONED, WHICH F10 DOES NOT ASK FOR. The finding
  // lists it among the fields to take from the occupation, and taking it there
  // NARROWS in 110 of the 204 pairs that state it on both sides: a psychic
  // dragon hatchling who becomes a Crazy would lose Healing, Physical and
  // Sensitive - three categories its own race page grants it. That is the exact
  // loss F10 was written to stop, and its own sentence is the argument against
  // its list: training adds to birth, it does not replace it.
  const cats = unionByName(born.categories_allowed, trained.categories_allowed);
  if (cats.length) out.categories_allowed = cats;

  return out;
}

// Every psionics block a class carries: its own, and any a special ability
// grants. Both reach `categoryAllows` at pick time, so both are validated.
function psionicBlocks(data) {
  const out = [];
  if (data?.psionics) out.push(['psionics', data.psionics]);
  for (const d of data?.special_abilities || []) {
    if (d && typeof d === 'object' && d.psionics) {
      out.push([`special_abilities.${d.name}.psionics`, d.psionics]);
    }
  }
  return out;
}

// The same fold for magic. BOOK-INGEST-AUDIT.md F14.
//
// F10 excluded this saying "no race/O.C.C. pair in the catalog states both".
// THIRTEEN races and eighteen occupations state `magic` - 234 pairs - and the
// line this replaces was `out.magic = occ.magic || rcc.magic`, which is worse
// than the psionics bug it sat beside: psionics at least gave the RACE the tie,
// while magic handed the occupation the win with no comparison at all.
//
// THE TYPE IS NOT A LADDER, which is the one real difference from psionics.
// `psionics.type` is minor < major < master and there is a stronger to compute.
// The magic types in this catalog are `spell`, `elemental`, `druid`,
// `intuitive`, `none`, and two named after their class - they are KINDS, not
// degrees. So the occupation's wins where it states one: a race's generic
// `spell` must not overwrite a Warlock's `elemental`, which says how the
// character casts.
function mergeMagic(born, trained) {
  if (!born) return trained;
  if (!trained) return born;

  // Spread first, so an unenumerated key survives. The magic blocks in this
  // catalog use ELEVEN keys - two more than psionics, `spell_lists` and
  // `spells_starting_groups` appearing once each - which is the argument for
  // not writing the list out.
  const out = { ...born };
  for (const [k, v] of Object.entries(trained)) if (v !== undefined) out[k] = v;

  // Inventories add up. 28 pairs grant named spells on both sides and 9 of them
  // overlap, so the dedupe is not decoration.
  const spells = unionByName(born.spells, trained.spells);
  if (spells.length) out.spells = spells;

  // `spell_levels_allowed` is a set of levels, and the wider one is the answer
  // for the same reason `categories_allowed` is unioned: taking the
  // occupation's DROPS a level the race allows in 19 of the 28 pairs that state
  // both - an entrancer who becomes a Warlock would lose levels 2, 3 and 4 its
  // own page grants.
  const levels = [...new Set([...(born.spell_levels_allowed || []),
                              ...(trained.spell_levels_allowed || [])])]
    .filter((n) => Number.isFinite(n)).sort((a, b) => a - b);
  if (levels.length) out.spell_levels_allowed = levels;

  // A count takes the higher, the same reading F10 arrived at: 108 pairs state
  // `spells_starting` on both sides and the occupation's is LOWER in 35 of
  // them, so preferring it would cut a royal frilled dragon hatchling from six
  // starting spells to one for studying as an Elemental Fusionist.
  for (const k of ['spells_starting', 'spells_per_level']) {
    const a = born[k], b = trained[k];
    if (Number.isFinite(a) && Number.isFinite(b)) out[k] = Math.max(a, b);
  }

  // Everything else - the ladders and the named source lists - keeps the
  // occupation's where it states one, which the spread above already did.
  return out;
}

// Merging two classes' bonuses for one key.
//
// Numbers add. Anything else — a dice expression — CANNOT be added: a race
// granting "+1d4 P.S." and an occupation granting "+2d6" means both are rolled,
// and there is no single expression that says so. So mixed or repeated dice
// collect into a list, and the roller evaluates each.
//
// This used to be `if (typeof v === 'number')`, which silently DROPPED any
// dice-valued bonus arriving from the second class. An R.C.C. composed with the
// Cyber-Knight lost all five of its +1D4s, and nothing anywhere said so.
function mergeBonusValue(have, incoming) {
  if (incoming === undefined || incoming === null) return have;
  if (have === undefined) return incoming;
  if (typeof have === 'number' && typeof incoming === 'number') return have + incoming;
  return [...[have].flat(), ...[incoming].flat()];
}

function mergeBonusBlock(a, b) {
  const merged = { ...(a || {}) };
  for (const [k, v] of Object.entries(b || {})) {
    // `saves.other` is a LIST of labelled bonuses, not a keyed number
    // (BOOK-INGEST-AUDIT.md F7). Summing it the way the numeric keys are summed
    // would produce nonsense; it is concatenated by sumBonusGroups below, for
    // the same reason `at_level` is - a race granting +2 against vacuum and an
    // occupation granting +1 against radiation grant BOTH.
    if (k === 'other') continue;
    merged[k] = mergeBonusValue(merged[k], v);
  }
  delete merged.other;
  return merged;
}

export function sumBonusGroups(a, b) {
  const out = {};
  // `combat` and `saves` are validated as numbers, so the dice branch above is
  // unreachable for them; they are merged through the same helper anyway rather
  // than kept as a separate code path that could disagree with it.
  for (const group of ['attributes', 'combat', 'saves', 'pools']) {
    const merged = mergeBonusBlock(a?.[group], b?.[group]);
    if (Object.keys(merged).length) out[group] = merged;
  }
  // The labelled saves both halves state, kept side by side (F7).
  const otherSaves = [...(a?.saves?.other || []), ...(b?.saves?.other || [])];
  if (otherSaves.length) out.saves = { ...(out.saves || {}), other: otherSaves };
  // at_level entries are kept side by side rather than merged by level:
  // classBonuses() folds every entry at or below the character's level anyway,
  // so two classes each granting +1 attack at level 5 correctly gives +2.
  const at = [...(a?.at_level || []), ...(b?.at_level || [])];
  if (at.length) out.at_level = at;

  // A MINIMUM IS NOT A BONUS, and merging it as one would be wrong twice over.
  //
  // It was not merged at all until now, so an occupation's requirement vanished
  // the moment a race was composed with it: the Juicer's P.S. 22 and the Crazy's
  // P.S. 19 / P.P. 17 - the only two that state any - were both silently lost,
  // and the Attributes step stopped saying a character did not qualify.
  //
  // The stricter wins rather than the sum. Two classes wanting P.S. 22 and P.S.
  // 19 want a character with P.S. 22, not one with 41.
  const mins = {};
  for (const src of [a?.attribute_minimums, b?.attribute_minimums]) {
    for (const [k, v] of Object.entries(src || {})) {
      if (typeof v !== 'number' || !Number.isFinite(v)) continue;
      mins[k] = Math.max(mins[k] ?? -Infinity, v);
    }
  }
  if (Object.keys(mins).length) out.attribute_minimums = mins;

  return Object.keys(out).length ? out : undefined;
}


/**
 * One bonuses block from every skill a character holds.
 *
 * Physical skills are not only percentile - Boxing is "+1 attack per melee, +2
 * parry & dodge, +1 roll, +2 P.S." Summed through the SAME merge two classes
 * go through, so a skill and a class granting the same key add up rather than
 * one quietly winning.
 *
 * Takes catalog rows rather than the character's own skill entries, so a
 * correction to the catalog reaches characters who already hold the skill.
 * Rows without bonuses cost nothing, so a caller can pass everything it has.
 */
const asJsonArray = (v) => {
  if (Array.isArray(v)) return v;
  if (typeof v !== 'string') return null;
  try {
    const parsed = JSON.parse(v);
    return Array.isArray(parsed) ? parsed : null;
  } catch { return null; }
};

const asBlock = (v) => {
  let b = v;
  if (typeof b === 'string') {
    try { b = JSON.parse(b); } catch { return null; }
  }
  return b && typeof b === 'object' && !Array.isArray(b) ? b : null;
};

// The entries of a `level_bonuses` schedule that a character of this level has
// reached. Rifts Ultimate Edition p.347: "ALL bonuses are accumulative" - a 5th
// level Expert has levels 1 through 5, not level 5 alone.
//
// A level of null means "the caller does not know", and nothing is applied. That
// is deliberately different from level 1: a caller that cannot say how
// experienced the character is should not silently hand out first level bonuses.
export function levelGrants(levelBonuses, level) {
  if (!Number.isFinite(level)) return [];
  const arr = asJsonArray(levelBonuses);
  if (!arr) return [];
  return arr.filter((e) => e && typeof e === 'object'
    && Number.isFinite(e.level) && e.level <= level);
}

// The plain-text half of a level schedule: what the character gained that is
// not a number. "Karate Kick (2D6 damage)", "Death blow on a Natural 20".
//
// Kept out of the bonuses block on purpose - these are capabilities a player
// reads, not values anything adds up - and returned in level order so the sheet
// can show a fighting style as the progression the book prints.
export function skillLevelNotes(rows, level) {
  const out = [];
  for (const row of rows || []) {
    for (const e of levelGrants(row?.level_bonuses, level)) {
      if (e.note) out.push({ skill: row.name ?? null, level: e.level, note: String(e.note) });
    }
  }
  return out.sort((a, b) => a.level - b.level
    || String(a.skill).localeCompare(String(b.skill)));
}

// The conditional half of a level schedule, totalled per condition.
//
// A W.P.'s bonuses apply only while the character is holding that weapon, so
// they must never reach the combat block — but they are still real, still
// accumulate by level, and a player cannot use them if the sheet never says
// what they are. Returned as one row per (skill, condition):
//
//   { skill: 'W.P. Sword', applies_when: 'with a sword',
//     combat: { strike: 3, parry: 2 } }
//
// One skill can carry several conditions: a sword swung and a sword thrown are
// different bonuses, and the book lists them separately.
export function skillConditionalBonuses(rows, level) {
  const byKey = new Map();
  for (const row of rows || []) {
    for (const e of levelGrants(row?.level_bonuses, level)) {
      if (!e.applies_when) continue;
      const key = (row.name ?? '') + '\u0000' + e.applies_when;
      const seen = byKey.get(key)
        ?? { skill: row.name ?? null, applies_when: String(e.applies_when), combat: {} };
      for (const [k, v] of Object.entries(e.combat || {})) {
        if (typeof v === 'number') seen.combat[k] = (seen.combat[k] || 0) + v;
      }
      byKey.set(key, seen);
    }
  }
  return [...byKey.values()]
    .filter((r) => Object.keys(r.combat).length)
    .sort((a, b) => String(a.skill).localeCompare(String(b.skill))
      || a.applies_when.localeCompare(b.applies_when));
}

// `level` is optional: omit it and only the flat `bonuses` column applies,
// which is exactly what every caller did before Hand to Hand had a schedule.
export function bonusesFromSkills(rows, level = null) {
  let out;
  // `attacks_base` STATES a starting number rather than adding to one, so it
  // cannot go through the summing path - two fighting styles would give eight
  // attacks. The strongest training wins, which is also what a character with
  // two Hand to Hand skills would actually fight at.
  let attacksBase = null;
  const take = (block) => {
    if (!block) return;
    const combat = block.combat;
    if (combat && typeof combat.attacks_base === 'number') {
      attacksBase = Math.max(attacksBase ?? 0, combat.attacks_base);
      const { attacks_base: _drop, ...rest } = combat;
      block = { ...block, combat: rest };
    }
    out = sumBonusGroups(out, block);
  };

  for (const row of rows || []) {
    take(asBlock(row?.bonuses));
    for (const entry of levelGrants(row?.level_bonuses, level)) {
      // A W.P. grants its strike and parry only "whenever that particular type
      // of weapon is used" (p.326). Summed here, a character with five W.P.s
      // would swing their FISTS at +5. Conditional entries are held back for
      // skillConditionalBonuses() instead — the same reason Fencing carries
      // its bonuses as a note rather than as numbers.
      if (entry.applies_when) continue;
      // `level`, `note` and `applies_when` describe the entry; only the groups
      // are bonuses.
      const { level: _lvl, note: _note, applies_when: _when, ...groups } = entry;
      take(groups);
    }
  }

  if (attacksBase != null) {
    out = out || {};
    out = { ...out, combat: { ...(out.combat || {}), attacks_base: attacksBase } };
  }
  return out;
}

// `rcc` supplies physiology, `occ` supplies occupation. Returns `rcc` unchanged
// when there is no second class, so every caller can apply it unconditionally.
export function combineClasses(rcc, occ) {
  if (!rcc || !occ) return rcc || occ || null;

  const out = { ...rcc };
  out.name = `${rcc.name} ${occ.name}`;
  out.occ_id = occ.id;
  out.occ_name = occ.name;

  // Physiology is the race's, whatever the character studied — a dragon's dice
  // and M.D.C. are the dragon's, and the O.C.C.'s formulas are ignored rather
  // than added, or a Chiang-Ku wizard would out-live the book's dragon.
  //
  // But only where the race HAS an opinion. A racial class that states no hit
  // points because it is an M.D.C. creature is saying something; one that
  // simply omits them is not, and taking "the R.C.C. alone" literally there
  // would leave the character with no hit points at all. So a pool the race
  // does not mention falls through to the occupation.
  //
  // `xp_table` is on this list for a different reason from the pools, and a
  // stronger one. Palladium names its experience charts by O.C.C. - "Knight &
  // Noble", "Thief & Merchant" - and a RACE has none, because experience comes
  // from what you do. Left off, an occupation's table was dropped on every
  // Palladium character (race primary, occupation second since #210) and the
  // race's absent table won, silently falling back to the house-rule default.
  //
  // UNLESS THE OCCUPATION SUPERSEDES THE RACE (F11). The Cosmo-Knight is not a
  // trade the character takes up, it is a transformation: the Cosmic Forge
  // rebuilds the body, the entry prints its own dice, M.D.C. and P.P.E., and
  // its skills line says the skills of his past life are lost and the character
  // is reborn (Phase World printed 100 and 102).
  //
  // Composed race-first, that class arrived wrong in almost every pairing.
  // Measured over all 57 published races: its `attribute_dice` survived 3
  // times, its `mdc_base` was discarded 36 times, its `ppe_base` 50 times, and
  // 37 races carried named skills through the transformation. ALL FOUR were
  // right for exactly ONE race - and that race states nothing in any of them.
  // A kreeghor cosmo-knight came out with roughly half the printed strength, a
  // seventh of the M.D.C. and a fiftieth of the P.P.E., on a class whose whole
  // character is going toe to toe with a starship.
  const superseded = occ.supersedes_race === true;
  // Carried onto the composed object, because callers need to know that what
  // they are looking at is a transformation. The wizard's Attributes step reads
  // it to stop calling the merged expressions "racial dice" when half of them
  // are the occupation's.
  if (superseded) out.supersedes_race = true;
  for (const key of ['attribute_dice', 'hit_points_base', 'sdc_base', 'mdc_base', 'ppe_base',
                     'starting_money', 'xp_table']) {
    if (superseded && occ[key] != null) out[key] = occ[key];
    else if (rcc[key] == null && occ[key] != null) out[key] = occ[key];
  }
  // The attributes are the ONE field the book carves out, and it does not say
  // replace - it says "use these die rolls, or the attributes of the
  // character's original race, WHICHEVER ARE HIGHER". Per attribute, because
  // that is how the sentence reads: a race with better P.S. keeps its P.S.
  // without keeping anything else.
  //
  // Compared by ceiling rather than by rolling, because composition happens
  // before a die is thrown and the stored value is an expression, not a number.
  // A side with no readable ceiling loses to one that has it; when neither
  // does, the transformed class keeps its own, which is the direction the rest
  // of this block already runs.
  if (superseded && occ.attribute_dice && rcc.attribute_dice) {
    const merged = { ...occ.attribute_dice };
    for (const [attr, raceExpr] of Object.entries(rcc.attribute_dice)) {
      const mine = attrReach(merged[attr]);
      const theirs = attrReach(raceExpr);
      if (theirs != null && (mine == null || theirs > mine)) merged[attr] = raceExpr;
    }
    out.attribute_dice = merged;
  }
  // An M.D.C. race is the one case where silence IS the statement: it tracks
  // M.D.C. instead of hit points, so an O.C.C.'s hit points must not sneak in.
  if (rcc.mdc_base != null && rcc.hit_points_base == null) delete out.hit_points_base;

  // Both sets of minimums apply, so the stricter wins.
  const reqs = { ...(rcc.attribute_requirements || {}) };
  for (const [k, v] of Object.entries(occ.attribute_requirements || {})) {
    if (typeof v !== 'number') continue;
    reqs[k] = typeof reqs[k] === 'number' ? Math.max(reqs[k], v) : v;
  }
  if (Object.keys(reqs).length) out.attribute_requirements = reqs;

  // Fixed skills from both; the related and secondary ALLOWANCES from the
  // O.C.C. alone, which is the whole reason a racial class lists none.
  //
  // A skill both classes grant is held ONCE. Two classes commonly overlap —
  // a Chiang-Ku and a Long Bowman both know Wilderness Survival — and
  // concatenating blindly produced a character holding it twice, which the
  // validator correctly refused to save. The higher base wins: being both
  // things does not make you worse at either.
  //
  // Only NAMED entries collapse. A choice-group has no name and no identity to
  // match on, so two groups stay two groups — "pick 3 Science" from each class
  // is genuinely six picks.
  //
  // A SUPERSEDING CLASS DOES NOT UNION THEM (F11). "When the character is
  // transformed, the skills of his past life are lost and the character is
  // reborn" is a replacement, and it was the loudest half of the defect: 37 of
  // the 57 races carried between 1 and 17 named skills through a
  // transformation that is supposed to erase them.
  const bySkill = new Map();
  const groups = [];
  const pastLife = superseded ? [] : (rcc.skills?.occ_skills || []);
  for (const entry of [...pastLife, ...(occ.skills?.occ_skills || [])]) {
    if (!entry?.name) { groups.push(entry); continue; }
    const key = String(entry.name).toLowerCase();
    const seen = bySkill.get(key);
    if (!seen || (entry.base ?? 0) > (seen.base ?? 0)) bySkill.set(key, entry);
  }
  out.skills = {
    ...(superseded ? {} : (rcc.skills || {})),
    occ_skills: [...bySkill.values(), ...groups],
  };
  if (occ.skills?.occ_related_skills) out.skills.occ_related_skills = occ.skills.occ_related_skills;
  if (occ.skills?.secondary_skills) out.skills.secondary_skills = occ.skills.secondary_skills;
  // An MOS belongs to the OCCUPATION - it is a military specialty, and the
  // Coalition classes that have one are all O.C.C.s. Carried across the merge
  // because this rebuilds `skills` wholesale, and without it a Technical
  // Officer taken alongside a racial class silently lost its specialties.
  // The race's own is the fallback, for a racial class that ever gains one.
  const mos = occ.skills?.mos ?? rcc.skills?.mos;
  if (mos) out.skills.mos = mos;

  out.bonuses = sumBonusGroups(rcc.bonuses, occ.bonuses);

  // Born plus trained, not one or the other (F10). The race is what a member of
  // that race comes with; the occupation is what its page teaches.
  if (rcc.psionics || occ.psionics) out.psionics = mergePsionics(rcc.psionics, occ.psionics);
  // Magic is what you studied AND what a creature was born with, and the two add
  // up the same way psionics do (F14). A superseding class is the exception, as
  // it is everywhere else: a character the book says was remade does not keep
  // its old race's magic either.
  if (occ.magic || rcc.magic) {
    out.magic = superseded ? (occ.magic || rcc.magic) : mergeMagic(rcc.magic, occ.magic);
  }

  for (const key of ['equipment_starting', 'level_progression', 'special_abilities',
                     'natural_abilities', 'restrictions']) {
    const both = [...(rcc[key] || []), ...(occ[key] || [])];
    if (both.length) out[key] = both;
  }

  return out;
}

// ─── related-skill categories ───
//
// A category is either a plain string ("Wilderness: Any") or an object saying
// what the book allows inside it. Every entry the books print is one of three
// shapes, so those are the three supported:
//
//   { name: "Espionage", only: ["Escape Artist"] }
//   { name: "Physical", except: ["Acrobatics", "Gymnastics", "Wrestling"] }
//   { name: "Technical", bonus: 10 }
//
// Strings keep working, so nothing already authored has to change. Shared by
// the wizard's picker and the server-side validator, because two copies of
// "may this character take this skill" is exactly the pair that drifts.
//
// `bonus` is the percentage a class page prints in parentheses beside the
// category — "Technical: Any (+10%)". It exists because until it did, those
// numbers had nowhere to go: `only` and `except` were the whole vocabulary, so
// an import either dropped the bonus silently or wrote a `bonus` key that
// parsed and then did nothing, which is the worse of the two. Pantheons of the
// Megaverse prints twenty-one of them across four classes, and the Godling
// shipped missing all five of its own.
//
// It combines with `only`/`except` rather than replacing them: the Godling's
// Medical line is "Any (except cybernetics; +10%)", one category carrying both.
//
// It applies to RELATED picks only, never secondary ones. That is the book's
// own rule and not a simplification — the secondary skills paragraph on every
// class page says the bonus in parentheses "applies only to O.C.C. related
// skill selections". The I.Q. bonus is separate and still reaches both.

const normName = (s) => String(s ?? '').trim().toLowerCase();

export const categoryName = (entry) => (typeof entry === 'string' ? entry : entry?.name ?? null);

// A human label for the picker: "Espionage (Escape Artist only)".
export function categoryLabel(entry) {
  const name = categoryName(entry);
  if (typeof entry === 'string' || !entry) return name ?? '';
  // The bonus rides along with whatever restriction the category also states,
  // because the book prints them in one parenthetical and a picker that showed
  // only half of it would be quietly lying about the other half.
  const pct = Number.isFinite(entry.bonus) && entry.bonus !== 0
    ? `${entry.bonus > 0 ? '+' : ''}${entry.bonus}%` : '';
  const parts = [];
  if (Array.isArray(entry.only) && entry.only.length) parts.push(`${entry.only.join(', ')} only`);
  else if (Array.isArray(entry.except) && entry.except.length) parts.push(`except ${entry.except.join(', ')}`);
  if (pct) parts.push(pct);
  return parts.length ? `${name} (${parts.join('; ')})` : (name ?? '');
}

// The percentage this category list adds to a RELATED pick of `skill`, or 0.
//
// Keyed on the skill's REAL catalog category, with ONE exception: an entry that
// admitted this pick through a cross-category `only` AND carries a percentage
// of its own scores it (BOOK-INGEST-AUDIT.md F9).
//
// The default is deliberate and stays. A cross-category `only` entry says "you
// may spend a pick here on this skill"; it does not by itself say the skill
// joins that category for scoring, and reading it that way unconditionally
// would hand the Glitter Boy's Wilderness Survival an Espionage bonus that was
// never printed.
//
// What the default could not tell apart is a cross-category line with NO
// printed percentage, where inheriting one would invent it, from a line WITH
// one, where dropping it loses what the book printed. Two classes print
// "Rogue: Prowl only (+5%)", the catalog files Prowl under Physical, and the
// +5% landed nowhere while the picker still showed the player "Rogue (Prowl
// only; +5%)" - the wizard promising what the sheet did not give.
//
// THE `!== 0` GUARD IS LOAD-BEARING and is why this is not simply "the
// admitting entry wins". Swept across every published class, EIGHTEEN picks are
// admitted by a cross-category `only` and only THREE of them name a percentage.
// Of the other fifteen, three sit on a real category that DOES pay - the
// Glitter Boy's Wilderness at +2%, the Combat Cyborg's Military at +10%, the
// CAF Trooper's Wilderness at +5% - so an unconditional swap would have taken
// those three to zero. The specific statement wins only where the book made one.
export function categoryBonus(categories, skill) {
  if (!Array.isArray(categories) || !categories.length) return 0;
  const name = normName(skill?.name);
  const real = normName(skill?.category);
  // Bounded exactly as categoryAllows bounds the same rule: the class must also
  // list the skill's real category, or the pick was never admitted this way.
  if (name && categories.some((c) => normName(categoryName(c)) === real)) {
    const admitting = categories.find((c) => c && typeof c === 'object'
      && normName(categoryName(c)) !== real
      && Array.isArray(c.only) && c.only.some((n) => normName(n) === name));
    if (admitting && Number.isFinite(admitting.bonus) && admitting.bonus !== 0) {
      return admitting.bonus;
    }
  }
  const entry = categories.find((c) => normName(categoryName(c)) === real);
  if (!entry || typeof entry === 'string') return 0;
  return Number.isFinite(entry.bonus) ? entry.bonus : 0;
}

// Does this category list admit `skill` — an object with `name` and `category`?
// An empty or absent list restricts nothing, which is what "any" means.
export function categoryAllows(categories, skill) {
  if (!Array.isArray(categories) || !categories.length) return true;
  const name = normName(skill?.name);

  // An `only` list names the skill by name, under the category THE BOOK files
  // it in. The catalog files each skill under exactly one category, and the two
  // schemes disagree often enough to matter: the Glitter Boy's "Espionage:
  // Wilderness Survival only" is an ordinary book line, and Wilderness Survival
  // is a Wilderness skill in the catalog.
  //
  // Matching an `only` entry by name is what the book means - you may spend a
  // pick from that category on this skill. Filtering by the catalog's category
  // first made the name match nothing, which cost the two Elemental Fusionists
  // their Writing and Lore: Cattle & Animals outright.
  //
  // BOUNDED by the class also listing the skill's real category. Without that
  // bound, any `only` entry would reach a skill from a category the class never
  // granted at all, which is wider than any book says. Every real case clears
  // it: a class naming a skill under a neighbouring category grants that
  // neighbour too.
  //
  // "Lists the category" is deliberately not "that category's own restriction
  // admits the skill". The Elemental Fusionists grant Technical with an `only`
  // list that does not carry Writing, and Communications names it instead -
  // requiring both would refuse the very skill this exists to reach. The more
  // specific statement, the one naming the skill, wins.
  //
  // Deliberately only `only`. An `except` naming a skill from another category
  // still excludes nothing, because nothing was offered there to exclude.
  if (name && categories.some((c) => normName(categoryName(c)) === normName(skill?.category))
      && categories.some((c) => c && typeof c === 'object'
        && Array.isArray(c.only) && c.only.some((n) => normName(n) === name))) {
    return true;
  }

  const cat = normName(skill?.category);
  const entry = categories.find((c) => normName(categoryName(c)) === cat);
  if (entry === undefined) return false;
  if (typeof entry === 'string') return true;
  if (Array.isArray(entry.only) && entry.only.length) {
    return entry.only.some((n) => normName(n) === name);
  }
  if (Array.isArray(entry.except) && entry.except.length) {
    return !entry.except.some((n) => normName(n) === name);
  }
  return true;
}

function validateCategories(where, categories, errors) {
  if (!Array.isArray(categories)) return;
  for (const c of categories) {
    if (typeof c === 'string') continue;
    if (!c || typeof c !== 'object' || Array.isArray(c)) {
      errors.push(`${where} entries must be a category name or an object with a name`);
      continue;
    }
    if (typeof c.name !== 'string' || !c.name.trim()) {
      errors.push(`${where} object entries need a name`);
    }
    for (const key of ['only', 'except']) {
      if (c[key] === undefined) continue;
      if (!Array.isArray(c[key]) || c[key].some((s) => typeof s !== 'string' || !s.trim())) {
        errors.push(`${where}.${c.name}.${key} must be a list of skill names`);
      }
    }
    // Both at once has no single reading: "only these, except some of them" is
    // just a shorter `only` list, and guessing which the author meant is worse
    // than saying so.
    if (Array.isArray(c.only) && Array.isArray(c.except)) {
      errors.push(`${where}.${c.name} sets both only and except; use one`);
    }
    // A bonus has to be a real number. The books print these as "+10%", and a
    // string "10%" or "+10" would pass `!== undefined`, fail Number.isFinite at
    // read time and add nothing — the exact silent no-op this key was added to
    // stop, reintroduced one layer down.
    if (c.bonus !== undefined && (typeof c.bonus !== 'number' || !Number.isFinite(c.bonus))) {
      errors.push(`${where}.${c.name}.bonus must be a number of percentage points, not "${c.bonus}"`);
    }
  }
}

// A per-category FLOOR on the related-skill picks: "Select 8 other skills, but
// at least two must be selected from espionage and two from rogue skills"
// (Phase World printed 83). BOOK-INGEST-AUDIT.md F6.
//
// `occ_related_skills` already says HOW MANY picks and WHICH categories are
// legal, and narrows a category with `only` / `except`. All three are ceilings.
// A floor is the opposite shape and could not be written at all, so eight
// classes across four books carried the rule as prose in a `note` and offered
// every pick freely - including the one thing each of their books forbids.
//
// TWO SPELLINGS, and the second is not decoration. The Freedom Fighter's floor
// names one category:
//
//   minimums:
//     - { count: 2, category: "Espionage" }
//     - { count: 2, category: "Rogue" }
//
// The City Rat's names a UNION - "at least three must be selected from Physical
// or Rogue skills" (Rifts Ultimate Edition printed 88). Three Physical, three
// Rogue, or any mix of three across the two; written as two separate floors it
// would demand six picks the book never asks for:
//
//   minimums:
//     - { count: 3, categories: ["Physical", "Rogue"] }
//
// So an entry carries a LIST of categories and is satisfied by picks from any
// of them. `category:` is the one-element sugar, because most floors are one
// category and a list of one reads badly beside a book that says "Technical".
const minimumCategories = (m) => (Array.isArray(m?.categories)
  ? m.categories
  : (m?.category === undefined ? [] : [m.category]));

/**
 * The related-skill floors of a class, normalised to `{ count, categories }`
 * with the sugar expanded. Empty when the class has none, which is all but
 * eight of them.
 *
 * The wizard, the server validator and this file's own checks all read the
 * floors through here, so the two spellings are resolved in exactly one place.
 */
export function relatedMinimums(cls) {
  const mins = cls?.skills?.occ_related_skills?.minimums;
  if (!Array.isArray(mins)) return [];
  return mins
    .filter((m) => m && typeof m === 'object' && Number.isFinite(m.count))
    .map((m) => ({ count: m.count, categories: minimumCategories(m).map(String) }));
}

/**
 * How the floors stand against the picks made, and whether they can still be
 * met. `categories` is the catalog category of each related pick the character
 * holds; `allowance` is how many related picks it may hold in total.
 *
 * A FLOOR IS NOT A CEILING, AND THE DIFFERENCE DECIDES WHEN IT CAN FIRE. The
 * count and category rules are broken the instant they are broken; a floor that
 * is merely unmet may still be met by the picks not yet spent. `unreachable` is
 * therefore the only honest trigger for refusing a save, and for telling a
 * player their build is illegal - "0/2 Espionage" on a half-built character is
 * a running total, not a fault.
 *
 * The shortfalls are summed against what remains rather than tested one at a
 * time. Six of eight spent on an Imperial Security Agent holding one espionage
 * and no rogue leaves each floor individually reachable - one more espionage,
 * or two more rogue - and the two together needing three picks where two
 * remain.
 *
 * THE SERVER VALIDATOR AND THE WIZARD BOTH COME THROUGH HERE. They arrive with
 * different things in hand - stored skill rows on one side, picked names and a
 * catalog index on the other - and they must not disagree about whether a
 * character is legal. Only the mapping to categories is theirs; the arithmetic
 * is this function's.
 */
export function relatedFloorStatus(cls, categories, allowance) {
  const floors = relatedMinimums(cls);
  const held = (Array.isArray(categories) ? categories : []).map(normName);
  const remaining = Math.max(0, (Number.isFinite(allowance) ? allowance : held.length) - held.length);
  const status = floors.map((f) => {
    const wanted = new Set(f.categories.map(normName));
    const have = held.filter((c) => wanted.has(c)).length;
    return { ...f, have, met: have >= f.count, missing: Math.max(0, f.count - have) };
  });
  const short = status.filter((f) => !f.met);
  const owed = short.reduce((n, f) => n + f.missing, 0);
  return { floors: status, short, remaining, owed, unreachable: owed > remaining };
}

/**
 * Shape checks on `occ_related_skills.minimums`.
 *
 * Every one of these is an ERROR rather than a warning, because a floor is
 * enforced server-side the moment it parses: a floor naming a category the
 * class does not grant would refuse every character of that class, and a floor
 * that is silently dropped puts the class back where F6 found it. Both failure
 * modes are worse than refusing to load the file.
 */
function validateRelatedMinimums(related, errors) {
  const mins = related?.minimums;
  if (mins === undefined) return;
  if (!Array.isArray(mins)) {
    errors.push('skills.occ_related_skills.minimums must be a list of { count, category } entries');
    return;
  }
  // The categories the class actually offers, by their normalised names. A
  // floor outside this set is unsatisfiable by construction.
  const granted = new Set((related.categories || [])
    .map((c) => normName(categoryName(c))).filter(Boolean));
  let floorTotal = 0;
  for (const m of mins) {
    if (!m || typeof m !== 'object' || Array.isArray(m)) {
      errors.push('skills.occ_related_skills.minimums entries must be objects');
      continue;
    }
    if (m.category !== undefined && m.categories !== undefined) {
      errors.push('skills.occ_related_skills.minimums entries set category or categories, not both');
    }
    if (!Number.isFinite(m.count) || m.count <= 0 || !Number.isInteger(m.count)) {
      errors.push(`skills.occ_related_skills.minimums.count must be a whole number above zero, not "${m.count}"`);
    } else {
      floorTotal += m.count;
    }
    const cats = minimumCategories(m);
    if (!cats.length) {
      errors.push('skills.occ_related_skills.minimums entries need a category or a categories list');
      continue;
    }
    for (const c of cats) {
      if (typeof c !== 'string' || !c.trim()) {
        errors.push('skills.occ_related_skills.minimums categories must be category names');
        continue;
      }
      if (granted.size && !granted.has(normName(c))) {
        errors.push(`skills.occ_related_skills.minimums names ${c}, `
          + 'which is not one of the categories this class allows as a related skill');
      }
    }
  }
  // The floors are spent OUT OF the same count, not on top of it. Two floors of
  // two over eight picks leave four free; two floors of five would leave less
  // than nothing, and the class could not be built at all.
  if (Number.isFinite(related.count) && floorTotal > related.count) {
    errors.push(`skills.occ_related_skills.minimums require ${floorTotal} picks `
      + `but the class grants only ${related.count}`);
  }
}

// The attributes a class bonus may name. Anything else is a typo — a bonus
// filed under a key nothing reads would silently do nothing, which is the
// failure this whole block exists to prevent.
// Not exported: js/class-blocks.js was the only thing outside this file that
// read it, and that went with the in-app importer. Still used three times
// below, so it stays a const rather than being inlined.
const BONUS_ATTRS = ['IQ', 'ME', 'MA', 'PS', 'PP', 'PE', 'PB', 'Spd'];

// The pools a class bonus may add to. Books state these as "plus 4D6" on top of
// whatever the occupation gives — the Demigod's P.P.E. and I.S.P. are both
// written that way (Rifts, Pantheons of the Megaverse p.17).
//
// Unlike combat and saves, a pool bonus is NOT re-read at render time. Pools are
// rolled once and stored as `*_max`, so the bonus is rolled with the base and
// folded into that number. A dice bonus re-evaluated every render would change
// the character's maximum under them.
export const POOL_BONUS_KEYS = ['hp', 'sdc', 'mdc', 'ppe', 'isp'];

// The three groups a bonus can land in. `combat` and `saves` deliberately do
// not enumerate their keys: both are open sets that derive.js grows, and a
// bonus to a key it has not heard of is better surfaced as a warning than
// rejected outright.
const BONUS_GROUPS = ['attributes', 'combat', 'saves'];

// A dice expression, for a bonus a book states as a roll rather than a fixed
// number — "add 2D6 to P.S.", "add 2D4x10 to Spd", "+1D4 on initiative".
//
// Every group accepts one. Combat and save bonuses were flat-only on the
// assumption that books always print them that way; the Godling's "+1D4 on
// initiative" is the counter-example, and it was a hard parse error.
const DICE_BONUS = /^\d+\s*d\s*\d+(?:\s*x\s*\d+)?(?:\s*[+-]\s*\d+)?$/i;
const isDiceBonus = (v) => typeof v === 'string' && DICE_BONUS.test(v.trim());

// An equipment quantity: a plain count, or a roll the book prints — the Priest
// of Light's 1D6 vials of holy water. The wizard rolls the dice form once at
// creation and stores the number.
const isValidQuantity = (v) =>
  (typeof v === 'number' && Number.isFinite(v) && v >= 1) || isDiceBonus(v);

function validateBonusGroup(where, group, block, errors, warnings) {
  if (block === undefined || block === null) return;
  if (typeof block !== 'object' || Array.isArray(block)) {
    errors.push(`${where}.${group} must be a map of name to number`);
    return;
  }
  for (const [k, v] of Object.entries(block)) {
    // `saves.other` is a labelled list rather than a keyed number, and has its
    // own validator (BOOK-INGEST-AUDIT.md F7).
    if (group === 'saves' && k === 'other') continue;
    const dice = isDiceBonus(v);
    if (!dice && (typeof v !== 'number' || !Number.isFinite(v))) {
      errors.push(`${where}.${group}.${k} must be a number or a dice expression like "2d6"`);
    } else if (group === 'attributes' && !BONUS_ATTRS.includes(k)) {
      errors.push(`${where}.attributes.${k} is not an attribute (${BONUS_ATTRS.join(', ')})`);
    } else if (v === 0) {
      warnings.push(`${where}.${group}.${k} is 0 and will do nothing`);
    }
  }
}

// A save the sixteen fixed fields do not name (BOOK-INGEST-AUDIT.md F7).
//
// `SAVE_FIELDS` in sheet.js is a literal list, and a book bonus outside it -
// the Spacer's "+2 to any saves against explosive decompression or other space
// dangers" - had nowhere to go. The parser accepted any key inside `saves` and
// still does, which is what lets `mind_control` work without a schema change;
// the cost was that `space_hazards: 2` parsed, validated and rendered NOWHERE.
//
// So the escape hatch is explicit and labelled in the book's own words rather
// than mapped onto the nearest existing field. That mapping is the trap this
// avoids: the Spacer's first draft wrote `toxins_poisons: 2`, which is a real,
// rendered +2 against venom the book never granted.
//
// A LABEL IS REQUIRED, and that is the whole design. An unlabelled entry is
// indistinguishable from the unrendered key this replaces.
function validateSaveOther(where, list, errors, warnings) {
  if (list === undefined || list === null) return;
  if (!Array.isArray(list)) {
    errors.push(`${where}.saves.other must be a list of { label, bonus }`);
    return;
  }
  list.forEach((e, i) => {
    const at = `${where}.saves.other[${i}]`;
    if (!e || typeof e !== 'object' || Array.isArray(e)) {
      errors.push(`${at} must be a map with a label and a bonus`);
      return;
    }
    if (typeof e.label !== 'string' || !e.label.trim()) {
      errors.push(`${at}.label is required - it is what the sheet shows in place of `
        + 'a field name, so an entry without one renders as an unnamed number');
    }
    const dice = isDiceBonus(e.bonus);
    if (!dice && (typeof e.bonus !== 'number' || !Number.isFinite(e.bonus))) {
      errors.push(`${at}.bonus must be a number or a dice expression like "2d6"`);
    } else if (e.bonus === 0) {
      warnings.push(`${at}.bonus is 0 and will do nothing`);
    }
    for (const k of Object.keys(e)) {
      if (k !== 'label' && k !== 'bonus' && k !== 'note') {
        warnings.push(`${at}.${k} is not read (label, bonus, note)`);
      }
    }
  });
}

// A flat number or a dice expression, keyed by pool. Dice are the common case —
// books write "plus 4D6" far more often than a fixed figure.
function validatePoolBonuses(where, block, errors, warnings) {
  if (block === undefined || block === null) return;
  if (typeof block !== 'object' || Array.isArray(block)) {
    errors.push(`${where}.pools must be a map of pool to number or dice`);
    return;
  }
  for (const [k, v] of Object.entries(block)) {
    if (!POOL_BONUS_KEYS.includes(k)) {
      errors.push(`${where}.pools.${k} is not a pool (${POOL_BONUS_KEYS.join(', ')})`);
    } else if (!isDiceBonus(v) && (typeof v !== 'number' || !Number.isFinite(v))) {
      errors.push(`${where}.pools.${k} must be a number or a dice expression like "4d6"`);
    } else if (v === 0) {
      warnings.push(`${where}.pools.${k} is 0 and will do nothing`);
    }
  }
}

// "Minimum P.S. is 22; if lower, adjust up to P.S. 22" (Juicer, Rifts p.69).
// A floor applied AFTER the dice bonus lands — deliberately not
// attribute_requirements, which gates whether the class may be taken at all.
function validateAttributeMinimums(block, errors) {
  if (block === undefined || block === null) return;
  if (typeof block !== 'object' || Array.isArray(block)) {
    errors.push('bonuses.attribute_minimums must be a map of attribute to number');
    return;
  }
  for (const [k, v] of Object.entries(block)) {
    if (!BONUS_ATTRS.includes(k)) {
      errors.push(`bonuses.attribute_minimums.${k} is not an attribute`);
    } else if (typeof v !== 'number' || !Number.isFinite(v)) {
      errors.push(`bonuses.attribute_minimums.${k} must be a number`);
    }
  }
}

// `opts.flatOnly` is what a SKILL's bonuses are validated with. A class rolls
// its dice bonuses once at creation and stores the result on the character; a
// skill can be taken at any level, so there is no equivalent moment and a dice
// bonus would either re-roll on every render or contribute nothing. Pools are
// refused for the same reason - S.D.C. is rolled into `sdc_max` once. Refusing
// beats storing Boxing's "+3D6 S.D.C." and then silently never applying it.
export function validateBonuses(bonuses, errors, warnings, opts = {}) {
  if (typeof bonuses !== 'object' || Array.isArray(bonuses) || bonuses === null) {
    errors.push('bonuses must be a map');
    return;
  }
  if (opts.flatOnly) {
    for (const g of BONUS_GROUPS) {
      for (const [k, v] of Object.entries(bonuses[g] || {})) {
        if (typeof v === 'string') {
          errors.push(`bonuses.${g}.${k} is a dice expression; a skill's bonuses must be `
            + 'flat numbers. Keep the roll in `note` until skill dice are rolled at acquisition');
        }
      }
    }
    if (bonuses.pools !== undefined) {
      errors.push('bonuses.pools is not applied for a skill - pools are rolled once into the '
        + "character's maximum. Keep it in `note`");
    }
    if (bonuses.at_level !== undefined) {
      errors.push('bonuses.at_level is not applied for a skill - a skill is not levelled');
    }
  }
  for (const g of BONUS_GROUPS) validateBonusGroup('bonuses', g, bonuses[g], errors, warnings);

  validateSaveOther('bonuses', bonuses.saves?.other, errors, warnings);

  validateAttributeMinimums(bonuses.attribute_minimums, errors);

  validatePoolBonuses('bonuses', bonuses.pools, errors, warnings);

  const known = new Set([...BONUS_GROUPS, 'at_level', 'attribute_minimums', 'pools']);
  for (const k of Object.keys(bonuses)) {
    if (!known.has(k)) warnings.push(`bonuses.${k} is not a recognised group and will be ignored`);
  }

  // Bonuses earned later. Proposed in the level-up diff and applied on
  // confirmation, like every other level-up change.
  if (bonuses.at_level !== undefined) {
    if (!Array.isArray(bonuses.at_level)) {
      errors.push('bonuses.at_level must be a list');
      return;
    }
    for (const step of bonuses.at_level) {
      if (!step || typeof step !== 'object' || typeof step.level !== 'number') {
        errors.push('bonuses.at_level entries need a numeric level');
        continue;
      }
      if (step.level < 2) warnings.push(`bonuses.at_level level ${step.level} — level 1 belongs in bonuses itself`);
      for (const g of BONUS_GROUPS) {
        validateBonusGroup(`bonuses.at_level[${step.level}]`, g, step[g], errors, warnings);
      }
      // Pools are rolled once at creation and stored, so there is nowhere for a
      // level-gated pool bonus to land. Said out loud rather than ignored: a
      // bonus filed under a key nothing reads is exactly the silent failure the
      // rest of this block exists to prevent.
      if (step.pools !== undefined) {
        warnings.push(`bonuses.at_level[${step.level}].pools is not applied — `
          + 'pools are rolled once at creation; state per-level growth in the pool formula '
          + 'itself ("P.E. x 5 plus 2D6 per level")');
      }
    }
  }
}

// Does this racial class need an occupation to be a playable character?
//
// The usual structure is a race and then an occupation: the R.C.C. sets the
// body, the O.C.C. sets what was learned. Both halves are optional in the data
// because the exceptions are real - a human takes an O.C.C. and has no race at
// all, and a Godling grants its own skills and stands alone - but the pairing is
// the normal case rather than a curiosity.
//
// Inferred from what the class grants rather than declared, because the skill
// counts already say it and no stored class would have to be edited: an R.C.C.
// offering no related and no secondary skills gives the player nothing to
// CHOOSE. Fixed skills do not count - a Chiang-Ku has twenty-four of them and
// still nothing chosen, which is exactly the case the O.C.C. is meant to fill.
//
// Inference is safe here only because the answer is a warning and never a
// refusal. A wrong guess costs a dismissible note, not a blocked save.
export function needsOccupation(cls) {
  if (!cls || cls.category !== 'rcc') return false;
  const s = cls.skills || {};
  return !(s.occ_related_skills?.count) && !(s.secondary_skills?.count);
}

// ---------- shared ability lists ----------
//
// A class states its own power list, even when the book prints one list and
// points several classes at it ("select any ONE power from those listed under
// godling"). That is a printing convenience, not a relationship between the
// classes: a mechanism that resolved one class's list out of another existed
// briefly (`from_class`, PR #80) and was removed when its only intended user —
// the Demigod — turned out to want independence. Recoverable from git if a
// genuinely shared list ever appears.
export function isAbilityChoice(entry) {
  return !!entry && typeof entry === 'object'
    && (entry.choose !== undefined || entry.from !== undefined);
}

// What a chosen ability may grant. Deliberately three keys, not the variant
// override set: these are what the Godling's eleven powers actually need, and a
// chosen ability that could restate attribute_dice or starting_money is not an
// ability, it is a second class wearing one's name.
//
//   - name: "Super-Tough"
//     description: "Add 1D6 to P.E. and 3D4x10 to M.D.C."
//     bonuses: { attributes: { PE: "1d6" }, pools: { mdc: "3d4x10" } }
//
// M.D.C. arrives as a pool BONUS rather than an override, which is why pool
// bonuses had to exist first — the ability adds to whatever the class already
// rolls, it does not replace the formula.
export const ABILITY_GRANTS = ['bonuses', 'psionics', 'magic'];

// A named ability definition, as opposed to a choice group.
export function isAbilityDefinition(entry) {
  return !!entry && typeof entry === 'object' && typeof entry.name === 'string' && !isAbilityChoice(entry);
}

// An ability may name the occupations whose powers it grants - the Godling's
// Magic Powers says "pick one: Ley Line Walker, Shifter, Mystic or Warlock
// (or Necromancer if evil)" - as `occ_options`, a list of class ids. Choosing
// such an ability IS choosing to have one of those occupations composed in,
// so the wizard turns the pick into a required occupation choice and the
// validator warns when a character holds the ability with no matching
// occupation. Returns { name, options } for the first chosen ability that
// carries options, or null. One helper, shared by both, so they cannot
// disagree about which pick demands what.
export function abilityOccOptions(cls, chosenNames) {
  const names = new Set((chosenNames || [])
    .map((n) => (typeof n === 'string' ? n : n?.name))
    .filter(Boolean).map((n) => n.trim().toLowerCase()));
  for (const d of cls?.special_abilities || []) {
    if (!isAbilityDefinition(d) || !Array.isArray(d.occ_options) || !d.occ_options.length) continue;
    if (names.has(d.name.trim().toLowerCase())) {
      return { name: d.name, options: d.occ_options.map(String) };
    }
  }
  return null;
}

// Every option a class offers from its own ability choice groups, by name.
export function abilityOptions(cls) {
  const out = [];
  for (const e of cls?.special_abilities || []) {
    if (!isAbilityChoice(e)) continue;
    for (const opt of e.from || []) {
      const name = typeof opt === 'string' ? opt : opt?.name;
      if (name) out.push(name);
    }
  }
  return out;
}

// A stored ability entry is a string (a player pick) or an object marked
// `{ name, gm: true }` (a power the G.M. assigned by hand - the Demigod's
// entry says most have ONE extra, "similar to that of the godly father or
// mother", and that grant is a ruling rather than a pick). One normalizer,
// shared by the composer and the validator, so the two cannot disagree about
// what counts as whose.
export function normalizeAbilities(list) {
  const out = [];
  for (const e of list || []) {
    if (typeof e === 'string' && e.trim()) out.push({ name: e.trim(), gm: false });
    else if (e && typeof e === 'object' && typeof e.name === 'string' && e.name.trim()) {
      out.push({ name: e.name.trim(), gm: e.gm === true });
    }
  }
  return out;
}

// Folds the abilities a character actually chose into its class.
//
// `chosen` is a list of names and DUPLICATES ARE MEANINGFUL: the Godling's Shape
// Shifter and Magic Powers can each be taken twice, and the book gives the
// second take a different meaning rather than a doubled one. A repeated pick
// applies its bonuses again — which is arithmetically the only honest reading —
// and surfaces `on_repeat` as the prose that says what the second one bought.
//
// Runs after race and occupation are composed, because an ability is chosen for
// the character rather than contributed by either half, and BEFORE any rolled
// psionic tier, so an ability that makes you a master psychic is what a rolled
// tier would have to beat.
export function applyAbilities(cls, chosen) {
  const picks = normalizeAbilities(chosen);
  if (!cls || !picks.length) return cls;

  const byName = new Map((cls.special_abilities || [])
    .filter(isAbilityDefinition)
    .map((d) => [d.name.trim().toLowerCase(), d]));

  const out = { ...cls };
  const taken = [];
  const counts = new Map();
  for (const { name, gm } of picks) {
    const key = name.toLowerCase();
    const def = byName.get(key);
    const n = (counts.get(key) || 0) + 1;
    counts.set(key, n);
    // A pick nothing defines is still recorded — it is a real choice the player
    // made, and dropping it would make the sheet disagree with what they picked.
    // A G.M.-assigned power is likelier still to be off-list, and grants all the
    // same when a definition exists.
    if (!def) { taken.push({ name, times: n, granted: false, ...(gm ? { gm: true } : {}) }); continue; }

    if (def.bonuses) out.bonuses = sumBonusGroups(out.bonuses, def.bonuses);
    // The stronger tier wins and the rest of the block is merged, the same rule
    // composing a race with an occupation uses, so an ability can only add.
    // The same fold, because the comment above claims it is the same rule and
    // F10 would otherwise have made that false. It is not hypothetical: the
    // Godling is a minor psychic whose "Super-Psionic Powers" ability grants
    // `{ type: master }` and nothing else, so choosing the ability's block
    // outright replaced the class's I.S.P. formula with none at all.
    if (def.psionics) out.psionics = mergePsionics(out.psionics, def.psionics);
    if (def.magic) out.magic = out.magic || def.magic;
    taken.push({ name: def.name, times: n, granted: true, ...(gm ? { gm: true } : {}),
      description: def.description, on_repeat: n > 1 ? def.on_repeat : undefined });
  }
  // What the character actually holds, for the sheet — as opposed to
  // special_abilities, which is what the class OFFERS.
  out.abilities_taken = taken;
  return out;
}

// The same idea for starting equipment, keyed on `item_id` rather than `name`.
//
// Books routinely say "one energy pistol of choice" where the format only had
// fixed item ids, and the workaround was a placeholder catalog row named after
// the category — `energy-pistol`, `vibro-blade`. Those are not items: no book
// entry will ever match them, so they sit in the catalog forever with no stats,
// and a character ends up holding a weapon that does not exist.
//
// There is no `categories` flavour here, unlike skills. Gear's `category` is
// weapon/armor/vehicle/gear — far too coarse to mean "any energy pistol" — so a
// gear choice enumerates its options explicitly.
export function isGearChoice(entry) {
  return !!entry && typeof entry === 'object' && !entry.item_id &&
    (entry.choose !== undefined || entry.from !== undefined);
}

// ---------- scalar helpers ----------

// Strips a trailing YAML comment. Per the YAML rule, `#` only starts a comment
// at the start of a line or after whitespace — so prose like "Note #7" and
// "don't" survive intact. Sourcebook text is full of both.
function stripComment(line) {
  let inQuote = null;
  for (let i = 0; i < line.length; i++) {
    const ch = line[i];
    if (inQuote) {
      if (ch === inQuote) inQuote = null;
    } else if (ch === '"' || ch === "'") {
      inQuote = ch;
    } else if (ch === '#' && (i === 0 || line[i - 1] === ' ' || line[i - 1] === '\t')) {
      return line.slice(0, i);
    }
  }
  return line;
}

function parseScalar(raw) {
  const s = raw.trim();
  if (s === '' || s === 'null' || s === '~') return null;
  if (s === 'true') return true;
  if (s === 'false') return false;
  // Quoted strings. The two YAML styles escape differently and the difference
  // matters: a double-quoted string uses backslashes, a single-quoted one
  // doubles the quote. Stripping the outer pair without unescaping left
  // `"Adult: the \"big\" one"` reading back with its backslashes still in, and
  // book text quotes things often enough for that to reach the catalog.
  if (s.length >= 2 && s[0] === '"' && s.endsWith('"')) {
    return s.slice(1, -1).replace(/\\(["\\/bfnrt])/g, (_, c) => (
      { b: '\b', f: '\f', n: '\n', r: '\r', t: '\t' }[c] ?? c
    ));
  }
  if (s.length >= 2 && s[0] === "'" && s.endsWith("'")) {
    return s.slice(1, -1).replace(/''/g, "'");
  }
  if (/^-?\d+$/.test(s)) return parseInt(s, 10);
  if (/^-?\d*\.\d+$/.test(s)) return parseFloat(s);
  return s;
}

// Split "a, b, {c: d}" on top-level commas (ignoring commas inside quotes/braces/brackets).
function splitTopLevel(s) {
  const parts = [];
  let depth = 0, inQuote = null, cur = '';
  for (const ch of s) {
    if (inQuote) {
      cur += ch;
      if (ch === inQuote) inQuote = null;
    } else if (ch === '"' || ch === "'") {
      cur += ch; inQuote = ch;
    } else if (ch === '{' || ch === '[') {
      cur += ch; depth++;
    } else if (ch === '}' || ch === ']') {
      cur += ch; depth--;
    } else if (ch === ',' && depth === 0) {
      parts.push(cur); cur = '';
    } else {
      cur += ch;
    }
  }
  if (cur.trim() !== '') parts.push(cur);
  return parts;
}

function splitKeyValue(s) {
  // First ':' not inside quotes/braces marks the key boundary.
  let depth = 0, inQuote = null;
  for (let i = 0; i < s.length; i++) {
    const ch = s[i];
    if (inQuote) {
      if (ch === inQuote) inQuote = null;
    } else if (ch === '"' || ch === "'") {
      inQuote = ch;
    } else if (ch === '{' || ch === '[') {
      depth++;
    } else if (ch === '}' || ch === ']') {
      depth--;
    } else if (ch === ':' && depth === 0) {
      return [s.slice(0, i).trim(), s.slice(i + 1).trim()];
    }
  }
  return null;
}

function parseInlineValue(s) {
  if (s[0] === '{' && s.endsWith('}')) {
    const obj = {};
    for (const part of splitTopLevel(s.slice(1, -1))) {
      const kv = splitKeyValue(part);
      if (kv) obj[kv[0]] = parseInlineValue(kv[1]);
    }
    return obj;
  }
  if (s[0] === '[' && s.endsWith(']')) {
    return splitTopLevel(s.slice(1, -1)).map((p) => parseInlineValue(p.trim()));
  }
  return parseScalar(s);
}

// ---------- block (indentation) parser ----------

// Each line keeps both its comment-stripped form (used for structure) and its
// raw form (used verbatim for block-scalar bodies, where a `#` is content, not
// a comment). `gap` records that a blank line preceded it, so paragraph breaks
// inside a block scalar survive.
//
// Known limitation: a block-scalar body line whose first non-space character is
// `#` is still treated as a comment and dropped.
function toLines(text) {
  const lines = [];
  let gap = false;
  for (const raw of text.split(/\r?\n/)) {
    if (raw.trim() === '') { gap = true; continue; }
    const stripped = stripComment(raw);
    if (stripped.trim() === '') continue; // comment-only line
    lines.push({
      indent: stripped.length - stripped.trimStart().length,
      text: stripped.trim(),
      rawText: raw.trimEnd(),
      rawIndent: raw.length - raw.trimStart().length,
      gap,
    });
    gap = false;
  }
  return lines;
}

// Joins a block-scalar body: `|` keeps line breaks, `>` folds to spaces, and a
// blank line in the source becomes a paragraph break in either style.
function joinBlock(body, style) {
  let out = '';
  body.forEach((line, idx) => {
    if (idx === 0) { out = line.text; return; }
    out += line.gap ? '\n\n' : (style === '|' ? '\n' : ' ');
    out += line.text;
  });
  return out.trim();
}

// Parses lines[start...] at exactly `indent`; returns [value, nextIndex].
function parseBlock(lines, start, indent) {
  if (lines[start].text.startsWith('- ') || lines[start].text === '-') {
    return parseList(lines, start, indent);
  }
  return parseMap(lines, start, indent);
}

function parseMap(lines, start, indent) {
  const map = {};
  let i = start;
  while (i < lines.length && lines[i].indent === indent && !lines[i].text.startsWith('- ')) {
    const kv = splitKeyValue(lines[i].text);
    if (!kv) throw new Error(`Expected "key: value" at: "${lines[i].text}"`);
    const [key, val] = kv;
    i++;
    if (BLOCK_SCALAR.test(val)) {
      // `key: |` / `key: >` — long free text on indented lines. The body is
      // taken raw: sourcebook prose is full of `#` and apostrophes, and none of
      // it is YAML syntax.
      const body = [];
      let baseIndent = null;
      while (i < lines.length && lines[i].indent > indent) {
        const line = lines[i];
        if (baseIndent === null) baseIndent = line.rawIndent;
        body.push({ text: line.rawText.slice(Math.min(baseIndent, line.rawIndent)), gap: line.gap });
        i++;
      }
      map[key] = joinBlock(body, val[0]);
    } else if (val !== '') {
      map[key] = parseInlineValue(val);
    } else if (i < lines.length && lines[i].indent > indent) {
      const [child, next] = parseBlock(lines, i, lines[i].indent);
      map[key] = child;
      i = next;
    } else {
      map[key] = null;
    }
  }
  return [map, i];
}

function parseList(lines, start, indent) {
  const list = [];
  let i = start;
  while (i < lines.length && lines[i].indent === indent && (lines[i].text.startsWith('- ') || lines[i].text === '-')) {
    const rest = lines[i].text === '-' ? '' : lines[i].text.slice(2).trim();
    const kv = rest === '' || rest[0] === '{' || rest[0] === '[' ? null : splitKeyValue(rest);
    if (kv) {
      // Block-form map item: "- key: v" plus continuation lines indented past the dash.
      // The first pair is re-injected at the continuation indent (dash + 2 spaces).
      const item = [{ indent: indent + 2, text: rest }];
      i++;
      while (i < lines.length && lines[i].indent > indent) {
        item.push(lines[i]);
        i++;
      }
      const [child] = parseMap(item, 0, indent + 2);
      list.push(child);
    } else {
      list.push(rest === '' ? null : parseInlineValue(rest));
      i++;
    }
  }
  return [list, i];
}

export function parseYaml(text) {
  const lines = toLines(text);
  if (lines.length === 0) return {};
  const [value] = parseBlock(lines, 0, lines[0].indent);
  return value;
}

// ---------- class file parser ----------

// Splits the markdown body into { "lore": "...", "gm notes": "..." } keyed by lowercased ## heading.
function parseBodySections(body) {
  const sections = {};
  const matches = [...body.matchAll(/^##\s+(.+)$/gm)];
  for (let i = 0; i < matches.length; i++) {
    const startIdx = matches[i].index + matches[i][0].length;
    const endIdx = i + 1 < matches.length ? matches[i + 1].index : body.length;
    sections[matches[i][1].trim().toLowerCase()] = body.slice(startIdx, endIdx).trim();
  }
  return sections;
}

/**
 * Parse one RCC/OCC markdown file.
 * Returns { ok, data, errors, warnings }. `data` is null only if the file has no
 * valid frontmatter block at all; otherwise it holds whatever parsed, plus:
 *   data.lore, data.gm_notes  — from ## Lore / ## GM Notes body sections
 *   data.sections             — all body sections keyed by lowercased heading
 */
// The book's own five groupings of Palladium O.C.C.s, taken from the contents
// page and the section each class is printed in: Clergy, Men of Arms, Optional
// O.C.C.s (96), the Ways of Magic (100) and Psychic Character Classes (156).
//
// They exist because the RACES reference them. "A dwarf may take any O.C.C.
// except magic" is a rule about a GROUP, and writing it as a list of the four
// magic classes we happen to hold today would silently stop covering the fifth.
export const OCC_GROUPS = ['clergy', 'men-of-arms', 'optional', 'magic', 'psychic'];

const GROUP_TOKEN = /^group:(.+)$/;

// "No R.C.C. at all", which in Rifts is what being human looks like.
export const RACE_NONE = 'none';

/**
 * Which occupations a race may take.
 *
 * `only` is a closed list and `except` an open one; a race states one or the
 * other, never both. Entries are class ids, or `group:<name>` for one of the
 * five above.
 *
 *   occ_restrictions:
 *     except: ["group:magic"]                 # the dwarf
 *     only: ["group:magic", "thief", ...]     # the gnome
 *
 * Returns { allowed, reason }. `reason` is filled only when it is false, and is
 * written for a player rather than a log.
 */
export function occAllowedForRace(race, occ) {
  const r = race?.occ_restrictions;
  if (!r || !occ?.id) return { allowed: true };
  const names = Array.isArray(r.only) ? r.only : Array.isArray(r.except) ? r.except : null;
  if (!names || !names.length) return { allowed: true };

  const matches = names.some((n) => {
    const g = GROUP_TOKEN.exec(String(n));
    return g ? occ.occ_group === g[1] : String(n) === occ.id;
  });

  const allowed = Array.isArray(r.only) ? matches : !matches;
  if (allowed) return { allowed: true };
  const what = race.name || race.id;
  return {
    allowed: false,
    reason: Array.isArray(r.only)
      ? `${what} is limited to certain occupations, and ${occ.name || occ.id} is not one of them.`
      : `${what} may not take ${occ.name || occ.id}.`,
  };
}

/**
 * Which races may take an occupation - the mirror of occAllowedForRace.
 *
 *   race_restrictions:
 *     only: ["none"]        # the Juicer: 95% human
 *
 * `none` is a RESERVED entry meaning "no R.C.C. at all", and it is the human
 * case. Rifts prints no Human R.C.C. because human is the default and unstated:
 * Rifts Ultimate Edition's contents list exactly one Racial Character Class,
 * the Dragon Hatchling. So "human only" is not a race to name, it is the
 * ABSENCE of one, and `only: ["none"]` says exactly that.
 *
 * Returns { allowed, reason }, filled only when false.
 */
export function raceAllowedForOcc(occ, race) {
  const r = occ?.race_restrictions;
  if (!r) return { allowed: true };
  const names = Array.isArray(r.only) ? r.only : Array.isArray(r.except) ? r.except : null;
  if (!names || !names.length) return { allowed: true };

  const matches = names.some((n) => (String(n) === RACE_NONE ? !race?.id : String(n) === race?.id));
  const allowed = Array.isArray(r.only) ? matches : !matches;
  if (allowed) return { allowed: true };

  const what = occ.name || occ.id;
  // The common case by far is an O.C.C. that may not be paired at all, and
  // "X is not open to a Dragon Hatchling" reads better there than a list.
  return {
    allowed: false,
    reason: race?.id
      ? `${what} is not open to a ${race.name || race.id}.`
      : `${what} requires a race this character does not have.`,
  };
}

// Every entry a restriction names must resolve to something. A class id with no
// class - or a group outside the five - silently allows whatever it meant to
// forbid, which is the same failure an `only` naming a skill with no catalog row
// causes and is why that one is a hard error too.
function validateOccRestrictions(block, errors, warnings) {
  if (block === undefined || block === null) return;
  if (typeof block !== 'object' || Array.isArray(block)) {
    errors.push('occ_restrictions must be a map with `only` or `except`');
    return;
  }
  const hasOnly = Array.isArray(block.only);
  const hasExcept = Array.isArray(block.except);
  if (hasOnly && hasExcept) {
    errors.push('occ_restrictions sets both only and except; a race states one or the other');
  }
  if (!hasOnly && !hasExcept) {
    errors.push('occ_restrictions needs an `only` or an `except` list');
    return;
  }
  const list = hasOnly ? block.only : block.except;
  if (!list.length) {
    errors.push(`occ_restrictions.${hasOnly ? 'only' : 'except'} is empty and would ` +
      `${hasOnly ? 'forbid everything' : 'forbid nothing'}`);
  }
  for (const n of list) {
    if (typeof n !== 'string' || !n.trim()) {
      errors.push('occ_restrictions entries must be class ids or group:<name>');
      continue;
    }
    const g = GROUP_TOKEN.exec(n);
    if (g && !OCC_GROUPS.includes(g[1])) {
      errors.push(`occ_restrictions names group:${g[1]}, which is not one of ` +
        OCC_GROUPS.join(' | '));
    } else if (!g && !/^[a-z0-9][a-z0-9-]*$/.test(n)) {
      errors.push(`occ_restrictions names "${n}", which is not a class id or a group`);
    }
  }
  if (block.note !== undefined && typeof block.note !== 'string') {
    errors.push('occ_restrictions.note must be a string');
  }
}

// The mirror check. A race id with no race is the same failure as a class id
// with no class: it silently allows exactly what it meant to forbid.
function validateRaceRestrictions(block, errors) {
  if (block === undefined || block === null) return;
  if (typeof block !== 'object' || Array.isArray(block)) {
    errors.push('race_restrictions must be a map with `only` or `except`');
    return;
  }
  const hasOnly = Array.isArray(block.only);
  const hasExcept = Array.isArray(block.except);
  if (hasOnly && hasExcept) {
    errors.push('race_restrictions sets both only and except; state one or the other');
  }
  if (!hasOnly && !hasExcept) {
    errors.push('race_restrictions needs an `only` or an `except` list');
    return;
  }
  const list = hasOnly ? block.only : block.except;
  if (!list.length) {
    errors.push(`race_restrictions.${hasOnly ? 'only' : 'except'} is empty and would ` +
      `${hasOnly ? 'forbid everything' : 'forbid nothing'}`);
  }
  for (const n of list) {
    if (typeof n !== 'string' || !n.trim()) {
      errors.push('race_restrictions entries must be race ids or "none"');
    } else if (n !== RACE_NONE && !/^[a-z0-9][a-z0-9-]*$/.test(n)) {
      errors.push(`race_restrictions names "${n}", which is not a race id or "none"`);
    }
  }
  if (block.note !== undefined && typeof block.note !== 'string') {
    errors.push('race_restrictions.note must be a string');
  }
}

export function parseClassMarkdown(text) {
  const errors = [];
  const warnings = [];

  const fm = text.match(/^---\r?\n([\s\S]*?)\r?\n---\s*\r?\n?([\s\S]*)$/);
  if (!fm) {
    return { ok: false, data: null, errors: ['No YAML frontmatter block found (--- ... ---)'], warnings };
  }

  let data;
  try {
    data = parseYaml(fm[1]);
  } catch (e) {
    return { ok: false, data: null, errors: ['Frontmatter parse error: ' + e.message], warnings };
  }

  // Required fields
  for (const field of ['id', 'name', 'system', 'source_book', 'category']) {
    if (data[field] == null || data[field] === '') errors.push(`Missing required field: ${field}`);
  }
  if (data.id != null && !/^[a-z0-9][a-z0-9-]*$/.test(String(data.id))) {
    errors.push(`id must be a kebab-case slug, got: ${data.id}`);
  }
  if (data.system != null && !VALID_SYSTEMS.includes(data.system)) {
    errors.push(`system must be one of ${VALID_SYSTEMS.join(' | ')}, got: ${data.system}`);
  }
  if (data.category != null && !VALID_CATEGORIES.includes(data.category)) {
    errors.push(`category must be one of ${VALID_CATEGORIES.join(' | ')}, got: ${data.category}`);
  }

  if (data.occ_group !== undefined && !OCC_GROUPS.includes(data.occ_group)) {
    errors.push(`occ_group must be one of ${OCC_GROUPS.join(' | ')}, got: ${data.occ_group}`);
  }
  if (data.occ_group !== undefined && data.category !== 'occ') {
    warnings.push('occ_group is set on something that is not an O.C.C. and will do nothing');
  }
  // F11. A class whose book says the character stops being what it was.
  // OPT-IN AND FALSE BY DEFAULT: every class in the catalog today wants the
  // race-primary policy - a dragon that studies an O.C.C. is still a dragon -
  // so this must never be inferred, only declared.
  if (data.supersedes_race !== undefined) {
    if (data.supersedes_race !== true) {
      errors.push('supersedes_race is a flag and may only be true; omit it otherwise');
    }
    if (data.category !== 'occ') {
      warnings.push('supersedes_race is set on something that is not an O.C.C. and will do nothing');
    }
  }
  if (data.occ_restrictions !== undefined && data.category !== 'rcc') {
    warnings.push('occ_restrictions is set on something that is not a race and will do nothing');
  }
  validateOccRestrictions(data.occ_restrictions, errors, warnings);

  // `psionics.categories_allowed` is a category list, and since F16 it takes
  // the SAME grammar as a skill category: a plain string, or an object with
  // `only` / `except`. The Crazy's book allows two categories "excluding Astral
  // Projection, Ectoplasm, Object Read and Telekinesis", and there was no way
  // to say that - `powers_from` is a positive list that REPLACES the category
  // gate rather than narrowing it.
  //
  // NOTE THAT THERE IS NO OTHER PSIONICS VALIDATION, which F16 assumed there
  // was. Nothing in this file checked that block before, so this validates the
  // one key whose grammar just widened rather than inventing a validator for
  // the whole thing.
  for (const [where, block] of psionicBlocks(data)) {
    validateCategories(`${where}.categories_allowed`, block.categories_allowed, errors);
    for (const c of block.categories_allowed || []) {
      // A percentage is a SKILL idea. A psionic power has an I.S.P. cost and no
      // percentage to raise, so a bonus here would be stored and never read -
      // the same silent no-op that made `bonus` a parse error on
      // secondary_skills.categories.
      if (c && typeof c === 'object' && c.bonus !== undefined) {
        errors.push(`${where}.categories_allowed.${c.name} sets a bonus; `
          + 'a psionic power has a cost, not a percentage');
      }
    }
  }
  if (data.race_restrictions !== undefined && data.category !== 'occ') {
    warnings.push('race_restrictions is set on something that is not an O.C.C. and will do nothing');
  }
  validateRaceRestrictions(data.race_restrictions, errors);

  // Shape checks on optional structures
  if (data.skills) {
    // An occ_skills entry is either a fixed skill ({name, base, per_level}) or a
    // choice-group ({choose, from: [...]}) — some classes bundle "pick N of
    // these" into the required list itself. Both may carry a free-text `note`
    // for conditional substitutions (advisory only, never enforced).
    validateSkillEntries('skills.occ_skills', data.skills.occ_skills, errors, warnings);

    // A Military Occupational Specialty: "select one area of specialty, gain
    // all skills under that MOS". Its options hold entries of exactly the same
    // shape as occ_skills - named skills and choice groups - so they go through
    // the same validator. Two validators for one shape is the pair that drifts.
    validateMos(data.skills.mos, errors, warnings);
    const related = data.skills.occ_related_skills;
    if (related) {
      if (typeof related.count !== 'number') errors.push('skills.occ_related_skills.count must be a number');
      validateCategories('skills.occ_related_skills.categories', related.categories, errors);
      // Optional staged picks: [{ level, count }] granted beyond the starting
      // count. Stored for future use — the leveling flow does not act on it yet.
      for (const step of related.schedule || []) {
        if (!step || typeof step.level !== 'number' || typeof step.count !== 'number') {
          errors.push('occ_related_skills.schedule entries need numeric level and count');
        }
      }
      // A per-category floor on those picks (F6). Validated after the
      // categories, because every check it makes is against them.
      validateRelatedMinimums(related, errors);
    }
    const secondary = data.skills.secondary_skills;
    if (secondary && typeof secondary.count !== 'number') errors.push('skills.secondary_skills.count must be a number');
    // A category bonus on the SECONDARY list would be stored and never read:
    // the books give the parenthetical percentage to related selections only,
    // so nothing applies it here. Rejected rather than ignored, because an
    // author writing it has misread the class page and would get no other
    // signal — the character would simply come out low by ten points.
    for (const c of secondary?.categories || []) {
      if (c && typeof c === 'object' && c.bonus !== undefined) {
        errors.push(`skills.secondary_skills.categories.${c.name} sets a bonus; `
          + 'the parenthetical percentage applies to related selections only');
      }
    }
    // Secondary skills can arrive on a schedule too — the Long Bowman gets one
    // more at levels 4, 7, 10 and 13. Same shape as the related schedule,
    // because it is the same idea.
    for (const e of secondary?.schedule || []) {
      if (!Number.isFinite(e?.level) || !Number.isFinite(e?.count)) {
        errors.push('secondary_skills.schedule entries need numeric level and count');
      }
    }
  }
  for (const eq of data.equipment_starting || []) {
    if (!eq || typeof eq !== 'object') { errors.push('equipment_starting entries must be objects'); continue; }
    if (isGearChoice(eq)) {
      if (typeof eq.choose !== 'number' || eq.choose < 1) {
        errors.push('equipment_starting choice needs a numeric choose >= 1');
      }
      if (!Array.isArray(eq.from) || !eq.from.length) {
        errors.push('equipment_starting choice needs a non-empty from list of item slugs');
      } else if (eq.from.some((s) => typeof s !== 'string' || !s.trim())) {
        errors.push('equipment_starting choice `from` must be item slugs');
      } else if (eq.choose > eq.from.length) {
        errors.push(`equipment_starting choice asks for ${eq.choose} of only ${eq.from.length} options`);
      }
      // A choice's qty applies per pick and is re-derived every render, so a
      // dice value here would re-roll each time the page painted. Fixed
      // entries roll once behind the wizard's equipInit guard; choices stay
      // plain numbers until someone builds them the same storage.
      if (eq.qty !== undefined && (typeof eq.qty !== 'number' || !Number.isFinite(eq.qty) || eq.qty < 1)) {
        errors.push('equipment_starting choice qty must be a plain number >= 1');
      }
    } else if (!eq.item_id) {
      errors.push('equipment_starting entries need an item_id (or choose/from for a choice)');
    } else if (eq.qty !== undefined && !isValidQuantity(eq.qty)) {
      errors.push(`equipment_starting ${eq.item_id}: qty must be a number >= 1 or a dice expression like "1d6"`);
    }
  }
  for (const lp of data.level_progression || []) {
    if (!lp || typeof lp !== 'object' || typeof lp.level !== 'number') {
      errors.push('level_progression entries need a numeric level');
    }
  }

  // What a class GRANTS mechanically, as opposed to level_progression.grants,
  // which is free text for display. A Dragon's "+2 to P.S." and "+1 attack per
  // melee at level 5" were prose that nothing could act on; this is where a
  // number goes so the sheet can actually add it up.
  if (data.bonuses) validateBonuses(data.bonuses, errors, warnings);

  // An ability choice group. Unvalidated until now, which is why a `choose`
  // written into special_abilities parsed clean and then did nothing at all.
  for (const e of data.special_abilities || []) {
    if (!isAbilityChoice(e)) continue;
    if (e.from !== undefined && !Array.isArray(e.from)) {
      errors.push('special_abilities: from must be a list of ability names');
    }
    if (e.choose !== undefined && (typeof e.choose !== 'number' || e.choose < 1)) {
      errors.push('special_abilities: choose must be a positive number');
    }
  }

  // A named ability may carry what it grants. Validated through exactly the same
  // path a class's own bonuses take, so an ability cannot express a bonus a
  // class could not — and a key derive.js does not read is caught here rather
  // than stored and silently ignored.
  const optionNames = new Set(abilityOptions(data).map((n) => n.trim().toLowerCase()));
  const defined = new Set();
  for (const e of data.special_abilities || []) {
    if (!isAbilityDefinition(e)) continue;
    defined.add(e.name.trim().toLowerCase());
    if (e.bonuses !== undefined) validateBonuses(e.bonuses, errors, warnings);
    if (e.repeatable !== undefined && typeof e.repeatable !== 'boolean') {
      errors.push(`special_abilities: ${e.name}.repeatable must be true or false`);
    }
    if (e.on_repeat !== undefined && typeof e.on_repeat !== 'string') {
      errors.push(`special_abilities: ${e.name}.on_repeat must be text`);
    }
    // Taking it twice is only meaningful if taking it twice is allowed.
    if (e.on_repeat !== undefined && e.repeatable !== true) {
      warnings.push(`special_abilities: ${e.name} states on_repeat but is not repeatable, `
        + 'so the second-take text can never be reached');
    }
    for (const k of ABILITY_GRANTS) {
      if (e[k] !== undefined && (typeof e[k] !== 'object' || Array.isArray(e[k]))) {
        errors.push(`special_abilities: ${e.name}.${k} must be a map`);
      }
    }
  }

  // The mirror of the warning below, and the one that actually cost something.
  // `applyAbilities` folds in bonuses for the abilities a character CHOSE - it
  // returns the class untouched when nothing was chosen - so a definition that
  // no choice group offers contributes its bonuses only if a player picks it or
  // a G.M. types the name in. Never automatically.
  //
  // That makes a `bonuses` block on an ability every character of the class
  // simply HAS a statement that reads as mechanical and is not. The Stone
  // Master's Marks of Heritage were written that way: +12 P.P.E. and +20 S.D.C.
  // that no Stone Master ever received. They belong on the class, or - when
  // only some characters have them - on the variant that does.
  for (const e of data.special_abilities || []) {
    if (!isAbilityDefinition(e) || e.bonuses === undefined) continue;
    if (optionNames.has(e.name.trim().toLowerCase())) continue;
    warnings.push(`special_abilities: ${e.name} carries bonuses but is not offered `
      + 'as a choice, so nothing grants it automatically - put them on the class '
      + '(or its variant) if every character has them');
  }

  // An option nothing defines can still be picked, and would grant nothing.
  // A warning rather than an error: a book routinely names a power it describes
  // only in prose, and refusing the class over it would be worse.
  for (const n of optionNames) {
    if (!defined.has(n)) {
      warnings.push(`special_abilities: "${n}" is offered as a choice but nothing defines it, `
        + 'so picking it grants nothing');
    }
  }
  if (data.variants !== undefined) {
    // The names the class grants by name, so an override that names anything
    // else can be called out rather than silently doing nothing.
    const granted = new Set((data.skills?.occ_skills || [])
      .filter((s) => s && typeof s.name === 'string')
      .map((s) => s.name.trim().toLowerCase()));
    validateVariants(data.variants, errors, warnings, granted);
  }

  const sections = parseBodySections(fm[2]);
  data.sections = sections;
  data.lore = sections['lore'] ?? null;
  data.gm_notes = sections['gm notes'] ?? null;
  if (!data.lore) warnings.push('No ## Lore section in body');

  return { ok: errors.length === 0, data, errors, warnings };
}
