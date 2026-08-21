-- The Juicer O.C.C., recovered into the repo.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-juicer-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-juicer-class.sql
--
-- WHY THIS EXISTS, LATE. This class predates the data-script convention: it was
-- imported through the UI, and every correction to it since is a fix-*.sql that
-- PATCHES a row nothing in the repo creates. So `schema.sql` plus the data
-- scripts rebuilt 24 of 26 published classes, and this was one of the two that
-- existed only in the live database. A drift check comparing production against
-- a database built from nothing is what turned it up.
--
-- The markdown below is production's CURRENT state, corrections included. The
-- fix-*.sql scripts that produced those corrections are each guarded on the
-- text they replace, so on a fresh build they find the corrected wording
-- already there and do nothing - which is what those guards are for.
--
-- INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE, so re-running is a
-- no-op instead of a silent partial write. On production this already finds the
-- row and does nothing; it is a fresh environment that needs it.

INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'juicer', 'Juicer', 'rifts', '---
id: juicer
name: Juicer
system: rifts
source_book: Rifts Ultimate Edition p.79-81
category: occ
hit_points_base: "P.E. + 1d4x10, +1d6 per level"
sdc_base: "1d4x100"
starting_money: "4d6x100"
bonuses:
  combat: { initiative: 4, attacks: 2, roll: 3, pull_punch: 2 }
  attributes: { PS: "2d6", PE: "2d6", Spd: "2d4x10" }
  attribute_minimums: { PS: 22 }
  saves: { psionics: 4, mind_control: 6, toxins_poisons: 8, harmful_drugs: 8, coma_death_pct: 20 }
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 92, per_level: 1, note: "At 92%." }
    - { choose: 2, categories: ["Communications"], bonus: 10, note: "Language: Other, two of choice (+10%)." }
    - { name: "Acrobatics", base: 45, per_level: 5, note: "+15%" }
    - { name: "Climbing", base: 60, per_level: 5, note: "+20%" }
    - { name: "Land Navigation", base: 41, per_level: 4, note: "+5%" }
    - { choose: 2, categories: ["Pilot"], bonus: 10, note: "Pilot: two of choice (+10%)." }
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Recognize Weapon Quality", base: 35, per_level: 5, note: "+10%" }
    - { name: "Running", base: 0, per_level: 0 }
    - { name: "Swimming", base: 60, per_level: 5, note: "+10%" }
    - { name: "W.P. Knife", base: 0, per_level: 0 }
    - { name: "W.P. Energy Pistol", base: 0, per_level: 0 }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P.: two of choice (any)." }
    - { name: "Wilderness Survival", base: 35, per_level: 5, note: "+5%" }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "May be changed to Hand to Hand: Martial Arts (or Assassin, if an evil alignment) at the cost of one O.C.C. Related Skill." }
  occ_related_skills:
    count: 8
    categories:
      - "Communications"
      - { name: "Cowboy", only: ["Breaking/Taming Wild Horses", "Roping", "Trick Riding"] }
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", only: ["Detect Ambush", "Detect Concealment", "Escape Artist", "Intelligence"] }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Mechanical", only: ["Automotive Mechanics", "Basic Mechanics"] }
      - { name: "Medical", only: ["First Aid"] }
      - "Military"
      - "Physical"
      - "Pilot"
      - "Pilot Related"
      - "Rogue"
      - { name: "Science", only: ["Basic Math", "Advanced Math"] }
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Espionage: the four named only (+5%). Military: Any (+10%). Physical: Any (+10% where applicable). Pilot: Any (+5% on all military types). Pilot Related: Any (+5%). Rogue: Any (+2% to most, +15% to Prowl). Science: Math skills only. Wilderness: Any (+5%)."
    schedule:
      - { level: 2, count: 1 }
      - { level: 5, count: 1 }
      - { level: 7, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 2
    schedule:
      - { level: 3, count: 2 }
      - { level: 6, count: 2 }
      - { level: 8, count: 2 }
      - { level: 10, count: 2 }
      - { level: 12, count: 2 }
equipment_starting:
  - { item_id: "bio-comp-system", qty: 1 }
  - { item_id: "drug-injection-harness", qty: 1 }
  - { item_id: "juicer-flex-plate-armor", qty: 1 }
  - { item_id: "optic-helmet", qty: 1 }
  - { item_id: "portable-irmss-kit", qty: 1 }
  - { item_id: "camouflage-fatigues", qty: 1 }
  - { item_id: "grey-fatigues", qty: 1 }
  - { item_id: "boots-with-knife-holster", qty: 1 }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "sunglasses", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "compass", qty: 1 }
  - { item_id: "ja-11-juicer-assassin-s-energy-rifle", qty: 1 }
  - { choose: 1, label: "energy pistol", qty: 1, from: ["ng-33-northern-gun-laser-pistol", "wilk-s-320-laser-pistol", "ng-57-northern-gun-heavy-duty-ion-blaster", "ng-super-laser-pistol-and-grenade-launcher"] }
  - { item_id: "e-clip", qty: 1 }
  - { choose: 1, label: "non-energy weapon", qty: 1, from: ["vibro-knife", "vibro-saber", "vibro-sword"] }
  - { item_id: "vibro-knife", qty: 1 }
