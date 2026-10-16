-- The True Sasquatch's creature row follows D-Bees of North America
-- (BOOK-INGEST-AUDIT F143, Canada part 3 of 4).
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~220-book-ingest-audit-f143-canada-sasquatch.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~220-book-ingest-audit-f143-canada-sasquatch.sql
--
-- The class true-sasquatch follows Rifts World Book 30: D-Bees of North
-- America (2007), printed 173-176, but its creatures row still cited Rifts
-- World Book 20: Canada printed 162-165 and carried its figures. By Nate's
-- ruling of 2026-10-04 the newest printing that STATES a figure wins, so the
-- row is UPDATED in place and moves its source_book; where D-Bees is silent,
-- Canada's figure stays (the S.D.C.-world figures, the city breakdown, the
-- diet). A complete line D-Bees restates without an item drops that item:
-- the Alignment line ("rare"), the R.C.C. Skills line (Canada's flat
-- percentages, the female's holistic medicine and first aid), the Magic line
-- ("never willing to learn it") and the Available O.C.C.s line. creatures has
-- no notes column, so each Canada figure that changed is kept in description
-- with its printed page.
--
-- Attacks: D-Bees prints four for an adult male, three for a female and two
-- for a youngster of 16 or younger. combat holds one number, and by Nate's
-- ruling of 2026-10-16 it is the male's 4; the female's and the youngster's
-- figures and the +1 at levels 2, 4, 7, 10 and 13 are in bonuses_note. The
-- other combat keys are the same in both books, so the key set is unchanged
-- and the row keeps its shape (F141). The new +2 Perception and the level 1
-- automatic dodge are in bonuses_note. I.S.P. is now printed, M.E. x2 for
-- both sexes, so isp is 'MEx2' (the noli-bushman shape in ~218) with each
-- sex's per-level dice in pools_note. The row has no stat_attacks, and
-- this script writes none.
--
-- Read off renders of both books (both at PDF offset +1). Guarded on the
-- row still citing Canada, so a re-run is a no-op. THIS SCRIPT CHANGES
-- PRODUCTION: one creatures row. The tilde number is claimed at merge.

UPDATE creatures
   SET alignment = 'Any, but typically Principled (45%), Scrupulous (35%), Unprincipled (15%), Anarchist (3%) or evil (any, 2%)',
       isp = 'MEx2',
       pools_note = 'M.D.C. is P.E. x2 plus 1D6 per level of experience. P.P.E. is the P.E. number plus 4D6, +6 per level. All Sasquatch are low-end Master Psychics: I.S.P. is the M.E. number x2, +1D8 per level for a male and +1D6+4 per level for a female. P.S. and P.E. are supernatural, and damage is as per Supernatural Strength. An attribute roll that comes up maximum (12 or 18) earns one extra die before the bonus is added. On S.D.C. worlds: Hit Points P.E. +1D6 per level, 1D4x10+30 S.D.C., Natural A.R. 7 (the A.R. is printed for S.D.C. worlds only). Average level 1D4+3 for NPCs; player characters start at level one.',
       combat = '{"attacks":4,"initiative":3,"parry":1,"pull_punch":5,"roll":2}',
       bonuses_note = 'Attacks per melee: an adult male starts with four, a female with three and a youngster (16 or younger) with two, +1 at levels 2, 4, 7, 10 and 13; the attacks figure above is the male''s. +2 on Perception Rolls, +3 to disarm. +1 to automatic dodge (costs no action) at levels 1, 2, 4, 6, 8, 10, 12 and 14. +2 to save vs poison, +5 to save vs disease, +2 vs possession and mind control; the Natural Abilities line, unchanged from Canada, still prints +2 to save vs disease and toxins. The bonus line prints pull punch twice, +5 and +4; +5 is kept. Fights only to escape and rarely kills for any reason. Vulnerabilities: spooked by machines and city life, and avoids them; its refusal to learn civilized ways or use M.D.C. weapons and armor is taken by some for primitive foolishness, and its shyness and gentleness can work against it.',
       skills_note = 'R.C.C. skills, most of them instinctive, printed as bonuses. Male: Camouflage (+40%), Climb (+20%), Land Navigation (24%, printed with no plus sign), Identify Plants and Fruits (+30%), Lore: Cattle & Animals (+20%), Prowl (+30%), Swimming (+10%), Track Animals (+20%), Track people (+20%, mainly to recognize tracks and avoid dangerous creatures and trouble with humanoids), Wilderness Survival (+40%), and W.P. Blunt or W.P. Staff. Female: Camouflage (+50%), Climb (+20%), Dance (+15%), Dowsing (+20%), Fishing (+20%), Identify Plants and Fruits (+45%), Land Navigation (26%, printed with no plus sign), Lore: Cattle & Animals (+20%), Prowl (+20%), Swimming (+20%), Track Animals (+10%), Track people (+20%) and Wilderness Survival (+40%). No other skills apply unless a Worldly Sasquatch. Most have no spoken language and no native tongue, but can learn one, typically American.',
       magic = 'None',
       psionics = 'Male: Empathic Transmission (6; Confusion, Fear and Love/Peacefulness only), Psionic Invisibility (10), Alter Aura (2), Deaden Senses (4), See the Invisible (4), Empathy (4), Sense Evil (2); Radiate Horror Factor (8) at level 2, Intuitive Combat (10) at level 4, Psychic Omni-Sight (15) at level 8. Female: Sense Dimensional Anomaly (4), Empathy (4), See Aura (6), See the Invisible (4), Sense Evil (2), Sense Time (2), Psychic Diagnosis (4), Psychic Purification (8), Psychic Surgery (14) and two Healing powers of choice; one more Healing power at levels 3, 6, 9 and 12, Bio-Regeneration (self; 6) at level 5 and one Sensitive power at level 8. Both: Special Telepathy with their own race.',
       life_span = '2D6+40 years; physically mature around age 16',
       habitat = 'Thickest in the Canadian Rockies of British Columbia and Alberta and the deep woods of Washington, Oregon and Montana; fewer in the Yukon, Idaho, Wyoming, Northern California and Colorado. Well over ten thousand in all, wandering in family groups of two to twelve',
       allies = 'Other Sasquatch and the Spirit Sasquatch; now and then an Indian Shaman, Druid, psychic or a kind adventurer who helps them, or characters of a good alignment',
       occ_note = 'Optional Player Character and NPC. Available O.C.C.s: none, unless a Worldly Sasquatch (D-Bees printed 176-177, a separate class for one that joins the wider world). Uses the Merc Soldier''s experience table. No cybernetics, no money and almost no gear. Slave market value 2D6x1,000 credits, mainly as an oddity and labor. A human or D-Bee child raised by them gets the same skills plus 1D4+1 from Wilderness and/or Physical, but none of the natural or psionic abilities; one who later becomes worldly may add a language (probably American +15%), two piloting skills, Horsemanship: General, two W.P.s and 1D4 Domestic and/or Technical skills, and 1D6 Secondary Skills at the next level.',
       description = 'The real Big Foot: a shy, gentle Stone Age cousin of humanity that walked over the Bering land bridge long ago and has hidden in the mountain forests ever since. The Rifts made it a minor Mega-Damage being, and it still answers any threat by slipping away. Canada printed 162-165, which this row followed until ~220, gave a life span of 50 years; two attacks at first level for every Sasquatch; automatic dodge from level 2 and no Perception bonus; only the +2 to save vs disease and toxins; no Master Psychic tier and no I.S.P.; flat skill figures (both sexes land navigation, wilderness survival and identify plants and fruits 90%, swim 65%; male climb 80%/50%, lore: animal/cattle, camouflage and prowl 74% +2% per level, track animals 55% and track humanoids 45% that do not improve; female fishing 80%, climb 70%/40% +2% per level, and holistic medicine, first aid, lore: animal/cattle, camouflage and prowl 60% +2% per level); the alignment as typically Principled, Scrupulous and Unprincipled, with Anarchist (3%) and evil (2%) rare; magic as none, never willing to learn it, though a Worldly Sasquatch may use TW and other magic items; Available O.C.C.s as none, with no experience table named; family groups of two to ten; English as the language a Sasquatch might learn; and no psionic costs, slave value, vulnerabilities line, good-alignment allies, or Horsemanship and Secondary Skills for a worldly foundling.',
       source_book = 'Rifts World Book 30: D-Bees of North America p.173-176'
 WHERE slug = 'true-sasquatch'
   AND source_book = 'Rifts World Book 20: Canada p.162-165';

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'the True Sasquatch cites D-Bees and not Canada' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'true-sasquatch'
   AND source_book = 'Rifts World Book 30: D-Bees of North America p.173-176';

SELECT 'the D-Bees figures landed' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'true-sasquatch'
   AND life_span LIKE '2D6+40 years%'
   AND json_extract(combat, '$.attacks') = 4
   AND isp = 'MEx2'
   AND magic = 'None'
   AND instr(bonuses_note, 'at levels 1, 2, 4, 6') > 0;

SELECT 'it keeps the Canada figures it replaced in its description' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'true-sasquatch'
   AND instr(description, 'which this row followed until ~220') > 0;

SELECT 'and it still owns no stat_attacks rows' AS assertion, count(*) AS got, 0 AS want
  FROM stat_attacks
 WHERE owner_kind = 'creature' AND owner_slug = 'true-sasquatch';

INSERT INTO data_script_runs (filename) VALUES ('~220-book-ingest-audit-f143-canada-sasquatch.sql');
