// The codex — every spell, psionic power, piece of gear, vessel, skill, class,
// Talent and super ability, and what each one is. SECTIONS below is the list;
// this sentence has gone stale before.
//
// Read-only by construction: this file makes only GETs and has no write path to
// leave out. That is the point of it being its own page rather than the catalog
// editor unlocked — see functions/.../codex.js and
// docs/plans/20-power-descriptions.md.
//
// A classic script, like sheet.js and js/api.js: it imports nothing, and a
// module would only cost the inline-handler ergonomics for no gain.
//
// Handlers are DELEGATED rather than inline. A row's key is its name or slug,
// and a name with an apostrophe in it — "Ba'al's Blessing" — is exactly the
// case where an inline onclick built by string concatenation breaks: escHtml
// makes it look right in the markup and hands the handler a syntax error. The
// list listens once and reads a data attribute instead. This matters MORE now
// than it did with two catalogs: gear names carry double quotes as well
// ("Rolling Thunder" All-Purpose Vehicle is a real row, and smoke.mjs pins it).
//
// ── ONE DESCRIPTOR PER SECTION, RATHER THAN A BRANCH PER FUNCTION ──
//
// This page used to serve two catalogs and branched on `S.tab` inside five
// separate functions. Four sections through that shape is the same if/else
// written five times, so each section now declares what it is and the render
// walks the declaration.
//
// A WORD ON THE `cost` SLOT, because it does NOT mean the same thing in all
// four: for spells it is P.P.E., for psionics I.S.P., for gear a PRICE in
// credits or gold, and for a vessel a price too. It is the right-hand column of
// a row, not a currency. A section returns '' when it has nothing to put there
// - Classes and Super Abilities always do - and Talents put TWO figures in it.

