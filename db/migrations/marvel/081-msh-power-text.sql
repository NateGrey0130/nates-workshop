-- 081: msh_power_text - the full text of the Ultimate Powers Book's power
-- listings, for Marvel Heroes (apps/marvel-heroes).
--
-- THE ROWS ARE NEVER IN THIS REPOSITORY. The repo is public and the text is
-- TSR's, so the app's committed data (apps/marvel-heroes/data/powers.json)
-- carries mechanics and a one-line summary written for the app, and the book's
-- own text lives only here. scripts/msh-extract.py builds the data script into
-- the gitignored .cache/msh/ from the PDF, and d1-apply loads it from there.
-- A database built from the repo therefore has this table EMPTY, and the app
-- is written for that: the power browser falls back to the summary.
--
-- `code` is the power's code as the roll tables give it (D1, MCo3), or a bare
-- class code (MG) for a section's own introduction. `page` is the printed page.
-- The msh_ prefix is the collision boundary: this is another app's table.
CREATE TABLE IF NOT EXISTS msh_power_text (
  code TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  page INTEGER,
  body TEXT NOT NULL
);

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('081-msh-power-text.sql');
