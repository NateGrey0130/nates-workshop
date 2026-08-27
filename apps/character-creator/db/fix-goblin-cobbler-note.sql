-- The Goblin's note about the Cobbler sub-race, corrected. Palladium Fantasy
-- RPG Main Book, printed p.300 (cache pf p302 - the pf cache runs printed+2,
-- established by F18).
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-goblin-cobbler-note.sql
--
-- CLASS-AUDIT.md S8. NOTE REWRITE ONLY - no mechanical data is touched, and
-- the Cobbler is still not imported.
--
-- The stored note says the Cobbler "is NOT expressible as a `variants` entry".
-- That was true when it was written and is now half false: VARIANT_OVERRIDES
-- has since grown, and the Cobbler's P.P.E. (3D4x10 plus 1D6 per level) and
-- its three save bonuses would fit a variant today. Two lesser errors ride
-- along with it - the page is printed 300, not 302, and the list of what
-- VARIANT_OVERRIDES admits omits `hit_points_base` and `starting_money`.
--
-- WHY THE ANSWER IS STILL NOT "BUILD IT", which is the part the note has to
-- carry so the next reader does not re-open this: five of the Cobbler's seven
-- parts remain inexpressible on a variant -
--
--   1. metamorphosis at will          natural_abilities, not a variant key
--   2. six faerie spells, 2/24hrs     a magic block, not a variant key
--   3. the 1-15 percentile roll       no field anywhere
--   4. no major/master psionics       psionics_allowed is class-level
--   5. +10% carpentry / boat building / sculpting - `skill_overrides` may
--      only restate a skill the class ALREADY GRANTS, and this R.C.C. grants
--      none at all. That is the same missing per-skill modifier the audit's
--      "checked and still true" list records for the changeling, the gnome
--      and the kobold.
--
-- Modelling the two that fit would buy a Cobbler carrying a mage's P.P.E.
-- with no spells to spend it on and no metamorphosis: a sub-race that looks
-- complete and holds nothing the book calls significant. That is the same
-- reasoning S7 was declined on.
--
-- One trap the note now records, because it would bite whoever tries: a
-- variant's `bonuses` REPLACE the class's rather than merging (VARIANT_MERGED
-- covers only attribute_dice and attribute_requirements), so a Cobbler
-- variant that stated its own three saves would silently drop the goblin's
-- +1 vs faerie magic and its S.D.C. pool bonus.
--
-- Guarded on the old text; re-running is a no-op once it is gone. Both
-- bullets are stored as single long lines, so no wrap-matching is needed
-- here - unlike the ley line walker's note in the sibling S3 script.

-- 1. The P.P.E. bullet, which pointed at "a sub-race the app cannot express".
UPDATE imported_classes
   SET markdown = replace(
         markdown,
         '6D6 is stored; the Cobbler figure belongs to a sub-race the app cannot express - see below.',
         '6D6 is stored; the Cobbler figure belongs to a sub-race that is still not imported - see below.'),
       updated_at = datetime('now')
 WHERE class_id = 'goblin'
   AND instr(markdown, 'a sub-race the app cannot express - see below.') > 0;

-- 2. The NOT IMPORTED bullet itself.
UPDATE imported_classes
   SET markdown = replace(
         markdown,
         '  - NOT IMPORTED - THE GOBLIN COBBLER, printed 302, an "Optional R.C.C." A goblin is a Cobbler on a percentile roll of 1-15. A Cobbler has metamorphosis at will into a small dark animal, six faerie spells cast twice per 24 hours at third-level strength (mend wood, wither plants, sense magic, tongues, charm, darkness), +1 to save vs all magic, +1 vs possession, +3 vs horror factor, and +10% to carpentry, boat building and sculpting/whittling. All other stats are the average goblin''s, and a character with major or master psionic powers cannot be a Cobbler. It is NOT expressible as a `variants` entry: VARIANT_OVERRIDES admits only attribute_dice, attribute_requirements, the pool bases, bonuses and skill_overrides, and the Cobbler''s whole substance is a magic block and an abilities block. Modelling it needs either a widened variant or a second class, and that is a decision rather than a transcription.',
         '  - NOT IMPORTED - THE GOBLIN COBBLER, printed 300, an "Optional R.C.C." A goblin is a Cobbler on a percentile roll of 1-15. A Cobbler has metamorphosis at will into a small dark animal, six faerie spells cast twice per 24 hours at third-level strength (mend wood, wither plants, sense magic, tongues, charm, darkness) which never improve with experience, +1 to save vs all magic, +1 vs possession, +3 vs horror factor, and +10% to carpentry, boat building and sculpting/whittling. All other stats are the average goblin''s, and a character with major or master psionic powers cannot be a Cobbler. An earlier version of this note said it was NOT expressible as a `variants` entry at all; that is now half false, which is class audit S8. VARIANT_OVERRIDES admits attribute_dice, attribute_requirements, hit_points_base, sdc_base, mdc_base, ppe_base, starting_money, bonuses and skill_overrides, so the Cobbler''s 3D4x10+1D6/level P.P.E. and its three save bonuses WOULD fit a variant today. Five of its seven parts still would not: metamorphosis (natural_abilities), the six spells (a magic block), the 1-15 percentile roll, the major/master psionic exclusion (psionics_allowed is class-level), and the +10% skill bonuses - skill_overrides may only restate a skill the class already grants and this R.C.C. grants none, the same missing per-skill modifier that blocks the changeling, the gnome and the kobold. Modelling only the two that fit would buy a Cobbler with a mage''s P.P.E., no spells to spend it on and no metamorphosis: a sub-race that looks complete and holds nothing the book calls significant. A second trap for whoever tries it - a variant''s bonuses REPLACE the class''s rather than merging, so stating the Cobbler''s three saves would silently drop the goblin''s +1 vs faerie magic and its S.D.C. pool bonus. The honest route is a second class, goblin-cobbler, which can carry the abilities and the magic block; that is a decision rather than a transcription, and it has not been made.'),
       updated_at = datetime('now')
 WHERE class_id = 'goblin'
   AND instr(markdown, 'THE GOBLIN COBBLER, printed 302') > 0;

-- Readback. Expected: page_fixed 1, stale_claim_gone 1, new_note 1,
-- ppe_bullet 1, data_intact 1, has_cr 0.
--
-- `data_intact` is the one that earns its place: this script must not have
-- touched a mechanic, and the goblin's own P.P.E. and bonuses line are what
-- a careless replace of a note ABOUT them would have hit.
SELECT (instr(markdown, 'THE GOBLIN COBBLER, printed 300') > 0)                  AS page_fixed,
       (instr(markdown, 'It is NOT expressible as a') = 0)                       AS stale_claim_gone,
       (instr(markdown, 'WOULD fit a variant today') > 0)                        AS new_note,
       (instr(markdown, 'a sub-race that is still not imported') > 0)            AS ppe_bullet,
       (instr(markdown, char(10) || 'ppe_base: "6d6"' || char(10)) > 0)
     * (instr(markdown, 'saves: { faerie_magic: 1, horror_factor: 2 }') > 0)     AS data_intact,
       (instr(markdown, char(13)) > 0)                                           AS has_cr
  FROM imported_classes WHERE class_id = 'goblin';

-- Records this run. Both statements guard themselves, so this is safe to
-- re-run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-goblin-cobbler-note.sql');
