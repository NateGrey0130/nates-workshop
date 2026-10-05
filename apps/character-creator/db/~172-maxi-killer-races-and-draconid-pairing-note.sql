-- The Maxi-Killer's race list, and what a Draconid pairing over-grants
-- 2 classes, each replaced whole: maxi-killer, draconid.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~172-maxi-killer-races-and-draconid-pairing-note.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.
-- Two decisions Nate took on 2026-10-05, after the retrospective close-out.
-- maxi-killer: race_restrictions.only gains the eight races Juicer Uprising p.54 names that are classes now.
-- draconid: the pick's note says the pairing brings more than printed 36 gives. No figure moves.

-- == maxi-killer ==
UPDATE imported_classes
   SET markdown = '---
id: maxi-killer
name: Maxi-Killer
system: rifts
source_book: Rifts World Book 10: Juicer Uprising p.53-55
category: occ
tags: [combat, augmented]
xp_table: [0, 2601, 5001, 10001, 20001, 30001, 49001, 62001, 80001, 110001, 150001, 200001, 250001, 310001, 370001]
occ_group: men-of-arms
race_restrictions:
  only: ["none", "dwarf", "elf", "ogre", "wolfen", "true-atlantean", "kittani-warrior", "kittani-field-mechanic", "kittani-espionage", "simvan-monster-rider", "hawrk-duhk", "hawrk-ka", "hawrk-ohl"]
  note: "This is the one Juicer conversion with its own printed racial list, and it is the widest in the book - Juicer Uprising p.54 names humans, True Atlanteans (but not Tattooed Men, and fewer than six magic tattoos), Kittani, Kydians, Wolfen, Elves, Dwarves, Simvan, Hawrk-duhk, Hawrk-ka, Hawrk-ofil, a variety of human-like D-Bees, and Splugorth High Lords who rarely bother. Most Maxi-Killers are humans, ogres or elves raised in slavery. The list names race ids, so it widens only when someone adds one: the True Atlantean, the three Kittani R.C.C.s, the Simvan and the three Hawrk (the third is the Hawrk-ohl of Rifts World Book 2: Atlantis) were added on 2026-10-05, Nate''s decision. A True Atlantean Maxi-Killer must hold fewer than six magic tattoos, which nothing checks. Kydians and Splugorth High Lords are not classes here and stay prose. Barred outright: shapeshifters, major or master psychics, practitioners of magic, creatures of magic and supernatural beings."
mdc_base: "2d4x10+60, +10 per level"
starting_money: "0"
bonuses:
  attributes: { PS: 8, PE: "1d4", PP: "1d4+1", Spd: "1d6x10" }
  attribute_minimums: { PS: 21 }
  combat: { initiative: 3, roll: 3, attacks: 1 }
  saves: { spell_magic: 4, psionics: 2, possession: 2, toxins_poisons: 4, disease: 4, horror_factor: 4, coma_death_pct: 30 }
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Radio: Basic", base: 50, per_level: 5, note: "+5%" }
    - { name: "Language: Dragonese", base: 98, per_level: 0, note: "Dragonese/Elf at 98%." }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "American at 98%." }
    - { name: "Intelligence", base: 42, per_level: 4, note: "+10%" }
    - { name: "Tracking (people)", base: 35, per_level: 5, note: "Printed as Tracking (+10%)." }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }
    - { name: "Swimming", base: 55, per_level: 5, note: "+5%" }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { name: "W.P. Sword", base: 0, per_level: 0 }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P.: two weapons of choice." }
    - { choose: 1, from: ["Hand to Hand: Martial Arts", "Hand to Hand: Assassin"], note: "The Maxi-Killer starts at Martial Arts or Assassin - the only class in this book that does not begin at Expert, and the only one with nothing to trade for the upgrade." }
  occ_related_skills:
    count: 4
    schedule: [{ level: 4, count: 1 }, { level: 8, count: 1 }, { level: 12, count: 1 }]
    categories:
      - { name: "Communications", bonus: 5 }
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", bonus: 5 }
      - { name: "Mechanical", only: ["Automotive Mechanics"] }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Military", bonus: 10 }
      - { name: "Physical", bonus: 5 }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Air Assault Armor", "Combat Pod"], bonus: 5 }
      - "Pilot Related"
      - { name: "Rogue", bonus: 2 }
      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced"], bonus: 10 }
      - { name: "Technical", except: ["Computer Operation", "Computer Programming"], bonus: 5 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 5 }
    note: "The book prints Pilot as any EXCEPT robot and power armor skills, and Technical as any EXCEPT computer; both are spelled out as the catalog rows they exclude, because an unmatched name in an except list excludes nothing and does so silently. Computer Repair is filed under Electrical here, which the Maxi-Killer restricts to Basic Electronics anyway."
  secondary_skills:
    count: 6
