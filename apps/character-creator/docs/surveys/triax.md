# Rifts World Book 5: Triax and the NGR — survey

Slug `triax`. Cached 2026-08-28 from `Rifts- World Book 5 Triax and the NGR.pdf`,
225 PDF pages, **scan (no text layer)**, OCR at 300 dpi, psm 3.

*Facts about this book, not prose from it — see `book-survey` §7. Keep this
line.*

## Page offset

**Read from `scripts/books.json`; not re-derived.**

`page_offset: 0` — cache file page = printed folio + 0, so printed folio F is
`p<F>.txt` and `read-columns.py <F>`. The third zero-offset book in the registry
after `potm` and `ww`, and the registry's note records the verification: 177
pages agree at +0 against 1 at +1, the five disagreements being OCR misreading
the folio itself rather than an offset region.

No `page_offset_exceptions`. Re-checked at the **back** of the book this session,
because the registry's measurement is a whole-book vote and `underseas` proved a
vote can hide a split: cache `p222` carries folio 222 and `p224` carries folio
224. The offset is constant end to end.

**`printed_pages` in the registry is `222` and the book's last printed folio is
`224`.** Printed 223 is the Europe map (unnumbered) and printed 224 is the
Experience Tables, which carries its folio plainly and is this book's most
important page. `p225` is an unnumbered back-cover advertisement. This is the
same shape as the `bom` and `new-west` notes — the registry outranks the
manifest, and here it is the registry that is short. Nothing is currently broken
by it: `printed_pages` gates the citation check by requiring the cache to hold at
least that many pages, and the cache holds 225. But a row cited to p.224 would be
citing a page the registry believes the book does not have. **Correct it to 224
in the first data PR.**

OCR quality is good for a scan: median 4,546 characters a page, min 3, max 7,136.
Stat-block labels survived — `Attribute Requirements:`, `O.C.C. Skills:`,
`M.D.C.:`, `Weight:`, `Black Market Cost:` all parse. Thirty-one pages fall under
800 characters and every one is art rather than damage: printed 25-32 is the
FIRST-TIMER comic strip, 186-190 is the Infiltration comic, 223 is the map, 225
is the back cover, and the rest are full-page illustrations. Curly quotes and
em-dashes are present throughout and must be stripped before any SQL.

## The book's authority tables

| page | table | states |
|---|---|---|
| **224** | *Experience Tables* | which classes are playable, and the level ladder for each |
| **156** | *Occupational Character Classes* (the O.C.C. roster) | the book's own list of its new classes, by division |
| 4-5 | *Contents* | section ranges and per-item page numbers for the whole book |

**This book ships two authorities on the class question and they agree exactly**,
which is the §4b case and is worth more than either alone. p.156 lists the new
O.C.C.s by division; p.224 gives fourteen ladder headings covering sixteen named
classes. The same sixteen names appear on both, with two spelling differences the
reader must resolve rather than treat as gaps:

| p.156 roster | p.224 ladder heading |
|---|---|
| Infantry Soldier O.C.C. | *Combat Soldier & Police/Enforcement* (shared) |
| Police Enforcement (Civil & Military Enforcement) | *Combat Soldier & Police/Enforcement* (shared) |

Two ladders are shared by more than one class, so fourteen headings are sixteen
classes: *Combat Soldier & Police/Enforcement* covers two, and *Communications
Officer / Medic-Medical Officer / Field Mechanic O.C.C.* covers three.

p.224 was **read as a 200 dpi render**, not off the text layer, per §0c. The
OCR welds its five columns and scatters the headings — the rendered page is what
established that fourteen headings cover sixteen classes rather than fourteen.
The OCR's numbers matched the render on every row that could be compared, so the
ladders themselves are transcribable from the cache; only the geometry needed the
image.

The Contents is clean and complete, and it is the fastest route to a per-item
page number for the gear chapters. **It is not reliable for names.** It
disagrees with the entry headings in at least three places — it prints *T-40
Plain Clothes*, *T-42 Commando Suit* and *T-45 Explorer* where the pages print
*T-40 Urban*, *T-42 Commando Scout* and *T-43 Explorer*. Per §4c the entry
heading is the row's name here, and the Contents reading goes in `variant_note`
where it differs. Note that one of those is a **model number** disagreement, not
just a title: T-45 against T-43.

