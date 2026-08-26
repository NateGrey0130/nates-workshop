# Starting above level 1

Building a character that begins at level 5 by replaying the level-up engine — and the
spell and psionic catalog work that took.

Part of the [character creator](../README.md) documentation.

---

## Starting above level 1

A player joining an established party used to have to be built at 1 and levelled
up five times through the XP endpoint, one confirmation at a time, inventing the
XP the character never earned to get there.

The wizard now asks for a **starting level** on the Race step, 1 to whatever the
class's own XP table caps at. Above 1, an **Advancement** step appears after
Powers.

**It is not a second system.** `buildProposal(character, cls, toLevel)` already
computed the whole diff for a span of levels, and by the end of the Powers step
the level-1 character is complete — which is exactly the input that function
takes. So starting at level 6 is *build at 1, then run the engine the live
level-up already uses*. That is why `js/leveling.js` moved into the app: the
browser cannot import anything under `functions/`, and
`_lib/leveling.js` now re-exports it so every server import is unchanged. Same
arrangement as `js/dice.js`, and for the same reason.

**One proposal per level, not one for the span.** The step runs the engine once
for each level gained, which is what makes a single level re-rollable — open
level 4, re-roll its dice, and every other level stays exactly as it stands.
Each level's growth is independent of the running total (the proposal reports
`from`/`to` and only the difference is kept), so every call starts from the
level-1 character.

The step opens on the summary — total pool growth, all skill picks, all spell
and psionic picks — with a collapsed section per level underneath. A player who
wants six levels resolved in one click gets that; one who wants to roll each
level's hit points separately gets that too.

### What the levels are allowed to change

| | |
|---|---|
| pool maxima | **rolled**, per level, from the class's `per level` formula |
| skills held since level 1 | advanced by `per_level × levels gained`, capped at 98% |
| skills picked with a grant | **not** advanced — a skill learned at level 5 is new, and starts at its catalog base |
| skill picks left blank | banked in `pending_skill_picks`, shown unspent on the sheet |
| XP | set to the level's own threshold, server-side |
| starting gear and money | **unchanged** |

**Gear and money do not scale, deliberately.** The books do not rule on what a
veteran owns, so any multiplier would be an invented rule and what a level-6
character has is a table conversation. Do not quietly add a per-level allowance.

**XP is not sent by the client.** The server reads `xpTableFor(cls)` and sets XP
to `thresholdFor(table, level)`, so the level and the XP beside it cannot
disagree. A level-6 character left at 0 XP reads as under-levelled to the XP
endpoint, and the very next award proposes a level-up it has already had.

**The server does not trust the pick count.** The wizard sends `picks_spent`;
the create endpoint recomputes the allowance with `skillGrantsFor(cls, 1, level)`
and banks the remainder, consuming from the earliest grant first — the same rule
a live level-up follows, now shared as `remainingGrants()` so the two cannot
drift. The character is also validated at **the level being created**, not at 1,
because the related and secondary allowances grow with level and judging a
level-6 character against a level-1 allowance refuses skills its class granted.

`validate-character.js` warns `xp_below_level` when a character above level 1
has less XP than its level needs. Hand-edited data and a G.M. levelling someone
by hand both produce it legitimately, so it is a warning and never a violation —
and the admin audit had to start selecting `xp` and passing it, because a
warning nothing hands the number to is a warning that never fires.

### Per-level spells are not in the data

`magic.spells_starting` and `psionics.powers_starting` are **level-1 counts**.
Until this change nothing in a class definition said what is learned per level —
only skills had a `schedule`. The books do state it, so the honest answer for a
class that has not been re-imported is *not recorded*, which is a different
answer from *none*:

```yaml
magic:
  spells_starting: 6
  spells_per_level: 2                                  # a flat rule
  # or, when the book varies it:
  spells_schedule: [{ level: 2, count: 2 }, { level: 3, count: 3 }]
psionics:
  powers_per_level: 1
  powers_schedule: [{ level: 4, count: 2 }]
```

`spellGrantsFor` and `psionicGrantsFor` return three distinguishable states:
`applicable: false` (the class has no magic at all), `unknown: true` (it has
magic and states no per-level rule), and a list of grants itemised by the level
that earned each. The Advancement step prints the difference — a class stating
nothing says so and offers nothing, rather than showing an empty list that reads
as *this class learns nothing at level 4*.

