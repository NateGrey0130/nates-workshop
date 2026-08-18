-- The Glitter Boy O.C.C., Rifts Ultimate Edition (rifts-core).
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   npx wrangler d1 execute DB --local --file apps/character-creator/db/add-glitter-boy-class.sql
--
-- Extracted by Claude from the page images through import/extract and
-- corrected in review (see `extraction_notes` in the markdown). Byte-identical
-- to what the local dress rehearsal published through the real confirm
-- endpoint. The power armor itself is a gear stub; its full stats live in the
-- class's GM Notes until the gear catalog grows a proper entry.
--
-- Gear stubs mirror what that confirm created locally, INSERT OR IGNORE like
-- buildStubStatements(). The four stub SKILLS additionally get real categories
-- - the server's pattern matcher left them NULL, and a skill with no category
-- never appears in a category picker. Their bases stay 0 and still need real
-- values from the skills chapter.
--
-- The em-dash in the stub description is built with char(8212) because
-- passing one through `wrangler d1 execute` on Windows has produced mojibake
-- before. Pure ASCII on purpose, for the same reason.

INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('glitter-boy-power-armor', 'Glitter Boy Power Armor', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'rifts-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('urban-warrior-armor', 'Urban Warrior Armor', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'rifts-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('huntsman-armor', 'Huntsman Armor', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'rifts-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('rifle', 'Rifle', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'rifts-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('hand-grenade', 'Hand Grenade', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'rifts-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('smoke-grenade', 'Smoke Grenade', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'rifts-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('signal-flare', 'Signal Flare', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'rifts-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('air-filter', 'Air Filter', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'rifts-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('gas-mask', 'Gas Mask', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'rifts-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('walkie-talkie', 'Walkie Talkie', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'rifts-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('fatigues', 'Fatigues', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'rifts-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('velcro-strapped-boots', 'Velcro Strapped Boots', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'rifts-core');

INSERT OR IGNORE INTO skills (name, category, base, per_level, source) VALUES ('Basic Mechanics', 'Mechanical', 0, 0, 'import');
UPDATE skills SET category = 'Mechanical' WHERE name = 'Basic Mechanics' AND category IS NULL;
INSERT OR IGNORE INTO skills (name, category, base, per_level, source) VALUES ('General Repair & Maintenance', 'Technical', 0, 0, 'import');
UPDATE skills SET category = 'Technical' WHERE name = 'General Repair & Maintenance' AND category IS NULL;
INSERT OR IGNORE INTO skills (name, category, base, per_level, source) VALUES ('Pilot Robot Combat Elite: Glitter Boy', 'Pilot', 0, 0, 'import');
UPDATE skills SET category = 'Pilot' WHERE name = 'Pilot Robot Combat Elite: Glitter Boy' AND category IS NULL;
INSERT OR IGNORE INTO skills (name, category, base, per_level, source) VALUES ('Pilot Robot Combat Basic (general)', 'Pilot', 0, 0, 'import');
UPDATE skills SET category = 'Pilot' WHERE name = 'Pilot Robot Combat Basic (general)' AND category IS NULL;

INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
VALUES ('glitter-boy', 'Glitter Boy', 'rifts', '---
id: glitter-boy
name: Glitter Boy
system: rifts
source_book: rifts-core
category: occ
starting_money: "4d6x100"
attribute_requirements:
  PP: 10
bonuses:
  combat: { initiative: 1, strike: 1, pull_punch: 2 }
  saves: { horror_factor: 3 }
  pools: { sdc: 20 }
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 95, per_level: 0 }
    - { choose: 2, categories: ["Technical"], bonus: 20, per_level: 5, note: "Language: Other, two of choice (+20%). The catalog has no individual language rows." }
    - { name: "Basic Electronics", base: 40, per_level: 5, note: "+10%" }
    - { name: "Basic Mechanics", base: 45, per_level: 5, note: "+15%" }
    - { name: "General Repair & Maintenance", base: 45, per_level: 5, note: "+10%" }
    - { name: "Land Navigation", base: 42, per_level: 4, note: "+6%" }
    - { name: "Pilot Robot Combat Elite: Glitter Boy", base: 0, per_level: 0 }
    - { name: "Pilot Robot Combat Basic (general)", base: 0, per_level: 0 }
    - { choose: 1, categories: ["Pilot"] }
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Read Sensory Equipment", base: 40, per_level: 5, note: "+10%" }
    - { name: "Weapon Systems", base: 50, per_level: 5, note: "+10%" }
    - { name: "W.P. Energy Pistol", base: 0, per_level: 0 }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { name: "W.P. Heavy Energy Weapons", base: 0, per_level: 0 }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "May be changed to Hand to Hand: Expert for the cost of one O.C.C. Related Skill, or Martial Arts (or Assassin if evil alignment) for the cost of two skill selections." }
  occ_related_skills:
    count: 7
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Espionage", only: ["Detect Ambush", "Detect Concealment", "Intelligence", "Wilderness Survival"] }
      - { name: "Mechanical", only: ["Automotive Mechanics"] }
      - { name: "Medical", only: ["First Aid", "Paramedic"] }
      - { name: "Military", only: ["Field Armorer & Munitions Expert", "Demolitions", "Demolitions Disposal", "Military Etiquette", "Recognize Weapon Quality"] }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics"] }
      - "Pilot"
      - { name: "Pilot Related", only: ["Navigation"] }
      - "Rogue"
      - "Science"
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Cowboy, Electrical and Horsemanship offer none and are omitted. Medical: pick one of the two. Category bonuses: Espionage Detect Ambush +10% and others +5%, Mechanical +5%, Military Demolitions/Disposal/Etiquette +10% and others +5%, Pilot Related +5%, Technical +5% to Jury-Rig, Salvage and Lore skills only, Wilderness +2%. Military Etiquette is a book option the catalog does not carry yet."
    schedule:
      - { level: 3, count: 2 }
      - { level: 6, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 2
    schedule:
      - { level: 3, count: 2 }
      - { level: 5, count: 2 }
      - { level: 8, count: 2 }
      - { level: 12, count: 2 }
equipment_starting:
  - { item_id: "glitter-boy-power-armor", qty: 1 }
  - { choose: 1, label: "light or medium environmental body armor", qty: 1, from: ["urban-warrior-armor", "huntsman-armor"] }
  - { choose: 1, label: "energy rifle of choice", qty: 1, from: ["wilk-s-447-laser-rifle", "ng-l5-northern-gun-laser-rifle", "ng-p7-northern-gun-particle-beam-rifle", "l-20-pulse-rifle", "energy-rifle"] }
  - { choose: 1, label: "energy side arm of choice", qty: 1, from: ["wilk-s-320-laser-pistol", "ng-33-northern-gun-laser-pistol", "energy-pistol"] }
  - { choose: 1, label: "non-energy weapon of choice", qty: 1, from: ["rifle", "automatic-pistol", "submachine-gun"] }
  - { item_id: "e-clip", qty: 4 }
  - { item_id: "hand-grenade", qty: 2 }
  - { item_id: "smoke-grenade", qty: 2 }
  - { item_id: "signal-flare", qty: 6 }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "gas-mask", qty: 1 }
  - { item_id: "walkie-talkie", qty: 1 }
  - { item_id: "fatigues", qty: 2 }
  - { item_id: "velcro-strapped-boots", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "portable-irmss-kit", qty: 1 }
natural_abilities:
  - name: "Racial Piloting Bonuses"
    description: "Glitter Boys descended from generations of GB pilots (rather than those who recently acquired their armor) get: +1 on initiative, +1 to strike, +2 to pull punch, +3 to save vs Horror Factor, +20 S.D.C., and +1 additional melee attack/action when using a GB. These bonuses only apply to those with a long family tradition of piloting the Glitter Boy."
  - name: "Hand to Hand Combat Elite: Glitter Boy"
    description: "Available only to those who take Power Armor Combat Elite: Glitter Boy (automatic to the Glitter Boy O.C.C.). All bonuses are in addition to the pilot''s own hand to hand combat training and attribute bonuses, and do not apply to the pilot''s physical abilities when outside his power armor. +2 extra attacks/actions per melee round, in addition to those of the pilot at level one; +1 additional attack at levels 3, 7, and 11. +2 on initiative. +2 to strike when shooting the Boom Gun and other rail guns/cannons, in addition to W.P. Heavy Energy Weapons skill bonuses. +2 to strike in hand to hand combat. +2 to parry in hand to hand combat. +2 to dodge. +1 to disarm. +4 to pull punch. +3 to roll with impact. Punch Damage: 1D4 M.D. restrained, 1D6 M.D. full strength. Power Punch: 2D6 M.D., counts as two melee attacks. Kick Damage: 2D4 M.D. (Power Kick not possible). Running Leap Kick: 4D6 M.D., counts as three attacks. Tear or Pry with Hands (Special): 1D6 M.D. Body Block/Ram: 2D4 M.D. Full Speed Running Ram: 3D6 M.D., uses up three melee actions. Stomp: 1D6 M.D., effective only against objects/targets smaller than three feet tall. Pylon Impalement: 1D6 M.D., not very useful in most combat situations."
  - name: "Special Sensory Systems"
    description: "Full optical systems including laser targeting, telescopic, passive nightvision (light amplification), thermal-imaging, infrared, ultraviolet, and polarization. Advanced Laser Targeting gives the Boom Gun +2 to strike (in addition to the usual power armor laser targeting bonus). Self-Destruct Mechanism prevents the armor and its technology from falling into enemy hands. Laser Resistant Armor: all Glitter Boys are made from special alloys with a chrome-looking surface resistant to laser attacks (half damage). Other features include all standard environmental power armor features, plus built-in language translator and depth gauge."
restrictions:
  - "Glitter Boy armor can be used by any character trained to pilot power armor, but only members of the Glitter Boy O.C.C. are specifically trained in the complete understanding and operation of GB armor at the elite level."
extraction_notes: |
  - REVIEW: the three ability entries are automatic and live under
    natural_abilities - special_abilities is for powers a player chooses, and
    this class chooses none. Fixed skills fold the O.C.C. bonus into the
    catalog base (Radio: Basic 45+10=55); Basic Mechanics and General Repair &
    Maintenance have catalog rows via backfill-import-skill-gaps.sql; their
    bases here fold that catalog base plus the O.C.C. bonus. The open
    weapon choices enumerate the catalog''s rifles and pistols with the generic
    rows as the of-choice fallback, and the non-energy weapon is one, as the
    book says, not two.
  - AUDIT: The class''s racial piloting bonuses (initiative, strike, pull punch, save vs
    Horror Factor, S.D.C., extra attack) are stated to apply ONLY to those "with a long
    family tradition of piloting the Glitter Boy," not those who recently acquired
    their armor - a conditional gate the bonuses schema cannot express, so it is
    recorded in bonuses at top-level AND repeated as prose in special_abilities per the
    book''s wording; GMs should apply it only when the character background supports it.
  - The Hand to Hand Combat Elite: Glitter Boy package (extra attacks at level 1/3/7/11,
    +2 initiative, +2 strike w/ Boom Gun, +2 strike/parry/dodge in HtH, +1 disarm, +4
    pull punch, +3 roll with impact, and various punch/kick/ram/stomp damage values)
    is conditional on taking Power Armor Combat Elite: Glitter Boy, which is automatic
    to this O.C.C., and only applies while piloting the armor (does not apply to the
    pilot''s own physical abilities outside the suit) - kept as prose rather than
    unconditional bonuses since it''s armor-state-dependent.
  - Standard Equipment lists choices without enumerated named items ("energy rifle and
    energy side arm of choice," "one non-energy weapon of choice (maybe S.D.C.)," "two
    hand grenades," "two smoke grenades") - recorded as open choices/labels since no
    specific catalog items are named on this page.
  - The Glitter Boy Power Armor itself (Model USA-G10, MDC by location, weapon
    systems, speed, statistical data, etc., detailed on pages 71-73) is referenced here
    as a single equipment item; full armor/weapon stats are summarized below in GM Notes
    rather than forced into the O.C.C. schema, since this schema is for the character
    class, not the vehicle/equipment catalog.
  - Page 70 "Game Designer''s Secrets" and page 73 "Designer''s Note to Game Masters" are
    author commentary (Kevin Siembieda) about the game''s design history and GM balance
    philosophy - placed under GM Notes as prose, not mechanical data.
  - Cybernetics: "Start with none, but may purchase cybernetic augmentation later as
    desired. Typically limited to cybernetic implants and Bio-Systems for medical
    reasons." No mechanical bonus stated, recorded as restriction/prose only.
  - Money: also noted to have "another 1D4x1000 in Black Market items" beyond the
    starting credits - recorded here since starting_money captures only the coin figure.
---

## Lore

"It''s not about fame, power or money. It''s about generations of tradition and making a difference, helping people who need it. That''s our destiny."

The Glitter Boy is both a relic of the past and symbol of power, hope and courage. Of all the Mega-Damage suits of power armor available on Rifts Earth, only the Glitter Boy is *known* to have originated from before the Great Cataclysm and remains one of the most powerful, feared and respected fighting machines on the planet. Powerful, because of its heavy armor and laser resistance. Feared, because of its Boom Gun and endurance. Respected, because Glitter Boy armor was the weapon of the greatest heroes in North America throughout the Two Hundred Years Dark Age.

Legend says the armor was created by a group of powerful beings known as the Neemans - heroic supermen who fought to stem the tide of chaos and destruction during the Great Cataclysm and are reputed to have saved millions of lives. Whether they were humans, D-Bees from another world, sorcerers, or demigods remains a matter of heated debate. The true origin (revealed by later Rifts sourcebooks) is that Glitter Boy armor was the *Chromium Guardsman*, developed by NEMA (Northern Eagle Military Alliance - USA, Canada, and Mexico), the first fully field-operational power armor deployed by the pre-Rifts US military, misidentified by Dark Age legend as the "Neemans."

During the Two Hundred Years Dark Age, humanity fell into barbarism, competing with D-Bees, monsters, demons, and dragons for survival. Only the Glitter Boy, largely undamaged and unmatched by contemporary technology, allowed lone champions and small bands of heroes to stand against overwhelming supernatural threats - armor passed down from hero to chosen successor or worthy squire, becoming a symbol of noble tradition and legend.

Today the Glitter Boy''s status as unique wonder is fading: the Coalition States and other manufacturers (Northern Gun, Triax, Naruni Enterprises) have produced newer, often smaller, faster power armors, and Free Quebec - the largest producer and secret manufacturer of Glitter Boys and variants (see Rifts World Book 22) - maintains the largest legion of GBs in the world, guarding the secrets of their construction jealously as the "secret weapon" underpinning their military strength and political independence. Most Glitter Boys encountered outside Free Quebec are heroes carrying on a long family legacy with pre-Rifts relic armor, patched and repaired for centuries.

The typical Glitter Boy pilot is a career soldier with delusions of greatness - a grunt who finds combat a thrill and a hero who strives to help the innocent and downtrodden. Many wander as mercenaries or community protectors, tolerant of nonhumans, respectful of life, and open to new ideas; their long heritage of heroism keeps them grounded and committed to fighting evil, especially monsters and slavers. Some call them "champions of heroes." All are nobody''s fools, and view strangers with suspicion until trust is earned. Combat experience can also harden pilots to cold, cruel indifference over time.

## GM Notes

**Alignment:** Any, but most tend to be Principled, Scrupulous, Unprincipled, and Anarchist.

**Glitter Boy Power Armor (Model USA-G10)** - Class: Laser Resistant Infantry Personnel Assault Unit. Crew: One pilot. Height 10 ft 5 in (3.1 m); Width 4 ft 4 in (1.3 m); Length 4 ft (1.2 m); Weight 1.2 tons fully loaded. Physical Strength equal to Robot P.S. of 30.

M.D.C. by Location: Rail Gun/Boom Gun - 175; *Head - 290; *Hands (2) - 100 each; Arms (2) - 270 each; Legs (2) - 450 each; Reinforced Pilot''s Compartment - 150; **Main Body - 770. (*Called Shot required, -4 to strike; **depleting Main Body shuts the armor down completely. Laser weapons do half damage to the Glitter Boy.)

Speed: Running 60 mph (96 km) max, tires the pilot at only 10% the usual fatigue rate. Leaping 12 ft (3.6 m) high/across, +10 ft (3 m) with running start; jet thrusters can add a leap up to 80 ft (24 m) or hold the GB aloft up to 12 ft for 1D6x10 seconds (not true flight). Underwater: 15 mph (24 km/13 knots) swimming, or walk the sea bed at 25% normal speed; max depth one mile (1.6 km); firing the Boom Gun underwater requires anchoring pylons into the seabed or a hull.

Main Weapon - RG-14 Rapid Acceleration Electromagnetic Rail Gun ("Boom Gun"): fires 200 flechette rounds per blast at Mach 5, inflicting 3D6x10 M.D. per burst; creates a sonic boom that deafens everyone within 200 ft (61 m) unprotected (2D4 minutes, -8 initiative, -3 parry/dodge; shorter duration with armor). Payload 1000 rounds per auto-feed canister; reload by hand takes 15 minutes for 40 rounds, or a small extra ammo-drum of 400 rounds can be hip-mounted. Maximum effective range 11,000 ft (~2 mi/3.2 km). Black Market Cost: 25 million+ credits new/fully powered with ammo; 15-20 million for rebuilt/gunless.

Designer commentary (Kevin Siembieda) notes the Glitter Boy was the very first character concept created for Rifts, originally envisioned as the central hero of a game called *Boomers* before evolving into one ensemble character among many as the RPG''s scope expanded.

On game balance: the Glitter Boy is designed with deliberate strengths (massive M.D.C., great firepower, killer reputation/Horror Factor) and deliberate weaknesses (slow speed, limited mobility, trouble with soft/muddy ground, vulnerability to fast fliers like SAMAS, concealed hit-and-run attackers, immobilization, and magic). GMs should exploit these weaknesses to keep the class balanced rather than banning it as "too powerful" or dismissing it as "too weak" - both complaints reflect the same character used well or poorly. A team of Glitter Boys or mixed adventurers using teamwork and cleverness should be rewarded; the GM''s job is to make villains counter that teamwork credibly, not simply hand PCs victories or overwhelm them arbitrarily.', 'published', 'import')
ON CONFLICT (class_id) DO UPDATE
   SET markdown = excluded.markdown,
       name = excluded.name,
       system = excluded.system,
       status = 'published',
       updated_at = datetime('now');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, created_by, length(markdown) AS markdown_bytes
  FROM imported_classes WHERE class_id = 'glitter-boy';
SELECT count(*) AS stub_gear_rows FROM gear
 WHERE slug IN ('glitter-boy-power-armor', 'urban-warrior-armor', 'huntsman-armor', 'rifle', 'hand-grenade', 'smoke-grenade', 'signal-flare', 'air-filter', 'gas-mask', 'walkie-talkie', 'fatigues', 'velcro-strapped-boots');
SELECT name, category FROM skills WHERE name IN ('Basic Mechanics', 'General Repair & Maintenance', 'Pilot Robot Combat Elite: Glitter Boy', 'Pilot Robot Combat Basic (general)');
