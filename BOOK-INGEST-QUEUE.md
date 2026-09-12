# Book-ingestion batch — queue, opened 2026-08-28

Seven books handed over on 2026-08-28, cached in one kickoff session. This file
is the cross-session state: **one session per book** from here, each reading
this file first and updating it last. Deferred code changes go in
`BOOK-INGEST-AUDIT.md`, not here.

Slugs, offsets and printed page counts below are recorded in
`scripts/books.json`, which is the authority the tooling reads. This table is
the human view of the same thing plus the import status.

## The books

| slug | book | PDF pages | layer | printed | offset | status |
|---|---|---|---|---|---|---|
| `triax` | Rifts WB 5: Triax and the NGR | 225 | SCAN (OCR) | 224 — corrected 2026-09-07, see below | **+0** | **imported** |
| `underseas` | Rifts WB 7: Underseas | 216 | SCAN (OCR) | 214 | **+0 / -1 split** | **imported** |
| `new-west` | Rifts WB 14: New West | 226 | text layer | 224 | +1 | **imported** |
| `spirit-west` | Rifts WB 15: Spirit West | 210 | text layer | 208 | +1 | **imported** |
| `mystic-russia` | Rifts WB 18: Mystic Russia | 178 | text layer | 176 | +1 | **surveyed** |
| `free-quebec` | Rifts WB 22: Free Quebec | 194 | text layer | 192 | +1 | **imported** |
| `phase-world` | Rifts DB 2: Phase World | 209 | SCAN (OCR) | 208 | **+0** | **imported** |

Status is `cached` -> `surveyed` -> `imported`. `phase-world` is **imported** as
of 2026-08-31: surveyed on 2026-08-30, then shipped in ten category batches,
and all THIRTY-FOUR of its playable classes are in. It also passed through a
fourth state the earlier sessions did not need - `importing`, for a book
shipping in batches across many sessions. **That state is empty again as of
2026-09-08**, `underseas` having left it; it was NOT empty while this sentence
said it was, from the day `underseas` entered it. The
survey at `apps/character-creator/docs/surveys/phase-world.md` remains the
record of what went in and what was deliberately left; its ledger is the
authority. The other six books are cache-only: the kickoff session caches and
registers, by design.

### `phase-world` progress, 2026-08-31

Seventeen PRs - eleven carrying data, each applied `--remote` before merging, and
six carrying survey, docs or a correction. Catalog totals moved 336 -> 345 skills,
975 -> 1024 gear, 101 -> 116 psionic powers, 126 -> 160 classes.

| category | in | left |
|---|---|---|
| skills | **9** - 7 new plus 2 the CCW classes turned up (Fighter Combat: Basic and Elite, printed 151) | none known; the book collects its new skills on printed 52-53 and 150-151 and both were read whole |
| re-citations | **8** rows moved off the phantom `Rifts Skill List` onto printed 52-53 and 150-151, taking it from 48 untraceable rows to 40 | the other 40, which are not this book's |
| gear | **47** - 43 from printed 114-129, every number read off a 200 dpi render, plus four the class entries themselves state. Three of the four are real rows rather than stubs: the Steelcloth Robes (A.R. 12, 90 M.D.C., printed 27) and the Steelcloth Robes and Jumpsuit (A.R. 19, 40 M.D.C., printed 29) are named AND statted inside their own class entries, which is more than the gear chapter gives some of its own rows. The two STUBS are the Plasma Hand Cannon, which appears exactly once in the whole book with its 2D6x10 M.D. and nothing else, and the Meditation Chip, which the two phase O.C.C.s carry and the book never stats | none in that range |
| classes | **34** of 34 - the book is complete. The CCW, printed 56-70: four O.C.C.s, the noro and its two O.C.C.s, Space Wolfen, Wolfen Quatoria, Catyr, Seljuk. The Transgalactic Empire, printed 73-84: Kreeghor, Machine People, Silhouette, Imperial Legionnaire, Imperial Security Agent, Freedom Fighter. The five spacefaring trades, printed 38-43: Spacer, Galactic Tracer, Space Pirate, Runner, Colonist. Two races and the Naruni enforcer, printed 35-38 and 46-48: Draconid, Phantom, Naruni Repo-Bot. The Pleasurer and the two playable hive-spawn, printed 88-89 and 92-94: Pleasurer, Vacuum Wasp, Termite Engineer. The four Prometheans, printed 25-29: First Stage Promethean, Promethean Phase Adept, Promethean Time Master, Phase Mystic. The two Cosmo-Knights, printed 99-104: Cosmo-Knight and Fallen Cosmo-Knight | **none** - every playable class the book defines is in |
| psionic powers | **15** - the Phase Powers of printed 32-35, in a new `Phase` category. The book calls them "a variation on psionic abilities... activated by using I.S.P.", and each prints Range, Duration, I.S.P. and a description - the exact column set the table holds | none; the book has no other power list |
| spells | **0** | the book defines **zero**, checked by stat-block scan rather than assumed. The Promethean Time Master's temporal magic is from Rifts England, which this catalog does not hold |

**Batch 8 added no skills and no gear, and that is the entry's own doing rather
than an omission.** None of the three states a `Money:` line, a
`Standard Equipment:` line or a Cybernetics line - grepped across the whole
Star Hives chapter, printed 88 to 95, and there is not one of any of them on
any of the five entries there, playable or NPC. The Termite Engineer's Chitin
Molding, the one percentage in the batch with no catalog row behind it, is
deliberately NOT made a skills row: the book defines it inside one race's
R.C.C. Skills line and nowhere else, and a skills row would offer it to every
class granting whatever category it was filed under. It is a natural ability
carrying both of its numbers instead.

**What is deliberately not imported, and will not be by a later batch either:**
the book's 25 vessels - 6 power armor and robots, 5 tanks, 14 starships and
shuttles, printed 130-149 and 157-173. `gear` holds one `mdc`, one `damage`, one
`range` and one `payload`; a vessel stat block here has M.D.C. by location,
five to eight numbered weapon systems each with four stats of its own, crew and
passenger complements, speed in three regimes and FTL range in light years per
hour. Keeping one weapon out of eight and dropping the rest is worse than not
storing it, because the row would then read as complete. Filed as
`BOOK-INGEST-AUDIT.md` F3, which also records that this is not new with this
book - the catalog's existing robot rows lose the same data silently.

Also out, on the book's own say-so: the **12 entries it names but does not make
playable** - seven labelled NPC or GM material in its own Contents, one labelled
so in its section heading, three that are lore or a cross-reference or the
alien-race generator, and the Dominator, which has no experience ladder and no
O.C.C. skills. The Experience Tables on printed 183 are the authority for that
line; see the survey.

That count was 11 until this batch reached the Transgalactic Empire. The **Royal
Kreeghor** was surveyed as playable and is not: the heading on printed 74 reads
*Royal Kreeghor R.C.C. / NPC Villains*, the entry ends "not intended to be
player-characters", and p.183 gives it no ladder. The Contents does not label it,
and the survey read the Contents. It is the only entry in the book where the
heading and the Contents disagree about that.

Ten findings have come out of this book - F2 through F11 in
`BOOK-INGEST-AUDIT.md`. None was implemented, per the standing constraint. F5 is
`attribute_dice` having no way to say an attribute DOES NOT EXIST: the Machine
People print "P.E. N/A" and `app.js` falls back to `3d6`, so the sheet shows a
constitution the book denies. F6 is `occ_related_skills` having no way to state
a per-category MINIMUM: both Empire O.C.C.s require at least two of their eight
related picks from Espionage and two from Rogue, and the app offers all eight
freely. F7 is the save list being SIXTEEN FIXED FIELDS: the Spacer's whole
mechanical grant is "+2 vs explosive decompression and other space dangers",
there is no environmental save in `SAVE_FIELDS`, and the near-miss that suggests
itself - `toxins_poisons` - would grant a real resistance to venom the book
never gave. F8 is `attribute_dice` SILENTLY DISCARDING A FIXED VALUE: the Naruni
Repo-Bot's chassis has "a P.S. of 50, P.P. 26", `rollAttribute` in `js/dice.js`
parses only `NdM` forms, and anything else falls through to `3d6` with the
notation rewritten to match - measured, `rollAttribute("50")` returns 9 and
reports `"3d6"`. It is F5's neighbour and worse: F5 is a class that cannot say
an attribute does not exist, F8 is a class that says the attribute is 50 and is
not heard. A sweep of all 148 published classes found one already carrying it,
the Holy Terror's `PS: "50"` from Wormwood, which has had a human's strength
since it was imported with every check calling it ready. The Repo-Bot does not
write it; both figures are prose in a natural ability. F9 is a cross-category
`only` pick LOSING THE PERCENTAGE PRINTED BESIDE IT: both playable hive-spawn
print "Rogue: Prowl only (+5%)", the catalog files Prowl under Physical, and
`categoryAllows` admits the skill while `categoryBonus` - which keys on the
skill's real category, deliberately and for a good reason - drops the +5%. The
picker still shows the player the +5%, so the wizard promises what the sheet
does not give. A sweep of every published class found exactly three rows in
this shape, one of them the Phaeton Juicer, so it did not arrive with this
book. F10 is a RACE AND AN O.C.C. THAT ARE BOTH PSYCHIC KEEPING ONLY ONE
PSIONICS BLOCK: `combineClasses` merges skills, sums bonuses and concatenates
abilities, then CHOOSES `psionics` by whichever tier is strictly higher, so a
tie goes to the race and the occupation's granted powers, starting picks,
categories and whole level schedule are discarded. Measured on all 361
race/occupation pairs where both state psionics - 93 discard a block that had
picks to lose, across 17 O.C.C.s. Two of this book's own shipped that way in
#409: `noro` and `noro-psychic` are both major, so the twelve powers and the
schedule that `fix-noro-psionic-schedules.sql` corrected in #411 have never
composed. The Promethean Phase Adept is the third, and its tier is not the
lever - master is the top of the ladder, the race holds it, and the comparison
is strict.

F11 is the LAST of them and it is F10's mechanism on four more fields. The
Cosmo-Knight is a transformation rather than a trade: its attribute line says to
take the HIGHER of its dice and the character's original race's, its M.D.C. and
P.P.E. are the new body's, and its O.C.C. Skills line says the skills of the past
life are lost and the character is reborn. `combineClasses` gives the RACE
precedence on `attribute_dice` and on every pool base - the occupation's value is
used only where the race states none, so nothing is ever compared - and it UNIONS
the two skill lists, so nothing can be replaced either. Measured against all 57
published R.C.C.s: the class's own dice survive on 3, its M.D.C. is discarded on
36, its P.P.E. on 50, and 37 races carry between 1 and 19 named skills through the
transformation. Exactly ONE race of 57 composes it correctly in all four places,
and only by stating nothing in any of them. A kreeghor cosmo-knight comes out with
P.S. 3d6+10 where the class prints 3d6+32. The figures are stored anyway, because
a character with no race then gets them and omitting them would be wrong in 57
cases rather than 54. It is NOT F5 or F8, which are about what one
`attribute_dice` cell may contain; this is about what happens to two cells that
both exist.

