-- The Knight of the Order of the Hospital O.C.C., Rifts Dimension Book 1:
-- Wormwood p.73-76.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-knight-of-the-order-of-the-hospital-class.sql
--
-- Hand-transcribed from the OCR cache (the scan has no text layer) and
-- validated with scripts/class-check.mjs --remote before this file was
-- written.
--
-- THE Standard Equipment LIST RUNS ACROSS THE p.75/p.76 BREAK, and
-- class-check --field-sources flags it as a span ending near the foot of its
-- page. The continuation on p.76 carries 1D4x10 worms of mending, 100 feet of
-- angel hair rope, the grappling hook, 2D4 resin spikes and the rations - a
-- third of the list. All of it is transcribed.
--
-- The book's own named non-player hero on p.82 is a Hospitaller and repeats
-- this class's numbers independently: recognizes poisons and potions at
-- 40% +5% per level, six blood worms, worms of mending, a first-aid kit,
-- paramedic, biology, dance and a musical instrument. That is a second
-- reading of the sheet, and it agrees.
--
-- occ_group is men-of-arms for all four. class-check does NOT require it and does
-- not report it as unmodelled, so all four read "ready" without it; the
-- regression test does require it, and failed with "4 of 78 ungrouped". The
-- gap between the two checks is real and reference/frontmatter.md documents
-- the key nowhere at all.
--
-- Pure ASCII, LF endings: the whole file, comments included.


-- Two Wormwood materials the catalog did not have. These are NOT stubs - the
-- book describes both on printed 42, under Mucus Resin and Angel Hair, so
-- there is nothing left for a later gear pass to fill in. cost stays NULL with
-- cost_note recording why, exactly as the 71 rows in add-wormwood-gear.sql do:
-- the planet grows this stuff and the people barter for it.
-- INSERT OR IGNORE, so whichever of these four scripts runs first wins and the
-- rest are no-ops. Filename order is execution order on a clean rebuild.
INSERT OR IGNORE INTO gear
  (slug, name, system, category, weight_lbs, cost, cost_note, description, source_book)
VALUES
  ('angel-hair-rope', 'Angel Hair Rope', 'rifts', 'gear', NULL, NULL, 'No published price. Wormwood runs on barter and this is made from what the living planet grows rather than sold; every O.C.C. in the book states Money: Not applicable.', 'Rope woven from angel hair, the cotton-like substance the living planet creates. It is white, yellow or tan, magically appears in the sky 30 to 100 feet (9 to 30.5 m) up and floats gently to the ground in fine strands 6 to 12 feet (1.8 to 3.7 m) long. It has the look, weight and feel of cotton and is three times stronger; woven into clothes it wears five times longer. The planet seems to know intuitively when its people need the fibers, and it also appears near places of habitation in regular cycles or on demand when a priest or wormspeaker calls for it. Every Wormwood O.C.C. is issued a coil: 50 feet (15 m) for the priest of light and the wormspeaker, 100 feet (30.5 m) for the warriors, the knights and the book''s named heroes. The book gives it no weight, no M.D.C. and no price.', 'Rifts Dimension Book 1: Wormwood p.42'),
  ('resin-spike', 'Resin Spike', 'rifts', 'gear', NULL, NULL, 'No published price. Wormwood runs on barter and this is made from what the living planet grows rather than sold; every O.C.C. in the book states Money: Not applicable.', 'A spike cut or moulded from Wormwood mucus resin, carried alongside rope and a grappling hook as climbing and anchoring kit. Liquified resin flows quietly from openings in the planet''s surface as a thick, warm, sticky glop with the consistency of liquified plastic; poured into molds and left to harden it becomes as strong as steel and as light as plastic, and the hardened rock can be chiseled, powdered or cut into slabs and made into everything from arrowheads and belt buckles to weapons and armor. The freelancer and both knight orders are issued 2D4 of them (p.69, p.72, p.76); the book''s named non-player heroes carry four (p.78) and six (p.82). No stats, no weight and no price are printed for the spike itself.', 'Rifts Dimension Book 1: Wormwood p.42');


