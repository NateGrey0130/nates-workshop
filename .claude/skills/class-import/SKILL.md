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

1. **Read the pages.** Check for a text layer FIRST — see the `book-survey`
   skill. A scan arrives as image renders and needs OCR; a book with a text
   layer is read straight with `python scripts/read-columns.py <pdf> <first>
   [last]`, geometrically, for nothing. The Palladium Fantasy main book has one
   and every class taken from it was read that way. Transcribe rather than
   guess either way: a wrong percentage is worse than a missing one, because
   nothing will ever flag it.
2. **Write the markdown to a scratch `.md` file first**, not straight into SQL.
   Iterating on bare markdown avoids re-escaping quotes every pass.
3. **Check it:**
   ```bash
   node scripts/class-check.mjs draft.md
   ```
   Parses through the real parser and cross-references the real catalogs. Free,
   no API call, no writes. Iterate here until it reads `ready`.

   Then check the fields nothing pins against the page they came from:
   ```bash
   node scripts/class-check.mjs draft.md --field-sources
   ```
   It prints the OCR-cache lines `starting_money` and the equipment prose were
   drawn from — and, when a source span ends near the bottom of its page, the
   first lines of the NEXT page. **Read that continuation block.** Both shipped
   `starting_money` errors were paragraphs that continued past a page break the
   reading stopped at (PR #280); this is the check that would have caught them.
   It resolves the book, window and page offset from `source_book` and the
   cache itself (`--book` / `--offset` override).
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

## A batch outlives the session on purpose

An import run is many PRs, and one conversation carrying all of them is the
most expensive way to hold what it knows: the 2026-08-25 efficiency audit
measured the same PR-shaped import costing 2–7× more late in a marathon
session than early, purely from re-carried context. The durable state lives in
`.cache/books/<slug>/SURVEY.md` (see the `book-survey` skill): append a ledger
line there when a PR merges, and **start a fresh session every 2–4 PRs**,
booted from that file plus `git log --oneline -15`. If the next class needs
something a previous conversation knew and the file does not hold, that is a
gap in the file — write it down there, not a reason to keep the session alive.

## The README is not working memory

**Never read `apps/character-creator/README.md` end to end.** The same audit
measured it read ~460 times across the book sessions, 37 of them in full, and
every full read re-carries for the rest of the session. The counts you would
skim it for — classes, skills, spells, gear — are pinned by the test suite, so
the test's own output is both cheaper and more current than the prose. For
everything else, index first, one section at a time:

```bash
node scripts/readme-section.mjs
```

```bash
node scripts/readme-section.mjs "Class definition format"
```

No arguments prints the heading index; a heading prints exactly one section,
bounded by the **next heading of any depth**, with its line range on stderr for
a bounded edit. The any-depth bound is the rule a 544-line section-eating edit
taught: a subsection is its own read, asked for by name.

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
The Priest of Light names `W.P. Siege` and `W.P. Large Axes` ahead of those rows
existing, and says so in its note; the exclusions activate by themselves when
the rows arrive. **The audit floor is TWO names, not zero** — it was three until
`W.P. Lance` was imported and that exclusion started working by itself, which is
the mechanism keeping its promise. The floor moves; check it rather than
trusting this sentence.

**But "not always a bug" is not "usually not a bug", and the ratio runs the
other way.** Sweeping every `only`/`except` name in every published class
against the live catalog on 2026-08-25 found **nine** unmatched names. Two were
the Priest of Light's. **Seven were dead exclusions** — six classes naming
`Robots and Power Armor` after the catalog renamed that row to
`Robots & Power Armor`, each silently offering the one Pilot skill its book
forbids, because an unmatched `except` fails OPEN.

A catalog rename breaks restrictions that were correct when they were written,
and nothing routine says so. **Re-run that sweep after any rename** — it is a
parse of every class against `SELECT name FROM skills`, and it is the only thing
that has ever caught this. Note the asymmetry it has to respect: a GRANTED skill
naming an old name still resolves, because redirects are consulted for
references; only restrictions skip them. The Robot Pilot cites the same old
string and is fine.

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
- **SQLite caps an expression tree at depth 100**, and a `||` chain is one node
  per term. Splicing a 60-line YAML block into `markdown` with
  `replace(markdown, anchor, '<line>' || char(10) || '<line>' || ...)` is
  rejected outright: `Expression tree is too large (maximum depth 100)`. Do it
  in CHUNKS of about 24 lines — plant a marker, append to it, then remove it.
  The sequence stays idempotent because the first statement cannot fire once the
  block is present and the rest cannot fire once the marker is gone.
- **A racial S.D.C. is a POOL BONUS, never `sdc_base`.** A race page saying
  *"20 plus those gained from O.C.C.s and physical skills"* means
  `bonuses: { pools: { sdc: 20 } }`. Written as `sdc_base` it is SILENTLY wrong:
  `combineClasses` gives the race's pool precedence over the occupation's, so a
  Troll Knight carries 40 instead of 40 + 3D6 and nothing on the sheet looks
  unusual. Palladium Fantasy printed 18 states the rule outright — *"All S.D.C.
  points/bonuses are cumulative."*
- **A class stating no `sdc_base` and no `mdc_base` needs a `CORE_SDC_BY_CLASS`
  entry** in `js/compose.js`, or the smoke test fails it. The value is `3D6` for
  a man of arms and `1D6` for everyone else, read off the book's own section
  heading — and for a RACE it is always `1D6`, because a race is never a man of
  arms and the entry only fires for a race played with no occupation at all.

## Correcting a class that already shipped

**Do not edit the original `add-*-class.sql`.** Those are one-shot scripts,
already applied. Add a new `fix-*.sql` alongside, guarded on the text it
replaces so re-running is a no-op, with readback `SELECT`s that assert the
result. Fifteen `fix-*.sql` / `apply-*.sql` scripts follow this shape.

**CHECK WHERE THE NEW NAME SORTS BEFORE YOU CHOOSE IT.** A clean rebuild applies
`apps/character-creator/db/*.sql` as one sorted glob, so filename order IS
execution order, and a correction that sorts BEFORE the file it corrects is
silently undone:

```bash
(ls apps/character-creator/db/*.sql | sed 's|.*/||'; echo "my-new-name.sql")   | sort | grep -n -B1 -A1 my-new-name
```

`fix-long-bowman-armor.sql` sorted before `fix-long-bowman.sql` — `-` is 0x2D
and `.` is 0x2E — and was overwritten by it on every rebuild. Only
`repo-vs-live.mjs` caught it, because production had them in the order they were
run by hand. `zz-` exists as a prefix for exactly this: a file that must sort
after everything.

The armor file has **since been folded away** — only `fix-long-bowman.sql` is in
the tree now — so do not go looking for it. The hazard is what survives, not
the file.

**One class per `add-<id>-class.sql`.** The smoke test maps each file to exactly
one id and checks `CORE_SDC_BY_CLASS` against that map; four classes in one file
left all four unaccounted for. A `fix-` script may touch several — the MOS fix
covers two — because nothing maps those to ids.

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

**CHECK THE REPORT BEFORE ACTING ON IT — it is a hand-maintained list and it has
been wrong twice.** `KNOWN_KEYS` in `scripts/class-check-lib.mjs` is written out
by hand, deliberately, because the question is not "does the parser touch it"
but "does anything downstream act on it". The cost of that is a FALSE alarm when
a key is modelled and nobody added it to the list:

| key | reported as unmodelled | actually |
|---|---|---|
| `psionics_allowed` | by the first six races to use it | modelled all along — `rollsForPsionics()`, the wizard's Race briefing, and a smoke check |
| `xp_table` | by anything that ever uses it | supported since `leveling.js` was written, read by six call sites, pinned by the smoke test |

A false alarm here is worse than a missing one, because the instruction attached
to the report is *delete the key or change the app*, and both break a working
field. **Grep for the key across `js/` and `functions/` before believing it.**
One hit in a `??`/`?.` chain is enough to mean it is read.

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
