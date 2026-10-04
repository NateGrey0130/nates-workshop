-- Six classes from five books turn a creation-time percentile table from prose
-- into a banded pick-one ability group, so the wizard's Roll d100 button can
-- roll it. The companion of ~089, for the books other than Underseas.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   arkhon            South America 2 printed 72. Psionics: 01-18 major, 19-50
--                     minor, 51-56 master (who become ESP Specialists). The page
--                     prints nothing for 57-00; that band is None and says so.
--   amaki-stone-man   South America 2 printed 155. Psionics: 01-20 major, 21-50
--                     minor, 51-64 master, 65-00 none. The class said the app's
--                     standard roll "cannot reach Master".
--   felinoid          South America printed 109. The sub-strain table: jaguar
--                     75%, lion 7%, leopard 5%, puma 5%, tiger 3%, small cats
--                     3%, other 2%. THE BOOK PRINTS SHARES, NOT BANDS: the bands
--                     are the shares laid end to end in printed order, and each
--                     option says so. Added dice are bonuses; a reduction stays
--                     in the description, because a dice bonus cannot be
--                     negative, and so does Horror Factor 10.
--   larmac            D-Bees of North America printed 120. Psionics: 01-02
--                     master, 03-07 major, 08-15 minor, 16-00 none.
--   mutant-rat        Lone Star printed 88. Psionics: 01-25 minor with four
--                     Sensitive powers. The page prints nothing for 26-00; that
--                     band is None and says so.
--   oni-of-the-one-hundred  Japan printed 201-202. The four natural-magic power
--                     sets gain their bands (01-25, 26-50, 51-75, 76-00), and
--                     five of the nine appearance tables become groups: Head
--                     Shape, Mouth, Arms and Hands, Legs, Other Features. The
--                     Japan survey left the tables out as "cosmetic"; these five
--                     carry Horror Factor, bite and hand damage, attacks per
--                     melee, Spd and M.D.C. What an ability can add is applied
--                     (attacks, entangle, Spd, M.D.C. as pool bonuses); the rest
--                     is in each option's description. The other four tables
--                     stay prose: two reroll, and two carry no numbers.
--
-- EVERY FIGURE WAS READ OFF A RENDER. Each draft reads `ready` in
-- class-check --remote, and abilityRollBands() returns bands covering 1-100 for
-- every banded group.
--
-- KNOWN AND NOT CHANGED HERE: a "None" result does not switch off the wizard's
-- standard Random Psionics step, which is offered to any class with no
-- class-level psionics block. That was already true of these classes before
-- this script, and is true of the live models (momano-headhunter).
--
-- NOT HERE, on purpose:
--   draconid (Phase World printed 36): its magician-or-psychic branch can be
--     written as a group, but the Magician option then adds 1D6x10 P.P.E. to
--     the RACE's base where the page means the Ley Line Walker's. The fix is a
--     yields_to_occupation the repo's race-and-occupation doc rules out for
--     this race by name. Left as prose.
--
-- Each UPDATE replaces the whole markdown and is guarded on a sentence the old
-- text holds and on the old text's exact length. Production held no character
-- on any of the six on 2026-10-03; the Oni's four power-set options are
-- renamed, and a pick is stored by name. THIS SCRIPT CHANGES PRODUCTION: six
-- class rows. The tilde number is claimed at merge.

-- == arkhon ==
UPDATE imported_classes
   SET markdown = '---
id: arkhon
men_of_arms: false
name: Arkhon
system: rifts
source_book: Rifts World Book 9: South America 2 p.71-73
category: rcc
tags: []
xp_table: [0, 2121, 4281, 8481, 16961, 24961, 34961, 49961, 69961, 94961, 129961, 179961, 229961, 279961, 329961]
attribute_dice:
  IQ: "2d6+6"
  ME: "3d6"
  MA: "3d6"
  PS: "2d6+12"
  PP: "2d6+12"
  PE: "3d6+4"
  PB: "3d6+6"
  Spd: "3d6+10"
hit_points_base: "P.E. + 1d6 per level"
starting_money: "1d6x1000"
bonuses:
  pools: { sdc: "2d6x10" }
  combat: { initiative: 1, roll: 2, pull_punch: 2 }
  saves: { spell_magic: 2, horror_factor: 3 }
