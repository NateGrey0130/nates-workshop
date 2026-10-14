-- BOOK-INGEST-AUDIT F130, second half: the linear per-level values on arac and chasseur-vert stay prose, and their notes stop citing F116 for them
-- 2 classes, each replaced whole: arac, chasseur-vert.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~188-book-ingest-audit-f130-linear.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.

-- == arac ==
UPDATE imported_classes
   SET markdown = '---
id: arac
name: A''rac
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.25-27
category: rcc
tags: [scholar]
men_of_arms: false
attribute_dice:
  IQ: "3d6+8"
  ME: "3d6"
  MA: "3d6+6"
  PS: "3d6+2"
  PP: "3d6+4"
  PE: "4d6+2"
  PB: "2d4+1"
  Spd: "4d6"
hit_points_base: "P.E. + 3d6, +1d8 per level"
ppe_base: "2d6"
yields_to_occupation: { ppe_base: [magic] }
bonuses:
  saves: { horror_factor: 2, toxins_poisons: 1, disease: 1 }
  pools: { sdc: "1d4x10" }
  at_level:
    - { level: 2, saves: { toxins_poisons: 1, disease: 1 } }
    - { level: 3, saves: { toxins_poisons: 1, disease: 1 } }
    - { level: 4, saves: { toxins_poisons: 1, disease: 1 } }
    - { level: 5, saves: { toxins_poisons: 1, disease: 1 } }
    - { level: 6, saves: { toxins_poisons: 1, disease: 1 } }
    - { level: 7, saves: { toxins_poisons: 1, disease: 1 } }
    - { level: 8, saves: { toxins_poisons: 1, disease: 1 } }
    - { level: 9, saves: { toxins_poisons: 1, disease: 1 } }
    - { level: 10, saves: { toxins_poisons: 1, disease: 1 } }
    - { level: 11, saves: { toxins_poisons: 1, disease: 1 } }
    - { level: 12, saves: { toxins_poisons: 1, disease: 1 } }
    - { level: 13, saves: { toxins_poisons: 1, disease: 1 } }
    - { level: 14, saves: { toxins_poisons: 1, disease: 1 } }
    - { level: 15, saves: { toxins_poisons: 1, disease: 1 } }
skills:
  occ_skills:
    - { name: "Climbing", base: 81, per_level: 1, note: "Natural climbing ability, 81% +1% per level; applies equally to climbing and rappelling." }
    - { choose: 1, from: ["Language: Other"], bonus: 20, note: "One additional Language: Other at +20%, whatever the O.C.C." }
    - { choose: 1, categories: ["Science"], bonus: 10, note: "One extra Science skill at +10%, whether or not the O.C.C. offers Science skills." }
natural_abilities:
  - name: "Superior vision"
    description: "Can read a small sign or recognize a face from 1200 feet (366 m) away, and sees the infrared and ultraviolet spectrums of light."
  - name: "Natural climber"
    description: "Thousands of microscopic hairs on each finger: Climb 81% +1% per level of experience, applying equally to climbing and rappelling."
  - name: "Excellent balance"
    description: "Base skill of 50%, or +15% to the Acrobatics and Gymnastics skills."
  - name: "Armored exoskeleton"
    description: "Skin of tiny segmented plates: a natural A.R. of 13. Physical S.D.C. is 1D4x10, +5 per level of experience starting at level two."
  - name: "Bionic-equivalent strength"
    description: "P.S. is equal to Bionic Strength, despite thin-looking limbs."
  - name: "Resistant to poison, disease and toxins"
    description: "+1 to save vs poison, toxins and disease per level of experience."
  - name: "Venomous bite"
    description: "Bite does 1D4 S.D.C. and a successful strike injects a toxin; the victim saves vs poison at 14 or higher. A successful save means 1D6 S.D.C. more damage; a failure means 4D6 S.D.C. more, and for 2D4 hours the victim is dizzy and drowsy: -3 to strike, parry and dodge, skills at -15%, and speed halved."
  - name: "Six-fingered hands and feet"
    description: "Four fingers and two opposable thumbs on each hand, and six toes suited both to walking and to climbing."
