import { diceBounds, isAbsentAttribute, isAttributeExpr, poolFormulaBounds, ATTRIBUTES, POOL_KEYS } from './dice.js';
import { isHandToHand } from './hand-to-hand.js';
import { keysMergedBy, GAME_SYSTEMS } from './class-keys.js';
// Two rule families live in their own modules and are re-exported here, so
// nothing that imports parser.js has to know they moved: the ability grants
// (js/abilities.js) and the class tags (js/class-tags.js).
export {
  isAbilityChoice, ABILITY_GRANTS, isAbilityDefinition, abilityOccOptions,
  abilityOptions, normalizeAbilities, abilityGroupIndexFor,
  abilityGroupCounts, abilityRollBands, abilityRollMatches, abilityRollLimit,
  abilityGroupOwed, abilityGroupLevels, abilityGroupAllowance,
  abilityLevelGrants, rollAbilityTable, abilityOffersPsionics,
  psionicsTableLeftRolling, abilityTouchesPool, applyAbilityPoolBases,
  abilityProgressionAt, applyAbilities
} from './abilities.js';
export {
  CLASS_TAGS, MAX_AUTHORED_TAGS, classTagInfo, classTags, suggestClassTags
} from './class-tags.js';
import { isAbilityChoice, ABILITY_GRANTS, isAbilityDefinition, abilityOptions,
         abilityRollLimit, applyAbilities, bandsOf, ABILITY_POOL_BASES,
         isHorrorFactor } from './abilities.js';
import { validateTags } from './class-tags.js';
// The combine rules are js/combine.js, re-exported here the same way.
export {
  mergePsionics, mergeTalents, mergeSuperAbilities, mergeMagic,
  sumBonusGroups, levelGrants, skillLevelNotes, skillConditionalBonuses,
  bonusesFromSkills, pairedSkillCounts, combineClasses
} from './combine.js';
import {
  psionicBlocks, superAbilityBlocks, SUPER_ABILITY_TIERS, talentBlocks,
  TALENT_TIERS, PAIRING_COUNT_LISTS
} from './combine.js';

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

// Heroes Unlimited is a FOURTH, added the same way and for the same reason;
// its survey is apps/character-creator/docs/surveys/heroes-unlimited-core.md.
// Nightbane is a THIRD Palladium game on the same engine, not a Rifts world
// book, so its classes need a system of their own. Added with the catalog half
// of BOOK-INGEST-AUDIT F73. `campaigns.system` is a SQLite CHECK and is
// deliberately NOT widened in the same change, which is why the wizard's own
// system picker in app.js still offers two: S.system feeds the campaign POST.
const VALID_SYSTEMS = GAME_SYSTEMS;   // js/class-keys.js
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

// An option in a skill choice group's `from` list is a name, or `{ name, bonus }`
// when the book gives that one option its own bonus: RUE p.154 offers the
// Psi-Stalker "Tanks & APCs (+10%) OR Hovercycles (+15%)", and one `bonus` on
// the group cannot say both. BOOK-INGEST-AUDIT.md F135.
//
// ONE reader for the name, so nothing downstream has to know which shape it was
// handed - `String(option)` on the object form is "[object Object]", which
// matches no skill and prints as itself.
export function skillOptionName(option) {  const name = typeof option === 'string' ? option : option?.name;
  return typeof name === 'string' ? name : '';
}

// What a pick from a choice group resolves against: the group itself, with the
// picked option's own bonus in place of the group's where the option states
// one. A bare-string option, and a pick the list does not name (a category
// group, a language taken through its Other row), gets the group back
// untouched, so a list of plain names behaves exactly as it did.
//
// An exact name wins over a "Pilot: any" prefix entry, so a list may give the
// family one bonus and one member of it another.
export function skillGroupForPick(group, pickName) {  const key = String(pickName ?? '').trim().toLowerCase();
  const stated = (group?.from || []).filter((o) => o && typeof o === 'object'
    && typeof o.bonus === 'number' && Number.isFinite(o.bonus));
  if (!key || !stated.length) return group;
  const nameOf = (o) => skillOptionName(o).trim().toLowerCase();
  const own = stated.find((o) => nameOf(o) === key)
    || stated.find((o) => {
      const m = nameOf(o).match(/^(.*?):\s*any$/);
      return m && key.startsWith(m[1] + ':');
    });
  return own ? { ...group, bonus: own.bonus } : group;
}

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
// The keys an O.C.C.'s `overrides_race` list may name (BOOK-INGEST-AUDIT F111):
// the two of combineClasses's race-first keys that come from what a character
// DOES rather than what it IS. Deliberately only these two - the body keys stay
// the race's, and a class that replaces the whole body wants supersedes_race.
// A race's `yields_to_occupation` map may name the same two and no others.
export const OVERRIDES_RACE_KEYS = ['ppe_base', 'starting_money'];

export const VARIANT_OVERRIDES = [
  'attribute_dice', 'attribute_requirements', 'attribute_maximums',
  'hit_points_base', 'sdc_base', 'mdc_base', 'ppe_base',
  'starting_money',
  // A Horror Factor a character PROJECTS. BOOK-INGEST-AUDIT F75. It was put on
  // this list with the Nightbane's two forms as its motivating case; that case
  // is `second_form.horror_factor` now (F74, survey D5), because a Morphus is a
  // state and not a variant. `add-cosmo-knight-class.sql` and
  // `add-asgardian-dwarf-class.sql` print "none normally, N if revealed". A
  // plain scalar, so it replaces rather than merging.
  //
  // `second_form` IS DELIBERATELY NOT ON THIS LIST. No staged class prints a
  // second body that differs by stage, and a variant naming one is warned about
  // below as a key a variant cannot override rather than silently ignored.
  'horror_factor',
  // A stage or option that levels on its own chart. Rifts World Book 29
  // printed 79 gives the Madhaven Mutant Shaman the Gateway Knight & Mutant
  // Shaman column while every other Haven Mutant takes the Haven Mutant R.C.C.
  // column, and the Shaman is a `shaman` variant on each of the eight mutants.
  // A scalar array, so it replaces. Every reader goes through `xpTableFor`
  // with the class AFTER `applyVariant` (the server's `loadClass`, and the
  // wizard's `composeClass` / `applyVariant`); an O.C.C.'s ladder still wins a
  // pairing in `combineClasses`, unless the race states `keeps_xp_table` (F122).
  // BOOK-INGEST-AUDIT F108.
  'xp_table',
  'bonuses',
  // NOT the skills block. `skill_overrides` below restates numbers on skills
  // the class already grants, which is a different and much smaller power.
  'skill_overrides',
  // Skills a variant ADDS to the parent's, and the count of related picks it
  // gets. Both are handled explicitly below the loop, like `skill_overrides`:
  // the loop only assigns, and neither of these means anything as a bare
  // top-level key. BOOK-INGEST-AUDIT.md F31.
  //
  // UNION, never replace, which is what keeps the restriction's reasoning
  // intact - a variant still cannot take a skill away, cannot contradict the
  // parent, and cannot become a second class, because the parent's whole list
  // survives in every variant by construction.
  'skills_additional',
  'related_skills_count',
];

