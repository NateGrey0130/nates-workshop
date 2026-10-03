# Rifts World Book 31: Triax 2 — survey

**Status:** `surveyed` — inventory and catalog diff done; the plan below follows the standing precedents, nothing imported yet. (2026-10-03)

**Rows citing this book:** none

Slug `triax-2`. Cached 2026-10-03 from `Rifts- World Book 31 Triax 2.pdf`,
194 PDF pages, **text layer**: `--probe` median 5,244 characters a page, 36.1%
stop words, no private-use glyphs.

*Facts about this book, not prose from it — see `book-survey` §7. Keep this
line.*

The 2010 sequel to `triax` (WB 5). About a third is setting (the gargoyle war
104-109 P.A., the NGR's cities, citizens and D-Bee policy, printed 8-68). The
rest is a machine catalog: Triax commercial goods and civilian vehicles,
domestic robots, weapons, body armor, power armor, drones, robots, combat
vehicles, aircraft, one O.C.C. with its airframes, and mobile bases. There is
no skill list, no spell or psionic list and no experience table.

## Page offset

**Read from `scripts/books.json`**, where this survey's PR registers it.

`page_offset: 1` — cache file page = printed folio + 1, so printed folio F is
`p<F+1>.txt` and `read-columns.py <F+1>`.

| cache page | folio printed on it | read from | offset |
|---|---|---|---|
| `p012` | 11 | text layer | +1 |
| `p050` | 49 | text layer | +1 |
| `p100` | 99 | text layer | +1 |
| `p150` | 149 | text layer | +1 |
| `p180` | 179 | text layer | +1 |
| `p193` | 192 | text layer | +1 |

One region. **`printed_pages` is 192**: `ocr-book.py` reported 191 because
the folio on `p193` sits mid-text rather than at the foot. `p194` is the back
cover; `p001`-`p004` cover and credits, `p005`-`p006` Contents and Quick Find.

## Cache health

- `welded_pages`: `p003` (credits) and `p044` (the NGR map page). Neither
  holds a stat block.
- `corrupt_pages`: none.
- `substituted_digits`: 39 pages, heaviest `p186` (7), `p137` (6), `p156`
  (5), `p187` (5). All are in the machine chapters. **Every number in a stat
  block is read off a render**, as for every vessel batch since Warlords of
  Russia: the text layer returns stat lines beside line art out of order.

## The book's authority tables

| cache page | printed | table | settles |
|---|---|---|---|
| **p005-p006** | 4-5 | *Contents* | every section's first page and every named machine |
| **p006** | 5 | *Quick Find* | a second index; it repeats the Contents' page numbers |

There is no experience table. The one O.C.C. (printed 165-168) names its
ladder in its own entry, read at import.

## Inventory

Counted from the Contents and confirmed by stat-block markers in the cache
(`M.D.C. by Location`, `Cost:`, `Mega-Damage:`, `Attribute Requirement`).

| printed | section | entries | kind |
|---|---|---|---|
| 8-68 | the war, the NGR, its cities and citizens, D-Bees | prose | setting |
| 17-19 | Jinna Gir Song | 1 | notable NPC (quick stats) |
| 30-32 | Struwwelpeter ("Dream Peter") | 1 | notable NPC |
| 65-68 | General Rasheen | 1 | notable NPC (quick stats) |
| 73-76 | Triax commercial products: meal paste maker, energy supplements, cosmetics | ~8 | gear |
| 76-84 | civilian cars, trucks, bikes, hover vehicles, WR wilderness vehicles, RRK and WaffenTek vehicles | ~20 | vehicles (S.D.C. and M.D.C.) |
| 85-89 | available features and add-on weapon systems for vehicles | ~40 options | price list |
| 89-95 | domestic robots V-100, V-200, V-250, V-1000 and the V-500 robot pets | ~5 | vehicles (`robot`) |
| 96-106 | pistols, rifles, giant-size and TX-H weapons, shields, WaffenTek energy weapons | ~25 | gear |
| 107-109 | body armor: T-1011-X2 Cyclops Booster, T-25 "Uber" Super-Exoskeleton, TD-10 Sea Cyclops | 3 | gear / vehicle |
| 110-125 | power armor: X-11 Predator II, X-21 War Eagle, X-80 Butterfly, X-700 Fat Boy, X-710 Hell Angel, X-1001 Ulti-Max II, Jaeger weapon systems | 6 | vehicles (`power-armor`) |
| 126-131 | drones: DV-39 Wolf, DVO-1, EIR-60, EIR-70 | 4 | vehicles (`drone`) |
| 132-156 | robots: X-1471 Wolfhound, X-2010 Longstrike, X-2020 Rainmaker, X-2525 Faust, X-2730 Griffon, X-2750 Talon, X-4500 Gunman, X-4600 Sharpshooter, X-5050 Black Death, X-5001 Devastator Mk II | 10 | vehicles (`robot`) |
| 157-164 | XM-350 Rhino, XM-279 Earth Lifter, XM-199 Phoenix | 3 | vehicles |
| 165-168 | Luftwaffe Cyborg Combat Pilot O.C.C. and its bionics | 1 class | class + `cybernetics` gear |
| 169-176 | XML-280 Black Eagle, XML-283 Wraith, XML-285 Ghost airframes; XLH hardpoint weapon pods | 3 + pods | vehicles (`borg`) + gear |
| 177-192 | drop forts and deployment pods, NGR Undertow, TX-MISB mobile strike base, IA-30 and AA-50 APCs | ~6 | vehicles |

## Catalog diff

Run against **production** (`--remote`) on 2026-10-03.

- **Vehicles:** every machine named in the Contents was checked against all
  55 rows citing `triax` and by name across the whole table. **None is held.**
  The near-names are earlier models, not reprints: `X-10A Predator` against
  the X-11 Predator II, `X-1000 Ulti-Max` against the X-1001 Ulti-Max II,
  `X-5000 Devastator` against the X-5001 Mk II, `XM-350 Leopard III APC`
  against the XM-350 Rhino, CWC's `SF-7 Talon` against the X-2750 Talon.
- **Gear:** the 22 held `TX-` and Triax weapon rows were compared by model
  number. None of this book's weapons is held (TX-6, TX-17, TX-23, TX-25,
  TX-27, TX-46, TX-75, TX-222, TX-249, TX-252, TX-SS01, TX-A1, VS-101, the TX-H
  series, TX-001/TX-002 shields, the WaffenTek line). `T-10 Infantry Cyclops`
  is held and the T-1011-X2 Cyclops Booster is a different suit.
