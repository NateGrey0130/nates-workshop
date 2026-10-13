-- The Noli Bushman and the N'mbyr Gorilla Man trim their occupation's skill counts by key
-- 2 classes, each replaced whole: noli-bushman, nmbyr-gorilla-man.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~186-book-ingest-audit-f129-noli-nmbyr.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.
-- BOOK-INGEST-AUDIT.md F129, the data. Both races printed the cut and left it
-- to the player; each now carries pairing_counts, and each loses the sentence
-- that said the cut was made by hand.
--
-- noli-bushman (Rifts World Book 30: D-Bees of North America printed 145, read
-- off a render 2026-10-13): Cowboy, Wilderness Scout (any) or Vagabond, and in
-- the case of the latter two reduce the number of O.C.C. Related and Secondary
-- Skill selections to three each. Stored as a cap of 3 on each list for
-- wilderness-scout and vagabond; the Cowboy is not cut. vagabond is the Rifts
-- class; vagabond-peasant is Palladium Fantasy and is not meant. Reduce is read
-- as at most three, so an occupation that offers fewer keeps its own count.
-- Canada printed 138 uses the same verb for its Noli Cowboy and Noli Scout.
--
-- nmbyr-gorilla-man (same book, printed 144, read off a render 2026-10-13): any
-- Men of Arms or Adventurer O.C.C., however reduce the selection of O.C.C.
-- Related Skills and Secondary Skills by half. Stored as a factor of 0.5 on
-- each list for every occupation. An odd count rounds down (Nate, 2026-10-12).
--
-- Creation counts only. No catalog row is added and no source_book changes.

-- == noli-bushman ==
UPDATE imported_classes
   SET markdown = '---
id: noli-bushman
name: Noli Bushman
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.144-146
category: rcc
tags: [wilderness]
men_of_arms: false
attribute_dice:
  IQ: "2d6+4"
  ME: "2d6+6"
  MA: "3d6"
  PS: "3d6+4"
  PP: "3d6+2"
  PE: "3d6+4"
  PB: "2d6"
  Spd: "6d6"
hit_points_base: "P.E. + 2d6, +1d6 per level"
ppe_base: "3d6"
occ_restrictions:
  only: ["psi-druid", "psi-slayer", "cowboy", "wilderness-scout", "vagabond", "cyber-knight"]
  note: "Limited to Psi-Druid, Psi-Slayer (the only two psychic O.C.C.s available), Cowboy, Wilderness Scout or Vagabond, and, rarely, Cyber-Knight. Not a candidate for M.O.M. or Juicer augmentation, and avoids bionics."
pairing_counts: [{ related: { cap: 3 }, secondary: { cap: 3 }, occupations: ["wilderness-scout", "vagabond"] }]
psionics:
  type: "master"
bonuses:
  pools: { sdc: "1d4x10" }
  combat: { initiative: 1, strike: 1, pull_punch: 4, roll: 2 }
  saves: { possession: 2, horror_factor: 3 }
skills:
  occ_skills:
    - { name: "Climbing", base: 60, per_level: 5, note: "R.C.C. instinct, +20%." }
    - { name: "Dowsing", base: 35, per_level: 5, note: "R.C.C. skill, +15%." }
    - { name: "Prowl", base: 35, per_level: 5, note: "R.C.C. instinct, +10%." }
    - { name: "Swimming", base: 60, per_level: 5, note: "R.C.C. skill, +10%." }
natural_abilities:
  - name: "Senses"
    description: "Sharp vision and nightvision to 300 feet (91.5 m). A thin second eyelid slides down as a natural polarizing lens, shielding the eye from bright light like a pair of polarized sunglasses."
  - name: "Master Psychic"
    description: "Every Noli is a Master Psychic and needs a 10 or higher to save vs psionic attack and mind control. A psionic attack counts as one melee action. A Psi-Druid or Psi-Slayer has the psionics and I.S.P. of that O.C.C.; every other Noli has the race''s own abilities and I.S.P."
  - name: "An S.D.C. being"
    description: "Hit Points are 2D6 plus the P.E. attribute number, plus 1D6 per level of experience starting at level one. S.D.C. is 1D4x10 plus any from physical skills. Needs magic or M.D.C. body armor against Mega-Damage weapons, just as a human does."
