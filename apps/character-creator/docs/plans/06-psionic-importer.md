# PR 6 — Psionic importer

> **Delivered** in [#21](https://github.com/NateGrey0130/nates-workshop/pull/21). This file is the record of why, not a to-do.

Thin by design. PR 5 built the engine; this is a configuration plus a schema
extension.

## Problem

26 psionic powers are hand-seeded with only a name, category, and ISP cost. Same
shape of gap as spells, smaller volume.

## Decisions

**Match the spell field block.** Psionic powers gain `range`, `duration`,
`saving_throw`, and `description` — the same field names PR 5 gives spells, so
the sheet can render both through one code path.

**Validate categories against the known set, flag misses.** Healing, Physical,
Sensitive, and Super are expected. Anything else is surfaced in review for you to
accept or correct rather than silently written. Rejected: accepting whatever the
book says, and hard-rejecting anything outside the four.

**Capture a per-power minimum tier, `min_tier`, from the book.** Minor, Major,
and Master differ in ways that change what a player may choose at build time, so
the tier a power requires is worth recording. Extract only what the book states —
do not infer a tier from the category.

This was reversed from an earlier decision to skip tiers entirely. Two things
already work and are **not** what this adds: the character's own tier lives in
class frontmatter as `psionics.type: minor | major | master`, and Super psionics
are already gated to Master through `psionics.categories_allowed`, with starting
counts of minor 2 / major 6 / master 8.

**`min_tier` NULL means "no restriction beyond its category"** — current
behaviour. The column only ever narrows access further, and only when a book
explicitly says so. Rejected: inferring the tier from the category on import,
which would record a guess as though the book said it — precisely what the review
step exists to prevent; and treating NULL as Master-only, which would hide most
of the existing catalog from Minor and Major psychics overnight.

**The 26 hand-seeded powers stay NULL.** They keep working under the rule above,
and PR 4's catalog edit UI is the tool for setting a tier by hand on the few that
need one. Rejected: a migration that backfills by category (bakes in an
inference), and re-importing the core book's psionics chapter to overwrite them
(best data, real work and API spend — a reasonable thing to do later, on
purpose).

**Enforcement is not in this PR.** The picker blocking an out-of-tier power is
[PR 12](12-psionic-tier-rules.md), which cannot be meaningfully built or tested
until this PR has put real data in the column.

Be aware while writing the prompt fragment: books express tier gating mostly at
the **category** level, not per power. Expect `min_tier` to come back absent for
most entries. That is the expected result, not a failed extraction.

## Schema

`db/migrations/007-psionic-detail.sql`:

```sql
ALTER TABLE psionic_powers ADD COLUMN range TEXT;
ALTER TABLE psionic_powers ADD COLUMN duration TEXT;
ALTER TABLE psionic_powers ADD COLUMN saving_throw TEXT;
ALTER TABLE psionic_powers ADD COLUMN description TEXT;
ALTER TABLE psionic_powers ADD COLUMN min_tier TEXT;   -- minor | major | master; NULL = category rules only
INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('007-psionic-detail.sql');
```

`TEXT` for the same reason as spells — book values are prose as often as numbers.
`min_tier` is deliberately nullable with no default; see the decision above.
Mirror the additions into `db/schema.sql`.

## Work

- Extend the `psionics` entry in `_lib/catalog-fields.js` with the new fields,
  `min_tier` included so PR 4's edit UI can set it by hand.
- Add a psionics prompt fragment describing what a psionic power entry looks like
  on the page: name, ISP cost, range, duration, saving throw, then prose. Note
  that ISP is often written as "6" or as a range like "4 or 8".
- Instruct the prompt to fill `min_tier` **only** when the book states a tier
  requirement for that power, and to leave it absent otherwise. An inferred tier
  is worse than no tier.
- Category validation lives in the engine's per-catalog validation hook. An
  unrecognised category stages the row with a flag; the review row shows it with
  a visible warning and a category selector so you can correct it in place before
  confirming.
- Add a **Psionics** tab to `import.html`.
- Sessions, staging, duplicate handling, and batch confirm all come from the
  engine unchanged.

## Acceptance

- A psionics session imports a page range and stages powers with populated
  range, duration, save, and description.
- A power whose extracted category is not one of the four is flagged in review
  and can be corrected before confirm.
- A power the book states a tier for is staged with `min_tier` set; a power with
  no stated tier is staged with `min_tier` absent, not guessed.
- Existing seeded powers keep `min_tier` NULL and remain selectable exactly as
  before — this PR changes no selection behaviour.
- An existing seeded power prompts update / keep both / ignore; a bare stub
  defaults to update.
- Confirmed powers appear in the wizard's powers picker.
- Non-admin is refused.
- `node apps/character-creator/test/smoke.mjs` passes.

## Out of scope

Enforcing `min_tier` in the powers picker and the tier-based save target — both
are [PR 12](12-psionic-tier-rules.md). Per-class power availability rules beyond
the existing `categories_allowed`. Rendering the new fields on the sheet.