**What batch 9 deliberately did not import.** The Promethean Time Master's
TEMPORAL MAGIC: it learns two temporal spells plus two normal ones at first
level and one of each per level after, and only the normal half is granted. The
catalog holds 607 spells and not one is temporal magic - zero rows cite Rifts
England, and the five time-flavoured spells it does hold are ordinary
invocations from the Book of Magic and Palladium Fantasy. Granting a note with
no gate would have offered the whole catalog for a pick the book restricts to a
list this machine does not have, which is F7's shape; under-granting and saying
so at the table is the smaller error. Also out: the First Stage Promethean's
rule that up to four of its fourteen related picks may be spent on phase powers
or temporal spells INSTEAD of skills - a skill slot traded for a catalog entry
of another kind is not a shape `occ_related_skills` has - and the NPC Second
Stage Promethean of printed 31-35, which the book labels Non-Player Characters
in its own heading and says outright is "unfit as player characters".
F5 has also gained a second occurrence: the Pleasurer prints "P.B. N/A", and
unlike the Machine People's P.E. it is not moot - a shapeshifter whose whole
trade is appearance is shown a rolled beauty score the book denies it.
F3 has since gained a second occurrence: the Noro Mystic Warrior is issued a
suit of psionic power armour as standard equipment, and that suit is one of the
25 vessels the finding excludes, so the class ships without the one item its own
book says it starts with. That is a sharper cost than a GM being unable to look
a starship up.

**A third correction, and it is a different mistake from the first two.**
`fix-galactic-tracer-rogue-note.sql` corrects two claims PR #413 shipped about
this book's +6% Rogue bonus - that the figure appears twice on printed 40, and
that the book uses it nowhere else. It appears once, and the book prints the
same +6% for the Noro Mystic Warrior on printed 64 and for the Pleasurer on
printed 89; all three store 6, so the catalog was contradicting the note when it
was written. No number moved and no character changed. The reason to fix it is
that the next session reading the tracer would take a +6% elsewhere in this book
for an OCR error to be normalised to +5, which is exactly the reading the
Pleasurer import had to talk itself out of. **Tally the cache before writing
"the only" into a note** - `grep -ohE '\(\+[0-9]+%\)' | sort | uniq -c` over
the whole book answers it and costs nothing.

**Batch 10 closed the book, and it added no skills, no gear and no spells** -
the same shape as batch 8, and for the same reason. Neither cosmo-knight entry
prints a `Money:` line: grepped across printed 99 to 104, there is not one, and
the Cosmo-Knight's Standard Equipment is prose naming no item the catalog could
hold. So both classes ship with no `starting_money` and no `equipment_starting`,
and `class-check --field-sources` reports outright that there are no free-text
fields to trace - an absence that is the entry's own doing rather than a gap in
the reading. Neither needed a `CORE_SDC_BY_CLASS` entry either: `withCorePools`
returns early for a class stating an `mdc_base`, and both state one.

**What batch 10 could not import, beyond F11.** The Fallen Knight's magic-or-
psionics option is described and not granted: the book points at the ley line
walker and the mind melter for progression, withholds their special abilities,
and adds two more classes from Conversion Books this catalog does not hold. A
`magic` or `psionics` block would have to replicate one of two other classes'
whole ladders and then choose between them at creation. Granting less and saying
so is the Time Master's precedent from batch 9, and both named classes are in
this catalog for a player to read. The blanket -20% also stops twice: at the
SECONDARY skills, because `parser.js` rejects a bonus on a secondary category
outright - deliberately, on the reasoning that a book's parenthetical percentage
applies to related selections only, which was true of every class before this
one - and at Weapon Proficiencies, whose catalog rows are base 0 with no
percentage to reduce. Both are in the class's notes for a GM to apply.

**And batch 10 changed one line of code, which is the only code this book
changed.** `regression.mjs` required every language choice group to carry a
bonus GREATER than zero. A fallen knight's is exactly zero - the Cosmo-Knight's
+20% less this entry's -20% - and the pick then resolves at the catalog's own
50% +5%/level, which is the right answer. The check's own comment says it exists
to catch a bonus LOST in a rewrite, and a lost bonus arrives as `undefined`
rather than as 0, so the comparison moved to `>= 0` and still catches every case
it was built for. It is a test rather than the app, the schema, a validator or a
generator, and the zero is written out explicitly in the class so an absent
bonus and a computed one still read differently.


**Two corrections have been shipped against classes this batch already
imported**, both the same mistake: an extraction note asserting the app could not
express something, written from memory of `frontmatter.md` rather than from the
code. `fix-noro-mind-control-saves.sql` restored a save key that five published
classes were already using. `fix-noro-psionic-schedules.sql` restored a per-entry
`categories` on the psionic power schedule, which had been denying the noro
psychic the Super power its book grants and letting the mystic warrior take eight
Super powers where the book grants two. Nothing failed either time; both classes
parsed, validated, composed and passed the full regression run. **Grep `js/` and
`functions/` before writing "the app cannot hold this" into a note** - that
sentence is durable and the next session believes it.

**`triax` and `new-west` were already registry stubs** with `source_pdf: null` —
one gear row cites Triax, one skill row cites New West. Their entries were
filled in, not created, and their existing `aliases` were kept: those aliases
are the live vocabulary those two rows resolve through.

**Those two rows still cannot be traced, and caching did not fix it.** Both cite
their book with no page number at all — `gear.Triax Pump Weapon` says
`Triax & The NGR`, `skills.W.P. Rope` says `Rifts New West`. Caching moved them
out of `not-cached` and straight into `no-page-range`, which is the same
untraceable in a different bucket. **Give each a page range in its own book's
session**, now that there is a book to find it in.

**And for one of them the page will not be found, because the skill is not in
the book.** With `new-west` cached, `drift-check`'s citation check can now say
that the name `W.P. Rope` appears nowhere in its 226 pages. What New West
actually prints, on printed 71, is:

- a skill called **Roping** — a regular skill, not a Weapon Proficiency, and the
  catalog already holds it separately as `Roping` (Cowboy, 20%+5%, cited to RUE
  p.302-303).
- a new-W.P. list of exactly three: **W.P. Bola**, **W.P. Snapshooting
  Specialty**, **W.P. Whip**. Of those the catalog holds only `W.P. Whip`, cited
  to RUE. **Bola and Snapshooting Specialty are missing.**

So `W.P. Rope` (Weapon Proficiencies, base 0, cited to this book) looks like a
row nothing in the book supports, sitting beside two the book defines and the
catalog lacks. **This is the New West session's first task, and it is a
judgement call, not a cleanup**: characters reference skills by name, so
retiring or merging one belongs to the catalog editor's duplicate tools, which
write redirects and rewrite characters. SQL cannot do it safely — the same
reasoning `add-juicer-uprising-skills.sql` records for Interrogation Techniques.
Establish what the row should be before touching it.

### `triax` survey, 2026-09-06

Surveyed, nothing imported yet. The survey is
`apps/character-creator/docs/surveys/triax.md` and it is what the next session
boots from. Four things it established that change what the import will cost:

**The book ships TWO class authorities and they agree exactly.** The O.C.C.
roster on printed 156 and the Experience Tables on printed 224 name the same
sixteen O.C.C.s. Fourteen ladder headings cover those sixteen because two ladders
are shared — one by the Infantry Soldier and the Police, one by the
Communications Officer, the Medic and the Field Mechanic. Printed 224 was read as
a 200 dpi render, not off the OCR, which is what established that; the text layer
welds its five columns.

**Twenty-one playable classes, from twenty entries.** Sixteen O.C.C.s plus four
gargoyle R.C.C. entries, one of which — the Gargoyle and Gurgoyle — states two
creatures separately at every point that matters and splits into two rows. The
back cover's "20 new O.C.C.s" is marketing copy and counts neither the split nor
the R.C.C.s; do not use it as an authority.

**The four R.C.C.s carry NO ladder on printed 224 and are still playable.** Each
says player characters use another class's table — the psi-stalker's, the
dragon's, the Dog Pack's — and they sit under a heading that calls them optional
player characters. This is the Royal Kreeghor check run from the other side: an
absent ladder is a question, not a verdict, and reading the entry answered it.
`M.O.M. Conversion` (printed 168-170) is the one that really is not a class — a
process description, absent from both authorities, with no attribute, skill or
equipment line.

**The skills diff came back near-empty, and that is the useful part.** Printed 155
prints seven new skills and the catalog already holds all seven; RUE defines six
of them on its own skill list, so they are false gaps rather than imports. Only
`Language: Gargoyle` and `Language: Brodkil` are new rows. `Streetwise: Drugs`
is a **re-citation** — it currently cites the phantom `Rifts Skill List`, and
Triax printed 155 is the earliest real printing on this machine, which takes that
book from 43 untraceable rows to 42.

**One trap worth carrying forward.** `Horsemanship: Exotic Animals` is uncited in
the catalog and Triax prints `30% +4%` beside the catalog's `+5%`, which reads
exactly like an error to correct. It is not: RUE printed 302 gives `30%/20% +5%`
and RUE is the later book, so the catalog is already right and Triax's figure is
the variant. Correcting it would have moved a value every published class can
reach.

The vessel exclusion is larger here than in any book this batch has taken —
about **107 of the 222 printed pages** are power armor, robots, drones, borg
models, combat vehicles and gargoyle machines, all `BOOK-INGEST-AUDIT.md` F3.
No new finding was filed; the book needs no mechanic F3 through F11 do not
already name.

**`printed_pages` in `scripts/books.json` is 222 and the book's last folio is
224.** Printed 223 is the map and printed 224 is the Experience Tables, which
carries its folio plainly. Nothing is broken by it today — the gate wants the
cache to hold at least `printed_pages` pages and it holds 225 — but a row cited
to p.224 would cite a page the registry thinks does not exist. **Correct it in
the first data PR.** The offset was re-checked at the back of the book rather
than trusted from the whole-book vote, on the `underseas` precedent: `p222`
carries folio 222 and `p224` carries 224, so +0 is constant end to end.

`triax-pump-weapon` is still the one untraceable row and it is now understood:
the book prints two pump weapons, the TX-5 Pump Pistol on printed 143 and the
TX-16 Pump Rifle on printed 144, plus the pump-round costs on 141. The stub is
referenced by the twelve Warlock classes, so it gets a page range and the two
real rows get imported — **it is not retired or merged in SQL**, for the same
reason `W.P. Rope` is not.

### `triax` batch 1 — the NGR Army, 2026-09-06 (PR #776)

Three of the twenty-one playable classes: Infantry Soldier, Communications
Officer, Medic/Medical Officer, printed 156-160. Catalog totals moved 169 ->
**172** classes, 344 -> **346** skills, 1021 -> **1024** gear. Applied
`--remote` before the PR; production read back at all three figures, and
`regression.mjs` produces the same three from a database built from nothing.

**The batch found two skills the survey did not, and the reason generalises.**
All three classes grant `Literacy: Euro` and `Language: Euro` and the catalog
held neither. The survey missed them because it derived its skills diff from
printed 155, the book's own *New Skills* heading — and Euro is not new, it is
one of the nine major languages of Rifts, named on RUE printed 304. **A class
can grant a skill the catalog lacks without the book calling it new**, so the
remaining batches should expect the same and find them with `class-check
--remote` rather than another read of printed 155. Both rows were added cited
to **RUE p.302-304, not to this book**, at the catalog's values rather than
RUE's printed `+3%`.

**A book-vs-book disagreement is now recorded and NOT yet settled.** Printed 155
lists Gargoyle, Brodkil and Demongogian as three languages; RUE printed 304 says
Demongogian **is** the language of gargoyles and brodkil, which would make two of
the three the row the catalog already holds. This book's own gargoyle R.C.C.s
grant *speak Gargoyle* by name and never mention Demongogian, so it is not a
spelling difference. **The gargoyle batch settles it from printed 198-202.**