special_abilities:
  - { choose: 1, from: ["Psionics: Noli Master Psychic", "Psionics: Psi-Druid or Psi-Slayer", "Psionics: Noli Cyber-Knight"], note: "Psionics (printed 145-146): pick the line that matches the occupation. A Cowboy, Wilderness Scout or Vagabond has the race''s own abilities; a Psi-Druid or Psi-Slayer uses that O.C.C.''s; a Cyber-Knight is the rarity described under Available O.C.C.s." }
  - name: "Psionics: Noli Master Psychic"
    description: "For a Noli Cowboy, Wilderness Scout or Vagabond. Bio-Regeneration (self), Empathy, Mind Block, Psionic Invisibility and Telepathy, plus two Physical and two Sensitive powers of choice. One additional power from the Physical or Sensitive category at each new level of experience, and one Super Psionic power of choice at levels 4, 8 and 12, excluding Psi-Sword. I.S.P.: M.E. attribute number x2 plus 1D6+1 per level of experience."
    occ_options: ["cowboy", "wilderness-scout", "vagabond"]
    psionics: { type: "master", isp_base: "M.E. x2 + 1d6+1 per level", powers: ["Bio-Regeneration", "Empathy", "Mind Block", "Psionic Invisibility", "Telepathy"], powers_starting: 4, powers_starting_groups: [{ count: 2, categories: ["Physical"], note: "Two Physical powers of choice." }, { count: 2, categories: ["Sensitive"], note: "Two Sensitive powers of choice." }], categories_allowed: ["Physical", "Sensitive"], powers_schedule: [{ level: 2, count: 1, categories: ["Physical", "Sensitive"], note: "One additional power from the Physical or Sensitive category at each new level of experience." }, { level: 3, count: 1, categories: ["Physical", "Sensitive"], note: "One additional power from the Physical or Sensitive category at each new level of experience." }, { level: 4, count: 1, categories: ["Physical", "Sensitive"], note: "One additional power from the Physical or Sensitive category at each new level of experience." }, { level: 4, count: 1, categories: ["Super"], note: "One Super Psionic power of choice at levels 4, 8 and 12, excluding Psi-Sword (Psi-Sword is only available to Noli Cyber-Knights)." }, { level: 5, count: 1, categories: ["Physical", "Sensitive"], note: "One additional power from the Physical or Sensitive category at each new level of experience." }, { level: 6, count: 1, categories: ["Physical", "Sensitive"], note: "One additional power from the Physical or Sensitive category at each new level of experience." }, { level: 7, count: 1, categories: ["Physical", "Sensitive"], note: "One additional power from the Physical or Sensitive category at each new level of experience." }, { level: 8, count: 1, categories: ["Physical", "Sensitive"], note: "One additional power from the Physical or Sensitive category at each new level of experience." }, { level: 8, count: 1, categories: ["Super"], note: "One Super Psionic power of choice at levels 4, 8 and 12, excluding Psi-Sword (Psi-Sword is only available to Noli Cyber-Knights)." }, { level: 9, count: 1, categories: ["Physical", "Sensitive"], note: "One additional power from the Physical or Sensitive category at each new level of experience." }, { level: 10, count: 1, categories: ["Physical", "Sensitive"], note: "One additional power from the Physical or Sensitive category at each new level of experience." }, { level: 11, count: 1, categories: ["Physical", "Sensitive"], note: "One additional power from the Physical or Sensitive category at each new level of experience." }, { level: 12, count: 1, categories: ["Physical", "Sensitive"], note: "One additional power from the Physical or Sensitive category at each new level of experience." }, { level: 12, count: 1, categories: ["Super"], note: "One Super Psionic power of choice at levels 4, 8 and 12, excluding Psi-Sword (Psi-Sword is only available to Noli Cyber-Knights)." }, { level: 13, count: 1, categories: ["Physical", "Sensitive"], note: "One additional power from the Physical or Sensitive category at each new level of experience." }, { level: 14, count: 1, categories: ["Physical", "Sensitive"], note: "One additional power from the Physical or Sensitive category at each new level of experience." }, { level: 15, count: 1, categories: ["Physical", "Sensitive"], note: "One additional power from the Physical or Sensitive category at each new level of experience." }] }
  - name: "Psionics: Psi-Druid or Psi-Slayer"
    description: "For a Noli Psi-Druid or Psi-Slayer, the only two psychic O.C.C.s available to the race. Ignore the race''s psionic abilities and I.S.P. and use the psionics, I.S.P., skills and abilities of that O.C.C."
    occ_options: ["psi-druid", "psi-slayer"]
  - name: "Psionics: Noli Cyber-Knight"
    description: "For a Noli Cyber-Knight, a rarity (only two are known) because the occupation limits the race''s natural range of psionic powers. Psi-Sword at 1st level and a total of six psionic powers selected from the Sensitive and/or Physical categories, in addition to those normally available to Cyber-Knights; the six are recorded by hand. I.S.P.: M.E. attribute number x2 plus 1D6+1 per level of experience."
    occ_options: ["cyber-knight"]
    psionics: { type: "master", isp_base: "M.E. x2 + 1d6+1 per level" }
