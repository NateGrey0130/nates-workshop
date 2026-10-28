// Chosen and granted special abilities: what a class offers, how a pick is
// counted, rolled and levelled, and how the ones a character holds are folded
// into the class it plays as (applyAbilities).
//
// Moved out of js/parser.js verbatim, and parser.js re-exports every name it
// exported before, so an importer of parser.js is unchanged. The validator
// half of the ability rules stays in parser.js and imports from here.
//
// The import below is a cycle (parser.js imports this file), and it is safe
// only because neither file reads the other's bindings while it is first
// evaluated: every use is inside a function body. Keep it that way. A
// top-level `const x = isDiceBonus(...)` here would throw on whichever file
// loads second. The combine rules it calls are js/combine.js, which is in the
// same cycle and under the same rule.
import { diceBounds } from './dice.js';
import { isDiceBonus } from './parser.js';
import { sumBonusGroups, mergePsionics, mergeTalents,
         mergeSuperAbilities, mergeMagic } from './combine.js';

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
// `attribute_dice` has since been let in on its own, like the two flags below
// this list (BOOK-INGEST-AUDIT F120, on Nate's ruling): a table ROW that prints
// "P.B. 2D4" is not adding to the roll, it is the roll. `starting_money` stays
// out, and the argument above still holds for it.
//
//   - name: "Super-Tough"
//     description: "Add 1D6 to P.E. and 3D4x10 to M.D.C."
//     bonuses: { attributes: { PE: "1d6" }, pools: { mdc: "3d4x10" } }
//
// M.D.C. arrives as a pool BONUS rather than an override, which is why pool
// bonuses had to exist first — the ability adds to whatever the class already
// rolls, it does not replace the formula.
export const ABILITY_GRANTS = ['bonuses', 'psionics', 'magic', 'super_abilities', 'talents'];

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

// Which choice group offers a given ability, by index, or -1 for one no group
// offers - a `{ gm: true }` ruling, or a pick left behind by a class edit.
//
// A group's `from` list is the only thing tying a pick to a group: `abilities`
// is a flat list of NAMES with nothing recording which group each came from,
// and widening it to carry one would change what every character stores. The
// first group offering the name wins. That is unambiguous on every class in the
// catalog - the two classes with more than one group, `hu-aliens` and
// `hu-experiments`, offer 28 and 29 option names across their groups and no
// name twice, counted through this parser against production 2026-09-15 - and
// where a future class does repeat one, attributing the pick to the earlier
// group is a defined answer rather than a crash.
export function abilityGroupIndexFor(cls, name) {
  const key = String(name && name.name ? name.name : name || '').trim().toLowerCase();
  if (!key) return -1;
  const groups = (cls?.special_abilities || []).filter(isAbilityChoice);
  for (let i = 0; i < groups.length; i++) {
    for (const opt of groups[i].from || []) {
      const optName = typeof opt === 'string' ? opt : opt?.name;
      if (optName && String(optName).trim().toLowerCase() === key) return i;
    }
  }
  return -1;
}

// How many picks each choice group currently holds, parallel to the group list.
//
// THE POINT OF THIS FUNCTION IS THAT A COUNT IS PER GROUP AND NOT PER
// CHARACTER. `abilityPicker` compared the character's TOTAL pick count against
// ONE group's `choose`, so on a class with more than one group the first pick
// disabled every remaining `+` button and the other groups became unreachable -
// the Heroes Unlimited Alien has four groups of `choose: 1` and a player could
// take one of the four (BOOK-INGEST-AUDIT.md F98). Anything measuring picks
// against a group's limit calls this rather than reading `abilities.length`.
export function abilityGroupCounts(cls, chosenNames) {
  const groups = (cls?.special_abilities || []).filter(isAbilityChoice);
  const counts = groups.map(() => 0);
  for (const entry of chosenNames || []) {
    const i = abilityGroupIndexFor(cls, entry);
    if (i >= 0) counts[i]++;
  }
  return counts;
}