skills:
  hand_to_hand: { costs: { martial_arts: 1 } }
  occ_skills:
    - { name: "Language: Arkhon", base: 98, per_level: 0, note: "Language and Literacy: Arkhon (98%): the speaking half." }
    - { name: "Literacy: Native Language", base: 98, per_level: 0, note: "The literacy half of Language and Literacy: Arkhon (98%)." }
    - { choose: 2, from: ["Language: Other"], bonus: 15, note: "Language: two of choice (+15%). Taken once per language - the picker asks which." }
    - { name: "Computer Operation", base: 55, per_level: 5, note: "+15%" }
    - { name: "Radio: Basic", base: 60, per_level: 5, note: "+15%" }
    - { name: "Running", base: 0, per_level: 0 }
    - { choose: 1, categories: ["Pilot"], bonus: 10, note: "Pilot: one of choice (+10%)." }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { name: "W.P. Energy Pistol", base: 0, per_level: 0 }
    - { choose: 1, from: ["W.P. Sword", "W.P. Knife"], note: "W.P. Sword or W.P. Knife (choose one)." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Can be changed to Hand to Hand: Martial Arts at the cost of one other skill." }
  occ_related_skills:
    count: 8
    categories:
      - { name: "Communications", bonus: 10 }
      - "Domestic"
      - { name: "Electrical", bonus: 5 }
      - { name: "Espionage", bonus: 5 }
      - { name: "Mechanical", bonus: 5 }
      - { name: "Medical", note: "+5% on Paramedic only." }
      - { name: "Military", bonus: 10 }
      - "Physical"
      - { name: "Pilot", bonus: 5 }
      - { name: "Pilot Related", bonus: 5 }
      - "Rogue"
      - { name: "Science", bonus: 5 }
      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Every category is Any. Medical carries +5% on Paramedic only: add it to that skill by hand."
    schedule:
      - { level: 3, count: 1 }
      - { level: 5, count: 1 }
      - { level: 8, count: 1 }
      - { level: 11, count: 1 }
      - { level: 14, count: 1 }
  secondary_skills:
    count: 5
    categories:
      - "Communications"
      - "Domestic"
      - "Electrical"
      - "Espionage"
      - "Mechanical"
      - "Medical"
      - "Military"
      - "Physical"
      - "Pilot"
      - "Pilot Related"
      - "Rogue"
      - "Science"
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
equipment_starting:
  - { item_id: "tb-prime-tri-beam-energy-rifle", qty: 1, note: "Arkhon energy rifle of choice; the TB-Prime is the book''s one tri-beam rifle (printed 80-81)." }
  - { choose: 1, label: "Arkhon energy pistol of choice", qty: 1, from: ["tb-3-tri-beam-energy-pistol", "tb-9-auto-pistol"], note: "The book''s two tri-beam pistols (printed 80)." }
  - { item_id: "arkhon-body-armor", qty: 1, note: "A suit of combat armor." }
  - { item_id: "walkie-talkie", qty: 1, note: "The book says a communicator." }
  - { item_id: "survival-kit", qty: 1 }
  - { item_id: "survival-knife", qty: 1 }
  - { choose: 1, label: "archaic or modern weapon of choice", qty: 1, from: ["tri-blade-energy-sword", "vibro-knife", "vibro-sword", "broadsword", "fr-5-flechette-rifle"], note: "The book says an archaic or modern weapon of choice without enumerating; the Arkhon tri-blade and flechette rifle lead the catalog set." }
natural_abilities:
  - { name: "Bite and Claws", description: "Bite does 2D6 S.D.C.; claws add 1D6 S.D.C. to hand to hand punches and kicks." }
  - { name: "Senses", description: "Roughly equivalent to a human''s; no special senses." }
  - { name: "Psionic Potential", description: "A higher incidence of psionics than humans. The race''s own percentile table is the Psionics pick under special abilities, taken in place of the standard psionics roll." }
  - { name: "Disbelief in Magic", description: "Their culture abandoned magic millennia ago and still does not believe in it, which is where the +2 save vs magic comes from. Some Arkhons may learn magic anyway." }
  - { name: "Life Span", description: "200 years with advanced medical technology, half that without; some wealthy Arkhons have added as much as 500 years with chemical treatments, cloned organs and anti-aging techniques." }
special_abilities:
  - { choose: 1, from: ["Psionics (01-18): Major Psionic", "Psionics (19-50): Minor Psionic", "Psionics (51-56): Master Psionic", "Psionics (57-00): None"], note: "Psionic Powers (printed 72): roll percentile dice or pick one. The book prints the first three bands only; 57-00 is what they leave." }
  - name: "Psionics (01-18): Major Psionic"
    description: "Percentile roll 01-18. A major psionic. The entry prints no power count, no categories and no I.S.P. for the tier, so take them from the psionics rules in use and record powers and I.S.P. by hand."
    psionics: { type: "major" }
  - name: "Psionics (19-50): Minor Psionic"
    description: "Percentile roll 19-50. A minor psionic. The entry prints no power count, no categories and no I.S.P. for the tier, so take them from the psionics rules in use and record powers and I.S.P. by hand."
    psionics: { type: "minor" }
  - name: "Psionics (51-56): Master Psionic"
    description: "Percentile roll 51-56. A master psionic. The book says these become Arkhon ESP Specialists, so choosing this asks for that O.C.C. as the paired occupation, and its page states the powers and I.S.P. The band is stored as printed, six points wide, although the next sentence of the entry calls master psionics a tiny percentage."
    psionics: { type: "master" }
    occ_options: ["arkhon-esp-specialist"]
  - name: "Psionics (57-00): None"
    description: "Percentile roll 57-00. No psionic powers. The book prints no band for this result: it is the remainder after the three printed bands (01-56). This table stands in place of the standard psionics roll."
restrictions:
  - "Credits: the 1D6x1000 are Arkhon credits, useful only within the Freehold. A renegade who has lived outside the Freehold has 2D6x100 standard credits instead."
side_effects: "HUMIDITY: at 60% humidity or higher the character is weak and easily exhausted: -4 to initiative, -2 to all combat actions, and one fewer attack per melee. Arkhons avoid jungles unless wearing environmental armor. Otherwise they tolerate heat and cold about as well as humans, and are better adapted than humans to the thin air of high mountains."
extraction_notes: "WB9 South America 2 printed 71-73 (cache p071-p073, page_offset 0); the stat block starts at the foot of printed 71, the attributes, pools, bonuses and psionics are printed 72, the skills, equipment and money printed 73. Printed 72 checked against a 200 dpi render; OCR and render agree. || XP: the Arkhon ladder on printed 192, read off a render, as briefed; lower bounds stored as printed. A race carries a ladder only when its book prints one for it, and this one does. In a pairing the occupation''s ladder wins. || POOLS: S.D.C. 2D6x10 in addition to skill bonuses - stored as a pool bonus (bonuses.pools.sdc), never sdc_base, because it adds to whatever an occupation grants. Hit points are printed as standard, same as humans; stored as the human formula P.E. + 1D6 per level. P.P.E. is printed as standard (same as humans) and is not stated. M.D.C.: by armor only. men_of_arms: false, as for every race. Horror Factor: none, not stored. || ATTRIBUTES: I.Q. 2D6+6, M.E. 3D6, M.A. 3D6, P.S. 2D6+12, P.P. 2D6+12, P.E. 3D6+4, P.B. 3D6+6, Spd 3D6+10, as printed. || BONUSES: +1 initiative, +2 roll with impact, +2 pull punch, +2 save vs magic (spell_magic), +3 save vs Horror Factor, all unconditional. || PSIONICS: the book prints its own odds (01-18 major, 19-50 minor, 51-56 master, a tiny percentage master). Stored since 2026-10-03 as a banded choose-1 group in special_abilities: one option per printed band and a 57-00 None, which the book does not print and which is the remainder of the three printed bands. No class-level psionics block; the major and minor options carry a type only, because the page prints no powers or I.S.P. for them, and the master option names the ESP Specialist in occ_options. The master result points at the Arkhon ESP Specialist O.C.C., which states its own master block. Note the printed ranges are odd - 51-56 is six percent for master, which the next sentence calls tiny - and are transcribed as printed. || MAGIC: none by culture, but not forbidden (some Arkhons might learn it); not stored as a restriction. || SKILLS: the book prints R.C.C. Skills plus R.C.C. Related and Secondary lists, so the race carries all three; an occupation''s related and secondary allowances replace these in a pairing. Language and Literacy: Arkhon (98%) -> Language: Arkhon 98 and Literacy: Native Language 98, both flat, the convention this book''s Inca Sun Priest uses for Quechua. Language two of choice +15 as two Language: Other picks. Computer Operations -> Computer Operation 40+15 = 55. Basic Radio -> Radio: Basic 45+15 = 60. Running. Pilot one of choice +10 as a Pilot choice group with bonus 10. W.P. Energy Rifle, W.P. Energy Pistol, W.P. Sword or Knife as a two-way choice. Hand to Hand: Expert, to Martial Arts for one other skill (costs martial_arts 1). || RELATED: 8, plus one at levels 3, 5, 8, 11 and 14. Every category Any: Communications +10, Electrical +5, Espionage +5, Mechanical +5, Military +10, Pilot +5, Pilot Related +5, Science +5, Technical +10; Domestic, Physical, Rogue, W.P. and Wilderness with none. Medical prints +5% on paramedic only; a category bonus applies to every pick in it, so no bonus is stored and the +5 is a note. Secondary: 5, same categories, no bonuses. || EQUIPMENT: energy rifle of choice -> TB-Prime (the only Arkhon tri-beam rifle; the M-100 is crew served); energy pistol of choice -> TB-3 or TB-9; a suit of combat armor -> arkhon-body-armor; communicator -> walkie-talkie (judgement, as the Inca Warrior''s radio); survival kit; survival knife; an archaic or modern weapon of choice -> a choice set led by the Arkhon Tri-Blade and FR-5. Power armor, special weapons and vehicles assigned for missions are not starting gear. || MONEY: 1D6x1000 Arkhon credits stored; the renegade alternative of 2D6x100 standard credits and the Freehold-only currency are a restriction line. In a pairing the race''s starting_money wins over an occupation''s, except the Arkhon Spectral Hunter''s and ESP Specialist''s: both are Arkhon-only, both print their own money, and both carry overrides_race: [starting_money] (BOOK-INGEST-AUDIT F111, taken 2026-09-27), so they start with 2D4x1000 and 2D6x1000. || Alliances (the Fallam, human and D-Bee servants) and alignment (any; 65% anarchist or evil) are lore."
---

## Lore

Arkhons are slender alien humanoids with a blend of feline and reptilian
features: yellow-grey hairless skin, human-like eyes, large pointed ears and a
slightly crouched stance. They tend to be wiry rather than bulky, yet stronger
than the average human. Soldiers wear red, spiked armor built around a single
central eye; civilians dress in every style, and some have taken to Earth
fashions.

Their homeworld resembled Earth, so they breathe its air and thrive in the
high, thin air of the mountains, but humid places sap them badly. Only the
bionic Spectral Hunters patrol the jungles as a matter of course.

Arkhon culture prizes success above everything: winning matters however it is
achieved, a loser deserved to lose, and bad luck is treated as a personal
flaw. Obedience to superiors is the other pillar - a failed leader is removed
by his equals, never questioned by those below him. The exiled Tlo-Arkhon clan,
beaten at home and battered on arrival, is desperate to redeem itself, and its
code excuses lies and betrayal so long as the Arkhons win.

## GM Notes

Alignment: any; about 65% of the invaders are anarchist or evil, usually
miscreant or aberrant. Good-aligned Arkhons are often shunned, and a few have
deserted to found small settlements in the far south.
',
       updated_at = datetime('now')
 WHERE class_id = 'arkhon'
   AND instr(markdown, 'the book''s odds are recorded in natural_abilities') > 0
   AND length(markdown) = 10628;

-- == amaki-stone-man ==
UPDATE imported_classes
   SET markdown = '---
id: amaki-stone-man
men_of_arms: false
name: Amaki Stone-Man
system: rifts
source_book: Rifts World Book 9: South America 2 p.154-155
category: rcc
tags: []
xp_table: [0, 2121, 4281, 8481, 16961, 24961, 34961, 49961, 69961, 94961, 129961, 179961, 229961, 279961, 329961]
attribute_dice:
  IQ: "3d6"
  ME: "3d6+2"
  MA: "3d6+2"
  PS: "2d6+12"
  PP: "3d4+10"
  PE: "3d6+6"
  PB: "3d6+2"
  Spd: "3d6"
hit_points_base: "P.E. x10 plus 4d6 per level of experience"
ppe_base: "4d6"
horror_factor: 6
bonuses:
  pools: { sdc: "3d6x100" }
  combat: { initiative: 1, parry: 1, dodge: 1, roll: 2 }
  saves: { horror_factor: 2 }
skills:
  occ_skills:
    - { name: "Language: Amaki", base: 98, per_level: 0, note: "Amaki (98%); known by about 95% of adult Amaki on Rifts Earth." }
    - { name: "Language: Spanish", base: 70, per_level: 5, note: "Spanish (+20%)." }
    - { name: "W.P. Sword", base: 0, per_level: 0, note: "Almost all adult Amaki; one of the two skills the Amaki blast-sword needs." }
    - { name: "W.P. Energy Pistol", base: 0, per_level: 0, note: "Almost all adult Amaki; the other skill the blast-sword needs." }
    - { name: "Dance", base: 45, per_level: 5, note: "+15%; most Amaki are great dancers." }
    - { choose: 1, from: ["Play Musical Instrument", "Sing"], bonus: 10, note: "One musical instrument or singing (+10%)." }
natural_abilities:
  - { name: "Stone Skin", description: "Natural Armor Rating (A.R.) 16. Not an M.D.C. being, but 3D6x100 S.D.C. and P.E. x10 hit points (1 M.D.C. equals 100 S.D.C.) let an Amaki survive minor Mega-Damage and shrug off small arms." }
  - { name: "Damage Resistance", description: "All non-magical attacks, physical and energy alike, do only half damage. Magic and psionic attacks do full damage." }
  - { name: "Nightvision", description: "1000 feet (305 m)." }
  - { name: "Keen Senses", description: "Hearing and vision slightly above the best human levels." }
  - { name: "Rapid Healing", description: "Heals damage five times as fast as a human." }
  - { name: "Stone Fists", description: "Restrained punch 1D4 S.D.C., full strength punch 4D6 S.D.C. (both plus P.S. bonus), power punch 1D6 M.D. (counts as two attacks)." }
  - { name: "Size and Life Span", description: "5 to 7 feet (1.5 to 2.1 m) tall, 120 to 200 lbs (54 to 90 kg); average life span 300 years." }
special_abilities:
  - { choose: 1, from: ["Psionics (01-20): Major Psionic", "Psionics (21-50): Minor Psionic", "Psionics (51-64): Master Psionic", "Psionics (65-00): None"], note: "Psionic Powers (printed 155): roll percentile dice or pick one." }
  - name: "Psionics (01-20): Major Psionic"
    description: "Percentile roll 01-20. A major psionic. The entry prints no power count, no categories and no I.S.P. for the tier, so take them from the psionics rules in use and record powers and I.S.P. by hand."
    psionics: { type: "major" }
  - name: "Psionics (21-50): Minor Psionic"
    description: "Percentile roll 21-50. A minor psionic. The entry prints no power count, no categories and no I.S.P. for the tier, so take them from the psionics rules in use and record powers and I.S.P. by hand."
    psionics: { type: "minor" }
  - name: "Psionics (51-64): Master Psionic"
    description: "Percentile roll 51-64. A master psionic. The entry prints no powers or I.S.P. for the tier; its Psionic O.C.C.s line says many Amaki are master psionics, with mind melters the commonest (50%) and duelists and bursters besides, so a master normally takes one of those O.C.C.s, whose page states the powers and I.S.P."
    psionics: { type: "master" }
  - name: "Psionics (65-00): None"
    description: "Percentile roll 65-00. No psionic powers. This table stands in place of the standard psionics roll."
restrictions:
  - "Psionics: the Amaki roll on their own table, not the standard one - 01-20 Major, 21-50 Minor, 51-64 Master, 65-00 none. It is the Psionics pick under special abilities; hold the race to it rather than to the standard roll."
  - "Magic: none of the race''s own; an Amaki magician gets magic from a magical O.C.C."
side_effects: "Vulnerabilities/Penalties: none, as printed. Typical NPC is level 1D4+1."
extraction_notes: "Rifts World Book 9: South America 2 printed 154-155 (cache p154-p155, page_offset 0). The heading and first paragraph are at the foot of 154; the whole stat block is on 155. OCR on 155 reads 8.D.C. for S.D.C. and [1.Q. for I.Q.; the numbers were taken from the OCR as briefed. No amaki-stone-man class was in production on 2026-09-25. || A RACE THAT TAKES AN O.C.C.: the R.C.C. prints only a racial skill paragraph (''these are in addition to O.C.C. skills''), no related or secondary lists, no Hand to Hand, no money, no cybernetics line and ''Weapons and Equipment: varies with O.C.C.'', and names its common O.C.C.s (Duelist, Gizmoteer, and a long list of core and Mercenaries O.C.C.s). So it grants no related or secondary skills, which is what makes needsOccupation() mark it normally paired; no occ_restrictions is stored because the book names no forbidden occupation. No equipment_starting and no starting_money: equipment and money sum or fall through across a pairing, and the race issues none (the book''s Amaki blast-sword, blast rifle, combat armor and TW psi-blade rows exist and are issued by the Duelist and Gizmoteer, not by the race). || XP: the Amaki Stone Man ladder on printed 192, as briefed (the same figures as the Arkhon ladder). The book prints a ladder for the race; it applies when the race is paired with an occupation that states none, which is most Rifts O.C.C.s, so it is stored. || POOLS: 3D6x100 S.D.C. is a racial S.D.C. and stored as a POOL BONUS (bonuses.pools.sdc), never sdc_base, so an occupation''s S.D.C. adds to it. Hit Points P.E. x10 plus 4D6 per level as printed. P.P.E. 4D6. Horror Factor 6. M.D.C. none; the ''survives minor M.D.'' note and A.R. 16 are natural_abilities text, since no class key carries a natural A.R. men_of_arms: false, as for every race. || ATTRIBUTES as printed: I.Q. 3D6, M.E. 3D6+2, M.A. 3D6+2, P.S. 2D6+12, P.P. 3D4+10, P.E. 3D6+6, P.B. 3D6+2, Spd 3D6. || BONUSES: +1 initiative, +1 parry and dodge, +2 roll with impact, +2 save vs horror factor, unconditional. The half damage from non-magical attacks is a natural ability, not a number. || PSIONICS: the book gives a race-specific percentile table (20% major, 30% minor, 14% master, 36% none). Stored since 2026-10-03 as a banded choose-1 group in special_abilities, one option per printed band. No class-level psionics block is stored and psionics_allowed is left unset; the tiers carry a type only, because the page prints no powers or I.S.P. for them. A psychic O.C.C. states its own block and wins. || SKILLS: Amaki (98%) as Language: Amaki 98 (the language only; the book says Amaki, not language and literacy); Spanish (+20%) as Language: Spanish 50+20; W.P. Sword and W.P. Energy Pistol; dancing (+15%) as Dance 30+15; one musical instrument or singing (+10%) as a choose 1 of Play Musical Instrument or Sing with bonus 10. The book says 95% of adult Amaki know these; stored as known, the percentage in the notes. || Alignment (any, leaning good and selfish), alliances with True Atlanteans, and the O.C.C. distribution lists are lore and GM notes."
---

## Lore

The Amaki are humanoids whose skin looks like polished marble: cool, smooth,
hairless and as hard as stone, yet flexible enough to move like flesh. Most
males grow a stony chin-crest shaped like the carved beards of ancient
Babylonian statues, which is where the humans of South America got the name
"Babylonians" for them. Their natural colour is grey or black, but Amaki love
to paint themselves in every shade and to dress extravagantly.

They came through the Rifts about a century after the Cataclysm, colonists
from a crowded but prosperous homeworld ruled by guild Houses, and built New
Babylon in partnership with the human survivors. They find humans the most
Amaki-like people they have ever met; friendships and even marriages between
the two are common.

## GM Notes

An Amaki is tough enough to shrug off small arms and survive light
Mega-Damage, and non-magical attacks do only half damage to one. Common
occupations are the Duelist and Gizmoteer, plus headhunters, wilderness
scouts, rogue scholars, operators, city rats and the Coalition-style military
O.C.C.s; their magicians are mostly techno-wizards, and their psychics mostly
mind melters.
',
       updated_at = datetime('now')
 WHERE class_id = 'amaki-stone-man'
   AND instr(markdown, 'cannot reach Master') > 0
   AND length(markdown) = 7027;

-- == felinoid ==
UPDATE imported_classes
   SET markdown = '---
id: felinoid
name: Felinoid (Jaguar Mutant)
system: rifts
source_book: Rifts World Book 6: South America p.107-109
category: rcc
tags: [psionics]
men_of_arms: false
horror_factor: 9
xp_table: [0, 1881, 3781, 7261, 14201, 21001, 31001, 41001, 52001, 72001, 102001, 137001, 187001, 237001, 287001]
occ_restrictions:
  except: ["coalition-grunt", "coalition-juicer", "coalition-samas-pilot", "coalition-technical-officer", "ngr-infantry-soldier", "ngr-power-armor-commando", "ngr-robot-combat-pilot", "ngr-robot-soldier", "ngr-cyborg-soldier", "fq-cyborg-soldier", "fq-cyborg-dervish", "fq-cyborg-imprimer", "fq-cyborg-leviathan", "fq-cyborg-slasher", "combat-cyborg", "caf-trooper", "fq-side-kick-rpa", "robot-pilot", "glitter-boy", "fq-descended-glitter-boy-pilot", "fq-glitter-girl-pilot", "juicer", "delphi-juicer", "dragon-juicer", "euro-juicer", "hyperion-juicer", "juicer-assassin", "juicer-gladiator", "juicer-scout", "mega-juicer", "phaeton-juicer", "titan-juicer"]
  note: "Any O.C.C. except Coalition or high-tech soldiers, power armor pilots, Glitter Boy pilots or Juicers. Shifters, Necromancers, Witches and Techno-Wizards are allowed but rare. Over 70% of city felinoids follow civilian occupations; the adventurers'' percentages are in the Lore."
attribute_dice:
  IQ: "3d6"
  ME: "3d6+4"
  MA: "3d6"
  PS: "4d6+4"
  PP: "4d6"
  PE: "4d6"
  PB: "3d6"
  Spd: "5d6"
hit_points_base: "P.E. + 1d6 per level"
bonuses:
  pools: { sdc: "1d6x10" }
  combat: { initiative: 1 }
natural_abilities:
  - { name: "Nightvision", description: "200 feet (61 m)." }
  - { name: "Keen Senses", description: "Excellent hearing and sense of smell." }
  - { name: "Enhanced Strength and Reflexes", description: "Stronger, faster and tougher than a human, but not supernatural." }
  - { name: "Retractable Claws", description: "Add 1D6 S.D.C. damage to hand to hand attacks." }
  - { name: "Fangs", description: "A bite inflicts 1D6 S.D.C." }
  - { name: "Feline Agility", description: "+10% to the Climbing and Acrobatics skills when the character has them from an O.C.C., and +3 feet (0.9 m) to all leaps. Not added automatically; add the +10% to those skills by hand." }
  - { name: "Cat-like Instincts", description: "Personality is almost completely human, with a few feline habits: daytime naps, pouncing on moving objects, a love of hunting, and purring when happy." }
special_abilities:
  - { choose: 1, from: ["Psionics: Eight Sensitive Powers", "Psionics: Eight Physical Powers", "Psionics: Eight Healing Powers", "Psionics: Six Mixed Powers"] }
  - name: "Psionics: Eight Sensitive Powers"
    description: "All felinoids are major psionics. This option takes all eight powers from the Sensitive category."
    psionics:
      type: "major"
      isp_base: "M.E. attribute number plus 1d4x10, +1d6+1 per level of experience"
      powers_starting: 8
      categories_allowed: ["Sensitive"]
  - name: "Psionics: Eight Physical Powers"
    description: "All felinoids are major psionics. This option takes all eight powers from the Physical category."
    psionics:
      type: "major"
      isp_base: "M.E. attribute number plus 1d4x10, +1d6+1 per level of experience"
      powers_starting: 8
      categories_allowed: ["Physical"]
  - name: "Psionics: Eight Healing Powers"
    description: "All felinoids are major psionics. This option takes all eight powers from the Healer category."
    psionics:
      type: "major"
      isp_base: "M.E. attribute number plus 1d4x10, +1d6+1 per level of experience"
      powers_starting: 8
      categories_allowed: ["Healing"]
  - name: "Psionics: Six Mixed Powers"
    description: "All felinoids are major psionics. This option takes six powers in any mix of the Sensitive, Physical and Healer categories."
    psionics:
      type: "major"
      isp_base: "M.E. attribute number plus 1d4x10, +1d6+1 per level of experience"
      powers_starting: 6
      categories_allowed: ["Sensitive", "Physical", "Healing"]
  - { choose: 1, from: ["Strain (01-75): Jaguar", "Strain (76-82): African Lion", "Strain (83-87): African Leopard", "Strain (88-92): Mountain Lion, Puma or Cougar", "Strain (93-95): Tiger", "Strain (96-98): Ocelot, Serval or Caracal", "Strain (99-00): Other"], note: "Sub-strain (printed 109): the book prints a share of the race for each strain, not a roll. The bands are those shares laid end to end in printed order, so roll percentile dice or pick one." }
  - name: "Strain (01-75): Jaguar"
    description: "Roll 01-75 or choose. The book gives the jaguar 75% of all felinoids; the band is derived from that printed share. Leopard-like spots on yellow or light brown fur, five to six feet tall. The class''s attributes are the jaguar''s, so nothing changes. Horror Factor 9."
  - name: "Strain (76-82): African Lion"
    description: "Roll 76-82 or choose. The book gives the African lion 7%; the band is derived from that printed share. The second largest strain after the tiger. Applied: +2D6 P.S., +2D6 Spd. Not applied, so do it by hand: reduce I.Q. by 1D4, and Horror Factor is 10 as one of the larger cats."
    bonuses: { attributes: { PS: "2d6", Spd: "2d6" } }
  - name: "Strain (83-87): African Leopard"
    description: "Roll 83-87 or choose. The book gives the African leopard 5%; the band is derived from that printed share. Applied: +1D6 P.P., +1D6 Spd. Not applied, so do it by hand: reduce M.E. by 1D6, and Horror Factor is 10 as one of the larger cats."
    bonuses: { attributes: { PP: "1d6", Spd: "1d6" } }
  - name: "Strain (88-92): Mountain Lion, Puma or Cougar"
    description: "Roll 88-92 or choose. The book gives the North American mountain lion, puma or cougar 5%; the band is derived from that printed share. Applied: +1D6 P.P., +1D6 P.E. Not applied, so do it by hand: reduce M.A. by 1D4, and Horror Factor is 10 as one of the larger cats."
    bonuses: { attributes: { PP: "1d6", PE: "1d6" } }
  - name: "Strain (93-95): Tiger"
    description: "Roll 93-95 or choose. The book gives the tiger 3%; the band is derived from that printed share. The largest of the cats, 7 to 8 feet (2.1 to 2.4 m). Applied: +2D6 P.S., +2D6 P.E. Not applied, so do it by hand: reduce Spd by 1D6, and Horror Factor is 10 as one of the larger cats."
    bonuses: { attributes: { PS: "2d6", PE: "2d6" } }
  - name: "Strain (96-98): Ocelot, Serval or Caracal"
    description: "Roll 96-98 or choose. The book gives the small South American cats (ocelot, serval and caracal, the lynx family) 3%; the band is derived from that printed share. Rarely over 5 feet (1.5 m). Same stats as the jaguar, except: reduce M.E., P.S. and Spd by 1D6 each, by hand - nothing is applied. Horror Factor 9."
  - name: "Strain (99-00): Other"
    description: "Roll 99-00 or choose. The book gives 2% to other strains and names neither an animal nor a modifier for them; the band is derived from that printed share. Nothing is applied: the G.M. decides the animal and any changes."
restrictions:
  - "Alignment: any."
  - "Magic: none, unless a magic O.C.C. is taken."
  - "Cybernetics: starts with none. There are no cybernetic facilities in Omagua, and most felinoids disdain cybernetic, bionic, chemical and bio-wizard enhancements, even in an O.C.C. that would normally allow them."
  - "M.D.C.: by armor or magic only."
  - "Horror Factor 10 for the larger mutant cats (lion, leopard, puma, tiger); 9 for the jaguar."
side_effects: "Size: 5 to 7 feet (1.5 to 2.1 m) tall; jaguars 5 to 6 feet, the larger strains 6.5 to 7.5 feet. Weight: 140 to 220 lbs (63 to 99 kg). Equipment and money come from the O.C.C."
extraction_notes: |
  - Rifts World Book 6: South America printed 107-109 (cache p108-p110).
    Printed 108 (cache p109) is a full-page illustration with no text.
    Printed 109 is on the substituted-digit list: the page was rendered
    and every number read off the ink (the text layer''s "lD4X10" is 1D4x10,
    "1J34" is 1D4, "(0/9 m)" is printed as 0/9 and read as 0.9 m).
  - The "Mutant Cat R.C.C." heading on printed 107 is a pointer to other
    books (Heroes Unlimited, TMNT, Vampire Kingdoms), not a class; not
    imported.
  - No felinoid class and no class named Felinoid was in production
    (checked --remote 2026-09-25).
  - men_of_arms false: a race. "S.D.C.: 1D6x10 plus O.C.C. and skill
    bonuses" is a racial pool bonus (bonuses.pools.sdc "1d6x10"), not
    sdc_base. Hit points are standard, P.E. + 1D6 per level. M.D.C. by
    armor or magic only; none stored.
  - xp_table from the "Sailor & Felinoid Mutant" ladder, printed 168
    (cache p169), lower bounds 0 / 1,881 / 3,781 / 7,261 / 14,201 / 21,001 /
    31,001 / 41,001 / 52,001 / 72,001 / 102,001 / 137,001 / 187,001 /
    237,001 / 287,001; identical to the sailor class''s stored xp_table.
    In a pairing the O.C.C.''s ladder wins where it states one.
  - Attributes as printed: I.Q. 3D6, M.E. 3D6+4, M.A. 3D6, P.S. 4D6+4,
    P.P. 4D6, P.E. 4D6, P.B. 3D6, Spd 5D6.
  - Sub-strains (lion 7%: +2D6 P.S. and Spd, -1D4 I.Q.; leopard 5%: +1D6
    P.P. and Spd, -1D6 M.E.; puma 5%: +1D6 P.P. and P.E., -1D4 M.A.;
    tiger 3%: +2D6 P.S. and P.E., -1D6 Spd; ocelot/serval/caracal 3%:
    -1D6 M.E., P.S. and Spd; 2% other; jaguar 75%) are NOT variants: each
    adds or subtracts a second die, which a single attribute dice string
    cannot state. Since 2026-10-03 they are a second choose-1 ability group,
    Strain, whose bands are the printed shares laid end to end in printed
    order (jaguar 01-75, lion 76-82, leopard 83-87, puma 88-92, tiger 93-95,
    small cats 96-98, other 99-00); the book prints shares, not bands. Each
    option carries its ADDED dice as attribute bonuses. The reductions are
    prose on the option, because a bonus takes no subtracted die, and so is
    the larger cats'' Horror Factor 10, because an ability cannot restate
    horror_factor.
    Horror Factor 9 is stored; 10 for the larger cats is a restriction line.
  - Bonuses: +1 initiative stored. +10% to Climbing and Acrobatics is a
    bonus to skills the R.C.C. does not grant (they come from the O.C.C.)
    and is a natural ability line; +3 ft to leaps, claws +1D6 S.D.C. and
    a 1D6 S.D.C. bite are prose.
  - Psionics: major psionic, "eight powers from one category or six from
    any of the three" (Sensitive, Physical, Healer - catalog Healing). The
    either/or is stored as one ability choice of four, each carrying its
    own psionics block (the Amazon''s pattern from this book), with no
    class-level psionics block. I.S.P. M.E. + 1D4x10 + 1D6+1 per level, on
    each option. No further powers with level are printed; no schedule.
  - Magic: none unless a magic O.C.C.; nothing stored.
  - O.C.C.s: "any except Coalition/High tech soldiers, power armor pilots,
    glitter boy pilots or juicers", stored as occ_restrictions.except.
    Decision on the vague "high tech soldiers": the Coalition O.C.C.s
    (grunt, SAMAS pilot, technical officer, Coalition Juicer), the NGR
    combat O.C.C.s (infantry, power armor commando, robot combat pilot,
    robot soldier, cyborg soldier), the Free Quebec cyborg soldiers,
    the Combat Cyborg and the CAF Trooper. Power armor pilots: SAMAS,
    Side Kick RPA, NGR power armor commando and the Robot Pilot (RUE''s
    robot and power armor pilot). Glitter Boy pilots: glitter-boy and the
    two Quebec GB pilot O.C.C.s; the GB Reloader is not a pilot and is
    allowed. Juicers: every juicer O.C.C.; the Juicer Wannabe is not a
    Juicer and is allowed. Merc Soldier and Headhunter stay allowed (the
    book lists Headhunters/Mercenaries as 20% of adventurers), as do the
    Marine and Navy Seaman.
  - Equipment: "varies with the O.C.C."; the adventurer''s jungle kit and
    the fondness for blades are prose in the Lore. Money: varies with
    O.C.C.; none stored.
  - Skills: none. An R.C.C. grants no related or secondary skills and this
    one prints no R.C.C. skills.
---

## Lore

Where the Coalition''s geneticists spread their work across many animals, the Argentine Empire''s Achilles Project concentrated on one: the South American jaguar. The project rounded up thousands of the rare cats, nearly wiping out the wild species, and the best blend of jaguar and human DNA became the felinoids, a mutant strain able to breed true, with enhanced but not supernatural strength, speed and endurance, and some minor psionic ability.

After the flight to Omagua the felinoids became the city''s most numerous people and its backbone, supplying artisans, workers and merchants as well as warriors, leaders and magicians. Unlike their super-powered mutant cousins they think and feel almost entirely like humans, keeping only a few feline habits.

Three-quarters of felinoids are jaguars with leopard-like spots on yellow or light brown fur, standing 5 to 6 feet tall. Project Achilles also produced larger strains, typically 6.5 to 7.5 feet tall.

**Sub-strains (the Strain pick):** jaguar 75%. African lion 7%, second largest: +2D6 P.S. and Spd, -1D4 I.Q. African leopard 5%: +1D6 P.P. and Spd, -1D6 M.E. North American mountain lion / puma / cougar 5%: +1D6 P.P. and P.E., -1D4 M.A. Tiger 3%, the largest at 7 to 8 feet: +2D6 P.S. and P.E., -1D6 Spd. Small South American cats (ocelot, serval, caracal) 3%, rarely over 5 feet: jaguar stats with -1D6 M.E., P.S. and Spd. Other 2%. The larger cats have Horror Factor 10.

This entry covers only the felinoid mutants, not the Ra-men, werejaguars or other D-bee felines of Omagua. Felinoids are sometimes mistaken for the werejaguars ("Jaguar People") of the Yucatan and the Americas.

**Occupations:** over 70% of city felinoids follow civilian trades - merchant, artist, farmer, laborer, healer, scholar, teacher. Among adventurers: Wilderness Scout 21%; Headhunter, Mercenary or Special Forces 20%; Priest of the Divine Felines 8%; Mind Melter 6%; Mystic 5%; Ley Line Walker 5%; Warlock (any element) 5%; Biomancer 5%; Totem Warrior (Jaguar only) 5%; Sailor or Pirate 5%; City Rat 5%; other 10%. Shifters, Necromancers, Witches and Techno-Wizards are rare.

**Equipment:** set by the O.C.C. Omagua has only limited high technology from transdimensional trade, so the G.M. rules on what is available. Adventurers and scouts usually carry jungle gear - backpack, sleeping bag, canteen, machete and a sidearm. Most mutant cats are drawn to bladed weapons, especially Kittani plasma swords and vibro-blades; magic blades are rare and coveted.

## GM Notes

The Totem Warrior pick is Jaguar only by the book; the app does not narrow the totem choice. The Strain pick applies each sub-strain''s added dice; its reductions and the larger cats'' Horror Factor 10 are not applied automatically.
',
       updated_at = datetime('now')
 WHERE class_id = 'felinoid'
   AND instr(markdown, '**Sub-strains (apply by hand):**') > 0
   AND length(markdown) = 11154;

-- == larmac ==
UPDATE imported_classes
   SET markdown = '---
id: larmac
name: Larmac
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.118-120
category: rcc
tags: []
horror_factor: 12
attribute_dice:
  IQ: "2d6+3"
  ME: "2d6+3"
  MA: "2d6"
  PS: "4d6+16"
  PP: "3d6"
  PE: "3d6+5"
  PB: "1d6+3"
  Spd: "2d6+5"
mdc_base: "P.E. + 5d6, +2d4 per level"
ppe_base: "1d6"
bonuses:
  saves: { horror_factor: 5, toxins_poisons: 6, disease: 6, harmful_drugs: 6, other: [ { label: "vs illusions", bonus: -3 } ] }
skills:
  occ_skills:
    - { name: "Cook", base: 55, per_level: 5, note: "+20%" }
    - { name: "Land Navigation", base: 56, per_level: 4, note: "+20%" }
    - { name: "Wilderness Survival", base: 50, per_level: 5, note: "+20%" }
    - { name: "W.P. Blunt", base: 0, per_level: 0 }
natural_abilities:
  - name: "Mega-Damage hide"
    description: "M.D.C. 5D6 plus the P.E. attribute number, +2D4 per level of experience. Recovers M.D.C. at 2D6+3 per day. On an S.D.C. world: 6D6 plus P.E. Hit Points and 6D6 S.D.C. plus skill bonuses, natural A.R. 12. The thick hide and blubber let a Larmac cross a desert by day without heat exhaustion or dehydration and shrug off cold down to -40 degrees Fahrenheit."
  - name: "Robot Strength"
    description: "P.S. 4D6+16 is equivalent to Robot Strength; damage is by Robot P.S. or weapon."
  - name: "Nightvision and endurance"
    description: "Nightvision 300 feet (91.5 m). Can go a week without food and four days without water before feeling the effects."
special_abilities:
  - name: "Highly motivated"
    description: "When highly motivated or fighting for his own life, the Larmac gets +1 melee action/attack, +1 on initiative and +1 to parry or dodge. Otherwise he is -1 on initiative."
  - { choose: 1, from: ["Psionics (01-02): Master Psionic", "Psionics (03-07): Major Psionic", "Psionics (08-15): Minor Psionic", "Psionics (16-00): None"], note: "Psionics (printed 120): psychic abilities are rare among Larmac. Roll percentile dice or pick one." }
  - name: "Psionics (01-02): Master Psionic"
    description: "Percentile roll 01-02. A master psionic: the table says to select a psionic O.C.C., whose page states the powers and I.S.P. This is the table''s own exception to the occupation line that bars most psionic O.C.C.s."
    psionics: { type: "master" }
  - name: "Psionics (03-07): Major Psionic"
    description: "Percentile roll 03-07. A major psionic. The entry prints no power count, no categories and no I.S.P. for the tier, so take them from the psionics rules in use and record powers and I.S.P. by hand."
    psionics: { type: "major" }
  - name: "Psionics (08-15): Minor Psionic"
    description: "Percentile roll 08-15. A minor psionic. The entry prints no power count, no categories and no I.S.P. for the tier, so take them from the psionics rules in use and record powers and I.S.P. by hand."
    psionics: { type: "minor" }
  - name: "Psionics (16-00): None"
    description: "Percentile roll 16-00. No psionic powers, like most Larmac. This table stands in place of the standard psionics roll."
trackable_resources: []
restrictions:
  - "Alignment: any, but the majority are Unprincipled (30%), Anarchist (30%), Aberrant (10%) or Miscreant (20%)."
  - "Available O.C.C.s: typically one of Bandit, Thief, Gambler, Highway Man, Sailor, Pirate, Grunt (thug/muscleman), Saloon Bum, Barmaid (if female), Saddle Tramp, Stoolie or Vagabond; only the most ambitious become a Wilderness Scout, Trapper-Woodsman, Professional Gambler, Pecos Raider, Merc Soldier or Sheriff''s Deputy. Can NOT select most Men at Arms or psionic O.C.C.s, including the Mystic."
  - "Magic: none; too lazy to study it, though they love magic items."
  - "Cybernetics: most avoid them, but may take minor implants and bionic prosthetics to repair injuries; human systems must be modified and always look mechanical. Bio-Systems are out of the question."
side_effects: "-1 on initiative unless highly motivated, and always -3 to save vs illusions. Hand to hand skill is rarely better than Basic. Many are addicted to Psi-Cola (an estimated 25-30% by 109 P.A.)."
extraction_notes: "WB30 D-Bees of North America printed 118-120 (cache p119-p121), every number read off 200 dpi renders; the entry ends at its Note on printed 120, above the Loaks heading (the brief gave 118-119; the stat block continues onto 120). A reprint: the Note says it first appeared in Coalition Wars Three: Sorcerers'' Revenge; not held, imported from here. TAG LINE: the heading reads only Larmac R.C.C.; no Optional Player Character or NPC line is printed. || CATEGORY: a race that takes an O.C.C.; Standard Equipment and Money As per O.C.C. No xp_table: the entry says to use the experience table of the chosen O.C.C. || POOLS: Mega-Damage printed 5D6 plus P.E. attribute number and +2D4 M.D.C. per level, stored as mdc_base, so no men_of_arms line. The S.D.C.-world figures are ability text. P.P.E. 1D6. Horror Factor 12. || ATTRIBUTES as printed; P.S. 4D6+16 Robot Strength (ability text). || BONUSES: +5 save vs Horror Factor; +6 to save vs poison, disease and drugs (printed under Natural Abilities) as toxins_poisons, disease and harmful_drugs; -3 to save vs illusions as saves.other (always, printed under Vulnerabilities). The +1 attack, +1 initiative and +1 parry or dodge when highly motivated are conditional, and so is the -1 initiative unless highly motivated: both are prose. || SKILLS: Cook 35+20, Land Navigation 36+20, Wilderness Survival 30+20, W.P. Blunt, in addition to an O.C.C. || PSIONICS: percentile table, stored since 2026-10-03 as a banded choose-1 group of four options in special_abilities, one per printed band; no class-level block (most Larmac have none), and the tiers carry a type only because the page prints no powers or I.S.P. for them. || OCCUPATIONS: a typical list plus a vague bar on most Men at Arms and psionic O.C.C.s; not stored as occ_restrictions (judgement), kept as a restriction line. || NOT STORED: size 6 to 7 feet, weight 250 to 500 lbs, life span 5D6+90, the 40-70 M.D.C. patchwork armor most wear (no stats beyond M.D.C.), habitat, allies and enemies; GM Notes."
---

## Lore

The Larmac are big, beefy D-Bees who look like giant horned toads: rough,
blotchy tan or greenish gray skin, a pair of small horns on top of the head
and two more behind, ear holes, small eyes, a long muzzle and a mouth of
jagged teeth. For all that, they are mammals, and the males are hairy.

They are reasonably smart and very strong, and could be fearsome warriors,
but most are cheerfully lazy. A typical Larmac wants to eat, drink, party,
gamble and sleep, and does only as much work as that takes, which often
means scavenging, panhandling, petty crime, muscle work or simply sponging
off friends. They are hard to insult and slow to anger, but when one
finally gets up, expect a serious fight. Dangle the promise of a big score
or easy street, though, and a Larmac will work hard, stay awake for days
and fight to the death for it. Good-hearted ones are fiercely loyal
friends; the anarchist and evil ones will sell anyone out for a payday.

## GM Notes

The book prints the heading as Larmac R.C.C., with no player character
line. Also called Lard Butts, Lazy Lards and Lazy Lizards.

Size 6 to 7 feet (1.8 to 2.1 m). Weight 250 to 500 pounds (112.5 to 225
kg), looking 40% to 100% overweight. Life span 5D6+90 years; physical
maturity by 17. Females bear litters of 1D4+1 after a 12 month pregnancy.

Most wear patchwork homespun M.D.C. armor of 40 to 70 M.D.C. with no
environmental systems. They like blunt weapons, heavy weapons, energy
weapons and explosives.

Habitat: from the St. Louis and Detroit-Windsor Rifts across lower Canada,
the Pecos Empire and the central and eastern old United States, in cities,
slums and the ''Burbs. Many Tolkeen refugees among them have sobered up and
some joined the resistance.

Allies: humans, Floopers, D''norr Devilmen, Kraks and anyone easygoing.
Enemies: the Coalition States, the Federation of Magic, Greot Hunters and
Vanguard Brawlers; they dislike know-it-alls, driven go-getters, tyrants
and slavers.
',
       updated_at = datetime('now')
 WHERE class_id = 'larmac'
   AND instr(markdown, 'name: "Rare psionics"') > 0
   AND length(markdown) = 6763;

-- == mutant-rat ==
UPDATE imported_classes
   SET markdown = '---
id: mutant-rat
name: Mutant Rat
system: rifts
source_book: Rifts World Book 13: Lone Star p.85-88
category: rcc
tags: [stealth]
xp_table: [0, 1901, 3601, 7201, 14401, 24501, 35001, 45001, 65001, 85001, 115001, 145001, 185001, 250001, 310001]
attribute_dice:
  IQ: "2d6+6"
  ME: "2d6"
  MA: "2d6"
  PS: "3d6"
  PP: "2d6+8"
  PE: "3d6"
  PB: "2d6"
  Spd: "4d6+6"
hit_points_base: "P.E. + 1d6 per level"
sdc_base: "P.E. + 4d6"
ppe_base: "3d6"
bonuses:
  combat: { attacks: 1, initiative: 3, dodge: 1, pull_punch: 1, roll: 2 }
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 90, per_level: 0, note: "The book prints: speaks American at 90% efficiency." }
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Escape Artist", base: 50, per_level: 5, note: "+20%" }
    - { name: "Intelligence", base: 42, per_level: 4, note: "+10%" }
    - { name: "Pick Locks", base: 40, per_level: 5, note: "+10%" }
    - { name: "Pick Pockets", base: 35, per_level: 5, note: "+10%" }
    - { name: "Land Navigation", base: 56, per_level: 4, note: "+20%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { name: "Sniper", base: 0, per_level: 0 }
    - { name: "Climbing", base: 85, per_level: 5, note: "Natural ability: the book prints Climb 85%/80%." }
    - { name: "Swimming", base: 75, per_level: 5, note: "Natural ability: the book prints Swim 75%." }
    - { name: "Prowl", base: 60, per_level: 2, note: "Natural ability: the book prints Prowl 60% +2% per level of experience." }
    - { name: "W.P. Knife", base: 0, per_level: 0, note: "W.P. Knife (Vibro-Blade)." }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P.: one of choice." }
    - { name: "Hand to Hand: Assassin", base: 0, per_level: 0 }
  occ_related_skills:
    count: 4
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", bonus: 10 }
      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"] }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Military", bonus: 5 }
      - "Physical"
      - { name: "Pilot", only: ["Hover Craft (ground)", "Truck", "Boat: Sail Type", "Boat: Motor, Race & Hydrofoil"], bonus: 5 }
      - { name: "Rogue", except: ["Computer Hacking"], bonus: 10 }
      - { name: "Technical", except: ["Computer Operation", "Computer Programming"], bonus: 10 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 5 }
    note: "The book calls these other skills. Electrical: Basic Electronics only. Espionage +10%. Mechanical: Basic Mechanics and Automotive only. Medical: First Aid only. Military +5%. Pilot: Hovercraft, truck, sail and motorboats only (+5%). Pilot Related and Science: none. Rogue: any except Computer Hacking (+10%). Technical: any except Computer Operation and Programming (+10%). Wilderness +5%. Mutant rats in the service of the CS are never taught to read."
    schedule:
      - { level: 3, count: 1 }
      - { level: 6, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 6
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - "Espionage"
      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"] }
      - { name: "Medical", only: ["First Aid"] }
      - "Military"
      - "Physical"
      - { name: "Pilot", only: ["Hover Craft (ground)", "Truck", "Boat: Sail Type", "Boat: Motor, Race & Hydrofoil"] }
      - { name: "Rogue", except: ["Computer Hacking"] }
      - { name: "Technical", except: ["Computer Operation", "Computer Programming"] }
      - "Weapon Proficiencies"
      - "Wilderness"
    schedule:
      - { level: 2, count: 2 }
      - { level: 4, count: 2 }
      - { level: 8, count: 2 }
      - { level: 12, count: 2 }
equipment_starting:
  - { item_id: "dog-pack-dpm-riot-armor", qty: 1, note: "DPM riot armor. Full environmental suits are never available." }
  - { choose: 1, label: "tinted goggles or non-environmental helmet", qty: 1, from: ["tinted-goggles", "helmet"], note: "The helmet comes with or without a visor." }
  - { item_id: "walkie-talkie", qty: 1, note: "The book says a radio." }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "pocket-mirror", qty: 1 }
  - { item_id: "lightweight-rope", qty: 5, note: "100 ft (30.5 m) of lightweight rope; the catalog row is a 20 foot length." }
  - { item_id: "spike", qty: 4 }
  - { item_id: "small-hammer", qty: 1, note: "Four spikes and a hammer." }
  - { item_id: "portable-language-translator", qty: 1 }
  - { item_id: "survival-knife", qty: 1 }
  - { choose: 1, label: "pair of Vibro-Knives and/or Vibro-Claws", qty: 2, from: ["vibro-knife", "vibro-claws"], note: "The book prints a pair of Vibro-knives and/or Vibro-claws." }
  - { item_id: "c-12-laser-rifle", qty: 1, note: "C-12 assault laser rifle." }
  - { item_id: "knapsack", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "gas-mask", qty: 1 }
  - { item_id: "canteen", qty: 1 }
