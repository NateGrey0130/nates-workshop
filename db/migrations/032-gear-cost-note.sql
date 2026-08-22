-- What a gear cost does not fit in one integer.
--
-- RUE prices much of its common gear as a RANGE - "Belt, Utility (military
-- style): 3-5 cr.", "Knife, Large (does 1D6 S.D.C. damage): 20-100 cr." - and
-- some entries qualify the number instead of bounding it: "double for gold".
--
-- `cost` held one integer and the rest was lost at import. That is not a
-- cosmetic loss. The equipment import stored the HIGH end of every range it met
-- while the catalog's own rows were at the LOW end, and because nothing
-- recorded that a choice had been made, the inconsistency was invisible until
-- somebody re-read the page: Knife, Small (15-75) came out dearer than Knife,
-- Large (20-100), and three rows were nearly "corrected" to prices the book
-- already agreed with at the other end of a range.
--
-- Same shape as the two columns that already solve this. spells.ppe_note and
-- psionic_powers.isp_note each carry a variable cost's schedule in a few words
-- while the numeric column holds the MINIMUM, which is what the sheet spends.
-- `cost` keeps that role - the low end, the number arithmetic uses - and
-- cost_note carries the range or the qualifier verbatim.

ALTER TABLE gear ADD COLUMN cost_note TEXT;

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('032-gear-cost-note.sql');
