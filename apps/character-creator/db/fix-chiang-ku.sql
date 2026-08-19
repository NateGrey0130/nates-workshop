-- Chiang-Ku Dragon corrected against Dragons and Gods, p.22-23.
--
-- The numbers were right: every attribute die, both stages' hit points, S.D.C.
-- and P.P.E., the natural A.R., the Horror Factor and the I.S.P. formula all
-- match the book. The import did well on those. What it got wrong was the
-- application of bonuses.
--
--   Skill bonuses were recorded as prose, not numbers. Art, writing, disguise,
--   holistic medicine, climbing, faerie lore and demon & monster lore each sat
--   in a `note` with no `base`, so every one fell back to the catalog value and
--   the bonus was lost. Climbing read 40 where the book gives 50; faerie lore
--   read 25 for 40.
--
--   Psionics granted six powers. The book gives SEVEN, from one category.
--
--   "Knows all domestic skills at 80" was a five-of-five choice group, which
--   made the player tick five boxes to receive skills the book simply grants.
--
--   The three bonus languages pointed at Communications, which after the
--   duplicate merge holds radios and surveillance gear rather than languages.
--
-- Guarded on the old prose-only Art entry, so re-running is a no-op.
--
-- Still not expressible, and documented rather than faked:
--   +2 pull punch (adult) and +3/+1 save vs illusionary magic - derive.js has
--     no key for either, so a bonus written here would do nothing.
--   Seven powers from ONE category - powers_starting sets the count, but a
--     class cannot state the single-category restriction the book gives.
--   Two more psi-powers at levels 3, 6, 9 and 12 - only skills have schedules.
--   A hatchling's advanced math starts at first level, not 96 - variants
--     cannot override skills, only dice, pools and bonuses.

UPDATE imported_classes
   SET markdown = '---
id: chiang-ku-dragon
name: Chiang-Ku Dragon
system: palladium-fantasy
source_book: dragons-and-gods
category: rcc
variants:
  - id: hatchling
    name: "Chiang-Ku Hatchling"
    attribute_dice:
      IQ: "3d6+4"
      ME: "3d6+4"
      MA: "3d6+4"
      PS: "3d6+4"
      PP: "2d6+3"
      PE: "2d6+3"
      PB: "2d6+3"
      Spd: "3d6+4"
    hit_points_base: "1D4x100 in human form, plus 100 when in serpent form"
    sdc_base: "2D6x10 plus 3D6 per level of experience"
    ppe_base: "2D4x10+20"
    bonuses:
      combat: { parry: 1 }
      saves: { spell_magic: 1, ritual_magic: 1, horror_factor: 2 }
  - id: adult
    name: "Adult Chiang-Ku"
    attribute_dice:
      IQ: "3d6+12"
      ME: "3d6+12"
      MA: "3d6+12"
      PS: "3d6+12"
      PP: "2d6+10"
      PE: "2d6+10"
      PB: "2d6+10"
      Spd: "3d6+12"
    hit_points_base: "3D4x100+1000 when in natural serpent form (only 3D4x100 when in humanoid form)"
    sdc_base: "4D6x100"
    ppe_base: "2D4x100+200 plus P.E. attribute number"
    bonuses:
      combat: { initiative: 1, strike: 1, parry: 2, dodge: 2, roll: 2 }
      saves: { psionics: 1, spell_magic: 2, ritual_magic: 2, horror_factor: 4 }
skills:
  occ_skills:
    - { name: "Basic Math", base: 96 }
    - { name: "Advanced Math", base: 96 }
    - { name: "Cook", base: 80, per_level: 5 }
    - { name: "Dance", base: 80, per_level: 5 }
    - { name: "Fishing", base: 80, per_level: 5 }
    - { name: "Play Musical Instrument", base: 80, per_level: 5 }
    - { name: "Sewing", base: 80, per_level: 5 }
    - { name: "Language: All (magical)", base: 98, note: "Magically understands and speaks all languages." }
    - { name: "Literacy: Dragonese/Elven", base: 98 }
    - { choose: 3, categories: ["Technical"], base: 80, per_level: 5, note: "Three other languages of choice, at least one human (+30%). The catalog has no individual language rows, so this offers the Technical category; pick languages." }
    - { name: "Art", base: 45, per_level: 5, note: "+10% O.C.C. bonus" }
    - { name: "Writing", base: 35, per_level: 5, note: "+10% O.C.C. bonus" }
    - { name: "Disguise", base: 30, per_level: 5, note: "+5% O.C.C. bonus" }
    - { name: "Holistic Medicine", base: 30, per_level: 5, note: "+10% O.C.C. bonus" }
    - { name: "Climbing", base: 50, per_level: 5, note: "+10% O.C.C. bonus" }
    - { name: "Lore ' || char(8212) || ' Faerie", base: 40, per_level: 5, note: "+15% O.C.C. bonus" }
    - { name: "Lore: Demons & Monsters", base: 30, per_level: 5, note: "+5% O.C.C. bonus" }
    - { name: "Land Navigation", base: 36, per_level: 4 }
    - { name: "Wilderness Survival", base: 30, per_level: 5 }
    - { name: "Streetwise", base: 20, per_level: 4 }
    - { choose: 3, categories: ["Science"] }
    - { choose: 3, categories: ["Technical"], note: "Scholar/Technical" }
    - { choose: 3, categories: ["Weapon Proficiencies"], note: "Three ancient weapon proficiencies of choice" }
    - { choose: 3, categories: ["Weapon Proficiencies"], note: "Three modern weapon proficiencies of choice" }
