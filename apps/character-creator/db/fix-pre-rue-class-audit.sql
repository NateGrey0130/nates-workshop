-- The four classes that still cited the ORIGINAL Rifts core book, re-audited
-- against Rifts Ultimate Edition.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-pre-rue-class-audit.sql
--
-- WHY. Every other Rifts class in this catalog is RUE. These four said
-- `source_book: rifts-core`, and nothing surfaced that - source_book is free
-- text inside the markdown, so "which classes predate the edition everything
-- else uses" was not a question the catalog could answer. Read against the RUE
-- OCR cache (.cache/books/rue), printed page = cache page minus 3, a folio
-- checked on p119 to confirm it.
--
-- The four came out very differently, which is the point of auditing rather
-- than assuming:
--
-- CYBER-KNIGHT - real drift, and the reason this was worth doing. RUE printed
-- 61-66 grants two whole categories the stored class did not have at all
-- (Cowboy, and Horsemanship: Exotic Animals), adds Basic Mechanics alongside
-- Automotive, prints SIX category bonuses that had nowhere to go before the
-- `bonus` key landed in #260, and gives the class a secondary-skill schedule
-- (+2 at levels 5, 10 and 15) that was missing. It also names
-- "Horsemanship: Cyber-Knight" - a distinct catalog row at 70%/+3 - where the
-- stored class granted Horsemanship: General at 55%/+4.
--
-- GLITTER BOY and LEY LINE WALKER - already accurate. Both were transcribed
-- from RUE despite what source_book said; their own notes cite RUE page
-- numbers. What they were missing is the category bonuses their notes had
-- RECORDED IN PROSE because the format could not hold them. All seven of the
-- Ley Line Walker's are applied now. Only three of the Glitter Boy's are: the
-- rest differ per skill inside one category ("Espionage: Detect Ambush +10%,
-- others +5%"), and a category carries one number, so those stay prose and the
-- note now says which are applied and which are not.
--
-- DRAGON HATCHLING - no mechanical change, because RUE DOES NOT CONTAIN IT.
-- The word "Horned" does not appear anywhere in RUE's 382 pages; RUE details
-- six other species - Cat's-Eye, Flame Wind, Forest Runner, Royal Frilled,
-- Snow Lizard and Whip-Tailed. So this class is not stale relative to RUE, it
-- is from a book RUE replaced with a different roster, and the honest fix is
-- to say which book rather than to change a number. Importing RUE's six is a
-- separate decision, not a correction.
--
-- Guarded on the marker each row still carries, so re-running is a no-op and a
-- class already corrected is left alone. Pure ASCII, LF endings.

-- cyber-knight -> Rifts Ultimate Edition p.61-66
UPDATE imported_classes
   SET markdown = '---
id: cyber-knight
occ_group: men-of-arms
name: Cyber-Knight
system: rifts
source_book: Rifts Ultimate Edition p.61-66
category: occ
attribute_requirements:
  ME: 11
hit_points_base: "P.E. + 1d6 per level"
sdc_base: "1d4x10"
ppe_base: "6d6"
starting_money: "2d6x100"
bonuses:
  combat: { initiative: 1, attacks: 1 }
  attributes: { MA: "1d4", ME: "1d4", PS: "1d4", PE: "1d4", Spd: "1d4" }
skills:
  occ_skills:
    - { name: "Literacy", base: 50, per_level: 5 }
    - { name: "Language: Native Tongue", base: 96, per_level: 0, note: "At 96%, the figure its own O.C.C. block prints (RUE p.66) rather than the catalog''s generic 98%. The book prints "Language: American and Dragonese/Elf at 96%"." }
    - { name: "Language: Dragonese", base: 96, per_level: 0 }
    - { choose: 2, from: ["Language: Other"], bonus: 30, per_level: 5, note: "Two additional languages of choice (+30%). Taken once per language - the picker asks which." }
    - { name: "Lore: Demons & Monsters", base: 45, per_level: 5, note: "Lore: Demon (+20%)" }
    - { name: "Anthropology", base: 35, per_level: 5, note: "+15%" }
    - { name: "Paramedic", base: 50, per_level: 5, note: "+10%" }
    - { name: "Land Navigation", base: 48, per_level: 4, note: "+12%" }
    - { name: "Horsemanship: Cyber-Knight", base: 70, per_level: 3, note: "The book names this skill specifically; it carries no O.C.C. bonus." }
    - { name: "Swimming", base: 60, per_level: 5, note: "+10%" }
    - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }
    - { name: "Body Building & Weight Lifting", base: 0, per_level: 0 }
    - { name: "Gymnastics", base: 35, per_level: 5, note: "+5%" }
    - { name: "Hand to Hand: Martial Arts", base: 0, per_level: 0 }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P. Ancient, two of choice" }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P. Modern, two of choice" }
  occ_related_skills:
    count: 12
    categories:
      - "Communications"
      - { name: "Cowboy", only: ["Breaking/Taming Wild Horse", "Trick Riding"] }
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", bonus: 5 }
      - { name: "Horsemanship", only: ["Horsemanship: Exotic Animals"], bonus: 10 }
      - { name: "Mechanical", only: ["Automotive Mechanics", "Basic Mechanics"] }
      - { name: "Military", bonus: 5 }
      - { name: "Physical", bonus: 5 }
      - "Pilot"
      - { name: "Pilot Related", bonus: 5 }
      - "Rogue"
      - "Science"
      - { name: "Technical", bonus: 5 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 5 }
    schedule:
      - { level: 3, count: 2 }
      - { level: 5, count: 3 }
      - { level: 6, count: 2 }
      - { level: 9, count: 2 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 6
    schedule:
      - { level: 5, count: 2 }
      - { level: 10, count: 2 }
      - { level: 15, count: 2 }
equipment_starting:
  - { item_id: "cyber-armor", qty: 1 }
  - { item_id: "survival-knife", qty: 2 }
  - { choose: 1, label: "transportation", qty: 1, from: ["riding-horse", "a-t-v-speedster-hover-cycle", "the-highway-man-motorcycle", "the-wastelander-motorcycle"] }
psionics:
  type: "major"
  isp_base: "6d6+10, +1d6 per level"
  powers_starting: 3
special_abilities:
  - name: "Psi-Sword"
    description: "A mega-damage blade of psychic energy willed into existence. 1D6 M.D. at first level, plus an additional 1D6 M.D. at levels three, six, nine, twelve and fifteen. Costs no I.S.P., has no time limit, and can be created any number of times a day. A true knight will never use it against a foe who is unarmed, not equipped with an equivalent weapon, and not a supernatural creature or dragon."
  - name: "Cyber-Armor"
    description: "The one cybernetic implant a cyber-knight starts with: concealed body armor, A.R. 16 and 50 M.D.C."
  - name: "Psionics"
    description: "Eighty percent of cyber-knights are psychic (roll 01-80). A psychic cyber-knight is a major psionic, saves against psionic attack at 12 or higher, and picks three permanent powers from a fixed list: empathy, mind block, object read, see the invisible, sense evil, sense magic, sixth sense, speed reading, summon inner strength."
  - name: "Techno-Wizardry"
    description: "Open-mindedness toward magic makes the cyber-knight one of the few O.C.C.s able to intuitively understand and use items created through techno-wizardry."
level_progression:
  - level: 3
    grants: ["Psi-Sword damage +1D6 M.D."]
  - level: 6
    grants: ["Psi-Sword damage +1D6 M.D."]
  - level: 9
    grants: ["Psi-Sword damage +1D6 M.D."]
  - level: 12
    grants: ["Psi-Sword damage +1D6 M.D."]
  - level: 15
    grants: ["Psi-Sword damage +1D6 M.D."]
restrictions:
  - "Good alignments as a rule; aberrant and anarchist are acceptable. A knight may be corrupted and turn evil like anybody else."
  - "Bound by the Code of Chivalry: to live, fair play, nobility, valor, honor, courtesy and loyalty."
  - "Rarely uses power armor or robot vehicles."
extraction_notes: |
  - The 80% chance of having psionics at all is a per-character roll the class schema cannot state; the class is written as psychic, which is the common case.
  - The three starting psi-powers come from a named list of nine, but `psionics` gates by category rather than by name, so any Sensitive/Physical/Healing power is offered.
  - Re-audited against Rifts Ultimate Edition printed 61-66 on 2026-08-25; it had been stored from the original Rifts core book. RUE grants Cowboy and Horsemanship categories this class was missing entirely, adds Basic Mechanics to Mechanical, and prints six category bonuses that had nowhere to go before the `bonus` key landed. It also names Horsemanship: Cyber-Knight, a distinct catalog row at 70%/+3, where this class had Horsemanship: General at 55%/+4.
  - Medical is excluded entirely, which is RUE''s "Medical: None".
  - Two per-skill bonuses remain prose because a category carries ONE number: Cowboy gives +10% to Breaking Horses only, not to Trick Riding.
  - The level-five related-skill grant is specifically three W.P.s; the schedule records the count but not the category.
  - The black market item worth 1D6x1000 credits is not modelled; only the 2D6x100 starting credits are.
---
## Lore

Wandering champions of the Megaverse, the Cyber-Knights are an order of noble
warriors founded by Lord Coake. Part paladin, part ranger, they roam the wilds
of post-apocalyptic North America defending the weak against monsters, bandits,
and the excesses of the Coalition States alike. Each knight carries the
signature Psi-Sword ' || char(8212) || ' a weapon of pure psychic energy that cannot be taken
from them ' || char(8212) || ' and lives by a strict code of chivalry.

## GM Notes

A Cyber-Knight who grossly violates the Code of Chivalry should face in-game
consequences (loss of reputation with the order, possible visit from a senior
knight). House rule: no starting cybernetics beyond the Cyber-Armor graft.
',
       updated_at = datetime('now')
 WHERE class_id = 'cyber-knight'
   AND instr(markdown, 'source_book: rifts-core') > 0;

-- glitter-boy -> Rifts Ultimate Edition p.67-73
UPDATE imported_classes
   SET markdown = '---
id: glitter-boy
occ_group: men-of-arms
name: Glitter Boy
system: rifts
source_book: Rifts Ultimate Edition p.67-73
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
    - { name: "Language: Native Tongue", base: 95, per_level: 0, note: "At 95%, the figure its own O.C.C. block prints (RUE p.70) rather than the catalog''s generic 98%." }
    - { choose: 2, from: ["Language: Other"], bonus: 20, per_level: 5, note: "Language: Other, two of choice (+20%). Taken once per language - the picker asks which." }
    - { name: "Basic Electronics", base: 40, per_level: 5, note: "+10%" }
    - { name: "Basic Mechanics", base: 45, per_level: 5, note: "+15%" }
    - { name: "General Repair & Maintenance", base: 45, per_level: 5, note: "+10%" }
    - { name: "Land Navigation", base: 42, per_level: 4, note: "+6%" }
    - { name: "Pilot Robot Combat Elite: Glitter Boy", base: 0, per_level: 0 }
    - { name: "Pilot Robot Combat Basic (general)", base: 0, per_level: 0 }
    - { choose: 1, categories: ["Pilot"] }
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Sensory Equipment", base: 40, per_level: 5, note: "+10%" }
    - { name: "Weapon Systems", base: 50, per_level: 5, note: "+10%" }
    - { name: "W.P. Energy Pistol", base: 0, per_level: 0 }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { name: "W.P. Heavy M.D. Weapons", base: 0, per_level: 0 }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "May be changed to Hand to Hand: Expert for the cost of one O.C.C. Related Skill, or Martial Arts (or Assassin if evil alignment) for the cost of two skill selections." }
  occ_related_skills:
    count: 7
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Espionage", only: ["Detect Ambush", "Detect Concealment", "Intelligence", "Wilderness Survival"] }
      - { name: "Mechanical", only: ["Automotive Mechanics"], bonus: 5 }
      - { name: "Medical", only: ["First Aid", "Paramedic"] }
      - { name: "Military", only: ["Field Armorer & Munitions Expert", "Demolitions", "Demolitions Disposal", "Military Etiquette", "Recognize Weapon Quality"] }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics"] }
      - "Pilot"
      - { name: "Pilot Related", only: ["Navigation"], bonus: 5 }
      - "Rogue"
      - "Science"
      - "Technical"
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 2 }
    note: "Cowboy, Electrical and Horsemanship offer none and are omitted. Medical: pick one of the two. Category bonuses: Espionage Detect Ambush +10% and others +5%, Mechanical +5%, Military Demolitions/Disposal/Etiquette +10% and others +5%, Pilot Related +5%, Technical +5% to Jury-Rig, Salvage and Lore skills only, Wilderness +2%. Military Etiquette is a book option the catalog does not carry yet. Of those bonuses, Mechanical +5%, Pilot Related +5% and Wilderness +2% are now APPLIED as category bonuses; the rest stay prose because they differ per skill and a category carries one number."
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
  - { choose: 1, label: "energy rifle of choice", qty: 1, from: ["wilk-s-447-laser-rifle", "ng-l5-northern-gun-laser-rifle", "ng-p7-northern-gun-particle-beam-rifle", "l-20-pulse-rifle"] }
  - { choose: 1, label: "energy side arm of choice", qty: 1, from: ["wilk-s-320-laser-pistol", "ng-33-northern-gun-laser-pistol"] }
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