natural_abilities:
  - { name: "Size and Build", description: "About 5 feet (1.5 m) tall and 120 to 160 pounds (54 to 72 kg). No human looks: an animal''s appearance with only a vaguely human, bipedal shape and a rat-like head. 85% have human legs, arms and builds, 15% have animal-like legs; all have a long, hairless tail, and most are thin and wiry. The hands are fully articulated with an opposable thumb and long, sharp nails. Stands and walks upright. Armor Rating: not applicable. Reduce Spd by 30% when climbing. Human speech is typically full but a bit guttural, with hissing, growling and squealing when excited, angry or scared. Reaches full physical maturity within one year; life span an estimated 20 to 30 years." }
  - { name: "Climb, Swim and Prowl", description: "Climb 85%/80%, Swim 75%, Prowl 60% +2% per level of experience." }
  - { name: "Identify Scents", description: "44% +2% per level of experience." }
  - { name: "Track by Scent", description: "40% +2% per level of experience." }
  - { name: "Leap", description: "6 feet (1.8 m) up and 10 feet (3 m) across; increase lengthwise leaps by 30% with a running or swing start." }
  - { name: "Bite, Claws and Blows", description: "Bite 2D6 S.D.C./H.P.; claw strike (with fingernails) 2D4 S.D.C.; punch 1D6; kick 2D6." }
  - { name: "Tail", description: "The tail is not like prehensile feet." }
  - { name: "Double Jointed", description: "The rat is double jointed." }
  - { name: "Ambidextrous", description: "The rat is ambidextrous." }
  - { name: "Combat Bonuses", description: "+1 attack per melee round, +3 on initiative, +1 to dodge, +1 to pull punch and +2 to roll with fall or impact, plus any skill bonuses." }
  - { name: "Gnawing", description: "Rats and most rodents must chew on wood, concrete or metal to wear down their ever growing teeth; otherwise the fangs grow through the jaws." }
  - { name: "Psionics", description: "01-25%: the rat is a minor psionic and selects four powers from the Sensitive category. 26-00%: no psionics. The entry prints no I.S.P. figure." }
