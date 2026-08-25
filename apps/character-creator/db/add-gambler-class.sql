-- Gambler, one of the five Juicer-Related O.C.C.s Rifts World
-- Book Ten: Juicer Uprising defines, printed p.58-59.
--
-- One-off data script, run once per environment. NOT a migration - it adds a
-- row, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-gambler-class.sql
--
-- The book has a TEXT LAYER, so this was read with scripts/read-columns.py and
-- transcribed rather than OCR'd. The printed-to-PDF offset is ZERO, verified
-- against three folios. Validated with scripts/class-check.mjs --remote against
-- the PRODUCTION catalog before this file was generated: 0 errors, 0 warnings.
--
-- NOT A JUICER. Ten related skills, the largest allowance in the book, plus one street contact per three points of M.A.
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
SELECT 'gambler', 'Gambler', 'rifts', '---
id: gambler
name: Gambler
system: rifts
source_book: Rifts World Book 10: Juicer Uprising p.58-59
category: occ
occ_group: optional
attribute_requirements: { IQ: 10, MA: 10 }
starting_money: "2d6x100"
skills:
  occ_skills:
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "Printed as Basic Math (+20%)." }
    - { name: "Gambling (Standard)", base: 50, per_level: 5, note: "+20%" }
    - { name: "Gambling (Dirty Tricks)", base: 40, per_level: 4, note: "Printed as Gambling: Dirty Tricks (+20%)." }
    - { name: "Palming", base: 30, per_level: 5, note: "+10%" }
    - { choose: 2, from: ["Language: Other"], bonus: 15, note: "Two languages of choice (+15%). Taken once per language - the picker asks which." }
    - { name: "Literacy: Native Language", base: 50, per_level: 5, note: "Printed as Literacy (+10%)." }
    - { name: "Streetwise", base: 34, per_level: 4, note: "+14%" }
    - { name: "Motorcycles & Snowmobiles", base: 70, per_level: 4, note: "Printed as Pilot: Motorcycle (+10%)." }
    - { name: "W.P. Knife", base: 0, per_level: 0 }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P.: one of choice." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "May be changed to Expert at the cost of one O.C.C. Related Skill, or to Martial Arts (or Assassin, if any evil alignment) at the cost of TWO." }
  occ_related_skills:
    count: 10
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 2 }, { level: 8, count: 1 }, { level: 10, count: 1 }, { level: 12, count: 1 }, { level: 14, count: 1 }]
    categories:
      - { name: "Communications", bonus: 5 }
      - { name: "Domestic", bonus: 5 }
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Mechanical", only: ["Automotive Mechanics"] }
      - { name: "Medical", only: ["First Aid"] }
      - "Physical"
      - { name: "Pilot", bonus: 5 }
      - "Pilot Related"
      - { name: "Rogue", bonus: 4 }
      - "Science"
      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
    note: "TEN related skills, the largest allowance of any class in this book, and the book requires that AT LEAST TWO of them come from the Rogue category - a condition the picker cannot enforce, so it is stated here. Espionage, Military and Wilderness are all None for a Gambler and are therefore absent rather than restricted; Science is open with no narrowing, which is unusual."
  secondary_skills:
    count: 6
special_abilities:
  - name: "Fast-Talk"
    description: "Gamblers are good at inventing on the spot, from a tall tale that impresses a new acquaintance to an excuse that gets him out of a corner. The book asks players to role-play this to the hilt: the better and more convincing the performance, the more likely it is to be believed, with M.A. and P.B. taken into account. Blatant lies and stories with obvious holes fool nobody, however charming the teller."
  - name: "Street Contacts"
    description: "A network of other gamblers, sports figures, city rats, street urchins, small-time criminals, prostitutes, beggars and even local police. At creation, and with the G.M.''s approval, the character has ONE CONTACT PER THREE POINTS OF M.A., rounded down - M.A. 10 gives three, M.A. 16 gives five. The player says who they are and how friendly. Genuinely powerful contacts - a crime boss, a police chief, a mayor - should count as two or more. Reaching one is a roll at 35% plus 5% per level plus I.Q. bonus; success means the meeting happens, and whether the contact knows anything is the G.M.''s call. Rumour and gossip about known street figures should be easy; dark secrets should not. A contact may also approach the character unprompted to warn him about something."
  - name: "Establishing a Network"
    description: "A Gambler who stays in any city more than six months establishes contacts there - useful for information, warnings and even help."
