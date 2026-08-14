// Extraction prompt for a book's skill chapter.
//
// Unlike the class importer, this pulls MANY rows from one page range, so the
// output is JSON rather than markdown. Skill chapters are dense two-column
// lists — the same column-splicing hazard applies, which is why the PDF goes to
// the model as a document rather than as extracted text.

export const SYSTEM_PROMPT = `You extract skill definitions from Palladium/Rifts RPG sourcebook pages into structured JSON.

These pages are TWO-COLUMN layouts. Read each column top-to-bottom in full before moving to the next, unless a section is visibly full-width. If a skill's description seems to jump topic mid-sentence, you have crossed a column boundary — re-read it.

Output ONLY a JSON array. No prose, no code fences, no commentary.

Rules:
- One object per skill. Skills are usually introduced by a bold name followed by a description and a "Base Skill" percentage.
- Never invent a percentage. If a skill has no stated base percentage, use 0 — many skills legitimately have none (Weapon Proficiencies, Hand to Hand, most physical training skills).
- Do not emit category headings, chapter headings, or introductory prose as skills.
- Skip a skill you cannot read confidently rather than guessing at its numbers.`;

export function buildUserPrompt({ category, sourceBook, systems, hints }) {
  return `Extract every skill defined on the attached page(s) into a JSON array.

## Object shape

Each element must be:

\`\`\`
{
  "name": "Climbing",          // exact skill name, no trailing colon or percentage
  "category": "Physical",      // the chapter/section heading it appears under
  "base": 40,                  // starting percentage as an integer; 0 if none stated
  "per_level": 5,              // percentage gained per level; 0 if none stated
  "note": "40%/30% climb/rappel"   // OPTIONAL — see below
}
\`\`\`

## Percentages

Palladium states these as "Base Skill: 40% +5% per level of experience". Put 40
in \`base\` and 5 in \`per_level\`.

Some skills state TWO percentages for different uses, e.g. Climbing at
"40%/30%" for climb versus rappel. Put the FIRST number in \`base\` and record
the full text in \`note\`. Do the same for any other qualifier that does not fit
the numeric fields — "counts as two skill selections", "+10% if taken as an
O.C.C. skill", penalties, or prerequisites.

## Categories

Use the section heading the skill appears under, normalised to one of:
Communications, Domestic, Electrical, Espionage, Mechanical, Medical, Military,
Physical, Pilot, Pilot Related, Rogue, Science, Technical, Weapon Proficiencies,
Wilderness, Horsemanship.
${category ? `\nThe operator says these pages are all: ${category}. Use that unless a page clearly says otherwise.` : ''}
${systems ? `\nThese skills are for: ${systems}.` : ''}
${sourceBook ? `\nSource book: ${sourceBook}.` : ''}

## Output

The JSON array only. If the pages contain no skill definitions, return \`[]\`.${hints ? `\n\n## Operator hints\n\n${hints}` : ''}`;
}