// The percentile bands a pick-one group's options carry in their NAMES, or null
// when the group is not a table a player can roll on.
//
// A book that rolls a character's branch - the Dog Boy's breed, the Gypsy
// Gifted's gift - is stored as a `{ choose: 1 }` group whose options are named
// for their band: "Breed (06-10): Wolfhound". The band is already there for the
// player to read, so the wizard's roll button reads the same text rather than
// asking every class for a second field that could disagree with its name.
//
// `00` closes a band at 100, as the books print it. An option with no band (the
// "table not used" choice) is simply not something a roll can land on.
//
// Null unless the banded options cover every number from 1 to 100: a roll on a
// table with a hole in it would sometimes land on nothing, and a button that
// sometimes does nothing reads as broken. Two options MAY share a band - the
// Dog Boy's 66-70 prints two breeds - and `abilityRollMatches` returns both.
//
// A group that states `rolls` is a table too, whatever it holds: the book
// rolls on it more than once (BOOK-INGEST-AUDIT F120, below).
const ABILITY_BAND = /\((\d{2})\s*-\s*(\d{2})\)/;
export function abilityRollBands(group) {
  if (!isAbilityChoice(group)) return null;
  if (group.rolls === undefined && (+group.choose || 0) !== 1) return null;
  return bandsOf(group);
}

export function bandsOf(group) {
  const bands = [];
  for (const opt of group.from || []) {
    const name = typeof opt === 'string' ? opt : opt?.name;
    const m = ABILITY_BAND.exec(String(name || ''));
    if (!m) continue;
    const lo = +m[1];
    const hi = m[2] === '00' ? 100 : +m[2];
    if (lo < 1 || hi < lo) return null;
    bands.push({ name, lo, hi });
  }
  if (bands.length < 2) return null;
  for (let n = 1; n <= 100; n++) {
    if (!bands.some((b) => n >= b.lo && n <= b.hi)) return null;
  }
  return bands;
}

// The option names a percentile roll lands on: one, or several where the book
// prints more than one result for a band.
export function abilityRollMatches(bands, roll) {
  return (bands || []).filter((b) => roll >= b.lo && roll <= b.hi).map((b) => b.name);
}

// A TABLE THE BOOK ROLLS ON MORE THAN ONCE (BOOK-INGEST-AUDIT F120, Nate's
// ruling 10 on the 2026-10-03 retrospective: one general mechanic).
//
//   - { rolls: 2, from: ["Feature (01-07): Rat Tail", ...] }
//   - { rolls: "1d4", from: ["Oddity (01-10): Extra Eyes", ...] }
//
// `rolls` stands where `choose` would: how many times the table is rolled - a
// whole number, or dice when the book rolls the count too ("roll 1D4 times").
// Each roll is a pick, and a result already held is rolled again, so no row is
// taken twice. The player may still choose by hand; the books say "or select".
//
// THE PARSER FILLS IN `choose` with the most the group can hold - the number,
// or the dice's ceiling - so everything that reads a group's limit (the picker,
// the server's count, the NPC generator) is right without knowing about
// `rolls`. A class that writes both must make them agree.
//
// What a dice count ROLLED is not stored: there is no column for it and the
// picks are the record. The server holds a `rolls` group to its ceiling.
export function abilityRollLimit(rolls) {
  if (Number.isInteger(rolls) && rolls >= 1) return rolls;
  if (isDiceBonus(rolls)) return diceBounds(rolls)?.max ?? null;
  return null;
}

// How many picks a group OWES before the wizard moves on. A `choose` group
// owes all of them. A table rolled a dice number of times owes only the least
// the dice can come up - the rolled count is not stored, so the Race step
// cannot hold a player who rolled 2 on 1D4 until four rows are held, which is
// what reading the filled-in `choose` did (found by F120's premise audit).
//
// A group picked AT SET LEVELS (F116, below) owes its level-1 pick at creation
// and nothing else: the later ones are banked when the level is reached.
export function abilityGroupOwed(group) {
  if (typeof group?.rolls === 'string') return diceBounds(group.rolls)?.min ?? 1;
  return abilityGroupAllowance(group, 1);
}