special_abilities:
  - name: "The Maxi-Inducer Symbiote"
    description: "Not a bio-comp and harness but a living thing, attached to the recipient''s back and resembling a chest amalgamate without a mouth or sensory organs. Its roots grow inside the body as well as outside, wrapping tendrils around the limbs and invading the internal organs. It both enhances and regulates the host''s metabolism, raising his attributes to supernatural levels. REMOVING IT IS IMPOSSIBLE WITHOUT INSTANTLY KILLING THE PATIENT."
  - name: "Grafted Armor"
    description: "A second symbiote linked to the Maxi-Inducer grows over the character like a living shell: 120 M.D.C. that regenerates 1D4x10 M.D.C. per hour, covered in a dozen or so small protective spines. It grows one forearm blade per level of experience up to three per arm, each an M.D.C. structure inflicting 2D6 M.D. If its M.D.C. is driven to zero it disappears, its roots retreating into the body - and until it has regenerated 50 M.D.C. the Juicer cannot regenerate at all and takes 3D6 M.D. per hour as the symbiote feeds on him to rebuild itself. Every point he loses goes into the symbiote. Past 50 M.D.C. both recover normally, and the armour regrows completely ten hours after that mark. If the Maxi-Killer dies before the creature reaches 50, THEY BOTH DIE."
  - name: "Supernatural Strength and Endurance"
    description: "A flat +8 to P.S., minimum 21, and it is supernatural. Damage follows the supernatural strength table reprinted in the Titan Juicer entry."
  - name: "Regeneration"
    description: "Regenerates 1D4x10 M.D.C. per hour and can REGROW SEVERED LIMBS AND LOST ORGANS - which no other Juicer in this book can do. Virtually impervious to pain. The +30% to save versus coma and death is in the bonuses block, and is the highest in the book."
  - name: "Super Reflexes and Reaction Time"
    description: "Gets an automatic parry or dodge against ALL attacks, including from behind and from surprise."
  - name: "Further Bio-Wizard Implants"
    description: "A Maxi-Killer who shows great loyalty and combat prowess, or who was made for the arena, may be granted one or two additional Bio-Wizard implants or appendages - rarely before third level. Kittani and Kydian volunteers get three automatically. A player character who escaped Atlantis will never be given any."
  - { choose: 1, from: ["Insanity (01-60): No Insanity", "Insanity (61-75): Loves Fighting and Competition", "Insanity (76-78): Hates Fighting", "Insanity (79-84): Obsession with Danger", "Insanity (85-90): Fear of Tattoos", "Insanity (91-95): Phobia of Splugorth", "Insanity (96-00): Phobia of High Lords"], note: "Maxi-Killer Insanity Table (printed 54), rolled once at creation or picked. The page has it rolled AGAIN every time a new bio-wizard enhancement is acquired: make that later roll by hand and record the result, it is not offered here." }
  - name: "Insanity (01-60): No Insanity"
    description: "Roll 01-60 or choose. No insanity: the conditioning held."
  - name: "Insanity (61-75): Loves Fighting and Competition"
    description: "Roll 61-75 or choose. Obsessed with fighting and competition, and loves it."
  - name: "Insanity (76-78): Hates Fighting"
    description: "Roll 76-78 or choose. Obsession with fighting: hates it and tries to avoid it."
  - name: "Insanity (79-84): Obsession with Danger"
    description: "Roll 79-84 or choose. Obsession with danger: loves it and takes needless risks."
  - name: "Insanity (85-90): Fear of Tattoos"
    description: "Roll 85-90 or choose. Not exactly a phobia, but a slight fear and paranoia about tattoos and those who have them: cannot stand to get any, distrusts anyone who has even one, and is very suspicious of Tattooed Men."
  - name: "Insanity (91-95): Phobia of Splugorth"
    description: "Roll 91-95 or choose. Phobia: Splugorth."
  - name: "Insanity (96-00): Phobia of High Lords"
    description: "Roll 96-00 or choose. Phobia: High Lords."
