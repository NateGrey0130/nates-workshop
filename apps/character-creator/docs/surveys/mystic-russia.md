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

**Experience Tables — printed 172 (cache `p173`).** Eight ladders covering
fourteen classes, several of them shared:

| ladder | covers |
|---|---|
| 1 | Night Witch, Mystic Kuznya |
| 2 | Russia Sorcerer (the book's own name for the Ley Line Walker) |
| 3 | Gypsy / Hidden Witch |
| 4 | Necromancer |
| 5 | Old Believer |
| 6 | The Slayer, Gypsy Layer of Laws |
| 7 | Gypsy Thief, Gypsy Enforcer |
| 8 | Fire Sorcerer, Gypsy Seer |
| 9 | Gypsy Beguiler, Gypsy Wizard-Thief |

**A TRAP WORTH THE WHOLE SECTION: the heading is split across two lines.** The
column reader put `Experience` on line 1 and `Tables` on line 2, so
`grep -i 'Experience Table'` over the cache **returns this page zero times** and
finds only the contents entry at printed 4 and a mention at printed 71. The
single most valuable page in the book is invisible to the obvious search. Search
for one word, or for the class names.

**And the experience table is NOT the roster** — the third book in a row where
that holds, after `new-west` and `spirit-west`. It lists fourteen and the book
defines more; the Gifted One and the Born Mystic have no ladder here.

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

### The book tags playability per entry, and several creatures are playable

Same shape as `spirit-west`. Tags found across the bestiary:

| entry | tag |
|---|---|
| Polevoi | player character or villain |
| Rusalka | player character and villain |
| Domovoi | NPC or villain, with an optional-player-character paragraph |
| Leshii | same |
| Spirit Wolf | NPC and villain, with an optional-player-character paragraph |
| Man-Wolf | NPC and villain |
| Vodianoi | NPC and villain |

The Necromancer's entry carries a line saying a player character of that class
is not recommended — a recommendation rather than a rule, and it is a full
O.C.C. with a ladder.

**How many of the ~69 bestiary pages are playable is NOT settled here.** The
tags above came from a pattern sweep, not from reading every entry, and that is
the single biggest open question before extraction.

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

**The five disagreements are levels, not names, and they are a decision rather
than a correction** — `book-survey` §4c. The catalog holds each of these from
another book:

| spell | catalog level | this book |
|---|---|---|
| Circle of Flame | 5 | 3 |
| Fire Fists | 6 | 3 |
| Fire Ball | 6 | 5 |
| Swords to Snakes | 9 | 8 |
| Healing Water | 6 | 10 |

Four of the five are cheaper here and one dearer, so this is not a single
systematic offset. **Settle it with the first spell PR, with both readings in
hand**, and record the losing number in `variant_note` rather than discarding it.

**The 131 are not hand-checked for false gaps yet.** The nearest-candidate
column shows no obvious mis-parse — the distances are large and the names are
plainly Russian-flavoured — but `book-survey` §3 says roughly one in twenty is a
false gap, so budget for ~6.

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

## Extraction plan

Nothing below is committed to. This is the proposal to agree on.

| # | batch | size | notes |
|---|---|---|---|
| 1 | the four spell traditions | ~131 rows | one batch per tradition, each carrying its own `Level N` headings as the authority. Spoiling and Nature are small enough to pair |
| 2 | the O.C.C.s | ~15 classes | `class-import`, one PR per two or three |
| 3 | the playable bestiary entries | unknown, ≤7 | **blocked on reading the tags properly**, which is free and not yet done |
| 4 | gear | ~20 | the bio-wizardry list at printed 107 needs its numbers read as dice expressions, not as printed |
| 5 | vessels | ~8 | same shape as Triax, Free Quebec and Spirit West |

**Left out, and why:** every bestiary entry the book tags NPC-only; the setting
and history chapters; the Steeds table until it is classified.

**The order that matters:** spells before classes. Nine of the fourteen classes
are spell casters, and a class citing a spell the catalog does not hold fails
its check.

## Ledger

Nothing shipped yet. The book is at **`surveyed`**.

### What remains

Everything. `source-coverage.mjs --remote` (2026-09-12) does not list
`mystic-russia` — no production row cites this book.