trackable_resources: []
restrictions:
  - "Alignment: any."
  - "Cowboy, Wilderness Scout (any) or Vagabond: in the case of the latter two, the number of O.C.C. Related and Secondary Skill selections is reduced to three each. Applied when the occupation is picked: at most three of each, so an occupation that offers fewer keeps its own count."
  - "A Noli Psi-Druid or Psi-Slayer ignores the race''s psionic abilities and I.S.P. and uses the psionics, I.S.P., skills and abilities of that O.C.C."
  - "Noli Cyber-Knight (only two are known): gets Psi-Sword at 1st level and a total of six powers chosen from the Sensitive and/or Physical categories, besides those a Cyber-Knight normally has. Recorded by hand."
  - "Not a candidate for M.O.M. or Juicer augmentation; avoids bionics, and cybernetics except for medical purposes."
extraction_notes: "Followed Rifts World Book 20: Canada printed 137-138 until this update to the D-Bees of North America printing (ruling of 2026-10-04: the newest printing that states a figure wins and the older figure is kept in a note). D-Bees of North America printed 144-146 (cache p145-p147) and Canada printed 137-138 (cache p138-p139) were both read off page renders. D-Bees closes the entry with Note: Original appearance, Rifts World Book 20: Canada. The lore is headed Noli Bushman and the stat block Noli - Optional Player Character and NPC; the class is named for the lore heading. || CATEGORY: a race that takes an occupation in both books; Standard Equipment is As per O.C.C. (D-Bees adds a preference for spears and staves as weapons) and Money is As per O.C.C. (Canada printed 138 has no money line). No xp_table: D-Bees says to use the Experience Table of the chosen O.C.C., and Canada prints no ladder for the race. || UNCHANGED BETWEEN THE BOOKS: the eight attribute dice, size, weight, P.P.E. 3D6, the Hit Points line, the S.D.C. figure, the natural abilities line and the bonus line read the same in both (D-Bees drops the S.D.C. line''s clause about needing magic or M.D.C. armor, and prints an M.D.C. line saying by body armor or other external protection). || HIT POINTS: both books print 2D6 +P.E. attribute number, plus 1D6 M.D. per level of experience starting at level one. The M.D. is a misprint on a Hit Points line of an S.D.C. being, repeated in D-Bees, and is read as 1D6 Hit Points per level; stored as hit_points_base. || S.D.C.: 1D4x10 plus those gained from Physical skills; stored as a pool bonus, never sdc_base, with men_of_arms false. D-Bees adds M.D.C.: By M.D.C. body armor or other external protection, and Horror Factor: Not applicable. || SKILLS: D-Bees R.C.C. Skills are Climbing (+20%), Dowsing (+15%), Prowl (+10%) and Swimming (+10%), in addition to the skills of any chosen O.C.C. Canada printed 138 gave R.C.C. Skills/Instincts: Climb +20% and Prowl +10% only, so Dowsing and Swimming are new with D-Bees. Climbing +20% over the catalog 40 is 60; Dowsing +15% over 20 is 35; Prowl +10% over 25 is 35; Swimming +10% over 50 is 60. || PSIONICS: D-Bees printed 145-146 prints the power list and an I.S.P. figure on the race itself: All Noli are Master Psychics with Bio-Regeneration (self, 6), Empathy (4), Mind Block (printed 40, read as the catalog Mind Block), Psionic Invisibility (10), Telepathy (4), two Physical and two Sensitive powers of choice, one more Physical or Sensitive power at each new level, one Super power of choice at levels 4, 8 and 12 excluding Psi-Sword, and I.S.P. of M.E. attribute number x2 plus 1D6+1 per level of experience; a Psi-Druid or Psi-Slayer ignores all of that and uses the psionics, I.S.P., skills and abilities of that O.C.C. Canada printed 138 gave Psionics: All Noli are effectively Master Psychics, although none are Mind Melters; see O.C.C.s, printed the same power list for the Noli Cowboy and Noli Scout only, and printed no I.S.P. figure at all. Stored as the class-level psionics type master, which holds for every Noli, plus a pick-one group of three options, because the package depends on the occupation: Psionics: Noli Master Psychic carries the package and the I.S.P. line for a Cowboy, Wilderness Scout or Vagabond; Psionics: Psi-Druid or Psi-Slayer carries no block; Psionics: Noli Cyber-Knight carries the tier and the I.S.P. line. Each option names its occupations. Bio-Regeneration is the Healing-category self power at 6 I.S.P., not the Super one. The Psi-Sword exclusion on the Super picks is in the note of those grants. || CYBER-KNIGHT: both books give a Noli Cyber-Knight Psi-Sword at 1st level and a total of six powers from the Sensitive and/or Physical categories in addition to those normally available to Cyber-Knights, because the occupation limits their natural range of psionic powers. Read as replacing the race package. The six additional powers are prose. Neither book prints an I.S.P. figure for the Noli Cyber-Knight by name; the D-Bees race line (M.E. x2 plus 1D6+1 per level) excepts only the Psi-Druid and Psi-Slayer, so it is stored on that option. || BONUSES: +1 initiative, +1 strike, +4 pull punch, +2 roll, +2 vs possession, +3 vs Horror Factor stored; the same line in both books. Needs 10 or higher to save vs psionic attacks and mind control is ability text. || OCCUPATIONS: D-Bees Available O.C.C.s are Psi-Druid, Psi-Slayer (the only two psychic O.C.C.s available to them), Cowboy, Wilderness Scout (any) or Vagabond (with leanings toward working with animals, farming and nature), and Cyber-Knight; stored as occ_restrictions.only. Canada printed 138 gave Psi-Druid, Psi-Slayer, Noli Cowboy or Noli Scout, and Cyber-Knight, with no Vagabond; it called the Noli Cowboy and Noli Scout effectively the Cowboy/Cow Puncher and Wilderness Scout O.C.C.s, and D-Bees no longer uses those two names. SKILL CUT: D-Bees says that in the case of the latter two the O.C.C. Related and Secondary Skill selections are reduced to three each, where the two named last are Wilderness Scout and Vagabond; Canada applied the same cut to the Noli Cowboy and Noli Scout. Stored as pairing_counts, a cap of three on each list for wilderness-scout and vagabond, the Rifts Vagabond and not the Palladium Fantasy vagabond-peasant. Reduce is read as at most three: an occupation that offers fewer than three keeps its own count, and a list the occupation does not offer is not created. See BOOK-INGEST-AUDIT.md F129. || CYBERNETICS: D-Bees adds Cybernetics and Bionics: Avoid them except for medical purposes, beside the sentence both books print (not candidates for M.O.M. and Juicer augmentation, and avoid bionics). || NPC AND BACKGROUND FIGURES, in GM Notes: alignment leanings (Principled 30%, Scrupulous 30%, Unprincipled 10%; Canada printed Any), NPC experience level 1D8, average life span 5D6+60 years with females living 2D6 years longer (Canada printed 138 gave 70-90 years, although a few claim to be older than 120), slave market value 2D4x1,000 credits, and the Lazlo, New Lazlo and Tolkeen numbers (Canada gave nearly one thousand at Lazlo, a few hundred at New Lazlo and three hundred joined to the crusade at Tolkeen). D-Bees also adds the nickname Green Scouts, the Inuit People and Mastadonoids among those the Noli get along with, Greots, Horune, Minions of Splugorth and slavers among those they have no love for, and Minnesota, New York, Vermont, New Hampshire, Massachusetts and Maine to the places they are found in small numbers; D-Bees does not restate supernatural evil among the enemies or the United States forests as a main habitat, and the GM Notes keep Canada there. || NOT STORED: size 5 ft 6 in to 6 ft, weight 120 to 160 pounds, the nicknames, allies, enemies and habitat. GM Notes still gives the allies, enemies and habitat as Canada printed them; the D-Bees additions are recorded in this note only."
---

