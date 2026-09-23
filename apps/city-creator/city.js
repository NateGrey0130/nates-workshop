// City Creator - the page. The engine is js/city-engine.js, a pure module;
// this file holds the settings, the city on screen and its locks, and draws
// them: text output, lock and reroll, JSON export (Phase 1), the map (Phase
// 2), and keeping a city in one of the G.M.'s campaigns with what the players
// may see of it (Phase 3). This browser's storage holds the city on screen as
// a convenience, so a reload does not lose it; the record is the saved row.
//
// A module, so it can import the engine; the inline handlers reach it through
// window.City. escHtml()/escJs() come from /shared/js/ui.js, api() from
// /apps/character-creator/js/api.js, claudeRequest() from /shared/js/api.js.

import { generateCity, rerollCity, rerollEntry, toggleLock, settingsProblems, restAreHuman,
  suggestions, sizeFor, newSeed, poolPrompt, parsePool, exportJson, SUPPORTED_SYSTEMS, rollRequest, linkSheet,
  stockShop, restockShop }
  from './js/city-engine.js';
import { layoutMap } from './js/city-map.js';

// The map is computed when the city CHANGES and kept with it, not redrawn
// from the layout code on every load: Phase 3 saves the generated city, and a
// later change to the layout must not move a saved city's districts.
const withMap = (city) => ({ ...city, map: layoutMap(city) });

const $ = (id) => document.getElementById(id);
const esc = (s) => escHtml(s == null ? '' : String(s));
const STORE = 'workshop.city.last';
const MODEL = 'claude-sonnet-5';

const S = {
  settings: { system: 'palladium-fantasy', population: 2500, npcCount: 12, everyRace: true,
    races: [{ id: 'human', name: 'Human', pct: 100, theme: '' }] },
  nameTheme: '',
  seed: '',
  rccs: null,        // the setting's published R.C.C.s, for the race rows
  city: null,
  busy: false, msg: '', err: false,
  // Keeping a city in a campaign (Phase 3, migration 080). `saved` is the row
  // this city is, once it has been saved; `dirty` is a change since.
  saved: null, dirty: false, camps: null, openCamp: '', savedList: null,
  keepMsg: '', keepErr: false,
  // "Roll stats" per NPC (Phase 4a): what the roller said, keyed by entry id.
  rolls: {},
  // The Codex's gear, loaded the first time a shop is stocked (Phase 4b).
  gear: null, stockMsg: '',
};

// ── storage: a convenience, never the record ──
function save() {
  try { localStorage.setItem(STORE, JSON.stringify({ settings: S.settings, nameTheme: S.nameTheme, city: S.city, saved: S.saved, dirty: S.dirty })); }
  catch { /* private mode, full storage - the page works without it */ }
}
function restore() {
  try {
    const v = JSON.parse(localStorage.getItem(STORE) || 'null');
    if (v?.settings) S.settings = v.settings;
    if (typeof v?.nameTheme === 'string') S.nameTheme = v.nameTheme;
    // A city kept by Phase 1 has no map yet: draw it once, then it is kept.
    if (v?.city?.version === 1) S.city = v.city.map ? v.city : withMap(v.city);
    if (S.city && v?.saved?.id) { S.saved = v.saved; S.dirty = !!v.dirty; }
  } catch { /* ignore */ }
}

// ── the race list: the setting's published R.C.C.s ──
// The classes request leaves out retired classes by their deleted_at (a
// retired class can still read status 'published', so status alone is not
// enough), and nothing here asks it to include them.
async function loadRaces() {
  try {
    const res = await api(`classes?system=${encodeURIComponent(S.settings.system)}&category=rcc`);
    S.rccs = (res.classes || []).filter((c) => c.category === 'rcc')
      .map((c) => ({ id: c.id, name: c.name })).sort((a, b) => a.name.localeCompare(b.name));
  } catch (err) {
    S.rccs = [];
    S.msg = 'Could not load the races: ' + err.message; S.err = true;
  }
}

