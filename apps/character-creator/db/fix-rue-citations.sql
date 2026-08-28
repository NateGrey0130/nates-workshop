-- Rifts Ultimate Edition's untraceable rows, cited by the page they are on.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-rue-citations.sql
--
-- 327 rows carried the bare title 'Rifts Ultimate Edition' and no page range.
-- Nothing here was ever `outside-cache`: all 382 pages are cached, so every
-- one of these could be located without reading anything new. See
-- apps/character-creator/docs/surveys/rue.md.
--
-- THREE READINGS, and no row here rests on fewer than three:
--
--   1. the TABLE OF CONTENTS (printed 8 and 9) gives each section a page;
--   2. the SAME section heading, found in the body, must agree with it -
--      and all fifteen spell levels, all four psionic categories and all
--      seventeen skill categories do. The body carries one section the
--      contents omits entirely: DOMESTIC SKILLS at printed 307;
--   3. the row's own name, found inside that section's page band, as the
--      book formats that kind of entry - spells and psionics as a heading
--      followed by Range:/I.S.P./P.P.E., skills and gear as the opening of
--      a paragraph.
--
-- 114 of the 115 rue spells are the ONLY occurrence of their name in the
-- whole description section, so the band did not even have to disambiguate
-- them. The exception is Dimensional Portal, which appears at 198 inside the
-- compact spell list and at 225 as its own entry; the band chose 225.
--
-- WHAT IS NOT HERE. 23 rows are held back rather than guessed, because RUE
-- does not print them under the catalog's name at all - three psionic powers,
-- nine skills (five of them W.P.s at a granularity RUE does not use), and
-- eleven gear rows. They are listed in the survey. Attributing them needs a
-- decision about WHICH book, which is not a re-provenance pass.
--
-- Every statement guards on the bare title, so this is a no-op on a row that
-- has already been given a page and cannot clobber a better citation.


