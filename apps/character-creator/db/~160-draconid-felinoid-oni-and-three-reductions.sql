-- Give the Draconid its magician-or-psychic pick, and six classes the reductions and Horror Factors their pages print
-- 6 classes, each replaced whole: draconid, felinoid, oni-of-the-one-hundred, wormspeaker, symbiotic-warrior, murder-wraith.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~160-draconid-felinoid-oni-and-three-reductions.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.
-- Close-out package C1, the first of Phase C: data that waited for code.
-- BOOK-INGEST-AUDIT F119 let a dice bonus be a reduction and let a chosen
-- ability carry a Horror Factor; F121 and F122 gave the Draconid its shape.
--
-- draconid (Phase World printed 36): the one prose "Magician or Psychic"
--   ability becomes a required pick-one group. Each option names its
--   occupation (occ_options) and carries its bonus (1D6x10 P.P.E., 1D4x10
--   I.S.P.); ppe_base is 1d6x10 and yields to a magic occupation; the race
--   keeps its own experience table in a pairing (keeps_xp_table).
-- felinoid (South America printed 109): the five strains' reductions become
--   signed dice, and the four larger cats restate Horror Factor 10.
-- oni-of-the-one-hundred (Japan printed 201): the twelve non-human head
--   shapes carry their Horror Factor bonus. Its tables are package C2.
-- wormspeaker, symbiotic-warrior (Wormwood printed 63, 64): -1D4 Spd.
-- murder-wraith (Juicer Uprising printed 51): -1D4 I.Q., M.E. and M.A.
--
-- Every figure was read off a page render and checked again by book-reconcile.
-- Production held no saved character on any of the six (queried 2026-10-05),
-- and no option that existed before is renamed except the Draconid's single
-- prose ability, which no character could have picked.
-- The Draconid also states horror_factor 10, which printed 35 prints and the
-- class held only as a natural-ability line.

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
  - { choose: 1, from: ["Other Powers: Magician", "Other Powers: Psychic"], note: "Other Powers (printed 36): every draconid becomes one or the other, by a subconscious process at birth. The pick names the occupation that carries the powers; take it on the Occupation step." }
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
   AND instr(markdown, 'unless the draconid took the magician path - see Other Powers') > 0
   AND length(markdown) = 10205;

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
    description: "Roll 76-82 or choose. The book gives the African lion 7%; the band is derived from that printed share. The second largest strain after the tiger. Applied: +2D6 P.S., +2D6 Spd, I.Q. reduced by 1D4, and Horror Factor 10 as one of the larger cats."
    horror_factor: 10
    bonuses: { attributes: { PS: "2d6", Spd: "2d6", IQ: "-1d4" } }
  - name: "Strain (83-87): African Leopard"
    description: "Roll 83-87 or choose. The book gives the African leopard 5%; the band is derived from that printed share. Applied: +1D6 P.P., +1D6 Spd, M.E. reduced by 1D6, and Horror Factor 10 as one of the larger cats."
    horror_factor: 10
    bonuses: { attributes: { PP: "1d6", Spd: "1d6", ME: "-1d6" } }
  - name: "Strain (88-92): Mountain Lion, Puma or Cougar"
    description: "Roll 88-92 or choose. The book gives the North American mountain lion, puma or cougar 5%; the band is derived from that printed share. Applied: +1D6 P.P., +1D6 P.E., M.A. reduced by 1D4, and Horror Factor 10 as one of the larger cats."
    horror_factor: 10
    bonuses: { attributes: { PP: "1d6", PE: "1d6", MA: "-1d4" } }
  - name: "Strain (93-95): Tiger"
    description: "Roll 93-95 or choose. The book gives the tiger 3%; the band is derived from that printed share. The largest of the cats, 7 to 8 feet (2.1 to 2.4 m). Applied: +2D6 P.S., +2D6 P.E., Spd reduced by 1D6, and Horror Factor 10 as one of the larger cats."
    horror_factor: 10
    bonuses: { attributes: { PS: "2d6", PE: "2d6", Spd: "-1d6" } }
  - name: "Strain (96-98): Ocelot, Serval or Caracal"
    description: "Roll 96-98 or choose. The book gives the small South American cats (ocelot, serval and caracal, the lynx family) 3%; the band is derived from that printed share. Rarely over 5 feet (1.5 m). Same stats as the jaguar, except M.E., P.S. and Spd are each reduced by 1D6, which the pick applies. Horror Factor 9."
    bonuses: { attributes: { ME: "-1d6", PS: "-1d6", Spd: "-1d6" } }
  - name: "Strain (99-00): Other"
    description: "Roll 99-00 or choose. The book gives 2% to other strains and names neither an animal nor a modifier for them; the band is derived from that printed share. Nothing is applied: the G.M. decides the animal and any changes."
