-- The Morphworm R.C.C., Rifts Dimension Book 1: Wormwood p.129-131.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-morphworm-class.sql
--
-- Its own stat block says "Experience Level: Not applicable" and printed 157
-- gives it an XP LADDER anyway, shared with the rumbler and the holy terror.
-- The ladder wins: it is the authority table for what is playable, and it is
-- what makes this race importable at all. The Not applicable line belongs to
-- the NPC villain listing above it.
--
-- Magic: the book gives 2D4 spells from each of levels one, two and three, 1D4
-- from each of four and five, and one each from six and seven - 6D4+2, whose
-- average is 17. spells_starting is stored at the more conservative 15 and the
-- exact per-level quota is in extraction_notes, because the frontmatter cannot
-- express a quota per spell level. The gate, spell_levels_allowed [1..7], IS
-- exact and is what really bounds the selection.
--
-- The book's "80% are low level practitioners of magic" is not modelled: a
-- fifth of morphworms have no magic at all, which is a roll at creation rather
-- than a property of the class.
--
-- p.129 opens with the tail of the FEATHERED SERPENT, which is NPC-only. The
-- morphworm starts partway down that page.
--
-- Hand-transcribed from the OCR cache (the scan has no text layer) and
-- validated with scripts/class-check.mjs --remote before this file was written.
--
-- AN R.C.C. IS A RACE, so related and secondary skills come from the O.C.C. and
-- zero of each is CORRECT rather than missing. The holy terror in this same PR
-- is the exception that proves it: the book prints eight related and four
-- secondary on its own pages, so those ARE transcribed. The rule guards against
-- inventing them, not against reading them.
--
-- No sdc_base anywhere: every one of these is a mega-damage creature and
-- carries mdc_base, so none needs a CORE_SDC_BY_CLASS entry. A racial S.D.C.
-- would be a POOL BONUS and never sdc_base.
--
-- Attacks are stored as combat.attacks_base, which REPLACES the default of two,
-- because these creatures state a total rather than a bonus. The per-level
-- additions are at_level entries.
--
-- Money: no starting_money anywhere. Every class in this book prints
-- "Money: Not applicable" - Wormwood barters.
--
-- Pure ASCII, LF endings: the whole file, comments included.


-- The class itself. INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE,
-- so re-running the script is a no-op instead of a silent partial write.
--
-- Every apostrophe inside the markdown is doubled.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'morphworm', 'Morphworm', 'rifts', '---
id: morphworm
name: Morphworm
system: rifts
source_book: Rifts Dimension Book 1: Wormwood p.129-131
category: rcc
attribute_dice:
  IQ: "2d6+10"
  ME: "2d6+10"
  MA: "2d6+10"
  PS: "3d6+10"
  PP: "2d6+10"
  PE: "3d6+10"
  PB: "1d4"
  Spd: "4d6+6"
mdc_base: "1d6x100"
ppe_base: "4d6x10"
bonuses:
  combat: { attacks_base: 3, initiative: 3, strike: 3, parry: 3, dodge: 2, roll: 3, pull_punch: 3 }
  saves: { horror_factor: 6, spell_magic: 3, illusionary_magic: 5 }
  at_level:
    - { level: 5, combat: { attacks: 1 } }
    - { level: 9, combat: { attacks: 1 } }
    - { level: 14, combat: { attacks: 1 } }
skills:
  occ_skills:
    - { name: "Language: Demongogian", base: 98, per_level: 5, note: "98%" }
    - { name: "Language: Gobblely", base: 98, per_level: 5, note: "98%" }
    - { name: "Language: Dragonese", base: 98, per_level: 5, note: "98%" }
    - { name: "Language: Ancient Greek", base: 98, per_level: 5, note: "98%; the book calls it Atlantean (ancient Greek)" }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "The book prints this as American (98%)." }
    - { name: "Literacy: Dragonese/Elven", base: 90, per_level: 5, note: "Reads and writes Dragonese at 90%. It also reads runes and magic symbols at 40%, which the catalog has no row for." }
    - { name: "Land Navigation", base: 41, per_level: 4, note: "+5%" }
    - { name: "Prowl", base: 30, per_level: 5, note: "+5%" }
    - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }
    - { name: "Disguise", base: 45, per_level: 5, note: "+20%" }
    - { name: "Intelligence", base: 42, per_level: 4, note: "+10%" }
    - { name: "Streetwise", base: 30, per_level: 4, note: "+10%" }
    - { name: "Anthropology", base: 25, per_level: 5, note: "+5%" }
    - { name: "Lore: Demons & Monsters", base: 35, per_level: 5, note: "+10%" }