On game balance: the Glitter Boy is designed with deliberate strengths (massive M.D.C., great firepower, killer reputation/Horror Factor) and deliberate weaknesses (slow speed, limited mobility, trouble with soft/muddy ground, vulnerability to fast fliers like SAMAS, concealed hit-and-run attackers, immobilization, and magic). GMs should exploit these weaknesses to keep the class balanced rather than banning it as "too powerful" or dismissing it as "too weak" - both complaints reflect the same character used well or poorly. A team of Glitter Boys or mixed adventurers using teamwork and cleverness should be rewarded; the GM''s job is to make villains counter that teamwork credibly, not simply hand PCs victories or overwhelm them arbitrarily.',
       updated_at = datetime('now')
 WHERE class_id = 'glitter-boy'
   AND instr(markdown, 'source_book: rifts-core') > 0;

-- ley-line-walker -> Rifts Ultimate Edition p.113-116
UPDATE imported_classes
   SET markdown = '---
id: ley-line-walker
occ_group: magic
name: Ley Line Walker
system: rifts
source_book: Rifts Ultimate Edition p.113-116
category: occ
attribute_requirements: { IQ: 10, PE: 12 }
ppe_base: "3d6x10+20, +3d6 per additional level starting at level two"
starting_money: "1d4x1000"
bonuses:
  saves: { horror_factor: 4, possession: 2, mind_control: 2, curses: 3 }
  at_level:
    - { level: 3, saves: { spell_magic: 1, ritual_magic: 1 } }
    - { level: 6, saves: { spell_magic: 1, ritual_magic: 1 } }
    - { level: 9, saves: { spell_magic: 1, ritual_magic: 1 } }
    - { level: 11, saves: { spell_magic: 1, ritual_magic: 1 } }
    - { level: 14, saves: { spell_magic: 1, ritual_magic: 1 } }
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { choose: 2, from: ["Language: Other"], bonus: 20, per_level: 5, note: "Language: Other, two of choice (+20%). Taken once per language - the picker asks which." }
    - { name: "Climbing", base: 45, per_level: 5, note: "+5%" }
    - { name: "Mathematics: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Land Navigation", base: 40, per_level: 4, note: "+4%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { choose: 1, categories: ["Pilot"], bonus: 5, note: "Pilot: one of choice (+5%)" }
    - { name: "Lore: Demons & Monsters", base: 40, per_level: 5, note: "Lore: Demon & Monster (+15%)" }
    - { choose: 4, categories: ["Technical"], bonus: 10, note: "Lore: four of choice (+10%). The catalog files lore skills under Technical." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Hand to Hand: Expert at the cost of one O.C.C. Related Skill, or Martial Arts (or Assassin, if evil alignment) at the cost of two O.C.C. Related Skills." }
  occ_related_skills:
    count: 7
    categories:
      - { name: "Communications", only: ["Radio: Basic"] }
      - { name: "Domestic", bonus: 10 }
      - { name: "Espionage", only: ["Intelligence"], bonus: 5 }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Medical", only: ["First Aid", "Paramedic"], bonus: 5 }
      - { name: "Physical", except: ["Gymnastics", "Wrestling"] }
      - { name: "Pilot", bonus: 2 }
      - { name: "Pilot Related", bonus: 2 }
      - "Rogue"
      - { name: "Science", bonus: 10 }
      - { name: "Technical", bonus: 5 }
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Two of the seven must be from Science and one from Technical. Electrical, Mechanical and Military offer none and are omitted. Paramedic counts as two skills. All seven category bonuses the book prints - Domestic +10%, Espionage +5%, Medical +5%, Pilot +2%, Pilot Related +2%, Science +10%, Technical +5% - are now APPLIED rather than recorded here, the `bonus` key having landed."
    schedule:
      - { level: 3, count: 2 }
      - { level: 6, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 6
    note: "Plus one additional Secondary Skill at levels 4, 8 and 12. These get no bonus other than a possible I.Q. bonus."
equipment_starting:
  - { choose: 1, label: "robe or cape", qty: 1, from: ["robe", "cape"] }
  - { item_id: "clothing", qty: 1 }
  - { item_id: "traveling-clothes", qty: 1 }
  - { choose: 1, label: "light M.D.C. body armor", qty: 1, from: ["dog-pack-dpm-riot-armor", "plastic-man-body-armor", "ca-2-light-dead-boy-armor", "urban-warrior-body-armor"] }
  - { item_id: "knapsack", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "small-sack", qty: 4 }
  - { item_id: "large-sack", qty: 1 }
  - { item_id: "wooden-stake", qty: 6 }
  - { item_id: "small-mallet", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "binoculars", qty: 1 }
  - { choose: 1, label: "tinted goggles or sunglasses", qty: 1, from: ["sunglasses", "tinted-goggles"] }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "gas-mask", qty: 1 }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "lightweight-cord", qty: 1 }
  - { item_id: "grappling-hook", qty: 1 }
  - { choose: 1, label: "pen or pencil", qty: 1, from: ["pen", "pencil"] }
  - { choose: 1, label: "note or sketch pad", qty: 1, from: ["note-pad", "sketch-pad"] }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "hand-axe", qty: 1 }
  - { choose: 1, label: "automatic pistol or submachine-gun", qty: 1, from: ["automatic-pistol", "submachine-gun"] }
  - { choose: 1, label: "energy pistol or rifle", qty: 1, from: ["wilk-s-320-laser-pistol", "ng-33-northern-gun-laser-pistol", "ng-57-northern-gun-heavy-duty-ion-blaster", "c-18-laser-pistol", "wilk-s-447-laser-rifle", "ng-l5-northern-gun-laser-rifle", "l-20-pulse-rifle"] }
  - { item_id: "ammunition-clips", qty: 3 }