psionics:
  type: "major"
  isp_base: "3D4x10 + M.E. attribute number"
  powers_starting: 7
  categories_allowed: ["Healing", "Physical", "Sensitive"]
natural_abilities:
  - name: "Impervious to Poison, Toxins, Drugs, and Gases"
    description: "The Chiang-Ku is unaffected by these substances."
  - name: "Nightvision"
    description: "90 ft (27.4 m)."
  - name: "See the Invisible"
    description: "Can perceive normally invisible creatures and objects."
  - name: "Fire and Cold Resistant"
    description: "Takes half damage from fire and cold based attacks."
  - name: "Dimensional Teleport"
    description: "90% chance of success. Note: ordinary (non-dimensional) teleportation and breath weapons are NOT among the powers of the Chiang-Ku."
  - name: "Instinctive Dimensional Magic"
    description: "An innate understanding and use of dimensional magic."
  - name: "Bio-Regeneration"
    description: "Recovers 1D4x10 S.D.C./hit points every five minutes."
  - name: "Natural Armor Rating"
    description: "Natural A.R. is 14 for an adult and 11 for a hatchling."
  - name: "Horror Factor"
    description: "13 for an adult, 9 for a hatchling."
special_abilities:
  - name: "Exceptional Metamorphosis"
    description: "A power of metamorphosis common to most dragons, but no other dragon possesses the degree of control and duration as the Chiang-Ku. Even as a hatchling, the dragon is a shapechanger supreme, able to completely alter its physical shape to look like any living animal, from human being to raven, and can even turn into mist (same as the spell). The transformation lasts indefinitely (mist has the same limits as the spell) ' || char(8212) || ' weeks, months, or years! Even when rendered unconscious or sleeping, the Chiang-Ku retains its false shape. Only coma or death will transform the dragon into its true serpentine body. The dragon''s shape-changing prowess is so great that it can try to copy/imitate a particular person or specific animal at a skill proficiency of 10% +5% per level of experience."
  - name: "Attacks Per Melee (Adult)"
    description: "Equal to basic hand to hand combat and varies with the level of experience. The magic tattoos automatically provide one additional attack per melee round."
  - name: "Damage"
    description: "Varies with supernatural P.S. or by magic or weapon. The tail has no extra abilities and cannot be used in combat."
  - name: "Magic Knowledge"
    description: "The Chiang-Ku are born with a full understanding of magic and some say, a secret, lost mystic art that they never share with others and seldom use (tattoo magic and the creation of the Elixir of Power and Deceit; see Rifts Atlantis and England). The Chiang-Ku never uses these powers on the Palladium World because their secrets were lost during the Time of a Thousand Magicks and even hints of them were destroyed during the Millennium of Purification. Even using the magic tattoos may entice somebody to attempt to figure out/develop the magic, so most Chiang-Ku never use them even in a life and death situation; only miscreant and diabolic dragons may consider their use. While most Chiang-Ku won''t use tattoo magic, all have at least a half dozen tattoos on their bodies, including the Marks of Heritage mystic symbol of the Eye of Knowledge."
  - name: "Study of Mystic Arts"
    description: "The hatchling knows no spell magic unless they study the arts of wizardry, but can intuitively use all types of magic devices without instruction, can read magic, use scrolls, and recognize magic circles, rune weapons and enchantment. Most study one form of mystic art: 50% Wizardry, 20% Diabolism, 20% Summoning, 5% other (an alien magic, or Necromancy, or Warlock, or is a nonmagical scholar). Adult Chiang-Ku Wizards of 8th level or higher experience are likely to know all spells from levels 1-9 plus 2D4 higher spells. Wizards higher than 15th level will also know all spells from levels 1-15 and many Spells of Legend (G.M.''s discretion)."
restrictions:
  - "Weaker with less hit points when in humanoid form, and generally has less hit points and S.D.C. than many of its brethren."
  - "The Chiang-Ku''s curiosity and compassion for others frequently gets the creature into trouble."
