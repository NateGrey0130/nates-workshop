# Rifts World Book 22: Free Quebec — survey

Slug `free-quebec`. Cached 2026-08-28 from `Rifts- World Book 22 Free Quebec.pdf`,
194 PDF pages, **text layer** (no OCR), read with `scripts/read-columns.py`.

*Facts about this book, not prose from it — see `book-survey` §7. Keep this
line.*

## Page offset

**Read from `scripts/books.json`; not re-derived.**

`page_offset: 1` — cache file page = printed folio + 1, so printed folio F is
`p<F+1>.txt` and `read-columns.py <F+1>`. This is the registry's commonest
offset and it is the one this book has.

No `page_offset_exceptions`, and this was checked **end to end** rather than
taken as a whole-book vote, because `underseas` proved a vote can hide a split.
Nine samples spread across the book, each read off the folio the page itself
prints:

| cache page | folio printed on it | offset |
|---|---|---|
| `p030` | 29 | +1 |
| `p050` | 49 | +1 |
| `p110` | 109 | +1 |
| `p130` | 129 | +1 |
| `p150` | 149 | +1 |
| `p185` | 184 | +1 |
| `p190` | 189 | +1 |
| `p192` | 191 | +1 |
| `p193` | 192 | +1 |

Constant at +1 from the front of the book to the last numbered page.

**`printed_pages` in the registry is `192` and the book's last printed folio is
`192`** — `p193`. `p194` is an unnumbered back-cover advertisement. Unlike the
`triax`, `bom` and `new-west` notes, the registry is **exactly right here** and
needs no correction.

## Text-layer quality, and the two pages that are genuinely scrambled

Median ~4,900 characters a page. Stat-block labels survive intact:
`Attribute Requirements:`, `O.C.C. Skills:`, `M.D.C. by Location:`, `Weight:`,
`Free Quebec Cost:`, `Payload:` all parse. Printed 37 is empty in the cache and
is a full-page illustration, not damage — it falls in the middle of the
"Descended" Glitter Boy Pilot entry, which is why that class must be read
**36 then 38**.

Curly quotes, em-dashes and the `�` replacement character are present and must
be stripped before any SQL.

**Two pages of 194 are out of reading order in the cache, and no column reader
can fix them.** `read-columns.py` buckets *blocks*; on these two pages `pymupdf`
returned a **single block whose own lines alternate between the two columns**,
so the damage is inside the block the reader is sorting.

| cache page | printed | what is welded | why it matters |
|---|---|---|---|
| `p043` | **42** | the Reloader O.C.C.'s `Money:` and `Cybernetics:` lines interleaved with its quarters prose | this is a `starting_money` field, and no test checks that field |
| `p059` | **58** | the Glitter Boy Transport's M.D.C.-by-location footnotes interleaved with its wing-damage rule | asterisk footnotes attach to the wrong locations |

Both were de-welded by reading the page's word geometry directly and re-splitting
on the x-midpoint against the page centre. The de-welded readings:

- **Printed 42, Reloader O.C.C.** — *"Monthly salary is 2100 credits. Starts off
  with one month's pay."* and *"Cybernetics: Starts with clock calendar and
  gyro-compass, plus select one additional cybernetic implant or bionic eye.
  Otherwise restricted to medical implants and prosthetics."*
- **Printed 58, GB Transport** — *"Inner Reinforced Cockpit Compartment — 100"*,
  *"** Main Body (cargo bay to rear) — 998"*, and the single-asterisk footnote
  *"Items marked by a single asterisk are small and/or difficult to strike. A
  character must make a 'called shot,' but even then the attacker is -3 to
  strike."* The wing rule is the OTHER column: *"Destroying one wing will reduce
  speed 10% and inflict a -20% penalty to the piloting skill. Destroying both
  wings reduces speed to 172 mph (277 km) and inflicts a -15% penalty."*

This is exactly the Juicer Uprising failure shape — a `starting_money` figure
sitting in text that does not read in the order it looks like it reads. Filed as
`BOOK-INGEST-AUDIT.md` **F30**: nothing detects a weld, and the cache gives no
sign that a page is wrong.

