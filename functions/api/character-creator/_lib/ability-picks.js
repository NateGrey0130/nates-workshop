// What a class ability picked AFTER creation does to the stored character.
// BOOK-INGEST-AUDIT F116.
//
// An ability chosen in the wizard is folded by `applyAbilities` every time the
// class is composed, which is enough for its flat bonuses, its psionics and its
// text. Two kinds of bonus are NOT read at render, because they are rolled once
// and stored:
//
//   a DICE bonus to an attribute, a combat number or a save
//       counts only what `attribute_bonuses` / `rolled_bonuses` hold for that
//       key (js/derive.js, classBonuses). The wizard rolls those at creation.
//   a POOL bonus, flat or dice
//       is rolled into `*_max` by the wizard and never looked at again.
//
// A Sohei's fifth-level Body Hardening Exercise is "+4D4x10 S.D.C." or "+1D6
// P.S.". Picked from a banked grant, with nothing but the name appended, it
// would add nothing. So the spend path rolls what the definition states and
// writes it where the wizard would have - found by F116's premise audit, which
// counted six of the Sohei's seven exercises carrying one.
//
// NOT HANDLED, and the sheet's own rule for a G.M.-assigned power says the same
// ("recorded, not re-rolled"): an ability that converts hit points and S.D.C.
// to M.D.C. (`mdc_from_hp_sdc`), one that restates `attribute_dice`, and the
// I.S.P. base of a `psionics` block the ability brings. A pool the character
// does not have is left alone - a bonus does not conjure one.

import { evalDiceBonus } from '../../../../apps/character-creator/js/dice.js';
import { isAbilityDefinition } from '../../../../apps/character-creator/js/parser.js';

const POOLS = ['hp', 'sdc', 'mdc', 'ppe', 'isp'];
const norm = (s) => String(s ?? '').trim().toLowerCase();

// The dice members of a bonus value: a string, or the strings in a list.
const diceOf = (v) => [v].flat().filter((x) => typeof x === 'string' && x.trim());
const flatOf = (v) => [v].flat().filter((x) => typeof x === 'number' && Number.isFinite(x))
  .reduce((a, b) => a + b, 0);

// `roll(dice)` is passed in so a test can pin it; the endpoint passes evalDiceBonus.
//
// Returns the three stored things as they should be AFTER the picks, plus what
// was rolled, for the response and the history:
//   attribute_bonuses  the flat attribute map the wizard stores
//   rolled_bonuses     { combat, saves }
//   pools              { hp_max, hp_current, ... } - only the ones that moved
//   rolled             [{ ability, what, dice, value }]
export function abilityPickEffects(cls, names, character, roll = evalDiceBonus) {
  const defs = new Map((cls?.special_abilities || []).filter(isAbilityDefinition)
    .map((d) => [norm(d.name), d]));
  const attribute_bonuses = { ...(character?.attribute_bonuses || {}) };
  const rolled_bonuses = {
    combat: { ...(character?.rolled_bonuses?.combat || {}) },
    saves: { ...(character?.rolled_bonuses?.saves || {}) },
  };
  const pools = {};
  const rolled = [];
  let touchedAttrs = false;
  let touchedRolled = false;

  for (const name of names) {
    const def = defs.get(norm(name));
    const b = def?.bonuses;
    if (!b || typeof b !== 'object') continue;

    for (const [attr, v] of Object.entries(b.attributes || {})) {
      for (const dice of diceOf(v)) {
        const value = roll(dice);
        if (!Number.isFinite(value)) continue;
        attribute_bonuses[attr] = (Number(attribute_bonuses[attr]) || 0) + value;
        touchedAttrs = true;
        rolled.push({ ability: def.name, what: attr, dice, value });
      }
    }
    for (const group of ['combat', 'saves']) {
      for (const [k, v] of Object.entries(b[group] || {})) {
        if (group === 'saves' && k === 'other') continue;
        for (const dice of diceOf(v)) {
          const value = roll(dice);
          if (!Number.isFinite(value)) continue;
          rolled_bonuses[group][k] = (Number(rolled_bonuses[group][k]) || 0) + value;
          touchedRolled = true;
          rolled.push({ ability: def.name, what: `${group}.${k}`, dice, value });
        }
      }
    }
    for (const pool of POOLS) {
      const v = b.pools?.[pool];
      if (v === undefined || v === null) continue;
      const maxKey = `${pool}_max`;
      const curKey = `${pool}_current`;
      const max = pools[maxKey] ?? character?.[maxKey];
      if (max === null || max === undefined) continue;
      let add = flatOf(v);
      for (const dice of diceOf(v)) {
        const value = roll(dice);
        if (!Number.isFinite(value)) continue;
        add += value;
        rolled.push({ ability: def.name, what: pool, dice, value });
      }
      if (!add) continue;
      pools[maxKey] = Number(max) + add;
      const cur = pools[curKey] ?? character?.[curKey];
      if (cur !== null && cur !== undefined) pools[curKey] = Math.max(0, Number(cur) + add);
      if (!diceOf(v).length) rolled.push({ ability: def.name, what: pool, dice: null, value: add });
    }
  }
  return {
    attribute_bonuses: touchedAttrs ? attribute_bonuses : null,
    rolled_bonuses: touchedRolled ? rolled_bonuses : null,
    pools,
    rolled,
  };
}
