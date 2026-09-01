# Roadmap — delivered

**Plans 05, 06 and 07 describe a thing that no longer exists.** The in-app
importer they specify was retired in full — page, routes, engine and staging
tables — after it turned out never to have run once against production. The
plans are LEFT AS WRITTEN, because this directory is a record of decisions and
not a description of the current code; deleting them would remove the reasoning
and leave only the outcome. What replaced them is `scripts/extract-class.mjs`
and a hand-written data script. See `docs/importing-from-pdfs.md`.

**Every plan here is built and merged except 19**, which is a specification
waiting on its first slice. These files are kept as the record of
*why* things are the way they are, not as a to-do list. (This line read "all
twelve" long after the table had grown past eighteen plans and PR #228. A count
in a heading is a maintenance burden nobody signed up for, so it is gone.)

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

**Paths inside a plan are as of the day it was written.** Files have moved
since, and a plan naming a migration number or a script filename is naming
what it *proposed*, which is not always what shipped. So a path here that does
not resolve means the file moved or was renamed — it does not mean the plan is
wrong. Search for the basename, or `git log --follow` it. Nothing in this
directory is maintained against the current tree, deliberately: these are
dated records, and a dated record pointing at where a file *was* is history.

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
| 17a | `gear.sdc` | [17](17-magic-items.md) | [#224](https://github.com/NateGrey0130/nates-workshop/pull/224) |
| 17b | Enchantments, and a third family | [17](17-magic-items.md) | [#225](https://github.com/NateGrey0130/nates-workshop/pull/225), [#226](https://github.com/NateGrey0130/nates-workshop/pull/226) |
| 17c | Enchant an item, sheet and API | [17](17-magic-items.md) | [#227](https://github.com/NateGrey0130/nates-workshop/pull/227) |
| 17d | 175 finished magic items | [17](17-magic-items.md) | [#228](https://github.com/NateGrey0130/nates-workshop/pull/228) |
| 18a | `xp_table` survives composition | [18](18-experience-tables.md) | [#222](https://github.com/NateGrey0130/nates-workshop/pull/222) |
| 18b | Experience tables by O.C.C. | [18](18-experience-tables.md) | [#223](https://github.com/NateGrey0130/nates-workshop/pull/223) |
| — | Duplicate merging | — | [#29](https://github.com/NateGrey0130/nates-workshop/pull/29) |

Duplicate merging was not in the roadmap. PR 4 deliberately left it out as
out of scope, and the first real book import immediately created the demand for
it — ten duplicate pairs that exact-name matching could not see.

## What was planned next, and has since shipped

Four plans written in an interview on 2026-08-20 as specifications rather than
records — **all four have since been built**, as each row says. The rejected
alternatives in them were rejected on purpose too.

| # | Plan | Depends on |
|---|---|---|
| 13 | [R.C.C.-first wizard](13-rcc-first-wizard.md) — Class splits into Race and Occupation with Attributes between them | — · **built** |
| 14 | [Starting above level 1](14-start-at-level.md) — an Advancement step running the existing level-up engine 1→N | 13 · **built** |
| 15 | [Campaign notes, search and the party stash](15-campaign-notes.md) — implied membership, FTS5 search, an Ask endpoint, a shared stash | — · **built** |
| 16 | [NPC dossiers and portraits](16-npc-dossiers.md) — `@mention` linking, a Claude sweep, and the site's first R2 bucket | 15 · **built** |

Two things in them are larger than they look. **PR 14 adds class-format keys**
(`magic.spells_per_level`, `psionics.powers_per_level`) because per-level spell
and psionic gains are not in the extracted data at all, and the importer prompt
has to name them or they never arrive. **PR 16 adds the site's first R2
binding**, as shared infrastructure rather than a character-creator private.

## Planned, not yet built

| # | Plan | Depends on |
|---|---|---|
| 19 | [G.M. grants](19-gm-grants.md) — skills, spells, psionics, abilities and stats a table hands out, entered by the player and recorded with who and why | — |

It is a specification rather than a record, so read it the way plans 13–16 were
read before they were built: the rejected alternatives in it were rejected on
purpose, and the section it calls open is open.

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

## Proposals, written before they were built

Two written proposals live here. They were asked for as writing rather than as
code, and they are kept apart from the roadmap above because that is how they
were commissioned — a recommendation with real numbers, and a decision to make
before any of it was built. Both were later green-lit, and both shipped.

| # | Proposal | Verdict | Built? |
|---|---|---|---|
| 17 | [Enchanted items](17-magic-items.md) | recommended, in a reduced form; do the `gear.sdc` column first and on its own | **yes**, #224 then #225-#228 |
| 18 | [Experience tables by O.C.C.](18-experience-tables.md) | recommended; **no schema at all** — the override already existed and two one-line bugs were in its way | **yes**, #222 then #223 |

Both shipped in the order they recommended. **17** did the `gear.sdc` column
first and on its own, then option B in three parts. The one thing it got wrong
is worth reading against the outcome: it counted printed 253 as *"29 finished
items with a price"*, and the page says those are **powers placed in** a ring,
three to an item — which made them a third enchantment family rather than
thirty rows of gear.

**18** shipped in the two halves it recommended: the blockers on their own, then the
225 numbers as a single data script with no schema at all. The proposal is left
as written rather than rewritten in the past tense — what it predicted and what
happened are both worth being able to read.
