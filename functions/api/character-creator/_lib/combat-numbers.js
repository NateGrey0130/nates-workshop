// A character's initiative bonus and attacks per melee, derived on the server
// exactly as the sheet derives them, for The Table's initiative (phase 3).
//
// The table page is not the sheet and holds none of its numbers, and a phone's
// message is not believed: so when a player joins, the join route asks this for
// each of their characters and hands the room the answer (the room's
// `initStats`). The same numbers for the GM's roster of statted NPCs.
//
// THE SAME PIPELINE AS GET characters/:id and sheet.js, not a second one:
//   the class composed with the skills' bonuses folded in (composeClass, the
//   bonus rows loadSkillBonuses reads, the totem), then
//   derive.classBonuses(cls, level, { attributes, combat, saves }) and
//   derive.combat(attributes, the typed overrides, those bonuses)
// - sheet.js builds `combat` with those two calls on those arguments, and
// workers/table-room/test/room.mjs holds the sheet to them. A number a human
// typed over the derived one on the sheet is in `characters.combat` and wins
// here as it wins there.
//
// Not modelled: a Nightbane's second form. The sheet shows its numbers while
// the form is up; this reads the first form's, which is the one the character
// has when the table has not been told otherwise.

import { getStored } from './class-store.js';
import { loadTotem } from './class-loader.js';
import { loadSkillBonuses } from './skill-bonuses.js';
import { decodeCharacter } from './character-json.js';
import { parseClassMarkdown } from '../../../../apps/character-creator/js/parser.js';
import { composeClass } from '../../../../apps/character-creator/js/compose.js';
// A classic script: importing it installs `globalThis.derive`.
import '../../../../apps/character-creator/js/derive.js';

const whole = (v, dflt) => {
  const n = Math.trunc(Number(v));
  return Number.isFinite(n) ? n : dflt;
};

// `rows` are characters rows (SELECT *). -> Map(id -> { bonus, attacks }).
// Classes are fetched once per class id, however many characters share one.
export async function initiativeNumbers(env, rows) {
  const derive = globalThis.derive;
  const parsed = new Map();
  const classOf = async (id) => {
    if (!id) return null;
    if (!parsed.has(id)) {
      const stored = await getStored(env, id);
      const p = stored ? parseClassMarkdown(stored.markdown) : null;
      parsed.set(id, p?.ok ? p.data : null);
    }
    return parsed.get(id);
  };
  const out = new Map();
  for (const raw of rows) {
    const c = decodeCharacter({ ...raw });
    let cls = null;
    try {
      cls = composeClass({
        rcc: await classOf(c.class_id),
        occ: await classOf(c.occ_class_id),
        character: c,
        totem: await loadTotem(env, c.totem),
        skillRows: await loadSkillBonuses(env, c),
      });
    } catch { cls = null; }
    const bonuses = derive.classBonuses(cls || {}, c.level, {
      attributes: c.attribute_bonuses || {},
      combat: c.rolled_bonuses?.combat || {},
      saves: c.rolled_bonuses?.saves || {},
    });
    const combat = derive.combat(c.attributes || {}, c.combat, bonuses);
    out.set(String(c.id), { bonus: whole(combat.initiative, 0), attacks: whole(combat.attacks, 2) });
  }
  return out;
}
