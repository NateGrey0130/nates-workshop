// Three of the wizard's rules, out of app.js so they can be RUN without a DOM:
// the race's dice bonuses, the starting pools and money, and the skills a
// character holds at level one.
//
// Moved as they stood, with the same names. Each takes the wizard's state as
// its first argument rather than reaching for the one S, and the helpers that
// still live in app.js (the catalog index, the Hand to Hand rule, the
// composed class, the advancement roll) arrive as functions in the second.
// app.js keeps a wrapper of the old name and signature that hands over S and
// those helpers, so no caller in the wizard changed. A helper is passed as a
// function, and called where the body always called it, so nothing is
// evaluated earlier, later or more often than it was.
import { rollStartingPools, rollStartingMoney, withIqBonus, newPickPercent } from './leveling.js';
import { skillBase } from './skill-base.js';
import { isFamilyName, otherRowFor } from './language-skills.js';
import { isChoiceGroup, skillGroupForPick } from './parser.js';

// The race's dice bonuses.
//
// deps: rollDiceBonusesOf(cls) -> { attributes, combat, saves };
//       rollOccBonuses(), rollTotemBonuses() - the other two halves, re-rolled
//       with this one only when forced.
export function rollAttrBonuses(s, force, { rollDiceBonusesOf, rollOccBonuses, rollTotemBonuses }) {
  // Idempotent unless forced. computePools() is called lazily whenever a later
  // step needs pools, and without this guard simply walking to Details silently
  // re-rolled a bonus the player had already read off the Attributes step.
  if (!force && s.attrBonuses && Object.keys(s.attrBonuses).length) return;

  // The RACE half only. s.cls carries the occupation's dice as well once one is
  // chosen, and rolling from it here would count those twice — once into
  // s.attrBonuses and again into s.occAttrBonuses.
  const r = rollDiceBonusesOf(s.raceCls || s.cls);
  s.attrBonuses = r.attributes;
  s.rolledBonuses = { combat: r.combat, saves: r.saves };
  // Review's Reroll button re-rolls the whole character, occupation included.
  if (force) { rollOccBonuses(); rollTotemBonuses(); }
}

// ---------- pools ----------
// `force` distinguishes the lazy first computation from the Reroll button.
// Only the button re-rolls what has already been rolled.
//
// deps: psiClass() - the composed class; rollAttrBonuses(force);
//       rollAdvancement(force).
export function computePools(s, force, { psiClass, rollAttrBonuses, rollAdvancement }) {
  const c = s.cls;
  // I.S.P. may come from a tier the character rolled rather than from the
  // class, so the pool is read off the composed object.
  const pc = psiClass();
  // The class's pool bonuses and a mega-damage conversion (BOOK-INGEST-AUDIT
  // F62) ride along inside rollStartingPools, the one roll the NPC generator
  // makes too.
  s.pools = rollStartingPools(c, s.attrs, pc.psionics);
  // Step 5 is "Equipment AND Money" (p.22) — every class starts with a sum of
  // coin as well as its kit. Rolled below by rollStartingMoney, so the Reroll
  // button on Review covers it, and stored in bio because it is a running
  // number the player edits rather than anything the rules derive.
  rollAttrBonuses(force);
  // Review's Reroll button re-rolls the whole character, and a character that
  // starts above level 1 includes the levels it climbed to get there.
  if (force) rollAdvancement(true);

  // Not over a sum the player typed. This runs whenever the pools were cleared
  // - an attribute, a variant, an occupation or a totem changing - and it used
  // to replace a hand-entered figure every time, which is the opposite of the
  // paragraph above. Review's Reroll (`force`) is the player asking for dice.
  if (force) s.moneyTyped = false;
  if (!s.moneyTyped) {
    const money = rollStartingMoney(c, s.attrs);
    if (money == null) delete s.bio.money; else s.bio.money = money;
  }
}