## Lore

The Noli (say "no lee") are forest people of eastern Canada and the
United States, with some now settling in Ontario and Lower Michigan. They
are built much like humans but have green skin, tufts of dark green or
brown fur like dreadlocks or soft quills, a long thin neck and a large
melon-shaped head. The eyes are big and dark green, the nose and ears are
little more than holes, and the wide mouth is full of flat teeth for
grinding bark, roots, grass, fruit and nuts.

They are born woodsmen, yet they have nothing against machines. Many wear
light or partial armor, carry Mega-Damage weapons and love small fast
vehicles such as hovercycles, as well as horses, Fury Beetles and other
mounts. Towns do not trouble them, though they like small ones and open
country best. That mix makes them fine scouts, ranch hands, animal handlers
and explorers, and every one of them is a powerful psychic. Outsiders call
them Greenbeans or Greenies.

## GM Notes

The book heads the race an optional player character and NPC.

Every Noli who is not a Psi-Druid or Psi-Slayer has this psionic package:
Bio-Regeneration (self), Empathy, Mind Block, Psionic Invisibility,
Telepathy, two Physical and two Sensitive powers of choice, one more from
either category at each new level, and one Super power (never Psi-Sword)
at levels 4, 8 and 12. I.S.P. is the M.E. attribute number x2 plus 1D6+1
per level of experience. A Psi-Druid or Psi-Slayer ignores all of that and
uses the psionics, I.S.P., skills and abilities of that O.C.C. The book
lists Cowboy, Wilderness Scout (any) or Vagabond and cuts the O.C.C.
Related and Secondary Skill selections of the latter two to three each;
the cut is applied when the occupation is picked.

