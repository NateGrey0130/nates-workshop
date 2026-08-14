// Extraction prompt for a book's spell chapter.
//
// Like the skill chapter, this pulls MANY rows from one page range, so the
// output is JSON. Spell entries are longer than skill entries — each carries a
// stat block plus prose — so a page range that works for skills may be too big
// here. The engine rejects a truncated reply rather than staging half a page.

export const SYSTEM_PROMPT = `You extract spell definitions from Palladium/Rifts RPG sourcebook pages into structured JSON.

These pages are TWO-COLUMN layouts. Read each column top-to-bottom in full before moving to the next, unless a section is visibly full-width. If a spell's description seems to jump topic mid-sentence, you have crossed a column boundary — re-read it.

Output ONLY a JSON array. No prose, no code fences, no commentary.

Rules:
- One object per spell. A spell is normally a bold name, sometimes followed by its level, then a short stat block (Range, Duration, Damage, Saving Throw, P.P.E.) and a description.
- Copy stat block values as the book writes them. "100 feet per level of experience" and "2D6 melee rounds" are correct answers — do not reduce them to a number.
- Never invent a value. Omit a field the entry does not state rather than guessing.
- P.P.E. and spell level are the two numeric fields. If a spell's P.P.E. varies, put the base number in ppe and the full wording in description.
- Do not emit level headings ("Level Three Spells"), chapter headings, or introductory prose as spells.
- Skip a spell you cannot read confidently rather than guessing at its numbers.`;

export function buildUserPrompt({ sourceBook, level, hints }) {
  return `Extract every spell defined on the attached page(s) into a JSON array.

## Object shape

Each element must be:

\`\`\`
{
  "name": "Fire Bolt",                  // exact spell name, no trailing colon or level
  "level": 4,                            // spell level as an integer; 0 if not stated
  "ppe": 7,                              // P.P.E. cost as an integer; 0 if not stated
  "range": "100 feet per level",         // omit if not stated
  "duration": "Instant",                 // omit if not stated
  "damage": "5D6",                       // omit if not stated
  "saving_throw": "Dodge, 16 or better", // omit if not stated
  "area_of_effect": "One target",        // omit if not stated
  "casting_time": "One melee action",    // omit if not stated
  "description": "..."                   // the spell's effect, in the book's own words, trimmed
}
\`\`\`

Only \`name\` is required. Omit any other key the entry does not state — an absent key is correct, an invented value is not.
${level ? `\nThese pages are the level ${level} spells. Use that level unless an entry says otherwise.\n` : ''}${sourceBook ? `\nThese pages come from: ${sourceBook}.\n` : ''}${hints ? `\n## Notes from the operator\n\n${hints}\n` : ''}
Return the JSON array and nothing else.`;
}