// A PICK MADE AT SET LEVELS (BOOK-INGEST-AUDIT F116).
//
//   - { choose: 1, at_levels: [1, 3, 6, 9, 12, 15], from: ["Art of ...", ...] }
//
// Rifts Japan's Mystic Ninja takes one art of invisibility at each of those
// levels; the Bishamon monk takes one at level 3 and none at creation. Without
// `at_levels` a group is what it always was: `choose` picks, at creation.
//
// `choose` is the number of picks EACH level gives. Level 1, when it is on the
// list, is the creation pick the wizard already offers; every later level
// banks a grant the sheet's banked-picks panel spends (kind `ability` in
// `pending_power_picks`), and spending one adds the name to the character's
// abilities, where applyAbilities folds it like any other.
//
// SO A GROUP'S LIMIT DEPENDS ON THE CHARACTER'S LEVEL, and everything that
// measured picks against `choose` asks this instead: the wizard's picker and
// gate (level 1), the server's count (the character's level), the NPC
// generator's creation picks.
//
// A LEVEL MAY CARRY ITS OWN COUNT (BOOK-INGEST-AUDIT F127).
//
//   - { choose: 1, at_levels: [{ level: 1, count: 4 }, 3, 6, 9], from: [...] }
//
// Four at creation and one more at 3, 6 and 9, from one list. A bare number
// still means `choose` picks at that level, so a group of bare numbers is
// exactly what it was. abilityGroupLevelCounts is the one reader of the entry
// shape; the three functions below it all go through it.
const isLevelNumber = (n) => Number.isInteger(n) && n >= 1;

function abilityLevelEntry(entry, choose) {
  if (isLevelNumber(entry)) return { level: entry, count: choose };
  if (entry && typeof entry === 'object' && !Array.isArray(entry)
      && isLevelNumber(entry.level) && isLevelNumber(entry.count)) {
    return { level: entry.level, count: entry.count };
  }
  return null;
}

// [{ level, count }] in level order, or null when the group states no usable
// `at_levels` - one malformed entry makes the whole list unusable, as it did
// when every entry was a number.
function abilityGroupLevelCounts(group) {
  const l = group?.at_levels;
  if (!Array.isArray(l) || !l.length) return null;
  const choose = +group?.choose || 0;
  const out = l.map((e) => abilityLevelEntry(e, choose));
  return out.every(Boolean) ? out.sort((a, b) => a.level - b.level) : null;
}

export function abilityGroupLevels(group) {
  return abilityGroupLevelCounts(group)?.map((e) => e.level) ?? null;
}

export function abilityGroupAllowance(group, level) {
  const choose = +group?.choose || 0;
  const levels = abilityGroupLevelCounts(group);
  if (!levels) return choose;
  const at = Number(level) || 1;
  return levels.reduce((n, e) => n + (e.level <= at ? e.count : 0), 0);
}

// What a span of levels earns from a class's levelled groups, itemised by the
// level that earned each - the shape perLevelGrants gives spells and Talents.
// Every level strictly above `fromLevel` and up to `toLevel`, so creation
// (from 1) never re-grants the level-1 pick the wizard already took.
//
// `slot` is the group's index among the composed class's choice groups: two
// groups may fire at one level (the Bishamon's exercise at 4 is not its art at
// 3, but a class could give both at 10), and level plus slot is what every
// grant is keyed on. The option names ride on the grant, so a banked pick
// keeps the list it was granted with even if the class is re-imported.
export function abilityLevelGrants(cls, fromLevel, toLevel) {
  const out = [];
  const groups = (cls?.special_abilities || []).filter(isAbilityChoice);
  groups.forEach((g, slot) => {
    // Each level's own count (F127): `choose` for a bare number, the entry's
    // `count` for one that states it.
    const levels = abilityGroupLevelCounts(g);
    if (!levels) return;
    const from = (g.from || []).map((o) => (typeof o === 'string' ? o : o?.name)).filter(Boolean).map(String);
    if (!from.length) return;
    for (const { level, count } of levels) {
      if (count <= 0 || level <= fromLevel || level > toLevel) continue;
      out.push({ level, slot, count, from,
        ...(typeof g.note === 'string' && g.note.trim() ? { note: g.note.trim() } : {}) });
    }
  });
  return out.sort((a, b) => a.level - b.level || a.slot - b.slot);
}