-- Spells - the general invocations, printed 198-225 (115)
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.211'
  WHERE name = 'Agony' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.211'
  WHERE name = 'Animate and Control Dead' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.206'
  WHERE name = 'Armor Bizarre' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.211'
  WHERE name = 'Ballistic Fire' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.218'
  WHERE name = 'Banishment' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.199'
  WHERE name = 'Befuddle' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.204'
  WHERE name = 'Blind' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.209'
  WHERE name = 'Call Lightning' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.207'
  WHERE name = 'Calling' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.204'
  WHERE name = 'Carpet of Adhesion' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.204'
  WHERE name = 'Charismatic Aura' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.207'
  WHERE name = 'Charm' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.207'
  WHERE name = 'Circle of Flame' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.200'
  WHERE name = 'Cleanse' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.200'
  WHERE name = 'Climb' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.200'
  WHERE name = 'Cloak of Darkness' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.198'
  WHERE name = 'Cloud of Smoke' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.214'
  WHERE name = 'Commune with Spirits' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.210'
  WHERE name = 'Compulsion' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.212'
  WHERE name = 'Constrain Being' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.218'
  WHERE name = 'Control & Enslave Entity' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.210'
  WHERE name = 'Cure Illness' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.204'
  WHERE name = 'Cure Minor Disorders' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.198'
  WHERE name = 'Death Trance' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.217'
  WHERE name = 'Desiccate the Supernatural' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.225'
  WHERE name = 'Dimensional Portal' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.212'
  WHERE name = 'Dispel Magic Barriers' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.207'
  WHERE name = 'Distant Voice' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.207'
  WHERE name = 'Domination' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.217'
  WHERE name = 'Dragon Fire' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.204'
  WHERE name = 'Electric Arc' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.207'
  WHERE name = 'Energy Disruption' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.205'
  WHERE name = 'Energy Field' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.208'
  WHERE name = 'Escape' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.214'
  WHERE name = 'Exorcism' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.214'
  WHERE name = 'Expel Demons' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.200'
  WHERE name = 'Extinguish Fire' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.214'
  WHERE name = 'Eyes of the Wolf' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.208'
  WHERE name = 'Eyes of Thoth' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.217'
  WHERE name = 'Familiar Link' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.200'
  WHERE name = 'Fear' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.208'
  WHERE name = 'Featherlight' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.210'
  WHERE name = 'Fire Ball' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.205'
  WHERE name = 'Fire Bolt' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.205'
  WHERE name = 'Fist of Fury' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.202'
  WHERE name = 'Float in Air' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.208'
  WHERE name = 'Fly' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.212'
  WHERE name = 'Fly as the Eagle' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.205'
  WHERE name = 'Fool''s Gold' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.214'
  WHERE name = 'Forcebonds' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.202'
  WHERE name = 'Fuel Flame' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.212'
  WHERE name = 'Globe of Silence' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.215'
  WHERE name = 'Greater Healing' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.212'
  WHERE name = 'Heal Self' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.208'
  WHERE name = 'Heal Wounds' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.201'
  WHERE name = 'Heavy Breathing' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.208'
  WHERE name = 'House of Glass' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.202'
  WHERE name = 'Ignite Fire' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.210'
  WHERE name = 'Impervious to Energy' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.202'
  WHERE name = 'Impervious to Fire' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.202'
  WHERE name = 'Impervious to Poison' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.212'
  WHERE name = 'Invisibility (Superior)' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.215'
  WHERE name = 'Ley Line Tendril Bolts' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.205'
  WHERE name = 'Ley Line Transmission' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.213'
  WHERE name = 'Life Drain' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.203'
  WHERE name = 'Life Source' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.209'
  WHERE name = 'Lifeblast' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.203'
  WHERE name = 'Light Healing' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.213'
  WHERE name = 'Lightblade' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.215'
  WHERE name = 'Lightning Arc' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.215'
  WHERE name = 'Locate' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.215'
  WHERE name = 'Luck Curse' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.205'
  WHERE name = 'Magic Net' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.210'
  WHERE name = 'Magic Pigeon' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.203'
  WHERE name = 'Magic Shield' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.215'
  WHERE name = 'Magical-Adrenal Rush' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.201'
  WHERE name = 'Manipulate Objects' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.210'
  WHERE name = 'Mask of Deceit' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.213'
  WHERE name = 'Metamorphosis: Animal' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.216'
  WHERE name = 'Metamorphosis: Human' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.206'
  WHERE name = 'Multiple Image' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.218'
  WHERE name = 'Mute' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.203'
  WHERE name = 'Mystic Fulcrum' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.216'
  WHERE name = 'Negate Magic' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.203'
  WHERE name = 'Negate Poison/Toxin' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.216'
  WHERE name = 'Power Weapon' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.218'
  WHERE name = 'Protection Circle: Simple' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.213'
  WHERE name = 'Purification' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.222'
  WHERE name = 'Re-Open Gateway' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.210'
  WHERE name = 'Reduce Self (6 inches)' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.206'
  WHERE name = 'Repel Animals' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.204'
  WHERE name = 'Resist Fire' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.199'
  WHERE name = 'See Aura' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.199'
  WHERE name = 'See the Invisible' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.206'
  WHERE name = 'Shadow Meld' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.210'
  WHERE name = 'Sheltering Force' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.216'
  WHERE name = 'Shockwave' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.217'
  WHERE name = 'Sickness' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.209'
  WHERE name = 'Sleep' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.218'
  WHERE name = 'Speed of the Snail' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.217'
  WHERE name = 'Spoil' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.220'
  WHERE name = 'Summon and Control Rodents' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.209'
  WHERE name = 'Superhuman Endurance' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.209'
  WHERE name = 'Superhuman Speed' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.209'
  WHERE name = 'Superhuman Strength' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.206'
  WHERE name = 'Swim as a Fish (lesser)' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.211'
  WHERE name = 'Teleport: Lesser' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.211'
  WHERE name = 'Tongues' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.206'
  WHERE name = 'Trance' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.201'
  WHERE name = 'Turn Dead' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.218'
  WHERE name = 'Wall of Defense' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.218'
  WHERE name = 'Water to Wine' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.214'
  WHERE name = 'Wind Rush' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.217'
  WHERE name = 'Wisps of Confusion' AND source_book = 'Rifts Ultimate Edition';
UPDATE spells SET source_book = 'Rifts Ultimate Edition p.211'
  WHERE name = 'Words of Truth' AND source_book = 'Rifts Ultimate Edition';


-- Spells RUE only MENTIONS. Each is named in a class's spell list at printed
-- 120 and described nowhere in this book. RUE's own 'List of Spells in Rifts
-- Book of Magic' (printed 226-228) sends them to the Book of Magic, and the
-- bom cache carries each one as a heading with its stat block on the page
-- named. These three change the BOOK, not just the page.