**A page that merely breaks mid-word across the gutter is NOT this.** Printed 45
reads `...Quebec weapon tech-` at the foot of column one and `nology. Well, at
least a partial breakthrough...` at the head of column two, and that page is
fine — it is ordinary two-column typesetting, and `book-survey` §0 already says
so. It was misread as scrambled once during this survey before the geometry was
checked. **Check the geometry before filing a page as damaged.**

## The book's authority tables

| page | table | states |
|---|---|---|
| **4-5** | *Content* | section ranges and per-item page numbers for the whole book |
| **34** | *O.C.C.s of the Free Quebec Military* | the percentage roster of who serves, and what is **absent** |
| **33** | *O.C.C. Overview & Reference* | which existing O.C.C.s are and are not found here |

**This book has NO Experience Table**, and that is a real absence rather than a
page not found: `Experience Table` appears nowhere in 194 pages, and the closest
thing — printed 190-192 — is adventure hooks. So the roster question has a
**single authority, the Contents**, and `phase-world` is the standing warning
about that: its Royal Kreeghor was surveyed as playable off the Contents alone
and the section heading said *NPC Villains*.

**So every class below was confirmed against its own stat-block markers**
(`Attribute Requirements:`, `O.C.C. Skills:`, `Standard Equipment:`) rather than
against the Contents, and each section heading was read.

The two authority tables that DO exist are worth reading for what they exclude,
because it is unusually specific. Printed 33-34 states the book's own negative
roster: **no practitioners of magic, no Crazies, no mutant animals or Dog Boys,
no D-Bees, no Psi-Stalkers, no psychics, no Skelebots** in Free Quebec or its
military. That is why the categories below come out as they do.

## Inventory

| category | count | where | verdict |
|---|---|---|---|
| **O.C.C.s** | **6 entries, 10 classes** | printed 32, 36-38, 38-39, 39-40, 41-42, 114-123 | **import** |
| **Vessels** | **22** - the survey projected 23; the QR-2 Abolisher Prime turned out to carry no stat block at all | printed 53-134 | **import** |
| **Gear** | **~18** | printed 43-51 | **import** |
| **Skills** | **0 new** | — | nothing to import; see the diff below |
| **Spells** | **0** | — | the book defines none |
| **Psionic powers** | **0** | — | the book defines none |
| **R.C.C.s** | **0** | — | the book has none; it is a human-supremacist nation book |

### Spells and psionics are zero, and this was scanned rather than assumed

`book-survey` phase 1 asks for this explicitly, so here is the scan:

| marker | pages carrying it |
|---|---|
| `P.P.E. Cost:` | **0 of 194** |
| `Saving Throw:` | **0 of 194** |
| `I.S.P.:` | **0 of 194** |
| `Spell Level` | **0 of 194** |

There is no spell import and no psionic import from this book, and the reason is
the book's own setting: printed 33 bans practitioners of magic from the nation
and printed 34 gives psychics a roster share of **`-0-`**. The absence is
editorial, not a gap in the scan.

### Classes — six entries, ten classes

| # | class | printed | note |
|---|---|---|---|
| 1 | le Surete du Quebec "Deep" (undercover) Intel Agent | 32 | complete on one page |
| 2 | The "Descended" Glitter Boy Pilot | 36, **38** | printed 37 is a full-page illustration |
| 3 | Glitter Girl Pilot | 38-39 | female-only by its own attribute requirement |
| 4 | Side Kick RPA (Military Power Armor Pilot) | 39-40 | **a declared copy** — see below |
| 5 | Glitter Boy Munitions Expert / "Reloader" | 41-**42** | printed 42 is a **welded** page |
| 6 | Free Quebec Cyborg Soldier | 114-115 | **plus four chassis** — see below |
| 6a | — FX-200C Imprimer | 115-116 | |
| 6b | — FX-320C Dervish | 117-118 | |
| 6c | — FX-340C Slasher | 119-120 | |
| 6d | — FX-370C Leviathan | 121-123 | |

**#4 is a declared copy.** Printed 39 says outright: *"These are basically the
same as the Elite RPA Pilot O.C.C. described in the Rifts RPG, page 53, except
their main type of power armor is the Side Kick... The stats are reprinted here
for the reader's convenience, along with modifications appropriate to the Quebec
Military."* Per `declared-copy-pairs` this ships as a **full class plus
`copy_of`**, not as a pointer — and the copy is the side that carries the
Quebec modifications, so where the two disagree the copy is the right side.