restrictions:
  - "Alignment: any."
  - "Magic: none, unless a magic O.C.C. is taken."
  - "Cybernetics: starts with none. There are no cybernetic facilities in Omagua, and most felinoids disdain cybernetic, bionic, chemical and bio-wizard enhancements, even in an O.C.C. that would normally allow them."
  - "M.D.C.: by armor or magic only."
  - "Horror Factor 10 for the larger mutant cats (lion, leopard, puma, tiger), which the Strain pick states; 9 for the jaguar. The page prints none for the small cats, which have the jaguar''s stats, so 9."
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
    option carries its added dice as attribute bonuses and, since 2026-10-05
    (BOOK-INGEST-AUDIT.md F119), its REDUCTIONS as signed dice: I.Q. -1D4
    lion, M.E. -1D6 leopard, M.A. -1D4 puma, Spd -1D6 tiger, and M.E., P.S.
    and Spd -1D6 each for the small cats, all read off a render of printed
    109. The four larger cats (lion, leopard, puma, tiger) restate
    horror_factor as 10 on the option; which strains count as "the larger
    mutant cats" is the page''s own grouping ("the larger cats include" those
    four, the small cats are listed apart).
    Horror Factor 9 is the class''s; the option''s 10 replaces it while held.
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

The Totem Warrior pick is Jaguar only by the book; the app does not narrow the totem choice. The Strain pick applies each sub-strain''s added dice and its reductions, and shows Horror Factor 10 for the four larger cats.
',
       updated_at = datetime('now')
 WHERE class_id = 'felinoid'
   AND instr(markdown, 'Not applied, so do it by hand: reduce I.Q. by 1D4') > 0
   AND length(markdown) = 14640;

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
  - { choose: 1, from: ["Head (01-05): Wild Boar", "Head (06-15): Lion or Cat", "Head (16-30): Human", "Head (31-40): Skeletal Human", "Head (41-45): Monkey", "Head (46-55): Melon", "Head (56-60): Fish", "Head (61-65): Snake", "Head (66-70): Bird", "Head (71-80): Rotting Skeleton", "Head (81-90): Neanderthal", "Head (91-95): Fox or Canine", "Head (96-00): Rat"], note: "Oni Head Shape (printed 201), rolled once. The result adds to the Horror Factor of 11, and the pick adds it." }
  - name: "Head (01-05): Wild Boar"
    description: "Roll 01-05 or choose. The head of a wild boar. Applied: +2 Horror Factor (13)."
    horror_factor_bonus: 2
  - name: "Head (06-15): Lion or Cat"
    description: "Roll 06-15 or choose. The head of a lion or cat. Applied: +2 Horror Factor (13)."
    horror_factor_bonus: 2
  - name: "Head (16-30): Human"
    description: "Roll 16-30 or choose. A human head. No Horror Factor bonus (11)."
  - name: "Head (31-40): Skeletal Human"
    description: "Roll 31-40 or choose. A skeletal human head with sunken features. Applied: +2 Horror Factor (13)."
    horror_factor_bonus: 2
  - name: "Head (41-45): Monkey"
    description: "Roll 41-45 or choose. The head of a monkey. Applied: +1 Horror Factor (12)."
    horror_factor_bonus: 1
  - name: "Head (46-55): Melon"
    description: "Roll 46-55 or choose. A large head, round like a melon. Applied: +3 Horror Factor (14)."
    horror_factor_bonus: 3
  - name: "Head (56-60): Fish"
    description: "Roll 56-60 or choose. A fish-like head. Applied: +2 Horror Factor (13)."
    horror_factor_bonus: 2
  - name: "Head (61-65): Snake"
    description: "Roll 61-65 or choose. A snake-like head. Applied: +3 Horror Factor (14)."
    horror_factor_bonus: 3
  - name: "Head (66-70): Bird"
    description: "Roll 66-70 or choose. A bird-like head. Applied: +2 Horror Factor (13)."
    horror_factor_bonus: 2
  - name: "Head (71-80): Rotting Skeleton"
    description: "Roll 71-80 or choose. A human head that looks like a rotting skeleton. Applied: +4 Horror Factor (15)."
    horror_factor_bonus: 4
  - name: "Head (81-90): Neanderthal"
    description: "Roll 81-90 or choose. A larger, thicker human skull with heavy brow ridges and a square chin. Applied: +1 Horror Factor (12)."
    horror_factor_bonus: 1
  - name: "Head (91-95): Fox or Canine"
    description: "Roll 91-95 or choose. The head of a fox or other canine. Applied: +2 Horror Factor (13)."
    horror_factor_bonus: 2
  - name: "Head (96-00): Rat"
    description: "Roll 96-00 or choose. A rat-like head. Applied: +2 Horror Factor (13)."
    horror_factor_bonus: 2
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
extraction_notes: "Rifts World Book 8: Japan printed 199-203 (text layer, page_offset +1: cache p200-p204). General oni rules on printed 199-200 (cache p200 is WELDED and was checked against a render; the text layer reads cleanly in column order). The appearance tables run printed 201-202 (cache p202-p203). The stat block is Oni of the One Hundred (Lesser Oni) on printed 202, right column, continued to the top of printed 203 (habitat, war band, clan, village, enemies, allies), read off a render of printed 202. || NPC: the book''s note makes these primarily N.P.C. villains, a player character at the G.M.''s discretion; stated in restrictions and GM Notes. || XP: the ''Sura-Kappa, Oni of the One Hundred'' column on the Experience Point Tables page (cache p217, printed 216, read off a render; third column, middle): lower bounds 0 / 2,001 / 4,001 / 8,201 / 16,401 / 24,501 / 34,601 / 49,701 / 69,801 / 94,901 / 129,001 / 179,101 / 229,201 / 279,301 / 329,401. || GROUP: a race, so men_of_arms: false (heading Oni of the One Hundred (Lesser Oni), an R.C.C.). No supersedes_race: this is a race, not a transformation. || ATTRIBUTES: I.Q., M.E., M.A. 2D6; P.S. 22+2D6; P.P. 12+2D6; P.E. 16+2D6; P.B. 1D6; all supernatural (prose). Spd is not a fixed roll: it comes from the Oni Legs table (5D6 human legs 01-15, 4D6 monkey 16-25, 6D6+10 classic oni 26-50, 6D6 for 51-90, 3D6 snail trunk 91-00). Stored as 6D6, the result for 40% of rolls; a character with another leg type rerolls Spd by hand. || POOLS: M.D.C. 2D6x10+40, plus Other Features additions (prose). P.P.E. 5D6 for a typical warrior. No hit points or S.D.C. (mega-damage creature). No starting money or equipment is printed. || HORROR FACTOR 11 plus the head shape bonus (+0 to +4), carried since 2026-10-05 as horror_factor_bonus on each Head option (BOOK-INGEST-AUDIT.md F119) and read off a render of printed 201: +2 boar, lion/cat, skeletal, fish, bird, fox/canine and rat; +1 monkey and neanderthal; +3 melon and snake; +4 rotting skeleton; none for the human head. || COMBAT: four attacks per melee as attacks_base 4, plus one at levels 6 and 12 as at_level. No hand to hand skill is printed and no price for one, so no hand_to_hand block. Bonuses as printed: +1 initiative, +2 strike, parry and dodge, +2 pull punch, +1 roll with punch/fall/impact, +6 vs horror factor. Damage figures are a natural ability (prose). || MAGIC: four sets of natural powers, one chosen or rolled, up to 8 casts per 24 hours. Each set is a chosen special ability carrying its spells; Tongues, common to all four, is granted by the class. The 8 casts are a trackable resource. Spoil (food & water) is the catalog''s Spoil; animate/control dead is Animate and Control Dead; fly as the eagle and fire ball as catalogued. || SKILLS: catalog base + printed bonus: Intelligence 32+4, track humanoids as Tracking (people) 25+10, Land Navigation 36+15, Climbing 40+10, Swimming 50+10; W.P. Blunt, W.P. Sword and two W.P.s of choice (any). Japanese as Language: Native Tongue at 98%, Gobblely at 98%, Faerie as a Language: Other pick at 98% (no Faerie row), and two other languages (+10%) as Language: Other picks. Four secondary skills from espionage, physical, technical, rogue and wilderness, as printed on the race. || APPEARANCE: the oni creation tables (body shape, head, nose, eyes, mouth, arms and hands, legs, other features, skin color) are random appearance tables, nine of them on printed 201-202 under ''Roll once on each unless indicated otherwise'', paraphrased in the body. Since 2026-10-03 the five single-roll tables whose results carry a number are banded choose-1 groups in special_abilities: Head Shape (Horror Factor +0 to +4, as horror_factor_bonus), Mouth (bite damage, prose), Arms & Hands (hand damage as prose; +1 attack at 21-30 and 76-85 and +4 entangle at 96-00 as bonuses), Legs (Spd dice: +10 Spd at 26-50 as a bonus, the 5D6, 4D6 and 3D6 results as prose because a bonus takes no subtracted die) and Other Features (M.D.C. +35, +10, +20, +25, +10, +5, +10 as pool bonuses; head butt damage prose). Not groups: Nose and Eyes each hold a result that rolls again on the same table (71-80 tiny nose of any type above, 81-90 four eyes of a rerolled shape), which one pick cannot state; Body Shape and Skin Color are single rolls that carry no number. The four power-set options were renamed with their bands the same day so the wizard can roll them."
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
   AND instr(markdown, '+2 Horror Factor (13), added by hand.') > 0
   AND length(markdown) = 28217;

