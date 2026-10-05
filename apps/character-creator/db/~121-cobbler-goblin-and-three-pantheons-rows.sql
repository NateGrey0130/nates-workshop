-- The Cobbler Goblin as a pick, and three held Pantheons rows given their page
-- and their printed figures.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~121-cobbler-goblin-and-three-pantheons-rows.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~121-cobbler-goblin-and-three-pantheons-rows.sql
--
-- Close-out package A12, the small corrections.
--
-- THREE GEAR ROWS (found while ~119's rows were checked against the pages).
-- daitya-magical-bracelets, enchanted-chain-mail-valkyrie and
-- valkyrie-magic-sword cited "Estimate - no published price found" and held
-- no figure. Rifts Conversion Book Two: Pantheons of the Megaverse prints all
-- three: the bracelets on printed 142 (levitate 30 feet, air-swim at swimming
-- speed), the mail (100 M.D.C.) and the sword (4D6 M.D.) on printed 168. Each
-- now cites its page and holds its figures. The book prints no price for any
-- of them, so the cost each row already holds stays, and cost_note says it is
-- an estimate. Read off renders by book-reconcile.
--
-- THE COBBLER GOBLIN (Rifts Conversion Book One printed 98-99) was one
-- natural ability the player applied by hand. It is now a pick-one group of
-- the page's two bands, 01-15 Cobbler and 16-00 ordinary. The Cobbler option
-- adds +1 to save vs all magic and +1 vs possession. Its P.P.E., its +3 vs
-- Horror Factor and its three skill bonuses stay by hand, for the reasons the
-- class note gives. The page's figures were re-read off a render: nothing in
-- the class disagreed.
--
-- Every write is guarded and a second run is a no-op.
-- THIS SCRIPT CHANGES PRODUCTION: three gear rows and one class row.

UPDATE gear
   SET source_book = 'Rifts Conversion Book Two: Pantheons of the Megaverse p.142',
       cost_note = 'Estimate: the book prints no price for it.',
       mdc = NULL, damage = NULL, is_mega_damage = 0,
       description = 'The pair of magical bracelets issued to elite Daitya warriors and to every Royal Daitya. The wearer can levitate up to 30 feet (9 m) and float off the ground on dry land, and can swim through the air at his normal underwater swimming speed.'
 WHERE slug = 'daitya-magical-bracelets'
   AND source_book = 'Estimate - no published price found';

UPDATE gear
   SET source_book = 'Rifts Conversion Book Two: Pantheons of the Megaverse p.168',
       cost_note = 'Estimate: the book prints no price for it.',
       mdc = 100, damage = NULL, is_mega_damage = 0,
       description = 'The suit of enchanted chain mail every Valkyrie is given: 100 M.D.C. Granted with the office, not bought.'
 WHERE slug = 'enchanted-chain-mail-valkyrie'
   AND source_book = 'Estimate - no published price found';

UPDATE gear
   SET source_book = 'Rifts Conversion Book Two: Pantheons of the Megaverse p.168',
       cost_note = 'Estimate: the book prints no price for it.',
       mdc = NULL, damage = '4D6 M.D.', is_mega_damage = 1,
       description = 'The magic sword every Valkyrie is given, doing 4D6 M.D. Granted with the office, not bought.'
 WHERE slug = 'valkyrie-magic-sword'
   AND source_book = 'Estimate - no published price found';

UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - name: "Cobbler Goblin (optional)"
    description: "A Goblin who keeps its Faerie Folk magic. Roll percentile: 1-15 makes the character a Cobbler (the text calls it a one in 20 mutant). A character with major or master psionics cannot be one. All other stats are the average Goblin''s, except: P.P.E. 3D4x10 +1D6 per level of experience instead of 6D6. (1) Metamorphosis at will into a small, dark animal no smaller than a toad - rat, toad, raven, black cat, weasel - at most once every two minutes, held as long as desired. (2) Faerie Magic: Mend Wood, Wither Plants, Sense Magic, Tongues, Charm and Darkness, each twice per 24 hours at third-level Wizard strength; they never improve with level, and a Cobbler can learn no other magic or read magic symbols. (3) +1 to save vs all magic, +1 vs possession, +3 vs Horror Factor, and +10% to carpentry, boat building and sculpting/whittling. Apply by hand."
restrictions:
',
         'special_abilities:
  - { choose: 1, from: ["Goblin (01-15): Cobbler", "Goblin (16-00): Ordinary Goblin"], note: "Printed 99: roll percentile, or pick one with the G.M.''s leave. A character with major or master psionics cannot be a Cobbler." }
  - name: "Goblin (16-00): Ordinary Goblin"
    description: "Roll 16-00. An ordinary Goblin, with none of the Faerie Folk''s magic."
  - name: "Goblin (01-15): Cobbler"
    description: "Roll 01-15 (the text on printed 98 calls the Cobbler a one in 20 mutant). A Goblin who keeps its Faerie Folk magic. All other stats are the average Goblin''s. (1) Metamorphosis at will into a small, dark animal no smaller than a toad - rat, toad, raven, black cat, weasel - at most once every two minutes, held as long as desired. (2) Faerie Magic: Mend Wood, Wither Plants, Sense Magic, Tongues, Charm and Darkness, each twice per 24 hours at third-level Wizard strength; they never improve with level, and a Cobbler can learn no other magic or read magic symbols. (3) +1 to save vs all magic and +1 vs possession, which this option adds. Apply by hand: P.P.E. 3D4x10 +1D6 per level of experience instead of 6D6; +3 to save vs Horror Factor (the page does not say whether it joins the Goblin''s own +2); and +10% to carpentry, boat building and sculpting/whittling."
    bonuses:
      saves: { spell_magic: 1, ritual_magic: 1, possession: 1 }
restrictions:
'),
       updated_at = datetime('now')
 WHERE class_id = 'rifts-goblin'
   AND instr(markdown, '  - name: "Cobbler Goblin (optional)"
    description: "A Goblin who keeps its Faerie Folk magic. Roll percentile: 1-15 ') > 0
   AND instr(markdown, 'ng and sculpting/whittling."
    bonuses:
      saves: { spell_magic: 1, ritual_magic: 1, possession: 1 }
restrictions:
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - THE COBBLER IS PROSE, NOT A VARIANT. The Palladium row''s note walks through why: a variant''s `bonuses` REPLACE the class''s rather than merging, so stating the Cobbler''s saves would drop the Goblin''s own; and five of its parts - metamorphosis, six spells, the percentile roll, the psionics bar and the +10% skill bonuses - are not variant-overridable at all. A variant carrying only the P.P.E. would look complete and hold nothing the book calls significant. So the Cobbler is one natural_abilities entry, and a player who rolls one applies it by hand.',
         '  - THE COBBLER IS A PICK SINCE ~121, not prose and not a variant. A variant''s `bonuses` replace the class''s, and a variant cannot carry the roll; an ability option can, so the two bands of printed 99 are a pick-one group under special_abilities. The Cobbler option adds what is unambiguous and has a key: +1 to save vs all magic (spell and ritual) and +1 vs possession. Three parts stay by hand and are in its description: the P.P.E. of 3D4x10 +1D6 per level, which REPLACES the Goblin''s 6D6 where a pool bonus could only add; the +3 vs Horror Factor, because the page does not say whether it joins the Goblin''s +2; and the three +10% skill bonuses. Its six Faerie spells are not a magic block: they are cast twice a day at a fixed third level, not from P.P.E., and Mend Wood has no catalog row.'),
       updated_at = datetime('now')
 WHERE class_id = 'rifts-goblin'
   AND instr(markdown, '  - THE COBBLER IS PROSE, NOT A VARIANT. The Palladium row''s note walks through why: a variant''s `bonuses` REPLACE the c') > 0
   AND instr(markdown, ' not a magic block: they are cast twice a day at a fixed third level, not from P.P.E., and Mend Wood has no catalog row.') = 0;

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'the three rows cite their page and hold their figures' AS assertion, count(*) AS got, 3 AS want
  FROM gear
 WHERE (slug = 'daitya-magical-bracelets' AND source_book LIKE '%Megaverse p.142' AND instr(description, '30 feet') > 0)
    OR (slug = 'enchanted-chain-mail-valkyrie' AND source_book LIKE '%Megaverse p.168' AND mdc = 100)
    OR (slug = 'valkyrie-magic-sword' AND source_book LIKE '%Megaverse p.168' AND damage = '4D6 M.D.' AND is_mega_damage = 1);

SELECT 'the goblin carries the two-band group and no longer the optional entry' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'rifts-goblin'
   AND instr(markdown, '- name: "Goblin (01-15): Cobbler"') > 0
   AND instr(markdown, 'Cobbler Goblin (optional)') = 0
   AND instr(markdown, 'THE COBBLER IS PROSE') = 0;

SELECT 'the class is exactly the length this script leaves it' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE (class_id = 'rifts-goblin' AND length(markdown) = 9622);

INSERT INTO data_script_runs (filename) VALUES ('~121-cobbler-goblin-and-three-pantheons-rows.sql');
