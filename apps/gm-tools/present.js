// Present mode — the GM's screen turned round at the table. P4b of the split.
//
// The room view itself - one picture on black, the arrows and keys, the chrome
// that fades, the wake lock, and the one button that reveals - is
// /shared/js/campaign/present.js, shared with every game's GM page. SHOW IS
// NOT REVEAL is held there, and read there by the smoke suite.
//
// What stays here is this game's: where leaving goes, and the City Creator's
// maps, which only the Palladium pages have.
//
// NO innerHTML IN THIS FILE EITHER. The markup is static in present.html and
// this only fills it, which is why the page does not load ui.js: there is
// nothing here to escape.
'use strict';

const params = new URLSearchParams(location.search);
const campaignId = params.get('campaign_id');
const entryId = params.get('entry_id');

const $ = (id) => document.getElementById(id);
// A city's view goes back to where it was opened from, which the server's
// answer says (loadCity).
const C = { gm: false, campaign: null };

// api() comes from js/api.js, loaded first as a classic script; the city view
// is the only request this file makes.

// Where Escape and ✕ go. The dashboard reopens the page named here, so
// leaving present mode lands on the page you were presenting FROM rather than
// at the top of the roster - which is what a GM who stepped out to show a map
// wants to come back to.
function backUrl() {
  const q = new URLSearchParams();
  if (campaignId) q.set('campaign_id', campaignId);
  if (entryId) q.set('entry_id', entryId);
  return '/apps/gm-tools/' + (q.toString() ? '?' + q : '');
}

// A city's view goes back to where it was opened from: the City Creator for
// its G.M., the campaign's notes for a player.
function cityBackUrl() {
  return C.gm ? '/apps/city-creator/'
    : '/apps/campaign/' + (C.campaign ? '?campaign_id=' + encodeURIComponent(C.campaign) : '');
}

function leave() { location.href = cityId ? cityBackUrl() : backUrl(); }

// ---------- a city's map (City Creator, Phase 4c) ----------
//
// ?city_id=N shows what the PLAYERS may see of a kept city: its districts, the
// pins the G.M. revealed, and the lines the G.M. wrote for them. It reads the
// server's player view (cities/:id/view), which is BUILT from those parts and
// nothing else, so there is nothing on this page to hide - a player who opens
// it sees exactly what the G.M. sees here. It writes nothing: revealing a pin
// is the City Creator's, and the room view's one write stays toggleReveal's.
//
// Drawn with createElementNS and textContent, never innerHTML: a district or a
// pin is named by whoever wrote the city.
const cityId = params.get('city_id');
const SVG = 'http://www.w3.org/2000/svg';
function svg(tag, attrs, text) {
  const el = document.createElementNS(SVG, tag);
  for (const [k, v] of Object.entries(attrs || {})) el.setAttribute(k, v);
  if (text != null) el.textContent = text;
  return el;
}
const svgPts = (list) => list.map(([x, y]) => `${x},${y}`).join(' ');

