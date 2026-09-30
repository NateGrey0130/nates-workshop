# Survey: MA4 The Fantastic Four Compendium (TSR6889)

Marvel Super Heroes Advanced Set accessory, David E. Martin, 1987. Registry
entry: `scripts/msh/books.json` -> `ma4`. Measured 2026-09-30.

**Rows citing this book:** none yet. This is the survey PR: a registry entry
and this file, no characters, items or D1 rows.

This is the fourth Marvel book. It went through `scripts/msh/` only. **It is
MA1's kind of book** (one sourcebook, one numbering, a printed Contents and
index, three columns), so [ma1.md](ma1.md) is the nearest worked example,
**but its stat grid is set differently**, and the difference decides the
parser (below).

## The scan

- 98 PDF pages, a pure scan: `scripts/msh/ocr-book.py ma4 --probe` medians
  0 text-layer characters over 20 sampled pages.
- Cached with `python scripts/msh/ocr-book.py ma4` into the main checkout's
  `.cache/msh/books/ma4/`: all 98 pages in 1m39s.
- The print is clean and Tesseract reads the body well. The grids' digits
  are the weak spot: in a `--psm 6` crop, `(30)` reads `(80)` or `(380)`
  and `(50)` reads `(80)`, 24 times over the book. The rank code beside each
  number catches every one (below).
