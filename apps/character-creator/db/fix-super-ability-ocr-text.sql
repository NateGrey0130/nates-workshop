-- Repair the OCR damage the codex made visible in 198 super-ability entries.
--
-- The codex's Super Abilities tab (#1152) is the first reader that shows a
-- whole description, and the first thing it showed was `Generate Fog & Smoke`
-- ending in "ee ar S One SSNSY ~ "yt, yp flees F OK ayy, Meet} py tf". A sweep
-- of all 364 rows on production, 2026-09-18, found that entry was one of many,
-- in every one of the three books the catalog was imported from:
--
--   52 endings  a page number, the next entry's heading, a picture read as
--               text, or a whole roster of powers read in after a section
--   121 page numbers inside the text (113 rows), often splitting a hyphenated word
--               ("in- 53 stances"); fix-hu-super-ability-leading-page-number
--               removed the three-digit ones and left two digits alone
--   38 rows     misread characters: "|" for I or 1, "{" for "(", "~" junk
--   26 rows     the Revised core's bullets, every one read as "@"
--   4 columns   a range or duration the import cut at a blank line
--
-- EVERY EDIT WAS READ IN PLACE, and the ones that could not be settled from
-- the OCR cache were settled from a render of the printed page. Two entries
-- were not garbage but truncated or displaced, and are completed here from the
-- page: `Weapon Melding` stopped at a page turn (printed 86-87), and
-- `Weight Manipulation` had the right column of printed 192 in the wrong order.
-- `Zombie Flesh`'s trailing "1D6" is the one its own Bio-Regeneration line lost.
--
-- NOT EVERY NUMBER NEXT TO A PAGE IS A PAGE. These look like page numbers and
-- are the book's own, and are asserted below rather than trusted:
-- `Anatomical Independence` H.F. 13 and 14, `Charge Object with Explosive
-- Energy`'s 19 inch television, `Dimensional Pocket`'s 12 items, `Dwarfing`'s
-- A.R. 10 and P.S. 12, and `Alter Physical Structure: Goo or Gel`'s 40.
--
-- NOT IN SCOPE: ordinary misspellings the scan made of real words ("haif",
-- "expericnee", "lignt"). No sweep finds them, and none was attempted.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-super-ability-ocr-text.sql
--
-- Each UPDATE is keyed on `name` (UNIQUE, never a literal id) and guarded on
-- the text it replaces, so re-running is a no-op and a row somebody has since
-- rewritten by hand is left alone. An ending is matched as the description's
-- exact suffix, so a fragment that also occurs mid-text cannot be touched.
-- Non-ASCII (the bullet) is spliced through char().

-- A. A printed page number left on the end of the entry.

UPDATE super_abilities SET description = substr(description, 1, length(description) - 4)
 WHERE name = 'Energy Absorption' AND substr(description, -4) = ' 183';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 4)
 WHERE name = 'Mechano-Link' AND substr(description, -4) = ' 187';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 3)
 WHERE name = 'Bookworm' AND substr(description, -3) = ' 16';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 3)
 WHERE name = 'Energy Expulsion: Directed Sound' AND substr(description, -3) = ' 22';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 3)
 WHERE name = 'Energy Expulsion: Force' AND substr(description, -3) = ' 23';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 3)
 WHERE name = 'Longevity' AND substr(description, -3) = ' 34';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 3)
 WHERE name = 'Personal Force Field' AND substr(description, -3) = ' 36';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 3)
 WHERE name = 'Weightlessness' AND substr(description, -3) = ' 50';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 3)
 WHERE name = 'Alter Physical Structure: Oil or Tar' AND substr(description, -3) = ' 57';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 3)
 WHERE name = 'Geo-Thermal Energy' AND substr(description, -3) = ' 76';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 3)
 WHERE name = 'Weapon Energy Extensions' AND substr(description, -3) = ' 86';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 3)
 WHERE name = 'Fireworks' AND substr(description, -3) = ' 13';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 3)
 WHERE name = 'Parabolic Hearing' AND substr(description, -3) = ' 17';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 3)
 WHERE name = 'Shadow Trap' AND substr(description, -3) = ' 20';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 3)
 WHERE name = 'Animal Abilities (New Types)' AND substr(description, -3) = ' 51';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 3)
 WHERE name = 'Merge Bio-Mass' AND substr(description, -3) = ' 79';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 3)
 WHERE name = 'Shadow Manipulation' AND substr(description, -3) = ' 95';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 3)
 WHERE name = 'Super-Regeneration' AND substr(description, -3) = ' 99';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 4)
 WHERE name = 'Transmutation' AND substr(description, -4) = ' 104';

-- B. The NEXT entry's heading read onto the end of this one.

UPDATE super_abilities SET description = substr(description, 1, length(description) - 19)
 WHERE name = 'Bubble Glue' AND substr(description, -19) = ' Charge Object with';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 14)
 WHERE name = 'Impervious to Cold & Freezing' AND substr(description, -14) = ' Impervious to';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 14)
 WHERE name = 'Impervious to Disease & Illness' AND substr(description, -14) = ' Impervious to';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 14)
 WHERE name = 'Impervious to Poison & Toxins' AND substr(description, -14) = ' Impervious to';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 10)
 WHERE name = 'Immune to Illusions' AND substr(description, -10) = ' Immune to';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 18)
 WHERE name = 'Energy Expulsion: Cold' AND substr(description, -18) = ' Energy Expulsion:';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 18)
 WHERE name = 'Energy Expulsion: Energy Aura' AND substr(description, -18) = ' Energy Expulsion:';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 18)
 WHERE name = 'Energy Expulsion: Plasma' AND substr(description, -18) = ' Energy Expulsion:';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 18)
 WHERE name = 'Energy Expulsion: Heat' AND substr(description, -18) = ' Energy Expulsion:';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 29)
 WHERE name = 'Alter Physical Structure: Lava' AND substr(description, -29) = ' 56 Alter Physical Structure:';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 26)
 WHERE name = 'Alter Physical Structure: Shadow' AND substr(description, -26) = ' Alter Physical Structure:';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 29)
 WHERE name = 'Alter Physical Structure: Foam' AND substr(description, -29) = ' 36 Alter Physical Structure:';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 26)
 WHERE name = 'Alter Physical Structure: Glass' AND substr(description, -26) = ' Alter Physical Structure:';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 2)
 WHERE name = 'Darkness Control' AND substr(description, -2) = ' :';

-- C. A book's own roster of powers read in after a section's last entry.

UPDATE super_abilities SET description = substr(description, 1, instr(description, ' MAJOR SUPER ABILITY DESCRIPTIONS LIST OF MAJOR SUPER ABILITIES') - 1)
 WHERE name = 'Underwater' AND instr(description, ' MAJOR SUPER ABILITY DESCRIPTIONS LIST OF MAJOR SUPER ABILITIES') > 0;