// These three are flat maps of INDEPENDENT per-attribute values, so a variant
// naming one attribute is saying something about that attribute and nothing
// about the other seven. Replacing them wholesale meant an adult dragon that
// overrode only P.S. silently lost the base's I.Q. dice and rolled a plain 3d6.
//
// Everything else replaces. A scalar has nothing to merge, and `bonuses` is a
// nested structure where merging would raise "which half won" on every key —
// a variant's bonuses ARE its bonuses.
//
// A key listed HERE and not in VARIANT_OVERRIDES is never read: `applyVariant`
// iterates the overrides and consults this list only to choose spread-vs-
// replace. F32's proposal named this list alone, which would have been a no-op.
const VARIANT_MERGED = ['attribute_dice', 'attribute_requirements', 'attribute_maximums'];

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

  // Skills the variant ADDS. The book's shape is a common training course plus
  // a chassis-specific supplement - "In addition to the Basic O.C.C. Skills,
  // the Imprimer gets these additional skills" - which `skill_overrides` cannot
  // express, because it may only restate a number on a skill already granted.
  //
  // THE UNION POLICY IS `combineClasses`', not a new one. Named entries dedupe
  // by lowercased name with the HIGHER `base` winning; choice groups never
  // collapse, because they have no identity to match on. That policy is already
  // tested and already the answer to "what happens when two lists overlap", and
  // a second, subtly different one is how two paths drift apart.
  //
  // NOT `applyMos`, which is the naive concat and is deliberately not exported
  // (`js/compose.js`) - an MOS is a specialty chosen at creation, and its own
  // comment says why it is not a variant.
  const extra = out.skills_additional;
  if (extra && typeof extra === 'object' && Array.isArray(extra.occ_skills)) {
    const bySkill = new Map();
    const groups = [];
    for (const entry of [...(out.skills?.occ_skills || []), ...extra.occ_skills]) {
      if (!entry?.name) { groups.push(entry); continue; }
      const key = String(entry.name).toLowerCase();
      const seen = bySkill.get(key);
      if (!seen || (entry.base ?? 0) > (seen.base ?? 0)) bySkill.set(key, entry);
    }
    out.skills = { ...out.skills, occ_skills: [...bySkill.values(), ...groups] };
  }
  delete out.skills_additional;

  // How many O.C.C. Related Skills this chassis gets. The book states it as a
  // delta from the base - "other O.C.C. skills are reduced to three (not six)".
  //
  // THE KEY IS `related_skills_count`, THE SAME NAME THE ABILITY PATH USES, and
  // that is a deliberate departure from F31, which proposed `related_skill_count`
  // - one character apart, meaning the same thing. Two spellings would be a trap
  // pointing the wrong way: a variant naming the ability's spelling gets the
  // ignored-key warning below, while an ability naming the variant's gets
  // nothing at all, because abilities have no unknown-key sweep. One name for
  // one mechanic removes the question. See `applyAbilities` for the twin.
  if (Number.isInteger(out.related_skills_count) && out.skills?.occ_related_skills) {
    out.skills = {
      ...out.skills,
      occ_related_skills: { ...out.skills.occ_related_skills, count: out.related_skills_count },
    };
  }
  delete out.related_skills_count;

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
    // `with` names the OTHER skills a repeated skill is paired with - the
    // Gunfighter takes W.P. Sharpshooting once for each of three weapons, and
    // the pairing is the part a bare count cannot carry. It annotates a NAMED
    // entry only: on a choice group there is no single skill to pair.
    // BOOK-INGEST-AUDIT.md F49.
    if (s.with !== undefined) {
      if (isChoiceGroup(s)) {
        errors.push(`${where} choice-group cannot take a with list; it annotates a named skill`);
      } else if (!Array.isArray(s.with) || s.with.length < 2
                 || s.with.some((n) => typeof n !== 'string' || !n.trim())) {
        errors.push(`${where}.with must be a list of two or more skill names`);
      } else if (new Set(s.with.map((n) => n.trim().toLowerCase())).size !== s.with.length) {
        errors.push(`${where}.with lists the same skill twice`);
      }
    }
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
      // A `from` option is a name, or `{ name, bonus }` for an option the book
      // gives its own bonus (BOOK-INGEST-AUDIT.md F135). The object form is
      // checked here because nothing else would: a missing name matches no
      // skill, and a bonus written as "15%" would fall back to the group's
      // silently - the wrong number, with nothing flagging it. An option bonus
      // beside a group `base` is refused for the reason the pair above is.
      if (hasFrom) {
        s.from.forEach((opt, oi) => {
          if (typeof opt === 'string') return;
          if (!opt || typeof opt !== 'object' || Array.isArray(opt)
              || typeof opt.name !== 'string' || !opt.name.trim()) {
            errors.push(`${where}.from[${oi}] must be a skill name or { name, bonus }`);
            return;
          }
          if (opt.bonus === undefined) return;
          if (typeof opt.bonus !== 'number' || !Number.isFinite(opt.bonus)) {
            errors.push(`${where}.from[${oi}] bonus must be a number`);
          } else if (s.base !== undefined) {
            errors.push(`${where}.from[${oi}] sets a bonus on a choice-group that sets base; use one`);
          }
        });
      }
      // `per_level` IS READ on a choice group and was the one key here nothing
      // checked. `resolveSkill` in app.js takes `explicit.per_level ??
      // cat.per_level ?? 0`, so a number here OVERRIDES the catalog row's own
      // figure for every pick in the group - which is how a class says "these
      // skills do not advance" over rows that otherwise would.
      //
      // Unvalidated, a string or a typo fell through to the catalog rate and
      // the class silently advanced skills its book freezes. 63 choice groups
      // across 29 data scripts carry the key (measured 2026-09-13), so this is
      // not one book's problem. BOOK-INGEST-AUDIT.md F80, which also settles
      // the question F25's note left open.
      if (s.per_level !== undefined
          && (typeof s.per_level !== 'number' || !Number.isFinite(s.per_level))) {
        errors.push(`${where} choice-group per_level must be a number`);
      }
      // `only`, `except`, `only_prefix` and `except_prefix` are read ONLY off a
      // CATEGORY ENTRY - `categoryAllows` below finds the entry matching the
      // skill's own category and reads them off that object, returning true
      // outright for a bare string. Written one level out, on the group, they
      // parse, validate, store and do NOTHING.
      //
      // REFUSED RATHER THAN WARNED, because there is no reading under which a
      // group-level prefix means anything: it is unambiguously a mistake, and
      // it fails OPEN in both directions. `only_prefix` ignored means the whole
      // category; `except_prefix` ignored means nothing is excluded. Both grant
      // MORE than the book allows, which is the direction nobody reports - a
      // player just gets a longer list. The Night Witch's "Lore: two of choice"
      // named its four lores on the group and so offered all 87 Technical
      // skills, and `class-check` called it `ready - 0 errors, 0 warnings`.
      //
      // It is easy to write because the correct form is more verbose and the
      // wrong one reads like the group's other keys: `choose`, `categories`,
      // `bonus` and `note` all live at this level, so a fifth looks at home.
      //
      // BOOK-INGEST-AUDIT.md F84. Swept before this landed: 318 published live
      // classes, 1,725 choice groups, 932 of these keys on a category entry and
      // ZERO on a group (--remote, 2026-09-14), so nothing in the catalog
      // starts failing on the day it ships.
      for (const k of ['only', 'except', 'only_prefix', 'except_prefix']) {
        if (s[k] === undefined) continue;
        errors.push(`${where} choice-group sets ${k} on the GROUP, where nothing reads it; `
          + `put it on the category entry - categories: [{ name: "...", ${k}: [...] }]`);
      }

      // AND THEN VALIDATE THE ENTRY THE REFUSAL ABOVE INSISTS ON.
      // BOOK-INGEST-AUDIT.md F88. F84 pushed authors off a form that was
      // silently DEAD and onto one that was silently UNVALIDATED: a group's
      // `categories` was never handed to validateCategories, which had exactly
      // three callers - categories_allowed, occ_related_skills and
      // skill_programs - and a choice group was not among them. So an entry
      // setting both `only` and `except`, an `only_prefix` written as a bare
      // string, and an entry with no `name` at all each parsed ok=true with
      // zero errors, while the IDENTICAL entry on occ_related_skills errored.
      // The rule existed, was written, fired, and was never reached from here.
      //
      // ERRORS rather than warnings, matching the three existing callers - a
      // fourth that warned instead would be a second standard. Safe because
      // F88's pre-run was done first: validateCategories was run over every
      // category entry on every choice-group-shaped object at any depth across
      // all 318 published live classes (--remote, 2026-09-15) and returned ZERO
      // errors on ZERO classes. Nothing starts failing the day this ships,
      // which matters more than usual here: class-store.js DROPS a class that
      // fails to parse out of GET /classes rather than 4xx-ing, and
      // class-loader.js returns null for it, so an error makes a class vanish
      // from every picker AND from its own saved characters.
      validateCategories(`${where} choice-group`, s.categories, errors);
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
      // Outside the chain above, because `per_level` is independent of which of
      // base/bonus the entry uses - and it was unchecked on a NAMED skill for
      // the same reason it was unchecked on a choice group: nothing read the
      // two halves of this function looking for the same key twice.
      // BOOK-INGEST-AUDIT.md F80.
      if (s.per_level !== undefined
          && (typeof s.per_level !== 'number' || !Number.isFinite(s.per_level))) {
        errors.push(`${where} "${s.name}" per_level must be a number`);
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
//
// `choose` MAY BE MORE THAN ONE, and until BOOK-INGEST-AUDIT.md F82 it could
// not be: it was validated here and honoured nowhere. `applyMos` took a single
// id, `S.mos` was a single value and the picker was a replace-toggle, so a
// class asking for three granted one and reported nothing wrong. Every class
// that shipped in that time asks for exactly one, which is why it never bit.
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

// Which specialties a character holds, out of whatever is carrying them.
//
// THREE shapes arrive here and all three are current:
//
//   ["recon", "comms"]     an array, which is what the wizard sends now
//   '["recon","comms"]'    that array as TEXT, straight off `characters.mos`
//   "recon"                one bare id - every row written before F82, and
//                          every draft saved before it
//
// `characters.mos` is deliberately NOT declared in CHARACTER_JSON_COLUMNS.
// That list decodes a parse failure to an empty value, and a bare id is not
// JSON - so declaring it there would turn a pre-F82 character's specialty into
// no specialty at all, silently, which is the one failure worth designing
// against. One tolerant reader costs less than a backfill and cannot lose a
// value it does not recognise.
//
// Order is the caller's, de-duplicated case-insensitively: the book's rule is
// that a program is taken once (Heroes Unlimited printed 27, restriction 8),
// and granting one twice would double its skills rather than refuse.
export function mosList(value) {
  const raw = Array.isArray(value) ? value : parseMosText(value);
  const seen = new Set();
  const out = [];
  for (const v of raw) {
    const id = String(v ?? '').trim();
    if (!id) continue;
    const key = id.toLowerCase();
    if (seen.has(key)) continue;
    seen.add(key);
    out.push(id);
  }
  return out;
}

function parseMosText(value) {
  if (value === null || value === undefined) return [];
  const s = String(value).trim();
  if (!s) return [];
  // Only a leading bracket is worth a parse attempt. A specialty id could in
  // principle be named "[recon]" and would then round-trip as one id, which is
  // the right answer for a string that is not a JSON array.
  if (s.startsWith('[')) {
    try {
      const parsed = JSON.parse(s);
      if (Array.isArray(parsed)) return parsed;
    } catch { /* not JSON after all; it is one id that happens to start with [ */ }
  }
  return [s];
}

// `totem` - the class picks one animal from the `totems` catalog
// (BOOK-INGEST-AUDIT.md F56). Spirit West printed 96-105 prints forty, and nine
// of its O.C.C.s pick one, so the table is shared rather than written into each.
//
//   totem: { from: "animal" }                 # skills and bonuses
//   totem: { from: "animal", powers: true }   # the Totem Warrior: its giant-form powers too
//
// `from` names the catalog's only kind. It is required rather than implied so a
// class whose book offers something else - the Elemental Shaman has one of four
// ELEMENTS instead, printed 65, and is one class per element since
// BOOK-INGEST-AUDIT F63 - cannot borrow the key and be handed forty animals.
export function validateTotem(t, errors, warnings) {
  if (t === undefined || t === null) return;
  if (typeof t !== 'object' || Array.isArray(t)) {
    errors.push('totem must be a map, e.g. { from: "animal" }');
    return;
  }
  if (t.from !== 'animal') errors.push(`totem.from must be "animal", got: ${t.from}`);
  if (t.powers !== undefined && t.powers !== true) {
    errors.push('totem.powers is a flag and may only be true; omit it otherwise');
  }
  for (const k of Object.keys(t)) {
    if (!['from', 'powers', 'note'].includes(k)) warnings.push(`totem.${k} is not read and will be ignored`);
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

    // F31. `skills_additional` is a skills block, and the only part of one a
    // variant may use is `occ_skills` - the additions the book states. A
    // variant that tried to restate `occ_related_skills` or `secondary_skills`
    // wholesale would be replacing the parent's allowance rather than adding
    // to it, which is the power this key is deliberately not given;
    // `related_skills_count` is how the count moves, and it is a number.
    if (v.skills_additional !== undefined) {
      const sa = v.skills_additional;
      if (!sa || typeof sa !== 'object' || Array.isArray(sa)) {
        errors.push(`variant "${v.id}" skills_additional must be an object with occ_skills`);
      } else {
        if (!Array.isArray(sa.occ_skills)) {
          errors.push(`variant "${v.id}" skills_additional needs an occ_skills list`);
        }
        for (const k of Object.keys(sa)) {
          if (k !== 'occ_skills') {
            errors.push(`variant "${v.id}" skills_additional.${k} is not addable - a variant `
              + 'may ADD occ_skills, and change the related count with related_skills_count');
          }
        }
      }
    }
    if (v.related_skills_count !== undefined
        && (!Number.isInteger(v.related_skills_count) || v.related_skills_count < 0)) {
      errors.push(`variant "${v.id}" related_skills_count must be a whole number`);
    }

    // A field a variant cannot override would silently do nothing, which is
    // exactly the confusion this list exists to prevent.
    for (const key of Object.keys(v)) {
      if (key === 'id' || key === 'name' || VARIANT_OVERRIDES.includes(key)) continue;
      warnings.push(`variant "${v.id}" sets ${key}, which a variant cannot override — it will be ignored`);
    }
  }
}

// ─── an R.C.C. and an O.C.C. together ─── moved to js/combine.js: re-exported at the top of this file.

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

export const normName = (s) => String(s ?? '').trim().toLowerCase();

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
  // The PREFIX forms are shown too. A picker that displayed "Pilot" while
  // silently withholding thirteen Robot Combat rows would be lying by omission
  // in the same way the bonus case above was - which is why they are appended
  // to the same parenthetical rather than given one of their own (F23(b)).
  const parts = [];
  const onlyBits = [
    ...(Array.isArray(entry.only) ? entry.only : []),
    ...(Array.isArray(entry.only_prefix) ? entry.only_prefix.map((p) => `${p}...`) : []),
  ];
  const exceptBits = [
    ...(Array.isArray(entry.except) ? entry.except : []),
    ...(Array.isArray(entry.except_prefix) ? entry.except_prefix.map((p) => `${p}...`) : []),
  ];
  if (onlyBits.length) parts.push(`${onlyBits.join(', ')} only`);
  else if (exceptBits.length) parts.push(`except ${exceptBits.join(', ')}`);
  if (pct) parts.push(pct);
  return parts.length ? `${name} (${parts.join('; ')})` : (name ?? '');
}