psionics:
  type: "minor"
  isp_base: "6d6x2"
  powers: ["Mind Block", "Presence Sense", "Empathy", "Death Trance", "Alter Aura"]
magic:
  type: "spell"
  spells_starting: 15
  spell_levels_allowed: [1, 2, 3, 4, 5, 6, 7]
natural_abilities:
  - { name: "Metamorphosis", description: "The morphworm assumes the shape of humans, D-bees or large mammals - tiger, wolf, horse - for a MAXIMUM OF 20 MINUTES PER HOUR. Its purpose is to hunt unsuspecting prey and to escape: the worm can stalk prey in the middle of a herd or a community without detection, and in many cases lives among the very creatures it preys on. It can take the form of a beautiful female or handsome male of a species to lure a member of the opposite sex into its clutches. P.B. is 1D4 in its natural worm form and can be raised as high as 22 by metamorphosis." }
  - { name: "Dimensional Teleport", description: "70%, twice per 24 hours, back to its homeworld or another familiar place." }
  - { name: "Nightvision", description: "200 feet (61 m), and it sees the invisible." }
  - { name: "Swimming", description: "90%, and it survives depths of up to two miles. It can hold its breath and slow its metabolism for 20 minutes." }
  - { name: "Impervious to Poison and Disease", description: "Entirely." }
  - { name: "Bio-Regeneration", description: "1D4x10 M.D.C. once per minute (four melee rounds) - but spending that energy six or more times makes the creature hungry, and after THIRTEEN it lapses into a feeding frenzy. It regenerates severed limbs within 24 hours, and needs to eat a human-size prey for the extra energy." }
  - { name: "Engulf and Digest", description: "The long snake-like body unravels into dozens of tentacles that hold and pull prey - usually still alive - inside the body, which reforms around it. Powerful stomach acids kill and dissolve it, and the body unravels again to toss out the skeletal remains. Prey usually dies within 1D4 minutes of being engulfed; a human-size creature takes 24 HOURS to dissolve completely, and throughout that time the worm is sluggish: speed, all combat bonuses and melee actions are HALVED and skills are at -40%." }
  - { name: "Learn New Languages", description: "The morphworm learns two new languages (+25%) whenever it arrives on a new world, reaching 75% proficiency within two months and 90% within six." }
special_abilities:
  - name: "The Hunger"
    description: "A morphworm must eat a human-size animal once a week. ON THE SIXTH DAY it starts to feel hungry and finds it hard to concentrate: -25% on skills, and friends and allies begin to look like a tasty morsel. To avoid eating its allies it will usually run off to hunt less personal prey. BY THE SEVENTH DAY it is insane with hunger, blinded by a frenzy that nothing but feasting will quell - it cannot recognize friend or foe or think clearly, and it will keep lashing out with murderous intent at anybody in its way even after engulfing prey, because it does not regain its senses until the food is fully digested. It can survive up to EIGHT WEEKS without eating, but stays a crazed murderous animal until it has consumed one human-size prey for every week of starvation. Some owners of gladiatorial arenas deliberately keep morphworms undernourished to make them mindlessly aggressive combatants."