// The character's skills as they stand at level 1 — the class's own, the
// choice-group picks, and the related and secondary skills chosen on the
// Skills step. Split out from skillsPayload because the Advancement step needs
// exactly this: the input a level-up proposal is computed against.
//
// deps: skillByName() -> Map of name to catalog row;
//       replaced - Map of the lower-cased Hand to Hand styles NOT on the
//         character (app.js handToHandReplaced());
//       iq - the I.Q. skill bonus, as read at level one (app.js says why);
//       psiClass() - the composed class; resolveSkill(name, explicit);
//       programSkills() - the rows the chosen skill programs grant;
//       pairedWith(list) - the note a paired skill carries.
export function skillsAtLevelOne(s, { skillByName, replaced, iq, psiClass, resolveSkill, programSkills, pairedWith }) {
  const find = (n) => skillByName().get(n)
    || (isFamilyName(n) ? { ...(skillByName().get(otherRowFor(n)) || {}), name: n } : {});
  const occ = s.cls.skills?.occ_skills || [];

  // pct stays the true current percentage, because level-up increments it and
  // the sheet prints it. iq_bonus records how much of it came from I.Q. so the
  // number can explain itself rather than being unexplained arithmetic.
  const withIq = (row) => withIqBonus(row, iq);

  // Read off the COMPOSED class, the same source renderSkills() builds its
  // picker from. A rolled major psionic halves the related allowance without
  // touching the category list, so the two agree either way — but they are one
  // question ("what may this character take, and at what percentage") and
  // reading it from two places is how the picker and the saved sheet drift.
  const relatedCats = () => psiClass().skills?.occ_related_skills?.categories || [];

  // Choice-group picks are stored exactly like fixed class skills, inheriting
  // the group's base/per_level - and the picked option's OWN bonus where the
  // list states one for it (BOOK-INGEST-AUDIT.md F135).
  const groupPicks = occ.flatMap((sk, gi) => !isChoiceGroup(sk) ? [] :
    (s.groupPicks[gi] || []).map((name) => {
      const r = resolveSkill(name, skillGroupForPick(sk, name));
      return { name, category: 'Class', pct: r.base, per_level: r.per_level, type: 'occ' };
    }));
  return [
    ...occ.filter((sk) => !isChoiceGroup(sk)).map((sk) => {
      const r = resolveSkill(sk.name, sk);
      const row = { name: sk.name, category: 'Class', pct: r.base, per_level: r.per_level, type: 'occ' };
      // The pairing travels with the character, or the sheet loses it: a
      // Gunfighter's three Sharpshooting specialties appeared NOWHERE on a
      // finished sheet before this. Carried as `note`, which the sheet already
      // renders as a sub-row, so no new render path is needed. One row, not
      // three - three rows of the same name are refused with HTTP 422 by
      // validate-character.js `duplicate_skill`. BOOK-INGEST-AUDIT.md F49.
      if (Array.isArray(sk.with) && sk.with.length) row.note = pairedWith(sk.with);
      return row;
    }),
    ...groupPicks,
    // The class's own per-category bonus — "Technical: Any (+10%)" — added to
    // the catalog base. Only to a skill that HAS a base: a W.P. or a hand to
    // hand sits at 0 because it is not percentile, and adding ten to it would
    // invent a roll that does not exist. Same guard resolveSkill() uses for a
    // choice group's `bonus`, for the same reason.
    ...s.related.map((n) => {
      const row = find(n);
      // newPickPercent is that rule (js/leveling.js): the level-up pick and the
      // NPC generator ask it too.
      return { name: n, category: row.category, pct: newPickPercent({ ...row, name: n }, s.attrs, relatedCats()),
               per_level: row.per_level || 0, type: 'related' };
    }),
    // Secondary skills get no O.C.C. bonus, but they are not frozen: "all
    // skills increase as the character grows in experience". Storing 0 here
    // stopped them advancing forever, so a level 10 character's hobby skills
    // sat at their level 1 values.
    ...s.secondary.map((n) => ({ name: n, category: find(n).category, pct: skillBase(find(n), s.attrs) || 0, per_level: find(n).per_level || 0, type: 'secondary' })),
    // Skill programs (F23(b)). The percentage is the PROGRAM's, not the
    // catalog's: printed 170 says "Base skill: 38%; no bonuses or improvement
    // with experience", so the row's own base and per-level are both discarded
    // rather than added to. That is what makes this a program and not a bonus.
    //
    // NO `skillBase` AND NO `categoryBonus`. A formula-derived base would
    // reintroduce the attribute the flat rate exists to ignore, and a category
    // bonus is refused at parse time for this block for the same reason.
    ...programSkills().map((row) => ({
      name: row.name,
      category: row.category,
      pct: +psiClass().skills.skill_programs.base || 0,
      per_level: +psiClass().skills.skill_programs.per_level || 0,
      type: 'program',
    })),
    // One Hand to Hand style (js/hand-to-hand.js). A replaced one is still on
    // the class's list, or still ticked in a choice group, and is not on the
    // character - so this is where it stops, which is every consumer at once:
    // the Review step, the level-up proposal, the draft and the save.
  ].filter((row) => !replaced.has(String(row.name).toLowerCase())).map(withIq);
}