special_abilities:
  - { choose: 1, from: ["Psionics (01-25): Minor Psionic", "Psionics (26-00): None"], note: "Psionics (printed 88): roll percentile dice or pick one. The book prints the 01-25 band only; 26-00 is what it leaves." }
  - name: "Psionics (01-25): Minor Psionic"
    description: "Percentile roll 01-25. A minor psionic who selects four powers from the Sensitive category. The entry prints no I.S.P. figure, so the G.M. sets one and it is recorded by hand."
    psionics:
      type: "minor"
      powers_starting: 4
      categories_allowed: ["Sensitive"]
  - name: "Psionics (26-00): None"
    description: "Percentile roll 26-00. No psionic powers. The book prints no band for this result: it is the remainder after 01-25. This table stands in place of the standard psionics roll."
trackable_resources: []
restrictions:
  - "Psionics: only 25% of mutant rats (01-25%) are psionic; those are minor psionics with four Sensitive powers."
  - "Magic: none. The study of magic does not appeal to mutant rats, although they like magic items and weapons."
  - "Mutant rats in the service of the CS are never taught to read."
  - "Money: no starting sum is printed. The CS military provides all basic needs (a place to sleep, food, clothing, medical treatment, basic supplies and equipment, limited access to military facilities) and a token monthly salary of 50-70 credits for personal items. Rats do not get the freedoms, privileges or trust given to Dog Boys."
  - "Full environmental suits are never available. Equipment on assignment is basically the Dog Boys'', but heavy weapons, explosives, environmental armor, vehicles and special equipment are much more limited and restricted to mutants with at least two years of proven service."
  - "Cybernetics: none."
  - "Maximum rank: non-commissioned officer up to Sergeant."
  - "Escaped rats can learn a number of new secondary skills. A free-born rat can select any adventurer or men of arms O.C.C., but halves that O.C.C.''s selection of other skills."
  - "A player character who is not a CS agent (spy, infiltrator, scout, soldier) is a feral renegade (a runaway or deserter, treated as a dangerous traitor to be terminated) or the free-born offspring of runaways (destroyed whenever encountered). Any rat that goes AWOL or feral is hunted down and destroyed."
  - "Alignment: any, but anarchist (30%), miscreant (30%) and diabolic (30%) are the most common."
  - "R.C.C. requirements: none, other than being a relatively intelligent, loyal and obedient mutant (60% are female); substandard creations are destroyed."