side_effects: "The human body is not meant to hold this state for long. Life span is the recipient''s own average divided by TWENTY, plus 4D6 months - so an average human or ogre lasts four years plus 4D6 months, a True Atlantean 25 years plus 4D6 months, and a Splugorth High Lord with a 1,200-year span would get 60 years plus 4D6 months, a long time for a human and a fraction of a lifetime for him. On top of the usual Juicer anxieties, insomnia, restlessness and impatience: the Maxi-Killer insanity table is rolled once at creation - that roll is the Insanity pick among the abilities - and again, by hand, every time a new bio-wizard enhancement is acquired. 01-60 no insanity; 61-75 obsessed with fighting and competition and loves it; 76-78 obsession with fighting, hates it and avoids it; 79-84 obsession with danger, takes needless risks; 85-90 a slight fear and paranoia about tattoos and those who have them, cannot stand to get any and distrusts anyone who has even one, very suspicious of Tattooed Men; 91-95 phobia of Splugorth; 96-00 phobia of High Lords."
restrictions: ["No cybernetics, ever.", "Available only to slaves and minions of the Splugorth.", "Cannot be transformed into a Murder-Wraith: the bio-wizardry prevents the necromantic ritual from taking effect.", "Shapeshifters, major or master psychics, practitioners of magic, creatures of magic and supernatural beings cannot take this conversion at all.", "True Atlanteans may take it only if they are not Tattooed Men and carry fewer than six magic tattoos."]
extraction_notes: "starting_money is 0 because the book prints Money: None - a Maxi-Killer is a slave and is issued what he needs, with a monthly allowance only at his master''s discretion. The life span is a FORMULA against the recipient''s own species rather than a fixed span, which is unique in this book and is stated in side_effects rather than computed. The +8 to P.S. is a flat integer, not dice, which is also unique here. The racial list is the widest in the book. Until 2026-10-05 race_restrictions named only wolfen, dwarf, elf, ogre and the human case, and this note said the list would widen by itself when the other races were imported; it could not, because an `only` names ids. On that day, on Nate''s decision, it gained true-atlantean, kittani-warrior, kittani-field-mechanic, kittani-espionage, simvan-monster-rider, hawrk-duhk, hawrk-ka and hawrk-ohl. The Kittani and the Simvan are R.C.C.s that carry their own skills, so pairing one with this class gives both skill sets; nothing trims that. Kydians and Splugorth High Lords are not classes in this catalog and stay prose. An `only` fails closed. 2026-10-05 (BOOK-INGEST-AUDIT.md F120): the Maxi-Killer Insanity Table, printed p.54 item 10, is seven rows - 01-60 no insanity, 61-75, 76-78, 79-84, 85-90, 91-95, 96-00 - covering 01-00 with no gap or overlap. The page says to roll once, and to roll again every time a new bio-wizard enhancement is acquired. Stored as one pick-one group of seven band-named Insanity options for the creation roll; the roll per later enhancement is stated in the group note and in side_effects and is made by hand, because it is earned in play rather than at a level. No row prints a number, so no option carries bonuses."
---

## Lore

The Splugorth of Atlantis have their own Juicer, and they built it to work on
people the human process kills.

The Atlantean conversion combines high technology - much of it copied directly
from human systems - with bio-wizardry. Officially it is the Bio-Wizard Juicer.
Everyone calls it the Maxi-Killer. Instead of a bio-comp and a drug harness
there is a Juicer Symbiote, the Maxi-Inducer, which attaches to the recipient''s
back, monitors his biology, and manipulates it.

Most Maxi-Killers are humans, ogres or elves raised in slavery, born to it or
taken young, and trained in combat since early childhood. Only the toughest and
most ruthless are chosen for the enhancement, or for similar "elite" gifts like
the Tattooed Maxi-Man. At sixteen or seventeen the loyal slave is united with the
symbiote and becomes a warrior in the service of the Splugorth.

They are teamed with Tattooed Men, Maxi-Men, Power Lords and other slave
warriors, and they are a popular attraction in the arenas of Atlantis. Trusted
servants are rewarded with as many as two more bio-wizard implants or limbs.
Some have been exported across the Megaverse, reaching Phase World and other
transdimensional markets as the property of a High Lord or as gladiators.