// ── settings panel ──
function settingsHtml() {
  const s = S.settings;
  const problems = settingsProblems(s);
  const total = s.races.reduce((n, x) => n + (Number(x.pct) || 0), 0);
  const size = sizeFor(s.population || 1, s.system);
  const raceOpts = (sel) => (S.rccs || []).map((c) => `<option value="${esc(c.id)}"${c.id === sel ? ' selected' : ''}>${esc(c.name)}</option>`).join('');
  return `<div class="panel city-settings">
    <h2 style="margin-top:0">Settings</h2>
    <div class="rowline" style="flex-wrap:wrap">
      <label class="small">Setting <select onchange="City.set('system', this.value)">
        ${SUPPORTED_SYSTEMS.map((x) => `<option value="${x}"${x === s.system ? ' selected' : ''}>${x === 'palladium-fantasy' ? 'Palladium Fantasy' : esc(x)}</option>`).join('')}
        <option disabled>Rifts (coming)</option>
      </select></label>
      <label class="small">Population <input type="number" min="1" value="${esc(s.population)}" style="width:8em"
        onchange="City.set('population', this.value)"></label>
      <label class="small">Suggest <select onchange="City.suggest(this.value); this.value=''">
        <option value="">— a typical —</option>
        ${suggestions(s.system).map((x) => `<option value="${x.population}">${esc(x.label)} (${x.population.toLocaleString()})</option>`).join('')}
      </select></label>
      <span class="muted small">${esc(size.label)}</span>
      <label class="small">Named NPCs <input type="number" min="0" max="200" value="${esc(s.npcCount)}" style="width:5em"
        onchange="City.set('npcCount', this.value)"></label>
    </div>
    <p class="muted small" style="margin:6px 0 0">Population sets how many districts, shops and places there are, and whether
      there are walls. The NPC count is yours alone; shop owners are among them.</p>

    <h3>Racial breakdown <span class="muted small">— ${total}% of 100%</span></h3>
    <div class="city-races">
      ${s.races.map((x, i) => `<div class="rowline city-race" style="flex-wrap:wrap">
        <select aria-label="Race ${i + 1}" onchange="City.race(${i}, 'id', this.value)">${raceOpts(x.id)}</select>
        <label class="small"><input type="number" min="0" max="100" step="1" value="${esc(x.pct)}" style="width:5em"
          aria-label="${esc(x.name)} percent" onchange="City.race(${i}, 'pct', this.value)">%</label>
        <input type="text" class="picker-input" placeholder="naming theme for this race (optional)" value="${esc(x.theme || '')}"
          aria-label="${esc(x.name)} naming theme" onchange="City.race(${i}, 'theme', this.value)">
        <button type="button" class="btn btn-sm btn-ghost" onclick="City.dropRace(${i})" aria-label="Remove ${esc(x.name)}">✕</button>
      </div>`).join('')}
    </div>
    <div class="rowline" style="flex-wrap:wrap;margin-top:6px">
      <button type="button" class="btn btn-sm" onclick="City.addRace()">+ Add a race</button>
      <button type="button" class="btn btn-sm" onclick="City.restHuman()">Rest are human</button>
      <label class="small"><input type="checkbox" ${s.everyRace ? 'checked' : ''} onchange="City.set('everyRace', this.checked)">
        at least one NPC of every listed race</label>
    </div>
    <p class="muted small" style="margin:6px 0 0">A race at 20% or more gets its own quarter.</p>

    <h3>Names</h3>
    <input type="text" class="picker-input" style="width:100%" value="${esc(S.nameTheme)}"
      placeholder="Naming theme, e.g. Venetian merchant princes, Norse dock workers (optional)"
      aria-label="Naming theme" onchange="City.theme(this.value)">
    <p class="muted small" style="margin:6px 0 0">With a theme, one AI call invents a name pool for this city and it is kept
      with the city: locks and rerolls draw from it and never call again. Without one, the built-in Palladium Fantasy names.</p>

    <div class="rowline" style="flex-wrap:wrap;margin-top:10px">
      <label class="small">Seed <input type="text" value="${esc(S.seed)}" placeholder="random" style="width:9em"
        aria-label="Seed" onchange="City.seed(this.value)"></label>
      <button type="button" class="btn btn-primary" onclick="City.generate()" ${problems.length || S.busy ? 'disabled' : ''}>
        ${S.busy ? 'Building…' : '🏰 Generate'}</button>
    </div>
    ${problems.length ? `<ul class="small warn">${problems.map((p) => `<li>${esc(p)}</li>`).join('')}</ul>` : ''}
    ${S.msg ? `<p class="small${S.err ? ' err' : ''}">${esc(S.msg)}</p>` : ''}
  </div>`;
}

