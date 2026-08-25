-- Juicer Wannabe, one of the five Juicer-Related O.C.C.s Rifts World
-- Book Ten: Juicer Uprising defines, printed p.59-61.
--
-- One-off data script, run once per environment. NOT a migration - it adds a
-- row, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-juicer-wannabe-class.sql
--
-- The book has a TEXT LAYER, so this was read with scripts/read-columns.py and
-- transcribed rather than OCR'd. The printed-to-PDF offset is ZERO, verified
-- against three folios. Validated with scripts/class-check.mjs --remote against
-- the PRODUCTION catalog before this file was generated: 0 errors, 0 warnings.
--
-- NOT A JUICER either - a thirteen-to-twenty-year-old who wants to be one. The only O.C.C. in Rifts that can BECOME a Juicer without freezing its skills, and drug addiction is what closes that door at -20% per habit.
--
-- THIRD AND LAST BATCH. See add-hyperion-juicer-class.sql for why this book's
-- fifteen classes are fifteen rows rather than one with `variants`.
--
-- THIS SECTION HAS A SHAPE OF ITS OWN. The book introduces it by saying Juicers
-- can pursue other areas of training "but always as a Man of Arms", that each
-- entry "requires the character to be a Juicer", and that "all Juicer bonuses
-- and penalties remain the same, only the training/skill programs and some
-- bonuses vary". So the Gladiator, the Assassin and the Scout print SKILLS AND
-- NOTHING ELSE - no attribute dice, no pools, no saving throws.
--
-- The app models ONE OCCUPATION PER CHARACTER and cannot compose a Juicer with
-- a training programme laid over it. Rather than ship three classes that
-- produce an incomplete sheet, each carries the STANDARD Juicer's numbers,
-- which is the default the book itself names two sentences later: "Use the
-- experience table for the 'standard' Juicer O.C.C. unless one of the new
-- Juicer variants." A Gladiator who is a Hyperion substitutes the Hyperion's
-- numbers and keeps the skill programme, and every one of the three says so in
-- its special_abilities and its extraction_notes.
--
-- AND TWO OF THE FIVE ARE NOT JUICERS AT ALL. The book is explicit: "The
-- Gambler and Juicer Wannabe are not Juicers, but characters who are often
-- associated with them." Those two get no Juicer bonuses, no pools of their
-- own, occ_group `optional` rather than men-of-arms, and a CORE_SDC_BY_CLASS
-- entry at 1D6 - because a class stating neither an sdc_base nor an mdc_base
-- needs one, and neither of them is a man of arms.
--
-- Pure ASCII with LF line endings, comments included, per PR #93 and #101.
-- Idempotent: the class INSERT is guarded by WHERE NOT EXISTS.

-- The class itself, published so it appears in the creation wizard.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'juicer-wannabe', 'Juicer Wannabe', 'rifts', '---
id: juicer-wannabe
name: Juicer Wannabe
system: rifts
source_book: Rifts World Book 10: Juicer Uprising p.59-61
category: occ
occ_group: optional
attribute_requirements: { PS: 10, PP: 10, PE: 10 }
starting_money: "2d6x100"
skills:
  occ_skills:
    - { name: "Body Building & Weight Lifting", base: 0, per_level: 0, note: "Printed as Body Building." }
    - { name: "Boxing", base: 0, per_level: 0 }
    - { choose: 2, from: ["Language: Other"], bonus: 10, note: "Two languages of choice (+10%). Taken once per language - the picker asks which." }
    - { name: "Streetwise", base: 30, per_level: 4, note: "+10%" }
    - { name: "Lore: Juicers", base: 40, per_level: 5, note: "Printed as Juicer Lore (+10%)." }
    - { name: "Athletics (general)", base: 0, per_level: 0, note: "Printed as General Athletics." }
    - { name: "Running", base: 0, per_level: 0 }
    - { name: "W.P. Knife", base: 0, per_level: 0 }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P.: one of choice." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "May be changed to Hand to Hand: Martial Arts (or Assassin, if an evil alignment) at the cost of one O.C.C. Related Skill." }
  occ_related_skills:
    count: 8
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
    categories:
      - { name: "Communications", bonus: 5 }
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Mechanical", only: ["Automotive Mechanics"] }
      - { name: "Medical", only: ["First Aid"] }
      - "Physical"
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Air Assault Armor", "Combat Pod", "Military: Tanks & APCs", "Military: Jet Fighters", "Military: Combat Helicopter", "Military: Submersibles", "Military: Warships & Patrol Boats"], bonus: 5 }
      - "Pilot Related"
      - { name: "Rogue", bonus: 6 }
      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced"] }
      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
    note: "Of the eight, AT LEAST TWO must come from Rogue and TWO from Physical - a condition the picker cannot enforce, so it is stated here. Espionage, Military and Wilderness are all None for a Wannabe and are therefore absent rather than restricted; the Wannabe is a city kid. Pilot is any except robots and military vehicles, spelled out as the catalog rows it excludes because an unmatched except excludes nothing and does so silently."
  secondary_skills:
    count: 4