extraction_notes: "WB13 Lone Star printed 85-88 (cache p086-p089, cache page = printed folio + 1). The Mutant Rodents heading and the Mutant Rats heading are in the right column of printed 85, after the end of the Monkey Boy Tech; the lore runs through 86 to the top of 87; the stat block is headed CS Mutant Rats on 87 and runs through the left column and the top of the right column of 88, ending at Maximum Rank, above the Mutant Bats heading. Every number was read off 170 dpi renders of cache p086-p089. || XP: the column headed Mutant Bat, Mutant Rat on the unnumbered Experience Tables page after printed 174 (cache p176), read off the render, lower bound of each band. || HEADING: CS Mutant Rats, under Mutant Rodents / Mutant Rats; an engineered mutant animal and a race. The Experience Tables index on printed 174 calls it Mutant Rat R.C.C. 85. || ATTRIBUTES as printed (Average Attribute Range, Typical Mutant Rat): I.Q. 2D6+6, M.E. 2D6, M.A. 2D6, P.S. 3D6, P.P. 2D6+8, P.E. 3D6, P.B. 2D6, Spd 4D6+6 running (reduce by 30% when climbing, text). || POOLS: Hit points P.E. plus 1D6 per level. S.D.C. is printed as ''P.E. attribute number plus 4D6 plus those gained from physical skills''. Stored as sdc_base ''P.E. + 4d6'' and NOT as bonuses.pools.sdc, the convention of the sibling Lone Star drafts for a printed formula that contains the P.E. number; because sdc_base is stated there is no men_of_arms line. P.P.E. 3D6 (Permanent P.P.E. Base). Armor Rating: not applicable. || BONUSES (natural abilities, top of printed 88): +1 attack per melee round, +3 initiative, +1 dodge, +1 pull punch, +2 roll with fall or impact; stored in bonuses.combat and restated as natural ability text. || NATURAL ABILITIES: Climb 85%/80% is stored as Climbing 85 with the catalog''s 5% per level (the book prints no per level figure for it; judgement, as the battle-cat draft), the second figure in the note. Swim 75% is Swimming 75 with the catalog''s 5% per level (none printed). Prowl 60% +2% per level is Prowl 60, per_level 2, as printed. None of the three is in the printed R.C.C. skill list; they are stored as skills because the natural abilities print them as percentages. Identify scents 44% +2% and track by scent 40% +2% are natural ability text. Damage as printed: bite 2D6 S.D.C./H.P., claw 2D4 S.D.C., punch 1D6, kick 2D6. || PSIONICS: ''01-25% are minor psionics; select four sensitive powers''. A percentile chance, so no class-level psionics block is stored; since 2026-10-03 it is a banded choose-1 group in special_abilities (01-25 minor with four Sensitive picks, and a 26-00 None the book leaves unprinted), and the line stays as natural ability text and a restriction. The entry prints no I.S.P. figure and none is stored. || SKILLS: Speaks American at 90% is Language: Native Tongue 90, per_level 0. Radio: Basic 45+10 = 55. Escape Artist 30+20 = 50. Intelligence 32+10 = 42. Pick Locks 30+10 = 40. Pick Pockets 25+10 = 35. Land Navigation 36+20 = 56. Wilderness Survival 30+10 = 40. Sniper, W.P. Knife (Vibro-Blade), W.P. Energy Rifle, one W.P. of choice. Hand to Hand: Assassin is granted outright; no change or price is printed, so no hand_to_hand block. || RELATED: four at level one, plus one at levels 3, 6, 9 and 12. Communications, Domestic, Physical and W.P. any; Electrical Basic Electronics only; Espionage any +10; Mechanical Basic Mechanics and Automotive only; Medical First Aid only; Military any +5; Pilot hovercraft, truck, sail and motorboats only +5 (Hover Craft (ground), Truck, Boat: Sail Type, Boat: Motor, Race & Hydrofoil); Pilot Related none; Rogue any except Computer Hacking +10; Science none; Technical any +10 except Computer Operation and Computer Programming; Wilderness any +5. ''Never taught to read'' applies to rats in CS service and is a restriction line, not an exclusion. SECONDARY: six at level one plus TWO at each of levels 2, 4, 8 and 12, same lists without bonuses. || FREE-BORN: the skills paragraph says escaped rats can learn new secondary skills and free-borns can select any adventurer or men of arms O.C.C. with the selection of other skills halved; stored as a restriction line. || EQUIPMENT: ''basically the same as Dog Boys, although full environmental suits are never available'', then the entry prints its own basic list, which is what is stored: DPM riot armor (dog-pack-dpm-riot-armor), tinted goggles or non-environmental helmet, radio as walkie-talkie, flashlight, pocket mirror, 100 ft of lightweight rope as five 20 ft lengths, four spikes and a hammer, portable language translator, survival knife, a pair of Vibro-knives and/or Vibro-claws as a choice at qty 2, C-12 assault laser rifle (c-12-laser-rifle), knapsack, backpack, utility belt, air filter, gas mask, canteen. The printed comb is a trivial personal item with no catalog row and is NOT stored. Equipment available upon assignment is a restriction line. || MONEY: the entry prints only a token monthly salary of 50-70 credits with all basic needs provided by the CS military, and no starting sum; it says rats do not have the Dog Boys'' freedoms, privileges or trust. No starting_money is stored; the salary is a restriction line. || OPTIONAL DOG BOY TABLES: the entry says nothing about them; nothing stored. || Identification coding (the Dog Boys'' dual I.D. system), typical missions (reconnaissance, undercover, extortion, espionage, intelligence), litter size (3D4 young), the desertion rate and the Rift escape are lore."
---

