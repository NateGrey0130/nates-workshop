// The Marvel app's own Universal Table and rank ladder, loaded once for the
// room's FEAT rolls. Its own module so dice.js stays pure and takes the table
// as an argument. Wrangler bundles the JSON; Node reads it through the import
// attribute, which is how workers/table-room/test/room.mjs loads the real room.

import ranks from '../../../apps/marvel-heroes/data/ranks.json' with { type: 'json' };
import universal from '../../../apps/marvel-heroes/data/universal.json' with { type: 'json' };
import talents from '../../../apps/marvel-heroes/data/talents.json' with { type: 'json' };
import { makeFeat } from '../../../apps/marvel-heroes/js/feat.js';
import { rollInitiative, orderRolled, initiativeTalents } from '../../../apps/marvel-heroes/js/initiative.js';

export const feat = makeFeat(ranks, universal);

// ── Initiative: house rule R25, the Marvel app's own module ─────────────────
//
// d100 each, highest first; a tie is broken by an initiative Talent that
// applies this round, then the Agility number, then a re-roll among the tied
// (apps/marvel-heroes/js/initiative.js has the rule and its reasons). The room
// calls that module, never a copy of it, so the table and the GM page cannot
// order one round two ways. A room entry is mapped to the module's combatant
// { key, name, agility, talent, applies } and back by `key`.

const INIT_TALENTS = new Set(initiativeTalents(talents));

// Whether a hero or NPC has one of the two Talents the rule reads, from the
// Talent ids its sheet holds.
export const hasInitTalent = (ids) => (Array.isArray(ids) ? ids : []).some((t) => INIT_TALENTS.has(String(t)));

const combatant = (e) => ({ key: e.id, name: e.name, agility: Number(e.agility) || 0, talent: !!e.talent, applies: !!e.applies });

// A whole round: every entry rolls d100 and the order comes back, each row
// carrying its roll, re-rolls and the tags that placed it.
export function rollRound(entries, random) {
  return rollInitiative(entries.map(combatant), random);
}

// Rows that already hold their `roll`, in R25 order (for slotting a latecomer).
export function orderMarvel(rows, random) {
  return orderRolled(rows.map((r) => ({ ...combatant(r), roll: r.roll, id: r.id })), random)
    .map((r) => ({ ...rows.find((x) => x.id === r.key), rerolls: r.rerolls, tags: r.tags }));
}