special_abilities:
  - name: "Enhancing Drugs"
    description: "Every Wannabe has access to designer drugs. Where appropriate the character starts with 1D4 doses of any THREE of the designer drugs described in this book - Mega, Rush and the rest. A player who does not want their character using drugs takes 2D6x100 credits instead. Most Wannabes tell themselves they only use when they need to, before a fight or something equally dangerous. A large majority use regularly, and at least 30% become addicted - and, the book notes, ironically never become Juicers as a result. About 50% avoid addiction; the statistics vary sharply from gang to gang."
  - name: "Becoming a Juicer Without Losing Anything"
    description: "THE ONLY O.C.C. THAT CAN BECOME A JUICER WITHOUT FREEZING ITS SKILLS. A 4th level Wannabe who saves enough for the conversion becomes a 4th LEVEL JUICER, and switches to the Juicer experience table from then on - slower progression, but often a much higher starting level. He gets NONE of the Juicer O.C.C.''s skills or skill bonuses; he keeps the Wannabe''s skills and improves them normally. New skills gained at later levels may be chosen from EITHER O.C.C.''s list, using whichever bonuses and selections are more favourable. The book''s own example: Joey Blood plays a Wannabe to fifth level, pays for the conversion, keeps every skill and gains none, takes all the physical bonuses of the Juicer conversion, and starts as a 5th level Juicer. At sixth level he may now take Escape Artist, which he could never have taken as a Wannabe, and it comes with the Juicer''s +5%."
side_effects: "Addiction is the trap. At least 30% of Wannabes get hooked on designer drugs, and an addict''s Juicer conversion becomes lethally unreliable: REDUCE THE CHANCE OF SUCCESS BY 20% PER DRUG ADDICTION. Two addictions is -40%, which takes the best body-chop-shops in the world from 98% down to 58%, and it goes downhill from there - the failures being brain damage, epileptic seizure, shock, stroke and heart attack. Most reputable facilities will not take an obvious addict at all, whatever the money or the threats. Roughly 35% of Wannabes eventually become Juicers by hook or by crook. About 35% die violently before their 21st birthday."
restrictions: ["NOT A JUICER. The Gambler and the Juicer Wannabe are the two classes in this section who are not Juicers at all. This class gets NO Juicer bonuses, no super endurance and no drug harness - only the designer drugs it can buy.", "The book notes this character is best suited as an NPC or villain/criminal rather than a player character.", "Most Wannabes are anarchist or miscreant, though any alignment is allowed.", "Age 13-20. Wannabes are children and teenagers.", "At least two of the eight O.C.C. Related Skills must come from Rogue and two from Physical."]
extraction_notes: "NO JUICER BONUSES, deliberately - the book says outright that the Gambler and Juicer Wannabe are not Juicers. It states no hit point or S.D.C. formula either, so it needs a CORE_SDC_BY_CLASS entry, at 1D6: he trains hard but the book files him with the Gambler rather than among the men of arms, and occ_group is `optional` for the same reason. starting_money is the 2D6x100 credits a character takes INSTEAD of the three designer drugs, which is the only coin figure the entry prints. The mid-campaign conversion to a full Juicer is the most interesting rule in the class and nothing in the app can perform it - a character has one occupation - so it is written out in full in the special ability for a GM to apply by hand. The two-from-Rogue and two-from-Physical condition on related skills cannot be expressed in the picker either."
---

## Lore

> "You ready, fresh meat?"
>
> "Ye..." I start to say when I get hit from behind. Hard. They work me over,
> boots and fists mostly, but along the way somebody decided a two-by-four is
> better. After a while, I stop feeling anything.
>
> Cold water splashes my face. "Wake up, fresh meat. You took your medicine like
> a man. I guess you''re in."
>
> I smile bloodily. I''m in the gang. Any day now, I''ll be a Juicer, and nobody
> will ever mess with me again.

Wannabe Juicers are young men and women, thirteen to twenty, who idolise the
Juicer life. Many want to be one someday; the rest just want to be as tough and
as feared. Wannabe gangs are a problem in several Coalition cities and in
Ishpeming, Los Alamo and Kingsdale. Some are hardened criminals running drugs,
cyber-snatching and protection rackets. Others formed to defend their
neighbourhood from other gangs.

What separates a Wannabe from an ordinary city rat is the designer drugs. At
least 80% use one or more, at minimum before a fight. Many also copy the
daredevil attitude: daring each other into picking fights with Dog Boy patrols,
jumping between rooftops, playing chicken with traffic. And a good number train
seriously - exercise, martial arts, weapons - because they have worked out that
relying on drugs alone is stupid and counter-productive. The rumour that heavy
users may be refused the Juicer enhancement, or suffer worse side effects, or
live shorter lives, is entirely true.

Some Wannabes leave the slums and become adventurers, rogues and travellers. A
few grow out of it and give up the drugs altogether. About 35% get their wish and
become Juicers by hook or by crook, and their knowledge of the life makes the
transition easy. About 35% die violently before they turn twenty-one.

## GM Notes

**The book says NPC, and this one is worth taking as advice rather than a rule.**
A Wannabe is a thirteen-to-twenty-year-old with a knife and a drug habit. As a
villain he is a gang; as a player character he is a campaign about getting out.

**The conversion rule is the best thing in the class.** No other O.C.C. in Rifts
can become a Juicer without freezing what it was. A fifth-level Wannabe who saves
the money becomes a fifth-level Juicer, keeps every skill, and starts drawing from
both skill lists at whichever bonus is better. That is a genuine character arc
with a price tag on it, and the price is exactly what the party has been
adventuring for.

**Addiction is what closes the door.** -20% per addiction on the conversion,
against a best-case 98%. Two habits and the best surgeon on the continent is a
coin flip, with a stroke on the losing side. And most reputable shops will not
take an obvious addict at any price - which means the ones who will are not
reputable.

**Three named gangs to hang a city on.** The Deadheads are thrill-seekers who
rarely rob anyone and send 2D6 members a year to "the finals". The Juicer
Disciples deal drugs, snatch bodies and kill for hire, and very few of them live
long enough to be converted. The Vigilantes defend Kingsdale, half of them never
touch drugs, and the authorities tolerate them because they help.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'juicer-wannabe');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes,
       instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'juicer-wannabe';

-- Records this run. One row per run rather than per file: every statement above
-- guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-juicer-wannabe-class.sql');
