// The City Creator's district map: geometry only, as numbers. city.js turns
// it into SVG.
//
// Phase 2 of the City Creator. A DISTRICT map, not a street map - the plan puts
// a drawn street map out of scope. What it draws: each district as a region,
// race quarters marked, a wall and its gates when the city has walls, main
// roads from the central square to the gates, an optional river, and a pin
// for every place of interest and shop, inside its own district.
//
// PURE AND SEEDED, like the engine: layoutMap(city) always returns the same map
// for the same city, so a saved city redraws exactly, and rerolling a shop
// moves only that shop's pin.
//
// ── How the districts are cut ──
// The city's outline is an irregular polygon. Each district gets a site inside
// it, and its region is the outline clipped by the perpendicular bisector
// against every other site - an exact Voronoi cell, cheap at fourteen
// districts. Every point of the city belongs to exactly one district, which is
// the property the smoke check reads back.
//
// ── Street plans (a theme's mapStyle) ──
// A themed city names one of MAP_STYLES. ORGANIC is the map above, drawn by
// the same code with the same random draws, so a city with no theme is
// unchanged to the byte. The others: GRID squares the outline, sets the
// districts on a grid and draws its streets and straight avenues; RAIL runs a
// railway across the sheet with a station by the square; CANAL always has the
// river and adds canals; VERTICAL marks a towering core round the square. Each
// extra is drawn from its own generator, after the organic draws.

import { rng, hash, MAP_STYLES } from './city-engine.js';

export const SIZE = 1000;              // the map's own units; the SVG scales them
const C = SIZE / 2;

// ── geometry ──

const area = (poly) => Math.abs(poly.reduce((n, [x1, y1], i) => {
  const [x2, y2] = poly[(i + 1) % poly.length];
  return n + (x1 * y2 - x2 * y1);
}, 0)) / 2;

function centroid(poly) {
  let x = 0, y = 0, a = 0;
  for (let i = 0; i < poly.length; i++) {
    const [x1, y1] = poly[i];
    const [x2, y2] = poly[(i + 1) % poly.length];
    const f = x1 * y2 - x2 * y1;
    a += f; x += (x1 + x2) * f; y += (y1 + y2) * f;
  }
  a /= 2;
  return a ? [x / (6 * a), y / (6 * a)] : poly[0];
}

// Ray casting.
export function inside([px, py], poly) {
  let hit = false;
  for (let i = 0, j = poly.length - 1; i < poly.length; j = i++) {
    const [xi, yi] = poly[i];
    const [xj, yj] = poly[j];
    if ((yi > py) !== (yj > py) && px < ((xj - xi) * (py - yi)) / (yj - yi) + xi) hit = !hit;
  }
  return hit;
}

// Keep the side of the bisector of a-b nearer a (Sutherland-Hodgman, one edge).
function clipToward(poly, a, b) {
  const mx = (a[0] + b[0]) / 2, my = (a[1] + b[1]) / 2;
  const nx = b[0] - a[0], ny = b[1] - a[1];
  const side = ([x, y]) => (x - mx) * nx + (y - my) * ny;   // < 0: a's side
  const out = [];
  for (let i = 0; i < poly.length; i++) {
    const p = poly[i];
    const q = poly[(i + 1) % poly.length];
    const sp = side(p), sq = side(q);
    if (sp <= 0) out.push(p);
    if ((sp < 0 && sq > 0) || (sp > 0 && sq < 0)) {
      const t = sp / (sp - sq);
      out.push([p[0] + t * (q[0] - p[0]), p[1] + t * (q[1] - p[1])]);
    }
  }
  return out;
}

// A point inside a polygon: a random spot in a random fan triangle, weighted by
// area, pulled a little toward the middle so a pin does not sit on an edge.
function pointIn(r, poly) {
  const c = centroid(poly);
  const tris = poly.map((p, i) => [c, p, poly[(i + 1) % poly.length]]);
  const weights = tris.map(area);
  let at = r() * weights.reduce((a, b) => a + b, 0);
  let k = 0;
  while (k < tris.length - 1 && at > weights[k]) { at -= weights[k]; k++; }
  const [a, b, d] = tris[k];
  let u = r(), v = r();
  if (u + v > 1) { u = 1 - u; v = 1 - v; }
  const x = a[0] + u * (b[0] - a[0]) + v * (d[0] - a[0]);
  const y = a[1] + u * (b[1] - a[1]) + v * (d[1] - a[1]);
  return [c[0] + (x - c[0]) * 0.8, c[1] + (y - c[1]) * 0.8];
}

