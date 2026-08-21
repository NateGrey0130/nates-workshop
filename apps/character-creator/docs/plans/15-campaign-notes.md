# PR 15 — Campaign notes, search, and the party stash

> **Built.** Decisions taken in an interview on 2026-08-20; the **As built**
> notes below record what the plan did not survive contact with.

## Problem

`journal_entries` exists and works, but it is reachable only from a character
sheet and only the GM may write a campaign-level entry —
`campaignAccess()` sets `canWrite: email === row.gm_email` and nothing else.
There is no campaign-level place to read the log, no search over it, and nothing
tracks what the party holds collectively.

## Decisions

**As built: the membership query had a column that does not exist.** The plan
wrote `AND deleted_at IS NULL`. `characters` has no `deleted_at` — character
deletion is not a feature — so the query would have failed on every call, which
is to say nobody would have been a member of anything.

**As built: `campaigns.gm_notes` already existed and had to be defended.**
Widening `canWrite` from "the G.M." to "any member" silently widened the
campaign PATCH endpoint with it, because that endpoint checked `canWrite`. Any
player could then have edited the G.M.'s private notes — the one pre-existing
secret in an app the interview had just decided has no secrets. `campaignAccess`
now returns `isGm` separately and the PATCH checks that instead.

**As built: a question is not a search.** `toMatchQuery` AND-ed every term,
which is right for a search box that should narrow as you type and wrong for
the ask endpoint: *"what did the baron's men want, and do we still have the rune
sword?"* AND-ed together matches no entry ever written. The endpoint retrieved
nothing, handed the model an empty context, and got back a perfectly correct
"the notes do not record it" — a failure that looks exactly like a working
feature. It takes `{ join: 'OR' }` now and lets bm25 rank.

**As built: `snippet()` returns markup built from user input.** Asking FTS5 to
wrap matches in `<mark>` means the note text around them arrives as HTML, and a
client that escaped the result would escape the marks with it. The delimiters
are U+0001 and U+0002 — two characters no keyboard produces — and the page
escapes first, then swaps them for tags. Verified with a note containing a
literal `<script>` tag: it renders as text, and the page holds no script element.

**As built: the smoke test could not read "twenty-one".** Its number-word parser
had no hyphenated entries and the capture group stopped at the hyphen, so
`Twenty-one tables` read as one table and reported a documentation drift that
was really the test's own bug. Hyphenated compounds now sum their parts.

### Membership is implied by having a character

**No `campaign_members` table.** A person may read and write a campaign's notes
if they are its GM **or** they own a character assigned to it. That query
already has all the data it needs:

```sql
SELECT 1 FROM characters
 WHERE campaign_id = ? AND owner_email = ? AND deleted_at IS NULL
 LIMIT 1
```

Rejected: an explicit invite list, and a join code. Both were weighed and both
lose to the fact that membership is already expressed by the thing that makes
someone a player. The cost is real and accepted: a spectator, or a player
between characters, cannot post. When that bites, an invite list can be added
without changing anything below — `campaignAccess` is the single chokepoint.

### Everything in a campaign is visible to everyone in it

**No GM-only notes, no hidden dossier fields, no per-player reveals.** Decided
explicitly, not by omission. A GM keeping secrets keeps them outside the app.

This is load-bearing further down: it means the search index, the ask endpoint
and the NPC dossiers in [PR 16](16-npc-dossiers.md) need **no visibility
filtering at all** beyond "is this person in this campaign". Adding secrets
later means auditing every one of those paths, so the decision is worth
re-opening deliberately rather than drifting into.

### Notes stay free-form

Existing `title` / `body` / `session_date` are enough. No note types, no
required tags. Inline `@Name` mentions are the only structure, and they are
optional. Rejected: typed notes (a form to fill in at the table is a note not
written), and AI-suggested tags on every save.

### Search is free; asking costs a call

**Two mechanisms, one box.** Typing searches; a button asks.

- **Search** is SQLite **FTS5** over titles and bodies — instant, free, works as
  you type, returns highlighted snippets, filterable by author, date and NPC.
- **Ask** sends the top-ranked matching entries to Claude and returns a written
  answer **with citations back to the entries it used**. One deliberate click,
  one model call.

Rejected: keyword-only (cannot answer *"what did the baron want from us?"*,
which is the actual question people ask); and routing every query through the
model (slow and paid for what `LIKE` would have answered).

**What Ask may read:** the campaign's journal entries, its NPC dossiers, and its
party stash and ledger. **Not** the party's character sheets — decided
explicitly. Sheet questions are answered by looking at the sheet, and including
five full characters would dominate the prompt.

Server-side, this calls `_lib/claude-client.js` directly. It must never fetch
the site's own `/api/claude` URL — Access intercepts the subrequest and returns
the login page as HTML. Standing constraint, and this is a new caller of it.

### The party stash mirrors `character_items`

Same shape, same discipline: real gear catalog rows, freeform items allowed,
soft-deleted with `removed_at` rather than deleted, and each row tied to the
journal entry that explains it. Currency is a running balance with the same
append-only ledger behind it.

**An item can be claimed onto a sheet.** Claiming writes the stash row's
`removed_at` and inserts a `character_items` row **in one batch**, carrying the
link. Rejected: a stash with no transfers (two places to edit for one object,
and they drift within a session), and a free-form shared text block (no history
when someone deletes a line, which is exactly when history matters).

