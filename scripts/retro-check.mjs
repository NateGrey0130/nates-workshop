#!/usr/bin/env node
// Does a class SAY it cannot do something it is already doing?
//
//   node scripts/retro-check.mjs            (--remote)
//   node scripts/retro-check.mjs --local
//
// RETRO-AUDIT R8. Every capability the app grew was added because some class
// needed it, and nothing goes back to the classes imported before it existed.
// RETRO-AUDIT measured four detectors for that and only one is worth running on
// a schedule - this one - so this script is deliberately NOT the obvious thing.
//
// WHAT THIS IS NOT: a capability-vs-date diff. "This class was imported before
// `mos` existed and has no `mos`" is 11% precision (RETRO-AUDIT's Method
// section, measured against the one capability with a known ground truth), and
// it cannot be improved, because EVERY capability here has a meaningful unset
// default: no `race_restrictions` means unrestricted, no `xp_table` means the
// house default. A check that fires on correct values trains you to stop
// reading it, which is the argument class-check.mjs already makes about its own
// UNMODELLED list.
//
// WHAT THIS IS: a self-contradiction inside one record. A class that carries a
// key WHILE its own prose says the app has no such key is wrong no matter what
// the capability timeline says, and it is wrong in a way nothing else notices -
// the data is right, so no test fails; only the sentence is false, and it tells
// the next reader not to try. CLASS-AUDIT S4 recorded that exact shape on the
// Godling; RETRO-AUDIT R1 found five more classes doing it.
//
// There is NO FALSE-POSITIVE CLASS here: a record cannot both carry a key and
// truthfully say the key does not exist. Every hit is a defect.
//
// WHAT IT CANNOT SEE, so its silence is not read as coverage: the other half of
// RETRO-AUDIT. A class with no `mos` at all has no key to contradict, so R2's
// demon-goblin and monk were invisible to this - as were R3 and R5. That half
// is a periodic claim sweep against the `claim-capability-verifier` subagent
// and cannot be mechanised.
//
// POSTURE: reports only. NO EXIT CODE, no CI gate - the same posture
// class-check.mjs gives UNMODELLED keys, and for the same reason.
//
// The pair list below is HAND-MAINTAINED, the same honest shape KNOWN_KEYS in
// class-check-lib.mjs takes: a new capability needs a new entry here, and
// nothing will remind you. That ongoing cost is why RETRO-AUDIT R8 is filed as
// `low` rather than higher.

import { d1Query, targetFromArgv } from './d1-query-lib.mjs';

// Each pair is: the KEY as it appears in the frontmatter, and a phrase that
// DENIES that key. `deny` is matched against the markdown with all runs of
// whitespace collapsed to one space, because a stored note wraps mid-phrase -
// `wilderness-scout` reads "(Perception\n    has no bonus key" and a naive
// match reports a false sentence as absent. CLASS-AUDIT S4 hit the same trap on
// the Godling, and this check missed one of its five hits until it normalised.
const PAIRS = [
  { cap: 'occ_related_skills.minimums',
    key: /^\s*minimums:/m,
    deny: /related skills cannot be expressed|cannot express a (?:constraint|minimum)|condition on related skills cannot/i },

  { cap: 'bonuses.saves.other',
    key: /saves:[\s\S]{0,400}?^\s*other:/m,
    deny: /not on the sheet|[Aa]pply it by hand|THE ONLY BONUS THIS CLASS HAS IS NOT STORED/ },

  { cap: 'bonuses.combat.perception',
    key: /combat:[\s\S]{0,900}?perception/m,
    deny: /[Pp]erception has no bonus key|neither spell strength nor perception is a/i },

  { cap: 'skills.mos',
    key: /^\s{2}mos:/m,
    deny: /CANNOT GRANT (?:THEM|SKILLS) CONDITIONALLY|schema cannot express[^.]{0,40}package|MOS skills are not modelled/i },

  { cap: 'categories_allowed[].except',
    key: /categories_allowed:[\s\S]{0,300}?except:/m,
    deny: /category exclusions are prose-only|exclusions[^.]{0,40}not expressible/i },

  { cap: 'magic.spells_from',
    key: /^\s*spells_from:/m,
    deny: /record picks by hand|spells are not yet in the spell catalog/i },

  { cap: 'psionics.powers_from',
    key: /^\s*powers_from:/m,
    deny: /gates by category rather than by name/i },

  { cap: 'psionics.powers_starting_groups',
    key: /^\s*powers_starting_groups:/m,
    deny: /per-category (?:split|starting).{0,40}cannot|one count, one category list/i },

  { cap: 'powers_schedule[].categories',
    key: /powers_schedule:[\s\S]{0,600}?categories:/m,
    deny: /no way to say so per entry|format having no way to say/i },

  { cap: 'skills.level_bonuses (applies_when)',
    key: /applies_when/,
    deny: /so none is stored|conditional[^.]{0,60}so none is/i },
];

