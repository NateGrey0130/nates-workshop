-- The Book of Magic's general invocations, cited by the page they are printed on.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-bom-invocation-citations.sql
--
-- The other half of INGESTION-AUDIT F24, and the larger one. #372 re-cited the
-- 231 elemental spells that claimed 'p.71-72'. These 177 never claimed a page
-- at all: they carry the bare title 'Rifts Book of Magic', which scores
-- no-page-range and which buildUpdate's COALESCE would not have caught,
-- because a bare title is not a NULL (F19).
--
-- THREE readings, and no row here rests on fewer than three:
--
--   1. the Index of Rifts Magic (printed 348-352) gives the name a page;
--   2. the index SECTION it is listed under gives it a level, which must
--      match the row's own `level` column in D1. This is what separates the
--      general invocation from the Warlock spell of the same name - the book
--      prints Wave of Frost at 60 (Air Level Three) and at 99 (Invocations
--      Level Three), and Throwing Stones, Shatter, Create Wood, Orb of Cold
--      and Light Target are all printed twice the same way;
--   3. the body text on the cited page carries the spell's HEADING - the name
--      on its own line followed by Range:/Duration:/P.P.E. A substring test
--      would not do: 'Ice', 'Seal' and 'Horror' occur in ordinary prose.
--
-- 176 of 177 were confirmed on the page the index named. ONE was not, and the
-- book is what disagreed with itself: WARRIOR HORDE is 'p. 158' in the
-- sectioned list and 'p. 159' in the same index's Alphabetical List. The body
-- puts the heading on printed 159, so 159 is what this writes. It is the
-- book-survey rule about two authorities checking each other, met in the
-- authority table rather than in an extraction.
--
-- Every statement guards on the bare title, so this is a no-op on a row that
-- has already been given a page and cannot clobber a better citation.

