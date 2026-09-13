# Rifts World Book 18: Mystic Russia — survey

**Surveyed 2026-09-12**, offline, off the cache. No extraction has been spent
yet: this file is what phases 1–3 of `book-survey` produced, and the extraction
plan at the end is the thing to agree on before phase 4 costs anything.

This is the **last book of the 2026-08-28 batch** (`BOOK-INGEST-QUEUE.md`).
Nothing in production cites it — `source-coverage.mjs --remote` does not list
the slug at all.

## Page offset

**`page_offset: 1`**, from `scripts/books.json`, and re-verified rather than
taken on trust: **cache page = printed folio + 1**.

| check | reading |
|---|---|
| cache `p108` last line | `107` |
| cache `p122` last line | `121` |
| cache `p173` carries the folio inline | `172` |

178 cache pages, 176 printed. Cache `p175`–`p177` are Palladium house ads and
`p178` is blank; the last page of the book proper is cache `p174` (printed 173).
**The registry note saying the last three cache pages are ads is one short** —
it is the last four, counting the blank.

## Cache health

Re-run 2026-09-12 with `ocr-book.py` (the book was cached 2026-08-28, before the
detectors existed):

| key | value |
|---|---|
| `text_layer` | true |
| `welded_pages` | **0** |
| `corrupt_pages` | **1** — cache `p175`, 3 hits, and it is a *Heroes Unlimited* house ad rather than a page of the book |
| `substituted_digits` | **72 pages** |

**The 72 matter more than anything else in this file.** This is the third
category from `book-survey` §0 — a digit set as a letter that looks like it —
and **a render does not fix it**, because the damage is in the ink. Two pages
where it lands on data an import reads:

- printed **107**, the bio-wizardry price list: prices print as `!D6xlOO
  credits`, `2D4xlOOO credits`, a dozen rows of it.
- printed **121**, the supernatural P.S. damage table: `!D4xlO M.D. on a power
  punch`, `!D6xlO+10 on a full strength punch`.

Read the token as the dice expression it can only be. `!D4xlO` has no other
reading.

## The book's authority tables

**Experience Tables — printed 172 (cache `p173`).** **Ten** ladders naming
**eighteen** classes, several of them shared:

