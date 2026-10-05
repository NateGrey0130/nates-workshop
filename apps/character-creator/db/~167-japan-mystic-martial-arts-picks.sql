-- Five Japan classes pick their mystic martial arts powers at the levels their pages print
-- 5 classes, each replaced whole: mystic-ninja, bishamon-fighting-monk, sohei-warrior-monk, dragon-hatchling-kumo-mi, dragon-hatchling-asama-tatsu.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~167-japan-mystic-martial-arts-picks.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.
-- Close-out package C4, the Japan half: the mystic martial arts powers of
-- Rifts World Book 8: Japan printed 195-199, and the five classes that pick
-- from them at set levels (BOOK-INGEST-AUDIT F116, at_levels).
--
-- The section prints nineteen powers: six arts of invisibility, seven body
-- hardening exercises, six zenjoriki powers. There is no table for them
-- (F117 was closed without a catalog, on Nate's word), so each class carries
-- its own copy of the definitions it can pick; the copies are identical,
-- generated from one reconciled set.
--
--   mystic-ninja (printed 52): one art of invisibility at each of levels 1,
--     3, 6, 9, 12 and 15. Until now a single creation pick.
--   bishamon-fighting-monk (printed 55-56): one art at level 3, one more body
--     hardening exercise at each of levels 4 and 10, one zenjoriki at 14.
--     Until now prose, recorded by hand. Its own Chi-Gung is untouched.
--   sohei-warrior-monk (printed 59): one body hardening exercise at each of
--     levels 1, 5 and 9, one zenjoriki at 14. Until now the level-1 pick only.
--   dragon-hatchling-asama-tatsu (printed 215): one zenjoriki at each of
--     levels 2, 7 and 12; the level-20 pick is past the ladder and stays a
--     line for the G.M.
--   dragon-hatchling-kumo-mi (printed 214): one art and one zenjoriki, no
--     levels printed, as before; its definitions take the fuller text.
--
-- The two dragon hatchlings are RACES and may be paired with the three
-- occupations, and a character's picks are one flat list of names, so the
-- races' options are prefixed "Hatchling" (BOOK-INGEST-AUDIT F125's caution).
-- Production held no saved character on any of the five (queried 2026-10-05).
--
-- The powers were read off renders of printed 195-199 by one agent and checked
-- entry by entry by book-reconcile; each class's own page was read by a second
-- agent and checked by book-reconcile: no wrong figure, level or bonus.

-- == mystic-ninja ==
UPDATE imported_classes
   SET markdown = '---
id: mystic-ninja
occ_group: men-of-arms
men_of_arms: true
name: Mystic Ninja
system: rifts
source_book: Rifts World Book 8: Japan p.51-55
category: occ
tags: [combat, stealth]
xp_table: [0, 2401, 4601, 9201, 18401, 28301, 48001, 78001, 110001, 150001, 200001, 250001, 310001, 380001, 470001]
attribute_requirements: { IQ: 9, MA: 12, PP: 14 }
ppe_base: "1d4x10 plus P.E. attribute number, +2d6 per additional level of experience"
starting_money: "2d6x100"
bonuses:
  saves: { horror_factor: 1, other: [{ label: "vs illusions", bonus: 1 }] }
  at_level:
    - { level: 2, saves: { horror_factor: 1 } }
    - { level: 4, saves: { horror_factor: 1 } }
    - { level: 5, saves: { horror_factor: 1 } }
    - { level: 7, saves: { horror_factor: 1 } }
    - { level: 9, saves: { horror_factor: 1 } }
    - { level: 11, saves: { horror_factor: 1 } }
    - { level: 15, saves: { horror_factor: 1 } }
psionics:
  type: "major"
  isp_base: "1d4x10 plus M.E. attribute number, +1d6+2 per additional level of experience"
  powers: ["Bio-Regeneration", "Induce Sleep"]
  categories_allowed: ["Physical"]
  powers_schedule:
    - { level: 2, count: 1, categories: ["Physical"] }
    - { level: 3, count: 1, categories: ["Physical"] }
    - { level: 4, count: 1, categories: ["Physical"] }
    - { level: 5, count: 1, categories: ["Physical"] }
    - { level: 6, count: 1, categories: ["Physical"] }
    - { level: 6, count: 1, from: ["Psi-Sword"], note: "The super-psionic power of Psi-Sword, gained at level six." }
    - { level: 7, count: 1, categories: ["Physical"] }
    - { level: 8, count: 1, categories: ["Physical"] }
    - { level: 9, count: 1, categories: ["Physical"] }
    - { level: 10, count: 1, categories: ["Physical"] }
    - { level: 11, count: 1, categories: ["Physical"] }
    - { level: 12, count: 1, categories: ["Physical"] }
    - { level: 13, count: 1, categories: ["Physical"] }
    - { level: 14, count: 1, categories: ["Physical"] }
    - { level: 15, count: 1, categories: ["Physical"] }
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Acrobatics", base: 35, per_level: 5, note: "+5%" }
    - { name: "Climbing", base: 55, per_level: 5, note: "+15%" }
    - { name: "Disguise", base: 45, per_level: 5, note: "+20%" }
    - { name: "Forgery", base: 30, per_level: 5, note: "+10%" }
    - { name: "Imitate Voices & Sounds", base: 56, per_level: 4, note: "+14%; the book prints Imitate Voices." }
    - { name: "Palming", base: 35, per_level: 5, note: "+15%" }
    - { name: "Pick Locks", base: 40, per_level: 5, note: "+10%; the book prints (10%) without a plus sign." }
    - { name: "Prowl", base: 35, per_level: 5, note: "+10%" }
    - { name: "Streetwise", base: 40, per_level: 4, note: "+20%" }
    - { name: "Swimming", base: 60, per_level: 5, note: "+10%" }
    - { name: "Language: Native Tongue", base: 96, per_level: 0, note: "The book prints Language: Japanese at 96%." }
    - { name: "Literacy: Native Language", base: 96, per_level: 0, note: "The book prints Literate in Japanese at 96%." }
    - { choose: 2, from: ["Language: Chinese", "Language: Mongolian", "Language: Russian", "Language: Euro", "Language: Spanish", "Language: Dragonese", "Language: Gobblely", "Language: Other"], bonus: 15, note: "Two additional languages to speak (+15%)." }
    - { name: "Horsemanship: General", base: 54, per_level: 4, note: "Ninja Horsemanship: ride any horse-like creature at 54% +4% per level (printed 54), the same as the samurai''s. Roll for a leap or a difficult maneuver such as riding while shooting a bow." }
    - { name: "W.P. Chain", base: 0, per_level: 0 }
    - { name: "W.P. Sword", base: 0, per_level: 0 }
    - { name: "W.P. Small Thrown Weapons", base: 0, per_level: 0 }
    - { name: "W.P. Archery", base: 0, per_level: 0, note: "The book prints W.P. Archery and Targeting. The ninja''s own short-bow rate of fire and range are under Ninja Bowmanship." }
    - { name: "Hand to Hand: Ninjitsu", base: 0, per_level: 0, note: "Printed Ninjutsu/Tai-Jutsu. Exclusive; no alternatives are possible." }
  occ_related_skills:
    count: 4
    categories:
      - "Communications"
      - { name: "Domestic", bonus: 10 }
      - { name: "Espionage", bonus: 10 }
      - { name: "Medical", only: ["First Aid", "Holistic Medicine"] }
      - { name: "Military", only: ["Camouflage"] }
      - { name: "Physical", bonus: 5 }
      - { name: "Pilot", only: ["Motorcycles & Snowmobiles", "Hover Craft (ground)"] }
      - { name: "Horsemanship", only: ["Horsemanship: Exotic Animals"] }
      - { name: "Rogue", except: ["Computer Hacking"], bonus: 10 }
      - "Science"
      - "Technical"
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 5 }
    note: "Electrical, Mechanical and Pilot Related: none. Pilot: horsemanship (exotic animals), motorcycle and hover car only. Technical: any, +10% on all language skills (add it to a language pick by hand). Physical: +5% when applicable. Weapon proficiencies: any, though ninja tend to stick with ancient types."
    schedule:
      - { level: 3, count: 1 }
      - { level: 5, count: 1 }
      - { level: 7, count: 1 }
      - { level: 9, count: 1 }
      - { level: 11, count: 1 }
      - { level: 15, count: 1 }
  secondary_skills:
    count: 0
    categories:
      - "Communications"
      - "Domestic"
      - "Espionage"
      - { name: "Medical", only: ["First Aid", "Holistic Medicine"] }
      - { name: "Military", only: ["Camouflage"] }
      - "Physical"
      - { name: "Pilot", only: ["Motorcycles & Snowmobiles", "Hover Craft (ground)"] }
      - { name: "Horsemanship", only: ["Horsemanship: Exotic Animals"] }
      - { name: "Rogue", except: ["Computer Hacking"] }
      - "Science"
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
    schedule:
      - { level: 2, count: 2 }
      - { level: 5, count: 2 }
      - { level: 9, count: 2 }
      - { level: 12, count: 2 }
equipment_starting:
  - { item_id: "clothing", qty: 1, note: "A set of regular, nondescript clothing, usually peasant or traveler garb, and several simple disguises." }
  - { item_id: "ninja-clothing-and-boots", qty: 1, note: "A black or camouflage ninja outfit; the book also gives two pairs of rubber-soled tabi boots." }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "food-rations", qty: "2d4", note: "2D4 days of rations." }
  - { item_id: "survival-kit", qty: 1, note: "Basic survival gear." }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "shuriken-rifts", qty: 12 }
  - { choose: 2, label: "ancient weapons of choice", qty: 1, from: ["katana-rifts", "wakizashi-rifts", "ninja-to-ninja-short-sword", "aikuchi-tanto-rifts", "kusari-gama-rifts", "manriki-gusari-rifts", "kusari-fundo", "kyoketsu-shoge", "nunchaku-rifts", "jitte-or-sai-rifts", "tonfa-rifts", "shikomi-zue-rifts", "shinobi-zue", "naginata-yari-rifts", "short-bow-rifts", "kawanga-rifts"], note: "The book says two ancient weapons of choice, usually concealable, without naming them; this is the catalog set of this book''s traditional weapons." }
  - { choose: 1, label: "vibro-blade", qty: 1, from: ["vibro-knife-tanto-jitte-sai", "vibro-saber-short-sword-ninja-short-sword", "vibro-katana", "vibro-wakizashi", "vibro-knife", "vibro-saber", "vibro-sword"], note: "The book says one vibro-blade without naming it; this book''s own vibro-blades (printed 117) come first." }
  - { item_id: "ninja-emergency-kit-rifts", qty: "1d4", note: "Carried or stored in the vicinity." }
special_abilities:
  - name: "Mega-Damage Transformation"
    description: "By will and concentration the ninja temporarily converts his hit points and S.D.C., including S.D.C. from physical skills, into M.D.C., becoming a mega-damage creature. Duration: three minutes per level of experience. Cost: 35 P.P.E. per transformation. Damage heals at the normal non-M.D.C. rate, since it is still his hit points and S.D.C. being hurt. His punches and kicks still inflict S.D.C. damage while transformed."
  - name: "Art of Escape (Inton-Jutsu)"
    description: "Like the escape artist skill but more complete: the ninja can dislocate joints and contort to slip bonds and squeeze into small openings, with muscle control, knots and ropes, and concealing tiny objects on the body. It does not include picking locks. Escapes handcuffs, locked chains, tied rope or plastic bonds automatically in 1D4 melee rounds; a straightjacket or similar restraint takes 1D4 melee rounds and a successful roll (each attempt takes time and may make noise). Escapes a hold in one melee action and a joint lock in one full melee round. High-tech restraints, confinement and difficult maneuvers take a roll and 3D4 melee rounds. Base skill: 46% +3% per level of experience."
  - name: "Ninja Bowmanship"
    description: "Uses the concealable short bow. Rate of fire with a short bow: two shots at level one, +1 at levels 2, 4, 6, 8, 10, 12 and 14; half that with a long bow. Effective range with a short bow: 320 ft (97.5 m) +10 ft (3.0 m) per level. Loses all bonuses to strike and half the rate of fire when off balance or shooting from a moving vehicle or horseback; the same penalties apply with a samurai long bow. The ninja may try to dodge arrows at -3, and energy blasts or gunfire at -6; a dodge counts as one melee action."
  - name: "False Identities"
    description: "Starts with two false, real-world identities (for example a sake merchant and a monk) and creates more aliases throughout life."
  - name: "P.P.E. from Chi-Mastery"
    description: "The ninja''s P.P.E. comes from an inward focus through meditation and ninjutsu, so he cannot draw P.P.E. from others, ley lines or nexus points. P.P.E. recovers at three points an hour, or six an hour through meditation. Hand to Hand: Ninjitsu doubles existing P.P.E. at level 11."
  - { choose: 1, at_levels: [1, 3, 6, 9, 12, 15], from: ["Art of Stealth (Pi Mi Hsing Tung)", "Art of Hiding (Inpo)", "Art of Evasion (Hsing Tsia)", "Art of Vanishing (Sun Shih K''an Chien Chih)", "Art of Disguise (Hensho-Jutsu)", "Art of Mystic Invisibility (Chi Zoshiki)"], note: "The Mystic Art of Stealth (printed 52): select one art of invisibility at each of levels 1, 3, 6, 9, 12 and 15, so all six are known by level 15. The arts are printed 195-196." }
  - name: "Art of Stealth (Pi Mi Hsing Tung)"
    description: "Mystic Art of Invisibility, the martial equivalent of prowl. Moving silently and out of sight in the dark while unsuspected is automatic, with no prowl roll; if the area comes under inspection (a spotlight, investigators) the chance to stay undetected is 43% +3% per level. Also Jung Hua, melting into water: moving silently into, out of and through water at 50% +3% per level (deep water requires the swimming skill)."
  - name: "Art of Hiding (Inpo)"
    description: "Mystic Art of Invisibility: becoming one with a surrounding object and staying motionless for hours or even days. Normally no chance of detection; in a well-lit area under careful inspection the chance to remain undetected is 60% +3% per level. Works only while the character stays motionless."
  - name: "Art of Evasion (Hsing Tsia)"
    description: "Mystic Art of Invisibility: staying out of view behind someone, turning as he turns. Automatic if the enemy is unaware of the character; if he knows or suspects someone is behind him, 50% +3% per level. The character can keep attacking from behind (critical strikes, knockout attacks) for as long as each roll keeps him unseen. Fails if a companion of the victim can see the attacker and warn him, or if the victim backs against a wall. Only the person stalked is fooled; everyone else sees both clearly. Once the victim catches sight of the stalker the power is negated and cannot be resumed unless the character can also vanish."
  - name: "Art of Vanishing (Sun Shih K''an Chien Chih)"
    description: "Mystic Art of Invisibility: disappearing from clear view, even mid-combat, by distraction and a sudden drop or roll. 85% +1% per level in full darkness with many obstructions; cumulative penalties of -10% in fair light, -20% in strong light, -15% on clear, flat, featureless ground, and -20% when cornered with nowhere to go but forward (or up, or down). The book''s example: a first level character in strong light on flat ground needs 50 or less. Lasts one melee action (two or three seconds), enough to begin the art of evasion or another ability, and the act of vanishing counts as one melee action."
  - name: "Art of Disguise (Hensho-Jutsu)"
    description: "Mystic Art of Invisibility: instantly changing posture, stance, walk and expression to pass as someone else in the same clothes. Automatic in crowds of 100 or more people; in smaller crowds or sparsely peopled areas 50% +3% per level, -40% if stopped and specifically questioned or searched. Combined with the Disguise skill: 96% to conceal true identity and 88% to physically impersonate a specific person or occupation (the latter after hours of study and practice). Useless in an outrageous outfit such as a ninja suit, though a hood or garment can be whipped off in a moment."
  - name: "Art of Mystic Invisibility (Chi Zoshiki)"
    description: "Mystic Art of Invisibility: clouding the minds of observers so the character vanishes even while standing in full view. Costs 1 P.P.E. per melee round (15 seconds) of invisibility, 4 P.P.E. per round to cloud 2-8 people at once, 12 per round for more than eight. He must turn visible to fight or to use any skill other than the arts of invisibility. It also shields his P.P.E. from magic and psionic detection and from being siphoned: detect magic, detect psionics and see the invisible cannot locate him, and those clouded cannot see him with optics or motion detectors either. Save: 19 or higher, rolled once for a whole group; a successful save means he is still seen. May try to turn invisible once per melee round."
restrictions:
  - "Cybernetics: none; they interfere with psionics, the magic transformation and the arts of stealth (-40% penalty with cybernetics or bionics). Only bio-systems may be considered."
  - "Hand to Hand: Ninjitsu is exclusive; no other hand to hand style is possible."
  - "No high-tech weapons, armor or tools to start; they may be acquired later."
