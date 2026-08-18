-- The Mind Melter O.C.C., Rifts Ultimate Edition (rifts-core).
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   npx wrangler d1 execute DB --local --file apps/character-creator/db/add-mind-melter-class.sql
--
-- Extracted by Claude from the page images through import/extract and
-- corrected in review (see `extraction_notes` in the markdown). Byte-identical
-- to what the local dress rehearsal published through the real confirm
-- endpoint.
--
-- The gear stubs mirror what that confirm created locally. INSERT OR IGNORE,
-- exactly like buildStubStatements(), so re-running or racing an import is
-- harmless. The em-dash in the stub description is built with char(8212)
-- because passing one through `wrangler d1 execute` on Windows has produced
-- mojibake before. Pure ASCII on purpose, for the same reason.
--
-- The `rifle` stub this class also references is carried by the Glitter Boy
-- script; both guard with INSERT OR IGNORE so order does not matter.

INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('sleeping-bag', 'Sleeping Bag', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'rifts-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('utility-ammo-belt', 'Utility Ammo Belt', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'rifts-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('sunglasses-or-tinted-goggles', 'Sunglasses Or Tinted Goggles', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'rifts-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('air-filter-or-gas-mask', 'Air Filter Or Gas Mask', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'rifts-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('knife', 'Knife', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'rifts-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('food-rations', 'Food Rations', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'rifts-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('hover-vehicle', 'Hover Vehicle', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'rifts-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('hovercycle', 'Hovercycle', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'rifts-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('robot-horse', 'Robot Horse', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'rifts-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('jet-pack', 'Jet Pack', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'rifts-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('motorcycle', 'Motorcycle', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'rifts-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('car', 'Car', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'rifts-core');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('techno-wizard-vehicle', 'Techno Wizard Vehicle', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'rifts-core');

INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('rifle', 'Rifle', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'rifts-core');

INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
VALUES ('mind-melter', 'Mind Melter', 'rifts', '---
id: mind-melter
name: Mind Melter
system: rifts
source_book: rifts-core
category: occ
ppe_base: "2d4"
bonuses:
  combat: { initiative: 3, strike: 1, pull_punch: 2, disarm: 2 }
  saves: { possession: 4, mind_control: 4, insanity: 3, horror_factor: 1 }
psionics:
  type: "master"
  powers_starting: 16
  isp_base: "3d6x10 + M.E. attribute number, +10 I.S.P. for each additional level of experience"
  powers:
    - "Alter Aura"
    - "Mind Block"
    - "See Aura"
    - "Sixth Sense"
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { choose: 2, categories: ["Technical"], bonus: 30, per_level: 5, note: "Language: Other, two of choice (+30%). The catalog has no individual language rows." }
    - { name: "Basic Math", base: 65, per_level: 5, note: "+20%" }
    - { name: "Athletics (general)", base: 0, per_level: 0 }
    - { name: "Streetwise", base: 35, per_level: 4, note: "+15%" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { choose: 2, categories: ["Pilot"], bonus: 10, note: "Two of choice (+10%); any except Robots and Military Vehicles" }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "One of choice" }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Hand to Hand: Expert at the cost of one O.C.C. Related Skill, or Martial Arts (or Assassin, if an evil alignment) for the cost of two O.C.C. Related Skills." }
  occ_related_skills:
    count: 6
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - "Espionage"
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"] }
      - { name: "Medical", only: ["First Aid", "Animal Husbandry", "Brewing"] }
      - "Military"
      - { name: "Physical", except: ["Acrobatics", "Wrestling"] }
      - "Pilot"
      - "Pilot Related"
      - "Rogue"
      - { name: "Science", only: ["Advanced Math"] }
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Cowboy: None (not a catalog category). Category bonuses: Espionage +5%, Pilot +5%, Rogue +2% (+10% to Seduction and Streetwise), Science +15%, Technical +10%. Animal Husbandry and Brewing are book options the catalog does not carry yet."
    schedule:
      - { level: 4, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 6
    note: "+2 additional Secondary Skills at levels 3, 6, 9 and 12."
equipment_starting:
  - { item_id: "traveling-clothes", qty: 2 }
  - { item_id: "clothing", qty: 1 }
  - { item_id: "light-mdc-body-armor", qty: 1 }
  - { item_id: "sleeping-bag", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "utility-ammo-belt", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "sunglasses-or-tinted-goggles", qty: 1 }
  - { item_id: "air-filter-or-gas-mask", qty: 1 }
  - { item_id: "knife", qty: 1 }
  - { item_id: "food-rations", qty: 1 }
  - { choose: 1, label: "energy weapon of choice", qty: 1, from: ["energy-pistol", "energy-rifle"] }
  - { choose: 1, label: "non-energy rifle or other weapon of choice", qty: 1, from: ["rifle", "automatic-pistol", "submachine-gun"] }
  - { choose: 1, label: "vehicle", qty: 1, from: ["hover-vehicle", "hovercycle", "robot-horse", "jet-pack", "motorcycle", "car", "techno-wizard-vehicle"] }
starting_money: "4d6x100"
extraction_notes: |
  - REVIEW: psionics.powers_starting is 16 - the four automatic powers (Alter
    Aura, Mind Block, See Aura, Sixth Sense) plus three from each of the four
    categories at level one. The wizard counts all sixteen as picks, so take
    the four automatic ones first; the level 2+ selection schedule is under GM
    Notes. P.P.E. base is deliberately tiny (2D4) - most potential went to
    psionics.
  - REVIEW: fixed skills fold the O.C.C. bonus into the catalog base
    (Streetwise 20+15=35); "Math: Basic" is stored as Basic Math. The wardrobe
    and food rations became catalog items; the open weapon choices enumerate
    the generic weapon rows.
  - Standard Equipment section notes Mind Melters find Techno-Wizard items fascinating and may adopt one or two as a favorite weapon or vehicle, and may also adopt a favorite magic item (preferring not to use magic items out of deference to their own psi-powers), and rarely carry more than 2-4 weapons total, adopting one or two particularly stylish/exciting favorites. This nuance did not fit equipment_starting cleanly and is preserved here.
  - "Money" entry also states the character has spent the rest of accumulated wealth on pleasure, clothing, and a vehicle, and separately starts with 2D4x1000 in salable Black Market items - recorded here since equipment_starting/starting_money can''t hold both the cash and the salable goods figure.
  - Cybernetics: starts with none; frowns on cybernetics/bionics, will use cybernetics only for medical reasons. Not a schema field, noted here.
  - "The influence of ley line energy" special rule: duration and range of psychic powers +50% within one mile of a ley line, doubled (duration, range, and damage) at or near a ley line nexus point (within one mile); the M.D.C./strength of any Telekinetic Force Field is also doubled near a nexus. No clean bonus field for this conditional/location-based effect, so it is recorded here and in GM Notes.
  - Attribute Requirements state "None," but a high I.Q. and M.E. of 10 or higher are strongly suggested - recorded as an empty attribute_requirements list plus this note since it''s advisory rather than a hard requirement.
  - Race Restrictions: most common among humans (84%); males and females can become Mind Melters. Not a schema field for race-percentage breakdowns, noted here.
  - Related O.C.C.s note points to Rifts World Book 12: Psyscape for other Master Psychics - not applicable to this class''s own stat block, noted for completeness.
---

## Lore

Most people agree that the Mind Melter is the most powerful and versatile of all psychics, at least among humans. Their vast range of powers also makes them one of the most feared. They are one of the few characters who select psychic powers from *all* the psychic power categories, including *Super*!

The Mind Melter relies almost entirely on his incredible psychic powers, a sharp mind and cunning, more than education, weapons or anything else. The most arrogant Mind Melters may even refrain from using more than a handful of modern weapons and devices as a sign of just how powerful they are (or believe they are). This is more than raw arrogance, for the Mind Melter is no man''s fool, and they are truly powerful beings. The *Telekinetic Force Field* is equal to any man-made or magic body armor and can be invisibly erected with a thought. The *Psi-Sword* is a Mega-Damage weapon that can be created out of thin air, just as the Mind Melter can create fire and water or searing pain. Even more terrifying is the Mind Melter''s ability to influence and *control the minds of others*. It is these powers of mental manipulation from which the name, Mind Melter, is derived.

This powerful Master Psychic doesn''t need a machine or outside energy source to fuel his powers, nor does he need to rely on years of magical study and training. No. His powers come from within. They come from his mind, are created at the speed of thought, and are fueled by his willpower and desires. It is from this that springs forth the Mind Melter''s arrogance - for he is a power unto himself. Unfortunately, this sense of power and the ability to manipulate others, all too often makes selfish and evil psychics cruel tyrants and despots. The worst lose touch with their humanity and consider all (or most) other life forms as beneath them. Lesser creatures to be used and manipulated for the Mind Melter''s benefit and amusement. Such foul-hearted villains give the Mind Melter his frightening reputation, but that does not mean all men and women of this profession are evil. There are just as many Mind Melters who have been great champions, fearsome heroes and defenders of the weak and downtrodden.

Mind Melters are forbidden entry to all Coalition cities and unwanted in the ''Burbs or any CS territory or holding. Their strong psychic essence is easily detected by Psi-Stalkers and Dog Boys, and they are always pursued by them. Thus, they are driven from the ''Burbs and always considered "armed and extremely dangerous" whenever and wherever they are encountered. Many CS troops don''t trust a Mind Melter under any circumstances and many kill them at the first opportunity, ideally from behind or while they are asleep or injured!

The Mind Melter has minimal education, having spent much of his time learning and mastering the complexity of psionic powers. The individual has come to rely on those powers, wits, and experience.

## GM Notes

**Special Mind Melter O.C.C. Powers** - power selection progresses steeply by level:

- **1st level:** Automatically knows Alter Aura (self; 4 ISP), Mind Block (4), See Aura (6), and Sixth Sense (2), plus select three additional powers from *each* of the four categories: Healing, Physical, Sensitive, and Super. At first level, Mind Wipe, Psi-Sword, and Mentally Possess Others may NOT be selected from the Super category; these three are unavailable until third level.
- **2nd level:** Select three powers total from Sensitive, Physical, and/or Healing, plus one from Super (still excluding Mind Wipe, Psi-Sword, and Mentally Possess Others).
- **3rd level:** Select three powers total from Sensitive, Physical, and/or Healing, plus one from Super, *including* Mind Wipe, Psi-Sword, and Mentally Possess Others.
- **4th level:** Select two powers from the Super category only.
- **5th level on:** Select two powers total from *any* of the four categories. Super-Psionic abilities are the most coveted at this stage.

As a Master Psychic, the Mind Melter needs a 10 or higher to save vs psionic attacks. Note the character''s permanent P.P.E. base is quite low (2D4) since most P.P.E. potential has been expended developing psychic abilities - GMs should remember this makes the Mind Melter poor at anything requiring raw P.P.E. reserves outside of psionics.

Ley line proximity is a major tactical consideration for this class: within one mile of a ley line, duration/range of psychic powers rise 50%; at a nexus point within one mile, duration, range, *and* damage double, and any Telekinetic Force Field''s effective M.D.C./strength doubles as well. GMs running ley-line-heavy settings should expect Mind Melters to gravitate toward and fight near these locations deliberately.', 'published', 'import')
ON CONFLICT (class_id) DO UPDATE
   SET markdown = excluded.markdown,
       name = excluded.name,
       system = excluded.system,
       status = 'published',
       updated_at = datetime('now');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, created_by, length(markdown) AS markdown_bytes
  FROM imported_classes WHERE class_id = 'mind-melter';
SELECT count(*) AS stub_gear_rows FROM gear
 WHERE slug IN ('sleeping-bag', 'utility-ammo-belt', 'sunglasses-or-tinted-goggles', 'air-filter-or-gas-mask', 'knife', 'food-rations', 'hover-vehicle', 'hovercycle', 'robot-horse', 'jet-pack', 'motorcycle', 'car', 'techno-wizard-vehicle', 'rifle');