-- == wormspeaker ==
UPDATE imported_classes
   SET markdown = '---
id: wormspeaker
name: Wormspeaker
system: rifts
source_book: Rifts Dimension Book 1: Wormwood p.63-64
category: occ
tags: [augmented, divine]
occ_group: clergy
xp_table: [0, 2151, 4301, 8601, 18601, 26601, 36601, 54601, 75601, 99601, 135601, 185601, 240601, 290601, 343601]
mdc_base: "25, plus 1d6 per level of experience"
ppe_base: "2d4x10+30, plus 2d6 per level of experience"
bonuses:
  attributes: { PS: -2, PP: -2, ME: "1d6", MA: "1d4", Spd: "-1d4" }
  saves: { horror_factor: 3, possession: 3, spell_magic: 1 }
skills:
  occ_skills:
    - { name: "Sing", base: 55, per_level: 5, note: "+20%" }
    - { name: "Play Musical Instrument", base: 55, per_level: 5, note: "+20%" }
    - { name: "Lore: Demons & Monsters", base: 45, per_level: 5, note: "+20%; the book prints Lore: Monsters & Demons" }
    - { name: "Lore: Wormwood", base: 40, per_level: 5, note: "40% +5% per level; includes the history, legends and world information in this book" }
    - { name: "Mathematics: Basic", base: 75, per_level: 5, note: "+30%; the book prints Math: Basic" }
    - { name: "First Aid", base: 55, per_level: 5, note: "+10%" }
    - { name: "Land Navigation", base: 56, per_level: 4, note: "+20%" }
    - { name: "Wilderness Survival", base: 50, per_level: 5, note: "+20%" }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P.: One of choice" }
    - { name: "Hand to Hand: Basic" }
  occ_related_skills:
    count: 6
    categories:
      - { name: "Domestic", bonus: 10 }
      - { name: "Espionage" }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Boxing"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Air Assault Armor", "Combat Pod", "Military: Tanks & APCs", "Space: Small Spacecraft", "Space: Space Fighter", "Space: Starship"] }
      - { name: "Science", bonus: 15 }
      - { name: "Technical", bonus: 15 }
      - { name: "Weapon Proficiencies" }
      - { name: "Wilderness" }
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
magic:
  type: "spell"
  spells: ["Close an Opening", "Create an Opening", "Create a Fountain of Water", "Destroy Life Force Cauldron", "Locate Home Town", "Locate Places of Evil", "Remove Symbiotes", "Ride Giant Parasites", "Summon & Use Symbiotes", "Summon Edible Grubs"]
  spells_from: ["Close an Opening", "Control Temperature", "Create Life Force Cauldron", "Create Magic Slime", "Create Shelter", "Create Stairs", "Create Tunnel", "Create Wall", "Create Worm Zombies", "Create a Burial Place", "Create a Fountain of Water", "Create a Pillar", "Create an Opening", "Destroy Life Force Cauldron", "Heat Point", "Hell Fire", "Invisible to Magic Seeing", "Life Fuel", "Locate Food & Resources", "Locate Home Town", "Locate Places of Evil", "Mold Structures", "Open & Close Dimensional Rifts", "Remove Symbiotes", "Repel Symbiotes", "Ride Giant Parasites", "Summon & Use Stones & Crystals", "Summon & Use Symbiotes", "Summon Battle Saints & Orbs", "Summon Edible Grubs", "Summon Entities", "Summon Flies", "Summon Wind", "Summon and Command Parasites", "Summon and use Angel Hair", "Summon and use Spirits of Wormwood"]
  spells_schedule: [{ level: 2, count: 1 }, { level: 3, count: 1 }, { level: 4, count: 1 }, { level: 5, count: 1 }, { level: 6, count: 1 }, { level: 7, count: 1 }, { level: 8, count: 1 }, { level: 9, count: 1 }, { level: 10, count: 1 }, { level: 11, count: 1 }, { level: 12, count: 1 }, { level: 13, count: 1 }, { level: 14, count: 1 }, { level: 15, count: 1 }]