## Lore

The mutant rat was the Lone Star complex''s attempt at a cheap, fast-breeding
army: a wiry, five foot rodent with a long bare tail that is fully grown in a
year. The plan was to throw them at an enemy in swarms ahead of the real
troops. The rats worked out what they were for almost at once, and have
despised their makers ever since.

They are sharp, adaptable and thoroughly self-interested. A rat will join a
pack, swear loyalty and then sell the pack out to save its skin or turn a
profit. In numbers they grow loud, reckless and cruel; alone they are careful
survivors with an eye on the next deal. They want rank, fame and above all
wealth, and army life offers none of it, so they desert more than any other
mutant.

The Coalition has written the experiment off. Most rats were destroyed, a few
hundred were sterilized and kept as spies, infiltrators and assassins attached
to special units, and the ones that escaped through a freak Rift now infest the
complex''s lower levels and the Pecos Badlands. Feral rats are killed on sight.

## GM Notes

A rat in Coalition service is watched constantly and trusted by nobody: it has
no starting money, only a token 50-70 credits a month, is never taught to
read, never gets a full environmental suit and tops out at Sergeant.

Roll percentile for psionics at creation: only 01-25% are minor psionics, with
four Sensitive powers; the book gives no I.S.P. figure, so the G.M. sets one.

A character outside CS service is a feral deserter or a free-born. A free-born
may take an adventurer or men of arms O.C.C. at half its other-skill
selections. Either kind is hunted by Dog Packs and mutant cats.
',
       updated_at = datetime('now')
 WHERE class_id = 'mutant-rat'
   AND instr(markdown, 'A percentile chance, so NO psionics block is stored') > 0
   AND length(markdown) = 16059;

-- == oni-of-the-one-hundred ==
UPDATE imported_classes
   SET markdown = '---
id: oni-of-the-one-hundred
name: Oni of the One Hundred
system: rifts
source_book: Rifts World Book 8: Japan p.199-203
category: rcc
tags: [supernatural]
men_of_arms: false
xp_table: [0, 2001, 4001, 8201, 16401, 24501, 34601, 49701, 69801, 94901, 129001, 179101, 229201, 279301, 329401]
attribute_dice:
  IQ: "2d6"
  ME: "2d6"
  MA: "2d6"
  PS: "2d6+22"
  PP: "2d6+12"
  PE: "2d6+16"
  PB: "1d6"
  Spd: "6d6"
mdc_base: "2d6x10+40"
ppe_base: "5d6"
horror_factor: 11
bonuses:
  combat: { attacks_base: 4, initiative: 1, strike: 2, parry: 2, dodge: 2, pull_punch: 2, roll: 1 }
  saves: { horror_factor: 6 }
  at_level:
    - { level: 6, combat: { attacks: 1 } }
    - { level: 12, combat: { attacks: 1 } }
magic:
  type: "spell"
  spells: ["Tongues"]
skills:
  occ_skills:
    - { name: "Intelligence", base: 36, per_level: 4, note: "+4%" }
    - { name: "Tracking (people)", base: 35, per_level: 5, note: "+10%; the book prints track humanoids." }
    - { name: "Land Navigation", base: 51, per_level: 4, note: "+15%" }
    - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }
    - { name: "Swimming", base: 60, per_level: 5, note: "+10%" }
    - { name: "W.P. Blunt", base: 0, per_level: 0 }
    - { name: "W.P. Sword", base: 0, per_level: 0 }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "The book: W.P. blunt, W.P. sword and two of choice (any)." }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "Speaks Japanese at 98%." }
    - { name: "Language: Gobblely", base: 98, per_level: 0, note: "98%." }
    - { choose: 1, from: ["Language: Other"], base: 98, note: "Faerie at 98%. The catalog has no Faerie language row; take Language: Other and name it Faerie." }
    - { choose: 2, from: ["Language: Other"], bonus: 10, note: "Can learn two other languages (+10%). Taken once per language - the picker asks which." }
  secondary_skills:
    count: 4
    categories: ["Espionage", "Physical", "Technical", "Rogue", "Wilderness"]
trackable_resources:
  - { key: spell-casts, label: "Natural spell casts", max: 8, reset_on: day, note: "As many as 8 spells from the oni''s power group (and Tongues) per 24 hours. Natural abilities, not learned spell magic." }