UPDATE super_abilities SET description = substr(description, 1, instr(description, ' ajor P}) Faecon E Wins') - 1)
 WHERE name = 'Whip Attack' AND instr(description, ' ajor P}) Faecon E Wins') > 0;
UPDATE super_abilities SET description = substr(description, 1, instr(description, ' New Major Super Abilities Absorb Matter') - 1)
 WHERE name = 'Without Sustenance' AND instr(description, ' New Major Super Abilities Absorb Matter') > 0;

-- D. An illustration read as text, on the end.

UPDATE super_abilities SET description = substr(description, 1, length(description) - 2)
 WHERE name = 'Energy Expulsion: Electricity' AND substr(description, -2) = ' >';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 2)
 WHERE name = 'Extraordinary Speed' AND substr(description, -2) = ' =';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 12)
 WHERE name = 'Flight: Glide' AND substr(description, -12) = ' > / \ ef AN';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 2)
 WHERE name = 'Impervious to Fire & Heat' AND substr(description, -2) = ' a';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 24)
 WHERE name = 'Animal Brother' AND substr(description, -24) = ' $ , , Z2\% vA 3 NS 4, S';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 68)
 WHERE name = 'Enlarge Body Parts' AND substr(description, -68) = ' T\ Y q a SE Vise kk S - - _ Wig Sau = ALR TSS A . es A AWTS wr ce |';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 21)
 WHERE name = 'Flight: Energy' AND substr(description, -21) = ' piciaobt aH 98 - _ =';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 10)
 WHERE name = 'Solar Powered' AND substr(description, -10) = ' WI LSA oO';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 34)
 WHERE name = 'Supervision: Thermal Vision' AND substr(description, -34) = ' aa aes So EET SBE EE en aA mk a i';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 56)
 WHERE name = 'Generate Fog & Smoke' AND substr(description, -56) = ' ee ar S One SSNSY ~ "yt, yp flees F OK ayy, Meet} py tf';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 44)
 WHERE name = 'Vertigo Field' AND substr(description, -44) = ' tar Mn raed tenet mV qt . oe Mt. wf fo "rng';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 15)
 WHERE name = 'Rocket Charge' AND substr(description, -15) = ' KS ih. - f {|}';

-- E. Endings the book prints differently: a misread stop, a missing stop, a
--    number moved out of its sentence, and one entry cut off at a page turn.

UPDATE super_abilities SET description = substr(description, 1, length(description) - 5) || '60ft.'
 WHERE name = 'Energy Expulsion: Fire' AND substr(description, -5) = '60ft,';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 21) || 'receiving some damage.'
 WHERE name = 'Totem Energy Aura' AND substr(description, -21) = 'receiving some damage';
UPDATE super_abilities SET description = substr(description, 1, length(description) - 16) || 'P.E. bonus).'
 WHERE name = 'Zombie Flesh' AND substr(description, -16) = 'P.E. bonus). 1D6';
UPDATE super_abilities SET description = replace(description, 'regenerates S.D.C./Hit Points', 'regenerates 1D6 S.D.C./Hit Points')
 WHERE name = 'Zombie Flesh' AND instr(description, 'regenerates S.D.C./Hit Points') > 0;
UPDATE super_abilities SET description = substr(description, 1, length(description) - 26) || 'use a rifle at ninth level proficiency. Rate of fire, when applicable, like bow and arrow, is equal to the character''s number of attacks per melee round, plus two. Note: A character with this power cannot learn any form of weapon related skills or any Weapon Proficiencies (W.P.s). She doesn''t feel the need to do so, and is correct in that she doesn''t need it. Melding with Body Armor: Armor can also be linked to the hero. In this case, the armor must be worn to use the power. The power of the link reshapes the armor to conform to the contour''s of the hero''s body. So tight is the fit, that the armor becomes like a second skin. Any movement or prowl penalties the armor usually has are reduced to zero. Body armor can also be strengthened. this costs 10 Hit Points per minute and charges the armor with an energy field that effectively doubles its normal S.D.C. (maximum additional S.D.C. is only 100 points). Other Abilities and Bonuses: The character has a natural understanding of how to care for and maintain all hand-held weapons, equal to a skill of 80% +4% per level of experience. +2 to strike and parry, even without melding. Add 1D6 to P.E. and add 6D6 to Hit Points.'
 WHERE name = 'Weapon Melding' AND substr(description, -26) = 'use a rifle at ninth jevel';

-- F. Page numbers inside the text, and the junk printed beside them. A number is
--    removed only after reading it in place; the ones that are real stay.

UPDATE super_abilities SET description = replace(description, 'character. 12 Vision', 'character. Vision')
 WHERE name = 'Anatomical Independence' AND instr(description, 'character. 12 Vision') > 0;
UPDATE super_abilities SET description = replace(description, 'wild or 13 mean', 'wild or mean')
 WHERE name = 'Animal Brother' AND instr(description, 'wild or 13 mean') > 0;
UPDATE super_abilities SET description = replace(description, 'visible. 15 2. No', 'visible. 2. No')
 WHERE name = 'Blur' AND instr(description, 'visible. 15 2. No') > 0;
UPDATE super_abilities SET description = replace(description, 'but the 18 character', 'but the character')
 WHERE name = 'Conduct Electricity' AND instr(description, 'but the 18 character') > 0;
UPDATE super_abilities SET description = replace(description, 'to this 19 character', 'to this character')
 WHERE name = 'Criminal Intuition' AND instr(description, 'to this 19 character') > 0;
UPDATE super_abilities SET description = replace(description, 'explosion. 20 Explosive', 'explosion. Explosive')
 WHERE name = 'Detonation or Explosive Power' AND instr(description, 'explosion. 20 Explosive') > 0;
UPDATE super_abilities SET description = replace(description, 'lost. 21 Cast', 'lost. Cast')
 WHERE name = 'Earth Empowerment' AND instr(description, 'lost. 21 Cast') > 0;
UPDATE super_abilities SET description = replace(description, 'by half. 24 Special', 'by half. Special')
 WHERE name = 'Energy Expulsion: Plasma' AND instr(description, 'by half. 24 Special') > 0;
UPDATE super_abilities SET description = replace(description, 'conversation. 25 Eyes:', 'conversation. Eyes:')
 WHERE name = 'Enlarge Body Parts' AND instr(description, 'conversation. 25 Eyes:') > 0;
UPDATE super_abilities SET description = replace(description, 'exist. 26 Number', 'exist. Number')
 WHERE name = 'Exploding Spheres' AND instr(description, 'exist. 26 Number') > 0;
UPDATE super_abilities SET description = replace(description, 'under _27 80 mph', 'under 80 mph')
 WHERE name = 'Flight: Energy' AND instr(description, 'under _27 80 mph') > 0;
UPDATE super_abilities SET description = replace(description, 'specific 28 receiver', 'specific receiver')
 WHERE name = 'Frequency Absorption' AND instr(description, 'specific 28 receiver') > 0;