equipment_starting:
  - { item_id: "hooded-cloak", qty: 2 }
  - { item_id: "clothing", qty: 2, note: "Two shirts and two pairs of pants." }
  - { item_id: "boots", qty: 1 }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "sleeping-bag", qty: 1 }
  - { item_id: "blanket-light", qty: 1 }
  - { item_id: "small-sack", qty: 1, note: "The book says one medium size sack; the catalog has no medium." }
  - { choose: 1, label: "backpack or saddlebag", qty: 1, from: ["backpack", "saddlebags"] }
  - { item_id: "utility-belt", qty: "1d4" }
  - { item_id: "angel-hair-rope", qty: 1, note: "50 feet (15 m)." }
  - { item_id: "food-rations", qty: 1, note: "2D4 weeks of rations." }
  - { item_id: "worms-of-armor", qty: 1, note: "One set." }
  - { item_id: "worms-of-blood", qty: 12 }
  - { item_id: "worms-of-mending", qty: 20 }
  - { item_id: "worms-of-power", qty: 1 }
  - { item_id: "worms-of-seeing", qty: 1 }
  - { item_id: "worms-of-speech", qty: 1 }
  - { item_id: "worms-of-spirit", qty: 1 }
special_abilities:
  - name: "Meditation"
    description: "Focusing his thought in prayer regains spent P.P.E. at ten points per hour, against four points an hour of ordinary rest, and gives the wormspeaker the ability to pilot battle saints and battle saint orbs. It can also be used to double his own rate of healing."
  - name: "All of the Worm Symbiotes"
    description: "The wormspeaker starts with EVERY worm symbiote in the book: a set of worms of armor, twelve worms of blood, twenty worms of mending, and one each of the worm of power, seeing, speech and spirit. He can add one further symbiote at levels 3, 4, 5, 6 and 8 - a total of five, on top of the worms - and can also use symbiotic stones and crystals and the spirit of Wormwood."
  - name: "Horror Factor 11"
    description: "The wormspeaker frightens humans and monsters alike. The worms give him a repulsive and eerie appearance, most notably a tongue composed entirely of wiggling worms."
level_progression:
  - { level: 3, grants: ["One additional symbiotic organism"] }
  - { level: 4, grants: ["One additional symbiotic organism"] }
  - { level: 5, grants: ["One additional symbiotic organism"] }
  - { level: 6, grants: ["One additional symbiotic organism"] }
  - { level: 8, grants: ["One additional symbiotic organism"] }