extraction_notes: "Rifts World Book 8: Japan printed 51-55 (cache p052-p056, text layer, page_offset +1). The class runs from the Mystic Ninja O.C.C. heading on printed 51 through the Money and Cybernetics lines at the top of printed 54; Traditional Ninja Equipment and Ninja Gimmick Clothing follow on 54-55 (catalog gear rows from add-a-japan-traditional-gear.sql, none granted at start beyond the outfit, shuriken and emergency kits). Class stat block read from renders of printed 53 and 54; the Arts of Invisibility from a render of printed 195 (cache 196, a corrupt page). || GROUP: the book files the class under New Empire & Traditional O.C.C.''s (contents, printed 4), which names no group. Stored as men-of-arms with men_of_arms true because it is a warrior class built on Hand to Hand: Ninjitsu; its psionics are major but secondary. A judgment call. || XP: the Tech-Ninja, Mystic Ninja column of the Experience Point Tables (printed 216, cache p217), read off a render. || SKILLS: Japanese is stored as Language: Native Tongue and Literacy: Native Language at 96%; the catalog has no Japanese row. Pick Locks prints (10%) with no plus sign; read as +10%. Acrobatics prints (+5) with no percent sign; read as +5%. W.P. Archery and Targeting is stored as W.P. Archery (RUE), not the book''s own W.P. Bow. Ninja Horsemanship (54% +4%) is stored as Horsemanship: General at the printed percentage. Technical''s +10% applies to language skills only and cannot be stated per skill, so it is in the related-skills note. Secondary skills: none at level one, two at each of levels 2, 5, 9 and 12, the book''s own phrasing elsewhere (printed 53). || HAND TO HAND: the style''s attribute bonuses and level table live on the Hand to Hand: Ninjitsu catalog row and are not repeated here. || PSIONICS: major; Bio-Regeneration (self, via meditation) and Induce Sleep at level one, one Physical power per level from two, and Psi-Sword at level six. I.S.P. 1D4x10 plus M.E., +1D6+2 per level. || MYSTIC MARTIAL ARTS: the book gives one Art of Invisibility (it calls the category the Art of Stealth) at levels 1, 3, 6, 9, 12 and 15. Stored as one pick group over the six arts taken at those six levels (BOOK-INGEST-AUDIT.md F116). || NOT STORED AS NUMBERS: the Mega-Damage Transformation is temporary and paid in P.P.E., so it is an ability, not mdc_from_hp_sdc. The bow''s dodge penalties are conditional and are prose. The save vs illusions is saves.other, not illusionary_magic. || 2026-10-05, MYSTIC ART OF STEALTH: printed 52, ability 2, read off a render: the character selects one power from the category at levels 1, 3, 6, 9, 12 and 15. Stored as one pick group with at_levels [1, 3, 6, 9, 12, 15] over the six arts of invisibility, level 1 being the creation pick; six picks over six arts, so every art is held by level 15 (BOOK-INGEST-AUDIT.md F116). The six definitions were replaced with the readings of printed 195-196 shared by every Japan class that takes these powers; none prints an unconditional number, so none carries bonuses. The Art of Escape (Inton-Jutsu), ability 3 on printed 52, is granted outright, is printed only on this page and is not in that category; its definition was checked against the render (1D4 melee rounds, 3D4 melee rounds, 46% +3% per level) and left as it was."
---

## Lore

The ninja clans of old Japan arose as peasant warrior societies opposed to the samurai who alone could bear arms. Barred from weapons and from work as fighters, they built their own secret martial arts, tools and techniques around stealth, disguise and absolute secrecy, and became the ultimate warriors for hire: spies, saboteurs and sometimes assassins, though never necessarily evil. They worked in small teams, used shuriken and smoke to cover an escape rather than to kill, hid tools in concealed pockets, and learned to dislocate their own joints to slip bonds and pass through narrow openings. Many were also fine swordsmen, archers and horsemen.

In Rifts Japan the ninja is little changed, except that intense training and deep spirituality in a magic-rich world have given the mystic ninja superhuman powers. Many regard these shadow warriors as supernatural agents of death. The mission comes first; killing is done only when it becomes necessary.

A clan keeps its members'' identities secret. The genin, or field ninja, live ordinary lives as merchants, priests or farmers until summoned, often with two or more false identities; the chunin deal with clients; the jonin who leads the clan is seen only by the chunin. A ninja whose capture would do the clan irreparable harm may take his own life rather than talk. The clans have friends among the eta, mercenaries and pirates across Japan.

## Player Notes

A player character may hide his occupation from his own group by posing as another O.C.C. (a monk, priest, ronin, mercenary, wilderness scout, vagabond or peasant), or may appear openly as a ninja, masked and in black, never revealing his true identity. He may come to trust companions enough to reveal one of his false identities.

The clan may call on the character for a mission of sabotage, espionage or assassination that cuts against the group''s plans, even setting him against its members. Defying the clan means another ninja or a team of 3-6 is sent to do the job, and the defiant ninja is marked as a traitor to be hunted down and silenced.

## Mystic Arts of Invisibility

The ninja selects one Mystic Art of Invisibility at level 1 and one more at each of levels 3, 6, 9, 12 and 15 (the ability choice above, offered again at each of those levels), so by level 15 he knows all six: Stealth, Hiding, Evasion, Vanishing, Disguise and Mystic Invisibility. Each art is described in the abilities above.

## Equipment and Money

Equipment is kept to a minimum. Besides the listed gear the ninja carries some personal items and two pairs of rubber-soled tabi boots. Weaponry is usually ancient and concealable. The ninja adapts to his world and may later use some technology, such as vibro-blades, laser scalpels, body armor and vehicles, but starts with none beyond the one vibro-blade. The clan provides or sells the traditional ninja equipment and gimmick clothing, which is not available to the public. Money: 2D6x100 credits in saleable items.
',
       updated_at = datetime('now')
 WHERE class_id = 'mystic-ninja'
   AND instr(markdown, 'record the later picks by hand as the character levels') > 0
   AND length(markdown) = 18799;

-- == bishamon-fighting-monk ==
UPDATE imported_classes
   SET markdown = '---
id: bishamon-fighting-monk
name: Bishamon Fighting Monk
system: rifts
source_book: Rifts World Book 8: Japan p.55-57
category: occ
tags: [combat, divine]
occ_group: men-of-arms
men_of_arms: true
xp_table: [0, 2201, 4401, 8801, 17601, 24001, 35001, 50501, 72501, 98501, 140501, 200501, 250501, 325501, 400501]
race_restrictions: { only: ["none"], note: "Human only. The order accepts other human races, but never D-Bees, however human they look. Men only: the order has no women warriors." }
attribute_requirements: { ME: 14, PP: 12, PE: 12 }
ppe_base: "P.E. x2, plus 2d6 per level of experience"
starting_money: "4d6x100"
bonuses:
  attributes: { PE: 1 }
  pools: { hp: "2d6", sdc: 90 }
  saves: { possession: 6 }
  at_level:
    - { level: 2, saves: { horror_factor: 1 } }
    - { level: 4, saves: { horror_factor: 1 } }
    - { level: 8, saves: { horror_factor: 1 } }
    - { level: 10, saves: { horror_factor: 1 } }
    - { level: 13, saves: { horror_factor: 1 } }
    - { level: 15, saves: { horror_factor: 1 } }
