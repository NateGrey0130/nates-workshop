// The wizard's state: what a fresh one holds, and which of its keys are the
// build.
//
// Its own module, with no DOM in it, so the test suite can import it. The
// object used to be a literal in app.js beside two hand-kept lists - the keys
// a draft persists and the keys resetBuild clears - and the three disagreed:
// skill programs and Talent picks were never saved in a draft, Talent picks
// survived "Create another character" into the next class, and `programs`
// did not exist at all on a resumed draft, so a skill-program class threw on
// its first render. Every key is now declared in freshState() and named in
// exactly one of the four lists below, and smoke.mjs fails on one that is not.

export function freshState() {
  return {
    step: 0, system: null, classMode: 'browse', quiz: [null, null, null],
    // An unfinished build found on the server, awaiting resume-or-discard.
    draftOffer: null,
    // Showing the home view rather than a wizard step - UI-AUDIT F39.
    home: false,
    // The updated_at of the draft this tab believes it owns, sent with every
    // save so the server can refuse to overwrite someone else's newer one.
    // null means "there is no draft and I expect to create it".
    draftVersion: null,
    draftNote: null,
    // A class asked for by a link (?class=): the one found, or the id that was not.
    classOffer: null, classMissing: null,
    draftConflict: null,
    // Two class fields, and the difference matters. `rcc` is what the player
    // PICKED on the Race step — raw, unresolved, still carrying its variants and
    // its choose-groups, which is what that step's pickers read. `cls` is what
    // the character IS: variant applied, occupation composed in, abilities folded
    // in. Nothing after the Occupation step knows there were ever two.
    //
    // It used to be one field that `confirmClass` overwrote in place, which was
    // fine while both halves were chosen on the same step and is not any more:
    // adding an occupation two steps later has to re-compose from the original.
    classes: [], rcc: null, cls: null,
    // The race half alone, composed. Kept because its dice bonuses are rolled and
    // read on the Attributes step, and choosing an occupation afterwards must not
    // re-roll a number the player has already seen.
    raceCls: null,
    attrMethods: {}, attrs: {}, attrRolls: {},
    // `mos` is a LIST since BOOK-INGEST-AUDIT.md F82 - `skills.mos.choose` may
    // ask for more than one, and until F82 it was validated and then ignored.
    related: [], secondary: [], groupPicks: {}, mos: [], totem: null,
    // Chosen skill PROGRAMS, by category name (BOOK-INGEST-AUDIT.md F23(b)).
    // Declared here since 2026-10-10: it used to exist only once resetBuild had
    // run, which a resumed draft never did.
    programs: [],
    // Fold state of the skill pick groups, and how far the player has been.
    // Both belong to one class's build and neither is worth resuming.
    groupUi: {}, maxStep: 0,
    // Starting-gear choices the class leaves open, and the slugs picked for each,
    // keyed by the entry's index in equipment_starting.
    gearChoices: [], gearPicks: {},
    // Which stage of the class, for classes that come in stages (a Dragon
    // hatchling vs an adult). NULL for every class that has none.
    variant: null,
    // The O.C.C. taken alongside an R.C.C., and its own stage. A racial class
    // grants no related or secondary skills — those come from the occupation —
    // so an R.C.C. character without one is deliberately thin.
    occ: null, occVariant: null,
    equipment: [], equipInit: false,
    // The last item removed on the Equipment step, for its one-step undo.
    removedEquip: null,
    charName: '', campaignId: null, newCampaign: '',
    spells: [], psi: [], bio: {},
    // The starting sum in `bio.money` was typed by the player, so re-rolling
    // the pools must not replace it.
    moneyTyped: false,
    // Super abilities chosen at level 1. `supers` is the flat list and
    // `superGroups` the per-group one, exactly as spells and psionics have both -
    // except that no Power Category uses the flat form, since every one that
    // grants abilities splits them by tier. It exists so the three kinds stay the
    // same shape and `powerList` needs no special case.
    supers: [],
    talents: [],
    // Step 3. psiRoll is {roll, tier} once rolled — null means not yet rolled,
    // and a tier of null is a real result (26-00, no psionics) rather than an
    // absence, so the two must stay distinguishable.
    psiRoll: null, psiShape: null, psiCategory: null, psiTrimmed: 0,
    // The Age table's ×2 for long-lived races, and the percentile each field
    // last rolled — shown so a result can be checked against the book.
    longLived: false, bioRolls: {},
    // A class may state an attribute bonus as dice ("add 2D6 to P.S."). Rolled
    // once here and stored, because it cannot be re-evaluated on every render.
    attrBonuses: {},
    // What a class's DICE combat/save bonuses came up. Rolled once, like
    // attrBonuses, because both are read at render time.
    rolledBonuses: { combat: {}, saves: {} },
    // The occupation's own dice bonuses, rolled when it is chosen and kept apart
    // from the race's — so switching occupation re-rolls its half and leaves the
    // race's alone. rolledAll() is the only thing that sees them summed.
    occAttrBonuses: {}, occRolledBonuses: { combat: {}, saves: {} },
    totemAttrBonuses: {}, totemRolledBonuses: { combat: {}, saves: {} },
    // A character may start above level 1. Everything the levels earn is resolved
    // on the Advancement step, which exists only while this is above 1.
    level: 1,
    // What the levels above 1 rolled and chose. Held apart from the level-1
    // build rather than folded into it, because the two are answerable to
    // different rules: a skill picked at level 5 starts at its catalog base and
    // is NOT back-dated, while a skill held since level 1 advances per level.
    // levelSpells is keyed by grant index, not a flat list: a spell's allowed
    // LEVEL can depend on which level earned it, so the two gained at level 2 are
    // a different choice from the two gained at level 5 and cannot share a pool.
    // levelPsi stays flat - no book states a per-level cap on psionic powers.
    // levelPsi is keyed by grant index for the same reason levelSpells is: a
    // psionic grant can name its own CATEGORIES, and the Mystic's level-4 power
    // comes from Super while its starting ones came from Sensitive and Healing.
    levelPools: {}, levelSpells: {}, levelPicks: {}, levelPsi: {}, levelSupers: {}, levelTalents: {},
    // The level-1 picks when the class SPLITS them across restrictions - the
    // Delphi Juicer's "3 Physical + 1 Super". Keyed by group index for the same
    // reason levelSpells is, and separate from the flat `spells`/`psi` on
    // purpose: a class with one starting group keeps writing into those, so no
    // draft saved before this existed changes shape.
    spellGroups: {}, psiGroups: {}, superGroups: {}, talentGroups: {},
    // What the class offered at level 1 when those picks were made, per kind.
    // See pruneStartingPicks.
    startShape: {},
    // Attributes re-rolled because a chosen O.C.C. raised a minimum the original
    // roll missed. Kept so the assist is visible as one rather than presented as
    // what the dice said first — posted as play events once the character exists.
    minRerolls: [],
    // Abilities picked from a class's choice group. A LIST, not a set: some are
    // repeatable and the second take means something different.
    abilities: [],
    // The Morphus (Nightbane survey D5): the generator's DECISIONS, in order, and
    // the second form's own rolls. Everything else - what is resolved, what is
    // pending - is replayed from the decisions by js/morphus.js, so undo is
    // dropping the last one and the draft holds nothing derived. `formSig` is the
    // composed class's second_form as JSON, so a different occupation that brings
    // a different form re-rolls the form's dice and keeps the table results.
    morphus: { decisions: [], form: null, formSig: null },
    // The traits catalog's rows, fetched the first time the Morphus step renders
    // and never persisted: a catalog, not the build.
    traitTables: null, traitError: null, morphusError: null,
    pools: null, savedId: null, saving: false,
    skillCatalog: [], items: [], campaigns: [], existing: [],
    // Retired gear slugs → the slug they resolve to now. See findItem().
    itemRedirects: {},
    spellCatalog: [], psiCatalog: [], superCatalog: [], me: null, isAdmin: false,
    talentCatalog: [], totemCatalog: [],
    // The catalogs as fetched, before a game system's own numbers are applied.
    skillCatalogRaw: [], psiCatalogRaw: [], skillSystemBases: [], psionicSystemCosts: [],
    // Picker filter text. Transient view state, never persisted in a draft —
    // resuming a build should not resume half a search.
    gearFilter: '', relatedFilter: '', secondaryFilter: '', spellFilter: '', psiFilter: '',
    superFilter: '',
    talentFilter: '',
    classFilter: '',
    // Tag chips pressed on the Race and Occupation steps. Same posture as the
    // filter text: view state, never persisted.
    classTagFilter: [], occTagFilter: [],
  };
}