side_effects: "Hampered by their own fascination with games of chance and with taking risks. The book files Gamblers as a more experienced and sophisticated sub-set of the City Rat and Vagabond, held back by exactly that."
restrictions: ["NOT A JUICER. The Gambler and the Juicer Wannabe are the two classes in this section who are not Juicers at all - they are people who hang around Juicers. This class gets NO Juicer bonuses, no super endurance, no drug harness and no shortened life span.", "At least two of the ten O.C.C. Related Skills must come from the Rogue category.", "Tends to shirk hard labour and common work, preferring the more glamorous and shady kind."]
extraction_notes: "NO JUICER BONUSES, deliberately - this is the point of the class and the book says so outright: \"The Gambler and Juicer Wannabe are not Juicers.\" It therefore states no hit point or S.D.C. formula of its own either, so it needs a CORE_SDC_BY_CLASS entry, at 1D6 because a gambler is not a man of arms. occ_group is `optional` for the same reason. starting_money is 2D6x100, taken from the Standard Equipment paragraph rather than a Money Bonus line, which this class does not have. The two-from-Rogue condition on related skills cannot be expressed in the picker and is stated in the note and the restrictions."
---

## Lore

The Gambler is in this book because gamblers are always around Juicers - working
the sports, hanging about the meal-tickets and the heroes.

The larger city-states of North America have grown enough to have their own
criminal and semi-criminal classes, and that includes professionals who spend
their lives risking everything on a throw of the dice or the outcome of a game.
On Rifts Earth they are a sub-set of the City Rat and the Vagabond - a bit more
experienced, a bit more sophisticated, and hampered by their own fascination with
chance.

Most are adventurers and opportunists who live in the shadowy underworld of
large cities. You will find them in the ''Burbs running a shell game, or in
Downside at a poker table where hundreds of thousands of credits turn on one
hand. Between games they will take almost any odd job, though they shirk hard
labour and common work in favour of something more glamorous and shady. Some are
accomplished thieves and con-men. Those working in Coalition cities rarely love
the government, and spend a good deal of time finding ways to cheat and steal
from the CS and their Dead Boy lackeys.

All that time in the underworld makes them extremely knowledgeable about local
crime figures and the authorities who chase them - and they know a great many
games of chance, and a great many ways to cheat at them. Whether they cheat or
not, they will spot anyone who tries. An angry gambler is a dangerous enemy,
especially with a hold-out weapon somewhere on him.

Sometimes a gambler and a Juicer become partners, the gambler acting as manager
and troubleshooter for a Gladiator or a sports figure - making the smart bets,
offering suckers'' odds on "his man", collecting the winnings, making sure the
debts get paid on time and that nobody dares try to cheat. He may also set up the
betting on a street fight, or promote an illegal competition outright.

## GM Notes

**Ten related skills.** The largest allowance in the book, and the schedule runs
to level fourteen. This is a character who knows a little about almost
everything, and the two-from-Rogue requirement is the only string attached.

**Street Contacts is the reason to have one in the party.** One contact per three
points of M.A., named by the player, reachable at 35% plus 5% per level. A
well-developed contact is a recurring NPC and a plot engine, and the book says as
much to the G.M. directly.

**He is fragile and he knows it.** No Juicer bonuses at all, Hand to Hand: Basic,
and a knife. A Gambler in a firefight is a liability; a Gambler in a room full of
people who owe money is the most dangerous person there.

**Best in a city game**, but the book is careful to say he should be able to look
after himself once he leaves one.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'gambler');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes,
       instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'gambler';

-- Records this run. One row per run rather than per file: every statement above
-- guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-gambler-class.sql');
