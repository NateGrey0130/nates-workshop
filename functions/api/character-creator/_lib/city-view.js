// What the PLAYERS may see of a City Creator city - BUILT, NOT FILTERED.
//
// Assembled field by field from the parts a player may see: the map's shapes
// and district names, the pins the G.M. revealed with the text the G.M. wrote
// FOR THE PLAYERS, and the districts' players' lines. Nothing else is read out
// of the city, so nothing else can reach a player. A new field added to the
// city later is invisible here until someone adds it on purpose.
//
// Two readers: cities/[id]/view.js, for a city whose map the G.M. has shown,
// and the table's city map (city-svg.js), for a city the G.M. has put on the
// table. Both draw from this and nothing else.

const pt = (p) => (Array.isArray(p) && p.length === 2 ? [Number(p[0]), Number(p[1])] : null);
const pts = (list) => (Array.isArray(list) ? list.map(pt).filter(Boolean) : []);

export function playerView(row, city) {
  const m = city.map || {};
  const reveal = city.reveal || {};
  const pub = city.public || {};
  const text = (id) => (typeof pub[id] === 'string' && pub[id].trim() ? pub[id].trim() : null);
  return {
    id: row.id,
    campaign_id: row.campaign_id,
    name: String(city.overview?.name || row.name),
    map: {
      view: Array.isArray(m.view) ? m.view.map(Number) : null,
      size: Number(m.size) || 1000,
      outline: pts(m.outline),
      wall: m.wall ? pts(m.wall) : null,
      gates: m.wall ? pts(m.gates) : [],
      roads: Array.isArray(m.roads) ? m.roads.map(pts) : [],
      river: m.river ? pts(m.river) : null,
      // A theme's street plan: shapes only. The theme's words never come here.
      canals: Array.isArray(m.canals) ? m.canals.map(pts) : null,
      streets: Array.isArray(m.streets) ? m.streets.map(pts) : null,
      rail: m.rail ? pts(m.rail) : null,
      station: m.rail ? pt(m.station) : null,
      core: m.core ? pts(m.core) : null,
      districts: (Array.isArray(m.districts) ? m.districts : []).map((d) => ({
        id: String(d.id), name: String(d.name || ''), quarter: !!d.race,
        polygon: pts(d.polygon), label: pt(d.label), text: text(d.id),
      })),
    },
    // Revealed pins only, renumbered 1..n so the count of hidden ones does
    // not show through gaps in the numbering.
    pins: (Array.isArray(m.pins) ? m.pins : []).filter((p) => reveal[p.id] === true).map((p, i) => ({
      id: String(p.id), n: i + 1, kind: p.kind === 'shop' ? 'shop' : 'place',
      label: String(p.label || ''), district: String(p.district || ''), at: pt(p.at), text: text(p.id),
    })),
  };
}