**#6 is four chassis and the `variants` block cannot hold them.** The book gives
one base O.C.C. (printed 114-115) and then four full-conversion bodies, each of
which *adds* skills to the base list and *reduces* the related-skill picks from
six to three. `VARIANT_OVERRIDES` admits `attribute_dice`,
`attribute_requirements`, the four pool bases, `starting_money`, `bonuses` and
`skill_overrides` — and `skill_overrides` restates the percentage of a skill the
class **already grants** and explicitly cannot add one. Neither the added skills
nor the changed pick count is expressible.

So they ship as **five separate classes**, each restating the eleven shared basic
skills. That is the duplication `variants` exists to prevent, and it is filed as
`BOOK-INGEST-AUDIT.md` **F31**. The four bodies are ALSO vessel rows — a
full-conversion cyborg here has M.D.C. by location and numbered weapon systems,
exactly like a power armor.

### Skills — zero new, and the diff says so with one dominant substitution

Fifty-two skill names were pulled from the six class entries and run against
production:

```
skills (--remote): 367 rows | book: 52 entries
matched 36  disagree 0  missing 16  extra 331
```

**All sixteen "missing" resolve to rows the catalog already has.** Every one is
a naming difference, which is `book-survey` phase 2's *"a dominant single
substitution is a vocabulary difference, not N corrections"* in its purest form
— here the substitution is the catalog's category prefix, or its own house
spelling:

| the book prints | the catalog holds |
|---|---|
| Surveillance Systems | `Surveillance` |
| Power Armor/Robot Combat Elite: Glitter Boy | `Robot Combat Elite: Glitter Boy` |
| Pilot Automobile | `Automobile` |
| Pilot Hovercraft, Pilot: Hover Vehicle | `Hover Craft (ground)` |
| Pilot Tank & APC | `Military: Tanks & APCs` |
| Read Sensory Equipment | `Sensory Equipment` |
| General Athletics | `Athletics (general)` |
| Basic Math, Math: Basic | `Mathematics: Basic` |
| Advanced Math | `Mathematics: Advanced` |
| Underwater Demolitions | `Demolitions: Underwater` |
| Climb | `Climbing` |
| Field Armorer | `Field Armorer & Munitions Expert` |
| W.P. Heavy Weapons | `W.P. Heavy Military Weapons` |
| W.P. Heavy Energy Weapons | `W.P. Heavy M.D. Weapons` |

Two more matched only through an alias and are naming drift rather than gaps:
`Radio: Scrambler` → `Radio: Scramblers`, `Tracking` → `Tracking (people)`.

**So this book adds no skills row.** It is the first book in the batch where the
answer to phase 2 is zero across the board for skills, spells and psionics — and
the reason the diff was worth running anyway is that sixteen false gaps is
exactly what a session extracts sixteen unnecessary rows from.

### Gear — printed 43 to 51

Free Quebec's own manufacture, all of it priced:

| item | printed | Free Quebec cost |
|---|---|---|
| Mini-HUD System | 44 | 15,000 |
| Q1-01 Laser Pistol | 44-45 | 10,000 |
| Q1-02 "Stopper" Ion Pistol | 45 | 12,000 |
| Q2-10 Laser Pulse Rifle | 45 | 16,000 |
| Q2-20 LLG "Infantry Standard" | 45-47 | 26,000 |
| Q2-30 Rapid-Fire Heavy Laser | 46-47 | 35,000 |
| Q4-40 "Mule" Assault Rifle | 47-48 | 15,000 |
| Q4-44 "Drummer" Double-Barreled Shotgun | 47-49 | 4,500 |
| Q5-50 Light Rail Gun | 48 | 32,000 |
| QN-06 Laser Harpoon Gun | 48-49 | 15,000 |
| — Standard harpoon | 49 | 6 |
| — Radio/Transmitter harpoon | 49 | 200 |
| — Flare harpoon | 49 | 15 |
| — High Explosive harpoon | 49 | 600 |
| QEBA-10 Environmental Battle Armor | 49-50 | 42,000 |
| JEBA-13 Juicer EBA | 50-51 | 40,000 |
| TX-J50 Juicer EBA | 51 | 50,000 |
| Stun/Flash Grenade | 43 | 100 |
| Tear Gas Grenade | 43-44 | 200 |