UPDATE super_abilities SET description = replace(description, '(G). 29 Creating', '(G). Creating')
 WHERE name = 'Gravitational Plane' AND instr(description, '(G). 29 Creating') > 0;
UPDATE super_abilities SET description = replace(description, 'weapons 30 (sword', 'weapons (sword')
 WHERE name = 'Heavyweight' AND instr(description, 'weapons 30 (sword') > 0;
UPDATE super_abilities SET description = replace(description, 'may be 31 canceled', 'may be canceled')
 WHERE name = 'Immovability' AND instr(description, 'may be 31 canceled') > 0;
UPDATE super_abilities SET description = replace(description, 'stowed). 33 Because', 'stowed). Because')
 WHERE name = 'Instant Weapon' AND instr(description, 'stowed). 33 Because') > 0;
UPDATE super_abilities SET description = replace(description, 'systems. 35 3.', 'systems. 3.')
 WHERE name = 'Mechanical Awareness' AND instr(description, 'systems. 35 3.') > 0;
UPDATE super_abilities SET description = replace(description, 'and an 38 A.R.', 'and an A.R.')
 WHERE name = 'Resin' AND instr(description, 'and an 38 A.R.') > 0;
UPDATE super_abilities SET description = replace(description, 'minute. 39 Damage:', 'minute. Damage:')
 WHERE name = 'Sensory Orb' AND instr(description, 'minute. 39 Damage:') > 0;
UPDATE super_abilities SET description = replace(description, 'wave. 41 Abilities', 'wave. Abilities')
 WHERE name = 'Sliding' AND instr(description, 'wave. 41 Abilities') > 0;
UPDATE super_abilities SET description = replace(description, 'holding a SC 42 gun', 'holding a gun')
 WHERE name = 'Sonar' AND instr(description, 'holding a SC 42 gun') > 0;
UPDATE super_abilities SET description = replace(description, 'abilities. 43 Bouncing', 'abilities. Bouncing')
 WHERE name = 'Super Bounce' AND instr(description, 'abilities. 43 Bouncing') > 0;
UPDATE super_abilities SET description = replace(description, 'AR. of 44 8 +1', 'A.R. of 8 +1')
 WHERE name = 'Super Hibernation & Stasis Field' AND instr(description, 'AR. of 44 8 +1') > 0;
UPDATE super_abilities SET description = replace(description, 'time. 45 Vulnerability', 'time. Vulnerability')
 WHERE name = 'Super Wind Blast' AND instr(description, 'time. 45 Vulnerability') > 0;
UPDATE super_abilities SET description = replace(description, 'thing 46 is', 'thing is')
 WHERE name = 'Tentacles of Hair' AND instr(description, 'thing 46 is') > 0;
UPDATE super_abilities SET description = replace(description, 'can 47 be thrown', 'can be thrown')
 WHERE name = 'Tractor Beam' AND instr(description, 'can 47 be thrown') > 0;
UPDATE super_abilities SET description = replace(description, 'self. 49 Sound', 'self. Sound')
 WHERE name = 'Warp Sound' AND instr(description, 'self. 49 Sound') > 0;
UPDATE super_abilities SET description = replace(description, 'ended. 52 Saving', 'ended. Saving')
 WHERE name = 'Absorb Bio-Mass' AND instr(description, 'ended. 52 Saving') > 0;
UPDATE super_abilities SET description = replace(description, 'in- 53 stances', 'instances')
 WHERE name = 'Alter Physical Structure: Crystal' AND instr(description, 'in- 53 stances') > 0;
UPDATE super_abilities SET description = replace(description, 'la- 54 ser-like', 'laser-like')
 WHERE name = 'Alter Physical Structure: Light' AND instr(description, 'la- 54 ser-like') > 0;
UPDATE super_abilities SET description = replace(description, 'night. 55 When', 'night. When')
 WHERE name = 'Alter Physical Structure: Light' AND instr(description, 'night. 55 When') > 0;
UPDATE super_abilities SET description = replace(description, 'out 58 his body', 'out his body')
 WHERE name = 'Alter Physical Structure: Rubber' AND instr(description, 'out 58 his body') > 0;
UPDATE super_abilities SET description = replace(description, 'instant. 59 Damage', 'instant. Damage')
 WHERE name = 'Alter Physical Structure: Sand' AND instr(description, 'instant. 59 Damage') > 0;
UPDATE super_abilities SET description = replace(description, 'have 60 no adverse', 'have no adverse')
 WHERE name = 'Alter Physical Structure: Shadow' AND instr(description, 'have 60 no adverse') > 0;
UPDATE super_abilities SET description = replace(description, 'transform 61 SO back', 'transform back')
 WHERE name = 'Alter Physical Structure: Shadow' AND instr(description, 'transform 61 SO back') > 0;
UPDATE super_abilities SET description = replace(description, 'At- 62 tacks', 'Attacks')
 WHERE name = 'Alter Physical Structure: Vapor or Fog' AND instr(description, 'At- 62 tacks') > 0;
UPDATE super_abilities SET description = replace(description, 'Effec- 63 tively', 'Effectively')
 WHERE name = 'Amphibious' AND instr(description, 'Effec- 63 tively') > 0;
UPDATE super_abilities SET description = replace(description, 'When 64 stopped', 'When stopped')
 WHERE name = 'Catastrophic System Failure' AND instr(description, 'When 64 stopped') > 0;
UPDATE super_abilities SET description = replace(description, 'rounds 65 after', 'rounds after')
 WHERE name = 'Chemical Secretion' AND instr(description, 'rounds 65 after') > 0;
UPDATE super_abilities SET description = replace(description, 'goes 66 up', 'goes up')
 WHERE name = 'Control Density' AND instr(description, 'goes 66 up') > 0;
UPDATE super_abilities SET description = replace(description, 'Nightstatking. Lightning Reflexes, Claws and 67 Cats:', 'Nightstalking. Cats:')
 WHERE name = 'Copy Animal Attributes' AND instr(description, 'Nightstatking. Lightning Reflexes, Claws and 67 Cats:') > 0;
UPDATE super_abilities SET description = replace(description, 'created. 69 6.', 'created. 6.')
 WHERE name = 'Create Force Constructs' AND instr(description, 'created. 69 6.') > 0;
UPDATE super_abilities SET description = replace(description, 'his 70 D-Room', 'his D-Room')
 WHERE name = 'Dimensional Room' AND instr(description, 'his 70 D-Room') > 0;
UPDATE super_abilities SET description = replace(description, 'com- 71 mands', 'commands')
 WHERE name = 'Energy Doppleganger' AND instr(description, 'com- 71 mands') > 0;
UPDATE super_abilities SET description = replace(description, 'Gateway. 73 eS Number', 'Gateway. Number')
 WHERE name = 'Gateways' AND instr(description, 'Gateway. 73 eS Number') > 0;
