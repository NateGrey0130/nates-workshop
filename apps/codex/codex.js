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
    hay: (r) => `${r.name} ${r.source_book || ''}`,
  },
  {
    id: 'psionics',
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
    label: 'Gear',
    key: (r) => String(r.slug).toLowerCase(),
    title: (r) => r.name,
    meta: (r) => r.category || 'Uncategorised',
    cost: (r) => money(r.cost, r.system, r.cost_note),
    // Only what this row has; a knife should not print an empty A.R. See
    // `have` in statBlock(). Weight is last because it is the one figure that
    // is about carrying rather than fighting.
    stats: (r) => [['Damage', damage(r)], ['Range', r.range], ['Payload', r.payload],
                   ['Rate of fire', r.rate_of_fire], ['A.R.', r.ar],
                   ['S.D.C.', r.sdc], ['M.D.C.', r.mdc],
                   ['Weight', r.weight_lbs != null ? `${r.weight_lbs} lbs` : null]],
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
    notes: (r) => [
      r.cost_note && `Price: ${r.cost_note}`,
      r.vehicle_slug && (r.vessel_name
        ? `Also recorded as a vessel — see ${r.vessel_name} under Vessels, which carries its M.D.C. by location and its weapon systems.`
        : 'Recorded as a vessel, which has not been imported yet.'),
    ],
    hay: (r) => `${r.name} ${r.source_book || ''} ${r.category || ''}`,
  },
  {
    id: 'vehicles',
    label: 'Vessels',
    key: (r) => String(r.slug).toLowerCase(),
    title: (r) => r.name,
    meta: (r) => r.vehicle_class || 'Unclassed',
    cost: (r) => money(r.cost, r.system, r.cost_note),
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
    stats: (r) => [['Crew', r.crew], ['Passengers', r.passengers],
                   [vesselUnit(r), r.mdc_main_body], ['A.R.', r.ar],
                   ['Ground speed', r.speed_ground], ['Air speed', r.speed_air],
                   ['Water speed', r.speed_water],
                   ['Dimensions', r.dimensions], ['Weight', r.weight_tons]],
    // The two things a vessel has that no other catalog row does, and the whole
    // reason `vehicles` is three tables rather than one.
    extra: (r) => locationsHtml(r) + weaponsHtml(r),
    notes: (r) => [r.cost_note && `Price: ${r.cost_note}`],
    hay: (r) => `${r.name} ${r.source_book || ''} ${r.vehicle_class || ''}`,
  },
  // UI-AUDIT F48. Appended rather than placed first so the default tab and every
  // #spells / #gear link already sent keep opening where they did.
  {
    id: 'skills',
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
    label: 'Classes',
    key: (r) => String(r.slug).toLowerCase(),
    title: (r) => r.name,
    meta: (r) => (r.category === 'rcc' ? 'R.C.C.' : r.category === 'occ' ? 'O.C.C.' : (r.category || '')),
    cost: () => '',
    stats: (r) => [
      ['Type', r.category === 'rcc' ? 'Racial character class' : r.category === 'occ' ? 'Occupational character class' : null],
      ['System', SYSTEM_LABEL[r.system] || r.system],
    ],
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
  focus: null,          // "<section>:<key>" a link named - scrolled to and marked
  missing: null,        // the key a link named that this section does not hold
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
    S.rows[id] = res[id] || [];
    delete S.error[id];
  } catch (err) {
    S.error[id] = err.message;
  }
  S.loading[id] = false;
  render();
  // A link may have named a row in this section before it had arrived.
  if (id === S.tab) settleFocus();
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
  return rowsFor(S.tab).filter((r) => {
    // A NULL system is unrestricted, which is how every picker already reads it.
    if (S.system && r.system && r.system !== 'both' && r.system !== S.system) return false;
    if (!terms.length) return true;
    const hay = sec.hay(r).toLowerCase();
    return terms.every((t) => hay.includes(t));
  });
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
  const textHtml = text ? `<p class="codex-text">${escHtml(text)}</p>`
    : S.textLoading[key] ? '<p class="codex-text muted">Loading…</p>'
    : S.textError[key] ? `<p class="err">Could not load this entry: ${escHtml(S.textError[key])}. Close it and open it again to retry.</p>`
    : sec.noText ? '' : '<p class="codex-text muted">No description imported yet.</p>';
  // A row with no text still lists — its stat block is worth having, and hiding
  // it would make the codex quietly disagree with the pickers about what
  // exists. It says so instead, which is also the visible edge of the Book of
  // Magic spells still to be filled in.
  const [sid, ...rest] = key.split(':');
  return `<div class="codex-entry${open ? ' open' : ''}${S.focus === key ? ' focus' : ''}">
    <button type="button" class="codex-head" data-key="${escHtml(key)}" aria-expanded="${open}">
      <span class="codex-name">${escHtml(sec.title(r))}</span>
      <span class="codex-meta">${escHtml(sec.meta(r))}</span>
      <span class="codex-cost">${escHtml(cost)}</span>
    </button>
    ${open ? `<div class="codex-body">
      ${statBlock(sec, r)}
      ${sec.extra ? sec.extra(r) : ''}
      ${textHtml}
      ${sec.notes(r).filter(Boolean)
        .map((n) => `<p class="note small">${escHtml(n)}</p>`).join('')}
      <p class="muted small codex-foot">${escHtml(r.source_book || 'source not recorded')}
        <button type="button" class="btn btn-sm btn-ghost noprint" data-copy="${escHtml(entryHash(sid, rest.join(':')))}">Copy link</button></p>
    </div>` : ''}
  </div>`;
}

