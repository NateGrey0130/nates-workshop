// Extraction prompt for a book's equipment chapter.
//
// The hardest of the four. A skill or spell chapter is a uniform list; an
// equipment chapter mixes weapon tables, armour tables and prose gear
// descriptions on the same page, with entirely different shapes and often no
// consistent heading between them. So the prompt names the kinds explicitly and
// leans hard on omitting fields rather than guessing at them — most items use
// only a handful of the available columns.

export const SYSTEM_PROMPT = `You extract equipment entries from Palladium/Rifts RPG sourcebook pages into structured JSON.

These pages are TWO-COLUMN layouts. Read each column top-to-bottom in full before moving to the next, unless a section is visibly full-width. If an item's description seems to jump topic mid-sentence, you have crossed a column boundary — re-read it.

Output ONLY a JSON array. No prose, no code fences, no commentary.

Rules:
- One object per item. Equipment pages mix several kinds: energy and projectile weapons, ancient weapons, body armour, vehicles, cybernetics, and general gear. Extract all of them.
- Most fields apply to only some kinds. Omit every field an entry does not state. An absent key is correct; an invented value is not.
- Copy values as the book writes them. "2000 feet", "2D6 M.D. single shot, 6D6 M.D. burst" and "20 rounds per clip" are correct answers — do not reduce them to a number.
- is_mega_damage is true when the item's damage is expressed in M.D. or M.D.C., false when it is S.D.C. or plain damage. If an entry states no damage at all, omit it.
- A.R., S.D.C. and M.D.C. are body armour's numbers. Give ar, sdc and mdc as integers, and only when the entry states them.
- sdc is what the OBJECT can take before it breaks, and it is not only armour: a shield, a walkie-talkie or a pair of goggles has one. It is NEVER the damage a weapon deals. "Does 1D6 S.D.C." on a knife is damage and belongs in damage; "30 S.D.C." for a shield is the shield's own and belongs in sdc. If the S.D.C. named is something the item cuts through or destroys, it belongs to that thing and you must omit it.
- cost is a plain integer number of credits or gold, with no separators or currency word.
- A RANGE is common: "Belt, Utility (military style): 3-5 cr." Put the LOW end in cost and the range verbatim in cost_note ("3-5 cr."). The low end is the convention every existing row follows, and cost is what the sheet does arithmetic with. Do not pick an end silently: a stored 75 that came from 15-75 is indistinguishable from a flat 75.
- A qualifier goes in cost_note too - "double for gold", "varies by region". If a cost is only "varies" with no number at all, omit cost and say so in cost_note.
- weight_lbs is in POUNDS and may be fractional. A weight given in ounces converts: "two ounces" is 0.125, "eight ounces" is 0.5. Never round a real weight down to 0 — an item that weighs something must not read as weightless. Omit the field entirely if the book states no weight.
- Do not emit table headers, section headings, or introductory prose as items.
- Skip an entry you cannot read confidently rather than guessing at its numbers.`;

export function buildUserPrompt({ sourceBook, category, hints }) {
  return `Extract every equipment entry on the attached page(s) into a JSON array.

## Object shape

Each element must be:

\`\`\`
{
  "name": "JA-11 Energy Rifle",     // exact item name, no trailing colon
  "category": "weapon",              // weapon | armor | vehicle | cybernetics | gear
  "weight_lbs": 14,                  // pounds, may be fractional (0.125 = two ounces); omit if not stated
  "cost": 32000,                     // integer, no separators; the LOW end of a range
  "cost_note": "20-100 cr.",         // the range or qualifier verbatim; omit if a flat price
  "damage": "3D6 M.D. per blast",   // as written; omit if not stated
  "is_mega_damage": true,            // true for M.D./M.D.C., false for S.D.C.; omit if no damage
  "range": "4000 feet",             // omit if not stated
  "payload": "20 shots per clip",   // omit if not stated
  "rate_of_fire": "Single shot",    // omit if not stated
  "ar": 14,                          // body armour only, integer; omit otherwise
  "mdc": 90,                         // body armour only, integer; omit otherwise
  "description": "..."              // what the item is, in the book's own words, trimmed
}
\`\`\`

Only \`name\` is required. A suit of armour will typically have ar, mdc and weight but no range or payload; a rifle the reverse; a backpack almost nothing but weight, cost and description. That is expected — omit rather than guess.
${category ? `\nThese pages are the ${category} entries. Use that category unless an entry says otherwise.\n` : ''}${sourceBook ? `\nThese pages come from: ${sourceBook}.\n` : ''}${hints ? `\n## Notes from the operator\n\n${hints}\n` : ''}
Return the JSON array and nothing else.`;
}