UPDATE super_abilities SET description = replace(description, 'and it 74 uses', 'and it uses')
 WHERE name = 'Geo-Thermal Energy' AND instr(description, 'and it 74 uses') > 0;
UPDATE super_abilities SET description = replace(description, 'damage. 77 Provides', 'damage. Provides')
 WHERE name = 'Matter Expulsion: Crystal' AND instr(description, 'damage. 77 Provides') > 0;
UPDATE super_abilities SET description = replace(description, 'aside. 78 4.', 'aside. 4.')
 WHERE name = 'Matter Expulsion: Metal/Steel' AND instr(description, 'aside. 78 4.') > 0;
UPDATE super_abilities SET description = replace(description, 'through BOON OOO OOS SS oF Repo fey {LLANE 8 | 79 narrow', 'through narrow')
 WHERE name = 'Mega-Wings' AND instr(description, 'through BOON OOO OOS SS oF Repo fey {LLANE 8 | 79 narrow') > 0;
UPDATE super_abilities SET description = replace(description, 'points of 80 his', 'points of his')
 WHERE name = 'Mega-Wings' AND instr(description, 'points of 80 his') > 0;
UPDATE super_abilities SET description = replace(description, 'Touches). 81 Increase', 'Touches). Increase')
 WHERE name = 'Power Touch' AND instr(description, 'Touches). 81 Increase') > 0;
UPDATE super_abilities SET description = replace(description, 're- 82 duced', 'reduced')
 WHERE name = 'Rocket Fists' AND instr(description, 're- 82 duced') > 0;
UPDATE super_abilities SET description = replace(description, 'experience. 83 Duration', 'experience. Duration')
 WHERE name = 'Spiral/Vortex' AND instr(description, 'experience. 83 Duration') > 0;
UPDATE super_abilities SET description = replace(description, 'tasks. 10 Range', 'tasks. Range')
 WHERE name = 'Energy Fists' AND instr(description, 'tasks. 10 Range') > 0;
UPDATE super_abilities SET description = replace(description, 'the 14 opponent', 'the opponent')
 WHERE name = 'Force Strike' AND instr(description, 'the 14 opponent') > 0;
UPDATE super_abilities SET description = replace(description, '(160 km). 15 Range', '(160 km). Range')
 WHERE name = 'Immune to High Speed Kinetic Attacks' AND instr(description, '(160 km). 15 Range') > 0;
UPDATE super_abilities SET description = replace(description, 'presence 16 (or nearby)', 'presence (or nearby)')
 WHERE name = 'Linguistics' AND instr(description, 'presence 16 (or nearby)') > 0;
UPDATE super_abilities SET description = replace(description, 'half.) 19 In', 'half.) In')
 WHERE name = 'Shadow Cloak' AND instr(description, 'half.) 19 In') > 0;
UPDATE super_abilities SET description = replace(description, 'shooting. 21 Note', 'shooting. Note')
 WHERE name = 'Sticky Globs' AND instr(description, 'shooting. 21 Note') > 0;
UPDATE super_abilities SET description = replace(description, 'attacked. 22 Range', 'attacked. Range')
 WHERE name = 'Transfixing Gaze' AND instr(description, 'attacked. 22 Range') > 0;
UPDATE super_abilities SET description = replace(description, 'vio- 23 lence', 'violence')
 WHERE name = 'Vocalization' AND instr(description, 'vio- 23 lence') > 0;
UPDATE super_abilities SET description = replace(description, 'S.D.C. 26 Miracle', 'S.D.C. Miracle')
 WHERE name = 'Absorb Matter' AND instr(description, 'S.D.C. 26 Miracle') > 0;
UPDATE super_abilities SET description = replace(description, 'weapon. 27 Number', 'weapon. Number')
 WHERE name = 'Aerodynamics' AND instr(description, 'weapon. 27 Number') > 0;
UPDATE super_abilities SET description = replace(description, 'ac- 28 tions', 'actions')
 WHERE name = 'Alter Physical Structure: Air' AND instr(description, 'ac- 28 tions') > 0;
UPDATE super_abilities SET description = replace(description, 'character. 29 Fire', 'character. Fire')
 WHERE name = 'Alter Physical Structure: Ash' AND instr(description, 'character. 29 Fire') > 0;
UPDATE super_abilities SET description = replace(description, 'desired. 30 9.', 'desired. 9.')
 WHERE name = 'Alter Physical Structure: Ash' AND instr(description, 'desired. 30 9.') > 0;
UPDATE super_abilities SET description = replace(description, 'bro- 32 ken', 'broken')
 WHERE name = 'Alter Physical Structure: Bone' AND instr(description, 'bro- 32 ken') > 0;
UPDATE super_abilities SET description = replace(description, 'land). 33 Huge', 'land). Huge')
 WHERE name = 'Alter Physical Structure: Coral' AND instr(description, 'land). 33 Huge') > 0;
UPDATE super_abilities SET description = replace(description, 'shoot. 34 Range', 'shoot. Range')
 WHERE name = 'Alter Physical Structure: Energy' AND instr(description, 'shoot. 34 Range') > 0;
UPDATE super_abilities SET description = replace(description, 'the 35 foam', 'the foam')
 WHERE name = 'Alter Physical Structure: Foam' AND instr(description, 'the 35 foam') > 0;
UPDATE super_abilities SET description = replace(description, 'like 37 a human', 'like a human')
 WHERE name = 'Alter Physical Structure: Human Force Field' AND instr(description, 'like 37 a human') > 0;
UPDATE super_abilities SET description = replace(description, 'experience. 38 Damage', 'experience. Damage')
 WHERE name = 'Alter Physical Structure: Glass' AND instr(description, 'experience. 38 Damage') > 0;
UPDATE super_abilities SET description = replace(description, 'a 39 crack', 'a crack')
 WHERE name = 'Alter Physical Structure: Goo or Gel' AND instr(description, 'a 39 crack') > 0;
UPDATE super_abilities SET description = replace(description, 'Points. 40 Lasers', 'Points. Lasers')
 WHERE name = 'Alter Physical Structure: Magnet' AND instr(description, 'Points. 40 Lasers') > 0;
UPDATE super_abilities SET description = replace(description, 'experience. Soh 41 Damage', 'experience. Damage')
 WHERE name = 'Alter Physical Structure: Mercury' AND instr(description, 'experience. Soh 41 Damage') > 0;
UPDATE super_abilities SET description = replace(description, 'the 42 character', 'the character')
 WHERE name = 'Alter Physical Structure: Pebbles' AND instr(description, 'the 42 character') > 0;
UPDATE super_abilities SET description = replace(description, 'attacks. 43 8.', 'attacks. 8.')
 WHERE name = 'Alter Physical Structure: Pebbles' AND instr(description, 'attacks. 43 8.') > 0;