// Roll a `rolls` group's table. `d100()` supplies each percentile roll and
// `count` how many results are wanted; both are passed in so the wizard, the
// NPC generator and the tests drive one walk.
//
// Returns { picks, log }: the option names taken, and one log line per d100 -
// { roll, names, taken } - where `taken` is the name that roll took, null when
// it was rolled again (every result in its band already held), and undefined
// when the band prints several results still open, which is left for the
// player rather than ruled on, as a pick-one roll leaves it.
//
// Bounded: a table cannot give more results than it has rows, and the walk
// stops after a fixed number of rolls rather than spin on a nearly full table.
export function rollAbilityTable(group, count, d100) {
  const bands = abilityRollBands(group);
  const picks = [];
  const log = [];
  if (!bands) return { picks, log };
  // One result per BAND: a band printing two results is one landing, left open.
  const want = Math.min(Math.max(0, +count || 0), new Set(bands.map((b) => `${b.lo}-${b.hi}`)).size);
  let open = want;
  // Bands left to the player; landing on one again is a repeat like any other.
  const left = new Set();
  for (let guard = 0; open > 0 && guard < 500; guard++) {
    const roll = d100();
    const names = abilityRollMatches(bands, roll);
    const fresh = names.filter((n) => !picks.includes(n));
    const band = names.join('|');
    if (!fresh.length || left.has(band)) { log.push({ roll, names, taken: null }); continue; }
    if (fresh.length > 1) { left.add(band); log.push({ roll, names: fresh }); open--; continue; }
    picks.push(fresh[0]);
    log.push({ roll, names, taken: fresh[0] });
    open--;
  }
  return { picks, log };
}

// A race that rolls psionics on its OWN table (BOOK-INGEST-AUDIT F118).
//
// The book prints the odds (*"01-77 none, 78-90 minor ..."*) and the class
// stores them as a pick group whose options carry `psionics` blocks. Such a
// class states `psionics_allowed: false` beside the group, which switches the
// standard Random Psionics roll off whatever is picked - its own table has
// replaced that one - while an option's block is still merged by
// applyAbilities, which does not ask the flag.
//
// `abilityOffersPsionics` is what the Race briefing asks, so a flagged class
// with such a group is not told it has no psychic potential.
export function abilityOffersPsionics(cls) {
  const offered = new Set(abilityOptions(cls).map((n) => n.trim().toLowerCase()));
  return (cls?.special_abilities || []).some((e) => isAbilityDefinition(e)
    && e.psionics && offered.has(e.name.trim().toLowerCase()));
}

// The "None" options of a class that holds such a table and STILL rolls the
// standard one, or an empty list. `class-check` warns on it. Matched on the
// word, because the options are named for their band ("Psionics (01-77):
// None"); a no-psionics result spelled another way is missed, which is the
// safe direction for a warning.
export function psionicsTableLeftRolling(cls) {
  if (!cls || cls.psionics || cls.psionics_allowed === false) return [];
  const defs = new Map((cls.special_abilities || []).filter(isAbilityDefinition)
    .map((d) => [d.name.trim().toLowerCase(), d]));
  const out = [];
  for (const g of (cls.special_abilities || []).filter(isAbilityChoice)) {
    const names = (g.from || []).map((o) => (typeof o === 'string' ? o : o?.name)).filter(Boolean);
    if (!names.some((n) => defs.get(n.trim().toLowerCase())?.psionics)) continue;
    out.push(...names.filter((n) => /\bnone\b/i.test(n) && !defs.get(n.trim().toLowerCase())?.psionics));
  }
  return out;
}