const SECTIONS = [
  {
    id: 'spells',
    groupNoun: 'level',
    label: 'Spells',
    key: (r) => String(r.name).toLowerCase(),
    title: (r) => r.name,
    meta: (r) => (r.level != null ? `Level ${r.level}` : 'Unleveled'),
    cost: (r) => (r.ppe != null ? `${r.ppe}${r.ppe_note ? '+' : ''} P.P.E.` : ''),
    stats: (r) => [['Range', r.range], ['Duration', r.duration], ['Damage', r.damage],
                   ['Saving throw', r.saving_throw], ['Area of effect', r.area_of_effect],
                   ['Casting time', r.casting_time]],
    notes: (r) => [r.ppe_note && `Cost varies — ${r.ppe_note}`,
                   r.variant_note && `An earlier book prints: ${r.variant_note}`],
    // The tradition's name too, so "warlock" or "ocean" finds the fold.
    hay: (r) => `${r.name} ${r.source_book || ''} ${r.tradition ? SpellTraditions.label(r.tradition) : ''}`,
  },
  {
    id: 'psionics',
    groupNoun: 'category',
    label: 'Psionics',
    key: (r) => String(r.name).toLowerCase(),
    title: (r) => r.name,
    meta: (r) => r.category || 'Uncategorised',
    cost: (r) => (r.isp != null ? `${r.isp}${r.isp_note ? '+' : ''} I.S.P.` : ''),
    stats: (r) => [['Range', r.range], ['Duration', r.duration], ['Saving throw', r.saving_throw]],
    notes: (r) => [r.isp_note && `Cost varies — ${r.isp_note}`,
                   r.variant_note && `An earlier book prints: ${r.variant_note}`,
                   r.min_tier && `Requires a ${r.min_tier} psychic.`],
    hay: (r) => `${r.name} ${r.source_book || ''} ${r.category || ''}`,
  },
  {
    id: 'gear',
    groupNoun: 'category',
    label: 'Gear',
    // ONE ENTRY PER NAME, NOT PER ROW. The table holds a row for every book
    // that prints an item, so `r` here is an entry from name-groups.js: its
    // `printings` are the rows. An item one book prints reads exactly as it did
    // as a bare row; an item several print says so on its line, and opens to a
    // line per book with that book's price and whatever else it prints
    // differently (see printingsHtml).
    countKey: 'gear_names',
    fold: (rows) => NameGroups.fold(rows),
    narrow: (r, system) => NameGroups.narrow(r, system),
    resolve: (rows, key) => NameGroups.resolve(rows, key),
    key: (r) => r.key,
    // Every printing's slug, because a character holds ONE printing and
    // me/holdings is keyed by the slug it holds.
    keys: (r) => r.slugs,
    title: (r) => r.name,
    badge: (r) => (r.printings.length > 1
      ? ` <span class="tag codex-books">${r.printings.length} books</span>` : ''),
    // Four names are `gear` in one book and `weapon` in another. The line shows
    // both and the category menu finds the entry under either.
    groups: (r) => [...new Set(r.printings.map((p) => p.category || 'Uncategorised'))],
    meta: (r) => [...new Set(r.printings.map((p) => p.category || 'Uncategorised'))].join(' · '),
    // Each distinct price once: three books at two prices is two figures.
    cost: (r) => [...new Set(r.printings.map((p) => money(p.cost, p.system, p.cost_note)).filter(Boolean))].join(' · '),
    // Only what this row has; a knife should not print an empty A.R. See
    // `have` in statBlock(). Weight is last because it is the one figure that
    // is about carrying rather than fighting. With several books, only what
    // they all AGREE on prints here; the rest is on each book's own line.
    stats: (r) => gearStats(r.printings[0]).filter((_, i) => agrees(r, gearStats, i)),
    extra: (r) => (r.printings.length > 1 ? printingsHtml(r, GEAR_LINES) : ''),
    textHtml: (r) => printingsTextHtml(r),
    foot: (r) => (r.printings.length > 1 ? `${r.printings.length} books` : r.source_book),
    // A NULL price is a finished row, not an unfinished one — books print
    // issued kit and unique artifacts with no price at all, and the schema says
    // so at length. The entry says nothing rather than showing an em dash that
    // reads as missing data.
    // A row that is really a VESSEL says so, and names the vessel rather than
    // its slug. 24 rows carry `category = 'vehicle'` and a full stat block from
    // before `vehicles` existed; as each book session transcribes one, the gear
    // row stays put — class markdown cites it by slug — and gains a pointer.
    // `vessel_name` is NULL when the pointer names a vessel not yet imported,
    // which migration 053 allows on purpose, so that case says the honest thing
    // instead of printing a slug that looks like a name.
    // With several books these two notes belong to ONE of them, so they move to
    // that book's line.
    notes: (r) => (r.printings.length > 1 ? [] : [
      r.printings[0].cost_note && `Price: ${r.printings[0].cost_note}`,
      vesselNote(r.printings[0]),
    ]),
    hay: (r) => `${r.name} ${r.printings.map((p) => `${p.source_book || ''} ${p.category || ''}`).join(' ')}`,
  },
  {
    id: 'vehicles',
    groupNoun: 'class',
    label: 'Vessels',
    // One entry per name, as Gear is and for the same reason: Heroes Unlimited
    // and Nightbane print the same 35 present-day vehicles, figure for figure,
    // and listed them twice (production, 2026-10-02: 463 rows, 428 names).
    countKey: 'vehicle_names',
    fold: (rows) => NameGroups.fold(rows),
    narrow: (r, system) => NameGroups.narrow(r, system),
    resolve: (rows, key) => NameGroups.resolve(rows, key),
    key: (r) => r.key,
    keys: (r) => r.slugs,
    title: (r) => r.name,
    badge: (r) => (r.printings.length > 1
      ? ` <span class="tag codex-books">${r.printings.length} books</span>` : ''),
    groups: (r) => [...new Set(r.printings.map((p) => p.vehicle_class || 'Unclassed'))],
    meta: (r) => [...new Set(r.printings.map((p) => p.vehicle_class || 'Unclassed'))].join(' · '),
    cost: (r) => [...new Set(r.printings.map((p) => money(p.cost, p.system, p.cost_note)).filter(Boolean))].join(' · '),
    // THE MAIN BODY IS LISTED HERE AND DID NOT USED TO BE. While every vessel
    // in the table was a Rifts machine with a locations block, the number was
    // reachable through the by-location list; Heroes Unlimited's vehicles mostly
    // print ONE figure and no breakdown, so 46 of its 49 showed crew, speeds and
    // dimensions with no durability anywhere on the card.
    //
    // THE LABEL IS THE UNIT, which is why it is computed. `mdc_main_body` holds
    // S.D.C. when `is_mega_damage` is 0 (migration 062), and one M.D.C. point
    // absorbs a hundred S.D.C. - a fixed "M.D.C." would overstate a Patton's
    // 1000 a hundredfold.
    stats: (r) => vesselStats(r.printings[0]).filter((_, i) => agrees(r, vesselStats, i)),
    // The two things a vessel has that no other catalog row does, and the whole
    // reason `vehicles` is three tables rather than one.
    extra: (r) => (r.printings.length > 1 ? printingsHtml(r, VESSEL_LINES) : '') + vesselBlocksHtml(r),
    textHtml: (r) => printingsTextHtml(r),
    foot: (r) => (r.printings.length > 1 ? `${r.printings.length} books` : r.source_book),
    notes: (r) => (r.printings.length > 1 ? [] : [r.printings[0].cost_note && `Price: ${r.printings[0].cost_note}`]),
    hay: (r) => `${r.name} ${r.printings.map((p) => `${p.source_book || ''} ${p.vehicle_class || ''}`).join(' ')}`,
  },
  // UI-AUDIT F48. Appended rather than placed first so the default tab and every
  // #spells / #gear link already sent keep opening where they did.
  {
    id: 'skills',
    groupNoun: 'category',
    label: 'Skills',
    key: (r) => String(r.name).toLowerCase(),
    title: (r) => r.name,
    meta: (r) => r.category || 'Uncategorised',
    cost: (r) => (r.base ? `${r.base}%${r.per_level ? ` +${r.per_level}/lvl` : ''}` : (r.base_formula ? 'formula' : '')),
    stats: (r) => [['Base', r.base ? `${r.base}%` : null], ['Per level', r.per_level ? `+${r.per_level}%` : null],
                   ['From attributes', r.base_formula]],
    notes: () => [],
    // The catalog has never held skill descriptions, so an empty text line would
    // read as "not imported yet" when there is nothing to import.
    noText: true,
    hay: (r) => `${r.name} ${r.source_book || ''} ${r.category || ''}`,
  },
  {
    id: 'classes',
    groupNoun: 'class type',
    label: 'Classes',
    key: (r) => String(r.slug).toLowerCase(),
    title: (r) => r.name,
    meta: (r) => (r.category === 'rcc' ? 'R.C.C.' : r.category === 'occ' ? 'O.C.C.' : (r.category || '')),
    cost: () => '',
    stats: (r) => [
      ['Type', r.category === 'rcc' ? 'Racial character class' : r.category === 'occ' ? 'Occupational character class' : null],
      ['System', SYSTEM_LABEL[r.system] || r.system],
    ],
    // The way from reading a class to playing one. A LINK, not a write: the
    // wizard takes `?class=<slug>` and does the rest, including asking before
    // it replaces a build already under way (there is one draft per person).
    // So this page stays read-only by construction, as the smoke test holds it.
    extra: (r) => `<p class="noprint"><a class="btn btn-sm" href="/apps/character-creator/?class=${
      encodeURIComponent(r.slug)}">Start a character with this class</a></p>`,
    notes: () => [],
    hay: (r) => `${r.name} ${r.source_book || ''} ${r.category || ''}`,
  },
  // Nightbane Talents (docs/plans/22-codex-powers-and-talents.md). Appended, for
  // the reason F48's two were.
  //
  // THE COST SLOT CARRIES TWO NUMBERS HERE, and that is the point of the row: a
  // Talent is bought once with PERMANENT P.P.E. and paid for again at every
  // use, which is why it has a table of its own (migration 063). One figure in
  // that column would be the wrong one whichever it was. `ppe` is the activation
  // MINIMUM and 0 means the book prints a schedule instead, so 0 reads as
  // "varies" and the schedule is in the notes - 22 of the 25 have one.
  {
    id: 'talents',
    groupNoun: 'tier',
    label: 'Talents',
    key: (r) => String(r.name).toLowerCase(),
    title: (r) => r.name,
    meta: (r) => TALENT_TIER[r.tier] || '',
    cost: (r) => `${r.acquire_ppe} to acquire · ${talentUse(r)}`,
    stats: (r) => [['To acquire', `${r.acquire_ppe} P.P.E., permanently`],
                   ['To use', talentUse(r)],
                   ['Minimum level', r.min_character_level],
                   ['Form', TALENT_FORM[r.form_required] || r.form_required],
                   ['Requires', r.prerequisite],
                   ['Range', r.range], ['Duration', r.duration],
                   ['Saving throw', r.saving_throw]],
    notes: (r) => [r.ppe_note && `Cost to use — ${r.ppe_note}`,
                   r.variant_note && `A different book prints: ${r.variant_note}`],
    hay: (r) => `${r.name} ${r.source_book || ''} ${r.tier || ''}`,
  },
  // Heroes Unlimited super abilities (plan 22), and THE ONE SECTION WHOSE TEXT
  // DOES NOT ARRIVE WITH ITS LIST. 364 rows with their descriptions are 323 KB
  // gzipped, more than the first four sections together, so the list comes
  // without them and `detail` names the request that fetches one when its row
  // is opened - see loadDetail(). No other section defines `detail`, and
  // everything that reads a description goes through textOf() and hasText() so
  // that stays the only difference.
  //
  // No cost: a super ability is a permanent trait and has nothing to pay. Most
  // have no stat block either (41, 30, 22 and 7 rows carry a range, duration,
  // damage and save), which is why statBlock() printing only what a row HAS
  // matters more here than anywhere.
  //
  // 83 of them are named `Family: Name` - 36 under Alter Physical Structure
  // alone. There is no grouping UI, deliberately: the all-terms filter already
  // is one, and typing "alter physical" is the group.
  {
    id: 'super-abilities',
    groupNoun: 'tier',
    label: 'Super Abilities',
    key: (r) => String(r.name).toLowerCase(),
    title: (r) => r.name,
    meta: (r) => SUPER_TIER[r.tier] || '',
    cost: () => '',
    stats: (r) => [['Range', r.range], ['Duration', r.duration], ['Damage', r.damage],
                   ['Saving throw', r.saving_throw]],
    notes: (r) => [r.variant_note && `An earlier book prints: ${r.variant_note}`],
    hay: (r) => `${r.name} ${r.source_book || ''} ${r.tier || ''}`,
    detail: (r) => 'codex?section=super-ability&name=' + encodeURIComponent(r.name),
    detailText: (res) => (res['super-ability'] || {}).description,
  },
  // The named people the books stat (migration 072). The book's own numbers
  // for one person, then what it hits with (stat_attacks), then its prose. A
  // G.M. puts one in a campaign from the campaign page's People tab.
  {
    id: 'notables',
    label: 'Notable NPCs',
    key: (r) => String(r.slug).toLowerCase(),
    title: (r) => r.name,
    meta: (r) => r.title || r.occ || '',
    cost: (r) => (r.level ? `Level ${r.level}` : ''),
    stats: (r) => [['Real name', r.real_name], ['Race', r.race], ['Occupation', r.occ],
                   ['Alignment', r.alignment], ['Age', r.age],
                   ['Attributes', attributeLine(r.attributes)],
                   ['Hit points', r.hp], ['S.D.C.', r.sdc], ['M.D.C.', r.mdc],
                   ['P.P.E.', r.ppe], ['I.S.P.', r.isp], ['A.R.', r.ar],
                   ['Horror Factor', r.horror_factor], ['Combat', combatLine(r.combat)]],
    extra: (r) => notableSkillsHtml(r) + notableAttacksHtml(r),
    notes: (r) => [r.bonuses_note && `Bonuses: ${r.bonuses_note}`,
                   r.skills_note && `Other skills: ${r.skills_note}`,
                   r.natural_abilities && `Natural abilities: ${r.natural_abilities}`,
                   r.magic && `Magic: ${r.magic}`, r.psionics && `Psionics: ${r.psionics}`,
                   r.super_powers && `Super powers: ${r.super_powers}`,
                   r.cybernetics && `Cybernetics: ${r.cybernetics}`,
                   r.weapons_and_equipment && `Weapons and equipment: ${r.weapons_and_equipment}`,
                   r.disposition && `Disposition: ${r.disposition}`],
    hay: (r) => `${r.name} ${r.real_name || ''} ${r.title || ''} ${r.occ || ''} ${r.source_book || ''}`,
  },
  // The species the books stat (migration 074). Its numbers are the book's
  // DICE ("I.Q. 2D6", hit points "PE+20"): a G.M. rolls individuals from them
  // on the campaign page's People tab, and each one rolls separately.
  {
    id: 'creatures',
    groupNoun: 'kind',
    label: 'Creatures',
    key: (r) => String(r.slug).toLowerCase(),
    title: (r) => r.name,
    meta: (r) => [r.category, r.playable ? 'playable' : ''].filter(Boolean).join(' · '),
    cost: (r) => (r.horror_factor != null ? `H.F. ${r.horror_factor}` : ''),
    stats: (r) => [['Alignment', r.alignment], ['Attributes', attributeLine(r.attributes)],
                   ['Hit points', r.hp], ['S.D.C.', r.sdc], ['M.D.C.', r.mdc],
                   ['P.P.E.', r.ppe], ['I.S.P.', r.isp], ['Natural A.R.', r.ar],
                   ['Horror Factor', r.horror_factor], ['Combat', combatLine(r.combat)],
                   ['Size', r.size], ['Weight', r.weight], ['Life span', r.life_span],
                   ['Habitat', r.habitat]],
    extra: (r) => notableAttacksHtml(r),
    notes: (r) => [r.pools_note && `Pools as printed: ${r.pools_note}`,
                   r.bonuses_note && `Bonuses: ${r.bonuses_note}`,
                   r.skills_note && `Skills: ${r.skills_note}`,
                   r.natural_abilities && `Natural abilities: ${r.natural_abilities}`,
                   r.magic && `Magic: ${r.magic}`, r.psionics && `Psionics: ${r.psionics}`,
                   r.occ_note && `O.C.C.s: ${r.occ_note}`,
                   r.allies && `Allies: ${r.allies}`, r.enemies && `Enemies: ${r.enemies}`],
    hay: (r) => `${r.name} ${r.category || ''} ${r.habitat || ''} ${r.source_book || ''}`,
  },
];