No finding was filed. This batch needed no mechanic `BOOK-INGEST-AUDIT.md`
F1-F22 do not already name, and the only code it touched is three
`CORE_SDC_BY_CLASS` entries in `js/compose.js` — per-class data the smoke test
requires of any class printing no S.D.C. formula, which every class import
adds.

## What the kickoff session established

**The page counts in the file listing were wrong.** It reported Triax at 734
pages, Underseas at 689 and Phase World at 640 — three to four times their real
length. pymupdf reads them as 225, 216 and 209. Believe pymupdf; this is the
same disagreement `ju` showed in the other direction (listing 120, pymupdf 162).

**Three of the seven are scans.** They are also the three large files (60-70MB
against 10-13MB), and the correlation held exactly. The four text-layer books
cached in seconds; the scans needed ~650 pages of Tesseract.

**`triax` and `phase-world` both have a ZERO offset** — printed N is cache
`pNNN`, and `read-columns.py` **N**. That makes **four** zero-offset books in
the catalog, after `potm` and `ww`. Both verified by folio rather than assumed:
triax 177 pages agree at +0 against 1, phase-world 166 against 3 in a single
unbroken region. The skill's warning applies to both — a zero offset leaves no
discrepancy to explain when a page reads wrong, which is why it cost a wrong
page read on the first Godling attempt in `potm`.

**This line said `read-columns.py N+1` until 2026-08-30, and it was wrong.** The
two numbers come from the same place, so there is nothing to convert between:
`ocr-book.py` writes cache `pNNN` from `doc[pno - 1]` and `read-columns.py`
reads `doc[n - 1]`, so **cache `pN` IS `read-columns.py N`, in every book**. The
`page_offset` then relates that shared number to the printed folio and nothing
else. `ww` — the other zero-offset book, registered by an earlier session — had
this right all along, and the wrong version contradicted it in the same file.

The mistake was reading it off `book-survey` 0d's table, where "zero-offset
book" means printed N is *pymupdf index* N (`potm`, whose `page_offset` is 1),
not `page_offset: 0`. Two different senses of "zero offset", one page apart —
which is the trap that section is thirty lines about, arrived at from the other
side. **Derive the number from the two scripts, not from prose about a third
book.**

**Zero offset is no longer the oddity the skill describes**, and only `pf` and
`underseas` split. **It is not the common case either — `+1` is, by a wide
margin. Read the registry; do not assume from either claim.**

**Corrected 2026-09-04.** This paragraph read *"Four of fifteen cached books
have one"* — wrong in both numbers — and called assuming `+1` *"a coin-flip"*,
which understated `+1` by roughly three to one. **No replacement figures are
given on purpose**: a ratio here moves every time a book is cached, and it went
stale unnoticed once already. `scripts/books.json` is the one place that cannot.
`SKILL-AUDIT` `F43`.

**`underseas` is the second split-offset book in the catalog, after `pf`, and
the first with a NEGATIVE offset.** Printed 1-130 sit at +0; printed 132-216 sit
at **-1**. The vote is 101 to 74, which is close enough that a single number
looks defensible and is wrong either way: `ocr-book.py` measured -1 for the
whole book and the mid-run smoke check measured +0, and each is right about half
of it. Recorded as `page_offset: -1` with an exception for `printed_through:
130`.

**The cause is a missing page: printed 131 is not in the PDF.** File `p130`
carries folio 130 and ends mid weapons stat block; `p131` carries folio 132 and
opens mid-sentence. This is a defect in the source scan, not in the cache — no
re-run fixes it, and the page is simply not available to cite. **Anything the
Underseas session finds that straddles printed 130-132 has a hole in the middle
of it**, so check that boundary before trusting a stat block read near it.
Printed 131 resolves to `p130` under the fall-through rule, which is the wrong
page; that is deliberate, on the `pf` precedent of sending an ambiguous boundary
page to the fuller of the two candidates.

**The other four measured +1 and were verified the same way** — 198/3,
190/2, 157/0 and 165/4 pages agreeing. The handful of disagreements are all
contents and index pages, which print many numbers and defeat a
"short line of digits is the folio" heuristic. None is a real offset conflict.

## The `ju` cache rebuild — done, and what it found

`.cache/books/ju/txt/` was raw `page.get_text()` with columns welded across the
gutter on 148 of 162 pages (INGESTION-AUDIT F2). Rebuilt 2026-08-28 with
`--force`; all 162 pages changed. Re-verification against the corrected cache:

- **16 classes** cite the book. All parse clean (0 errors, 0 warnings) and all
  resolve onto their cited pages.
- **All 16 `starting_money` values confirmed**, including the four the book
  states in prose rather than on a `Money:` line. The two figures fixed in
  PR #280 (Gambler `6d6x10`, Wannabe `5d6x100`) both match the book.
- **42 gear rows confirmed** — every `cost` and `mdc` present on the cited
  pages. The three that did not match a digit string are prices the book writes
  in words: 1.1, 3.2 and 3.6 million credits.
