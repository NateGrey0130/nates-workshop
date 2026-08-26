# Race and occupation

The R.C.C.-first wizard, how a race and an occupation compose, and the MOS packages
that sit on top of an O.C.C.

Part of the [character creator](../README.md) documentation.

---

## The race is chosen first

The wizard's order follows how a character is actually made: you are a dragon,
you roll to find out what kind of dragon, and then you decide what the dragon
studied.

```
System → Race → Attributes → Occupation → Skills → Equipment → Powers → (Advancement) → Details → Review
```

Advancement appears only when the starting level is above 1 — see
[Starting above level 1](starting-above-level-1.md#starting-above-level-1); at level 1 the stepper
walks past it.

The **Race** step is a briefing rather than a row in a list. Before committing,
the player reads what the R.C.C. grants: the attribute dice it will roll per
attribute, the pool formulas as formulas, the bonuses, the psionic tier (or
`psionics_allowed: false`, which is a statement and looks like an absence), the
skills it already knows, and whether an occupation is normally taken alongside
it. All of that used to be first visible a step later, after the choice had been
made and the dice were already rolling.

**The bonuses line names all four groups**, `pools` included. It listed
attributes, combat and saves only, and a **pool bonus does not appear in the
`Pools` line either** — that line prints the pool's own FORMULA, and a class
that adds to another's roll rather than replacing it states no formula at all.
So the Troll's +40 S.D.C., the single most distinctive number on its page, was
shown nowhere on the step that exists to show it. Fifteen of the sixty-one
classes published before the races grant a pool bonus, so this was never only a
race problem. A smoke check now fails if the briefing stops reading one of the
four groups.

**The list still holds every class for the system.** An O.C.C. taken as the
primary class is a human character and always was. When that happens the
Occupation step does not apply and is greyed in the stepper rather than removed,
so the numbering stays the same between two characters side by side.

`stepApplies(i)` decides, and `seekStep` walks past a step that does not apply
from either direction. A predicate rather than a hard-coded skip, because
`render()` also consults it — a resumed draft, or an ability dropped after the
fact, can otherwise land on a step that stopped making sense.

### A roll can now miss a minimum

Attribute minimums come from **both** classes, the stricter of each. Rolling
before the occupation is chosen therefore admits a state the old order could not
reach: a stat block that fails the O.C.C. the player then wants.

The Occupation step names the attribute and the number missed by, and offers to
**re-roll that attribute alone**, with the race's dice for it. Whatever it comes
up as, it stands — including a second failure, which may be re-rolled again only
if the player chooses to.

Three alternatives were rejected on purpose:

- **Re-rolling the whole stat block** throws away good rolls to fix one bad one.
- **Auto-raising to the minimum**, which several books instruct, would leave a
  number on the sheet that no dice produced. The app's posture is that every
  number came from somewhere.
- **Offering a choice between re-rolling and raising** is two mechanisms where
  one will do.

**It is never a refusal.** A player may decline and continue with the minimum
unmet; `validate-character.js` warns on save and the admin audit lists it under
*worth a look*, which is the existing doctrine for occupations rather than a
stricter rule invented for the same class of problem.

Each re-roll is recorded and posted as a `roll` play event once the character
exists — the events API already defines that kind as a pure record with no state
change. A number that came from a second attempt should not sit on the sheet
looking like what the dice said first.

### Two class fields, not one

`S.rcc` is what the player **picked**: raw, unresolved, still carrying its
variants and choose-groups, which is what the Race step's pickers read. `S.cls`
is what the character **is**: variant applied, occupation composed in, abilities
folded in.

It used to be one field that `confirmClass` overwrote in place. That was fine
while both halves were chosen on the same step and is not any more — adding an
occupation two steps later has to re-compose from the original, and a composed
class has already lost the halves.

`S.raceCls` is the third: the race alone, composed. It exists because **its dice
bonuses were rolled and read on the Attributes step**, and choosing an occupation
afterwards must not re-roll a number the player has already seen. So the two
sets of rolls are held apart — `S.attrBonuses` for the race, `S.occAttrBonuses`
for the occupation — and `rolledAll()` is the only thing that sees them summed.
Changing occupation re-rolls its half and leaves the race's alone.

### A draft stores its step as an index

Which means changing `STEPS` silently re-points every draft in flight. Drafts
carry `steps_version`; version 1 is the eight-step list with one combined Class
step, version 2 split Class into Race and Occupation (nine steps), and
version 3 — the list above — inserted Advancement after Powers.

`migrateDraft()` maps an old index forward, one insertion per version, so the
migrations **chain**: a version-1 draft runs through both. Only the steps
**after** an inserted step move — for 1→2, System (0), Class→Race (1) and
Attributes (2) keep their index and Skills onward shift by one; for 2→3,
everything up to Powers keeps its index and Details and Review shift by one.
A draft stopped on the old Class step resumes on Race, which is right — it had
not committed to an occupation in any way the new step could trust. The resume
*offer* reads the migrated index too, or it would name the wrong step in the
sentence asking you to resume.

The smoke test pins the list, the version and the mapping together, because each
is only correct with respect to the others.

---

## A race and an occupation together

Palladium characters routinely have both. A Chiang-Ku Dragon who studies wizardry
is a dragon **and** a wizard, and the two contribute different halves: the race
sets the body, the occupation sets what was learned. This is also why a racial
class legitimately grants **no** related or secondary skills — those come
entirely from the O.C.C., so an R.C.C.-only character correctly has none.

A character carries `class_id` (+ `class_variant`) for the race and
`occ_class_id` (+ `occ_class_variant`) for the occupation. Both optional halves;
every character created before this has `occ_class_id` NULL and behaves exactly
as it did.

**The pairing is the normal structure, not an extra.** A player picks a race and
then an occupation, and the wizard says so: the picker is labelled *normally
required* for a race that needs one and *optional for this race* otherwise,
rather than a flat "optional" for all. Both exceptions are real and both still
work - an O.C.C. alone is a human character and shows no race picker at all, and
a race that grants its own skills stands on its own.

**Which races need one is inferred, not declared.** `needsOccupation(cls)` is
true for an R.C.C. granting no related and no secondary skills: it offers the
player nothing to *choose*. Fixed skills deliberately do not count - a Chiang-Ku
has twenty-four of them and still nothing chosen, which is exactly the gap an
O.C.C. fills. Measured against the published classes, that marks the Demigod
(nothing at all) and the Chiang-Ku (body skills only), and leaves the Godling
(8 related, 5 secondary) and the Dragon Hatchling (6 related) alone.

Inferred rather than declared because the skill counts already say it and no
stored class needs editing - and it is only safe because **the answer is always
a warning and never a refusal.** A wrong guess costs a dismissible note. The
warning appears in the wizard beside the picker, and `validate-character.js`
raises `no_occupation` so it also reaches the save path and the
[character audit](wizard-and-sheet.md#server-side-rule-enforcement), where it lands under *worth a
look* rather than *would be refused on save*.

`combineClasses(rcc, occ)` composes them into **one class-shaped object**, the
same trick `applyVariant` uses a layer down. Callers do not reach for it
directly: [`js/compose.js`](../js/compose.js) is the single place that knows the
whole order — variant, then race + occupation, then any rolled psionics — and
every site goes through it. See
[One place composes a class](../README.md#one-place-composes-a-class). The validator, the level-up diff,
`derive`'s bonuses and the sheet all read `cls.skills`, `cls.bonuses` and the
pool bases as before — none of them knows a character can have two classes.

| | comes from |
|---|---|
| attribute dice, pool formulas | the **race** |
| attribute minimums | **both** — the stricter of each |
| fixed skills | **both**, a shared skill held once at the higher base |
| related & secondary allowances | the **occupation** |
| bonuses | **both** — flat numbers summed, dice collected (see below) |
| psionics | the **stronger tier** |
| magic | the **occupation** |
| equipment, abilities, level progression | **both** |

Three rules earned by getting them wrong first:

- **A pool the race does not mention falls through to the occupation** — but an
  M.D.C. race keeps no hit points. Silence means "not applicable" for a creature
  that tracks M.D.C. and "no opinion" for one that simply omits the line.
- **A skill both classes grant is held once**, at the higher base. Concatenating
  blindly produced a character holding Wilderness Survival twice, which the
  validator correctly refused to save. Choice-groups are *not* collapsed — they
  have no identity to match on, so "pick 3 Science" from each class is six picks.
- **The audit and the stage-change endpoint compose too.** Judging a Chiang-Ku
  Wizard against the dragon alone reports every skill its occupation grants as a
  violation.
- **A dice bonus cannot be summed, so it is collected.** A race granting
  `+1d4 P.S.` and an occupation granting `+2d6` means both are rolled; there is
  no single expression that says so, so the merged value is `["1d4", "2d6"]` and
  each rolls. Flat numbers still add, and a mixed list keeps both halves.

  This is the shape of a bug that was live: the merge copied the second class's
  values **only when they were numbers**, so every dice bonus arriving from the
  *occupation* was silently dropped. Any R.C.C. composed with the Cyber-Knight
  lost all five of its `+1D4`s, and nothing reported it. The same collect rule
  now applies within one class, where a level-1 dice bonus and an `at_level` one
  for the same attribute used to overwrite each other.

---

### The fourteen Palladium player races

Until this import the catalog held **one** Palladium R.C.C. — the Chiang-Ku
Dragon — and four R.C.C.s in total. Every Palladium occupation that had been
imported was therefore an occupation with nothing underneath it: the wizard
picks a race first, and the only race a Palladium character could be was a
dragon. The fourteen races on printed 288-312 are what the rest of that book
assumes.

| race | printed | racial S.D.C. | psionics | O.C.C.s the page allows |
|---|---|---|---|---|
| Human | 288 | — | standard | any |
| Elf | 290 | +10 | standard | any |
| Dwarf | 292 | +15 | standard | any **except magic** |
| Gnome | 294 | — | **none** | magic, clergy or optional, plus ranger, mercenary, soldier, thief, assassin |
| Troglodyte | 295 | +10 | **none** | mercenary, soldier, thief, assassin, monk, vagabond |
| Kobold | 297 | +5 | standard | any except long bowman, knight, palladin |
| Goblin | 299 | +5 | standard | assassin, thief, mercenary, soldier, black priest, witch, vagabond, occasional psychic |
| Hob-Goblin | 300 | — | **none** | assassin, thief, mercenary, soldier, black priest, witch, vagabond |
| Orc | 302 | +10 | **none** | mercenary, soldier, assassin, thief, black priest, witch, vagabond |
| Ogre | 304 | +20 | **none** | any |
| Troll | 306 | +40 | **none** | any except psychic P.C.C.s and illusionist |
| Changeling | 308 | — | standard | any |
| Wolfen | 310 | +20 | standard | any |
| Coyle | 312 | +10 | standard | any |

**A race's S.D.C. is a pool BONUS, not `sdc_base`.** This is the one decision
the whole batch turns on. Ten of the fourteen pages state a number, and every
one of them states it the same way — *"10 plus those gained from O.C.C.s and
physical skills"* — and printed 18 says so outright: *"Some non-human races and
O.C.C.s also get special S.D.C. bonuses. All S.D.C. points/bonuses are
cumulative."*

Written as `sdc_base` it would have been silently wrong, because
`combineClasses` gives the **race's** pool precedence over the occupation's: a
Troll Knight would carry 40 S.D.C. instead of 40 + 3D6. Written as
`bonuses.pools.sdc` it is summed across both halves by `sumBonusGroups`, exactly
as the Stone Master's flat P.P.E. term is. The same reading covers the four
races whose page says *"only those gained from O.C.C.s and physical skills"* —
they state no bonus at all, and the occupation's roll stands alone.

Because no race states `sdc_base`, all fourteen need an entry in
`CORE_SDC_BY_CLASS`, and all fourteen are `1D6`. **A race is never a man of
arms** — the job decides that, and `withCorePools` looks the occupation up
first — so those entries fire only for a race played with no occupation at all,
where printed 18's third bucket, *"practitioners of magic, scholars and all
others"*, is the one that applies.

**Every one of the fourteen needs an occupation, and `needsOccupation()` says so
without being told.** It is true for an R.C.C. granting no related and no
secondary skills, and a Palladium race grants neither — those come from the
O.C.C. That was already the rule; the races are the first classes where it is
the normal case rather than the exception.

**Hit points are transcribed rather than defaulted.** Every race page prints
*"P.E. +1D6 per level of experience"*, which is identical to the core rule
`compose.js` would have supplied. It is written into the class anyway, because
the page states it and the class file records what the page says.

**Six races state `psionics_allowed: false`** — gnome, troglodyte, hob-goblin,
orc, ogre and troll — which is the first use of that key by any published class.
It skips the Random Psionics Table entirely. The hob-goblin is the case worth
reading twice: it can never *have* psychic powers **and** is +1 to save against
them, which is not a contradiction and is the clearest demonstration that the
two are different fields.

#### What a race states that the app cannot yet hold

Three things, all recorded as prose and all listed in the affected classes'
`extraction_notes`:

- **A race-level per-skill percentage bonus.** *"Add a bonus of +5% to the
  following skills (this is in addition to O.C.C. bonuses): general repair,
  masonry, carpentry, …"* modifies skills the **occupation** grants. `occ_skills`
  *grants* a skill; `skill_overrides` only restates one the class already grants;
  `skills.bonuses` is a catalog-row property shared by every class. None of the
  three expresses "+5% to it if you have it". Four races are affected — dwarf
  (eleven skills plus any Military skill), gnome (nine), kobold (three) and
  changeling (Disguise). **The ogre's is different and IS modelled**: its page
  *grants* Recognize Weapon Quality, Falconry and Animal Husbandry outright, so
  those are `occ_skills` at the catalog base plus the printed bonus.
- **A horror factor the creature projects.** Six races have one — ogre 10,
  changeling 10, Coyle 11, troll 12, Wolfen 12, troglodyte 13 when enraged.
  `saves.horror_factor` is the bonus for *resisting* one; there is no field for
  *having* one. Recorded in `natural_abilities`.
- **Racial percentile abilities.** Underground Tunneling, Underground
  Architecture, Underground Sense of Direction, Track Blood Scent and Recognize
  Scent of Others all behave exactly like skills — a base percentage rising per
  level — but they belong to no catalog category and are granted rather than
  chosen, so filing them as catalog skills would make them pickable by anyone as
  a secondary skill. They are `natural_abilities` with their numbers stated,
  which is the Chiang-Ku's precedent.

Two saves the races needed did **not** stay prose. `faerie_magic` and `disease`
became real keys, because a bonus written for a key `derive.js` does not expose
reaches nothing at all — see
[House rules and derived values](house-rules.md#house-rules-and-derived-values).

#### Deliberately not imported

**The Goblin Cobbler** (printed 302), an "Optional R.C.C." — a goblin is one on
a percentile roll of 1-15. It has metamorphosis at will, six faerie spells cast
twice per 24 hours at third-level strength, +1 to save vs all magic, +1 vs
possession, +3 vs horror factor, and +10% to three crafts. It is **not** a
`variants` entry: `VARIANT_OVERRIDES` admits `attribute_dice`,
`attribute_requirements`, the pool bases, `bonuses` and `skill_overrides`, and
the Cobbler's whole substance is a `magic` block and an abilities block. It
needs either a widened variant or a second class, and that is a decision rather
than a transcription. Recorded in the goblin's `extraction_notes` and GM notes.

**Demons, deevils and the other creatures of magic** (printed 313 onward) are
out of scope for this pass — they are monsters the GM runs, not races a player
picks, and they are a much larger body of stat blocks.

---

## A Military Occupational Specialty adds a skill package

RUE gives several classes an MOS: *"Select one of the following areas of
specialty. Gains all skills under that MOS."* The Coalition Technical Officer
offers seven, the Merc Soldier seven and the Robot Pilot two.

The last two were prose for a long time. Both shipped carrying a note saying an
MOS was *"a package choice the schema cannot express"* and that the skills
should be added *"by hand on the sheet"* — true when they were written, and
untrue from the moment `skills.mos` landed for the Technical Officer. The cost
of leaving it was not documentation: a Merc Soldier was **seven** skills short
of what the book gives every one of them and a Robot Pilot **eight**, including
Robot Combat: Basic and Robot Combat Elite, which are the entire point of that
class.

```yaml
skills:
  mos:
    choose: 1
    note: "Every skill under it is granted in addition to the O.C.C. skills."
    options:
      - id: "robotics"
        name: "Robotics MOS"
        skills:
          - { name: "Robot Electronics", base: 50, per_level: 5 }
          - { choose: 2, categories: ["Mechanical", "Electrical"], bonus: 10 }
```

**It is not a variant, and that distinction is the whole reason it exists.** A
variant **replaces** what the class says, and `VARIANT_OVERRIDES` excludes the
skills block on purpose — `skill_overrides` restating a percentage on a skill
the class already grants is a much smaller power than swapping a skill list. An
MOS **adds**: the Technical Officer's own page says the character gets its O.C.C.
skills *"plus the MOS skills chosen previously"*.

So `applyMos()` appends the chosen option's entries to `occ_skills` rather than
replacing them, and it runs on the **composed** class rather than on the
occupation slot — a character with no racial class carries their O.C.C. in the
`rcc` slot, so attaching it to `occ` worked for a D-Bee Technical Officer and
not for a human one. `combineClasses` carries `skills.mos` across the merge for
the same reason: it rebuilds `skills` wholesale, and without that a Technical
Officer taken alongside a racial class silently lost every specialty.

**An option's entries are the same shape as `occ_skills`** — fixed skills and
choice groups — so both go through `validateSkillEntries()`. Two validators for
one shape is the pair that drifts.

`characters.mos` stores which one, by id, parallel to `class_variant`. The
granted skills are already in `skills`, but which package produced them is not
recoverable from that, so the sheet could not show it and a re-derive could not
reproduce it.

**Unchosen is a warning, not a violation.** A class offering an MOS with none
picked is missing a whole skill package and nothing else would mention it; an id
no option carries means the class was edited under a saved character. Both are
reported where a human sees them, and neither blocks a save — the same reasoning
`no_occupation` uses.

### Two things that cost time here

**The parser wants list items indented deeper than their key.** Standard YAML
accepts either, and the minimal `parseYaml` in this repo returns `null` for the
same-indent form:

```yaml
skills:          # this parses to null
- { name: "X" }

skills:          # this parses
  - { name: "X" }
```

Every MOS option reported "grants no skills", which was true of what the parser
had produced.

**The Technical Officer's page had to be re-read in column order.** Tesseract's
own page segmentation spliced the two columns together and produced
`Medic MOS: computer, tool kit if applicable` — the left column's heading
running straight into the right column's equipment list. Read that way the class
has five specialties; read in column order it has **seven**. See
`scripts/read-columns.py` — this line pointed at a copy of that script under
`.claude/skills/book-survey/reference/` until the copy was deleted for being a
diverged fork of the real one.
