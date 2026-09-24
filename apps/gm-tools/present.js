// Present mode — the GM's screen turned round at the table. P4b of the split.
//
// One picture, fitted to the screen, on black. Arrows move through the
// pictures of ONE page (migration 078's `campaign_entries`), Escape goes back
// to the dashboard with that page reopened.
//
// SHOW IS NOT REVEAL, and this file is where that holds or does not.
// `toggleReveal` is the ONLY function here that sends a write, and it runs
// from one button press and nothing else - not from opening the page, not from
// `go()`, not from a key. A GM shows a map to the room a dozen times before
// deciding the party keeps a copy of it, and those are different decisions:
// the second one lands in the players' Handouts tab forever and the first one
// ends when the laptop turns back round.
//
// The affordance is here ANYWAY, rather than only on the dashboard, because
// the two do happen together at a table and walking out of the room view to
// press a button on another page is how a GM ends up not bothering.
//
// NO innerHTML IN THIS FILE. The markup is static in present.html and this
// only fills it - a caption is set as textContent, an image as a src. That is
// why the page does not load ui.js: there is nothing here to escape.
'use strict';

const params = new URLSearchParams(location.search);
const campaignId = params.get('campaign_id');
const entryId = params.get('entry_id');

const $ = (id) => document.getElementById(id);
const P = { entry: null, images: [], at: 0, lock: null };

// api() comes from js/api.js, loaded first as a classic script.

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
  return P.cityGm ? '/apps/city-creator/'
    : '/apps/campaign/' + (P.cityCampaign ? '?campaign_id=' + encodeURIComponent(P.cityCampaign) : '');
}

function leave() { location.href = cityId ? cityBackUrl() : backUrl(); }

// A dead end says what went wrong and keeps the way out: the top bar stays,
// the picture and the arrows go. A player who reaches this URL lands here -
// the entry endpoint is GM-only, so the refusal is the server's rather than a
// check this page performs.
function fail(text) {
  document.body.classList.add('is-error');
  $('frame').hidden = true;
  $('state').hidden = false;
  $('state').textContent = text;
  wake(true);
}

async function load() {
  if (cityId) return loadCity();
  if (!campaignId || !entryId) {
    fail('Present mode opens a page of pictures. Pick one on the dashboard and press Present.');
    return;
  }
  try {
    const res = await api(`campaigns/${campaignId}/entries/${entryId}`);
    P.entry = res.entry;
    P.images = res.images || [];
  } catch (err) {
    fail(err.status === 403 ? 'Only the GM of this campaign can present its pages.' : err.message);
    return;
  }
  if (!P.images.length) {
    $('title').textContent = P.entry.title;
    fail('This page has no pictures yet. Add one on the dashboard and it can be shown here.');
    return;
  }
  // ?image_id= names the picture to open on, so "Present" on a particular
  // picture starts there rather than at the top of the page.
  const wanted = params.get('image_id');
  const at = P.images.findIndex((i) => String(i.id) === String(wanted));
  P.at = at >= 0 ? at : 0;
  $('state').hidden = true;
  $('frame').hidden = false;
  show();
  keepAwake();
}

function src(image) {
  return `/api/character-creator/campaigns/${campaignId}/images/${image.id}`;
}

function show() {
  const image = P.images[P.at];
  const pic = $('pic');
  pic.src = src(image);
  // The caption when there is one, the page's title when there is not: an
  // empty alt on the only thing on the screen tells a screen reader nothing.
  pic.alt = image.caption || P.entry.title;

  $('title').textContent = P.entry.title;
  $('count').textContent = `${P.at + 1} / ${P.images.length}`;
  $('caption').textContent = image.caption || '';
  $('prev').disabled = P.at === 0;
  $('next').disabled = P.at === P.images.length - 1;
  paintReveal(image);
  $('msg').textContent = '';

  // The address bar names the picture on screen, so a reload stays put and
  // Escape goes back to the right page.
  const q = new URLSearchParams({ campaign_id: campaignId, entry_id: entryId, image_id: String(image.id) });
  history.replaceState(null, '', location.pathname + '?' + q);

  // A picture is served at the size it was uploaded - up to 5MB, and there is
  // no resizing on this runtime - so the one after this is fetched now rather
  // than when the arrow is pressed. Both neighbours, because a GM steps back
  // through a page as often as forward.
  for (const n of [P.at + 1, P.at - 1]) {
    if (P.images[n]) new Image().src = src(P.images[n]);
  }
}

function paintReveal(image) {
  const on = !!image.revealed_at;
  const btn = $('reveal');
  btn.textContent = on ? '🙈 Hide from players' : '👁 Reveal to players';
  btn.className = on ? 'btn' : 'btn btn-primary';
  // Said plainly, because it is the one thing on this screen that has already
  // left the room: what the party can open in their own Handouts tab.
  $('shown').textContent = on ? 'the party has this' : 'yours alone — showing it here does not change that';
}

