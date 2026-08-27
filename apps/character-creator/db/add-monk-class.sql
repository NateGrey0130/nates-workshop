-- The Monk O.C.C., Rifts Dimension Book 1: Wormwood p.59-62.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-monk-class.sql
--
-- Shares printed 59 with the Apok: the apok's O.C.C. block ends in the left
-- column and "Monk O.C.C." opens the right. The monk's own prayer list starts
-- at the foot of p.59 and finishes at the top of p.60; both halves were read.
--
-- THE AREA OF MASTERY GRANTS SKILLS AND THE APP CANNOT GRANT THEM
-- CONDITIONALLY. Each of the three areas confers its own list - Defense adds
-- Gymnastics, Running, Escape Artist and two W.P.s; Offense adds Acrobatics,
-- Boxing, W.P. Targeting and four W.P.s; Meditation adds Art, Prowl, Escape
-- Artist, Palming, Concealment, Climbing and two W.P.s - and which list you
-- get depends on a choice made at creation. special_abilities carries the
-- descriptions and the unconditional flat bonuses; the SKILLS are prose and
-- have to be added by hand. That is the one thing here the app does not model,
-- and it is a decision rather than an omission.
--
-- Two of those three lists grant skills the class's own related list EXCLUDES
-- - gymnastics, acrobatics and boxing - which is the book granting an
-- exception to its own restriction rather than a transcription error.
--
-- The monk grants NO W.P. of its own: "See area of Mastery for W.P. and
-- specific combat skills." That is why the O.C.C. skill list ends at
-- Hand to Hand: Martial Arts.
--
-- Hand-transcribed from the OCR cache (the scan has no text layer) and
-- validated with scripts/class-check.mjs --remote before this file was
-- written. Skill bases are the catalog base plus the printed O.C.C. bonus,
-- already added; a parenthetical WITHOUT a plus sign is an absolute
-- percentage, which is how this book prints its languages and its Lore:
-- Wormwood, so "Language: American (98%)" is base 98 rather than a bonus.
--
-- occ_group is clergy for all four. class-check does NOT require the key and
-- does not report it as unmodelled; regression.mjs DOES require it. All four
-- commune with Wormwood and meditate, and warrior-monk is already filed as
-- clergy despite being a warrior, which is the precedent for the apok.
--
-- Money: no starting_money. Every O.C.C. in this book prints
-- "Money: Not applicable" - Wormwood barters - and that is a property of the
-- setting rather than a failed extraction.
--
-- Pure ASCII, LF endings: the whole file, comments included.


-- The class itself. INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE,
-- so re-running the script is a no-op instead of a silent partial write.
--
-- Every apostrophe inside the markdown is doubled.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'monk', 'Monk', 'rifts', '---
id: monk
name: Monk
system: rifts
source_book: Rifts Dimension Book 1: Wormwood p.59-62
category: occ
occ_group: clergy
xp_table: [0, 2201, 4401, 8801, 17601, 24001, 35001, 50501, 72501, 98501, 140501, 200501, 250501, 300501, 400501]
mdc_base: "1d4x10+30, plus 1d6 per level of experience"
ppe_base: "1d6x10, plus 2d6 per level of experience"
bonuses:
  saves: { horror_factor: 3, possession: 3, spell_magic: 1 }
