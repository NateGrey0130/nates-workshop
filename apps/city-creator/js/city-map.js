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

import { rng, hash } from './city-engine.js';

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

// ── the map ──

/**
 * The map for a city: { size, outline, districts, wall, gates, roads, river,
 * square, pins }. Every coordinate is in 0..SIZE. Deterministic in the city's
 * seed and its entries' ids.
 */
export function layoutMap(city) {
  const r = rng(hash(city.seed, 'map'));
  const n = Math.max(1, city.districts.length);
  // Bigger cities fill more of the sheet.
  const radius = SIZE * (0.3 + Math.min(0.14, n * 0.012));

  // The outline: a ragged circle.
  const sides = 28;
  const wobble = Array.from({ length: sides }, () => 0.9 + r() * 0.16);
  const outline = wobble.map((w, i) => {
    const t = (i / sides) * Math.PI * 2;
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
  const sites = order.map((d, i) => {
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
  const gates = [...new Set(gateAt)].map((i) => round(outline[i]));
  const roads = gates.map((g) => {
    // A road bends once on the way out, so it reads as a road and not a ruler.
    const mid = [(square[0] + g[0]) / 2 + (r() - 0.5) * 60, (square[1] + g[1]) / 2 + (r() - 0.5) * 60];
    return [square, round(mid), g];
  });

  // A river in about half of cities: in at one edge of the sheet, out the other.
  let river = null;
  if (r() < 0.5) {
    const t = r() * Math.PI;
    const dx = Math.cos(t), dy = Math.sin(t);
    const off = (r() - 0.5) * radius * 0.6;
    const px = -dy * off, py = dx * off;
    const pts = [];
    for (let k = -3; k <= 3; k++) {
      const s = (k / 3) * SIZE * 0.75;
      pts.push(round([C + px + dx * s + (r() - 0.5) * 40, C + py + dy * s + (r() - 0.5) * 40]));
    }
    river = pts;
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
    gates, roads, river, square, pins };
}

export { area };
