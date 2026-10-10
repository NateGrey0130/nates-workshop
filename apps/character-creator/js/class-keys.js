// Every key a class's frontmatter may carry, stated once.
//
// Until 2026-10-10 this list lived in scripts/class-check-lib.mjs as
// KNOWN_KEYS, kept by hand beside a parser that never looked at it: the parser
// stores whatever YAML it finds, so a mistyped key - `hit_point_base` - parsed
// clean and was then read by nothing. class-check caught it for whoever ran
// class-check; the import tool and the class editor, which call the parser,
// said nothing.
//
// The parser warns from this list now, and class-check's KNOWN_KEYS is built
// from it, so there is one list and two readers. It is still a LITERAL list,
// for the reason its old header gave: the question is not "does the parser
// touch it" but "does anything downstream act on it", and that answer is
// spread across parser.js, compose.js, derive.js, app.js and sheet.js. A key
// is added here in the change that teaches something to read it.
//
// No imports, on purpose: parser.js imports this, and so does a Node script.

export const CLASS_KEYS = [
  'id', 'name', 'system', 'source_book', 'category',
  'attribute_requirements', 'attribute_maximums', 'attribute_dice',
  'hit_points_base', 'sdc_base', 'mdc_base', 'ppe_base',
  // The book's O.C.C. grouping for a class that prints no S.D.C. formula:
  // compose.js rolls 3D6 for true and 1D6 for false. Since 2026-09-25; it was
  // a map in compose.js before that.
  'men_of_arms',
  'starting_money', 'skills', 'equipment_starting', 'level_progression',
  'psionics', 'magic', 'bonuses', 'special_abilities', 'natural_abilities',
  'restrictions', 'side_effects', 'variants', 'extraction_notes',
  // A race with NO psychic potential. Fully modelled and always has been -
  // `rollsForPsionics()` in js/psionics.js skips the Random Psionics Table on
  // it, the wizard's Race briefing prints "no psychic potential", and the smoke
  // test pins both. It was missing from this list only because no published
  // class had used it: the first six that do are Palladium Fantasy races, and
  // they arrived reported as UNMODELLED. A false alarm here is worse than a
  // missing one, because the instruction attached to it is to delete the key or
  // change the app, and both would break a working field.
  'psionics_allowed',
  // A class's own experience chart, overriding the house-rule default.
  // `xpTableFor()` has honoured it since leveling.js was written, across six
  // call sites, and the smoke test pins the override - it was missing here only
  // because no published class had used one yet. Same false alarm
  // `psionics_allowed` gave, and worse than a missing entry for the same
  // reason: the instruction attached to UNMODELLED is to delete the key or
  // change the app, and both would break a working field.
  'xp_table',
  // Countable things a class hands out that are not pools - uses per day,
  // doses, charges. Drawn by the sheet through trackableRows()
  // (js/sheet-layout.js, apps/character-sheet/sheet.js) and documented in
  // class-import's frontmatter reference. Missing here only because no
  // published class used it until South America's Anti-Monster and Totem
  // Warrior (2026-09-25) - the same false alarm as the two keys above.
  'trackable_resources',
  // Which of the book's five groupings an O.C.C. belongs to, and which
  // occupations a race may take. Both are modelled and validated in
  // parser.js; a race's restrictions were free text and display-only until
  // the structured field landed beside them.
  'occ_group', 'occ_restrictions',
  // The mirror: which races may take an O.C.C. "none" is the human case,
  // because Rifts prints no Human R.C.C.
  'race_restrictions',
  // An O.C.C. whose book says the character stops being what it was - the
  // Cosmo-Knight's transformation. Read by combineClasses, which then takes the
  // occupation's pools and skills and the HIGHER of the two attribute dice.
  // BOOK-INGEST-AUDIT.md F11.
  'supersedes_race',
  // The narrow opt-in beside it: which of ppe_base and starting_money an O.C.C.
  // takes over from a race that states its own. Read by combineClasses.
  // BOOK-INGEST-AUDIT.md F111.
  'overrides_race',
  // The same two keys from the RACE's side: which occupation groups a race's
  // ppe_base or starting_money yields to. Read by combineClasses.
  // BOOK-INGEST-AUDIT.md F111, the Larhold part.
  'yields_to_occupation',
  // A race that keeps its own experience ladder in a pairing, where its book
  // says so. Read by combineClasses. BOOK-INGEST-AUDIT.md F122.
  'keeps_xp_table',
  // Which of a race's named occ_skills survive a pairing, where its book keeps
  // only a few - the Larhold's War Bison riding and W.P. Archery. Read by
  // combineClasses. BOOK-INGEST-AUDIT.md F114.
  'pairing_skills',
  // A class whose own attacks stand and whose Hand to Hand style adds none -
  // the Pneuma-Biforms' "do not add the melee round attacks from the hand to
  // hand combat skill". Read by bonusesFromSkills, carried by combineClasses.
  'ignores_style_attacks',
  // A class whose BOOK defines it as another class - "create the character as
  // usual" for the Euro-Juicer, "Same as the Ley Line Walker" for the Rifter -
  // is stored as a full copy, because nothing here composes one class from
  // another. `copy_of: { class: "<id>", except: [<top-level keys>] }` records
  // the relationship so an invariant can assert the two still match.
  //
  // It IS read, which is why it belongs on this list: test/regression.mjs walks
  // every declared pair against a database rebuilt from the repo. Nothing at
  // RUNTIME reads it, and that is the posture BOOK-INGEST-AUDIT.md F25 asks for
  // - assert, do not model.
  //
  // It also has to be here rather than left to report as UNMODELLED: the smoke
  // suite FAILS a shipped class that reports an unmodelled key, so a
  // declaration added without this entry turns the suite red rather than
  // printing a note. F25 guessed the opposite and its outcome note corrects it.
  'copy_of',
  // A pick from the shared `totems` catalog (BOOK-INGEST-AUDIT.md F56). Read by
  // composeClass, which folds the chosen row's skills and bonuses in, and by
  // the wizard, the validator and the sheet.
  'totem',
  // A mega-damage creature whose S.D.C. and hit points become one M.D.C. total
  // (BOOK-INGEST-AUDIT F62). Read by js/leveling.js's convertsToMdc, which the
  // wizard's pool roll, the validator and the level-up proposal all call.
  'mdc_from_hp_sdc',
  // Heroes Unlimited's fifth power kind, granted by a Power Category in the
  // R.C.C. slot. Read by combineClasses and applyAbilities in js/parser.js,
  // startingGroups in js/leveling.js, the wizard's Powers step, the create
  // validator and the sheet.
  'super_abilities',
  // Nightbane Talents, the NINTH catalog (migration 063, BOOK-INGEST-AUDIT
  // F76). The only power here that costs something to HAVE as well as to USE,
  // which is why it is neither a spell nor a psionic power. Read by
  // combineClasses and applyAbilities in js/parser.js, startingGroups and
  // talentGrantsFor in js/leveling.js, the wizard's Powers step, the create
  // validator and the sheet.
  'talents',
  // A Horror Factor the character PROJECTS, as a number or as the phrase the
  // book prints. Modelled in js/parser.js - validated there, carried by
  // combineClasses, overridable by a variant - and rendered by sheet.js beside
  // the pools. NOT the save of the same name, which is a `bonuses.saves` key.
  // BOOK-INGEST-AUDIT F75.
  'horror_factor',
  // A second body the character changes into in play - the Nightbane's Morphus
  // (BOOK-INGEST-AUDIT F74, survey D5). Validated in js/parser.js, carried by
  // combineClasses, folded into numbers by js/second-form.js, stored on
  // `characters.second_form` (migration 069), levelled by js/leveling.js and
  // drawn by sheet.js behind its form toggle.
  'second_form',
  // Authored class tags - `tags: [stealth, wilderness]` - that the wizard's
  // Race and Occupation steps filter on and the guided quiz scores. The
  // vocabulary and its validation are CLASS_TAGS in js/parser.js.
  'tags',
];

