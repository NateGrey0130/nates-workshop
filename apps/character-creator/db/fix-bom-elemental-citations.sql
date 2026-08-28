-- The Book of Magic's elemental spells, cited by the page they are printed on.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-bom-elemental-citations.sql
--
-- INGESTION-AUDIT F24. 231 spells carried 'Rifts Book of Magic p.71-72', which is not an
-- index or a table: printed 71-72 is Earth Warlock levels Six and Seven, about
-- eight spells. The 231 are the four elemental lists entire - Air 65, Earth 62,
-- Water 52, Fire 52 - so a range covering part of ONE element's TWO levels was
-- stamped on all four.
--
-- Pages come from two independent readings: the definition's own page inside
-- the element's block, and the book's master index (Index of Rifts Magic,
-- printed 348-352). The index alone does not settle it - 71 of these names are
-- printed twice, once in a Warlock list and once in the general invocations -
-- and the block alone gives no page. Together: 222 exact pages.
--
-- The remaining 9 take their element's range, which is true but less
-- precise: the book spells those names differently from the catalog.
--
-- Every statement guards on the WRONG value, so this is a no-op on a row that
-- has already been corrected and cannot clobber a better citation. Sorts after
-- add-elemental-spells.sql, which is the file that wrote the stamp.


UPDATE spells SET source_book = 'Rifts Book of Magic p.59'
  WHERE name = 'Air: Air Bubble' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.57-66'
  WHERE name = 'Air: Atmospheric Manipulation' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.60'
  WHERE name = 'Air: Ball Lightning' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.62'
  WHERE name = 'Air: Breath of Life' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.57'
  WHERE name = 'Air: Breathe Without Air' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.59'
  WHERE name = 'Air: Call Lightning' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.60'
  WHERE name = 'Air: Calm Storms' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.57'
  WHERE name = 'Air: Change Wind Direction' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.62'
  WHERE name = 'Air: Circle of Rain' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.57'
  WHERE name = 'Air: Cloak of Darkness' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.57'
  WHERE name = 'Air: Cloud of Slumber' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.57'
  WHERE name = 'Air: Cloud of Steam' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.57'
  WHERE name = 'Air: Create Air' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.57'
  WHERE name = 'Air: Create Light' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.57'
  WHERE name = 'Air: Create Mild Wind' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.65'
  WHERE name = 'Air: Creature of the Wind' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.62'
  WHERE name = 'Air: Darken the Sky' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.59'
  WHERE name = 'Air: Darkness' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.62'
  WHERE name = 'Air: Detect the Invisible' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.61'
  WHERE name = 'Air: Dissipate Gases' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.57'
  WHERE name = 'Air: Distant Voice' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.58'
  WHERE name = 'Air: Electric Arc' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.63'
  WHERE name = 'Air: Electrical Field' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.63'
  WHERE name = 'Air: Electro-Magnetism' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.59'
  WHERE name = 'Air: Fingers of the Wind' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.59'
  WHERE name = 'Air: Float in Air' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.61'
  WHERE name = 'Air: Freeze Water' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.59'
  WHERE name = 'Air: Frequency Jamming' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.59'
  WHERE name = 'Air: Frostblade' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.58'
  WHERE name = 'Air: Heavy Breathing' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.58'
  WHERE name = 'Air: Howling Wind' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.64'
  WHERE name = 'Air: Hurricane' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.61'
  WHERE name = 'Air: Invisibility' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.62'
  WHERE name = 'Air: Invisible Wall' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.61'
  WHERE name = 'Air: Leaf Rustler' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.58'
  WHERE name = 'Air: Levitate' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.61'
  WHERE name = 'Air: Lightblade' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.61'
  WHERE name = 'Air: Lightning Arc' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.58'
  WHERE name = 'Air: Mesmerism' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.58'
  WHERE name = 'Air: Miasma' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.64'
  WHERE name = 'Air: Mist of Death' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.59'
  WHERE name = 'Air: Northern Lights' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.58'
  WHERE name = 'Air: Northwind' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.59'
  WHERE name = 'Air: Orb of Cold' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.62'
  WHERE name = 'Air: Phantom' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.62'
  WHERE name = 'Air: Phantom Footman' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.63'
  WHERE name = 'Air: Phantom Mount' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.62'
  WHERE name = 'Air: Protection from Lightning' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.65'
  WHERE name = 'Air: Rainbow' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.60'
  WHERE name = 'Air: Resist Cold' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.60'
  WHERE name = 'Air: Sheltering Force' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.59'
  WHERE name = 'Air: Silence' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.64'
  WHERE name = 'Air: Snow Storm' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.63'
  WHERE name = 'Air: Sonic Blast' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.57'
  WHERE name = 'Air: Stop Wind' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.57-66'
  WHERE name = 'Air: Thunderclap' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.65'
  WHERE name = 'Air: Tornado' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.64'
  WHERE name = 'Air: Vacuum' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.60'
  WHERE name = 'Air: Walk the Wind' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.60'
  WHERE name = 'Air: Wave of Frost' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.63'
  WHERE name = 'Air: Whirlwind' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.64'
  WHERE name = 'Air: Whisper of the Wind' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.65'
  WHERE name = 'Air: Wind Blast' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.65'
  WHERE name = 'Air: Wind Cushion' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.60'
  WHERE name = 'Air: Wind Rush' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.69'
  WHERE name = 'Earth: Animate Object' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.68'
  WHERE name = 'Earth: Animate Plants' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.73'
  WHERE name = 'Earth: Cap Volcano' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.67'
  WHERE name = 'Earth: Chameleon' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.70'
  WHERE name = 'Earth: Chasm' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.71'
  WHERE name = 'Earth: Clay or Stone to Iron' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.70'
  WHERE name = 'Earth: Clay to Lead' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.70'
  WHERE name = 'Earth: Clay to Stone' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.71'
  WHERE name = 'Earth: Close Fissures' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.70'
  WHERE name = 'Earth: Cocoon of Stone' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.68'
  WHERE name = 'Earth: Create Dirt or Clay' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.73'
  WHERE name = 'Earth: Create Golem' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.69'
  WHERE name = 'Earth: Create Mound' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.71'
  WHERE name = 'Earth: Create Steel' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.67'
  WHERE name = 'Earth: Create Wood' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.69'
  WHERE name = 'Earth: Crumble Stone' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.69'
  WHERE name = 'Earth: Dig' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.68'
  WHERE name = 'Earth: Dirt to Clay' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.68'
  WHERE name = 'Earth: Dirt to Sand' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.67'
  WHERE name = 'Earth: Dowsing' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.67'
  WHERE name = 'Earth: Dust Storm' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.69'
  WHERE name = 'Earth: Earth Rumble' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.72'
  WHERE name = 'Earth: Earthquake' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.69'
  WHERE name = 'Earth: Encase Object in Stone' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.73'
  WHERE name = 'Earth: Firequake' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.67'
  WHERE name = 'Earth: Fool''s Gold' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.68'
  WHERE name = 'Earth: Grow Plants' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.68'
  WHERE name = 'Earth: Hopping Stones' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.67'
  WHERE name = 'Earth: Identify Minerals' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.67'
  WHERE name = 'Earth: Identify Plants' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.73'
  WHERE name = 'Earth: Ironwood' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.71'
  WHERE name = 'Earth: Little Mud Mound' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.69'
  WHERE name = 'Earth: Locate Minerals' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.74'
  WHERE name = 'Earth: Magnetism' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.72'
  WHERE name = 'Earth: Mend Metal' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.70'
  WHERE name = 'Earth: Mend Stone' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.72'
  WHERE name = 'Earth: Metal to Clay' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.67'
  WHERE name = 'Earth: Mystic Fulcrum' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.72'
  WHERE name = 'Earth: Petrification' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.70'
  WHERE name = 'Earth: Quicksand' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.70'
  WHERE name = 'Earth: Repel Animals' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.72'
  WHERE name = 'Earth: River of Lava' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.67'
  WHERE name = 'Earth: Rock to Mud' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.67'
  WHERE name = 'Earth: Rot Wood' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.70'
  WHERE name = 'Earth: Rust' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.70'
  WHERE name = 'Earth: Sand Storm' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.72'
  WHERE name = 'Earth: Sculpt & Animate Clay' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.67'
  WHERE name = 'Earth: Shatter' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.69'
  WHERE name = 'Earth: Shrink Plant' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.72'
  WHERE name = 'Earth: Stone to Flesh' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.74'
  WHERE name = 'Earth: Suspended Animation' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.68'
  WHERE name = 'Earth: Throwing Stones' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.68'
  WHERE name = 'Earth: Track' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.74'
  WHERE name = 'Earth: Transference of Essence' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.72'
  WHERE name = 'Earth: Travel Through Stone' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.71'
  WHERE name = 'Earth: Travel Through Walls' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.68'
  WHERE name = 'Earth: Wall of Clay' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.73'
  WHERE name = 'Earth: Wall of Iron' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.69'
  WHERE name = 'Earth: Wall of Stone' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.70'
  WHERE name = 'Earth: Wall of Thorns' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.68'
  WHERE name = 'Earth: Wither Plants' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.72'
  WHERE name = 'Earth: Wood to Stone' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.74'
  WHERE name = 'Fire: Blinding Flash' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.79'
  WHERE name = 'Fire: Blue Flame' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.79'
  WHERE name = 'Fire: Breathe Fire' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.80'
  WHERE name = 'Fire: Burst into Flame' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.76'
  WHERE name = 'Fire: Circle of Cold' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.76'
  WHERE name = 'Fire: Circle of Flame' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.75'
  WHERE name = 'Fire: Cloud of Ash' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.74'
  WHERE name = 'Fire: Cloud of Smoke' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.77'
  WHERE name = 'Fire: Cloud of Steam' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.75'
  WHERE name = 'Fire: Create Coal' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.77'
  WHERE name = 'Fire: Create Heat' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.79'
  WHERE name = 'Fire: Dancing Fires' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.76'
  WHERE name = 'Fire: Darkness' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.80'
  WHERE name = 'Fire: Drought' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.79'
  WHERE name = 'Fire: Eat Fire' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.79'
  WHERE name = 'Fire: Eternal Flame' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.77'
  WHERE name = 'Fire: Extinguish Fire' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.75'
  WHERE name = 'Fire: Fiery Touch' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.77'
  WHERE name = 'Fire: Fire Ball' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.78'
  WHERE name = 'Fire: Fire Blossom' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.75'
  WHERE name = 'Fire: Fire Bolt' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.79'
  WHERE name = 'Fire: Fire Globe' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.74'
  WHERE name = 'Fire: Fire Gout' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.80'
  WHERE name = 'Fire: Fire Sponge' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.80'
  WHERE name = 'Fire: Fire Whip' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.76'
  WHERE name = 'Fire: Fireblast' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.78'
  WHERE name = 'Fire: Flame Friend' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.76'
  WHERE name = 'Fire: Flame Lick' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.80'
  WHERE name = 'Fire: Flame of Life' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.76'
  WHERE name = 'Fire: Freeze Water' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.78'
  WHERE name = 'Fire: Fuel Flame' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.75'
  WHERE name = 'Fire: Globe of Daylight' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.78'
  WHERE name = 'Fire: Heal Burns' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.74-81'
  WHERE name = 'Fire: Heat Object/Boil Water' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.75'
  WHERE name = 'Fire: Impervious to Fire' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.74'
  WHERE name = 'Fire: Lower Temperature' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.80'
  WHERE name = 'Fire: Melt Metal' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.78'
  WHERE name = 'Fire: Mini-Fireballs' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.75'
  WHERE name = 'Fire: Nightvision' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.74'
  WHERE name = 'Fire: Part Fire' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.81'
  WHERE name = 'Fire: Plasma Bolt' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.76'
  WHERE name = 'Fire: Resist Cold' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.80'
  WHERE name = 'Fire: River of Lava' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.79'
  WHERE name = 'Fire: Screaming Wall of Flame' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.78'
  WHERE name = 'Fire: See Through Smoke' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.76'
  WHERE name = 'Fire: Spontaneous Combustion' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.75'
  WHERE name = 'Fire: Stench of Hades' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.76'
  WHERE name = 'Fire: Swirling Lights' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.80'
  WHERE name = 'Fire: Ten Foot Wheel of Fire' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.76'
  WHERE name = 'Fire: Tongue of Flame' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.74'
  WHERE name = 'Fire: Wall of Flame' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.79'
  WHERE name = 'Fire: Wall of Ice' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.82-88'
  WHERE name = 'Water: Breathe Underwater' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.88'
  WHERE name = 'Water: Calm Waters' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.88'
  WHERE name = 'Water: Calm Waters (greater)' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.83'
  WHERE name = 'Water: Change Current' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.82-88'
  WHERE name = 'Water: Circle of Rain' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.82'
  WHERE name = 'Water: Cloud of Steam' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.82'
  WHERE name = 'Water: Color Water' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.82-88'
  WHERE name = 'Water: Command Fish' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.85'
  WHERE name = 'Water: Communicate with Sea Creature' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.82'
  WHERE name = 'Water: Create Fog' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.85'
  WHERE name = 'Water: Create Water' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.88'
  WHERE name = 'Water: Creature of the Waves' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.82'
  WHERE name = 'Water: Dowsing' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.87'
  WHERE name = 'Water: Drought' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.86'
  WHERE name = 'Water: Earth to Mud' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.86'
  WHERE name = 'Water: Encase in Ice' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.82'
  WHERE name = 'Water: Float on Water' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.83'
  WHERE name = 'Water: Fog of Fear' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.83'
  WHERE name = 'Water: Foul Water' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.82-88'
  WHERE name = 'Water: Freeze Water' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.83'
  WHERE name = 'Water: Frostblade' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.85'
  WHERE name = 'Water: Hail' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.86'
  WHERE name = 'Water: Heal Burns' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.86'
  WHERE name = 'Water: Hurricane' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.82-88'
  WHERE name = 'Water: Impervious to Ocean Depth' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.83'
  WHERE name = 'Water: Liquids to Water' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.87'
  WHERE name = 'Water: Little Ice Monster' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.87'
  WHERE name = 'Water: Part Waters' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.82'
  WHERE name = 'Water: Protection from Lightning' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.82'
  WHERE name = 'Water: Purple Mist' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.82'
  WHERE name = 'Water: Rain Dance' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.85'
  WHERE name = 'Water: Resist Cold' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.83'
  WHERE name = 'Water: Resist Fire' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.83'
  WHERE name = 'Water: Ride the Waves' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.82'
  WHERE name = 'Water: Salt Water to Fresh' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.82'
  WHERE name = 'Water: Sense Direction Underwater' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.85'
  WHERE name = 'Water: Shards of Ice' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.85'
  WHERE name = 'Water: Sheet of Ice' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.82'
  WHERE name = 'Water: Snow Storm' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.85'
  WHERE name = 'Water: Speak Underwater' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.82-88'
  WHERE name = 'Water: Summon Sharks or Whales' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.82'
  WHERE name = 'Water: Summon Storm' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.85'
  WHERE name = 'Water: Swim Like the Dolphin' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.83'
  WHERE name = 'Water: Swim as a Fish: Superior' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.82'
  WHERE name = 'Water: Ten Foot Ball of Ice' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.82'
  WHERE name = 'Water: Tidal Wave' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.82'
  WHERE name = 'Water: Walk the Waves' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.85'
  WHERE name = 'Water: Wall of Ice' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.83'
  WHERE name = 'Water: Water Seal' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.85'
  WHERE name = 'Water: Water Wisps' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.82'
  WHERE name = 'Water: Water to Wine' AND source_book = 'Rifts Book of Magic p.71-72';
UPDATE spells SET source_book = 'Rifts Book of Magic p.82'
  WHERE name = 'Water: Whirlpool' AND source_book = 'Rifts Book of Magic p.71-72';


-- Read the result back rather than trusting the exit code. The first must be 0.
SELECT count(*) AS still_wrong FROM spells WHERE source_book = 'Rifts Book of Magic p.71-72';
SELECT count(*) AS now_cited FROM spells
  WHERE source_book LIKE 'Rifts Book of Magic p.%' AND source_book <> 'Rifts Book of Magic p.71-72';

-- Records this run. REQUIRED: the smoke test fails a data script with no footer.
INSERT INTO data_script_runs (filename) VALUES ('fix-bom-elemental-citations.sql');