natural_abilities:
  - name: "Sense Ley Line"
    description: "The Ley Line Walker can feel whether there is a ley line within the area of his sensing abilities, 10 miles (16 km) per level of experience. He can tell whether it is near or far and follow the feeling to the location of the ley line. Base Skill: 30% +5% per each additional level of experience."
  - name: "Sense Ley Line Nexus"
    description: "Once the ley line has been found, the walker can follow the ley line to as many nexus points as it may have. A nexus point is where two or more ley lines cross/intersect. Base Skill: 40% +5% per each additional level of experience."
  - name: "Sense a Rift"
    description: "The mage will automatically feel the sensation of a Rift opening or closing anywhere within 50 miles (80 km) of him. Increase the sensing range 10 miles (16 km) per each additional level of experience starting with level two. Although he cannot tell exactly where this Rift is, the mage knows if it is near or far and whether it is big or small. Note: When actually on a ley line, the Line Walker will know exactly where the Rift is located and he can sense one wherever it is, as long as it is on the ley line or a connecting line."
  - name: "Sense Magic in Use"
    description: "The expenditure of magic in the form of a spell, Rifting, or Techno-Wizardry can be felt, if not seen, up to 100 feet (30.5 m) away per every level of the Line Walker''s experience. The Line Walker will not know the location nor be able to trace it, but he will feel its energy and know that magic is being used in the area of his sensing range. Note: This does not include the use of psionic powers."
  - name: "See Magic Energy"
    description: "The mage sees magic energy/P.P.E. radiating from people, creatures, objects, and areas, as a faint aura whenever more than 20 P.P.E. points are present. The sensing ability is so acute that the Ley Line Walker can see things made invisible by magic and invisible things that are magical, including invisible dragons and other creatures of magic. This special sight occurs only when the mage desires to use it and focuses on seeing the magically invisible. However, the effort uses up one melee attack/action per round (15 seconds) that this special sight is willed in place. Note: Does not work on the spell, Invisibility Superior. Range: Line of sight, about 1000 feet (305 m)."
  - name: "Read Ley Lines"
    description: "This power instills the mage with instant information about the ley line in a matter of moments. The Ley Line Walker will know the following: what directions the ley line runs (and therefore, his location on it; north, south, east, west, etc.), how long the line runs, whether there are any nexus points and where, and whether there are any Rifts presently open along the line. The character also knows about any major natural disasters currently happening along the line, such as a forest fire, flooding, hurricane, or earthquake. War and magic are not natural disasters. The power is automatic and does not require the expenditure of personal P.P.E."
  - name: "Ley Line Transmission"
    description: "A Ley Line Walker can send a verbal and/or visual message directly along a ley line to another person so long as that person is located somewhere on the line. The best messages are brief ones of under a hundred words to avoid overwhelming the recipient. Unfortunately, the message is a one way transmission unless the other person is also a Line Walker or other mage with the Transmission spell. Range is limited only by the length of the ley line and the people''s position on the line. The time lapse between sending and receiving a ley line transmission is only a matter of seconds. The message can be sent to one specific person or several people (one person per level of the sender''s experience), or several people at different locations on the line. There is a 01-20% chance that a telepathic individual (psionic or magic) may be able to listen in on the message. Any psionic or magic character with Telepathy will sense a Ley Line Transmission coming through, and eavesdrop (01-31% chance) that they too can receive the message). There is no way for the sender to know if others have eavesdropped on his message. Nor is there any way to scramble the message. This power is an automatic ability for the Ley Line Walker and does not require the expenditure of personal P.P.E."
  - name: "Ley Line Phasing (teleportaton)"
    description: "A Ley Line Walker also has the power to instantly teleport from one place to another, FLAWLESSLY anywhere on the same ley line. That can be anywhere in any direction (ley lines can be a quarter/0.4 km to one full mile/1.6 km wide!), including up into the air (ley lines are typically a half mile/0.8 km to two miles/3.2 km tall) and hang there because Line Walkers can walk a ley line, as in walk floating above the ground. If he teleports up into the air he can stay suspended (+20% to Prowl/hide, because us ground dwelling humans don''t usually look up). To do this Ley Line Teleport the mage must concentrate, opening himself to the ley line energy and focusing all of his thoughts to the task of teleporting to the new location. Engaging in conversation or combat, even self-defense, will break the concentration, forcing the mage to start over. The process requires 1D4 melees (15 to 60 seconds) of concentration every time before the teleportation happens, so he can''t just pop out in a heartbeat, but it''s very, very handy. The teleport is always on target, because the Ley Line Walker is one with the ley line. Of course, unless he can see his destination, he can''t know who or what might also be present in that area and he could appear in the middle of an armed camp (but not inside one of them or a tree, etc., as is the danger with the Teleportation spell). Note: Ley Line Phasing is an automatic ability common to all Ley Line Walkers at NO P.P.E. cost, but it does take its toll on the body. The maximum number of phasings/teleports possible is four per hour. The per 24 hour period is 4 +2 per each level of experience (6 at level one, 8 at level two, 10 at level three, etc). More than this is just impossible. The only other limitations are: 1) He can only teleport himself and his possessions, nobody else. 2) The location must be along the same ley line as if traveling on a mystic railway. To switch to a different ley line, the character must travel or teleport to the nexus point intersection where two or more different ley lines cross paths to follow one of the other lines."
  - name: "Ley Line Walking or Line Drifting"
    description: "A Ley Line Walker can open himself to the ley line energies and walk or float through the air along the length of the ley line. The speed factor is a mere Speed of 10, but is relaxing and requires absolutely no exertion or even physical movement of the feet or body if drifting afloat. NO P.P.E. is necessary for Ley Line Walker to do this, because he''s drawing on the ambient energy of the line and his attunement to ley line energy make him practically a living part of the line itself. Note: He can even meditate while drifting down a ley line. Height is typically 1-5 feet (0.3 to 1.5 m) above the ground, but if he concentrates he can reach a height as great as the line itself. This is dangerous, however, as it leaves him out in the open easy to see from a great distance. Just below or just above treetop level is common among those who like to be high above the ground."
  - name: "Ley Line Rejuvenation"
    description: "The character can absorb ley line energy to double the rate of natural healing. To do this, the mage must concentrate and relax on a ley line, letting the mystic energy fill him and heal him over a period of days. The mage can also perform an instant rejuvenation on a ley line as often as once every 24 hours, in which after about ten minutes of concentration, he is completely rested, alert, and healed of 20 Hit Points and 20 S.D.C. +1D6 additional Hit Points and 2D6 S.D.C. (or 4D6 M.D.C. if a Mega-Damage being) per level of experience! Again at no P.P.E. cost, but only possible on a ley line. Note: No P.P.E. or I.S.P. can be restored this way, only Hit Points and S.D.C."
  - name: "Ley Line Observation Ball"
    description: "A globe of light, about the size of a soccer ball, can be conjured out of thin air and linked to the Ley Line Walker like a third eye. The sphere of blue or white light can be directed by its creator to zoom ahead or behind him like a remote control spy device or familiar. Everything that the ball sees and hears is instantly transmitted to its maker. The sphere will remain in existence as long as the Ley Line Walker stays within the ley line, or until he dispels it, or until it is destroyed. Stats for a typical Observation Ball: M.D.C.: One point per level of its creator. Range: Up to 500 feet (152 m) away from its creator per level of experience, so a fifth level Ley Line Walker could send his Observation Ball 2500 feet away and a tenth level mage almost one mile (1.6 km). Speed: Up to Spd 44 (30 mph/48 km). Bonuses: +3 to dodge. It has no offensive capabilities other than to buzz onlookers and possibly startle them (not likely). Actions of that sort, however, require the Ley Line Walker to have line of sight on the ball for him to direct it mentally, each attack/action of the ball counting as one of his own melee actions/attacks."
  - name: "Affinity with Rift & Ley Line Magic"
    description: "The Spell Invocations known as Rift & Ley Line Magic are most commonly known by the Ley Line Walker O.C.C. These spells are common to the Ley Line Walker and although these spells can be important to the profession, the Ley Line Walker does not start with any at level one (unless a Ley Line Rifter O.C.C.). They are usually acquired over time. The Rift & Ley Line Magic spells are: Dimensional Portal (1000), Ley Line Fade (20), Ley Line Ghost (80 or 240), Ley Line Phantom (40), Ley Line Restoration (800+), Ley Line Resurrection (2000+), Ley Line Shutdown (3000), Ley Line Storm Defense (180), Ley Line Tendril Bolts (26), Ley Line Time Capsule (15), Ley Line Time Flux (80), Ley Line Transmission (30), Rift to Limbo (160), Rift Teleportation (200), Rift Triangular Defense System (840), Summon Ley Line Storm (500), Swallowing Rift (300). Learning them: These spells can be learned by being taught by an elder mage or by communing with the ley line. This can occur upon reaching a new mystic plateau (new level of experience), in which the character goes off onto a ley line allow and goes into a meditative trance that last 48 hours. At the end of the trance he knows one of these spells (pick one)."
  - name: "Ley Line Force Field"
    description: "The Ley Line Walker can also put in place an energy field reminiscent of the Armor of Ithan around himself whenever he''s on a ley line. This extra bit of protection provides 20 M.D.C. +2 M.D.C. per level of its creator''s experience. It costs the mage 10 P.P.E. to create/summon it initially, but once it is in place it remains up for the entire time he remains on the ley line or until he dispels it. If the Ley Line Force Field is destroyed, it will regenerate at full strength at the start of the next melee round. Note: Having the force field up and in place draws upon half the ambient P.P.E. of the ley line normally available (20 P.P.E.) to the Ley Line Walker per melee round. Energy the mage often draws upon to supplement his own spell casting. This could be a problem in a combat situation and require the character to drop his protective field to tap more energy."
  - name: "Initial Spell Knowledge"
    description: "In addition to the ley line powers, the Ley Line Walker is a master of spell magic (tends to avoid ritual magic, but can perform rituals if so needed). At level one experience, players may select any three spells from each magic Level 1-4, for a total of 12 spells (three from each). Each additional level of experience, the character will be able to figure out/select one new spell equal to his own level of achievement/experience. So a 4th level Ley Line Walker can select one new spell from level four, or from levels one, two or three (not one from each)."
  - name: "Learning New Spells"
    description: "Additional spells and rituals of any magic level can be learned and or purchased at any time regardless of the character''s experience level."
  - name: "P.P.E."
    description: "Like all practitioners of magic, the Ley Line Walker is a living battery of mystic energy. He draws upon that energy reserve to cast his spells and use magic. The Line Walker has the greatest amount of permanent P.P.E. of all mortal practitioners of magic. Permanent Base P.P.E.: 3D6x10+20 added to the character''s P.E. attribute number to start. Plus an additional 3D6 P.P.E. per each additional level of experience starting at level two. Supplemental P.P.E.: The Ley Line Walker can also draw an extra 20 P.P.E. per melee round when on a ley line and 40 when at a ley lines nexus point! P.P.E. can also be stolen from living creatures and people by killing them (hence rituals involving human sacrifices) because their P.P.E. is doubled at the moment of death! However, a character of good or Unprincipled alignment would never do such a thing (except possibly under the most extreme circumstance). People can also willingly give up a portion of their P.P.E., but that''s an unusual situation."
