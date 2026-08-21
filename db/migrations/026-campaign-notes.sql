-- Campaign notes: full-text search, the party stash, and the currency ledger.
--
-- Nothing here changes who owns what. Membership is not a table: a person may
-- read and write a campaign's notes if they are its G.M. or they own a
-- character assigned to it, which the `characters` row already says. See
-- `campaignAccess` in functions/api/character-creator/_lib/auth.js.

-- ---------------------------------------------------------------------------
-- Full-text search over the journal.
--
-- External-content FTS5: the index carries no copy of the text, so
-- journal_entries stays the single source and the two cannot disagree about
-- what an entry says. The cost is that the triggers below are mandatory -
-- an external-content table does not notice writes on its own.
CREATE VIRTUAL TABLE IF NOT EXISTS journal_fts USING fts5(
  title, body,
  content='journal_entries', content_rowid='id',
  tokenize='porter unicode61'
);

-- Porter stemming so "negotiated" finds "negotiate", and unicode61 so a name
-- with an accent is still one token.

CREATE TRIGGER IF NOT EXISTS journal_fts_ai AFTER INSERT ON journal_entries BEGIN
  INSERT INTO journal_fts(rowid, title, body) VALUES (new.id, new.title, new.body);
END;

-- 'delete' is not a typo: an external-content FTS5 table is told about a
-- removal by inserting a delete command row carrying the OLD values, because
-- it has no copy of them to look up.
CREATE TRIGGER IF NOT EXISTS journal_fts_ad AFTER DELETE ON journal_entries BEGIN
  INSERT INTO journal_fts(journal_fts, rowid, title, body)
  VALUES ('delete', old.id, old.title, old.body);
END;

CREATE TRIGGER IF NOT EXISTS journal_fts_au AFTER UPDATE ON journal_entries BEGIN
  INSERT INTO journal_fts(journal_fts, rowid, title, body)
  VALUES ('delete', old.id, old.title, old.body);
  INSERT INTO journal_fts(rowid, title, body) VALUES (new.id, new.title, new.body);
END;

-- Everything already written. Safe to re-run: the rebuild command discards the
-- index and reads journal_entries again, so a partially-populated index from an
-- interrupted run does not produce duplicates.
INSERT INTO journal_fts(journal_fts) VALUES ('rebuild');

-- ---------------------------------------------------------------------------
-- The party stash: character_items' shape, owned by a campaign rather than a
-- character. Same discipline - real gear catalog rows, freeform items allowed,
-- soft-deleted rather than deleted, and tied to the journal entry that explains
-- how the party came by it.
CREATE TABLE IF NOT EXISTS campaign_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  campaign_id INTEGER NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
  item_id INTEGER REFERENCES gear(id),              -- NULL = freeform custom item
  custom_name TEXT,                                 -- required for freeform items
  qty INTEGER NOT NULL DEFAULT 1,
  notes TEXT,
  journal_entry_id INTEGER REFERENCES journal_entries(id) ON DELETE SET NULL,
  added_by TEXT NOT NULL,
  added_at TEXT NOT NULL DEFAULT (datetime('now')),
  removed_at TEXT,                                  -- NULL = still in the stash
  removed_by TEXT,
  -- Set when the row left the stash for someone's sheet, as opposed to being
  -- spent, lost or given away. The claim and the character_items insert happen
  -- in one batch, so this never points at a row that was not created.
  claimed_by_character_id INTEGER REFERENCES characters(id) ON DELETE SET NULL,
  CHECK (item_id IS NOT NULL OR custom_name IS NOT NULL)
);
CREATE INDEX IF NOT EXISTS idx_campaign_items_campaign ON campaign_items (campaign_id);

-- ---------------------------------------------------------------------------
-- Party currency as a LEDGER, not a number.
--
-- The balance is SUM(delta), so there is no stored total that can disagree with
-- its own history, and "where did the 4,000 credits go" is answerable. Rows are
-- appended and never updated.
--
-- `currency` is free text rather than an enum: the two systems use different
-- coin, a campaign may track several at once, and a party that wants to track
-- "favours owed" in the same ledger is not doing anything wrong.
CREATE TABLE IF NOT EXISTS campaign_currency (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  campaign_id INTEGER NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
  currency TEXT NOT NULL,
  delta INTEGER NOT NULL,                           -- signed; positive is income
  reason TEXT,
  journal_entry_id INTEGER REFERENCES journal_entries(id) ON DELETE SET NULL,
  created_by TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_campaign_currency_campaign
  ON campaign_currency (campaign_id, currency);

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('026-campaign-notes.sql');