special_abilities:
  - choose: 1
    from: ["Oni Powers (01-25): Curses", "Oni Powers (26-50): Blight", "Oni Powers (51-75): Fire", "Oni Powers (76-00): Wind and Storm"]
    note: "Every Oni of the One Hundred has one of four sets of natural magic powers (printed 202). Select one, or roll percentile dice. All four include Tongues."
  - name: "Oni Powers (01-25): Curses"
    description: "Percentile 01-25. Natural spell-like powers: Fear, Compulsion, Luck Curse, Minor Curse, Repel Animals and Tongues. Up to 8 casts per 24 hours in total."
    magic: { spells: ["Fear", "Compulsion", "Luck Curse", "Minor Curse", "Repel Animals"] }
  - name: "Oni Powers (26-50): Blight"
    description: "Percentile 26-50. Natural spell-like powers: Befuddle, Blind, Sickness, Spoil (food and water), Animate and Control Dead, and Tongues. Up to 8 casts per 24 hours in total."
    magic: { spells: ["Befuddle", "Blind", "Sickness", "Spoil", "Animate and Control Dead"] }
  - name: "Oni Powers (51-75): Fire"
    description: "Percentile 51-75. Natural spell-like powers: Globe of Daylight, Ignite Fire, Cloud of Smoke, Fire Ball, Fool''s Gold and Tongues. Up to 8 casts per 24 hours in total."
    magic: { spells: ["Globe of Daylight", "Ignite Fire", "Cloud of Smoke", "Fire Ball", "Fool''s Gold"] }
  - name: "Oni Powers (76-00): Wind and Storm"
    description: "Percentile 76-00. Natural spell-like powers: Breathe Without Air, Fly as the Eagle, Wind Rush, Summon Fog, Summon Storm and Tongues. Up to 8 casts per 24 hours in total."
    magic: { spells: ["Breathe Without Air", "Fly as the Eagle", "Wind Rush", "Summon Fog", "Summon Storm"] }
  - { choose: 1, from: ["Head (01-05): Wild Boar", "Head (06-15): Lion or Cat", "Head (16-30): Human", "Head (31-40): Skeletal Human", "Head (41-45): Monkey", "Head (46-55): Melon", "Head (56-60): Fish", "Head (61-65): Snake", "Head (66-70): Bird", "Head (71-80): Rotting Skeleton", "Head (81-90): Neanderthal", "Head (91-95): Fox or Canine", "Head (96-00): Rat"], note: "Oni Head Shape (printed 201), rolled once. The result adds to the Horror Factor of 11, which the sheet does not add up: write the total in by hand." }
  - name: "Head (01-05): Wild Boar"
    description: "Roll 01-05 or choose. The head of a wild boar. +2 Horror Factor (13), added by hand."
  - name: "Head (06-15): Lion or Cat"
    description: "Roll 06-15 or choose. The head of a lion or cat. +2 Horror Factor (13), added by hand."
  - name: "Head (16-30): Human"
    description: "Roll 16-30 or choose. A human head. No Horror Factor bonus (11)."
  - name: "Head (31-40): Skeletal Human"
    description: "Roll 31-40 or choose. A skeletal human head with sunken features. +2 Horror Factor (13), added by hand."
  - name: "Head (41-45): Monkey"
    description: "Roll 41-45 or choose. The head of a monkey. +1 Horror Factor (12), added by hand."
  - name: "Head (46-55): Melon"
    description: "Roll 46-55 or choose. A large head, round like a melon. +3 Horror Factor (14), added by hand."
  - name: "Head (56-60): Fish"
    description: "Roll 56-60 or choose. A fish-like head. +2 Horror Factor (13), added by hand."
  - name: "Head (61-65): Snake"
    description: "Roll 61-65 or choose. A snake-like head. +3 Horror Factor (14), added by hand."
  - name: "Head (66-70): Bird"
    description: "Roll 66-70 or choose. A bird-like head. +2 Horror Factor (13), added by hand."
  - name: "Head (71-80): Rotting Skeleton"
    description: "Roll 71-80 or choose. A human head that looks like a rotting skeleton. +4 Horror Factor (15), added by hand."
  - name: "Head (81-90): Neanderthal"
    description: "Roll 81-90 or choose. A larger, thicker human skull with heavy brow ridges and a square chin. +1 Horror Factor (12), added by hand."
  - name: "Head (91-95): Fox or Canine"
    description: "Roll 91-95 or choose. The head of a fox or other canine. +2 Horror Factor (13), added by hand."
  - name: "Head (96-00): Rat"
    description: "Roll 96-00 or choose. A rat-like head. +2 Horror Factor (13), added by hand."
  - { choose: 1, from: ["Mouth (01-10): Toad Mouth, Flat Teeth", "Mouth (11-20): Human, Crooked Teeth", "Mouth (21-30): Human, Fangs", "Mouth (31-40): Oversized Human", "Mouth (41-50): Monkey", "Mouth (51-60): Lipless Toad Slit", "Mouth (61-70): Canine Muzzle", "Mouth (71-80): Flabby, Flat Teeth", "Mouth (81-90): Flabby, Toothless", "Mouth (91-00): Tiny Slit"], note: "Oni Mouth (printed 201), rolled once. The result sets the bite damage, which is a figure to read rather than a number the sheet adds." }
  - name: "Mouth (01-10): Toad Mouth, Flat Teeth"
    description: "Roll 01-10 or choose. A large toad-like mouth with flabby lips and an even row of large, flat teeth. Bite: 2D4 M.D."
  - name: "Mouth (11-20): Human, Crooked Teeth"
    description: "Roll 11-20 or choose. A human mouth with crooked teeth. Bite: 1D4 M.D."
  - name: "Mouth (21-30): Human, Fangs"
    description: "Roll 21-30 or choose. A human mouth with fangs and sharp teeth. Bite: 2D4 M.D."
  - name: "Mouth (31-40): Oversized Human"
    description: "Roll 31-40 or choose. A human mouth twice the normal size, with large, pointed, crooked teeth. Bite: 3D4 M.D."
  - name: "Mouth (41-50): Monkey"
    description: "Roll 41-50 or choose. A large monkey-like mouth of sharp teeth and big fangs. Bite: 3D6 M.D."
  - name: "Mouth (51-60): Lipless Toad Slit"
    description: "Roll 51-60 or choose. A large toad mouth with no lips, a long slit full of tiny, sharp teeth. Bite: 2D6 M.D."
  - name: "Mouth (61-70): Canine Muzzle"
    description: "Roll 61-70 or choose. A canine mouth and short muzzle with a dog''s teeth and fangs. Bite: 3D6 M.D."
  - name: "Mouth (71-80): Flabby, Flat Teeth"
    description: "Roll 71-80 or choose. A large mouth with flabby, quivering lips and large, flat, crooked teeth. Bite: 2D4 M.D."
  - name: "Mouth (81-90): Flabby, Toothless"
    description: "Roll 81-90 or choose. A large mouth with flabby, quivering lips and no teeth at all. Bite: one point of mega-damage."
  - name: "Mouth (91-00): Tiny Slit"
    description: "Roll 91-00 or choose. A tiny slit half the size of a human mouth, lipless, with tiny teeth and a thin snake''s tongue. Bite: 1D4 M.D."
  - { choose: 1, from: ["Arms (01-20): Human", "Arms (21-30): Oversized Pair and a Third Arm", "Arms (31-45): Two-Fingered Claws", "Arms (46-56): Gnarled, Skeletal Hands", "Arms (57-67): Monkey-like Claws", "Arms (68-75): Squirrel or Rat-like", "Arms (76-85): Five Arms", "Arms (86-95): Bird Claws", "Arms (96-00): Tentacles"], note: "Oni Arms & Hands (printed 201), rolled once. The M.D. figure is the hand attack for that kind of arm; an extra attack per melee is added by the pick." }
  - name: "Arms (01-20): Human"
    description: "Roll 01-20 or choose. Perfectly human arms and hands, no claws. 1D6 M.D."
  - name: "Arms (21-30): Oversized Pair and a Third Arm"
    description: "Roll 21-30 or choose. A pair of large, oversized, muscular arms (3D6 M.D.) and a third, smaller arm with two clawed fingers and a thumb (2D6 M.D.). Applied: +1 attack per melee round."
    bonuses: { combat: { attacks: 1 } }
  - name: "Arms (31-45): Two-Fingered Claws"
    description: "Roll 31-45 or choose. Muscular human arms ending in clawed hands of two fingers and a thumb. 3D6 M.D."
  - name: "Arms (46-56): Gnarled, Skeletal Hands"
    description: "Roll 46-56 or choose. Thin, gnarled arms, muscular but misshapen, with skeletal hands and long clawed fingers. 2D6 M.D."
  - name: "Arms (57-67): Monkey-like Claws"
    description: "Roll 57-67 or choose. Muscular arms, monkey-like in shape and length, with three-fingered claws and a thumb. 2D4 M.D."
  - name: "Arms (68-75): Squirrel or Rat-like"
    description: "Roll 68-75 or choose. Short, spindly arms like a squirrel''s or rat''s, with small articulated hands and fingers. 1D4 M.D."
  - name: "Arms (76-85): Five Arms"
    description: "Roll 76-85 or choose. Five arms of equal size and proportion. 3D6 M.D. Applied: +1 attack per melee round."
    bonuses: { combat: { attacks: 1 } }
  - name: "Arms (86-95): Bird Claws"
    description: "Roll 86-95 or choose. Powerful arms with bird-like clawed hands. 3D6 M.D."
  - name: "Arms (96-00): Tentacles"
    description: "Roll 96-00 or choose. Octopus-like tentacles in place of arms, twice the length of human arms. 2D6 M.D. from a whip attack. Applied: +4 to entangle, which the book prints as +4 to entangle, grab or hold."
    bonuses: { combat: { entangle: 4 } }
  - { choose: 1, from: ["Legs (01-15): Human", "Legs (16-25): Monkey-like", "Legs (26-50): Classic Oni", "Legs (51-60): Skeletal, Two-Toed", "Legs (61-70): Bird-like", "Legs (71-80): Human, Clawed Toes", "Legs (81-90): Animal-like", "Legs (91-00): Snail Trunk"], note: "Oni Legs (printed 201), rolled once. The result sets the Spd attribute. The class rolls 6D6, the figure of four of the eight results; the classic oni''s +10 is added by the pick, and the three slower kinds are rerolled by hand." }
  - name: "Legs (01-15): Human"
    description: "Roll 01-15 or choose. Perfectly human legs, no claws. Spd is 5D6: not applied, so reroll Spd on 5D6 by hand."
  - name: "Legs (16-25): Monkey-like"
    description: "Roll 16-25 or choose. Short, stubby monkey-like legs; waddles when walking and lopes on all fours to run. Prehensile feet add +10% to balance and climbing, by hand. Spd is 4D6: not applied, so reroll Spd on 4D6 by hand."
  - name: "Legs (26-50): Classic Oni"
    description: "Roll 26-50 or choose. Powerfully built upper legs, rather thin lower legs, and feet with two large clawed toes. Spd is 6D6+10. Applied: +10 Spd on the class''s 6D6."
    bonuses: { attributes: { Spd: 10 } }
  - name: "Legs (51-60): Skeletal, Two-Toed"
    description: "Roll 51-60 or choose. Skeletal legs with the classic two-toed, clawed feet. Spd is 6D6, the class''s own roll."
  - name: "Legs (61-70): Bird-like"
    description: "Roll 61-70 or choose. Spindly stick legs and clawed bird feet. Spd is 6D6, the class''s own roll."
  - name: "Legs (71-80): Human, Clawed Toes"
    description: "Roll 71-80 or choose. Human feet with clawed toes. Spd is 6D6, the class''s own roll."
  - name: "Legs (81-90): Animal-like"
    description: "Roll 81-90 or choose. Animal legs, hooved or like a bear''s (the book prints ''hover''). Spd is 6D6, the class''s own roll."
  - name: "Legs (91-00): Snail Trunk"
    description: "Roll 91-00 or choose. No feet or legs: a snail-like trunk that slithers. +4 to maintain balance, by hand. Spd is 3D6: not applied, so reroll Spd on 3D6 by hand."
  - { choose: 1, from: ["Feature (01-07): Rat Tail", "Feature (08-14): Tiny Scales", "Feature (15-21): Small Horns", "Feature (22-28): Large Horns", "Feature (29-35): Large Mane", "Feature (36-42): Bushy Eyebrows and Beard", "Feature (43-49): Lumpy Flesh", "Feature (50-56): Hairy Body", "Feature (57-64): Hairless, Pale Skin", "Feature (65-72): Boils or Scabs", "Feature (73-80): Pot Belly", "Feature (81-87): Hunchback", "Feature (88-94): Lizard Tail", "Feature (95-00): Fur"], note: "Other Features (printed 201-202), rolled once. Seven of the results add to M.D.C. and the pick adds them." }
  - name: "Feature (01-07): Rat Tail"
    description: "Roll 01-07 or choose. The tail of a rat."
  - name: "Feature (08-14): Tiny Scales"
    description: "Roll 08-14 or choose. Skin covered in tiny scales. Applied: +35 M.D.C."
    bonuses: { pools: { mdc: 35 } }
  - name: "Feature (15-21): Small Horns"
    description: "Roll 15-21 or choose. A pair of small horns. Head butt: 1D4 M.D."
  - name: "Feature (22-28): Large Horns"
    description: "Roll 22-28 or choose. A pair of large horns. Head butt: 2D6 M.D."
  - name: "Feature (29-35): Large Mane"
    description: "Roll 29-35 or choose. A large mane of black, red, gold or green hair."
  - name: "Feature (36-42): Bushy Eyebrows and Beard"
    description: "Roll 36-42 or choose. Bushy eyebrows and a scraggly beard."
  - name: "Feature (43-49): Lumpy Flesh"
    description: "Roll 43-49 or choose. Lumpy pink or white flesh. Applied: +10 M.D.C."
    bonuses: { pools: { mdc: 10 } }
  - name: "Feature (50-56): Hairy Body"
    description: "Roll 50-56 or choose. A hairy body with tan or red skin. Applied: +20 M.D.C."
    bonuses: { pools: { mdc: 20 } }
  - name: "Feature (57-64): Hairless, Pale Skin"
    description: "Roll 57-64 or choose. No hair anywhere on the body, and pale skin."
  - name: "Feature (65-72): Boils or Scabs"
    description: "Roll 65-72 or choose. Boils or scabs cover the body. Applied: +25 M.D.C."
    bonuses: { pools: { mdc: 25 } }
  - name: "Feature (73-80): Pot Belly"
    description: "Roll 73-80 or choose. A pot belly on an otherwise muscular body. Applied: +10 M.D.C."
    bonuses: { pools: { mdc: 10 } }
  - name: "Feature (81-87): Hunchback"
    description: "Roll 81-87 or choose. A hunchback. Applied: +5 M.D.C."
    bonuses: { pools: { mdc: 5 } }
  - name: "Feature (88-94): Lizard Tail"
    description: "Roll 88-94 or choose. The tail of a lizard."
  - name: "Feature (95-00): Fur"
    description: "Roll 95-00 or choose. Covered in fur. Applied: +10 M.D.C."
    bonuses: { pools: { mdc: 10 } }
natural_abilities:
  - { name: "Nightvision", description: "500 feet (152 m); can see even in total darkness." }
  - { name: "Fire and Cold Resistant", description: "Fire and cold do half damage." }
  - { name: "Impervious to Disease", description: "Cannot catch or suffer from disease." }
  - { name: "Bio-Regeneration", description: "2D6 M.D. per hour." }
  - { name: "Supernatural Attributes", description: "All attributes are considered supernatural, including P.S. and P.E." }
  - { name: "Mega-Damage Creature", description: "A supernatural being from another dimension. M.D.C. 2D6x10+40, plus any M.D.C. from the Other Features appearance table; no hit points or S.D.C." }
  - { name: "Natural Attacks", description: "Restrained claw 5D6 S.D.C. plus P.S. damage bonus; full strength claw, punch or kick 3D6 M.D.; gore with horns 2D6+6 M.D.; power punch 6D6 M.D. (counts as two attacks); leap kick 1D4x10 M.D. (counts as two attacks); body flip/throw 2D6 M.D. The appearance tables give bite, arm and head butt damage that varies by oni." }
restrictions:
  - "Primarily an N.P.C. villain. A player character is entirely at the G.M.''s discretion, and is likely an outcast among its kind - possibly because of an anarchist, unprincipled or scrupulous alignment."
  - "Alignment: 45% miscreant, 30% diabolic, 5% aberrant, 15% anarchist and 5% other."
  - "Psionics: none."
  - "Magic: the four power sets are natural abilities; the oni knows no spell magic and cannot learn it as a spell caster does."
  - "Technology: too ignorant and impatient to learn to operate power armor, computers and vehicles. Fewer than 15% use energy weapons, rail guns or human body armor, and those only at a rudimentary level."
  - "Size: 4 to 5 feet (1.2 to 1.5 m), unless the body shape table makes it a giant. Weight: 100 to 250 pounds (45 to 112.5 kg)."
  - "Average life span: 250+ years."
  - "Average experience level for N.P.C.s: third level for a typical warrior, 1D4+2 for elite warriors, 1D4+4 for a war chief or clan leader."
  - "Horror Factor 11 is the factor the oni projects, plus the bonus from its head shape; its +6 to save vs Horror Factor is in bonuses."