special_abilities:
  - name: "Mental Attribute Bonus (I.Q.)"
    description: "+1D4 to I.Q. The book grants +1D4 to one Mental attribute of the player''s choice."
    bonuses: { attributes: { IQ: "1d4" } }
  - name: "Mental Attribute Bonus (M.E.)"
    description: "+1D4 to M.E. The book grants +1D4 to one Mental attribute of the player''s choice."
    bonuses: { attributes: { ME: "1d4" } }
  - name: "Mental Attribute Bonus (M.A.)"
    description: "+1D4 to M.A. The book grants +1D4 to one Mental attribute of the player''s choice."
    bonuses: { attributes: { MA: "1d4" } }
  - { choose: 1, from: ["Mental Attribute Bonus (I.Q.)", "Mental Attribute Bonus (M.E.)", "Mental Attribute Bonus (M.A.)"] }
magic:
  type: "Ley Line Walker (Wizard)"
  spells_starting: 12
  spell_levels_allowed: [1, 2, 3, 4]
  spells_per_level: 2
  spells_per_level_levels: up_to_character_level
extraction_notes: |
  - The +1D4 bonus applies to any ONE Mental attribute (I.Q., M.E., or M.A.) at
    the player''s choice; modelled as three special_abilities fragments behind a
    choose-1 group, so the wizard offers the pick and the die rolls at creation.
  - The ley line powers are automatic rather than chosen, so they live under
    natural_abilities; special_abilities holds only the attribute pick. Fixed
    skill bases fold the O.C.C. bonus into the catalog base (Climbing 40+5=45),
    and "Math: Basic" / "Lore: Demon & Monster" are stored under their catalog
    names, Basic Math and Lore: Demons & Monsters.
  - The "+2 to save vs possession and mind control" bonus is recorded as both
    possession and mind_control - the derive layer carries a mind_control key
    (the Juicer''s +6 uses it), which an earlier revision of these notes
    believed did not exist.
  - The "+3 to save vs curses" at levels three, nine, eleven and fourteen is
    carried as bonuses.at_level entries, which accumulate as the character
    reaches each level. "+1 to spell strength" at levels 3, 7, 10 and 13 and
    "+1 on Perception Rolls at levels 2, 5, 7, 10, and 13; double when on a
    ley line" stay recorded here: neither spell strength nor perception is a
    derived stat yet, so there is still no key for a number to land on.
  - P.P.E. Recovery: spent P.P.E. recovers at a rate of seven points per hour of sleep or rest. Meditation restores P.P.E. at 15 per hour of meditation and is equal to one hour of sleep for this character when it comes to recovery from fatigue and physical rest. Not a schema field.
  - Cybernetics: "Starts with none and will avoid getting any cybernetic or other forms of physical augmentation because it interferes with magic. However, Bio-System prosthetics will be considered if necessary." Not modeled as a field; noted here.
  - Racial Requirement: "None. At least 30% are D-Bees." Not modeled since no explicit numeric requirement field exists for a distribution note; noted here.
  - Vehicle/weapon choice notes: "Vehicle of choice is usually a Techno-Wizardry device or hover vehicle or motorcycle or jet pack" is left as a choice not encoded in equipment_starting since no specific item slugs are given.
  - Ley Line Rifter O.C.C. begins at the end of this page range (page 4) but is a separate class and intentionally excluded from this extraction.