async function loadCity() {
  document.body.classList.add('is-city');
  for (const id of ['prev', 'next', 'reveal', 'shown', 'count']) $(id).hidden = true;
  let res;
  try { res = await api(`cities/${cityId}/view`); }
  catch (err) { mcPresent.fail(err.status === 404 ? 'That city map is not shown to the players.' : err.message); return; }
  const c = res.city;
  C.gm = res.is_gm;
  C.campaign = c.campaign_id;
  $('title').textContent = c.name;
  const m = c.map;
  const box = $('citymap');
  box.setAttribute('viewBox', (m.view || [0, 0, m.size, m.size]).join(' '));
  box.setAttribute('aria-label', `Map of ${c.name}`);
  box.replaceChildren();
  // The quarter hatch city.css fills a race quarter with: defined per page,
  // so this page draws its own copy of the City Creator's pattern.
  const hatch = svg('pattern', { id: 'quarter-hatch', width: 16, height: 16, patternUnits: 'userSpaceOnUse',
    patternTransform: 'rotate(45)' });
  hatch.append(svg('rect', { width: 16, height: 16, class: 'map-hatch-bg' }),
    svg('line', { x1: 0, y1: 0, x2: 0, y2: 16, class: 'map-hatch' }));
  const defs = svg('defs');
  defs.append(hatch);
  box.append(defs, svg('polygon', { points: svgPts(m.outline), class: 'map-ground' }));
  m.districts.forEach((d, i) => {
    const cell = svg('polygon', { points: svgPts(d.polygon), class: `map-cell ${d.quarter ? 'map-cell-quarter' : 'map-cell-' + (i % 4)}` });
    cell.append(svg('title', {}, d.name));
    box.append(cell);
  });
  // The river, then a theme's street plan, as the City Creator draws them:
  // over the districts, whose fills are opaque.
  if (m.river) box.append(svg('polyline', { points: svgPts(m.river), class: 'map-river' }));
  for (const c of m.canals || []) box.append(svg('polyline', { points: svgPts(c), class: 'map-canal' }));
  if (m.core) box.append(svg('polygon', { points: svgPts(m.core), class: 'map-core' }));
  for (const l of m.streets || []) box.append(svg('polyline', { points: svgPts(l), class: 'map-street' }));
  for (const r of m.roads) box.append(svg('polyline', { points: svgPts(r), class: 'map-road' }));
  if (m.rail) {
    box.append(svg('polyline', { points: svgPts(m.rail), class: 'map-rail' }),
      svg('polyline', { points: svgPts(m.rail), class: 'map-rail-ties' }));
    if (m.station) box.append(svg('rect', { x: m.station[0] - 18, y: m.station[1] - 10, width: 36, height: 20, class: 'map-station' }));
  }
  if (m.wall) box.append(svg('polygon', { points: svgPts(m.wall), class: 'map-wall' }));
  for (const [x, y] of m.gates) box.append(svg('rect', { x: x - 14, y: y - 14, width: 28, height: 28, class: 'map-gate' }));
  for (const d of m.districts) if (d.label) box.append(svg('text', { x: d.label[0], y: d.label[1], class: 'map-label' }, d.name));
  for (const p of c.pins) {
    const g = svg('g', { class: `map-pin map-pin-${p.kind}` });
    g.append(p.kind === 'shop'
      ? svg('rect', { x: p.at[0] - 16, y: p.at[1] - 16, width: 32, height: 32, rx: 4 })
      : svg('circle', { cx: p.at[0], cy: p.at[1], r: 17 }));
    g.append(svg('text', { x: p.at[0], y: p.at[1] }, String(p.n)));
    g.append(svg('title', {}, p.label));
    box.append(g);
  }
  // What the players read: each revealed pin and each district the G.M. wrote a
  // line for, as text.
  const key = $('citykey');
  key.replaceChildren();
  for (const p of c.pins) {
    const li = document.createElement('li');
    li.value = p.n;
    const b = document.createElement('b');
    b.textContent = p.label;
    li.append(b, document.createTextNode(p.text ? ` - ${p.text}` : ''));
    key.append(li);
  }
  const notes = $('citynotes');
  notes.replaceChildren();
  for (const d of m.districts.filter((x) => x.text)) {
    const para = document.createElement('p');
    const b = document.createElement('b');
    b.textContent = d.name;
    para.append(b, document.createTextNode(` - ${d.text}`));
    notes.append(para);
  }
  $('caption').textContent = c.pins.length ? '' : 'No places marked yet.';
  $('state').hidden = true;
  $('city').hidden = false;
  mcPresent.keepAwake();
  // The Table: a city can go on the TV too. The shared half decides whether
  // to offer it (a table open, and this person its GM) and sends the show.
  mcPresent.offer({ kind: 'city', id: cityId }, c.campaign_id);
}

mcPresent.start({
  base: '/api/character-creator', campaignId, entryId, imageId: params.get('image_id'),
  leave, load: cityId ? loadCity : null,
});
