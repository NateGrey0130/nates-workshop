# Language, literacy and enchantments

Two rule families the catalog models as data rather than as code.

Part of the [character creator](../README.md) documentation.

---

## Language and Literacy: Other, once per language

"Language: Other" is the skill list's escape hatch: one catalog row standing
in for every language the books never print. A character takes it **once per
language** — Language: English, Language: Spanish, Language: Orc — each a
separate skill named for what it is, all advancing on the Other row's numbers
(50% +5/lvl). No catalog row per language exists or is wanted: the character's
denormalized skill rows carry the name and the percentages, which is exactly
what they were built for.

**"Literacy: Other" is the same row for reading rather than speaking** (30%
+5/lvl, filed under Communications), and the rule is now stated **per family**
rather than per row, so both behave identically everywhere. See
[Literacy is the second family](#literacy-is-the-second-family).

The rule lives in [`js/language-skills.js`](../js/language-skills.js) and has
**five** consumers that must agree — the wizard's related/secondary picker, the
wizard's **choice-group** control, the sheet's claim/level-up picker, the
server's pick validator, and the server's level-up pick resolver:

- **In the wizard**, the Language: Other row prompts for the language instead
  of toggling, and never reads as already-taken, so it can be taken again.
  Each named language renders as its own checked row and un-picks
  individually. Duplicates are refused by name; class category gates apply
  unchanged (the row is Technical).
- **In an `occ_skills` choice group** it does the same — and for a long time it
  did not, because a group is a different control with its own toggle. There
  the same row was a plain checkbox, so *"two languages of choice"* produced a
  character holding one skill named, literally, `Language: Other`. Two Priests
  of Light in production are carrying exactly that. See
  [Languages of choice come from languages](#languages-of-choice-come-from-languages).
- **At level-up and claim time**, choosing Language: Other in a pick dropdown
  sprouts a "Which language?" input; the composed name is what submits. A
  blank language waits unspent, like any blank row.
- **Server-side**, a pick named "Language: X" that misses the catalog resolves
  to the Other row — the numbers still come from the catalog, so a caller
  cannot invent a percentage — with the language kept in the stored name.

The resolution rule everywhere: exact catalog hit first, and only a **miss**
in the `Language:` or `Literacy:` family falls back to **its own** family's
Other row. So Language: Dragonese, which has its own catalog row, resolves to
its own numbers, and a Literacy pick is never satisfied by a spoken language.
The smoke test pins the name-composition rules.

---

### Languages of choice come from languages

Thirty-three classes said *"two languages of choice"* — one, three, whatever
their book gives — and offered a whole skill **category** instead. Every one has
been narrowed to the repeatable `Language: Other` row.

| | classes | what the pick offered |
|---|---|---|
| via `Technical` | 7 | ~60 skills, languages among them |
| via `Communications` | 25 | 17 skills, **no ordinary language at all** |
| split in two | 1 | the Diabolist, below |

**The Communications twenty-five are the ones that mattered.**
`Language: Other` is filed under **Technical**. The only language row in
Communications is `Language: All (magical)`, which is a magical ability rather
than a language anybody learns. So a Ley Line Rifter's two languages could only
be spent on Radio: Basic, Cryptography or Surveillance — the class could not
grant a single language through its language pick.

The Technical seven were merely too wide, and nobody spent a pick on Gemology.
What they *did* do is instructive: two Priests of Light in production hold
`Language: Mongolian`, a Rifts-world language on a Palladium class, offered only
because it happens to sit in Technical.

#### The defect underneath was in the wizard, not the data

`Language: Other` is taken **once per language** and stored under the language's
own name. The related/secondary picker has always known that. **An `occ_skills`
choice group is a separate control and did not** — there the row was a plain
checkbox, so ticking it gave the character a placeholder instead of a name. Both
Priests of Light are carrying a skill called, literally, `Language: Other`.

Three things had to change together, and the third is the one that would have
been silent:

1. **`js/parser.js`** — a group may ask for more picks than its `from` list is
   long when the list carries a repeatable row. Without that, *"three languages
   of choice"* cannot be written down at all. The exemption is narrow: an
   ordinary over-asking list still errors.
2. **`app.js` `toggleGroupPick`** — prompts for the language, the way
   `toggleSkill` already did. The named picks render as their own rows so they
   can be un-picked.
3. **`app.js` `resolveSkill`** — falls back to the Other row's numbers for a
   name in the `Language:` family, the same resolution rule `skillsAtLevelOne`
   applies to related and secondary picks. A named language has no catalog row
   **by design**, so without this a group-picked `Language: Elven` saved at
   **0% +0/lvl**: a language the class granted, on the sheet, worth nothing and
   never advancing.

`_lib/validate-character.js` counts a named language toward a group offering the
Other row. It is advisory either way, but a Knight who took the two languages his
book grants was reading as having taken none.

#### Two numbers were wrong on the same lines

Rewriting a line while leaving a known-wrong number on it would be worse, so
these were corrected in the same script and named in its header. Both are the
printed percentage read wrong, and in both the class's own note records the
book's figure:

- **Cyber-Doc** — `base: 20, per_level: 0`. The printed *"+20%"* is a bonus on
  the Other row's 50%, not a flat 20% frozen for fifteen levels. Now `bonus: 20`,
  so the language resolves at 70% +5/lvl.
- **Vagabond** — no bonus at all, where the note said *"(+15%)"*. Now `bonus: 15`.

Every sibling class writes this as `bonus`; these two were the outliers.

#### The Diabolist was split by the limit this removed

Its book line is three languages of choice. A choice group could not ask for
more options than it listed, so it was written as `choose: 2` plus `choose: 1`,
with a note saying exactly why. That note described a limitation that no longer
exists — so the split and its explanation are both gone and the three languages
are one group again.

**One thing the shape still cannot hold**, stated in its own note rather than
dropped: the Headhunter Techno-Warrior's line is *"three languages of choice,
**or** one other language and two Lore skills"*. A choice group picks from one
pool, so it offers the three languages and the note carries the alternative.

**No character lost anything.** This narrows what may be *chosen*, not what has
been; the four production characters built on these classes keep every skill
they hold.

---

### Literacy is the second family

The same check, run on literacy. `Literacy: Other` was the only member of its
family with **no rule at all** — it was treated as one ordinary skill — so a
Wizard *"literate in two languages of choice"* spent both picks and ended up
literate in "Other". Six classes, and the shapes differ:

| class | was | now |
|---|---|---|
| Rogue Scholar | the whole `Communications` **category**, 17 skills | pick 3, +30% |
| Diabolist | a from-list of 4 **generic** Literacy rows | pick 2, +20% |
| Summoner | same | pick 2, +20% |
| Wizard | same | pick 2, +15% |
| Shifter | `Literacy: Other` granted as a **fixed** skill, base 50 | pick 1, +20% |
| Warlock | same, base 40 | pick 1, +10% |

The Rogue Scholar is the language defect exactly. The middle three were better
and still wrong: the four rows on offer — `Literacy`, `Literacy: Native
Language`, `Literacy: Dragonese/Elven`, `Literacy: Other` — are all generic, so
two picks bought nothing named. The last two **granted the placeholder**, which
is a pick that was never offered; both of their own notes say *"of choice"* in
so many words.

**No number changed in the six.** Every group keeps its own `choose` and
`bonus`, and the two fixed grants became a pick at the bonus their base already
encoded — the Shifter's 50 is the catalog's 30 plus its printed 20, the
Warlock's 40 is 30 plus 10. Only the **name** changes, from `Literacy: Other`
to the language the player picks.

#### Generalising the rule was most of the work

[`js/language-skills.js`](../js/language-skills.js) went from a Language-only API
to a per-**family** one: `isFamilyName`, `isRepeatableRow`, `otherRowFor`,
`familySkillName`, `promptFor`. `isLanguageName` and `languageSkillName` are
gone — generalising left them with no callers, which is what the smoke test's
dead-export check exists to catch. Eleven call sites across `app.js`,
`sheet.js`, `parser.js`, `_lib/validate-character.js` and `_lib/skill-picks.js`
now name a family rather than a row, and the prompt asks *"Which written
language?"* when it should.

#### The Stone Master was granting nothing at all

Found by the same sweep, a different defect, fixed in the same script:

- **`Literacy: Dragonese/Elf`** — no such catalog row and **no redirect**, so
  the skill resolved to nothing. The row is spelled `Dragonese/Elven`.
- **`Language: American`** — `base: 0, per_level: 0`, so it sat on the sheet at
  0% and stayed there for fifteen levels. It has no catalog row of its own,
  which is precisely what the Language family's Other row is for: 50% +5/lvl.

Both are pinned by regression now: **every fixed skill must resolve to real
numbers** (a catalog row, a redirect, or its own stated base), and **no
Language or Literacy skill may sit at 0%**.

This sweep also turned up **68 fixed skills sitting below their catalog base**,
which needed the books open one class at a time. See
[A printed bonus is not a base](#a-printed-bonus-is-not-a-base).

---

### A printed bonus is not a base

An O.C.C. skill list writes a fixed percentage two ways, and they mean opposite
things:

| printed | means |
|---|---|
| `Language: Native Tongue at 96%.` | the figure **is** the percentage |
| `Chemistry (+10%)` | ten points **on top of** Chemistry's own 30% |

Both were stored the same way, as `base`. So the Cyber-Doc — a surgeon —
diagnosed at **Computer Operation 5%** where any passer-by has 40%, and the
SAMAS Pilot drove at **Automobile 15%** against a catalog row of 60%. Not a
small bonus: a crippling floor, on exactly the skills the class exists to be
good at.

**48 skills across six classes** now carry `bonus` instead, which
`resolveSkill` has always summed onto the catalog row — the app supported this
the whole time; only the data and the validator disagreed.

| class | skills | source |
|---|---|---|
| Cyber-Doc | 10 | RUE p.90 |
| Rogue Scholar | 10 | RUE p.94 |
| Wilderness Scout | 9 | RUE p.99 |
| Coalition SAMAS Pilot | 8 | RUE p.233 |
| Stone Master | 6 | Book of Magic p.224 |
| Vagabond | 5 | RUE p.97 |

Dropping `per_level` alongside `base` matters too: the SAMAS Pilot's Automobile
carried `+5`/level where the catalog row is `+2`.

#### Read as images, not as OCR

Rifts Ultimate Edition has no text layer. The OCR cache is good for *locating* a
section and not for transcribing one — it had merged the SAMAS Pilot's skill
list with the Coalition Grunt's column beside it, which would have written six
wrong numbers. Every page here was rendered and read as an image instead, and
the generator refuses to rewrite a line whose stored number does not already
equal the printed bonus.

#### What was checked and deliberately left alone

15 rows still sit below their catalog base, and every one is what its book
prints:

- **Twelve `Language: Native Tongue` rows at 88–97%.** The Vagabond really does
  speak at 88% and the Mystic at 97%; the catalog's generic 98% is not what
  those classes get. Each now carries the page it came from, because eight of
  them carried nothing and every audit re-derived the same answer from the same
  scans — which is the work a note exists to prevent.
- **The Noble's Horsemanship: General at 35%/+5.** The O.C.C. block prints it
  with no bonus at all — the 35 is the *Palladium Fantasy* skill's own number,
  a cross-system difference its note already records.
- **The Warrior Monk's Begging at 20%/+3.** Palladium Fantasy prints, in so many
  words, *"Base Skill: 20%+3% per level of experience."*
- **The Vagabond's Begging at 10%.** Printed `Begging (10%)` — no plus, where
  every sibling line has one. Kept as a base, but its `per_level: 0` was dropped
  so it advances at the catalog's +3 instead of freezing for fifteen levels.

The Chiang-Ku hatchling was a different defect found by the same sweep: the
adult knows all domestic skills at 80%, which is right, but the hatchling
variant lowered five of them to a flat 25, which is nobody's number. Dragons &
Gods p.22 says hatchling skills *"start at first level proficiency"*, and the
override's Advanced Math already read that way at the catalog's own 45. The five
domestic rows now do too.

Three regression invariants hold the line: a `bonus` may never sit on a name the
catalog does not have (it would resolve to **0**, not to the bonus), **no fixed
skill may sit under its catalog base without a note explaining why**, and that
rule asserts it actually compared rows rather than passing vacuously.

The middle one used to exempt the `Language:` and `Literacy:` families outright.
That exemption did nothing useful — the check already skips names the catalog
does not hold, and a native tongue *does* have a catalog row — so all it achieved
was hiding twelve rows that really are below the line. It is gone, and the rule
is now simply: **below the line, say why.**

---

## Enchantments

**What an alchemist puts INTO an object, as opposed to the object.** Palladium
Fantasy draws three families the same way — a property with a price and a cap,
instilled into ordinary gear:

| family | count | printed | cap |
|---|---|---|---|
| `armor` | 11 features | 249 | four to a suit |
| `weapon` | 21 properties | 249-250 | three to a weapon |
| `charm` | 30 powers | 253 | three to a ring, bracelet or medallion |

*"Cloak of Armor, 20,000 gold"* is a **gear row**. *"+1 A.R., 4,000 gold"* is
**not**: it is a modifier that can sit on any of the armour rows the catalog
already has, and a row per combination of every feature with every suit is not
a catalog, it is a combinatorial explosion.

The charm family is the one worth reading the book for. It is easy to take those
thirty as finished items — a Ring of Chameleon, a Medallion of Teleport — and
the page says otherwise: *"The following magic effects can be **placed in**
rings, bracelets, charms, and medallions,"* three powers to an item.

### The array is on the instance

`character_items.enchantments` is a JSON array of slugs on the **inventory
row**, not a flag on `gear`. One long sword in a party of four can be the Demon
Slayer while the other three stay ordinary, and no other shape can say that.

### Bonuses reuse the block that already exists

`enchantments.bonuses` is the **same JSON block** `skills.bonuses` and a class's
`bonuses:` use, validated through the same `validateBonuses`. That is not a
convenience — it is why this was affordable: *Invisible Weapon: +3 initiative,
+2 strike and parry* is `{"combat":{"initiative":3,"strike":2,"parry":2}}` and
`derive.js` needed **no new cases**, exactly as it needed none when skills
learned to grant bonuses.

Seven of the 62 carry one. Dice are stored **as dice** — the Thunder Hammer's
extra 2D6 is `"2d6"`, not a 2 — which the group has accepted since the
Godling's *"+1D4 on initiative"* made it a hard parse error.

**The rest stay prose, deliberately.** Three fireballs a day, double damage to
demons, teleport three times daily: a number would be a lie about what the book
grants. Two more are prose for a different reason — Protection from Circles and
from Witches are real `+1`s with **no save to land on**, since the sheet's save
block covers spell magic, ritual magic, wards, psionics and horror factor. A
bonus on a key nothing renders is stored, ignored, and indistinguishable from
one that works, so both the generator and regression **refuse** a save key the
sheet cannot show.

### The rules live on the server

`PATCH /characters/:id/items/:itemId` takes the whole array and checks it, because
the sheet is not the only caller and a stored slug that resolves to nothing
renders as a slug forever:

- an armour feature needs armour and a weapon property needs a weapon;
- a charm power may go in anything **except** a weapon, which the book states
  outright;
- one item may not mix two families;
- the cap comes from `max_per_item` **on the row**, not from a constant — four
  features fit in a suit and a fifth is refused.

A freeform item (`gear_slug` NULL) has no category to check against, so the family
rule is skipped rather than guessed at: a GM who writes in "silver signet ring"
should be able to enchant it. The cap still applies.

### The armour table, all sixteen rows of it

Printed 270 prints **sixteen** types of armour and the catalog held **five**, so
a Palladium character could buy soft leather, hard leather, studded leather,
chain mail or scale mail and nothing else — no cloth, no padding, no splint, no
plate, and not one of the half suits, which is most of what a poor character or
a heavily armoured one would actually wear. All sixteen are there now, plus the
three leather half suits the prose beneath the table gives.

The five that were already there are a **check on the reading** rather than just
data: they come from the same table, and the generator refuses to run if any of
them has drifted from the printed figures. All five matched.

**Three half suits keep no price.** The table prices the metal ones; the leather
half suits appear only in the prose — *"half suit of Soft Leather has 10 S.D.C.
& A.R. 6"* — with no figure, and a number there would be invented. The same
prose says a half suit of padded, quilt or cloth *"isn't worthwhile"*, so none
is imported.

**Shields are on printed 60**, under W.P. Shield, not in the armour table. The
catalog had the small wood-and-leather one and mentioned the metal-plated
version inside its own description; all five are now rows.

### Seven Rifts armour rows were the same suit twice

Each pair was one row imported from Rifts Ultimate Edition p.261-270 and one
older row whose `source_book` read *"Web reference (not book-verified)"*. On the
four full-suit pairs the M.D.C. and the weight agree exactly — 95/24, 70/21,
35/13, 50/11 — which is what makes them duplicates rather than four suits that
happen to share a shape. The book-verified row is the keeper every time.

**The Crusader pair disagreed on price**, 55,000 against 40,000. That one is not
a tidy-up: one of those numbers was wrong and the catalog offered both.

**The three Dead Boy rows are a different shape.** Two were one-line stubs with
no M.D.C. and no cost, standing beside full rows that had both. The third was
not a suit at all — *"Dead Boy" Body Armor (Black Market)* had no M.D.C. and its
description said outright that it was a price. Printed 261 puts that price under
*"Features Common to All Dead Boy Armor"*, so it belongs to **both** suits and is
now a `cost_note` on each rather than an item somebody could wear.

**One redirect already pointed at a row being retired.** `dead-boy-body-armor`
resolved to the CA-2 *stub*, so it is re-pointed first — a retired key resolving
to a row that no longer exists is the one failure `catalog_redirects` exists to
prevent, and regression now checks it over the whole catalog.

**Checked and found distinct**, so left alone: the Bushman Trooper (90 M.D.C.
against the composite's 60 — a separate model, not another printing), the
Huntsman and Juicer Assassin plate (both 45 M.D.C. and everything else different),
and `cyber-armor`, which two characters are wearing.

### The items themselves are gear

The other half of printed 249-267. The enchantments are what an alchemist puts
INTO an object; **175 finished items** are the objects he sells over the
counter, and those are ordinary `gear` rows.

| section | rows | section | rows |
|---|---|---|---|
| Magic potions | 28 | Faerie foods | 28 |
| Miscellaneous components | 28 | Herblore drugs | 17 |
| Poisons and toxins | 12 | Magic fabrics | 11 |
| Other articles | 11 | Bandages and make-up | 10 |
| Crystals and stones | 9 | Magic powders | 8 |
| Magic fumes | 7 | Guardian stones | 3 |
| Magic armour, finished suits | 3 | | |

**The three magic suits go in as armour**, not as an undifferentiated `magic`
row: the page prints an A.R. and an S.D.C. for each, and those columns exist —
Cloak of Armor at A.R. 14 / S.D.C. 50, Cloak of Protection at 12 / 50, Leather
of Iron at 15 / 60. Everything else is `category = 'magic'`.

`cost` holds the low end and `cost_note` the rest, which most of these need: the
book prices in ranges far more often than in figures, and four different ways —
a range (*"20,000-40,000 gold"*), an open end (*"700,000+"*), a per-unit rate
(*"80 gold per foot"*), and a band. **Faerie foods are priced by band**, which
their own preamble states: 500-1,500 for the recreational ones, 2,000-10,000 for
the debilitating. They are prefixed *Faerie* because the catalog already sells an
ordinary goose.

**One item has no price and keeps none.** The Crystal Ball is *"considered
priceless and sells for millions"*, and a number there would be invented.

#### Reading prose, not a table

These entries are paragraphs with a price somewhere inside. An extractor found
the boundaries; three classes of error had to be corrected by reading the page,
and all three are pinned:

- **A price wrapped across a line.** `20,000-
30,000` rejoins as the single
  number **2,000,030,000** if the de-hyphenation that fixes a broken *word* is
  let near a number. The Fright Wig and the Chaser crystal both read that way.
- **A longer entry labels its own parts** — `Duration:`, `A.R.:`, `Cost:` — and
  each looks exactly like the start of a new item. The Cape of Dimensions' 700,000
  gold was attributed to an item called *"Use Limits"*.
- **The first price in an entry is not its price.** The Cape mentions 25,000 gold
  to repair a tear long before its own cost line.

### What is deliberately not modelled

- **Rune and holy weapons** are *generated* from a tier and a table of powers
  rather than listed. Importing them would invent about forty items the book
  does not print.
- **Curses** are effects applied to a person or an object, with no price and no
  weight — closer to a spell than to a sword.
- **Transformable weapons** are a kind of weapon rather than a property, and the
  book says outright that one *"cannot have any other magic properties"*.
- **Duration and frequency** stay in the description. *"20 melees, twice daily"*
  is two numbers and a unit; three columns used by one family of one book, with
  nowhere on the sheet to put them, would be worse than a sentence.

---