const round = ([x, y]) => [Math.round(x * 10) / 10, Math.round(y * 10) / 10];

// The parts of segment a-b inside a polygon, as [p, q] pairs.
function clipLine(poly, a, b) {
  const ts = [0, 1];
  const dx = b[0] - a[0], dy = b[1] - a[1];
  for (let i = 0; i < poly.length; i++) {
    const [x1, y1] = poly[i];
    const [x2, y2] = poly[(i + 1) % poly.length];
    const ex = x2 - x1, ey = y2 - y1;
    const den = dx * ey - dy * ex;
    if (!den) continue;
    const t = ((x1 - a[0]) * ey - (y1 - a[1]) * ex) / den;
    const u = ((x1 - a[0]) * dy - (y1 - a[1]) * dx) / den;
    if (t > 0 && t < 1 && u >= 0 && u <= 1) ts.push(t);
  }
  ts.sort((m, n) => m - n);
  const at = (t) => [a[0] + dx * t, a[1] + dy * t];
  const out = [];
  for (let i = 0; i < ts.length - 1; i++) {
    if (ts[i + 1] - ts[i] < 1e-6) continue;
    if (inside(at((ts[i] + ts[i + 1]) / 2), poly)) out.push([round(at(ts[i])), round(at(ts[i + 1]))]);
  }
  return out;
}

// A river across the sheet: in at one edge, out the other.
function riverLine(r, radius) {
  const t = r() * Math.PI;
  const dx = Math.cos(t), dy = Math.sin(t);
  const off = (r() - 0.5) * radius * 0.6;
  const px = -dy * off, py = dx * off;
  const pts = [];
  for (let k = -3; k <= 3; k++) {
    const s = (k / 3) * SIZE * 0.75;
    pts.push(round([C + px + dx * s + (r() - 0.5) * 40, C + py + dy * s + (r() - 0.5) * 40]));
  }
  return pts;
}

// Grid sites: the nearest cells to the middle, the centre district in the
// middle one and the race quarters in the outermost, as on the organic map.
function gridSites(r, order, quarterCount, radius) {
  const n = order.length;
  const cols = Math.ceil(Math.sqrt(n));
  const rows = Math.ceil(n / cols);
  const span = radius * 1.5;
  const w = span / cols, h = span / rows;
  const cells = [];
  for (let row = 0; row < rows; row++) {
    for (let col = 0; col < cols; col++) {
      cells.push([C - span / 2 + (col + 0.5) * w + (r() - 0.5) * w * 0.16,
        C - span / 2 + (row + 0.5) * h + (r() - 0.5) * h * 0.16]);
    }
  }
  const byMiddle = cells.map((c) => [c, Math.hypot(c[0] - C, c[1] - C)]).sort((a, b) => a[1] - b[1]).map((x) => x[0]).slice(0, n);
  const out = new Array(n);
  out[0] = byMiddle[0];
  for (let i = 1; i <= quarterCount; i++) out[i] = byMiddle[n - i];
  let k = 1;
  for (let i = quarterCount + 1; i < n; i++) out[i] = byMiddle[k++];
  return { sites: out, span, w, h };
}

// ── the map ──

/**
 * The map for a city: { size, outline, districts, wall, gates, roads, river,
 * square, pins }. Every coordinate is in 0..SIZE. Deterministic in the city's
 * seed and its entries' ids.
 */
