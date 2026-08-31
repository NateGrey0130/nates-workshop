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
| `triax` | Rifts WB 5: Triax and the NGR | 225 | SCAN (OCR) | 222 | **+0** | cached |
| `underseas` | Rifts WB 7: Underseas | 216 | SCAN (OCR) | 214 | **+0 / -1 split** | cached |
| `new-west` | Rifts WB 14: New West | 226 | text layer | 224 | +1 | cached |
| `spirit-west` | Rifts WB 15: Spirit West | 210 | text layer | 208 | +1 | cached |
| `mystic-russia` | Rifts WB 18: Mystic Russia | 178 | text layer | 176 | +1 | cached |
| `free-quebec` | Rifts WB 22: Free Quebec | 194 | text layer | 192 | +1 | cached |
| `phase-world` | Rifts DB 2: Phase World | 209 | SCAN (OCR) | 208 | **+0** | **importing** |

Status is `cached` -> `surveyed` -> `imported`. `phase-world` is **importing**,
a fourth state the earlier sessions did not need: surveyed on 2026-08-30 and
shipping in category batches, with thirty-two of its thirty-four playable
classes in and two left. The
survey at `apps/character-creator/docs/surveys/phase-world.md` is the boot file
for any session continuing it, and its ledger is the authority on what has
already gone in. The other six books are cache-only: the kickoff session caches
and registers, by design.

### `phase-world` progress, 2026-08-31

Sixteen PRs - ten carrying data, each applied `--remote` before merging, and six
carrying survey, docs or a correction. Catalog totals moved 336 -> 345 skills,
975 -> 1024 gear, 101 -> 116 psionic powers, 126 -> 158 classes.

| category | in | left |
|---|---|---|
| skills | **9** - 7 new plus 2 the CCW classes turned up (Fighter Combat: Basic and Elite, printed 151) | none known; the book collects its new skills on printed 52-53 and 150-151 and both were read whole |
| re-citations | **8** rows moved off the phantom `Rifts Skill List` onto printed 52-53 and 150-151, taking it from 48 untraceable rows to 40 | the other 40, which are not this book's |
| gear | **47** - 43 from printed 114-129, every number read off a 200 dpi render, plus four the class entries themselves state. Three of the four are real rows rather than stubs: the Steelcloth Robes (A.R. 12, 90 M.D.C., printed 27) and the Steelcloth Robes and Jumpsuit (A.R. 19, 40 M.D.C., printed 29) are named AND statted inside their own class entries, which is more than the gear chapter gives some of its own rows. The two STUBS are the Plasma Hand Cannon, which appears exactly once in the whole book with its 2D6x10 M.D. and nothing else, and the Meditation Chip, which the two phase O.C.C.s carry and the book never stats | none in that range |
| classes | **32** of 34. The CCW, printed 56-70: four O.C.C.s, the noro and its two O.C.C.s, Space Wolfen, Wolfen Quatoria, Catyr, Seljuk. The Transgalactic Empire, printed 73-84: Kreeghor, Machine People, Silhouette, Imperial Legionnaire, Imperial Security Agent, Freedom Fighter. The five spacefaring trades, printed 38-43: Spacer, Galactic Tracer, Space Pirate, Runner, Colonist. Two races and the Naruni enforcer, printed 35-38 and 46-48: Draconid, Phantom, Naruni Repo-Bot. The Pleasurer and the two playable hive-spawn, printed 88-89 and 92-94: Pleasurer, Vacuum Wasp, Termite Engineer. The four Prometheans, printed 25-29: First Stage Promethean, Promethean Phase Adept, Promethean Time Master, Phase Mystic | **2** - the two Cosmo-Knights, printed 99-104, which finish the book |
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

Nine findings have come out of this book so far - F2 through F10 in
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

**Zero offset is no longer the oddity the skill describes.** Four of fifteen
cached books have one and only `pf` and `underseas` split. Assuming +1 because
most books have it is now a coin-flip, not a default: read the registry.

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
