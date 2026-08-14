# PR 6 — Psionic importer

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

**No psychic access level.** Capturing whether a power is Minor, Major, or Master
tier was offered and *not* chosen. Consequence, recorded here so it is not
mistaken for an oversight: the powers picker cannot filter Super psionics to
Master psychics automatically. That gating stays a table judgement. If you later
want it enforced, it is an added column plus picker logic, not a redesign.

## Schema

`db/migrations/008-psionic-detail.sql`:

```sql
ALTER TABLE psionic_powers ADD COLUMN range TEXT;
ALTER TABLE psionic_powers ADD COLUMN duration TEXT;
ALTER TABLE psionic_powers ADD COLUMN saving_throw TEXT;
ALTER TABLE psionic_powers ADD COLUMN description TEXT;
INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('008-psionic-detail.sql');
```

`TEXT` for the same reason as spells — book values are prose as often as numbers.
Mirror the additions into `db/schema.sql`.

## Work

- Extend the `psionics` entry in `_lib/catalog-fields.js` with the new fields.
- Add a psionics prompt fragment describing what a psionic power entry looks like
  on the page: name, ISP cost, range, duration, saving throw, then prose. Note
  that ISP is often written as "6" or as a range like "4 or 8".
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
- An existing seeded power prompts update / keep both / ignore; a bare stub
  defaults to update.
- Confirmed powers appear in the wizard's powers picker.
- Non-admin is refused.
- `node apps/character-creator/test/smoke.mjs` passes.

## Out of scope

Psychic access-level tiering, per-class power availability rules, and rendering
the new fields on the sheet.
