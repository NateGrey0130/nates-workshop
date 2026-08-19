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
const PSI_TIERS = ['minor', 'major', 'master'];
const tierRank = (t) => PSI_TIERS.indexOf(String(t ?? '').toLowerCase());

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
  for (const [k, v] of Object.entries(b || {})) merged[k] = mergeBonusValue(merged[k], v);
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
  // at_level entries are kept side by side rather than merged by level:
  // classBonuses() folds every entry at or below the character's level anyway,
  // so two classes each granting +1 attack at level 5 correctly gives +2.
  const at = [...(a?.at_level || []), ...(b?.at_level || [])];
  if (at.length) out.at_level = at;
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
export function bonusesFromSkills(rows) {
  let out;
  for (const row of rows || []) {
    let b = row?.bonuses;
    if (typeof b === 'string') {
      try { b = JSON.parse(b); } catch { continue; }
    }
    if (!b || typeof b !== 'object' || Array.isArray(b)) continue;
    out = sumBonusGroups(out, b);
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
  for (const key of ['attribute_dice', 'hit_points_base', 'sdc_base', 'mdc_base', 'ppe_base',
                     'starting_money']) {
    if (rcc[key] == null && occ[key] != null) out[key] = occ[key];
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
  const bySkill = new Map();
  const groups = [];
  for (const entry of [...(rcc.skills?.occ_skills || []), ...(occ.skills?.occ_skills || [])]) {
    if (!entry?.name) { groups.push(entry); continue; }
    const key = String(entry.name).toLowerCase();
    const seen = bySkill.get(key);
    if (!seen || (entry.base ?? 0) > (seen.base ?? 0)) bySkill.set(key, entry);
  }
  out.skills = {
    ...(rcc.skills || {}),
    occ_skills: [...bySkill.values(), ...groups],
  };
  if (occ.skills?.occ_related_skills) out.skills.occ_related_skills = occ.skills.occ_related_skills;
  if (occ.skills?.secondary_skills) out.skills.secondary_skills = occ.skills.secondary_skills;

  out.bonuses = sumBonusGroups(rcc.bonuses, occ.bonuses);

  // The stronger psychic wins: a dragon that is already a Major psychic does
  // not become weaker by studying an O.C.C. with minor psionics.
  if (rcc.psionics || occ.psionics) {
    out.psionics = tierRank(occ.psionics?.type) > tierRank(rcc.psionics?.type)
      ? occ.psionics : (rcc.psionics || occ.psionics);
  }
  // Magic is what you studied, so the O.C.C. wins when both state it.
  if (occ.magic || rcc.magic) out.magic = occ.magic || rcc.magic;

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
// what the book allows inside it. Every entry the books print is one of two
// shapes, so those are the two supported:
//
//   { name: "Espionage", only: ["Escape Artist"] }
//   { name: "Physical", except: ["Acrobatics", "Gymnastics", "Wrestling"] }
//
// Strings keep working, so nothing already authored has to change. Shared by
// the wizard's picker and the server-side validator, because two copies of
// "may this character take this skill" is exactly the pair that drifts.

const normName = (s) => String(s ?? '').trim().toLowerCase();

export const categoryName = (entry) => (typeof entry === 'string' ? entry : entry?.name ?? null);

// A human label for the picker: "Espionage (Escape Artist only)".
export function categoryLabel(entry) {
  const name = categoryName(entry);
  if (typeof entry === 'string' || !entry) return name ?? '';
  if (Array.isArray(entry.only) && entry.only.length) return `${name} (${entry.only.join(', ')} only)`;
  if (Array.isArray(entry.except) && entry.except.length) return `${name} (except ${entry.except.join(', ')})`;
  return name ?? '';
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
  }
}

// The attributes a class bonus may name. Anything else is a typo — a bonus
// filed under a key nothing reads would silently do nothing, which is the
// failure this whole block exists to prevent.
export const BONUS_ATTRS = ['IQ', 'ME', 'MA', 'PS', 'PP', 'PE', 'PB', 'Spd'];

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
    // The stronger tier wins, the same rule composing a race with an occupation
    // uses, so an ability cannot make a Master psychic weaker.
    if (def.psionics) {
      out.psionics = tierRank(def.psionics.type) > tierRank(out.psionics?.type)
        ? def.psionics : (out.psionics || def.psionics);
    }
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

  // Shape checks on optional structures
  if (data.skills) {
    // An occ_skills entry is either a fixed skill ({name, base, per_level}) or a
    // choice-group ({choose, from: [...]}) — some classes bundle "pick N of
    // these" into the required list itself. Both may carry a free-text `note`
    // for conditional substitutions (advisory only, never enforced).
    for (const s of data.skills.occ_skills || []) {
      if (!s || typeof s !== 'object') { errors.push('skills.occ_skills entries must be objects'); continue; }
      if (isChoiceGroup(s)) {
        // Two flavours: an enumerated `from` list, or `categories` when the book
        // says "any N skills from <category>" (e.g. "two piloting skills of choice").
        if (typeof s.choose !== 'number' || s.choose < 1) errors.push('occ_skills choice-group needs a numeric choose >= 1');
        const hasFrom = Array.isArray(s.from) && s.from.length > 0;
        const hasCats = Array.isArray(s.categories) && s.categories.length > 0;
        if (!hasFrom && !hasCats) {
          errors.push('occ_skills choice-group needs a non-empty from list or categories list');
        } else if (hasFrom && !hasCats && s.choose > s.from.length) {
          errors.push(`occ_skills choice-group asks for ${s.choose} of only ${s.from.length} options`);
        }
        // `base` fixes the percentage; `bonus` adds to whatever each pick's own
        // base is. Both at once has no single reading, and a group spanning a
        // category almost always wants the second: the members start at
        // different percentages, so one number cannot express "+30%".
        if (s.base !== undefined && s.bonus !== undefined) {
          errors.push('occ_skills choice-group sets both base and bonus; use one');
        }
        if (s.bonus !== undefined && (typeof s.bonus !== 'number' || !Number.isFinite(s.bonus))) {
          errors.push('occ_skills choice-group bonus must be a number');
        }
      } else if (!s.name) {
        errors.push('skills.occ_skills entries need a name (or choose/from for a choice-group)');
      } else if (typeof s.base !== 'number') {
        warnings.push(`occ_skill "${s.name}" has no numeric base %`);
      }
    }
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
    }
    const secondary = data.skills.secondary_skills;
    if (secondary && typeof secondary.count !== 'number') errors.push('skills.secondary_skills.count must be a number');
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