restrictions: ["May never be of an evil alignment", "May never select Impervious to Symbiotes", "Cannot draw P.P.E. from other beings except by blood sacrifice or when it is offered freely by another wormspeaker or a priest", "Cybernetics and bionics are virtually non-existent"]
side_effects: "Penalties: reduce P.B. by 50%, to no lower than 2 - this already takes every symbiotic organism into account, so do not apply their penalties again - and -2 P.S., -2 P.P. and -1D4 Spd. The P.B. halving is not applied automatically; work it out by hand. The bonuses run the other way too: +1D6 M.E. and +1D4 M.A., plus all the bonuses from the symbiotic worms and organisms."
extraction_notes: "Money: the book states outright that money is Not applicable on Wormwood - valuables, weapons, food and services are exchanged by barter and a character is judged by his standing in the community - so no starting_money is stored. p.52 puts the wormspeaker fourth in the social hierarchy, just below the priest of light, and says some are regarded as highly as one. || Attribute changes: the flat ones and the POSITIVE dice are stored - -2 P.S., -2 P.P., +1D6 M.E. and +1D4 M.A. This note said bonuses.attributes could take none of the dice, which was false for the positive ones (RETRO-AUDIT R11, 2026-09-04). The -1D4 Spd is stored as a signed dice bonus since 2026-10-05 (BOOK-INGEST-AUDIT.md F119; printed 63, read off a render). The P.B. halving is not stored: see BOOK-INGEST-AUDIT.md F119, which adds reductions and no halving. It stays in side_effects and is worked out by hand. Storing an average would put a number in the sheet the book never prints. || THIS IS THE CLASS THAT DRAWS MOST HEAVILY ON #353. All seven worm symbiotes are issued as real item_ids rather than described, which is every worm row that PR imported. || Summon Edible Grubs: the description heading on p.63 prints Summon Edible Grubs & Worms, the p.83 authority list prints Summon Edible Grubs, and the catalog holds the list''s spelling. Same for Summon & Use Symbiotes, which p.63 prints as Summon and Use Symbiotes. The p.83 list is the authority for membership, per the survey. || The level-up list excludes Impervious to Symbiotes, which the book states outright. It does NOT exclude the life force cauldron, magic slime, life force battery or worm zombie prayers: the book says the wormspeaker WOULD NEVER CREATE those, which is disposition rather than a bar, and it says in the same breath that he might use a life force cauldron and magic slime for a good purpose. Those stay selectable and the disposition is recorded here. || Standard Equipment is at the TOP of p.64, above the Symbiotic Warrior''s own heading - the two classes'' equipment blocks sit on one page and class-check --field-sources shows both."
---

## Lore

The wormspeaker is born from the peasant class, the common man. He is not usually
affiliated with a specific church or kingdom and spreads no particular doctrine.
He rises from humble beginnings through the use of symbiotic organisms and a
closeness with the Living Planet itself. The people consider him a holy man and
an oracle who uses his knowledge and insight to help others - more a shaman or a
witch doctor than a priest. Highly regarded, protected and granted favors, few
wormspeakers ever become wealthy or hold power; the closest they come to a throne
is as advisor to a king or his court.

The class is usually referred to in the masculine because 95% are male, but women
can also become wormspeakers. They see glimpses of the future and sense the
presence of evil and magic. Their psionic powers come from a variety of
permanent, worm-like symbiotes, which give them a repulsive and eerie appearance
- most notably a tongue composed entirely of wiggling worms.

They draw their power through those symbiotes from the Living Planet, which makes
their relationship with Wormwood more genuinely symbiotic than any other
character''s. That union may be part of why a wormspeaker can never be evil. He
more than any other understands the plight and the pain of the living planet, as
well as that of the people.

## GM Notes

Alignment is any EXCEPT evil: 20% anarchist, 20% unprincipled, 20% principled and
40% scrupulous. The book ties this to the union with the planet rather than to
any vow, so it is a property of what the wormspeaker is, not a rule he could
break.

He starts with every worm symbiote in the book and adds five more organisms over
his career, so his sheet grows sideways rather than upward - most of what he can
do at tenth level is a list of things attached to his body. The P.B. penalty
already accounts for all of them; do not stack the individual symbiotes''
appearance penalties on top.

The book draws one sharp line and one soft one. The sharp line: he can never
learn Impervious to Symbiotes, which would sever him from the source of his own
power. The soft one: he would never create a life force cauldron, magic slime, a
life force battery or a worm zombie - but he might well use a life force cauldron
or magic slime for a good purpose. That is a character judgement, not a
prohibition, and it is where a wormspeaker''s morality gets interesting.
',
       updated_at = datetime('now')
 WHERE class_id = 'wormspeaker'
   AND instr(markdown, 'The P.B. halving and the Spd die are not applied automatically') > 0
   AND length(markdown) = 11140;

-- == symbiotic-warrior ==
UPDATE imported_classes
   SET markdown = '---
