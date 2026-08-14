# Roadmap — planned PRs

Eleven planned PRs closing out the "Known limitations and refactor candidates"
section of the [app README](../../README.md#known-limitations-and-refactor-candidates).

Each item is its own PR, each has its own plan file, and every plan records
decisions that were made deliberately in a planning interview — not defaults.
**Where a plan says a choice was rejected, it was rejected on purpose.** Do not
quietly re-add it.

## Build order

Infrastructure first, so later PRs land on a base that records its own schema
changes and can undo a bad import.

| # | PR | Plan | Depends on |
|---|---|---|---|
| 1 | Migration tracking | [01-migration-tracking.md](01-migration-tracking.md) | — |
| 2 | Class soft-delete | [02-class-soft-delete.md](02-class-soft-delete.md) | 1 |
| 3 | Rename `items` to `gear` | [03-items-to-gear.md](03-items-to-gear.md) | 1 |
| 4 | Catalog edit UI | [04-catalog-edit-ui.md](04-catalog-edit-ui.md) | 1, 3 |
| 5 | Spell importer + shared engine | [05-spell-importer.md](05-spell-importer.md) | 1, 4 |
| 6 | Psionic importer | [06-psionic-importer.md](06-psionic-importer.md) | 5 |
| 7 | Gear importer | [07-gear-importer.md](07-gear-importer.md) | 3, 5 |
| 8 | List pagination | [08-pagination.md](08-pagination.md) | — |
| 9 | Level-up skill picker | [09-levelup-skill-picker.md](09-levelup-skill-picker.md) | — |
| 10 | Server-side rule enforcement | [10-server-rule-enforcement.md](10-server-rule-enforcement.md) | 9 |
| 11 | Sheet targeted re-render | [11-sheet-targeted-render.md](11-sheet-targeted-render.md) | — |

PRs 8, 9, and 11 have no hard dependency on the infra work and can move earlier
if something makes that convenient. 5 → 6 → 7 must stay in order: PR 5 builds the
shared import engine that 6 and 7 are thin configurations of.

## Decisions that span several PRs

**One shared catalog import engine.** PR 5 generalises the working skill importer
into a reusable engine — upload, extract, duplicate detection, update / keep-both
/ ignore review, batch confirm — driven by a per-catalog configuration. The skill
importer migrates onto it in the same PR. PRs 6 and 7 then add a config each
rather than a fourth copy of the flow. The alternative of cloning the skill
importer three times was considered and rejected: a bug fix would need applying
four times.

**One field vocabulary across catalogs.** Spells, psionic powers, and gear all
gain a real stat block, and spells and psionics deliberately share field names
(`range`, `duration`, `saving_throw`, `description`) so the sheet renders both
through the same code.

**The catalog field config is written once, in PR 4.** The edit UI needs a
per-catalog description of fields, types, and labels. That same config drives
the importers' extraction prompts and review tables. This is why the edit UI is
sequenced before the importers rather than after.

**Admin-gated writes.** Catalogs are global — one edit changes every character.
Every catalog write, from the edit UI and from every importer, stays behind the
existing `ADMIN_EMAIL` gate in `functions/api/_lib/access.js`, which fails closed.

## Standing constraints these plans inherit

From the app README, and non-negotiable in every plan below:

- **PDFs go to Claude as document attachments, never as pre-extracted text.**
  Layout-preserving extraction splices two-column sourcebook pages together
  mid-line. Do not add a text pre-pass.
- **Server-side callers use `_lib/claude-client.js` directly.** Never fetch the
  site's own `/api/claude` URL — Access intercepts the subrequest and returns the
  login page as HTML.
- **`db/schema.sql` stays idempotent**; ALTERs live in `db/migrations/`.
- **Schema changes are applied by hand before the deploy that needs them**, and
  verified by querying them back rather than by trusting an exit code.
- No build step, no framework, no dependencies.