// Whether taking or dropping this ability changes a pool the wizard has ALREADY
// ROLLED. Pools are rolled once and the later steps roll again only when there
// are none, so an ability swapped after the roll otherwise leaves the old
// numbers standing - BOOK-INGEST-AUDIT.md F67.
//
// Three shapes reach a pool: a `bonuses.pools` entry, F62/F64's
// `mdc_from_hp_sdc` (hit points and S.D.C. become one M.D.C. maximum), and a
// `psionics.isp_base`, which applyAbilities merges in and computePools rolls off
// the composed block - the Gypsy Gifted's four Gifts each state a different one.
// F67 named the first two; the third is the same defect, found by its premise
// audit, and leaving it out would have fixed six classes of the ten that have
// an ability of this kind.
export function abilityTouchesPool(def) {
  if (!def || typeof def !== 'object') return false;
  const pools = def.bonuses?.pools;
  return (!!pools && typeof pools === 'object' && Object.keys(pools).length > 0)
    || def.mdc_from_hp_sdc === true
    || def.psionics?.isp_base != null
    // A fourth shape since F128: the option states the pool's base itself.
    || ABILITY_POOL_BASES.some((k) => def[k] != null);
}

// A POOL BASE CARRIED BY A CHOSEN OPTION (BOOK-INGEST-AUDIT F128).
//
// A pool bonus adds to a base the class states, and rollPoolFormula keeps a
// null base null whatever the bonus. So a table whose rows decide whether the
// character is an M.D.C. being at all - the Phase World alien's "Base M.D.C."
// - had nothing to say it with: the row's M.D.C. was a bonus on no base, and
// rolled nothing.
//
//   - { name: "Damage Capacity (71-80): M.D.C. Being", mdc_base: "1d6x10" }
//
// The three keys are the class's own, with the class's own grammar, and on
// Nate's rulings (2026-10-12):
//
//   - an option that sets `mdc_base` makes the character an M.D.C. being
//     EXACTLY as a class-level `mdc_base` does - not a pool beside hit points;
//   - an option's base REPLACES a base the class states.
//
// "Exactly as a class-level one" is why this is its own function and not a
// line in applyAbilities. Everything that treats an M.D.C. class differently
// runs BEFORE the abilities are folded: combineClasses drops an occupation's
// hit points under an M.D.C. race, and compose.js's withCorePools fills in the
// core hit points and S.D.C. only when there is no `mdc_base`. Folded
// afterwards, the base would arrive on a character that had already been
// given both. So composeClass runs this on each half, before the two are
// combined, and the half then says what it would have said had the class
// stated the base itself. applyAbilities does not fold these keys.
//
// Each half reads only its own definitions, so a pick the other half defines
// is skipped here, as an undefined pick is. A later pick restating the same
// base wins, which is the order the picks were made in. The class is returned
// untouched - the same object - when no held option states a base.
export const ABILITY_POOL_BASES =['mdc_base', 'sdc_base', 'hit_points_base'];

export function applyAbilityPoolBases(cls, chosen) {
  const picks = normalizeAbilities(chosen);
  if (!cls || !picks.length) return cls;
  const byName = new Map((cls.special_abilities || [])
    .filter(isAbilityDefinition)
    .map((d) => [d.name.trim().toLowerCase(), d]));
  let out = cls;
  for (const { name } of picks) {
    const def = byName.get(name.toLowerCase());
    if (!def) continue;
    for (const k of ABILITY_POOL_BASES) {
      if (def[k] == null) continue;
      if (out === cls) out = { ...cls };
      out[k] = def[k];
    }
  }
  return out;
}

