-- The Berserker, an optional player character from Rifts Conversion Book Two:
-- Pantheons of the Megaverse, printed p.168-169.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-berserker-class.sql
--
-- Read straight from the PDF with scripts/read-columns.py. This book has a text
-- layer, so nothing was OCR'd or inferred from a page image, and its
-- printed-to-PDF offset is zero. Validated with scripts/class-check.mjs
-- --remote against the PRODUCTION catalog before this file was generated:
-- 0 errors, 0 warnings.
--
-- IMPORTED AS AN O.C.C., AND THE BOOK DISAGREES WITH ITSELF. The contents page
-- calls it "Berserkers (optional R.C.C.)". The entry prints ATTRIBUTE
-- REQUIREMENTS (P.S. 16, P.E. 16), no rolled attributes, no racial M.D.C. and a
-- borrowed O.C.C. skill list - every one of those is an occupation's shape. It
-- also says only humans and perhaps dwarves can BECOME berserkers, which is a
-- thing you do rather than a thing you are born as. The page wins.
--
-- THE SKILL LIST IS THE LOSSY PART. "Can select skills only as per the vagabond
-- or wilderness scout O.C.C.s" cannot be said in this format - `variants`
-- explicitly cannot override the skills block. Stored as the UNION of the two
-- classes' categories at the vagabond's count of five, with the instruction in a
-- note. The union is the permissive direction on purpose: it never blocks a skill
-- either list allows, and a class that silently REFUSES a legal skill is
-- invisible to the player where an extra offer sits next to the note explaining
-- it.
--
-- None of the ten rage effects is in `bonuses:`. Every one is conditional on
-- being in the rage, and `bonuses:` is applied unconditionally - a berserker
-- walking around with +1 attack and 2D4x10 M.D.C. permanently would be a
-- different and far stronger class. Four of the ten are COSTS and say so first.
--
-- Pure ASCII with LF line endings, comments included, per PR #93 and #101. The
-- one em-dash that must survive is the gear stub marker, which
-- import-engine.js matches on, built with char(8212) rather than embedded.
--
-- Idempotent: catalog rows are INSERT OR IGNORE and the class INSERT is guarded
-- by WHERE NOT EXISTS, so re-running writes nothing.

-- The class itself, published so it appears in the creation wizard.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'berserker', 'Berserker', 'rifts', '---
id: berserker
name: Berserker
system: rifts
source_book: pantheons-of-the-megaverse
category: occ
occ_group: men-of-arms
attribute_requirements: { PS: 16, PE: 16 }
skills:
  occ_related_skills:
    count: 5
    categories:
      - "Communications"
      - "Domestic"
      - "Electrical"
      - "Espionage"
      - "Horsemanship"
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
    note: "The book grants no skill list of its own: ''Can select skills only as per the vagabond or wilderness scout O.C.C.s''. Pick ONE of those two classes and follow its list - this is the union of what they allow, so it does not block anything either of them permits."
special_abilities:
  - name: "The Rage"
    description: "In combat the berserker can try to work himself into a fury - jumping up and down, beating himself with the blunt side of his weapons, gnawing at a shield''s rim. Chance of success 10% plus 5% per level of experience, +10% if injured or angered, +20% if fighting to avenge an injustice or just plain frustrated, +30% if avenging a fallen hero or comrade or a horrible injustice, +40% if avenging the death of innocent people or the reputation of Odin and Asgard. The rage lasts one minute per level of experience and can be summoned once per day per level. EVERY power below comes from it, and every one of them ends when it does."
  - name: "Mega-Damage Body"
    description: "While raging the berserker is a supernatural being with 2D4x10 M.D.C. plus 20 M.D.C. per level of experience. In a non-mega-damage world, 2D6x10 S.D.C. plus 20 S.D.C. per level."
  - name: "Increased Strength"
    description: "Add 6 to P.S. while raging, and it becomes supernatural strength."
  - name: "Rage Regeneration"
    description: "While berserk the character recovers 1D6 M.D.C. every other melee round."
  - name: "Rage Combat Bonuses"
    description: "During the rage: +3 to save vs horror factor, +1 on initiative, +1 to strike, and one additional attack per melee. A further +1 to strike, parry and dodge at levels 6 and 12."
  - name: "Rage Resistance to Magic and Psionics"
    description: "While berserk: +10 to save vs all types of mind control and illusions, +3 to save vs magic, +5 to save vs psionic attack, and immune to possession."
  - name: "Reduced Mental Faculties"
    description: "A COST, not a benefit. The character''s I.Q. is halved during the rage. He cannot cast magic spells or use psionic abilities while in this state, and all skills are performed at -60%."
  - name: "Suicidal Bravery"
    description: "A COST. The character will not surrender or stop fighting while raging. Realising the battle is hopeless, he must force himself out of the rage: base 10% +5% per level of experience. A berserker fighting against hopeless odds is a common danger."
  - name: "A Danger to His Friends"
    description: "A COST. A berserker who has killed or incapacitated every obvious enemy must try to snap out of the rage, as above, or he attacks any living being near him - friends, allies, innocent bystanders, even livestock. With nobody around he strikes at trees and inanimate objects until the rage is spent."
  - name: "Exhaustion"
    description: "A COST. When the rage ends the character is tired and confused: -2 on all combat bonuses, -2 attacks per melee, speed halved, and every bonus of the rage including the M.D.C. transformation is lost. He needs an hour''s rest to recover his normal strength, and may burst into another rage before then depending on the circumstances."