// ── the city ──
const locked = (id) => S.city.locks.includes(id);
function tools(id) {
  const on = locked(id);
  return `<span class="city-tools">
    <button type="button" class="btn btn-sm btn-ghost" aria-pressed="${on}" title="${on ? 'Unlock' : 'Lock - keep this through a reroll'}"
      onclick="City.lock('${escJs(id)}')">${on ? '🔒' : '🔓'}</button>
    <button type="button" class="btn btn-sm btn-ghost" title="Reroll just this" ${on ? 'disabled' : ''}
      onclick="City.reroll('${escJs(id)}')">🎲</button>
  </span>`;
}
const card = (id, body) => `<div class="city-entry${locked(id) ? ' is-locked' : ''}" id="e-${esc(id)}">${tools(id)}<div>${body}</div></div>`;

// ── the map (Phase 2) ──
// An SVG in the map's own 0..1000 units, scaled to the panel's width, so it
// reads on a phone and prints as it looks. Pins are numbered, and the list
// under the map says what each number is - a label on every pin would not
// fit on a phone. A pin is a real link to its entry.
const pts = (poly) => poly.map(([x, y]) => `${x},${y}`).join(' ');
const pinNo = (map, id) => map?.pins.find((p) => p.id === id)?.n;
// The entry's number on the map, so the list and the map can be read together.
const pinTag = (c, id) => (pinNo(c.map, id) ? `<span class="tag map-no">${pinNo(c.map, id)}</span> ` : '');

function mapHtml(c) {
  const m = c.map;
  if (!m) return '';
  const districts = m.districts.map((d, i) => `<g class="map-district${d.race ? ' is-quarter' : ''}">
      <polygon points="${pts(d.polygon)}" class="map-cell ${d.race ? 'map-cell-quarter' : `map-cell-${i % 4}`}"><title>${
        esc(d.name)}</title></polygon>
    </g>`).join('');
  // Labels on their own layer, over the roads and the wall, under the pins.
  const labels = m.districts.map((d) =>
    `<text x="${d.label[0]}" y="${d.label[1]}" class="map-label">${esc(d.name)}</text>`).join('');
  const river = m.river ? `<polyline points="${pts(m.river)}" class="map-river"/>` : '';
  const wall = m.wall ? `<polygon points="${pts(m.wall)}" class="map-wall"/>` : '';
  const roads = m.roads.map((r) => `<polyline points="${pts(r)}" class="map-road"/>`).join('');
  const gates = m.wall ? m.gates.map(([x, y]) => `<rect x="${x - 14}" y="${y - 14}" width="28" height="28" class="map-gate"/>`).join('') : '';
  const pins = m.pins.map((p) => `<a href="#e-${esc(p.id)}" onclick="City.goto('${escJs(p.id)}'); return false;"
      aria-label="${p.n}: ${esc(p.label)}">
      <g class="map-pin map-pin-${p.kind}">${p.kind === 'shop'
        ? `<rect x="${p.at[0] - 16}" y="${p.at[1] - 16}" width="32" height="32" rx="4"/>`
        : `<circle cx="${p.at[0]}" cy="${p.at[1]}" r="17"/>`}
      <text x="${p.at[0]}" y="${p.at[1]}">${p.n}</text></g></a>`).join('');
  return `<div class="panel city-map-panel">
    <h3 style="margin-top:0">Map <span class="muted small">— districts${m.wall ? ', walls and gates' : ''}${m.river ? ', the river' : ''};
      numbers are places (○) and shops (■)</span></h3>
    <svg class="city-map" viewBox="${(m.view || [0, 0, m.size, m.size]).join(' ')}" role="img" aria-label="Map of ${esc(c.overview.name)}">
      <defs><pattern id="quarter-hatch" width="16" height="16" patternUnits="userSpaceOnUse" patternTransform="rotate(45)">
        <rect width="16" height="16" class="map-hatch-bg"/><line x1="0" y1="0" x2="0" y2="16" class="map-hatch"/></pattern></defs>
      <polygon points="${pts(m.outline)}" class="map-ground"/>
      ${river}${districts}${roads}${wall}${gates}${labels}${pins}
    </svg>
    <ol class="map-key small">${m.pins.map((p) => `<li value="${p.n}"><a href="#e-${esc(p.id)}"
      onclick="City.goto('${escJs(p.id)}'); return false;">${esc(p.label)}</a>
      <span class="muted">${p.kind === 'shop' ? 'shop' : 'place'}, ${esc(p.district)}</span>
      ${S.saved ? revealToggle(c, p.id) : ''}</li>`).join('')}</ol>
  </div>`;
}

