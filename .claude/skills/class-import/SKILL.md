---
name: class-import
description: Transcribe a Rifts or Palladium Fantasy O.C.C. or R.C.C. from a sourcebook into the character creator as a D1 data script. Use when adding, importing, transcribing, publishing or fixing a class — "add the Crazy O.C.C.", "import this R.C.C. from the scans", "the Dragon's bonuses are wrong". Covers the frontmatter contract, the validator, catalog stubs, and what to do when a class needs a mechanic the app cannot express yet.
---

# Importing a class

A class is a markdown file — YAML frontmatter for mechanics, prose body for
lore — stored as one row in `imported_classes`. Adding one means writing a
one-off SQL data script under `apps/character-creator/db/`.

**Do not read `js/parser.js` to work out the format.** It is 1100 lines and
`reference/frontmatter.md` covers what it accepts. Read the parser only when
modelling something new (see the last section).

## The loop

1. **Read the pages.** Scans have no text layer, so the pages arrive as image
   renders. Transcribe rather than guess: a wrong percentage is worse than a
   missing one, because nothing will ever flag it.
2. **Write the markdown to a scratch `.md` file first**, not straight into SQL.
   Iterating on a bare markdown file avoids re-escaping quotes every pass.
3. **Check it:**
   ```bash
   node scripts/class-check.mjs draft.md
   ```
   Parses through the real parser and cross-references the real catalogs. Free,
   no API call, no writes. Iterate here until it reads `ready`.
4. **Wrap it in a data script** — copy `reference/data-script.sql`, paste the
   stub SQL `class-check` printed, then check the finished script too:
   ```bash
   node scripts/class-check.mjs apps/character-creator/db/add-<id>-class.sql
   ```
   Checking the `.sql` also runs the ASCII/CRLF pre-flight, which the `.md`
   form cannot.
5. **Apply it:**
   ```bash
   node scripts/d1-apply.mjs --local apps/character-creator/db/add-<id>-class.sql
   ```
   Then `--remote` once it looks right locally. Merging to `main` is the deploy;
   the data script is applied by hand, separately, to each environment.
6. **Run the smoke test** before opening a PR: `node apps/character-creator/test/smoke.mjs`

## What class-check tells you

| Section | Meaning |
|---|---|
| `ERRORS` | The parser rejects it. Blocking. |
| `WARNINGS` | Parses, but does something you may not have meant. Read each one. |
| `SQL PRE-FLIGHT` | A CR or a non-ASCII byte. Blocking — both have reached production before. |
| `UNMODELLED` | A top-level key nothing in the app reads. **A decision, not a defect** — see below. |
| `CATALOG` | Missing skills/spells/psionics/gear, plus the stub SQL to add them. |
| `restrictions` | Named skills that match no catalog row. These silently do nothing. |

An unmatched `except` is the dangerous one: `categoryAllows` compares literal
names, so a restriction naming a skill the catalog spells differently excludes
**nothing** and the class quietly offers skills the book forbids.

## Rules that are easy to get wrong

- **Related and secondary skills come from the O.C.C., not the R.C.C.** An
  R.C.C. granting zero of each is correct, not missing data. A character takes
  an R.C.C. *and* an O.C.C.; the racial class supplies the body, the occupation
  supplies the skill allowances.
- **`base` is the catalog base plus the class's printed bonus**, already added.
  The book prints "Lore: Magic (+15%)" and the catalog holds Lore: Magic at 25%,
  so the class file says `base: 40`. The app does not add the two at runtime.
- **`base` fixes a percentage, `bonus` adds to whatever the pick's own base is.**
  A choice-group spanning a category almost always wants `bonus` — its members
  start at different percentages, so one number cannot express "+30%".
- **Money is coin only.** `starting_money` is credits (Rifts) or gold
  (Palladium). Starting gear goes in `equipment_starting`.
- **Every gear item needs a catalog row.** Missing ones get a stub carrying the
  exact marker `STUB — created by class import, needs stats`, which is how the
  gear importer later recognises it as unfilled. `class-check` generates these.
- **The file must be pure ASCII with LF endings.** An em-dash is spliced in as
  `' || char(8212) || '`. Both rules exist because both failure modes reached
  production (PRs #93 and #101).
- **Conditional bonuses are prose.** `bonuses:` is applied unconditionally, so
  "+2 to strike when flying" belongs in `special_abilities` or `side_effects`,
  never in the block the sheet adds up.

## When a class needs the app to change

This is expected and is not a failure of the import. Several classes have
needed it — the Godling's Magic Powers demanding an occupation, staged R.C.C.s
needing `variants`, variable PPE costs needing a cost schedule.

`class-check` reports it as `UNMODELLED`: a top-level key that parses fine and
that nothing then reads. **Never leave one unresolved.** Silent storage is how
a class ships looking complete and doing nothing.

Two legitimate answers, and it is the user's call which:

- **Ship now, model later.** Move it into the body as prose so it is at least
  visible on the class detail, and note it in `extraction_notes`. Right when the
  mechanic is rare or cosmetic.
- **Model it.** A real change, and it touches a predictable set of places:

  | File | What goes in it |
  |---|---|
  | `js/parser.js` | Validate the new block; add it to `VARIANT_OVERRIDES` if a variant may override it |
  | `scripts/class-check-lib.mjs` | Add the key to `KNOWN_KEYS` — otherwise it keeps reporting as unmodelled |
  | `functions/api/.../validate-character.js` | Enforce it server-side, if a character can violate it |
  | `js/compose.js` | Fold it in, if an R.C.C.+O.C.C. pair has to combine it |
  | `app.js` / `sheet.js` | Show it in the wizard and on the sheet |
  | `test/smoke.mjs` | A case for the new shape |
  | `apps/character-creator/README.md` | What it means and why it exists |

  Prefer extending an existing block over adding a top-level key — `bonuses`
  already covers attributes, combat, saves, pools and `at_level`, and a new
  bonus group there costs one entry rather than a new code path.

## Reference

- `reference/frontmatter.md` — every block, its shape, and what reads it
- `reference/data-script.sql` — the data-script skeleton to copy
