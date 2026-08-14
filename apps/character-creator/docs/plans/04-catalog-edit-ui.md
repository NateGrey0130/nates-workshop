# PR 4 — Catalog edit UI

## Problem

Only the importers write catalog rows. A single wrong percentage — and the
README documents two real cases, a skill read as 0% where the catalog had 30%,
and a secondary percentage split into its own entry — currently needs a
re-import or raw SQL.

## Decision

**All four catalogs, filterable table with inline row editing, plus manual row
creation, admin only.**

Rejected, deliberately:

- **Delete.** Not in this PR. Bad rows get corrected, not removed.
- **Merge duplicates.** Not in this PR, despite being the natural undo for a bad
  "keep both" import decision. Worth revisiting once the three new importers have
  been used against real books.
- **A "what references this row" view.** Not in this PR.
- **Modal, per-row page, and bulk grid** edit surfaces. Inline expansion suits
  the actual use case: hunt down one wrong number and fix it.
- **GM or all-signed-in access.** Catalogs are global; a GM's edit would leak
  into every other campaign. Per-campaign overrides would be the correct feature
  and are not this one.

## The catalog field config

This PR's most important output is not the UI — it is a single declarative
description of each catalog, which PRs 5, 6, and 7 reuse for their extraction
prompts and review tables.

New file, `functions/api/character-creator/_lib/catalog-fields.js`, exporting one
entry per catalog:

```js
export const CATALOGS = {
  skills:   { table: 'skills',          label: 'Skills',         fields: [...] },
  spells:   { table: 'spells',          label: 'Spells',         fields: [...] },
  psionics: { table: 'psionic_powers',  label: 'Psionic powers', fields: [...] },
  gear:     { table: 'gear',            label: 'Gear',           fields: [...] },
};
```

Each field carries at least: `name`, `label`, `type` (`text` | `int` | `bool` |
`json` | `longtext`), whether it is required, and whether it is the display name.
Write it so a new catalog is an entry, not a code change.

At this PR's point in the sequence the spell, psionic, and gear tables still have
their thin column sets. Define the config against what exists; PRs 5–7 each add
their new columns and extend their own entry.

## Work

**API** — `functions/api/character-creator/catalogs.js` today returns a trimmed
projection with no `id`, no `source_book`, and no `note`. Editing needs full
rows, so:

- Keep the existing shape for the wizard, which boots on it and does not want
  the extra weight.
- Add admin-gated CRUD-minus-delete: read full rows, update a row, create a row.
  Prefer new routes under `catalogs/` over overloading the boot endpoint.
- Validate against the field config — reject unknown fields, coerce types, and
  enforce the `name` unique constraint with a clear 409 rather than a raw SQLite
  error.
- Set `source = 'manual'` on hand-created and hand-edited rows so a later import
  can tell curated data from extracted data. The importers already default a
  bare stub to *update* and a curated row to *ignore*; this makes that
  distinction explicit rather than inferred.

**UI** — a new admin page alongside `import.html`, following the same framework
conventions (`/shared/styles.css`, `/shared/js/ui.js`, `escHtml` on every
interpolation):

- Catalog switcher across the four, matching the full-width tab pattern
  established on the import page in PR 13.
- Text filter over name, plus a category filter where the catalog has one.
- Click a row to expand it into editable fields in place; save or cancel that
  row. Only one row open at a time.
- "Add row" opens the same editor empty.
- Table columns come from the field config, so a new column appears without
  touching the page.

**Discoverability** — the import page's own history is the warning here. Add a
link from the character creator's landing page and cross-link between the import
and catalog pages, or this ships invisible the way the skills importer did.

## Acceptance

- All four catalogs list, filter, and page through their rows.
- Editing a skill's `base` percentage persists and is reflected in the wizard on
  next boot.
- Creating a skill by hand makes it selectable in the wizard.
- A duplicate name returns a clear error, not a 500.
- A non-admin gets a 403 from every write route and cannot reach the page.
- `node apps/character-creator/test/smoke.mjs` passes.

## Out of scope

Deleting rows, merging duplicates, reference lookup, bulk editing, per-campaign
overrides, and any edit history or audit trail.
