// Marvel Heroes' saved heroes: the checks every write goes through, kept free
// of any request or database so apps/marvel-heroes/test/smoke.mjs can run them.
//
// A hero arrives as { id?, name, build, snapshot, sheet }. `build` and
// `snapshot` are produced by the app, so they are only checked for shape and
// size; `sheet` is what a person types, so it is cut down to the known fields.

export const MAX_HEROES = 200;          // per owner
export const MAX_JSON = 48 * 1024;      // bytes, per JSON column
const NAME_MAX = 80;
export const ID = /^[a-z0-9-]{8,64}$/;

// The written fields of the Judge's Book character sheet, and how long each
// may be. A key not listed here is dropped rather than refused, so an older
// or newer page can still save.
export const SHEET_FIELDS = {
  identity: 120, player: 80, group: 120, base: 120, occupation: 120,
  birthplace: 120, legal_status: 80, marital_status: 80, age: 20, height: 20,
  weight: 20, second_form: 200, background: 4000, notes: 4000,
};
// Numbers the sheet tracks in play. Each is a whole number or absent.
export const SHEET_NUMBERS = ['health', 'karma', 'karma_pool', 'advancement'];
const NUMBER_MAX = 1000000;

function sanitizeSheet(input) {
  const out = {};
  if (!input || typeof input !== 'object' || Array.isArray(input)) return out;
  for (const [k, max] of Object.entries(SHEET_FIELDS)) {
    if (typeof input[k] === 'string' && input[k].trim()) out[k] = input[k].slice(0, max);
  }
  for (const k of SHEET_NUMBERS) {
    const n = input[k];
    if (Number.isInteger(n) && Math.abs(n) <= NUMBER_MAX) out[k] = n;
  }
  return out;
}

const plainObject = (x) => !!x && typeof x === 'object' && !Array.isArray(x);
const bytes = (s) => new TextEncoder().encode(s).length;

// -> { hero } or { error }. The id is optional: a new hero gets one from the
// endpoint, never from the page.
export function sanitizeHero(body) {
  if (!plainObject(body)) return { error: 'A hero is a JSON object' };
  const name = typeof body.name === 'string' ? body.name.trim().slice(0, NAME_MAX) : '';
  if (!name) return { error: 'A hero needs a name' };
  if (body.id !== undefined && body.id !== null && !(typeof body.id === 'string' && ID.test(body.id))) {
    return { error: 'Not a hero id' };
  }
  // Two kinds of build: the generator's seeds and picks, or a Point Buy tab's
  // purchases (`mode: 'pointbuy'`, R24). Each is rebuilt from its own known
  // keys, so nothing else rides along - and a Point Buy build keeps its mode,
  // which is what sends it back to the right tab when it is opened.
  const b = body.build;
  const pointBuy = plainObject(b) && b.mode === 'pointbuy';
  if (pointBuy ? !plainObject(b.pb) : !plainObject(b) || !plainObject(b.seeds)) {
    return { error: 'A hero needs the generator state it was built from' };
  }
  if (!plainObject(body.snapshot) || !plainObject(body.snapshot.abilities)) return { error: 'A hero needs a snapshot of what was built' };
  const build = JSON.stringify(pointBuy ? { mode: 'pointbuy', pb: b.pb }
    : { seeds: b.seeds, picks: plainObject(b.picks) ? b.picks : {} });
  const snapshot = JSON.stringify(body.snapshot);
  // No sheet at all means "leave the saved one alone": the generator saves a
  // hero's build without knowing what was written on its sheet.
  const sheet = body.sheet === undefined ? null : JSON.stringify(sanitizeSheet(body.sheet));
  for (const [k, v] of [['build', build], ['snapshot', snapshot], ['sheet', sheet ?? '']]) {
    if (bytes(v) > MAX_JSON) return { error: `The hero's ${k} is too large` };
  }
  return { hero: { id: body.id || null, name, build, snapshot, sheet } };
}

// A stored row, back into what the page works with.
export function rowToHero(row) {
  const parse = (s, dflt) => { try { return JSON.parse(s); } catch { return dflt; } };
  return {
    id: row.id, name: row.name,
    build: parse(row.build, {}), snapshot: parse(row.snapshot, {}), sheet: parse(row.sheet, {}),
    created_at: row.created_at, updated_at: row.updated_at,
  };
}