Alignment: any, leaning toward Principled (30%), Scrupulous (30%) and
Unprincipled (10%). NPCs are experience level 1D8 or as set by the Game
Master; player characters start at level one and use the Experience Table
of the chosen O.C.C. Standard equipment and money are as per O.C.C., with
a preference for spears and staves as weapons. Slave market value:
2D4x1,000 credits as fighters, scouts and slave labor.

A Noli Cyber-Knight is a rarity: Psi-Sword at 1st level and six powers in
all from the Sensitive and/or Physical categories, on top of the Knight''s
usual ones.

Size 5 feet 6 inches to 6 feet (1.7 to 1.8 m). Weight 120 to 160 pounds
(54 to 72 kg). Average life span 5D6+60 years; females live 2D6 years longer
than males. Physical maturity comes by age 17.

Allies: nothing formal. They get on with Native Americans, Psi-Stalkers,
Simvan, rogue Dog Boys and tolerant humans and D-Bees. Nearly one thousand
live in Lazlo and 400 at New Lazlo. A thousand perished in the
Coalition-Tolkeen War.

Enemies: the Coalition and the Quebec military, at whose hands they have
suffered, and the Xiticix, Yeno, Loup Garou, vampires and supernatural
evil. They are wary of other strong psychics, think Mind Melters and Mind
Bleeders dangerous, and stay away from Psyscape.

Habitat: mostly Ontario, Quebec and the eastern forests of Canada and the
U.S., with small numbers in Manitoba, Michigan, Illinois and Wisconsin.
',
       updated_at = datetime('now')
 WHERE class_id = 'noli-bushman'
   AND instr(markdown, 'Skill selections is reduced to three each. Recorded by hand.') > 0
   AND length(markdown) = 17735;