A few have escaped. None of them can ever live a normal life, covered as they
are by the symbiote - and there is no taking it off.

## GM Notes

**Demographics.** The Maxi-Killer does not appear in the book''s North American
Juicer breakdown at all; it is Splugorth technology, and its numbers belong to
Atlantis.

**This is the widest-open Juicer in the book and the most owned.** Fourteen
named peoples can take it, against the human-plus-three of everything else - and
the price is that you are a slave. An escaped Maxi-Killer is a strong character
concept with a symbiote on his back that everyone can see.

**The armour is a second creature with its own hit points and its own agenda.**
Drive it to zero and it does not just stop protecting him: it starts eating him,
3D6 M.D. an hour, until it has rebuilt 50 M.D.C. And if he dies first, it dies.
That is a fight with a third party in it.

**The life span formula is the cruellest thing here.** Divide by twenty. A human
gets four years. A True Atlantean gets twenty-five - and loses four hundred and
seventy-five.
',
       updated_at = datetime('now')
 WHERE class_id = 'maxi-killer'
   AND instr(markdown, 'will start working by themselves if they are ever imported') > 0
   AND length(markdown) = 13352;

-- == draconid ==
UPDATE imported_classes
   SET markdown = '---
id: draconid
name: Draconid
system: rifts
category: rcc
tags: [supernatural]
xp_table: [0, 2201, 4401, 9001, 19001, 28001, 40001, 60001, 80001, 100001, 150001, 200001, 275001, 350001, 425001]
keeps_xp_table: true
source_book: Rifts Dimension Book 2: Phase World p.35-36
attribute_dice:
  IQ: "3d6+3"
  ME: "4d6+3"
  MA: "3d6+3"
  PS: "3d6+6"
  PP: "3d6+3"
  PE: "4d6+3"
  PB: "4d6"
  Spd: "4d6"
mdc_base: "4d6x10, plus 1d6 per level of experience"
horror_factor: 10
ppe_base: "1d6x10"
yields_to_occupation: { ppe_base: [magic] }
bonuses:
  saves: { spell_magic: 1, horror_factor: 3 }
natural_abilities:
  - { name: "Nightvision", description: "90 ft (27.4 m)." }
  - { name: "See the Invisible", description: "Constant, at will, at no cost." }
  - { name: "Bio-Regeneration", description: "Regenerates 3d6 M.D.C. every five minutes." }
  - { name: "Supernatural Strength", description: "Physical strength is supernatural. A bite inflicts 2d4 M.D.; other damage varies with P.S. The sheet has no strength-type field." }
  - { name: "Natural Combat Ability", description: "Draconids fight well by instinct, on top of whatever hand to hand training they take as a skill." }
  - { name: "Horror Factor", description: "10 (printed 35). Draconids are mistaken for demons in some places." }
  - { name: "Average Life Span", description: "3,000 years; some live two or three times as long." }
  - { name: "Size", description: "Five to seven feet tall (1.5 to 2.1 m)." }
special_abilities:
  - { choose: 1, from: ["Other Powers: Magician", "Other Powers: Psychic"], note: "Other Powers (printed 36): every draconid becomes one or the other, by a subconscious process at birth. The pick names the occupation that carries the powers; take it on the Occupation step. The page gives the occupation''s POWERS only: the pairing also brings that occupation''s O.C.C. skills, related skill count, equipment and money, which a draconid does not get by the book. The app cannot trim them, so leave them off or clear it with the G.M." }
  - name: "Other Powers: Magician"
    description: "All the powers of a Ley Line Walker, with a 1D6x10 P.P.E. bonus. Take the Ley Line Walker as the occupation. Printed 35 gives the race 1D6x10 P.P.E. unless it uses magic, so the Ley Line Walker''s P.P.E. is used in place of that and this pick adds the bonus 1D6x10 to it. The draconid levels on its own experience table either way."
    occ_options: [ley-line-walker]
    bonuses: { pools: { ppe: "1d6x10" } }
  - name: "Other Powers: Psychic"
    description: "All the abilities and powers of a Mind Melter, with a bonus of 1D4x10 I.S.P. Take the Mind Melter as the occupation; this pick adds the bonus 1D4x10 I.S.P. The race''s 1D6x10 P.P.E. is kept (printed 35 sets it aside only for a draconid that uses magic), and the draconid levels on its own experience table either way."
    occ_options: [mind-melter]
    bonuses: { pools: { isp: "1d4x10" } }