restrictions: ["A player character cannot have an alignment better than scrupulous - anarchist or aberrant are more likely", "Body armor: none, unless in disguise"]
side_effects: "Madness from hunger, and they are greedy and deceitful besides. Both P.S. and P.E. are supernatural, which the sheet does not model. Hit points in an S.D.C. environment are 1D4x1000. Damage: bite 4D6 M.D.; a strike from the spiny end of the tail adds 1D6 M.D. on top of the supernatural P.S."
extraction_notes: "Related and secondary skills: NONE, correct rather than missing. This is an R.C.C. || Magic: the book says 80% are low level practitioners of magic - level 1D4, usually spell casters or shifters - and few ever advance beyond fourth level ability. Spell selection is 2D4 spells from each of levels one, two and three, 1D4 from each of levels four and five, and one each from levels six and seven. That totals 6D4+2, whose average is 17; spells_starting is stored at 15 as the more conservative figure and the exact per-level breakdown is here, because the frontmatter cannot express a per-spell-level quota. THE SPELL LEVEL GATE (1-7) IS EXACT and is what actually bounds the selection. || The 80% clause is not modelled: a fifth of morphworms have no magic at all, which is a die roll at creation rather than a class property. || Psionics: 6D6x2 I.S.P., minor, powers limited to the five named, so powers_starting is absent and all five are granted. || Experience Level in the book reads Not applicable, but p.157 DOES give the morphworm an XP ladder, shared with the rumbler and the holy terror. The ladder is the authority - it is what makes this race importable - and the Not applicable line refers to the NPC villain listing rather than to a player character. || Money: no starting_money; Special vehicle is None to start. || Reading runes and magic symbols at 40% has no catalog row and is recorded on the Literacy note rather than invented. || NO xp_table IS STORED, AND THAT IS THE REPO INVARIANT RATHER THAN A GAP. regression.mjs pins the check that no R.C.C. carries one - a race has no experience table because experience comes from what you do, and the composition fix in #222 depends on it. p.157 DOES print a ladder for this race, and it is what made the race importable at all, so the numbers are recorded here rather than lost: Morphworm, Rumbler & Holy Terror: 0 / 2,901 / 4,801 / 9,601 / 19,201 / 29,201 / 49,001 / 79,001 / 119,001 / 169,001 / 230,001 / 300,001 / 380,001 / 470,001 / 600,001. A character levels on its O.C.C.s table, or on DEFAULT_XP_TABLE in js/leveling.js when played as a race alone - the same delegation the Norse Giant records."
---

## Lore

Morphworms are hideous monsters who feed on humans, D-bees and mammals. The body
is long and snaking and covered in fine scales, with two prehensile tentacles
toward the head that serve as arms and hands, a pair of large emerald green eyes
and a gaping mouth.

They are experienced dimensional travelers who have visited Earth and many other
worlds over the centuries, and are usually taken for menacing demons or
conquering fiends. At times a morphworm shows great curiosity, intelligence,
compassion and self control. When it is hungry it becomes a slobbering monster
obsessed with feeding, and during that frenzy it will attack its dearest friends
and allies. A while after devouring its victim it regains self-awareness and may
regret the act - but there was nothing it could do to stop itself.

Even fed and content, most morphworms are selfish or evil creatures who crave
knowledge, power and self-gratification, and few are ever entirely trustworthy or
sincere. Most are loners who prefer to operate away from other morphworms. Many
establish a power base on some other world and may even rule a small kingdom;
others attach themselves to more powerful beings such as the Unholy, riding on
their coattails toward the power, wealth or excitement they want.

## GM Notes

Most morphworms are supernatural villains and not intended as a common player
character. A player character must be a renegade and a traitor: captured by the
Forces of Darkness, the worm is tortured and killed, or made to live out its life
in madness and hunger in the gladiatorial arena. A good-aligned morphworm is a
true oddity - perhaps one in fifty million - but even a self-serving anarchist
makes an interesting and dangerous companion. Start at first or second level, and
no better than scrupulous.

**The hunger is the character.** It is a weekly clock the G.M. controls, and it
turns the party''s ally into the party''s problem on a schedule everyone at the
table can see coming. The sixth day is the warning; the seventh is not a choice
the player gets to make. A morphworm who has just fed is sluggish for a full day -
half speed, half attacks, half bonuses, -40% skills - which means the cost of
feeding lands immediately after the danger of not feeding passes.

About 70% on Wormwood are sworn to the Unholy, fewer than 2% to the Champions of
Light, and all the rest are free agents looking for trouble. They live 2000 years.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'morphworm');


-- Read the result back rather than trusting the exit code. d1-apply prints
-- these, and a CR in the stored markdown means the checkout mangled the file.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'morphworm';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-morphworm-class.sql');