| ladder | covers |
|---|---|
| 1 | Night Witch, Mystic Kuznya |
| 2 | Russia Sorcerer (the book's own name for the Ley Line Walker) |
| 3 | Gypsy / Hidden Witch |
| 4 | Necromancer |
| 5 | Old Believer |
| 6 | The Slayer, Gypsy Layer of Laws |
| 7 | Gypsy Thief, Gypsy Enforcer |
| 8 | Born Mystic, The Gifted Ones, Gypsy Fortune Teller |
| 9 | Fire Sorcerer, Gypsy Seer |
| 10 | Gypsy Beguiler, Gypsy Wizard-Thief |

**A TRAP WORTH THE WHOLE SECTION: the heading is split across two lines.** The
column reader put `Experience` on line 1 and `Tables` on line 2, so
`grep -i 'Experience Table'` over the cache **returns this page zero times** and
finds only the contents entry at printed 4 and a mention at printed 71. The
single most valuable page in the book is invisible to the obvious search. Search
for one word, or for the class names.

**CORRECTED 2026-09-12 (PR #984): the experience table IS the roster here, and
this section previously said the opposite.** The first reading dropped ladder 8
— `Born Mystic,` / `The Gifted Ones &` / `Gypsy Fortune Teller`, three label
lines at `p173` lines 120-122 — and then reasoned from the hole it had left,
concluding that the Gifted One and the Born Mystic had no ladder. They share one.
**Every class this book actually defines has a ladder.** The two entries that
look like exceptions are not classes: the **Russian Shifter/Summoner** (printed
127) is a pointer — *"The original description for the Shifter is found in the
Rifts® RPG, page 87"*, and the author says space prevented more — and **The Pact
Witch** (printed 73) is a concept heading above the Night Witch. So
`new-west`/`spirit-west`'s trap does **not** recur here, which is worth as much
as finding it would have been.

**The shape of the error is the lesson, not the number.** Nothing about a
nine-row table looks wrong; it was checked against a prose count written from the
same reading, so both halves agreed and were both wrong. **Count the label lines
on the page** — `grep -vnE '^[0-9 ,.-]*$' p173.txt` prints all twenty of them in
one command, and the ladders are whatever those resolve into.

**Magic levels come from `Level N` headings**, not from descriptions — five
`Level One` headings mark the five tradition starts, at cache `p077`, `p093`,
`p107`, `p112` and `p131`.

## Inventory

Counted by structural marker per page, never by name.

| band (printed) | what is there |
|---|---|
| 19–71 | the **bestiary** — demons, spirits and creatures of Russian folklore. `R.C.C. Skills` and `Horror Factor`, ~69 pages |
| 75–86 | Night Witch and Hidden Witch, and **Spoiling Magic** |
| 87–105 | Necromancer, and **Bone Magic** |
| 106–110 | a fifth `Level One` heading at printed 106, then the Sorcerer and Fire Sorcerer |
| 111–120 | **Fire Magic** |
| 122–140 | Mystic Kuznya, Old Believer, Slayer, and **Nature Magic** |
| 142–156 | the **Gypsy** classes, and a Steeds table at printed 142 |
| 159–171 | **Sovietski military vehicles**, priced |
| 172 | the Experience Tables |

**Zero I.S.P. stat lines in the whole book.** No psionic powers are defined.

## Classes

Definition pages — the page carrying the entry's own `Attribute Requirements` or
`O.C.C. Skills` block, not a mention:

| printed | class |
|---|---|
| 75 | Night Witch O.C.C. |
| 82 | Hidden Witch — tagged *Optional O.C.C. & N.P.C. Villain* |
| 90 | Necromancer O.C.C. |
| 109 | Sorcerer O.C.C. and Russian Fire Sorcerer O.C.C. |
| 122 | Russian Mystic Kuznya O.C.C. |
| 129 | Old Believer O.C.C. |
| 138 | Slayer O.C.C. |
| 143 | Gypsy Thief O.C.C. |
| 146 | Gypsy Wizard-Thief O.C.C. |
| 148 | Gypsy Seer O.C.C. |
| 150 | Gypsy Fortune Teller O.C.C. |
| 151 | The Gifted One O.C.C. |
| 153 | Gypsy Beguiler O.C.C. |
| 155 | Gypsy Enforcer O.C.C. |

Headings elsewhere also name a **Layer of Laws O.C.C.** and a **Born Mystic**,
which appears as both `O.C.C.` and **`P.C.C.`** — the `new-west` P.C.C. trap is
present in this book too, so a roster scan keyed on `O.C.C.`/`R.C.C.` alone will
miss it. **Count the entries, not the headings.**

### The book tags playability per entry — READ 2026-09-12 (PR #984)

**Settled. The answer is eight entries, and the tag headings the first sweep
read are not the authority — the `Player Note:` paragraphs are, and on four
entries the two disagree.**

The bestiary is **printed 16-71**, and the contents page at printed 4 is its
index: **28 named entries, 26 with stat blocks.** The two without are
`Werebeasts` and `Vampires`, both at printed 71 and both pointers — to
Conversion Book One p191 and to Vampire Kingdoms. Every entry carries a heading
of the form `<name> ... NPC Villain` or `<name> ... Player Character or
Villain` sitting above its `Also Known as` line.

**The eighteen demons (printed 19-54) are NPC, all of them**, and none carries a
`Player Note:` at all — `Player Note:` occurs exactly **eight** times in the
book and every one is a Woodland Spirit. **One demon has no tag whatsoever:** the
**Serpent Hound** (printed 40) goes straight from prose to `Also Known as the
Fire Hound`, with a bare `Serpent Hound` heading. Its intent is not in doubt
among seventeen siblings marked NPC Villain, but the book does not say so, and an
importer should record that as untagged rather than inferred.

**The eight Woodland Spirits (printed 57-70) each carry a `Player Note:`, and
that note is the verdict:**

| entry | printed | the heading says | the `Player Note:` says |
|---|---|---|---|
| Domovoi | 57 | **Non**-Player Character or Villain | GM *"can allow ... as an optional player character"*; 95% abstain from adventure |
| Leshii | 59 | **Non**-Player Character or Villain | GM *"can allow ... as an optional player character"* |
| Polevoi | 61 | Player Character or Villain | *"can allow a Polevoi as an **optional** player character"* |
| Rusalka | 63 | Player Character & Villain | optional, *"but such cruel and petty creatures are **not recommended**"*; best as a villain |
| Vodianoi | 64 | **Non**-Player Character & Villain | *"not suitable ... **unless it is one of the rare good or anarchist ones**"* — conditional, not a refusal |
| Firebird | 67 | **Non**-Player Character/Animal | **"Not applicable as a player character."** — the only flat no in the book |
| Spirit Wolf | 68 | **Non**-Player Character & Villain | GM *"may allow ... as an optional player character"* |
| Man-Wolf | 69 | **Non**-Player Character & Villain | *"can be used as a player character ... a fun and challenging character to play"* — the **warmest** endorsement of the eight |

**So seven of eight are playable to some degree and only the Firebird is
refused** — and the heading is wrong in **both** directions. Two headed *Player
Character* (Polevoi, Rusalka) are merely optional, Rusalka actively discouraged;
four headed *Non-Player Character* are GM-allowable, and the Man-Wolf — headed
NPC — gets the most enthusiastic playability note in the book. **A sweep over the
headings does not merely undercount, it inverts the top and the bottom of the
list.**

**The import blocker nobody would have predicted: only ONE of the seven says how
to level.** The Man-Wolf's `Level of Experience:` line sends a player character
to *"the same experience table as the Dragon Hatchling"*; the other six state no
ladder anywhere in the book, and the printed-172 table has no spirit on it. A
playable row needs an `xp_table`, so six of these need a decision before they can
be imported at all — not a reading, a decision.

**And `~69 bestiary pages` was wrong, by 24.** That figure is the count of pages
carrying `Horror Factor`/`Natural Abilities`/`Habitat:` **anywhere in the
book**, and twenty-four of them sit in the classes section at printed 75-155 —
the Night Witch's demon helpers, the Necromancer's animated dead, class entries
with a `Habitat:` line. The bestiary is **56 printed pages**, 45 of which carry
creature fields.

The Necromancer's entry carries a line saying a player character of that class
is not recommended — a recommendation rather than a rule, and it is a full
O.C.C. with a ladder.

## Catalog diff

`node scripts/catalog-diff.mjs --remote --table spells --entries <parsed> --compare level`,
2026-09-12, against 773 production spells.

| bucket | count |
|---|---|
| matched | 10 |
| **disagree (level)** | **5** |
| **missing** | **131** |
| extra | 758 (other books) |

146 entries parsed across four traditions:

| tradition | printed | entries | levels |
|---|---|---|---|
| Spoiling Magic | 75–86 | 18 | 1–10 |
| Bone Magic | 87–105 | 59 | 1–14 |
| Fire Magic | 111–120 | 39 | 1–12 |
| Nature Magic | 129–140 | 30 | 1–12 |

### The "five disagreements" were measured against the wrong rows

**CORRECTED 2026-09-12 (PR #985). This section previously called five spells a
level dispute to arbitrate. They are not one, and the catalog's own convention
is why.**

Every one of the five sits inside a **named Mystic Russia tradition** — Living
Fire (printed 112-115) or Nature (printed 134) — and this catalog already holds
tradition spells as **their own row at their own level**, beside the common
invocation:

| spell | common invocation | the `Fire:` tradition row |
|---|---|---|
| Circle of Flame | 5 — Rifts Ultimate Edition p.207 | **3** — Book of Magic p.76 |
| Fire Ball | 6 — RUE p.210 | **3** — Book of Magic p.77 |
| Fire Bolt | 4 — RUE p.205 | **1** — Book of Magic p.75 |
| Impervious to Fire | 3 — RUE p.202 | **1** — Book of Magic p.75 |

The tradition version is **consistently cheaper**, which is a Palladium design
pattern rather than a discrepancy. The first reading compared this book's
tradition spells against the *common-invocation* rows, and so reported a
conflict wherever the two tiers differ — which is everywhere, by design.

**The clearest consequence: Circle of Flame is not a disagreement at all.**
`Fire: Circle of Flame` is already level 3, exactly what this book prints. That
is agreement, read as conflict.

**Two of the five were never name matches either.** `Fire Fists` here is
`Fire Fist` — singular, Palladium Fantasy Main Book p.199 — and `Healing Water`
is `Ocean: Healing Waters`, Underseas p.65, already namespaced to a different
tradition.

**The 131 IS hand-checked now, and it holds.** Re-diffed 2026-09-12 with
tradition prefixes and trailing plurals folded: 147 distinct titles parsed, **16
matched, 131 absent** — and one of the sixteen (`Fumigate: Insects` ->
`Metamorphosis: Insect`) is the checker being too eager, not a real match. Fifteen
real matches, exactly what the first pass reported. `book-survey` §3 budgets ~6
false gaps out of 131; **there are none.** Do not re-spend this check.

### Skills, psionics, gear, vessels

- **Skills: no new-skills section exists.** A grep for a skill-description or
  new-skills heading returns nothing. **This is exactly what `spirit-west`'s
  survey said before one of its classes turned out to grant `W.P. Tomahawk`** —
  so treat it as "the book defines none", never as "none will be needed".
- **Psionics: zero.** No `I.S.P.` stat line anywhere in 178 pages.
- **Gear: priced entries on printed 159–170**, inside the vehicles chapter, plus
  the bio-wizardry price list at printed 107 — which is one of the pages the
  digit substitution eats.
- **Vessels: printed 159–171**, Sovietski military, eight pages carrying
  `M.D.C. by Location`. A Steeds table at printed 142 lists Burkov Mastodon,
  bionic horses, Hell Horses and Serpent Hounds — **not yet classified** as
  vessels, creatures or gear.

## Decisions settled with Nate, 2026-09-12

**These are agreed, not proposed. Implement them; do not re-litigate them.**

**D1 — the 146 spells take four tradition prefixes:** `Spoiling:`, `Bone:`,
`Living Fire:`, `Nature:`. **Precedent, in this catalog, from two earlier
imports:** New West's seven `Clouds of ...` traditions and Underseas' `Spellsong`
and `Dolphin` were all namespaced the same way, and **378 of the 773 spell names
carry a `Tradition: Name` prefix**. Where a prefixed row retells an established
spell, point `same_spell_as` at the established row and let each keep **its own
level and PPE** — the column exists for exactly this, and ten rows already use
it. **No existing row changes value**, so nothing a live character can cast moves
under them.

**D2 — the five "disagreements" need no ruling**, and fall out of D1. Each
becomes its own tradition row at the level this book prints, linked by
`same_spell_as`. `variant_note` is **not** the mechanism here: it records what an
older book prints *instead*, and these are not competing readings of one row.

**D3 — every imported creature OMITS `xp_table` and takes the house
default.** (Written when all seven were in scope; **D4** has since filtered the
Rusalka, so it governs the six that remain. Nothing about the reasoning changes.) Settled 2026-09-12, and it replaces an earlier D3 that promised Nate
a list of six proposed ladders. **There is nothing to propose.** `xp_table` is
not a named reference — it is a literal cumulative-XP array in class
frontmatter, and `xpTableFor()` in `apps/character-creator/js/leveling.js`
falls back to `DEFAULT_XP_TABLE` when a class omits it. **All seven Dragon
Hatchling classes in this catalog use that default**, so the pointer the book
itself gives the Man-Wolf — *"the same experience table as the Dragon
Hatchling"* — resolves HERE to the default. The other six state no ladder, so
they land in the same place. **172 of 265 live classes already use it.** Zero
invention, and the "six need a decision before they can be imported" framing
turns out to have been too strong: they need no ladder at all.

**D4 — import SIX creatures; the Rusalka is filtered at import.** Amended
2026-09-12 on Nate's word; the first D4 imported all seven with Rusalka's caveat
merely noted.

**Import:** Domovoi, Leshii, Polevoi, Vodianoi, Spirit Wolf, Man-Wolf.

**Excluded, and why each:**

| entry | the book's words |
|---|---|
| **Rusalka** | *"not recommended as player characters ... best suited as a villain"* — **filtered by D4**, not by the book's tag, which does stat it as playable |
| Firebird | *"Not applicable as a player character."* — the book's own refusal |
| the eighteen demons | all tagged NPC Villain |
| Serpent Hound | a demon among demons; the one entry the book never tagged at all |

**The remaining six keep their GM-permission caveat in `extraction_notes`
verbatim** — the Domovoi/Leshii *95% abstain from adventure*, the Vodianoi
*"not suitable ... unless it is one of the rare good or anarchist ones"*.
Precedent for importing an optional-PC creature: **eight live classes already
carry "optional player character" language** — Vacuum Wasp, Termite Engineer,
Gargoyle, Dragon Ray, Rurlel Eelman among them.

**Do not read "six" as the bestiary reading's result.** The reading found
**seven** entries the book tags playable, and that stands unchanged in the
bestiary section above. Six is what D4 chooses to import. The two numbers answer
different questions and both are correct.

**D5 — the five-batch plan below is GREEN-LIT, in its stated order.** Spells,
then classes, then creatures, then gear, then vessels. The spells-before-classes
ordering is not a preference: a class citing a spell the catalog does not hold
fails its check.

## Extraction plan

**Green-lit by D5 on 2026-09-12, in this order.** This section is no longer a
proposal. Roughly 180 rows across several sessions; the `book-survey` skill
§7/§8 is the authority on how they are split, and its rule is one session per
book, booted from this file.

| # | batch | size | notes |
|---|---|---|---|
| 1 | the four spell traditions | **131 rows**, count verified | one batch per tradition, each carrying its own `Level N` headings as the authority. Spoiling and Nature are small enough to pair. **Names take the D1 prefixes**, and a retelling links with `same_spell_as` |
| 2 | the O.C.C.s | ~15 classes | `class-import`, one PR per two or three |
| 3 | the playable bestiary entries | **6 rows** | the book tags seven; **D4 filters the Rusalka**. None needs an `xp_table` — **D3** settles that all take the house default, which is what the book's own Man-Wolf pointer resolves to here |
| 4 | gear | ~20 | the bio-wizardry list at printed 107 needs its numbers read as dice expressions, not as printed |
| 5 | vessels | ~8 | same shape as Triax, Free Quebec and Spirit West |

**Left out, and why:** the eighteen demons and the Firebird — the demons all
tagged NPC Villain, the Firebird *"not applicable as a player character"*; the
setting and history chapters; the Steeds table until it is classified. The
**Serpent Hound** is left out as a demon among demons, noting that it is the one
entry the book never tagged.

**The order that matters:** spells before classes. Most of the eighteen classes
cast — the count was never measured and the ratio this line used to quote was
written against the wrong denominator, so take it as "most, verify per class" —
and a class citing a spell the catalog does not hold fails its check.

## Ledger

**Batch 1 of 5 has shipped.** The book stays at **`surveyed`** because the
queue's status vocabulary has no partial state, and calling it `imported` with
one batch of five in would be the worse lie.

| batch | what | status |
|---|---|---|
| 1 | **Spoiling Magic, 18 spells** | **SHIPPED** 2026-09-12, applied `--remote` before merge. Production 773 -> 791 spells |
| 1 | **Bone Magic, 59 spells** | **SHIPPED** 2026-09-12, applied `--remote` before merge. Production 791 -> 850 spells. All fourteen levels, no gaps |
| 1 | **Living Fire, 39 spells** | **SHIPPED** 2026-09-12, applied `--remote` before merge. Production 850 -> 889 spells. **7 retellings linked with `same_spell_as`** - 14 name matches, 6 rejected on mechanics |
| 1 | Nature Magic, ~30 spells | not started |
| 2 | the O.C.C.s, ~15 classes | not started |
| 3 | six playable creatures | not started |
| 4 | gear, ~20 rows | not started |
| 5 | vessels, 8 | not started |

**What batch 1 established, so the other three traditions do not re-derive it:**

- **D1's naming works and cost nothing.** All 18 were new; no collision, no
  `same_spell_as`, and **no existing row changed value**.
- **`tradition` is a second, separate thing from the name prefix**, and the
  schema says a new import must set it. `spoiling` is its own value because the
  book gates the tradition outright — *"Spoiling magic is exclusive to the
  various Witch O.C.C.s and no other"* (printed 76). The other three traditions
  get their own values for the same reason: one shared value would hand Fire
  magic to the Necromancer.
- **Three parse traps, all real properties of this text layer**, and the next
  tradition will hit them: a field's continuation can be a complete capitalised
  sentence (so a field runs to the next field LABEL, not to the first capital);
  **`P.P.E.Cost:13` appears with no spaces**, on five of these eighteen; and
  **`Note:` is not a field** — it appears mid-description as a prose aside, and
  listing it as one makes it the block's last field and swallows the cost.
- **A tradition's last spell block runs to the end of the band** unless it is
  given a terminator, and the heading that ends Spoiling Magic is
  `The Hidden` / `Witch O.C.C.` — **split across two lines**, the same trap
  this survey records for the Experience Tables. A phrase grep will not find it.
- **The book skips Level Nine here**, going Level Eight then Level Ten. Verified
  against every `Level N` heading in the band; nothing was dropped.

**Verify a data script by BUILDING a database**, not by reading an exit code: a
fresh worktree's local D1 is empty, so `d1-apply --local` fails with *"no such
table: spells"* and proves nothing. `node:sqlite` applies `db/schema.sql` in one
pass and then the script, and the script's own `got`/`want` rows can then be
checked rather than eyeballed.

**What batch 1b (Bone Magic, 59 spells) added, and both are traps the remaining
two traditions can still hit:**

- **A SUMMONING spell prints the summoned creature's whole stat block inside its
  description** — `Damage:`, `Horror Factor:`, `M.D.C.:` — and `Damage:` is
  also a spell-header field. Read as one, it made Summon Magot's cost swallow
  the thirteen lines between. **The header is the run of labels up to and
  INCLUDING the cost**, which is always last; a label after it is prose. A
  line-gap threshold cannot do this job: a real `Damage:` field runs ten lines
  in Accelerated Decay and the stray one sits thirteen lines down, so any
  threshold would be tuned to this book's luck.
- **A CROSS-BATCH ASSERTION IS AN ASSERTION ABOUT EXECUTION ORDER.** This script
  first asserted the Spoiling batch still held its 18 rows. That passes against
  production and **can never pass in a clean rebuild**: data scripts run in
  filename order, and `...-mr-bone-spells.sql` sorts **before**
  `...-mr-spoiling-spells.sql`, so on a fresh database the Spoiling rows do not
  exist yet. `regression.mjs` does exactly that rebuild, so it would have failed
  CI. **Each batch asserts its own rows and nothing else.**
- **The costs are not all numerals.** The book spells small ones as words
  ("Two points"), and Return from the Grave is *"Special; a total of 60 P.P.E.
  and 24 hit points are permanently spent"* — `ppe` takes the 60 and the note
  keeps the sentence, because the hit-point half is a second cost nothing
  models. 23 of the 59 carry a schedule.
- **Move the pinned spell count in `docs/operations.md` in the same PR.**
  `regression.mjs` rebuilds from every data script and compares; `smoke.mjs`
  does not, so a local smoke pass says nothing about it. Batch 1a learned this
  from a red CI run.

**Batch 1c (Living Fire, 39 spells) is the one D1 and D2 were argued over, and
it settled them in production:**

- **14 of the 39 share a name with an existing row**, which is where the
  withdrawn "five spells disagree on level" reading came from. **D2 is now
  demonstrated rather than argued.** This book's `Circle of Flame` is **level 3,
  "6 for Fire Sorcerers, 10 for other magic O.C.C.s"** - the LEVEL matches
  `Fire: Circle of Flame` (3) exactly, and the price for everyone else matches
  the bare `Circle of Flame` (10). There was never a disagreement; there was a
  two-tier price and a comparison against the wrong row.
- **THE LINKS MUST BE DECIDED BY `scripts/same-spell-lib.mjs`, NOT BY NAME**, and
  this batch learned it the expensive way. 14 of the 39 are name matches; the
  first version linked all of them, was applied `--remote`, and was then refused
  by CI - `regression.mjs` runs that library over every link on a clean rebuild
  and it **rejects 6 of the 14**. In this repo `same_spell_as` asserts THE SAME
  SPELL at its own level and cost; a pair disagreeing on mechanics is two spells
  sharing a name, exactly as the library's own header records for the
  Ocean/Water pairs. **7 links survive.** The six rejected are now named in
  `regression.mjs`'s `mustNotLink` list so nobody re-links them from the name.
- **The repo already shipped the judgement** (BOOK-INGEST-AUDIT F26) and a
  hand-rolled name match was used instead. Before inventing a comparison, look
  for the one that exists.
- **Two of the fourteen are judgement, not a name match**, and both are written
  into the script: `Fire Fists` is linked to `Fire Fist` (Palladium Fantasy) -
  same magic, level 3/cost 8/M.D. both hands here against level 6/cost 15/S.D.C.
  one fist there - and **`Fumigate: Insects` is deliberately NOT linked**, though
  a normaliser that strips any `Word: ` prefix matches it to
  `Metamorphosis: Insect`. One drives insects out of a building, the other turns
  the caster into one. **The same normaliser will offer that false positive
  again.**
- **`tradition` is `living-fire`, the first hyphenated value here, and
  deliberately not `fire`:** the catalog's `Fire:` family are WARLOCK spells
  carrying `tradition = 'warlock'`, so `fire` would assert these are the same
  tradition. They are not.
- **The book jumps Level Nine to Level Twelve**, no Ten or Eleven - the same
  shape as Spoiling Magic having no Level Nine. Verified against every heading.
- **VERIFY AGAINST A FULL REBUILD, not just the sibling batches.** A script that
  links a retelling asserts the established row EXISTS, and those rows arrive
  from the ordinary catalog scripts - so a database holding only this book's
  scripts fails that assertion for the wrong reason, and a dangling link looks
  identical to it. Replaying **all 581** prior data scripts into `node:sqlite`
  takes seconds and applied with **zero** statement failures.