## Schema

`db/migrations/026-campaign-notes.sql`:

```sql
-- Full-text search over the journal. External-content FTS5 so the index
-- carries no copy of the text; journal_entries stays the only source.
CREATE VIRTUAL TABLE journal_fts USING fts5(
  title, body,
  content='journal_entries', content_rowid='id',
  tokenize='porter unicode61'
);

CREATE TRIGGER journal_fts_ai AFTER INSERT ON journal_entries BEGIN
  INSERT INTO journal_fts(rowid, title, body) VALUES (new.id, new.title, new.body);
END;
CREATE TRIGGER journal_fts_ad AFTER DELETE ON journal_entries BEGIN
  INSERT INTO journal_fts(journal_fts, rowid, title, body) VALUES ('delete', old.id, old.title, old.body);
END;
CREATE TRIGGER journal_fts_au AFTER UPDATE ON journal_entries BEGIN
  INSERT INTO journal_fts(journal_fts, rowid, title, body) VALUES ('delete', old.id, old.title, old.body);
  INSERT INTO journal_fts(rowid, title, body) VALUES (new.id, new.title, new.body);
END;

-- Backfill anything already written.
INSERT INTO journal_fts(rowid, title, body) SELECT id, title, body FROM journal_entries;

-- The party stash: character_items' shape, owned by a campaign.
CREATE TABLE campaign_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  campaign_id INTEGER NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
  item_id INTEGER REFERENCES gear(id),              -- NULL = freeform
  custom_name TEXT,
  qty INTEGER NOT NULL DEFAULT 1,
  notes TEXT,
  journal_entry_id INTEGER REFERENCES journal_entries(id) ON DELETE SET NULL,
  added_by TEXT NOT NULL,
  added_at TEXT NOT NULL DEFAULT (datetime('now')),
  removed_at TEXT,                                  -- NULL = still in the stash
  removed_by TEXT,
  claimed_by_character_id INTEGER REFERENCES characters(id) ON DELETE SET NULL,
  CHECK (item_id IS NOT NULL OR custom_name IS NOT NULL)
);
CREATE INDEX idx_campaign_items_campaign ON campaign_items (campaign_id);

-- Currency as a ledger, not a number. The balance is the sum.
CREATE TABLE campaign_currency (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  campaign_id INTEGER NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
  currency TEXT NOT NULL,                           -- 'credits', 'gold', …
  delta INTEGER NOT NULL,                           -- signed; never updated
  reason TEXT,
  journal_entry_id INTEGER REFERENCES journal_entries(id) ON DELETE SET NULL,
  created_by TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX idx_campaign_currency_campaign ON campaign_currency (campaign_id, currency);

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('026-campaign-notes.sql');
```

Mirror all of it into `db/schema.sql` with `IF NOT EXISTS`, plus the guarded
seed line the migration convention requires.

`currency` is free text rather than an enum because the two systems use
different coin and a campaign may track several at once. The balance is
`SUM(delta)` — a ledger with no stored total cannot disagree with itself.

## Work

**`_lib/auth.js`** — `campaignAccess` gains the implied-membership query.
Single chokepoint; nothing else learns the rule. `canWrite` becomes true for
members, and a separate `isGm` is returned for the few GM-only actions that
remain (renaming the campaign, deleting entries that are not yours).

**`functions/api/character-creator/journal.js`** — POST already derives
`campaign_id` server-side rather than trusting the client; that stays. The
GM-only branch for campaign-level entries relaxes to member-only. Add PATCH and
DELETE for an author editing their own entry (GM may delete any).

**New endpoints**

| | |
|---|---|
| `GET  campaigns/[id]/search?q=` | FTS5 `MATCH`, ranked, snippets, paged through `_lib/paging.js` |
| `POST campaigns/[id]/ask` | top matches + dossiers + stash → `claude-client.js` → answer with cited entry ids |
| `GET/POST campaigns/[id]/items` | the stash |
| `POST campaigns/[id]/items/[itemId]/claim` | batch: set `removed_at`, insert `character_items` |
| `GET/POST campaigns/[id]/currency` | ledger append + computed balances |

**New page** `campaign.html` / `campaign.js` — the campaign's own view, which
does not exist today: the note feed with a composer, the search box with the
Ask button beside it, the party stash and the currency panel. Follows the app
convention — `index.html` + `styles.css` + `app.js` shape, `/shared/js/ui.js`
for `escHtml` and `openModal`, no dependencies, no build step.

**The sheet's journal panel stays.** It keeps calling `journal.js` with
`include_campaign=1` exactly as now; the new page is an addition, not a move.

## Rejected, recorded so it is not re-added

- A `campaign_members` table (implied membership covers the real cases).
- GM-private notes and per-player reveals.
- Vector search / embeddings for the Ask path. FTS5 retrieval over one
  campaign's notes is a small enough corpus that ranked keyword matching is
  adequate context, and embeddings would add a store, a backfill and a
  re-embed-on-edit path for a retrieval problem that is not yet hard.
- A stored currency total alongside the ledger.

## Depends on

Nothing. [PR 16](16-npc-dossiers.md) depends on this.
