// An R.C.C. and an O.C.C. together: how a race and an occupation fold into
// one class (combineClasses), the merge helpers it folds each block with, and
// the level and bonus helpers that read a class's skills at a level.
//
// Moved out of js/parser.js verbatim, and parser.js re-exports every name it
// exported before, so an importer of parser.js is unchanged. The validator in
// parser.js still reads six names from here, imported and not re-exported.
//
// The import from parser.js below is a cycle (parser.js imports this file), and
// it is safe only because neither file reads the other's bindings while it is
// first evaluated: every use is inside a function body. Keep it that way. A
// top-level `const x = OVERRIDES_RACE_KEYS[0]` here would throw on whichever
// file loads second. normName comes from js/categories.js, which imports
// nothing and so is outside the cycle.
import { diceBounds, isAbsentAttribute } from './dice.js';
import { isHandToHand } from './hand-to-hand.js';
import { keysMergedBy } from './class-keys.js';
import { normName } from './categories.js';
import { OVERRIDES_RACE_KEYS } from './parser.js';

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
export function mergePsionics(born, trained) {
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
export function psionicBlocks(data) {
  const out = [];
  if (data?.psionics) out.push(['psionics', data.psionics]);
  for (const d of data?.special_abilities || []) {
    if (d && typeof d === 'object' && d.psionics) {
      out.push([`special_abilities.${d.name}.psionics`, d.psionics]);
    }
  }
  return out;
}

// Every super-ability block a class carries: its own, and any a special ability
// grants. The same fold as psionicBlocks, and it exists for the same reason: a
// Heroes Unlimited Power Category rolls on a table whose outcomes are whole
// PACKAGES - "one major and three minor" against "four minor" - and the only
// shape in this file that can offer a choice between packages is an ability
// choice group whose options each carry a grant.
export function superAbilityBlocks(data) {
  const out = [];
  if (data?.super_abilities) out.push(['super_abilities', data.super_abilities]);
  for (const d of data?.special_abilities || []) {
    if (d && typeof d === 'object' && d.super_abilities) {
      out.push([`special_abilities.${d.name}.super_abilities`, d.super_abilities]);
    }
  }
  return out;
}

// The two tiers Heroes Unlimited prints, and the only values the catalog's
// `super_abilities.tier` carries - 202 minor and 162 major, production,
// 2026-09-13. NOT A LADDER, which is the difference from `psionics.type`: a
// major is not a stronger minor, it is a different pool, and a category
// granting "one major and one minor" draws from both. So there is no stronger
// to compute and nothing here ranks them.
export const SUPER_ABILITY_TIERS = ['minor', 'major'];

// The same shape for Nightbane Talents, whose block is `talents`. A Talent is
// the only power here that costs something to HAVE as well as to USE, and both
// costs live on the catalog row (migration 063) rather than on the grant - so a
// grant says only how many, and at creation of which tier.
export function talentBlocks(data) {
  const out = [];
  if (data?.talents) out.push(['talents', data.talents]);
  for (const d of data?.special_abilities || []) {
    if (d && typeof d === 'object' && d.talents) {
      out.push([`special_abilities.${d.name}.talents`, d.talents]);
    }
  }
  return out;
}

// The two the book prints, printed 106: "Common" Talents are available to all
// Nightbane; "Elite" Talents are restricted to a few types and tied to the
// character's Morphus. NOT A LADDER, for the reason the super-ability tiers are
// not one - an Elite is not a stronger Common, it is a different set gated on
// what the character's Morphus already is.
export const TALENT_TIERS = ['common', 'elite'];

// Two talent blocks added together - the class's own plus whatever a chosen
// ability grants. Counts ADD, lists union and schedules concatenate, exactly as
// mergeSuperAbilities does and for the same reason: no tier to rank and no kind
// to prefer, so nothing here can silently drop a grant.
export function mergeTalents(born, trained) {
  if (!born) return trained;
  if (!trained) return born;
  const out = { ...born };
  for (const [k, v] of Object.entries(trained)) if (v !== undefined) out[k] = v;

  const starting = (born.talents_starting || 0) + (trained.talents_starting || 0);
  if (starting) out.talents_starting = starting;
  const perLevel = (born.talents_per_level || 0) + (trained.talents_per_level || 0);
  if (perLevel) out.talents_per_level = perLevel;
  const purchases = (born.talents_purchases_per_level || 0) + (trained.talents_purchases_per_level || 0);
  if (purchases) out.talents_purchases_per_level = purchases;
  for (const k of ['talents', 'talents_from']) {
    const both = unionByName(born[k], trained[k]);
    if (both.length) out[k] = both;
  }
  const groups = [...(born.talents_starting_groups || []),
                  ...(trained.talents_starting_groups || [])];
  if (groups.length) out.talents_starting_groups = groups;
  // Schedules CONCATENATE rather than union: two blocks each granting a free
  // Talent at level four is two Talents at level four, and `perLevelGrants`
  // gives each its own slot. Deduplicating would silently halve it.
  const schedule = [...(born.talents_schedule || []), ...(trained.talents_schedule || [])];
  if (schedule.length) out.talents_schedule = schedule;
  const tiers = [...new Set([...(born.tiers_allowed || []),
                             ...(trained.tiers_allowed || [])])];
  if (tiers.length) out.tiers_allowed = tiers;
  return out;
}

// Two super-ability blocks added together - the class's own plus whatever a
// chosen ability grants. Counts ADD and lists union, which is the whole of it:
// with no tier to rank and no kind to prefer there is nothing here that could
// silently drop a grant the way `out.magic = occ.magic || rcc.magic` did.
export function mergeSuperAbilities(born, trained) {
  if (!born) return trained;
  if (!trained) return born;
  // Spread first so an unenumerated key survives, the same courtesy mergeMagic
  // extends to the eleven keys its blocks use.
  const out = { ...born };
  for (const [k, v] of Object.entries(trained)) if (v !== undefined) out[k] = v;

  const starting = (born.abilities_starting || 0) + (trained.abilities_starting || 0);
  if (starting) out.abilities_starting = starting;
  for (const k of ['abilities', 'abilities_from']) {
    const both = unionByName(born[k], trained[k]);
    if (both.length) out[k] = both;
  }
  const groups = [...(born.abilities_starting_groups || []),
                  ...(trained.abilities_starting_groups || [])];
  if (groups.length) out.abilities_starting_groups = groups;
  const tiers = [...new Set([...(born.tiers_allowed || []),
                             ...(trained.tiers_allowed || [])])];
  if (tiers.length) out.tiers_allowed = tiers;
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
export function mergeMagic(born, trained) {
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

  // Traditions a level-gated pick may reach are UNIONED for the same reason
  // levels are: an ocean-magic race studying as an occupation that states its
  // own allowance must not lose the race's. BOOK-INGEST-AUDIT F57.
  const traditions = [...new Set([...(born.spell_traditions_allowed || []),
                                  ...(trained.spell_traditions_allowed || [])]
    .map((t) => String(t).trim().toLowerCase()).filter(Boolean))];
  if (traditions.length) out.spell_traditions_allowed = traditions;

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
  // `attacks_base` STATES a starting number (p.347), so of two it is the
  // higher that stands - the rule bonusesFromSkills() already kept between two
  // styles. Summed with the rest, a race and an occupation added their counts,
  // and a class stating four attacks with Hand to Hand: Assassin's three
  // fought at seven. A class whose book says "one ADDITIONAL attack" or "plus
  // those gained from hand to hand" means a bonus, and says so as `attacks`.
  const baseA = a?.combat?.attacks_base;
  const baseB = b?.combat?.attacks_base;
  if (typeof baseA === 'number' && typeof baseB === 'number') {
    out.combat.attacks_base = Math.max(baseA, baseB);
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
//
// `cls` is optional too, and matters for one flag: `ignores_style_attacks`.
// Some books give a creature its own attacks and say a Hand to Hand style adds
// none of them - "Do not add the melee round attacks from the hand to hand
// combat skill, only use it for bonuses and fighting techniques" (Underseas
// p.52, for each Pneuma-Biform). For such a class a style's `attacks_base`
// and per-level `attacks` are dropped and everything else it grants stands.
// Only a style's: Boxing's extra attack is a skill's, not a style's, and the
// books that say this name the hand to hand skill.
export function bonusesFromSkills(rows, level = null, cls = null) {
  let out;
  // `attacks_base` STATES a starting number rather than adding to one, so it
  // cannot go through the summing path - two fighting styles would give eight
  // attacks. The strongest training wins, which is also what a character with
  // two Hand to Hand skills would actually fight at.
  let attacksBase = null;
  const noStyleAttacks = cls?.ignores_style_attacks === true;
  let styleRow = false;
  const take = (block) => {
    if (!block) return;
    if (noStyleAttacks && styleRow && block.combat) {
      const { attacks_base: _base, attacks: _attacks, ...kept } = block.combat;
      block = { ...block, combat: kept };
    }
    const combat = block.combat;
    if (combat && typeof combat.attacks_base === 'number') {
      attacksBase = Math.max(attacksBase ?? 0, combat.attacks_base);
      const { attacks_base: _drop, ...rest } = combat;
      block = { ...block, combat: rest };
    }
    out = sumBonusGroups(out, block);
  };

  for (const row of rows || []) {
    // A style is recognised by name, as everywhere (js/hand-to-hand.js); the
    // regression suite pins every row stating attacks_base to that name.
    styleRow = isHandToHand(row?.name);
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

// The race's fixed skills a pairing carries: all of them, or, when the race
// declares `pairing_skills` (BOOK-INGEST-AUDIT F114), only the named entries it
// lists, in its order, with its `base` and `note` laid over the race's entry.
// A listed name the race does not hold is dropped here and refused by
// parseClassMarkdown, so it never reaches a pairing unnoticed.
function racePairingSkills(rcc) {
  const own = rcc.skills?.occ_skills || [];
  if (!Array.isArray(rcc.pairing_skills)) return own;
  const byName = new Map();
  for (const e of own) if (e?.name) byName.set(String(e.name).toLowerCase(), e);
  const kept = [];
  for (const p of rcc.pairing_skills) {
    const found = p?.name != null ? byName.get(String(p.name).toLowerCase()) : null;
    if (!found) continue;
    kept.push({
      ...found,
      ...(typeof p.base === 'number' ? { base: p.base } : {}),
      ...(typeof p.note === 'string' ? { note: p.note } : {}),
    });
  }
  return kept;
}

// The two allowance lists a race's `pairing_counts` may trim, by the name the
// key uses for each (BOOK-INGEST-AUDIT F129). Read by the validator too.
export const PAIRING_COUNT_LISTS = { related: 'occ_related_skills', secondary: 'secondary_skills' };

// An occupation's related and secondary allowances as a race's `pairing_counts`
// leaves them: `{ occ_related_skills?, secondary_skills? }`, holding only a
// list whose count moved, each a COPY so the occupation's own block is never
// written to. Every entry that names no `occupations`, or names this one,
// applies, in the order written. A `factor` rounds DOWN (Nate, 2026-10-12: a
// halved five is two); a `cap` only ever lowers. A list the occupation does
// not state is not created: there is nothing to trim.
//
// CREATION COUNTS ONLY, on the same word: `schedule` and `level_progression`
// picks gained at later levels are not touched.
function pairingCounts(rcc, occ) {
  const trimmed = {};
  if (!Array.isArray(rcc.pairing_counts)) return trimmed;
  for (const entry of rcc.pairing_counts) {
    if (!entry || typeof entry !== 'object') continue;
    if (Array.isArray(entry.occupations) && !entry.occupations.includes(occ.id)) continue;
    for (const [list, key] of Object.entries(PAIRING_COUNT_LISTS)) {
      const rule = entry[list];
      const block = trimmed[key] || occ.skills?.[key];
      if (!rule || typeof rule !== 'object' || !block || typeof block.count !== 'number') continue;
      let count = block.count;
      // The epsilon keeps a product that is a whole number in the book from
      // landing a hair under it in binary and flooring one too low.
      if (typeof rule.factor === 'number') count = Math.floor(count * rule.factor + 1e-9);
      else if (typeof rule.cap === 'number') count = Math.min(count, rule.cap);
      if (count !== block.count) trimmed[key] = { ...block, count: Math.max(0, count) };
    }
  }
  return trimmed;
}

// What a preview of an occupation prints beside a race: for each of the two
// allowance lists, `count` is what the composed character gets and `own` is
// what the occupation states. They differ only where the race's
// `pairing_counts` trimmed the list, so `count !== own` is the whole test for
// "this race takes fewer". Read off `combineClasses` itself, not worked out
// again, so the wizard's occupation picker cannot promise a count the skills
// step and the server then refuse - which it did until 2026-10-13, printing
// the occupation's whole six beside a race that halves it. A list the
// occupation does not state reads 0 for both, as the picker always printed it.
export function pairedSkillCounts(rcc, occ) {
  const paired = (rcc && occ ? combineClasses(rcc, occ) : occ)?.skills || {};
  const row = (key) => {
    const own = occ?.skills?.[key];
    return own ? { count: paired[key]?.count ?? 0, own: own.count ?? 0 } : { count: 0, own: 0 };
  };
  return { related: row(PAIRING_COUNT_LISTS.related), secondary: row(PAIRING_COUNT_LISTS.secondary) };
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
  // `xp_table` is NOT on this list; it has its own rule, straight after it.
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
  // A race whose book says a style adds no attacks keeps saying so through
  // `out`, the race spread; an occupation that says it is carried the same way.
  if (occ.ignores_style_attacks === true) out.ignores_style_attacks = true;
  // A mega-damage conversion is the OCCUPATION's when it states one - the Totem
  // Warrior's supernatural P.E. comes from its infusion, not from a race - and
  // `out` starts as the race spread, so it is carried (BOOK-INGEST-AUDIT F62).
  // An M.D.C. race still keeps its own pool: convertsToMdc yields to mdc_base.
  if (occ.mdc_from_hp_sdc === true) out.mdc_from_hp_sdc = true;
  // `psionics_allowed: false` is carried from the occupation the same way
  // (BOOK-INGEST-AUDIT F118). The race's rides the spread; an occupation's was
  // dropped, so a class stating it in the occupation slot - its own psionics
  // table, or none at all - sent the pair to the standard Random Psionics roll
  // anyway. Either half saying no is a no: the flag only ever switches the
  // standard roll off, and a `psionics` block on either half is untouched.
  if (occ.psionics_allowed === false) out.psionics_allowed = false;
  // `horror_factor` rides this loop rather than the bare spread above, and both
  // halves of the loop matter for it (F75). Without it: an OCCUPATION that
  // projects one is silently dropped when the race states none, and a
  // SUPERSEDING class keeps the race's - which is wrong and had a live
  // instance, since `cosmo-knight` is the only carrier of `supersedes_race` and
  // its own prose already states a projected Horror Factor.
  //
  // WHEN BOTH STATE ONE AND NEITHER SUPERSEDES, THE RACE'S WINS, and that is
  // deliberate rather than inherited: a Horror Factor is a property of the
  // body, so the thing a character IS outranks the job it took. Stated here
  // because the loop's behaviour is the policy and nothing else says so.
  //
  // `second_form` rides it for the same reason and with the same policy
  // (BOOK-INGEST-AUDIT F74, survey D5). A second body is the BODY's: a Nightbane
  // R.C.C. states it and pairs with package O.C.C.s that state none, which the
  // `{ ...rcc }` spread already carries - but an occupation that is itself the
  // transformation would be dropped without the loop, and a superseding one
  // must replace the race's. Race wins when both state one.
  // The list is CLASS_MERGE's `race-first` keys in js/class-keys.js.
  for (const key of keysMergedBy('race-first')) {
    if (superseded && occ[key] != null) out[key] = occ[key];
    else if (rcc[key] == null && occ[key] != null) out[key] = occ[key];
  }
  // AN OCCUPATION MAY OPT IN, KEY BY KEY, FOR TWO OF THOSE (BOOK-INGEST-AUDIT
  // F111). `overrides_race: [ppe_base, starting_money]` makes the occupation's
  // value win the listed keys when it states one; every other key, and every
  // occupation without the list, composes exactly as above.
  //
  // Opt-in rather than the rule F111 proposed (the occupation's money always
  // wins, a magic occupation's P.P.E. wins), on Nate's word, 2026-09-27: a
  // census of every legal published pairing found that rule would move ~9,390
  // pairings' P.P.E. - 2,451 of them DOWN, a Phoenixi mage losing its 3D4x100 -
  // and ~6,048 pairings' money, including races whose book prints none, and
  // would break races whose P.P.E. ADDS to a mage's (rifts-cyclops, rifts-elf)
  // or prints its own mage figure (godling, true-inca, draconid). The list
  // reaches every race the occupation can pair with, which is why
  // parseClassMarkdown warns when it is not limited by race_restrictions.only.
  if (!superseded && Array.isArray(occ.overrides_race)) {
    for (const key of occ.overrides_race) {
      if (OVERRIDES_RACE_KEYS.includes(key) && occ[key] != null) out[key] = occ[key];
    }
  }
  // THE SAME TWO KEYS, DECLARED FROM THE RACE'S SIDE (BOOK-INGEST-AUDIT F111,
  // the Larhold part, on Nate's word 2026-09-27). `yields_to_occupation` maps a
  // key to the occupation groups whose stated value wins it:
  //
  //   yields_to_occupation: { ppe_base: [magic, clergy] }   # PF human, elf
  //
  // For a race whose book prints its figure as the one for a character who does
  // NOT take that kind of occupation - "2D6 for most adults, unless a mage or
  // clergy O.C.C." - when the occupation it can pair with is open to every race,
  // so `overrides_race` would reach the races whose P.P.E. ADDS to a mage's or
  // prints its own. Only a race that says so yields; every other race is
  // race-first exactly as above.
  const yields = rcc.yields_to_occupation;
  if (!superseded && yields && typeof yields === 'object' && !Array.isArray(yields)) {
    for (const key of OVERRIDES_RACE_KEYS) {
      const groups = yields[key];
      if (Array.isArray(groups) && groups.includes(occ.occ_group) && occ[key] != null) out[key] = occ[key];
    }
  }
  // `xp_table` runs the OTHER way: when both halves state one, the OCCUPATION's
  // wins, superseding or not (one opt-out, F122, at the foot of this comment). Palladium names its experience charts by O.C.C. -
  // "Knight & Noble", "Thief & Merchant" - because experience comes from what
  // you do, so a character who takes up a trade levels on the trade's chart.
  // Left to the race, an occupation's table was dropped on every Palladium
  // character (race primary, occupation second since #210).
  //
  // A race may still carry one, and it is not dead weight: some books also print
  // a ladder for a race played WITHOUT an occupation - Nightbane printed 233 has
  // "Hound & Hunter", "Wampyr" and "Nightprince & Vampire" beside the O.C.C.
  // charts. Nate's call, 2026-09-17 (docs/surveys/nightbane-core.md, "Follow-up
  // decisions after the import"): the race's ladder applies when it is played
  // alone, which needs nothing here - `combineClasses` is not reached without an
  // occupation, and the `{ ...rcc }` spread carries it into a pairing whose
  // occupation states none - and an O.C.C.'s ladder wins a pairing. Until then
  // this key rode the loop above, where the race won, and the one thing keeping
  // that harmless was a regression invariant that no R.C.C. carried a table.
  //
  // UNLESS THE RACE'S OWN BOOK SAYS IT KEEPS ITS LADDER (BOOK-INGEST-AUDIT
  // F122). Phase World's Draconid takes a Ley Line Walker's or a Mind Melter's
  // powers and "in either case" levels on the Draconid's table. A race-side
  // flag, like `yields_to_occupation`: the race knows which kind it is. A
  // superseding occupation still wins - the character is no longer its race.
  const keepsLadder = rcc.keeps_xp_table === true && rcc.xp_table != null && !superseded;
  if (occ.xp_table != null && !keepsLadder) out.xp_table = occ.xp_table;
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

  // Ceilings the same way, except "stricter" is the LOWER number. A book that
  // caps an attribute is saying the same kind of thing as one that floors it,
  // so both sides apply and neither replaces the other (F32).
  //
  // This block has to exist even though `out = { ...rcc }` above already
  // carries the RACE's ceilings: without it the OCCUPATION's are silently
  // dropped. That is a half-implementation failing in exactly one direction,
  // which is the shape a merged key hides best.
  const maxes = { ...(rcc.attribute_maximums || {}) };
  for (const [k, v] of Object.entries(occ.attribute_maximums || {})) {
    if (typeof v !== 'number') continue;
    maxes[k] = typeof maxes[k] === 'number' ? Math.min(maxes[k], v) : v;
  }
  if (Object.keys(maxes).length) out.attribute_maximums = maxes;

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
  //
  // A RACE MAY NAME THE FEW IT KEEPS (BOOK-INGEST-AUDIT F114). The union above
  // is F11's default and stays one; `pairing_skills` is a race-side opt-in for
  // a book whose R.C.C. list is the kit of a member who takes NO occupation and
  // which names what carries over when one is taken - South America 2 printed
  // 186, "in addition to the specific O.C.C. skills, all Larhold will have
  // Riding: War Bison ... and W.P.: Archery and Targeting." Only the race's
  // named entries it lists survive, each with its own `base` or `note` where
  // given, and the race's choice groups do not; a race without the key
  // composes exactly as above.
  const bySkill = new Map();
  const groups = [];
  const pastLife = superseded ? [] : racePairingSkills(rcc);
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
  // A RACE MAY TAKE FEWER OF THEM (BOOK-INGEST-AUDIT F129). The allowances are
  // the occupation's, whole, and that stays the default; `pairing_counts` is a
  // race-side opt-in for a book that cuts them - D-Bees' N'mbyr Gorilla Man
  // halves both for any occupation, Canada's Noli Bushman gets three of each
  // as a Wilderness Scout or Vagabond. Not for a superseding occupation: that
  // character is no longer its race.
  if (!superseded) Object.assign(out.skills, pairingCounts(rcc, occ));
  // Skill programs are carried for the same reason the MOS below is, and the
  // omission would have been worse: this rebuilds `skills` wholesale from the
  // RACE's block, so an occupation's `skill_programs` would vanish while a
  // race's survived - and the only class that has one is an O.C.C.
  // (BOOK-INGEST-AUDIT.md F23(b)). The block would have done nothing for the
  // very class it was built for, silently, with every test still passing.
  const programs = occ.skills?.skill_programs ?? rcc.skills?.skill_programs;
  if (programs) out.skills.skill_programs = programs;
  // The Hand to Hand price list (js/hand-to-hand.js) is bought out of RELATED
  // skills, and related skills are the occupation's - so in a pairing the
  // occupation's list is the only one, and an occupation that states none
  // leaves the composed class with none: any style, one pick. The race's list
  // prices the race's own Hand to Hand, which is an R.C.C. skill, so it is
  // REMOVED here rather than left standing from the race spread above (Nate,
  // 2026-10-12, for every race). It used to be the fallback, and a paired
  // Larhold Cyber-Knight was priced off the Barbarian's "Expert can be
  // changed" over a Martial Arts the Cyber-Knight grants, when the race's
  // own Expert no longer carries over (BOOK-INGEST-AUDIT.md F114's aside). A
  // racial class played with no occupation keeps its own list, because this
  // function hands it back untouched on its first line and never gets here.
  const h2h = occ.skills?.hand_to_hand;
  if (h2h) out.skills.hand_to_hand = h2h;
  else delete out.skills.hand_to_hand;
  // An MOS belongs to the OCCUPATION - it is a military specialty, and the
  // Coalition classes that have one are all O.C.C.s. Carried across the merge
  // because this rebuilds `skills` wholesale, and without it a Technical
  // Officer taken alongside a racial class silently lost its specialties.
  // The race's own is the fallback, for a racial class that ever gains one.
  const mos = occ.skills?.mos ?? rcc.skills?.mos;
  if (mos) out.skills.mos = mos;
  // A totem pick is an OCCUPATION's in every class that has one (Spirit West,
  // BOOK-INGEST-AUDIT.md F56), and `out` starts as the race spread, so an
  // O.C.C.'s key is carried here or a D-Bee Tribal Warrior loses the pick. Top
  // level rather than under `skills`, because a totem grants bonuses as well.
  const totem = occ.totem ?? rcc.totem;
  if (totem) out.totem = totem;

  out.bonuses = sumBonusGroups(rcc.bonuses, occ.bonuses);

  // Born plus trained, not one or the other (F10). The race is what a member of
  // that race comes with; the occupation is what its page teaches.
  if (rcc.psionics || occ.psionics) out.psionics = mergePsionics(rcc.psionics, occ.psionics);
  // A Heroes Unlimited character is a Power Category in the R.C.C. slot and an
  // Educational Level in the O.C.C. slot, so in every class that book will ever
  // ship the block is on the RACE side - the mirror image of `skill_programs`
  // two dozen lines above, which is only ever an O.C.C.'s. MERGED rather than
  // read off one slot, for the reason F10 and F14 both give: a rule that reads
  // from one side is a half-implementation failing in exactly one direction,
  // and this is the direction nothing would notice.
  //
  // THE SUPERSEDE BRANCH DOES NOT ERASE, and neither does magic's. `out` is
  // seeded `{ ...rcc }` and the branch hands back `occ.X || rcc.X`, so a
  // superseding occupation that states no block of its own - every one of them,
  // since supersedes_race marks a transformation rather than a caster - leaves
  // the race's standing. Measured on both existing blocks;
  // BOOK-INGEST-AUDIT.md F81, TAKEN 2026-09-15 as a correction to the comment
  // above magic, which claimed the opposite. This sentence used to say that
  // comment was still wrong; it is not, and the full reasoning now lives there.
  if (rcc.super_abilities || occ.super_abilities) {
    out.super_abilities = superseded
      ? (occ.super_abilities || rcc.super_abilities)
      : mergeSuperAbilities(rcc.super_abilities, occ.super_abilities);
  }
  // Talents fold the same way, and follow `supersedes_race` for the same
  // reason: a superseding occupation is a transformation into something else,
  // so what the race could do is what it USED to be able to do.
  if (rcc.talents || occ.talents) {
    out.talents = superseded
      ? (occ.talents || rcc.talents)
      : mergeTalents(rcc.talents, occ.talents);
  }
  // Magic is what you studied AND what a creature was born with, and the two add
  // up the same way psionics do (F14).
  //
  // THIS COMMENT USED TO SAY A SUPERSEDING CLASS ERASES THE RACE'S MAGIC. It
  // does not, and BOOK-INGEST-AUDIT.md F81 is the record of the contradiction:
  // `out` is seeded `{ ...rcc }` and this branch hands back
  // `occ.magic || rcc.magic`, so a superseding occupation stating no magic of
  // its own - every one of them, since supersedes_race marks a transformation
  // rather than a caster - leaves the race's block standing.
  //
  // THE CODE IS THE SIDE THAT WAS RIGHT, which is why the sentence went rather
  // than the behaviour. Two user-facing statements of the rule already agreed
  // with the code and would have become false: `docs/race-and-occupation.md`'s
  // superseding table ends `| everything else | unchanged |`, and
  // `apps/character-creator/README.md` enumerates what the flag inverts - pools,
  // starting_money, xp_table, occ_skills, attribute_dice - and lists neither
  // magic nor psionics. One comment disagreed with two specs and the code.
  //
  // WHAT `superseded` ACTUALLY BUYS HERE, and it is not nothing: when the occ
  // DOES state magic, this takes it OUTRIGHT instead of merging, so the race's
  // `spells_starting` is dropped rather than max'd. `super_abilities` above is
  // written the same way. PSIONICS IS NOT - it merges unconditionally, and
  // mergePsionics promotes the tier, takes the max of the counts and unions the
  // named powers (F10's reason: 89 of 165 pairs carry the LOWER count on the occ
  // side). So all three agree about a superseding occ that states NOTHING, and
  // two of the three differ from the third about one that states something.
  // Nothing in the catalog reaches that case - `cosmo-knight` is the only
  // carrier of the flag and states none of the three blocks (--remote,
  // 2026-09-15) - which is why this is written down rather than changed.
  if (occ.magic || rcc.magic) {
    out.magic = superseded ? (occ.magic || rcc.magic) : mergeMagic(rcc.magic, occ.magic);
  }

  for (const key of keysMergedBy('concat')) {
    const both = [...(rcc[key] || []), ...(occ[key] || [])];
    if (both.length) out[key] = both;
  }

  // What the occupation tracks at the table and what it costs to be one are the
  // occupation's own, whatever body it is taken in. Neither key was named
  // anywhere above, so `{ ...rcc }` answered for both and an occupation's were
  // dropped the moment a race was chosen - silently, and even when the race
  // stated none. A resource the race already names is the race's, as its pools
  // are.
  {
    const mine = rcc.trackable_resources || [];
    const held = new Set(mine.map((r) => r?.name));
    const theirs = (occ.trackable_resources || []).filter((r) => !held.has(r?.name));
    if (theirs.length) out.trackable_resources = [...mine, ...theirs];
  }
  // `side_effects` is free text or a list, and both readers take either. One
  // side speaking keeps its own shape; two become a list, race first.
  {
    const said = (v) => (Array.isArray(v) ? v : [v]).filter((s) => s != null && String(s).trim() !== '');
    const theirs = said(occ.side_effects);
    if (theirs.length) {
      const mine = said(rcc.side_effects);
      out.side_effects = mine.length ? [...mine, ...theirs] : occ.side_effects;
    }
  }

  return out;
}