special_abilities:
  - name: "Perception"
    description: "+1D4 to Perception Rolls, rolled once."
  - name: "Scientific aptitude"
    description: "+5% to all Science and Technical skills, in addition to any O.C.C. or I.Q. bonuses."
level_progression:
  - { level: 2, grants: ["+5 S.D.C. at each level of experience from level two on"] }
trackable_resources: []
restrictions:
  - "Alignment: any, but tend to be Principled (20%), Scrupulous (30%), Unprincipled (20%) or Anarchist (20%)."
  - "Gains no S.D.C., P.S. or P.E. bonuses from Physical skills; P.P. and Spd bonuses from Physical skills do apply."
  - "Psionics: standard, as a human. Magic: only by O.C.C., as a human; P.P.E. is 2D6 or per a magic O.C.C."
  - "Cybernetics and bionics: tend to avoid them."
  - "Standard equipment and money: as per the chosen O.C.C."
extraction_notes: "Rifts World Book 30: D-Bees of North America printed 25-27 (cache p026-p028), a scan; every number read off 200 dpi renders of cache p027 (stat block, printed 26) and p028 (printed 27) and checked against the OCR. Heading A''rac - Optional Player Character or NPC (printed 26). The entry opens on printed 25 below the Amorph experience table and ends on printed 27 above Auto-G; first printed in Rifts World Book 27: Adventures in Dinosaur Swamp, not held, so it is imported from here. || ID: arac (the apostrophe dropped); name A''rac. || CATEGORY: a race that takes an O.C.C. No xp_table: the Experience Level note says to use the chosen O.C.C.''s table. men_of_arms false. || ATTRIBUTES as printed; P.B. 2D4+1 is by human standards (2D6+10 by A''rac standards), stored as 2d4+1. P.S. equals Bionic Strength: ability text. || HIT POINTS: 3D6 + P.E. attribute, plus 1D8 per level starting at level one, stored as hit_points_base P.E. + 3d6, +1d8 per level, the shape earlier imports used for starting at level one. || S.D.C.: 1D4x10 stored as a pool bonus; +5 S.D.C. per level from level two cannot be a pool bonus (pools in at_level are not applied), so it is level_progression prose, added by hand at each level (BOOK-INGEST-AUDIT.md F130; Nate''s ruling of 2026-10-13 keeps it prose, with no sdc_base term and no ability progression). No S.D.C. from Physical skills: a restriction line. Natural A.R. 13: ability text. || P.P.E.: 2D6 or per magic O.C.C., stored as ppe_base 2d6 with yields_to_occupation ppe_base [magic], as aardan-tek carries for the same wording. Regression pins that flag''s carriers by name (test/regression.mjs, the list holding aardan-tek), so this class must be added to it. || BONUSES: +2 vs Horror Factor; +1 per level vs poison, toxins and disease stored as toxins_poisons and disease 1 at level 1 and at_level +1 at levels 2-15. +1D4 to Perception Rolls is a dice bonus, a special ability. || SKILLS: Climb 81% +1% per level stored as Climbing 81/1. R.C.C. Skills Bonuses: one extra Language: Other at +20%, one extra Science skill at +10%, granted as choices; +5% to all Science and Technical skills cannot be expressed and is a special ability. Balance base 50% or +15% to Acrobatics and Gymnastics: ability text (the catalog has no balance skill). || BITE: 1D4 S.D.C., save vs poison 14+, 1D6 on a save or 4D6 and -3 strike/parry/dodge, -15% skills, half speed for 2D4 hours. || OCCUPATIONS: no restriction; most choose Scholar and Adventurer O.C.C.s, especially explorers (Wilderness Scout, Saddle Tramp, Vagabond, Pathfinder, Dinosaur Swamp O.C.C.s), and magic users tend to Shifter and Temporal Wizard. In GM Notes. || NOT STORED: size 6-7 feet, weight 130-210 lbs, life span 6D6+260 years, NPC level 2D4, slave market value, allies, enemies, habitat; in GM Notes."
---

## Lore

The A''rac are tall, lean D-Bees descended from spider-like ancestors. They
walk upright on two thin legs and have two thin arms, yet they are as strong
as a bionic human. Each hand has four fingers and two thumbs covered in
microscopic hairs that let them climb almost anything. Their heads are a
spider''s, with two large black eyes, two small ones below them and a false
pair above, and four toothed mandibles for a mouth; they live on liquefied
meat and blood. The skin is a fine, glossy shell of tiny plates.