---

## Lore

The Ley Line Walker is a spell casting wizard but is anything but traditional. The mage is so attuned to ley lines that he can see magic energy emanating from even weak ley lines, normally invisible to the human eye, and see invisible magic energy (P.P.E.) radiating from living beings, enchanted/magic objects, Techno-Wizard devices, and supernatural creatures. This is not a see aura, but an ability to actually see mystic energy waves. Furthermore, the Ley Line Walker can feel the presence of ley lines, pinpoint nexus areas, and tell when a Rift has opened nearby.

The pursuit of magic is a means to utilize natural energy and direct it with one''s own force of will. The Ley Line Walker spends years learning to focus his thoughts and build his will in order to direct and mold mystic energy. He also spends years learning how to let the ley line energy flow into and through him, building his tolerance for magic energy and making the Line Walker a sort of living relay station and energy transformer, as well as a P.P.E. battery. At these moments, the Line Walker becomes part of the energy he is directing and it gives him much greater control and range of magic abilities.

Ley Line Walkers are inquisitive and open to new ideas, people, and philosophies. Many are literate, study areas of science and have no aversion to using high-tech weapons, vehicles, and equipment. Lightweight weapons and armor are generally preferred because they are less cumbersome and do not interfere with the flow of magic energy (full body armor and bionics block and disrupt magic energy).