-- Re-attributed to the Book of Magic (3)
-- bom printed 131 prints `Summon & Control Canines (ritual)`; level 9 matches the bom band 126-132
UPDATE spells SET source_book = 'Rifts Book of Magic p.131'
  WHERE name = 'Summon and Control Canines' AND source_book = 'Rifts Ultimate Edition';
-- RUE's cross-reference list says 109; bom printed 109 carries the heading
UPDATE spells SET source_book = 'Rifts Book of Magic p.109'
  WHERE name = 'Sustain' AND source_book = 'Rifts Ultimate Edition';
-- RUE's cross-reference list says 114; bom printed 114 carries the heading
UPDATE spells SET source_book = 'Rifts Book of Magic p.114'
  WHERE name = 'Time Slip' AND source_book = 'Rifts Ultimate Edition';


-- Psionic powers, printed 164-184 (79)
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.166'
  WHERE name = 'Alter Aura' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.171'
  WHERE name = 'Astral Projection' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.177'
  WHERE name = 'Bio-Manipulation (the evil eye)' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.164'
  WHERE name = 'Bio-Regeneration' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.178'
  WHERE name = 'Bio-Regeneration (Super)' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.172'
  WHERE name = 'Clairvoyance' AND source_book = 'Rifts Ultimate Edition';
-- the book prints `Commune with Spirits`, plural, at printed 172, inside the Sensitive band 171-177
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.172'
  WHERE name = 'Commune with Spirit' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.165'
  WHERE name = 'Deaden Pain' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.167'
  WHERE name = 'Death Trance' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.165'
  WHERE name = 'Detect Psionics' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.167'
  WHERE name = 'Ectoplasm' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.168'
  WHERE name = 'Ectoplasmic Disguise' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.178'
  WHERE name = 'Electrokinesis' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.178'
  WHERE name = 'Empathic Transmission' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.172'
  WHERE name = 'Empathy' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.165'
  WHERE name = 'Exorcism' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.178'
  WHERE name = 'Group Mind Block' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.179'
  WHERE name = 'Group Trance' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.165'
  WHERE name = 'Healing Touch' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.179'
  WHERE name = 'Hydrokinesis' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.179'
  WHERE name = 'Hypnotic Suggestion' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.168'
  WHERE name = 'Impervious to Cold' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.168'
  WHERE name = 'Impervious to Fire' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.168'
  WHERE name = 'Impervious to Poison/Toxin' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.165'
  WHERE name = 'Increased Healing' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.165'
  WHERE name = 'Induce Sleep' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.173'
  WHERE name = 'Intuitive Combat' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.168'
  WHERE name = 'Levitation' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.174'
  WHERE name = 'Mask I.S.P. & Psionics' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.174'
  WHERE name = 'Mask P.P.E.' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.174'
  WHERE name = 'Meditation' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.179'
  WHERE name = 'Mentally Possess Others' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.169'
  WHERE name = 'Mind Block' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.180'
  WHERE name = 'Mind Block Auto-Defense' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.180'
  WHERE name = 'Mind Bolt' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.180'
  WHERE name = 'Mind Bond' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.180'
  WHERE name = 'Mind Wipe' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.169'
  WHERE name = 'Nightvision' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.174'
  WHERE name = 'Object Read (Psychometry)' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.180'
  WHERE name = 'P.P.E. Shield' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.175'
  WHERE name = 'Presence Sense' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.180'
  WHERE name = 'Psi-Shield' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.180'
  WHERE name = 'Psi-Sword' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.181'
  WHERE name = 'Psionic Invisibility' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.166'
  WHERE name = 'Psychic Diagnosis' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.181'
  WHERE name = 'Psychic Omni-Sight' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.166'
  WHERE name = 'Psychic Purification' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.166'
  WHERE name = 'Psychic Surgery' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.182'
  WHERE name = 'Psychosomatic Disease' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.182'
  WHERE name = 'Pyrokinesis' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.175'
  WHERE name = 'Read Dimensional Portal' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.175'
  WHERE name = 'Remote Viewing' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.166'
  WHERE name = 'Resist Fatigue' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.169'
  WHERE name = 'Resist Hunger' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.169'
  WHERE name = 'Resist Thirst' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.166'
  WHERE name = 'Restore P.P.E.' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.175'
  WHERE name = 'See Aura' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.176'
  WHERE name = 'See The Invisible' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.176'
  WHERE name = 'Sense Dimensional Anomaly' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.176'
  WHERE name = 'Sense Evil' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.176'
  WHERE name = 'Sense Magic' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.176'
  WHERE name = 'Sixth Sense' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.177'
  WHERE name = 'Speed Reading' AND source_book = 'Rifts Ultimate Edition';
