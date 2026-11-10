---
name: class-import
description: Transcribe a Rifts or Palladium Fantasy O.C.C. or R.C.C. from a sourcebook into the character creator as a D1 data script, and fill the catalog gaps it turns up. Use when adding, importing, transcribing, publishing or fixing a class — "add the Crazy O.C.C.", "import this R.C.C. from the scans", "the Dragon's bonuses are wrong", "these skills are missing" — and when importing skills, spells or gear from a book. Covers the frontmatter contract, the validator, catalog conventions, and what to do when a class needs a mechanic the app cannot express yet.
---

# Importing a class

> **Pinned:** the frontmatter and every repo path named here
> (`environment.mjs`), every absolute path (`instruction-paths.mjs`), and that
> it separates the permanent half of `extraction_notes` from the perishable
> (`smoke.mjs`). `rendered-ui.mjs` pins `reference/frontmatter.md`;
> `environment.mjs` pins `reference/data-script.sql`. Why each rule exists,
> with its incident: `reference/why.md`.

A class is a markdown file (YAML frontmatter for mechanics, prose body for
lore) stored as one row in `imported_classes`. Adding one means a one-off SQL
data script under `apps/character-creator/db/`.

**Do not read `js/parser.js` to learn the format**; `reference/frontmatter.md`
covers it. Read the parser only when modelling something new, and then read it
rather than the reference, which is not the whole key list.

## The loop

1. **Read the pages.** Check for a text layer first (`book-survey`). A text
   layer is read with `python scripts/read-columns.py <pdf> <first> [last]`; a
   scan needs OCR. Transcribe, never guess: a wrong percentage is worse than a
   missing one, because nothing flags it.
2. **Write the markdown to a scratch `.md` file**, not straight into SQL.
   **Give it a `tags:` line** after `category`: up to four authored tags for
   what the class is for (`reference/frontmatter.md` → *Tags*). The wizard's
   class filters and its quiz read nothing else.
3. **Check it against production**, and iterate until it reads `ready`:
   ```bash
   node scripts/class-check.mjs draft.md --remote
   ```
   **Always `--remote`.** A local D1 behind production reports real rows as
   missing and prints stub SQL that then ships. It is slow; run two classes at
   a time. Then check the unpinned fields against their page:
   ```bash
   node scripts/class-check.mjs draft.md --field-sources
   ```
   **Read the continuation block** it prints when a source span ends near a
   page bottom. `starting_money` has shipped wrong from a paragraph continued
   past a page break.
4. **Emit the data script**, still `--remote`, because this is the step that
   writes stubs into a file that ships:
   ```bash
   node scripts/class-check.mjs draft.md --remote --emit-script <id> > apps/character-creator/db/add-<id>-class.sql
   ```
   It writes stdout only, applies nothing, and refuses a draft that is not
   `ready`. `reference/data-script.sql` is the annotated skeleton for a script
   this does not fit. **Then check the finished `.sql` as its own step**, which
   runs the ASCII/CRLF pre-flight against the real artifact:
   ```bash
   node scripts/class-check.mjs apps/character-creator/db/add-<id>-class.sql
   ```
5. **Apply** `--local`, then `--remote` once it looks right. **Ask before
   `--remote`**: it writes the live database, before the merge (`ship-pr` →
   *The ordering rule*).
   ```bash
   node scripts/d1-apply.mjs --local apps/character-creator/db/add-<id>-class.sql
   ```
6. **Run the smoke test** before opening a PR:
   `node apps/character-creator/test/smoke.mjs`

**One class per `add-<id>-class.sql`.** The smoke test maps each file to one id.
A `fix-` script may touch several.

## A batch outlives the session on purpose

The durable state of an import run is `apps/character-creator/docs/surveys/<slug>.md`
(`book-survey`), not the conversation. **Start a fresh session every 2–4 PRs**,
booted from that file plus `git log --oneline -15`. Anything a session needed
that the file lacks is a gap in the file: write it there.

**The ledger line goes in the same PR as the work it describes**, written
before you open the PR. **Its PR column holds the branch name**
(`pal/data/<slug>-<what>`), never `#TBD` and never a later commit to fill in a
number: the number does not exist until `gh pr create`, and
`gh pr list --state all --head <branch>` finds it from the branch. Rows before
2026-09-27 carry `#N`, or a `#TBD` filled in by a second commit. That was the
old convention, and it is not a precedent to copy. Say what went in, the
catalog total it moved, and that the data was applied `--remote` first.

**Never read `apps/character-creator/README.md` end to end.** The counts are
pinned by the tests, whose output is cheaper and current. Read one section:

```bash
node scripts/readme-section.mjs
```

```bash
node scripts/readme-section.mjs "Class definition format"
```

## What class-check tells you

| Section | Meaning |
|---|---|
| `ERRORS` | The parser rejects it. Blocking. |
| `WARNINGS` | Parses, but may not do what you meant. Read each one. |
| `SQL PRE-FLIGHT` | A CR or a non-ASCII byte. Blocking. |
| `UNMODELLED` | A top-level key nothing reads. A decision, see the last section. |
| `CATALOG` | Missing skills/spells/psionics/gear, with stub SQL. |
| `restrictions` | Restriction names matching no catalog row. They do nothing. |
| `unreachable` | An `only` naming a skill whose real category the class does not grant: a skill nobody can take. |
| `cross-category` | An `only` naming a skill filed elsewhere, where the class does grant that category. Works. |
| `no-op except` | An `except` naming a skill from another category. Excludes nothing. |