**No Free Quebec gear or vessel row exists in the catalog today** — checked
`--remote`, `source_book LIKE '%Quebec%'` returns zero from both `gear` and
`vehicles`. Three published classes mention Free Quebec in prose (`glitter-boy`,
`robot-pilot`, `coalition-juicer`) and all three are other books' rows.

### Vessels — printed 53 to 134

Twenty-three, and they are the centre of gravity of this book rather than an
appendix. The `vehicles` / `vehicle_locations` / `vehicle_weapons` tables from
migration 048 hold them; `triax` shipped 55 and `underseas` its own set through
the same shape.

| # | vessel | printed | class |
|---|---|---|---|
| 1 | Cougar Hover Jeep | 53-55 | vehicle |
| 2 | Bobcat Hover Cycle | 55-56 | vehicle |
| 3 | GB6-96 Glitter Boy Transport | 57-59 | vehicle |
| 4 | RHV-60 Reloader Hover Vehicle | 60-61 | vehicle |
| 5 | QR-1 Enforcer Prime | 63-65 | robot |
| 6 | QR-2 Abolisher Prime | 65-66 | robot |
| 7 | QR-3 Guardian Robot | 66-69 | robot |
| 8 | Classic Glitter Boy | 81-83 | power-armor |
| 9 | Triax Glitter Boy | 84-86 | power-armor |
| 10 | Glitter Girl | 87-91 | power-armor |
| 11 | Glitter Boy Side Kick | 92-94 | power-armor |
| 12 | Tarantula Glitter Boy | 95-97 | power-armor |
| 13 | Taurus Glitter Boy | 98-100 | power-armor |
| 14 | Silver Wolf Glitter Boy | 101-104 | power-armor |
| 15 | QPA-201 Power Trooper | 105-107 | power-armor |
| 16 | QPA-101 "Pale Death" SAMAS | 107-110 | power-armor |
| 17 | "Violator" SAMAS (V-SAM) | 111-113 | power-armor |
| 18 | FX-200C Imprimer | 115-116 | borg |
| 19 | FX-320C Dervish | 117-118 | borg |
| 20 | FX-340C Slasher | 119-120 | borg |
| 21 | FX-370C Leviathan | 121-123 | borg |
| 22 | NS-B20 'Borg Dive Armor | 129 | borg |
| 23 | Sea Dragon | 130-132 | power-armor |

**The catalog holds one Glitter Boy vessel today and it is Triax's `T-550`.**
The Classic Glitter Boy — the USA-G10 that the whole line descends from — is not
in it. This book is where it arrives.

## What is deliberately NOT imported

Named here so it is on the record as a decision rather than an omission.

**Cross-references to other books' rows.** Printed 43-44 lists the old-style CS
weapons the Quebec Military uses (C-18, C-10, C-12, C-14, C-27, CR-1, C-40R, CS
Vibro-Blades, CS Neural Mace) and gives **page numbers into the Rifts RPG
instead of stats**. Printed 44 does the same for Triax's TX-5, TX-11 and TX-26
and Northern Gun's NG-P7; printed 51-52 does it for Urban Warrior, Plastic Man,
Huntsman and Bushman body armor; printed 52-53 does it for Mark V APCs, Spider
Skull Walkers, Sky Cycles and the CS Command Car. **The book prints no numbers
for any of them**, so there is nothing to extract — importing them would mean
copying another book this catalog may or may not hold, under this book's
citation.

**Existing O.C.C.s the book merely lists.** Printed 33-35 is a reference chapter:
which Rifts RPG, Coalition War Campaign, Rifts Canada and Rifts Mercenaries
classes are found in Free Quebec, and at what percentage. Five Headhunter types
are named on printed 34 with no stats. No new class is defined there.

