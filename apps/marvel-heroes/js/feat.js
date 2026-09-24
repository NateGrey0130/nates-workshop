// FEAT rolls on the Universal Table. Pure: give it the ladder and the table
// (data/ranks.json, data/universal.json) and it answers; nothing here reads
// the page or the network.

const ORDER = ['white', 'green', 'yellow', 'red'];

export function makeFeat(ranks, universal) {
  const ladder = ranks.ranks;
  const index = Object.fromEntries(ladder.map((r, i) => [r.id, i]));
  const column = Object.fromEntries(universal.columns.map((c) => [c.rank, c.colours]));
  const actions = Object.fromEntries(universal.actions.map((a) => [a.id, a]));

  // The rank a rank NUMBER falls in. Above Class 5000 is still Class 5000:
  // Beyond has no number, and is only ever named.
  function rankForNumber(n) {
    if (!Number.isFinite(n) || n < 0) return null;
    for (const r of ladder) {
      if (r.min === null) continue;
      if (n >= r.min && (r.max === null || n <= r.max)) return r.id;
    }
    return null;
  }

  // A column shift moves along the ladder and stops at either end.
  function shift(rankId, cs) {
    const i = index[rankId];
    if (i === undefined) throw new Error(`unknown rank ${rankId}`);
    return ladder[Math.max(0, Math.min(ladder.length - 1, i + cs))].id;
  }

  // The colour a d100 roll gives on a rank's column.
  function colour(rankId, roll) {
    const col = column[rankId];
    if (!col) throw new Error(`no Universal Table column for ${rankId}`);
    const row = universal.rows.findIndex(([lo, hi]) => roll >= lo && roll <= hi);
    if (row < 0) throw new Error(`roll ${roll} is not on the table`);
    return col[row];
  }

  // A whole FEAT: rank, shift, roll -> the column used, the colour, whether it
  // met the colour needed, and what that colour means for a kind of FEAT.
  function roll({ rank, cs = 0, d100, need = 'green', action = null }) {
    const used = shift(rank, cs);
    const got = colour(used, d100);
    return {
      rank, cs, column: used, d100, colour: got, need,
      success: ORDER.indexOf(got) >= ORDER.indexOf(need),
      result: action ? actions[action]?.results[got] ?? null : null,
    };
  }

  // A Slam, Stun or Kill result is not the end of it: the TARGET then makes an
  // Endurance FEAT on that result's own column of the Effects Table (PB back
  // cover), which universal.json carries as the actions slam, stun and kill.
  // Answers that column, or null for any other result.
  const FOLLOW = { Slam: 'slam', Stun: 'stun', Kill: 'kill' };
  function followUp(result) {
    return FOLLOW[result] ? actions[FOLLOW[result]] ?? null : null;
  }

  return { ladder, actions: universal.actions, rankForNumber, shift, colour, roll, followUp, ORDER };
}