Only `ERRORS` and `SQL PRE-FLIGHT` set the exit code.

**An error or warning ends in `(line N)` when it names a place in the class
markdown.** The line is found from the message's own path, so a message that
names no key carries none.

**One warning is a merge blocker in disguise:** `N bonus key(s) the sheet has
no field for`. The key parses, validates and composes, and the sheet draws it
nowhere, so the bonus is lost. It does not set the exit code here, but `smoke`
refuses a shipped class that has one. Fix the spelling, or add the key to
`COMBAT_FIELDS` or `SAVE_FIELDS` in `apps/character-sheet/sheet.js`, or carry
the bonus as `saves.other` or a special ability.

**An unmatched restriction is usually a bug.** An unmatched `except` fails
OPEN: the class offers what its book forbids. The known exceptions are the
Priest of Light's `W.P. Siege` and `W.P. Large Axes`, named ahead of their rows
and noted as such. **After any catalog rename, re-run the restriction sweep**:
`apps/character-creator/test/regression.mjs` runs it over every class against a
scratch D1. To run it `--remote` by hand, pass `restrictionNames()` the
`.data` of `parseClassMarkdown`'s result, not the result itself.

**The rules that are easy to get wrong** when writing a class are in `.claude/rules/class-data-scripts.md`. That file loads by itself only when a file under `apps/character-creator/db/` is read, so read it now if it is not in context.

## An extraction note that describes the APP will go stale

`extraction_notes` does two jobs, and only one is permanent:

| | |
|---|---|
| what the book prints, and what was stored | **permanent**: the record |
| what the app could do on the day of the import | **perishable**: it rots silently |

Write the DECISION and cite the finding, not the mechanism:

> Not stored; see BOOK-INGEST-AUDIT.md F8.  ← never goes stale
> `rollAttribute` parses only NdM forms, so a fixed value falls back to 3d6.  ← always will

Where the mechanism has to be in the class, write it past tense and name the
PR. `node scripts/audit-citations.mjs --remote F8` lists every class citing a
finding.

**Correcting a class that already shipped** (the `fix-` script, `class-fix-sql.mjs`, where a name sorts, keying a catalog write) is in the same file, `.claude/rules/class-data-scripts.md`: read it before writing the correction if it is not in context.

## When a class needs the app to change

Expected, not a failure. `class-check` reports it as `UNMODELLED`, a key that
parses and that nothing reads. **Never leave one unresolved**: silent storage is
how a class ships looking complete and doing nothing.

**Verify the report first.** `CLASS_KEYS` in
`apps/character-creator/js/class-keys.js` is hand-kept and has falsely reported
modelled keys (`psionics_allowed`, `xp_table`). **Grep the key across `js/` and `functions/`**; one hit in a
`??`/`?.` chain means it is read.

Then it is Nate's call:

- **Ship now, model later.** Move it into the body as prose and note it in
  `extraction_notes`.
- **Model it**, touching a predictable set of places:

  | File | What goes in it |
  |---|---|
  | `js/parser.js` | Validate the block; add it to `VARIANT_OVERRIDES` if a variant may override it |
  | `js/class-keys.js` | Add the key to `CLASS_KEYS`, and its race-and-occupation rule to `CLASS_MERGE` beside it; smoke fails without the rule |
  | `functions/api/.../validate-character.js` | Enforce it server-side, if a character can violate it |
  | `js/compose.js` | Fold it in, if an R.C.C.+O.C.C. pair combines it |
  | `js/derive.js` | Turn it into a number, if the sheet adds it up |
  | `app.js` / `sheet.js` | Show it in the wizard **and** on the sheet; they are separate paths |
  | `db/migrations/NNN-*.sql` + `db/schema.sql` | A column, if it is catalog data (`schema-change`); record it in the `apps/character-creator/docs/operations.md` migration table |
  | `test/smoke.mjs` | A case for the new shape |
  | `apps/character-creator/README.md` or the right file under `docs/` | What it means and why |

  Prefer extending an existing block: `bonuses` covers attributes, combat,
  saves, pools, `attribute_minimums` and `at_level`. **But `combat` and `saves`
  are open at the validator and CLOSED at the sheet**: an invented key parses,
  composes and renders nowhere, because `sheet.js` draws the literal lists
  `SAVE_FIELDS` and `COMBAT_FIELDS`. A new key means editing `derive.js` **and**
  that list. Use `saves.other` for an unnamed save and `special_abilities` for a
  combat bonus. **Reuse `validateBonuses()`**; two validators for one shape drift.

## Reference

- `reference/frontmatter.md`: every block, its shape, and what reads it
- `reference/catalog.md`: naming, renames, disagreements, skill bonuses, and
  extracting a skill list from a PDF
- `reference/data-script.sql`: the annotated data-script skeleton
- `reference/why.md`: the incident behind each rule above, for when a rule
  looks wrong and you are about to break it