They are curious, studious and gentle, and their calm manner does much to
win over people who flinch at their faces. A''rac wander the Megaverse for
the sake of learning, keep careful journals of everything they see, and
often settle down after an adventure to write about it. Most pass through
Earth''s Rifts on the way to somewhere else, so only a few stay.

Those who do stay despise willful ignorance. They gather at Lazlo and New
Lazlo, speak out against the Coalition States and the Federation of Magic,
teach reading in the ''Burbs, and some smuggle banned books through the
Black Market.

## GM Notes

Size 6-7 feet (1.8 to 2.1 m), tall and lean. Weight 130 to 210 lbs (58.5 to
94.5 kg). Life span 6D6+260 years; mature by 18; females lay 1D4 eggs after
an 8 month gestation and can bear young until 200; the eggs hatch three
months later. Experience Level for NPCs: 2D4.

Available O.C.C.s: drawn to Scholar and Adventurer occupations, especially
explorers such as the Wilderness Scout, Saddle Tramp, Vagabond, Pathfinder
and most Dinosaur Swamp O.C.C.s; they avoid combat O.C.C.s but often know a
few Weapon Proficiencies. Those who learn magic lean toward Shifter and
Temporal Wizard. They love sensors, computers, electronics, books and data.

Habitat: cool, dry climates preferred, but found anywhere. Fewer than two
thousand in the US and Canada, mostly in the East and the Magic Zone: about
thirty at New Lazlo, four times that at Lazlo, and isolated communities of
4D6x10. The vampires of Mexico drive them off, since A''rac blood cannot be
drunk.

Slave Market Value: 1D6x10,000 credits as an intelligent slave, half that
for the arena or labor.

Allies: lovers of knowledge and exploration - Aardan Tek, Adna Nomads,
Dewtani, N''reta, dragons, Mystics, Rogue Scholars and Scientists. Enemies:
the Coalition States, the Federation of Magic, and the Splugorth and their
minions; they are wary of Spinne and never trust the Chasseur Vert. Many
humans take them for monsters.
',
       updated_at = datetime('now')
 WHERE class_id = 'arac'
   AND instr(markdown, 'not modelled (BOOK-INGEST-AUDIT.md F116, since built, is an ability pick from a named list at set levels and does not cover this)') > 0
   AND length(markdown) = 9375;

-- == chasseur-vert ==
UPDATE imported_classes
   SET markdown = '---
id: chasseur-vert
name: Chasseur Vert
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.46-48
category: rcc
tags: [stealth, wilderness]
men_of_arms: false
attribute_dice:
  IQ: "2d6+6"
  ME: "2d6+6"
  MA: "3d6+6"
  PS: "3d6+6"
  PP: "2d6+6"
  PE: "2d6+6"
  PB: "3d6"
  Spd: "3d6"
hit_points_base: "P.E. + 2d6 per level"
ppe_base: "1d6"
occ_restrictions:
  except: ["combat-cyborg", "cs-cyborg-strike-trooper", "destroyer-borg", "fq-cyborg-soldier", "fq-cyborg-dervish", "fq-cyborg-imprimer", "fq-cyborg-leviathan", "fq-cyborg-slasher", "mining-borg", "ngr-cyborg-soldier", "ojahee-borg", "plains-borg", "republic-cyborg-soldier", "cyborg-shocktrooper", "ninja-borg", "warlord-heavy-machine", "warlord-light-machine"]
  note: "Military-minded Green Hunters lean toward Wilderness Scout, Special Forces, Military Specialist, Merc Soldier, Bandit and similar O.C.C.s. Artists, philosophers and scholars fall under Rogue Scholar or Vagabond. Mystics and Ley Line Walkers are most common among the magically inclined. Cybernetics and bionics are incompatible with their physiology."
bonuses:
  pools: { sdc: "2d6x10" }
  combat: { strike: 2, roll: 1 }
  saves: { other: [ { label: "vs toxic chemicals, pollutants and defoliants", bonus: -2 } ] }