// ── keeping it (Phase 3) ──
// A city is saved into one of the G.M.'s own campaigns, whole, as generated.
// Until then everything is only in this page. Once saved, each pin gets a
// reveal switch and each district, place and shop a "what the players read"
// line - the only text a player view will ever carry about it. A G.M.'s
// secrets stay in the fields the players' view never reads.
const revealed = (c, id) => !!c.reveal?.[id];
function revealToggle(c, id) {
  const on = revealed(c, id);
  return `<button type="button" class="btn btn-sm btn-ghost city-reveal" aria-pressed="${on}"
    title="${on ? 'Shown to the players - hide it' : 'Hidden from the players - reveal it'}"
    onclick="City.reveal('${escJs(id)}')">${on ? '👁 shown' : '🙈 hidden'}</button>`;
}
function publicField(c, id) {
  if (!S.saved) return '';
  return `<input type="text" class="picker-input city-public" value="${esc(c.public?.[id] || '')}"
    placeholder="What the players read about this (optional)" aria-label="What the players read"
    onchange="City.publicText('${escJs(id)}', this.value)">`;
}

function keepHtml() {
  const c = S.city;
  const camps = S.camps || [];
  const sys = c?.settings?.system;
  const own = camps.filter((x) => !sys || x.system === sys);
  const openList = S.savedList
    ? (S.savedList.length ? `<ul class="small">${S.savedList.map((x) => `<li><a href="#" onclick="City.openSaved(${x.id}); return false;">${
        esc(x.name)}</a> <span class="muted">${x.show_map ? 'map shown' : 'hidden'}</span></li>`).join('')}</ul>`
      : '<p class="muted small">No cities kept in that campaign yet.</p>')
    : '';
  return `<div class="panel city-keep">
    <h3 style="margin-top:0">Keep it in a campaign <span class="muted small">— your campaigns only; everything stays yours until you show it</span></h3>
    ${c ? (S.saved
      ? `<p class="small">Saved in <b>${esc(camps.find((x) => x.id === S.saved.campaign_id)?.name || 'campaign ' + S.saved.campaign_id)}</b>${
          S.dirty ? ' — <span class="warn">changed since</span>' : ''}.</p>
        <div class="rowline" style="flex-wrap:wrap">
          <button type="button" class="btn btn-sm btn-primary" onclick="City.keep()" ${S.dirty ? '' : 'disabled'}>💾 Save changes</button>
          <label class="small"><input type="checkbox" ${S.saved.show_map ? 'checked' : ''} onchange="City.showMap(this.checked)">
            Show the map to players</label>
          ${/* What the table sees, from the server's player view - the same
               page a player opens. The G.M. may open it before showing it. */ ''}
          <a class="btn btn-sm" href="/apps/gm-tools/present.html?city_id=${S.saved.id}">▶ Present what the players see</a>
          <button type="button" class="btn btn-sm btn-ghost" onclick="City.deleteSaved()">delete saved city</button>
          <button type="button" class="btn btn-sm btn-ghost" onclick="City.forget()">start a new city</button>
        </div>`
      : `<div class="rowline" style="flex-wrap:wrap">
          <label class="small">Campaign <select id="keep-camp">
            ${own.length ? own.map((x) => `<option value="${x.id}">${esc(x.name)}</option>`).join('')
              : `<option value="">— none of yours is ${esc(sys || '')} —</option>`}
          </select></label>
          <button type="button" class="btn btn-sm btn-primary" onclick="City.keep()" ${own.length ? '' : 'disabled'}>💾 Save this city</button>
        </div>`) : ''}
    <div class="rowline" style="flex-wrap:wrap;margin-top:8px">
      <label class="small">Open a kept city from <select onchange="City.listSaved(this.value)">
        <option value="">— a campaign —</option>
        ${camps.map((x) => `<option value="${x.id}"${String(x.id) === S.openCamp ? ' selected' : ''}>${esc(x.name)}</option>`).join('')}
      </select></label>
    </div>
    ${openList}
    ${S.keepMsg ? `<p class="small${S.keepErr ? ' err' : ''}">${esc(S.keepMsg)}</p>` : ''}
  </div>`;
}