// Does this ONE category entry, already known to match the skill's real
// category, admit the skill? `name` is normName(skill.name).
//
// PREFIX FORMS, for a book that excludes a FAMILY rather than a list.
// BOOK-INGEST-AUDIT.md F23(b): Triax printed 170 says "Technical: All, except
// lore" and "Pilot: All, except pilot robots & power armor and robot combat".
// Those are 14 `Lore...` rows and 13 `Robot Combat...` rows, and this book
// alone added NINE of the latter - so an exact-name list would rot on contact
// and under-grant silently, which is the direction nothing reports.
//
// SCOPED TO THIS ENTRY, never applied globally. Two `Lore:` rows are filed
// under Cowboy rather than Technical, and a prefix reaching across categories
// would exclude them from a Cowboy grant that never mentioned lore. Every
// caller hands this an entry already matching the skill's real category, so
// testing it here IS the scoping.
function entryAdmits(entry, name) {
  if (typeof entry === 'string') return true;
  if (!entry || typeof entry !== 'object') return false;
  const hasPrefix = (list) => Array.isArray(list)
    && list.some((p) => normName(p) && name.startsWith(normName(p)));

  if (entryNarrowsByOnly(entry)) {
    return (entry.only || []).some((n) => normName(n) === name)
      || hasPrefix(entry.only_prefix);
  }
  // `except` AND `except_prefix` TOGETHER ARE LEGAL, unlike `only` with
  // `except`. Both point the same way - each REMOVES rows - so "these named
  // ones, and everything starting with that" has exactly one reading, where
  // "only these, except some of them" has none. The Pilot line needs precisely
  // this combination and cannot be written without it: one exact name
  // (`Robots & Power Armor`) and one family (`Robot Combat...`).
  if (entryNarrowsByExcept(entry)) {
    return !(entry.except || []).some((n) => normName(n) === name)
      && !hasPrefix(entry.except_prefix);
  }
  return true;
}

const entryNarrowsByOnly = (entry) => !!entry && typeof entry === 'object'
  && ((Array.isArray(entry.only) && entry.only.length > 0)
    || (Array.isArray(entry.only_prefix) && entry.only_prefix.length > 0));
const entryNarrowsByExcept = (entry) => !!entry && typeof entry === 'object'
  && ((Array.isArray(entry.except) && entry.except.length > 0)
    || (Array.isArray(entry.except_prefix) && entry.except_prefix.length > 0));

// WHICH of the class's entries for the skill's real category speaks for it,
// and whether that entry admits it (BOOK-INGEST-AUDIT.md F109).
//
// A book can print a bonus for PART of a category: Coalition War Campaign's
// Nautical Specialist is "Pilot: Any, +10% to water vehicles only". That is
// written as the category twice - `{ Pilot, only: [the water vehicles],
// bonus: 10 }` and `{ Pilot, except: [the same names] }` - and both
// categoryAllows and categoryBonus used to take the FIRST entry with a matching
// name. With the `only` entry first every other Pilot skill was REFUSED; with
// the `except` entry first none got the +10%.
//
// So the entries are ranked, most specific first:
//   1. an `only` / `only_prefix` entry that names the skill;
//   2. an `except` / `except_prefix` entry that does not exclude it;
//   3. a plain entry, which admits everything in the category.
// The first rank that holds wins, and it is BOTH the admission and the bonus,
// so the two functions cannot disagree about which line of the book applied.
//
// When no entry admits the skill, the first same-named entry is returned with
// `admits: false`. That keeps a list naming the category once - every class
// before F109 - behaving exactly as the old first-hit lookup did, including
// categoryBonus's fallback for a pick admitted cross-category.
//
// A MERGED list can hold two same-named entries too: dedupeCategories
// (functions/api/character-creator/_lib/skill-picks.js) folds several related
// grants' lists into one. Ranking reads that list as "a pick passes if any
// grant admits it, and the most specific grant pays", where first-hit read it
// as whichever grant happened to be listed first.
function realCategoryEntry(categories, skill) {
  const name = normName(skill?.name);
  const cat = normName(skill?.category);
  const same = categories.filter((c) => normName(categoryName(c)) === cat);
  if (!same.length) return { entry: undefined, admits: false };
  const admitting = same.filter((c) => entryAdmits(c, name));
  const best = admitting.find(entryNarrowsByOnly)
    ?? admitting.find(entryNarrowsByExcept)
    ?? admitting[0];
  return best !== undefined ? { entry: best, admits: true } : { entry: same[0], admits: false };
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
  // Ranked, not first-hit: a category printed with a bonus for part of it is
  // two entries, and the one naming the skill pays (F109, realCategoryEntry).
  const { entry } = realCategoryEntry(categories, skill);
  if (!entry || typeof entry === 'string') return 0;
  return Number.isFinite(entry.bonus) ? entry.bonus : 0;
}