side_effects: "Weakness for alcohol, which can be used as a bribe or to gather information. Carnivores who prefer human flesh. Money and equipment: none printed. Oni favor clubs, swords and axes, prize captured vibro-blades, rune weapons and magic arms and armor, and increasingly steal M.D. body armor and energy weapons; oni masters know a secret ritual that makes melee weapons inflict mega-damage and armor gain M.D.C. Appearance is rolled on the oni creation tables (see Appearance below). The five tables whose results carry a number - head, mouth, arms and hands, legs, other features - are picks under special abilities; body shape, nose, eyes and skin color stay in the Appearance section."
extraction_notes: "Rifts World Book 8: Japan printed 199-203 (text layer, page_offset +1: cache p200-p204). General oni rules on printed 199-200 (cache p200 is WELDED and was checked against a render; the text layer reads cleanly in column order). The appearance tables run printed 201-202 (cache p202-p203). The stat block is Oni of the One Hundred (Lesser Oni) on printed 202, right column, continued to the top of printed 203 (habitat, war band, clan, village, enemies, allies), read off a render of printed 202. || NPC: the book''s note makes these primarily N.P.C. villains, a player character at the G.M.''s discretion; stated in restrictions and GM Notes. || XP: the ''Sura-Kappa, Oni of the One Hundred'' column on the Experience Point Tables page (cache p217, printed 216, read off a render; third column, middle): lower bounds 0 / 2,001 / 4,001 / 8,201 / 16,401 / 24,501 / 34,601 / 49,701 / 69,801 / 94,901 / 129,001 / 179,101 / 229,201 / 279,301 / 329,401. || GROUP: a race, so men_of_arms: false (heading Oni of the One Hundred (Lesser Oni), an R.C.C.). No supersedes_race: this is a race, not a transformation. || ATTRIBUTES: I.Q., M.E., M.A. 2D6; P.S. 22+2D6; P.P. 12+2D6; P.E. 16+2D6; P.B. 1D6; all supernatural (prose). Spd is not a fixed roll: it comes from the Oni Legs table (5D6 human legs 01-15, 4D6 monkey 16-25, 6D6+10 classic oni 26-50, 6D6 for 51-90, 3D6 snail trunk 91-00). Stored as 6D6, the result for 40% of rolls; a character with another leg type rerolls Spd by hand. || POOLS: M.D.C. 2D6x10+40, plus Other Features additions (prose). P.P.E. 5D6 for a typical warrior. No hit points or S.D.C. (mega-damage creature). No starting money or equipment is printed. || HORROR FACTOR 11 plus the head shape bonus (+0 to +4, prose). || COMBAT: four attacks per melee as attacks_base 4, plus one at levels 6 and 12 as at_level. No hand to hand skill is printed and no price for one, so no hand_to_hand block. Bonuses as printed: +1 initiative, +2 strike, parry and dodge, +2 pull punch, +1 roll with punch/fall/impact, +6 vs horror factor. Damage figures are a natural ability (prose). || MAGIC: four sets of natural powers, one chosen or rolled, up to 8 casts per 24 hours. Each set is a chosen special ability carrying its spells; Tongues, common to all four, is granted by the class. The 8 casts are a trackable resource. Spoil (food & water) is the catalog''s Spoil; animate/control dead is Animate and Control Dead; fly as the eagle and fire ball as catalogued. || SKILLS: catalog base + printed bonus: Intelligence 32+4, track humanoids as Tracking (people) 25+10, Land Navigation 36+15, Climbing 40+10, Swimming 50+10; W.P. Blunt, W.P. Sword and two W.P.s of choice (any). Japanese as Language: Native Tongue at 98%, Gobblely at 98%, Faerie as a Language: Other pick at 98% (no Faerie row), and two other languages (+10%) as Language: Other picks. Four secondary skills from espionage, physical, technical, rogue and wilderness, as printed on the race. || APPEARANCE: the oni creation tables (body shape, head, nose, eyes, mouth, arms and hands, legs, other features, skin color) are random appearance tables, nine of them on printed 201-202 under ''Roll once on each unless indicated otherwise'', paraphrased in the body. Since 2026-10-03 the five single-roll tables whose results carry a number are banded choose-1 groups in special_abilities: Head Shape (Horror Factor +0 to +4, prose, because an ability cannot restate horror_factor), Mouth (bite damage, prose), Arms & Hands (hand damage as prose; +1 attack at 21-30 and 76-85 and +4 entangle at 96-00 as bonuses), Legs (Spd dice: +10 Spd at 26-50 as a bonus, the 5D6, 4D6 and 3D6 results as prose because a bonus takes no subtracted die) and Other Features (M.D.C. +35, +10, +20, +25, +10, +5, +10 as pool bonuses; head butt damage prose). Not groups: Nose and Eyes each hold a result that rolls again on the same table (71-80 tiny nose of any type above, 81-90 four eyes of a rerolled shape), which one pick cannot state; Body Shape and Skin Color are single rolls that carry no number. The four power-set options were renamed with their bands the same day so the wizard can roll them."
---

## Lore

Oni is the Japanese word for demon, and Japanese legend knows hundreds of kinds, most without a proper name: an oni is called by its look ("the three-armed oni"), its temper, its deeds or its master. They stand for the nameless terrors of the night and are always ugly or frightening: animal heads, misshapen faces with huge noses and crooked teeth, manes of wild black or red hair, big clawed two-toed feet, horns on at least half of them, hunched and oddly shaped bodies. Most are small and goblin-like, four or five feet tall, though the occasional giant turns up.

The Oni of the One Hundred are the commonest oni: dull-witted, cruel beings who delight in murder, torture, kidnapping, robbery and vandalism against anything weaker. Tens of thousands of them roam the wilderness of the islands and dominate The Zone. They come from a dimension long linked to Japan; only a few hundred lived there in ancient times, where they became the demons, ghosts and goblins of old tales, but when the Rifts opened they flooded in by the thousands.

They travel in small tribal war bands that raid villages, waylay travelers and even slip into the reborn cities of the Republic. They enslave humans, sometimes rule whole villages, and carry off women and children as slaves, sacrifices or food. Power is the only authority they respect: the strongest warrior or mightiest magic-wielder leads, and every leader is challenged the moment he looks weak. Outsiders - wizards, warlords, pirates, greater demons - gain oni minions by beating the chief and his rivals, and keep them only by terror. Clans war on each other constantly, and nearly every oni boasts that he will one day rule Japan.

Oni are bold in numbers but easily cowed: feats of magic, great strength or courage can scatter a band, and defeating its one to five ringleaders usually sends the rest fleeing. Not all of them frighten, though, and some fight to the death. All are liars and backstabbers. They fear and covet "man''s technology" - power armor, cyborgs, robots and energy weapons - and steal M.D. body armor, vibro-blades and guns, but are too impatient to learn machines. Most still fight with tooth and claw, sheer strength and natural magic. They eat any humanoid or animal they kill and have a notorious weakness for alcohol.

## Appearance

Oni are rolled on the book''s creation tables, one roll per table. In summary:

- **Body shape:** from perfectly human, broad and muscular, or skeletal, through a lumpy snail-like blob, a fat bald buddha, a neckless toad, a barrel-chested bird-body, a giant of 9 to 12 feet, to a scaled fish with fins and tail.
- **Head:** boar, lion or cat, human, sunken skeletal, monkey, huge melon-round, fish, snake, bird, rotting skull, neanderthal, fox or rat. Each non-human head adds +1 to +4 to Horror Factor (the rotting skull +4, melon and snake +3).
- **Nose:** normal, huge bulbous or pointed, broad and ape-like, a bird''s beak, an animal snout, a tiny version of any of these, snake slits, a rat''s nose, or none at all.
- **Eyes:** wild and crazed, huge glowing almond eyes, large pale or crystal-clear orbs, small red, yellow or black eyes, sparkling snake eyes, jade bird eyes, ordinary human eyes, four eyes, or a single large pale blue or violet eye.
- **Mouth:** from toad-like mouths of flat teeth to fanged monkey and canine muzzles, a toothless flabby mouth or a lipless slit with a snake''s tongue; the bite does from 1 M.D. up to 3D6 M.D. depending on the mouth.
- **Arms and hands:** human hands, a third small clawed arm (an extra attack), two-fingered claws, skeletal talons, monkey or rat-like limbs, five arms (an extra attack), bird claws, or tentacles that whip and grab. Claw damage runs from 1D4 to 3D6 M.D. by type.
- **Legs:** human legs, stubby monkey legs, the classic oni legs with two clawed toes, skeletal or bird legs, clawed human feet, bear-like animal legs, or a slithering snail trunk. The leg type sets Spd, from 3D6 to 6D6+10.
- **Other features:** rat or lizard tail, fine scales, small or large horns (head butts), a great mane, bushy brows and beard, lumpy pink flesh, a hairy red or tan hide, hairlessness, boils and scabs, a pot belly, a hunchback, or fur. Several of these add 5 to 35 M.D.C.
- **Skin color:** brown or tan, reddish brown, red, fiery red, light or jade green, light blue, pale grey, stark white or ivory, or mustard yellow-brown.

## Society

A small war band is 1D6+4 oni, a medium one 3D6+12, and the largest seldom pass 80. Clans run from 20 to 40 members up to 300 to 500. An oni village holds several hundred oni from more than one clan, some goblins, imps and other supernatural hangers-on, a few human or D-bee allies, and hundreds of human and D-bee slaves. They live in wilderness, mountains, slums, sewers and ruins across Japan, Taiwan, Korea, China, and parts of India and Southeast Asia, mostly in The Zone and the Freelands, with a few tribes in the New Empire''s backwaters and the Republic''s alleys.

Their ancient enemies are tengu, yamabushi, bishamon, demon quellers, samurai, psi-stalkers, Atlantean Undead Slayers and a handful of gods. They avoid faerie folk, elementals, dragons and the kilin as threats rather than foes. Their allies are other oni and demons, vampires, goblins and goblin spiders, ogres, trolls, gargoyles, evil dragons, priests and sorcerers; the Horune pirates have traded with them for decades.

## GM Notes

The book makes the Oni of the One Hundred primarily an N.P.C. villain and leaves a player character entirely to the G.M.''s discretion. Such a character is probably an outcast from its tribe, often for an anarchist, unprincipled or scrupulous alignment. The average N.P.C. warrior is third level; elite warriors 1D4+2, war chiefs and clan leaders 1D4+4. One oni in ten is an oni master and one in fifty an oni mystic (separate entries).
',
       updated_at = datetime('now')
 WHERE class_id = 'oni-of-the-one-hundred'
   AND instr(markdown, '"Oni Powers: Curses"') > 0
   AND length(markdown) = 15606;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 6 classes carry their new text' AS assertion, count(*) AS got, 6 AS want
  FROM imported_classes
 WHERE (class_id = 'arkhon' AND instr(markdown, 'Psionics (57-00): None') > 0)
    OR (class_id = 'amaki-stone-man' AND instr(markdown, 'Psionics (65-00): None') > 0)
    OR (class_id = 'felinoid' AND instr(markdown, 'Strain (01-75)') > 0)
    OR (class_id = 'larmac' AND instr(markdown, 'Psionics (16-00): None') > 0)
    OR (class_id = 'mutant-rat' AND instr(markdown, 'Psionics (26-00): None') > 0)
    OR (class_id = 'oni-of-the-one-hundred' AND instr(markdown, '"Oni Powers (01-25): Curses"') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'arkhon' AND instr(markdown, 'the book''s odds are recorded in natural_abilities') > 0)
    OR (class_id = 'amaki-stone-man' AND instr(markdown, 'cannot reach Master') > 0)
    OR (class_id = 'felinoid' AND instr(markdown, '**Sub-strains (apply by hand):**') > 0)
    OR (class_id = 'larmac' AND instr(markdown, 'name: "Rare psionics"') > 0)
    OR (class_id = 'mutant-rat' AND instr(markdown, 'A percentile chance, so NO psionics block is stored') > 0)
    OR (class_id = 'oni-of-the-one-hundred' AND instr(markdown, '"Oni Powers: Curses"') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('arkhon', 'amaki-stone-man', 'felinoid', 'larmac', 'mutant-rat', 'oni-of-the-one-hundred') AND instr(markdown, char(13)) > 0;

INSERT INTO data_script_runs (filename) VALUES ('~090-percentile-groups-six-classes.sql');