A schedule is the **complete** statement when present and a flat `*_per_level`
is ignored alongside it. Two keys that combine is a rule nobody remembers
correctly six months later.

**How many is not the same question as which.** The Ley Line Walker learns *"2
additional spells per level of experience, equal to or lower than their current
level of experience, starting at level 2"* — a cap that tracks the character
rather than a list, and one that **disagrees with the starting selection on
purpose**: a fresh walker picks twelve spells from `spell_levels_allowed:
[1,2,3,4]`, and the two it gains at level 2 may only be spell levels 1–2.

```yaml
magic:
  spells_starting: 12
  spell_levels_allowed: [1, 2, 3, 4]              # the starting twelve
  spells_per_level: 2
  spells_per_level_levels: up_to_character_level  # the per-level pair
```

`spells_per_level_levels` takes `up_to_character_level` or an explicit list, and
falls back to `spell_levels_allowed` when absent — so it costs nothing for a
class whose per-level picks are not capped this way.

**A schedule entry may override all of it**, because some books vary the cap per
level rather than by one rule. The Mystic (RUE p.119) is the case that forced
it: four spells at level 2 from spell levels 1–3, three at level 3 from 1–4,
then two per level from its own level downward. The first two are the
character's level **plus one** and the rest are the character's level, which no
single rule expresses.

```yaml
magic:
  spells_starting: 8
  spell_levels_allowed: [1, 2]
  spells_per_level_levels: up_to_character_level   # what entries without one use
  spells_schedule:
    - { level: 2, count: 4, spell_levels: [1, 2, 3] }
    - { level: 3, count: 3, spell_levels: [1, 2, 3, 4] }
    - { level: 4, count: 2 }
    # … every level, to the class's cap
```

An entry's own `spell_levels` wins; entries lacking one fall back to the
class-wide rule. And because a schedule is a finite list, **"and each additional
level of experience" has to be written out** — to 15, the default XP table's
cap. A class with a shorter `xp_table` simply never reaches the tail.

### Several grants can share a level, and a rule can be unenforceable

The Shifter needed both. It gains **three** spells at every level from level two,
and they do not come from the same place:

> Starting at level two, the Shifter can choose one spell from the following
> list plus one Protection or Summoning spell also in this list: *[34 named
> spells]* … and any Summoning spell that may be desired, excluding weather
> summoning. In addition, the Shifter can select one non-dimension related or
> control based spell, but they are limited to spells equal to or less than the
> Shifter's current level of experience.

So the **level alone stopped identifying a grant**. Entries sharing a level are
told apart by `slot`, and everything that keys a grant — the room accounting, the
banking, the pick payload — keys on level *and* slot.

```yaml
magic:
  spells_per_level_from: ["Banishment", "Charm", …]   # declared ONCE
  spells_per_level_levels: up_to_character_level
  spells_schedule:
    - { level: 2, count: 2, from_list: true, note: "One of these two must be a Protection or Summoning spell" }
    - { level: 2, count: 1, note: "Not dimension-related or control-based" }
```

`from_list` points at a list declared once rather than repeated on every entry.
It takes two forms, because a class can have one list or several:

| | |
|---|---|
| `from_list: true` | the class's single list, `spells_per_level_from` — the Shifter |
| `from_list: "A"` | one of several, from a `spell_lists` map — the Ley Line Rifter, which learns *"one spell (pick one) from each list"* every level |

Repeating a thirty-four name list on every entry would put it in the class
definition fourteen times and make one correction fourteen edits. **A slot
bounded by a named list is not also bounded by a spell level** — the list is the
restriction. A `from_list` naming a list that does not exist restricts nothing
rather than everything, which is the safer direction to fail.

**Modelled as two grants, not three**, because the difference between the book's
first two is a restriction nothing can check.

#### The lists outran the catalog, until the book was read

Both classes named spells the catalog never had: the Rifter's List A resolved
**3 of 17** and its List B 13 of 21, the Shifter's list 19 of 34. One chapter —
Rift & Ley Line Magic — accounted for nearly all of it.
`add-book-of-magic-rift-spells.sql` added the 72 spells behind that gap, read
out of the Book of Magic with the app's own importer, and all three lists now
resolve in full.