skills:
  occ_skills:
    - { name: "Lore: Demons & Monsters", base: 45, per_level: 5, note: "+20%; the book prints Lore: Monsters & Demons" }
    - { name: "Lore: Wormwood", base: 20, per_level: 5, note: "20% +5% per level; includes the history, legends and world information in this book" }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "The book prints this as Language: American (98%)." }
    - { name: "Language: Demongogian", base: 70, per_level: 5, note: "+20%" }
    - { name: "Literacy: Native Language", base: 45, per_level: 5, note: "+5%; the book prints Literacy American" }
    - { name: "Sing", base: 45, per_level: 5, note: "+10%" }
    - { name: "Mathematics: Basic", base: 75, per_level: 5, note: "+30%; the book prints Math: Basic" }
    - { name: "First Aid", base: 65, per_level: 5, note: "+20%" }
    - { name: "Wilderness Survival", base: 45, per_level: 5, note: "+15%" }
    - { name: "Hand to Hand: Martial Arts", note: "See the area of Mastery for W.P.s and the specific combat skills." }
  occ_related_skills:
    count: 6
    categories:
      - { name: "Communications" }
      - { name: "Domestic", bonus: 20 }
      - { name: "Espionage", bonus: 5 }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Boxing"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Air Assault Armor", "Combat Pod", "Military: Tanks & APCs", "Space: Small Spacecraft", "Space: Space Fighter", "Space: Starship"] }
      - { name: "Rogue", bonus: 5 }
      - { name: "Science", bonus: 10 }
      - { name: "Technical", bonus: 10 }
      - { name: "Weapon Proficiencies" }
      - { name: "Wilderness", bonus: 10 }
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
magic:
  type: "spell"
  spells_starting: 4
  spells_from: ["Close an Opening", "Create an Opening", "Create a Fountain of Water", "Locate Places of Evil", "Locate Food & Resources", "Locate Home Town", "Summon Battle Saints & Orbs", "Invisible to Magic Seeing"]
equipment_starting:
  - { item_id: "hooded-robe", qty: 2, note: "For travelling." }
  - { item_id: "sandals", qty: 1, note: "Sandals or moccasins." }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "first-aid-kit", qty: 1 }
  - { item_id: "sleeping-bag-rifts", qty: 1 }
  - { item_id: "blanket-light", qty: 1 }
  - { item_id: "small-sack", qty: "1d4", note: "The book says 1D4 medium size sacks; the catalog has no medium." }
  - { choose: 1, label: "backpack or saddlebag", qty: 1, from: ["backpack", "saddlebags"] }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "angel-hair-rope", qty: 1, note: "50 feet (15 m)." }
  - { item_id: "food-rations", qty: 1, note: "1D4 weeks of rations." }