- **All 12 of the book's new skills accounted for** — the 4 imported plus the 8
  RUE absorbed, each matched by value as well as name (`Technical: Juicer Lore`
  is the catalog's `Lore: Juicers`, RUE p.302-303).
- **One real error found**, and it is column-weld damage:
  `Juicer Uprising p.66 lists 30%+4%` sat on **Gambling (Standard)**, which the
  book gives as 30%+5% — identical to RUE, no disagreement at all. The 30%+4%
  belongs to **Gambling (Dirty Tricks)**, which RUE gives as 20%+4%. In the old
  cache that line sat in the right-hand column two thirds of a page above its
  own entry. Fixed by `zzzzz-fix-ju-gambling-notes.sql`.

The rebuild was worth doing and the yield was one row. That is the honest
figure; it is not an argument that the other caches are fine, and it is not an
argument that they are worth re-reading either.

## Per-book rules for the sessions that follow

- Survey first, diff second, extract last. `catalog-diff.mjs --remote` — local
  is stale.
- Read every class entry **to the end, onto the next page**. Both ju
  `starting_money` errors were page-break misses.
- Read tables as rendered images at 200 dpi. A text layer gives prose, not
  chart geometry.
- Data PRs merge as they go, applied `--remote` before merge. Nothing stacks.
- **A book does not get to start engineering work on its own — but `book-survey`
  §8 owns that rule now, in three tiers, and it is the copy that governs.**
  Import what the schema supports, note the drop in `extraction_notes`, file the
  gap in `BOOK-INGEST-AUDIT.md`, keep going.

**This bullet read *"No application code, schema, validator or generator changes
from a book"* until 2026-09-07, and it was false for the whole ten days it
stood.** Eleven book-session PRs edited `js/compose.js` because the smoke test
requires it of any class stating no S.D.C. formula, and on 2026-09-07 one book
produced a migration, three tables, a validator change and a change across six
files — all asked for, none of it a violation of anything. The absolute wording
is not restored; §8 carries the replacement, the PR numbers and the
`audit-premise-auditor` rule that took its place. **The batch sections below
this line are records and are unedited**, including the ones written while the
old wording stood.

### `triax` batch 2 — the NGR Armored Division, 2026-09-06 (PR #777)

Five more classes, printed 161-170: Cyborg Soldier, Field Mechanic, Power Armor
Commando, Robot Combat Pilot, Robot Soldier. **Eight of twenty-one now in.**
Catalog totals moved 172 -> **177** classes, 346 -> **353** skills, 1024 ->
**1025** gear. Applied `--remote` before the PR; production read back at all
three, and `regression.mjs` produces the same three from nothing.

**The seven new skills are `Robot Combat Elite:` rows, one per Triax machine**,
following the catalog's existing `Robot Combat Elite: Glitter Boy` and
`: SAMAS` rather than collapsing into the generic row. Collapsing would have
granted the Power Armor Commando ONE elite proficiency where its book grants
three. The machines themselves stay out under F3, and that is not a
contradiction: an elite row is a training proficiency, base 0, meaningful
whether or not the machine can be stored.

**F3 bites harder in this division than anywhere else in the batch so far**, and
in a new way. For the Army classes a vessel was equipment. Here it is the
character: the Cyborg Soldier's chassis, the Power Armor Commando's T-31 and
the Robot Soldier's robot body are all F3 vessels, so all three ship with no
`mdc_base` and take the core S.D.C. rule, which is a human's. Each says so in
its own `extraction_notes` and body. No new finding - this is F3 doing what F3
says.

**One finding filed: `BOOK-INGEST-AUDIT.md` F23.** The Robot Soldier is the only
published O.C.C. in the catalog granting NO skills at all, and both reasons are
the book's: printed 170 says its skills are the character's PREVIOUS O.C.C.'s,
frozen at the level held at conversion, and it grants up to three skill
CATEGORIES wholesale at a flat 38% rather than N skills from a list. Neither is
a shape the app has. What the book states in its own right - combat bonuses,
four saves, three extra attacks at levels 2, 6 and 12 - is stored; the rest is
in the class body for the GM.

**A reading worth carrying to the next batch**: three entries in this division
print a percentage with no plus sign or defer a weapon to another book. The
Field Mechanic's `Math: Advanced (10%)` is the sharp one - read as +10%, because
a fixed 10% would be worse than the untrained base, which no Palladium class
prints. Its laser torch and laser wand are deferred to Wilk's and are not
stubbed.

### `triax` batch 3 — the Intelligence Division and the police, 2026-09-06 (PR #778)

Three more classes, printed 171-174: Intelligence Officer, Intelligence
Commando, Police Officer. **Eleven of twenty-one now in**, which closes every
Military O.C.C. the book has. Catalog totals moved 177 -> **180** classes,
353 -> **355** skills, and gear did NOT move - the first batch of this book
needing no new gear row and no stub at all.

**The check caught a contradiction the reading had already talked itself into.**
Printed 174 restricts the Police O.C.C.'s Espionage picks to disguise, sniper,
tracking and wilderness survival, and prints "Wilderness: None" four lines
later. Wilderness Survival is a WILDERNESS-category skill here, and a
cross-category `only` is admitted solely when the class also lists that skill's
real category - so transcribing both lines literally left the skill granted and
**not takeable**, which `class-check` reports as `unreachable`. The draft's own
extraction note had asserted the opposite in as many words: that wilderness
survival was reachable through the Espionage line, *"which is what the book
means"*. It was not, and nothing but the check would have said so. Resolved by
listing Wilderness with `only: ["Wilderness Survival"]` at the Espionage line's
+10%.

**That is the second time in this book a `class-check` restriction warning has
found a real defect** - the first was the Medic's `Identify Plants & Fruits`,
which the catalog spells singular. Both fail OPEN. **Read the restrictions
section of every draft's report rather than skimming to `ready`.**

**No finding filed.** Nothing in this division needed a mechanic the app lacks.
Two more `Robot Combat Elite:` rows were added for the X-60 Flanker and the
X-500 Forager, in `add-ngr-additional-elite-skills.sql` - a SIBLING of the
armored-division file rather than an edit to it, since that one is a one-shot
already applied everywhere.

**One shape worth carrying forward:** three of these entries state a
related-skill FLOOR rather than a plain count - the Intelligence Officer's *two
rogue skills and three others* and the Commando's *two W.P.s and three others*
are five picks with a floor of two, not seven picks. Both are stored with
`minimums`. Expect the Gypsy entries to print the same shape.

### `triax` batch 4 — the Gypsy O.C.C.s, 2026-09-06 (PR #779)

Four more classes, printed 179-185: Gypsy Thief, Gypsy Wizard Thief, Gypsy Seer
and Gypsy - The Gifted. **Fifteen of twenty-one now in**, which closes every
O.C.C. this book has; the six that remain are the Euro-Juicer and the five
gargoyle R.C.C.s. Catalog totals moved 180 -> **184** classes and 355 -> **356**
skills, and gear did not move.

**The prediction at the end of batch 3 was wrong, and it is worth correcting
here rather than quietly.** That note said *"expect the Gypsy entries to print
the same shape"* - a related-skill FLOOR, stored with `minimums`. **None of the
four does.** Every Gypsy entry prints a plain count: six, five, four and four,
each with one more at levels three, six, nine and twelve. The floors were an
Intelligence Division habit, not a book-wide one.

**READ THE PERCENTAGES OFF A RENDER, NOT THE OCR - four skills in this section
print a FIXED percentage with no plus sign.** `Lore: Demons & Monsters (20%)`
and `Lore: Faeries (15%)` on both the Wizard Thief and the Seer,
`Play Musical Instrument: One of choice (10%)` on the Seer, and
`Identify Plants & Fruits (20%)` on the Gifted - every one of them beside
entries in the same list that DO carry a plus. The OCR reproduces the absence
faithfully, which is exactly why it could not settle the question: the same
engine that might have dropped the sign is the only witness. Three pages were
rendered at 200 dpi through pymupdf and read. All four are real, and all four
sit BELOW the catalog base for that skill - the musical instrument at 10
against a base of 35 - which is the tell. A class granting a skill below its
own catalog base looks like a transcription error and is not.

**`Language: Gypsy` is a new skill row and it is cited to TRIAX**, unlike the
two Euro rows batch 1 added, which went to RUE because Euro is a Rifts-wide
language RUE already names. The gypsy tongue is not: printed 179 describes it
and its dozen symbols, and nothing earlier on this machine prints it at all. It
is NOT one of the seven new skills printed 155 lists, which is why the survey's
skills diff never found it - a language named only inside the O.C.C. entries.

**The Gifted needed a shape nobody here had used, and `variants` was the wrong
guess.** Its psionic profile is ROLLED from a four-band percentile table, and
the bands differ in tier, I.S.P., counts, categories, ladders, saves and even
in whether the character gets O.C.C. Related Skills. `VARIANT_OVERRIDES` cannot
carry `psionics` - it carries `bonuses` and the pool bases and no more - but
`ABILITY_GRANTS` can, and `mergePsionics` returns an ability's block unchanged
when the class states none. So the class carries NO class-level psionics block
and the four bands are four named abilities under one `{ choose: 1 }`, each
with its own complete block. Verified by composing all four through the real
parser. **`BOOK-INGEST-AUDIT.md` F24** is filed for the one thing that still
does not fit: the related-skill count is four for a major psionic and zero for
a master, and neither an ability nor a variant can carry a skills block.

**A readback query got the class count wrong before the ledger did.** Counting
`status = 'published'` alone returns 185; the generic warlock is retired with
`deleted_at` and keeps its published status, so the live count needs
`AND deleted_at IS NULL` and is 184. `docs/operations.md` calls its row
*classes (published, live)* for exactly this reason. Production and a clean
rebuild agree at 184 - there is no drift here, only a query that was short a
clause.

### `triax` batch 5 — the Euro-Juicer, 2026-09-06 (PR #780)

One class, printed 175, under the book's own heading *Non-Military O.C.C.s*.
**Sixteen of twenty-one now in**; the five gargoyle R.C.C.s are all that remain.
Classes 184 -> **185**, skills and gear unmoved.

**THE ENTRY STATES NO MECHANICS AT ALL.** Printed 175 says, in full, that *"the
same creation considerations, conditions, skills, bonuses and penalties as
described in the Rifts RPG are applicable to the NGR/European Juicer - create the
character as usual."* No attribute line, no skill list, no bonuses, no equipment,
no money. It is on the printed 156 roster and has its own ladder on printed 224,
so it is playable by both authorities and was imported rather than left out.

**And the ladder is the Juicer's, reprinted** - 0-2,140 through 341,601-401,700,
read off a 190 dpi render of printed 224. That was the check on whether the
sentence above meant what it said, and it did. Nothing is stored from it; a Rifts
O.C.C. carries no `xp_table` here.

**So the row is a hand copy of `juicer`, and the copy was DIFFED rather than
trusted.** Both markdowns were parsed and compared block by block:
`hit_points_base`, `sdc_base`, `starting_money`, `bonuses`, `special_abilities`
and `equipment_starting` came back byte-identical, and the skill and restriction
blocks matched except where the draft intended otherwise. **The diff caught one
unintended divergence** - an abbreviated IRMSS description - which is the whole
argument for running it. Do this for any future copy.

**`BOOK-INGEST-AUDIT.md` F25** is filed for what remains: nothing records that
two rows must stay identical, so a correction to `juicer` will not reach this one.
Its proposal declines the general inheritance mechanism and takes only a
regression invariant.

**FOR THE GEAR BATCH: printed 175-178 is not in the survey's gear plan and holds
priced rows.** The JAEP programs carry market costs of 125,000, 85,000, 85,000 and
95,000 credits, and six designer drugs - boing-go, crash, euphie, psike-B, psike-E
and rush - carry per-dose costs from 20 to 200 credits. The survey's extraction
plan covers printed 34-38, 141-154, 205 and 210-214 and none of 175-178. Whoever
takes the gear batch should decide whether a chemical programme and a drug dose
are `gear` rows here; neither is a weapon or a suit of armour, and both have a
price and a described effect.

### `triax` batch 6 — the five gargoyle R.C.C.s, 2026-09-07 (PR #781)

Five classes, printed 197-202, under the book's own heading *Optional Player
Characters*: Gargoyle, Gurgoyle, Gargoyle Lord, Gargoyle Mage and Gargoylite.
**All twenty-one of this book's playable classes are now in.** Classes 185 ->
**190**, skills 356 -> **358**, gear unmoved at **1025**.

**The survey's two open questions about this section both resolved, and in
opposite directions.**

*The Gargoyle Mage's earth magic resolved cleanly.* The plan said to check
whether the catalog's warlock rows cover levels 1-3 before granting anything,
because a grant with no gate is the F7 shape the Time Master import refused.
Queried against production: the catalog holds exactly **29** `Earth:` spells at
levels 1-3 and all 29 are granted BY NAME. `spells_starting` is 0 - the mage
POSSESSES them rather than picking any, so a count would turn a grant into a
choice the book does not offer. The list will rot the same way the Gypsy
Gifted's healing powers do, and the row says so.

*The Gargoylite's ladder did NOT resolve, and it is still open.* Printed 202
says player characters use the Dog Pack's experience table. There is no row
named Dog Pack; the nearest is `dog-boy`. That is a question for RUE and NOT an
equivalence to assume from the names. It costs nothing today - a Rifts class
carries no `xp_table` here - and it would cost something the moment anything
reads a ladder for this class.

**"+3 on all saving throws" had to be written out as fourteen keys** on the
Lord, the Mage and the Gargoylite. `sheet.js` draws sixteen saves from a literal
list, so a blanket bonus appears nowhere unless it is stated against each one.
Two are excluded deliberately every time: `horror_factor`, which those entries
give their own +10 or +12, and `coma_death_pct`, which is a percentage rather
than a d20 bonus.

**The book writes attribute dice as "18+2D6" and `rollAttribute` parses
"2d6+18".** Same distribution, opposite order. Written the book's way round,
`class-check` rejects it as neither dice nor a fixed number and warns that the
roller would silently substitute 3d6 - which is exactly the F8 failure, caught
here by the check rather than in production. Every one of the five needed it.

**Two entries do NOT grant Language: Gargoyle and that is transcribed rather
than corrected.** The Mage's and the Gargoylite's skill lists name
Dragonese/Elven and Gobblely at 98% and stop, where the Gargoyle, Gurgoyle and
Lord all name Gargoyle as well. Both entries carry a Data Note saying other
information is the same as the gargoyle - but a skill LIST is information the
entry states in its own right, so the omission stands and is recorded in both
rows.

**No finding filed.** Nothing in this section needed a mechanic the app lacks
that was not already recorded: the flying speed, the conditional flight dodge,
the stone metamorphosis and the secondary-skill category exclusions are all
prose by existing rule, and each row says which and why.

### What is left on `triax` after the classes

The status above says `importing` rather than `imported` on purpose. Three
items from the survey's extraction plan are still open, and they are named here
rather than left to be inferred from a plan five PRs old:

1. **The gear pass, ~55 rows** - printed 34-38 (9 armour), 141-150 (~30 weapons
   and ammunition), 151-154 (optics, medical, computers, cybernetics), 205 (one
   gurgoyle armour) and 210-214 (15 gargoyle and Kittani weapons). **Plus
   printed 175-178, which the plan does not list**: the four JAEP programs with
   market costs and six designer drugs with per-dose costs. Recorded in batch
   5's note.
2. **Two re-citations**, neither done by any of the six class batches:
   `Streetwise: Drugs` to Triax printed 155, which takes `rifts-skill-list` from
   43 untraceable rows to 42; and `Horsemanship: Exotic Animals` to RUE printed
   302 with Triax's +4% in `variant_note`.
3. **One stub resolution** - `triax-pump-weapon`, this book's single `other` row
   in `source-coverage`, cited with no page range and also one of the gear
   stubs. Finishing it moves two lines at once.

**The registry correction is DONE** and is the one plan item this batch closed
outside its own scope: `printed_pages` 222 -> 224 in `scripts/books.json`. The
survey asked for it in the book's FIRST data PR and four data PRs went by
without it. Nothing broke - `printed_pages` gates the citation check by
requiring the cache to hold at least that many pages, and the cache holds 225 -
but a row cited to p.224 would have been citing a page the registry believed the
book did not have, and the Euro-Juicer's notes cite that page.

### `triax` loose ends, 2026-09-07 (PR #782)

No classes. The three small plan items the six class batches all skipped, plus
one note that had gone false.

**The two re-citations landed and both predictions held.** `Streetwise: Drugs`
was cited to the phantom *Rifts Skill List*; Triax printed 155 prints it under
the book's own New Skills section, and re-citing it takes that phantom book from
43 untraceable rows to **42**, exactly as the survey said it would.
`Horsemanship: Exotic Animals` had NO source_book at all; RUE printed 302 lists
it as *(30%/20%+5%)*, which is where the catalog's 30 +5 comes from, and Triax
printed 155 reprints it at *30% +4%*. RUE is the later book, so the citation goes
to RUE and the Triax figure is recorded in the note rather than changing the row.

**A premise in the survey's own plan was wrong, and it is worth naming.** The
plan said to put Triax's +4% in `variant_note`. **There is no `variant_note`
column** - `skills` has `id, name, category, base, per_level, systems, source,
source_book, note, bonuses, level_bonuses, base_formula`. It went in `note`.

**`triax-pump-weapon` has a page range and is STILL A STUB, deliberately.** It
now cites printed 143-144, which covers both weapons the book describes - the
TX-5 Pump Pistol and the TX-16 Pump Rifle - so this book reads **39 traceable /
0 other**. The description keeps its STUB marker because the row still has no
stats and the gear importer keys on that marker. **The row is a PLACEHOLDER
standing for two weapons**, referenced by the ten Warlock classes; replacing it
with two real rows and a choice group is gear-batch work.

**The Gargoylite's ladder is SETTLED and its class note is corrected.** Printed
202 borrows the *Dog Pack's* experience table and no catalog row carries that
name. RUE answers it: RUE names the class *"Dog Boys (Coalition Dog Pack -
Mutant Canines)"*, and its contents page files *Coalition Dog Pack* as a section
INSIDE the Dog Boy O.C.C. - the pack is the unit, the Dog Boy is the class. The
borrowed ladder is `dog-boy`'s, which RUE printed 295 heads *"CS Grunt & Dog
Boys"* and shares with `coalition-grunt`. Both rows are published.

