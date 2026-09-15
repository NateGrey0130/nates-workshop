-- Nightbane Talents: the ninth catalog, and the first power here that costs
-- something to HAVE as well as something to USE.
--
-- BOOK-INGEST-AUDIT F76. A Talent states a permanent P.P.E. price paid once to
-- acquire it for life, and a second P.P.E. price every time it is activated.
-- Neither `spells` nor `psionic_powers` can hold both: each has exactly one
-- integer cost column, and a Talent stored in either loses a number.
--
-- WHY A TABLE RATHER THAN TWO COLUMNS ON `spells`, which was F76's option A:
-- a Talent is not a spell. It cannot be taught or learned, it is never cast
-- from a list, it is gated on the character's FORM rather than on a tradition,
-- and every spell row would gain columns no spell will ever use. Same argument
-- migration 057 made for `super_abilities`, and the same answer.
--
-- ===================================================================
-- WHAT THE BOOK ACTUALLY PRINTS, because F76 described it wrongly
-- ===================================================================
--
-- Counted off the cache on 2026-09-15, printed 106-115 (`nightbane-core`,
-- page_offset +1, so cache p107-p116): 25 Talents, 25 `Cost:` lines and 25
-- `Limitations:` lines, one of each per Talent.
--
-- F76 SAYS "TWO COST COLUMNS" AND THAT IS WRONG. Only THREE of the 25 are a
-- clean acquire/activate pair - Anti-Arcane 15/20, Mirror Sight 5/2, Soul
-- Shield 6/4. The other 22 carry a third term, in four shapes:
--
--   a per-unit rate  "15 to activate, plus 15 P.P.E. for each additional
--                     minute the borrowed Morphus is kept"
--   an upgrade       "+5 P.P.E. per additional 10 miles"
--   a non-P.P.E.     "8 to activate plus it inflicts 1D6 S.D.C. points of
--                     damage on the user"
--   no integer       "20 P.P.E. to acquire it permanently; P.P.E. cost varies
--                     as described above"  (two Talents read like this)
--
-- So the shape is NOT cost + cost. It is acquire + activation-minimum + the
-- schedule in words, which is what `spells` and `psionic_powers` already do
-- with `ppe`/`ppe_note` and `isp`/`isp_note` - a pair F76 never weighs, and
-- which production uses on 143 spells and 21 psionic powers. `ppe` here means
-- exactly what it means there: the MINIMUM, which is what a use button spends.
--
-- FORM IS NOT A BOOLEAN. F76 says "most work only in the Morphus form". Counted
-- the same day off the 25 `Limitations:` blocks: morphus 22, facade 1
-- (Reshape Facade), both 1 (Mirror Sight), and ONE that states no form at all -
-- its whole Limitations line is a range. A `morphus_only` flag would have to
-- invent an answer for three rows out of 25, so this is free text with NULL
-- meaning the book does not say.
--
-- THE LEVEL GATE IS AN INTEGER BECAUSE THE BOOK IS NOT. Ten of the 25 are gated
-- on character level, written six different ways across those ten lines -
-- `3rd level`, `5th level`, `6th level`, `fifth level`, `fourth level`,
-- `third level`. Storing the prose would make every consumer re-parse it.
--
-- FIVE CARRY A PREREQUISITE, which F76 does not mention at all. Four are the
-- Elite Talents, gated on a Morphus characteristic ("At least one
-- biomechanical characteristic"), and one is a Talent gated on ANOTHER Talent -
-- Mirror Search requires Mirror Sight. Free text, because those two kinds do
-- not share a referent and a foreign key could express only the second.
--
-- NO `damage` COLUMN, deliberately, though `super_abilities` has one. No Talent
-- prints a flat damage: Shadow Blast does 1D4 S.D.C. per P.P.E. spent and
-- Bloodbath's 1D6 is dealt to the USER. Both are a function of the cost rather
-- than a number, so the column would hold a formula nothing parses. It can be
-- added later if a Nightbane sourcebook prints one.
--
-- NO CHECK ON `system`, matching `spells`, `psionic_powers` and
-- `super_abilities`, which all leave it free text with a comment. F76 depends
-- on F73, and F73's blocking half shipped in #1037 (migrations 058-060) - but
-- what that widened was the CHECK on `campaigns`, `gear` and `vehicles`, none
-- of which this table has. A new CHECK here would re-create the problem F73
-- was filed about.

CREATE TABLE IF NOT EXISTS talents (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  tier TEXT,                              -- common | elite; NULL = the book does not say
  -- The permanent price, paid once, for life. Every one of the 25 states a flat
  -- integer, which is why this is the only cost column that is NOT NULL.
  acquire_ppe INTEGER NOT NULL DEFAULT 0,
  -- The activation MINIMUM, and 0 means "varies, see the note" - the two
  -- Talents whose activation the book declines to fix. Same meaning `ppe` has
  -- on `spells`; see migration 021.
  ppe INTEGER NOT NULL DEFAULT 0,
  ppe_note TEXT,                          -- the activation schedule in a few words:
                                          -- the per-minute rate, the upgrade, the
                                          -- S.D.C. the user pays. 22 of 25 need one.
  min_character_level INTEGER,            -- NULL = no level gate. 10 of 25 have one
  form_required TEXT,                     -- morphus | facade | both; NULL = not stated
  prerequisite TEXT,                      -- another Talent, or a Morphus characteristic
  source TEXT NOT NULL DEFAULT 'seed',
  source_book TEXT,
  system TEXT,                            -- NULL = unrestricted, as everywhere else
  -- Field names match `spells`, `psionic_powers` and `super_abilities` on
  -- purpose, so the sheet renders all four the same way.
  range TEXT,
  duration TEXT,
  saving_throw TEXT,
  description TEXT,
  variant_note TEXT                       -- what a different book prints instead
);

CREATE INDEX IF NOT EXISTS idx_talents_tier ON talents (tier);

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('063-talents.sql');