special_abilities:
  - name: "Meditation"
    description: "Important for the monk to use his magic powers, his special martial arts powers of mastery, and to pilot battle saints and orbs. Meditation and prayer regain spent P.P.E. at ten points per hour, against four points an hour of ordinary rest, and increase healing threefold."
  - choose: 1
    from: ["The Art of Defense", "The Art of Offense", "The Art of Meditation & Spirit"]
    note: "Each monk studies ONE area of focus. It is the single biggest decision on the sheet - it sets his combat techniques, his bonuses, his extra skills and his disposition."
  - name: "The Art of Defense"
    description: "Defensive combat techniques: paired weapons, punch, kick, entangle, multiple attackers and Judo style body flip. Bonuses: +2 to roll with impact, +4 to pull punch, and +2 on initiative ONLY when defending, against -2 on initiative for acts of aggression. Additional skills: Gymnastics, Running, Escape Artist (+10%) and two W.P.s of choice from any category. Powers: (1) AUTOMATIC DODGE - dodge instead of parry without losing a melee action. (2) BODY HARDENING - +2D4x10 M.D.C., impervious to normal fire and cold, half damage from mega-damage fire and cold; the body is like iron and he can block blades, flaming swords and energy weapons bare-handed - it hurts and does damage but does not break the skin. Punches and kicks land like a lead pipe: 2D4 M.D. punch or 2D6 M.D. kick to supernatural monsters, 3D6 or 5D6 S.D.C. to mortals. (3) FAST HANDS - block or parry every attack from multiple attackers simultaneously without using up a melee action. (4) KICK PARRY - block a punch, kick or strike with feet and legs; the parry does no damage. (5) TUMBLE STRIKE - roll or somersault toward an attacker at +3 to dodge anything aimed at him, then bowl into him for normal damage and knock him down, costing him one melee attack and initiative. Disposition: calm, soft spoken and courteous; good natured, friendly, diplomatic, avoids unnecessary violence - and will not tolerate injustice or stand idle while the innocent are hurt."
    bonuses: { combat: { roll: 2, pull_punch: 4 } }
  - name: "The Art of Offense"
    description: "Offensive combat techniques: paired weapons, kick attack, jump kick, leap kick, multiple attackers and simultaneous attack. Bonuses: +2 on initiative, +1 to strike and one additional attack per melee round. Additional skills: Acrobatics, Boxing, W.P. Targeting and FOUR W.P.s of choice from any category. Powers: (1) SPIRIT FIST - a punch, jab or open hand strike inflicting 1D4x10 M.D. to supernatural beings, demons, elementals and creatures of magic including dragons (1D4x10 S.D.C. to non-mega-damage beings); costs two melee attacks. (2) SPIRIT KICK - 1D6x10 M.D. on the same terms, costing two melee attacks, and the kicker automatically loses initiative the following round. (3) SPIRIT LEAP KICK - 3D6x10 M.D., but it must be the character''s FIRST AND ONLY attack of that melee: the leap uses up every attack he had, and after landing he can only parry or dodge. (4) VITAL STRIKE - two melee attacks, and only on a natural unmodified 17-20; a lower roll that still hits does normal damage and burns the two actions anyway. Choose: disarm (weapons fly 1D4x10 feet, victim loses initiative and one action, and the monk gains a temporary horror factor of 12 - a failed save means the opponent surrenders or flees for 1D4 minutes); knock down and stun (victim loses two attacks, initiative and his footing); critical bull''s eye strike (double damage to exactly what he aimed at); or nerve strike (a limb is paralysed for 1D4 melee rounds). Disposition: bold, confident, outspoken, undiplomatic and aggressive; enjoys a challenge and hard labor, flamboyant and courageous, and actively seeks out injustice and cruelty in order to end it."
    bonuses: { combat: { initiative: 2, strike: 1, attacks: 1 } }
  - name: "The Art of Meditation & Spirit"
    description: "Basic combat techniques: punch, kick and Judo style body flip. Bonuses: +2 to roll with impact, +1 to pull punch, +1 on initiative, and recovers 15 P.P.E. per hour of meditation. Additional skills: Art (+10%), Prowl (+10%), Escape Artist (+10%), Palming (+10%), Concealment (+10%), Climbing (+10%) and two W.P.s of choice from any category. ONLY ONE POWER OF MEDITATION CAN BE USED AT A TIME. (1) INNER PHYSICAL STRENGTH - does not fatigue, half damage from heat and cold, +6 to P.S. and Spd, +4 to save vs poison, drugs or disease, +2 vs magic and psionics; three minutes per level, three times per 24 hours. (2) SPIRIT STRENGTH - overcome the penalties of exhaustion, pain, drugs, sickness, injury, insanity, psionics and magic by sheer force of will; while it holds they are completely gone, and when it ends they all return and he may collapse. Three minutes per level, three times per 24 hours. (3) THIRD EYE - see the invisible, sense evil, sense magic, +4 to save vs horror factor, impervious to possession and mind control, and cannot be tempted to act against his alignment or alliances; five minutes per level, three times per 24 hours. (4) DEATH STRIKE - used with great reluctance and it may kill him too. He summons all his physical, spiritual and magic energy (at least 20 P.P.E.), strikes bare-handed or with a kick, and ALWAYS hits for 2D4x100 M.D. or S.D.C. A survivor is paralysed and senseless for 2D4 minutes and afterwards runs at half speed, bonuses and attacks for 1D6x10 minutes. Once per 24 hours. It completely drains him: all P.P.E. gone, no meditative powers for twelve hours, helpless on the ground for 1D4 minutes, barely able to move for ten more (one action per round, speed down 80%, no bonuses, no skills, no attacks), then half of everything for six hours. Disposition: introspective thinkers and debaters with a love for life and art, willing to discuss any philosophy - and at the end of the debate they stand by their beliefs and stand up to any bully or monster."
    bonuses: { combat: { roll: 2, pull_punch: 1, initiative: 1 } }
