-- Where an older book prints a different number, and the newer one wins.
--
-- The catalog now draws on three books that overlap heavily: Rifts Ultimate
-- Edition (2005), the Rifts Book of Magic, and the Palladium Fantasy main book
-- (1983). Where two of them state the same spell or power differently, the
-- LATER book is authoritative - RUE over the Book of Magic, either over
-- Palladium Fantasy - and that rule already proved itself before it was
-- written down: the only two psionic costs Palladium disagrees with are
-- Commune with Spirit and Sense Dimensional Anomaly, which are exactly the two
-- RUE corrected earlier.
--
-- The losing number is still worth keeping. A GM running Palladium Fantasy
-- wants to know the book at their elbow says 10 P.P.E. where the sheet says 7.
--
-- WHY NOT ppe_note / isp_note, which look like the obvious home: they are not
-- free-text. The wizard renders
--
--     `${sp.ppe}${sp.ppe_note && sp.ppe > 0 ? '+' : ''} P.P.E.`
--
-- so the mere PRESENCE of ppe_note turns a cost into "7+ P.P.E." - it means
-- "this cost varies". Recording a cross-book difference there would make
-- fourteen fixed-cost spells display as variable ones. The column already has
-- a meaning; this needs its own.
--
-- `skills` needs no such column: its `note` is plain display text already
-- carrying things like "40%/30% climb/rappel".

ALTER TABLE spells ADD COLUMN variant_note TEXT;
ALTER TABLE psionic_powers ADD COLUMN variant_note TEXT;

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('033-variant-note.sql');