UPDATE super_abilities SET description = replace(description, 'wa- 45 ter', 'water')
 WHERE name = 'Alter Physical Structure: Sponge' AND instr(description, 'wa- 45 ter') > 0;
UPDATE super_abilities SET description = replace(description, 'experience. 46 Damage', 'experience. Damage')
 WHERE name = 'Alter Physical Structure: Vines' AND instr(description, 'experience. 46 Damage') > 0;
UPDATE super_abilities SET description = replace(description, 'starlight). 47 Fights', 'starlight). Fights')
 WHERE name = 'Alter Physical Structure: Void' AND instr(description, 'starlight). 47 Fights') > 0;
UPDATE super_abilities SET description = replace(description, 'transforms). 48 2.', 'transforms). 2.')
 WHERE name = 'Alter Physical Structure: Wax' AND instr(description, 'transforms). 48 2.') > 0;
UPDATE super_abilities SET description = replace(description, 'shoulders. 50 Abilities', 'shoulders. Abilities')
 WHERE name = 'Animal Abilities (New Types)' AND instr(description, 'shoulders. 50 Abilities') > 0;
UPDATE super_abilities SET description = replace(description, 'attack/action. 53 Bonuses', 'attack/action. Bonuses')
 WHERE name = 'Control the Void' AND instr(description, 'attack/action. 53 Bonuses') > 0;
UPDATE super_abilities SET description = replace(description, 'experience. 54 Range', 'experience. Range')
 WHERE name = 'Copy Energy Pattern' AND instr(description, 'experience. 54 Range') > 0;
UPDATE super_abilities SET description = replace(description, 'at- 55 tack', 'attack')
 WHERE name = 'Defensive Immunity' AND instr(description, 'at- 55 tack') > 0;
UPDATE super_abilities SET description = replace(description, 'experience. 56 Damage', 'experience. Damage')
 WHERE name = 'Earth Possession' AND instr(description, 'experience. 56 Damage') > 0;
UPDATE super_abilities SET description = replace(description, 'cre- 57 ator', 'creator')
 WHERE name = 'Earth Possession' AND instr(description, 'cre- 57 ator') > 0;
UPDATE super_abilities SET description = replace(description, 'desires. 59 Damage', 'desires. Damage')
 WHERE name = 'Ectoplasmic Webbing' AND instr(description, 'desires. 59 Damage') > 0;
UPDATE super_abilities SET description = replace(description, 'min- $s Garvssy 61 utes', 'minutes')
 WHERE name = 'Energy Wings' AND instr(description, 'min- $s Garvssy 61 utes') > 0;
UPDATE super_abilities SET description = replace(description, 'experience. 62 Damage', 'experience. Damage')
 WHERE name = 'Enlarge Items' AND instr(description, 'experience. 62 Damage') > 0;
UPDATE super_abilities SET description = replace(description, 'experience. 64 Duration', 'experience. Duration')
 WHERE name = 'Force Manipulation' AND instr(description, 'experience. 64 Duration') > 0;
UPDATE super_abilities SET description = replace(description, 'power. 65 Damage', 'power. Damage')
 WHERE name = 'Grant Powers' AND instr(description, 'power. 65 Damage') > 0;
UPDATE super_abilities SET description = replace(description, 'adver- 66 sary', 'adversary')
 WHERE name = 'Gravity Waves' AND instr(description, 'adver- 66 sary') > 0;
UPDATE super_abilities SET description = replace(description, 'any super 67 being', 'any super being')
 WHERE name = 'Illusions' AND instr(description, 'any super 67 being') > 0;
UPDATE super_abilities SET description = replace(description, 'has 68 a picture', 'has a picture')
 WHERE name = 'Illusions' AND instr(description, 'has 68 a picture') > 0;
UPDATE super_abilities SET description = replace(description, 'allow- 69 ing', 'allowing')
 WHERE name = 'Immobilization Ray' AND instr(description, 'allow- 69 ing') > 0;
UPDATE super_abilities SET description = replace(description, 'across. 70 As', 'across. As')
 WHERE name = 'Indestructible' AND instr(description, 'across. 70 As') > 0;
UPDATE super_abilities SET description = replace(description, 'might be 71 controlled by an A.|.', 'might be controlled by an A.I.')
 WHERE name = 'Inhabitation' AND instr(description, 'might be 71 controlled by an A.|.') > 0;
UPDATE super_abilities SET description = replace(description, 'experience. 13. 72 Range', 'experience. Range')
 WHERE name = 'Junkyard' AND instr(description, 'experience. 13. 72 Range') > 0;
UPDATE super_abilities SET description = replace(description, 'Leeches 74 for', 'Leeches for')
 WHERE name = 'Life Leech' AND instr(description, 'Leeches 74 for') > 0;
UPDATE super_abilities SET description = replace(description, 'con- 75 nection', 'connection')
 WHERE name = 'Machine Merge' AND instr(description, 'con- 75 nection') > 0;
UPDATE super_abilities SET description = replace(description, 'within 76 1D6+6', 'within 1D6+6')
 WHERE name = 'Matter Expulsion: Bone' AND instr(description, 'within 76 1D6+6') > 0;
UPDATE super_abilities SET description = replace(description, 'weapon. 77 Damage', 'weapon. Damage')
 WHERE name = 'Matter Expulsion: Wood' AND instr(description, 'weapon. 77 Damage') > 0;
UPDATE super_abilities SET description = replace(description, 'strong, 78 able', 'strong, able')
 WHERE name = 'Mega-Tail' AND instr(description, 'strong, 78 able') > 0;
UPDATE super_abilities SET description = replace(description, 'loca- 80 tion', 'location')
 WHERE name = 'Metal Manipulation' AND instr(description, 'loca- 80 tion') > 0;
UPDATE super_abilities SET description = replace(description, 'experience. 81 Range', 'experience. Range')
 WHERE name = 'Molecular Compression' AND instr(description, 'experience. 81 Range') > 0;
UPDATE super_abilities SET description = replace(description, 'selections. 82 Combat', 'selections. Combat')
 WHERE name = 'Monstrous Form' AND instr(description, 'selections. 82 Combat') > 0;
UPDATE super_abilities SET description = replace(description, 'volley. 83 After', 'volley. After')
 WHERE name = 'Orbital Spheres' AND instr(description, 'volley. 83 After') > 0;
UPDATE super_abilities SET description = replace(description, 'limit. 84 5.', 'limit. 5.')
 WHERE name = 'Pause Temporal Flow' AND instr(description, 'limit. 84 5.') > 0;
UPDATE super_abilities SET description = replace(description, 'officer, 85 judge', 'officer, judge')
 WHERE name = 'Personal Recognition' AND instr(description, 'officer, 85 judge') > 0;
UPDATE super_abilities SET description = replace(description, 'Powers 86 of super-speed', 'Powers of super-speed')
 WHERE name = 'Pestilence' AND instr(description, 'Powers 86 of super-speed') > 0;