Costs are printed **once**, on the entry, so gear values are transcribed rather
than reconciled. The experience ladders are printed once as well, but they carry
their own internal check — each level's low is the previous level's high plus one
— which is the §0e self-check and is free.

## Inventory

Counted by structure over all 225 cached pages, not by reading prose.

| section | printed pages | what is there |
|---|---|---|
| front matter, Erin Tarn letters, the NGR | 1-24 | lore |
| FIRST-TIMER comic | 25-32 | art |
| body armor | 33-38 | 8 armor suits + 1 jet-pack accessory |
| power armor | 39-47 | 4 suits — **vessel-shaped** |
| robot vehicles | 48-81 | 12 robots — **vessel-shaped** |
| robot drones | 82-89 | 3 drones — **vessel-shaped** |
| enemy infiltration bots & borgs | 90-98 | 6 units — **vessel-shaped** |
| cyborgs | 99-116 | 5 borg models — **vessel-shaped** |
| combat vehicles | 117-140 | 20 vehicles, tanks and aircraft — **vessel-shaped** |
| **weapons** | **141-150** | ~30 line items incl. ammunition and grouped entries |
| **new high-tech equipment** | **151-152** | 3 groups: optics, medical, computers/translators |
| **new cybernetic implants** | **153-154** | 3 groups: eye augmentation, sensors, bionic weapons |
| **new skills** | **155** | 7 skills + a 3-language update |
| **new O.C.C.s** | **156-185** | 16 playable O.C.C.s |
| M.O.M. Conversion | 168-170 | a process description — **not an O.C.C.**, see below |
| Infiltration comic | 186-190 | art |
| Gargoyle Empire lore | 191-197 | lore |
| **optional player characters** | **197-201** | 4 playable R.C.C.s |
| gargoyles & technology, recognizing EIRs | 202-204 | lore |
| gurgoyle armor, power armor, robots | 205-209 | 1 armor + 3 **vessel-shaped** |
| **gargoyle & Kittani weapons** | **210-214** | 15 weapons |
| people & places, translations | 215-222 | lore |
| map | 223 | art |
| **Experience Tables** | **224** | the authority |

### Categories this book defines ZERO of

- **Spells.** Checked by stat-block scan across all 225 pages, not assumed: five
  pages carry a `P.P.E.:` line (183, 198, 199, 201, 220) and every one is a
  creature or class P.P.E. base, not a spell. The Gargoyle Mage on p.201 grants
  earth elemental magic and **points at Rifts Conversion Book One** for the spell
  descriptions; `cb1` is cached and the catalog already holds the Warlock
  classes, so those spells are reachable without this book defining any.
- **Psionic powers.** Three pages carry an `I.S.P.:` line (183, 184, 185) and all
  three are the Gypsy Seer and Gypsy — The Gifted drawing on the existing psionic
  lists. No page defines a new power.

## Classes

### Playable O.C.C.s (16) — printed 156-185

| class | printed | XP ladder on p.224 |
|---|---|---|
| Infantry Soldier | 157 | Combat Soldier & Police/Enforcement |
| Communications Officer | 158 | Comms / Medic / Field Mechanic |
| Medic/Medical Officer | 159 | Comms / Medic / Field Mechanic |
| Cyborg Soldier | 161 | Cyborg Soldier |
| Field Mechanic | 162 | Comms / Medic / Field Mechanic |
| Power Armor Commando | 164 | Power Armor Commando |
| Robot Combat Pilot | 165 | Robot Combat Pilot |
| Robot Soldier | 166 | Robot Soldier |
| Intelligence Officer | 171 | Intelligence Officer |
| Intelligence Commando | 172 | Intelligence Commando |
| Police Enforcement | 173 | Combat Soldier & Police/Enforcement |
| Euro-Juicer | 175 | Euro-Juicer |
| Gypsy Thief | 180 | Gypsy Thief |
| Gypsy Wizard Thief | 181 | Gypsy Wizard Thief |
| Gypsy Seer | 182 | Gypsy Seer |
| Gypsy — The Gifted | 184 | Gypsy — The Gifted |