id: symbiotic-warrior
name: Symbiotic Warrior
system: rifts
source_book: Rifts Dimension Book 1: Wormwood p.64-65
category: occ
tags: [combat, augmented]
occ_group: men-of-arms
xp_table: [0, 1901, 3701, 7401, 14801, 22101, 31201, 41301, 54401, 75501, 105601, 140701, 190801, 240901, 292001]
mdc_base: "30, plus 1d6 per level of experience"
ppe_base: "1d4x10, plus 1d6 per level of experience"
bonuses:
  attributes: { ME: -1, Spd: "-1d4" }
  combat: { initiative: 1, pull_punch: 1, roll: 1 }
  saves: { horror_factor: 2, possession: 1 }
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "The book prints this as Language: American (98%)." }
    - { name: "Language: Gobblely", base: 98, per_level: 5, note: "98%" }
    - { name: "First Aid", base: 50, per_level: 5, note: "+5%" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { name: "Horsemanship: General", base: 45, per_level: 4, note: "+5%; the book grants all riding animals in general" }
    - { name: "W.P. Targeting" }
    - { name: "W.P. Knife" }
    - { name: "W.P. Sword" }
    - { choose: 3, categories: ["Weapon Proficiencies"], note: "W.P.: Three of choice" }
    - { name: "Hand to Hand: Expert", note: "Hand to Hand: Assassin instead, if the character is of an evil alignment." }
  occ_related_skills:
    count: 8
    categories:
      - { name: "Domestic", bonus: 10 }
      - { name: "Espionage", bonus: 5 }
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Air Assault Armor", "Combat Pod", "Military: Tanks & APCs", "Space: Small Spacecraft", "Space: Space Fighter", "Space: Starship"] }
      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced"] }
      - { name: "Technical", bonus: 5 }
      - { name: "Weapon Proficiencies", bonus: 5 }
      - { name: "Wilderness", bonus: 5 }
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
magic:
  type: "spell"
  spells: ["Close an Opening", "Create an Opening", "Locate Home Town", "Ride Giant Parasites"]
equipment_starting:
  - { choose: 1, label: "hooded cloak or cape", qty: 1, from: ["hooded-cloak", "cape"] }
  - { item_id: "clothing", qty: 2, note: "Two shirts and two pairs of pants." }
  - { item_id: "boots", qty: 1 }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "sleeping-bag", qty: 1 }
  - { item_id: "blanket-light", qty: 1 }
  - { item_id: "small-sack", qty: 1, note: "The book says one medium size sack. A medium sack row exists now (sack-medium); the class still stores the small sack." }
  - { choose: 1, label: "backpack or saddlebag", qty: 1, from: ["backpack", "saddlebags"] }
  - { item_id: "utility-belt", qty: "1d4" }
  - { item_id: "angel-hair-rope", qty: 1, note: "100 feet. The book prints (15 m), which is the metric figure for FIFTY feet; its other three warrior O.C.C.s print 100 feet (30.5 m)." }
  - { item_id: "grappling-hook", qty: 1 }
  - { item_id: "food-rations", qty: 1, note: "2D4 weeks of rations." }
special_abilities:
  - name: "Symbiotic Organisms"
    description: "The symbiotic warrior starts with one claw, one crawler, one star and one worm, each of his choice, and adds one more symbiote at levels 2, 4, 6, 8, 10 and 12. He may also acquire and use symbiotic stones and crystals, the spirit of Wormwood, worms of blood, worms of mending, and the potions and ointments made from magic slime."
  - name: "Horror Factor 10"
    description: "The symbiotic warrior has a horror factor of 10 and may frighten humans and monsters alike."
level_progression:
  - { level: 2, grants: ["One additional symbiotic organism"] }
  - { level: 4, grants: ["One additional symbiotic organism"] }
  - { level: 6, grants: ["One additional symbiotic organism"] }
  - { level: 8, grants: ["One additional symbiotic organism"] }
  - { level: 10, grants: ["One additional symbiotic organism"] }
  - { level: 12, grants: ["One additional symbiotic organism"] }
restrictions: ["Cannot select additional communion abilities as he grows in experience", "Not trained in the art of meditation", "Cybernetics and bionics are virtually non-existent"]
side_effects: "Penalties: -1 M.E. and -1D4 Spd, both applied by the class''s bonuses (Wormwood printed 64)."
extraction_notes: "Money: the book states outright that money is Not applicable on Wormwood - valuables, weapons, food and services are exchanged by barter and a character is judged by his standing in the community - so no starting_money is stored. This is a property of the setting, not a failed extraction. || The Standard Equipment line prints 100 feet of rope (15 m; made from angel hair). 100 feet is 30.5 m, and the other three warrior O.C.C.s in this book print 100 feet (30.5 m); the wormspeaker on p.63-64 prints 50 feet (15 m). The metric figure is the book''s own typo, and the FEET figure is transcribed. This script adds the angel-hair-rope catalog row the four warrior O.C.C.s all needed. || Pilot: the book excludes power armor, robots, tanks and spaceships. Only Pilot-category rows can be excluded from a Pilot pick, so tanks is Military: Tanks & APCs (which the catalog files under Pilot) and spaceships are the three Space craft rows. The robot combat rows and the two power armor suits are excluded on the same reading the Juicer Gladiator already uses for the same book phrase."
---

## Lore