// A notable NPC's eight attributes on one line, in the sheet's order and with
// the book's abbreviations.
const ATTR_LABELS = [['IQ', 'I.Q.'], ['ME', 'M.E.'], ['MA', 'M.A.'], ['PS', 'P.S.'],
                     ['PP', 'P.P.'], ['PE', 'P.E.'], ['PB', 'P.B.'], ['Spd', 'Spd.']];
function attributeLine(a) {
  if (!a || typeof a !== 'object') return '';
  return ATTR_LABELS.filter(([k]) => a[k] != null).map(([k, label]) => `${label} ${a[k]}`).join(', ');
}
// The combat totals as the book prints them: attacks, then each bonus signed.
const COMBAT_LABELS = [['attacks', 'attacks per melee'], ['initiative', 'initiative'], ['strike', 'strike'],
                       ['parry', 'parry'], ['dodge', 'dodge'], ['roll', 'roll'], ['pull', 'pull punch'],
                       ['disarm', 'disarm'], ['entangle', 'entangle'], ['damage', 'damage']];
function combatLine(c) {
  if (!c || typeof c !== 'object') return '';
  return COMBAT_LABELS.filter(([k]) => c[k] != null)
    .map(([k, label]) => (k === 'attacks' ? `${c[k]} ${label}` : `${c[k] >= 0 ? '+' : ''}${c[k]} ${label}`))
    .join(', ');
}
function notableSkillsHtml(r) {
  if (!Array.isArray(r.skills) || !r.skills.length) return '';
  return `<p class="small"><b>Skills:</b> ${r.skills
    .map((s) => `${escHtml(s.name)} ${escHtml(s.pct)}%`).join(', ')}</p>`;
}
function notableAttacksHtml(r) {
  if (!Array.isArray(r.attacks) || !r.attacks.length) return '';
  return `<ul class="small codex-attacks">${r.attacks.map((a) => `<li><b>${escHtml(a.name)}</b>${
    a.damage ? ` — ${escHtml(a.damage)}${a.is_mega_damage && !/M\.?D/.test(a.damage) ? ' M.D.' : ''}` : ''}${
    a.range ? `, range ${escHtml(a.range)}` : ''}${a.note ? ` (${escHtml(a.note)})` : ''}</li>`).join('')}</ul>`;
}

const byId = (id) => SECTIONS.find((s) => s.id === id) || SECTIONS[0];

const S = {
  tab: 'spells',
  filter: '',
  system: '',
  open: new Set(),      // "<section>:<key>" of the entries showing their text
  rows: {},             // section id -> the rows, once fetched
  loading: {},          // section id -> a fetch is in flight
  error: {},            // section id -> what went wrong
  counts: null,         // from ?section=index, so the tabs are labelled at once
  // Only a section with a `detail` hook uses these three, keyed like `open`.
  text: {},             // "<section>:<key>" -> the entry's text, once fetched
  textLoading: {},      // -> a fetch for it is in flight
  textError: {},        // -> what went wrong; cleared by the next attempt
  group: '',            // one meta value ("Level 3", "Weapons") or '' for all
  sort: '',             // a sortsFor() key, '' = the catalog's own order
  holdings: null,       // me/holdings: { holds: {section: {key: [ids]}}, byId }
  focus: null,          // "<section>:<key>" a link named - scrolled to and marked
  missing: null,        // the key a link named that this section does not hold
  mark: null,           // the slug a link named: one book's line in its entry
  folds: new Set(),     // spell tradition folds opened by hand: "air" or "warlock/air"
  traditionClasses: {}, // tradition slug -> the class names that can learn it
};

const $ = (id) => document.getElementById(id);
const rowsFor = (id) => S.rows[id] || [];

// ── formatting helpers ──

