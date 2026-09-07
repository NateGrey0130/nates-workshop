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
| `triax` | Rifts WB 5: Triax and the NGR | 225 | SCAN (OCR) | 222 — see below | **+0** | **importing** — 15 of 21 classes |
| `underseas` | Rifts WB 7: Underseas | 216 | SCAN (OCR) | 214 | **+0 / -1 split** | cached |
| `new-west` | Rifts WB 14: New West | 226 | text layer | 224 | +1 | cached |
| `spirit-west` | Rifts WB 15: Spirit West | 210 | text layer | 208 | +1 | cached |
| `mystic-russia` | Rifts WB 18: Mystic Russia | 178 | text layer | 176 | +1 | cached |
| `free-quebec` | Rifts WB 22: Free Quebec | 194 | text layer | 192 | +1 | cached |
| `phase-world` | Rifts DB 2: Phase World | 209 | SCAN (OCR) | 208 | **+0** | **imported** |

Status is `cached` -> `surveyed` -> `imported`. `phase-world` is **imported** as
of 2026-08-31: surveyed on 2026-08-30, then shipped in ten category batches,
and all THIRTY-FOUR of its playable classes are in. It also passed through a
fourth state the earlier sessions did not need - `importing`, for a book
shipping in batches across many sessions - and that state is now empty. The
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
- **No application code, schema, validator or generator changes from a book.**
  Import what the schema supports, note the drop in `extraction_notes`, file the
  gap in `BOOK-INGEST-AUDIT.md`, keep going.

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