// ── "Roll stats" (Phase 4a) ──
// A kept city's NPC can become a statted NPC in its campaign: the roller
// builds their race's R.C.C. with the job their role maps to, and the sheet
// is linked from the entry. The roller refuses rather than guesses; its
// refusal is shown here as it comes, and nothing is invented to stand in.
function statsTools(n) {
  if (!S.saved) return '';
  const r = S.rolls[n.id];
  const link = n.sheet_id
    ? `<a class="btn btn-sm btn-ghost" href="/apps/character-sheet/?id=${n.sheet_id}">📜 open sheet</a>`
    : `<button type="button" class="btn btn-sm btn-ghost" onclick="City.rollStats('${escJs(n.id)}')" ${r?.busy ? 'disabled' : ''}>
        ${r?.busy ? 'Rolling…' : '🎲 Roll stats'}</button>`;
  return `<div class="rowline city-stats" style="flex-wrap:wrap">${link}
    ${r?.msg ? `<span class="small${r.err ? ' err' : ' muted'}">${esc(r.msg)}</span>` : ''}</div>`;
}

// ── shop inventories (Phase 4b) ──
// Real gear rows from the Codex, copied into the city with this city's price,
// so a kept city keeps its stock when the Codex changes. A shop the Codex can
// only partly stock says so; nothing is invented to fill the shelf.
function stockHtml(s) {
  if (!s.inventory) {
    return `<button type="button" class="btn btn-sm btn-ghost" onclick="City.stock('${escJs(s.id)}')">📦 Stock it</button>`;
  }
  return `<details class="city-stock"><summary class="small">${s.inventory.length} item${s.inventory.length === 1 ? '' : 's'} for sale</summary>
    <table class="small"><thead><tr><th>Item</th><th>Here</th><th>Book</th></tr></thead><tbody>
      ${s.inventory.map((i) => `<tr><td>${esc(i.name)}</td><td>${i.price} gp</td><td class="muted">${i.book}</td></tr>`).join('')}
    </tbody></table>
    ${s.stock_note ? `<p class="small warn">${esc(s.stock_note)}</p>` : ''}
    <button type="button" class="btn btn-sm btn-ghost" onclick="City.restock('${escJs(s.id)}')">🎲 Restock</button>
  </details>`;
}
async function loadGear() {
  if (S.gear) return S.gear;
  S.gear = (await api('codex?section=gear')).gear || [];
  return S.gear;
}

function cityHtml() {
  const c = S.city;
  if (!c) return '';
  const o = c.overview;
  const npcName = Object.fromEntries(c.npcs.map((n) => [n.id, n.name || '(unnamed)']));
  return `<div class="panel">
    <div class="rowline" style="flex-wrap:wrap;justify-content:space-between">
      <h2 style="margin:0">${esc(o.name)}</h2>
      <span class="rowline">
        <button type="button" class="btn btn-sm" onclick="City.rerollAll()">🎲 Reroll everything unlocked</button>
        <button type="button" class="btn btn-sm" onclick="City.exportJson()">⬇ Export JSON</button>
      </span>
    </div>
    <p class="muted small">Seed ${esc(c.seed)}${c.pool ? ' · names from this city\'s own AI name pool' : ' · built-in names'}</p>
    ${c.warnings?.length ? `<ul class="small warn">${c.warnings.map((w) => `<li>${esc(w)}</li>`).join('')}</ul>` : ''}
    ${card('overview', `<p><b>${esc(o.size)}</b> of ${Number(o.population).toLocaleString()} ·
      ruled by ${esc(o.government)} · ${esc(o.wealth)} · lives on ${esc(o.trade)}</p>
      <p>${o.walls ? 'Walls: ' + esc(o.walls) + '.' : 'No walls.'}</p>
      ${o.factions.length ? `<p><b>Factions</b></p><ul>${o.factions.map((f) =>
        `<li><b>${esc(f.name)}</b>${f.goal ? ', ' + esc(f.goal) : ''}</li>`).join('')}</ul>` : ''}`)}
  </div>

  ${mapHtml(c)}

  <div class="panel"><h3 style="margin-top:0">Districts</h3>
    ${c.districts.map((d) => card(d.id, `<p><b>${esc(d.name)}</b>${d.name !== d.kind ? ` <span class="muted small">${esc(d.kind)}</span>` : ''}
      — ${esc(d.mood)}</p>
      <details><summary class="small">d6 encounters</summary><ol class="small">${d.encounters.map((e) => `<li>${esc(e.text)}</li>`).join('')}</ol></details>
      ${publicField(c, d.id)}`)).join('')}
  </div>

  <div class="panel"><h3 style="margin-top:0">Places of interest</h3>
    ${c.places.map((p) => card(p.id, `<p>${pinTag(c, p.id)}${esc(p.name)}${p.district ? ` <span class="muted small">— ${esc(p.district)}</span>` : ''}</p>
      ${publicField(c, p.id)}`)).join('')}
  </div>

  <div class="panel"><h3 style="margin-top:0">Shops and taverns</h3>
    <div class="rowline" style="flex-wrap:wrap">
      <button type="button" class="btn btn-sm" onclick="City.stockAll()">📦 Stock every shop from the Codex</button>
      <span class="muted small">6-10 real items each, at book price × the city's wealth (${esc(o.wealth)})</span>
    </div>
    ${S.stockMsg ? `<p class="small err">${esc(S.stockMsg)}</p>` : ''}
    ${c.shops.map((s) => card(s.id, `<p>${pinTag(c, s.id)}<b>${esc(s.name || '(unnamed)')}</b> <span class="muted small">${esc(s.type)}${s.district ? ', ' + esc(s.district) : ''}</span></p>
      <p class="small">Known for ${esc(s.specialty)}. Prices ${esc(s.price)}. Owner: ${esc(npcName[s.owner] || 'nobody named')} — ${esc(s.quirk)}.</p>
      ${stockHtml(s)}
      ${publicField(c, s.id)}`)).join('')}
  </div>

  <div class="panel"><h3 style="margin-top:0">Named NPCs <span class="muted small">— ${c.npcs.length}</span></h3>
    ${c.npcs.map((n) => card(n.id, `<p><b>${esc(n.name || '(unnamed)')}</b> <span class="muted small">${esc(n.race)}, ${esc(n.role)}</span></p>
      <p class="small">${esc(n.look)}; ${esc(n.quirk)}. Wants ${esc(n.want)}.
      <span class="gm-secret">Secret: ${esc(n.secret)}.</span></p>
      ${statsTools(n)}`)).join('') || '<p class="muted small">None asked for.</p>'}
  </div>

  <div class="panel"><h3 style="margin-top:0">City quirks</h3>
    ${c.quirks.map((q) => card(q.id, `<p>${esc(q.text)}</p>`)).join('')}
  </div>

  <div class="panel"><h3 style="margin-top:0">Rumours <span class="muted small">— d10, marked for you</span></h3>
    ${c.rumours.map((x) => card(x.id, `<p><b>${x.roll}.</b> ${esc(x.text)}
      <span class="tag ${x.true ? 'rumour-true' : 'rumour-false'}">${x.true ? 'true' : 'false'}</span></p>`)).join('')}
  </div>`;
}