// This file is a classic script and imports nothing (see the header), so it
// cannot reach app.js's map of the same name and keeps its own. Two copies of
// three strings, deliberately, rather than a module boundary this page does not
// otherwise need — smoke.mjs pins the two against each other so they cannot
// drift. It replaced a two-arm ternary that printed the raw slug for anything
// else, which is what a Nightbane row would have shown. BOOK-INGEST-AUDIT F73.
const SYSTEM_LABEL = {
  rifts: 'Rifts',
  'palladium-fantasy': 'Palladium Fantasy',
  nightbane: 'Nightbane',
  'heroes-unlimited': 'Heroes Unlimited',
};

// Credits in Rifts, gold in Palladium Fantasy, dollars in Nightbane AND in
// Heroes Unlimited — both are set on present-day Earth and price everything in
// them. A row marked `both`
// or left NULL is unrestricted, and the overwhelming bulk of this catalog is
// Rifts, so it still reads as credits — the same reading every picker already
// applies to a NULL system. `cost` is a range's LOW end and `cost_note` carries
// the rest, so a row with a note is marked rather than quoted precisely.
//
// The Nightbane arm is NEW, and its absence is what BOOK-INGEST-AUDIT F73
// should have named: the fallback here is credits, not a neutral word, so a
// dollar price read as a Rifts price. `js/rules.js` — which F73 blamed instead
// — already had a third arm. See F73's outcome note.
function money(cost, system, note) {
  if (cost == null) return '';
  const unit = system === 'palladium-fantasy' ? 'gold'
    : system === 'nightbane' || system === 'heroes-unlimited' ? 'dollars' : 'cr.';
  return `${Number(cost).toLocaleString('en-US')}${note ? '+' : ''} ${unit}`;
}

// Books write damage as prose as often as figures, and most mega-damage strings
// already say so ("2D6 M.D. single shot"). `is_mega_damage` is structured
// because reading it back out of the string is error-prone — so it is used to
// ADD the marker only where the string does not already carry it, rather than
// to rewrite what the book wrote.
function damage(r) {
  if (!r.damage) return null;
  const d = String(r.damage);
  return r.is_mega_damage && !/M\.?D\.?/i.test(d) ? `${d} (M.D.)` : d;
}

// ── one entry, several books (gear and vessels) ──

// One printing's stat block. The entry prints the lines every book agrees on
// and each book's line prints the rest, so the two are the same list split by
// agrees() and nothing falls between them.
function gearStats(p) {
  return [['Damage', damage(p)], ['Range', p.range], ['Payload', p.payload],
          ['Rate of fire', p.rate_of_fire], ['A.R.', p.ar],
          ['S.D.C.', p.sdc], ['M.D.C.', p.mdc],
          ['Weight', p.weight_lbs != null ? `${p.weight_lbs} lbs` : null]];
}

const blank = (v) => v == null || String(v).trim() === '';

// Whether every book prints the same thing for stat `i`. A book that prints
// nothing where another prints a figure DISAGREES: the Rifts Eggshell Bomb has
// a range and the other two do not, and that range is the Rifts book's alone.
// The LABEL counts too: a vessel's durability line is "S.D.C." or "M.D.C." by
// the row's own unit, and the same number in two units is not agreement.
function agrees(g, statsOf, i) {
  const vals = g.printings.map((p) => { const [k, v] = statsOf(p)[i]; return blank(v) ? '' : `${k}|${v}`; });
  return vals.every((v) => v === vals[0]);
}

function vesselStats(p) {
  return [['Crew', p.crew], ['Passengers', p.passengers],
          [vesselUnit(p), p.mdc_main_body], ['A.R.', p.ar],
          ['Ground speed', p.speed_ground], ['Air speed', p.speed_air],
          ['Water speed', p.speed_water],
          ['Dimensions', p.dimensions], ['Weight', p.weight_tons]];
}

// A vessel's locations and weapon systems, once when every book prints the
// same ones and otherwise under each book's name.
function vesselBlocksHtml(g) {
  const blocks = g.printings.map((p) => locationsHtml(p) + weaponsHtml(p));
  if (blocks.every((b) => b === blocks[0])) return blocks[0];
  return g.printings.map((p, i) => (blocks[i]
    ? `<div class="codex-sub">${escHtml(p.source_book || 'source not recorded')}</div>${blocks[i]}` : '')).join('');
}

// What a section's book lines are made of: which holdings they read, the stat
// block they split, and the field two books may file an entry under differently.
const GEAR_LINES = { sec: 'gear', statsOf: gearStats, kindLabel: 'Category',
                     kind: (p) => p.category || 'Uncategorised', note: (p) => vesselNote(p) };
const VESSEL_LINES = { sec: 'vehicles', statsOf: vesselStats, kindLabel: 'Class',
                       kind: (p) => p.vehicle_class || 'Unclassed', note: () => '' };

function vesselNote(p) {
  if (!p.vehicle_slug) return '';
  return p.vessel_name
    ? `Also recorded as a vessel — see ${p.vessel_name} under Vessels, which carries its M.D.C. by location and its weapon systems.`
    : 'Recorded as a vessel, which has not been imported yet.';
}

// A line per book: the book and its price, then what THAT book prints that the
// others do not - the game, its own figures, a note on the price. The price is
// exact here, without the "+" the entry's line uses, because the note it stands
// for is printed right under it. A book with no price prints none: NULL is a
// finished row (see the schema), not a gap to mark.
//
// `yours` goes on the printing a character actually holds, and S.mark is the
// printing a link named - the sheet links an item by the slug it holds.
function printingsHtml(g, lines) {
  const cats = new Set(g.printings.map(lines.kind));
  return `<div class="codex-sub">Found in</div>
    ${g.printings.map((p) => {
      const slug = String(p.slug).toLowerCase();
      const held = (S.holdings?.holds?.[lines.sec]?.[slug] || []).length > 0;
      const bits = [['Game', SYSTEM_LABEL[p.system]],
                    cats.size > 1 ? [lines.kindLabel, lines.kind(p)] : null,
                    ...lines.statsOf(p).filter((_, i) => !agrees(g, lines.statsOf, i)),
                    ['Price note', p.cost_note]]
        .filter((b) => b && !blank(b[1]));
      const vessel = lines.note(p);
      return `<div class="codex-printing${S.mark === slug ? ' mark' : ''}">
        <div class="codex-printing-head">
          <span class="codex-printing-book">${escHtml(p.source_book || 'source not recorded')}${
            held ? ' <span class="tag codex-yours">yours</span>' : ''}</span>
          <span class="codex-cost">${escHtml(money(p.cost, p.system))}</span>
        </div>
        ${bits.length ? `<dl class="codex-stats">${bits.map(([k, v]) =>
          `<dt>${escHtml(k)}</dt><dd>${escHtml(v)}</dd>`).join('')}</dl>` : ''}
        ${vessel ? `<p class="note small">${escHtml(vessel)}</p>` : ''}
      </div>`;
    }).join('')}`;
}

// Every book's text, all showing, each under the book it came from. Books that
// word it identically share one heading. Returns null when there is at most one
// wording, and the entry prints it the way every other section does.
function printingsTextHtml(g) {
  const by = new Map();
  for (const p of g.printings) {
    if (blank(p.description)) continue;
    const t = String(p.description).trim();
    if (!by.has(t)) by.set(t, []);
    by.get(t).push(p.source_book || 'source not recorded');
  }
  if (by.size < 2) return null;
  return [...by.entries()].map(([t, books]) =>
    `<div class="codex-sub">${escHtml(books.join('; '))}</div><p class="codex-text">${escHtml(t)}</p>`).join('');
}

// ── Talent and super ability labels ──

