---
paths:
  - "apps/character-creator/db/**"
---

# Class data scripts

> **What pins this file:** every absolute path it names, by
> `apps/character-creator/test/checks/instruction-paths.mjs`. Nothing pins
> its frontmatter or the repo paths it names: it is a path-scoped rule, not a
> skill, so `environment.mjs` does not read it.
>
> **The prose is pinned by nothing** - read an undated claim here as true on
> the day it was written.

These bind anyone writing under `apps/character-creator/db/`. They were moved
unchanged out of the `class-import` skill (2026-11-06), which still owns the
import loop, what `class-check` reports, extraction notes, and what to do when
a class needs the app to change.

## Rules that are easy to get wrong

- **Related and secondary skills come from the O.C.C., not the R.C.C.** An
  R.C.C. granting zero of each is correct.
- **`base` is the catalog base plus the class's printed bonus**, added by you.
  The book prints "Lore: Magic (+15%)", the catalog holds 25%, so the class
  says `base: 40`. The app does not add them at runtime.
- **`base` fixes a percentage; `bonus` adds to each pick's own base.** A choice
  group spanning a category almost always wants `bonus`.
- **Look every name up; never carry one in your head.** Conventions are mixed:
  the `Pilot` category holds both prefixed (`Military: Combat Helicopter`) and
  bare (`Helicopter`) rows. `class-check --remote` prints whatever matched nothing.
- **A wrong name fails in opposite directions.** A grant resolves through
  `catalog_redirects` and works; an `only`/`except` skips redirects and dies
  silently, with `except` failing open.
- **Money is coin only.** `starting_money` is credits or gold; gear goes in
  `equipment_starting`.
- **Every gear item needs a catalog row.** A missing one gets a stub marked
  exactly `STUB — created by class import, needs stats`. `class-check` writes it.
- **Pure ASCII and LF, in the whole file, comments included.** An em-dash in a
  value is spliced as `' || char(8212) || '`; one in a comment must go.
- **Conditional bonuses are prose.** `bonuses:` apply unconditionally, so "+2 to
  strike when flying" goes in `special_abilities` or `side_effects`.
- **D1 caps a compound SELECT at five terms.** A readback that `UNION`s six
  fails and rolls the file back; count with `IN`.
- **SQLite caps an expression tree at depth 100.** Splice a long YAML block with
  `replace(... || char(10) || ...)` in chunks of about 24 lines: plant a
  marker, append to it, then remove it.
- **A racial S.D.C. is a POOL BONUS, never `sdc_base`.** *"20 plus those gained
  from O.C.C.s and physical skills"* is `bonuses: { pools: { sdc: 20 } }`.
  As `sdc_base` it silently overrides the occupation's pool.
- **A class stating no `sdc_base` and no `mdc_base` needs a `men_of_arms` line**
  in its own frontmatter: `true` rolls the core 3D6, `false` the core 1D6. Read
  it off the book's section heading and name that heading in
  `extraction_notes`. **A race is always `false`.** Smoke and regression fail a
  class that states neither. Never edit `js/compose.js` for this.

## Correcting a class that already shipped

**Never edit the original `add-*-class.sql`**: it was applied once. Add a new
`fix-*.sql`, guarded on the text it replaces so a re-run is a no-op, with
readback `SELECT`s asserting the result. (`backfill-`, `merge-`, `rename-` and
`retire-` name more specific jobs.)

**An edit too large for a `replace()`** - a prose table turned into a pick
group, a class rewritten whole - goes through
`node scripts/class-fix-sql.mjs <fix-dir> <out.sql>`, not a generator rebuilt
in the scratchpad
or retyped from memory (BOOK-INGEST-AUDIT.md F124). The test for "too large":
the guarded `replace()` calls would outnumber the lines left alone. It takes
the finished markdown and, per class, a `guard` sentence (or `guard_absent`)
and a `proof`, and writes the guarded whole-markdown `UPDATE`s with their
read-backs; pass `--remote` so `old_length` is read from production rather
than measured off a file. The markdown may hold an em dash or any other
character above U+007F: it is written as a `char(N)` splice
(BOOK-INGEST-AUDIT.md F132). A `guard` or a `proof` may not, so pick ones
that avoid it. Its header gives the input shape. When it refuses
the input, fix the input. NEW catalog rows a class needs go through
`scripts/rows-sql.mjs` and vehicles through `scripts/vessel-sql.mjs`; a
correction to a row that EXISTS is still a hand-written `fix-` script, because
those two write `INSERT OR IGNORE`.

**Check where the new name sorts BEFORE choosing it.** A rebuild applies
`apps/character-creator/db/*.sql` as one sorted glob, so a correction that sorts
before the file it corrects is silently undone:

```bash
(ls apps/character-creator/db/*.sql | sed 's|.*/||'; echo "my-new-name.sql")   | sort | grep -n -B1 -A1 my-new-name
```

Never reason from a prefix convention: `z`-tiers have escalated past `zzzzz-`,
and `-` (0x2D) sorts before `.` (0x2E), so `fix-x-y.sql` sorts before
`fix-x.sql`. Run the command and read where the name lands.

The markdown lives in D1, so a fix edits it with `replace()`:

```sql
UPDATE imported_classes SET markdown = replace(markdown, '"Old Name"', '"New Name"')
  WHERE class_id = 'x' AND instr(markdown, '"Old Name"') > 0;
```

Checking the original `.sql` afterwards still reports the pre-fix state: **the
`.sql` reports what it creates; the database is the current truth.**

**Key a CATALOG write on `name`, or `slug` for gear, never a literal `id`.**
Catalog ids are autoincrement insertion order, which differs per environment,
so `WHERE id = 283` hits the wrong row with no error. `test/smoke.mjs` refuses a
literal one. Classes are keyed on `class_id`, a stable slug.