The traditional garb of the Ley Line Walker comes from the beginning of the Dark Age and always includes some kind of headgear and tunic to cover the head and part of the face, a hooded cloak or cape (very big in cloaks and capes), loose fitting robes, loincloth (worn over pants or robes) and/or ornate belt with inscribed strips of cloth or ornate jewelry dangling from the waist, walking boots, and a gas mask or air filter to cover the mouth. Goggles, horns, and other face wrappings and coverings may also be part of the ensemble.

There are two schools of thought about Rift & Ley Line Magic. One is the typical Line Walker who feels Ley Line Magic is useful, but no more important or significant than any other spell invocation. The smaller camp who feel Ley Line Magic is of significant and overriding value is the Ley Line Rifter camp, described as elitists with unique and keen insights whose focus makes them special - specialists in Rift and Ley Line Magic, which most Ley Line Walkers and other practitioners of magic regard as short-sighted and limiting.

## GM Notes

**Ley Line Walker Concealed Body Armor:** Although it is not usually visible, light to medium body armor is worn under the robes. The chest, shoulders, thighs and back of the head are always protected. Two thirds of the time the M.D.C. plating also covers the arms as vambraces and armored gauntlets, and the rest of the legs as well. Again, it is either concealed under the robes or loose, baggy clothing, or so stylish it looks like ornamental arm bracelets or vambraces rather than armor. The materials are often made from natural M.D.C. materials like the plates from a Fury Beetle or hide of a dinosaur, and interlaced with M.D. ceramic plates, padding and miracle fibers. M.D. metal alloys may be used but are kept to a minimum because they interfere with the flow of P.P.E. and interferes with the ability to cast spells. Remember, the mage also has magic spells, such as Armor of Ithan, Impervious to Fire, etc., he can cast to provide additional protection for himself.