// THE BUILD: what the player rolled and chose for one class. Saved in a draft,
// and cleared when the class or the game system changes. A new pick the wizard
// learns to hold belongs here unless there is a reason it does not.
export const BUILD_KEYS = [
  'variant', 'occ', 'occVariant', 'attrMethods', 'attrs', 'attrRolls', 'related', 'secondary',
  'groupPicks', 'gearPicks', 'mos', 'totem', 'programs', 'equipment', 'equipInit', 'moneyTyped', 'spells',
  'psi', 'bio', 'pools', 'longLived', 'bioRolls', 'psiRoll', 'psiShape', 'psiCategory',
  'attrBonuses', 'rolledBonuses', 'abilities', 'occAttrBonuses', 'occRolledBonuses',
  'totemAttrBonuses', 'totemRolledBonuses', 'minRerolls', 'level', 'levelPools', 'levelSpells',
  'levelPsi', 'levelPicks', 'spellGroups', 'psiGroups', 'supers', 'superGroups', 'levelSupers',
  'talents', 'talentGroups', 'levelTalents', 'morphus', 'startShape',
];

// Saved in a draft and KEPT across a class change: where the player is and
// who the character is, which no class decides.
export const KEPT_KEYS = [
  'step', 'system', 'classMode', 'quiz', 'charName', 'campaignId', 'newCampaign',
];

