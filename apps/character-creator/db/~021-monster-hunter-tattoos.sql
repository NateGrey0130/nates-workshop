-- The Atlantean Monster Hunter (Rifts World Book 6: South America printed
-- 99-102) gets the magic tattoos its book gives it, as catalog tattoo spells,
-- and its race note stops saying the catalog has no True Atlantean race.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~021-monster-hunter-tattoos.sql
--
-- WHY NOW. The class was imported with its tattoos as prose because there was
-- no tattoo catalog. Rifts World Book 2: Atlantis (#1429) added 32 spells with
-- tradition 'tattoo' and granted them to seven classes through
-- `spell_traditions_allowed: ["tattoo"]`. This class says it is "a special
-- force of tattooed warriors modelled on the Undead Slayers", and the grant
-- copies undead-slayer's shape.
--
-- WHAT PRINTED 100-101 GIVES (cache p101, read off the text layer): the Marks
-- of Heritage (a heart impaled by a stake, a flaming sword), then 15 tattoos:
-- one simple weapon, two magic weapons, two animals, two monsters, four
-- Monster-Shaping, three powers and one more of any category; each level two
-- simple tattoos or one major one (powers, monster, Monster-Shaping or magic
-- weapon).
--
-- HOW IT IS STORED:
--   spells (fixed)   the two Marks, All Simple Weapons, Animals, Monsters. The
--                    catalog holds each of the last three as ONE row whose
--                    image is named on the sheet, so two animals and two
--                    monsters are one row each (tattooed-man's convention).
--   starting picks   2 magic weapons, 3 powers, 1 any - spells_starting 6.
--                    The lists are undead-slayer's magic_weapons and powers
--                    and tattooed-man's any, copied verbatim.
--   levels 2-15      one pick from undead-slayer's major list.
--   prose            the four Monster-Shaping tattoos and later ones. The book
--                    defines Monster-Shaping as a costing system by M.D.C.
--                    tier, not a list of named tattoos, so there is no row to
--                    grant. It stays in the Monster-Shaping Tattoos ability.
--
-- The race list keeps `none` for a True Atlantean rather than naming the
-- true-atlantean R.C.C., as undead-slayer does (atlantis.md): that R.C.C.
-- carries S.D.C. +70, P.P.E. +22 and the two Marks as bonuses and spells, and
-- this O.C.C.'s own M.D.C., P.P.E. and tattoos already count them, so the pair
-- would count them twice. The false parenthesis is rewritten.
--
-- MECHANICS as in ~020: one replace() per change on text appearing once,
-- guarded, a re-run a no-op, generated read-backs. Sorts after
-- add-atlantean-monster-hunter-class.sql, fix-atlantean-monster-hunter-xp.sql
-- and every Atlantis script that writes the tattoo spells.

UPDATE imported_classes SET markdown = replace(markdown, 'A True Atlantean is played with no R.C.C. (the catalog has no True Atlantean race); the True Atlantean section below holds that racial block.', 'A True Atlantean is played with no R.C.C., as the Undead Slayer is: the catalog does hold a true-atlantean R.C.C. (Rifts World Book 2: Atlantis), and its S.D.C. and P.P.E. bonuses and two Marks of Heritage are already counted in this O.C.C.''s own M.D.C., P.P.E. and tattoos, so pairing the two would count them twice. The True Atlantean section below holds the racial block.'), updated_at = datetime('now')
 WHERE class_id = 'atlantean-monster-hunter' AND deleted_at IS NULL AND instr(markdown, 'A True Atlantean is played with no R.C.C. (the catalog has no True Atlantean race); the True Atlantean section below holds that racial block.') > 0;

UPDATE imported_classes SET markdown = replace(markdown, '  - { item_id: "tw-converted-energy-pistol", qty: 1 }
special_abilities:
', '  - { item_id: "tw-converted-energy-pistol", qty: 1 }
magic:
  type: "spell"
  spell_traditions_allowed: ["tattoo"]
  spells: ["Tattoo: Heart Pierced by a Wooden Stake (protection)", "Tattoo: Weapon Covered in Flames", "Tattoo: All Simple Weapons", "Tattoo: Animals", "Tattoo: Monsters"]
  spells_starting: 6
  spells_starting_groups:
    - { count: 2, from_list: "magic_weapons", note: "Two magic weapons of choice. A weapon may carry more than one feature, so a feature already held (the Mark''s flaming sword) may be taken again on another weapon; record the weapons in the Magic Tattoos (Rifts Atlantis) ability." }
    - { count: 3, from_list: "powers", note: "Three power tattoos of choice." }
    - { count: 1, from_list: "any", note: "One more tattoo from any category. An extra simple weapon, animal or monster is one more image under the row already held, and a fifth Monster-Shaping tattoo has no row: note either on the sheet and take nothing here for it." }
  spell_lists:
    magic_weapons: ["Tattoo: Two Weapons Crossed", "Tattoo: Weapon Dripping Blood", "Tattoo: Weapon Covered in Flames", "Tattoo: Weapon Covered in Flames and a Coiled Snake/Serpent", "Tattoo: Weapon with Wings", "Tattoo: Flaming Shield"]
    powers: ["Tattoo: Chain Encircling a Skull or Brain (psionic save)", "Tattoo: Chain with a Broken Link (strength)", "Tattoo: Chain Wrapped Around a Cloud (air powers)", "Tattoo: Cross (turn dead)", "Tattoo: Eye with a Dagger In It (blind)", "Tattoo: Eye of Knowledge (language)", "Tattoo: Eye of Mystic Knowledge (magic)", "Tattoo: Eye With Tears (empathy & transmission)", "Tattoo: Eyes: Three (supernatural vision)", "Tattoo: Heart Pierced by a Wooden Stake (protection)", "Tattoo: Heart Encircled by Chains (invulnerability)", "Tattoo: Heart with Large Wings (fly)", "Tattoo: Heart with Tiny Wings (run)", "Tattoo: Knight in Full Body Armor", "Tattoo: Lightning Bolts (shoot lightning)", "Tattoo: Phoenix Rising From the Flames (resurrection)", "Tattoo: Rose and Thorny Stem & Dripping Blood (heal)", "Tattoo: Shark or Dolphin (swim)", "Tattoo: Skull with Bat Wings (animate dead)", "Tattoo: Skull Coiled with Thorns (death touch)", "Tattoo: Skull Engulfed in Flames (fire powers)", "Tattoo: Thorns or Ball of Thorns (protection: poison)"]
    any: ["Tattoo: S.D.C. Shield", "Tattoo: Two Weapons Crossed", "Tattoo: Weapon Dripping Blood", "Tattoo: Weapon Covered in Flames", "Tattoo: Weapon Covered in Flames and a Coiled Snake/Serpent", "Tattoo: Weapon with Wings", "Tattoo: Flaming Shield", "Tattoo: Chain Encircling a Skull or Brain (psionic save)", "Tattoo: Chain with a Broken Link (strength)", "Tattoo: Chain Wrapped Around a Cloud (air powers)", "Tattoo: Cross (turn dead)", "Tattoo: Eye with a Dagger In It (blind)", "Tattoo: Eye of Knowledge (language)", "Tattoo: Eye of Mystic Knowledge (magic)", "Tattoo: Eye With Tears (empathy & transmission)", "Tattoo: Eyes: Three (supernatural vision)", "Tattoo: Heart Pierced by a Wooden Stake (protection)", "Tattoo: Heart Encircled by Chains (invulnerability)", "Tattoo: Heart with Large Wings (fly)", "Tattoo: Heart with Tiny Wings (run)", "Tattoo: Knight in Full Body Armor", "Tattoo: Lightning Bolts (shoot lightning)", "Tattoo: Phoenix Rising From the Flames (resurrection)", "Tattoo: Rose and Thorny Stem & Dripping Blood (heal)", "Tattoo: Shark or Dolphin (swim)", "Tattoo: Skull with Bat Wings (animate dead)", "Tattoo: Skull Coiled with Thorns (death touch)", "Tattoo: Skull Engulfed in Flames (fire powers)", "Tattoo: Thorns or Ball of Thorns (protection: poison)"]
    major: ["Tattoo: Monsters", "Tattoo: Two Weapons Crossed", "Tattoo: Weapon Dripping Blood", "Tattoo: Weapon Covered in Flames", "Tattoo: Weapon Covered in Flames and a Coiled Snake/Serpent", "Tattoo: Weapon with Wings", "Tattoo: Flaming Shield", "Tattoo: Chain Encircling a Skull or Brain (psionic save)", "Tattoo: Chain with a Broken Link (strength)", "Tattoo: Chain Wrapped Around a Cloud (air powers)", "Tattoo: Cross (turn dead)", "Tattoo: Eye with a Dagger In It (blind)", "Tattoo: Eye of Knowledge (language)", "Tattoo: Eye of Mystic Knowledge (magic)", "Tattoo: Eye With Tears (empathy & transmission)", "Tattoo: Eyes: Three (supernatural vision)", "Tattoo: Heart Pierced by a Wooden Stake (protection)", "Tattoo: Heart Encircled by Chains (invulnerability)", "Tattoo: Heart with Large Wings (fly)", "Tattoo: Heart with Tiny Wings (run)", "Tattoo: Knight in Full Body Armor", "Tattoo: Lightning Bolts (shoot lightning)", "Tattoo: Phoenix Rising From the Flames (resurrection)", "Tattoo: Rose and Thorny Stem & Dripping Blood (heal)", "Tattoo: Shark or Dolphin (swim)", "Tattoo: Skull with Bat Wings (animate dead)", "Tattoo: Skull Coiled with Thorns (death touch)", "Tattoo: Skull Engulfed in Flames (fire powers)", "Tattoo: Thorns or Ball of Thorns (protection: poison)"]
  spells_schedule:
    - { level: 2, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or instead two simple tattoos (animal or simple weapon), recorded in the Magic Tattoos (Rifts Atlantis) ability. A Monster-Shaping tattoo is also a major tattoo; it has no catalog row and is recorded in the Monster-Shaping Tattoos ability instead of a pick here. Added by a clan elder or alchemist, never more than two at a time and at least six months apart." }
    - { level: 3, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or instead two simple tattoos (animal or simple weapon), recorded in the Magic Tattoos (Rifts Atlantis) ability. A Monster-Shaping tattoo is also a major tattoo; it has no catalog row and is recorded in the Monster-Shaping Tattoos ability instead of a pick here. Added by a clan elder or alchemist, never more than two at a time and at least six months apart." }
    - { level: 4, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or instead two simple tattoos (animal or simple weapon), recorded in the Magic Tattoos (Rifts Atlantis) ability. A Monster-Shaping tattoo is also a major tattoo; it has no catalog row and is recorded in the Monster-Shaping Tattoos ability instead of a pick here. Added by a clan elder or alchemist, never more than two at a time and at least six months apart." }
    - { level: 5, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or instead two simple tattoos (animal or simple weapon), recorded in the Magic Tattoos (Rifts Atlantis) ability. A Monster-Shaping tattoo is also a major tattoo; it has no catalog row and is recorded in the Monster-Shaping Tattoos ability instead of a pick here. Added by a clan elder or alchemist, never more than two at a time and at least six months apart." }
    - { level: 6, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or instead two simple tattoos (animal or simple weapon), recorded in the Magic Tattoos (Rifts Atlantis) ability. A Monster-Shaping tattoo is also a major tattoo; it has no catalog row and is recorded in the Monster-Shaping Tattoos ability instead of a pick here. Added by a clan elder or alchemist, never more than two at a time and at least six months apart." }
    - { level: 7, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or instead two simple tattoos (animal or simple weapon), recorded in the Magic Tattoos (Rifts Atlantis) ability. A Monster-Shaping tattoo is also a major tattoo; it has no catalog row and is recorded in the Monster-Shaping Tattoos ability instead of a pick here. Added by a clan elder or alchemist, never more than two at a time and at least six months apart." }
    - { level: 8, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or instead two simple tattoos (animal or simple weapon), recorded in the Magic Tattoos (Rifts Atlantis) ability. A Monster-Shaping tattoo is also a major tattoo; it has no catalog row and is recorded in the Monster-Shaping Tattoos ability instead of a pick here. Added by a clan elder or alchemist, never more than two at a time and at least six months apart." }
    - { level: 9, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or instead two simple tattoos (animal or simple weapon), recorded in the Magic Tattoos (Rifts Atlantis) ability. A Monster-Shaping tattoo is also a major tattoo; it has no catalog row and is recorded in the Monster-Shaping Tattoos ability instead of a pick here. Added by a clan elder or alchemist, never more than two at a time and at least six months apart." }
    - { level: 10, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or instead two simple tattoos (animal or simple weapon), recorded in the Magic Tattoos (Rifts Atlantis) ability. A Monster-Shaping tattoo is also a major tattoo; it has no catalog row and is recorded in the Monster-Shaping Tattoos ability instead of a pick here. Added by a clan elder or alchemist, never more than two at a time and at least six months apart." }
    - { level: 11, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or instead two simple tattoos (animal or simple weapon), recorded in the Magic Tattoos (Rifts Atlantis) ability. A Monster-Shaping tattoo is also a major tattoo; it has no catalog row and is recorded in the Monster-Shaping Tattoos ability instead of a pick here. Added by a clan elder or alchemist, never more than two at a time and at least six months apart." }
    - { level: 12, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or instead two simple tattoos (animal or simple weapon), recorded in the Magic Tattoos (Rifts Atlantis) ability. A Monster-Shaping tattoo is also a major tattoo; it has no catalog row and is recorded in the Monster-Shaping Tattoos ability instead of a pick here. Added by a clan elder or alchemist, never more than two at a time and at least six months apart." }
    - { level: 13, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or instead two simple tattoos (animal or simple weapon), recorded in the Magic Tattoos (Rifts Atlantis) ability. A Monster-Shaping tattoo is also a major tattoo; it has no catalog row and is recorded in the Monster-Shaping Tattoos ability instead of a pick here. Added by a clan elder or alchemist, never more than two at a time and at least six months apart." }
    - { level: 14, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or instead two simple tattoos (animal or simple weapon), recorded in the Magic Tattoos (Rifts Atlantis) ability. A Monster-Shaping tattoo is also a major tattoo; it has no catalog row and is recorded in the Monster-Shaping Tattoos ability instead of a pick here. Added by a clan elder or alchemist, never more than two at a time and at least six months apart." }
    - { level: 15, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or instead two simple tattoos (animal or simple weapon), recorded in the Magic Tattoos (Rifts Atlantis) ability. A Monster-Shaping tattoo is also a major tattoo; it has no catalog row and is recorded in the Monster-Shaping Tattoos ability instead of a pick here. Added by a clan elder or alchemist, never more than two at a time and at least six months apart." }
special_abilities:
'), updated_at = datetime('now')
 WHERE class_id = 'atlantean-monster-hunter' AND deleted_at IS NULL AND instr(markdown, '  - { item_id: "tw-converted-energy-pistol", qty: 1 }
special_abilities:
') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'Never more than two at a time, and at least six months between pairs. The individual tattoos are described in Rifts Atlantis."', 'Never more than two at a time, and at least six months between pairs. The individual tattoos are described in Rifts Atlantis. Granted as tattoo spells: the two Marks, All Simple Weapons, Animals and Monsters outright (one row each; the second animal and second monster are images under the same row), then two magic weapons, three powers and one of any category as picks. The four Monster-Shaping tattoos have no catalog row and are recorded in the Monster-Shaping Tattoos ability."'), updated_at = datetime('now')
 WHERE class_id = 'atlantean-monster-hunter' AND deleted_at IS NULL AND instr(markdown, 'Never more than two at a time, and at least six months between pairs. The individual tattoos are described in Rifts Atlantis."') > 0;

UPDATE imported_classes SET markdown = replace(markdown, '|| TATTOOS follow the catalog''s convention (stone-master): magic tattoos are prose special abilities, there being no tattoo catalog. The 15 starting picks are listed by category; Monster-Shaping is a costing system by M.D.C. tier and stays prose. ', '|| TATTOOS: imported as prose special abilities, there being no tattoo catalog then. Rifts World Book 2: Atlantis (#1429) added the 32 tattoo-tradition spells, and ~021-monster-hunter-tattoos.sql granted them as undead-slayer does: the two Marks of Heritage and All Simple Weapons, Animals and Monsters as fixed spells (the book''s one simple weapon, two animals and two monsters; a second image adds no row), then starting picks of two magic weapons, three powers and one of any category, and one major tattoo per level 2-15. The Marks are granted to every Monster Hunter, human, ogre and Chiang-Ku included, because the stored M.D.C. and P.P.E. already count all 17 starting tattoos. Monster-Shaping is a costing system by M.D.C. tier with no named tattoos, so its four starting tattoos and any later ones stay prose. || RACE, later: the note that the catalog had no True Atlantean race went false with Atlantis''s true-atlantean R.C.C.; ~021-monster-hunter-tattoos.sql rewrote it. The class keeps only none rather than naming that R.C.C., as undead-slayer does: the race carries S.D.C. +70, P.P.E. +22 and the two Marks, all of which this class''s own pools and tattoos already count, so the pair would count them twice. '), updated_at = datetime('now')
 WHERE class_id = 'atlantean-monster-hunter' AND deleted_at IS NULL AND instr(markdown, '|| TATTOOS follow the catalog''s convention (stone-master): magic tattoos are prose special abilities, there being no tattoo catalog. The 15 starting picks are listed by category; Monster-Shaping is a costing system by M.D.C. tier and stays prose. ') > 0;

SELECT 'atlantean-monster-hunter: every new text is in' AS assertion, (instr(markdown, 'the catalog does hold a true-atlantean R.C.C.') > 0) + (instr(markdown, 'spell_traditions_allowed: ["tattoo"]') > 0) + (instr(markdown, 'Granted as tattoo spells: the two Marks') > 0) + (instr(markdown, 'granted them as undead-slayer does') > 0) AS got, 4 AS want
  FROM imported_classes WHERE class_id = 'atlantean-monster-hunter' AND deleted_at IS NULL;

SELECT 'atlantean-monster-hunter: every replaced text is gone' AS assertion, (instr(markdown, 'the catalog has no True Atlantean race') > 0) + (instr(markdown, 'follow the catalog''s convention (stone-master)') > 0) AS got, 0 AS want
  FROM imported_classes WHERE class_id = 'atlantean-monster-hunter' AND deleted_at IS NULL;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~021-monster-hunter-tattoos.sql');
