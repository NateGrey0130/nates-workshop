// "Language: Other" is the book's escape hatch: one catalog row standing in
// for every language the skill list never prints. A character takes it once
// PER LANGUAGE — Language: English, Language: Spanish, Language: Orc — each a
// separate skill named for what it is, all advancing on the Other row's
// numbers (50% +5/lvl). Storing the language in the name is what the
// denormalized character skill rows were built for; no catalog row per
// language is needed or wanted.
//
// The rule lives in one place and is consumed three ways: the wizard imports
// it as a module, the server's pick validator imports it the same way, and
// the sheet — a plain-script page — reads the globalThis mirror below, which
// its <script type="module"> tag has installed before any render runs.

export const LANGUAGE_OTHER = 'Language: Other';

// A name in the "Language: X" family, the Other row itself included. The
// resolution rule everywhere is: exact catalog hit first, and only a MISS in
// this family falls back to the Other row's numbers.
export const isLanguageName = (n) => /^language:\s*\S/i.test(String(n || ''));

// What the player typed -> the stored skill name, tolerant of them typing the
// "Language:" prefix themselves. Null for a blank.
export function languageSkillName(raw) {
  const t = String(raw || '').trim().replace(/^language:\s*/i, '').trim();
  return t ? `Language: ${t}` : null;
}

globalThis.langSkills = { LANGUAGE_OTHER, isLanguageName, languageSkillName };