UPDATE spells SET source_book = 'Rifts Book of Magic p.143'
  WHERE name = 'Amulet' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.150'
  WHERE name = 'Annihilate' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.138'
  WHERE name = 'Anti-Magic Cloud' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.110'
  WHERE name = 'Apparition' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.132'
  WHERE name = 'Armorbane' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.138'
  WHERE name = 'Astral Hole' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.99'
  WHERE name = 'Astral Projection' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.104'
  WHERE name = 'Aura of Death' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.126'
  WHERE name = 'Aura of Doom' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.93'
  WHERE name = 'Aura of Power' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.110'
  WHERE name = 'Barrage' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.154'
  WHERE name = 'Barrier of Thoth' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.126'
  WHERE name = 'Beat Insurmountable Odds' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.154'
  WHERE name = 'Blight of Ages' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.155'
  WHERE name = 'Blood and Thunder' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.139'
  WHERE name = 'Bottomless Pit' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.143'
  WHERE name = 'Calm Storms' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.100'
  WHERE name = 'Chromatic Protection' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.152'
  WHERE name = 'Circle of Travel' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.150'
  WHERE name = 'Close Rift' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.147'
  WHERE name = 'Collapse' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.147'
  WHERE name = 'Create Golem' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.140'
  WHERE name = 'Create Magic Scroll' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.139'
  WHERE name = 'Create Mummy' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.127'
  WHERE name = 'Create Steel' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.111'
  WHERE name = 'Create Water' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.96'
  WHERE name = 'Create Wood' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.144'
  WHERE name = 'Create Zombie' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.155'
  WHERE name = 'Crimson Wall of Lictalon' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.111'
  WHERE name = 'Crushing Fist' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.140'
  WHERE name = 'Curse of the World Bizarre' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.127'
  WHERE name = 'Curse: Phobia' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.127'
  WHERE name = 'D-Step' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.104'
  WHERE name = 'Death Curse' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.132'
  WHERE name = 'Deathword' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.100'
  WHERE name = 'Deflect' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.152'
  WHERE name = 'Dimensional Teleport' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.140'
  WHERE name = 'Disharmonize' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.156'
  WHERE name = 'Doppleganger (Superior)' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.152'
  WHERE name = 'Enchant Weapon (Minor)' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.133'
  WHERE name = 'Enemy Mind' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.111'
  WHERE name = 'Energize Spell' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.140'
  WHERE name = 'Energy Sphere' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.144'
  WHERE name = 'Ensorcel' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.111'
  WHERE name = 'Fire Blossom' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.120'
  WHERE name = 'Fire Globe' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.115'
  WHERE name = 'Fire Gout' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.101'
  WHERE name = 'Fireblast' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.141'
  WHERE name = 'Firequake' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.112'
  WHERE name = 'Fortify Against Disease' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.112'
  WHERE name = 'Frequency Jamming' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.112'
  WHERE name = 'Frostblade' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.133'
  WHERE name = 'Giant' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.121'
  WHERE name = 'Hallucination' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.133'
  WHERE name = 'Havoc' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.144'
  WHERE name = 'Heavy Air' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.156'
  WHERE name = 'Hivemind' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.106'
  WHERE name = 'Horrific Illusion' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.106'
  WHERE name = 'Horror' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.112'
  WHERE name = 'Ice' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.141'
  WHERE name = 'Id Alter Ego' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.151'
  WHERE name = 'Id Barrier' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.112'
  WHERE name = 'Illusion Booster' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.128'
  WHERE name = 'Illusion Manipulation' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.133'
  WHERE name = 'Illusory Forest' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.141'
  WHERE name = 'Illusory Terrain' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.112'
  WHERE name = 'Illusory Wall' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.151'
  WHERE name = 'Impenetrable Wall of Force' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.107'
  WHERE name = 'Implosion Neutralizer' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.107'
  WHERE name = 'Influence the Beast' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.108'
  WHERE name = 'Instill Knowledge' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.121'
  WHERE name = 'Invincible Armor' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.116'
  WHERE name = 'Invulnerability' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.145'
  WHERE name = 'Ironwood' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.116'
  WHERE name = 'Ley Line Fade' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.134'
  WHERE name = 'Ley Line Ghost' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.129'
  WHERE name = 'Ley Line Phantom' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.153'
  WHERE name = 'Ley Line Restoration' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.156'
  WHERE name = 'Ley Line Resurrection' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.153'
  WHERE name = 'Ley Line Shutdown' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.141'
  WHERE name = 'Ley Line Storm Defense' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.121'
  WHERE name = 'Ley Line Time Capsule' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.129'
  WHERE name = 'Ley Line Time Flux' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.121'
  WHERE name = 'Lifeward' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.97'
  WHERE name = 'Light Target' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.135'
  WHERE name = 'Magic Warrior' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.113'
  WHERE name = 'Memory Bank' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.108'
  WHERE name = 'Mend the Broken' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.109'
  WHERE name = 'Mental Blast' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.117'
  WHERE name = 'Mental Shock' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.129'
  WHERE name = 'Metamorphosis: Insect' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.145'
  WHERE name = 'Metamorphosis: Mist' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.135'
  WHERE name = 'Metamorphosis: Superior' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.135'
  WHERE name = 'Meteor' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.157'
  WHERE name = 'Metropolis' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.142'
  WHERE name = 'Mindshatter' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.122'
  WHERE name = 'Minor Curse' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.95'
  WHERE name = 'Mystic Alarm' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.135'
  WHERE name = 'Mystic Portal' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.157'
  WHERE name = 'Mystic Quake' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.118'
  WHERE name = 'Negate Mechanics' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.145'
  WHERE name = 'Null Sphere' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.123'
  WHERE name = 'Oracle' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.98'
  WHERE name = 'Orb of Cold' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.130'
  WHERE name = 'Phantom Mount' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.135'
  WHERE name = 'Plane Skip' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.113'
  WHERE name = 'Power Bolt' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.148'
  WHERE name = 'Protection Circle: Superior' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.136'
  WHERE name = 'Purge Other' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.130'
  WHERE name = 'Purge Self' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.136'
  WHERE name = 'Reality Flux' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.130'
  WHERE name = 'Realm of Chaos' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.102'
  WHERE name = 'Reflection' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.142'
  WHERE name = 'Remove Curse' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.151'
  WHERE name = 'Restoration' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.148'
  WHERE name = 'Restore Life' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.136'
  WHERE name = 'Restore Limb' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.151'
  WHERE name = 'Resurrection' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.102'
  WHERE name = 'Ricochet Strike' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.142'
  WHERE name = 'Rift Teleportation' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.142'
  WHERE name = 'Rift to Limbo' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.151'
  WHERE name = 'Rift Triangular Defense System' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.157'
  WHERE name = 'Sanctuary' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.149'
  WHERE name = 'Sanctum' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.102'
  WHERE name = 'Seal' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.118'
  WHERE name = 'Second Sight' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.143'
  WHERE name = 'See in Magic Darkness' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.118'
  WHERE name = 'See Wards' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.149'
  WHERE name = 'Shadow Wall' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.95'
  WHERE name = 'Shatter' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.119'
  WHERE name = 'Sonic Blast' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.124'
  WHERE name = 'Sorcerous Fury' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.145'
  WHERE name = 'Soultwist' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.136'
  WHERE name = 'Speed Weapon' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.119'
  WHERE name = 'Spinning Blades' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.158'
  WHERE name = 'Steel Rain' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.125'
  WHERE name = 'Stone to Flesh' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.119'
  WHERE name = 'Sub-Particle Acceleration' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.151'
  WHERE name = 'Summon & Control Sea Serpents' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.153'
  WHERE name = 'Summon Ally' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.143'
  WHERE name = 'Summon and Control Animals' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.146'
  WHERE name = 'Summon and Control Entity' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.146'
  WHERE name = 'Summon and Control Rain' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.149'
  WHERE name = 'Summon and Control Storm' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.143'
  WHERE name = 'Summon Fog' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.136'
  WHERE name = 'Summon Greater Familiar' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.149'
  WHERE name = 'Summon Lesser Being' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.146'
  WHERE name = 'Summon Ley Line Storm' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.137'
  WHERE name = 'Summon Shadow Beast' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.137'
  WHERE name = 'Super-Healing' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.146'
  WHERE name = 'Swallowing Rift' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.149'
  WHERE name = 'Swap Places' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.109'
  WHERE name = 'Swim as a Fish (Superior)' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.131'
  WHERE name = 'Swords to Snakes' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.150'
  WHERE name = 'Talisman' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.131'
  WHERE name = 'Tame Beast' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.114'
  WHERE name = 'Targeted Deflection' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.98'
  WHERE name = 'Telekinesis' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.153'
  WHERE name = 'Teleport: Superior' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.158'
  WHERE name = 'The Slowness' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.95'
  WHERE name = 'Throwing Stones' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.146'
  WHERE name = 'Time Hole' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.132'
  WHERE name = 'Transferal' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.153'
  WHERE name = 'Transformation' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.158'
  WHERE name = 'Vicious Circle' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.154'
  WHERE name = 'Void' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.137'
  WHERE name = 'Wall of Not' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.147'
  WHERE name = 'Wall of the Weird' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.125'
  WHERE name = 'Wall of Wind' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.138'
  WHERE name = 'Wards' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.138'
  WHERE name = 'Warped Space' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.159'
  WHERE name = 'Warrior Horde' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.103'
  WHERE name = 'Watchguard' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.99'
  WHERE name = 'Wave of Frost' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.103'
  WHERE name = 'Weight of Duty' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.125'
  WHERE name = 'Winged Flight' AND source_book = 'Rifts Book of Magic';
UPDATE spells SET source_book = 'Rifts Book of Magic p.126'
  WHERE name = 'World Bizarre' AND source_book = 'Rifts Book of Magic';


-- Read the result back rather than trusting the exit code. The first must be 0.
SELECT count(*) AS still_bare FROM spells WHERE source_book = 'Rifts Book of Magic';
SELECT count(*) AS now_cited FROM spells WHERE source_book LIKE 'Rifts Book of Magic p.%';

-- Records this run. REQUIRED: the smoke test fails a data script with no footer.
INSERT INTO data_script_runs (filename) VALUES ('fix-bom-invocation-citations.sql');
