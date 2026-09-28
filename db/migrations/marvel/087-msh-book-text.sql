-- 087: msh_book_text - the prose of the Marvel sourcebooks' character entries
-- (MA1 Children of the Atom first), for the Marvel codex's Notable NPCs and the
-- GM tools.
--
-- THE ROWS ARE NEVER IN THIS REPOSITORY, for the reason migration 081 gives:
-- the repo is public and the text is TSR's. The numbers, rank codes, power names
-- and page citations are committed (apps/marvel-heroes/data/); every sentence of
-- the book's own text - a power's description, talents, contacts, the "Running"
-- notes - lives only here. scripts/msh/roster.py parses the local OCR cache and
-- the data script is written into the gitignored .cache/msh/, loaded with
-- d1-apply --db marvel. A database built from the repo has this table EMPTY, and
-- the codex shows the committed facts without the prose.
--
-- One row per piece of an entry, so a card fetches all of one entry at once:
--   key    '<book>:<entry>:<part>[:<n>]', unique ('ma1:nightcrawler:power:1')
--   book   the registry slug (scripts/msh/books.json)
--   entry  the entry's slug, as the committed data names it
--   part   power | talents | contacts | running | background | notes | member | prose
--   name   the power's or member's printed name, when the part has one
--   page   the printed page the piece starts on
--   body   the text, folded to ASCII
CREATE TABLE IF NOT EXISTS msh_book_text (
  key TEXT PRIMARY KEY,
  book TEXT NOT NULL,
  entry TEXT NOT NULL,
  part TEXT NOT NULL,
  name TEXT,
  page INTEGER,
  body TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_msh_book_text_entry ON msh_book_text (book, entry);

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('087-msh-book-text.sql');