**A spell description does not print its level.** The book states that only in
the section heading a spell is listed under, so importing description pages
returned level 0 for **69 of 84** spells — and a level-0 spell matches no
`spell_levels` filter, so confirming those would have added rows the pickers
could never offer. That is what an import that looks like it worked looks like.
The level comes from the book's own master by-level index (pp. 89-92) instead,
and a spell that index could not place was left out rather than guessed at.

**Three independent readings had to agree** before anything landed: each spell's
own stat block, the cost the master index prints beside the name, and the cost
the class page prints in parentheses. Where the Shifter's class page disagreed —
`Influence the Beast` at 20 against 12, `Tame Beast` at 30 against 60 — the
description and the index agreed with each other, so the class page is the
outlier and the stat block won.

#### The whole Invocation list, and what supplying the level did not fix

`add-book-of-magic-invocations.sql` adds **108 spells** — every Invocation in
the book the catalog did not already hold, levels 2 through 15 plus the Spells
of Legend. A Ley Line Walker's picker went from 203 of the book's 311 listed
invocations to all of them.

Knowing the level does not come from the description, this import supplied it:
one request per **level section**, each carrying its own level, so no batch could
straddle a boundary. That was necessary and **not sufficient**. The book's
`Level N` headings sit *partway down a page*, so the first page of every batch
still carries the tail of the previous level — and those spells were stamped
with the new batch's level. **Thirteen rows came back exactly one level too
high**, `Sonic Blast`, `Wards` and `Wall of the Weird` among them, every one of
them looking completely ordinary.

So the rule is sharper than "supply the level": **the index is the authority and
the page position is not**. Every row was corrected against the master by-level
index, which states each spell's level in one place regardless of where its
description falls.

`Rift Teleportation` shows the mechanism at its clearest. Its stat block starts
on p143 and its `P.P.E.: Two Hundred` line falls on p144, so the Level Twelve
batch saw only the tail and produced a *second* row — conflated name, wrong
level, no cost at all — for a spell the catalog already had.

**Parsing that index took three passes, and the first two were quietly wrong.**
Worth recording, because each failure produced a plausible-looking answer:

| pass | what it did | how it showed |
|---|---|---|
| linear text | read the page as a text stream | levels one and two came back **empty**; `Blinding Flash` and `Globe of Daylight` filed under level three. It is set in three columns and the stream does not follow them — so read it geometrically, bucketing by x and sorting by y |
| strict names | allowed only letters in a name | silently dropped every `Summon & Control ...` entry and every name carrying its own parenthetical, like `Doppleganger (Superior) (1,000)` |
| strict costs | required a cost to be numeric | rejected `(l)` — an OCR'd 1 — along with `(400 to 1000+)` and `(1,600 or Special)` |

The finished index holds **311** entries and every staged row matched one. Costs
agreed on **108 of 108** between each spell's own stat block and the index.

#### A restriction the catalog cannot enforce is stated, not dropped