function render() {
  $('settings').innerHTML = settingsHtml();
  $('city').innerHTML = keepHtml() + cityHtml();
}

// ── keeping: the requests ──
// The G.M.'s own campaigns: a city is saved only into one they run, and the
// server refuses anything else (requireCampaign) whatever this list says.
async function loadCamps() {
  try {
    const [c, me] = await Promise.all([api('campaigns?limit=500'), api('me')]);
    S.camps = (c.campaigns || []).filter((x) => x.gm_email === me.email);
  } catch { S.camps = []; }
}
const post = (path, method, body) => api(path, { method, headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(body) });
function keepFail(err) { S.keepMsg = err.message; S.keepErr = true; render(); }
// A reroll or an edit to a saved city marks it changed; Save puts it back.
function changed() { if (S.saved) S.dirty = true; }

// ── actions ──
const num = (v, lo, hi) => Math.max(lo, Math.min(hi, Math.trunc(Number(v)) || 0));

async function generate() {
  const problems = settingsProblems(S.settings);
  if (problems.length) return render();
  S.busy = true; S.msg = ''; S.err = false;
  render();
  const seed = S.seed.trim() ? (Number(S.seed) >>> 0 || hashSeed(S.seed)) : newSeed();
  try {
    let pool = null;
    if (S.nameTheme.trim() || S.settings.races.some((x) => x.theme?.trim())) {
      S.msg = 'Asking for a name pool…'; render();
      const { system, prompt } = poolPrompt(S.settings, S.nameTheme.trim() || 'fantasy');
      // 12,000 tokens: the first try at 4,000 stopped mid-list (stop_reason
      // max_tokens) once the model's thinking and ~300 names were counted.
      const res = await claudeRequest({ model: MODEL, max_tokens: 12000, system,
        messages: [{ role: 'user', content: prompt }] });
      if (res.stop_reason === 'max_tokens') throw new Error('The name pool was cut off before it finished - try again, or a shorter theme');
      pool = parsePool(res.content?.map((b) => b.text || '').join('') || '', S.settings);
    }
    S.city = withMap(generateCity(S.settings, seed, pool));
    // A new city is not the saved one: saving it makes another row.
    S.saved = null; S.dirty = false; S.keepMsg = '';
    S.msg = '';
    save();
  } catch (err) {
    S.msg = err.message; S.err = true;
  }
  S.busy = false;
  render();
}
// A typed seed that is not a number is still a seed.
function hashSeed(s) { let h = 0; for (const ch of s) h = (Math.imul(h, 31) + ch.charCodeAt(0)) >>> 0; return h; }

