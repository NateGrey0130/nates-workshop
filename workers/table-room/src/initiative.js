// The Table — initiative: one order and one current turn per room. THE state
// and THE masking rule, in one place.
//
// Imports nothing, like visibility.js and showing.js. How an order is ROLLED
// is each game's (palladium.js, and marvel.js, which calls the Marvel app's own
// R25 module); the room hands those in as a `rules` object:
//   perMelee   true: a round is a Palladium melee, passes repeated until every
//              combatant's attacks are spent. false: one pass (Marvel).
//   rollOne(entry, random)  -> { roll, total } for one combatant
//   order(rows, random)     -> rows that tied on `total`, in the game's order,
//                              each carrying the `rerolls` and `tags` that placed it
//   rollRound(entries, random) (Marvel only) -> the whole round at once
//
// THE GM DRIVES. Nothing here advances on its own: a turn moves only on
// `next`, a round only on `newRound`.
//
// AN ENTRY is one combatant:
//   id        random, made by the room. It is all a screen uses to name a row,
//             so a hidden NPC's id says nothing about who it is.
//   kind      'pc' (a player's character), 'npc' (one of the campaign's statted
//             NPCs) or 'name' (added by name alone)
//   ref       the character, hero or NPC-sheet id behind a pc or npc; the GM's
//   name, hidden, rolled, roll, total, rerolls, tags
//   bonus, attacks, spent          Palladium: the roll's bonus, attacks per
//                                  melee, and how many are spent this melee
//   agility, talent, applies       Marvel: R25's tie-breakers
// `entries` IS the order: the rolled first, in initiative order, then anyone
// who has not rolled yet.
//
// HIDDEN NPCS. initView() is the only way initiative leaves the room. To
// anyone but the GM a hidden entry is { id, kind: 'npc', name: '???', hidden,
// rolled } and nothing else - no name, no ref, no numbers - so its name never
// reaches a player's phone or the TV, in `state` or in `init`.

export const MAX_ENTRIES = 40;
export const HIDDEN_NAME = '???';

export const emptyInit = () => ({ round: 1, pass: 1, started: false, over: false, turn: null, entries: [] });

const byId = (init, id) => init.entries.find((e) => e.id === id) ?? null;
const indexOf = (init, id) => init.entries.findIndex((e) => e.id === id);
const rolledOf = (init) => init.entries.filter((e) => e.rolled);

export const canAct = (e, rules) => !!e?.rolled && (!rules.perMelee || (Number(e.spent) || 0) < (Number(e.attacks) || 0));

function unroll(e) {
  Object.assign(e, { rolled: false, roll: null, total: null, rerolls: [], tags: [], spent: 0 });
}

// A new combatant, not yet rolled, at the end of the list. `fields` is already
// cleaned by the room. A pc or npc already in the list is not added twice.
export function addEntry(init, fields, id) {
  if (init.entries.length >= MAX_ENTRIES) return { error: `At most ${MAX_ENTRIES} in one initiative order` };
  if (fields.ref != null && init.entries.some((e) => e.kind === fields.kind && e.ref === fields.ref)) {
    return { error: `${fields.name} is already in the order` };
  }
  const e = { id, hidden: false, applies: false, ...fields };
  unroll(e);
  init.entries.push(e);
  return { entry: e };
}

// Put a freshly rolled entry where its roll places it among the rolled. A tie
// is settled by the game's own rule among the tied and the newcomer only, so
// a latecomer never reshuffles the people already placed.
function slot(init, entry, rules, random) {
  init.entries.splice(indexOf(init, entry.id), 1);
  const rolled = rolledOf(init);
  const ties = rolled.filter((e) => e.total === entry.total);
  let at;
  if (ties.length) {
    const sorted = rules.order([...ties, entry], random);
    const mine = sorted.find((r) => r.id === entry.id);
    entry.rerolls = mine.rerolls;
    entry.tags = mine.tags;
    // The people it tied with were placed by the same rule: say so on their
    // rows too, keeping whatever placed them before.
    for (const r of sorted) {
      const e = r.id === entry.id ? null : ties.find((t) => t.id === r.id);
      if (e) e.tags = [...new Set([...(e.tags || []), ...r.tags])];
    }
    const before = sorted.slice(0, sorted.indexOf(mine)).length;
    at = before < ties.length ? indexOf(init, ties[before].id) : indexOf(init, ties[ties.length - 1].id) + 1;
  } else {
    const below = rolled.find((e) => e.total < entry.total);
    at = below ? indexOf(init, below.id) : rolled.length;
  }
  init.entries.splice(at, 0, entry);
}

// One combatant rolls: a player for their own character, the GM for anyone.
export function rollEntry(init, id, rules, random) {
  const e = byId(init, id);
  if (!e) return { error: 'Nobody by that name is in the order' };
  if (e.rolled) return { error: `${e.name} has already rolled` };
  const r = rules.rollOne(e, random);
  Object.assign(e, { rolled: true, roll: r.roll, total: r.total, rerolls: [], tags: [], spent: 0 });
  slot(init, e, rules, random);
  return { entry: e };
}

// Marvel's Roll the round: everyone at once, by R25.
export function rollAll(init, rules, random) {
  if (!init.entries.length) return { error: 'Add someone to the order first' };
  const rows = rules.rollRound(init.entries, random);
  init.entries = rows.map((r) => {
    const e = byId(init, r.key);
    return { ...e, rolled: true, roll: r.roll, total: r.roll, rerolls: r.rerolls, tags: r.tags, spent: 0 };
  });
  Object.assign(init, { started: false, over: false, turn: null, pass: 1 });
  return {};
}