restrictions:
  - "Alignment: any, but tends towards anarchist or evil."
  - "Only humans, and perhaps dwarves, can become berserkers, and the character must have worshipped Odin for a long time. There are a few dimensions whose denizens still worship the Nordic gods."
  - "Horror Factor: 13 while in the berserk state."
  - "SKILLS ARE BORROWED. The book gives the berserker no list of his own - he selects skills only as per the vagabond or wilderness scout O.C.C. Pick one of those two and follow it."
  - "Odin grants this gift to warriors of great promise, and it is also a curse: the rage stays with the character for the rest of his life unless he can somehow convince Odin himself to remove it."
  - "Standard equipment: normal for the character''s world setting. Money: none to start. Cybernetics and bionics: usually none."
  - "A player choosing this class must accept that the character will never lead a normal life. The fury can break out at any time and makes him a danger to his companions and to himself."
side_effects: "Berserkers are fighters who have devoted themselves to Odin, and are feared by ordinary people for their extreme, Viking-like views of justice and their uncontrolled rage. They end up living away from society, wandering the wilderness alone or with others of their kind - some become deadly mercenaries, others find a cause to fight for. Whatever they do they are rarely accepted, because they are a constant danger to everyone around them. Berserkers make tragic characters, or powerful villains."
extraction_notes: |
  Read from Pantheons of the Megaverse printed p.168-169 with
  scripts/read-columns.py. Text layer, offset zero.

  IMPORTED AS AN O.C.C., NOT AN R.C.C., and the book disagrees with itself on
  that point. The contents page calls it "Berserkers (optional R.C.C.)"; the
  entry prints ATTRIBUTE REQUIREMENTS (P.S. 16, P.E. 16), no rolled attributes,
  no racial M.D.C., and a borrowed O.C.C. skill list. Every one of those is an
  occupation''s shape and none of them is a race''s. It also says outright that
  only humans and perhaps dwarves can BECOME berserkers, which is a thing you
  do rather than a thing you are born as. The page wins over the contents page.

  1. THE SKILL LIST IS THE LOSSY PART, and it is the only one. "Can select
     skills only as per the vagabond or wilderness scout O.C.C.s" cannot be
     said in this format: `variants` explicitly cannot override the skills
     block (see VARIANT_OVERRIDES in js/parser.js, which says so in a comment),
     and no key references another class''s skills. What is stored is the UNION
     of the two classes'' related-skill categories, at the vagabond''s count of
     five, with the instruction in a note.

     The union is deliberately the permissive direction. It never blocks
     something either book list allows; it can allow something one of them
     alone would not. Chosen that way round because a class that silently
     REFUSES a legal skill is invisible to the player, where a class that
     offers one too many is caught by the note sitting next to it.
  2. NO SECONDARY SKILLS, because the Vagabond this borrows from has none
     either - checked, not assumed.
  3. NO S.D.C. AND NO HIT POINTS, so the core rule applies through
     CORE_SDC_BY_CLASS in js/compose.js. Filed at 3D6, the man-of-arms value:
     the book''s first sentence is "The berserkers are FIGHTERS who have devoted
     themselves to Odin", and the class carries P.S. and P.E. minimums, which
     is a man-of-arms signature. The counter-argument is real and worth
     recording - its skills come from the vagabond and the wilderness scout,
     which are both 1D6 - but a borrowed skill list is not what that table
     keys on.
  4. `occ_group: men-of-arms`, for the same reason, so a race restricting by
     group treats him as what the book calls him.
  5. THE TEN RAGE EFFECTS ARE ALL GRANTED, not chosen. They are not a menu -
     the book lists what happens when the rage takes hold, and four of the ten
     are COSTS: halved I.Q. and skills at -60%, suicidal bravery, the danger to
     his own friends, and the exhaustion afterwards. They are stored as
     abilities rather than prose so the sheet shows them beside the benefits,
     and each cost says so in its first words.
  6. NONE OF THE RAGE BONUSES ARE IN `bonuses:`. Every one of them is
     conditional on being in the rage, and `bonuses:` is applied
     unconditionally - a berserker walking around with +1 attack and 2D4x10
     M.D.C. all the time would be a different and much stronger class.
---

## Lore

The berserkers are fighters who have devoted themselves to Odin. As a reward -
some would say a curse - Odin grants them incredible powers when they enter a
state of just or righteous rage: righting an injustice, defending the name and
reputation of Odin or Asgard, avenging the wronged or the slain innocent by
beating up or killing those responsible.

Ordinary people fear them, because of their extreme Viking-like views of justice
and their uncontrolled rage. So berserkers end up living away from society,
wandering the wilderness alone or with others of their kind. Some become deadly
mercenaries. Others find a cause to support and fight for. Whatever they do,
they are rarely accepted, because they are a constant danger to everyone around
them.

Only humans, and perhaps dwarves, can become berserkers, and the character must
have worshipped Odin for a long time - there are a few dimensions whose denizens
still do. Odin grants the gift to warriors of great promise. It is also a curse:
the rage stays for the rest of the character''s life, unless he can somehow
convince Odin himself to remove it.

## GM Notes

Read the four costs before the six benefits, because the costs are what the
class is for. A raging berserker has half his I.Q., performs every skill at
-60%, cannot cast or use psionics, will not surrender, and - once every obvious
enemy is down - must roll to avoid attacking his own party. The roll is 10% plus
5% per level, which means a first-level berserker fails it nineteen times in
twenty.

That is the design. The book says so plainly: players choosing this class must
realise they will never lead a normal life, and that they are a danger to their
fellow adventurers and to themselves. It suggests berserkers make tragic
characters or powerful villains, and both readings are supported.

A G.M. running one in a party should decide up front what happens the first time
the rage turns inward, because it will.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'berserker');

-- Read the result back rather than trusting the exit code. A CR in the stored
-- markdown means the checkout mangled the file.
SELECT class_id, name, status, length(markdown) AS bytes,
       instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'berserker';

-- Records this run. One row per run rather than per file: every statement above
-- guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-berserker-class.sql');