extraction_notes: |
  - This entry covers only the Palladium Fantasy (Dragons and Gods) statistics. The page also includes a separate "Chiang-Ku Rifts Stats" conversion block (M.D.C., Rifts R.C.C. Skills) which was intentionally omitted per import instructions.
  - "Average level of experience of an adult is 1D4+7" and hatchling starting skill proficiencies (language and basic math at 96%, all other skills starting at first level) are NPC-generation notes not captured by a schema field.
  - "Skill proficiency depends on the level of experience, plus I.Q. bonus (if any)" applies to the skill list as a general modifier not encodable per-skill.
  - Magic Knowledge/Study of Mystic Arts describes a percentile chance of studying one of several magic schools (50% Wizardry, 20% Diabolism, 20% Summoning, 5% other) rather than a fixed spells_starting/spell_levels_allowed value, so it was not forced into the `magic` schema field and is instead recorded under special_abilities.
  - Enemies, Allies, Habitat, and Average Life Span fields from the sourcebook have no corresponding schema field and are recorded in the Lore/GM Notes sections instead.
---

## Lore

The Chiang-Ku dragon is extremely rare on the Palladium World. Earthlings will recognize it as a Chinese dragon with a long serpentine body with triangular shaped, emerald green scales, two short forearms and one to two pairs of short legs; the feet have three toes. The head is slender and angular, and can look reptilian/dragon-like or a bit more lion-like; all have whiskers on their chin and a mouth filled with sharp teeth. The tail has no special feature or abilities.

The Chiang-Ku are said to be the wisest of all dragons and masters of magic. They are also said to be the most experienced dimensional travelers and are constantly exploring other worlds and investigating (and often helping) alien people. All Chiang-Ku have a high regard for life and have always been fond of human beings. In many respects, the Chiang-Ku can be considered the Paladin or missionary of Dragonkind. They are famous for protecting people of all races against supernatural evil and helping people to learn and stand on their own. To this end, the dragon is usually happy to teach people scholarly skills (languages, literacy, lore, etc.), as well as offer hints and suggestions on how to do things more efficiently. Occasionally, a Chiang-Ku will teach Wizards a helpful spell, but usually nothing beyond 5th level unless the creature knows the Wizard well and believes he will use his knowledge for good (even then it rarely shares knowledge above 10th level).

The Chiang-Ku''s helpful nature and affections for lesser beings, particularly humans, makes them the most knowledgeable of and comfortable among human civilization. A Chiang-Ku metamorphed into human guise can easily pass as the genuine article. Their favorite disguises when impersonating humans is that of a scholar, monk or priest. This disguise enables them to help humans in subtle ways from behind the scenes and without revealing their inhuman nature. They like to aid others by helping them help themselves. According to legend, a great purge conducted by the forces of darkness slew tens of thousands of these noble creatures. Exactly how many survived is unknown even to the dragons themselves. They speculate that there are probably as many as one hundred to one thousand scattered throughout the Megaverse. A Chiang-Ku is rumored to have started (and still helps operate) the monastic order that trains Undead Hunters (see Book 7: Yin-Sloth Jungles). Another is rumored to live in the Great Northern Wilderness and a third is rumored to be enslaved by an evil lord of the Western Empire.

**Alignment:** Any, but typically good or selfish.

**Size (adult):** 12 to 20 feet (3.6 to 6.1 m) long, including the tail which is typically one-quarter of the overall length. Stands about four feet (1.2 m) at the shoulders. In human form the dragon can range from about five to six feet (1.5 to 1.8 m) tall. Hatchlings are typically 10% smaller.

**Weight (adult):** 200 lbs (90 kg) in human form, 1000 lbs (450 kg) in serpent form. Hatchlings are about 20% lighter.

**Habitat:** Can be found anywhere.

**Average Life Span:** 6000 years; some are said to reach 10,000!

**Enemies:** None per se. Champions of Light will regard all creatures of darkness as their enemy. Demons, Deevils and gods of darkness like to torture and torment these dragons and occasionally engage in campaigns to destroy them.

**Allies:** Chiang-Ku get along famously with Kukulcans and other dragons of good alignment and intentions. They also regard humans and most Champions of Light as potential friends and allies. They are also said to associate with the Gods of Light.

## GM Notes

A Chiang-Ku PC is an unusually powerful and knowledgeable ally, but the honor code of restraint around tattoo magic and the Elixir of Power and Deceit should be respected in play ' || char(8212) || ' most Chiang-Ku, even evil-tempted ones, refuse to use or reveal these secrets on the Palladium World out of respect for the Elves'' and Dwarves'' choice to eradicate that magic. Reserve tattoo magic use for miscreant or diabolic Chiang-Ku antagonists.

Because the dragon''s helpfulness and curiosity are core to its concept, GMs can use these traits as complications: a Chiang-Ku PC or NPC is likely to intervene to teach, protect or advise even at personal risk, and its desire to see mortals solve their own problems ("helping people help themselves") can create friction with parties wanting more direct intervention.

The percentile chance of a young Chiang-Ku''s chosen field of study (50% Wizardry, 20% Diabolism, 20% Summoning, 5% other) can be used to quickly generate NPC dragons'' capabilities and outlook.',
       updated_at = datetime('now')
 WHERE class_id = 'chiang-ku-dragon'
   AND markdown LIKE '%{ name: "Art", note: "+10%" }%';

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-chiang-ku.sql');
