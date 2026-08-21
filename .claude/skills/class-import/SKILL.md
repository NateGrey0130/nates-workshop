---
name: class-import
description: Transcribe a Rifts or Palladium Fantasy O.C.C. or R.C.C. from a sourcebook into the character creator as a D1 data script, and fill the catalog gaps it turns up. Use when adding, importing, transcribing, publishing or fixing a class — "add the Crazy O.C.C.", "import this R.C.C. from the scans", "the Dragon's bonuses are wrong", "these skills are missing" — and when importing skills, spells or gear from a book. Covers the frontmatter contract, the validator, catalog conventions, and what to do when a class needs a mechanic the app cannot express yet.
---

# Importing a class

A class is a markdown file — YAML frontmatter for mechanics, prose body for
lore — stored as one row in `imported_classes`. Adding one means writing a
one-off SQL data script under `apps/character-creator/db/`.

**Do not read `js/parser.js` to work out the format.** It is 1100+ lines and
`reference/frontmatter.md` covers what it accepts. Read the parser only when
modelling something new (see the last section).

## The loop

1. **Read the pages.** Scans have no text layer, so pages arrive as image
   renders. Transcribe rather than guess: a wrong percentage is worse than a
   missing one, because nothing will ever flag it.
2. **Write the markdown to a scratch `.md` file first**, not straight into SQL.
   Iterating on bare markdown avoids re-escaping quotes every pass.
3. **Check it:**
   ```bash
   node scripts/class-check.mjs draft.md
   ```
   Parses through the real parser and cross-references the real catalogs. Free,
   no API call, no writes. Iterate here until it reads `ready`.
4. **Wrap it in a data script** — copy `reference/data-script.sql`, paste the
   stub SQL `class-check` printed, and set the filename in the closing
   `data_script_runs` line. Then check the finished script too:
   ```bash
   node scripts/class-check.mjs apps/character-creator/db/add-<id>-class.sql
   ```
   Checking the `.sql` also runs the ASCII/CRLF pre-flight, which the `.md`
   form cannot.
5. **Apply it:**
   ```bash
   node scripts/d1-apply.mjs --local apps/character-creator/db/add-<id>-class.sql
   ```
   Then `--remote` once it looks right locally. **Ask before `--remote`** — it
   writes to the live database. Merging to `main` is the deploy; data scripts
   are applied by hand, separately, to each environment.
6. **Run the smoke test** before opening a PR:
   `node apps/character-creator/test/smoke.mjs`

## What class-check tells you

| Section | Meaning |
|---|---|
| `ERRORS` | The parser rejects it. Blocking. |
| `WARNINGS` | Parses, but does something you may not have meant. Read each one. |
| `SQL PRE-FLIGHT` | A CR or a non-ASCII byte. Blocking — both reached production before. |
| `UNMODELLED` | A top-level key nothing in the app reads. A decision, not a defect — see below. |
| `CATALOG` | Missing skills/spells/psionics/gear, plus stub SQL to add them. |
| `restrictions` | Restriction names matching no catalog row. They do nothing. |
| `unreachable` | An `only` naming a skill whose real category the class does not grant. **The class grants a skill nobody can take.** |
| `cross-category` | An `only` naming a skill the catalog files elsewhere, where the class *does* grant that category. Works — shown so it reads as deliberate. |
| `no-op except` | An `except` naming a skill from another category. Excludes nothing. |

Only `ERRORS` and `SQL PRE-FLIGHT` set the exit code. The rest are findings
about the books, not a file the parser rejects.

**A restriction naming a row the catalog does not have is not always a bug.**
The Priest of Light names `W.P. Siege`, `W.P. Large Axes` and `W.P. Lance`
ahead of those rows existing, and says so in its note; the exclusions activate
by themselves when the rows arrive. The audit floor is three names, not zero.

## Rules that are easy to get wrong

- **Related and secondary skills come from the O.C.C., not the R.C.C.** An
  R.C.C. granting zero of each is correct, not missing data.
- **`base` is the catalog base plus the class's printed bonus**, already added.
  The book prints "Lore: Magic (+15%)" and the catalog holds it at 25%, so the
  class file says `base: 40`. The app does not add the two at runtime.
- **`base` fixes a percentage, `bonus` adds to each pick's own base.** A
  choice-group spanning a category almost always wants `bonus`.