A human or D-bee fighter who has given his body over to Wormwood''s symbiotic
organisms and fights with the powers they lend him. As a rule most of his
attributes are average or below - the symbiotes are what make him formidable,
not the man underneath. He is not a priest and not a mage, knows four prayers
and will never learn a fifth, and has never been trained to meditate.

Native humans of Wormwood have adapted to the energies of the living planet and
are mega-damage creatures in P.P.E. rich environments such as Wormwood and
Rifts Earth. In an environment that is not magic rich, the warrior''s M.D.C. is
S.D.C. instead.

Most are anarchist, unprincipled or scrupulous. The symbiotic warrior sits at
the low end of Wormwood''s social scale, and the horror of what rides on his
body is part of why.

## GM Notes

Dark Symbiotic Warriors are employed by the Forces of Darkness. The only real
difference between them and a player character is their black hearts and evil
alignment - the class is otherwise identical, which makes it a ready-made
antagonist.

The horror factor of 10 cuts both ways: it frightens humans as readily as
monsters, and the knights of the Temple and the priests of light look down on
anyone carrying symbiotes at all.
',
       updated_at = datetime('now')
 WHERE class_id = 'symbiotic-warrior'
   AND instr(markdown, 'The Spd loss is a die roll and is not applied automatically') > 0
   AND length(markdown) = 6920;

-- == murder-wraith ==
UPDATE imported_classes
   SET markdown = '---
id: murder-wraith
men_of_arms: false
name: Murder-Wraith
system: rifts
source_book: Rifts World Book 10: Juicer Uprising p.50-53
category: rcc
tags: [combat, augmented, supernatural, evil]
hit_points_base: "the former body''s S.D.C. and hit points COMBINED - most Juicers have hundreds of S.D.C. and 30+ hit points. For a Mega-Juicer, multiply his M.D.C. by two. Neither pool ever rises again: experience level is frozen at the moment of death."
ppe_base: "P.E. x2"
bonuses:
  attributes: { PS: "1d4+2", IQ: "-1d4", ME: "-1d4", MA: "-1d4" }
  saves: { spell_magic: 2, psionics: 2, horror_factor: 10 }
natural_abilities:
  - name: "Horror Factor: 14"
    description: "And alignment is diabolic 90% of the time, miscreant the other 10%. There is no good Murder-Wraith."
  - name: "Retains Every Juicer Power"
    description: "All the Juicer powers, bonuses and abilities of the previous life carry over. The bio-comps fuse magically with the body, and the creature never needs another drug or chemical to keep them - the one Juicer in this book with no supply problem, because it is already dead."
  - name: "Supernatural Attributes"
    description: "Strength and endurance become supernatural if they were not already. Use the original Juicer''s attributes, then subtract 1D4 from I.Q., M.E. and M.A., add 1D4+2 to P.S., and reduce Physical Beauty BY TWO-THIRDS. Damage follows the supernatural strength table reprinted in the Titan Juicer entry."
  - name: "Invulnerability"
    description: "Non-magical weapons and attacks do NO damage at all - including M.D. energy weapons and plasma bolts. Powerful explosions and mega-damage attacks may knock a Murder-Wraith down; they do not hurt it. It carries M.D.C. by worn armour only, and many do not bother with armour."
  - name: "Regeneration"
    description: "Regenerates 3D6 hit points at the END OF EVERY MELEE ROUND. The only way to destroy one is to drive it to negative 10 hit points, at which point it crumbles into dust and ceases to exist."
  - name: "Energy Vampirism and Cannibalism"
    description: "Needs both P.P.E. and the flesh of thinking beings to survive - at least 10 P.P.E. and one pound of human or D-Bee flesh a week, and it can store up to ten weeks'' worth by consuming that much in a day. P.P.E. is absorbed ONLY by touching a victim who is in pain, which is why most Murder-Wraiths torture their prey or eat them alive: 1D6 P.P.E. per round of pain, up to the victim''s total. The drain is neither permanent nor lethal in itself, but survivors must save versus insanity or take a permanent derangement (01-33 roll on the random insanity table, 34-67 phobia of Murder-Wraiths or all undead, 68-00 obsession with destroying them). Miss either the flesh or the P.P.E. and its own pool drops by one point per day; exhaust it through starvation and the creature dissolves into a pile of goo."
  - name: "Frozen"
    description: "Experience level, skills and skill percentages are all fixed at the moment of death and never improve. Whatever the Juicer knew is what the Murder-Wraith knows, forever."
  - name: "Life Span"
    description: "Unknown, and presumed eternal - or until something destroys it."