psionics:
  type: "major"
  isp_base: "M.E. attribute number plus 2d4x10, +1d6+2 per level of experience"
  powers: ["Deaden Pain", "Exorcism", "Healing Touch", "Psychic Diagnosis", "Psychic Purification", "Psychic Surgery"]
  powers_starting: 0
  powers_schedule:
    - { level: 3, count: 3, from: ["Resist Hunger", "Resist Thirst", "Mind Block"], note: "Resist Hunger, Resist Thirst and Mind Block are all granted at third level." }
    - { level: 6, count: 2, from: ["See The Invisible", "Summon Inner Strength"], note: "See the Invisible and Summon Inner Strength are both granted at sixth level." }
    - { level: 9, count: 2, from: ["Nightvision", "Resist Fatigue"], note: "Nightvision and Resist Fatigue are both granted at ninth level." }
    - { level: 12, count: 1, from: ["Pyrokinesis"], note: "Pyrokinesis is granted at twelfth level." }
    - { level: 15, count: 1, from: ["Psi-Shield"], note: "Psi-Shield is granted at fifteenth level." }
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Carpentry", base: 35, per_level: 5, note: "+10%" }
    - { name: "Cook", base: 45, per_level: 5, note: "+10%" }
    - { name: "Dance", base: 40, per_level: 5, note: "+10%" }
    - { name: "Play Musical Instrument", base: 45, per_level: 5, note: "+10%; one instrument of choice." }
    - { name: "Literacy: Native Language", base: 98, per_level: 0, note: "The book prints Literacy: Japanese at 98%." }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "The book prints Language: Japanese at 98%." }
    - { choose: 2, from: ["Language: Other"], bonus: 20, note: "Two additional languages of choice (+20% each)." }
    - { name: "Lore: Demons & Monsters", base: 35, per_level: 5, note: "+10%" }
    - { name: "Mathematics: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Holistic Medicine", base: 32, per_level: 5, note: "+12%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { name: "Tracking (people)", base: 35, per_level: 5, note: "+10%; the book prints Tracking, of oni and humans." }
    - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Begging", base: 10, per_level: 3, note: "A temple skill; the book prints 10% +3% per level for the bishamon." }
    - { name: "Fasting", base: 33, per_level: 3, note: "A temple skill; the book prints 33% +3% per level for the bishamon. Two weeks without food is easy with water; after that, roll under the skill to avoid weakness or sickness." }
    - { choose: 1, from: ["Japanese Mythology", "Lore: Magic", "Calligraphy", "Poetry (Haiku)", "Go", "Gardening"], bonus: 10, note: "Oriental Philosophies: one of Japanese mythology, magic lore, calligraphy, haiku poetry, go or (Zen) gardening (+10%)." }
    - { name: "W.P. Staff", base: 0, per_level: 0, note: "Does not include jodo skills and bonuses." }
    - { name: "W.P. Sword", base: 0, per_level: 0, note: "Does not include the daisho or paired weapons." }
    - { name: "Hand to Hand: Aikido", base: 0, per_level: 0, note: "No other combat alternatives are allowed." }
  occ_related_skills:
    count: 4
    categories:
      - { name: "Domestic", bonus: 10 }
      - { name: "Espionage", bonus: 5 }
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Rogue", bonus: 6, except: ["Computer Hacking"] }
      - "Science"
      - { name: "Technical", bonus: 10, except: ["Computer Operation", "Computer Programming", "Photography"] }
      - { name: "Weapon Proficiencies", only: ["W.P. Archery", "W.P. Axe", "W.P. Blunt", "W.P. Bola", "W.P. Bow", "W.P. Chain", "W.P. Cross Bow", "W.P. Forked", "W.P. Knife", "W.P. Lance", "W.P. Mouth Weapons (Blow Guns)", "W.P. Paired Weapons", "W.P. Pole Arm", "W.P. Rope", "W.P. Shield", "W.P. Slingshot", "W.P. Small Thrown Weapons", "W.P. Spear", "W.P. Staff", "W.P. Sword", "W.P. Targeting", "W.P. Tomahawk", "W.P. Trident", "W.P. Whip"] }
      - { name: "Wilderness", bonus: 10 }
    note: "Communications, Electrical, Mechanical, Military, Pilot and Pilot Related: none (monks walk or ride in carts and vehicles). Medical: Mystic Herbology only (+10%), a Rifts England skill the catalog does not hold. Weapon Proficiencies: ancient only. All new skills start at level one proficiency."
    schedule:
      - { level: 3, count: 1 }
      - { level: 7, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 0
    categories:
      - "Domestic"
      - "Espionage"
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Rogue", except: ["Computer Hacking"] }
      - "Science"
      - { name: "Technical", except: ["Computer Operation", "Computer Programming", "Photography"] }
      - { name: "Weapon Proficiencies", only: ["W.P. Archery", "W.P. Axe", "W.P. Blunt", "W.P. Bola", "W.P. Bow", "W.P. Chain", "W.P. Cross Bow", "W.P. Forked", "W.P. Knife", "W.P. Lance", "W.P. Mouth Weapons (Blow Guns)", "W.P. Paired Weapons", "W.P. Pole Arm", "W.P. Rope", "W.P. Shield", "W.P. Slingshot", "W.P. Small Thrown Weapons", "W.P. Spear", "W.P. Staff", "W.P. Sword", "W.P. Targeting", "W.P. Tomahawk", "W.P. Trident", "W.P. Whip"] }
      - "Wilderness"
    note: "None at first level: two secondary skills at levels three, six, nine and twelve, from the related list and its limits, without its bonuses."
    schedule:
      - { level: 3, count: 2 }
      - { level: 6, count: 2 }
      - { level: 9, count: 2 }
      - { level: 12, count: 2 }
equipment_starting:
  - { item_id: "traveling-clothes", qty: 1, note: "Several changes of clothes suitable for wilderness travel." }
  - { item_id: "boots", qty: 1, note: "Boots suitable for wilderness travel." }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "belt", qty: 1 }
  - { item_id: "bedroll", qty: 1, note: "The book prints sleeping roll." }
  - { item_id: "large-sack", qty: 1 }
  - { item_id: "small-sack", qty: "1d6" }
  - { item_id: "specimen-jar", qty: 1, note: "Glass or clay jars and specimen containers." }
  - { item_id: "rope", qty: 2, note: "50 ft (15.2 m); the catalog sells rope per 40 ft." }
  - { item_id: "utensil-kit", qty: 1, note: "The book prints cooking utensils." }
  - { item_id: "food-rations", qty: "3d4", note: "3D4 days of rations." }
  - { item_id: "water-skin", qty: 1 }
  - { item_id: "knife", qty: 1 }
  - { item_id: "sohei-staff-of-defense", qty: 1, note: "A wooden staff made from a Millennium Tree, the same as the sohei monk''s." }
  - { item_id: "weapons-matching-w-p-skills", qty: 1, note: "One ancient weapon of choice." }
  - { item_id: "small-mallet", qty: 1 }
  - { item_id: "spikes-wooden-stakes-6-wood", qty: 1, note: "Six wooden stakes (1D6 S.D.C.)." }
  - { item_id: "medical-bag", qty: 1, note: "A satchel or side pouch of medical supplies, always carried: first-aid items, scissors, plant snippers, knives, bowls and specimen jars, and 1D6x5 non-magical herbs (see Rifts England)." }
special_abilities:
  - name: "Chi-Gung: Mega-Damage Skin"
    description: "A body hardening exercise, part inner spirit, part training, part mysticism. The skin has a natural A.R. of 18 and the monk has at least 100 S.D.C.; whenever chi-gung focus is used, the S.D.C. and hit points of that skin become mega-damage. Costs 1 P.P.E. per two minutes (8 melee rounds). S.D.C. and hit points lost as M.D.C. recover as usual. Its +1 P.E., +2D6 hit points and +90 S.D.C. are in the class bonuses."
  - name: "Chi M.D. Death Blow"
    description: "Against oni, demons, dragons, elementals and other supernatural beings and creatures of magic, a punch, kick, sword, staff or spear strike does double normal damage plus P.S. damage bonus as mega-damage, and the creature cannot bio-regenerate that injury for 1D4 hours. Counts as two melee attacks. The monk must be pure of spirit and intent: never in anger, fear or revenge. Not against bots, borgs, power armor or other non-supernatural M.D.C. targets, and never with guns or bows. It draws on the monk''s P.P.E. and counts as a magical attack. Same as the samurai (printed 47)."
  - name: "Mystic Martial Arts Powers"
    description: "One mystic art of invisibility at level 3, one additional body hardening exercise at each of levels 4 and 10, and one zenjoriki power at level 14 (printed 56), each chosen from the groups below when the level is reached. Nothing is chosen at level 1. Chi-Gung is already known and is not offered again. The bonuses of several body hardening exercises are cumulative."
  - { choose: 1, at_levels: [3], from: ["Art of Stealth (Pi Mi Hsing Tung)", "Art of Hiding (Inpo)", "Art of Evasion (Hsing Tsia)", "Art of Vanishing (Sun Shih K''an Chien Chih)", "Art of Disguise (Hensho-Jutsu)", "Art of Mystic Invisibility (Chi Zoshiki)"], note: "One mystic art of invisibility, selected at level three (printed 56; the arts are printed 195-196)." }
  - name: "Art of Stealth (Pi Mi Hsing Tung)"
    description: "Mystic Art of Invisibility, the martial equivalent of prowl. Moving silently and out of sight in the dark while unsuspected is automatic, with no prowl roll; if the area comes under inspection (a spotlight, investigators) the chance to stay undetected is 43% +3% per level. Also Jung Hua, melting into water: moving silently into, out of and through water at 50% +3% per level (deep water requires the swimming skill)."
  - name: "Art of Hiding (Inpo)"
    description: "Mystic Art of Invisibility: becoming one with a surrounding object and staying motionless for hours or even days. Normally no chance of detection; in a well-lit area under careful inspection the chance to remain undetected is 60% +3% per level. Works only while the character stays motionless."
  - name: "Art of Evasion (Hsing Tsia)"
    description: "Mystic Art of Invisibility: staying out of view behind someone, turning as he turns. Automatic if the enemy is unaware of the character; if he knows or suspects someone is behind him, 50% +3% per level. The character can keep attacking from behind (critical strikes, knockout attacks) for as long as each roll keeps him unseen. Fails if a companion of the victim can see the attacker and warn him, or if the victim backs against a wall. Only the person stalked is fooled; everyone else sees both clearly. Once the victim catches sight of the stalker the power is negated and cannot be resumed unless the character can also vanish."
  - name: "Art of Vanishing (Sun Shih K''an Chien Chih)"
    description: "Mystic Art of Invisibility: disappearing from clear view, even mid-combat, by distraction and a sudden drop or roll. 85% +1% per level in full darkness with many obstructions; cumulative penalties of -10% in fair light, -20% in strong light, -15% on clear, flat, featureless ground, and -20% when cornered with nowhere to go but forward (or up, or down). The book''s example: a first level character in strong light on flat ground needs 50 or less. Lasts one melee action (two or three seconds), enough to begin the art of evasion or another ability, and the act of vanishing counts as one melee action."
  - name: "Art of Disguise (Hensho-Jutsu)"
    description: "Mystic Art of Invisibility: instantly changing posture, stance, walk and expression to pass as someone else in the same clothes. Automatic in crowds of 100 or more people; in smaller crowds or sparsely peopled areas 50% +3% per level, -40% if stopped and specifically questioned or searched. Combined with the Disguise skill: 96% to conceal true identity and 88% to physically impersonate a specific person or occupation (the latter after hours of study and practice). Useless in an outrageous outfit such as a ninja suit, though a hood or garment can be whipped off in a moment."
  - name: "Art of Mystic Invisibility (Chi Zoshiki)"
    description: "Mystic Art of Invisibility: clouding the minds of observers so the character vanishes even while standing in full view. Costs 1 P.P.E. per melee round (15 seconds) of invisibility, 4 P.P.E. per round to cloud 2-8 people at once, 12 per round for more than eight. He must turn visible to fight or to use any skill other than the arts of invisibility. It also shields his P.P.E. from magic and psionic detection and from being siphoned: detect magic, detect psionics and see the invisible cannot locate him, and those clouded cannot see him with optics or motion detectors either. Save: 19 or higher, rolled once for a whole group; a successful save means he is still seen. May try to turn invisible once per melee round."
  - { choose: 1, at_levels: [4, 10], from: ["Stone Ox", "Kangeiko & Shochu Geiko", "Iron Hand (Kanshu)", "Dam Sum Sing", "Wrist Hardening", "Kick Practice (Chagi)"], note: "One additional body hardening exercise at level 4 and another at level 10 (printed 56; the exercises are printed 196-197). Chi-Gung Mega-Damage Skin is the seventh exercise; the monk already has it and it is not offered." }
  - name: "Stone Ox"
    description: "Body hardening: the ultimate endurance training. Fatigues at half the normal rate and can lift and carry 50 times the normal weight capacity. +2 P.S., +1 P.E., +4D4x10 S.D.C., on top of any O.C.C. and skill bonuses. Immune to the vital strike atemi. As with every body hardening exercise, 5 P.P.E. turns the character''s S.D.C. (not hit points) into M.D.C. for one minute (4 melee rounds), instantly, and the bonuses of several exercises are cumulative."
    bonuses: { attributes: { PS: 2, PE: 1 }, pools: { sdc: "4d4x10" } }
  - name: "Kangeiko & Shochu Geiko"
    description: "Body hardening: winter and summer training combined. Can endure severe weather unprotected for a full day (24 hours) without harm; invulnerable to stun and paralysis attacks; fire and cold based attacks, including magic and plasma, do half damage; impervious to the withering flesh atemi. +3D6 S.D.C., +1D6 hit points, +1 P.E. As with every body hardening exercise, 5 P.P.E. turns the character''s S.D.C. (not hit points) into M.D.C. for one minute (4 melee rounds), instantly, and the bonuses of several exercises are cumulative."
    bonuses: { attributes: { PE: 1 }, pools: { sdc: "3d6", hp: "1d6" } }
  - name: "Iron Hand (Kanshu)"
    description: "Body hardening, the Penetration Hand: toughened hands take no damage from striking or breaking hard objects and can handle burning coals, boiling oil, lava or fire without pain or harm; even magic fire and plasma do half damage to the hands. Normal punch 2D6 S.D.C., karate punch 4D6 S.D.C., knife hand or palm strike 1D6 M.D., power punch 2D6 M.D. (counts as two melee actions; double normal damage for a mega-damage creature that already inflicts M.D.). Punches can be pulled to do S.D.C. instead of mega-damage. +4 to damage on all hand strikes. As with every body hardening exercise, 5 P.P.E. turns the character''s S.D.C. (not hit points) into M.D.C. for one minute (4 melee rounds), instantly, and the bonuses of several exercises are cumulative."
  - name: "Dam Sum Sing"
    description: "Body hardening: full-power sparring for strength and resistance. All damage from punches, kicks, falls, impacts, explosions and even projectiles (arrows, bullets, rail gun rounds) is halved. +1 P.E., +20 S.D.C., +2 to roll with punch, fall or impact (a successful roll halves the damage again). As with every body hardening exercise, 5 P.P.E. turns the character''s S.D.C. (not hit points) into M.D.C. for one minute (4 melee rounds), instantly, and the bonuses of several exercises are cumulative."
    bonuses: { attributes: { PE: 1 }, pools: { sdc: 20 }, combat: { roll: 2 } }
  - name: "Wrist Hardening"
    description: "Body hardening: superhumanly strong wrists and joints. +5 to escape from all holds; can lock the joints so that a combined strength of double the character''s natural P.S. is needed to bend them or break his grip; can parry attacks, even mega-damage attacks, with the wrists (normal bonuses apply). +1D6 P.S., +4 to maintain balance. As with every body hardening exercise, 5 P.P.E. turns the character''s S.D.C. (not hit points) into M.D.C. for one minute (4 melee rounds), instantly, and the bonuses of several exercises are cumulative."
    bonuses: { attributes: { PS: "1d6" } }
  - name: "Kick Practice (Chagi)"
    description: "Body hardening: kicks at every height, the splits, and a jump kick straight overhead. Normal kick 4D6 S.D.C., karate and wheel kick 6D6 S.D.C., snap kick 2D6 S.D.C., jump kick 3D6 M.D., roundhouse kick 6D6 M.D., power kick 5D6 M.D. (counts as two melee actions; double normal damage for a mega-damage creature that already inflicts M.D.). Kicks can be pulled to do S.D.C. instead of mega-damage. Leaps 10 ft (3 m) high +2 ft (0.6 m) per level from a standing or crouched position; add 10 ft to lengthwise leaps with a running start. +1 to strike, +3D6 Spd. As with every body hardening exercise, 5 P.P.E. turns the character''s S.D.C. (not hit points) into M.D.C. for one minute (4 melee rounds), instantly, and the bonuses of several exercises are cumulative."
    bonuses: { attributes: { Spd: "3d6" }, combat: { strike: 1 } }
  - { choose: 1, at_levels: [14], from: ["Zenjoriki: Calm Minds", "Zenjoriki: Karumi-Jutsu", "Zenjoriki: Two Minds", "Zenjoriki: Vibrating Palm", "Zenjoriki: Vital Strike Atemi", "Zenjoriki: Withering Flesh Atemi"], note: "One zenjoriki power, selected at level 14 (printed 56; the powers are printed 197-199)." }
  - name: "Zenjoriki: Calm Minds"
    description: "10 P.P.E.; range 120 feet (36.5 m); lasts three minutes (12 melee rounds); takes one melee action (3 seconds) to perform. Everyone in range, friend and foe alike, who fails a save vs calm of 17 or better on a twenty-sided die (M.E. bonus applies) stops attacking at once and cannot resume offensive action until it ends, though they may defend, flee or do anything else. Any attack by the user dispels it instantly. It cannot be used on the same group again for another hour. It also dispels fear and any other hysterical emotion, whatever the cause."
  - name: "Zenjoriki: Karumi-Jutsu"
    description: "10 P.P.E.; self; lasts three minutes (12 melee rounds) per level; no save. The character changes his own body''s weight at will - not his clothing or possessions. It takes total concentration: no other attacks, defenses or actions while it is used, and it does not work in combat or when unconscious. Falling: lands on his feet unhurt from any distance. Jumping: up to 10 times his normal distance (at least 40 feet/12.2 m). Climbing: any surface, like an insect, with no fear of falling. Treading lightly: walks on a spider''s web, thread, a thin branch, an extremely fragile bridge, china teacups or leaves without breaking or disturbing them."
  - name: "Zenjoriki: Two Minds"
    description: "30 P.P.E.; self; lasts three minutes (12 melee rounds) per level; no save. The soul splits into the Hun (Cloud Soul) and the Po (Bone Soul), which act independently, even in two places at once; typically the Po fights with the body while the Hun works on tactics, calls commands or makes simultaneous psionic, magic or long-range attacks at -4 to strike. Hun: a wispy ghost with speech, analytical thought, mathematics, map reading, all thinking skills and the use of magic/P.P.E. and psionics/I.S.P.; mental attributes at full, physical at half; it cannot fight or use martial arts, recharge P.P.E. or I.S.P., or sense danger, art, taste or smell, and is barely able to walk. Po: keeps the body with all combat bonuses, physical skills, martial arts, weapon proficiencies and pilot skills, P.P.E. and I.S.P. regeneration, and taste, scent and esthetics; physical attributes at full, mental at half; it cannot speak, use thinking skills, magic or psionics, or control its emotions. Hit points and S.D.C. are split 50/50 between the two. Once split the roles cannot be swapped without rejoining and starting over."
  - name: "Zenjoriki: Vibrating Palm"
    description: "70 P.P.E.; range 120 feet (36.5 m); lasts up to 10 melee rounds (two and a half minutes); no save. Sympathetic vibrations shatter any material object: 1 point in the first melee round, doubling every round after (2, then 4, then 8 and so on) to the maximum of 512 points by the tenth round of an uninterrupted attack. S.D.C. damage to humans and S.D.C. structures, mega-damage to mega-damage beings and structures. More than 512 takes a second attack and another 70 P.P.E. It needs complete, undivided attention: no other attacks, actions or defenses, not even talking or looking elsewhere; being knocked out, blinded or tackled interrupts it. Stopped or interrupted, the vibrations end, no more damage is added, and starting again begins at 1 point."
  - name: "Zenjoriki: Vital Strike Atemi"
    description: "20 P.P.E.; a punch, kick or hand-held weapon strike (not thrown weapons or arrows); instant. The blow does its normal damage directly to hit points, bypassing physical S.D.C.; a victim at zero hit points or below falls into a coma whatever S.D.C. remains. Save: the victim halves the damage with a roll with punch/fall/impact that beats the attacker''s roll to strike. It cannot be used to inflict S.D.C. damage, does only normal damage to body armor and inanimate objects, and cannot pass through M.D.C. environmental body armor, power armor or vehicles (it works through non-environmental armor). Against mega-damage supernatural beings such as oni and dragons each strike does the blow''s damage x2 as M.D. (a 1D6 S.D.C. punch does 2D6 M.D., a 3D6 sword 6D6 M.D.). Characters with Stone Ox are immune; those with Chi-Gung mega-damage skin take half damage without rolling."
  - name: "Zenjoriki: Withering Flesh Atemi"
    description: "25 P.P.E. if the punch or kick strikes, 5 P.P.E. if it misses; instant. Instead of normal damage the strike knocks out up to 100 points of a living victim''s natural S.D.C., leaving him open to attacks on hit points. Save: the victim halves it with a roll with punch/fall/impact that beats the attacker''s roll to strike. It cannot inflict hit point damage, cannot damage body armor or inanimate objects, and cannot pass through M.D.C. environmental body armor, power armor or vehicles (it works through non-environmental armor). Against mega-damage supernatural beings such as oni, dragons and even gods each strike does 2D4x10 M.D. (only 1D4x10 against elementals), until half the creature''s M.D.C. is gone, after which it has no effect; that damage cannot be regenerated by any means for one full hour. Characters with Kangeiko & Shochu Geiko are immune; those with Chi-Gung mega-damage skin take half damage without rolling."
  - name: "Bishamon Meditation"
    description: "Base skill 20% +5% per level. The body stays motionless without fatigue or pain and the mind clear; while meditating the monk recovers I.S.P., P.P.E. and other inner resources at double the normal rate. Not a substitute for sleep, but refreshing. The monk stays subconsciously aware of his surroundings and can leave meditation instantly with no combat penalty. Meditation time: one hour at first level, plus 30 minutes per additional level."
level_progression:
  - { level: 2, grants: ["+1 to save vs horror factor"] }
  - { level: 3, grants: ["Psionics: Resist Hunger, Resist Thirst, Mind Block"] }
  - { level: 4, grants: ["+1 to save vs horror factor"] }
  - { level: 6, grants: ["Psionics: See the Invisible, Summon Inner Strength", "May be given one of the more powerful Millennium Tree staves for great courage or self-sacrifice"] }
  - { level: 8, grants: ["+1 to save vs horror factor"] }
  - { level: 9, grants: ["Psionics: Nightvision, Resist Fatigue"] }
  - { level: 10, grants: ["+1 to save vs horror factor"] }
  - { level: 12, grants: ["Psionics: Pyrokinesis"] }
  - { level: 13, grants: ["+1 to save vs horror factor"] }
  - { level: 15, grants: ["Psionics: Psi-Shield", "+1 to save vs horror factor"] }
restrictions:
  - "Human only; never D-Bees. Male only."
  - "Hand to Hand: Aikido only; no other combat alternatives are allowed."
  - "Cybernetics: none, not even for medical reasons."
trackable_resources: []
side_effects: "Money is 4D6x100 credits in gold or tradeable items, and the monk rarely has more: what he does not need for the fight against supernatural evil goes to the order or to the needy. Bishamon monasteries supply clothing, food, armor and weapons, and give shelter at any of them; common folk often offer a monk free room, sake and food. Starts with no magic weapons or items beyond the staff."
extraction_notes: "Rifts World Book 8: Japan printed 55-57 (cache p056-p058, text layer, page_offset +1). The entry opens mid-page on printed 55 under Bishamon Fighting Monk and ends at the foot of 57; printed 58 opens the Sohei Warrior Monk. XP ladder: p217 (cache; the printed page is folioed 216), first column, middle block, headed Bishamon, Fighting Monk / Sohei, Warrior Monk, read off a render. men_of_arms and occ_group: the book files this class under New Empire & Traditional O.C.C.s (printed 43), which names no grouping; it is a warrior order trained in aikido, so men-of-arms and the 3D6 core S.D.C. were chosen. The book prints no O.C.C. S.D.C.; chi-gung says the monk has at least 100 S.D.C. and adds +90, which is stored as a pool bonus; the 100 floor is prose. Psionics: the book calls the monk something between a major and master psychic; stored as major. The fixed psionic powers at levels 3, 6, 9, 12 and 15 are schedule entries whose list equals their count. Mystic martial arts powers (printed 56; descriptions printed 195-198): the class picks one art of invisibility at 3, a body hardening exercise at 4 and 10, and a zenjoriki power at 14; chi-gung itself is granted at level 1 and stored as an ability plus class bonuses. There is no level-1 pick. 2026-10-05, the picks (BOOK-INGEST-AUDIT.md F116): printed 56, ability 3, reads that one additional body hardening exercise/power can be selected at levels 4 and 10, one mystic art of invisibility at level three, and one zenjoriki power at level 14, and sends the reader to the mystic martial arts section (printed 195-199). Stored as three pick groups: the six arts of invisibility at level 3; the six body hardening exercises other than chi-gung at levels 4 and 10, read as one at each level (the word additional, and chi-gung being granted outright as ability 1, are why the seventh exercise is not offered); the six zenjoriki powers at level 14. The eighteen definitions are the section''s entries under the names the sohei, mystic ninja and kumo-mi use; a picked exercise carries its own unconditional bonuses, so nothing is added to the class bonuses for them. The class''s own Chi-Gung: Mega-Damage Skin entry keeps its name and its Healing line from printed 55, with its numbers still in the class bonuses and no bonuses line of its own. The record-by-hand lines for levels 3, 4, 10 and 14 were removed from the level progression. Skills: Literacy and Language: Japanese map to the native-language rows, as the catalog holds no Japanese rows. Begging and Fasting are stored at the book''s own 10%+3% and 33%+3%, as the sohei and yamabushi store theirs. Bishamon Meditation has no catalog row and is an ability. Medical: Mystic Herbology (+10%) only; the catalog holds no Mystic Herbology row, so Medical is left out of the related categories rather than written as an only that matches nothing. Weapon Proficiencies: ancient only, enumerated. Technical: except computers is read as Computer Operation and Computer Programming. Equipment: the staff is the Sohei Staff of Defense (printed 35, the same as the sohei monk''s); the herbs have no catalog row and are in the medical bag''s note. Mega-damage leaf or bark armor, the daito and the bisento are described as characteristic, not as standard equipment, and are not given."
---

## Lore

When the gods, demons and dragons returned to Japan, a host of religious orders rose with them, and among the most popular are the bishamon fighting monks. Ancient belief held that four Guardian deities protected the world from demons; only Bishamon is still remembered, and his order was founded to help him drive the supernatural invaders out of Japan.

Like wandering priests and demon quellers, the monks roam the countryside healing the sick and battling monstrous beings from other dimensions. Bishamon and the other gods taught them disciplines of healing, curing disease, exorcism and banishing demons, and they are tenacious warriors trained in aikido. Their mission is to cleanse Japan of the demon hordes and dark magic.

Away from battle most monks are gentle, jovial and caring: they help on farms, rebuild homes and temples, tend the sick and lift spirits with stories, songs and feats of prowess. Some, hardened by the atrocities they have seen, have grown cold toward human suffering and live only to destroy demons, willing to sacrifice a few innocents as casualties of war.

The monks shave their heads except for a long strip worn in a pony tail, and wear no facial hair. They often go bareheaded or wear a dish-shaped hat, and wear mega-damage leaf or bark armor from the sacred tree over or under a brown robe. The great two-handed daito sword and the bisento spear are their trademarks.

Standard equipment: several changes of travel clothes and boots, a backpack, belt, sleeping roll, one large and 1D6 small sacks, specimen jars, 50 ft of rope, cooking utensils, 3D4 days of rations and a water skin; a knife, a Millennium Tree staff, an ancient weapon of choice, a mallet and six wooden stakes; and a satchel of medical supplies with 1D6x5 non-magical herbs. Monks of 6th level or higher who show great courage or self-sacrifice may be given one of the more powerful Millennium Tree staves.

## Mystic Martial Arts Powers

Picked by the player at the levels below, from the pick groups in the class abilities, which hold the full entries. Descriptions paraphrased from the book''s mystic martial arts section (printed 195-198).

**Level 3: one mystic art of invisibility.**

- Stealth: moves silently and unseen; automatic in the dark when unsuspected, 43% +3% per level under inspection. Includes moving silently into, out of and through water (50% +3% per level; deep water needs Swimming).
- Hiding: becomes one with surrounding objects while motionless, for hours or days; 60% +3% per level only when the area is well lit and carefully searched.
- Evasion: stays behind a victim out of sight; automatic when unsuspected, otherwise 50% +3% per level. Allows continuous attacks from behind while unseen.
- Vanishing: a sleight-of-hand disappearance, even mid-combat, for one melee action; 85% +1% per level in darkness, with penalties for light and open or cornered ground.
- Disguise: radically changes posture, walk and expression to blend into a crowd; 50% +3% per level, -40% if stopped and questioned.
- Mystic Invisibility: clouds observers'' minds to vanish in plain sight, 1 P.P.E. per melee round (4 for 2-8 people, 12 for more). Also hides the monk''s P.P.E. from detection and fools sensors; victims save on 19 or higher. The monk must become visible to fight or use other skills.

**Levels 4 and 10: one more body hardening exercise each.** Each can also turn the monk''s S.D.C. (not hit points) into M.D.C. for one minute for 5 P.P.E. Chi-Gung is already known.

- Stone Ox: +2 P.S., +1 P.E., +4D4x10 S.D.C.; fatigues at half rate and lifts and carries 50 times normal.
- Kangeiko & Shochu Geiko: +3D6 S.D.C., +1D6 hit points, +1 P.E.; a full day unprotected in extreme weather without harm, immune to stun and paralysis, half damage from fire and cold (including magic and plasma), immune to withering flesh.
- Iron Hand: hand strikes take no damage and do more (knife hand or palm strike 1D6 M.D., power punch 2D6 M.D.), hands resist fire; +4 damage on hand strikes.
- Dam Sum Sing: half damage from punches, kicks, falls, impacts, explosions and projectiles; +1 P.E., +20 S.D.C., +2 roll with impact.
- Wrist Hardening: +5 to escape holds, joints lock at double P.S., can parry even mega-damage attacks with the wrists; +1D6 P.S., +4 maintain balance.
- Kick Practice: mega-damage kicks (jump kick 3D6 M.D., roundhouse 6D6 M.D.) and great standing leaps; +1 strike, +3D6 Spd.

**Level 14: one zenjoriki power.**

- Calm Minds: 10 P.P.E.; everyone within 120 ft stops attacking for three minutes unless they save on 17 or higher; broken if the monk attacks.
- Karumi-Jutsu: 10 P.P.E.; controls his own weight for three minutes per level: safe falls, tenfold jumps, climbing like an insect, treading on fragile surfaces. Not in combat.
- Two Minds: 30 P.P.E.; splits the soul into the thinking Hun and the fighting Po, which act independently for three minutes per level.
- Vibrating Palm: 70 P.P.E.; sympathetic vibrations double their damage each melee round, up to 512 points over ten uninterrupted rounds.
- Vital Strike Atemi: 20 P.P.E.; a strike''s damage goes straight to hit points, or double as M.D. against supernatural beings.
- Withering Flesh Atemi: 25 P.P.E. (5 on a miss); a strike strips up to 100 S.D.C., or 2D4x10 M.D. from a supernatural being, up to half its M.D.C.

## GM Notes

Chi-gung''s minimum of 100 S.D.C. is not enforced by the sheet; check it at creation. The mystic martial arts picks above are offered by the sheet when the monk reaches levels 3, 4, 10 and 14.
',
       updated_at = datetime('now')
 WHERE class_id = 'bishamon-fighting-monk'
   AND instr(markdown, 'These are picked by the player and recorded by hand') > 0
   AND length(markdown) = 19197;

-- == sohei-warrior-monk ==
UPDATE imported_classes
   SET markdown = '---
id: sohei-warrior-monk
occ_group: men-of-arms
men_of_arms: true
name: Sohei Warrior Monk
system: rifts
source_book: Rifts World Book 8: Japan p.58-60
category: occ
tags: [combat, divine]
xp_table: [0, 2201, 4401, 8801, 17601, 24001, 35001, 50501, 72501, 98501, 140501, 200501, 250501, 325501, 400501]
attribute_requirements: { PP: 11, PE: 11 }
ppe_base: "P.E. x3 + 1d6 per level"
starting_money: "3d4x10"
bonuses:
  saves: { possession: 3 }
  at_level:
    - { level: 2, saves: { horror_factor: 1 } }
    - { level: 4, saves: { horror_factor: 1 } }
    - { level: 7, saves: { horror_factor: 1 } }
    - { level: 9, saves: { horror_factor: 1 } }
    - { level: 11, saves: { horror_factor: 1 } }
    - { level: 13, saves: { horror_factor: 1 } }
    - { level: 15, saves: { horror_factor: 1 } }
skills:
  hand_to_hand: { costs: { teng_jutsu: 3 } }
  occ_skills:
    - { name: "Climbing", base: 45, per_level: 5, note: "+5%" }
    - { name: "Calligraphy", base: 45, per_level: 5, note: "+10%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { name: "Japanese Mythology", base: 45, per_level: 5, note: "+15%" }
    - { name: "Literacy: Native Language", base: 98, per_level: 0, note: "The book prints Literacy: Japanese at 98%; the catalog has no Japanese literacy row." }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "The book prints Language: Japanese at 98%; the catalog has no Japanese language row." }
    - { choose: 2, from: ["Language: Other"], bonus: 15, note: "Two languages of choice (+15% each)." }
    - { name: "Mathematics: Basic", base: 55, per_level: 5, note: "+10% for a nun; the monk variant restates it at +20%." }
    - { name: "W.P. Staff", base: 0, per_level: 0, note: "In addition to the jodo abilities and bonuses." }
    - { name: "Hand to Hand: Jujitsu", base: 0, per_level: 0, note: "Can be changed to Teng-jutsu at the cost of three other skill selections; no other combat alternative is allowed." }
    - { name: "Begging", base: 20, per_level: 3, note: "Temple skill; the book prints 20% +3% per level for the sohei." }
    - { name: "Fasting", base: 40, per_level: 3, note: "Temple skill." }
    - { choose: 1, from: ["Lore: Demons & Monsters", "Lore: Magic", "Poetry (Haiku)", "Go", "Gardening"], bonus: 15, note: "Oriental Philosophies: one of demon and monster lore, magic lore, haiku poetry, go or (Zen) gardening, +15%." }
  occ_related_skills:
    count: 5
    categories:
      - { name: "Domestic", bonus: 10 }
      - { name: "Medical", only: ["First Aid", "Holistic Medicine"] }
      - { name: "Physical", except: ["Acrobatics", "Boxing"] }
      - { name: "Rogue", only: ["Streetwise", "Concealment"] }
      - { name: "Science", bonus: 5 }
      - "Technical"
      - { name: "Weapon Proficiencies", only: ["W.P. Blunt", "W.P. Knife", "W.P. Forked"] }
      - { name: "Wilderness", bonus: 5 }
    note: "Communications, Electrical, Espionage, Mechanical, Military, Pilot and Pilot Related: none (not even horsemanship; monks walk or ride in a cart). Rogue: Streetwise (+8%) and Concealment (+6%) only. Technical: any, +10% to language skills only."
    schedule:
      - { level: 2, count: 1 }
      - { level: 5, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 3
    categories:
      - "Domestic"
      - { name: "Medical", only: ["First Aid", "Holistic Medicine"] }
      - { name: "Physical", except: ["Acrobatics", "Boxing"] }
      - { name: "Rogue", only: ["Streetwise", "Concealment"] }
      - "Science"
      - "Technical"
      - { name: "Weapon Proficiencies", only: ["W.P. Blunt", "W.P. Knife", "W.P. Forked"] }
      - "Wilderness"
    schedule:
      - { level: 4, count: 2 }
      - { level: 8, count: 2 }
      - { level: 12, count: 2 }
variants:
  - id: monk
    name: "Sohei Warrior Monk"
    skills_additional:
      occ_skills:
        - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
        - { name: "Lore: Magic", base: 35, per_level: 5, note: "+10%; the book prints Magic Lore." }
        - { name: "W.P. Spear", base: 0, per_level: 0 }
    skill_overrides:
      - { name: "Mathematics: Basic", base: 65, per_level: 5 }
  - id: nun
    name: "Female Sohei (Warrior Nun)"
    skills_additional:
      occ_skills:
        - { name: "Cook", base: 45, per_level: 5, note: "+10%" }
        - { name: "Sewing", base: 50, per_level: 5, note: "+10%; the book prints Sew." }
        - { name: "Sing", base: 45, per_level: 5, note: "+10%" }
        - { name: "Holistic Medicine", base: 30, per_level: 5, note: "+10%" }
equipment_starting:
  - { item_id: "millennium-leaf-body-armor", qty: 1, note: "Millennium Tree leaf armor, 60 M.D.C., worn under the robes; not an environmental suit." }
  - { item_id: "sohei-staff-of-defense", qty: 1, note: "Most sohei (90%) are given this Millennium Tree staff; other magic staves or spears may be used instead." }
  - { item_id: "naginata-yari-rifts", qty: 1, note: "The book prints naginata spear." }
  - { item_id: "knife", qty: 1 }
  - { item_id: "robe", qty: 4, note: "A pair of white robes and a pair of light brown robes." }
  - { item_id: "sandals", qty: 1, note: "Sandals or tabi." }
  - { item_id: "rope", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "small-sack", qty: 3 }
  - { item_id: "water-skin-1-gallon", qty: 1, note: "The book prints a large water skin." }
  - { item_id: "food-rations", qty: 1, note: "The book prints 4D4 days of rations." }
special_abilities:
  - name: "Jodo, the Way of the Staff"
    description: "A staff (and spear) martial art first developed against sword-bearing samurai; the monks have also earned the right to carry spears and polearms. Jodo Strike: a deliberate thrust to the side of the head with the staff point or spear butt, announced before the roll. On a strike roll of 18 or higher (bonuses included) it does an extra 1D6 damage, the victim loses initiative and one melee action, and has a 01-50% chance to drop one held weapon (victim''s choice if paired). A hit under 18 does normal damage only. Jodo bonuses: one extra attack per melee round when using a staff or spear of any kind, and +1 to parry in addition to jujitsu and attribute bonuses."
  - name: "Parry Arrows with Staff or Spear"
    description: "Can parry arrows, darts and thrown objects at -2 and gunfire at -6, against one opponent''s projectiles at a time. The penalty improves by +2 at level three and by +1 at levels 4, 6, 9, 12 and 15."
  - name: "Chi M.D. Death Blow"
    description: "Same as the samurai''s: against supernatural beings and creatures of magic only, a punch, kick, staff or spear strike does double normal damage plus P.S. bonus as mega-damage, and the victim cannot bio-regenerate that injury for 1D4 hours. Counts as two melee actions; must be used with a pure spirit, never in anger, fear or revenge; useless against machines, ordinary humans, guns and bows. Draws on the character''s P.P.E. and counts as a magical attack."
  - name: "Mystic Martial Arts Powers"
    description: "One body hardening exercise at each of levels 1, 5 and 9, and one zenjoriki power at level 14 (printed 59), chosen from the groups below when the level is reached. Each body hardening exercise also lets the character spend 5 P.P.E. (unless stated otherwise) to turn his S.D.C., not hit points, into M.D.C. for one minute (4 melee rounds); bonuses from several exercises are cumulative."
  - { choose: 1, at_levels: [1, 5, 9], from: ["Stone Ox", "Kangeiko & Shochu Geiko", "Iron Hand (Kanshu)", "Chi-Gung Mega-Damage Skin", "Dam Sum Sing", "Wrist Hardening", "Kick Practice (Chagi)"], note: "One body hardening exercise at level 1, another at level 5 and another at level 9 (printed 59; the exercises are printed 196-197)." }
  - name: "Stone Ox"
    description: "Body hardening: the ultimate endurance training. Fatigues at half the normal rate and can lift and carry 50 times the normal weight capacity. +2 P.S., +1 P.E., +4D4x10 S.D.C., on top of any O.C.C. and skill bonuses. Immune to the vital strike atemi. As with every body hardening exercise, 5 P.P.E. turns the character''s S.D.C. (not hit points) into M.D.C. for one minute (4 melee rounds), instantly, and the bonuses of several exercises are cumulative."
    bonuses: { attributes: { PS: 2, PE: 1 }, pools: { sdc: "4d4x10" } }
  - name: "Kangeiko & Shochu Geiko"
    description: "Body hardening: winter and summer training combined. Can endure severe weather unprotected for a full day (24 hours) without harm; invulnerable to stun and paralysis attacks; fire and cold based attacks, including magic and plasma, do half damage; impervious to the withering flesh atemi. +3D6 S.D.C., +1D6 hit points, +1 P.E. As with every body hardening exercise, 5 P.P.E. turns the character''s S.D.C. (not hit points) into M.D.C. for one minute (4 melee rounds), instantly, and the bonuses of several exercises are cumulative."
    bonuses: { attributes: { PE: 1 }, pools: { sdc: "3d6", hp: "1d6" } }
  - name: "Iron Hand (Kanshu)"
    description: "Body hardening, the Penetration Hand: toughened hands take no damage from striking or breaking hard objects and can handle burning coals, boiling oil, lava or fire without pain or harm; even magic fire and plasma do half damage to the hands. Normal punch 2D6 S.D.C., karate punch 4D6 S.D.C., knife hand or palm strike 1D6 M.D., power punch 2D6 M.D. (counts as two melee actions; double normal damage for a mega-damage creature that already inflicts M.D.). Punches can be pulled to do S.D.C. instead of mega-damage. +4 to damage on all hand strikes. As with every body hardening exercise, 5 P.P.E. turns the character''s S.D.C. (not hit points) into M.D.C. for one minute (4 melee rounds), instantly, and the bonuses of several exercises are cumulative."
  - name: "Chi-Gung Mega-Damage Skin"
    description: "Body hardening: skin that blades cannot cut and arrows cannot pierce, with a natural A.R. of 18 and at least 100 S.D.C. Whenever chi-gung focus is used the S.D.C. AND hit points of that skin become mega-damage, at 1 P.P.E. per two minutes (8 melee rounds) - this replaces the usual 5 P.P.E. for one minute of the other exercises. +1 P.E., +2D6 hit points, +90 S.D.C., on top of any O.C.C. and skill bonuses. Takes half damage from the vital strike and withering flesh atemi without rolling. Bonuses are cumulative with other exercises."
    bonuses: { attributes: { PE: 1 }, pools: { sdc: 90, hp: "2d6" } }
  - name: "Dam Sum Sing"
    description: "Body hardening: full-power sparring for strength and resistance. All damage from punches, kicks, falls, impacts, explosions and even projectiles (arrows, bullets, rail gun rounds) is halved. +1 P.E., +20 S.D.C., +2 to roll with punch, fall or impact (a successful roll halves the damage again). As with every body hardening exercise, 5 P.P.E. turns the character''s S.D.C. (not hit points) into M.D.C. for one minute (4 melee rounds), instantly, and the bonuses of several exercises are cumulative."
    bonuses: { attributes: { PE: 1 }, pools: { sdc: 20 }, combat: { roll: 2 } }
  - name: "Wrist Hardening"
    description: "Body hardening: superhumanly strong wrists and joints. +5 to escape from all holds; can lock the joints so that a combined strength of double the character''s natural P.S. is needed to bend them or break his grip; can parry attacks, even mega-damage attacks, with the wrists (normal bonuses apply). +1D6 P.S., +4 to maintain balance. As with every body hardening exercise, 5 P.P.E. turns the character''s S.D.C. (not hit points) into M.D.C. for one minute (4 melee rounds), instantly, and the bonuses of several exercises are cumulative."
    bonuses: { attributes: { PS: "1d6" } }
  - name: "Kick Practice (Chagi)"
    description: "Body hardening: kicks at every height, the splits, and a jump kick straight overhead. Normal kick 4D6 S.D.C., karate and wheel kick 6D6 S.D.C., snap kick 2D6 S.D.C., jump kick 3D6 M.D., roundhouse kick 6D6 M.D., power kick 5D6 M.D. (counts as two melee actions; double normal damage for a mega-damage creature that already inflicts M.D.). Kicks can be pulled to do S.D.C. instead of mega-damage. Leaps 10 ft (3 m) high +2 ft (0.6 m) per level from a standing or crouched position; add 10 ft to lengthwise leaps with a running start. +1 to strike, +3D6 Spd. As with every body hardening exercise, 5 P.P.E. turns the character''s S.D.C. (not hit points) into M.D.C. for one minute (4 melee rounds), instantly, and the bonuses of several exercises are cumulative."
    bonuses: { attributes: { Spd: "3d6" }, combat: { strike: 1 } }
  - { choose: 1, at_levels: [14], from: ["Zenjoriki: Calm Minds", "Zenjoriki: Karumi-Jutsu", "Zenjoriki: Two Minds", "Zenjoriki: Vibrating Palm", "Zenjoriki: Vital Strike Atemi", "Zenjoriki: Withering Flesh Atemi"], note: "One zenjoriki power, selected at level 14 (printed 59; the powers are printed 197-199)." }
  - name: "Zenjoriki: Calm Minds"
    description: "10 P.P.E.; range 120 feet (36.5 m); lasts three minutes (12 melee rounds); takes one melee action (3 seconds) to perform. Everyone in range, friend and foe alike, who fails a save vs calm of 17 or better on a twenty-sided die (M.E. bonus applies) stops attacking at once and cannot resume offensive action until it ends, though they may defend, flee or do anything else. Any attack by the user dispels it instantly. It cannot be used on the same group again for another hour. It also dispels fear and any other hysterical emotion, whatever the cause."
  - name: "Zenjoriki: Karumi-Jutsu"
    description: "10 P.P.E.; self; lasts three minutes (12 melee rounds) per level; no save. The character changes his own body''s weight at will - not his clothing or possessions. It takes total concentration: no other attacks, defenses or actions while it is used, and it does not work in combat or when unconscious. Falling: lands on his feet unhurt from any distance. Jumping: up to 10 times his normal distance (at least 40 feet/12.2 m). Climbing: any surface, like an insect, with no fear of falling. Treading lightly: walks on a spider''s web, thread, a thin branch, an extremely fragile bridge, china teacups or leaves without breaking or disturbing them."
  - name: "Zenjoriki: Two Minds"
    description: "30 P.P.E.; self; lasts three minutes (12 melee rounds) per level; no save. The soul splits into the Hun (Cloud Soul) and the Po (Bone Soul), which act independently, even in two places at once; typically the Po fights with the body while the Hun works on tactics, calls commands or makes simultaneous psionic, magic or long-range attacks at -4 to strike. Hun: a wispy ghost with speech, analytical thought, mathematics, map reading, all thinking skills and the use of magic/P.P.E. and psionics/I.S.P.; mental attributes at full, physical at half; it cannot fight or use martial arts, recharge P.P.E. or I.S.P., or sense danger, art, taste or smell, and is barely able to walk. Po: keeps the body with all combat bonuses, physical skills, martial arts, weapon proficiencies and pilot skills, P.P.E. and I.S.P. regeneration, and taste, scent and esthetics; physical attributes at full, mental at half; it cannot speak, use thinking skills, magic or psionics, or control its emotions. Hit points and S.D.C. are split 50/50 between the two. Once split the roles cannot be swapped without rejoining and starting over."
  - name: "Zenjoriki: Vibrating Palm"
    description: "70 P.P.E.; range 120 feet (36.5 m); lasts up to 10 melee rounds (two and a half minutes); no save. Sympathetic vibrations shatter any material object: 1 point in the first melee round, doubling every round after (2, then 4, then 8 and so on) to the maximum of 512 points by the tenth round of an uninterrupted attack. S.D.C. damage to humans and S.D.C. structures, mega-damage to mega-damage beings and structures. More than 512 takes a second attack and another 70 P.P.E. It needs complete, undivided attention: no other attacks, actions or defenses, not even talking or looking elsewhere; being knocked out, blinded or tackled interrupts it. Stopped or interrupted, the vibrations end, no more damage is added, and starting again begins at 1 point."
  - name: "Zenjoriki: Vital Strike Atemi"
    description: "20 P.P.E.; a punch, kick or hand-held weapon strike (not thrown weapons or arrows); instant. The blow does its normal damage directly to hit points, bypassing physical S.D.C.; a victim at zero hit points or below falls into a coma whatever S.D.C. remains. Save: the victim halves the damage with a roll with punch/fall/impact that beats the attacker''s roll to strike. It cannot be used to inflict S.D.C. damage, does only normal damage to body armor and inanimate objects, and cannot pass through M.D.C. environmental body armor, power armor or vehicles (it works through non-environmental armor). Against mega-damage supernatural beings such as oni and dragons each strike does the blow''s damage x2 as M.D. (a 1D6 S.D.C. punch does 2D6 M.D., a 3D6 sword 6D6 M.D.). Characters with Stone Ox are immune; those with Chi-Gung mega-damage skin take half damage without rolling."
  - name: "Zenjoriki: Withering Flesh Atemi"
    description: "25 P.P.E. if the punch or kick strikes, 5 P.P.E. if it misses; instant. Instead of normal damage the strike knocks out up to 100 points of a living victim''s natural S.D.C., leaving him open to attacks on hit points. Save: the victim halves it with a roll with punch/fall/impact that beats the attacker''s roll to strike. It cannot inflict hit point damage, cannot damage body armor or inanimate objects, and cannot pass through M.D.C. environmental body armor, power armor or vehicles (it works through non-environmental armor). Against mega-damage supernatural beings such as oni, dragons and even gods each strike does 2D4x10 M.D. (only 1D4x10 against elementals), until half the creature''s M.D.C. is gone, after which it has no effect; that damage cannot be regenerated by any means for one full hour. Characters with Kangeiko & Shochu Geiko are immune; those with Chi-Gung mega-damage skin take half damage without rolling."
  - name: "Feng Shui or Geomancy"
    description: "Temple skill, 15% +5% per level. Evaluates the P.P.E. of an area: whether good or evil forces control it, whether its flow is natural or being tapped (wizards, rituals, Rifts), the direction of a nexus on that line, its strength, an approaching ley line storm, and whether the line connects to an open Rift, including one to a world ruled by demons or other evil supernatural forces."
  - name: "Sohei Meditation"
    description: "Temple skill, 20% +6% per level. The body rests motionless without fatigue or pain while the mind stays clear; I.S.P., P.P.E. and other inner resources recover three times as fast. Not a substitute for sleep. The meditator stays aware of the surroundings and can leave the meditation instantly with no combat penalty. Can meditate one hour at first level, plus one hour per level of experience."
restrictions:
  - "Cybernetics: none. A true Shinto monk never takes cybernetics; only 3% will even consider bio-systems."
  - "Hand to hand: Jujitsu, or Teng-jutsu at the cost of three other skills; no other combat alternatives."
  - "Pilot: none, not even horsemanship."
side_effects: "At 6th level the monastery presents a suit of Millennium Tree bark armor (120 M.D.C., millennium-bark-body-armor). Higher level monks (6th or higher) who show great courage or self-sacrifice may be given one of the more powerful Millennium Tree staves. Two towels to wrap the head are part of the kit and have no catalog row."
extraction_notes: "Rifts World Book 8: Japan printed 58-60 (cache p059-p061, text layer, page_offset +1). The entry opens under Sohei / Warrior Monk O.C.C. on printed 58 and the female sohei note ends mid-column on printed 60, where Yamabushi begins. Printed 59 and the top of 60 were rendered to read the digit cipher: parry arrows +1 at levels 4, 6, 9, 12 and 15; horror factor at 2, 4, 7, 9, 11, 13 and 15; money 3D4x10 (the book prints 3D4xlO even on the render). || XP: the Bishamon, Fighting Monk / Sohei, Warrior Monk column on the Experience Point Tables page (cache p217, printed folio 216), read off a render: 0 / 2,201 / 4,401 / 8,801 / 17,601 / 24,001 / 35,001 / 50,501 / 72,501 / 98,501 / 140,501 / 200,501 / 250,501 / 325,501 / 400,501. || GROUP: men-of-arms, men_of_arms: true. The book files it under no Men of Arms heading (the section is the New Empire''s traditional O.C.C.s); the sohei is a martial artist first, as the samurai. No S.D.C. or hit point formula is printed. || VARIANTS: printed 60 says women join as nuns with the same martial arts and a different O.C.C. skill list. A variant cannot remove a parent skill, so the parent holds the skills both lists share and each variant adds its own: the monk adds Land Navigation, Magic Lore and W.P. Spear and restates Mathematics: Basic at +20%; the nun adds Cook, Sew (Sewing), Sing and Holistic Medicine, and keeps Mathematics: Basic at +10%. Related and secondary skills, abilities and equipment are shared, as the book says. || SKILLS: Japanese at 98% is stored as Language: Native Tongue and Literacy: Native Language at 98 (no Japanese rows in the catalog). Begging is printed at 20% +3% for this class; the catalog row holds 30% +3%, and the class states the printed figure. Fasting 40% +3% matches the catalog. Oriental Philosophies is one choice of five at +15%. Feng Shui or Geomancy (15% +5%) has a catalog row now (Lore: Feng Shui/Geomancy, base 15, +5); the class does not grant it and still stores a special ability with the percentage in prose. Sohei Meditation (20% +6%) has no catalog row and is a special ability with its percentage in prose. || RELATED: five, plus one at levels 2, 5, 9 and 12. Technical is any, but its +10% applies to language skills only, so no category bonus is stored and the note says so. Rogue: Streetwise (+8%) and Concealment (+6%) only; the per-skill bonuses are in the note, not stored. Secondary: three, plus two at levels 4, 8 and 12, same limits without bonuses. || MYSTIC MARTIAL ARTS: one body hardening exercise at levels 1, 5 and 9 plus one zenjoriki power at level 14 (printed 59; powers printed 195-199). 2026-10-05, the picks (BOOK-INGEST-AUDIT.md F116): printed 59, ability 3, reads that one body hardening exercise/power can be selected at levels 1, 5 and 9, plus one zenjoriki power at level 14, and sends the reader to the mystic martial arts section (printed 195-199); it gives the class no art of invisibility. Stored as two pick groups: the seven body hardening exercises at levels 1, 5 and 9, and the six zenjoriki powers at level 14. The seven exercise definitions were replaced by the section''s fuller entries under the same names and with the same unconditional bonuses as before, and the six zenjoriki definitions were added; a picked exercise carries its own bonuses. The three level progression lines the groups replace were removed, which leaves the class with no level progression list. || BONUSES: +3 save vs possession; +1 save vs horror factor at levels 2, 4, 7, 9, 11, 13 and 15. The jodo extra attack and +1 parry (tied to staff or spear use) and the parry-arrows penalties are prose. Jujitsu''s own bonuses come from its skill row. Iron Hand''s +4 damage applies to hand strikes only and is prose. || MONEY: 3D4x10 credits'' worth of gold or tradeable goods. || EQUIPMENT: leaf armor, the Staff of Defense (90% of sohei), naginata as naginata-yari-rifts, knife, four robes, sandals or tabi as sandals, rope, backpack, three small sacks, a large water skin as water-skin-1-gallon, 4D4 days of rations as one food-rations. Towels are prose (no catalog row). The 6th-level bark armor is prose."
---

## Lore

The sohei are the traditional Shinto warrior monks of Japan. Many wander alone or in pairs, helping villagers with their children and harvests, advising elders and officials, preparing festivals, tending the sick, bargaining with landlords on the farmers'' behalf, carrying news and stories, and driving off or slaying oni and bandits. Some counsel or assist samurai and daimyo, or teach language, calligraphy, dance and poetry to nobles.

In wartime whole armies of sohei defend temples, villages and shogunates against rival factions, oni and invaders, and attacking a sohei temple is known to be folly: the monks can disarm and beat seasoned samurai with their tall wooden staves and naginata. A typical temple holds 2D4 jodo masters (1D4+9th level), 4D6 experienced monks (1D4+5th level), 6D6 young monks (1D4+1 level), 1D4x10 first-level monks and 1D6x10 novices still in training; large temples have three times as many and small ones half. There are at least 80 sohei temples in the New Empire and perhaps 400 across the islands. Two large sohei monasteries and a bishamon monastery stand within half a mile of the Millennium Tree at Kyoto, and the monks and Shinto priests share the tree''s gifts to arm their orders. The sohei and bishamon orders are friendly rivals, each vying for the people''s favor.

A sohei shaves his head and face as a sign of humility, covers his head with a knotted towel (often cut from a Millennium Tree leaf) when travelling or fighting, and wears Millennium Tree leaf or bark armor under a white robe, often with a darker brown or tan robe over it. The tall staff and the naginata are the order''s trademarks. Any alignment is possible; typically 20% principled, 25% scrupulous, 15% anarchist, 15% aberrant and 25% other. Any "willing spirit" may join, so some temples are associated with dragons or with the tengu and other minions of Shinto gods. A high P.S., M.E. and M.A. help but are not required.

Sohei acquire little wealth. Monasteries supply their basic needs, and a travelling monk can find shelter, food, water, a new robe and a place to sleep at any sohei monastery, or usually with farmers and villagers, in return for a small donation or some help with chores. A community the monk has defended usually offers a little money and free food and lodging. Some monks have a weakness for drink and books, but most live modestly and give much of what they earn to the poor and their order.

## Warrior Nuns

Women join sohei monasteries as nuns and learn the same martial arts, including jodo; only their O.C.C. skills differ (the nun variant). Most nuns defend their monastery, temples and shrines, the Millennium Trees and their community, and fight oni and evil spirits when needed, but seldom travel, spending their days as cooks, seamstresses, craftswomen, healers, teachers and advisors. A few are born with the urge to travel, fight and adventure; they are uncommon but do exist.

## Mystic Martial Arts Powers

The sohei chooses one body hardening exercise at level 1, and chooses another at level 5 and another at level 9, from the seven exercises listed with the class abilities: Stone Ox, Kangeiko & Shochu Geiko, Iron Hand (Kanshu), Chi-Gung Mega-Damage Skin, Dam Sum Sing, Wrist Hardening and Kick Practice (Chagi). The bonuses of several exercises are cumulative. The sheet offers each pick when its level is reached.

At level 14 the sohei learns one zenjoriki power, a spirit power fuelled by P.P.E., picked from the six listed with the class abilities and summarised here (printed 197-199):

- Calm Minds (10 P.P.E., 120 ft, three minutes): everyone in range, friend or foe, who fails a save of 17 (M.E. bonus applies) stops attacking, though they may defend or flee; any attack by the user ends it, and it cannot be used on the same group again for an hour. It also dispels fear and hysteria.
- Karumi-Jutsu (10 P.P.E., self, three minutes per level): the character controls his body''s weight while concentrating, to fall any distance unhurt, jump ten times his normal distance, climb any surface like an insect, and tread on the most delicate surfaces without harm. It does not work in combat.
- Two Minds (30 P.P.E., self, three minutes per level): the soul splits into the analytical Hun, a ghostly form with the mental skills and magic or psionics, and the instinctive Po, which keeps the body and fights with every physical skill but cannot speak or think tactically. Hit points and S.D.C. are split between them, and the roles cannot be swapped until they rejoin.
- Vibrating Palm (70 P.P.E., 120 ft, up to 10 melee rounds): sympathetic vibrations shatter an object or being, 1 point in the first round and doubling each round to a maximum of 512 by the tenth; S.D.C. against S.D.C. targets and M.D. against mega-damage ones. It takes the user''s complete attention, and any interruption resets it.
- Vital Strike Atemi (20 P.P.E.): a punch, kick or hand-weapon strike does its normal damage directly to hit points, and a victim reduced to zero falls into a coma whatever S.D.C. remains; a roll with impact that beats the strike halves it. Against mega-damage supernatural beings it does the blow''s damage x2 as M.D. It cannot pass environmental armor, and Stone Ox makes a target immune.
- Withering Flesh Atemi (25 P.P.E. on a hit, 5 on a miss; punch or kick): instead of normal damage the strike strips up to 100 of the victim''s natural S.D.C., leaving hit points exposed; a roll with impact that beats the strike halves it. Against mega-damage supernatural beings it does 2D4x10 M.D. (1D4x10 against elementals), up to half the creature''s M.D.C., and that damage cannot regenerate for an hour. Kangeiko & Shochu Geiko makes a target immune, and Chi-Gung skin halves it.
',
       updated_at = datetime('now')
 WHERE class_id = 'sohei-warrior-monk'
   AND instr(markdown, 'Add the level 5 and level 9 picks to the character by hand; the sheet does not grant them.') > 0
   AND length(markdown) = 21451;

-- == dragon-hatchling-kumo-mi ==
UPDATE imported_classes
   SET markdown = '---
id: dragon-hatchling-kumo-mi
name: Dragon Hatchling (Kumo-Mi)
system: rifts
source_book: Rifts World Book 8: Japan p.212-214
category: rcc
tags: [supernatural, high-power, flyer, stealth]
xp_table: [0, 3001, 5001, 10001, 20001, 30001, 50001, 80001, 120001, 170001, 230001, 300001, 380001, 470001, 600001]
attribute_dice:
  IQ: "3d6+10"
  ME: "3d6+10"
  MA: "2d6+15"
  PS: "2d6+28"
  PP: "3d6+8"
  PE: "3d6+12"
  PB: "3d6+10"
  Spd: "3d6+88"
mdc_base: "1D4x100+50"
ppe_base: "1D4x100"
horror_factor: 15
magic:
  type: "spell"
  spells_starting: 0
psionics:
  type: "major"
  isp_base: "3D4x10"
  powers: ["Bio-Regeneration", "Deaden Pain", "Detect Psionics", "Exorcism", "Healing Touch", "Increased Healing", "Induce Sleep", "Lust for Life", "Psychic Diagnosis", "Psychic Purification", "Psychic Surgery", "Resist Fatigue", "Restore P.P.E.", "Stop Bleeding", "Suppress Fear", "Telepathy", "Empathy", "Mind Block"]
  powers_starting: 0
bonuses:
  combat: { attacks_base: 4, initiative: 3, strike: 1, parry: 1, dodge: 4, roll: 3 }
  saves: { horror_factor: 7, spell_magic: 2, ritual_magic: 2, psionics: 2, mind_control: 2, possession: 2, illusionary_magic: 2, faerie_magic: 2, curses: 2, insanity: 2, toxins_poisons: 2, harmful_drugs: 2, disease: 2, pain: 2, fatigue: 2 }
skills:
  occ_skills:
    - { name: "Mathematics: Basic", base: 98, per_level: 0, note: "Instinctive." }
    - { name: "Language: Dragonese", base: 98, per_level: 0, note: "Instinctive." }
    - { name: "Literacy: Dragonese/Elven", base: 98, per_level: 0, note: "Instinctive." }
  occ_related_skills:
    count: 1
    categories:
      - { name: "Technical", only: ["Language: Other", "Research", "Lore: Astral", "Lore: D-Bee", "Lore: Demons & Monsters", "Lore: Dimensions", "Lore: Faeries & Creatures of Magic", "Lore: Galactic/Alien", "Lore: Juicers", "Lore: Magic", "Lore: Nightbane", "Lore: Nightlands", "Lore: Psychics & Psionics", "Lore: Religion", "Lore: Vampires"], bonus: 15 }
      - { name: "Communications", only: ["Literacy: Other"], bonus: 15 }
      - { name: "Cowboy", only: ["Lore: American Indians", "Lore: Cattle & Animals"], bonus: 15 }
    note: "The Rifts hatchling R.C.C.''s Special Areas of Interest and Expertise - one at levels 1, 3, 6, 9, 12, 15 and 20, each at +15%. Language: Other (any), Literacy: Other (any), Lore (all) and Research; dragons love language."
    schedule:
      - { level: 3, count: 1 }
      - { level: 6, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
      - { level: 15, count: 1 }
      - { level: 20, count: 1 }
  secondary_skills:
    count: 2
    schedule:
      - { level: 2, count: 2 }
      - { level: 4, count: 2 }
      - { level: 8, count: 2 }
      - { level: 10, count: 2 }
      - { level: 15, count: 2 }
      - { level: 20, count: 2 }
natural_abilities:
  - name: "Supernatural Attributes"
    description: "All attributes are considered supernatural."
  - name: "Flight"
    description: "Flies by snaking through the sky like an eel through water, rarely touching the ground; Spd 3D6+88, over 55 mph (88 km)."
  - name: "Nightvision"
    description: "1200 feet (366 m); can see even in total darkness."
  - name: "See the Invisible"
    description: "At will."
  - name: "Turn Invisible at Will"
    description: "At will."
  - name: "Climbing"
    description: "98%."
  - name: "Prowl"
    description: "60%."
  - name: "Adjust Size"
    description: "Can take any size from 15 feet (4.6 m) long, snout to tail tip, up to its natural full length of 60 feet (18.3 m) - the adult''s figure. It usually moves in a fluid, coiled pattern, like an undulating spring."
  - name: "Bio-Regeneration"
    description: "1D4x10 M.D.C. per minute."
  - name: "Dimensional Teleport"
    description: "88%."
  - name: "Impervious to Cold, Poisons, Disease and Possession"
    description: "No effect from any of them."
  - name: "Claws, Bite and Tail"
    description: "Bite 5D6 M.D., claw strike 5D6 M.D., punch or kick 5D6 M.D., tail whip 1D4x10 M.D., power punch 1D6x10 M.D. The book prints one set of figures and does not scale them for a hatchling. It prefers to use magic and magic weapons."
special_abilities:
  - name: "Attacks per Melee"
    description: "A hatchling has four physical or psionic attacks per melee round, or two by magic. A young adult has six and a mature adult seven."
  - { choose: 1, from: ["Hatchling Art of Stealth (Pi Mi Hsing Tung)", "Hatchling Art of Hiding (Inpo)", "Hatchling Art of Evasion (Hsing Tsia)", "Hatchling Art of Vanishing (Sun Shih K''an Chien Chih)", "Hatchling Art of Disguise (Hensho-Jutsu)", "Hatchling Art of Mystic Invisibility (Chi Zoshiki)"], note: "Mystic Martial Arts Knowledge: select one art of invisibility (printed 214; the arts are printed 195-196)." }
  - { choose: 1, from: ["Hatchling Zenjoriki: Calm Minds", "Hatchling Zenjoriki: Karumi-Jutsu", "Hatchling Zenjoriki: Two Minds", "Hatchling Zenjoriki: Vibrating Palm", "Hatchling Zenjoriki: Vital Strike Atemi", "Hatchling Zenjoriki: Withering Flesh Atemi"], note: "Mystic Martial Arts Knowledge: select one zenjoriki power (printed 214; the powers are printed 197-199)." }
  - name: "Hatchling Art of Stealth (Pi Mi Hsing Tung)"
    description: "Mystic Art of Invisibility, the martial equivalent of prowl. Moving silently and out of sight in the dark while unsuspected is automatic, with no prowl roll; if the area comes under inspection (a spotlight, investigators) the chance to stay undetected is 43% +3% per level. Also Jung Hua, melting into water: moving silently into, out of and through water at 50% +3% per level (deep water requires the swimming skill)."
  - name: "Hatchling Art of Hiding (Inpo)"
    description: "Mystic Art of Invisibility: becoming one with a surrounding object and staying motionless for hours or even days. Normally no chance of detection; in a well-lit area under careful inspection the chance to remain undetected is 60% +3% per level. Works only while the character stays motionless."
  - name: "Hatchling Art of Evasion (Hsing Tsia)"
    description: "Mystic Art of Invisibility: staying out of view behind someone, turning as he turns. Automatic if the enemy is unaware of the character; if he knows or suspects someone is behind him, 50% +3% per level. The character can keep attacking from behind (critical strikes, knockout attacks) for as long as each roll keeps him unseen. Fails if a companion of the victim can see the attacker and warn him, or if the victim backs against a wall. Only the person stalked is fooled; everyone else sees both clearly. Once the victim catches sight of the stalker the power is negated and cannot be resumed unless the character can also vanish."
  - name: "Hatchling Art of Vanishing (Sun Shih K''an Chien Chih)"
    description: "Mystic Art of Invisibility: disappearing from clear view, even mid-combat, by distraction and a sudden drop or roll. 85% +1% per level in full darkness with many obstructions; cumulative penalties of -10% in fair light, -20% in strong light, -15% on clear, flat, featureless ground, and -20% when cornered with nowhere to go but forward (or up, or down). The book''s example: a first level character in strong light on flat ground needs 50 or less. Lasts one melee action (two or three seconds), enough to begin the art of evasion or another ability, and the act of vanishing counts as one melee action."
  - name: "Hatchling Art of Disguise (Hensho-Jutsu)"
    description: "Mystic Art of Invisibility: instantly changing posture, stance, walk and expression to pass as someone else in the same clothes. Automatic in crowds of 100 or more people; in smaller crowds or sparsely peopled areas 50% +3% per level, -40% if stopped and specifically questioned or searched. Combined with the Disguise skill: 96% to conceal true identity and 88% to physically impersonate a specific person or occupation (the latter after hours of study and practice). Useless in an outrageous outfit such as a ninja suit, though a hood or garment can be whipped off in a moment."
  - name: "Hatchling Art of Mystic Invisibility (Chi Zoshiki)"
    description: "Mystic Art of Invisibility: clouding the minds of observers so the character vanishes even while standing in full view. Costs 1 P.P.E. per melee round (15 seconds) of invisibility, 4 P.P.E. per round to cloud 2-8 people at once, 12 per round for more than eight. He must turn visible to fight or to use any skill other than the arts of invisibility. It also shields his P.P.E. from magic and psionic detection and from being siphoned: detect magic, detect psionics and see the invisible cannot locate him, and those clouded cannot see him with optics or motion detectors either. Save: 19 or higher, rolled once for a whole group; a successful save means he is still seen. May try to turn invisible once per melee round."
  - name: "Hatchling Zenjoriki: Calm Minds"
    description: "10 P.P.E.; range 120 feet (36.5 m); lasts three minutes (12 melee rounds); takes one melee action (3 seconds) to perform. Everyone in range, friend and foe alike, who fails a save vs calm of 17 or better on a twenty-sided die (M.E. bonus applies) stops attacking at once and cannot resume offensive action until it ends, though they may defend, flee or do anything else. Any attack by the user dispels it instantly. It cannot be used on the same group again for another hour. It also dispels fear and any other hysterical emotion, whatever the cause."
  - name: "Hatchling Zenjoriki: Karumi-Jutsu"
    description: "10 P.P.E.; self; lasts three minutes (12 melee rounds) per level; no save. The character changes his own body''s weight at will - not his clothing or possessions. It takes total concentration: no other attacks, defenses or actions while it is used, and it does not work in combat or when unconscious. Falling: lands on his feet unhurt from any distance. Jumping: up to 10 times his normal distance (at least 40 feet/12.2 m). Climbing: any surface, like an insect, with no fear of falling. Treading lightly: walks on a spider''s web, thread, a thin branch, an extremely fragile bridge, china teacups or leaves without breaking or disturbing them."
  - name: "Hatchling Zenjoriki: Two Minds"
    description: "30 P.P.E.; self; lasts three minutes (12 melee rounds) per level; no save. The soul splits into the Hun (Cloud Soul) and the Po (Bone Soul), which act independently, even in two places at once; typically the Po fights with the body while the Hun works on tactics, calls commands or makes simultaneous psionic, magic or long-range attacks at -4 to strike. Hun: a wispy ghost with speech, analytical thought, mathematics, map reading, all thinking skills and the use of magic/P.P.E. and psionics/I.S.P.; mental attributes at full, physical at half; it cannot fight or use martial arts, recharge P.P.E. or I.S.P., or sense danger, art, taste or smell, and is barely able to walk. Po: keeps the body with all combat bonuses, physical skills, martial arts, weapon proficiencies and pilot skills, P.P.E. and I.S.P. regeneration, and taste, scent and esthetics; physical attributes at full, mental at half; it cannot speak, use thinking skills, magic or psionics, or control its emotions. Hit points and S.D.C. are split 50/50 between the two. Once split the roles cannot be swapped without rejoining and starting over."
  - name: "Hatchling Zenjoriki: Vibrating Palm"
    description: "70 P.P.E.; range 120 feet (36.5 m); lasts up to 10 melee rounds (two and a half minutes); no save. Sympathetic vibrations shatter any material object: 1 point in the first melee round, doubling every round after (2, then 4, then 8 and so on) to the maximum of 512 points by the tenth round of an uninterrupted attack. S.D.C. damage to humans and S.D.C. structures, mega-damage to mega-damage beings and structures. More than 512 takes a second attack and another 70 P.P.E. It needs complete, undivided attention: no other attacks, actions or defenses, not even talking or looking elsewhere; being knocked out, blinded or tackled interrupts it. Stopped or interrupted, the vibrations end, no more damage is added, and starting again begins at 1 point."
  - name: "Hatchling Zenjoriki: Vital Strike Atemi"
    description: "20 P.P.E.; a punch, kick or hand-held weapon strike (not thrown weapons or arrows); instant. The blow does its normal damage directly to hit points, bypassing physical S.D.C.; a victim at zero hit points or below falls into a coma whatever S.D.C. remains. Save: the victim halves the damage with a roll with punch/fall/impact that beats the attacker''s roll to strike. It cannot be used to inflict S.D.C. damage, does only normal damage to body armor and inanimate objects, and cannot pass through M.D.C. environmental body armor, power armor or vehicles (it works through non-environmental armor). Against mega-damage supernatural beings such as oni and dragons each strike does the blow''s damage x2 as M.D. (a 1D6 S.D.C. punch does 2D6 M.D., a 3D6 sword 6D6 M.D.). Characters with Stone Ox are immune; those with Chi-Gung mega-damage skin take half damage without rolling."
  - name: "Hatchling Zenjoriki: Withering Flesh Atemi"
    description: "25 P.P.E. if the punch or kick strikes, 5 P.P.E. if it misses; instant. Instead of normal damage the strike knocks out up to 100 points of a living victim''s natural S.D.C., leaving him open to attacks on hit points. Save: the victim halves it with a roll with punch/fall/impact that beats the attacker''s roll to strike. It cannot inflict hit point damage, cannot damage body armor or inanimate objects, and cannot pass through M.D.C. environmental body armor, power armor or vehicles (it works through non-environmental armor). Against mega-damage supernatural beings such as oni, dragons and even gods each strike does 2D4x10 M.D. (only 1D4x10 against elementals), until half the creature''s M.D.C. is gone, after which it has no effect; that damage cannot be regenerated by any means for one full hour. Characters with Kangeiko & Shochu Geiko are immune; those with Chi-Gung mega-damage skin take half damage without rolling."
  - name: "Magic (adults and NPC dragons)"
    description: "The species entry prints the magic of a grown dragon (adult P.P.E. 1D6x100+200): 50% know all air, illusion and dimensional magic spells listed in the Rifts RPG, plus Tongues, Magic Pigeon, Eyes of Thoth, Sanctum, Dispel Magic Barrier, Negate Magic, Anti-Magic Cloud and both protection circles; the other 50% know all air warlock spells (Rifts Conversion Book One). A player character hatchling starts with none of it and learns spells by the hatchling rules."
  - name: "R.C.C. Skills (adults and NPC dragons)"
    description: "Only scholarly pursuits: all Technical skills (including all lores, languages and literacy) except computers and photography, all at +10%, plus Basic Math (+10%), Calligraphy, Land Navigation, Identify Plants & Fruits, Gardening, Dance, Sing and Play Wind Instruments (flutes and horns). A player character hatchling uses the Rifts hatchling R.C.C.''s skills instead."
level_progression:
  - { level: 3, grants: ["Choose a definitive alignment, if not already chosen"] }
  - { level: 9, grants: ["+1 to Spell Strength"] }
restrictions:
  - "Alignment: any; kumo-mi can be good, anarchist or evil. Under the Rifts hatchling rules most hatchlings begin as Unprincipled or Anarchist and behave like a child of four to seven - self-serving, self-obsessed, a little snotty, liable to wander off - and at level three the player must settle on a definitive alignment."
  - "Horror Factor (awe): 15. The book prints one figure for the species and does not scale it for a hatchling."
  - "Speed: 3D6+88 flying/snaking through the sky. The book prints no running speed."
  - "Vulnerabilities: weapons made of silver do mega-damage; fire and magic weapons do their usual damage; earth elementals inflict double damage."
  - "MAGIC: knows NO spells at first level. Spells are learned by the usual means from second level - by third level the hatchling has 2D4+2 spells from levels 1-3, another 2D4+2 by fifth level from levels 3-8, and 3 new spells per level thereafter up to its own level. Two spells may be cast per melee round, and it gains +1 to spell strength at level nine. Those counts are dice-valued, which a spell schedule cannot hold, so they are recorded here."
  - "It understands magic fully without knowing spells: it uses any techno-wizard device without instruction, recognises and uses magic weapons, reads magic, uses scrolls, and recognises magic circles and enchantment at 40% +3% per level. It senses ley lines and nexus points within 20 miles (32 km) and other dragons - even metamorphosed ones - on sight to 4000 feet (1219 m). Sensing gives nearness and direction, never a pinpoint."
  - "PSIONICS: all the Healing powers plus Telepathy, Empathy and Mind Block, as the species prints; I.S.P. 3D4x10."
  - "Size: a hatchling is born about one-third of its mature size and reaches 80% of full size within 3D4 weeks of hatching; it is not mature until about 600 years old. The adult weighs four tons."
  - "Dragons do not need to eat or drink - as creatures of magic they absorb magic energy - and do so only for the pleasure of it."
  - "Cybernetics and bionics: NONE, ever. The bio-regenerative powers reject implants and push them back out as the body heals."
  - "Money: a hatchling under 100 years old is not much interested in wealth or power, though always drawn to magic items. It wants to see the world."
  - "Weapons and equipment: it can use any weapon and may wear little or nothing, mega-damage armour included, except as part of a disguise."
  - "Only the dragon''s I.Q. bonus applies to secondary skills. The level 20 grants recorded above come from the Rifts hatchling R.C.C.; this app caps a character at level 15, so they will not fire."
  - "Teleport: the Rifts hatchling R.C.C. says only adult dragons have the natural dimensional powers of the dragons in other books; the 88% printed here is the species figure, not scaled for a hatchling. The GM decides whether a hatchling may use it outside a ley line nexus."
side_effects: "One of the three Japanese dragons Rifts World Book 8: Japan details, printed 212-214. The book makes the dragon an NPC, and says a player character uses the same basic rules as the Rifts RPG hatchling R.C.C. and starts as a first level hatchling. The kumo-mi is indigenous to an alien dimension and lives 8,000 years or more."
extraction_notes: |
  Read from Rifts World Book 8: Japan printed 212-214 via the text layer at
  .cache/books/japan (page_offset +1: cache p213-p215). The lore opens under
  Kumo-Mi in the right column of printed 212; the stat block starts on printed
  213 (a half page beside art) and ends at the head of printed 214, where
  Asama-Tatsu begins. Printed 213 was rendered (pymupdf index 213) to read the
  digit-cipher figures: M.D.C. 1D4x100+50 hatchling, 1D4x1000+600 young adult,
  2D4x1000+100 mature adult; P.P.E. 1D4x100 hatchling, 1D6x100+80 young adult,
  1D6x100+200 mature adult; I.S.P. 3D4x10. Printed 214''s figures (tail whip
  1D4x10, power punch 1D6x10) were read from the text layer.

  THE SHAPE IS THE RUE HATCHLINGS''. The species tag line says a player
  character uses the Rifts RPG hatchling R.C.C., and Rifts Ultimate Edition
  printed 158 says the other species use that Dragon R.C.C. for skills and level
  advancement and names this book among them. So this copies
  dragon-hatchling-flame-wind line for line wherever the rule is the common
  R.C.C.''s: the three instinctive skills at 98%, the Special Areas of Interest as
  the related allowance, the secondary skills and their schedule, spells_starting
  0 with the learning ladder as prose, the magic-understanding, size, food,
  cybernetics, money and weapons paragraphs. The species half is this book''s.

  1. HATCHLING FIGURES WHERE THE BOOK PRINTS THEM. M.D.C. and P.P.E. are the
     hatchling''s figures; attacks are "four if a hatchling", attacks_base 4.
     The young and mature adult figures are prose. The book prints NO +10 M.D.C.
     per level and no per-level P.P.E. for these species, so none is stored.
  2. ONE FIGURE FOR EVERY AGE. Attributes, horror factor, I.S.P., psionic
     powers, natural abilities, damage and bonuses are printed once, not split by
     age, and are stored as printed. RUE printed 158 converts a hatchling to an
     adult; nothing converts the other way. Flagged for Nate.
  3. Spd 3D6+88 is the printed flying speed; no running speed is printed.
  4. BONUSES: "+2 on all saving throws" is written out across the fourteen d20
     saves, as fire-dragon does; the +7 vs horror factor is its own key.
  5. PSIONICS: "all healing abilities plus telepathy, empathy and mind block",
     granted by name. The Healing list is every catalog Healing row citing Rifts
     Ultimate Edition (15); Attack Disease and Transfer I.S.P. cite the Palladium
     Fantasy main book and are left out. Type major: no Super power is named; the
     book states no tier - a judgement.
  6. MAGIC: the species'' spell lists are the grown dragon''s and are a special
     ability; the magic block is the hatchling R.C.C.''s. "Dispel magic" is read
     as Dispel Magic Barrier.
  7. SKILLS: the species'' R.C.C. skill list is prose, because RUE printed 158
     gives a hatchling species the Dragon R.C.C.''s skills.
  8. MYSTIC MARTIAL ARTS: "select one art of invisibility and one zenjoriki
     power", with no level named, is two level-1 choose groups over the six arts
     (printed 195-196) and the six zenjoriki powers (printed 197-199). The
     descriptions are the readings of those pages shared by every Japan class
     that takes these powers; see note 11 for the names.
     Compare BOOK-INGEST-AUDIT.md F116 for the classes that pick at later levels.
  9. xp_table: none printed for dragons on the Experience Point Tables (cache
     p217, folio 216; read off a render, no dragon column). Copied from the
     seven dragon-hatchling classes: RUE''s Dragon Hatchling & Adult Dragon ladder,
     RUE printed 295, via ~006-rue-xp-ladders.sql.
  10. horror_factor is a top-level key here where flame-wind has only prose,
      because the Japan entry prints one figure and the key is modelled.
  11. 2026-10-05, MYSTIC MARTIAL ARTS KNOWLEDGE: printed 214, read off a render:
      "Select one art of invisibility and one Zenjoriki power", with no level
      and no later pick printed. Kept as the two creation pick groups. The
      twelve definitions were replaced with the readings of printed 195-199
      shared by every Japan class that takes these powers; none prints an
      unconditional number, so none carries bonuses. Every option is named
      with a "Hatchling " prefix here, in its definition and in its group,
      because a race and an occupation can be paired and a character''s picks
      are one list of names: the occupations that pick from the same powers
      keep the plain names. The zenjoriki powers run to the top of printed
      199, so "197-198" above and in the group note was corrected to 197-199.
---

## Lore

Kumo-mi means "cloud serpent" or "cloud dragon", for the dragon lives high in
the mountains where the clouds come to rest, and for its elemental powers. It is
a creature of the air, moving through it like an eel through water, snaking and
floating effortlessly and rarely touching the ground.

Its fine scales are usually white with green accents and jade whiskers and fins,
or pale blue with green or dark blue fins along the spine. Its eyes sparkle like
diamonds and a pair of long horns crowns its head; a single pair of clawed limbs
sits toward the front of a long, smooth, snake-like body.

Kumo-mi are like humans: some are good and kind, others notoriously evil, most
somewhere between. An ancient cloud serpent called Summer Snow is a guardian of
Mount Fuji and a friend to the New Empire, while another rules an oni kingdom in
The Zone as an infamous despot. They are rare - no more than a hundred across the
islands.

**Habitat:** Indigenous to an alien dimension; occasionally found anywhere, but
favours Japan, Korea, China, India and Indonesia. Many keep mountain retreats.

**Enemies:** Often clashes with elementals and with power-hungry creatures of
magic and supernatural beings.

**Allies:** Varies with the dragon; most are drawn to intelligent, trustworthy
beings and practitioners of magic, and tend to avoid other dragons.

**Average Life Span:** 8,000+ years.

## GM Notes

Average NPC level: 1D4+2 for hatchlings and young adults, 2D4+4 for mature
adults. A player character starts as a first level hatchling.

Grown dragon figures: M.D.C. 1D4x1000+600 (young adult), 2D4x1000+100 (mature
adult); P.P.E. 1D6x100+80 (young adult), 1D6x100+200 (mature adult); six
attacks per melee for a young adult and seven for a mature adult, physical or
psionic, or two by magic. Full length 60 feet (18.3 m), four tons.
',
       updated_at = datetime('now')
 WHERE class_id = 'dragon-hatchling-kumo-mi'
   AND instr(markdown, 'descriptions are the paraphrases used by mystic-ninja and sohei-warrior-monk.') > 0
   AND length(markdown) = 19942;

-- == dragon-hatchling-asama-tatsu ==
UPDATE imported_classes
   SET markdown = '---
id: dragon-hatchling-asama-tatsu
name: Dragon Hatchling (Asama-Tatsu)
system: rifts
source_book: Rifts World Book 8: Japan p.214-215
category: rcc
tags: [supernatural, high-power, flyer]
xp_table: [0, 3001, 5001, 10001, 20001, 30001, 50001, 80001, 120001, 170001, 230001, 300001, 380001, 470001, 600001]
attribute_dice:
  IQ: "2d6+16"
  ME: "2d6+10"
  MA: "2d6+10"
  PS: "2d6+36"
  PP: "2d6+10"
  PE: "2d6+16"
  PB: "3d6+10"
  Spd: "3d6+88"
mdc_base: "1D4x100+50"
ppe_base: "1D4x100"
horror_factor: 16
magic:
  type: "spell"
  spells_starting: 0
psionics:
  type: "master"
  isp_base: "3D4x10"
  powers: ["Alter Aura", "Deaden Senses", "Death Trance", "Ectoplasm", "Ectoplasmic Disguise", "Float", "Impervious to Cold", "Impervious to Fire", "Impervious to Poison/Toxin", "Levitation", "Mind Block", "Nightvision", "Resist Hunger", "Resist Thirst", "Spontaneous Combustion", "Summon Inner Strength", "Telekinesis", "Telekinetic Leap", "Telekinetic Lift", "Telekinetic Punch", "Telekinetic Push", "Teleport Object", "Telepathy", "Pyrokinesis", "Mind Block Auto-Defense", "P.P.E. Shield"]
  powers_starting: 0
bonuses:
  combat: { attacks_base: 4, initiative: 4, strike: 2, parry: 2, dodge: 2, roll: 2 }
  saves: { horror_factor: 8, spell_magic: 2, ritual_magic: 2, psionics: 2, mind_control: 2, possession: 2, illusionary_magic: 2, faerie_magic: 2, curses: 2, insanity: 2, toxins_poisons: 2, harmful_drugs: 2, disease: 2, pain: 2, fatigue: 2 }
skills:
  occ_skills:
    - { name: "Mathematics: Basic", base: 98, per_level: 0, note: "Instinctive." }
    - { name: "Language: Dragonese", base: 98, per_level: 0, note: "Instinctive." }
    - { name: "Literacy: Dragonese/Elven", base: 98, per_level: 0, note: "Instinctive." }
  occ_related_skills:
    count: 1
    categories:
      - { name: "Technical", only: ["Language: Other", "Research", "Lore: Astral", "Lore: D-Bee", "Lore: Demons & Monsters", "Lore: Dimensions", "Lore: Faeries & Creatures of Magic", "Lore: Galactic/Alien", "Lore: Juicers", "Lore: Magic", "Lore: Nightbane", "Lore: Nightlands", "Lore: Psychics & Psionics", "Lore: Religion", "Lore: Vampires"], bonus: 15 }
      - { name: "Communications", only: ["Literacy: Other"], bonus: 15 }
      - { name: "Cowboy", only: ["Lore: American Indians", "Lore: Cattle & Animals"], bonus: 15 }
    note: "The Rifts hatchling R.C.C.''s Special Areas of Interest and Expertise - one at levels 1, 3, 6, 9, 12, 15 and 20, each at +15%. Language: Other (any), Literacy: Other (any), Lore (all) and Research; dragons love language."
    schedule:
      - { level: 3, count: 1 }
      - { level: 6, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
      - { level: 15, count: 1 }
      - { level: 20, count: 1 }
  secondary_skills:
    count: 2
    schedule:
      - { level: 2, count: 2 }
      - { level: 4, count: 2 }
      - { level: 8, count: 2 }
      - { level: 10, count: 2 }
      - { level: 15, count: 2 }
      - { level: 20, count: 2 }
natural_abilities:
  - name: "Supernatural Attributes"
    description: "All attributes are considered supernatural."
  - name: "Flight"
    description: "Flies by snaking through the sky; Spd 3D6+88, over 55 mph (88 km)."
  - name: "Nightvision"
    description: "1200 feet (365 m); can see even in total darkness."
  - name: "See the Invisible"
    description: "At will."
  - name: "Impervious to Fire and Heat"
    description: "Even mega-damage plasma and magic fire."
  - name: "Impervious to Poisons, Disease and Possession"
    description: "No effect from any of them."
  - name: "Climbing"
    description: "90%."
  - name: "Swimming"
    description: "90%."
  - name: "Adjust Size"
    description: "Can adjust its length from 20 to 100 feet (6-30.5 m); the Size line prints the smallest size as 15 feet (4.6 m). 100 feet is its natural full length - the adult''s figure."
  - name: "Bio-Regeneration"
    description: "1D4x10 M.D.C. per minute."
  - name: "Dimensional Teleport"
    description: "92%."
  - name: "Teleport Self"
    description: "96%."
  - name: "Claws, Bite and Tail"
    description: "6D6 S.D.C. on a restrained punch, 5D6 M.D. on a full strength punch or claw strike, 1D6x10 M.D. on a power punch, bite 6D6 M.D., tail whip 1D6x10 M.D. The book prints one set of figures and does not scale them for a hatchling. It prefers to use magic, but fights like a tsunami when angry or fighting for its life."
special_abilities:
  - name: "Attacks per Melee"
    description: "A hatchling has four physical or psionic attacks per melee round, or two by magic. A young adult has six and a mature adult seven."
  - name: "Mystic Martial Arts Knowledge"
    description: "Selects one zenjoriki power at levels 2, 7, 12 and 20 (printed 215), from the six printed 197-199: Calm Minds, Karumi-Jutsu, Two Minds, Vibrating Palm, Vital Strike Atemi and Withering Flesh Atemi. None is known at level one. The picks at levels 2, 7 and 12 are made from the group below, whose options are named with a Hatchling prefix; the level 20 pick is past the fifteen levels played here and is the GM''s to grant."
  - { choose: 1, at_levels: [2, 7, 12], from: ["Hatchling Zenjoriki: Calm Minds", "Hatchling Zenjoriki: Karumi-Jutsu", "Hatchling Zenjoriki: Two Minds", "Hatchling Zenjoriki: Vibrating Palm", "Hatchling Zenjoriki: Vital Strike Atemi", "Hatchling Zenjoriki: Withering Flesh Atemi"], note: "Mystic Martial Arts Knowledge (printed 215): one zenjoriki power at each of levels 2, 7 and 12; none at level one. The page prints a fourth pick at level 20, beyond the fifteen levels played here - the GM grants it by hand from whichever powers remain." }
  - name: "Hatchling Zenjoriki: Calm Minds"
    description: "10 P.P.E.; range 120 feet (36.5 m); lasts three minutes (12 melee rounds); takes one melee action (3 seconds) to perform. Everyone in range, friend and foe alike, who fails a save vs calm of 17 or better on a twenty-sided die (M.E. bonus applies) stops attacking at once and cannot resume offensive action until it ends, though they may defend, flee or do anything else. Any attack by the user dispels it instantly. It cannot be used on the same group again for another hour. It also dispels fear and any other hysterical emotion, whatever the cause."
  - name: "Hatchling Zenjoriki: Karumi-Jutsu"
    description: "10 P.P.E.; self; lasts three minutes (12 melee rounds) per level; no save. The character changes his own body''s weight at will - not his clothing or possessions. It takes total concentration: no other attacks, defenses or actions while it is used, and it does not work in combat or when unconscious. Falling: lands on his feet unhurt from any distance. Jumping: up to 10 times his normal distance (at least 40 feet/12.2 m). Climbing: any surface, like an insect, with no fear of falling. Treading lightly: walks on a spider''s web, thread, a thin branch, an extremely fragile bridge, china teacups or leaves without breaking or disturbing them."
  - name: "Hatchling Zenjoriki: Two Minds"
    description: "30 P.P.E.; self; lasts three minutes (12 melee rounds) per level; no save. The soul splits into the Hun (Cloud Soul) and the Po (Bone Soul), which act independently, even in two places at once; typically the Po fights with the body while the Hun works on tactics, calls commands or makes simultaneous psionic, magic or long-range attacks at -4 to strike. Hun: a wispy ghost with speech, analytical thought, mathematics, map reading, all thinking skills and the use of magic/P.P.E. and psionics/I.S.P.; mental attributes at full, physical at half; it cannot fight or use martial arts, recharge P.P.E. or I.S.P., or sense danger, art, taste or smell, and is barely able to walk. Po: keeps the body with all combat bonuses, physical skills, martial arts, weapon proficiencies and pilot skills, P.P.E. and I.S.P. regeneration, and taste, scent and esthetics; physical attributes at full, mental at half; it cannot speak, use thinking skills, magic or psionics, or control its emotions. Hit points and S.D.C. are split 50/50 between the two. Once split the roles cannot be swapped without rejoining and starting over."
  - name: "Hatchling Zenjoriki: Vibrating Palm"
    description: "70 P.P.E.; range 120 feet (36.5 m); lasts up to 10 melee rounds (two and a half minutes); no save. Sympathetic vibrations shatter any material object: 1 point in the first melee round, doubling every round after (2, then 4, then 8 and so on) to the maximum of 512 points by the tenth round of an uninterrupted attack. S.D.C. damage to humans and S.D.C. structures, mega-damage to mega-damage beings and structures. More than 512 takes a second attack and another 70 P.P.E. It needs complete, undivided attention: no other attacks, actions or defenses, not even talking or looking elsewhere; being knocked out, blinded or tackled interrupts it. Stopped or interrupted, the vibrations end, no more damage is added, and starting again begins at 1 point."
  - name: "Hatchling Zenjoriki: Vital Strike Atemi"
    description: "20 P.P.E.; a punch, kick or hand-held weapon strike (not thrown weapons or arrows); instant. The blow does its normal damage directly to hit points, bypassing physical S.D.C.; a victim at zero hit points or below falls into a coma whatever S.D.C. remains. Save: the victim halves the damage with a roll with punch/fall/impact that beats the attacker''s roll to strike. It cannot be used to inflict S.D.C. damage, does only normal damage to body armor and inanimate objects, and cannot pass through M.D.C. environmental body armor, power armor or vehicles (it works through non-environmental armor). Against mega-damage supernatural beings such as oni and dragons each strike does the blow''s damage x2 as M.D. (a 1D6 S.D.C. punch does 2D6 M.D., a 3D6 sword 6D6 M.D.). Characters with Stone Ox are immune; those with Chi-Gung mega-damage skin take half damage without rolling."
  - name: "Hatchling Zenjoriki: Withering Flesh Atemi"
    description: "25 P.P.E. if the punch or kick strikes, 5 P.P.E. if it misses; instant. Instead of normal damage the strike knocks out up to 100 points of a living victim''s natural S.D.C., leaving him open to attacks on hit points. Save: the victim halves it with a roll with punch/fall/impact that beats the attacker''s roll to strike. It cannot inflict hit point damage, cannot damage body armor or inanimate objects, and cannot pass through M.D.C. environmental body armor, power armor or vehicles (it works through non-environmental armor). Against mega-damage supernatural beings such as oni, dragons and even gods each strike does 2D4x10 M.D. (only 1D4x10 against elementals), until half the creature''s M.D.C. is gone, after which it has no effect; that damage cannot be regenerated by any means for one full hour. Characters with Kangeiko & Shochu Geiko are immune; those with Chi-Gung mega-damage skin take half damage without rolling."
  - name: "Magic (adults and NPC dragons)"
    description: "The species entry prints the magic of a grown dragon (adult P.P.E. 2D4x100+200): 50% are ley line walkers who know all spells of levels 1-7 plus 12 more from levels 8-15; 20% are diabolists (Rifts Conversion Book One); 20% are techno-wizards who know all spells of levels 1-5 plus six of choice from higher levels; 10% are alchemists (NPCs) who can create every item listed in the book''s magic section except rune weapons. A player character hatchling starts with none of it and learns spells by the hatchling rules."
  - name: "R.C.C. Skills (adults and NPC dragons)"
    description: "Only scholarly pursuits: all Science and Technical skills including computers, and all Pilot Related skills or Medical and herbal skills; all at +20%. A player character hatchling uses the Rifts hatchling R.C.C.''s skills instead."
level_progression:
  - { level: 3, grants: ["Choose a definitive alignment, if not already chosen"] }
  - { level: 9, grants: ["+1 to Spell Strength"] }
  - { level: 20, grants: ["A fourth zenjoriki power (printed 215; granted by the GM)"] }
restrictions:
  - "Alignment: any; good, anarchist or evil, though most are aloof. Under the Rifts hatchling rules most hatchlings begin as Unprincipled or Anarchist and behave like a child of four to seven - self-serving, self-obsessed, a little snotty, liable to wander off - and at level three the player must settle on a definitive alignment."
  - "Horror Factor (awe): 16. The book prints one figure for the species and does not scale it for a hatchling."
  - "Speed: 3D6+88 flying/snaking through the sky. The book prints no running speed."
  - "Vulnerabilities: cold-based attacks and magic do double damage; magic weapons and mega-damage weapons do their usual damage."
  - "MAGIC: knows NO spells at first level. Spells are learned by the usual means from second level - by third level the hatchling has 2D4+2 spells from levels 1-3, another 2D4+2 by fifth level from levels 3-8, and 3 new spells per level thereafter up to its own level. Two spells may be cast per melee round, and it gains +1 to spell strength at level nine. Those counts are dice-valued, which a spell schedule cannot hold, so they are recorded here."
  - "It understands magic fully without knowing spells: it uses any techno-wizard device without instruction, recognises and uses magic weapons, reads magic, uses scrolls, and recognises magic circles and enchantment at 40% +3% per level. It senses ley lines and nexus points within 20 miles (32 km) and other dragons - even metamorphosed ones - on sight to 4000 feet (1219 m). Sensing gives nearness and direction, never a pinpoint."
  - "PSIONICS: all the Physical powers plus Telepathy, Pyrokinesis, Mind Block Auto-Defense and P.P.E. Shield, as the species prints; I.S.P. 3D4x10."
  - "Size: a hatchling is born about one-third of its mature size and reaches 80% of full size within 3D4 weeks of hatching; it is not mature until about 600 years old. The adult stands 20 feet (6 m) tall at the head, is 100 feet (30.5 m) long and weighs twenty-two tons."
  - "Dragons do not need to eat or drink - as creatures of magic they absorb magic energy - and do so only for the pleasure of it."
  - "Cybernetics and bionics: NONE, ever. The bio-regenerative powers reject implants and push them back out as the body heals."
  - "Money: a hatchling under 100 years old is not much interested in wealth or power, though always drawn to magic items. It wants to see the world."
  - "Weapons and equipment: it can use any weapon and may wear little or nothing, mega-damage armour included, except as part of a disguise."
  - "Only the dragon''s I.Q. bonus applies to secondary skills. The level 20 grants recorded above come from the book and the Rifts hatchling R.C.C.; this app caps a character at level 15, so they will not fire."
  - "Teleport: the Rifts hatchling R.C.C. says a hatchling can teleport only itself, and that only adult dragons have the natural dimensional powers of the dragons in other books; the 92% and 96% printed here are the species figures, not scaled for a hatchling. The GM decides whether a hatchling may teleport dimensionally outside a ley line nexus."
side_effects: "One of the three Japanese dragons Rifts World Book 8: Japan details, printed 214-215. The book makes the dragon an NPC, and says a player character uses the same basic rules as the Rifts RPG hatchling R.C.C. and starts as a first level hatchling. The asama-tatsu is indigenous to an alien dimension and lives 8,000 years or more."
extraction_notes: |
  Read from Rifts World Book 8: Japan printed 214-215 via the text layer at
  .cache/books/japan (page_offset +1: cache p215-p216). The lore and the
  Asama-Tatsu/Dragon heading are in the right column of printed 214; the stat
  block is printed 215, which was rendered (pymupdf index 215) to read the
  digit-cipher figures: M.D.C. 1D4x100+50 hatchling, 1D6x1000+600 young adult,
  2D4x1000+1400 mature adult; P.P.E. 1D4x100 hatchling, 1D6x100+100 young adult,
  2D4x100+200 mature adult; I.S.P. 3D4x10; zenjoriki levels 2, 7, 12 and 20.

  THE SHAPE IS THE RUE HATCHLINGS''. The species tag line says a player
  character uses the Rifts RPG hatchling R.C.C., and Rifts Ultimate Edition
  printed 158 says the other species use that Dragon R.C.C. for skills and level
  advancement and names this book among them. So this copies
  dragon-hatchling-flame-wind line for line wherever the rule is the common
  R.C.C.''s: the three instinctive skills at 98%, the Special Areas of Interest as
  the related allowance, the secondary skills and their schedule, spells_starting
  0 with the learning ladder as prose, the magic-understanding, size, food,
  cybernetics, money and weapons paragraphs. The species half is this book''s.

  1. HATCHLING FIGURES WHERE THE BOOK PRINTS THEM. M.D.C. and P.P.E. are the
     hatchling''s figures; attacks are "four if a hatchling", attacks_base 4.
     The young and mature adult figures are prose. The book prints NO +10 M.D.C.
     per level and no per-level P.P.E. for these species, so none is stored.
  2. ONE FIGURE FOR EVERY AGE. Attributes, horror factor, I.S.P., psionic
     powers, natural abilities, damage and bonuses are printed once, not split by
     age, and are stored as printed. RUE printed 158 converts a hatchling to an
     adult; nothing converts the other way. P.S. 2D6+36 is far above any RUE
     hatchling. Flagged for Nate.
  3. Spd 3D6+88 is the printed flying speed; no running speed is printed.
  4. SIZE DISAGREES WITH ITSELF: the Size line says 15 to 100 feet, Natural
     Abilities says 20 to 100 feet. Both are in the Adjust Size description.
  5. BONUSES: "+2 on all saving throws" is written out across the fourteen d20
     saves, as fire-dragon does; the +8 vs horror factor is its own key.
  6. PSIONICS: "all physical abilities plus telepathy, pyrokinesis, mind block
     auto-defense, and P.P.E. shield", granted by name. The Physical list is
     every catalog Physical row with a Rifts or unrestricted system (22,
     including Teleport Object, whose row cites no book). Type master because
     three Super powers are named; the book states no tier - a judgement.
  7. MAGIC: the species'' magic is the grown dragon''s and is a special ability;
     the magic block is the hatchling R.C.C.''s.
  8. SKILLS: the species'' R.C.C. skill list is prose, because RUE printed 158
     gives a hatchling species the Dragon R.C.C.''s skills.
  9. MYSTIC MARTIAL ARTS: one zenjoriki power at levels 2, 7, 12 and 20; none
     at level one. See the 2026-10-05 note below for how the picks are stored.
  10. xp_table: none printed for dragons on the Experience Point Tables (cache
      p217, folio 216; read off a render, no dragon column). Copied from the
      seven dragon-hatchling classes: RUE''s Dragon Hatchling & Adult Dragon
      ladder, RUE printed 295, via ~006-rue-xp-ladders.sql.
  11. horror_factor is a top-level key here where flame-wind has only prose,
      because the Japan entry prints one figure and the key is modelled.

  2026-10-05, MYSTIC MARTIAL ARTS KNOWLEDGE (BOOK-INGEST-AUDIT.md F116).
  Printed 215, re-read off a render: "Select one Zenjoriki power at levels 2,
  7, 12, and 20." Stored as one pick group, choose 1 at levels 2, 7 and 12,
  over the six zenjoriki powers of printed 197-199, each with its own
  definition. Level 20 is past the fifteen-level ladder, so that fourth pick
  is prose in the group''s note and a level 20 line that will not fire. The
  six option names carry a "Hatchling " prefix (Hatchling Zenjoriki: Calm
  Minds and so on) so that a hatchling paired with an occupation that picks
  the same powers under their plain names does not share one name between
  two groups; the text of each power is otherwise the section''s. No
  zenjoriki power prints an unconditional bonus, so none carries bonuses.
---

## Lore

Asama-tatsu means "volcano dragon" - probably because the creature is
impervious to fire, has an explosive temper when pushed too far, and is said to
live inside volcanoes to avoid humans pestering it for its great knowledge.

It is huge: 20 feet (6 m) from the top of its head to its front feet and 100
feet (30.5 m) long. Its scales look like gold but are not, its eyes are silver,
and its head is crowned with a golden unicorn horn and a mane of golden-red
hair; the long, fibrous fins down its spine are dark crimson or black shot with
red. Like most dragons it can be good or evil, but most are aloof, and a few have
joined monasteries to help teach the monks.

**Habitat:** Indigenous to an alien dimension; occasionally found anywhere, but
favours Japan, Korea, China, India and Indonesia. Many keep mountain retreats.

**Enemies:** Often clashes with power-hungry creatures of magic and supernatural
beings.

**Allies:** Varies with the dragon; most are loners and tend to avoid other
dragons.

**Average Life Span:** 8,000+ years.

## Zenjoriki Powers

The asama-tatsu learns one zenjoriki power at levels 2, 7, 12 and 20. The
first three are picked on the sheet as the character reaches each level; the
level 20 pick is beyond this app''s level cap and is the GM''s to grant. The six
powers, printed 197-199:

- Calm Minds (10 P.P.E., 120 feet, three minutes): everyone in range who fails a
  save of 17 (M.E. bonus applies) stops attacking, though they may defend or
  flee; any attack by the user ends it, and it cannot be used on the same group
  again for an hour. It also dispels fear and hysteria.
- Karumi-Jutsu (10 P.P.E., self, three minutes per level): controls the body''s
  weight while concentrating - safe falls from any height, tenfold jumps,
  climbing any surface like an insect, treading on delicate surfaces. Not in
  combat.
- Two Minds (30 P.P.E., self, three minutes per level): the soul splits into the
  thinking Hun, a ghostly form with the mental skills and magic or psionics, and
  the fighting Po, which keeps the body; hit points and S.D.C. are split between
  them.
- Vibrating Palm (70 P.P.E., 120 feet, up to 10 melee rounds): sympathetic
  vibrations do 1 point in the first round, doubling each round to 512 by the
  tenth - S.D.C. or M.D. by target - while the user concentrates without
  interruption.
- Vital Strike Atemi (20 P.P.E., touch): a strike''s damage goes straight to hit
  points, a victim at zero falling into a coma; against mega-damage
  supernatural beings it does double the blow''s damage as M.D.
- Withering Flesh Atemi (25 P.P.E. on a hit, 5 on a miss): a strike strips up to
  100 natural S.D.C., or 2D4x10 M.D. (1D4x10 against elementals) from a
  supernatural being, up to half its M.D.C., which cannot regenerate for an hour.

## GM Notes

Average NPC level: 1D4+2 for hatchlings and young adults, 2D4+5 for mature
adults. A player character starts as a first level hatchling.

Grown dragon figures: M.D.C. 1D6x1000+600 (young adult), 2D4x1000+1400 (mature
adult); P.P.E. 1D6x100+100 (young adult), 2D4x100+200 (mature adult); six
attacks per melee for a young adult and seven for a mature adult, physical or
psionic, or two by magic. Twenty-two tons.
',
       updated_at = datetime('now')
 WHERE class_id = 'dragon-hatchling-asama-tatsu'
   AND instr(markdown, 'at level one, so no choose group. Later picks are prose') > 0
   AND length(markdown) = 16453;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 5 classes carry their new text' AS assertion, count(*) AS got, 5 AS want
  FROM imported_classes
 WHERE (class_id = 'mystic-ninja' AND instr(markdown, 'at_levels: [1, 3, 6, 9, 12, 15]') > 0)
    OR (class_id = 'bishamon-fighting-monk' AND instr(markdown, 'one additional body hardening exercise at each of levels 4 and 10') > 0)
    OR (class_id = 'sohei-warrior-monk' AND instr(markdown, 'The sheet offers each pick when its level is reached.') > 0)
    OR (class_id = 'dragon-hatchling-kumo-mi' AND instr(markdown, 'Hatchling Zenjoriki: Calm Minds') > 0)
    OR (class_id = 'dragon-hatchling-asama-tatsu' AND instr(markdown, 'Hatchling Zenjoriki: Calm Minds') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'mystic-ninja' AND instr(markdown, 'record the later picks by hand as the character levels') > 0)
    OR (class_id = 'bishamon-fighting-monk' AND instr(markdown, 'These are picked by the player and recorded by hand') > 0)
    OR (class_id = 'sohei-warrior-monk' AND instr(markdown, 'Add the level 5 and level 9 picks to the character by hand; the sheet does not grant them.') > 0)
    OR (class_id = 'dragon-hatchling-kumo-mi' AND instr(markdown, 'descriptions are the paraphrases used by mystic-ninja and sohei-warrior-monk.') > 0)
    OR (class_id = 'dragon-hatchling-asama-tatsu' AND instr(markdown, 'at level one, so no choose group. Later picks are prose') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('mystic-ninja', 'bishamon-fighting-monk', 'sohei-warrior-monk', 'dragon-hatchling-kumo-mi', 'dragon-hatchling-asama-tatsu') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~167-japan-mystic-martial-arts-picks.sql');