p.156 marks **Robot Soldier** as optional. It has its own ladder on p.224 and a
full entry, so it is imported like the rest; the marking is a GM note and belongs
in `extraction_notes`.

### Playable R.C.C.s (4) — printed 197-201

**These four carry no ladder on p.224, and that absence is NOT the phase-world
Royal Kreeghor signal.** Each entry states outright that player characters use
another class's table, which is affirmative language about playability, and the
section heading on p.197 is *Optional Player Characters*. Read every one before
concluding from p.224 alone — this is the trap that cost the Phase World session
a wrongly-surveyed class in the other direction.

| class | printed | XP ladder |
|---|---|---|
| Gargoyle R.C.C. | 198-199 | borrows the psi-stalker's |
| Gurgoyle R.C.C. | 198-199 | borrows the psi-stalker's |
| Gargoyle Lord R.C.C. | 199-200 | borrows the dragon's |
| Gargoyle Mage R.C.C. | 200-201 | borrows the dragon's |
| Gargoylite R.C.C. | 201-202 | borrows the Dog Pack's |

**One entry, two creatures.** p.198 is headed for the gargoyle *and* the gurgoyle
together and then states them separately at every point that matters: two
attribute lines, two M.D.C. formulas, two horror factors, two running speeds, two
leap distances, and a skills list whose entries diverge by species (escape artist
is gurgoyle-only; swim is +10% for the gurgoyle and -10% for the gargoyle).
**Split it into two classes.** One row could not hold both without discarding
half of each, and the split is what the catalog does for the twelve Warlock
variants already.

That makes the count **five R.C.C. rows from four entries**, so the book's
playable total is **21 classes, not 20** — the back-cover blurb's "20 new
O.C.C.s" is marketing copy and counts neither the split nor the R.C.C.s
consistently. Do not use it as an authority.

All five borrow, and **two of the three named ladders resolve in this catalog
and the third does not.** Checked against production rather than assumed:
`psi-stalker` and `wild-psi-stalker` are published, and the dragon ladder is
carried by seven published `dragon-hatchling-*` rows plus `chiang-ku-dragon`.
**There is no row named Dog Pack.** The nearest is `dog-boy` (Dog Boy), and
whether Rifts prints the Dog Pack ladder as the Dog Boy's is a question to settle
from RUE before importing the Gargoylite — not an equivalence to assume from the
names. It is the one class in this section whose ladder is unresolved, and it is
unresolved on the catalog's side rather than the book's.

Whether a borrowed ladder can be *stored* at all is a separate question for the
import phase: if a class row carries its own experience table, these five need
the borrowed values copied in rather than a reference, and if it does not, the
reference belongs in `extraction_notes`. Read the frontmatter contract before
writing the first gargoyle row; do not infer it from this file.

### Excluded: M.O.M. Conversion (printed 168-170)

**Not a class.** It appears in the Contents between two O.C.C.s, which is what
makes it look like one, and it is absent from **both** authorities — not on the
p.156 roster, and no ladder on p.224. The pages describe a mind-transference
process, its failure modes and a body-deterioration schedule; there is no
`Attribute Requirements:` line, no `O.C.C. Skills:` list and no equipment. The
structural scan agrees: p.168-170 never reach two class markers. Importing it
would contradict both authorities.

### Class id collisions

No exact collisions among the 169 published classes, but three near-misses that
would read as duplicates in a picker:

| Triax class | already published | use |
|---|---|---|
| Robot Combat Pilot | `robot-pilot` (Robot Pilot) | `robot-combat-pilot` |
| Infantry Soldier | `soldier` (Soldier) | `ngr-infantry-soldier` |
| Gypsy Thief | `thief` (Thief) | `gypsy-thief` |

**Proposed convention: prefix the eleven NGR military and police classes
`ngr-`**, following the catalog's existing faction prefix (`coalition-samas-pilot`,
`coalition-juicer`). The book scopes them to the New German Republic and its own
divisions. The Gypsy, Euro-Juicer and gargoyle classes take no prefix. This is a
convention this import would **establish** for a second faction rather than
follow, so it is called out here rather than settled quietly.