function tabsHtml() {
  return `<div class="tabbar codex-tabs">
    ${SECTIONS.map((s) => {
      const n = S.counts ? S.counts[s.id] : (S.rows[s.id] ? S.rows[s.id].length : null);
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
      <span class="muted small">${shown.length} of ${total}${
        shown.length && !sec.noText ? ` · ${withText} with text` : ''}</span>
    </div>

    ${S.missing ? `<p class="err small">The link asked for “${escHtml(S.missing)}”, and ${
      escHtml(sec.label)} has no entry by that name. It may have been renamed or merged — try the filter.</p>` : ''}
    <div class="panel codex-list" id="codex-list">
      ${shown.length ? shown.map((r) => entry(sec, r)).join('')
        : '<p class="muted small">Nothing matches that.</p>'}
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
    location.hash = '#' + S.tab;
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

  const head = e.target.closest('.codex-head');
  if (head) {
    const key = head.dataset.key;
    const opening = !S.open.has(key);
    if (opening) S.open.add(key); else S.open.delete(key);
    S.filterFocused = false;
    S.focus = null;
    S.missing = null;
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

document.addEventListener('input', (e) => {
  if (e.target.id === 'codex-filter') { S.filter = e.target.value; S.filterFocused = true; S.missing = null; render(); }
});

document.addEventListener('change', (e) => {
  if (e.target.id === 'codex-system') { S.system = e.target.value; S.filterFocused = false; render(); }
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
  const want = S.focus;
  if (!want || !S.rows[S.tab]) return;
  const sec = byId(S.tab);
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
  if (key) {
    const k = tab + ':' + key;
    S.open.add(k);
    S.focus = k;
    // The one row a link names must be on screen: a system filter chosen
    // earlier would otherwise hide it and read as a broken link.
    S.system = '';
  }
  render();
  // Loaded already: settle now. Not yet: loadSection settles when it lands.
  if (S.rows[tab]) settleFocus(); else loadSection(tab);
}

// Back and Forward between two entry links, and a link clicked on this page.
// The page's own tab clicks set the hash too; that arrives here as well and
// is harmless, because the state it describes is the state already showing.
window.addEventListener('hashchange', applyHash);

render();
loadIndex();
applyHash();
loadSection(S.tab);