-- == nmbyr-gorilla-man ==
UPDATE imported_classes
   SET markdown = '---
id: nmbyr-gorilla-man
name: N''mbyr Gorilla Man
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.143-144
category: rcc
tags: []
attribute_dice:
  IQ: "2d6+4"
  ME: "2d6+2"
  MA: "2d6"
  PS: "4d6+10"
  PP: "3d6"
  PE: "3d6+6"
  PB: "2d6"
  Spd: "2d6"
hit_points_base: "P.E. + 1d6 per level"
sdc_base: "3d4x10"
ppe_base: "6d6"
horror_factor: 10
occ_restrictions:
  only: ["group:men-of-arms", "group:optional"]
  note: "Any Men of Arms or Adventurer O.C.C.; in each case the O.C.C. Related and Secondary skill selections are cut in half. Never a magic O.C.C. Crazy conversion does not work on this alien physiology, though the group token still offers it. Juicer augmentation is tragic: it gives all the powers of a Juicer but also 1D6 random insanities, the character cannot detox, and burns out (dies) in 1D4 years."
pairing_counts: [{ related: { factor: 0.5 }, secondary: { factor: 0.5 } }]
psionics:
  type: "major"
  isp_base: "P.E., +10 per level"
  powers_starting: 6
  categories_allowed: ["Physical"]
bonuses:
  combat: { strike: 1, parry: 1, pull_punch: 2, damage_bonus: 4 }
  saves: { horror_factor: 1, harmful_drugs: -6 }
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 95, per_level: 0, note: "N''mbyr at 95%." }
    - { name: "Wrestling", base: 0, per_level: 0 }
    - { name: "Physical Labor", base: 0, per_level: 0 }
    - { name: "Athletics (general)", base: 0, per_level: 0 }
natural_abilities:
  - { name: "Keen Vision and Nightvision", description: "Keen vision; nightvision 120 feet (36.5 m)." }
  - { name: "Augmented P.S.", description: "P.S. is Augmented Strength; damage is as per Augmented P.S., or Supernatural P.S. during a violent outburst, or by weapon." }
special_abilities:
  - name: "Violent Outburst"
    description: "When seriously angry, embarrassed, frightened or frustrated the N''mbyr loses his temper and self-control and beats on the person or thing (computer, vehicle, machine) responsible. While it lasts: +1 attack per melee round, +2 on initiative, +1 to strike, +10 P.S., and P.S. goes from Augmented to the equivalent of a Supernatural P.S. of 1D4+21 (2D6 M.D. punch or kick, 4D6 M.D. power punch, 1 M.D. bite), +6 to save vs horror factor, +2 to save vs mind control, possession and psionic attack. Penalties: -30% on skill performance, -2 to dodge, cannot pull punches, fears nothing, and forgets its mission, its friends, its own well-being and its enhanced P.S. The race''s Horror Factor of 10 (15 to children and women) applies only while it is enraged."
  - name: "Eruptor"
    description: "20% of N''mbyr are Psychic Eruptors, considered Master Psychics: instead of the usual allowance they hold 1D4+1 Physical powers of choice plus ONE Super power from Electrokinesis, Hydrokinesis, Pyrokinesis, Telekinesis (Super) or Telekinetic Force Field, and those powers have double the normal range and duration and +1D6 M.D. damage. Eruptor I.S.P. is P.E. x3, +10 per level of experience starting with level one, and an Eruptor gets no additional psionic abilities as it advances in level. Rolled at creation; the G.M. adjusts the psionic picks and I.S.P. by hand."
restrictions:
  - "Needs an O.C.C.: the R.C.C. skills are in addition to O.C.C. skills."
  - "O.C.C. Related and Secondary skill selections are reduced by half, whatever the O.C.C.; applied when the occupation is picked, an odd count rounding down."
  - "Crazy conversion does not work on this race."
  - "Juicer augmentation: all the powers of a Juicer, plus 1D6 random insanities (Rifts Ultimate Edition p.332); cannot detox, and burns out (dies) in 1D4 years."
  - "Magic: none, and never a magic O.C.C."
  - "Equipment and money: as per O.C.C.; slave wages are one third to half of what a human or other D-Bee would make."
  - "Cybernetics and bionics: as per O.C.C., but generally avoided; a lost limb may be replaced by a stronger prosthetic."