## Catalog diff

Run against **production** (`--remote`) on 2026-09-06: 344 skills, 169 published
classes, 1,021 gear, 607 spells, 116 psionic powers.

### classes: 21 missing, 0 false gaps

Nothing in production cites this book for a class. The twelve rows whose markdown
matches `Triax` are the Warlock family and the Glitter Boy and Juicer, which name
Triax *equipment*; none is a Triax class.

### skills: 1 re-citation, 0 new rows, 6 false gaps

**This is the survey's most useful finding and it inverts the obvious plan.**
p.155 prints seven new skills, and the catalog already holds every one of them.
Six are false gaps, and RUE — the later, errata'd core book — defines them on its
own skill list at printed 302-306 and 311-325:

| p.155 prints | catalog holds | base | verdict |
|---|---|---|---|
| Basic Mechanics | `Basic Mechanics` | 30% +5% | false gap; RUE p.302 agrees, value matches |
| Lore — Magic | `Lore: Magic` | 25% +5% | false gap; RUE p.303 agrees, value matches |
| Lore — D-bee | `Lore: D-Bee` | 25% +5% | false gap; already cited to RUE |
| W.P. Battle Axe | `W.P. Axe` | base 0 | false gap; RUE defines it |
| W.P. Polearm | `W.P. Pole Arm` | base 0 | false gap; RUE defines it |
| Horsemanship: Exotic Animals | `Horsemanship: Exotic Animals` | 30% **+5%** | false gap — **but the books disagree**, see below |
| Streetwise — Drugs | `Streetwise: Drugs` | 25% +5% | **re-cite**, see below |

**`Horsemanship: Exotic Animals` is a genuine book-vs-book disagreement and the
catalog is already right.** Triax p.155 gives `30% +4%` with one percentile; RUE
printed 302 gives `30%/20% +5%` with two, and prints a full description at
printed 311. The catalog stores base 30 / per_level 5, which is RUE's reading.
Under this repo's standing doctrine — the later book wins and the losing number
is recorded — **no value changes**; Triax's `+4%` goes into `variant_note`. The
row is currently `source_book: NULL`, so it should be cited to RUE p.302 rather
than to this book. Flagged here because the uncited row plus a `+4%` on the page
in front of you reads exactly like a catalog error to correct, and correcting it
would move a value 148 published classes can reach.

**`Streetwise: Drugs` is the one real gain, and it is a re-citation.** The
catalog cites it to `Rifts Skill List` — the phantom compiled PDF that is not a
Palladium book and whose 43 remaining rows cite no cached page. Triax p.155
prints it, with the base the catalog already stores (25% +5%). A cache-wide
search finds it in exactly two books: `triax` (printed 155, plus in-class
references on 180 and 185) and `mystic-russia` (printed 143 and 155). Triax is
WB5 and Mystic Russia is WB18, so **Triax p.155 is the earliest real printing on
this machine**. Re-citing takes `rifts-skill-list` from 43 untraceable rows to
**42** — the same move the Phase World session made eight times.

**Three languages, one of which exists.** p.155 adds Gargoyle, Brodkil and
Demongogian to the common European set. The catalog holds `Language: Demongogian`
(filed `Technical`, which is where it sits rather than `Communications` — do not
"fix" that as part of this import). `Language: Gargoyle` and `Language: Brodkil`
are **genuinely missing** and are the only new skill rows this book yields.

So: **2 new skill rows, 1 re-citation, 1 re-citation of an uncited row to RUE, 0
corrections.** The extraction budget for skills is near zero, which is the whole
point of doing phase 3 first.

**Corrected 2026-09-06, by the NGR Army batch: that count was two rows short,
and the reason is a real limit of this section's method.** Everything above was
derived from printed 155, the book's own *New Skills* heading — and a class may
grant a skill the catalog lacks without the book calling it new. All three NGR
Army O.C.C.s grant **`Literacy: Euro`** and **`Language: Euro`** outright, and
the catalog held neither. Euro is not new to Triax at all: it is one of the nine
major languages of Rifts, named on RUE printed 304, which is exactly why printed
155 does not list it. Both rows were added by `add-euro-language-skills.sql`,
**cited to RUE p.302-304 rather than to this book**, at the catalog's own values
rather than RUE's printed `+3%` per level — the script's header carries the
argument for both decisions.