- **Pilot skills store without a `Pilot:` or `Military:` prefix.** The catalog
  row is `Jet Fighters`, not `Military: Jet Fighters`. Naming the prefixed form
  cost three classes a restriction that silently did nothing.
- **Money is coin only.** `starting_money` is credits or gold; starting gear
  goes in `equipment_starting`.
- **Every gear item needs a catalog row.** Missing ones get a stub carrying the
  exact marker `STUB — created by class import, needs stats`, which is how the
  gear importer later recognises it as unfilled. `class-check` generates these.
- **Pure ASCII, LF endings** — in the WHOLE file, comments included, not just
  the executable SQL. An em-dash in a value is spliced as `' || char(8212) || '`;
  one in a comment has to go too, because wrangler on Windows has turned a
  commented non-ASCII character into mojibake in production. The smoke test
  checks both separately: `every data script is pure ASCII` covers the file,
  `no .sql has non-ASCII in executable SQL` covers the values. Both rules exist
  because both failure modes reached production (#93, #101).
- **Conditional bonuses are prose.** `bonuses:` is applied unconditionally, so
  "+2 to strike when flying" belongs in `special_abilities` or `side_effects`.
- **D1 caps compound SELECT terms below six.** A readback that `UNION`s six
  names fails and rolls the whole file back. Count with `IN` instead.

## Correcting a class that already shipped

**Do not edit the original `add-*-class.sql`.** Those are one-shot scripts,
already applied. Add a new `fix-*.sql` alongside, guarded on the text it
replaces so re-running is a no-op, with readback `SELECT`s that assert the
result. Fifteen `fix-*.sql` / `apply-*.sql` scripts follow this shape.

The class markdown lives in D1, so a fix script edits it with `replace()`:

```sql
UPDATE imported_classes SET markdown = replace(markdown, '"Old Name"', '"New Name"')
  WHERE class_id = 'x' AND instr(markdown, '"Old Name"') > 0;
```

A consequence worth knowing: running `class-check` against the original `.sql`
afterwards still reports the pre-fix state. **The `.sql` reports the state it
creates; the database is the current truth.**

## When a class needs the app to change

Expected, not a failure of the import. The Godling's Magic Powers demanding an
occupation, staged R.C.C.s needing `variants`, variable P.P.E. costs, and
skills granting attribute bonuses all started this way.

`class-check` reports it as `UNMODELLED`: a top-level key that parses fine and
that nothing then reads. **Never leave one unresolved.** Silent storage is how
a class ships looking complete and doing nothing.

Two legitimate answers, and it is the user's call which:

- **Ship now, model later.** Move it into the body as prose so it is at least
  visible on the class detail, and note it in `extraction_notes`.
- **Model it.** A real change, touching a predictable set of places:

  | File | What goes in it |
  |---|---|
  | `js/parser.js` | Validate the new block; add it to `VARIANT_OVERRIDES` if a variant may override it |
  | `scripts/class-check-lib.mjs` | Add the key to `KNOWN_KEYS`, or it keeps reporting as unmodelled |
  | `functions/api/.../validate-character.js` | Enforce it server-side, if a character can violate it |
  | `js/compose.js` | Fold it in, if an R.C.C.+O.C.C. pair has to combine it |
  | `js/derive.js` | Turn it into a number, if the sheet adds it up |
  | `app.js` / `sheet.js` | Show it in the wizard and on the sheet — **both**, they are separate paths |
  | `db/migrations/NNN-*.sql` + `db/schema.sql` | A column, if it is catalog data. Record it in the README migration table or the smoke test fails |
  | `test/smoke.mjs` | A case for the new shape |
  | `apps/character-creator/README.md` | What it means and why it exists |

  Prefer extending an existing block over adding a top-level key — `bonuses`
  already covers attributes, combat, saves, pools and `at_level`, and `combat`
  and `saves` are open sets, so a new key there costs nothing.

  **Reuse the validator.** A skill's bonuses go through the same
  `validateBonuses()` a class's do, which is why `derive.js` needed no new
  cases for them. Two validators for one shape is the pair that drifts.

## Reference

- `reference/frontmatter.md` — every block, its shape, and what reads it
- `reference/catalog.md` — catalog conventions: naming, renames, disagreements,
  skill bonuses, and extracting a skill list from a PDF
- `reference/data-script.sql` — the data-script skeleton to copy