side_effects: "Prone to violent outbursts (see the ability). Low tolerance for alcohol and drugs: drunk after two drinks and high quickly and profoundly, -6 to save vs drugs, and 40% are addicted to drugs or alcohol, which worsen the mood swings; resistant to poisons and other toxins through high P.E. The inhuman appearance is hard to disguise."
extraction_notes: "This class followed Rifts World Book 11: Coalition War Campaign printed 202-203 until this update; it now follows the newer printing, Rifts World Book 30: D-Bees of North America printed 143-144, which says the race originally appeared in Coalition War Campaign (ruling of 2026-10-04: the newest printing that states a figure wins and the older figure is kept here). Both entries were read off page renders (D-Bees cache p144-p145, Coalition War Campaign cache p203-p204). || Unchanged between the two printings: the eight attribute dice, Hit Points P.E. plus 1D6 per level, S.D.C. a bare 3D4x10 (no plus-O.C.C. clause, so stored as sdc_base; no men_of_arms line because the race states its pool), P.P.E. 6D6, nightvision 120 feet, the outburst''s +10 P.S., +1 attack, +6 vs Horror Factor, +2 vs mind control, possession and psionic attack, -2 dodge and -30% skills, 1D4+2 Physical powers, the Eruptor''s 1D4+1 Physical powers plus one Super power with doubled range and duration, no magic, and the halving of O.C.C. Related and Secondary skills. The halving is stored as pairing_counts, a factor of one half on each list for every occupation, an odd count rounding down (ruling of 2026-10-12); see BOOK-INGEST-AUDIT.md F129. || Violent Outburst: D-Bees prints a Supernatural P.S. of 1D4+21 doing 2D6 M.D. from a punch or kick and 4D6 M.D. with a power punch, and adds +2 on initiative and +1 to strike. Coalition War Campaign printed 203 gave a supernatural P.S. of 19, 1D6 M.D. from a punch or kick and 2D6 M.D. with a power punch, and no initiative or strike bonus. The bite is one M.D. in both. || P.S.: D-Bees marks P.S. 4D6+10 as Augmented Strength and lists Augmented P.S. among the natural abilities; Coalition War Campaign printed 202 gave the same dice with no strength class. Stored as a natural ability. || Horror Factor: D-Bees prints 10 (15 to children and women), but only when they are enraged; Coalition War Campaign printed 202 gave a bare 10. horror_factor stays 10 and the condition and the 15 are in the Violent Outburst ability. || Bonuses: D-Bees prints, in addition to those from attributes and skills, +1 to strike and parry, +2 to pull punch, +4 to damage and +1 to save vs Horror Factor, stored in bonuses. Coalition War Campaign printed no bonus line at all. D-Bees also prints -6 to save vs drugs under Vulnerabilities, stored as saves harmful_drugs -6; Coalition War Campaign printed only that many are attracted to drugs and alcohol. The outburst bonuses are conditional and stay in the ability. || Psionics: D-Bees prints the average N''mbyr as a Major Psychic with 1D4+2 Physical powers of choice and I.S.P. equal to the P.E. attribute number +10 per level of experience starting at level one. Coalition War Campaign printed 203 gave I.S.P. as M.E. attribute number x3 plus 10 per level for the whole race and named no tier for the average member (only that 20% are major or master psychics), which was stored as minor. powers_starting holds the ceiling 6 of the 1D4+2 roll and the roll is the player''s to honour. Eruptors (20%): D-Bees prints them as Master Psychics with I.S.P. P.E. x3 +10 per level starting with level one, +1D6 M.D. damage, and no additional psionic abilities as they advance; Coalition War Campaign printed major or master, damage +1D6 points, and the same M.E. x3 I.S.P. as everyone else. The Eruptor stays a special ability in prose, with Telekinesis (10+) read as the catalog''s Telekinesis (Super). || Available O.C.C.s: D-Bees prints any Men of Arms or Adventurer O.C.C., stored as occ_restrictions only [group:men-of-arms, group:optional]; the catalog''s optional group is the Adventurers and Scholars section. Coalition War Campaign printed 203 gave any Men of Arms or vagabond or wilderness scout, both of which sit inside that group. Juicer: D-Bees prints that those who insist on Juicer augmentation receive all the powers of a Juicer but also 1D6 random insanities, cannot detox and burn out in 1D4 years; Coalition War Campaign printed that Juicer and Crazy conversions do not work on the alien physiology, and in its Bionics line that some have elected to get Juicer augmentation. Crazy conversion does not work in either printing; a race states only or except, not both, so that exclusion is in the note and restrictions. || Skills: D-Bees prints R.C.C. Skills as Language: Native Tongue (N''mbyr at 95%), Wrestling, Physical Labor and Athletics (General), in addition to O.C.C. skills. Coalition War Campaign printed no R.C.C. skill list and no percentage for the native language (it was stored at the catalog''s 98); its closing note gave American (+20%) and one language of choice (+15%). D-Bees restates the R.C.C. skills as a complete line without them, so they are not stored; languages come from the O.C.C. || Equipment and money: D-Bees prints Standard Equipment as per O.C.C. and Money as per O.C.C. (slave wages are one third to half of what a human or other D-Bee would make), so the class states no equipment_starting and no starting_money. Coalition War Campaign printed 203 gave the clothes on their back, a knife or mace, an energy weapon of choice and some personal items, and 2D6x10 credits. Favorite weapons (Neural-Mace, Vibro-Blades, heavy weapons) and any armor are the same in both. || Cybernetics: D-Bees prints as per O.C.C., but tend to avoid them. Coalition War Campaign printed that a more powerful prosthetic limb is considered if the natural one is lost and that most avoid M.O.M. implants; D-Bees does not restate either and the prosthetic line is kept. || XP: D-Bees prints use the Experience Table of the chosen O.C.C.; Coalition War Campaign''s tables (printed 224) print no N''mbyr ladder. No xp_table. || Not stored as mechanics, D-Bees only: alignments lean Scrupulous (20%), Unprincipled (20%) and Anarchist (35%); life span 3D6+50 years; 40% are addicted to drugs or alcohol; slave market value 4D4x1,000."
---

