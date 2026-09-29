// The Table — who may look at the picture on the table. THE rule, in one place.
//
// Imported by the room (workers/table-room/src/room.js), which decides who is
// sent a `show`, AND by the Pages routes (functions/api/_lib/table-room.js),
// which read a picture ref off a request with imageRef(). The room answers the
// image route's one question - may this person fetch this picture right now? -
// with mayFetch() below, so the socket that is told about a picture and the
// route that serves its bytes cannot disagree about who that is.
//
// Like visibility.js, this file imports nothing, so it can cross into the
// Pages build.
//
// SHOW IS NOT REVEAL. A shown picture is the table's for the moment and leaves
// no trace: nothing here writes D1, and Clear ends it. Reveal - the switch that
// puts a picture in the players' Handouts for good - is present.js's
// toggleReveal and the campaign image route's own rule, untouched by this.
//
// A REF names one picture: { kind, id }.
//   image   a picture on a setting page (campaign_images / msh_campaign_images)
//   city    a City Creator city's map, as the players' view draws it (Palladium)
// Which kinds a game has is the game adapter's business; an id it does not
// know is simply not found.

export const KINDS = ['image', 'city'];

const ROW_ID = /^[1-9]\d{0,11}$/;

// A ref from anywhere - a request's query, a GM's show - or null.
export function imageRef(kind, id) {
  const k = String(kind ?? '');
  const i = String(id ?? '');
  if (!KINDS.includes(k) || !ROW_ID.test(i)) return null;
  return { kind: k, id: i };
}

export const sameImage = (a, b) => !!a && !!b && a.kind === b.kind && String(a.id) === String(b.id);

// Which connections are shown the picture. The GM and the TV always; a player
// once they have taken a seat, because "at a table that player is seated at"
// is the design's own line - a phone still choosing a character is not at the
// table yet.
export function mayView(conn) {
  if (!conn) return false;
  if (conn.role === 'gm' || conn.role === 'display') return true;
  return conn.role === 'player' && !!conn.seat;
}

// May `email` fetch `ref` now? Only while it IS the picture on the table, and
// only for someone connected here who may view it. Before Show, after Clear,
// after the table closes, for another picture, or for anyone not at this table,
// the answer is no - and the route turns no into "not found".
export function mayFetch(conns, shown, email, ref) {
  if (!email || !sameImage(shown, ref)) return false;
  return (conns || []).some((c) => c && c.email === email && mayView(c));
}