natural_abilities:
  - name: "Plant Physiology"
    description: "A carnivorous, intelligent plant with a root-like skeleton and sap in place of blood. Thick fibrous skin gives a natural A.R. of 12. Impervious to human diseases."
  - name: "Forearm Thorns"
    description: "Two retractable thorns in the forearms deal 2D6 S.D.C. plus the toxin (see Venin) and attribute bonus damage."
special_abilities:
  - name: "Chameau (Water Absorption)"
    description: "Absorbs water by drinking, from pools or tanks, or from the air in a humid enough environment. Soaks up enough water in 1D4 hours to survive two days per level of experience."
  - name: "Camouflage"
    description: "Changes skin color to blend with natural surroundings. In vegetation, from scrub desert to rainforest, 90% undetectable if completely still, 70% if moving two feet (0.6 m) per melee round or slower, 20% if moving 6 feet (1.8 m) per melee round; useless at any faster pace. Reduced by -60% in a purely artificial environment; city parks, gardens and preserves impose no penalty."
  - name: "Croissance (Regeneration)"
    description: "Heals twice as fast as a human and regrows lost limbs and extremities in 1D4+1 months, starting as small sprouts."
  - name: "Discretion (Stealth)"
    description: "Prowl 76% +3% per level when moving through vegetation and natural landscapes; halved in an urban or artificial environment. +2 on Perception Rolls in a natural setting."
  - name: "Parfum (Chemical Lure)"
    description: "Exudes an intoxicating pheromone that lures animal prey, range about 2,500 feet (762 m) depending on the wind. Requires a save vs non-lethal poison; on a failure the prey blindly seeks the source, becomes euphoric, loses half its melee attacks and is -5 on initiative and -3 to strike, parry and dodge. Penalties are half against intelligent life forms (round down)."
  - name: "Seve (Sap)"
    description: "Secretes a powerful sticky sap from the hands, used to repair broken items and to entrap foes. A good layer can stick a grown human or an item of up to 300 pounds (135 kg); a combined P.S. of 25 is needed to pull free. Solvents such as gasoline, mineral spirits and bestine neutralize it. One melee round (15 seconds) to secrete enough to glue a person to a tree."
  - name: "Tetu (Root to Ground)"
    description: "Takes one melee to root to the ground and then cannot be budged; uprooting takes a Supernatural P.S. greater than the Green Hunter''s P.E. +1 point per level. Works only on natural surfaces (stone, soil, sand), never concrete, asphalt, metal or other man-made surfaces."
  - name: "Venin (Poison)"
    description: "The forearm thorns inject a toxin: within 1D4 melee rounds the victim falls ill and suffers -2 on all combat bonuses and -10% on all skills and speed. The victim must then save vs lethal poison every ten minutes for two hours or take 2D6 damage directly to Hit Points, and is nauseated, cramped and racked with sweats and chills throughout."
trackable_resources: []
restrictions:
  - "Alignment: any, but good and selfish alignments predominate."
  - "Cybernetics and bionics: none; incompatible with Chasseur Vert physiology. Cyborg O.C.C.s are excluded by name."
