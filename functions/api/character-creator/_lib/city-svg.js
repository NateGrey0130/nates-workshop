// A City Creator city's map as one SVG file - what the table's TV and phones
// load when the G.M. shows a city (The Table, phase 2).
//
// DRAWN FROM THE PLAYERS' VIEW AND NOTHING ELSE. The input is playerView()'s
// output (city-view.js), never the city, so whatever that function leaves out
// cannot be drawn here: no NPC, no secret, no pin the G.M. has not revealed.
//
// WHY A FILE AND NOT THE PAGE'S OWN DRAWING. The table page shows every
// picture the same way - an <img> fitted to the TV, and a tap on a phone to
// zoom - and it serves every picture through one route that asks the room
// first. A city drawn as a file is just another picture to both. The cost is a
// third drawing of the map, beside the City Creator's (city.js) and Present
// mode's (apps/gm-tools/present.js): the same shapes in the same order, pinned
// together by the City Creator smoke checks.
//
// An SVG loaded by <img> reaches no stylesheet and no web font, so the palette
// is written in: Board & Tissue's light tokens from
// apps/character-creator/styles.css, and the classes from city.css.

const esc = (s) => String(s ?? '').replace(/[&<>"']/g, (c) => `&#${c.charCodeAt(0)};`);
const num = (n) => (Number.isFinite(n) ? Math.round(n * 10) / 10 : 0);
const pts = (list) => list.map(([x, y]) => `${num(x)},${num(y)}`).join(' ');
const cut = (s, max) => (s.length > max ? `${s.slice(0, max - 1)}…` : s);

const STYLE = `
  .bg { fill: #FFFFFF; }
  .map-ground { fill: #F9FAF9; stroke: none; }
  .map-cell { stroke: #C1C7BF; stroke-width: 3; }
  .map-cell-0 { fill: #FFFFFF; } .map-cell-1 { fill: #F0F2EF; }
  .map-cell-2 { fill: #F9FAF9; } .map-cell-3 { fill: #FFFFFF; }
  .map-cell-quarter { fill: url(#quarter-hatch); }
  .map-hatch-bg { fill: #FFFFFF; }
  .map-hatch { stroke: #A8401A; stroke-width: 6; opacity: 0.35; }
  text { font-family: Archivo, system-ui, -apple-system, 'Segoe UI', sans-serif; fill: #1A1614; }
  .map-label { font-size: 26px; font-weight: 700; text-anchor: middle;
    paint-order: stroke; stroke: #FFFFFF; stroke-width: 6px; stroke-linejoin: round; }
  .map-river { fill: none; stroke: #8E3412; stroke-width: 22; stroke-linecap: round; stroke-linejoin: round; opacity: 0.55; }
  .map-road { fill: none; stroke: #4A433F; stroke-width: 7; stroke-dasharray: 18 10; stroke-linecap: round; }
  .map-wall { fill: none; stroke: #1A1614; stroke-width: 10; stroke-linejoin: round; }
  .map-canal { fill: none; stroke: #8E3412; stroke-width: 12; stroke-linecap: round; stroke-linejoin: round; opacity: 0.5; }
  .map-street { fill: none; stroke: #C1C7BF; stroke-width: 2.5; opacity: 0.7; }
  .map-rail { fill: none; stroke: #1A1614; stroke-width: 5; }
  .map-rail-ties { fill: none; stroke: #1A1614; stroke-width: 16; stroke-dasharray: 3 14; }
  .map-station { fill: #FFFFFF; stroke: #1A1614; stroke-width: 4; }
  .map-core { fill: #4A433F; fill-opacity: 0.18; stroke: #1A1614; stroke-width: 4; stroke-dasharray: 10 6; }
  .map-gate { fill: #FFFFFF; stroke: #1A1614; stroke-width: 5; }
  .map-pin circle, .map-pin rect { stroke: #1A1614; stroke-width: 3; }
  .map-pin-place circle { fill: #FFFFFF; }
  .map-pin-shop rect { fill: #A8401A; }
  .map-pin text { font-size: 20px; font-weight: 700; text-anchor: middle; dominant-baseline: central; }
  .map-pin-shop text { fill: #FFFFFF; }
  .key-title { font-weight: 700; }
  .key-name { font-weight: 700; }
  .key-text { fill: #4A433F; }
`;

// The map, then - when there is anything to read - a key to its right: each
// revealed pin by number, and each district the G.M. wrote a line for. The
// same two lists Present mode shows under its map.
export function citySvg(city) {
  const m = city.map;
  const [vx, vy, vw, vh] = (m.view && m.view.length === 4 ? m.view : [0, 0, m.size, m.size]).map(Number);

  const out = [];
  out.push(`<defs><pattern id="quarter-hatch" width="16" height="16" patternUnits="userSpaceOnUse" patternTransform="rotate(45)">`
    + `<rect width="16" height="16" class="map-hatch-bg"/><line x1="0" y1="0" x2="0" y2="16" class="map-hatch"/></pattern></defs>`);
  out.push(`<polygon points="${pts(m.outline)}" class="map-ground"/>`);
  m.districts.forEach((d, i) => {
    out.push(`<polygon points="${pts(d.polygon)}" class="map-cell ${d.quarter ? 'map-cell-quarter' : `map-cell-${i % 4}`}"/>`);
  });
  // Over the districts, whose fills are opaque - the order city.js keeps.
  if (m.river) out.push(`<polyline points="${pts(m.river)}" class="map-river"/>`);
  for (const c of m.canals || []) out.push(`<polyline points="${pts(c)}" class="map-canal"/>`);
  if (m.core) out.push(`<polygon points="${pts(m.core)}" class="map-core"/>`);
  for (const l of m.streets || []) out.push(`<polyline points="${pts(l)}" class="map-street"/>`);
  for (const r of m.roads) out.push(`<polyline points="${pts(r)}" class="map-road"/>`);
  if (m.rail) {
    out.push(`<polyline points="${pts(m.rail)}" class="map-rail"/><polyline points="${pts(m.rail)}" class="map-rail-ties"/>`);
    if (m.station) out.push(`<rect x="${num(m.station[0] - 18)}" y="${num(m.station[1] - 10)}" width="36" height="20" class="map-station"/>`);
  }
  if (m.wall) out.push(`<polygon points="${pts(m.wall)}" class="map-wall"/>`);
  for (const [x, y] of m.gates) out.push(`<rect x="${num(x - 14)}" y="${num(y - 14)}" width="28" height="28" class="map-gate"/>`);
  for (const d of m.districts) {
    if (d.label) out.push(`<text x="${num(d.label[0])}" y="${num(d.label[1])}" class="map-label">${esc(d.name)}</text>`);
  }
  for (const p of city.pins) {
    if (!p.at) continue;
    const [x, y] = p.at;
    out.push(`<g class="map-pin map-pin-${p.kind}">${p.kind === 'shop'
      ? `<rect x="${num(x - 16)}" y="${num(y - 16)}" width="32" height="32" rx="4"/>`
      : `<circle cx="${num(x)}" cy="${num(y)}" r="17"/>`}<text x="${num(x)}" y="${num(y)}">${p.n}</text></g>`);
  }

  // The key.
  const lines = [
    ...city.pins.map((p) => ({ name: `${p.n}. ${p.label}`, text: p.text })),
    ...m.districts.filter((d) => d.text).map((d) => ({ name: d.name, text: d.text })),
  ];
  let width = vw;
  if (lines.length) {
    const fs = Math.max(18, Math.round(vh / 34));
    const lh = Math.round(fs * 1.45);
    const kx = vx + vw + fs * 2;
    const kw = Math.round(vw * 0.8);
    const chars = Math.floor(kw / (fs * 0.55));
    const room = Math.floor((vh - lh * 2) / lh);
    const shown = lines.length > room ? lines.slice(0, room - 1) : lines;
    out.push(`<text x="${kx}" y="${vy + lh}" class="key-title" font-size="${Math.round(fs * 1.3)}">${esc(cut(city.name, chars))}</text>`);
    shown.forEach((l, i) => {
      const name = cut(l.name, chars);
      const rest = l.text ? cut(` — ${l.text}`, Math.max(0, chars - name.length)) : '';
      out.push(`<text x="${kx}" y="${vy + lh * (i + 2.4)}" font-size="${fs}"><tspan class="key-name">${esc(name)}</tspan>`
        + (rest.length > 3 ? `<tspan class="key-text">${esc(rest)}</tspan>` : '') + '</text>');
    });
    if (shown.length < lines.length) {
      out.push(`<text x="${kx}" y="${vy + lh * (shown.length + 2.4)}" font-size="${fs}" class="key-text">…and ${lines.length - shown.length} more</text>`);
    }
    width = vw + fs * 2 + kw;
  }

  return `<?xml version="1.0" encoding="UTF-8"?>\n`
    + `<svg xmlns="http://www.w3.org/2000/svg" viewBox="${vx} ${vy} ${num(width)} ${vh}" width="${num(width)}" height="${vh}" role="img" aria-label="Map of ${esc(city.name)}">`
    + `<style>${STYLE}</style><rect x="${vx}" y="${vy}" width="${num(width)}" height="${vh}" class="bg"/>`
    + out.join('') + '</svg>';
}
