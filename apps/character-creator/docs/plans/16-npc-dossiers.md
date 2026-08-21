# PR 16 — NPC dossiers and portraits

> **Planned**, not built. Decisions taken in an interview on 2026-08-20.

## Problem

The people a campaign meets live in prose scattered across journal entries.
Three sessions later nobody can say who the merchant in Kingsdale was, whether
he is still alive, or what the party promised him.

## Decisions

### An NPC belongs to one campaign

Campaign-scoped, with structured fields: name, aliases, portrait, faction,
disposition toward the party, status (alive / dead / unknown / never met), a
short description, and an auto-maintained list of every entry that mentions
them. Structured because the fields are what make the roster filterable and
what make the [Ask endpoint](15-campaign-notes.md) able to answer *"who do we
trust in Kingsdale?"* without re-reading the prose.

Rejected: **global NPCs shared across campaigns** — right only if the campaigns
share a world, and it leaks what one table knows into another's dossier; and a
**single free-form prose block**, which is less to build and leaves nothing to
sort or filter by.

### Two ways in: mentions, and a sweep

**`@Name` in a note is the primary path** — deterministic, free, instant, and
under the writer's control. Typing `@` in the composer offers the campaign's
existing NPCs; accepting one links the entry to that dossier, and typing a name
nobody has used yet offers to create one.

**A Claude sweep is the safety net.** A button on the campaign page (any member
may press it) sends entries that have not been swept and asks for named people
nobody tagged. It returns **proposals**, and a proposal is not a dossier: a
human accepts, merges into an existing NPC, or dismisses it. Rejected: an
automatic scan on every note save (a model call per note, and it will confidently
turn *"the guard"* into a person until someone stops it); mention-only (nothing
is captured when the table forgets, which is every table); and manual-only
dossiers with the model merely enriching them.

**A dismissed proposal stays dismissed.** Without that, the next sweep proposes
the same non-person again and the button becomes noise.

**Mentions record how they were made.** `source` is `'mention'` or `'ai'`, so a
link a person typed is distinguishable from one a model inferred. Same instinct
as the `override: true` flag on out-of-category skill picks: a decision made by
software should be visible as one.

### Portraits go in R2, and R2 becomes site infrastructure

There is no R2 binding on the site today — `wrangler.jsonc` binds D1 and nothing
else. This PR adds one, and adds it as **shared site infrastructure** rather
than a character-creator private: MediaVault stores cover art as text today and
filament-forge already reads file bytes, so the second and third users exist.

Rejected: **base64 data URIs in D1** (D1 rows cap near 1 MB, the database is
shared with every other app on the site, and "thumbnails only" is a rule nobody
remembers in six months); and **external URLs** (nothing is behind the Access
wall, and the image breaks when the host does).

Uploads are served through a Pages Function that checks campaign membership —
**never a public bucket URL**. The whole site is behind Access and an
unauthenticated image endpoint would be the one hole in it.

## Schema

`db/migrations/027-npc-dossiers.sql`:

```sql
CREATE TABLE npcs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  campaign_id INTEGER NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  aliases TEXT,                          -- JSON array; also matched by the sweep
  faction TEXT,
  disposition TEXT,                      -- free text: 'hostile', 'owes us a favour'
  status TEXT NOT NULL DEFAULT 'unknown'
    CHECK (status IN ('alive', 'dead', 'unknown', 'never-met')),
  description TEXT,
  portrait_key TEXT,                     -- R2 object key; NULL = no portrait
  created_by TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX idx_npcs_campaign ON npcs (campaign_id);
CREATE UNIQUE INDEX idx_npcs_campaign_name ON npcs (campaign_id, name);

-- Which entries mention whom, and whether a person or a model said so.
CREATE TABLE npc_mentions (
  npc_id INTEGER NOT NULL REFERENCES npcs(id) ON DELETE CASCADE,
  journal_entry_id INTEGER NOT NULL REFERENCES journal_entries(id) ON DELETE CASCADE,
  source TEXT NOT NULL CHECK (source IN ('mention', 'ai')),
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  PRIMARY KEY (npc_id, journal_entry_id)
);
CREATE INDEX idx_npc_mentions_entry ON npc_mentions (journal_entry_id);

-- Sweep bookkeeping: what has been looked at, and what was rejected.
CREATE TABLE npc_sweeps (
  journal_entry_id INTEGER PRIMARY KEY REFERENCES journal_entries(id) ON DELETE CASCADE,
  swept_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE TABLE npc_proposals_dismissed (
  campaign_id INTEGER NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  dismissed_by TEXT NOT NULL,
  dismissed_at TEXT NOT NULL DEFAULT (datetime('now')),
  PRIMARY KEY (campaign_id, name)
);

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('027-npc-dossiers.sql');
```

Mirror into `db/schema.sql` with `IF NOT EXISTS` and the guarded seed line.

The unique index on `(campaign_id, name)` is what makes `@Kevik` resolve to one
dossier rather than three. Renaming an NPC whose new name is taken is a merge,
not an insert — the catalog's duplicate-merge machinery is the precedent, though
this case is small enough to handle directly.

`wrangler.jsonc` gains:

```jsonc
"r2_buckets": [
  { "binding": "MEDIA", "bucket_name": "nates-workshop-media" }
]
```

Named for the site, not the app, because the second user is coming. The bucket
must be created before the deploy that binds it, same discipline as a migration:
create it, then verify by listing it back rather than trusting an exit code.

## Work

**Mention parsing** — one shared function, `parseMentions(body)`, returning the
names an entry references. Called on POST and PATCH of a journal entry; it
reconciles `npc_mentions` for that entry (adds new, removes ones the edit
deleted) in the same batch as the write. Mentions are stored as plain `@Name`
text in the body, not as ids — the body stays readable text that survives a
rename, and resolution happens against the name index at write time.

**Sweep endpoint** `POST campaigns/[id]/npcs/sweep` — selects entries with no
`npc_sweeps` row, sends them to `_lib/claude-client.js` (directly, never via the
site's own `/api/claude` URL), asks for named individuals with a one-line
description and the entry each came from, filters out existing NPCs, existing
aliases and dismissed names, and returns proposals. Marks entries swept **only
after** a successful response, so a failed call is retried rather than skipped.
Follows the importer's review-step shape: nothing lands without confirmation.

**Portraits** — `POST npcs/[id]/portrait` accepts a single image, resized
client-side to a sane bound before upload, writes to R2 under
`npc/{campaign_id}/{npc_id}/{uuid}`, and stores the key. `GET` streams it back
through a membership check with a long `Cache-Control`, since the key changes
whenever the image does. Replacing a portrait deletes the old object.

**Dossier UI** on the campaign page from [PR 15](15-campaign-notes.md): a roster
filterable by status and faction, a dossier view with the fields, the portrait,
and the backlinked mentions in date order — which is the thing that actually
answers *"what do we know about him?"*.

**The Ask endpoint gains dossiers as context.** Already decided in PR 15; this
is where the data arrives.

## Depends on

[PR 15](15-campaign-notes.md), for the campaign page, the membership rule and
the Ask endpoint this extends.