// Does this category list name `skill` in an `only` list? A class that names a
// skill outright is its book's own word that the skill may be taken, so the
// pickers let it past the game filter (`skills.systems`) - for THIS grant only.
// The Chiang-Ku Dragon is a Palladium Fantasy class whose book grants "three
// modern weapon proficiencies", and Palladium Fantasy's own tag holds none.
// Callers still test categoryAllows; this answers only the game question.
export function namedByOnly(categories, skill) {
  if (!Array.isArray(categories)) return false;
  const name = normName(skill?.name);
  return !!name && categories.some((c) => c && typeof c === 'object'
    && Array.isArray(c.only) && c.only.some((n) => normName(n) === name));
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

  // Every entry naming the skill's real category is asked, not only the first:
  // a category can be listed twice to scope a bonus to part of it (F109), and
  // the `only` half must not refuse what the `except` half admits. The entry
  // itself is judged by entryAdmits, which reads `only`, `except`,
  // `only_prefix` and `except_prefix` off the ENTRY.
  return realCategoryEntry(categories, skill).admits;
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
    for (const key of ['only', 'except', 'only_prefix', 'except_prefix']) {
      if (c[key] === undefined) continue;
      if (!Array.isArray(c[key]) || c[key].some((s) => typeof s !== 'string' || !s.trim())) {
        errors.push(`${where}.${c.name}.${key} must be a list of `
          + (key.endsWith('_prefix') ? 'name prefixes' : 'skill names'));
      }
    }
    // Both at once has no single reading: "only these, except some of them" is
    // just a shorter `only` list, and guessing which the author meant is worse
    // than saying so.
    //
    // THE PREFIX FORMS ARE JUDGED THE SAME WAY, BY DIRECTION. `except` with
    // `except_prefix` is fine - both remove rows, so the reading is one list.
    // Anything mixing an ADMITTING form with an EXCLUDING one is refused, for
    // the reason above (F23(b)).
    const admits = (Array.isArray(c.only) && c.only.length)
      || (Array.isArray(c.only_prefix) && c.only_prefix.length);
    const excludes = (Array.isArray(c.except) && c.except.length)
      || (Array.isArray(c.except_prefix) && c.except_prefix.length);
    if (admits && excludes) {
      // Wording is pinned: test/smoke.mjs matches /both only and except/ on
      // this message, and that check predates the prefix forms. Phrased to keep
      // it true rather than editing the test to suit a new sentence.
      errors.push(`${where}.${c.name} sets both only and except forms; use one direction`);
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

// A percentage is a SKILL idea, and a psionic category may not carry one.
// BOOK-INGEST-AUDIT.md F92. This was written inline against `categories_allowed`
// and F91 then added two more lists that reach the same gate, so it is a
// function rather than three copies of one `if`.
//
// THE REASON THE OLD COMMENT GAVE WAS WRONG, and the message it produced is
// kept because the message is not. It said a bonus here "would be stored and
// never read". It is read: `categoryLabel` (this file) renders
// `Number.isFinite(entry.bonus)` into the picker caption, and four call sites
// show it on a psionic category - the starting-group picker (app.js:3708), the
// sheet (sheet.js:2531 via psiCatLabel), the server's rejection text
// (power-picks.js:194) and validate-character.js:505. What NOTHING does is
// APPLY it: `categoryBonus` has two call sites and both are skill-side.
//
// So the defect is worse than the old comment claimed rather than absent. A
// stored bonus is not inert - it prints "Super (+10%)" on a power that has no
// percentage to raise, which is the wizard promising what the sheet cannot
// give. Read 2026-09-15.
function refusePsionicBonus(where, categories, errors) {
  for (const c of categories || []) {
    if (c && typeof c === 'object' && c.bonus !== undefined) {
      errors.push(`${where}.${c.name} sets a bonus; `
        + 'a psionic power has a cost, not a percentage');
    }
  }
}

// A per-category FLOOR on the related-skill picks: "Select 8 other skills, but
// at least two must be selected from espionage and two from rogue skills"
// (Phase World printed 83). BOOK-INGEST-AUDIT.md F6.
//
// `occ_related_skills` already says HOW MANY picks and WHICH categories are
// legal, and narrows a category with `only` / `except`. All three are ceilings.
// A floor is the opposite shape and could not be written at all, so classes
// across several books carried the rule as prose in a `note` and offered every
// pick freely - including the one thing each of their books forbids.
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
 * with the sugar expanded. Empty when the class has none, which is most of
 * them.
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
 *
 * AN ALLOWANCE BELOW THE FLOORS' OWN TOTAL (BOOK-INGEST-AUDIT F129). A class's
 * file cannot state one - validateRelatedMinimums refuses it - but a race's
 * `pairing_counts` trims the composed count, and three picks cannot hold two
 * Espionage and two Military. Tested the old way every such build is
 * unreachable, the one with every pick on a floor included. Nate's ruling,
 * 2026-10-13: the count stays what the book prints, and every pick goes to a
 * required category until the picks run out. So below the total a build is
 * legal exactly when no pick is WASTED, a wasted pick being one that brought
 * the floors no nearer: one outside every floor, or one more in a floor
 * already full. `trimmed` says which of the two tests was applied.
 *
 * At or above the total the old test runs, untouched. For floors that share no
 * category the two are one test - `wasted > allowance - total` is `owed >
 * remaining` rearranged - so the split changes nothing there; it exists so
 * that no build judged before this was written is judged differently now.
 */
export function relatedFloorStatus(cls, categories, allowance) {
  const floors = relatedMinimums(cls);
  const held = (Array.isArray(categories) ? categories : []).map(normName);
  const allowed = Number.isFinite(allowance) ? allowance : held.length;
  const remaining = Math.max(0, allowed - held.length);
  const status = floors.map((f) => {
    const wanted = new Set(f.categories.map(normName));
    const have = held.filter((c) => wanted.has(c)).length;
    return { ...f, have, met: have >= f.count, missing: Math.max(0, f.count - have) };
  });
  const short = status.filter((f) => !f.met);
  const owed = short.reduce((n, f) => n + f.missing, 0);
  const floorTotal = floors.reduce((n, f) => n + f.count, 0);
  if (allowed >= floorTotal) {
    return { floors: status, short, remaining, owed, trimmed: false, wasted: 0, unreachable: owed > remaining };
  }
  // The fewest picks that would meet every floor, from nothing and from here.
  // A pick counts toward EVERY floor naming its category (that is what `have`
  // counts above), so floors sharing a category need fewer picks than their
  // counts add up to, and the sum cannot stand in for this.
  const sets = floors.map((f) => new Set(f.categories.map(normName)));
  const fewest = floorPicksNeeded(sets, floors.map((f) => f.count));
  const needed = floorPicksNeeded(sets, status.map((f) => f.missing));
  const wasted = held.length - (fewest - needed);
  return { floors: status, short, remaining, owed, trimmed: true, wasted,
           unreachable: wasted > Math.max(0, allowed - fewest) };
}

// The fewest picks that bring every deficit to zero, when one pick lowers the
// deficit of each floor whose categories include it. Floors are few and small,
// so this walks every choice, remembering the deficits it has already solved.
function floorPicksNeeded(sets, deficits, memo = new Map()) {
  if (deficits.every((d) => d <= 0)) return 0;
  const key = deficits.join(',');
  if (memo.has(key)) return memo.get(key);
  const open = new Set();
  sets.forEach((set, i) => { if (deficits[i] > 0) for (const c of set) open.add(c); });
  let best = Infinity;
  for (const c of open) {
    const next = deficits.map((d, i) => (sets[i].has(c) ? Math.max(0, d - 1) : d));
    best = Math.min(best, 1 + floorPicksNeeded(sets, next, memo));
  }
  memo.set(key, best);
  return best;
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
const BONUS_ATTRS = ATTRIBUTES;

// The pools a class bonus may add to. Books state these as "plus 4D6" on top of
// whatever the occupation gives — the Demigod's P.P.E. and I.S.P. are both
// written that way (Rifts, Pantheons of the Megaverse p.17).
//
// Unlike combat and saves, a pool bonus is NOT re-read at render time. Pools are
// rolled once and stored as `*_max`, so the bonus is rolled with the base and
// folded into that number. A dice bonus re-evaluated every render would change
// the character's maximum under them.
export const POOL_BONUS_KEYS = POOL_KEYS;

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
// Exported for the catalog write path (js/catalog-fields.js, the `dice` field
// type), so a catalog column holding a roll accepts exactly what a bonus does.
export const isDiceBonus = (v) => typeof v === 'string' && DICE_BONUS.test(v.trim());

// A BONUS may also be a reduction - "reduce M.E. by 1D6" is `"-1d6"`
// (BOOK-INGEST-AUDIT F119). Its own predicate, because the two callers above
// and below must stay unsigned: a catalog `dice` column and an equipment
// quantity are amounts, not adjustments. A leading PLUS stays refused, as
// RETRO-AUDIT recorded it: the unsigned form already means that.
const SIGNED_DICE_BONUS = /^-?\s*\d+\s*d\s*\d+(?:\s*x\s*\d+)?(?:\s*[+-]\s*\d+)?$/i;
export const isSignedDiceBonus = (v) => typeof v === 'string' && SIGNED_DICE_BONUS.test(v.trim());

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
    const dice = isSignedDiceBonus(v);
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
    } else if (dice) {
      // Accepted, and rolled by nothing (BOOK-INGEST-AUDIT.md F126): the wizard
      // rolls the keyed combat and save groups and skips `other`, and the
      // sheet's labelled saves keep finite numbers only. A warning, not an
      // error, because the entry is well formed - it is the readers that stop
      // short. Rolling and storing it waits for a class that needs it.
      warnings.push(`${at}.bonus is a dice expression (${JSON.stringify(e.bonus)}) and will not be `
        + 'shown on the sheet - nothing rolls a saves.other bonus, so write the roll in the label '
        + 'or in a special ability');
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
    } else if (!isSignedDiceBonus(v) && (typeof v !== 'number' || !Number.isFinite(v))) {
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

// "A P.B. of 12 or lower (they want average looking people)" - le Surete du
// Quebec Deep Intel Agent, Free Quebec printed 32. A CEILING on an attribute,
// which `attribute_requirements` cannot say: that block is minimums throughout,
// merged with `Math.max` and rendered `PB 12+`, so writing a cap there states
// the exact inverse of the book. BOOK-INGEST-AUDIT.md F32.
//
// NOT `bonuses.attribute_minimums`, whose name this one echoes and whose job it
// does not share. That is a floor applied AFTER the dice bonus lands; this
// gates nothing and adjusts nothing, it is what the book says the character
// may not exceed.
function validateAttributeMaximums(block, reqs, errors, warnings) {
  if (block === undefined || block === null) return;
  if (typeof block !== 'object' || Array.isArray(block)) {
    errors.push('attribute_maximums must be a map of attribute to number');
    return;
  }
  for (const [k, v] of Object.entries(block)) {
    if (!BONUS_ATTRS.includes(k)) {
      errors.push(`attribute_maximums.${k} is not an attribute (${BONUS_ATTRS.join(', ')})`);
      continue;
    }
    if (typeof v !== 'number' || !Number.isFinite(v)) {
      errors.push(`attribute_maximums.${k} must be a number`);
      continue;
    }
    // A cap below the floor for the same attribute admits nobody, and both
    // halves usually come off one printed line - "I.Q. 10 and M.A. 10 or
    // higher, and a P.B. of 12 or lower" - so a transposition puts them the
    // wrong way round rather than producing anything a reader would notice.
    const min = reqs && typeof reqs === 'object' ? reqs[k] : undefined;
    if (typeof min === 'number' && Number.isFinite(min) && v < min) {
      errors.push(`attribute_maximums.${k} is ${v} but attribute_requirements.${k} is ${min}`
        + ' - no character can satisfy both');
    }
  }
  if (!Object.keys(block).length) {
    warnings.push('attribute_maximums is empty and will do nothing');
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

// ─── a second body ───
//
// A class whose character has TWO physical forms and changes between them in
// play: the Nightbane's Facade and Morphus (printed 87), and anything later that
// prints the same shape. BOOK-INGEST-AUDIT F74 recorded the gap; Nightbane survey
// D5 built it, on Nate's word that the sheet TOGGLES between the forms and
// tracks each form's damage separately.
//
// NOT `variants`, and F74's closure says why at length: a variant is a KIND of
// the class picked once at creation, and these are two STATES of one character.
// So the class's own block is the FIRST form, unchanged, and this block states
// only how the second one differs from it:
//
//   second_form:
//     name: "Morphus"                     the second form, as the sheet labels it
//     first_name: "Facade"                what the class's own block is called
//     bonuses:                            a class `bonuses` block, applying ONLY in
//       attributes: { PS: 10, PE: 10 }    the second form, ON TOP of the first
//       pools: { sdc: "2d6x10" }          form's. `pools` takes sdc and hp only -
//       combat: { strike: 2 }             P.P.E. and I.S.P. are the first form's -
//       saves: { psionics: 3 }            and dice are rolled ONCE and stored
//     hit_points_base: "P.E. x2 + 2d6 per level"
//                                         REPLACES the class's hit points for the
//                                         second form, read against ITS P.E.
//     horror_factor: 6                    the second form's projected Horror
//     horror_factor_max: 18               Factor, and the most results may raise it
//     traits_from: morphus                the catalog whose rows are the form's
//                                         generated traits
//
// `bonuses` rather than separate attribute and S.D.C. keys because a table
// result already IS a `bonuses` block (migration 068), so the form's own delta
// and every result it collects are one shape, folded by one function
// (js/second-form.js) and validated by one validator.
//
// ERRORS, not warnings, on a malformed block - the posture `bonuses` has.
// class-store.js drops a class that fails to parse, but a block no published
// class carries yet cannot make a live class vanish, and a second body that
// parses with half its numbers ignored is the silent storage class-import
// forbids. class-check shows the error before anything is published.
//
// The catalogs a form's traits may come from. A literal list here rather than
// read from js/catalog-fields.js, which imports this file. Exported for the
// wizard's lazy fetch of a form's tables (functions/.../catalogs/traits.js),
// which serves exactly these catalogs and no other.
export const SECOND_FORM_TRAIT_CATALOGS = ['morphus'];
// The pools a second form may add to. Hit points and S.D.C. are the body's; the
// book's Morphus keeps the Facade's P.P.E. (printed 87).
export const SECOND_FORM_POOLS = ['sdc', 'hp'];
const SECOND_FORM_KEYS = ['name', 'first_name', 'bonuses', 'hit_points_base', 'horror_factor',
  'horror_factor_max', 'traits_from'];

function validateSecondForm(sf, errors, warnings) {
  if (!sf || typeof sf !== 'object' || Array.isArray(sf)) {
    errors.push('second_form must be a map (' + SECOND_FORM_KEYS.join(', ') + ')');
    return;
  }
  for (const k of ['name', 'first_name']) {
    if (typeof sf[k] !== 'string' || !sf[k].trim()) {
      errors.push(`second_form.${k} is required - it is what the sheet's form toggle says`);
    }
  }
  if (sf.bonuses !== undefined) {
    // Through the SAME validator a class's bonuses go through, with its
    // messages re-rooted so an error names the block it came from.
    const e = [], w = [];
    validateBonuses(sf.bonuses, e, w);
    errors.push(...e.map((m) => 'second_form.' + m));
    warnings.push(...w.map((m) => 'second_form.' + m));
    if (sf.bonuses && typeof sf.bonuses === 'object' && !Array.isArray(sf.bonuses)) {
      const pools = sf.bonuses.pools;
      for (const k of Object.keys(pools && typeof pools === 'object' ? pools : {})) {
        if (POOL_BONUS_KEYS.includes(k) && !SECOND_FORM_POOLS.includes(k)) {
          errors.push(`second_form.bonuses.pools.${k} is not a second form's pool - only `
            + `${SECOND_FORM_POOLS.join(' and ')} differ between forms`);
        }
      }
      // A level-gated form bonus has no moment to be rolled at: the form's dice
      // are rolled once, when the form is made. Refused rather than ignored.
      if (sf.bonuses.at_level !== undefined) {
        errors.push('second_form.bonuses.at_level is not supported - a second form\'s bonuses '
          + 'apply from level 1; state a level-gated one in the class\'s own bonuses');
      }
    }
  }
  if (sf.hit_points_base !== undefined) {
    const probe = { IQ: 10, ME: 10, MA: 10, PS: 10, PP: 10, PE: 10, PB: 10, Spd: 10 };
    if (poolFormulaBounds(sf.hit_points_base, probe) == null) {
      errors.push(`second_form.hit_points_base "${sf.hit_points_base}" is not a formula the pools `
        + 'read - a number, dice, or an attribute plus dice ("P.E. x2 + 2d6 per level")');
    }
  }
  const isCount = (v) => Number.isInteger(v) && v >= 0;
  if (sf.horror_factor !== undefined && !isCount(sf.horror_factor)) {
    errors.push('second_form.horror_factor must be a whole number - the second form\'s BASE, '
      + 'which table results add to');
  }
  if (sf.horror_factor_max !== undefined) {
    if (!isCount(sf.horror_factor_max)) {
      errors.push('second_form.horror_factor_max must be a whole number');
    } else if (isCount(sf.horror_factor) && sf.horror_factor_max < sf.horror_factor) {
      errors.push(`second_form.horror_factor_max is ${sf.horror_factor_max}, below its base of `
        + `${sf.horror_factor}`);
    }
  }
  if (sf.traits_from !== undefined && !SECOND_FORM_TRAIT_CATALOGS.includes(sf.traits_from)) {
    errors.push('second_form.traits_from must name a catalog a form\'s traits come from '
      + `(${SECOND_FORM_TRAIT_CATALOGS.join(', ')}), got: ${sf.traits_from}`);
  }
  for (const k of Object.keys(sf)) {
    if (!SECOND_FORM_KEYS.includes(k)) {
      warnings.push(`second_form.${k} is not read (${SECOND_FORM_KEYS.join(', ')}) and will be ignored`);
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

// ---------- shared ability lists ---------- moved to js/abilities.js: re-exported at the top of this file.

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

// ---------- where a message points ----------
//
// An error from this file names what is wrong by PATH - `skills.occ_skills
// "Boxing" ...`, `bonuses.at_level[3].saves ...`, `variant "adult" ...` - and
// never said where that is. On a 200-line class the author searched for it.
//
// This reads the path back off the front of a message and finds the line it
// names, as deep as the frontmatter spells it out in block style: a key
// written inline (`bonuses: { combat: { ... } }`) is on its parent's line, so
// the answer stops there, which is still the right line to open.
//
// DERIVED FROM THE MESSAGE, not carried by the validators. Eighteen of them
// push some 240 messages through half a dozen different signatures, and
// threading a position through each would touch every one to say what the
// message already says. The cost of doing it this way is that a message which
// does not begin with a path has no line: `Missing required field: name`
// cannot point at a key that is not there, and gets null. smoke holds one
// class broken on known lines to those lines, and every message a shipped
// class produces that opens with one of its own keys to resolving.
//
// Takes the whole class markdown and answers in ITS line numbers (the opening
// `---` is line 1), since that is the file the author has open.
export function locateMessage(message, markdown) {
  const all = String(markdown ?? '').split(/\r?\n/);
  if (all[0]?.trim() !== '---') return null;
  const close = all.findIndex((l, i) => i > 0 && l.trim() === '---');
  if (close < 0) return null;
  const lines = all.slice(1, close);          // lines[i] is file line i + 2
  const text = String(message ?? '');

  let path;
  let variantId = null;
  const variant = text.match(/^variant "([^"]+)"/);
  if (variant) {
    path = ['variants'];
    variantId = variant[1];
  } else {
    const head = text.match(/^[a-z_][a-z0-9_]*(?:\.[A-Za-z_][A-Za-z0-9_]*|\[[^\]]*\])*/);
    if (!head) return null;
    path = head[0].replace(/\[[^\]]*\]/g, '').split('.');
  }

  const indentOf = (l) => l.length - l.trimStart().length;
  const skippable = (l) => l.trim() === '' || l.trimStart().startsWith('#');
  // The block under the key on line `at`: every following line indented
  // deeper than it, blank lines and comments included.
  const blockEnd = (at, limit) => {
    const own = indentOf(lines[at]);
    let e = at + 1;
    while (e < limit && (skippable(lines[e]) || indentOf(lines[e]) > own)) e++;
    return e;
  };
  const keyLine = (key) => new RegExp('^\\s*(?:-\\s+)?["\']?' + key + '["\']?\\s*:');

  let at = lines.findIndex((l) => indentOf(l) === 0 && keyLine(path[0]).test(l));
  if (at < 0) return null;
  let end = blockEnd(at, lines.length);
  let depth = 1;
  for (; depth < path.length; depth++) {
    const re = keyLine(path[depth]);
    let found = -1;
    for (let i = at + 1; i < end; i++) if (re.test(lines[i])) { found = i; break; }
    if (found < 0) break;
    at = found;
    end = blockEnd(at, end);
  }
  if (variantId) {
    const re = new RegExp('\\bid\\s*:\\s*["\']?' + variantId.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + '["\']?(?:\\s|,|}|$)');
    for (let i = at; i < end; i++) if (re.test(lines[i])) { at = i; break; }
  } else {
    // `skills.occ_skills "Boxing" has no ...`, `skills.mos["Military"] ...`:
    // the entry is named right where the path ends, so its own line is
    // better than the list's. Only if the path was followed all the way -
    // a name found under some OTHER key would point at the wrong thing.
    const named = text.match(/^[a-z_][\w.]*(?:\["([^"\]]+)"\])?(?: "([^"]+)")?/);
    const name = named?.[2] ?? named?.[1] ?? null;
    if (name && depth === path.length) {
      for (let i = at + 1; i < end; i++) if (lines[i].includes(name)) { at = i; break; }
    }
  }
  return { key: path.slice(0, depth).join('.'), line: at + 2 };
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

// ── class tags ── moved to js/class-tags.js: re-exported at the top of this file.

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
  if (data.tags !== undefined) validateTags(data.tags, errors, warnings, data);
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
  // F111. Which of the race-first keys this occupation takes over in a pairing.
  // Opt-in and closed: only OVERRIDES_RACE_KEYS, because the body keys belong
  // to the race and a whole-body replacement is supersedes_race's job.
  if (data.overrides_race !== undefined) {
    const list = data.overrides_race;
    if (!Array.isArray(list) || list.length === 0) {
      errors.push(`overrides_race must be a non-empty list of ${OVERRIDES_RACE_KEYS.join(' | ')}`);
    } else {
      for (const k of list) {
        if (!OVERRIDES_RACE_KEYS.includes(k)) {
          errors.push(`overrides_race may name only ${OVERRIDES_RACE_KEYS.join(' | ')}, got: ${k}`);
        } else if (data[k] == null) {
          warnings.push(`overrides_race names ${k}, which this class does not state, so it takes nothing`);
        }
      }
      if (new Set(list).size !== list.length) errors.push('overrides_race names a key twice');
    }
    if (data.category !== 'occ') {
      warnings.push('overrides_race is set on something that is not an O.C.C. and will do nothing');
    } else if (data.supersedes_race === true) {
      warnings.push('overrides_race is redundant beside supersedes_race, which already takes every pool');
    } else if (!Array.isArray(data.race_restrictions?.only)) {
      // The census that declined F111's global rule is the reason: an O.C.C.
      // open to every race moves every race's figure, including the ones whose
      // book ADDS its P.P.E. to a mage's or prints its own.
      warnings.push('overrides_race is not limited by race_restrictions.only, so it replaces'
        + ' the figure of EVERY race this class can be taken with - check the races whose'
        + ' own book adds to it or prints its own (BOOK-INGEST-AUDIT F111)');
    }
  }
  // F111, the race's side. Which of the same two keys this race gives up, and to
  // which occupation groups. Closed on both levels: only OVERRIDES_RACE_KEYS,
  // only OCC_GROUPS, because a group name matching nothing would yield to no
  // one and say nothing.
  if (data.yields_to_occupation !== undefined) {
    const y = data.yields_to_occupation;
    if (!y || typeof y !== 'object' || Array.isArray(y) || Object.keys(y).length === 0) {
      errors.push(`yields_to_occupation must be a non-empty map of ${OVERRIDES_RACE_KEYS.join(' | ')}`
        + ' to a list of occupation groups');
    } else {
      for (const [k, groups] of Object.entries(y)) {
        if (!OVERRIDES_RACE_KEYS.includes(k)) {
          errors.push(`yields_to_occupation may name only ${OVERRIDES_RACE_KEYS.join(' | ')}, got: ${k}`);
          continue;
        }
        if (!Array.isArray(groups) || groups.length === 0) {
          errors.push(`yields_to_occupation.${k} must be a non-empty list of ${OCC_GROUPS.join(' | ')}`);
          continue;
        }
        for (const g of groups) {
          if (!OCC_GROUPS.includes(g)) {
            errors.push(`yields_to_occupation.${k} names ${g}, which is not one of ${OCC_GROUPS.join(' | ')}`);
          }
        }
        if (new Set(groups).size !== groups.length) errors.push(`yields_to_occupation.${k} names a group twice`);
        if (data[k] == null) {
          warnings.push(`yields_to_occupation names ${k}, which this race does not state, so there is nothing to yield`);
        }
      }
    }
    // An error, not overrides_race's warning: on an occupation it reads as the
    // occupation declaring what IT yields, which is the opposite of what it does.
    if (data.category !== 'rcc') {
      errors.push('yields_to_occupation belongs on an R.C.C.; an occupation that takes a race\'s'
        + ' figure says so with overrides_race');
    }
  }
  // F122. A race whose own book says it levels on its own table even when it
  // takes an occupation's powers. A flag, true or absent, on an R.C.C.
  if (data.keeps_xp_table !== undefined) {
    if (data.keeps_xp_table !== true) {
      errors.push('keeps_xp_table is a flag and may only be true; omit it otherwise');
    } else if (data.category !== 'rcc') {
      errors.push('keeps_xp_table belongs on an R.C.C.; an occupation\'s ladder already wins a pairing');
    } else if (!Array.isArray(data.xp_table)) {
      warnings.push('keeps_xp_table is set on a race that states no xp_table, so there is no ladder to keep');
    }
  }
  // F114. The race's named skills that survive a pairing, where its book keeps
  // only a few. Closed on the race's own list: a name it does not hold would
  // keep nothing and say nothing, which is the silent shape this refuses.
  if (data.pairing_skills !== undefined) {
    const list = data.pairing_skills;
    if (!Array.isArray(list) || list.length === 0) {
      errors.push('pairing_skills must be a non-empty list of { name, base?, note? }');
    } else {
      const own = new Set((data.skills?.occ_skills || [])
        .filter((e) => e?.name).map((e) => String(e.name).toLowerCase()));
      const seen = new Set();
      for (const p of list) {
        if (!p || typeof p !== 'object' || Array.isArray(p) || typeof p.name !== 'string' || !p.name.trim()) {
          errors.push('pairing_skills entries must each be a map with a name');
          continue;
        }
        const extra = Object.keys(p).filter((k) => !['name', 'base', 'note'].includes(k));
        if (extra.length) errors.push(`pairing_skills.${p.name} may carry only name, base and note, got: ${extra.join(', ')}`);
        if (p.base !== undefined && typeof p.base !== 'number') errors.push(`pairing_skills.${p.name} base must be a number`);
        if (p.note !== undefined && typeof p.note !== 'string') errors.push(`pairing_skills.${p.name} note must be text`);
        const key = p.name.toLowerCase();
        if (!own.has(key)) errors.push(`pairing_skills names ${p.name}, which is not one of this race's named occ_skills`);
        if (seen.has(key)) errors.push(`pairing_skills names ${p.name} twice`);
        seen.add(key);
      }
    }
    if (data.category !== 'rcc') {
      errors.push('pairing_skills belongs on an R.C.C.; it says which of a race\'s skills an occupation leaves standing');
    }
  }
  // F129. What a race takes off a paired occupation's related and secondary
  // counts. Each entry names one or both lists, each list a factor or a cap,
  // and an entry without `occupations` reaches every occupation. Closed on
  // every level, because a misspelt list or rule would trim nothing and say
  // nothing.
  if (data.pairing_counts !== undefined) {
    const list = data.pairing_counts;
    const shape = '{ related?: { factor | cap }, secondary?: { factor | cap }, occupations?: [<occupation id>] }';
    if (!Array.isArray(list) || list.length === 0) {
      errors.push(`pairing_counts must be a non-empty list of ${shape}`);
    } else {
      list.forEach((entry, i) => {
        const at = `pairing_counts[${i}]`;
        if (!entry || typeof entry !== 'object' || Array.isArray(entry)) {
          errors.push(`${at} must be a map: ${shape}`);
          return;
        }
        const lists = Object.keys(entry).filter((k) => k !== 'occupations');
        const unknown = lists.filter((k) => !(k in PAIRING_COUNT_LISTS));
        if (unknown.length) {
          errors.push(`${at} names ${unknown.join(', ')}, which is not a list it can trim (related, secondary)`);
        }
        if (!lists.some((k) => k in PAIRING_COUNT_LISTS)) errors.push(`${at} must name related, secondary or both`);
        for (const k of lists.filter((x) => x in PAIRING_COUNT_LISTS)) {
          const rule = entry[k];
          if (!rule || typeof rule !== 'object' || Array.isArray(rule)) {
            errors.push(`${at}.${k} must be a map with a factor or a cap`);
            continue;
          }
          const extra = Object.keys(rule).filter((x) => x !== 'factor' && x !== 'cap');
          if (extra.length) errors.push(`${at}.${k} may carry only factor or cap, got: ${extra.join(', ')}`);
          const hasFactor = rule.factor !== undefined;
          const hasCap = rule.cap !== undefined;
          if (hasFactor && hasCap) errors.push(`${at}.${k} states both a factor and a cap; it takes one`);
          else if (!hasFactor && !hasCap) errors.push(`${at}.${k} needs a factor or a cap`);
          if (hasFactor && !(typeof rule.factor === 'number' && rule.factor >= 0 && rule.factor <= 1)) {
            errors.push(`${at}.${k}.factor must be a number from 0 to 1; this key only takes picks away`);
          }
          if (hasCap && !(Number.isInteger(rule.cap) && rule.cap >= 0)) {
            errors.push(`${at}.${k}.cap must be a whole number, zero or more`);
          }
        }
        if (entry.occupations !== undefined) {
          const occs = entry.occupations;
          if (!Array.isArray(occs) || occs.length === 0 || occs.some((o) => typeof o !== 'string' || !o.trim())) {
            errors.push(`${at}.occupations must be a non-empty list of occupation ids; omit it to reach every occupation`);
          } else if (new Set(occs).size !== occs.length) {
            errors.push(`${at}.occupations names an occupation twice`);
          }
        }
      });
    }
    if (data.category !== 'rcc') {
      errors.push('pairing_counts belongs on an R.C.C.; it says how many related and secondary picks'
        + ' a race takes from the occupation it pairs with');
    }
  }
  // A class whose own attacks stand and whose Hand to Hand style adds none
  // (bonusesFromSkills). Opt-in, from a book that says so or states a whole
  // attack schedule of its own; without one to stand in, it would leave the
  // character at the default two.
  if (data.ignores_style_attacks !== undefined) {
    if (data.ignores_style_attacks !== true) {
      errors.push('ignores_style_attacks is a flag and may only be true; omit it otherwise');
    } else if (typeof data.bonuses?.combat?.attacks_base !== 'number') {
      errors.push('ignores_style_attacks needs bonuses.combat.attacks_base - the attacks that stand instead of the style\'s');
    }
  }
  // F62. A mega-damage creature whose S.D.C. and hit points ARE its M.D.C. -
  // the Totem Warrior's supernatural P.E. Opt-in, and only for a PERMANENT
  // conversion; a temporary one (the Psycho-Stalker's) is an ability.
  if (data.mdc_from_hp_sdc !== undefined) {
    if (data.mdc_from_hp_sdc !== true) {
      errors.push('mdc_from_hp_sdc is a flag and may only be true; omit it otherwise');
    } else if (data.mdc_base != null) {
      warnings.push('mdc_from_hp_sdc is set beside an mdc_base, which wins; the flag does nothing');
    }
  }
  // A Horror Factor the character PROJECTS - BOOK-INGEST-AUDIT F75. NOT the
  // save of the same name, which lives at `bonuses.saves.horror_factor` and is
  // a bonus to resist someone ELSE's. Two numbers, two meanings, and nothing
  // here connects them.
  //
  // A STRING OR A NUMBER, exactly as the pool bases are, because the live data
  // is overwhelmingly not a scalar: `10+1D4`, `none if pretending to be human`,
  // `8 on foot and 15 on a flying mount`, `10, but only when in sand form`,
  // `NONE, stated outright`. A number-only field would have served almost none
  // of the 27 classes that print one - including the Nightbane this was filed
  // for, whose value is "base 6 in the Morphus, none in the human form".
  //
  // DISPLAY ONLY. Nothing rolls it and nothing rolls against it, which is the
  // posture F75 asks for; `9+1D4` is printed as written rather than resolved,
  // the way a pool base's formula is shown before it is rolled.
  //
  // A WARNING AND NEVER AN ERROR. `class-store.js` DROPS a class that fails to
  // parse out of GET /classes rather than 4xx-ing, so an error on a new
  // display-only field would make a class vanish from every picker AND from its
  // own saved characters - see the note on the psionic category calls below.
  if (data.horror_factor !== undefined) {
    const hf = data.horror_factor;
    const ok = (typeof hf === 'number' && Number.isFinite(hf))
      || (typeof hf === 'string' && hf.trim() !== '');
    if (!ok) {
      warnings.push('horror_factor should be a number or the phrase the book prints, '
        + 'and this one is neither; it will be shown as given');
    }
  }
  // A SECOND BODY - BOOK-INGEST-AUDIT F74, built by Nightbane survey D5. See
  // validateSecondForm for the shape and why it is not `variants`.
  if (data.second_form !== undefined) validateSecondForm(data.second_form, errors, warnings);
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
    // AND THE TWO KEYS THAT WIN OVER IT. BOOK-INGEST-AUDIT.md F91, the same
    // hole F88 closed one key over. `categories_allowed` is the FALLBACK:
    // `psionicCategoriesForGrant` (js/leveling.js:617-627) returns a schedule
    // entry's own `categories` in preference to it, and `startingGroups`
    // (js/leveling.js:487-488) does the same for a starting group - so the
    // branch that WINS was the branch nothing checked.
    //
    // Both reach `categoryAllows`, and the schedule key reaches it in three
    // places rather than one: the wizard's level-up picker (app.js:2047 into
    // :2092), the sheet's own re-implementation (sheet.js:2558 into :2486,
    // which cannot import the reader), and the SERVER, which ENFORCES it -
    // functions/api/character-creator/_lib/power-picks.js:191 rejects a pick
    // outside the grant's categories. A starting group's key reaches one
    // picker, app.js:3698. All four read 2026-09-15.
    //
    // ERRORS rather than warnings, matching the four existing callers - the
    // posture F91 asks for in those words. Safe because its pre-run was
    // re-measured rather than trusted: validateCategories over every entry of
    // both keys, on every psionics block of all 318 published live classes
    // (--remote, 2026-09-15), is 446 + 41 category entries and ZERO errors.
    // The harness was proved on an injected offender before the clean run was
    // believed. Nothing starts failing the day this ships, which matters here
    // because class-store.js DROPS a class that fails to parse rather than
    // 4xx-ing, so an error makes a class vanish from every picker AND from its
    // own saved characters.
    for (const [key, list] of [['powers_schedule', block.powers_schedule],
                               ['powers_starting_groups', block.powers_starting_groups]]) {
      if (!Array.isArray(list)) continue;
      for (const entry of list) {
        if (!entry || typeof entry !== 'object') continue;
        validateCategories(`${where}.${key}.categories`, entry.categories, errors);
        // F92: and the bonus refusal `categories_allowed` has always carried.
        // It sits inside the psionicBlocks walk deliberately - that fold covers
        // a class's own psionics AND any an ability grants, so these are FOUR
        // surfaces rather than the two F92's table names. A patch written
        // against `data.psionics` alone would have left the ability-granted
        // pair open, which is the half F91's own sweep found live.
        refusePsionicBonus(`${where}.${key}.categories`, entry.categories, errors);
      }
    }
    refusePsionicBonus(`${where}.categories_allowed`, block.categories_allowed, errors);
  }
  // SUPER ABILITIES - the fifth power kind, and the third block of the family
  // `magic` and `psionics` already form. A Heroes Unlimited super ability is a
  // permanent trait with a range, a duration and a damage, NO cost and NO level
  // (which is why it needed its own table rather than a spell row), so the gate
  // on a pick is the TIER and nothing else.
  //
  // The block is named for the catalog table it draws from, which puts it three
  // characters from `special_abilities` - a different key entirely, holding the
  // class's OWN prose abilities and granting nothing from any catalog. The
  // collision is unfortunate and the alternative was worse: naming the block for
  // what it grants would have left the catalog and the frontmatter disagreeing
  // about what the thing is called.
  //
  // These keys pair name for name with STARTING_SPEC.super in js/leveling.js.
  // Anything added here has to be added there too, or it parses, stores and is
  // never read - the exact shape `from_list` failed in for eleven months.
  for (const [where, block] of superAbilityBlocks(data)) {
    if (typeof block !== 'object' || Array.isArray(block)) {
      errors.push(`${where} must be a map`);
      continue;
    }
    if (block.abilities_starting !== undefined
        && (!Number.isInteger(block.abilities_starting) || block.abilities_starting < 0)) {
      errors.push(`${where}.abilities_starting must be a whole number of picks, zero or more`);
    }
    // REFUSED, NOT IGNORED. A per-level grant would have to be banked, and
    // `pending_power_picks` has columns for a spell level, a tradition, a
    // category and a name list - none for a TIER - so a banked super-ability
    // grant would come back ungated and spend against all 364 rows. See the note
    // where superAbilityGrantsFor would have been, in js/leveling.js. Nothing in
    // either Heroes Unlimited book asks for this: the core grants every super
    // ability at creation.
    for (const k of ['abilities_per_level', 'abilities_schedule']) {
      if (block[k] !== undefined) {
        errors.push(`${where}.${k} is not supported - a super ability is granted at `
          + 'creation, and there is nowhere to bank a per-level grant of one');
      }
    }
    // A CLOSED set of two, unlike a skill or psionic category. Those are open
    // vocabularies where an unknown name is a catalog gap worth reporting
    // softly; there are exactly two tiers and there always will be, so a typo
    // is a rule nothing can satisfy and the picker would come back empty.
    for (const t of block.tiers_allowed || []) {
      if (!SUPER_ABILITY_TIERS.includes(t)) {
        errors.push(`${where}.tiers_allowed must be ${SUPER_ABILITY_TIERS.join(' or ')}, got: ${t}`);
      }
    }
    if (block.tiers_allowed !== undefined
        && (!Array.isArray(block.tiers_allowed) || !block.tiers_allowed.length)) {
      errors.push(`${where}.tiers_allowed must be a non-empty list; omit it to allow both tiers`);
    }
    for (const k of ['abilities', 'abilities_from']) {
      if (block[k] !== undefined
          && (!Array.isArray(block[k]) || block[k].some((n) => typeof n !== 'string'))) {
        errors.push(`${where}.${k} must be a list of super ability names`);
      }
    }
    for (const g of block.abilities_starting_groups || []) {
      if (!g || typeof g !== 'object' || !Number.isInteger(g.count) || g.count < 1) {
        errors.push(`${where}.abilities_starting_groups entries need a whole count above zero`);
        continue;
      }
      for (const t of g.tiers || []) {
        if (!SUPER_ABILITY_TIERS.includes(t)) {
          errors.push(`${where}.abilities_starting_groups tiers must be `
            + `${SUPER_ABILITY_TIERS.join(' or ')}, got: ${t}`);
        }
      }
    }
    // A block that grants nothing is the silent-storage shape this file exists
    // to catch: it parses, it stores, the sheet grows a heading, and the player
    // is offered nothing. Stated zero is fine and means none, as it does for
    // the five dragon hatchlings that state `spells_starting: 0`.
    const grantsSomething = block.abilities_starting !== undefined
      || (block.abilities_starting_groups || []).length
      || (block.abilities || []).length;
    if (!grantsSomething) {
      warnings.push(`${where} grants no super abilities - state abilities_starting, `
        + 'abilities, or a group, or drop the block');
    }
  }

  // Nightbane Talents. These keys pair name for name with STARTING_SPEC.talent
  // in js/leveling.js; anything added here has to be added there too, or it
  // parses, stores and is never read.
  //
  // UNLIKE super abilities, A PER-LEVEL GRANT IS SUPPORTED, and the difference
  // is storage rather than taste. A banked super-ability grant needs a TIER
  // column `pending_power_picks` does not have. A banked TALENT grant needs
  // nothing: the book's free Talents arrive unrestricted - "one additional free
  // ability at levels four, seven, ten and twelve", printed 106 - and what
  // limits the pick is the ROW's own `min_character_level` and `prerequisite`,
  // evaluated when it is spent. Migration 064 widened the `kind` CHECK and
  // added no column, which is exactly why this is allowed and that is not.
  for (const [where, block] of talentBlocks(data)) {
    if (typeof block !== 'object' || Array.isArray(block)) {
      errors.push(`${where} must be a map`);
      continue;
    }
    // `talents_purchases_per_level` is how many Talents the character may BUY at
    // level one and at every level after - two, printed 106 - each paid for out
    // of the P.P.E. base (BOOK-INGEST-AUDIT F101). Read by talentPurchaseGrantsFor.
    for (const k of ['talents_starting', 'talents_per_level', 'talents_purchases_per_level']) {
      if (block[k] !== undefined && (!Number.isInteger(block[k]) || block[k] < 0)) {
        errors.push(`${where}.${k} must be a whole number of picks, zero or more`);
      }
    }
    // A CLOSED set of two, for the reason tiers_allowed is closed on a super
    // ability block: there are exactly two tiers, so a typo is a rule nothing
    // can satisfy and the picker comes back empty rather than wrong.
    for (const t of block.tiers_allowed || []) {
      if (!TALENT_TIERS.includes(t)) {
        errors.push(`${where}.tiers_allowed must be ${TALENT_TIERS.join(' or ')}, got: ${t}`);
      }
    }
    if (block.tiers_allowed !== undefined
        && (!Array.isArray(block.tiers_allowed) || !block.tiers_allowed.length)) {
      errors.push(`${where}.tiers_allowed must be a non-empty list; omit it to allow both tiers`);
    }
    for (const k of ['talents', 'talents_from']) {
      if (block[k] !== undefined
          && (!Array.isArray(block[k]) || block[k].some((n) => typeof n !== 'string'))) {
        errors.push(`${where}.${k} must be a list of talent names`);
      }
    }
    for (const g of block.talents_starting_groups || []) {
      if (!g || typeof g !== 'object' || !Number.isInteger(g.count) || g.count < 1) {
        errors.push(`${where}.talents_starting_groups entries need a whole count above zero`);
        continue;
      }
      for (const t of g.tiers || []) {
        if (!TALENT_TIERS.includes(t)) {
          errors.push(`${where}.talents_starting_groups tiers must be `
            + `${TALENT_TIERS.join(' or ')}, got: ${t}`);
        }
      }
    }
    if (block.talents_schedule !== undefined && !Array.isArray(block.talents_schedule)) {
      errors.push(`${where}.talents_schedule must be a list of { level, count } entries`);
    }
    for (const e of Array.isArray(block.talents_schedule) ? block.talents_schedule : []) {
      if (!e || typeof e !== 'object' || !Number.isInteger(e.level) || e.level < 1) {
        errors.push(`${where}.talents_schedule entries need a whole level of 1 or more`);
        continue;
      }
      if (e.count !== undefined && (!Number.isInteger(e.count) || e.count < 1)) {
        errors.push(`${where}.talents_schedule entries need a whole count above zero`);
      }
    }
    // A block that grants nothing is the silent-storage shape: it parses, it
    // stores, the sheet grows a heading and the player is offered nothing.
    const grantsSomething = block.talents_starting !== undefined
      || block.talents_per_level !== undefined
      || block.talents_purchases_per_level !== undefined
      || (block.talents_starting_groups || []).length
      || (block.talents_schedule || []).length
      || (block.talents || []).length;
    if (!grantsSomething) {
      warnings.push(`${where} grants no talents - state talents_starting, talents, `
        + 'a schedule, or a group, or drop the block');
    }
  }

  if (data.race_restrictions !== undefined && data.category !== 'occ') {
    warnings.push('race_restrictions is set on something that is not an O.C.C. and will do nothing');
  }
  validateRaceRestrictions(data.race_restrictions, errors);
  validateTotem(data.totem, errors, warnings);

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

    // SKILL PROGRAMS: choose N CATEGORIES, take everything each one allows, at
    // one fixed percentage. BOOK-INGEST-AUDIT.md F23(b).
    //
    // Not `occ_related_skills` with a large count. That picks SKILLS from a
    // list of categories; this picks CATEGORIES and grants their whole
    // contents, so a count large enough to cover them would also let the player
    // spend it inside a category the book never granted.
    //
    // `base` is a FIXED percentage rather than a bonus, and `per_level` is
    // normally 0 - the Triax robot soldier's programs sit at a flat 38% with
    // "no bonuses or improvement with experience" (printed 170). A skill with
    // `per_level: 0` simply never advances; js/leveling.js skips it.
    const programs = data.skills.skill_programs;
    if (programs) {
      if (!Number.isInteger(programs.choose) || programs.choose < 1) {
        errors.push('skills.skill_programs.choose must be a whole number above zero');
      }
      if (!Number.isFinite(programs.base)) {
        errors.push('skills.skill_programs.base must be a number - the fixed percentage '
          + 'every skill in a chosen program is granted at');
      }
      if (programs.per_level !== undefined && !Number.isFinite(programs.per_level)) {
        errors.push('skills.skill_programs.per_level must be a number');
      }
      validateCategories('skills.skill_programs.categories', programs.categories, errors);
      if (!Array.isArray(programs.categories) || !programs.categories.length) {
        errors.push('skills.skill_programs.categories must list the categories '
          + 'that can be chosen as programs');
      } else if (Number.isInteger(programs.choose)
                 && programs.choose > programs.categories.length) {
        // Offering three picks from two categories is a transcription error
        // every time, and it fails as a silently short list rather than as
        // anything a player would notice.
        errors.push(`skills.skill_programs.choose is ${programs.choose} but only `
          + `${programs.categories.length} categories are offered`);
      }
      // A category BONUS makes no sense against a fixed base: the whole point
      // of a program is one flat percentage, so a per-category adjustment would
      // be stored and never read. Same reasoning as the psionic case above.
      for (const c of programs.categories || []) {
        if (c && typeof c === 'object' && c.bonus !== undefined) {
          errors.push(`skills.skill_programs.categories.${c.name} sets a bonus; `
            + 'a program grants one fixed percentage and nothing reads it');
        }
      }
    }
    // What the class charges to change or buy a Hand to Hand style
    // (js/hand-to-hand.js). The keys are checked for SHAPE, not against a list
    // of styles: a book may print one the catalog gains later, and a key that
    // names no style is simply never asked for. What is refused is what would
    // be read WRONG - a quoted key keeps its quotes through this parser and
    // would match nothing, so every style would silently read "not offered".
    const h2h = data.skills.hand_to_hand;
    if (h2h !== undefined) {
      if (!h2h || typeof h2h !== 'object' || Array.isArray(h2h)) {
        errors.push('skills.hand_to_hand must be a block: { costs: { expert: 1, ... } }');
      } else {
        const known = new Set(['costs', 'conditions', 'creation_only']);
        for (const k of Object.keys(h2h)) {
          if (!known.has(k)) errors.push(`skills.hand_to_hand.${k} is not a key anything reads`);
        }
        if (!h2h.costs || typeof h2h.costs !== 'object' || Array.isArray(h2h.costs)) {
          errors.push('skills.hand_to_hand.costs must be a map of style to picks - {} when nothing is offered');
        }
        for (const group of ['costs', 'conditions']) {
          for (const [k, v] of Object.entries((h2h[group] && typeof h2h[group] === 'object') ? h2h[group] : {})) {
            if (!/^[a-z0-9_]+$/.test(k)) {
              errors.push(`skills.hand_to_hand.${group}.${k} must be a bare lower-case style key `
                + '(martial_arts, not "Hand to Hand: Martial Arts") - a quoted key keeps its quotes');
            }
            if (group === 'costs' && !(Number.isInteger(v) && v >= 0)) {
              errors.push(`skills.hand_to_hand.costs.${k} must be a whole number of picks, 0 or more`);
            }
            if (group === 'conditions' && (typeof v !== 'string' || !v.trim())) {
              errors.push(`skills.hand_to_hand.conditions.${k} must be the book's condition, in words`);
            }
          }
        }
        for (const k of Object.keys((h2h.conditions && typeof h2h.conditions === 'object') ? h2h.conditions : {})) {
          if (h2h.costs && typeof h2h.costs === 'object' && !(k in h2h.costs)) {
            errors.push(`skills.hand_to_hand.conditions.${k} is a condition on a style the class does not price`);
          }
        }
        if (h2h.creation_only !== undefined && typeof h2h.creation_only !== 'boolean') {
          errors.push('skills.hand_to_hand.creation_only must be true or false');
        }
      }
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

  // A book's CEILING on an attribute (F32). Validated here and not beside
  // `attribute_requirements`, which has no shape validator of its own - a gap
  // this finding found and did not widen: a new key with no checking at all is
  // how "the wrong key parses, validates and is confidently wrong" happens.
  validateAttributeMaximums(data.attribute_maximums, data.attribute_requirements,
    errors, warnings);

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
    // A pick made at set levels (F116): which levels, each giving `choose`
    // picks. Rising, distinct, whole and at least 1, and never beside `rolls`,
    // whose count is a table's and not a level's. An entry may instead be
    // `{ level, count }` (F127), a level that gives its own number of picks:
    // those two keys and no others, both whole and at least 1, so a misspelt
    // `cuont` is refused and not read as `choose`.
    if (e.at_levels !== undefined) {
      const l = e.at_levels;
      const isLevel = (n) => Number.isInteger(n) && n >= 1;
      const levelOf = (n) => (isLevel(n) ? n
        : n && typeof n === 'object' && !Array.isArray(n) && isLevel(n.level) && isLevel(n.count)
          && Object.keys(n).every((k) => k === 'level' || k === 'count') ? n.level : null);
      const lv = Array.isArray(l) ? l.map(levelOf) : [];
      if (!Array.isArray(l) || !l.length || lv.some((n) => n === null)) {
        errors.push('special_abilities: at_levels must be a non-empty list of whole-number levels of 1 or more, '
          + 'each a number or { level, count } with a whole count of 1 or more');
      } else if (lv.some((n, i) => i > 0 && n <= lv[i - 1])) {
        errors.push('special_abilities: at_levels must rise, each level once - '
          + `got [${lv.join(', ')}]`);
      }
      if (e.rolls !== undefined) {
        errors.push('special_abilities: a group states at_levels or rolls, not both');
      }
      if (e.choose === undefined) {
        errors.push('special_abilities: an at_levels group needs choose - the picks each of its levels gives');
      }
    }
    // A table rolled more than once (F120). `rolls` stands in for `choose`,
    // which is filled in here with the most the group can hold.
    if (e.rolls !== undefined) {
      const limit = abilityRollLimit(e.rolls);
      if (limit === null) {
        errors.push('special_abilities: rolls must be a whole number of 1 or more, or dice '
          + 'like "1d4" when the book rolls the count');
      } else if (!Array.isArray(e.from) || !bandsOf(e)) {
        errors.push('special_abilities: a rolls group needs options named for percentile bands '
          + 'that cover 01-00, like "Kind (01-50): A" - a table with a hole in it cannot be rolled');
      } else if (e.choose !== undefined && e.choose !== limit) {
        errors.push(`special_abilities: rolls ${JSON.stringify(e.rolls)} holds at most ${limit}, `
          + `but choose says ${e.choose}; state rolls alone`);
      } else if (e.from.some((o) => !(data.special_abilities || []).some((d) => isAbilityDefinition(d)
          && d.name.trim().toLowerCase() === String(typeof o === 'string' ? o : o?.name).trim().toLowerCase()))) {
        errors.push('special_abilities: every row of a rolls group needs its own definition - '
          + 'the server refuses a second take of a row only where the row is defined');
      } else {
        e.choose = limit;
        if (limit > new Set(e.from.map((o) => (typeof o === 'string' ? o : o?.name))).size) {
          warnings.push(`special_abilities: rolls ${JSON.stringify(e.rolls)} can ask for more results `
            + 'than the table has rows; it stops when every row is held');
        }
      }
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
    // A per-branch related-skill count (BOOK-INGEST-AUDIT.md F24). Zero is the
    // whole point of it - a master psionic Gifted gets none - so it is checked
    // as a non-negative INTEGER rather than a truthy number.
    if (e.related_skills_count !== undefined
        && (!Number.isInteger(e.related_skills_count) || e.related_skills_count < 0)) {
      errors.push(`special_abilities: ${e.name}.related_skills_count must be a `
        + 'non-negative integer');
    }
    // F117: an ability's level table, as display text. Every malformed entry is
    // an error - a line with no level would be shown at the wrong time, or not
    // at all, and nothing else would say so.
    if (e.progression !== undefined) {
      if (!Array.isArray(e.progression) || !e.progression.length) {
        errors.push(`special_abilities: ${e.name}.progression must be a non-empty list of { level, text }`);
      } else {
        const seenLevels = new Set();
        for (const l of e.progression) {
          if (!l || typeof l !== 'object' || !Number.isInteger(l.level) || l.level < 1
              || typeof l.text !== 'string' || !l.text.trim()) {
            errors.push(`special_abilities: ${e.name}.progression entries need a whole-number level `
              + 'of 1 or more and text');
            break;
          }
          if (seenLevels.has(l.level)) {
            errors.push(`special_abilities: ${e.name}.progression states level ${l.level} twice - `
              + 'put everything that level gives in one entry');
            break;
          }
          seenLevels.add(l.level);
        }
      }
    }
    // F120: the dice a table row prints for an attribute. The class's own
    // grammar - dice, a fixed number, or N/A - and only real attributes.
    if (e.attribute_dice !== undefined) {
      if (!e.attribute_dice || typeof e.attribute_dice !== 'object' || Array.isArray(e.attribute_dice)) {
        errors.push(`special_abilities: ${e.name}.attribute_dice must be a map of attribute to dice`);
      } else {
        for (const [attr, expr] of Object.entries(e.attribute_dice)) {
          if (!BONUS_ATTRS.includes(attr)) {
            errors.push(`special_abilities: ${e.name}.attribute_dice.${attr} is not an attribute `
              + `(${BONUS_ATTRS.join(', ')})`);
          } else if (!isAttributeExpr(expr)) {
            errors.push(`special_abilities: ${e.name}.attribute_dice.${attr} must be dice like "3d6", `
              + 'a fixed number, or N/A');
          }
        }
        if (!optionNames.has(e.name.trim().toLowerCase())) {
          warnings.push(`special_abilities: ${e.name} states attribute_dice but is not offered as a `
            + 'choice, so nothing applies it - put the dice on the class (or its variant)');
        }
      }
    }
    // F119: the projected Horror Factor a held option restates or adds to.
    // Warnings on a bad restatement, as on the class's own (a display-only key
    // must not make a class vanish); the bonus is arithmetic, so it is an error.
    if (e.horror_factor !== undefined && !isHorrorFactor(e.horror_factor)) {
      warnings.push(`special_abilities: ${e.name}.horror_factor should be a number or the phrase `
        + 'the book prints, and this one is neither; it is ignored');
    }
    if (e.horror_factor_bonus !== undefined
        && (!Number.isInteger(e.horror_factor_bonus) || e.horror_factor_bonus === 0)) {
      errors.push(`special_abilities: ${e.name}.horror_factor_bonus must be a whole number other `
        + 'than 0 - what the option adds to the Horror Factor the character projects');
    }
    if ((e.horror_factor !== undefined || e.horror_factor_bonus !== undefined)
        && !optionNames.has(e.name.trim().toLowerCase())) {
      warnings.push(`special_abilities: ${e.name} states a Horror Factor but is not offered as a `
        + 'choice, so nothing applies it - put it on the class (or its variant) if every '
        + 'character has it');
    }
    // F64: F62's conversion flag, carried by a chosen ability. True or absent.
    if (e.mdc_from_hp_sdc !== undefined && e.mdc_from_hp_sdc !== true) {
      errors.push(`special_abilities: ${e.name}.mdc_from_hp_sdc is a flag and may only be true; `
        + 'omit it otherwise');
    }
    // F128: a pool base the option states. The class's own grammar, held to
    // what the pools can read - an unreadable base rolls nothing, which is the
    // silence the key exists to end.
    for (const k of ABILITY_POOL_BASES) {
      if (e[k] === undefined) continue;
      const probe = { IQ: 10, ME: 10, MA: 10, PS: 10, PP: 10, PE: 10, PB: 10, Spd: 10 };
      const readable = (typeof e[k] === 'number' || typeof e[k] === 'string')
        && poolFormulaBounds(e[k], probe) != null;
      if (!readable) {
        errors.push(`special_abilities: ${e.name}.${k} is not a formula the pools read - a number, `
          + 'dice, or an attribute plus dice ("P.E. x2 + 2d6 per level")');
      } else if (!optionNames.has(e.name.trim().toLowerCase())) {
        warnings.push(`special_abilities: ${e.name} states ${k} but is not offered as a choice, `
          + 'so nothing applies it - put the base on the class (or its variant)');
      }
    }
    if (e.mdc_base !== undefined && e.mdc_from_hp_sdc === true) {
      warnings.push(`special_abilities: ${e.name} sets mdc_from_hp_sdc beside an mdc_base, which `
        + 'wins; the flag does nothing');
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

  // Where each message points, in this markdown's own line numbers, or null.
  // Parallel to the two lists rather than folded into the strings, so nothing
  // that reads a message has to learn to strip a suffix. See locateMessage.
  const lineOf = (m) => locateMessage(m, text)?.line ?? null;
  return { ok: errors.length === 0, data, errors, warnings,
           lines: { errors: errors.map(lineOf), warnings: warnings.map(lineOf) } };
}