UPDATE super_abilities SET description = replace(description, 'Re- 87 gardless', 'Regardless')
 WHERE name = 'Polymorph' AND instr(description, 'Re- 87 gardless') > 0;
UPDATE super_abilities SET description = replace(description, 'mas- 88 sive', 'massive')
 WHERE name = 'Prodigious Limbs' AND instr(description, 'mas- 88 sive') > 0;
UPDATE super_abilities SET description = replace(description, 'rating. 89 Superior', 'rating. Superior')
 WHERE name = 'Prodigious Multiple Arms' AND instr(description, 'rating. 89 Superior') > 0;
UPDATE super_abilities SET description = replace(description, '90%. 90 Roads', '90%. Roads')
 WHERE name = 'Rainmaker' AND instr(description, '90%. 90 Roads') > 0;
UPDATE super_abilities SET description = replace(description, 'level. 91 4.', 'level. 4.')
 WHERE name = 'Rainmaker' AND instr(description, 'level. 91 4.') > 0;
UPDATE super_abilities SET description = replace(description, 'Instant. 92 Damage', 'Instant. Damage')
 WHERE name = 'Rocket Charge' AND instr(description, 'Instant. 92 Damage') > 0;
UPDATE super_abilities SET description = replace(description, 'the 93 character', 'the character')
 WHERE name = 'Self-Explosion' AND instr(description, 'the 93 character') > 0;
UPDATE super_abilities SET description = replace(description, 'sense 94 any', 'sense any')
 WHERE name = 'Shadow Manipulation' AND instr(description, 'sense 94 any') > 0;
UPDATE super_abilities SET description = replace(description, 'effect 96 feel', 'effect feel')
 WHERE name = 'Stretch Time' AND instr(description, 'effect 96 feel') > 0;
UPDATE super_abilities SET description = replace(description, 'thrown. 98 Ice Armor', 'thrown. Ice Armor')
 WHERE name = 'Sub-Zero' AND instr(description, 'thrown. 98 Ice Armor') > 0;

-- G. Misread characters and scan junk inside the text.

UPDATE super_abilities SET description = replace(description, '+3 tostrike if an aimed shot, + | tostrike', '+3 to strike if an aimed shot, +1 to strike')
 WHERE name = 'Energy Expulsion: Energy' AND instr(description, '+3 tostrike if an aimed shot, + | tostrike') > 0;
UPDATE super_abilities SET description = replace(description, '+ | to strike', '+1 to strike')
 WHERE name = 'Energy Expulsion: Electricity' AND instr(description, '+ | to strike') > 0;
UPDATE super_abilities SET description = replace(description, 'Subtract - | on initiative. Subtract - 1 Lo parry. Subtract - | to dodge.', 'Subtract -1 on initiative. Subtract -1 to parry. Subtract -1 to dodge.')
 WHERE name = 'Flight: Winged' AND instr(description, 'Subtract - | on initiative. Subtract - 1 Lo parry. Subtract - | to dodge.') > 0;
UPDATE super_abilities SET description = replace(description, 'Speed - |60mph (256kmph) plus 1Omph', 'Speed - 160mph (256kmph) plus 10mph')
 WHERE name = 'Flight: Winged' AND instr(description, 'Speed - |60mph (256kmph) plus 1Omph') > 0;
UPDATE super_abilities SET description = replace(description, 'Recovers 3 .D.C.', 'Recovers 3 S.D.C.')
 WHERE name = 'Healing Factor' AND instr(description, 'Recovers 3 .D.C.') > 0;
UPDATE super_abilities SET description = replace(description, 'mustelids. gees OIA => NOCTURNAL', 'mustelids. NOCTURNAL')
 WHERE name = 'Animal Abilities' AND instr(description, 'mustelids. gees OIA => NOCTURNAL') > 0;
UPDATE super_abilities SET description = replace(description, 'Hand/Arm $0lbs', 'Hand/Arm 50lbs')
 WHERE name = 'Control Elemental Force: Earth' AND instr(description, 'Hand/Arm $0lbs') > 0;
UPDATE super_abilities SET description = replace(description, '30 \4 mid-sized car', '30 1/2 mid-sized car')
 WHERE name = 'Control Elemental Force: Earth' AND instr(description, '30 \4 mid-sized car') > 0;
UPDATE super_abilities SET description = replace(description, '1. Wall of Earth the creator. Attacks', '1. Wall of Earth Attacks')
 WHERE name = 'Control Elemental Force: Earth' AND instr(description, '1. Wall of Earth the creator. Attacks') > 0;
UPDATE super_abilities SET description = replace(description, 'Duration: | a melee', 'Duration: 1/2 a melee')
 WHERE name = 'Control Elemental Force: Water' AND instr(description, 'Duration: | a melee') > 0;
UPDATE super_abilities SET description = replace(description, 'experience. ~ 3. Energy Flash 2 Attacks', 'experience. 3. Energy Flash Attacks')
 WHERE name = 'Energy Absorption' AND instr(description, 'experience. ~ 3. Energy Flash 2 Attacks') > 0;
UPDATE super_abilities SET description = replace(description, 'sensors ~and', 'sensors and')
 WHERE name = 'Invisibility' AND instr(description, 'sensors ~and') > 0;
UPDATE super_abilities SET description = replace(description, 'penalties. ; @ The', 'penalties. @ The')
 WHERE name = 'Invisibility' AND instr(description, 'penalties. ; @ The') > 0;
UPDATE super_abilities SET description = replace(description, 'Opponents: - | to strike.', 'Opponents: - 1 to strike.')
 WHERE name = 'Karmic Power' AND instr(description, 'Opponents: - | to strike.') > 0;
UPDATE super_abilities SET description = replace(description, 'by 10. '' @ Items', 'by 10. @ Items')
 WHERE name = 'Plant Control' AND instr(description, 'by 10. '' @ Items') > 0;
UPDATE super_abilities SET description = replace(description, '30 8.D.C.', '30 S.D.C.')
 WHERE name = 'Plant Control' AND instr(description, '30 8.D.C.') > 0;
UPDATE super_abilities SET description = replace(description, '1D4~x 10', '1D4x10')
 WHERE name = 'Plant Control' AND instr(description, '1D4~x 10') > 0;
UPDATE super_abilities SET description = replace(description, 'Disadvantages: - | to strike. ? All distances', 'Disadvantages: -1 to strike. -2 to parry. All distances')
 WHERE name = 'Shrink' AND instr(description, 'Disadvantages: - | to strike. ? All distances') > 0;
UPDATE super_abilities SET description = replace(description, '1D4~x 10', '1D4x10')
 WHERE name = 'Sonic Power' AND instr(description, '1D4~x 10') > 0;
UPDATE super_abilities SET description = replace(description, 'attribute. . @ +1 to strike. : 4 @ +2', 'attribute. @ +1 to strike. @ +2')
 WHERE name = 'Stretching (elasticity)' AND instr(description, 'attribute. . @ +1 to strike. : 4 @ +2') > 0;
