-- One row's variant_note: Underseas spells its own EMP spell THREE ways, and
-- add-underseas-spells.sql only knew about two of them.
--
-- One-off data cleanup, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzz-underseas-emp-third-spelling.sql
--
-- The spell chapter on printed 70 prints the name twice and differently:
--
--   Alphabetical Spell List (printed 70)   Electromagnetic Pulse
--   description heading (printed 70)       Electro-Magnetic Pulse
--
-- add-underseas-spells.sql stored the list spelling, because the alphabetical
-- list is the authority for membership, and recorded the heading in
-- variant_note. That was right and is unchanged.
--
-- THE THIRD SPELLING TURNED UP IN A CLASS, not in the spell chapter. The
-- Dolphin R.C.C. on printed 80 lists the ten dolphin spells again, as part of
-- its own spell-casting ability, and calls this one:
--
--   Electromagnetic BLAST
--
-- Not "Pulse". That is a fourth appearance of the same spell under a third
-- name, in a chapter ten pages away from the one that defines it, and it was
-- found only because the Dolphin R.C.C. import had to match its list against
-- the catalog row by row.
--
-- NOTHING IS RENAMED. The alphabetical list still wins - it is the authority
-- for what spells exist - and the row keeps the name every class references.
-- This adds the third reading to the note so the disagreement is on the record
-- rather than lost, which is the same handling the other two readings got.
--
-- Guarded on the new text being absent, so re-running is a no-op.

UPDATE spells
   SET variant_note = variant_note
     || ' The Dolphin R.C.C. on printed 80 lists it a THIRD way, as Electromagnetic BLAST, in its own spell-casting ability. The alphabetical list on printed 70 remains the authority and the row is not renamed; all three readings are recorded here.'
 WHERE name = 'Dolphin: Electromagnetic Pulse'
   AND variant_note IS NOT NULL
   AND instr(variant_note, 'Electromagnetic BLAST') = 0;

SELECT name, variant_note FROM spells WHERE name = 'Dolphin: Electromagnetic Pulse';

INSERT INTO data_script_runs (filename) VALUES ('zzzzz-underseas-emp-third-spelling.sql');