special_abilities:
  - name: "Super-Endurance"
    description: "Add 1D4x100 S.D.C., add 1D4x10 Hit Points, and 2D6 to P.E. attribute. Can lift and carry four times more than a normal person of equivalent strength and endurance, and can last 10 times longer before feeling the effects of exhaustion. Can remain alert and operate at full efficiency for up to five days (120 hours) without sleep. Normally needs only three hours of sleep per day."
  - name: "Super-Strength"
    description: "Add 2D6 to P.S. attribute. Minimum P.S. is 22; if lower, adjust up to P.S. 22. See the Augmented P.S. table for specifics on P.S. and damage."
  - name: "Super-Speed"
    description: "Add 2D4x10 to Spd attribute. Can leap 30 feet (9.1 m) across and 20 feet (6.1 m) high after a short run; half that distance from a dead stop."
  - name: "Super-Reflexes and Reaction Time"
    description: "An accelerated metabolism makes everything around the Juicer seem to move in slow motion. Bonuses: +2 attacks per melee round, +4 on initiative, +2 on Perception Rolls, +2 to disarm, +2 to pull punch, +3 to roll with impact, and an AUTOMATIC DODGE on all attacks, even from behind and surprise - the act of dodging does NOT use up a melee attack (normal dodge bonuses do not apply, but P.P. bonuses do). +1 to auto-dodge at levels 1, 3, 6, 9 and 12."
  - name: "Saving Throw Bonuses"
    description: "+4 to save vs psionics, +6 to save vs mind control (psionic and chemical), +8 to save vs toxic gases, poisons, and other drugs. The bio-comp can slow blood flow or increase oxygen levels to slow the effects of drugs, or inject natural and synthetic chemicals to counteract them immediately; the Juicer can also slip into a trance-like state to conserve oxygen."
  - name: "Enhanced Healing"
    description: "Heals four times faster than normal. +20% to save vs coma and death. Virtually impervious to pain - no amount of physical pain will impair the Juicer until he is down to 5 Hit Points or less, at which point the warrior collapses into a bio-comp induced trance/coma of accelerated healing."
  - name: "IRMSS (Internal Robot Medical Surgeon System)"
    description: "Two housing units of microscopic medical robots: an external chest plate over the heart (robots injected directly into a main heart artery reach a torn vein or artery anywhere in the body within 60 seconds) and an internal neck unit controlled by the bio-comp, whose robots can be guided back and recharged by the body''s own electro-magnetic energy to be used over and over. All IRMSS units stop bleeding, suture veins and arteries, and aid internal repair."
restrictions:
  - "Racial Requirement: 95% human. The pre-Rifts technology was created specifically for humans; adapting it to nonhumans is lethal unless the D-Bee is very human-like."
  - "Penalties: cannot sleep without a sedative or tranquilizers; jumpy and anxious; when jolted alert from a zoned-out state (15 seconds/one melee), the first melee round is at HALF normal combat bonuses."
  - "The Juicer will die after five years and 4D6 months. No exceptions, no saving throws. Not even psionic healing or magic Restoration or Resurrection (-50% success for Juicers) can help."