// AN ABILITY THAT GROWS BY LEVEL, AS TEXT (BOOK-INGEST-AUDIT F117).
//
// A China 2 Mystic Martial Art Power is a table from level 1 to 15: named
// techniques, I.S.P. and S.D.C. additions, combat bonuses. Only level 1 was
// stored, in the ability's description. On Nate's word (2026-10-04) the rest
// is DISPLAY ONLY - no catalog of powers, no levelled-ability reader - so the
// lines ride on the ability and the sheet shows the ones the character has
// reached, and the next one:
//
//   - name: "Mystic Martial Art Power: Gui Long Kung Fu (Dragon Blade)"
//     description: "Level 1: ..."
//     progression:
//       - { level: 2, text: "+1 to strike and parry with the blade." }
//       - { level: 3, text: "Blade Chi Strike: ..." }
//
// `level` is the CHARACTER's level. A class that learns the power late, or
// begins it part-way, writes its own levels: every class carries its own copy
// of the ability, so the lines are that class's.
//
// NOTHING ROLLS OR ADDS WHAT A LINE SAYS. A bonus the book grants at a level
// that should reach the sheet's numbers belongs in the class's own
// `bonuses.at_level`, as it always did.
export function abilityProgressionAt(ability, characterLevel) {
  const lvl = Number(characterLevel) || 1;
  const all = (Array.isArray(ability?.progression) ? ability.progression : [])
    .filter((l) => l && Number.isInteger(l.level) && typeof l.text === 'string')
    .map((l) => ({ level: l.level, text: l.text }))
    .sort((a, b) => a.level - b.level);
  return { reached: all.filter((l) => l.level <= lvl), next: all.find((l) => l.level > lvl) || null };
}

// The Horror Factor a chosen ability carries (BOOK-INGEST-AUDIT F119).
//
// Two keys on an ability option, both DISPLAY-ONLY like the class's own
// `horror_factor` (F75), which is the only thing either touches:
//
//   horror_factor: 10        RESTATES it while the option is held - a number or
//                            the book's phrase, exactly as on a class. The
//                            Felinoid is 9, and 10 as one of the larger cats.
//   horror_factor_bonus: 2   ADDS to it, summed across every held option - the
//                            Oni's head shape is "+2 Horror Factor" on its 11.
//
// THE NAMES FOLLOW THE CLASS AND THE VARIANT, where `horror_factor` is a
// replacing scalar (VARIANT_OVERRIDES). A `traits` row runs the other way -
// its `horror_factor` adds and `horror_factor_set` replaces - because a
// Morphus result adds far more often than it sets; an ability option sits on
// the class, so it reads like the class.
//
// A bonus needs a number to add to. Onto a phrase ("10+1D4") it is appended as
// written rather than guessed at, and with no factor at all it is the factor.
// Neither reaches a second form: a Morphus folds its own (js/second-form.js).
export const isHorrorFactor = (v) => (typeof v === 'number' && Number.isFinite(v))
  || (typeof v === 'string' && v.trim() !== '');

