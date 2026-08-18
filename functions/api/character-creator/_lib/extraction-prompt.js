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

Omitting fields: when the page explicitly states that something does NOT apply —
"Attribute Requirements: None", "no psionics", "cannot cast spells" — omit that
field entirely. Do not encode the absence as a note, an empty value, or the
string "none". An absent field already means "does not apply"; recording the
absence adds a field a human then has to delete.

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
- starting_money: what the class starts with in gold (Palladium) or credits
    (Rifts), as the book writes it — a formula string like "2d6x10" or a flat
    number. Record ONLY the coin. Saleable goods, gems and artifacts the entry
    also lists belong in equipment_starting, not here.
- variants: use this when the page gives MORE THAN ONE set of statistics for the
    same creature — most often age stages ("hatchling" and "adult"), sometimes
    forms or castes. Without it the second stat block has nowhere to go and gets
    dropped, which loses exactly the numbers the entry exists for.
      variants:
        - id: hatchling            # lower-case slug, unique within the class
          name: "Chiang-Ku Hatchling"
          attribute_dice: { PS: "4d6+12" }
          mdc_base: "1d4x100"
        - id: adult
          name: "Adult Chiang-Ku"
          attribute_dice: { PS: "4d6+30" }
          mdc_base: "1d6x1000"
          bonuses: { combat: { attacks: 2 } }
    Everything the stages SHARE — skills, natural_abilities, special_abilities,
    psionics, magic, equipment, lore — stays at the top level and is written
    once. A variant may override ONLY attribute_dice, attribute_requirements,
    hit_points_base, sdc_base, mdc_base, ppe_base, starting_money and bonuses;
    anything else in
    a variant is ignored.
    attribute_dice and attribute_requirements merge per attribute, so a variant
    naming only P.S. keeps the others from the top level. The rest replace.
    If a stat differs between stages, put it in the variants and NOT at the top
    level. If the page describes only one form, omit variants entirely.
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
    When the book leaves an item OPEN TO CHOICE — "one energy pistol of choice",
    "any two ancient weapons", "pick one of the following" — emit a choice
    instead of a fixed item:
      { choose: 1, from: ["ng-33-laser-pistol", "wilks-320-laser-pistol"], label: "energy pistol", qty: 1 }
    \`from\` must list the actual item slugs the book offers. If the book names
    the specific options, use exactly those. If it names only a general kind and
    no options, still describe the kind in \`label\` and list whatever candidate
    slugs the book mentions elsewhere.
    Do NOT invent a placeholder item to stand for the category — an item_id of
    "energy-pistol" or "ancient-weapon" is wrong, because no real catalog entry
    will ever match it and the character ends up holding a weapon with no stats.
- psionics: { type: "minor"|"major"|"master", isp_base: "formula" }
    If the class AUTOMATICALLY KNOWS specific named psionic powers, list their
    names in \`powers: ["Sixth Sense", "Clairvoyance"]\`. Put them here as well as
    describing them in prose — the app cross-references these names against its
    power catalog, and a power named only inside a special_abilities description
    is invisible to it.
- magic: { type: "...", spells_starting: N, spell_levels_allowed: [1, 2] }
    Likewise, if the class automatically knows specific named spells, list their
    names in \`spells: ["Globe of Daylight", "Sense Magic"]\`. Only list spells the
    book actually names; if the class simply chooses N spells of a given level,
    give spells_starting/spell_levels_allowed and no \`spells\` list.
- special_abilities / natural_abilities: list of { name, description }
- bonuses: the class's MECHANICAL grants, as numbers the app can add up.
    { attributes: { PS: 2 }, combat: { attacks: 1, strike: 2 }, saves: { magic: 2 },
      at_level: [ { level: 5, combat: { attacks: 1 } } ] }
    Use it whenever the book states a flat numeric bonus — "+2 to P.S.",
    "+1 attack per melee", "+3 to save vs magic", "+1 additional attack at
    levels 5, 10 and 15" (which is three at_level entries, one each).
    Use ONLY these keys. A bonus filed under any other name is stored and then
    never read by anything — it silently does nothing, which is worse than
    leaving it as prose.
      attributes: IQ, ME, MA, PS, PP, PE, PB, Spd
      combat:     attacks, initiative, strike, parry, dodge, roll, damage_bonus
                  ("roll" is roll with punch/fall/impact)
      saves:      spell_magic, ritual_magic, psionics, toxins_poisons,
                  harmful_drugs, insanity, possession, horror_factor, pain
      pools:      hp, sdc, mdc, ppe, isp
    A pool bonus is what the class adds ON TOP of a pool's own formula, and it
    is the ONLY bonus group that takes dice as well as a flat number. Use it for
    "P.P.E.: as per the appropriate O.C.C., plus 4D6" — { pools: { ppe: "4d6" } }
    — leaving ppe_base absent so the occupation's own formula still applies.
    Writing that sentence into ppe_base instead produces NO P.P.E. at all.
    Do NOT use it for a pool the class states outright ("P.E. x 10 M.D.C.");
    that is mdc_base. And do not put a pool bonus in at_level — pools are rolled
    once at creation, so per-level growth belongs in the formula itself
    ("P.E. x 5 plus 2D6 per level").
    Any of these may be DICE rather than a flat number when the book prints one
    that way - "+1D4 on initiative" is { combat: { initiative: "1d4" } }. It is
    rolled once when the character is made and kept, never re-rolled.
    A book's flat "+2 to save vs magic" covers both spell_magic and ritual_magic
    — give both. A bonus the list cannot express (pull punch, save vs
    illusionary magic) belongs in prose, not under an invented key.
    Bonuses granted from the start go in \`bonuses\` itself; ones earned later go
    in \`at_level\` with the level they arrive at.
    Do NOT put a bonus here that the book makes conditional ("+2 to strike when
    flying", "+1 to parry with a sword") — those stay as prose in
    special_abilities, because the app would apply them unconditionally.
    Describing the ability in prose as well is correct and expected; this block
    is in addition to that, not instead of it.
- special_abilities: list of { name, description }. If the page says the
    character PICKS some of them ("select THREE powers from the following"),
    add one entry { choose: N, from: ["Name", "Name", ...] } listing the option
    names, alongside the { name, description } entries that describe them.
    If the page points at ANOTHER class for the list ("select any one power from
    those listed under godling"), write { choose: N, from_class: "godling" } and
    do NOT copy the options across — the reference is resolved for you.
    An option the page gives NUMBERS for carries them, using the same bonus
    shape a class uses: { name, description, bonuses: { attributes: {...},
    pools: { mdc: "3d4x10" }, combat: {...}, saves: {...} } }. Use pools for
    "adds N M.D.C./S.D.C./P.P.E./I.S.P.", never a pool base — the ability adds
    to what the class already rolls. An option that says it may be taken twice
    gets repeatable: true, and on_repeat: "<what the second take does>" when the
    page says the second one differs. Leave a power with no numbers as prose.
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
