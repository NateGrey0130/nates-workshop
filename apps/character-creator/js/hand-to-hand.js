// A character fights with ONE Hand to Hand style, bought at its class's price.
//
// A class hands most characters a Hand to Hand skill outright - Basic for a
// scholar, Expert for a soldier - and the books then let the player trade up.
// Dozens of class notes in db/*.sql carry the sentence: "Can be changed to Hand
// to Hand: Expert at the cost of one O.C.C. Related Skill". Changed TO, not
// added to. Until this file existed nothing knew that: the Skills step offered
// Hand to Hand: Commando to a Juicer already granted Expert, both rows were
// saved, and bonusesFromSkills() summed the two schedules - strike, parry,
// dodge and damage from both styles at once. Only `attacks_base` was spared,
// because it takes the larger rather than adding. One live character was
// carrying the pair when this was written.
//
// So the rule is stated once and consumed FOUR ways, the same arrangement
// js/language-skills.js has and for the same reason - they must not disagree:
// the wizard's Skills step, the wizard's Advancement step and the two server
// endpoints that spend a level-up pick all import it as a module, and the
// sheet - a plain-script page - reads the globalThis mirror below.
//
// WHAT COUNTS is decided by name. Every Hand to Hand row in the catalog is
// named `Hand to Hand: <style>`, and a saved character skill carries its name
// and nothing else about the catalog row it came from - so the name is the one
// test all four consumers can run. It is PINNED from the other side: the
// regression suite fails any catalog row that states `attacks_base` - which
// is what makes a row a fighting style - under a name this test does not
// recognise. So a style imported as "H2H: Ninjitsu" fails a required check
// rather than stacking. Name it `Hand to Hand: <style>`.
//
// THE PRICE is the class's, and it is data: `skills.hand_to_hand`.
//
//   hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }
//
// Costs are in related-skill picks and are keyed by styleKey() - the name after
// "Hand to Hand: ", lower-cased - because the frontmatter parser keeps the
// quotes on a quoted KEY. Three readings, and the difference matters:
//
//   no block at all      the class says nothing. Any style, one pick, as ever.
//   a style in `costs`   offered at that price. 0 is a real price - the
//                        Palladin changes to Assassin "at no cost".
//   a style NOT in it    not offered. The book lists what may be bought, and
//                        "Basic ONLY. No upgrade at any price" is `costs: {}`.
//
// A cost of N is the pick that takes the style plus N-1 more that buy nothing
// else, so the rest of the app keeps counting rows: handToHandSurcharge() is
// that N-1, and every allowance check adds it.

const HAND_TO_HAND = /^hand to hand\b/i;

/** Is this skill name a Hand to Hand style? */
export const isHandToHand = (name) => HAND_TO_HAND.test(String(name || '').trim());

// A skill the PLAYER spent a pick on, as against one the class handed over.
// `occ` and `program` rows are grants; a row with no type is treated as one
// too, which is the safe side - it can be replaced and never does the
// replacing.
const isChosen = (row) => row?.type === 'related' || row?.type === 'secondary';

/**
 * Reduce a skill list to one Hand to Hand style.
 *
 * WHICH ONE SURVIVES: a style the player chose beats one the class granted,
 * and otherwise the later row wins. Both halves are the same idea - the most
 * deliberate, most recent decision stands. Every caller appends new skills to
 * the end of the list, so "a pick just made replaces what was held" needs no
 * special case here. It is also what the Navy Seaman's SEAL specialties ask
 * for in so many words - "granted FREE by this specialty, replacing the
 * class's Hand to Hand: Basic" - because an MOS's skills are appended.
 *
 * Deliberately NOT a ranking. Basic < Expert < Martial Arts is true, but
 * Assassin against Commando is an argument, and a player downgrading on
 * purpose is allowed to. The confirm dialog is where that is asked.
 *
 * Returns the list untouched (same array) when there is nothing to do, so a
 * caller can apply it unconditionally and compare by identity.
 */
export function oneHandToHand(rows) {
  const list = Array.isArray(rows) ? rows : [];
  const styles = list.filter((r) => isHandToHand(r?.name));
  if (styles.length < 2) return { skills: list, kept: styles[0] || null, dropped: [] };
  const chosen = styles.filter(isChosen);
  const kept = (chosen.length ? chosen : styles).at(-1);
  return {
    skills: list.filter((r) => r === kept || !isHandToHand(r?.name)),
    kept,
    dropped: styles.filter((r) => r !== kept),
  };
}

/** "Hand to Hand: Martial Arts" -> "martial_arts", the key a class prices it under. */
export const styleKey = (name) => String(name || '').trim()
  .replace(/^hand to hand\s*:?\s*/i, '').trim().toLowerCase().replace(/[^a-z0-9]+/g, '_');

/**
 * What a class charges for a style, in related-skill picks.
 *
 *   undefined  the class has no `hand_to_hand` block - it states no price
 *   null       the class has one and does not offer this style
 *   a number   the price, 0 included
 *
 * `atCreation: false` is the sheet and the level-up endpoints asking: a class
 * whose book allows the change "only when the character is being initially
 * created" offers nothing afterwards.
 */
export function handToHandCost(cls, name, { atCreation = true } = {}) {
  const block = cls?.skills?.hand_to_hand;
  if (!block || typeof block !== 'object') return undefined;
  if (!atCreation && block.creation_only) return null;
  const cost = block.costs?.[styleKey(name)];
  return Number.isFinite(cost) && cost >= 0 ? cost : null;
}

/** The book's condition on a style, as words - "evil alignment" - or ''. */
export const handToHandCondition = (cls, name) =>
  String(cls?.skills?.hand_to_hand?.conditions?.[styleKey(name)] || '');

/**
 * What a list of skills costs BEYOND one pick per row: for each chosen style,
 * its price minus the row it occupies. Negative for a free change, which hands
 * the row's pick back. Zero for a class that states no price, and zero for a
 * style it does not offer - "not offered" is a different finding from
 * "underpaid", and charging for it would report both.
 */
export function handToHandSurcharge(cls, rows, opts) {
  let extra = 0;
  for (const r of rows || []) {
    if (!isChosen(r) || !isHandToHand(r?.name)) continue;
    const cost = handToHandCost(cls, r.name, opts);
    if (typeof cost === 'number') extra += cost - 1;
  }
  return extra;
}

/** "free" / "1 related skill pick" / "3 related skill picks". */
export const costLabel = (cost) => (cost === 0 ? 'free'
  : `${cost} related skill pick${cost === 1 ? '' : 's'}`);

/**
 * What to ask before a replacement. `held` is the style being given up and
 * `granted` says whether the class supplied it - the player should know they
 * are trading away something they were given, not something they picked a
 * moment ago. The price and the book's condition ride along when the class
 * states them: a confirm is the last point at which "three picks" is news.
 */
export function replacePrompt(held, taking, granted, { cost, condition } = {}) {
  const priced = typeof cost === 'number';
  return `This character already has ${held}${granted ? ', granted by the class' : ''}.\n\n`
    + 'A character trains in one Hand to Hand style, so taking '
    + `${taking} REPLACES ${held} rather than adding to it.\n\n`
    + (priced ? `This class's price for ${taking}: ${costLabel(cost)}.\n` : '')
    + (condition ? `The book's condition: ${condition}.\n` : '')
    + (priced || condition ? '\n' : '')
    + `Replace ${held} with ${taking}?`;
}

globalThis.handToHand = { isHandToHand, oneHandToHand, replacePrompt, styleKey,
  handToHandCost, handToHandCondition, handToHandSurcharge, costLabel };