-- printed 182 as sub-ability 2 of Pyrokinesis, a SUPER-psionic - the catalog files it as Physical, which is a separate question
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.182'
  WHERE name = 'Spontaneous Combustion' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.166'
  WHERE name = 'Stop Bleeding' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.169'
  WHERE name = 'Summon Inner Strength' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.166'
  WHERE name = 'Suppress Fear' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.169'
  WHERE name = 'Telekinesis' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.182'
  WHERE name = 'Telekinesis (Super)' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.183'
  WHERE name = 'Telekinetic Acceleration Attack' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.183'
  WHERE name = 'Telekinetic Force Field' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.170'
  WHERE name = 'Telekinetic Leap' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.170'
  WHERE name = 'Telekinetic Lift' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.170'
  WHERE name = 'Telekinetic Punch' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.170'
  WHERE name = 'Telekinetic Push' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.184'
  WHERE name = 'Telemechanic Possession' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.183'
  WHERE name = 'Telemechanics' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.177'
  WHERE name = 'Telepathy' AND source_book = 'Rifts Ultimate Edition';
UPDATE psionic_powers SET source_book = 'Rifts Ultimate Edition p.177'
  WHERE name = 'Total Recall' AND source_book = 'Rifts Ultimate Edition';


-- Skills, printed 304-329 (84)
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.312'
  WHERE name = 'Aircraft Mechanics' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.318'
  WHERE name = 'Airplane' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.321'
  WHERE name = 'Anthropology' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.322'
  WHERE name = 'Archaeology' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.316'
  WHERE name = 'Athletics (general)' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.318'
  WHERE name = 'Automobile' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.312'
  WHERE name = 'Automotive Mechanics' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.308'
  WHERE name = 'Basic Electronics' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.329'
  WHERE name = 'Boat Building' AND source_book = 'Rifts Ultimate Edition';
-- the book prints `Boats: Motor, Race & Hydrofoil Types`
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.318'
  WHERE name = 'Boat: Motor, Race & Hydrofoil' AND source_book = 'Rifts Ultimate Edition';
-- the book prints `Boats: Sail Types`
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.318'
  WHERE name = 'Boat: Sail Type' AND source_book = 'Rifts Ultimate Edition';
-- the book prints `Boats: Ships/Seamanship`
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.318'
  WHERE name = 'Boat: Ships' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.322'
  WHERE name = 'Botany' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.329'
  WHERE name = 'Carpentry' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.322'
  WHERE name = 'Chemistry ' || char(8212) || ' Analytical' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.320'
  WHERE name = 'Computer Hacking' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.323'
  WHERE name = 'Computer Programming' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.308'
  WHERE name = 'Computer Repair' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.320'
  WHERE name = 'Concealment' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.307'
  WHERE name = 'Cook' AND source_book = 'Rifts Ultimate Edition';
-- printed 304 under COMMUNICATION skills; the catalog files it as Technical
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.304'
  WHERE name = 'Creative Writing' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.307'
  WHERE name = 'Dance' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.315'
  WHERE name = 'Demolitions Disposal' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.308'
  WHERE name = 'Electrical Engineer' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.314'
  WHERE name = 'First Aid' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.307'
  WHERE name = 'Fishing' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.314'
  WHERE name = 'Forensics' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.308'
  WHERE name = 'Forgery' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.316'
  WHERE name = 'Hand to Hand: Assassin' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.316'
  WHERE name = 'Hand to Hand: Basic' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.316'
  WHERE name = 'Hand to Hand: Martial Arts' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.314'
  WHERE name = 'Holistic Medicine' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.311'
  WHERE name = 'Horsemanship: General' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.318'
  WHERE name = 'Hover Craft (ground)' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.330'
  WHERE name = 'Hunting' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.309'
  WHERE name = 'Interrogation' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.319'
  WHERE name = 'Jet Aircraft' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.319'
  WHERE name = 'Jet Packs' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.312'
  WHERE name = 'Locksmith' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.325'
  WHERE name = 'Lore: Faeries & Creatures of Magic' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.312'
  WHERE name = 'Mechanical Engineer' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.314'
  WHERE name = 'Medical Doctor' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.319'
  WHERE name = 'Military: Jet Fighters' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.319'
  WHERE name = 'Military: Tanks & APCs' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.319'
  WHERE name = 'Motorcycles & Snowmobiles' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.320'
  WHERE name = 'Navigation' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.316'
  WHERE name = 'No Hand to Hand Combat Skill' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.305'
  WHERE name = 'Optic Systems' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.321'
  WHERE name = 'Palming' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.314'
  WHERE name = 'Paramedic' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.314'
  WHERE name = 'Pathology' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.325'
  WHERE name = 'Photography' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.309'
  WHERE name = 'Pick Locks' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.309'
  WHERE name = 'Pick Pockets' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.307'
  WHERE name = 'Play Musical Instrument' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.330'
  WHERE name = 'Preserve Food' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.305'
  WHERE name = 'Radio: Scramblers' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.325'
  WHERE name = 'Recycling' AND source_book = 'Rifts Ultimate Edition';