side_effects: "Ennui: after more than two weeks living in a city a Chasseur Vert grows agitated and surly and sinks into a depression: -2 to Perception Rolls, -4 on initiative, -2 to all combat rolls and -25% on all skills. Solaire Actionne (Solar Powered): needs four hours of natural sunlight a day (double under a grow lamp); after 48 hours without light it loses 25% of its Hit Points, then 10% every 48 hours until it dies. Defeuillez (Poison Vulnerability): -2 to save against toxic chemicals, pollutants and especially defoliants; a defoliant spray or gas does 3D6 S.D.C. per blast and immersion 1D6x10 damage per minute. Faim (Dietary Needs): must eat five pounds of meat a week or suffer starvation (Rifts World Book 27: Adventures in Dinosaur Swamp, pages 13-14). Faiblesse (Fear of Blades): takes double damage from edged and slashing weapons, and facing a foe wielding one must save vs Horror Factor 10 (14 against Vibro-Blades) or be panic-stricken, losing initiative and suffering -2 to all combat rolls."
extraction_notes: "WB30 D-Bees of North America printed 46-48 (cache p047-p049), numbers read off 200 dpi renders. The brief listed 46-47; Experience Level through Rivals and Enemies are on printed 48, so source_book cites 46-48. Tag line: Chasseur Vert - Optional Player Character or NPC. || CATEGORY: a race that takes an occupation; no R.C.C. skills printed. men_of_arms false. No xp_table: the book prints no ladder for the race, which uses its O.C.C.''s. || POOLS: Hit Points P.E. plus 2D6 per level. S.D.C. 2D6x10, stored as a pool bonus (never sdc_base). M.D.C. by armor only. A.R. 12 is ability text. Horror Factor not applicable. P.P.E. 1D6. || BONUSES: +2 strike and +1 roll with impact stored. +2 Perception in a natural setting is conditional and is in the Discretion ability. Impervious to human diseases is ability text. The -2 to save vs toxic chemicals and defoliants is saves.other. || SKILLS: the Prowl 76% +3% per level in natural surroundings is conditional (halved in cities) and is a special ability, not the catalog Prowl. || LEVEL-GATED: water absorption lasting two days per level, and the uprooting threshold of P.E. +1 per level, are prose in their abilities, worked out by hand: the book prints a formula for each and no table (BOOK-INGEST-AUDIT.md F130). || OCCUPATIONS: printed as favorites, not limits; Cybernetics and Bionics None, incompatible with the physiology, so the catalog''s cyborg O.C.C.s are excluded by name. || EQUIPMENT and MONEY: as per O.C.C. || NOT STORED: size 5 ft to 6 ft 6 in, weight 150-190 lbs, life span 2D6+50 years, NPC experience level 1D4, Also known as (Green Hunters, Plant Men, Libertines), psionics standard, magic only by O.C.C., habitat (forests of southern and eastern Canada and east of the Mississippi; first sighted 105 P.A.; fewer than 2,000 in North America), slave market value 3D6x1,000 credits, allies and enemies (the Spinne, tyrants and slavers). The ability names carry French accents in the book; they are written without them."
---

## Lore

The Chasseur Vert, or Green Hunters, are intelligent carnivorous plants
from the same world as the Spinne Spider People, their ancient rivals.
The old wars between the two have cooled into scorn on both sides: the
Green Hunters pity the Spinne as prisoners of tradition, which the
Spinne find maddening. For ages the Chasseur Vert hunted the Spinne for
sport and food, though that ended generations ago.

They stand around six feet, broad and strong, with cool, smooth, light
green skin like an aloe, tangled green-brown tendrils for hair, glittering
stone-like eyes and a jack-o''-lantern grin of sharp teeth. They live on
sunlight but still need meat, and can change color and release a
pheromone to bring prey to them, which makes them superb trappers,
scouts and rangers. They despise cities, build open, sunny homes of
natural materials, and live in large, close families. Passionate
hedonists and thinkers, they love food, drink, art and argument,
produce many poets, artists and philosophers, and are tireless foes of
tyranny and slavery. They first appeared on Rifts Earth in 105 P.A., and
fewer than two thousand live in North America.
',
       updated_at = datetime('now')
 WHERE class_id = 'chasseur-vert'
   AND instr(markdown, 'not modelled (BOOK-INGEST-AUDIT.md F116, since built, is an ability pick from a named list at set levels and does not cover this)') > 0
   AND length(markdown) = 8678;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 2 classes carry their new text' AS assertion, count(*) AS got, 2 AS want
  FROM imported_classes
 WHERE (class_id = 'arac' AND instr(markdown, 'added by hand at each level (BOOK-INGEST-AUDIT.md F130') > 0)
    OR (class_id = 'chasseur-vert' AND instr(markdown, 'no table (BOOK-INGEST-AUDIT.md F130)') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'arac' AND instr(markdown, 'not modelled (BOOK-INGEST-AUDIT.md F116, since built, is an ability pick from a named list at set levels and does not cover this)') > 0)
    OR (class_id = 'chasseur-vert' AND instr(markdown, 'not modelled (BOOK-INGEST-AUDIT.md F116, since built, is an ability pick from a named list at set levels and does not cover this)') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('arac', 'chasseur-vert') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~188-book-ingest-audit-f130-linear.sql');