The class note said the question was open. **A note recording a resolved
question as open is durable and the next session believes it**, which is the
shape `class-import` warns about, so it was rewritten rather than left. The
survey's own paragraph is left standing with a dated note beneath it, because it
was true when the survey ran and its reasoning - do not assume an equivalence
from two names that look alike - is why the check was worth running.

**The gear-stub count moved 7 -> 11 and none of that is these six batches.**
The survey's figure was pasted before batch 1, which created three stubs, and
batch 2 created a fourth. Batches 4, 5 and 6 created none: every class script
in them emitted zero stub rows, because the skill rows they needed were applied
first on purpose.

### `triax` gear pass, 2026-09-07 (PR #786) — AND THE BOOK IS CLOSED

Seven scripts, **113 new gear rows and four stubs filled**. Gear 1025 ->
**1137**. `triax` now reads **151 traceable / 0 other**, and the repo-wide
gear-stub backlog fell from eleven to **seven** - none of the seven is this
book's. **Status moves to `imported`.**

**THE SURVEY ESTIMATED ~55 IMPORTABLE ROWS AND THE REAL FIGURE IS 113**, after
removing about twenty-five candidates the catalog already held. The estimate
came from a page count; the duplicates only showed up in a name-by-name diff
against all 1,025 existing rows. Do that diff before quoting a row count.

**FOUR STUBS WERE FILLED, NOT DUPLICATED.** t-10-infantry-cyclops-body-armor,
t-12-field-medic-body-armor, t-13-field-mechanic-body-armor and
tx-42-laser-pulse-rifle were created by the NGR class batches and cited to the
O.C.C. pages that mention them; the armour and weapons chapters are where they
are actually statted. Nine published classes reference those slugs, so the
slugs are untouched and each UPDATE is guarded on the STUB marker.

**`triax-pump-weapon` IS STILL A STUB ON PURPOSE.** The survey said not to
retire or merge it - twelve Warlock classes reference it by slug, and
rewriting a referenced slug is the catalog editor's duplicate-tool job. Both
real weapons it stands for, the TX-5 Pump Pistol and the TX-16 Pump Rifle, are
now imported beside it; the placeholder keeps its page range from PR #782.

**A NO-OP INSERT IS HOW THE LAST DUPLICATE WAS CAUGHT.** The equipment batch
originally carried a Palm Bio-Unit row; the catalog already held it from RUE,
so `INSERT OR IGNORE` silently did nothing and the row count came back one
short of the number written. **Count what you inserted against what appeared** -
the guard prevents the duplicate but says nothing about it.

**THREE THINGS THE BOOK CONTRADICTS ITSELF ON**, all recorded in the scripts
rather than resolved:

1. A pump round costs **300** credits on printed 141, **400** in the TX-5 entry
   and **200** in the TX-16 entry. Each weapon row carries its own entry's
   figure and the ammunition row carries the general rule.
2. The Kittani Energy Lance prints *fair availability* beside its payload and
   *poor availability* beside its price, two lines apart on printed 214.
3. The Falcon 300 prints a maximum speed of 120 mph and then describes its
   electric range as *about 200 miles an hour*.

A fourth is a CONVERSION rather than a contradiction: 800 feet is printed as
*(224 m)* throughout the pistol pages, where 800 feet is 244 m. Verified on a
render - it repeats identically across entries, so it is the book's error and
not the OCR's. The foot figure is what is stored.

**CYBERNETICS ARE NOW IN THE CATALOG, AND THAT IS A NEW CONVENTION.** Before
this batch a query for bionic, cyber and implant across all 1,025 gear rows
returned exactly one row, and that was a suit of armour from a web reference.
The twenty-five implants of printed 153-154 are filed as ordinary `gear` - and
as `weapon` for the four that do damage - on the same reading that puts Juicer
Uprising's designer drugs and the bio-comp system in `gear`. **Nothing in the
app installs an implant or tracks one**, so these are purchasable items and no
more than that; 113 published classes mention cybernetics, almost all of them
in a restriction saying the class starts with none.

**THREE OF THIS BOOK'S SIX DESIGNER DRUGS WERE ALREADY IN THE CATALOG** from
Juicer Uprising - boing-go, crash and rush - at DIFFERENT prices (Triax prints
20-50 where the catalog has 30-60, and so on for the other two). The catalog
wins and a disagreement is not a gap, so nothing was overwritten and no second
row was made; the Triax figures are in the header of
`add-triax-gear-g-drugs-and-jaep.sql`. Only euphie, psike-B and psike-E are new.

**Printed 175-178 was NOT in the survey's gear plan** and holds seven of these
rows - the four JAEP programmes and those three drugs. It was found by reading
the Euro-Juicer's own pages during batch 5, not by the survey's diff.

**Four rows carry NO PRICE and say so in `cost_note`**: the giant Electro-Mace,
the Blaster Neural Whip, the gargoyle Wing and Tail Blades, and the Psionic
Electro-Magnetic Dampers. The book prints none for any of them. They do not
land on the `gear with no price` backlog line, which counts rows with neither a
cost nor a note - that line went DOWN, 35 to 31, because filling the four stubs
removed more than these added.

**What is still absent, and always was:** the ~53 vessels of printed 39-140 and
205-209 - roughly 107 of 222 printed pages - excluded by
`BOOK-INGEST-AUDIT.md` **F3**, which is about the shape of the `gear` table and
not about this book.

### Three loose ends settled, 2026-09-07 (PR #788)

One correction, and two questions that turned out to need no change. All
three were on the outstanding list written at the end of the gear pass.

**1. THE CYBERNETICS CATEGORY - CORRECTED.** The twenty-five Triax implants
went in as `category = 'gear'` and `'weapon'`, and the catalog already had a
word for them: `db/schema.sql` documents `gear.category` as *weapon | armor |
vehicle | cybernetics | gear*, and `js/catalog-fields.js` offers exactly those
plus `magic` as the editor's select for that field. **`cybernetics` was a
supported value with a UI behind it, and simply unused.** The import filed its
rows around it rather than in it, because there was no precedent in the DATA -
but there was one in the schema comment and the editor config, and neither was
consulted. `fix-triax-cybernetics-category.sql` moves all twenty-five.

All four that do damage move too. The Laser Beam Eye, the LGL-31 Grapnel, the
PL-31 Palm Laser Torch and the RVB-31 Concealed Vibro-Blade went in as
`weapon`; they are still implants, the damage is in the `damage` column either
way, and filing them by what they ARE keeps the twenty-five together. The
SPU-5 stays `gear`: printed 152-153 sells it as a worn belt or collar for 100
credits and as an implant for 2,000, it is one device and one row, and it is
primarily worn.

**2. THE WALKER/RIFTER `per_level` ASYMMETRY - NO DEFECT. Both resolve to the
same number.** The Ley Line Walker's `Language: Other` choice group carries
`per_level: 5` and the Ley Line Rifter's does not, and PR #784 left it open
because what `per_level` means on a CHOICE group as opposed to a named skill
was not established. It is established now:

```
app.js:2119   per_level: explicit.per_level ?? cat.per_level ?? 0,
app.js:3206   // Choice-group picks are stored exactly like fixed class
              // skills, inheriting the group's base/per_level.
```

So a choice group's `per_level` IS read, and it overrides the catalog row for
every pick made from that group. The Walker states +5 explicitly; the Rifter
omits it and falls through to the `Language: Other` catalog row, **which is
+5**. Identical outcome. **Nothing is changed**, and the honest reason to
leave it is that the two are not actually different today - but they would
diverge the moment `Language: Other` changed its per-level step, which is
worth knowing and is why this paragraph exists rather than a fix.

A first reading of this got it backwards - the VALIDATOR
(`validateSkillEntries`) never looks at `per_level` on a choice group, which
makes it look inert. The validator not checking a key is not the app not
reading it. Two different files, two different questions.

**3. THE `drift-check` CITATION ADVISORY - A FALSE POSITIVE.**
`spells.Water: Summon Sharks/Whales` cites *Rifts Book of Magic p.87* and
drift-check reports the name absent from that book's text. The spell is there:
`bom` has `page_offset: 1`, so printed 87 is cache `p088.txt`, and line 43 of
that file reads `Summon SharkslWhales` - **the OCR read the slash as a lower
case L**. The citation is correct and the row needs nothing. Recorded so the
next person to run drift-check does not chase it again; the advisory is
advisory precisely because a name a book writes differently reads the same as
one it never had.

### `underseas` survey and skills, 2026-09-07 (PR pending)

Surveyed, and the first data batch is in. The survey is
`apps/character-creator/docs/surveys/underseas.md` and it is what the next
session boots from. Four things it established:

**The Experience Tables on printed 214 are the class authority, and they cut
the count roughly in half.** A stat-block marker scan finds forty-odd entries;
the ladder names **twenty-six**. The creatures chapter (pp.20-46) is the
difference: nearly every entry there carries `R.C.C. Skills of Note:` plus
Market Value / Habitat / Enemies / Allies, which is the book's monster shape,
and page 214 gives exactly two of them a ladder — the **Dragon Ray** and
**Gene-Splicer Mutants**. Everything else in those pages is an NPC by the
book's own reckoning.

That page also settles two names the chapter headings spell differently:
the **Ocean Wizard O.C.C.** (p.60) is *Ocean Mage* in the ladder and the
**Sea Inquisitor O.C.C.** (p.48) is *Sea Inquisitioner*.

**The book adds ZERO psionic powers, and that was checked rather than
assumed.** The `I.S.P.` scan hits ten pages, one occurrence each, and every one
is a class's own pool line. The four cetacean psionics sections (pp.80, 88, 90,
92) are roll tables selecting from the existing categories. No psionic import.

**Nine ocean spells share a name with a Water Warlock spell the catalog already
holds, and they are the SAME spell at a different level and cost.** Not a
duplicate to skip and not a correction to apply. `Water: Whirlpool` was read out
of production and compared against printed 70 line by line — same 120 foot
radius, same 500 foot casting range, same ten feet per melee drag, same 20 foot
centre — and the Book of Magic publishes it at level 5 for 40 P.P.E. where
Underseas publishes it at level 9 for 50. One row cannot hold both, because the
sheet's use button spends `ppe`. The import ships the ocean rows under an
`Ocean:` prefix, following the `Water:` / `Fire:` / `Air:` / `Earth:` families
already in the catalog, and records the warlock reading in `variant_note`.