**Named NPCs.** Printed 127 (Commodore Jacques LeFevre), 142 (Prime Minister
James Lorne), 151 (Colonel Robert Miller) and 175 (les Soldats de St. Jean's
leader) are individual stat blocks — attributes, Hit Points, S.D.C., age,
disposition — for specific characters, not classes. They are setting.

**Setting and narrative.** The Coalition-at-war chapter (printed 6-31), Free
Quebec's history and worldview (printed 133-153), Old Bones (printed 152-184)
and the adventure hooks (printed 185-193).

## The plan

| batch | what | PR |
|---|---|---|
| 1 | this survey; queue → `surveyed` | — |
| 2 | gear, printed 43-51 | |
| 3 | classes: Deep Intel Agent, "Descended" GB Pilot, Glitter Girl Pilot | |
| 4 | classes: Side Kick RPA, GB Munitions Expert/"Reloader" | |
| 5 | classes: Free Quebec Cyborg Soldier + four chassis | |
| 6-9 | vessels, in four slices by page range | |
| 10 | findings implemented; queue → `imported` | |

**A vessel belongs to the slice its NAME HEADING falls in** — the rule the
`triax` vessel scripts state at the top of every file, and the reason no vessel
there is split across two files or imported twice.

## Ledger

*What went in, in which PR, and what it moved. Appended before each PR opens,
per `class-import` — "the ledger line goes in the same PR as the work it
describes".*

| PR | batch | rows | catalog total after |
|---|---|---|---|
| #818 | survey; queue `cached` -> `surveyed` | 0 | unchanged |
| #819 | gear, printed 44-51 | **17** | gear 1236 -> **1253** |
| #820 | classes: all five O.C.C.s of printed 32-42 | **5** | classes 215 -> **220** |
| #821 | vessels, printed 52-134, in four slices | **22** | vehicles 105 -> **127** |

### Batch 2 — gear (PR #819)

Seventeen rows: ten weapons, three suits of body armor, the Mini-HUD optic and
the four harpoon types the QN-06 fires. Applied `--remote` before the merge and
read back at 17; `gear` total 1236 -> 1253.

**Five rows this batch did NOT add, because the catalog already had them at the
prices this book prints.** The grenade and flare block of printed 43-44 —
Stun/Flash Grenade at 100, Tear Gas Grenade at 200, Flare at 1, Parachute Flare
at 10, and Smoke Grenade — all exist and all agree. Checked `--remote` before
the file was written. That is the gear-side twin of the skills diff: the same
false-gap shape, and the same reason to run the check rather than extract from
the page.

**The Q4-44 "Drummer" prints a black market price ten times its own.** 4,500
credits retail, and then *"45,000-50,000 credits"* on the black market — the
identical figure the Q4-40 Mule two entries earlier gives for a gun that retails
at 15,000. It reads like a copied line. **Stored as printed**, with the
`cost_note` saying outright that the figure is suspect and why. A guess at what
was meant would be indistinguishable from a number the book gave, which is the
argument the `cost` column's own comment makes about inventing prices.

**Gear ordering is why this batch went first.** The class scripts reference gear
slugs in `equipment_starting`, and `class-check --remote` emits a stub `INSERT`
for any slug the catalog does not have. A stub written into `add-<id>-class.sql`
sorts before `add-free-quebec-gear.sql` and would win on a clean rebuild. Gear
applied `--remote` first means there is nothing to stub.



### Batch 3 — the five O.C.C.s of printed 32-42 (PR #820)

Five O.C.C.s, applied `--remote` before the merge: the SQ Deep Intel Agent,
the "Descended" Glitter Boy Pilot, the Glitter Girl Pilot, the Side Kick RPA
and the Glitter Boy Munitions Expert. `imported_classes` published and live
215 -> 220, and both pinned counts move with it: the clean-run table in
`docs/operations.md` and the README's hit-point-silence sentence, which goes
from *one-hundred-and-ten of two-hundred-and-fifteen* to
*one-hundred-and-fifteen of two-hundred-and-twenty* — all five state no hit
point formula and no `mdc_base`.
point formula and no `mdc_base`.

