# PR 2 — Class soft-delete

> **Delivered** in [#16](https://github.com/NateGrey0130/nates-workshop/pull/16). This file is the record of why, not a to-do.

## Problem

When classes lived in committed markdown files, a bad row could be overridden by
a commit. D1 is now the only source and deletes are hard. A mis-imported or
mistakenly deleted O.C.C. is unrecoverable.

## Decision

**`deleted_at` on stored classes only.** Characters already built on a retired
class keep working, and the sheet shows a quiet advisory that the class was
retired.

Rejected, deliberately:

- **Extending soft-delete to catalogs and characters.** Wider net, but not the
  stated problem, and every list query would need the filter. Revisit if a bad
  catalog import actually bites — the importers all end in a review step
  specifically to prevent that.
- **Blocking deletion while a class is in use.** Would force cleanup of live
  characters before retiring a class, which is backwards: retiring a class is
  usually *why* you want the old characters left alone.
- **Silent hiding with no sheet indication.** A character whose class no longer
  appears in the picker should say so somewhere, or it looks like data loss.

## Schema

`db/migrations/003-class-soft-delete.sql`:

```sql
ALTER TABLE <stored classes table> ADD COLUMN deleted_at TEXT;
INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('003-class-soft-delete.sql');
```

Also add the column to `db/schema.sql`'s create statement for new databases.
Confirm the table's real name in `db/schema.sql` before writing this — the
README calls it "classes created by the PDF import tool".

## Work

`functions/api/character-creator/_lib/class-store.js` owns all of this:

- `deleteStored` becomes a soft delete — `UPDATE … SET deleted_at = datetime('now')`.
- `listStored` and `loadPublished` filter `WHERE deleted_at IS NULL` by default,
  and take an option to include deleted rows.
- `getStored` still returns a deleted class when asked by id, so characters
  referencing it continue to resolve. This is what keeps existing sheets working.
- Add `restoreStored(id)` — `UPDATE … SET deleted_at = NULL`.
- **Check the `parseCache`.** It is keyed on `updated_at`. A soft delete or
  restore must invalidate or bump that key, or a deleted class can be served from
  a stale isolate cache. Setting `updated_at` alongside `deleted_at` is the
  simplest fix.

API and UI:

- The admin class list gains a "retired" filter and a restore action for rows in
  it. Admin-gated, same as the rest of the import surface.
- The creation wizard's class picker shows only live classes.
- `sheet.js` renders an advisory — reuse the existing `advisory()` helper — when
  the character's class has a non-null `deleted_at`: *"This class has been
  retired. Existing characters are unaffected."*

## Acceptance

- Deleting a class removes it from the wizard's picker.
- A character built on that class still loads, still saves, still levels up, and
  shows the retirement advisory on its sheet.
- Restoring the class removes the advisory and returns it to the picker, with no
  stale-cache delay.
- A non-admin cannot delete or restore.
- `node apps/character-creator/test/smoke.mjs` passes.

## Out of scope

Soft-delete for skills, spells, psionic powers, gear, characters, or campaigns.
Purge tooling for genuinely removing a soft-deleted class.