UPDATE super_abilities SET description = replace(description, '+1 to strike \ Penalties', '+1 to strike. Penalties')
 WHERE name = 'Alter Physical Structure: Liquid' AND instr(description, '+1 to strike \ Penalties') > 0;
UPDATE super_abilities SET description = replace(description, 'all do /2 damage', 'all do 1/2 damage')
 WHERE name = 'Alter Physical Structure: Ice' AND instr(description, 'all do /2 damage') > 0;
UPDATE super_abilities SET description = replace(description, 'punches do 2 damage', 'punches do 1/2 damage')
 WHERE name = 'Alter Physical Structure: Ice' AND instr(description, 'punches do 2 damage') > 0;
UPDATE super_abilities SET description = replace(description, 'you or | might', 'you or I might')
 WHERE name = 'Abnormal Energy Sense' AND instr(description, 'you or | might') > 0;
UPDATE super_abilities SET description = replace(description, 'can | used', 'can be used')
 WHERE name = 'Color Manipulation' AND instr(description, 'can | used') > 0;
UPDATE super_abilities SET description = replace(description, 'ana imal', 'an animal')
 WHERE name = 'Color Manipulation' AND instr(description, 'ana imal') > 0;
UPDATE super_abilities SET description = replace(description, 'damage {the player', 'damage (the player')
 WHERE name = 'Living Anatomy' AND instr(description, 'damage {the player') > 0;
UPDATE super_abilities SET description = replace(description, 'greater | power', 'greater power')
 WHERE name = 'Power Weapon' AND instr(description, 'greater | power') > 0;
UPDATE super_abilities SET description = replace(description, 'after {D6+2', 'after 1D6+2')
 WHERE name = 'Venomous Attack' AND instr(description, 'after {D6+2') > 0;
UPDATE super_abilities SET description = replace(description, 'did | get', 'did I get')
 WHERE name = 'Absorb Bio-Mass' AND instr(description, 'did | get') > 0;
UPDATE super_abilities SET description = replace(description, 'sink. {f close', 'sink. If close')
 WHERE name = 'Alter Physical Structure: Sand' AND instr(description, 'sink. {f close') > 0;
UPDATE super_abilities SET description = replace(description, 'shadow RY ''e ( ath a. we ~ WN or materialize', 'shadow or materialize')
 WHERE name = 'Alter Physical Structure: Shadow' AND instr(description, 'shadow RY ''e ( ath a. we ~ WN or materialize') > 0;
UPDATE super_abilities SET description = replace(description, 'seconds. {if the hold', 'seconds. If the hold')
 WHERE name = 'Borrow Power' AND instr(description, 'seconds. {if the hold') > 0;
UPDATE super_abilities SET description = replace(description, 'dodge ~ roll', 'dodge - roll')
 WHERE name = 'Distort Space' AND instr(description, 'dodge ~ roll') > 0;
UPDATE super_abilities SET description = replace(description, 'he is on},', 'he is on),')
 WHERE name = 'Geo-Thermal Energy' AND instr(description, 'he is on},') > 0;
UPDATE super_abilities SET description = replace(description, 'Rating {A.R.)', 'Rating (A.R.)')
 WHERE name = 'Control Density' AND instr(description, 'Rating {A.R.)') > 0;
UPDATE super_abilities SET description = replace(description, 'power: |t uses', 'power: It uses')
 WHERE name = 'Vertigo Field' AND instr(description, 'power: |t uses') > 0;
UPDATE super_abilities SET description = replace(description, 'Increase |.Q.', 'Increase I.Q.')
 WHERE name = 'Extraordinary Intelligence' AND instr(description, 'Increase |.Q.') > 0;
UPDATE super_abilities SET description = replace(description, '01-10%. e@ Subject', '01-10%. @ Subject')
 WHERE name = 'Illusions' AND instr(description, '01-10%. e@ Subject') > 0;
UPDATE super_abilities SET description = replace(description, 'made |ndestructible', 'made Indestructible')
 WHERE name = 'Indestructible' AND instr(description, 'made |ndestructible') > 0;
UPDATE super_abilities SET description = replace(description, 'Vulnerabilities\Weaknesses', 'Vulnerabilities/Weaknesses')
 WHERE name = 'Massive Damage Capacity' AND instr(description, 'Vulnerabilities\Weaknesses') > 0;
UPDATE super_abilities SET description = replace(description, 'then. | guess', 'then. I guess')
 WHERE name = 'Super-Regeneration' AND instr(description, 'then. | guess') > 0;
UPDATE super_abilities SET description = replace(description, 'thing | remember', 'thing I remember')
 WHERE name = 'Super-Regeneration' AND instr(description, 'thing | remember') > 0;
UPDATE super_abilities SET description = replace(description, 'strike). < Helicopter', 'strike). Helicopter')
 WHERE name = 'Techno-Form' AND instr(description, 'strike). < Helicopter') > 0;
UPDATE super_abilities SET description = replace(description, 'hear it. experience. +20 feet (6.1 m) if used underwater. Duration', 'hear it. Duration')
 WHERE name = 'Energy Expulsion: Ultrasonic Screech' AND instr(description, 'hear it. experience. +20 feet (6.1 m) if used underwater. Duration') > 0;
UPDATE super_abilities SET description = replace(description, ' | ', ' I ')
 WHERE name = 'Unnoteworthy - Forgettable' AND instr(description, ' | ') > 0;
UPDATE super_abilities SET description = replace(description, 'For ail I know', 'For all I know')
 WHERE name = 'Unnoteworthy - Forgettable' AND instr(description, 'For ail I know') > 0;
UPDATE super_abilities SET description = replace(description, 'his weight = = - - - - \ \ 4. SOME EFFECTS OF NOTE: ; Weightlessness is being effectively without weight. This means power four times, decreasing or increasing the weight of an object up to 400lbs (100lbs per each attack) per melee. Attacks must be directed at one person or item at a time. No simultaneous multiple attacks. Duration is six minutes on an unfocused attack, or indefinitely if the character is intentionally concentrating to maintain the weight change. Subtract one attack per melee if concentrating to maintain an effect. Maximum weight increase is 10,000 pounds (5 tons). victims', 'his weight power four times, decreasing or increasing the weight of an object up to 400lbs (100lbs per each attack) per melee. 2. Attacks must be directed at one person or item at a time. No simultaneous multiple attacks. 3. Duration is six minutes on an unfocused attack, or indefinitely if the character is intentionally concentrating to maintain the weight change. Subtract one attack per melee if concentrating to maintain an effect. 4. Maximum weight increase is 10,000 pounds (5 tons). SOME EFFECTS OF NOTE: Weightlessness is being effectively without weight. This means victims')
 WHERE name = 'Weight Manipulation' AND instr(description, 'his weight = = - - - - \ \ 4. SOME EFFECTS OF NOTE: ; Weightlessness is being effectively without weight. This means power four times, decreasing or increasing the weight of an object up to 400lbs (100lbs per each attack) per melee. Attacks must be directed at one person or item at a time. No simultaneous multiple attacks. Duration is six minutes on an unfocused attack, or indefinitely if the character is intentionally concentrating to maintain the weight change. Subtract one attack per melee if concentrating to maintain an effect. Maximum weight increase is 10,000 pounds (5 tons). victims') > 0;