**`CORE_SDC_BY_CLASS` gained three entries**, which is a `book-survey` §8 tier-1
edit and not a code change: the smoke test fails any class stating neither an
S.D.C. nor an M.D.C. formula without one. This book does not sort its O.C.C.s
into Palladium's men-of-arms and scholar sections, so as with `underseas` the
skill lists are the argument, and it is recorded in the table itself: **3D6** for
both Glitter Boy pilots (Elite GB combat training, two W.P.s granted outright,
Weapon Systems, Military open), **1D6** for the Deep Intel Agent, whose combat
grant is Hand to Hand: Basic and two W.P.s of choice and whose own related-skill
list reads *"Military: None"*.

**Both money figures were checked against the page with `--field-sources`**, not
just read. Each is a complete paragraph well clear of a page break: 4,200-6,000
for the agent (low end stored, per the range convention) and 3,200 for both
pilots. This is the check that would have caught the two Juicer Uprising errors.

**Most of the Glitter Boy pilots' bonuses are NOT in `bonuses`, and that is the
book's doing.** Both O.C.C. Bonus lines end *"All bonuses, other than H.F., apply
only when piloting a Glitter Boy"*, and `bonuses:` is applied unconditionally —
so the +1 strike, the roll and pull-punch bonuses, the initiative ladders and the
+1 attack at levels 5/11 and 4/10 are all `special_abilities` entries naming the
condition. Only the Horror Factor ladder is stored as a bonus, through `at_level`.

**The +10 S.D.C. is stored unconditionally and the printed sentence arguably does
not allow it.** Read strictly, *"all bonuses other than H.F."* includes the
S.D.C. It is stored anyway, because an S.D.C. bonus that applies only inside a
Mega-Damage power armor is inert by construction — the character is not taking
S.D.C. damage in there — so the conditional reading makes the line mean nothing.
Recorded in both classes' `extraction_notes` rather than resolved.

**Two findings came out of this batch:**

- **F32** — `attribute_requirements` holds minimums only, and the Deep Intel
  Agent's *"P.B. of 12 or lower"* is a **ceiling**. Writing it there would state
  the exact inverse of the book and render to the player as `PB 12+`. It is in
  `restrictions` instead, which displays it and enforces nothing.
- **F33** — the gear catalog holds the same item twice under two slugs (four
  pairs verified), found while resolving this class's `equipment_starting`. Not
  this book's rows. Filed **without** a merge script on purpose: three detectors
  were written this session and every one produced false positives or missed a
  known pair.

**Three `equipment_starting` slugs were corrected rather than stubbed.**
`class-check --remote` reported `plastic-man-armor`, `bushman-armor` and
`language-translator` missing and offered stub SQL for all three. All three
already exist under different slugs
(`plastic-man-full-environmental-body-armor`,
`bushman-full-composite-environmental-body-armor`,
`portable-language-translator`). Accepting the stubs would have created three
duplicate rows — the exact shape F33 is about.

**The Glitter Girl's "Must be female" is in `restrictions`.** The book prints it
inside the Attribute Requirements line, and that block is a flat map of the eight
attributes; there is no sex or gender on a character to check against. Not filed
as a finding: unlike F32 it does not invert anything, it simply has nowhere to go.
**`CORE_SDC_BY_CLASS` gained five entries** — a `book-survey` §8 tier-1 edit,
not a code change: the smoke test fails any class stating neither an S.D.C. nor
an M.D.C. formula without one. This book does not sort its O.C.C.s into
Palladium's men-of-arms and scholar sections, so as with `underseas` the skill
lists are the argument, and it is recorded in the table itself. **3D6** for the
two Glitter Boy pilots, the Side Kick and the Reloader; **1D6** for the Deep
Intel Agent, whose combat grant is Hand to Hand: Basic and two W.P.s of choice
and whose own related-skill list reads *"Military: None"*.

**The Reloader is the one that needed an argument.** By the Underseas
reasoning — Hand to Hand: Basic, two W.P.s — it reads as 1D6. Two things
outweigh that, and both are the book being explicit rather than a judgement
about a skill list: printed 41 says outright that *"Loaders are also combat
trained soldiers who will not hesitate to fight"*, and printed 34 lists Reload
Teams on the **army's own roster** of military O.C.C.s, as *"EOD Specialists
(includes Reload Teams)"*. Underseas had no sentence like that to read, which
is why its scientists went the other way.