A spell row carries a name, a level, a cost and a stat block — **no category and
no tag**. So *"non-dimension related or control based"*, *"Protection or
Summoning"* and *"any Summoning spell"* have nothing to filter on. Classifying
three hundred spells by reading their names would be exactly the guessing
[the import rules forbid](known-limitations.md#known-limitations-and-refactor-candidates).

`note` carries the rule to where the choice is made, and the picker says plainly
that it cannot check it. That is the **skill-category posture, not the
psychic-tier one**: a rule the app cannot verify is one it should be honest
about rather than silently drop or silently enforce wrongly.

**The named list is enforced**, server-side as well as in the picker. It used
to be **15 of the Shifter's 34 spells that were not in the catalog** — the
dimensional ones the class is built around (`Close Rift`, `D-Step`, `Rift to
Limbo`, `Time Hole`…), from a chapter nobody had imported. They stayed in the
list on purpose, because a picker should name what it cannot find rather than
silently shrink, and they lit up the day `add-book-of-magic-rift-spells.sql`
arrived. **All 34 resolve now**, as do the Ley Line Rifter's 17 and 21.

That behaviour is still the point, even with nothing currently missing: a list
naming a spell the catalog lacks is a visible gap, not a shorter list.

Three of the 34 use the catalog's spelling rather than the book's, checked before
the list was written: `Control **&** Enslave Entity`, `De**si**ccate the
Supernatural` (the page misspells it), and `**Air:** Phantom Mount`.

#### Six spell levels RUE overrides, and an index that took three tries to read

`fix-rue-spell-levels.sql` corrects **six levels and one P.P.E. floor** against
RUE, which came out after the Book of Magic and overrides it.

All six level rows already carried `source_book = 'Rifts Ultimate Edition'`, and
all six were **exactly one level too high** — the same signature as the thirteen
rows the Book of Magic import got wrong, and the same cause: level headings sit
*partway down a page*, so the first page of an extraction batch carries the tail
of the previous level and those rows get stamped with the new batch's number.

| spell | catalog | RUE index | RUE description section |
|---|---|---|---|
| Teleport: Lesser | 7 | **6** | 6 |
| Tongues | 7 | **6** | 6 |
| Words of Truth | 7 | **6** | 6 |
| Sickness | 9 | **8** | 8 |
| Spoil | 9 | **8** | 8 |
| Wisps of Confusion | 9 | **8** | 8 |

`Manipulate Objects` stored `ppe = 0` with the note `2 per 5 lbs`. The book
prints *"P.P.E.: Varies; two P.P.E. per five pounds"* and the index prints
`2+`. **A stored 0 reads as free at the table** and also matches the stub
heuristic; `ppe` holds the minimum and `ppe_note` carries the schedule.

**Nothing was added.** The index listed five spells the catalog appeared to
lack and all five were the same spell under a different spelling — the diff
manufactured them by comparing raw names: `Animate/Control Dead` =
`Animate and Control Dead`, `Power Weapons` = `Power Weapon`,
`Summon & Control Canine` = `Summon and Control Canines`, `Control/Enslave
Entity` = `Control & Enslave Entity`, `Swim as a Fish` = `Swim as a Fish
(lesser)`. They keep the catalog's spelling: renaming would break every class
definition citing the current name, and citations are matched **in the browser**,
where `catalog_redirects` are not sent.

**The probes were wrong before the parser was.** Four spells came out at a level
that contradicted what I expected — `Carpet of Adhesion` 4 not 5, `Magic Net` 4
not 7, `Circle of Flame` 5 not 6, `Constrain Being` 7 not 10. Checking each
against its description section showed RUE agreeing with itself both times. The
expectations came from another edition. A probe that fails is a question, not a
verdict.

#### The Palladium invocation list, and the 57 nobody could reach

Two scripts, and the second is the one that mattered more.

`add-pf-invocations.sql` adds the **27** spells the Palladium Fantasy main book
prints and the catalog did not hold. `retag-pf-spells-both.sql` moves **57**
that were already there from `system = 'rifts'` to `both`.

**A Palladium Wizard could reach 98 of the 182 spells its own book lists.**
`inSystem()` offers a catalog row when its system is NULL, `both`, or the
build's own, and every spell imported from a Rifts book carries `rifts` — so a
spell in *both* books was invisible to the Palladium half of the app. This is
the same defect
[`fix-pf-armor-and-cross-system-gear.sql`](../db/fix-pf-armor-and-cross-system-gear.sql)
fixed for gear, where the Knight held clothing, gloves and a riding horse its
own sheet could not resolve. The trigger there was *"a class in the other system
grants the row outright"*; here it is stronger — the other system's core book
prints the spell by name, with a level and a cost the catalog already agrees
with.

The damage was worst exactly where a caster earns it. **Every spell from level
ten up was on that list bar one**, so a Palladium Wizard reaching tenth level
was offered almost nothing new: Mystic Portal, Summon Shadow Beast, Anti-Magic
Cloud, Create Golem, Resurrection, Dimensional Portal and all four Spells of
Legend were filed as Rifts-only. Nothing is taken away by the fix — `both` is a
superset of `rifts`, so every Rifts character still sees every one of them.

**No OCR and no model call.** The PDF carries a real text layer, so both tables
and all 27 descriptions were read geometrically with
[`scripts/read-columns.py`](../../../scripts/read-columns.py). The whole import cost
nothing but reading.

**The book ships two authority tables and they check each other.** An
alphabetical list by level (printed 187), which is the only place a level is
stated at all, and an alphabetical list by page (printed 188), which repeats
every cost. Parsed side by side they disagree on exactly **two costs out of
182** — See the Invisible (4 or 6) and Curse: Phobia (40 or 50) — and neither is
in this batch. Every imported row also has a **third** reading: the P.P.E. line
in its own stat block, usually spelled out in words there, *Twenty-Five* against
the index's 25. 27 of 27 agree.

**Two false gaps, both naming.** `catalog-diff.mjs` reported 29 missing and two
were not: *Swim as a Fish* is the catalog's `Swim as a Fish (lesser)`, and
*Invulnerability: Limited* is the catalog's `Invulnerability` — same level and
same cost in both cases, and the description page heads the second
*"Invulnerability (limited)"* where the index adds a colon. Three more looked
like near matches and are genuinely different spells: `Animate Object` against
the Warlock's `Earth: Animate Object`, `Circle of Concealment` against
`Concealment`, and `Time Capsule` (Touch, 30 P.P.E., preserves objects) against
the Rifts `Ley Line Time Capsule` (15).

**Nothing to record from the disagreements**, which is the result worth stating
plainly. `catalog-diff` reported 21 rows whose stored value differs from the
book. Fourteen already carry the Palladium figure in `variant_note` from
[`add-palladium-variants.sql`](../db/add-palladium-variants.sql); four are costs
the book qualifies and the catalog already explains in `ppe_note`; and four are
Spells of Legend, which the catalog stores at level 15 with a note saying so.
The later book still wins and **no stored number changed.**

**One page argues with the index, and the index won.** Exactly six description
blocks state a level of their own, and five of them are the book's own Spells of
Legend. The sixth is *The Finger of Lictalon*, headed *"Level: Spell of Legend"*
on printed 211 while the by-level index files it under Level Eleven. Three
things point the other way from its own page: the index puts it at eleven, the
Spells of Legend list does not name it, and its 150 P.P.E. sits with the level
elevens rather than the 1000-5000 of the legends. It is stored at eleven and its
`variant_note` records the losing reading rather than discarding it.

**The Druid is why this was worth doing now.** Its `level_progression` names
sixteen abilities as prose, and six of the wizard spells among them had no
catalog row of any spelling before this import — Faerie Speak, Control the
Beasts, Summon and Control Canines, Witch Bottle, Faeries' Dance and Monster
Insect. Three more were there under a different spelling, which is worse than
absent: the class page tells a player they gain *Faerie's Dance* at ninth level,
and typing that into the picker finds nothing.
[`fix-druid-spell-names.sql`](../db/fix-druid-spell-names.sql) aligns those three.
All thirteen wizard spells the Druid names now resolve.

**Eight of its sixteen do not, and should not.** Healing Touch, Kindle Flame,
Prophecy, Divination, Phoenix Healing, Protection Charm, Weather Control and
Communication are **Druidic magic powers** with their own descriptions on the
Druid's own pages, not wizard spells. Kindle Flame is the one that reads like an
oversight and is not: printed 76 gives it a full description, and the level four
line does not say *"as the wizard spells"* the way levels 2, 5 and 7 do.

#### Four spells the catalog held twice

`fix-duplicate-spell-rows.sql` removes four duplicate rows. **They were not
found by looking.** The new matcher refused to match RUE's `Summon & Control
Canine` because two catalog rows claimed the alias, and that refusal to guess
exposed a duplicate nobody had noticed. Scanning every catalog the same way —
group by name with parentheticals and connectives dropped, then require the
identifying fields to agree — found three more. All four are in `spells`;
skills, gear and psionic_powers are clean.

Every pair was settled against a book, not against which name looked nicer:

| kept | removed | why |
|---|---|---|
| `Fear` | `Fear (Horror Factor: 16)` | RUE's index prints the name plainly as **Fear**, level 2, 5 P.P.E. The stat detail was baked into the name by the importer |
| `Summon and Control Canines` | `Summon & Control Canines` | same spell imported once from each book; the Book of Magic copy carries **no description** |
| `Circle of Travel` | `Circle of Travel (Ritual)` | the Book of Magic master index lists it **once**, and the word "Ritual" appears nowhere on those index pages |
| `Transformation` | `Transformation (Ritual)` | same |

The `(Ritual)` rows had the same level, the same P.P.E., no description, and a
P.P.E. note saying the same thing in different words. They are an import
artifact, not a second spell.

Two safety checks ran first. **No class cites any of the eight names** — and the
first attempt at that check looked for YAML list items and returned zero for
everything, which would have read as "safe" for entirely the wrong reason.
Classes cite spells as an inline `Name (cost), Name (cost)` run; the corrected
check was probed against a name known to be cited before its zeros were
believed. **No character holds any of them** in its powers JSON.

The script matches **by name, never by id**: row ids differ between the local
and remote databases — `Fear (Horror Factor: 16)` is #37 locally and #29 in
production — so an id here would delete the wrong spell in one of them.

#### The import tooling, and the mistakes that paid for it

Four pieces, each built because the same class of error kept producing
confident wrong answers.

**`scripts/catalog-match-lib.mjs` — matching a book's names to the catalog's.**
Nearly every wrong import answer came from here:

| import | first answer | truth |
|---|---|---|
| psionics missing | 21 | 16 |
| psionics wrong category | 23 | 0 |
| spells missing | 5 | 0 |
| gear | "136 additive" | 27 collided |

Two failure modes, opposite directions. **Too strict invents gaps** — `Commune
with Spirits` and `Commune with Spirit` are one power, and importing the "gap"
duplicates it. **Too loose invents corrections** — RUE prints `Bio-Regenerate
(self)` *and* `Bio-Regeneration (Super)`, so stripping the parenthetical
collapses them onto one row and generates confident fixes to rows that were
already right.

The rule that survives both: **exact match first, and a relaxed match only when
it is unambiguous on BOTH sides**. Everything else is reported with its nearest
candidate and decided by a person. `nearest()` is advisory and must stay that
way — `Telekinetic Push`/`Punch` are distance 2 and are different powers, while
`Animate/Control Dead`/`Animate and Control Dead` are distance 4 and are the
same spell.

**`vocabularyWarnings()` catches the 22-of-23 case.** When one substitution
accounts for nearly all of a field's disagreements, that is a naming convention,
not N corrections. It fires on `Super-Psionics -> Super` (29 of 30) and stays
silent on the six genuine RUE spell-level corrections, which spread across two
different substitutions. Both behaviours are pinned in the smoke test.

**`scripts/catalog-diff.mjs`** puts that behind a CLI and prints four buckets —
disagree / missing / matched / extra — plus the vocabulary warning at the top.

```bash
node scripts/catalog-diff.mjs --table psionic_powers \
     --entries .cache/books/rue/psionics.json --compare category,isp
```

**`scripts/ocr-book.py` — OCR a scanned book once, properly.** Every setting in
it was learned by getting it wrong:

| setting | why |
|---|---|
| `--psm 3`, not `6` | at psm 6 Tesseract welds columns: `Level Two  Magic Shield (6)  Distant Voice (10)` arrives as one line |
| TSV always, beside the text | reading an index in reading order needs word geometry; the first pass saved text only and two pages had to be re-OCR'd mid-task |
| `--user-words` | Tesseract reads `I.S.P.` as `LS.P.`; a strict pattern found **10** stat blocks in a chapter that has **86** |
| 500 dpi for index pages | the authority tables are set in the smallest type in the book |
| normalise once, at ingest | `$.D.C.`/`[.S.P.`/`fect` are properties of the scan, not of today's import — fixing them per-import is how an unbounded `fect`->`feet` turned "effectively" into "effeetively" |

`.txt` is normalised, `.raw.txt` is what Tesseract actually said, `tsv/` carries
the geometry. **The cache is gitignored on purpose**: it is the full text of a
book Palladium still sells. Regenerate it, do not commit it.

```bash
python scripts/ocr-book.py "path/to/Book.pdf" --slug rue --tables 167,200-202 --dpi-tables 500
```

**A citation guard in `drift-check`.** Every psionic power claimed
`source_book = 'Rifts Ultimate Edition'` and twelve appeared nowhere in that
book. drift-check asks whether the repo can rebuild the database; this asks
whether the database is telling the truth about where it came from.

**Advisory, and it does not touch the exit code.** Run against a complete cache
for the first time it reported 40 problems, and the shape of its mistakes is the
useful part:

- 18 skills were flagged because the guard expanded `&` to "and" while the
  book text had the `&` deleted — `Motorcycles & Snowmobiles` became
  `motorcycles and snowmobiles` against a book holding `motorcycles snowmobiles`.
- **35 of the rest were gear, and gear is now excluded.** A gear name here is
  reworded prose, not a heading the book prints: the catalog says `"Dead Boy"
  Body Armor CA-2 (Light)` where RUE says *"CA-2 Light Body Armor"*, and `Light
  Mdc Body Armor` where the book says *"light M.D.C. body armor"*. Both are in
  the book. A check that cries wolf 35 times is worse than no check.

Left over: 422 rows checked, **4 worth a look** — four `W.P.` skills whose
component words appear in RUE but never as a skill heading. That is the right
kind of output for an advisory: a question, not a verdict. Whether a citation is
right is a different question from whether the repo can rebuild the database,
and wiring it into the exit code would fail every run over a name the book
spells differently, which is how a useful check gets ignored.

It runs only when the book's OCR cache is **complete** — a partial cache once
accused four gear rows whose pages simply had not been OCR'd yet, so it reads
the expected page count from the manifest and skips otherwise.

**`.claude/agents/book-reconcile.md`** is a second reader for the reconcile
pass, and deliberately has no write tools. It exists because the failures worth
catching all look ordinary from inside the parse — most sharply when four spell
probes "failed" and the book was right both times while my expectations came
from a different edition. **A failed probe is a question, not a verdict.**

#### The RUE psionics gap, and a diff that lied twice

`add-rue-psionics-gap.sql` adds the **16 psionic powers** Rifts Ultimate
Edition defines that the catalog did not carry, and corrects two I.S.P. costs.

The authority is the **Psionic checklist on printed p164**, which states every
power's name, category and I.S.P. cost in one place — the psionics equivalent
of the Book of Magic's master index. Every row was then read a second time from
its own stat block on printed pp.165-184. All sixteen agree.

The first diff of that checklist against the catalog reported **21 missing and
23 wrong categories**. Both numbers were mostly noise, and applying either
would have done damage.

**The catalog's category vocabulary is `Healing` / `Physical` / `Sensitive` /
`Super`. RUE's section heading reads "Super-Psionics".** That one word
accounted for **22 of the 23** category "errors". Rewriting them would have
moved 22 rows to a category value nothing else in the app uses, breaking every
picker that filters on it. Alias the heading; do not import it.

**A parenthetical qualifier is part of a power's identity.** RUE prints
`Bio-Regenerate (self)` *and* `Bio-Regeneration (Super)`; `Telekinesis` *and*
`Telekinesis (Super)`. Matching on names with the parenthetical stripped
collapsed each pair onto a single catalog row and produced three I.S.P.
"corrections" and two category "corrections" **to rows that were already
right**. The same stripping is what made three more look missing when they were
present under a different spelling:

| RUE prints | catalog holds |
|---|---|
| Bio-Regenerate (self) | Bio-Regeneration |
| Impervious to Poison | Impervious to Poison/Toxin |
| Commune with Spirits | Commune with Spirit |

So the match is **exact first**, and a stripped match is accepted only when it
is unambiguous *on both sides*. Anything left over is reported with its nearest
candidate and judged by eye — `Telekinetic Push` and `Telekinetic Punch` are two
characters apart and are different powers.

Two costs RUE genuinely overrides, each confirmed by both readings:

| power | catalog | RUE checklist | RUE stat block |
|---|---|---|---|
| Commune with Spirit | 8 | 6 | 6 |
| Sense Dimensional Anomaly | 6 | 4 | 4 |

Descriptions come from the book's own OCR'd text rather than a re-extraction —
it costs nothing and cannot invent anything. What it *can* do is carry OCR
damage, so the cleanup is an explicit table. Two defects it introduced before
being caught: an unbounded `fect`->`feet` rule turned "effectively" into
"effeetively", and the last power's block, having no following heading, ran off
the end of the chapter and swallowed the opening of the Magic section — 9,706
characters of description for a power that needs 2,677.

**OCR reads `I.S.P.` as `LS.P.` on most of these pages.** A strict pattern found
10 stat blocks in a chapter that has 86. Any pattern matching a psionic cost
line has to accept `I`, `L`, `l` and `1` as the first character.

#### Twelve rows claimed a citation the book does not support

All 94 psionic powers carried `source_book = 'Rifts Ultimate Edition'`. **Twelve
of them do not appear in that book at all** - not on the checklist, and nowhere
in the text of any of its 382 pages: `Attack Disease`, `Transfer I.S.P.`,
`Teleport Object`, `Commune with Animals`, `Dispel Spirits`,
`Advanced Trance State`, `Catatonic Strike`, `Cure Insanity`,
`Induce Nightmare`, `Insert Memory`, `Invisible Haze`, `Mental Illusion`.

They came from `add-rue-psionics-batch.sql`, an earlier extraction. The chapter
OCR'd completely - printed pp.165-184 each carry 3.7-7.5 KB - so this is not a
gap in the reading. The citation is simply wrong.

`fix-unverified-psionic-provenance.sql` sets those twelve to `source_book NULL`.
**It does not delete them.** Several are real Palladium powers from World Book
12: Psyscape, which RUE's own checklist page points at, so the content is worth
keeping and only the citation is false. Nor are they retagged *to* Psyscape:
that book is not in hand, and a guess is what created this. NULL is the honest
value.

Three tests were tried before one was trusted:

| test | absent | verdict |
|---|---|---|
| whole name | 13 | too strict - RUE prints `Commune with Spirits`, catalog holds `Commune with Spirit` |
| any distinctive word present | 7 | far too generous - `Catatonic Strike` matched on "strike", and "catatonic" appears on an insanity table 200 pages away |
| **whole name, parenthetical dropped, plural-tolerant** | **12** | used - the parenthetical must go or `Object Read (Psychometry)` reads as absent when RUE lists plain `Object Read` |

### A psionic grant can name its categories, and they replace the class's

Same shape, different subject, and the Mystic needed both halves — which is why
it is the class worth designing against. Bullet 4 of the same page:

> Select three additional psychic abilities from the **Sensitive** category and
> another two from the **Healer** category. At levels four and eight the Mystic
> can select one additional ability from the **Super** category.

```yaml
psionics:
  type: major
  powers_starting: 5
  categories_allowed: ["Sensitive", "Healing"]
  powers_schedule:
    - { level: 4, count: 1, categories: ["Super"] }
    - { level: 8, count: 1, categories: ["Super"] }
```

**A grant's categories REPLACE the class's rather than narrowing them**, and
that is the whole point rather than a convenience. Every catalogued power has a
NULL `min_tier`, so the per-power tier gate never fires and **tier is enforced
by category**: Super is master-only because non-masters are not offered it. A
grant naming Super *is* the book granting a major psychic an exception, so
intersecting it with the class's own categories would throw the exception away
and leave an empty picker.

Which also means **the psionic picker is per grant**, as the spell picker
already was. It used to be one batched set, on the reasoning that no book states
which level a given power had to be learned at. The Mystic states exactly that.

`pending_power_picks.categories` carries it for a banked grant, copied at grant
time for the same reason `spell_levels` is.

**Which is why the spell picker is per grant, not one batched set.** Each level's
spells are chosen from the levels *that* level allows, the way skill picks are
already chosen from the categories their grant allows. Batching them would
quietly let the level-2 pair be filled with level-4 spells. Psionic powers stay
batched: no book states which level a given power had to be learned at.

The cap is **enforced, not advised** — an out-of-cap spell is not in the list at
all. A spell's level is a mechanical rule like a psychic tier, not a table
judgement like a skill category, and the app already draws that line.

"starting at level 2" needs no key: a per-level grant is earned for every level
above the first, which is levels 2 upward by definition.

`extraction-prompt.js` names all four keys, because
[a field the prompt does not mention is a field that never arrives](known-limitations.md#known-limitations-and-refactor-candidates) —
`variants` shipped as schema the prompt was never told about and the first class
with age stages came back with both stat blocks dropped.

### The live level-up grants them too

The sheet's level-up panel offers the spells and powers the crossed levels earn,
one select per slot, grouped by the level that granted it — because for spells
the levels a slot may draw from belong to *that* grant. Crossing two levels at
once caps each pair separately.

Unspent slots **bank into `pending_power_picks`**, the same as skill picks, for
the same reason: levelling up is never blocked on choosing, so a grant nobody
spent has to go somewhere or the spells that level earned vanish silently.

The cap is enforced **server-side**, not only in the picker. `resolvePowerPicks`
checks every pick against the grant it claims — that such a grant exists, that
it has room, that the power is not already known, that it is in the catalog, and
that a spell's level is inside that grant's cap. A rejected pick fails the whole
level-up with a sentence saying which and why, rather than being dropped.

One trap worth recording: `loadCharacter` does not join `campaigns`, so the
system filter on the catalog lookup read `character.campaign_system` and got
`undefined` — a silent no-op that would have let a Rifts caster learn a
Palladium-only spell. The system is fetched explicitly now.

---