// `tier` and `form_required` are stored as the lowercase words the schema lists.
// An unlisted value falls through to the stored word (form) or to nothing
// (tier) rather than to a guess: `form_required` is free text on purpose,
// because the book gives four answers across 25 rows and a later one may give a
// fifth.
const TALENT_TIER = { common: 'Common', elite: 'Elite' };
const TALENT_FORM = { morphus: 'Morphus only', facade: 'Facade only', both: 'Either form' };
const SUPER_TIER = { minor: 'Minor', major: 'Major' };

// What one use costs. 0 is not free - it is "the book prints a schedule", and
// the schedule is `ppe_note`, which the entry's notes carry in full.
function talentUse(r) {
  return r.ppe ? `${r.ppe}${r.ppe_note ? '+' : ''} P.P.E.` : 'varies';
}

// ── vessel-only blocks ──

// WHICH UNIT A VESSEL'S NUMBERS ARE IN. `mdc_main_body` and every `mdc` on its
// location rows are S.D.C. when `is_mega_damage` is 0 — the column names predate
// migration 062 and are not the unit. Defaults to M.D.C. when the flag is absent,
// which is what a row loaded from an older payload is.
function vesselUnit(r) {
  return r.is_mega_damage === 0 ? 'S.D.C.' : 'M.D.C.';
}

// Durability by location, in the book's printed order — which is the array
// order, because the endpoint spent `ordinal` on its ORDER BY. `mdc` is NULL
// where a book prints a formula instead and `mdc_note` carries it, so a row
// shows whichever it has. The heading names the unit rather than assuming it.
function locationsHtml(r) {
  const rows = r.locations || [];
  if (!rows.length) return '';
  return `<div class="codex-sub">${vesselUnit(r)} by location</div>
    <dl class="codex-stats">${rows.map((l) =>
      `<dt>${escHtml(l.location)}</dt><dd>${escHtml(
        l.mdc != null ? String(l.mdc) : (l.mdc_note || '—'))}</dd>`).join('')}</dl>`;
}

// The numbered weapon systems. `ordinal` IS rendered here, unlike on locations:
// it is the book's own numbering and a reader comparing against their copy
// needs it.
function weaponsHtml(r) {
  const rows = r.weapons || [];
  if (!rows.length) return '';
  return `<div class="codex-sub">Weapon systems</div>
    ${rows.map((w) => {
      const bits = [['Damage', damage(w)], ['Range', w.range], ['Rate of fire', w.rate_of_fire],
                    ['Payload', w.payload], ['Bonus', w.bonus]]
        .filter(([, v]) => v != null && String(v).trim() !== '');
      return `<div class="codex-weapon">
        <div class="codex-weapon-name">${w.ordinal != null ? escHtml(w.ordinal + '. ') : ''}${escHtml(w.name)}</div>
        ${bits.length ? `<dl class="codex-stats">${bits.map(([k, v]) =>
          `<dt>${escHtml(k)}</dt><dd>${escHtml(v)}</dd>`).join('')}</dl>` : ''}
        ${w.note ? `<p class="note small">${escHtml(w.note)}</p>` : ''}
      </div>`;
    }).join('')}`;
}

// ── loading ──

// One section, the first time its tab is opened, and never again for the life
// of the page. The browser handles revalidation: js/api.js sends nothing
// special, fetch carries If-None-Match itself, and the endpoint answers 304.
async function loadSection(id) {
  if (S.rows[id] || S.loading[id]) return;
  S.loading[id] = true;
  render();
  try {
    const res = await api('codex?section=' + encodeURIComponent(id));
    // A section that lists something other than its rows says how (gear: one
    // entry per name). Everything below this line reads entries.
    const sec = byId(id);
    S.rows[id] = sec.fold ? sec.fold(res[id] || []) : (res[id] || []);
    if (res.traditions) S.traditionClasses = res.traditions;
    delete S.error[id];
  } catch (err) {
    S.error[id] = err.message;
  }
  S.loading[id] = false;
  render();
  // A link may have named a row in this section before it had arrived.
  if (id === S.tab) settleFocus();
}

// Which of the reader's OWN characters hold what (me/holdings), fetched once
// for the whole page - it is a few hundred keys at most, against a request per
// opened entry otherwise. Keyed exactly as each section keys its rows, so a
// lookup is sec.id + sec.key(r). A failure costs the "yours" marks and nothing
// else: the codex is a reference first, and it must not wait on this.
async function loadHoldings() {
  try {
    const res = await api('me/holdings');
    S.holdings = {
      holds: res.holds || {},
      byId: Object.fromEntries((res.characters || []).map((c) => [c.id, c])),
    };
  } catch {
    S.holdings = null;
  }
  render();
}

function heldBy(sec, r) {
  const held = S.holdings?.holds?.[sec.id] || {};
  const ids = new Set((sec.keys ? sec.keys(r) : [sec.key(r)]).flatMap((k) => held[k] || []));
  return [...ids].map((id) => S.holdings.byId[id]).filter(Boolean);
}

async function loadIndex() {
  try {
    S.counts = (await api('codex?section=index')).counts || null;
  } catch {
    // A failed count leaves the tabs unlabelled and nothing else. It is not
    // worth an error panel in front of a catalog that would have loaded fine.
    S.counts = null;
  }
  render();
}

// One ENTRY's text, the first time its row is opened, for the one section that
// does not send text with its list (plan 22 D1). Kept for the life of the page,
// like a section; the browser revalidates it the same way.
//
// A failure is recorded against the ENTRY and shown inside it. The list loaded
// fine, so an error panel over the whole section would be the wrong size of
// apology - and the record is cleared on the next attempt, so closing the row
// and opening it again is the retry, with nothing extra to press.
//
// A row the list says has no text is never asked for: `has_text` already
// answered, and the entry says "not imported yet" without a round trip.
async function loadDetail(sec, r) {
  const key = sec.id + ':' + sec.key(r);
  if (!sec.detail || !r.has_text || S.text[key] != null || S.textLoading[key]) return;
  S.textLoading[key] = true;
  delete S.textError[key];
  render();
  try {
    S.text[key] = sec.detailText(await api(sec.detail(r))) || '';
  } catch (err) {
    S.textError[key] = err.message;
  }
  delete S.textLoading[key];
  render();
}

// What an entry has to read, wherever it came from: with the row, or fetched.
function textOf(sec, r) {
  const t = sec.detail ? S.text[sec.id + ':' + sec.key(r)] : r.description;
  return t && String(t).trim() ? String(t) : '';
}

// Whether the catalog HOLDS text for a row - which for a `detail` section is
// known before any of it has been fetched.
function hasText(sec, r) {
  return sec.detail ? !!r.has_text : !!(r.description && String(r.description).trim());
}

// ── filtering ──

// Name, source book and the section's own category field; all terms required,
// order irrelevant — the same rule js/picker.js applies in the wizard, so
// "rifts fire" narrows rather than widens. The DESCRIPTION is deliberately not
// searched: a hit whose reason is invisible until you expand the row reads as a
// bug, and picker.js's comment says so about the fields it leaves out.
function visible() {
  const sec = byId(S.tab);
  const terms = S.filter.trim().toLowerCase().split(/\s+/).filter(Boolean);
  // A group this section does not have (a stale link) narrows nothing, rather
  // than narrowing to nothing.
  const group = (groupsFor(sec) || []).some(([g]) => g === S.group) ? S.group : '';
  // An entry holding several rows is narrowed to the chosen system's rows
  // rather than kept or dropped whole, so the Rifts view of a four-book item
  // shows the Rifts price and not the other three.
  const all = sec.narrow && S.system
    ? rowsFor(S.tab).map((r) => sec.narrow(r, S.system)).filter(Boolean) : rowsFor(S.tab);
  const rows = all.filter((r) => {
    // A NULL system is unrestricted, which is how every picker already reads it.
    if (S.system && r.system && r.system !== 'both' && r.system !== S.system) return false;
    if (group && !groupsOf(sec, r).includes(group)) return false;
    if (!terms.length) return true;
    const hay = sec.hay(r).toLowerCase();
    return terms.every((t) => hay.includes(t));
  });
  return sortRows(sec, rows);
}

