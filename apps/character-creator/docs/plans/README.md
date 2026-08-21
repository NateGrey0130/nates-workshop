# Roadmap — delivered

**All twelve PRs are built and merged.** These files are kept as the record of
*why* things are the way they are, not as a to-do list.

Each plan records decisions made deliberately in a planning interview — and, as
importantly, the alternatives that were **rejected**. Where a plan says a choice
was rejected, it was rejected on purpose. Do not quietly re-add it.

**This roadmap ends at [#29](https://github.com/NateGrey0130/nates-workshop/pull/29); the work did not.** Everything
after it — the rules audit against the source books, the class-data corrections
and the schema work that came out of them — is recorded in
[`docs/rules-audit.md`](../rules-audit.md) instead. Where the two disagree, the
audit is newer: it was written against the books, and a plan describes the code
as it stood the day the plan was written. [Plan 12](12-psionic-tier-rules.md) is
the one most changed since, and carries a note saying so.

Several plans also carry an **As built** note where reality diverged from the
plan. Those divergences are the most useful thing here: they are the places
where the plan turned out to be wrong once it met the code.

## What shipped

| # | PR | Plan | Merged |
|---|---|---|---|
| 1 | Migration tracking | [01](01-migration-tracking.md) | [#15](https://github.com/NateGrey0130/nates-workshop/pull/15) |
| 2 | Class soft-delete | [02](02-class-soft-delete.md) | [#16](https://github.com/NateGrey0130/nates-workshop/pull/16) |
| 3 | Rename `items` to `gear` | [03](03-items-to-gear.md) | [#17](https://github.com/NateGrey0130/nates-workshop/pull/17) |
| 4 | Catalog edit UI + field config | [04](04-catalog-edit-ui.md) | [#18](https://github.com/NateGrey0130/nates-workshop/pull/18) |
| 5a | Shared import engine | [05](05-spell-importer.md) | [#19](https://github.com/NateGrey0130/nates-workshop/pull/19) |
| 5b | Spell importer + sessions | [05](05-spell-importer.md) | [#20](https://github.com/NateGrey0130/nates-workshop/pull/20) |
| 6 | Psionic importer | [06](06-psionic-importer.md) | [#21](https://github.com/NateGrey0130/nates-workshop/pull/21) |
| — | Review fixes | — | [#22](https://github.com/NateGrey0130/nates-workshop/pull/22) |
| 7 | Gear importer | [07](07-gear-importer.md) | [#23](https://github.com/NateGrey0130/nates-workshop/pull/23) |
| 8 | List pagination | [08](08-pagination.md) | [#24](https://github.com/NateGrey0130/nates-workshop/pull/24) |
| 9 | Level-up skill picker | [09](09-levelup-skill-picker.md) | [#25](https://github.com/NateGrey0130/nates-workshop/pull/25) |
| 10 | Server-side rule enforcement | [10](10-server-rule-enforcement.md) | [#26](https://github.com/NateGrey0130/nates-workshop/pull/26) |
| 11 | Sheet targeted re-render | [11](11-sheet-targeted-render.md) | [#27](https://github.com/NateGrey0130/nates-workshop/pull/27) |
| 12 | Psychic tier rules | [12](12-psionic-tier-rules.md) | [#28](https://github.com/NateGrey0130/nates-workshop/pull/28) |
| — | Duplicate merging | — | [#29](https://github.com/NateGrey0130/nates-workshop/pull/29) |

Duplicate merging was not in the roadmap. PR 4 deliberately left it out as
out of scope, and the first real book import immediately created the demand for
it — ten duplicate pairs that exact-name matching could not see.

## What is planned

Four plans written in an interview on 2026-08-20 and **not yet built**. Unlike
everything above, these are specifications rather than records — but the
rejected alternatives in them were rejected on purpose too.

| # | Plan | Depends on |
|---|---|---|
| 13 | [R.C.C.-first wizard](13-rcc-first-wizard.md) — Class splits into Race and Occupation with Attributes between them | — · **built** |
| 14 | [Starting above level 1](14-start-at-level.md) — an Advancement step running the existing level-up engine 1→N | 13 · **built** |
| 15 | [Campaign notes, search and the party stash](15-campaign-notes.md) — implied membership, FTS5 search, an Ask endpoint, a shared stash | — |
| 16 | [NPC dossiers and portraits](16-npc-dossiers.md) — `@mention` linking, a Claude sweep, and the site's first R2 bucket | 15 |

Two things in them are larger than they look. **PR 14 adds class-format keys**
(`magic.spells_per_level`, `psionics.powers_per_level`) because per-level spell
and psionic gains are not in the extracted data at all, and the importer prompt
has to name them or they never arrive. **PR 16 adds the site's first R2
binding**, as shared infrastructure rather than a character-creator private.

## Where the plans were wrong

Worth reading before trusting any plan as a specification:

- **PR 1** called for a `003` backfill migration. Guarded seeding in
  `schema.sql` made it unnecessary, and the guard — checking the schema feature
  a migration adds, rather than assuming — became the convention every later
  migration follows.
- **PR 2** warned about invalidating a parse cache. Unnecessary: the cache is
  only consulted for rows the query already returned.
- **PR 8** wanted uniform pagination across every list endpoint. The wizard
  boots by fetching five lists and rendering pickers from three of them, so a
  truncated catalog would silently hide valid choices. Only the lists that grow
  with play are bounded.
- **PR 10** assumed a character's stored skill rows were a usable source of
  category. They are not — the wizard writes `category: "Class"` on every
  O.C.C. skill — and choice groups turned out to be uncheckable in principle,
  so they warn rather than block.
- **PR 11** knew about armour re-renders but not that the inventory paths called
  `load()`, which refetched and replaced state wholesale. That was the bug
  actually destroying unsaved edits.

## Decisions that span several PRs

**One shared catalog import engine.** Skills, spells, psionic powers and gear
all run through `_lib/import-engine.js` with a per-catalog spec; the session
endpoints for the latter three are three lines each. Cloning the skill importer
was considered and rejected — a bug fix would have needed applying four times.

**One field vocabulary.** Spells and psionics deliberately share field names
(`range`, `duration`, `saving_throw`, `description`) so the sheet renders both
through the same code.

**Importers record what the book says; they never infer.** An absent value stays
absent, and NULL means "not stated" rather than a computed default. PR 6's
`min_tier` is the clearest case.

**Admin-gated catalog writes.** Catalogs are global — one edit changes every
character — so every write stays behind the `ADMIN_EMAIL` gate, which fails
closed.

## Standing constraints

Non-negotiable, and every plan inherits them:

- **PDFs go to Claude as document attachments, never as pre-extracted text.**
  Layout-preserving extraction splices two-column sourcebook pages together
  mid-line. Do not add a text pre-pass.
- **Server-side callers use `_lib/claude-client.js` directly.** Never fetch the
  site's own `/api/claude` URL — Access intercepts the subrequest and returns
  the login page as HTML.
- **`db/schema.sql` stays idempotent**; ALTERs live in `db/migrations/`, each
  recording itself in `schema_migrations` and each with a guarded seed line in
  `schema.sql`.
- **Schema changes are applied by hand before the deploy that needs them**, and
  verified by querying them back rather than trusting an exit code.
- No build step, no framework, no dependencies.