function goTo(at) {
  if (at < 0 || at >= P.images.length || at === P.at) return;
  P.at = at;
  show();
}

const go = (by) => goTo(P.at + by);

// THE ONE WRITE ON THIS PAGE.
async function toggleReveal() {
  const image = P.images[P.at];
  const on = !image.revealed_at;
  $('msg').textContent = on ? 'Revealing…' : 'Hiding…';
  try {
    const res = await api(`campaigns/${campaignId}/images/${image.id}`, {
      method: 'PATCH', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ revealed: on }),
    });
    P.images[P.at] = { ...image, ...res.image };
    paintReveal(P.images[P.at]);
    $('msg').textContent = on ? 'In their Handouts now.' : 'Gone from their Handouts.';
  } catch (err) {
    $('msg').textContent = err.message;
  }
}

// ---------- a city's map (City Creator, Phase 4c) ----------
//
// ?city_id=N shows what the PLAYERS may see of a kept city: its districts, the
// pins the G.M. revealed, and the lines the G.M. wrote for them. It reads the
// server's player view (cities/:id/view), which is BUILT from those parts and
// nothing else, so there is nothing on this page to hide - a player who opens
// it sees exactly what the G.M. sees here. It writes nothing: revealing a pin
// is the City Creator's, and this file's one write stays toggleReveal's.
//
// Drawn with createElementNS and textContent, never innerHTML, like the rest
// of this file: a district or a pin is named by whoever wrote the city.
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
  catch (err) { fail(err.status === 404 ? 'That city map is not shown to the players.' : err.message); return; }
  const c = res.city;
  P.cityGm = res.is_gm;
  P.cityCampaign = c.campaign_id;
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
  if (m.river) box.append(svg('polyline', { points: svgPts(m.river), class: 'map-river' }));
  m.districts.forEach((d, i) => {
    const cell = svg('polygon', { points: svgPts(d.polygon), class: `map-cell ${d.quarter ? 'map-cell-quarter' : 'map-cell-' + (i % 4)}` });
    cell.append(svg('title', {}, d.name));
    box.append(cell);
  });
  // A theme's street plan, as the City Creator draws it: over the districts.
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
  keepAwake();
}

// ---------- the chrome, and when it is not there ----------
//
// Everything that is not the picture fades after a few seconds of nothing
// happening, and comes back on any movement, key or touch. A GM who turns the
// laptop round mid-sentence should not be showing the party a row of buttons.
let idle = null;
function wake(stay) {
  document.body.classList.remove('idle');
  clearTimeout(idle);
  if (!stay) idle = setTimeout(() => document.body.classList.add('idle'), 2800);
}

// ---------- the screen stays on ----------
//
// A tablet propped on the table dims and locks in a minute or two, which is
// the exact failure this page exists to avoid. Not supported everywhere and
// refused in some contexts; a refusal is silent because the page works
// perfectly well without it and a warning would be noise the GM cannot act on.
async function keepAwake() {
  try {
    P.lock = await navigator.wakeLock?.request('screen');
    P.lock?.addEventListener('release', () => { P.lock = null; });
  } catch { /* see above */ }
}

async function fullscreen() {
  try {
    if (document.fullscreenElement) await document.exitFullscreen();
    else await document.documentElement.requestFullscreen();
  } catch { /* a browser may refuse it; nothing else depends on it */ }
}

function bind() {
  $('prev').addEventListener('click', () => go(-1));
  $('next').addEventListener('click', () => go(1));
  $('close').addEventListener('click', leave);
  $('fullscreen').addEventListener('click', fullscreen);
  $('reveal').addEventListener('click', toggleReveal);
  document.addEventListener('fullscreenchange', () => {
    $('fullscreen').textContent = document.fullscreenElement ? '⛶ Leave fullscreen' : '⛶ Fullscreen';
  });

  // Arrows, and the two keys a presenter's clicker actually sends. NOT the
  // space bar: space activates whatever button has focus, and the button most
  // likely to have it is the one that shows a picture to the party.
  document.addEventListener('keydown', (e) => {
    wake();
    if (e.key === 'Escape') leave();
    else if (e.key === 'ArrowRight' || e.key === 'PageDown') go(1);
    else if (e.key === 'ArrowLeft' || e.key === 'PageUp') go(-1);
    else if (e.key === 'Home') goTo(0);
    else if (e.key === 'End') goTo(P.images.length - 1);
    else return;
    e.preventDefault();
  });
  for (const ev of ['mousemove', 'pointerdown', 'touchstart', 'wheel']) {
    document.addEventListener(ev, () => wake(), { passive: true });
  }
  // The lock is dropped whenever the tab is hidden and is not handed back, so
  // it has to be asked for again when the page comes forward.
  document.addEventListener('visibilitychange', () => {
    if (document.visibilityState === 'visible' && !P.lock && P.images.length) keepAwake();
  });
}

bind();
wake();
load();