-- printed 319, `Robot Combat: Elite is usually reserved for specialists...`
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.319'
  WHERE name = 'Robot Combat Elite' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.308'
  WHERE name = 'Robot Electronics' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.312'
  WHERE name = 'Robot Mechanics' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.319'
  WHERE name = 'Robots & Power Armor' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.317'
  WHERE name = 'SCUBA' AND source_book = 'Rifts Ultimate Edition';
-- the book prints `Sense of balance (60% +5% per level)` at printed 316
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.316'
  WHERE name = 'Sense of Balance' AND source_book = 'Rifts Ultimate Edition';
-- printed 305 under Communication; Pilot Related at 320 only cross-references it
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.305'
  WHERE name = 'Sensory Equipment' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.308'
  WHERE name = 'Sewing' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.309'
  WHERE name = 'Sniper' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.321'
  WHERE name = 'Streetwise' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.305'
  WHERE name = 'Surveillance' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.305'
  WHERE name = 'T.V./Video' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.319'
  WHERE name = 'Truck' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.326'
  WHERE name = 'W.P. Archery' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.326'
  WHERE name = 'W.P. Blunt' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.326'
  WHERE name = 'W.P. Chain' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.329'
  WHERE name = 'W.P. Energy Pistol' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.329'
  WHERE name = 'W.P. Energy Rifle' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.329'
  WHERE name = 'W.P. Heavy Military Weapons' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.327'
  WHERE name = 'W.P. Knife' AND source_book = 'Rifts Ultimate Edition';
-- printed 327, `W.P. Paired Weapons (Exclusive to Men at Arms O.C.C.s)`
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.327'
  WHERE name = 'W.P. Paired Weapons' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.327'
  WHERE name = 'W.P. Shield' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.329'
  WHERE name = 'W.P. Submachine-Gun' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.327'
  WHERE name = 'W.P. Sword' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.320'
  WHERE name = 'Weapon Systems' AND source_book = 'Rifts Ultimate Edition';
UPDATE skills SET source_book = 'Rifts Ultimate Edition p.313'
  WHERE name = 'Weapons Engineer' AND source_book = 'Rifts Ultimate Edition';


-- Gear, printed 240-273 (23)
-- printed 259, `Dog Pack Spikes.`
UPDATE gear SET source_book = 'Rifts Ultimate Edition p.259'
  WHERE name = 'Dog Pack Spikes (collars, arm/wrist bands, other)' AND source_book = 'Rifts Ultimate Edition';
UPDATE gear SET source_book = 'Rifts Ultimate Edition p.270'
  WHERE name = 'JA-11 Juicer Assassin''s Energy Rifle' AND source_book = 'Rifts Ultimate Edition';
UPDATE gear SET source_book = 'Rifts Ultimate Edition p.270'
  WHERE name = 'JA-9 Juicer Assassin Variable Laser Rifle' AND source_book = 'Rifts Ultimate Edition';
UPDATE gear SET source_book = 'Rifts Ultimate Edition p.270'
  WHERE name = 'L-20 Pulse Rifle' AND source_book = 'Rifts Ultimate Edition';
-- also named in a class description; the equipment-section page is the citation
UPDATE gear SET source_book = 'Rifts Ultimate Edition p.259'
  WHERE name = 'Neural Mace' AND source_book = 'Rifts Ultimate Edition';
UPDATE gear SET source_book = 'Rifts Ultimate Edition p.270'
  WHERE name = 'NG-101 Rail Gun' AND source_book = 'Rifts Ultimate Edition';
UPDATE gear SET source_book = 'Rifts Ultimate Edition p.271'
  WHERE name = 'NG-202 Rail Gun' AND source_book = 'Rifts Ultimate Edition';