// ── narrowing and ordering ──
//
// THE GROUP IS THE ROW'S OWN META LINE - "Level 3", "Healing", "Weapons",
// "R.C.C.", "Major" - rather than a field chosen per section. That line is
// already what each section decided a reader groups by, it already arrives
// with every row, and it means a new section gets a group filter without
// anyone remembering to give it one. A section whose meta is closer to a
// caption than a category (a notable NPC's title) has too many distinct
// values to be a menu, and gets none: GROUP_MAX is where a dropdown stops
// being faster than typing.
const GROUP_MAX = 60;

// The groups ONE row is in. Its meta line, unless the section says the line
// names more than one - a gear entry two books file differently is in both.
function groupsOf(sec, r) {
  return sec.groups ? sec.groups(r) : [sec.meta(r)].filter(Boolean);
}

function groupsFor(sec) {
  const rows = rowsFor(sec.id);
  if (!rows.length) return null;
  const n = new Map();
  for (const r of rows) {
    for (const g of groupsOf(sec, r)) n.set(g, (n.get(g) || 0) + 1);
  }
  if (n.size < 2 || n.size > GROUP_MAX) return null;
  // Natural order, so "Level 10" follows "Level 9" rather than "Level 1".
  return [...n.entries()].sort((a, b) => a[0].localeCompare(b[0], undefined, { numeric: true }));
}

// The DEFAULT is the catalog's own order, which the endpoint already groups
// (spells by level, psionics by category, gear by category) - so it is named
// for what it is rather than hidden behind "name". Every section can sort by
// name and by book; the rest are the one number a section is compared on.
// A missing number sorts LAST in either direction, never first: "no price" is
// not the cheapest item.
const SORT_EXTRA = {
  spells: [['ppe', 'P.P.E. cost', (r) => r.ppe]],
  psionics: [['isp', 'I.S.P. cost', (r) => r.isp]],
  // An entry sorts on the LOWEST figure among the books showing, so under a
  // system filter it sorts on that system's own.
  gear: [['cost', 'Price', (r) => lowest(r.printings.map((p) => p.cost))],
         ['weight', 'Weight', (r) => lowest(r.printings.map((p) => p.weight_lbs))]],
  skills: [['base', 'Base %', (r) => (r.base ? Number(r.base) : null)]],
  notables: [['level', 'Level', (r) => r.level]],
  talents: [['acquire', 'Cost to acquire', (r) => r.acquire_ppe]],
};

function lowest(vals) {
  const nums = vals.filter((v) => typeof v === 'number');
  return nums.length ? Math.min(...nums) : null;
}

function sortsFor(sec) {
  return [['', 'Catalog order'], ['name', 'Name'], ['book', 'Book'],
          ...(SORT_EXTRA[sec.id] || []).map(([k, label]) => [k, label])];
}

function sortRows(sec, rows) {
  const by = sortsFor(sec).some(([k]) => k === S.sort) ? S.sort : '';
  if (!by) return rows;
  const byName = (a, b) => String(sec.title(a)).localeCompare(String(sec.title(b)));
  if (by === 'name') return [...rows].sort(byName);
  if (by === 'book') {
    return [...rows].sort((a, b) =>
      String(a.source_book || '￿').localeCompare(String(b.source_book || '￿'), undefined, { numeric: true })
      || byName(a, b));
  }
  const get = (SORT_EXTRA[sec.id] || []).find(([k]) => k === by)[2];
  const num = (r) => { const v = get(r); return v == null || v === '' || !Number.isFinite(Number(v)) ? null : Number(v); };
  return [...rows].sort((a, b) => {
    const x = num(a), y = num(b);
    if (x == null || y == null) return x == null && y == null ? byName(a, b) : x == null ? 1 : -1;
    return x - y || byName(a, b);
  });
}

// The narrowing lives in the address too, so a filtered view is a link: the
// search (`?q=`), system, group and sort. The HASH stays the section and
// entry, as "a link to one entry" below describes, and the two never mix -
// an entry's Copy link is deliberately free of whatever filter you had on.
function syncQuery() {
  const p = new URLSearchParams();
  if (S.filter) p.set('q', S.filter);
  if (S.system) p.set('system', S.system);
  if (S.group) p.set('group', S.group);
  if (S.sort) p.set('sort', S.sort);
  const qs = p.toString();
  history.replaceState(null, '', location.pathname + (qs ? '?' + qs : '') + location.hash);
}

// ── rendering ──

// The printed stat block, in the book's own order. Only the fields this row
// actually has: a spell with no area of effect should not print an em dash next
// to one, which is how the sheet's own field rows already behave.
function statBlock(sec, r) {
  const have = sec.stats(r).filter(([, v]) => v != null && String(v).trim() !== '');
  if (!have.length) return '';
  return `<dl class="codex-stats">${have
    .map(([k, v]) => `<dt>${escHtml(k)}</dt><dd>${escHtml(v)}</dd>`).join('')}</dl>`;
}

function entry(sec, r) {
  const key = sec.id + ':' + sec.key(r);
  const open = S.open.has(key);
  const text = textOf(sec, r);
  const cost = sec.cost(r);
  // Three things an open entry with no text can mean, and only a `detail`
  // section can mean the first two: still on its way, failed to arrive, or not
  // in the catalog at all.
  const ownText = sec.textHtml ? sec.textHtml(r) : null;
  const textHtml = ownText ? ownText
    : text ? `<p class="codex-text">${escHtml(text)}</p>`
    : S.textLoading[key] ? '<p class="codex-text muted">Loading…</p>'
    : S.textError[key] ? `<p class="err">Could not load this entry: ${escHtml(S.textError[key])}. Close it and open it again to retry.</p>`
    : sec.noText ? '' : '<p class="codex-text muted">No description imported yet.</p>';
  // A row with no text still lists — its stat block is worth having, and hiding
  // it would make the codex quietly disagree with the pickers about what
  // exists. It says so instead, which is also the visible edge of the Book of
  // Magic spells still to be filled in.
  const [sid, ...rest] = key.split(':');
  const mine = heldBy(sec, r);
  return `<div class="codex-entry${open ? ' open' : ''}${S.focus === key ? ' focus' : ''}">
    <button type="button" class="codex-head" data-key="${escHtml(key)}" aria-expanded="${open}">
      <span class="codex-name">${escHtml(sec.title(r))}${sec.badge ? sec.badge(r) : ''}${mine.length
        ? ` <span class="tag codex-yours" title="${escHtml(`Held by ${mine.map((c) => c.name).join(', ')}`)}">yours</span>` : ''}</span>
      <span class="codex-meta">${escHtml(sec.meta(r))}</span>
      <span class="codex-cost">${escHtml(cost)}</span>
    </button>
    ${open ? `<div class="codex-body">
      ${statBlock(sec, r)}
      ${sec.extra ? sec.extra(r) : ''}
      ${textHtml}
      ${sec.notes(r).filter(Boolean)
        .map((n) => `<p class="note small">${escHtml(n)}</p>`).join('')}
      ${mine.length ? `<p class="small codex-mine noprint">${sec.id === 'classes'
        ? 'Your characters of this class' : 'Your characters with this'}: ${mine.map((c) =>
          `<a href="/apps/character-sheet/?id=${encodeURIComponent(c.id)}">${escHtml(c.name)}</a>`).join(', ')}</p>` : ''}
      <p class="muted small codex-foot">${escHtml((sec.foot ? sec.foot(r) : r.source_book) || 'source not recorded')}
        <button type="button" class="btn btn-sm btn-ghost noprint" data-copy="${escHtml(entryHash(sid, rest.join(':')))}">Copy link</button></p>
    </div>` : ''}
  </div>`;
}