// Produced by the parser from the body, never written by hand. A class that
// states one in its frontmatter is not refused for it - the body wins.
export const PRODUCED_KEYS = ['lore', 'gm_notes', 'sections'];

// The keys the app reads UNDER `skills`. The history of why each is here, and
// of the two easy to miss, is with unmodelledSkillKeys in
// scripts/class-check-lib.mjs.
export const SKILLS_KEYS = [
  'occ_skills', 'occ_related_skills', 'secondary_skills', 'skill_programs', 'mos',
  // js/hand-to-hand.js, parser.js, app.js, sheet.js, _lib/skill-picks.js - the
  // class's price list for changing or buying a Hand to Hand style.
  'hand_to_hand',
];

// WHAT A RACE AND AN OCCUPATION DO WITH EACH KEY when one character holds
// both. combineClasses() in parser.js starts from a copy of the race, so a key
// it never mentions is the race's - which is the right answer for an id and
// was the wrong one for `trackable_resources` and `side_effects`, dropped from
// every paired occupation until 2026-10-10 because nobody had to decide.
//
// So every key decides, here. smoke.mjs fails on a key with no rule, and runs
// each plain rule against combineClasses itself, so a rule written here and
// not implemented there fails too.
//
//   race              the race's, always. The occupation's is not carried:
//                     either it describes the class rather than the character
//                     (id, tags, occ_group), or it is read off the raw class
//                     before the two are combined (men_of_arms, variants).
//   race-first        the race's where it states one, else the occupation's.
//                     Physiology: a dragon's hit points are a dragon's.
//                     combineClasses loops over these.
//   occupation-first  the occupation's where it states one, else the race's.
//   concat            both lists, the race's first. combineClasses loops.
//   flag              true if either side says so.
//   custom            its own code in combineClasses, with its reason there.
export const CLASS_MERGE = {
  id: 'race', system: 'race', source_book: 'race', category: 'race',
  // "<race> <occupation>".
  name: 'custom',
  attribute_dice: 'race-first', hit_points_base: 'race-first', sdc_base: 'race-first',
  mdc_base: 'race-first', ppe_base: 'race-first', starting_money: 'race-first',
  horror_factor: 'race-first', second_form: 'race-first',
  // The stricter of the two, key by key.
  attribute_requirements: 'custom', attribute_maximums: 'custom',
  // Read by compose.js off the occupation, then the race, before they combine.
  men_of_arms: 'race',
  // The lists union by name and the allowances are the occupation's.
  skills: 'custom',
  equipment_starting: 'concat', level_progression: 'concat', special_abilities: 'concat',
  natural_abilities: 'concat', restrictions: 'concat',
  // Each through its own merge function; bonuses sum.
  psionics: 'custom', magic: 'custom', super_abilities: 'custom', talents: 'custom', bonuses: 'custom',
  // Joined by name, the race's row winning a shared one.
  trackable_resources: 'custom',
  // One side keeps its own shape; two become a list.
  side_effects: 'custom',
  // Applied to each class before the two are combined.
  variants: 'race',
  extraction_notes: 'race', copy_of: 'race', tags: 'race',
  // False from the occupation closes it; nothing reopens it.
  psionics_allowed: 'custom',
  // The occupation's, unless the race keeps its own ladder.
  xp_table: 'custom',
  // Read off the raw classes: by the pickers, and by combineClasses from the
  // side that owns each.
  occ_group: 'race', occ_restrictions: 'race', race_restrictions: 'race',
  overrides_race: 'race', yields_to_occupation: 'race', keeps_xp_table: 'race',
  pairing_skills: 'race',
  supersedes_race: 'flag', ignores_style_attacks: 'flag', mdc_from_hp_sdc: 'flag',
  totem: 'occupation-first',
  // The race's page is the character's; the occupation's body is its own page.
  lore: 'race', gm_notes: 'race', sections: 'race',
};

/** The keys that merge by one rule, in the order CLASS_MERGE states them. */
export function keysMergedBy(rule) {
  return Object.keys(CLASS_MERGE).filter((k) => CLASS_MERGE[k] === rule);
}

const TOP = new Set([...CLASS_KEYS, ...PRODUCED_KEYS]);
const UNDER_SKILLS = new Set(SKILLS_KEYS);

/** Top-level keys of a parsed class that nothing reads. */
export function unknownClassKeys(data) {
  if (!data || typeof data !== 'object') return [];
  return Object.keys(data).filter((k) => !TOP.has(k));
}

/** Keys under `skills` that nothing reads. */
export function unknownSkillsKeys(data) {
  const skills = data && typeof data === 'object' ? data.skills : null;
  if (!skills || typeof skills !== 'object' || Array.isArray(skills)) return [];
  return Object.keys(skills).filter((k) => !UNDER_SKILLS.has(k));
}