function withHorrorBonus(base, added) {
  if (!added) return base;
  if (base === undefined || base === null || String(base).trim() === '') return added;
  const n = typeof base === 'number' ? base : (/^\s*\d+\s*$/.test(String(base)) ? Number(base) : null);
  if (n !== null) return n + added;
  return `${String(base).trim()} ${added > 0 ? '+' : '-'}${Math.abs(added)}`;
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
  // The Horror Factor a held option restates, and what held options add to it
  // (BOOK-INGEST-AUDIT F119). Folded after the loop, because a restatement and
  // a bonus may come from different picks in either order.
  let horrorSet;
  let horrorAdded = 0;
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
    // Magic through the same fold. This line was `out.magic || def.magic`, which
    // gave the ability nothing whenever the class cast at all: its named spells
    // and its higher count were dropped. The class's own statements still win
    // key for key - the ability is the `born` side - which is the order that
    // stops an "innate" ability renaming how a Wizard casts. `type: none` is
    // left exactly as it was: the Godling states it on purpose, because its
    // magic is the occupation Magic Powers makes it pick (docs/leveling.md).
    if (def.magic && out.magic?.type !== 'none') out.magic = mergeMagic(def.magic, out.magic);
    // Super abilities ADD rather than defer to whichever side spoke first: a
    // Power Category states what its own page grants and a chosen option states
    // what the roll bought, and both are real. The merge also has to work from
    // NOTHING, because the commonest shape is a category granting none itself
    // and offering several packages - Experiments' Table C is six of them - so
    // `out.super_abilities` is usually undefined here and the option's block
    // arrives whole.
    if (def.super_abilities) {
      out.super_abilities = mergeSuperAbilities(out.super_abilities, def.super_abilities);
    }

    // The same fold for Talents, so an Elite Talent granted by a chosen
    // Morphus characteristic arrives whole when the class itself grants none.
    if (def.talents) {
      out.talents = mergeTalents(out.talents, def.talents);
    }
    // An ability that changes HOW MANY O.C.C. Related Skills the class grants.
    // BOOK-INGEST-AUDIT.md F24: the Gypsy Gifted rolls one of four psychic
    // profiles, and two of the four are master psychics who get NO related
    // skills where the other two get four. The count is a property of the
    // branch, and neither `variants` nor ABILITY_GRANTS could carry it -
    // VARIANT_OVERRIDES excludes the skills block on purpose, and an ability
    // carrying a whole `skills` block would be the same power by another name.
    //
    // This OVERRIDES one number rather than carrying a block, which is the
    // same size of power `skill_overrides` already has on a variant. It cannot
    // add a skill, change a category, or touch what the class teaches.
    //
    // Copy-on-write: `out` is a shallow copy of the class, so writing through
    // out.skills would mutate the caller's class object - and composeClass runs
    // this on every recompose.
    if (Number.isInteger(def.related_skills_count) && out.skills?.occ_related_skills) {
      out.skills = {
        ...out.skills,
        occ_related_skills: {
          ...out.skills.occ_related_skills,
          count: def.related_skills_count,
        },
      };
    }
    // An ability that turns S.D.C. and hit points into M.D.C. - F62's flag,
    // carried by a CHOICE. BOOK-INGEST-AUDIT F64: the Spirit Warrior converts
    // only through its Earth or Plant realm, three of six chosen, so a class key
    // would convert the four combinations with neither. A flag rather than a
    // block, folded on its own like related_skills_count above and for the same
    // reason kept out of ABILITY_GRANTS, whose keys are maps. The realm's extra
    // M.D.C. rides beside it as an ordinary pools.mdc bonus, so two converting
    // realms combine theirs, as printed 47 says they do.
    if (def.mdc_from_hp_sdc === true) out.mdc_from_hp_sdc = true;
    // A pool BASE an option states (F128) is NOT folded here: composeClass
    // folds it through applyAbilityPoolBases before the classes are combined,
    // because that is the only point at which it can count as the class's own.
    // A table row that prints the DICE an attribute is rolled on - the Amphib's
    // Appearance sets P.B. to 3D4, 2D6 or 1D6 (BOOK-INGEST-AUDIT F120). It
    // restates the class's dice for the attributes it names and leaves the
    // rest; the wizard rolls attributes off the composed class, after the pick.
    if (def.attribute_dice && typeof def.attribute_dice === 'object' && !Array.isArray(def.attribute_dice)) {
      out.attribute_dice = { ...(out.attribute_dice || {}), ...def.attribute_dice };
    }
    if (isHorrorFactor(def.horror_factor)) horrorSet = def.horror_factor;
    if (Number.isInteger(def.horror_factor_bonus)) horrorAdded += def.horror_factor_bonus;
    taken.push({ name: def.name, times: n, granted: true, ...(gm ? { gm: true } : {}),
      description: def.description, on_repeat: n > 1 ? def.on_repeat : undefined,
      // What the ability becomes as the character levels, in the book's own
      // words (BOOK-INGEST-AUDIT F117). Display only: the sheet lists it under
      // the ability, and nothing here adds a number.
      ...(Array.isArray(def.progression) && def.progression.length ? { progression: def.progression } : {}) });
  }
  const horror = withHorrorBonus(horrorSet !== undefined ? horrorSet : out.horror_factor, horrorAdded);
  if (horror !== undefined) out.horror_factor = horror;
  // What the character actually holds, for the sheet — as opposed to
  // special_abilities, which is what the class OFFERS.
  out.abilities_taken = taken;
  return out;
}