**Six `Rifts Skill List` rows turn out to be printed in this book**, and all six
agree on category, base and per-level. `zzzzz-recite-underseas-skills.sql` moves
the citations; the sheet drops from **40 rows to 34**. This is the mechanism
`zzzzz-recite-phase-world-skills.sql` established, and it is a citation change
and never a rename, for the `W.P. Rope` reasons above.

**Skills batch.** Eight new rows — Advanced Fishing, Marine Biology, Sea
Holistic Medicine, Track & Hunt Sea Animals, Undersea Salvage, Advanced Deep Sea
Diving, W.P. Torpedo, W.P. Trident. Catalog moved 358 -> **366** skills.
Applied `--remote` before the PR.

**Two readings this book loses, recorded on the rows that won.** Printed 210
gives Underwater Demolitions at 56% **+3%** where the catalog's
`Demolitions: Underwater` cites RUE at **+4%**; printed 212 gives W.P. Harpoon
Gun its last strike bonus at level **thirteen** where the catalog's
`W.P. Harpoon & Spear Gun` cites RUE at **fifteen**. RUE is later and both
catalog rows stand.

**One skill this book prints with no percentage at all.** *Pilot: Advanced Deep
Sea Diving* (printed 212) describes what the skill covers and states neither a
base nor a per-level step. That is the book, not the OCR — the paragraph reads
clean and ends on a complete sentence. It ships at base 0 with the omission in
its note. **Not an audit finding:** `base_formula` exists (F2, PR #427) and does
not help, because there is no formula either. Do not invent a number for it.

**One near-duplicate noticed and left alone, on the `W.P. Rope` precedent.** The
catalog holds TWO rows for the submersible-piloting skill — `Boat: Submersibles`
(now cited to Underseas p.212) and `Military: Submersibles` (RUE p.302-303) —
both Pilot, both 40% +4%. Underseas prints it once. Merging them is
duplicate-tool work that writes redirects and rewrites characters; picking which
name survives is a catalog decision, not a reading of this book.

### `underseas` complete, 2026-09-08 (PRs #798-#810) — AND THE BOOK IS CLOSED

**Thirteen PRs**, carrying **37 data scripts** between them. Twelve applied
`--remote` before merging; exactly one, #806, carried no SQL at all and was a
correction to this book's own survey ledger. Counted from the PRs rather than
from memory, because the one arithmetic slip this book produced - #805 claiming
all 25 classes when 20 were in - was a batch count nobody checked against the
thing it described. Catalog totals moved
**358 -> 367 skills, 607 -> 681 spells, 190 -> 215 classes, 1154 -> 1241 gear,
55 -> 105 vessels**.

| category | in | left |
|---|---|---|
| skills | **9** - 8 new from the skills chapter plus `Language: Dolphin/Whale`, which the chapter does NOT define and which was found in a class list on printed 75-76 | none known |
| re-citations | **6** rows moved off the phantom `Rifts Skill List` onto this book's own pages, taking it from 40 untraceable rows to **34** | the other 34, which are not this book's |
| spells | **74** across four traditions - 41 `Ocean:`, 21 `Spellsong:`, 10 `Dolphin:`, 2 Korallyte unprefixed. Ten collide with an existing `Water:` warlock row and are the SAME spell at another tradition's price, which was CHECKED against printed 70 line by line rather than assumed. `variant_note` on each; gap filed as **F26** | none |
| classes | **25** of 25 - the book is complete, verified by counting `imported_classes` against the printed-214 ladder rather than by adding up batches | **none** |
| gear | **87** - weapons, armour, bionics and the book's 33 priced sea vessels, which go in `gear` with category `vehicle` on the existing 36-row precedent and are the first rows to use `gear.sdc` | see the stub note below |
| vessels | **50** stat blocks with 415 M.D.C. locations and 247 weapon systems, in five files split by the page each block's HEADING falls on | none |

**Only ONE of the fifty vessels has a price**, and that is the section rather
than a gap in the reading. Every other entry is military, magic or Atlantean and
the book's own phrase is some variant of *never sold to outsiders*. Twelve
follow that with an ESTIMATE, and an estimate is not a price, so none of them is
stored as one. The Poseidon is the sharpest case: **4.2 billion credits to
build** is a real, stated figure and still not a market price.

**A cyborg is in the `vehicles` table, deliberately.** The VX-20,000 Barracuda
carries a `Model Type:` line, M.D.C. by location and numbered weapon systems -
the shape migration 048 built that table for, and the same rule the gear pass
used to route 26 entries there. Its `Class:` line is stored verbatim.

**Printed 131 is absent from the source PDF** and it IS a loss: it cuts the USS
Ticonderoga after weapon system 2. Four OTHER pages inside stat blocks - printed
142, 187, 194 and 208 - are blank illustration pages and lose nothing, which was
checked field by field on each. Two of those four were not known before the
vessel pass.

**The book contradicts itself at least six times and every contradiction is
stored rather than resolved**, because picking a winner erases it: the War Crab
names one gun twice, the Sea Fin numbers a system "4" twice, the Poseidon's
systems run 1-5 then 7, the Sea Bat's rail gun count disagrees with its own
text, the Barracuda's Quad Rifle prints two laser ranges, and the Deathbringer
repeats a system's Range and Payload lines verbatim.

**Two findings came out of this book**, F26 and F27, and both are open. **F27 is
the one that matters to the NEXT book**: `class-check` does not validate skill
names inside an MOS option, so a typo there ships silently. Any book with a
military career structure is exposed to it.

### The CI debt this book left, and closing it (PR #810)

**`regression.mjs` was red from PR #807 through #809** - three merges, the same
eight checks failing byte for byte in every run. No one of those PRs caused it
and no one of them fixed it, which is the part worth recording here rather than
only in the survey: **a check that stays red across merges stops being read**,
and the next book's session would have inherited a signal it could not use.

Six were stale documented counts, one was the Navy Seaman's unregistered MOS,
and nine were O.C.C.s shipped with no `occ_group` - which is not cosmetic, since
a race restriction naming a missing group fails OPEN.

**A rule worth carrying forward:** the grouping could not be read off a heading.
`zz-rifts-occ-groups.sql` could cite RUE's own section headings straight into
the five names `OCC_GROUPS` allows; **Underseas groups by NATION instead**, and
no nation is one of the five. The evidence used was the 3D6/1D6 split already
cited behind each class's `CORE_SDC_BY_CLASS` entry. **Any book that does not
print the five categories will need the same substitution**, so check for it at
survey time rather than at the end.

### What was still open when this book closed - and what closed it

**All but one of these is now shut**, in PRs #811 through #814, and this section
is kept rather than deleted because the SHAPE of each is what the next book
needs, not the fact that it is fixed.

- **18 gear stubs** - CLOSED (#814). The class imports coined a gear slug from
  the book's own wording rather than matching an existing catalog row, and the
  gear pass did not clear them because it extracted the entries the book PRICES
  and none of the eighteen is one. **Five were duplicates** of rows already held
  under another name - `flashlight-pen` against RUE's `Pen Flashlight`,
  `hand-computer` against `Hand-Held Computer` - and were merged with a
  forwarding redirect. **Thirteen were not**, and took a marked estimate on the
  `estimate-mundane-gear-prices.sql` precedent: cost only, never a weight and
  never a combat number. **This was first reported as "MOST are duplicates" and
  that was wrong** - it was five of eighteen, and the difference only showed up
  when each pair was checked column by column, which is why `net-fishing` did
  NOT become a sixth: it is a `palladium-fantasy` row and the stub is `rifts`.
- **F27** - TAKEN (#812). The one that mattered to the next book.
- **Nothing checks a vessel's citation** - CLOSED as **F28** (#813). Filed and
  taken in one change. `vehicles` was missing from `source-coverage.mjs`'s
  catalog list, so 105 vessels across two books carried a `source_book` nothing
  verified. It appeared in that file exactly once, in the no-price count, which
  is why a grep made it look covered.
- **F26 is the one still open**, and it is the smaller of the two spell-linking
  designs rather than anything blocking.

**The lesson worth carrying, which is none of the four individually:** every one
of these was invisible to the thing that should have caught it, and visible
immediately once someone asked *"what does this check NOT look at"*. The queue
status, the stub marker, the coverage list and the MOS blind spot all reported
healthy while being wrong. Ask that question at the END of a book, not only at
the start.

### `free-quebec` survey, 2026-09-08 (PR pending)

Status `cached` -> **`surveyed`**. The survey is at
`apps/character-creator/docs/surveys/free-quebec.md` and is the authority; what
follows is the queue's own view.

**Offset confirmed +1 END TO END**, nine samples read off the folios the pages
print, front to back — not a whole-book vote, because `underseas` proved a vote
can hide a split. `printed_pages: 192` in the registry is **exactly right** and
needs no correction, unlike `triax`, `bom` and `new-west`.

| category | found | verdict |
|---|---|---|
| O.C.C.s | 6 entries, **10 classes** | import |
| vessels | **23** | import |
| gear | **~18** | import |
| skills | **0 new** | nothing to import |
| spells | **0** | the book defines none |
| psionic powers | **0** | the book defines none |
| R.C.C.s | **0** | the book has none |

**Zero spells and zero psionics, scanned rather than assumed**: `P.P.E. Cost:`,
`Saving Throw:`, `I.S.P.:` and `Spell Level` each appear on **0 of 194 pages**.
The absence is editorial — printed 33 bans practitioners of magic from the
nation and printed 34 gives psychics a roster share of `-0-`.

**Zero new skills, and this is the diff's own answer rather than a shortcut.**
Fifty-two names pulled from the six class entries, run `--remote`: 36 matched,
2 matched by alias, **16 reported missing and all sixteen are false gaps** —
every one a category prefix or a house spelling the catalog already holds
(`Pilot Automobile` -> `Automobile`, `Basic Math` -> `Mathematics: Basic`,
`Climb` -> `Climbing`, and eleven more). That is `book-survey` phase 2's
*"a dominant single substitution is a vocabulary difference, not N
corrections"*, and running the diff is what stopped sixteen duplicate rows.

**This book has NO Experience Table** — the phrase appears nowhere in 194 pages
— so its roster has a single authority, the Contents. `phase-world`'s Royal
Kreeghor is the standing warning about exactly that, so every class here was
confirmed against its own stat-block markers and its section heading rather than
against the Contents.

**Two findings filed, F30 and F31**, and both are pre-authorized for
implementation in this book's closing PR rather than deferred:

- **F30** — a cached page can be **welded** across the gutter when `pymupdf`
  returns one block holding both columns' lines, and nothing detects it.
  Two pages of 194 here, and one of them carries a `starting_money` field.
  Detection is geometric and costs nothing; it should run for the three
  text-layer books still unsurveyed in this batch.
- **F31** — a `variants` block may not add a skill or change the related-skill
  count, which is the shape this book's four cyborg chassis use. They ship as
  five classes each restating eleven shared skills, which is the drift
  `variants` exists to prevent.

**What is deliberately not imported**: the old-style CS, Triax and Northern Gun
weapons of printed 43-44 and the body armor and vehicles of printed 51-53, all
of which the book gives **page references into other books instead of stats**;
the reference chapter of printed 33-35, which lists existing O.C.C.s at
percentages and defines none; the four named-NPC stat blocks on printed 127,
142, 151 and 175; and the setting chapters — the war narrative (6-31), Free
Quebec itself (133-153), Old Bones (152-184) and the adventure hooks (185-193).

### `free-quebec` complete, 2026-09-08 (PRs #818-#822) — AND THE BOOK IS CLOSED

Status `surveyed` -> **`imported`**. Five PRs, four of them carrying data, each
applied `--remote` before its merge.

| PR | batch | rows | catalog after |
|---|---|---|---|
| #818 | survey | 0 | unchanged |
| #819 | gear, printed 44-51 | 17 | gear 1236 -> **1253** |
| #820 | the five O.C.C.s of printed 32-42 | 5 | classes 215 -> **220** |
| #821 | vessels, printed 52-134 | 22 | vehicles 105 -> **127** |
| #822 | the cyborg O.C.C. and its four chassis | 5 | classes 220 -> **225** |

**Ten classes, twenty-two vessels, seventeen gear rows. Zero spells, zero
psionic powers, zero new skills** — every one of those zeros confirmed by
stat-block scan rather than assumed, and the skills zero only after a `--remote`
diff whose sixteen "missing" rows all turned out to be false gaps.

**What is deliberately not imported** is in the survey at
`apps/character-creator/docs/surveys/free-quebec.md`, and the one addition the
survey did not predict is the **QR-2 Abolisher Prime**: it has a heading, a
paragraph and a height, and no stat block anywhere in this book, only a redirect
to Coalition War Campaign. Twenty-two vessels rather than the projected
twenty-three.

**The findings this book produced are all resolved, 2026-09-08 (PRs #823-#834).**
Nine were open at the end of the import - `F30`-`F36` from the book, plus `F37`
and `F38` filed while taking them - and none is now. **This line says no more
than that on purpose:** which finding got what, and which proposals turned out
to be different work than they described, lives under each finding in
`BOOK-INGEST-AUDIT.md`, and a per-finding roll-call here would be a second place
for that to be wrong. `audit-menu` -> *A header MAY NOT carry a per-finding
state*. **Read under the heading.**

Two are worth knowing at queue level, because they change how the NEXT book is
read rather than what this one shipped: `ocr-book.py` now records `welded_pages`
and `corrupt_pages` in every text-layer cache manifest, and `class-check
--field-sources` warns when a class was drawn from either kind of page. Run it
on a book you cached weeks ago - the first cross-book sweep found 42 welded
pages across ten of eleven text-layer caches, and rediscovered a scrambled `bom`
page that had been found by hand.

*(What follows is the state as it stood when the import closed, kept as the
dated record it is.)*

**Seven findings, F30 through F36**, and the two the queue previously described
as pre-authorized are now six plus one. **None is implemented.** All six of
F30-F35 went through `audit-premise-auditor` before any implementation was
attempted, and **seven claims did not survive** — including a quotation in F33
that exists in no row, and F34's data half shrinking from fifteen classes to
nine because six of the fifteen turned out to be a legitimate shape. The
corrections are in the menu in place; the scope changes are in a dated
premise-audit section at its end. **Read that section before taking any of
F30-F36**: two of the proposals are now different work than they describe, and
F31 in particular asks for a key one character from one that already exists.

**This supersedes the earlier line in this file saying F30 and F31 are
pre-authorized for implementation in this book's closing PR.** They were not
implemented, and the premise audit is why: F30's detector needs a filter it did
not specify, and F31's proposal collides with `related_skills_count`. Both are
better taken deliberately than folded into a data PR.

### `new-west` survey, 2026-09-09 (PR #880) - and FULLY IMPORTED 2026-09-10

Status `cached` -> **`surveyed`**. No data shipped; the survey is at
`apps/character-creator/docs/surveys/new-west.md` and is the file the import
sessions boot from.

**This is the largest book left in the batch by playable roster: 26 classes**,
against `phase-world`'s 34 and `triax`'s 21. Also 50 new spells, 4 new skills,
79 priced gear entries and ~15 vessels. Nothing of it is in the catalog — the
one row citing this book is `skills.W.P. Rope`, which has no page range and
predates the cache.

**Run `ocr-book.py` again on any book cached before 2026-09-08 before surveying
it.** This cache was built 2026-08-28, so its manifest had neither
`welded_pages` nor `corrupt_pages`; a plain re-run recomputed both in seconds
and skipped all 226 already-cached pages. It found **one welded page and three
glyph-corrupt ones**, and two of the four sit on pages data will be read from —
printed 130 (Keepers of the Desert) and printed 217 (three Techno-Wizard
prices). `spirit-west` and `mystic-russia` were cached the same day and have
not had this done.

**Three findings from the survey that change how a Rifts book is scanned, not
just this one:**

- **A roster scan keyed on `O.C.C.` and `R.C.C.` misses classes.** The
  Psi-Slinger is a **`P.C.C.`** and has no other heading; Cactus People and
  Mountain Giant carry no class suffix at all. Three of 26 invisible to the
  marker scan that every previous book in this batch used.
- **The playable/NPC line is stated per entry, on the entry's own tag line**,
  and this book tags all 30 racial and creature entries that way. Scanning for
  that tag found the 8 playable ones directly. It is much cheaper than reading
  the section and much more reliable than the section boundary — Psi-Ponies is
  playable and sits 20 pages inside the creature chapter.
- **An experience ladder is NOT evidence of playability.** Three NPC creatures
  here have one. A session that inferred the roster from the experience-table
  page — which is otherwise the best authority in the book, and settles which
  classes borrow a ladder from the core rules — would have imported three
  monsters.

**Nothing was filed on `BOOK-INGEST-AUDIT.md`, and the reason is that the one
mechanic this book looked like it needed already SHIPPED.** The CyberSlinger is
three chassis of one full-conversion cyborg, the same shape as Free Quebec's
cyborg and its four — which was `F31`, and `F31` was **taken on 2026-09-08 in
PR #834**. `skills_additional` and `related_skills_count` are both in
`VARIANT_OVERRIDES` and both have handlers in `js/parser.js`. A chassis can add
skills and move the related-skill count today.

**The half of `F31` that was deliberately not done does not bite here.** Its
outcome note is explicit that the five Free Quebec cyborg classes are *not*
restructured, because characters reference a class by `class_id` and collapsing
four chassis into variants would retire four ids that are pointed at. The
CyberSlinger chassis are new and unpublished, so there is nothing to retire and
the mechanism is available from the first PR.

**This paragraph said the opposite for the length of one commit** — that F31 was
open and the rows should be added to it. Checking F31's outcome note rather than
its heading is what corrected it, which is the `audit-menu` rule about reading
to the next `###`, met from the direction it is usually missed.

Two decisions are left open in the survey rather than settled here, because both
are cheaper to make once with the first spell PR in hand than to guess at now:
whether the 50 Cloud Magic rows take a tradition prefix in `name`, and where the
seven cloud categories live given that `spells` has no `category` column.

### `new-west` is FULLY IMPORTED, 2026-09-10

Status `surveyed` -> **`imported`**, across fourteen PRs: #881 (58 Cloud Magic
spells), #882 (skills), #883/#885/#886/#887/#888/#890/#892 (all 25 playable
classes), #895/#896/#897/#898/#901 (100 gear rows) and #899/#900 (15 vessels).

**Catalog movement:** classes 225 -> **250**, skills 367 -> **370**, spells
681 -> **739**, gear 1249 -> **1349**, vehicles 143 -> **158**.

**The roster was 25, not the 26 this section claims above.** The CyberSlinger is
not a class - printed 189-193 gives the three chassis a `Model Type`, a `Class:`
line reading "Full Conversion Cyborg", an `M.D.C. by Location` block and a cost
in millions, and NO class block on any of the three pages. Printed 190 says they
are cyborg BODIES whose recipients fall into the existing 'Borg O.C.C. They
shipped as vessels in #899.

**A FOURTH SCAN TRAP, on top of the three this section already records: COUNT
THE ENTRIES, NOT THE HEADINGS.** The RH-1001A Appaloosa is the fourth robot
horse and both the survey and a later heading scan found only three, because
its heading is "Appaloosa or Pony" and carries no model number.

**THE BIGGEST FINDING IS ABOUT `corrupt_pages`, AND IT IS NOT ABOUT THIS BOOK.**
New West renders the digit **1 as `!` or `l`** and **0 as `O` or `Q`** inside
almost every `NDNx10` / `NDNx100` construction - `!D4xlO`, `3D4xlOO`, `10Q`.
**It affects roughly sixty pages; the manifest lists three.** The detector looks
for glyphs that FAIL TO MAP, and these map to perfectly valid characters, so a
substitution cipher is invisible to it. It is also **in the ink** - confirmed at
600 dpi - so a render does not cure it, unlike printed 217, which is the other
kind. **This book is the reference case for both halves of `book-survey` 0a's
distinction.**

It reaches `Money: Starts with 3D4xlOO credits` on almost every O.C.C. page.
Nothing leaked: swept `--remote` afterwards and no row in `imported_classes`,
`gear` or `vehicles` contains `xlO`, `xlOO` or `!D`. **Check the other text-layer
caches for the same pattern before trusting a dice figure read from one.**

**Left for a decision, all recorded in the survey's own findings section**: the
Black Market price divergence on three CS armours RUE already holds; the
`regression.mjs` check that refuses a grenade carrying both an `sdc` and a
damage die; and the `corrupt_pages` blind spot above.

### `spirit-west` survey, 2026-09-10

Status `cached` -> **`surveyed`**. The survey is at
`apps/character-creator/docs/surveys/spirit-west.md` and is the authority; what
follows is the queue's own view.

**Cache re-run first**, per the `new-west` instruction above: one welded page
(printed 201, the War Chief power armor), eight glyph-corrupt pages (four on
pages data comes from) and **85 pages of `substituted_digits`** - every O.C.C.'s
trade-goods allowance prints as `2D6xlOO` or `3D6xlOO`.

| category | found | verdict |
|---|---|---|
| O.C.C.s | **11** - four warriors, seven shamans | import |
| R.C.C.s | **1** - the Wendigo, tagged NPC *and* optional R.C.C. | import |
| spells | **34** shaman invocations, levels 1-13, cost printed four times each | import |
| gear | ~12 on printed 203, plus ~45 **unpriced** fetishes | import |
| vessels | **6** robots and power armor, none sold on any market | import |
| skills | **0** - no new-skills section | nothing to import |
| psionic powers | **0** | nothing to import |

**The experience tables are not the roster here either** - the third book to
show it, after `new-west`. Printed 7 gives ladders to six NPC entries (Great
Little Ones, Two-Faced Star People, Man-Monsters, Man-Eagles, Stone Giants,
Black-Winged Monster Men) and sends the Ukt Water Serpent to the dragon table.
Every one is tagged NPC on its own heading.

**Two findings filed, F56 and F57, neither implemented.** F56 is the 40 totem
animals (first counted as 48) nine of the eleven O.C.C.s must pick from: a
totem grants skills as well as bonuses, abilities carry no skills, and the table
would repeat in every class. F57 is not this book's alone - a class whose spell
pool is a level range already admits every leveled spell of every tradition, and
the 34 shaman spells will join the 167 warlock, `Ocean:` and `Dolphin:` rows the
Ley Line Walker is offered today.

*2026-09-10: F56 was taken. The forty totems are rows in `totems` (migration
056), and the nine classes carry a `totem` key the wizard resolves into a pick;
see its outcome note.*

**What is deliberately not imported**: the Kachina Dancer (a role layered on an
O.C.C., not one), every NPC monster, spirit and god on printed 106-188, the
totems as catalog rows (F56), and the setting.

### `spirit-west` is FULLY IMPORTED, 2026-09-10

Status `surveyed` -> **`imported`**, across seven PRs, all in one session: #934
(survey), #935 (34 shaman spells), #936 (46 fetishes), #937 (the four warriors
and W.P. Tomahawk), #938 (Plant, Animal, Mask and Healing Shaman), #939
(Paradox, Elemental and Fetish Shaman and the Wendigo), and #940 (gear and
vessels), which closed the book. Each data PR was applied `--remote` before its merge.

