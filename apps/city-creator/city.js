// City Creator - the page. The engine is js/city-engine.js, a pure module;
// this file holds the settings, the city on screen and its locks, and draws
// them. Phase 1: text output, lock and reroll, JSON export. No map and no
// saving yet (Phases 2 and 3), so the city lives in this page - and in this
// browser's storage as a convenience, so a reload does not lose it.
//
// A module, so it can import the engine; the inline handlers reach it through
// window.City. escHtml()/escJs() come from /shared/js/ui.js, api() from
// /apps/character-creator/js/api.js, claudeRequest() from /shared/js/api.js.

import { generateCity, rerollCity, rerollEntry, toggleLock, settingsProblems, restAreHuman,
  suggestions, sizeFor, newSeed, poolPrompt, parsePool, exportJson, SUPPORTED_SYSTEMS } from './js/city-engine.js';

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
};

// ── storage: a convenience, never the record ──
function save() {
  try { localStorage.setItem(STORE, JSON.stringify({ settings: S.settings, nameTheme: S.nameTheme, city: S.city })); }
  catch { /* private mode, full storage - the page works without it */ }
}
function restore() {
  try {
    const v = JSON.parse(localStorage.getItem(STORE) || 'null');
    if (v?.settings) S.settings = v.settings;
    if (typeof v?.nameTheme === 'string') S.nameTheme = v.nameTheme;
    if (v?.city?.version === 1) S.city = v.city;
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
const card = (id, body) => `<div class="city-entry${locked(id) ? ' is-locked' : ''}">${tools(id)}<div>${body}</div></div>`;

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

  <div class="panel"><h3 style="margin-top:0">Districts</h3>
    ${c.districts.map((d) => card(d.id, `<p><b>${esc(d.name)}</b>${d.name !== d.kind ? ` <span class="muted small">${esc(d.kind)}</span>` : ''}
      — ${esc(d.mood)}</p>
      <details><summary class="small">d6 encounters</summary><ol class="small">${d.encounters.map((e) => `<li>${esc(e.text)}</li>`).join('')}</ol></details>`)).join('')}
  </div>

  <div class="panel"><h3 style="margin-top:0">Places of interest</h3>
    ${c.places.map((p) => card(p.id, `<p>${esc(p.name)}${p.district ? ` <span class="muted small">— ${esc(p.district)}</span>` : ''}</p>`)).join('')}
  </div>

  <div class="panel"><h3 style="margin-top:0">Shops and taverns</h3>
    ${c.shops.map((s) => card(s.id, `<p><b>${esc(s.name || '(unnamed)')}</b> <span class="muted small">${esc(s.type)}${s.district ? ', ' + esc(s.district) : ''}</span></p>
      <p class="small">Known for ${esc(s.specialty)}. Prices ${esc(s.price)}. Owner: ${esc(npcName[s.owner] || 'nobody named')} — ${esc(s.quirk)}.</p>`)).join('')}
  </div>

  <div class="panel"><h3 style="margin-top:0">Named NPCs <span class="muted small">— ${c.npcs.length}</span></h3>
    ${c.npcs.map((n) => card(n.id, `<p><b>${esc(n.name || '(unnamed)')}</b> <span class="muted small">${esc(n.race)}, ${esc(n.role)}</span></p>
      <p class="small">${esc(n.look)}; ${esc(n.quirk)}. Wants ${esc(n.want)}.
      <span class="gm-secret">Secret: ${esc(n.secret)}.</span></p>`)).join('') || '<p class="muted small">None asked for.</p>'}
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
  $('city').innerHTML = cityHtml();
}

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
    S.city = generateCity(S.settings, seed, pool);
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
  lock(id) { S.city = toggleLock(S.city, id); save(); render(); },
  reroll(id) { S.city = rerollEntry(S.city, id); save(); render(); },
  rerollAll() { S.city = rerollCity(S.city, newSeed()); save(); render(); },
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
await loadRaces();
render();