-- The class itself. INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE,
-- so re-running the script is a no-op instead of a silent partial write.
--
-- Every apostrophe inside the markdown is doubled.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'knight-of-the-order-of-the-hospital', 'Knight of the Order of the Hospital', 'rifts', '---
id: knight-of-the-order-of-the-hospital
name: Knight of the Order of the Hospital
system: rifts
source_book: Rifts Dimension Book 1: Wormwood p.73-76
category: occ
occ_group: men-of-arms
xp_table: [0, 2151, 4301, 8601, 17201, 25501, 36001, 52001, 73001, 98001, 134001, 184001, 240001, 295001, 365001]
attribute_requirements: { ME: 15 }
mdc_base: "1d4x10+30"
ppe_base: "6d6x2"
bonuses:
  saves: { horror_factor: 2, spell_magic: 2, disease: 2 }
skills:
  occ_skills:
    - { name: "Dance", base: 45, per_level: 5, note: "+15%" }
    - { choose: 1, from: ["Sing", "Play Musical Instrument"], bonus: 15, note: "The book grants Sing or Play Musical Instrument (+15%)." }
    - { name: "Horsemanship: General", base: 45, per_level: 4, note: "+5%; the book calls it the general animal riding skill" }
    - { choose: 1, from: ["Motorcycles & Snowmobiles", "Hovercycles, Skycycles & Rocket Bikes"], bonus: 10, note: "The book grants Pilot Motorcycle or Hovercycle (+10%)." }
    - { name: "Land Navigation", base: 56, per_level: 4, note: "+20%" }
    - { name: "Wilderness Survival", base: 45, per_level: 5, note: "+15%" }
    - { name: "Paramedic", base: 60, per_level: 5, note: "+20%" }
    - { name: "Biology", base: 40, per_level: 5, note: "+10%" }
    - { name: "Mathematics: Basic", base: 60, per_level: 5, note: "+15%; the book prints Math: Basic" }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "The book prints this as Language: American (98%)." }
    - { name: "Language: Demongogian", base: 98, per_level: 5, note: "98%" }
    - { name: "Language: Other", base: 70, per_level: 5, note: "+20%; the book grants one language of choice" }
    - { name: "W.P. Targeting" }
    - { name: "W.P. Knife" }
    - { name: "W.P. Sword" }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P.: Select two of choice." }
    - { name: "Hand to Hand: Expert", note: "May be raised to Hand to Hand: Martial Arts, or Hand to Hand: Assassin if of an evil alignment, for one O.C.C. related skill." }
  occ_related_skills:
    count: 6
    categories:
      - { name: "Communications", bonus: 5 }
      - { name: "Domestic", bonus: 10 }
      - { name: "Espionage", bonus: 5 }
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Air Assault Armor", "Combat Pod", "Military: Tanks & APCs", "Space: Small Spacecraft", "Space: Space Fighter", "Space: Starship"], bonus: 5 }
      - { name: "Rogue", only: ["Streetwise", "Palming", "Concealment"] }
      - { name: "Science", bonus: 10 }
      - { name: "Technical", bonus: 10 }
      - { name: "Weapon Proficiencies" }
      - { name: "Wilderness" }
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
equipment_starting:
  - { item_id: "clothing", qty: 1, note: "Travelling clothes." }
  - { item_id: "dress-clothing", qty: 1, note: "Or dress body armor." }
  - { item_id: "boots", qty: 1 }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "hat-short-brim", qty: 1 }
  - { item_id: "sleeping-bag-rifts", qty: 1 }
  - { item_id: "blanket-light", qty: 1 }
  - { choose: 1, label: "backpack or saddlebag", qty: 1, from: ["backpack", "saddlebags"] }
  - { item_id: "utility-belt", qty: "1d4" }
  - { item_id: "first-aid-kit", qty: 1, note: "Including scalpels, sutures and needles, bandages and the like." }
  - { item_id: "worms-of-blood", qty: 6, note: "The book calls them blood worms." }
  - { item_id: "worms-of-mending", qty: "1d4x10" }
  - { item_id: "angel-hair-rope", qty: 1, note: "100 feet (30.5 m)." }
  - { item_id: "grappling-hook", qty: 1 }
  - { item_id: "resin-spike", qty: "2d4" }
  - { item_id: "food-rations", qty: 1, note: "2D4 weeks of rations." }
special_abilities:
  - name: "Recognize Poisons, Drugs and Magic Potions"
    description: "Recognizes poisons, drugs and magic potions or slime: 40% +5% per level of experience."
  - name: "Meditation"
    description: "Meditation is the same as the priest''s."
  - name: "Cathedral Standing"
    description: "Most knights of the Hospital are highly respected and honored within the human society of Wormwood. They are given access to most buildings and homes, provided with a place to sleep, given food and drink, and treated to a great deal of attention and comfort."