window.City = {
  set(key, value) {
    const s = S.settings;
    if (key === 'population') s.population = num(value, 1, 10000000);
    else if (key === 'npcCount') s.npcCount = num(value, 0, 200);
    else if (key === 'everyRace') s.everyRace = !!value;
    else if (key === 'system') { s.system = value; S.rccs = null; loadRaces().then(render); }
    save(); render();
  },
  suggest(pop) { if (pop) { S.settings.population = Number(pop); save(); render(); } },
  race(i, key, value) {
    const x = S.settings.races[i];
    if (key === 'id') { const c = S.rccs.find((r) => r.id === value); x.id = value; x.name = c?.name || value; }
    else if (key === 'pct') x.pct = Math.max(0, Math.min(100, Number(value) || 0));
    else x[key] = value;
    save(); render();
  },
  addRace() {
    const taken = new Set(S.settings.races.map((x) => x.id));
    const next = (S.rccs || []).find((c) => !taken.has(c.id));
    if (next) S.settings.races.push({ id: next.id, name: next.name, pct: 0, theme: '' });
    save(); render();
  },
  dropRace(i) { S.settings.races.splice(i, 1); save(); render(); },
  restHuman() {
    const human = (S.rccs || []).find((c) => c.id === 'human') || { id: 'human', name: 'Human' };
    S.settings.races = restAreHuman(S.settings.races, { ...human, theme: '' });
    save(); render();
  },
  theme(v) { S.nameTheme = v; save(); },
  seed(v) { S.seed = v; },
  generate,
  lock(id) { S.city = toggleLock(S.city, id); changed(); save(); render(); },
  async keep() {
    S.keepMsg = ''; S.keepErr = false;
    try {
      if (S.saved) {
        const { reveal: _r, public: _p, ...summary } = await post(`cities/${S.saved.id}`, 'PATCH', { city: S.city });
        S.saved = { ...S.saved, ...summary };
        S.keepMsg = 'Saved.';
      } else {
        const campaignId = Number($('keep-camp')?.value);
        const res = await post(`campaigns/${campaignId}/cities`, 'POST', { city: S.city });
        S.saved = res.city;
        S.keepMsg = `Kept ${res.city.name}. Nothing is shown to the players until you say so.`;
      }
      S.dirty = false;
      save(); render();
    } catch (err) { keepFail(err); }
  },
  async showMap(on) {
    try {
      const res = await post(`cities/${S.saved.id}`, 'PATCH', { show_map: !!on });
      S.saved = { ...S.saved, show_map: res.show_map };
      S.keepMsg = res.show_map ? 'The map is shown to the players - revealed pins only.' : 'The map is hidden again.';
      S.keepErr = false; save(); render();
    } catch (err) { keepFail(err); }
  },
  // Reveal and public text are saved straight away: they are the switches a
  // G.M. flips mid-session, and waiting for "Save changes" would lose them.
  async reveal(id) {
    try {
      const res = await post(`cities/${S.saved.id}`, 'PATCH', { reveal: { [id]: !revealed(S.city, id) } });
      S.city = { ...S.city, reveal: res.reveal };
      save(); render();
    } catch (err) { keepFail(err); }
  },
  async publicText(id, text) {
    try {
      const res = await post(`cities/${S.saved.id}`, 'PATCH', { public: { [id]: text } });
      S.city = { ...S.city, public: res.public };
      save();
    } catch (err) { keepFail(err); }
  },
  async listSaved(campaignId) {
    S.openCamp = campaignId; S.savedList = null;
    if (!campaignId) return render();
    try { S.savedList = (await api(`campaigns/${campaignId}/cities`)).cities || []; } catch (err) { return keepFail(err); }
    render();
  },
  async openSaved(id) {
    try {
      const res = await api(`cities/${id}`);
      S.city = res.city.map ? res.city : withMap(res.city);
      S.saved = { id: res.id, campaign_id: res.campaign_id, name: res.name, show_map: res.show_map };
      S.settings = structuredClone(res.city.settings);
      S.dirty = false; S.keepMsg = `Opened ${res.name}.`; S.keepErr = false;
      save(); render();
    } catch (err) { keepFail(err); }
  },
  async deleteSaved() {
    if (!confirm(`Delete the saved ${S.city.overview.name} from its campaign? The city stays on this page until you start another.`)) return;
    try {
      await api(`cities/${S.saved.id}`, { method: 'DELETE' });
      S.saved = null; S.dirty = false; S.keepMsg = 'Deleted from the campaign.'; S.keepErr = false;
      save(); render();
    } catch (err) { keepFail(err); }
  },
  async stock(id) {
    try { S.city = stockShop(S.city, id, await loadGear()); S.stockMsg = ''; changed(); save(); }
    catch (err) { S.stockMsg = 'Could not stock it: ' + err.message; }
    render();
  },
  async restock(id) {
    try { S.city = restockShop(S.city, id, await loadGear()); changed(); save(); }
    catch (err) { S.stockMsg = 'Could not restock it: ' + err.message; }
    render();
  },
  async stockAll() {
    try {
      const gear = await loadGear();
      for (const shop of S.city.shops) S.city = stockShop(S.city, shop.id, gear);
      S.stockMsg = ''; changed(); save();
    } catch (err) { S.stockMsg = 'Could not stock the shops: ' + err.message; }
    render();
  },
  async rollStats(id) {
    S.rolls[id] = { busy: true };
    render();
    try {
      const body = rollRequest(S.city, id);
      const res = await post(`campaigns/${S.saved.campaign_id}/npcs/generate`, 'POST', body);
      const made = res.npcs?.[0];
      if (!made) throw new Error(res.refused?.error || 'The roller made nobody');
      S.city = linkSheet(S.city, id, made.id);
      // The link is part of the kept city: saved at once, like a reveal.
      const { reveal: _r, public: _p, ...summary } = await post(`cities/${S.saved.id}`, 'PATCH', { city: S.city });
      S.saved = { ...S.saved, ...summary };
      const banked = (made.powers_banked || 0) + (made.picks_pending || 0);
      S.rolls[id] = { msg: `Rolled as ${body.occ_class_id ? 'a ' + body.occ_class_id.replace(/-/g, ' ') : 'their race alone'}${
        banked ? `; ${banked} pick${banked === 1 ? '' : 's'} banked on the sheet` : ''}.` };
      save();
    } catch (err) {
      // The roller's own words - a race that bars the job, a class it cannot build.
      S.rolls[id] = { msg: err.message, err: true };
    }
    render();
  },
  forget() { S.saved = null; S.dirty = false; S.keepMsg = ''; save(); render(); },
  reroll(id) { S.city = withMap(rerollEntry(S.city, id)); changed(); save(); render(); },
  rerollAll() { S.city = withMap(rerollCity(S.city, newSeed())); changed(); save(); render(); },
  // A pin names an entry: bring it into view and mark it for a moment.
  goto(id) {
    const el = document.getElementById('e-' + id);
    if (!el) return;
    // An instant jump: the flash already says where you landed, and a smooth
    // scroll does not move at all in a page the browser is not painting.
    el.scrollIntoView({ block: 'center' });
    el.classList.add('is-flash');
    setTimeout(() => el.classList.remove('is-flash'), 1600);
  },
  exportJson() {
    const blob = new Blob([exportJson(S.city)], { type: 'application/json' });
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = `${(S.city.overview.name || 'city').replace(/[^\w-]+/g, '-').toLowerCase()}.json`;
    a.click();
    setTimeout(() => URL.revokeObjectURL(a.href), 1000);
  },
};

restore();
await Promise.all([loadRaces(), loadCamps()]);
// ?seed=N opens on that city, built from the settings on screen - a seed can
// be passed on, and a printed page can be made without clicking. Built-in
// names only: a URL never spends an AI call.
const urlSeed = new URLSearchParams(location.search).get('seed');
if (urlSeed && !settingsProblems(S.settings).length) {
  S.seed = urlSeed;
  S.city = withMap(generateCity(S.settings, Number(urlSeed) >>> 0 || hashSeed(urlSeed), null));
  // A city from the URL is a new city, whatever was kept before it: left
  // pointing at the saved row, "Save changes" would overwrite that city
  // with this one. Seen when a reload of ?seed= showed "Saved in ...".
  S.saved = null; S.dirty = false;
}
render();