// Cleared with the build and NOT saved: derived from the class on resume, or
// view state that belongs to one class's screens.
export const DERIVED_KEYS = [
  'raceCls', 'cls', 'gearChoices', 'groupUi', 'maxStep', 'psiTrimmed', 'removedEquip',
  'morphusError',
];

// Neither: the catalogs, which are large, shared and stale the moment they are
// written down; who is signed in; the picked class itself, which a draft stores
// as an id; filter text; and the draft's own bookkeeping.
export const SESSION_KEYS = [
  'draftOffer', 'home', 'draftVersion', 'draftNote', 'draftConflict', 'classOffer',
  'classMissing', 'classes', 'rcc', 'traitTables', 'traitError', 'savedId', 'saving',
  'skillCatalog', 'items', 'campaigns', 'existing', 'itemRedirects', 'spellCatalog',
  'psiCatalog', 'superCatalog', 'me', 'isAdmin', 'talentCatalog', 'totemCatalog',
  'skillCatalogRaw', 'psiCatalogRaw', 'skillSystemBases', 'psionicSystemCosts', 'gearFilter',
  'relatedFilter', 'secondaryFilter', 'spellFilter', 'psiFilter', 'superFilter', 'talentFilter',
  'classFilter', 'classTagFilter', 'occTagFilter',
];

// The level-1 power picks, by kind: the flat list a class with one starting
// group writes into, and the per-group map a class that splits them uses.
export const STARTING_PICK_KINDS = [
  { kind: 'spell', flat: 'spells', groups: 'spellGroups' },
  { kind: 'psionic', flat: 'psi', groups: 'psiGroups' },
  { kind: 'super', flat: 'supers', groups: 'superGroups' },
  { kind: 'talent', flat: 'talents', groups: 'talentGroups' },
];

// Drops the level-1 power picks of any kind whose offer has changed.
//
// A group pick is stored under its group's INDEX, so it cannot be matched to
// "the same group" in a different class: the Biomancer's group 0 and another
// caster's group 0 are different lists. And nothing cleared these when the
// occupation, the variant or the race changed, so a Cyber-Knight who had been
// a Biomancer for one step kept three spells, showed them on Review and sent
// them to the server. So the picks of a kind live exactly as long as what the
// class offers of that kind stays the same, and `shapeOf(kind)` says what
// that is - the caller passes the composed class's starting groups.
//
// The first call for a build records and drops nothing: a draft saved before
// `startShape` existed resumes with its picks intact.
export function pruneStartingPicks(state, shapeOf) {
  const seen = state.startShape || (state.startShape = {});
  const dropped = [];
  for (const { kind, flat, groups } of STARTING_PICK_KINDS) {
    const now = JSON.stringify(shapeOf(kind) ?? null);
    if (kind in seen && seen[kind] !== now) {
      if ((state[flat] || []).length || Object.keys(state[groups] || {}).length) dropped.push(kind);
      state[flat] = [];
      state[groups] = {};
    }
    seen[kind] = now;
  }
  return dropped;
}

// An explicit allowlist, not a copy of the state: everything here is the build
// itself.
export const DRAFT_KEYS = [...KEPT_KEYS, ...BUILD_KEYS];

// Fresh values for everything a class change clears. Read off freshState()
// rather than restated, so a default is written once.
export function freshBuild() {
  const fresh = freshState();
  return Object.fromEntries([...BUILD_KEYS, ...DERIVED_KEYS].map((k) => [k, fresh[k]]));
}
