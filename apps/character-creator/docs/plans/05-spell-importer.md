# PR 5 — Spell importer and the shared import engine

> **Delivered** in [#19](https://github.com/NateGrey0130/nates-workshop/pull/19). This file is the record of why, not a to-do.
> Split in two: the engine refactor is #19, the spell importer and sessions #20.

The largest PR in the roadmap. It does two things: generalises the working skill
importer into a reusable engine, and lands the spell importer on top of it.

## Problem

19 spells are hand-seeded, and each carries only a name, level, and PPE cost —
not enough to cast from. A Rifts spell chapter is hundreds of entries across many
pages, so this is also the first import that cannot be done in one call.

## Decisions

**Full stat block plus description.** Spells gain `range`, `duration`, `damage`,
`saving_throw`, `area_of_effect`, `casting_time`, and `description`. Rejected: a
mechanical-only block with no prose, keeping the three thin columns, and adding a
`raw_text` verbatim column alongside.

**Named import sessions.** Start a session, submit page ranges one at a time, and
extracted spells accumulate in a persistent staging table you review and confirm
in batches. Survives a closed tab; you can stop halfway through a book and resume
later. Rejected: one range at a time with nothing linking the runs, multi-range
fan-out in a single submission, and whole-chapter auto-chunking.

**Extend the smoke test before refactoring.** `test/smoke.mjs` gains coverage of
the skill import path *first*, so migrating it onto shared code has something to
prove against. Rejected: verifying by hand through the UI, and leaving the skill
importer on its own path.

**Duplicate detection on name only.** Consistent with the existing importer and
the `name` UNIQUE constraint. A second book's "Fire Bolt" prompts update /
keep both / ignore, with keep-both defaulting to `Fire Bolt (<book>)`. Rejected:
keying on name plus level, and fuzzy near-match flagging.

## Sequence within the PR

Land these as separate commits so a regression is bisectable:

1. **Smoke test coverage for skill import.** Parser-level and store-level, not a
   live API call.
2. **Extract the engine**, migrate the skill importer onto it, prove the smoke
   test still passes. No behaviour change.
3. **Schema** — spell columns and the staging table.
4. **Spell importer** as a config on the engine.

## The engine

New `functions/api/character-creator/_lib/import-engine.js`, generalising what
`import/skills/extract.js` and `import/skills/confirm.js` do today:

- Build the extraction prompt from a catalog's field config (PR 4's
  `catalog-fields.js`) plus a per-catalog prompt fragment.
- Send the PDF as a **document attachment** via `_lib/claude-client.js` directly.
  Never a text pre-pass. Never a self-fetch of `/api/claude`.
- Parse and validate the response against the field config.
- Cross-reference names against the live catalog to classify each row as new or
  duplicate, reusing the batched `IN` lookups in `_lib/catalog.js`.
- Apply default actions: a bare stub defaults to *update*, a curated row defaults
  to *ignore*, so hand-corrected numbers are never silently overwritten. With
  PR 4 in place, `source = 'manual'` makes "curated" explicit.
- Confirm as one `batch()`, with the `queued` Set that prevents intra-batch name
  collisions and the try/catch that returns 409 rather than failing the run.

Per-catalog configuration supplies: the catalog key, the prompt fragment
describing what the book's entries look like, any value validation, and the
duplicate-key strategy.

## Schema

`db/migrations/005-spell-detail.sql`:

```sql
ALTER TABLE spells ADD COLUMN range TEXT;
ALTER TABLE spells ADD COLUMN duration TEXT;
ALTER TABLE spells ADD COLUMN damage TEXT;
ALTER TABLE spells ADD COLUMN saving_throw TEXT;
ALTER TABLE spells ADD COLUMN area_of_effect TEXT;
ALTER TABLE spells ADD COLUMN casting_time TEXT;
ALTER TABLE spells ADD COLUMN description TEXT;
```

These are `TEXT` on purpose — book values are prose as often as numbers
("100 feet per level of experience", "2D6 melee rounds").

`db/migrations/006-import-sessions.sql` — the staging tables:

```sql
CREATE TABLE import_sessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  catalog TEXT NOT NULL,             -- spells | psionics | gear | skills
  name TEXT NOT NULL,
  source_book TEXT,
  created_by TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  closed_at TEXT
);

CREATE TABLE import_staged (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id INTEGER NOT NULL REFERENCES import_sessions(id) ON DELETE CASCADE,
  page_range TEXT,
  payload TEXT NOT NULL,             -- JSON: the extracted row
  match_id INTEGER,                  -- catalog row this duplicates, if any
  action TEXT NOT NULL DEFAULT 'new',-- new | update | keep_both | ignore
  resolved_name TEXT,                -- for keep_both
  confirmed_at TEXT
);
CREATE INDEX idx_import_staged_session ON import_staged (session_id);
```

Both migrations end with their `schema_migrations` insert, and both tables go
into `db/schema.sql` as `IF NOT EXISTS` creates.

The staging table is catalog-agnostic — PRs 6 and 7 reuse it as-is.

## UI

`import.html` gains a **Spells** tab beside Classes and Skills. Given how the
skills importer shipped invisible, treat tab discoverability as part of the work,
not a follow-up.

The spell flow differs from skills by having a session shell around it:

1. **Sessions list** — open sessions with their catalog, book, and staged count;
   resume or start new.
2. **Inside a session** — submit a page range, watch it extract, and see results
   append to the staged list. Submit the next range without leaving.
3. **Review** — the full staged list with per-row action controls, filterable to
   just the duplicates. Bulk-set actions across the visible filter.
4. **Confirm** — applies staged rows in one batch, marks them confirmed, and
   leaves the session open for more ranges.

Autosave-on-parse is already the class importer's behaviour and is the point of
the staging table here: an extraction is persisted the instant it parses.

## Cost and timing note

Two skill pages yielded 33 skills in about 28 seconds. Spell entries are longer,
and a full stat block plus description is a much larger response per entry.
Expect a page range to be slower and to return fewer entries than the skill
importer did. Keep ranges small — one or two pages — and let the session
accumulate. `MAX_TOKENS_CEILING` in `_lib/claude-client.js` is 16000; a range
that hits the ceiling truncates, so the engine must detect a truncated or
unparseable response and report it rather than staging partial data.

## Acceptance

- Smoke test covers the skill import path and passes both before and after the
  engine extraction.
- A real skill import still works end to end after migration, with unchanged
  review behaviour.
- A spell session can be created, receive two separate page ranges, be closed in
  the browser, reopened, and confirmed.
- Extracted spells carry populated stat block fields, not just name/level/PPE.
- A spell already in the catalog prompts update / keep both / ignore, defaulting
  to ignore for a curated row.
- Two spells with the same name inside one confirm batch return a 409 conflict
  report rather than failing the whole run.
- A truncated model response is reported, not partially staged.
- Non-admin is refused.

## Out of scope

Psionic and gear importers — PRs 6 and 7, each a config on this engine. Editing
spells, which is PR 4. Rendering the new spell fields on the character sheet:
worth a follow-up, and explicitly not part of this PR.