restrictions: ["NPC VILLAIN. The book says outright that this is not recommended as a player character.", "Must have been an evil Juicer in life.", "Dragon Juicers, all other techno-wizard and bio-wizard variants, and Psycho-Stalkers CANNOT become Murder-Wraiths - their magical or psychic abilities prevent the necromantic ritual from taking effect.", "No psionic powers. Any the Juicer had in life are lost.", "No magic powers.", "Vulnerable to silver, to magic weapons and mega-damage magic (full damage), to supernatural hand to hand attacks (one M.D. point inflicts one hit point), to S.D.C. magic at half damage, and to holy and rune weapons that punish undead at double damage or their usual vampire bonus, whichever is higher."]
extraction_notes: "MODELLED AS AN R.C.C. AND NOT AN O.C.C., which is what the book prints: it has R.C.C. Skills, a Horror Factor, Natural Abilities and a Vulnerabilities section, and its skills are the former life''s rather than a training programme. An R.C.C. granting no related and no secondary skills is correct rather than missing data, and here it is the point - the skills are frozen. The book''s I.Q., M.E. and M.A. penalties (-1D4 each, printed 51, read off a render) are stored as signed dice bonuses since 2026-10-05 beside the +1D4+2 to P.S. (BOOK-INGEST-AUDIT.md F119). The two-thirds cut to P.B. is not stored and stays prose. Hit points are a formula in words for the same reason: the pool is read off the character the Murder-Wraith used to be, which nothing in the app can compute. This class is published so it can be built and put on a sheet, which is how a GM uses an NPC - the NPC warning is in restrictions and in the prose, where a player will see it."
---

## Lore

Rifts Earth has produced two kinds of techno-wizard Juicer. One is alchemical -
the Dragon Juicer, made with dragon''s blood in Kingsdale. The other is
necromantic.

Murder-Wraiths are men and women who worshipped the embodiment of Death itself
and let themselves be made into undead monsters with no shred of humanity left.
They are the work of the most vile and extreme members of the Federation of
Magic and other foul sorcerers, and most are in the service of a Necromancer or
a death cult like the Grim Reapers - working alongside zombies, skeletons and
other undead, and the occasional vampire, demon or supernatural predator.

They are not made against their will. Every Murder-Wraith volunteered, and
committed horrible crimes to qualify. For the most part they are beyond
redemption, as bad as a master vampire and every bit as willing.

What they get for it is a body that most weapons simply cannot hurt, that heals
3D6 hit points every fifteen seconds, that keeps every Juicer power it ever had
without needing another dose of anything, and that will never grow old.

What they pay is everything else. A Murder-Wraith cannot learn. Its experience
level froze at the moment it died, and it will know exactly what it knew that
day for however long eternity turns out to be. And it must eat: ten P.P.E. and a
pound of human flesh a week, and the P.P.E. only comes out of someone who is in
pain.

## GM Notes

**The book calls this an NPC villain and means it.** It is here so a GM can
build one, roll it, and put it on a sheet - not as an option for the table.

**Invulnerability is not a difficulty setting, it is a puzzle.** Energy weapons,
plasma, rail guns and explosives do nothing. Silver does full damage. Magic does
full damage. A supernatural fist does one hit point per M.D. point. Holy and
rune weapons that punish undead do double. A party that has none of those cannot
hurt a Murder-Wraith at all, and 3D6 regeneration per round means it does not
matter how long they try.

**It has to be driven to -10 hit points**, not zero, against 3D6 healing every
round. That is the whole fight.

**The starvation clock is the humane way out.** Cut a Murder-Wraith off from
P.P.E. and flesh and it loses a point a day until it dissolves. Trapping one is
a legitimate victory, and a much more achievable one than killing it.

**Note who cannot become one.** Dragon Juicers, Psycho-Stalkers and every
bio-wizard variant are immune to the ritual - their magic or psionics get in the
way. Murder-Wraiths are made from the mundane Juicers: the standard, the
Hyperion, the Titan, the Phaeton, the Mega, the Delphi, the Coalition.
',
       updated_at = datetime('now')
 WHERE class_id = 'murder-wraith'
   AND instr(markdown, 'because the bonuses block takes additions') > 0
   AND length(markdown) = 7450;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 6 classes carry their new text' AS assertion, count(*) AS got, 6 AS want
  FROM imported_classes
 WHERE (class_id = 'draconid' AND instr(markdown, 'keeps_xp_table: true') > 0)
    OR (class_id = 'felinoid' AND instr(markdown, 'IQ: "-1d4"') > 0)
    OR (class_id = 'oni-of-the-one-hundred' AND instr(markdown, 'horror_factor_bonus: 4') > 0)
    OR (class_id = 'wormspeaker' AND instr(markdown, 'Spd: "-1d4"') > 0)
    OR (class_id = 'symbiotic-warrior' AND instr(markdown, 'Spd: "-1d4"') > 0)
    OR (class_id = 'murder-wraith' AND instr(markdown, 'IQ: "-1d4", ME: "-1d4", MA: "-1d4"') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'draconid' AND instr(markdown, 'unless the draconid took the magician path - see Other Powers') > 0)
    OR (class_id = 'felinoid' AND instr(markdown, 'Not applied, so do it by hand: reduce I.Q. by 1D4') > 0)
    OR (class_id = 'oni-of-the-one-hundred' AND instr(markdown, '+2 Horror Factor (13), added by hand.') > 0)
    OR (class_id = 'wormspeaker' AND instr(markdown, 'The P.B. halving and the Spd die are not applied automatically') > 0)
    OR (class_id = 'symbiotic-warrior' AND instr(markdown, 'The Spd loss is a die roll and is not applied automatically') > 0)
    OR (class_id = 'murder-wraith' AND instr(markdown, 'because the bonuses block takes additions') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('draconid', 'felinoid', 'oni-of-the-one-hundred', 'wormspeaker', 'symbiotic-warrior', 'murder-wraith') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~160-draconid-felinoid-oni-and-three-reductions.sql');