**Catalog movement:** classes 250 -> **262**, skills 371 -> **372**, spells
739 -> **773**, gear 1349 -> **1408**, vehicles 158 -> **164**.

| category | in | not in, and why |
|---|---|---|
| classes | **12 of 12** - 11 O.C.C.s and the Wendigo R.C.C. | none |
| spells | **34**, unprefixed, at their printed levels | the Paradox Shaman's Rifts England temporal spells, which the catalog does not hold |
| skills | **1** - W.P. Tomahawk | the survey's "zero new skills" was right about the book's definitions and blind to a class granting one, which is the Triax lesson again |
| gear | **59** - 46 unpriced fetishes and 13 Weapons of Note | seven arrowheads already held from Triax |
| vessels | **6**, 60 locations, 32 weapons, none priced | none |

**Three things this book established that the next one needs:**

- **Named spell lists match by exact string.** `catalog-diff` normalizes `&` to
  `and` and ignores case, so it reported `Summon & Control Rodents` as matched
  while the wizard, which compares lowercased names exactly, would have dropped
  the pick. Six list names had to take the catalog's spelling. **Check a list
  with a plain `IN (...)` query, not with the diff.**
- **A remote apply can hang for an hour with the database half written.** It
  happened twice here - three of four classes in, the fourth call never
  returning. Read production, kill only the stuck process tree, and re-apply
  what is missing; the class scripts' `WHERE NOT EXISTS` makes that safe, and
  the footer rows say which files landed.