- The PDF was copied to `C:\Users\natha\Projects\workshop\books\`, beside
  the other three.

| PDF | printed | what |
|---|---|---|
| 1 | - | front cover |
| 2 | 1 | art, Contents, credits |
| 3-97 | 2-96 | the book; the index is printed 96 |
| 98 | - | back cover |

## Offset

**printed = PDF - 1.** `scripts/msh/survey.py` reads a folio on 78 pages and
all 78 agree; none disagrees. The index's own folio (96 on PDF 97) says the
same.

## The book's own authority lists

- **Contents (printed p.1).** Nine entries and no sub-entries: Introduction
  and A Brief History (2), The Fantastic Four (3), Friends of the FF (11),
  Races and Organizations (25), Fiends and Foes (38), Travel Guide (76),
  Vehicles (93), Index (96). **Every one agrees with its page:** each banner
  is the first line of PDF 4, 12, 26, 39, 77, 94 and 97. Stored as
  `sections`; there are no `contents_errata`.
- **Index (printed p.96).** 173 names and 176 page references, transcribed
  by eye from crops of its three columns, as MA1's was. Stored as `index`.
  Two names have more than one page: Baxter Building (the range 76-78) and
  Hydro-Base (33 and 83). The index mixes characters, races, locations,
  items and vehicles, and names each character by code name.

## What an entry looks like

```
NAME                           bold capitals, 1.09-1.17x the body line height
Real name / alias line         bold mixed case: "Reed Richards", "(pre-Nova)"
F  GD  (10)   Health: 46       seven rows: letter, rank CODE, then (number);
A  GD  (10)                    Health, Karma, Resources, Popularity to the
S  TY  (6)    Karma: 40        right, on rows F, S, R and P, each with a colon
E  EX  (20)
R  GD  (10)   Resources: RM(30)
I  GD  (10)
P  GD  (10)   Popularity: 20
KNOWN POWERS:                  "Italic Name: text" paragraphs
WEAKNESS: / WEAKNESSES:        on 20 entries
TALENTS:  CONTACTS:  BACKGROUND:  RUNNING <NAME>:   run-ins, in this order
```

**The grid is the difference.** MA1 prints `F 20 Ex  Health = 106`, number
before code, and `roster.py`'s `ROW` needs the number first. MA4 prints the
code first and the number in parentheses, and labels with a colon. So MA1's
row reader reads **no MA4 grid**, and `survey.py` finds 0 blocks (its
`Health =` anchor and its row pattern are MA1's).

**Header height fails, as on ME1.** Measured on the TSV: body lines box at a
median of 35 px (p95 37), and every character header at 1.09-1.17 times
that. MA1's 1.35 rule finds none. Every character has a grid, so the header
can be found from the grid (`gridbooks.mark_headers`), not from its size.
Two headers sit beside art and did not OCR at all: Thundra (p.20) and Gorgon
(p.29).

**Values the parser must accept as printed:**

| printed | where |
|---|---|
| `CL1000`, `CL3000`, `CL5000` and **also** `C1000`, `C3000` with no number | Class ranks; the High Evolutionary (p.22) prints the C form, Ego (p.61) the CL form |
| `X (150)`, `Y (200)`, `Z (500)` | Shift ranks, as a bare letter (Ego, Giganto, Punisher I) |
| `Shift 0` | Giganto and the Turtle Transports (p.34) |
| `RE (30)` | Stingray, p.18: the book's misprint of RM, aliased |
| `N/A` in a rank | Destroyer (p.47), Living Computers of Xandar (p.91) |
| `Resources: none`, `N/A`, `N.A.`, `CL3000` | robots, Ego, Terminus |
| `Popularity: Special`, `-500`, `8(75)`, `9 (80 among Inhumans)` | Hate-Monger III, Terminus, Thundra, Karnak |
| a grid with no Popularity line | 19 grids: creatures, tiers, alternate forms |
| `Physical ranks Vary` and only R, I, P | the New Men, p.90 |

## Stat blocks: 129 full grids, plus one partial

Found by re-reading every `Health` label's column from a `--psm 6` crop of
the page image (a scratch script, not committed; the parser PR does this
for real), and checked against the book's own arithmetic:

| measure | count |
|---|---|
| full seven-row grids | 129 |
| partial (R, I, P only) | 1, the New Men |
| read with seven rows from the crop | 123; the other 6 read by eye on the image, and all 6 add up |
| codes with an unrepaired number | 0, once `(80)` is read as the code's own 30 or 50 |
| Health = F+A+S+E and Karma = R+I+P | all but **7**, each read on the page |
| not checkable (an `N/A` rank) | 2 |

By section: The Fantastic Four 10, Friends of the FF 27, Races and
Organizations 19, Fiends and Foes 65, Travel Guide 8 plus the New Men.

**The seven misprints, each read off the page image:**

| entry | printed | the book's own arithmetic |
|---|---|---|
| Guardsman, p.20 | Health 90 | F+A+S+E = 20+20+40+50 = 130 |
| Karnak, p.30 | Karma 60 | R+I+P = 10+50+20 = 80 |
| Alpha Primitives, p.31 | Health 66 | 6+6+30+30 = 72 |
| Skrull-X, p.52 | Health 165 | 40+30+50+75 = 195 |
| Diablo, p.58 | Karma 66 | 30+6+20 = 56 |
| Hate-Monger III, p.64 | Health 18 | 6+6+6+10 = 28 |
| Molecule Man, p.66 | Karma 89 | 10+2+75 = 87 |

No rank code disagrees with its printed number anywhere: every mismatch the
OCR showed was a digit misread, and the image has the rank's own number.

## Quote marks

Six quoted phrases were read on the page image (pp. 17, 24, 65, 78, 82,
86). Every one is a **double** quote that the OCR gave as single marks or as
U+FFFD. No single-quoted phrase was found, so this book looks like MHSP1
(every single mark a misread) rather than MA1. The data PR should confirm
it on more pages before `pair_quotes` relies on it.

## Entry kinds

1. **Character.** One grid for one being: most of the book.
2. **Versions: two cards, one person.** Frankie Raye (p.11, pre-Nova) and
   Nova II (p.49); two Human Torches, the current one (p.6) and the android
   Human Torch I (p.74), who are different beings. The Hate Monger (p.63) and
   Hate-Monger III (p.64) are different beings too.
3. **Forms.** The Thing prints a second grid for his human form (p.5).
4. **Two characters, one code name.** Destroyer (p.47, the armour) and the
   header DESTROYER on p.58, which the index calls Darkoth the Death
   Destroyer. Doctor Doom (p.38) and Doctor Doom II (p.41, Kristoff), with a
   third grid on p.40, Victor von Doom II, that the index does not name.
5. **Generic tier.** A typical member of a race or a kind of robot: Inhuman
   (p.26), Atlanteans (p.33), Guardian Robots (p.39), Guardbots and Killer
   Robots (p.40), Skrull, printed as the typical warrior (p.51), the Moloids
   and Tyrranoids (one grid, p.89), Lava Men (p.89), Pseudo-Skrulls (p.85),
   the four Central City breeds (Burners, Clobbers, Head-Brothers, Winged
   Flyers, p.82, as run-ins), and the four Elementals (pp. 59-60).
6. **Member without a block.** Names under a heading, with no grid: the
   Notable Skrulls on p.51 (run-ins: Jaketch, Raksorr, Skragg, Warlord
   Morrat, Xalxor, Zendrao and others) and the Prominent Atlanteans on p.33
   (a capitalised name and one identity line each: Andromeda, Arkus, Byrrah,
   Coral, Dara, Dorma and others).
7. **Team.** Grids that follow a team heading: the Frightful Four (p.53),
   the Super-Apes (Igor, Mikhlo, Peotor, pp. 68-69) and Salem's Seven (seven
   grids, pp. 70-72).
8. **A grid on something that is not a character.** The Turtle Transports,
   inside Atlantean Equipment's items (p.34), and Galactus's Cat (p.44).

## What is not character-shaped

- **Items.** Run-in items under Atlantean Equipment (p.34: Water-Breathing
  System, One-Man Propulsion System, Proteus Horn, Turtle Transports), the
  Skrull weapons (p.51), Galactus's Ships (p.43) and the Survivors' Fleet
  (p.49). Mechanics are ranks in the prose.
- **Travel Guide (printed 76-92).** Locations, each under its own header,
  from the Baxter Building (76-78, with floor plans and numbered room keys)
  to Xandar (91). Some are statted: Central City's breeds, the Pseudo-Skrulls,
  Subterranea's peoples, the New Men and the Living Computers of Xandar.
- **Vehicles (printed 93-95).** Eight vehicles, each under a header: the
  Fantasticar, Fantasticopter, Intercontinental Passenger Missile, Negative
  Zone Explorer I, Pogo-Plane, Reducta-Craft, Sky-Cycles and the Skrull
  Starship. **There are no Control/Speed/Body lines** as MA1's vehicles have;
  speeds and ranks are in the prose.
- **There is no adventure**, so nothing here needs `adventure`.

## Decisions this survey leaves open

1. **The reader.** A new `layout` for code-first grids, reusing
   `roster.read_entries()` as `gridbooks.py` does, with its own row pattern
   (`CODE (N)`), the colon labels and grid-anchored headers. **Recommended**
   over teaching MA1's `ROW` a second order, since MA1's live data depends on
   that pattern. Either way, MA1, MHSP1 and ME1 are proved byte-identical
   before it merges.
2. **The misprints.** MA1's override shape, printed and corrected, for the
   seven above.
3. **Teams.** The Contents has no team sections, so the teams are the book's
   own groupings: Fantastic Four, Friends of the FF, Inhumans, Atlanteans,
   Skrulls, Frightful Four, Super-Apes, Salem's Seven, and Fiends and Foes
   for the rest. **Inhumans and Skrulls are ME1's team names already**, and a
   team name is a filter group shared by every book. Recommended: share them,
   because they are the same peoples.
4. **Characters already carded by another book** (`data/npcs.json`,
   2026-09-30) become second cards with `-ma4` ids, as agreed 2026-09-28:
   - MHSP1: Galactus, Galactus's Cat, Doctor Doom, Mister Fantastic, the
     Human Torch, She-Hulk, the Molecule Man
   - ME1: the Silver Surfer, Firelord, Ego, Black Bolt, Medusa, Karnak,
     Gorgon, Triton, Crystal, Maximus, Lockjaw, and the typical Skrull
     warrior

   ME1's Nova is not MA4's Nova II (Frankie Raye), so that is a new card.
5. **The Travel Guide and Vehicles.** Import the locations and vehicles as
   items, as MA1's were, or characters only, as for ME1? They are the larger
   part of this book that is not characters (printed 76-95).
6. **Members without a block** (the Notable Skrulls, the Prominent
   Atlanteans): names under their tier, as MA1's Gladiators are, unless the
   text gives ranks to build from. Dorma has a grid of her own (Lady Dorma,
   p.36), so her Prominent Atlanteans line is a cross-reference.

## The next PRs

1. **Parser** (`msh/feat/ma4-parser`): the reader, and `character_pages`,
   `teams` and `index_aliases` in the registry.
2. **Data** (`msh/data/ma4-fantastic-four`): `npcs.py` and `extras.py`, the
   overrides, the D1 load before the merge, and this file's Rows line.

## How to reproduce

```bash
python scripts/msh/ocr-book.py ma4
```

```bash
python scripts/msh/survey.py ma4
```

Set `WORKSHOP_MSH_CACHE` to the main checkout's `.cache/msh` when running from a
worktree.