// ── spell traditions ──
//
// General invocations keep the main list; each tradition folds under a heading
// of its own, closed until opened (js/traditions.js has why). A fold opens by
// itself in two cases, and cannot be closed while either holds: the filter has
// text and the fold holds a match - typing must still reach everything - or a
// link named a row inside it, which has to be on screen. A spell one of your
// characters holds does NOT open it: a Warlock's twenty would pin its fold open
// for good, so the heading counts them instead.
//
// Inside a fold the rows take level headings when the sort is the catalog's
// own, which is by level; under any other sort a heading would split the order
// the reader asked for.
function spellListHtml(sec, rows) {
  const { general, traditions } = SpellTraditions.partition(rows);
  if (!traditions.length) return general.map((r) => entry(sec, r)).join('');
  const typed = !!S.filter.trim();
  const keyOf = (r) => sec.id + ':' + sec.key(r);

  const leveled = (list) => {
    if (S.sort) return list.map((r) => entry(sec, r)).join('');
    let last;
    return list.map((r) => {
      const lvl = r.level != null ? `Level ${r.level}` : 'Unleveled';
      const head = lvl !== last ? `<div class="codex-lvl">${escHtml(lvl)}</div>` : '';
      last = lvl;
      return head + entry(sec, r);
    }).join('');
  };

  const fold = (key, name, list, who, families, inner) => {
    const forced = typed || (!!S.focus && list.some((r) => keyOf(r) === S.focus));
    const open = forced || S.folds.has(key);
    const mine = list.filter((r) => heldBy(sec, r).length).length;
    const count = `${list.length} ${typed ? (list.length === 1 ? 'match' : 'matches')
      : (list.length === 1 ? 'spell' : 'spells')}`;
    const inside = `<span class="codex-fold-name">${escHtml(name)}${mine
        ? ` <span class="tag codex-yours">${mine} yours</span>` : ''}</span>
      <span class="codex-fold-n">${count}</span>
      ${who != null ? `<span class="codex-fold-who">${who.length
        ? `Only for: ${escHtml(who.join(', '))}` : 'No published class learns these yet'}</span>` : ''}`;
    const cls = `codex-fold${inner ? ' inner' : ''}`;
    const head = forced
      ? `<div class="${cls} forced">${inside}</div>`
      : `<button type="button" class="${cls}" data-fold="${escHtml(key)}" aria-expanded="${open}">${inside}</button>`;
    if (!open) return head;
    const body = families
      ? families.map((f) => fold(`${key}/${f.id}`, f.label, f.rows, null, null, true)).join('')
      : leveled(list);
    return head + `<div class="codex-fold-body">${body}</div>`;
  };

  return (general.length ? `<div class="codex-band"><h2>General spells</h2>
        <span>Any caster whose class allows the level · ${general.length}</span></div>`
        + general.map((r) => entry(sec, r)).join('') : '')
    + `<div class="codex-band"><h2>Tradition spells</h2>
        <span>Only for the classes named under each heading · ${rows.length - general.length}</span></div>`
    + traditions.map((t) => fold(t.id, t.label, t.rows, S.traditionClasses[t.id] || [], t.families, false)).join('');
}

function tabsHtml() {
  return `<div class="tabbar codex-tabs">
    ${SECTIONS.map((s) => {
      // What is listed once it is loaded, the index's count until then. A
      // section that lists fewer entries than it has rows names its own count.
      const n = S.rows[s.id] ? S.rows[s.id].length : (S.counts ? S.counts[s.countKey || s.id] : null);
      return `<button type="button" class="tab${S.tab === s.id ? ' on' : ''}" data-tab="${s.id}">
        ${escHtml(s.label)}${n != null ? ` <span class="tab-n">${n}</span>` : ''}</button>`;
    }).join('')}
  </div>`;
}

function listHtml(sec) {
  if (S.error[sec.id]) {
    return `<div class="panel"><p class="err">Failed to load: ${escHtml(S.error[sec.id])}</p></div>`;
  }
  if (S.loading[sec.id] || !S.rows[sec.id]) {
    return `<div class="panel"><p class="muted">Loading ${escHtml(sec.label.toLowerCase())}…</p></div>`;
  }

  const groups = groupsFor(sec);
  const shown = visible();
  const total = rowsFor(sec.id).length;
  const withText = shown.filter((r) => hasText(sec, r)).length;

  return `<div class="codex-toolbar">
      <input type="search" id="codex-filter" class="pick-filter" placeholder="Filter by name or book…"
        value="${escHtml(S.filter)}" autocomplete="off">
      <select id="codex-system">
        <option value=""${S.system ? '' : ' selected'}>All systems</option>
        <option value="rifts"${S.system === 'rifts' ? ' selected' : ''}>Rifts</option>
        <option value="palladium-fantasy"${S.system === 'palladium-fantasy' ? ' selected' : ''}>Palladium Fantasy</option>
        <option value="nightbane"${S.system === 'nightbane' ? ' selected' : ''}>Nightbane</option>
        <option value="heroes-unlimited"${S.system === 'heroes-unlimited' ? ' selected' : ''}>Heroes Unlimited</option>
      </select>
      ${groups ? `<select id="codex-group" aria-label="Only one ${escHtml(sec.groupNoun || 'group')}">
        <option value="">Every ${escHtml(sec.groupNoun || 'group')}</option>
        ${groups.map(([g, n]) => `<option value="${escHtml(g)}"${S.group === g ? ' selected' : ''}>${
          escHtml(g)} (${n})</option>`).join('')}
      </select>` : ''}
      <select id="codex-sort" aria-label="Sort by">
        ${sortsFor(sec).map(([k, label]) => `<option value="${k}"${(S.sort || '') === k ? ' selected' : ''}>${
          k ? 'Sort: ' : ''}${escHtml(label)}</option>`).join('')}
      </select>
      <span class="muted small">${shown.length} of ${total}${
        shown.length && !sec.noText ? ` · ${withText} with text` : ''}</span>
    </div>

    ${S.missing ? `<p class="err small">The link asked for “${escHtml(S.missing)}”, and ${
      escHtml(sec.label)} has no entry by that name. It may have been renamed or merged — try the filter.</p>` : ''}
    <div class="panel codex-list" id="codex-list">
      ${!shown.length ? '<p class="muted small">Nothing matches that.</p>'
        : sec.id === 'spells' ? spellListHtml(sec, shown)
        : shown.map((r) => entry(sec, r)).join('')}
    </div>`;
}

function render() {
  const sec = byId(S.tab);
  $('app').innerHTML = tabsHtml() + listHtml(sec);

  const box = $('codex-filter');
  // Same caret restoration Picker.wire() does, and for the same reason: this
  // page rebuilds by replacing innerHTML, so an input loses focus and drops the
  // caret to the end mid-keystroke.
  if (S.filterFocused && box) { box.focus(); box.setSelectionRange(box.value.length, box.value.length); }
}