Stats for Concealed Ley Line Walker Armor: Light Armor Protection: 2D6+32 M.D.C. main body. Medium Armor: 3D6+50 M.D.C. main body; arms typically have 11-18 M.D.C., legs have 22-28 M.D.C.; -5% to Prowl, Climb, Swimming and other physical skills. Both are very common. Seldom wears heavy body armor. Heavy and full body armor are available in a variety of styles, but are seldom worn (maybe 10% wear them). For one, it''s too bulky and uncomfortable, and for another, it''s expensive, and lastly, unless it is made predominantly with natural materials, conventional environmental armor prevents spell casting. Techno-Wizard armor is one alternative for superior protection as well as a few non-magical alternatives, but Mage Armor always requires special consideration and construction to allow spell casting and the use of special abilities.

GMs should note the tension between the two philosophical camps of Ley Line Walkers (generalists vs. the specialist "Ley Line Rifter" mindset) as a roleplaying and rivalry hook - some Rifters look down on generalist Walkers, and vice versa.',
       updated_at = datetime('now')
 WHERE class_id = 'ley-line-walker'
   AND instr(markdown, 'source_book: rifts-core') > 0;

-- dragon-hatchling -> Rifts RPG (original core book)
UPDATE imported_classes
   SET markdown = '---
id: dragon-hatchling
name: Dragon Hatchling (Great Horned)
system: rifts
source_book: Rifts RPG (original core book)
category: rcc
attribute_dice:
  IQ: "5d6"
  ME: "5d6"
  MA: "4d6"
  PS: "6d6"
  PP: "4d6"
  PE: "5d6"
  PB: "6d6"
  Spd: "4d6"
mdc_base: "1d4x100+50"
ppe_base: "2d6x10"
bonuses:
  combat: { attacks: 1 }
skills:
  occ_skills:
    - { name: "Literacy: Dragonese/Elven", base: 98, per_level: 0 }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "One additional language of choice, usually American" }
    - { name: "Mathematics: Basic", base: 98, per_level: 0 }
  occ_related_skills:
    count: 6
    categories: ["Communications", "Domestic", "Military", "Pilot", "Pilot Related", "Rogue", "Technical", "Wilderness"]
    note: "No skill bonuses other than a possible I.Q. bonus. The hatchling is too busy testing its natural abilities to concentrate on mundane human skills."
    schedule:
      - { level: 4, count: 4 }
      - { level: 8, count: 4 }