UPDATE gear SET source_book = 'Rifts Ultimate Edition p.269'
  WHERE name = 'NG-33 Northern Gun Laser Pistol' AND source_book = 'Rifts Ultimate Edition';
UPDATE gear SET source_book = 'Rifts Ultimate Edition p.269'
  WHERE name = 'NG-57 Northern Gun Heavy-Duty Ion Blaster' AND source_book = 'Rifts Ultimate Edition';
UPDATE gear SET source_book = 'Rifts Ultimate Edition p.270'
  WHERE name = 'NG-P7 Northern Gun Particle Beam Rifle' AND source_book = 'Rifts Ultimate Edition';
-- printed 266, `Big Boss ATV` - the catalog adds the article and the dots
UPDATE gear SET source_book = 'Rifts Ultimate Edition p.266'
  WHERE name = 'The Big Boss A.T.V.' AND source_book = 'Rifts Ultimate Edition';
-- printed 266, `Highway-Man Motorcycle`
UPDATE gear SET source_book = 'Rifts Ultimate Edition p.266'
  WHERE name = 'The Highway-Man Motorcycle' AND source_book = 'Rifts Ultimate Edition';
-- printed 266, `Mountaineer ATV`
UPDATE gear SET source_book = 'Rifts Ultimate Edition p.266'
  WHERE name = 'The Mountaineer A.T.V.' AND source_book = 'Rifts Ultimate Edition';
-- printed 266, `Wastelander Motorcycle`
UPDATE gear SET source_book = 'Rifts Ultimate Edition p.266'
  WHERE name = 'The Wastelander Motorcycle' AND source_book = 'Rifts Ultimate Edition';
-- also named in a class description; the equipment-section page is the citation
UPDATE gear SET source_book = 'Rifts Ultimate Edition p.259'
  WHERE name = 'Vibro-Knife' AND source_book = 'Rifts Ultimate Edition';
-- also named in a class description; the equipment-section page is the citation
UPDATE gear SET source_book = 'Rifts Ultimate Edition p.259'
  WHERE name = 'Vibro-Saber' AND source_book = 'Rifts Ultimate Edition';
UPDATE gear SET source_book = 'Rifts Ultimate Edition p.259'
  WHERE name = 'Vibro-Sword' AND source_book = 'Rifts Ultimate Edition';
UPDATE gear SET source_book = 'Rifts Ultimate Edition p.268'
  WHERE name = 'Wilk''s 320 Laser Pistol' AND source_book = 'Rifts Ultimate Edition';
UPDATE gear SET source_book = 'Rifts Ultimate Edition p.269'
  WHERE name = 'Wilk''s 447 Laser Rifle' AND source_book = 'Rifts Ultimate Edition';
UPDATE gear SET source_book = 'Rifts Ultimate Edition p.267'
  WHERE name = 'Wilk''s Jet Pack' AND source_book = 'Rifts Ultimate Edition';
-- also named in a class description; the equipment-section page is the citation
UPDATE gear SET source_book = 'Rifts Ultimate Edition p.269'
  WHERE name = 'Wilk''s Laser Scalpel' AND source_book = 'Rifts Ultimate Edition';
UPDATE gear SET source_book = 'Rifts Ultimate Edition p.269'
  WHERE name = 'Wilk''s Laser Wand (tool)' AND source_book = 'Rifts Ultimate Edition';
UPDATE gear SET source_book = 'Rifts Ultimate Edition p.269'
  WHERE name = 'Wilk''s Portable Laser Torch (tool)' AND source_book = 'Rifts Ultimate Edition';


-- Read the result back rather than trusting the exit code.
SELECT 'spells' AS t, count(*) AS still_bare FROM spells WHERE source_book = 'Rifts Ultimate Edition'
UNION ALL SELECT 'skills', count(*) FROM skills WHERE source_book = 'Rifts Ultimate Edition'
UNION ALL SELECT 'psionic_powers', count(*) FROM psionic_powers WHERE source_book = 'Rifts Ultimate Edition'
UNION ALL SELECT 'gear', count(*) FROM gear WHERE source_book = 'Rifts Ultimate Edition';
-- 23 held back deliberately: 3 psionic powers, 9 skills, 11 gear. The four
-- counts above must read 0 / 9 / 3 / 11 and nothing else.

-- Records this run. REQUIRED: the smoke test fails a data script with no footer.
INSERT INTO data_script_runs (filename) VALUES ('fix-rue-citations.sql');