// ─── one listener for the page, rather than a handler per row ───
document.addEventListener('click', (e) => {
  const tab = e.target.closest('[data-tab]');
  if (tab) {
    S.tab = tab.dataset.tab;
    S.filterFocused = false;
    // The filter is per-section: a query that narrowed spells means nothing
    // against vessels, and carrying it across would open a tab on "nothing
    // matches that" with no visible reason.
    S.filter = '';
    // A group and a sort belong to one section's rows for the same reason.
    // The system does not, and stays.
    S.group = '';
    S.sort = '';
    location.hash = '#' + S.tab;
    syncQuery();
    render();
    loadSection(S.tab);
    return;
  }

  const copy = e.target.closest('[data-copy]');
  if (copy) {
    const url = location.origin + location.pathname + copy.dataset.copy;
    const done = (msg) => { copy.textContent = msg; setTimeout(() => { copy.textContent = 'Copy link'; }, 1500); };
    if (navigator.clipboard) navigator.clipboard.writeText(url).then(() => done('Copied'), () => done('Copy failed'));
    else done('Copy failed');
    return;
  }

  const fold = e.target.closest('button.codex-fold');
  if (fold) {
    const k = fold.dataset.fold;
    if (S.folds.has(k)) S.folds.delete(k); else S.folds.add(k);
    S.filterFocused = false;
    render();
    return;
  }

  const head = e.target.closest('.codex-head');
  if (head) {
    const key = head.dataset.key;
    const opening = !S.open.has(key);
    if (opening) S.open.add(key); else S.open.delete(key);
    S.filterFocused = false;
    S.focus = null;
    S.missing = null;
    S.mark = null;
    // The address follows the row: opening one makes the URL bar a link to it,
    // closing it falls back to the section. See "a link to one entry" below.
    const sid = key.slice(0, key.indexOf(':'));
    history.replaceState(null, '', opening ? entryHash(sid, key.slice(sid.length + 1)) : entryHash(sid));
    render();
    // A `detail` section's text is fetched by the act of opening the row. The
    // row is found again from the key rather than carried on the element: the
    // key is already the delegated handler's whole contract (see the header).
    const sec = byId(S.tab);
    if (opening && sec.detail) {
      const row = rowsFor(sec.id).find((r) => sec.id + ':' + sec.key(r) === key);
      if (row) loadDetail(sec, row);
    }
  }
});

let filterTimer = null;
document.addEventListener('input', (e) => {
  if (e.target.id !== 'codex-filter') return;
  S.filter = e.target.value; S.filterFocused = true; S.missing = null;
  // The list is rebuilt whole on a render - thousands of entries on the Gear tab - so it
  // waits for a pause in the typing rather than running on every key.
  clearTimeout(filterTimer);
  filterTimer = setTimeout(() => { syncQuery(); render(); }, 140);
});

document.addEventListener('change', (e) => {
  const pick = { 'codex-system': 'system', 'codex-group': 'group', 'codex-sort': 'sort' }[e.target.id];
  if (pick) { S[pick] = e.target.value; S.filterFocused = false; syncQuery(); render(); }
});

// ─── a link to one entry ───
//
// `#spells` opens a section; `#spells/fireball` opens that section with that
// ENTRY open, scrolled to and marked. The part after the slash is the
// section's own `key` - the same string the open-set and the delegated handler
// already use - so a link and a click can never disagree about which row is
// meant. Name-keyed sections (spells, psionics, skills, talents, super
// abilities) link by lower-cased name, encoded: "Ba'al's Blessing" and the
// super abilities with an ampersand are exactly the names that break a link
// built any other way. The sheet builds these links too, from the same rule.
//
// Opening an entry REPLACES the address rather than pushing it, so the URL bar
// is always a link to what is on screen and Back still leaves the page rather
// than walking back through every row you opened.

function entryHash(secId, key) {
  return '#' + secId + (key != null ? '/' + encodeURIComponent(key) : '');
}

function parseHash() {
  const h = location.hash.replace(/^#/, '');
  const at = h.indexOf('/');
  const tab = at < 0 ? h : h.slice(0, at);
  let key = null;
  if (at >= 0) {
    try { key = decodeURIComponent(h.slice(at + 1)).toLowerCase(); } catch { key = null; }
  }
  return { tab, key: key || null };
}

// Called once the section's rows are in. A link to a row that is not there -
// a renamed spell, a typo in a hand-made link - says so rather than landing on
// the top of the list as if it had worked.
function settleFocus() {
  let want = S.focus;
  if (!want || !S.rows[S.tab]) return;
  const sec = byId(S.tab);
  // A gear link names ONE printing by its slug, and the entry is keyed by its
  // first. Any of its slugs opens it, and the one named is marked inside.
  if (sec.resolve) {
    const named = want.slice(sec.id.length + 1);
    const real = sec.resolve(rowsFor(sec.id), named);
    if (real) {
      S.mark = named;
      if (real !== named) {
        S.open.delete(want);
        want = sec.id + ':' + real;
        S.open.add(want);
        S.focus = want;
      }
      render();
    }
  }
  const row = rowsFor(sec.id).find((r) => sec.id + ':' + sec.key(r) === want);
  if (!row) {
    S.focus = null;
    S.missing = want.slice(sec.id.length + 1);
    render();
    return;
  }
  if (sec.detail) loadDetail(sec, row);
  const el = document.querySelector(`.codex-head[data-key="${CSS.escape(want)}"]`);
  if (el) { el.scrollIntoView({ block: 'center' }); el.focus({ preventScroll: true }); }
}

function applyHash() {
  const { tab, key } = parseHash();
  if (!SECTIONS.some((s) => s.id === tab)) return;
  if (tab !== S.tab) { S.filter = ''; S.filterFocused = false; }
  S.tab = tab;
  S.missing = null;
  S.focus = null;
  S.mark = null;
  if (key) {
    const k = tab + ':' + key;
    S.open.add(k);
    S.focus = k;
    // The one row a link names must be on screen: a filter, system or group
    // chosen earlier would otherwise hide it and read as a broken link.
    S.system = '';
    S.filter = '';
    S.group = '';
    syncQuery();
  }
  render();
  // Loaded already: settle now. Not yet: loadSection settles when it lands.
  if (S.rows[tab]) settleFocus(); else loadSection(tab);
}

// Back and Forward between two entry links, and a link clicked on this page.
// The page's own tab clicks set the hash too; that arrives here as well and
// is harmless, because the state it describes is the state already showing.
window.addEventListener('hashchange', applyHash);

// A filtered view arrives as ?q=&system=&group=&sort= (syncQuery above).
// Read before the hash, so an entry link can still clear what would hide it.
// A value the page does not offer is dropped rather than trusted: the group
// and sort are checked against the section when it renders, the system here.
{
  const p = new URLSearchParams(location.search);
  S.filter = p.get('q') || '';
  const sys = p.get('system') || '';
  S.system = ['rifts', 'palladium-fantasy', 'nightbane', 'heroes-unlimited'].includes(sys) ? sys : '';
  S.group = p.get('group') || '';
  S.sort = p.get('sort') || '';
  // The section too, or applyHash would read #gear as a change of tab away
  // from the default and throw the search it just restored away with it.
  const { tab } = parseHash();
  if (SECTIONS.some((s) => s.id === tab)) S.tab = tab;
}

render();
loadIndex();
loadHoldings();
applyHash();
loadSection(S.tab);
