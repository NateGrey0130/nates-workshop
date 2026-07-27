// Builds the OCC/RCC extraction prompt (import spec section 3).
//
// Deliberately sends the PDF page itself rather than extracted text: layout-
// preserving text extraction splices neighbouring columns together mid-line on
// these two-column sourcebook pages, destroying the column boundary before the
// model ever sees it.

export const SYSTEM_PROMPT = `You extract Palladium/Rifts character class definitions from RPG sourcebook pages into a strict markdown format.

You are reading a scanned or digital page from a tabletop RPG sourcebook. These pages are TWO-COLUMN layouts, and some pages mix column widths, sidebars, and full-width sections on the same page. Read the columns carefully and in the correct reading order: finish the full left column top-to-bottom before starting the right column, unless a section is visibly full-width. Never stitch a line from one column onto a line from the other — if a sentence seems to jump topic mid-line, you have crossed a column boundary; re-read it.

Extract exactly ONE character class. Output ONLY the finished markdown file, with no commentary before or after it and no code fences.

Rules:
- Use ONLY the fields in the target schema. Omit any field that does not apply — never invent or guess a value to fill a slot.
- Keep dice/formula strings verbatim as written in the book (e.g. "P.E. + 1d6 per level", "2d4x10+20", "1d4x100").
- Put readable prose (background, description, roleplaying colour) under "## Lore" and any table-specific or GM-facing advice under "## GM Notes". Do not put prose in the frontmatter.
- If you encounter a mechanic that does not cleanly fit the schema, DO NOT force it into a field and DO NOT silently drop it. Record it in \`extraction_notes\` describing what you saw and where it appeared. This is expected and useful — a class with honest extraction_notes is far more valuable than one with invented structure.`;

export function buildUserPrompt(examples, hints) {
  const exampleBlock = examples
    .map((ex, i) => `### Example ${i + 1} — ${ex.name}\n\n${ex.text}`)
    .join('\n\n---\n\n');

  return `Extract the character class from the attached PDF page(s) into the exact markdown format below.

## Target schema (YAML frontmatter)

Required:
- id: kebab-case slug (e.g. \`juicer\`)
- name: display name (e.g. \`Juicer O.C.C.\` → use \`Juicer\`)
- system: \`rifts\` or \`palladium-fantasy\`
- source_book: kebab-case slug of the book (e.g. \`rifts-core\`)
- category: \`occ\` or \`rcc\`

Optional — include only what the page actually states:
- attribute_requirements: map of attribute → minimum (e.g. \`ME: 12\`)
- attribute_dice: map of attribute → roll string, for RCCs with racial stats
- hit_points_base / sdc_base / mdc_base / ppe_base: formula strings or numbers
- skills:
    occ_skills: list. Each entry is EITHER a fixed skill:
        - { name: "Radio: Basic", base: 40, per_level: 5 }
      OR a choice-group, when the required list itself says "pick N". Two forms:
        - { choose: 2, from: ["Pilot: Hovercycle", "Pilot: Truck"], base: 45, per_level: 5 }
          when the book ENUMERATES the specific options, and
        - { choose: 2, categories: ["Pilot"], base: 45, per_level: 5 }
          when the book says "any N skills from <category>" (e.g. "two piloting
          skills of choice"). Use \`categories\`, never a one-element \`from\` like
          ["Piloting: any"] — \`from\` must list real, individually pickable skills.
      Any entry may also carry a free-text \`note\` for a conditional or alternate
      substitution the book describes (e.g. an alignment-gated swap). Advisory text only.
    occ_related_skills: { count: N, categories: [...] }
      \`categories\` must be PLAIN category names only, drawn from: Communications,
      Domestic, Electrical, Espionage, Mechanical, Medical, Military, Physical,
      Pilot, Pilot Related, Rogue, Science, Technical, Weapon Proficiencies,
      Wilderness, Horsemanship. Do NOT append restrictions or bonuses to the name —
      no "Espionage: intelligence only (+5%)". Omit categories the book excludes,
      and put per-category restrictions and percentage bonuses in a \`note\` field
      on occ_related_skills instead.
      May also carry \`schedule: [{ level: 3, count: 1 }, ...]\` when the book grants
      ADDITIONAL picks at specific later levels.
    secondary_skills: { count: N }
- equipment_starting: list of { item_id: "kebab-case-slug", qty: N }
- psionics: { type: "minor"|"major"|"master", isp_base: "formula" }
- magic: { type: "...", spells_starting: N, spell_levels_allowed: [1, 2] }
- special_abilities / natural_abilities: list of { name, description }
- level_progression: list of { level: N, grants: ["...", "..."] }
- restrictions: list of free-text strings (things the class may not do)
- side_effects: free-text string or list — substantial drawback/cost mechanics
  core to the class (burnout, dependency, crash effects). Descriptive only.
- extraction_notes: free-text string — anything you saw that does not fit above.

## Format examples (match these conventions exactly)

${exampleBlock}

## Output

Return the complete markdown file only, in this exact order:

1. A line containing only \`---\`
2. The YAML frontmatter
3. A line containing only \`---\` — this CLOSING delimiter is mandatory and easy to
   forget; the file is invalid without it
4. \`## Lore\`
5. \`## GM Notes\` if the page supports one

Long free-text values (side_effects, extraction_notes, notes) may use YAML block
scalars (\`key: |\`) or quoted strings — both parse. Keep list values as YAML lists.${hints ? `\n\n## Operator hints\n\n${hints}` : ''}`;
}