**All four money figures were checked against the page with `--field-sources`.**
4,200-6,000 for the agent (low end stored), 3,200 for both pilots, 2,400 for the
Side Kick, and **2,100 for the Reloader, which came off a welded page** and was
read from word geometry instead — printed 42 is one of F30's two pages, and the
field it welds is `starting_money`. That is the Juicer Uprising failure shape
arriving by a different route, and it is the one number in this batch that the
cache alone would have got wrong.

**Most of the Glitter Boy pilots' bonuses are NOT in `bonuses`, and that is the
book's doing.** Both O.C.C. Bonus lines end *"All bonuses, other than H.F., apply
only when piloting a Glitter Boy"*, and `bonuses:` is applied unconditionally —
so the +1 strike, the roll and pull-punch bonuses, the initiative ladders and the
+1 attack at levels 5/11 and 4/10 are `special_abilities` entries naming the
condition. Only the Horror Factor ladder is stored as a bonus, through
`at_level`. The Reloader splits the same way and the book splits it *for* us: its
first bonus block is explicitly limited to mechanical operations, and a second
block headed *"Other O.C.C. bonuses"* is not.

**The +10 S.D.C. is stored unconditionally and the printed sentence arguably does
not allow it.** Read strictly, *"all bonuses other than H.F."* includes the
S.D.C. It is stored anyway, because an S.D.C. bonus that applies only inside a
Mega-Damage power armor is inert by construction — the character is not taking
S.D.C. damage in there — so the conditional reading makes the line mean nothing.
Recorded in both classes' `extraction_notes` rather than resolved.

### What this batch got wrong first, and what caught it

**`regression.mjs` failed the first three classes** on
`no class GRANTS the placeholder row as a fixed skill`. `Language: Other` and
`Literacy: Other` are placeholder rows — they exist to be picked from, and
naming one as a fixed skill leaves the character holding a skill called,
literally, *"Literacy: Other"*. All five classes were rewritten to offer both
through choice groups.

**The three already applied `--remote` were replaced rather than patched.** They
were fifteen minutes old, no PR had merged, and `--remote` confirmed **zero
characters** referenced them, so the rows were deleted and the corrected scripts
re-applied. An `add-` plus `fix-` pair is the right shape for a class that has
shipped; it is the wrong shape for one that never existed publicly.

**Chasing it turned up F34**: the literacy family has that guard and the
**language family does not**, twenty lines above it in the same file. Fifteen
published classes name `Language: Other` as a fixed skill today and nothing
says so — `ngr-police` carries the note *"Select one additional language
(+10%)"* on an entry that offers no selection. None of the five here does.

**Two more things `class-check` caught before they shipped**, both the same
shape — a cross-category `only` that would have been *granted but not takeable*:
the Reloader's *"Rogue: Pick Locks only"* (the catalog files Pick Locks under
Espionage) and the Descended pilot's and Side Kick's *"Espionage: Wilderness
Survival only"* (filed under Wilderness). Each is offered under the skill's real
category restricted to that one name, which is what the book's two printed lines
mean together.

**Three `equipment_starting` slugs were corrected rather than stubbed.**
`class-check --remote` reported `plastic-man-armor`, `bushman-armor` and
`language-translator` missing and offered stub SQL for all three; all three
already exist under different slugs. Accepting the stubs would have created three
duplicate rows — the exact shape **F33** is about, which is how F33 was found.

**Two classes ship without the vehicle their own book issues them.** The Side
Kick RPA starts with a Side Kick power armor and the Reloader with an RHV-60
Reloader Hover Vehicle; both are `vehicles` rows and `equipment_starting` can
only reference `gear` slugs. Recorded in each class's `restrictions` where a
player will see it. **F3**, and the same cost the Noro Mystic Warrior paid. The
two Glitter Boy pilots escape it only because a pre-migration-048
`glitter-boy-power-armor` row still exists in `gear`.

**The Side Kick declares itself a copy and ships without `copy_of`.** Printed 39
calls it *"basically the same as the Elite RPA Pilot O.C.C. described in the
Rifts RPG, page 53"*. No such class is in this catalog, and the nearest one —
`robot-pilot`, Rifts Ultimate Edition p.83-85 — is a different class with
different attribute requirements, so declaring a copy of it would assert a match
that does not hold and fail the regression's copy sweep.