restrictions: ["Sworn to an oath of poverty", "Has forsaken all political aspirations", "Cannot draw P.P.E. from other beings except by blood sacrifice", "Cybernetics and bionics are virtually non-existent"]
side_effects: "Most monks avoid symbiotes, but may acquire one or two over the years, and will use blood worms and worms of mending. Most wear little or no armor - the heavy and plate types interfere with movement, agility and speed - so chain mail and light armor at 40 M.D.C. with no prowl penalty are the only types considered."
extraction_notes: "Money: the book states outright that money is Not applicable on Wormwood - characters exchange goods and services for other goods and services - so no starting_money is stored. Monks are highly regarded by most communities, especially in demon infested lands. || The Monk SHARES printed 59 with the Apok: the Apok''s O.C.C. block ends in the left column and Monk O.C.C. opens the right, and the monk''s own prayer list starts at the foot of p.59 and finishes at the top of p.60. Both halves were read. || THE AREA OF MASTERY GRANTS SKILLS, AND THE APP CANNOT GRANT THEM CONDITIONALLY. Each of the three areas confers its own skill list - Defense adds Gymnastics, Running, Escape Artist and two W.P.s; Offense adds Acrobatics, Boxing, W.P. Targeting and four W.P.s; Meditation adds Art, Prowl, Escape Artist, Palming, Concealment, Climbing and two W.P.s - and those depend on a choice made at creation. special_abilities carries the descriptions and the flat bonuses, but the skills are recorded in prose and have to be added by hand. This is the one thing in this class the app does not model, and it is deliberate rather than missed. Note that Defense and Offense both grant skills the class''s own related list EXCLUDES (gymnastics, acrobatics, boxing), which is the book granting an exception to its own restriction. || The mastery bonuses that ARE stored are only the unconditional ones. The Art of Defense''s +2 on initiative applies ONLY when defending and carries -2 for acts of aggression, so neither number is stored; the +2 to roll and +4 to pull punch are. || The monk grants NO W.P. of its own - the book says to see the area of Mastery for W.P.s - which is why the O.C.C. skill list ends at Hand to Hand: Martial Arts."
---

## Lore

The monks are a loose knit set of religious communities that splintered away
from the laws and teachings of the Cathedral. Most believe the Cathedral is too
removed from the people and too concerned with material wealth and power, and
that its leaders are bogged down in bureaucracy and politics - a ponderous group
of plotters, too slow to decide anything and too slow to fight monsters.

Wormwood monks are very narrowly focused: destroy all monsters, help the
innocent. To stay in touch with the needs of the people they have taken an oath
of poverty and forsaken all political ambition, and they view those who have such
ambitions with distrust. They are common folk, like the people they protect. When
they are not in combat they work the fields, build, and help healers and
teachers. The typical monk is a hard working laborer as well as a master of hand
to hand combat.

The first ten years of a monk''s training are given entirely to the mastery of
himself and the martial arts; a disciple only becomes a first level monk after
those years. Monasteries are simple, bare bones communities where the young are
cloistered away from the temptations of the world to learn martial arts and
develop inner strength. Many learn to master their inner spirit in ways of
superhuman focus and control, and yet seldom find inner peace, because they are
so driven.

## GM Notes

Monks, along with the apok, recognize the evil and self-serving forces inside the
Cathedral and are not afraid to point them out. They can be extremely
self-righteous and outspoken, and many openly criticize the Cathedral and treat
its priests and Knights of the Temple with sarcasm and little respect. This has
created real animosity - even good priests and knights find a lot of monks
unnecessarily rude, crude and belligerent. A monk will, however, show great
respect and honor toward any knight, priest or fighter who has proven himself in
combat, and many treat the apok like celebrities.

Alignment runs roughly 2% evil, 13% selfish, 20% unprincipled, 40% scrupulous and
25% principled. p.52 places the monk at the top of the middle class, above the
average citizen and the freelance warrior; inside the Cathedral''s own hierarchy
he is sixth, below the apok.

**Pick the area of mastery before anything else.** It determines the monk''s
combat techniques, his skills, his bonuses and even his temperament, and the
three read as three different classes at the table: the Defense monk is an
unkillable bodyguard, the Offense monk deletes supernatural things with his bare
hands at a cost of two attacks apiece, and the Meditation monk is a philosopher
holding a once-a-day 2D4x100 M.D. death sentence he will be helpless for hours
after using.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'monk');


-- Read the result back rather than trusting the exit code. d1-apply prints
-- these, and a CR in the stored markdown means the checkout mangled the file.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'monk';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-monk-class.sql');