**So the remaining batches should expect the same shape** and not treat this
section as a closed list. The check that finds them is `class-check --remote` on
each draft, not another read of printed 155.

**A second disagreement, recorded before the gargoyle batch needs it.** Printed
155 lists Gargoyle, Brodkil and Demongogian as three separate languages. **RUE
printed 304 says Demongogian is itself the language of gargoyles and brodkil**,
which would make two of the three the same row the catalog already holds. Under
the later-book-wins rule that argues against adding `Language: Gargoyle` and
`Language: Brodkil` at all — but this book's own gargoyle R.C.C.s grant *speak
Gargoyle* by name and never mention Demongogian, so the two readings are not
merely a spelling difference. **Settle it in the gargoyle batch, from the R.C.C.
entries on printed 198-202**, and do not let the plan above decide it by
default.

### gear: ~55 importable rows, 1 existing row to resolve

`triax-pump-weapon` is the single production row citing this book, and it is
untraceable — `source_book: "Triax & The NGR"` with no page range, which is how
it shows as `triax 0 / 1` in coverage. Its description says outright that it is a
stub created by a class import and needs stats, and it is referenced by the
**twelve Warlock classes** from `cb1` as standard equipment.

The book prints **two** pump weapons and a shared ammunition rule, so the stub
does not resolve to one row:

| printed | entry |
|---|---|
| 141 | Pump Rounds — the ammunition, with costs |
| 143 | TX-5 Pump Pistol |
| 144 | TX-16 Pump Rifle |

Import both real rows, then give the stub a page range so it stops being
untraceable. **Do not retire or merge the stub in SQL** — twelve published
classes reference it by slug, and rewriting a referenced slug is the catalog
editor's duplicate-tool job, exactly as `add-juicer-uprising-skills.sql` records
for Interrogation Techniques and as the queue records for `W.P. Rope`. This is
the second of the two rows the kickoff session flagged as untraceable; the New
West one is the other.

## Extraction plan

Phase 4 costs money; everything above was free.

1. **21 classes** from pp.156-185 and 197-202, in batches by division —
   NGR Army (3), Armored Division (5), Intelligence & Police (3), Euro-Juicer (1),
   Gypsy (4), gargoyle R.C.C.s (5). Entries are in the standard shape the
   `class-import` skill expects and parse cleanly from the cache. Read each to the
   end and onto the next page: eight of the sixteen O.C.C. entries begin partway
   down a page.
2. **2 skill rows** — `Language: Gargoyle`, `Language: Brodkil`.
3. **2 re-citations** — `Streetwise: Drugs` to Triax p.155,
   `Horsemanship: Exotic Animals` to RUE p.302 with Triax's `+4%` in
   `variant_note`.
4. **~55 gear rows** from pp.34-38 (9 armor), 141-150 (~30 weapons and
   ammunition), 151-154 (optics, medical, computers, cybernetics), 205 (1 gurgoyle
   armor) and 210-214 (15 gargoyle and Kittani weapons). Read every number off a
   200 dpi render rather than the OCR, per the Phase World precedent.
5. **1 registry correction** — `printed_pages` 222 → 224.
6. **1 stub resolution** — TX-5 and TX-16 imported, `triax-pump-weapon` given a
   page range.

What is deliberately left, with the reason for each:

- **The book's ~53 vessels** — 4 power armor, 12 robots, 3 drones, 6 infiltration
  units, 5 borg models, 20 combat vehicles and 3 gurgoyle machines, across printed
  39-140 and 205-209. `BOOK-INGEST-AUDIT.md` **F3**: `gear` holds one `mdc`, one
  `damage`, one `range` and one `payload`, and a vessel here has M.D.C. by
  location and several numbered weapon systems with four stats each. This is
  roughly **107 of the book's 222 printed pages** — a larger share than in any
  book this batch has taken so far, and worth stating plainly rather than leaving
  as a footnote. F3's schema half closed in PR #616 with the keep-dropping
  decision and the limitation written into `docs/known-limitations.md`; nothing
  about that closure makes these rows importable.