- **Notable NPCs:** Jinna Gir Song, Struwwelpeter and General Rasheen are not
  held. Victor Lazlo is (Africa); his printed-46 update is prose.
- **Classes:** the Luftwaffe Cyborg Combat Pilot is not held.

Each batch re-diffs its own rows against production before its script is
written (`book-survey` §4).

## Extraction plan

Render-first extraction by agents, every row checked by `book-reconcile`
before the apply, as Warlords of Russia's vessels were.

| # | batch | rows | notes |
|---|---|---|---|
| 1 | gear: commercial products, weapons, shields, body armor, hardpoint pods, the pilot's bionics | ~45 | gear before the class, which names the bionics |
| 2 | civilian vehicles and domestic robots, printed 76-95 | ~25 | S.D.C. machines carry `is_mega_damage = 0` |
| 3 | power armor and drones, printed 107-131 | ~11 | the T-25 Super-Exoskeleton prints M.D.C. by location and goes here |
| 4 | robots, combat vehicles, aircraft, printed 132-164 | ~13 | |
| 5 | the O.C.C., its three airframes and the mobile bases, printed 165-192 | 1 class + ~9 | airframes are `borg` vessels, as the Warlords cyborg bodies were |
| 6 | notable NPCs | 3 | through `bestiary-sql.mjs` |

**Defaults taken, by precedent, without a separate decision:**

- **The vehicle features and add-on weapon systems (printed 85-89) are left
  out**, as Warlords of Russia's generic vehicle price lists were (its D4).
  They are options on another machine, not items a character carries.
- The Autobahn random encounter table (printed 50) and the setting prose are
  left out.
- A machine is one `vehicles` row with its locations and weapons; a weapon a
  character can buy on its own is also a `gear` row.

## Ledger

| date | branch | what went in |
|---|---|---|
| 2026-10-03 | `pal/data/triax-2-survey` | cache built (194 pp, text layer), `triax-2` registered in `books.json`, offset +1 verified at eight folios, this survey. No rows. |
