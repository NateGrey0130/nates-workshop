// A character fights with ONE Hand to Hand style.
//
// A class hands most characters a Hand to Hand skill outright - Basic for a
// scholar, Expert for a soldier - and the books then let the player trade up.
// Dozens of class notes in db/*.sql carry the sentence: "Can be changed to Hand
// to Hand: Expert at the cost of one O.C.C. Related Skill". Changed TO, not
// added to. Until this file existed nothing knew that:
// the Skills step offered Hand to Hand: Commando to a Juicer already granted
// Expert, both rows were saved, and bonusesFromSkills() summed the two
// schedules - strike, parry, dodge and damage from both styles at once. Only
// `attacks_base` was spared, because it takes the larger rather than adding.
// One live character was carrying the pair when this was written.
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
// test all four consumers can run. The smoke suite pins the five level tables
// in db/add-hand-to-hand-level-bonuses.sql against it. WHAT NOTHING PINS: a
// style imported later under some other spelling - "H2H: Ninjitsu" - would
// pass straight through and stack. Name it `Hand to Hand: <style>`.

//
// WHAT THIS DOES NOT DO: charge the book's price. The cost is per class and it
// varies - one related skill for most, "two O.C.C. Related Skills, or Martial
// Arts for the cost of three" for others - and it lives in each class's note
// as prose. The replacement spends the ONE pick it was made with, exactly as
// taking the second style did before. The note is on the Skills step for the
// player to honour; nothing enforces the difference.

const HAND_TO_HAND =/^hand to hand\b/i;

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
 * special case here.
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

/**
 * What to ask before a replacement. `held` is the style being given up and
 * `granted` says whether the class supplied it - the player should know they
 * are trading away something they were given, not something they picked a
 * moment ago.
 */
export function replacePrompt(held, taking, granted) {
  return `This character already has ${held}${granted ? ', granted by the class' : ''}.\n\n`
    + 'A character trains in one Hand to Hand style, so taking '
    + `${taking} REPLACES ${held} rather than adding to it.\n\n`
    + `Replace ${held} with ${taking}?`;
}

globalThis.handToHand = { isHandToHand, oneHandToHand, replacePrompt };