- **M.O.M. Conversion**, printed 168-170 — a process, on neither authority. See
  above.
- **Earth elemental spells for the Gargoyle Mage** — the entry grants levels 1-3
  at fourth-level warlock proficiency and points at Conversion Book One for the
  descriptions. Check whether the catalog's existing warlock spell rows cover it
  before granting anything; if they do this costs nothing, and if they do not it
  is a grant with no gate, which is the F7 shape the Time Master import refused.
- **The five new-skill false gaps** — already in the catalog under RUE's
  spellings.

## Ledger

| date | PR | what went in |
|---|---|---|
| 2026-08-28 | [#400](https://github.com/NateGrey0130/nates-workshop/pull/400) | cache built (225 pp), registered in `books.json`, offset 0 measured — kickoff session, seven books |
| 2026-09-06 | — | surveyed: two authorities agreed, 21 playable classes established, skills diff came back near-empty |
| 2026-09-06 | [#776](https://github.com/NateGrey0130/nates-workshop/pull/776) | **batch 1, NGR Army (3 of 21 classes)**: Infantry Soldier, Communications Officer, Medic/Medical Officer. Classes 169 -> **172**, skills 344 -> **346** (`Language: Euro`, `Literacy: Euro`, both cited to RUE), gear 1021 -> **1024** (three stubs for the gear batch to fill). Applied `--remote` before the PR; production read back at 172/346/1024. |
| 2026-09-06 | [#777](https://github.com/NateGrey0130/nates-workshop/pull/777) | **batch 2, NGR Armored Division (5 of 21 classes, 8 cumulative)**: Cyborg Soldier, Field Mechanic, Power Armor Commando, Robot Combat Pilot, Robot Soldier. Classes 172 -> **177**, skills 346 -> **353** (seven machine-specific `Robot Combat Elite:` rows), gear 1024 -> **1025** (one stub). Filed `BOOK-INGEST-AUDIT.md` **F23** - the Robot Soldier grants no skills, because both ways its book gives it skills are shapes the app lacks. Applied `--remote` before the PR; production read back at 177/353/1025. |
| 2026-09-06 | [#778](https://github.com/NateGrey0130/nates-workshop/pull/778) | **batch 3, NGR Intelligence Division and police (3 of 21 classes, 11 cumulative)**: Intelligence Officer, Intelligence Commando, Police Officer. Classes 177 -> **180**, skills 353 -> **355** (two more machine-specific `Robot Combat Elite:` rows), gear unchanged at **1025** - the first batch needing no new gear row at all. Applied `--remote` before the PR; production read back at 180/355/1025. |

### What remains

Pasted from `node scripts/source-coverage.mjs --remote`, 2026-09-06:

```
BY BOOK       traceable / other
  triax                0 / 1
  rifts-skill-list     0 / 43
```

```
BACKLOG       rows an importer created and nobody finished
  gear stubs             7   description still says STUB — created by class import
  gear with no price    31   no cost and no cost_note to explain it
  skill stubs            5   created by an import and never given a base %, a bonus or a note
  spell stubs            2   level 0 and 0 P.P.E.
  psionic stubs          1   0 I.S.P.
  spell text missing     0   nothing for the codex to show
  psionic text missing   0   nothing for the codex to show
```

`triax`'s `other` is exactly one row and it is `triax-pump-weapon`: cited to this
book with **no page range**, which is the `no-page-range` bucket rather than
`not-cached`. It is also one of the seven **gear stubs** in the BACKLOG block, so
finishing it moves two lines at once. Both should move in this book's first data
PR.

`rifts-skill-list`'s 43 sit in `not-cached` and are not this book's, but one of
them is: `Streetwise: Drugs` is re-cited by the plan above, which takes that
count to 42. Nothing else here should move — a Triax import that changes `spell
text missing` or `psionic text missing` has done something the survey did not ask
for, because this book defines zero of both.