### Batch 4 — the vessels (PR #821)

Twenty-two vessels, 222 `vehicle_locations` rows and 129 `vehicle_weapons` rows,
applied `--remote` before the merge. `vehicles` 105 -> 127.

| slice | printed | rows |
|---|---|---|
| `p052-069` | 52-69 | 6 — Cougar, Bobcat, GB6-96 Transport, RHV-60, QR-1, QR-3 |
| `p079-104` | 79-104 | 7 — the whole Glitter Boy line |
| `p105-123` | 105-123 | 7 — three power armor and the four FX cyborg bodies |
| `p124-134` | 124-134 | 2 — NS-B20 Dive Armor and the Sea Dragon |

**Twenty-two, not the twenty-three the survey projected.** The QR-2 Abolisher
Prime is deliberately not a row: printed 65-66 gives it a heading, a paragraph
and a height, then *"For complete stats and additional information, see Rifts
World Book 11: Coalition War Campaign, pages 134-137."* No Model Type, no Crew,
no M.D.C. by Location, no Cost, no Weapon Systems anywhere in this book. F3's
own reasoning applies exactly — a row keeping one field out of twenty is worse
than no row, because it reads as complete.

**The Classic Glitter Boy enters the catalog here.** Before this batch the only
Glitter Boy vessel was Triax's T-550, imported with that book; the USA-G10 the
whole line descends from was missing.

### The number that was wrong, and how it was caught

**Printed 95's text layer is corrupt, and one of the corrupted characters is a
digit inside a table that looks fine.** The cache gives the Tarantula Glitter
Boy's QST-333 Shaker Cannon as **115** and its Vibro-Blade as **"5Q"**. Rendered
at 200 dpi the page reads **175** and **50**.

The Vibro-Blade announces itself — `5Q` is not a number. The Shaker Cannon does
not: 115 is a plausible M.D.C. figure in a column of plausible figures, and it
is wrong by sixty points. **An extraction pass over the cached text reported 115
in good faith**, and it was caught only because the same page's scrambled prose
forced a render, which happened to show the M.D.C. block too. That is luck, and
it is filed as **F36**.

The render also resolved the entry's underwater rule, unreadable in the cache:
**laser range underwater is increased by 50%**, while plasma, ion and rail are
all halved.

### What the extraction was told to record rather than resolve

Every one of these is stored as the book prints it, with the disagreement in the
row's own note:

- The **Sea Dragon's vibro-fins** carry two different damage figures four lines
  apart — 1D6+2 M.D. in the weapon line, 1D6/2D6 in the prose above it.
- The **RHV-60's jet M.D.C. reads backwards**: its six "small" directional jets
  carry 85 each and its six "main" hover jets 40.
- The **QR-1 is the only vessel in the book with no Free Quebec price**, giving
  a black market figure alone where every other entry leads with one.
- The **Slasher's cost is spelled out in words** where every other vessel uses
  numerals, and its armor note is shaped differently from its three siblings'.
- The **Leviathan's asterisks do not resolve** — five weapon mounts carry one
  and the entry's only footnote is the head-kill rule, which cannot apply to a
  thruster.
- The **QR-3's maximum depth is printed "4000 feet (1219 km)"**, where the
  metric figure should read metres.
- The **Classic Glitter Boy's Boom Gun is printed "RG-IS"**. It is stored as
  **RG-15**, and the reason is internal to the book rather than a guess: the
  Tarantula's optional replacement Boom Gun on printed 97 is printed RG-15 and
  points back at the Classic for its stats.

**The Leviathan's row is assembled from two slices.** Its heading is on printed
121 so it belongs to the p105-123 file, but its hand-to-hand bonuses and damage
table are on printed 124, in the next slice's range. Both readings reported the
seam, which is what made the complete row possible rather than a truncated one.

**Printed 58's welded page cost nothing here** because F30 was already filed and
the extraction was told about it: the GB6-96 Transport's M.D.C. footnotes were
read from the page's word geometry rather than from the cache.