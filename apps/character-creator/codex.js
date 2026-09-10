// The codex — every spell, psionic power, piece of gear and vessel, and what
// each one is.
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
// a row, not a currency. A section returns '' when it has nothing to put there.

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
    stats: (r) => [['Crew', r.crew], ['Passengers', r.passengers],
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
      ['System', r.system === 'rifts' ? 'Rifts' : r.system === 'palladium-fantasy' ? 'Palladium Fantasy' : r.system],
    ],
    notes: () => [],
    hay: (r) => `${r.name} ${r.source_book || ''} ${r.category || ''}`,
  },
];

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
};

const $ = (id) => document.getElementById(id);
const rowsFor = (id) => S.rows[id] || [];

// ── formatting helpers ──

// Credits in Rifts, gold in Palladium Fantasy. A row marked `both` or left NULL
// is unrestricted, and the overwhelming bulk of this catalog is Rifts, so it
// reads as credits — the same reading every picker already applies to a NULL
// system. `cost` is a range's LOW end and `cost_note` carries the rest, so a
// row with a note is marked rather than quoted precisely.
function money(cost, system, note) {
  if (cost == null) return '';
  const unit = system === 'palladium-fantasy' ? 'gold' : 'cr.';
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

// ── vessel-only blocks ──

// M.D.C. by location, in the book's printed order — which is the array order,
// because the endpoint spent `ordinal` on its ORDER BY. `mdc` is NULL where a
// book prints a formula instead and `mdc_note` carries it, so a row shows
// whichever it has.
function locationsHtml(r) {
  const rows = r.locations || [];
  if (!rows.length) return '';
  return `<div class="codex-sub">M.D.C. by location</div>
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
  const text = r.description && String(r.description).trim();
  const cost = sec.cost(r);
  // A row with no text still lists — its stat block is worth having, and hiding
  // it would make the codex quietly disagree with the pickers about what
  // exists. It says so instead, which is also the visible edge of the Book of
  // Magic spells still to be filled in.
  return `<div class="codex-entry${open ? ' open' : ''}">
    <button type="button" class="codex-head" data-key="${escHtml(key)}" aria-expanded="${open}">
      <span class="codex-name">${escHtml(sec.title(r))}</span>
      <span class="codex-meta">${escHtml(sec.meta(r))}</span>
      <span class="codex-cost">${escHtml(cost)}</span>
    </button>
    ${open ? `<div class="codex-body">
      ${statBlock(sec, r)}
      ${sec.extra ? sec.extra(r) : ''}
      ${text ? `<p class="codex-text">${escHtml(r.description)}</p>`
             : sec.noText ? '' : '<p class="codex-text muted">No description imported yet.</p>'}
      ${sec.notes(r).filter(Boolean)
        .map((n) => `<p class="note small">${escHtml(n)}</p>`).join('')}
      <p class="muted small">${escHtml(r.source_book || 'source not recorded')}</p>
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
  const withText = shown.filter((r) => r.description && String(r.description).trim()).length;

  return `<div class="codex-toolbar">
      <input type="search" id="codex-filter" class="pick-filter" placeholder="Filter by name or book…"
        value="${escHtml(S.filter)}" autocomplete="off">
      <select id="codex-system">
        <option value=""${S.system ? '' : ' selected'}>Both systems</option>
        <option value="rifts"${S.system === 'rifts' ? ' selected' : ''}>Rifts</option>
        <option value="palladium-fantasy"${S.system === 'palladium-fantasy' ? ' selected' : ''}>Palladium Fantasy</option>
      </select>
      <span class="muted small">${shown.length} of ${total}${
        shown.length && !sec.noText ? ` · ${withText} with text` : ''}</span>
    </div>

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

  const head = e.target.closest('.codex-head');
  if (head) {
    const key = head.dataset.key;
    if (S.open.has(key)) S.open.delete(key); else S.open.add(key);
    S.filterFocused = false;
    render();
  }
});

document.addEventListener('input', (e) => {
  if (e.target.id === 'codex-filter') { S.filter = e.target.value; S.filterFocused = true; render(); }
});

document.addEventListener('change', (e) => {
  if (e.target.id === 'codex-system') { S.system = e.target.value; S.filterFocused = false; render(); }
});

// A link may arrive pointed at any of the six.
const fromHash = location.hash.replace(/^#/, '');
if (SECTIONS.some((s) => s.id === fromHash)) S.tab = fromHash;

render();
loadIndex();
loadSection(S.tab);