## Lore

The N''mbyr, pronounced Nim-beer, are called Gorilla Men for their ape-like
look: simian faces, long powerful arms and short legs. They are strong,
emotional and quick to anger, love hard labor, wrestling and football, and
make fine climbers, laborers and warriors. Most are good-natured, but even a
friendly one can fly into a rage and maul a comrade. They came through an
anomaly at the Old Chicago ruins and are most common in the Midwest and the
Magic Zone.

## GM Notes

Any alignment. Six to seven feet, 160 to 250 lbs. They rely on physical
strength and psionics rather than magic, favor neural maces, vibro-blades
and heavy weapons, and can wear any armor. As downtrodden Burbs D-bees they
earn slave wages. Rage outbursts make them dangerous allies as well as
enemies.
',
       updated_at = datetime('now')
 WHERE class_id = 'nmbyr-gorilla-man'
   AND instr(markdown, 'skill selections are reduced by half; apply by hand.') > 0
   AND length(markdown) = 10644;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 2 classes carry their new text' AS assertion, count(*) AS got, 2 AS want
  FROM imported_classes
 WHERE (class_id = 'noli-bushman' AND instr(markdown, 'pairing_counts: [{ related: { cap: 3 }, secondary: { cap: 3 }, occupations: ["wilderness-scout", "vagabond"] }]') > 0)
    OR (class_id = 'nmbyr-gorilla-man' AND instr(markdown, 'pairing_counts: [{ related: { factor: 0.5 }, secondary: { factor: 0.5 } }]') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'noli-bushman' AND instr(markdown, 'Skill selections is reduced to three each. Recorded by hand.') > 0)
    OR (class_id = 'nmbyr-gorilla-man' AND instr(markdown, 'skill selections are reduced by half; apply by hand.') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('noli-bushman', 'nmbyr-gorilla-man') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~186-book-ingest-audit-f129-noli-nmbyr.sql');