// ---- the check proves itself before it reports ----------------------------
//
// A check that has only ever passed has proved nothing, and this one reports
// NOTHING TO REPORT on a healthy catalog - which is indistinguishable from a
// regex that silently stopped matching. So every pair is fired against a
// specimen of the defect it looks for, taken from the record that actually had
// it, before any real class is read. If a pair stops matching its own specimen,
// this says so and the report below is not to be trusted.
//
// The specimens are verbatim pre-fix text from the classes RETRO-AUDIT R1 and
// R6 corrected on 2026-09-04. `wilderness-scout`'s is quoted WITH its line wrap,
// because reproducing that wrap is the point of normalising whitespace.
const SPECIMENS = [
  ['occ_related_skills.minimums',
   '  minimums:\n    - { count: 2, category: "Rogue" }',
   'The two-from-Rogue condition on related skills cannot be expressed in the picker.'],
  ['bonuses.saves.other',
   'bonuses:\n  saves:\n    other:\n      - { label: "vs vacuum", bonus: 2 }',
   'The class bonus is not on the sheet. Apply it by hand.'],
  ['bonuses.combat.perception',
   'bonuses:\n  combat: { initiative: 1, perception: 3 }',
   '+3 on Perception Rolls (Perception\n    has no bonus key, left as prose)'],
  ['skills.mos',
   'skills:\n  mos:\n    choose: 1',
   'THE APP CANNOT GRANT SKILLS CONDITIONALLY ON A CHOICE.'],
  ['categories_allowed[].except',
   'categories_allowed:\n  - { name: "Sensitive", except: ["Astral Projection"] }',
   'The category exclusions are prose-only.'],
  ['powers_schedule[].categories',
   'psionics:\n  powers_schedule:\n    - { level: 5, count: 1, categories: ["Super"] }',
   'the format having no way to say so per entry'],
  ['skills.level_bonuses (applies_when)',
   'level_bonuses: [{"level":1,"applies_when":"with a sword","combat":{"strike":1}}]',
   'All of them are conditional, so none is stored.'],
];

function selfTest() {
  const broken = [];
  for (const [cap, keyText, denyText] of SPECIMENS) {
    const pair = PAIRS.find((p) => p.cap === cap);
    if (!pair) { broken.push(`${cap}: no pair by that name`); continue; }
    const flat = denyText.replace(/\s+/g, ' ');
    if (!pair.key.test(keyText)) broken.push(`${cap}: key regex missed its own specimen`);
    if (!pair.deny.test(flat)) broken.push(`${cap}: deny regex missed its own specimen`);
  }
  // Every pair with no specimen is UNPROVEN, and says so rather than passing
  // quietly - the honest state for a hand-maintained list.
  const unproven = PAIRS.map((p) => p.cap).filter((c) => !SPECIMENS.some((s) => s[0] === c));
  return { broken, unproven };
}

const { broken, unproven } = selfTest();
if (broken.length) {
  console.log('\n*** retro-check SELF-TEST FAILED - do not trust the report below ***');
  for (const b of broken) console.log('    ' + b);
}

const target = targetFromArgv();

const rows = d1Query(
  "SELECT class_id, markdown FROM imported_classes WHERE deleted_at IS NULL AND status = 'published' ORDER BY class_id",
  { target });

// A CORRECTED note quotes the sentence it corrected - that is what a correction
// is for, and `audit-menu` asks for exactly that: write it past-tense and name
// the finding. So the phrase survives in the record and a naive matcher reports
// the fix as the defect, forever.
//
// This is the same hole menu-check.mjs documents about quoted specimens, and it
// is not hypothetical: the first run of this script reported `spacer` and
// `dragon-hatchling-royal-frilled`, both of which had been corrected hours
// earlier by RETRO-AUDIT R1 and R6. Their notes now read "...until RETRO-AUDIT
// R1" and quote the old wording after it.
//
// So a denial sitting near a finding citation is a QUOTATION, not a claim. It
// is still printed - silently dropping it would hide a real hit that happened to
// sit beside a citation - but under its own heading.
const CITATION = /(?:RETRO|CLASS|BOOK-INGEST|INGESTION|UI|REDESIGN|HEALTH|SKILL)-AUDIT\s+[A-Z]?\d+|until RETRO-AUDIT/i;
const NEAR = 260;

function isQuotation(flat, deny) {
  const m = flat.match(deny);
  if (!m) return false;
  const at = m.index ?? 0;
  return CITATION.test(flat.slice(Math.max(0, at - NEAR), at + NEAR));
}

const hits = [];
const quoted = [];
for (const r of rows) {
  const flat = String(r.markdown).replace(/\s+/g, ' ');
  for (const p of PAIRS) {
    if (!p.key.test(r.markdown) || !p.deny.test(flat)) continue;
    (isQuotation(flat, p.deny) ? quoted : hits).push({ id: r.class_id, cap: p.cap });
  }
}

console.log(`\nretro-check (${target.replace('--', '')}) — a class that DENIES a key it carries`);
console.log(`  ${rows.length} published classes, ${PAIRS.length} capability pairs`);
console.log(`  self-test: ${SPECIMENS.length - broken.length}/${SPECIMENS.length} pairs matched their own specimen`
  + (unproven.length ? `, ${unproven.length} unproven (no specimen): ${unproven.join(', ')}` : ''));
console.log('');

if (!hits.length) {
  console.log('  NOTHING TO REPORT.\n');
  console.log('  This does NOT mean no class is missing a mechanic - only that no');
  console.log('  class contradicts itself about one. A class with no key at all has');
  console.log('  nothing to contradict, and that half needs a claim sweep.');
} else {
  for (const h of hits) console.log(`  ${h.id.padEnd(34)} carries ${h.cap} and denies it`);
  console.log(`\n  ${hits.length} record(s) to correct. Each is a note to rewrite, not a`);
  console.log('  mechanic to build: the data is already right. See RETRO-AUDIT R1.');
}

if (quoted.length) {
  console.log(`\n  ---- ${quoted.length} quotation(s), not claims ----`);
  console.log('  The denial sits beside a finding citation, so it is a corrected note');
  console.log('  quoting what it corrected. Read it before dismissing it: this cannot');
  console.log('  tell a quotation from a claim that merely happens to cite something.\n');
  for (const q of quoted) console.log(`  ${q.id.padEnd(34)} ${q.cap}`);
}

// No exit code, deliberately. See the posture note at the top.
console.log('');
