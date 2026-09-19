-- A psionic power's I.S.P. price where one GAME prints a different one.
--
-- BOOK-INGEST-AUDIT.md F102, option A - the psionic half. `psionic_powers`
-- holds one `isp` per power and had no per-game home for another. Hypnotic
-- Suggestion is the case that found it: 6 I.S.P. in the catalog (Rifts Ultimate
-- Edition, filed under Super), 2 in Heroes Unlimited (printed 133), and in
-- Nightbane 2 as a Sensitive power (printed 77) and 4 as a Healer one (printed
-- 84). Death Trance is the second: Nightbane prints it at 2 as a Sensitive
-- power (printed 72) against the catalog's 1, which Nightbane's Physical entry
-- agrees with (printed 78).
--
-- A SIBLING OF skill_system_bases (migration 061), on purpose, and not a
-- second row per game. A second `Hypnotic Suggestion` would split the one name
-- every one of those books prints, and `psionic_powers.name` is UNIQUE, so it
-- would need a name no book uses. Same shape, same reasons: keyed on the NAME
-- because `psionic_powers.id` is insertion order and differs per environment,
-- and ON UPDATE CASCADE so a catalog rename carries the price with it.
--
-- `isp` AND `isp_note` MEAN WHAT THEY MEAN ON psionic_powers. `isp` is the
-- minimum, which is what the sheet's use button spends; `isp_note` is the
-- variable schedule in a few words, and its presence is what tells the wizard
-- the cost varies (migration 020). That is how a book printing two prices for
-- one power in one game is stored: the lower as `isp`, the other in the note.
-- NULL in either column means "the catalog's own", per column, and the CHECK
-- refuses a row that says nothing.

CREATE TABLE IF NOT EXISTS psionic_system_costs (
  power_name TEXT NOT NULL
    REFERENCES psionic_powers(name) ON DELETE CASCADE ON UPDATE CASCADE,
  system TEXT NOT NULL
    CHECK (system IN ('rifts', 'palladium-fantasy', 'nightbane', 'heroes-unlimited')),
  isp INTEGER,                            -- NULL = this game charges the catalog's price
  isp_note TEXT,                          -- NULL = same
  note TEXT,                              -- why it differs, or what else the page says
  source_book TEXT,                       -- the book and page the price came from
  CHECK (isp IS NOT NULL OR isp_note IS NOT NULL),
  PRIMARY KEY (power_name, system)
);

-- Every reader loads one system's whole set at once, as skill_system_bases' do.
CREATE INDEX IF NOT EXISTS idx_psionic_system_costs_system
  ON psionic_system_costs(system);

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('076-psionic-system-costs.sql');