// Where the turn goes from the entry at `from` (-1 to start), without spending
// anything. { index, wrapped } or null when nobody is left to act.
function after(init, from, rules) {
  const n = init.entries.length;
  for (let i = from + 1; i < n; i++) if (canAct(init.entries[i], rules)) return { index: i, wrapped: false };
  if (!rules.perMelee) return null;
  for (let i = 0; i < n; i++) if (canAct(init.entries[i], rules)) return { index: i, wrapped: true };
  return null;
}

// Nobody left: a Palladium melee is over and waits for New melee; a Marvel
// round ends there and then, the way the GM page ends one - the order goes,
// and so does every Talent tick, which applies to one round's circumstances.
function endOfRound(init, rules) {
  init.turn = null;
  if (rules.perMelee) {
    init.over = true;
    return;
  }
  init.round += 1;
  Object.assign(init, { started: false, over: false, pass: 1 });
  for (const e of init.entries) { unroll(e); e.applies = false; }
}

function moveOn(init, from, rules) {
  const next = after(init, from, rules);
  if (!next) return endOfRound(init, rules);
  if (next.wrapped) init.pass += 1;
  init.turn = init.entries[next.index].id;
}

// The GM's Next. The first press starts the round; each after it ends the
// current combatant's action (in Palladium, spending one attack) and lights
// the next one who can act.
export function next(init, rules) {
  if (!init.started) {
    if (!rolledOf(init).length) return { error: 'Nobody has rolled yet' };
    Object.assign(init, { started: true, over: false, pass: 1 });
    moveOn(init, -1, rules);
    return {};
  }
  if (init.over || init.turn == null) return { error: 'The melee is over. Start a new one.' };
  const i = indexOf(init, init.turn);
  const cur = init.entries[i];
  if (rules.perMelee) cur.spent = (Number(cur.spent) || 0) + 1;
  moveOn(init, i, rules);
  return {};
}

// Who acts after the current combatant, for "On deck".
export function onDeck(init, rules) {
  if (!init.started || init.turn == null) return null;
  const copy = structuredClone(init);
  next(copy, rules);
  if (!copy.started || copy.turn == null || copy.round !== init.round) return null;
  return copy.turn;
}

// A new round. Palladium keeps the order unless the GM asks everyone to roll
// again; Marvel always rolls again (Roll the round).
export function newRound(init, rules, { reroll = false } = {}) {
  init.round += 1;
  Object.assign(init, { pass: 1, started: false, over: false, turn: null });
  for (const e of init.entries) {
    e.spent = 0;
    e.applies = false;
    if (reroll || !rules.perMelee) unroll(e);
  }
  return {};
}

// Out of the fight. Removing whoever is up passes the turn on without
// spending anything of theirs.
export function removeEntry(init, id, rules) {
  const i = indexOf(init, id);
  if (i < 0) return { error: 'Nobody by that name is in the order' };
  if (init.turn === id) {
    const nextUp = after(init, i, rules);
    if (!nextUp || init.entries[nextUp.index].id === id) endOfRound(init, rules);
    else {
      if (nextUp.wrapped) init.pass += 1;
      init.turn = init.entries[nextUp.index].id;
    }
  }
  init.entries.splice(indexOf(init, id), 1);
  if (!init.entries.length) Object.assign(init, emptyInit(), { round: init.round });
  return {};
}

// The GM drags a row. Only among the rolled: someone who has not rolled has
// no place in the order yet.
export function moveEntry(init, id, to) {
  const e = byId(init, id);
  if (!e) return { error: 'Nobody by that name is in the order' };
  if (!e.rolled) return { error: `${e.name} has not rolled yet` };
  const last = rolledOf(init).length - 1;
  const t = Math.max(0, Math.min(last, Math.trunc(Number(to))));
  if (!Number.isFinite(t)) return { error: 'Move to where?' };
  init.entries.splice(indexOf(init, id), 1);
  init.entries.splice(t, 0, e);
  return {};
}

// The GM's switches on one row: hidden (an NPC only), and Marvel's
// "Talent applies" tick.
export function setEntry(init, id, { hidden, applies } = {}) {
  const e = byId(init, id);
  if (!e) return { error: 'Nobody by that name is in the order' };
  if (typeof hidden === 'boolean') {
    if (e.kind === 'pc' && hidden) return { error: 'A player\'s character cannot be hidden' };
    e.hidden = hidden;
  }
  if (typeof applies === 'boolean') e.applies = applies;
  return {};
}

// ── What a screen receives ──────────────────────────────────────────────────

const NUMBERS = ['roll', 'total', 'rerolls', 'tags', 'bonus', 'attacks', 'spent', 'agility', 'talent', 'applies'];

export function entryView(e, conn) {
  const gm = conn?.role === 'gm';
  if (e.hidden && !gm) return { id: e.id, kind: 'npc', name: HIDDEN_NAME, hidden: true, rolled: !!e.rolled };
  const out = { id: e.id, kind: e.kind, name: e.name, hidden: !!e.hidden, rolled: !!e.rolled };
  for (const k of NUMBERS) if (e[k] !== undefined) out[k] = e[k];
  // A phone knows its own row by its seat; nobody but the GM learns which
  // NPC sheet stands behind a row.
  if (e.kind === 'pc') out.characterId = e.ref;
  if (gm) out.ref = e.ref ?? null;
  return out;
}

export function initView(init, conn, rules) {
  const i = init ?? emptyInit();
  return {
    round: i.round, pass: i.pass, started: i.started, over: i.over,
    turn: i.turn, onDeck: rules ? onDeck(i, rules) : null,
    entries: i.entries.map((e) => entryView(e, conn)),
  };
}

// The seated character a turn belongs to, for "You're up": a pc's ref, or null.
export const characterOf = (init, id) => {
  const e = id == null ? null : byId(init, id);
  return e?.kind === 'pc' ? String(e.ref) : null;
};