side_effects: "A DRACONID IS VULNERABLE EXACTLY AS A DRAGON IS. Any weapon, spell or potion that does extra damage to dragons affects a draconid the same way. It is the one penalty this race carries and the app has no damage-taken model to apply it with."
skills:
  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Mathematics: Basic", bonus: 15, note: "Printed as Basic Math (+15%)." }
    - { name: "Radio: Basic", bonus: 10, note: "Printed as Basic Radio (+10%)." }
    - { name: "Basic Electronics", bonus: 10, note: "+10% bonus over base." }
    - { name: "Language: Dragonese", base: 98, per_level: 0, note: "Printed as Language: Dragonese/Elven 98%. The catalog files the tongue as Language: Dragonese." }
    - { name: "Language: Trade Five/Reptile", base: 98, per_level: 0, note: "Printed as Language: Trade Five 98%. The catalog row is Language: Trade Five/Reptile, re-cited onto printed 52 in the skills batch." }
    - { choose: 2, from: ["Language: Other"], bonus: 20, note: "Language: Any two (+20%). The catalog''s repeatable Language: Other row is what an any-language pick resolves through." }
    - { name: "Lore: Demons & Monsters", bonus: 15, note: "Printed as Demon and Monster Lore (+15%)." }
    - { choose: 1, categories: ["Pilot"], bonus: 10, note: "Pilot: Pick one (+10%)." }
    - { name: "Wilderness Survival", bonus: 10, note: "+10% bonus over base." }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P.: Any two." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "May be changed to Expert at the cost of one other skill, or to Martial Arts - Assassin if of an evil alignment - at the cost of two." }
  occ_related_skills:
    count: 6
    categories:
      - { name: "Communications", bonus: 10 }
      - { name: "Domestic", bonus: 5 }
      - "Electrical"
      - { name: "Espionage", bonus: 5 }
      - "Mechanical"
      - "Medical"
      - "Military"
      - "Physical"
      - { name: "Pilot", bonus: 5 }
      - { name: "Pilot Related", bonus: 5 }
      - { name: "Rogue", bonus: 5 }
      - "Science"
      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 10 }
    note: "Select an additional six other skills. There is no schedule: six at first level is all a draconid gets from this list. Pilot Related is printed as Any (+5% if applicable), and the condition is not storable - the category bonus is applied to every pick in it."
  secondary_skills:
    count: 6
    note: "Six secondary skills from the same list, without the bonuses in parentheses."
extraction_notes: |
  - Read from the OCR cache of a scan and verified against 200 dpi renders of
    printed 35 and 36, which between them carry the whole stat block and the
    whole skill list, with a 400 dpi crop of the R.C.C. skill list and of the
    related-skill categories. The entry begins on printed 35 under the section
    heading "Other Races & O.C.C.s of Note Common to Phase World" and ends on
    printed 36 at "Alliances and Allies"; both pages were read to the end and
    the Phantom''s heading is what follows.
  - THE MAGICIAN/PSYCHIC BRANCH IS A REQUIRED PICK-ONE GROUP SINCE 2026-10-05
    (BOOK-INGEST-AUDIT.md F121, F122; before that it was one prose ability).
    Printed 36, read off a 200 dpi render: a magician gets "all the powers of
    a ley line walker with a 1D6x10 P.P.E. bonus", a psychic "all the abilities
    and powers of a mind melter with a bonus of 1D4x10 I.S.P. points", and in
    either case the draconid''s own experience table is used. Each option names
    its occupation in occ_options and carries the bonus as a pool bonus; the
    powers themselves come from the occupation the pick brings.
  - P.P.E.: the book prints "1D6x10 unless they use magic (see below)". Stored
    as ppe_base 1d6x10 with yields_to_occupation { ppe_base: [magic] }, so a
    magician has the Ley Line Walker''s P.P.E. plus the option''s 1d6x10, and a
    psychic or a draconid with no occupation keeps 1D6x10.
  - THE LADDER IS KEPT IN A PAIRING: keeps_xp_table is true because the page
    says to use the draconid''s table in either case.
  - WHAT THE PAIRING GIVES THAT THE PAGE DOES NOT. The page grants the
    occupation''s POWERS and prints the draconid''s own R.C.C. skills, six
    related and six secondary. Taking the occupation also brings its O.C.C.
    skills, its related-skill count, its equipment and its money, none of
    which the page gives. Recorded, not corrected: the G.M. trims them.
  - THE LADDER IS STORED AS xp_table SINCE 2026-09-26. Printed 183 heads the column "Silhouette,
    Draconid & Repo-Bots"; the import stored none because composition was then race-primary; an O.C.C.''s ladder has won a pairing since 2026-09-17, so a table here no longer would
    win over the occupation''s and silently drop it. The ladder is: 0, 2,201,
    4,401, 9,001, 19,001, 28,001, 40,001, 60,001, 80,001, 100,001, 150,001,
    200,001, 275,001, 350,001, 425,001. Read off a 250 dpi render of printed
    183 this session; it agrees band for band with the copy the Silhouette
    recorded in PR #411.
  - AN R.C.C. WITH RELATED AND SECONDARY SKILLS IS UNUSUAL BUT NOT WRONG, and
    the Machine People in this book are the same shape. The class-import rule
    that related and secondary skills come from the O.C.C. describes the common
    case; this book prints an R.C.C. Related Skills list for this race and it is
    imported as printed.
  - PSIONICS ARE NOT MENTIONED except through the psychic branch, so there is no
    psionics block and no `psionics_allowed`. A draconid who took that path has
    a mind melter''s powers through the occupation; one who did not rolls like
    anyone else. Absent and false are different statements and this race makes
    neither outright.
  - A natural M.D.C. creature, so there is no S.D.C. and no `men_of_arms`
    line. The book''s S.D.C./Hit Points line says draconids "become mega-damage
    creatures on Phase World and other dimensions with high P.P.E. levels",
    which is a setting rule about where they are, not a second pool.
  - The race states no Money, no Cybernetics and no standard equipment; all come
    from the O.C.C. if one is taken.