export function layoutMap(city) {
  const r = rng(hash(city.seed, 'map'));
  const style = MAP_STYLES.includes(city.theme?.pack?.mapStyle) ? city.theme.pack.mapStyle : 'organic';
  const n = Math.max(1, city.districts.length);
  // Bigger cities fill more of the sheet.
  const radius = SIZE * (0.3 + Math.min(0.14, n * 0.012));

  // The outline: a ragged circle.
  const sides = 28;
  const wobble = Array.from({ length: sides }, () => 0.9 + r() * 0.16);
  // A grid city's outline is a rounded square, its edges barely ragged.
  const squared = (v) => Math.sign(v) * Math.abs(v) ** 0.25;
  const outline = wobble.map((w, i) => {
    const t = (i / sides) * Math.PI * 2;
    if (style === 'grid') {
      const g = 0.94 + (w - 0.9) * 0.25;
      return [C + squared(Math.cos(t)) * radius * g, C + squared(Math.sin(t)) * radius * g];
    }
    return [C + Math.cos(t) * radius * w, C + Math.sin(t) * radius * w];
  });

  // Sites: one ring of districts round a centre one, jittered. The centre
  // district is the first plain district after the quarters - quarters sit on
  // the edge, as a quarter usually does.
  const quarters = city.districts.filter((d) => d.race);
  const plain = city.districts.filter((d) => !d.race);
  const order = [...plain.slice(0, 1), ...quarters, ...plain.slice(1)];
  const ring = order.length - 1;
  const spin = r() * Math.PI * 2;
  const grid = style === 'grid' ? gridSites(r, order, quarters.length, radius) : null;
  const sites = grid ? grid.sites : order.map((d, i) => {
    if (i === 0 && order.length > 1) return [C + (r() - 0.5) * 30, C + (r() - 0.5) * 30];
    if (order.length === 1) return [C, C];
    const t = spin + ((i - 1) / ring) * Math.PI * 2 + (r() - 0.5) * 0.3;
    const d0 = radius * (0.55 + r() * 0.2);
    return [C + Math.cos(t) * d0, C + Math.sin(t) * d0];
  });
  const districts = order.map((d, i) => {
    let cell = outline;
    for (let j = 0; j < sites.length; j++) if (j !== i) cell = clipToward(cell, sites[i], sites[j]);
    return { id: d.id, name: d.name, race: d.race || null, polygon: cell.map(round), label: round(centroid(cell)) };
  });

  const square = round(districts[0].label);

  // Walls, gates and the roads that run out through them.
  const walled = !!city.overview?.walls;
  const gateCount = walled ? 2 + Math.floor(r() * 3) : 3;
  const gateAt = Array.from({ length: gateCount }, (_, i) =>
    Math.floor(((i + r() * 0.5) / gateCount) * sides) % sides);
  // A grid city's gates are its four compass points, and its two avenues
  // run straight across it, gate to gate, crossing in the middle.
  const gates = grid ? [0, 7, 14, 21].map((i) => round(outline[i]))
    : [...new Set(gateAt)].map((i) => round(outline[i]));
  const roads = grid ? [[gates[2], gates[0]], [gates[3], gates[1]]] : gates.map((g) => {
    // A road bends once on the way out, so it reads as a road and not a ruler.
    const mid = [(square[0] + g[0]) / 2 + (r() - 0.5) * 60, (square[1] + g[1]) / 2 + (r() - 0.5) * 60];
    return [square, round(mid), g];
  });

  // A river in about half of cities: in at one edge of the sheet, out the other.
  let river = null;
  if (r() < 0.5) river = riverLine(r, radius);

  // A street plan's own additions, from their own generator.
  const extra = {};
  if (style !== 'organic') {
    const rs = rng(hash(city.seed, 'map-style', style));
    extra.style = style;
    if (grid) {
      // Streets every half cell, across the whole city.
      const lines = [];
      const reach = radius * 1.3;
      for (let k = 0; k <= Math.round(grid.span / (grid.w / 2)); k++) {
        const x = C - grid.span / 2 + (k * grid.w) / 2;
        lines.push(...clipLine(outline, [x, C - reach], [x, C + reach]));
      }
      for (let k = 0; k <= Math.round(grid.span / (grid.h / 2)); k++) {
        const y = C - grid.span / 2 + (k * grid.h) / 2;
        lines.push(...clipLine(outline, [C - reach, y], [C + reach, y]));
      }
      extra.streets = lines;
    } else if (style === 'rail') {
      // A railway straight across the sheet, passing near the square, with the
      // station where it comes closest.
      const t = rs() * Math.PI;
      const dx = Math.cos(t), dy = Math.sin(t);
      const off = (rs() - 0.5) * radius * 0.4;
      const through = [square[0] - dy * off, square[1] + dx * off];
      const reach = SIZE * 0.75;
      extra.rail = [round([through[0] - dx * reach, through[1] - dy * reach]), round([through[0] + dx * reach, through[1] + dy * reach])];
      extra.station = round(through);
    } else if (style === 'canal') {
      if (!river) river = riverLine(rs, radius);
      const count = 2 + Math.floor(rs() * 3);
      extra.canals = Array.from({ length: count }, () => {
        const i = Math.floor(rs() * sides);
        const j = (i + Math.floor(sides / 2) + Math.floor((rs() - 0.5) * 8) + sides) % sides;
        const mid = [(outline[i][0] + outline[j][0]) / 2 + (rs() - 0.5) * radius * 0.5,
          (outline[i][1] + outline[j][1]) / 2 + (rs() - 0.5) * radius * 0.5];
        return [round(outline[i]), round(mid), round(outline[j])];
      });
    } else if (style === 'vertical') {
      // The core: a tight ragged ring round the square, where the towers are.
      const coreR = radius * 0.2;
      extra.core = Array.from({ length: 16 }, (_, i) => {
        const t = (i / 16) * Math.PI * 2;
        const w = 0.85 + rs() * 0.3;
        return round([square[0] + Math.cos(t) * coreR * w, square[1] + Math.sin(t) * coreR * w]);
      });
    }
  }

  // Pins: every place and shop in its own district, seeded by its own id, and
  // kept clear of the district's label and of the pins already placed there.
  // The trade: rerolling one shop can nudge a later pin in the SAME district;
  // pins elsewhere never move. Unreadable overlapping numbers were worse.
  const cellOf = Object.fromEntries(districts.map((d) => [d.name, d]));
  const placed = {};
  const pins = [
    ...city.places.map((p) => ({ id: p.id, kind: 'place', label: p.name, district: p.district })),
    ...city.shops.map((s) => ({ id: s.id, kind: 'shop', label: s.name || s.type, district: s.district })),
  ].map((pin, i) => {
    const d = cellOf[pin.district] || districts[i % districts.length];
    const pr = rng(hash(city.seed, 'pin', pin.id, city.rolls?.[pin.id] || 0));
    // The best of a few tries, scored by its worst clearance: from the label
    // (wide, not tall) and from each pin already in this district.
    const others = (placed[d.id] ||= []);
    let at = null, best = -1;
    for (let k = 0; k < 16; k++) {
      const p = pointIn(pr, d.polygon);
      const dx = (p[0] - d.label[0]) / 110, dy = (p[1] - d.label[1]) / 40;
      let score = dx * dx + dy * dy;
      for (const o of others) score = Math.min(score, ((p[0] - o[0]) ** 2 + (p[1] - o[1]) ** 2) / (44 * 44));
      if (score > best) { best = score; at = p; }
      if (score > 1) break;
    }
    others.push(at);
    return { ...pin, district: d.name, districtId: d.id, at: round(at), n: i + 1 };
  });

  // The view is the city and a margin, not the whole sheet: on a phone the
  // empty sheet round a small town left the pins nine pixels wide.
  const xs = outline.map((p) => p[0]), ys = outline.map((p) => p[1]);
  const pad = 36;
  const view = [Math.floor(Math.min(...xs) - pad), Math.floor(Math.min(...ys) - pad),
    Math.ceil(Math.max(...xs) - Math.min(...xs) + 2 * pad), Math.ceil(Math.max(...ys) - Math.min(...ys) + 2 * pad)];

  return { size: SIZE, view, outline: outline.map(round), districts, wall: walled ? outline.map(round) : null,
    gates, roads, river, square, pins, ...extra };
}

export { area };