- **`regression.mjs` can fail locally for a reason that is not the data** -
  `BOOK-INGEST-AUDIT` F58. On this machine the bootstrap took 251 s against a
  180 s timeout while CI builds it in 18 s. A "cannot build a database" with
  only npm notice lines is that; CI's regression job is the tiebreak.

**Findings from this book: F56, F57, F58**, none implemented. F56 (totems) is
the one that costs players something today - nine classes carry the pick in
prose.

*Dated 2026-09-10, written the day the book closed and before any of the three
was taken. This line does not track them: read each one's outcome note under
its heading in `BOOK-INGEST-AUDIT.md`. F59 was filed from F57's premise audit.*

### `mystic-russia` cache re-run, 2026-09-12 - and every other text-layer cache with it

Status stays **`cached`**. No survey, no data; this is the one prep step the
`new-west` section above asks for, run at last, plus the sweep it implies.

**The instruction, from that section:** *"Run `ocr-book.py` again on any book
cached before 2026-09-08 before surveying it"*, ending
*"`spirit-west` and `mystic-russia` were cached the same day and have not had
this done."* `spirit-west` had it done on 2026-09-10, as its own section
records. `mystic-russia` is the last one, and it is now done:

| | |
|---|---|
| welded pages | **0** |
| glyph-corrupt | **1** - cache p175, and it is a **Heroes Unlimited house ad**, not a page of the book. Cache p175-p177 are ads and p178 is blank; the last page of the book is cache p174, *Ley Lines of Russia* |
| substituted digits | **72 pages** |

**Seventy-two, and they land on the two page kinds an import reads.** Cache
p108 (printed 107) is the bio-wizardry price list and prints
`Claw: Animal - !D6xlOO credits`, `Horn: Supernatural Being - 2D4xlOOO`, a
dozen rows of it. Cache p122 (printed 121) is the supernatural P.S. damage
table - `!D4xlO M.D. on a power punch`, `!D6xlO+10 on a full strength punch`.
Both were read off the cache on 2026-09-12. The offset holds at +1 by the
folios printed on those two pages: cache p108 ends `107`, cache p122 ends
`121`.

**A render does not cure this** - it is in the ink, which is the half of
`book-survey` 0a's distinction that `new-west` is the reference case for. Read
the token as the dice expression it can only be.

### The six text-layer caches with no digit measurement at all

Found while doing the above, by reading every `manifest.json` under
`.cache/books/` on 2026-09-12 rather than trusting any list. **Six of the
eleven text-layer caches had no `substituted_digits` key**, and five of those
six had none of the three, so every book below had been extracted from with no
idea whether its digits were intact. All six were re-run the same day; the run
is free, since every page is already cached.

| slug | welded | glyph-corrupt | substituted digits |
|---|---|---|---|
| `dag` | 6 | 2 | **40** |
| `fom` | 9 | 4 | 2 |
| `free-quebec` | 2 | 6 | **30** |
| `ju` | 3 | 7 | **44** |
| `pf` | 6 | 1 | **28** |
| `potm` | 1 | 3 | 11 |

`free-quebec` is the one to notice: it had `welded_pages` and
`corrupt_pages` already and no `substituted_digits`, so it was re-run once
before the digit detector existed and looked measured. **A manifest with two of
the three keys is not a measured cache.**

**Every text-layer cache in the tree carries the substitution to some degree**,
from 2 pages (`fom`) to 116 (`bom`). The five scan caches - `rue`,
`phase-world`, `triax`, `underseas`, `ww` - correctly carry none of the three:
the digit detector is text-layer only, by the script's own design.

### Nothing leaked into production, swept 2026-09-12

The `new-west` sweep is the precedent and this one is wider: a **case-sensitive**
`GLOB` (`LIKE` is case-insensitive in SQLite and reports matches that are not
there) for `xlO`, `!D<digit>`, `<digit>DlO` and `x<digit>O` over every
numeric-bearing column of `gear`, `vehicles`, `spells`, `skills`,
`psionic_powers` and `vehicle_weapons`, `--remote`:

```
gear 0 | vehicles 0 | spells 0 | skills 0 | psionic_powers 0 | vehicle_weapons 0
```

`imported_classes` returns **10** rows, and all ten are the Spirit West classes
**quoting the corrupted token beside the reading** in their notes - *"The trade
goods print as 2D6xlOO and are read as 2D6x100"*. That is the shape that book
established and it is the right one: the note records what the page says, the
data records what it means.

**What this does not prove.** The sweep finds the cipher's own tokens. A figure
misread into a plausible number - `!D4` read as `1D4` where the page meant
something else - leaves no token to find, and nothing here reaches that.

### `mystic-russia` survey, 2026-09-12 — and the batch has no book left at `cached`

Status `cached` -> **`surveyed`**. No data shipped. The survey is at
`apps/character-creator/docs/surveys/mystic-russia.md` and is the authority;
what follows is the queue's own view.

**The cache re-run was done first**, per the `new-west` instruction — it is the
section above this one, and it is why this survey could trust its own page
numbers.

| category | found | verdict |
|---|---|---|
| spells | **146** parsed across four traditions; **131 missing** from the catalog | import |
| classes | ~15 O.C.C.s, printed 75-155 | import |
| playable creatures | **7**, read 2026-09-12 (PR #984) | import the seven; six of them state no experience table anywhere in the book |
| gear | ~20, printed 107 and 159-170 | import |
| vessels | **8** Sovietski pages, printed 159-171 | import |
| skills | **0** — no new-skills section exists | nothing to import, with the `spirit-west` caveat |
| psionic powers | **0** — not one `I.S.P.` stat line in 178 pages | nothing to import |

**THE TRAP THIS BOOK ADDS TO THE LIST, and it is a new one: a two-word heading
can be split across two lines by the column reader.** The Experience Tables page
is printed 172, and the cache has `Experience` on one line and `Tables` on the
next — so `grep -i 'Experience Table'` over the whole cache returns **zero
hits** for it and finds only the contents entry. The single most valuable page
in the book is invisible to the obvious search. Search one word, or search the
class names.

**The experience table IS the roster here — and the paragraph this replaces said
it was not.** Corrected 2026-09-12 (PR #984). The first reading counted eight
ladders, listed nine, and missed a tenth: `Born Mystic,` / `The Gifted Ones &` /
`Gypsy Fortune Teller` at `p173` lines 120-122. It then concluded from its own
gap that those two classes had no ladder. **Ten ladders name eighteen classes,
and every class the book defines has one** — the Russian Shifter/Summoner is a
pointer to the Rifts® RPG rather than a definition. So `new-west`'s and
`spirit-west`'s trap does **not** recur in this book. The **Born Mystic does
still appear as a `P.C.C.`**, and that half stands.

**The "five spells disagree on LEVEL" reading is WITHDRAWN, 2026-09-12 (PR
#985).** All five sit inside a named Mystic Russia tradition, and this catalog
already holds tradition spells as their own row at their own level beside the
common invocation — `Fire: Circle of Flame` is level 3 where `Circle of Flame`
is 5, and three more fire spells pair the same way. The first pass compared this
book's tradition spells against the common-invocation rows and so reported a
conflict wherever the two tiers differ, which is by design. **`Circle of Flame`
turns out to AGREE exactly**, and two of the five were never name matches
(`Fire Fist` singular; `Ocean: Healing Waters`). Settled by decision **D1** in
the survey: four tradition prefixes, retellings linked with `same_spell_as`, and
**no existing row changes value**.

**Spells before classes.** Most of the eighteen laddered classes cast — the
ratio previously quoted here rested on the wrong denominator and was never
measured — and a class citing a spell the catalog does not hold fails its check.

**That open question is now closed, 2026-09-12 (PR #984): seven entries are
playable, and the pattern sweep had the list inverted.** The tag HEADING is not
the authority — the `Player Note:` paragraph under it is, and the two disagree on
four of the eight Woodland Spirits. Two headed *Player Character* (Polevoi,
Rusalka) turn out to be GM-optional with Rusalka expressly *"not recommended"*,
while the **Man-Wolf, headed *Non*-Player Character, gets the warmest
endorsement in the book** — *"a fun and challenging character to play"*. Only the
**Firebird** is refused outright. All eighteen demons are NPC, and the **Serpent
Hound** (printed 40) is the one entry carrying no tag at all.

**And `~69 bestiary pages` was wrong by 24** — that was the count of
creature-field pages across the WHOLE book, and twenty-four of them are in the
classes section at printed 75-155. The bestiary is printed 16-71, 56 pages.

**The "blocker" that reading found was not one, and it is worth saying why.**
Six of the seven playable entries state no experience table anywhere in the
book, and only the Man-Wolf says how to level — *"the same experience table as
the Dragon Hatchling"*. That reads like a decision to settle. It is not:
`xp_table` is a literal array in class frontmatter with a **house-rule default**
when it is absent, **all seven Dragon Hatchling classes here use that default**,
and so do 172 of 265 live classes. The book's own pointer therefore resolves to
the default, and the other six land in the same place. Settled as **D3** in the
survey: all seven omit `xp_table`. **Checking the catalog beat proposing a list
of borrowed ladders.**

**The book is GREEN-LIT for ingestion, 2026-09-12.** Five decisions are recorded
in the survey — D1 spell namespacing, D2 the withdrawn level dispute, D3 the
experience tables, D4 import all seven creatures, D5 the five-batch plan in its
stated order. **Nothing is outstanding.**

**With this, no book in the batch is at `cached`.** Seven handed over on
2026-08-28: six imported, this one surveyed.