---

## Lore

Draconids are false reptilian humanoids. They look like lizard men, but for all
their scales they are mammals and bear live young. The resemblance that matters
is to dragons: like dragons they are creatures of magic, with great arcane and
psionic powers, and scholars have argued for centuries about why.

Some say a wizard or a god mixed dragons with humans, or perhaps Atlanteans.
Some of the draconids'' own creation legends put the race as the missing link
between the two. Others hold that they are an unrelated species that evolved
naturally in some alien dimension and merely converged on the shape.

An erect humanoid with a long reptilian snout, bat-wing shaped ears and a
short, almost vestigial tail. Large canine teeth, clawed hands and feet, no
wings at all. The scales run green, blue, red and every shade between those
three. In some places they are mistaken for demons, and the reaction to one is
about what a demon would get.

## Where they are

Draconids have spread through the Megaverse. They are far more numerous than
true dragons and still not widespread compared to other races, turning up in
small concentrations on Rifts Earth and at transdimensional ports like Atlantis
and Worldgate.

A great many were drawn to Phase World early in its history and stayed. They
are now part of the fabric of the city of Center and of the space stations
circling the planet, and members of the race sit among the city''s
administrators and guardians. Others live among the United Worlds of Warlock,
and others wander the cosmos as adventurers.

## Magic or the mind, decided before birth

Every draconid becomes a magician or a psychic. It is not a choice the
character makes and not a training the character undertakes - it is a
subconscious process that happens at birth, and it settles which of two very
large sets of powers the draconid will spend a three-thousand-year life with.

A magician gets everything a ley line walker has. A psychic gets everything a
mind melter has. Either way the draconid advances on its own experience table.

## Allies

Draconids on Phase World are in close alliance with the Promethean race. They
also work well with human and Wolfen wizards, with the Seljuk, and with Elves.
',
       updated_at = datetime('now')
 WHERE class_id = 'draconid'
   AND instr(markdown, 'The app cannot trim them, so leave them off') = 0
   AND length(markdown) = 11212;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 2 classes carry their new text' AS assertion, count(*) AS got, 2 AS want
  FROM imported_classes
 WHERE (class_id = 'maxi-killer' AND instr(markdown, '"hawrk-duhk", "hawrk-ka", "hawrk-ohl"]') > 0)
    OR (class_id = 'draconid' AND instr(markdown, 'The app cannot trim them, so leave them off') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'maxi-killer' AND instr(markdown, 'will start working by themselves if they are ever imported') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('maxi-killer', 'draconid') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~172-maxi-killer-races-and-draconid-pairing-note.sql');