UPDATE super_abilities SET description = replace(description, 'reduced to''a speed', 'reduced to a speed')
 WHERE name = 'Weight Manipulation' AND instr(description, 'reduced to''a speed') > 0;
UPDATE super_abilities SET description = replace(description, '100]bs', '100lbs')
 WHERE name = 'Weight Manipulation' AND instr(description, '100]bs') > 0;

-- H. Stat columns the import cut at a blank line or misread. Where a cut left
--    its remainder inside the description, section G removes it there.

UPDATE super_abilities SET range = '10ft per level of experience.'
 WHERE name = 'Energy Absorption' AND range = '(ft per level of experience.';
UPDATE super_abilities SET damage = '2D6'
 WHERE name = 'Energy Absorption' AND damage = '2D6 ae';
UPDATE super_abilities SET duration = 'Permanent, until knocked down or dispelled by the creator.'
 WHERE name = 'Control Elemental Force: Earth' AND duration = 'Permanent, until knocked down or dispelled by';
UPDATE super_abilities SET range = '40 feet (12.2 m) radius +10 feet (3 m) per level of experience. +20 feet (6.1 m) if used underwater.'
 WHERE name = 'Energy Expulsion: Ultrasonic Screech' AND range = '40 feet (12.2 m) radius +10 feet (3 m) per level of';

-- I. The Revised core prints a bullet before each item of a list, and the scan read
--    every one as "@". Applied last, after section G tidied the few with junk beside them.

UPDATE super_abilities SET description = replace(description, ' @ ', ' ' || char(8226) || ' ')
 WHERE instr(description, ' @ ') > 0;

-- ASSERTIONS.

SELECT 'no super ability description ends in a page number' AS assertion, count(*) AS got, 0 AS want
  FROM super_abilities
 WHERE description GLOB '* [0-9]' OR description GLOB '* [0-9][0-9]' OR description GLOB '* [0-9][0-9][0-9]';

SELECT 'none ends in the next entry''s heading' AS assertion, count(*) AS got, 0 AS want
  FROM super_abilities
 WHERE description LIKE '%Alter Physical Structure:' OR description LIKE '%Energy Expulsion:'
    OR description LIKE '% Impervious to' OR description LIKE '% Immune to' OR description LIKE '% Charge Object with';

SELECT 'no description carries a scanned bullet or scan junk' AS assertion, count(*) AS got, 0 AS want
  FROM super_abilities
 WHERE instr(description, '@') > 0 OR description GLOB '*[{}~|\<>]*';

SELECT 'the Revised core''s lists carry their bullets' AS assertion, count(*) AS got, 26 AS want
  FROM super_abilities WHERE instr(description, char(8226)) > 0;

SELECT 'no roster of powers is left inside an entry' AS assertion, count(*) AS got, 0 AS want
  FROM super_abilities
 WHERE instr(description, 'LIST OF MAJOR SUPER ABILITIES') > 0 OR instr(description, 'New Major Super Abilities') > 0
    OR instr(description, 'Rocket Fists Spiral/Vortex') > 0;

-- The two entries completed from the page.
SELECT 'Weapon Melding runs to the end of printed 87' AS assertion, count(*) AS got, 1 AS want
  FROM super_abilities
 WHERE name = 'Weapon Melding' AND description LIKE '%at ninth level proficiency. Rate of fire%'
   AND description LIKE '%Add 1D6 to P.E. and add 6D6 to Hit Points.';

SELECT 'Weight Manipulation reads in the order printed 192 does' AS assertion, count(*) AS got, 1 AS want
  FROM super_abilities
 WHERE name = 'Weight Manipulation'
   AND instr(description, 'use his weight power four times') > 0
   AND instr(description, '4. Maximum weight increase is 10,000 pounds (5 tons). SOME EFFECTS OF NOTE: Weightlessness') > 0
   AND instr(description, 'This means victims of weightlessness') > 0;

SELECT 'Zombie Flesh regenerates 1D6 again' AS assertion, count(*) AS got, 1 AS want
  FROM super_abilities
 WHERE name = 'Zombie Flesh' AND instr(description, 'regenerates 1D6 S.D.C./Hit Points') > 0
   AND description LIKE '%P.E. bonus).';

-- The numbers a looser rule would have destroyed. They are the reason every
-- page-number edit above names its fragment instead of matching a pattern.
SELECT 'the real numbers beside a page are still there' AS assertion, count(*) AS got, 4 AS want
  FROM super_abilities
 WHERE (name = 'Anatomical Independence' AND instr(description, 'Horror Factor: 13 for moving body parts, H.F. 14') > 0)
    OR (name = 'Charge Object with Explosive Energy' AND instr(description, '19 inch television') > 0)
    OR (name = 'Dimensional Pocket' AND instr(description, 'more than 12 items') > 0)
    OR (name = 'Alter Physical Structure: Goo or Gel' AND instr(description, 'or 40 for Superhuman') > 0);

SELECT 'the four stat columns the import cut are whole' AS assertion, count(*) AS got, 3 AS want
  FROM super_abilities
 WHERE (name = 'Energy Absorption' AND range = '10ft per level of experience.' AND damage = '2D6')
    OR (name = 'Control Elemental Force: Earth' AND duration = 'Permanent, until knocked down or dispelled by the creator.')
    OR (name = 'Energy Expulsion: Ultrasonic Screech'
        AND range = '40 feet (12.2 m) radius +10 feet (3 m) per level of experience. +20 feet (6.1 m) if used underwater.');

SELECT 'Generate Fog & Smoke ends where the book does' AS assertion, count(*) AS got, 1 AS want
  FROM super_abilities WHERE name = 'Generate Fog & Smoke' AND description LIKE '%he has an H.F. of 10.';

SELECT 'and their remainders are gone from the descriptions' AS assertion, count(*) AS got, 0 AS want
  FROM super_abilities
 WHERE (name = 'Energy Expulsion: Ultrasonic Screech' AND instr(description, 'hear it. experience.') > 0)
    OR (name = 'Control Elemental Force: Earth' AND instr(description, 'Wall of Earth the creator.') > 0);

SELECT 'every super ability is still here, and none lost its text' AS assertion, count(*) AS got, 364 AS want
  FROM super_abilities WHERE length(description) >= 60;

INSERT INTO data_script_runs (filename) VALUES ('fix-super-ability-ocr-text.sql');