restrictions: ["May not wear or link with symbiotic organisms", "Cybernetics and bionics are virtually non-existent"]
side_effects: "A true knight of the Hospital never wears or links with symbiotic organisms, but will use healing worms, magic slime, blood stones and magic crystals. He may pilot battle saints and battle saint orbs and link with the spirit of Wormwood, all of which are considered great honors."
extraction_notes: "Money: the book states outright that money is Not applicable on Wormwood - valuables, weapons, food and services are exchanged by barter and a character is judged by his standing in the community - so no starting_money is stored. || Attribute requirements: only M.E. 15 is mandatory. A high M.A., P.S. and P.E. are suggested and are not stored. If the character''s I.Q. is six or less the skill bonuses are halved, which is prose rather than a requirement. || Alignment: any, but most are principled or scrupulous, and unprincipled is acceptable. An anarchist character who has not reached a good alignment by third level is banished from the Order and LOSES ALL HIS HEALING POWERS - a real mechanic the app cannot express as a conditional, so it is recorded here and in the GM notes. || The Standard Equipment line runs across the p.75/p.76 break and both halves were read; the rope, grappling hook, resin spikes and rations are all on p.76."
---

## Lore

The common slang name for this order is Hospitallers, or the Knights of Mercy.
These noble knights are eternal optimists who seldom despair even in the face of
evil and death - which is why the character must have a high mental endurance.

They serve as healers, moral advisors, scholars, philosophers and historians as
well as dedicated protectors of the weak and the innocent. Most are excellent
speakers who can inspire hope and strength by their words; those who are not so
eloquent inspire through their actions, firm resolve, gentle mercies, kindness
and personal sacrifice. They ask no reward or thanks, taking solace in the fact
that they help others.

They cannot be corrupted by the promise of riches, glory or power, and seldom
give in to blackmail or torture. On another world, in another time, they might
be considered noble and courageous paladins as well as healers.

## GM Notes

The typical player character starts at level one or two. The average non-player
Hospitaller is 1D4+4 level; about 30% are 9th to 14th level.

**The corruption plot.** Corrupt high priests and knights of the Temple view the
Hospitallers with concern and contempt, because a man who cannot be corrupted is
a force that cannot be turned. They know that one day the Hospitallers will see
them as a menace and rise up to destroy them. Many of these knights already watch
the growing corruption in the power core of the Cathedral with a concerned eye;
for now they turn their attention to a far greater evil, but when that battle is
over they will turn it inward.

Knights who question the justice, honor or commands of corrupt Cathedral leaders
are given the most dangerous assignments or sent to faraway lands. Those who
publicly defy church leaders are expelled and may be excommunicated and branded
heretics - but this punishment is far less devastating than it is for a Templar.
Most citizens judge the character by his words and works and may decide the
church is mistaken.

**The alignment clock.** An anarchist Hospitaller is allowed at the G.M.''s
discretion, and will be counselled by other knights to become a better person. If
he has not reached a good alignment by third level - unprincipled is enough - he
is banished from the Order and loses all of his healing powers. He can continue
as a freelance warrior on the side of good or become a mercenary, but the
Hospitallers will always view him with shame and suspicion. Nothing in the app
enforces this; it is the G.M.''s to run.

The Code of the Knights of the Hospital is very similar to that of the
cyber-knights of Rifts Earth, in seven parts: To Live, Fair Play, Nobility,
Valor, Honor, Courtesy and Loyalty. Unlike the Templar code, its exemptions are
narrow - Honor and Courtesy are "not applicable to criminals, traitors,
evildoers, monsters and Forces of Darkness", and Nobility says outright to
administer justice and mercy equally for all and to protect the innocent
regardless of class or race.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'knight-of-the-order-of-the-hospital');


-- Read the result back rather than trusting the exit code. d1-apply prints
-- these, and a CR in the stored markdown means the checkout mangled the file.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'knight-of-the-order-of-the-hospital';
SELECT count(*) AS wormwood_materials FROM gear WHERE slug IN ('angel-hair-rope', 'resin-spike');

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-knight-of-the-order-of-the-hospital-class.sql');
