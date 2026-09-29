// The Table — who may see a roll. THE rule, in one place.
//
// Imported by the room (workers/table-room/src/room.js), which filters every
// live message with it, AND by the Pages routes that read a saved table
// session back out of D1 (functions/api/_lib/table-room.js). One function for
// both, so a roll that was hidden at the table cannot turn up in the campaign
// afterwards because two copies of the rule disagreed.
//
// This file imports nothing on purpose. The Pages build compiles everything a
// function imports with ITS OWN wrangler (SETUP.md, "When the merge does not
// deploy"), so the room's other modules - which import Marvel's JSON tables -
// stay out of that build, and only this one crosses over.
//
// THREE VISIBILITIES
//   all     Everyone: every screen, the TV included.
//   gm      "To GM": a player's private roll. That player and the GM.
//   secret  "GM only": the GM alone.
//
// A CONNECTION is { role: 'gm' | 'player' | 'display', email }. The role is the
// one the join route decided from D1; the page never chooses what it may see.
// A Display is the TV, and it sees public rolls ONLY - even when the laptop on
// the TV is signed in as the GM or as the player who made a private roll,
// because everyone in the room can read the TV.

export const VISIBILITIES = ['all', 'gm', 'secret'];

export function canSee(conn, roll) {
  if (!conn || !roll) return false;
  if (roll.visibility === 'all') return true;
  if (conn.role === 'gm') return true;
  if (roll.visibility === 'gm') {
    return conn.role === 'player' && !!conn.email && conn.email === roll.by?.email;
  }
  // 'secret', and anything that is not one of the three: nobody but the GM.
  return false;
}

// A roll as one screen receives it, live or read back from a saved session.
// The roller's email stays in the room and in the saved record, where canSee
// needs it; a screen learns only whether the roll is its own.
export function rollView(roll, conn) {
  const { by = {}, ...rest } = roll;
  return {
    ...rest,
    by: { name: by.name, role: by.role, characterId: by.characterId ?? null },
    mine: conn.role !== 'display' && !!conn.email && conn.email === by.email,
  };
}

// A saved feed, as one reader may see it: the room's own rule, applied again
// by the Pages route that reads a closed session back out of D1.
export function filterFeed(feed, conn) {
  return (Array.isArray(feed) ? feed : []).filter((r) => canSee(conn, r)).map((r) => rollView(r, conn));
}

// What a role may ASK for. A player's choices are Everyone and To GM; the GM's
// are Everyone and GM only. No value at all is the ordinary public roll; any
// value but 'all' is private - the closest private visibility that role has -
// so a garbled value can only ever hide a roll, never show one.
// A Display cannot roll at all: null.
export function visibilityFor(role, asked) {
  if (role === 'display' || !['gm', 'player'].includes(role)) return null;
  if (asked === 'all' || asked === undefined) return 'all';
  return role === 'gm' ? 'secret' : 'gm';
}