psionics:
  type: "major"
  isp_base: "3d4x10"
  powers_starting: 8
  categories_allowed: ["Healing", "Physical", "Sensitive"]
natural_abilities:
  - name: "Flight"
    description: "Flies at 70 mph (112 km)."
  - name: "Nightvision"
    description: "90 feet (27.4 m)."
  - name: "See the Invisible"
    description: "Perceives normally invisible creatures and objects."
  - name: "Fire and Cold Resistant"
    description: "Takes half damage from fire and cold."
  - name: "Bio-Regeneration"
    description: "Recovers 1D4x10 M.D. points every five minutes."
  - name: "Armor Rating"
    description: "The skin is a mega-damage substance impervious to normal weapons. Magic, psionics and mega-damage weapons have full effect."
  - name: "Metamorphosis"
    description: "Completely alters its physical shape to look like any living animal, from human being to raven. Cannot become an inanimate object or an insect; minimum size is about that of a cat and the maximum cannot exceed its own. Lasts two hours per level of experience, tripled on or near a ley line or nexus point within two miles (3.2 km). A dragon in another shape keeps all its natural powers and gains none of the animal''s."
  - name: "Teleport"
    description: "28% +2% per level of experience, at will, up to five miles away. At the hatchling stage it can teleport only itself, and may attempt one every other melee round. Only a mature dragon can teleport dimensionally without a ley line nexus."
  - name: "Fire Breath"
    description: "2D6 Mega-Damage, range 60 feet (18 m)."
  - name: "Claws and Bite"
    description: "Claws inflict 2D6 Mega-Damage, bite 2D4 Mega-Damage."
special_abilities:
  - name: "Magic Knowledge"
    description: "A full understanding of magic, but the hatchling knows NO spells yet. It can intuitively use all types of techno-wizardry devices without instruction, read magic, use scrolls, and recognize magic circles and enchantment. It can also sense ley lines, nexus points and other dragons within 20 miles (32 km) - nearness and general direction only, never a pinpoint location."
  - name: "Learning Spells"
    description: "Spells can be learned by the usual means beginning at third level. The hatchling can cast two new spells per level of experience."
  - name: "Combat Abilities"
    description: "Equal to Hand to Hand: Basic, plus one extra melee attack."
level_progression:
  - level: 3
    grants: ["May begin learning spells by the usual means; two new spells per level"]
  - level: 5
    grants: ["+4 psionic powers"]
  - level: 10
    grants: ["+4 psionic powers"]
restrictions:
  - "A dragon is a hatchling until full maturity at roughly 600 years of age."
  - "Without a chosen alignment the hatchling starts anarchist - self serving, greedy and snotty - and must settle on a definitive alignment at level three."
  - "Hatchlings are naive about the modern world; play accordingly."
extraction_notes: |
  - AUDIT (Rifts p.98, p.100). The previous definition was invented almost throughout.
    Every attribute was written as a 3d6/4d6 pool with a flat modifier; the book gives
    plain dice pools of varying size (I.Q. 5D6, P.S. 6D6, P.B. 6D6, Spd 4D6 and so on).
  - The hatchling knows NO spells. The class previously granted four spells of levels
    1-2 through a `magic` block, which the book contradicts directly: spells can first
    be learned at third level, two per level thereafter.
  - Psionics: eight powers, not the six the major-psionic default gives, and I.S.P. is
    3D4x10 rather than the 1d6x10+30 recorded.
  - The extra melee attack is now a real bonus rather than prose.
  - Not expressible: the 28% +2%/level teleport chance, "two new spells per level from
    third", and the alignment defaulting to anarchist until level three. All recorded
    as prose.
---
## Lore

Great Horned Dragons are among the mightiest beings of the Megaverse, and even
a hatchling ' || char(8212) || ' mere decades old ' || char(8212) || ' is a creature of Mega-Damage flesh, innate
magic, and razor intellect. Hatchling player characters are newly hatched
(often orphaned by dimension-hopping circumstance), possessing terrifying raw
power but a child''s understanding of the world. They metamorphose into human
form to walk among mortals, and most are insatiably curious.

## GM Notes

The power gap between a hatchling and human classes is real ' || char(8212) || ' lean on the
naivete and the attention a young dragon attracts (Coalition, dragon hunters,
other dragons) to balance the table. Metamorphosis does not grant the copied
creature''s abilities, only its shape.
',
       updated_at = datetime('now')
 WHERE class_id = 'dragon-hatchling'
   AND instr(markdown, 'source_book: rifts-core') > 0;

-- Read the result back rather than trusting the exit code.
SELECT class_id,
       length(markdown) AS bytes,
       instr(markdown, char(13)) > 0                      AS has_cr,
       instr(markdown, 'source_book: rifts-core') > 0     AS still_pre_rue
  FROM imported_classes
 WHERE class_id IN ('cyber-knight', 'glitter-boy', 'ley-line-walker', 'dragon-hatchling')
 ORDER BY class_id;

-- The Cyber-Knight's specific corrections, counted arithmetically: D1 rejects a
-- compound SELECT built from about nine literals and rolls the file back.
SELECT (instr(markdown, 'Horsemanship: Cyber-Knight') > 0)
     + (instr(markdown, 'Breaking/Taming Wild Horse') > 0)
     + (instr(markdown, 'Basic Mechanics') > 0)
     + (instr(markdown, 'level: 15, count: 2') > 0)        AS ck_of_four
  FROM imported_classes WHERE class_id = 'cyber-knight';

INSERT INTO data_script_runs (filename) VALUES ('fix-pre-rue-class-audit.sql');
