// "Language: Other" is the book's escape hatch: one catalog row standing in
// for every language the skill list never prints. A character takes it once
// PER LANGUAGE — Language: English, Language: Spanish, Language: Orc — each a
// separate skill named for what it is, all advancing on the Other row's
// numbers (50% +5/lvl). Storing the language in the name is what the
// denormalized character skill rows were built for; no catalog row per
// language is needed or wanted.
//
// "Literacy: Other" is the SAME row for reading rather than speaking, and for a
// long time nothing treated it that way. It was the only member of its family
// with no rule: a Wizard "literate in two languages of choice" picked twice
// from a list of four generic rows, and taking the Other one gave the character
// a skill named, literally, "Literacy: Other" — a placeholder where a language
// belongs. Two published classes still grant that as a FIXED skill.
//
// So the rule is stated per FAMILY rather than per row.
//
// The rule lives in one place and is consumed FIVE ways, all of which must
// agree: the wizard's related/secondary picker, the wizard's choice-group
// control, the server's pick validator and the level-up pick resolver all
// import it as a module, and the sheet — a plain-script page — reads the
// globalThis mirror below, which its <script type="module"> tag has installed
// before any render runs.

export const LANGUAGE_OTHER = 'Language: Other';
export const LITERACY_OTHER = 'Literacy: Other';

// Every family whose "Other" row stands in for the whole family. The prefix is
// what a member's name starts with; `other` is the catalog row its numbers and
// its category come from.
const FAMILIES = [
  { prefix: 'Language', other: LANGUAGE_OTHER },
  { prefix: 'Literacy', other: LITERACY_OTHER },
];

const familyRe = (prefix) => new RegExp(`^${prefix}:\\s*\\S`, 'i');

/** The family a stored skill name belongs to, or null. Internal: callers want
 *  `isFamilyName` or `otherRowFor`, which is the whole surface anyone needs. */
function familyOf(name) {
  const n = String(name || '');
  return FAMILIES.find((f) => familyRe(f.prefix).test(n)) || null;
}

/** Is this name in one of the families — the Other row itself included? */
export const isFamilyName = (name) => familyOf(name) !== null;

/**
 * Is this the repeatable ROW itself — the one that prompts rather than toggles?
 *
 * A member like "Language: Elven" is NOT repeatable: it is one specific skill
 * and a character holds it once.
 */
export const isRepeatableRow = (name) =>
  FAMILIES.some((f) => f.other.toLowerCase() === String(name || '').trim().toLowerCase());

/** The catalog row a family member takes its numbers from, or null. */
export const otherRowFor = (name) => familyOf(name)?.other ?? null;

/** Every repeatable row, for a caller that has to load them all up front. */
export const REPEATABLE_ROWS = FAMILIES.map((f) => f.other);

/**
 * What the player typed -> the stored skill name, for the family `otherRow`
 * belongs to. Tolerant of them typing the prefix themselves. Null for a blank.
 */
export function familySkillName(otherRow, raw) {
  const fam = FAMILIES.find((f) => f.other.toLowerCase() === String(otherRow || '').trim().toLowerCase())
    ?? FAMILIES[0];
  // Strip the prefix only — `familyRe` ends in `\S`, so reusing it here would
  // eat the first letter of the language and turn "language: orc" into "rc".
  const t = String(raw || '').trim()
    .replace(new RegExp(`^${fam.prefix}:\\s*`, 'i'), '').trim();
  return t ? `${fam.prefix}: ${t}` : null;
}

/** What to ask, so the prompt says "language" or "written language" correctly. */
export const promptFor = (otherRow) =>
  (String(otherRow || '').toLowerCase() === LITERACY_OTHER.toLowerCase()
    ? 'Which written language? (saved as "Literacy: <name>")'
    : 'Which language? (saved as "Language: <name>")');

// `isLanguageName` and `languageSkillName` stood here and are gone. They were
// the whole API while Language was the only family, and generalising left every
// one of their six call sites using the family versions instead - so what
// remained was two exports nothing imported, which is the shape the smoke
// test's dead-export check exists to catch. `isFamilyName(n)` and
// `familySkillName(LANGUAGE_OTHER, raw)` are what they did.

globalThis.langSkills = {
  LANGUAGE_OTHER, LITERACY_OTHER, REPEATABLE_ROWS,
  isFamilyName, isRepeatableRow, otherRowFor, familySkillName, promptFor,
};