extraction_notes: |
  - EDITION UPDATE: rewritten against Rifts Ultimate Edition p.79-81. The
    previous entry was audited against the original Rifts core book (p.69-71);
    RUE revised the class. Changes: roll bonus 4 to 3, +2 pull punch added,
    the P.P. +2D4 bonus and P.P. 20 minimum removed (RUE grants neither),
    automatic parry removed (auto-DODGE only), O.C.C. skills gained
    Acrobatics/Climbing/Recognize Weapon Quality/Running/Swimming and fixed
    W.P. Energy Pistol, languages two of choice (not three), related skills
    8 with +1 at 2/5/7/9/12 (was 7 with a different schedule), secondary 2 at
    levels 1/3/6/8/10/12 (was a flat 6).
  - +2 Perception, +2 disarm and the auto-dodge progression have no bonus key
    and live in the Super-Reflexes description.
  - Equipment: 2D4 E-Clips for each energy weapon, one weapon for each W.P. -
    dice and per-W.P. quantities stay prose. Money: 4D6x100 credits plus
    4D6x100 in Black Market items. Cybernetics: starts with none, by pride.
  - Detoxification percentile tables are transcribed in GM Notes.
---

## Lore

In man''s search to create the ultimate human, it was inevitable that someone would turn to chemical enhancement. The bio-comp system - two tiny mega-computers linked to hundreds of microscopic sensors threaded through the body - monitors blood flow, oxygen, adrenaline, hormones and neurological responses, triggering precise doses of designer drugs through an injection collar and harness. The same nano-technology drives the IRMSS, a battery of microscopic robots programmed to perform internal surgery.

The chemically "juiced-up" subject is 10 times faster, stronger and more alert than the average human, perceiving the world in slow motion while moving with lightning speed. "Live fast. Die young." The strain on all systems is so terrible that the body literally burns out: the heart of a 20 year old Juicer can just explode one day. Without exception, a Juicer over five years old will die of a stroke or heart failure before his eighth year of service; average life expectancy is six years.

Juicer mercenaries are among the most highly paid and feared in the Americas. The usual deal is Juicer conversion and big pay (4D4x10,000 credits a year) for two years of loyal service in an army. Conversion can be purchased outright at places like Kingsdale and MercTown for a staggering 400,000 credits. The Coalition had outlawed Juicer technology, but the War in Tolkeen and the Campaign of Unity sanctioned Juicers in the Coalition Military; the CS still refuses to hire Juicer mercenaries, and anyone convicted of creating a Juicer in CS territory is executed.

Juicers tend to be bold, outspoken, cocky, self-reliant warriors who live for action, frequently taking unnecessary risks and accepting challenges of strength and combat to prove themselves the ultimate warriors. Related O.C.C.s: Hyperion, Titan, Phaeton, Mega-, Delphi and Dragon Juicers and the Maxi-Killers (Rifts World Book 10: Juicer Uprising); the Euro-Juicer (World Book 5: Triax & the NGR).

## GM Notes

**Detoxification - a chance for survival.** Must be attempted within the first three years as a Juicer; after three years the success ratio is severely reduced and eventually becomes impossible. The steps: (1) Removal of the bio-comp system (the microscopic data implants can remain) and destruction of the drug harness - surgery preferably by a Cyber-Doc, otherwise severe scarring (reduce P.B. by 1D4). (2) Select a new O.C.C.: only Merc Soldier, City Rat, Wilderness Scout and Vagabond are available (or equivalent men-at-arms from other books); the character retains his old skills frozen until the new O.C.C. reaches an equivalent level, and selects seven new skills. (3) The Price of Drugs: ALL Juicer bonuses and powers are permanently gone; all physical attributes reduced to 8 plus a roll of 1D4 each; looks 10 years older per year as a Juicer; reduce P.B. by 1D4; S.D.C. reduced to 5D6; Hit Points P.E. +1D6 per level; -2 on initiative, no automatic dodge; roll on the permanent side effect table: 01-10% no side effects; 11-30% permanent joint stiffness (-1 strike, parry, dodge, roll); 31-50% weakened immune system (-1 all saves, -10% vs coma); 51-70% poor memory (-5% all skills); 71-90% dependent on other drugs or alcohol; 91-00% roll a Phobia and a Neurosis.

**Detox success:** two of three percentile successes to purge; may retry weekly. Year one 01-89%, year two 01-76%, year three 01-59%, year four 01-27%, year five 01-09%, year six 01%, year seven 0%. A failed roll: 01-40% addicted to other drugs or alcohol; 41-70% depressed and racked - all skills at half, combat bonuses and Speed halved (permanent unless successfully shaken); 71-90% wants to become a Juicer again; 91-00% commits suicide. If detox happens in the first or second year: +6D6 S.D.C., +2 P.S., P.P. and P.B., +2D6 Spd, and skip the side effect table.

This is the "Classic" Juicer - see Rifts World Book 10: Juicer Uprising for variants.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'juicer');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'juicer';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-juicer-class.sql');
