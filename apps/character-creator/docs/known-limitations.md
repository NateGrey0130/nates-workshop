# Known limitations and refactor candidates

The honest list, roughly by value.

Part of the [character creator](../README.md) documentation.

---

## Known limitations and refactor candidates

Honest list, roughly by value.

The planned PRs and the two shipped proposals are recorded under
[`docs/plans/`](plans/README.md) with their design decisions and rejected
alternatives. The rules audit against the source books — the class-data
corrections and the schema work that came out of them — is in
[`docs/rules-audit.md`](rules-audit.md).

The one refactor candidate that had earned itself is done: six places composed a
class by hand and now none do. See
[One place composes a class](../README.md#one-place-composes-a-class).

**An R.C.C. with no related or secondary skills is correct, not a gap.** Those
come from the O.C.C. a character takes alongside its race, so `relatedAllowance`
returning 0 for the Chiang-Ku Dragon is the right answer rather than a missed
extraction. Listed here only so it is not "fixed" — see
[A race and an occupation together](race-and-occupation.md#a-race-and-an-occupation-together) for how
the O.C.C. half is now carried.

**Which O.C.C. a race may take was the largest unenforced rule in the app, and
it is enforced now.** Every one of the fourteen Palladium Fantasy player races
prints an "O.C.C.s Available to X" line and eight are real restrictions rather
than "any": a dwarf may take no magic O.C.C. at all, a kobold no long bowman,
knight or palladin, a troll no psychic P.C.C., and the troglodyte is held to six
occupations by name. All of it was transcribed into each race's `restrictions:`
block, which is **display-only** - the player was told and nothing stopped them.

This entry stays in the list because the reasoning is worth keeping, not because
anything is outstanding. Two keys carry it now, both
in class markdown like `xp_table`, neither needing a migration:

| key | on | what |
|---|---|---|
| `occ_group` | all 59 O.C.C.s — 25 Palladium, 34 Rifts | one of `clergy`, `men-of-arms`, `optional`, `magic`, `psychic` |
| `occ_restrictions` | 10 races — the 8 Palladium ones, plus the Norse Giant and the Warriors of Valhalla | `only: [...]` **or** `except: [...]`, never both |

Entries are class ids or `group:<name>`. **Groups are the point.** *"A dwarf may
take any O.C.C. except magic"* is a rule about a group; written as a list of the
four magic classes the catalog holds today it would silently stop covering the
fifth — and a restriction that quietly stops restricting is worse than none,
because nothing says it happened.

The groups are the **book's own**, taken from the section each class is printed
in: Clergy, Men of Arms (78-95), Optional O.C.C.s (96), the Ways of Magic (100)
and Psychic Character Classes (156).

**The Rifts side went without this key for months, and that was two silent
failures waiting.** `occ_group` was set on the 25 Palladium O.C.C.s and on none
of the 34 Rifts ones, so a `group:` token matched *nothing* on the Rifts side —
and which way that fails depends on which list it is in:

| written | resolves to | effect |
|---|---|---|
| `only: ["group:men-of-arms"]` | nothing matches | fails **closed** — the race can take nothing |
| `except: ["group:magic"]` | nothing matches | fails **open** — the race can take everything |

The second is the dangerous one, and it is the same shape as the Godling's dead
`except` that reached production and went unnoticed for months. Nothing was
broken in practice only because every existing user of a group token — dwarf,
gnome, goblin, troll — is a Palladium race restricting Palladium occupations,
where both sides had the key. `zz-rifts-occ-groups.sql` closes it, using RUE's
own section headings: Men of Arms (45-85) plus Coalition Military (231-237),
practitioners of magic (100-135), psychics (139-156), and Adventurers & Scholars
(86-99). Those are the same headings `CORE_SDC_BY_CLASS` cites for its 3D6/1D6
split, so the two tables agree by construction rather than by coincidence.

Two calls in that script are worth knowing. **Adventurers & Scholars are filed
as `optional`** — the five group names are fixed in `OCC_GROUPS` and none of
them is "adventurer", and `optional` carries the closest meaning, being
Palladium's own heading for the O.C.C.s that are neither men of arms nor spell
casters. And the **two Psi-Stalkers are `psychic`** even though
`CORE_SDC_BY_CLASS` gives them a man-of-arms 3D6: that table's comment says why
— *psychics by the book's grouping, but hunters by trade* — so the S.D.C.
follows the trade and the group follows the book.

**A group cannot carve out an exception.** "Any men of arms *other than* CS or
NGR military" is not expressible as `only: ["group:men-of-arms"]` minus three,
so a race stating one has to enumerate ids and say so in its notes. The Norse
Giant is the first to hit this.

**Every name must resolve.** A class id with no class silently *allows* exactly
what it meant to forbid, so the parser rejects one and regression checks it over
the live catalog — the same hazard an `only` naming a skill with no catalog row
carries. Three of the book's names needed mapping, and each race's note records
which: *black priest* is the Priest of Darkness (printed 68 says so in as many
words), *monk* is the Warrior Monk, *vagabond* is the Vagabond/Peasant/Farmer.

**One bar is deliberately unenforced.** The troll may take no psychic P.C.C. and
no *illusionist* — and there is no illusionist row, because the main book names
it among the practitioners of magic on printed 100 and never prints one. Naming
it would be naming nothing, so it lives in the note and the psychic half is
enforced.

The wizard shows barred occupations **disabled rather than hidden**, under a
*"Not open to a Dwarf"* group with the reason beneath — a player looking for the
Knight should learn that the race forbids it, not that the app has no Knight.
The server refuses one on create, because a disabled `<option>` is a hint and
not a rule, and a draft restored from before the field landed arrives the same
way.

No live character was affected: all nine are on races that carry no restriction.

### And the mirror: which races may take an occupation

`race_restrictions` is the same shape on an **O.C.C.**, and it is the half the
Juicer needed. Its abilities add to an existing person, and the book is specific
about which person: *"Racial Requirement: 95% human"* (RUE p.81).

**`none` is the human case**, and it is why this key needs a reserved word
rather than a race id. **Rifts prints no Human R.C.C.** — RUE's contents list
exactly one Racial Character Class, the Dragon Hatchling on printed 156 —
because human is the default and the unstated, which is why a Rifts O.C.C.
stands alone in the first place. So *"human only"* is not a race to name; it is
the **absence** of one, and `only: ["none"]` says that.

These O.C.C.s carry a hard bar. The count is deliberately not given here — it
grew from seven to twelve in a single import and will grow again; `regression.mjs`
names the seven the rule was written against and checks they still carry it,
which is the part that cannot drift. The founding seven:

| class | the book's line |
|---|---|
| Juicer | 95% human (p.81), **widened** — see below |
| Psi-Stalker, Wild Psi-Stalker | *"Psi-Stalkers are mutant humans only"* (p.152, 155) |
| Coalition Grunt | *"Humans and Psi-Stalkers only"* (p.230) |
| Coalition SAMAS Pilot, Technical Officer | *"Racial Restrictions: Human."* (p.233, 237) |
| Dog Boy | a CS-made mutant canine — the Dog Boy **is** the race (p.142) |

Six of the seven already recorded the rule in prose. **The Coalition Grunt did
not** — its markdown says a great deal about Coalition doctrine toward
non-humans and never states the restriction the book prints. That one was found
by reading the book rather than the class.

**What gets nothing, deliberately:** the eight O.C.C.s whose racial line is a
*statistic* rather than a bar — *"None, although only about 20% are D-Bees"*,
*"None; half are D-Bees"*. A percentage of who happens to play one is not a
rule, and turning it into a restriction would forbid characters the book allows.

**And one of the seven has since been widened.** Rifts World Book 10: Juicer
Uprising, printed 16-17, has a *Non-Human Juicers* section that qualifies RUE's
one-line racial requirement: Dwarves take the standard process unpenalised,
Elves need tailored drugs, Ogres are close enough to human for any conversion,
and True Atlanteans qualify and live longer for it. Trolls, Orcs, Goblins and
Giants cannot at all, nor can dragons, shapeshifters or supernatural beings.
The Juicer therefore reads `only: ["none", "dwarf", "elf", "ogre"]`, and the
Hyperion and Phaeton variants drop `dwarf` again — their reflex enhancements
burn out the Dwarven nervous system.

**RUE does not overrule this even though it is later.** RUE p.84 ends the Juicer
entry by naming all seven variants and pointing at that book: a cross-reference,
not a restatement. Its *"95% human"* is the summary line of an entry that then
tells you where the qualifications live.

**The list stays an `only`, which fails closed**, so widening it cannot loosen
anything that was already refused. Two things it cannot yet say: there is no
True Atlantean R.C.C. row, so that allowance sits in the note until one exists
(the Priest of Light mechanism — a restriction written ahead of its row); and
`dwarf`, `elf` and `ogre` are Palladium Fantasy rows, which the book itself
invites by calling these races Palladium-World D-Bees, but which the wizard's
per-system filter keeps out of a Rifts game today regardless.

Both directions are checked in the same two places, and either may refuse: the
picker filters on both, and the server runs both on create.

### Dead code, and the check that keeps it gone

**There is no dead code left to find, and a check keeps it that way.** An audit
scanned every export in `apps/`, `functions/`, `scripts/` and `shared/` for a
name nothing else mentions — counting HTML as a consumer, because the wizard
binds inline handlers — and every Pages Function route for a leaf the client
never names. It found **four** exports and **no** unreachable endpoint:

| | why it was there |
|---|---|
| `compose.js` `applyMos` | only ever called inside its own file. Now un-exported, which enforces what the README already said — `composeClass` is the one entry point — more firmly than the smoke check that guards `combineClasses` |
| `catalog-match-lib.mjs` `looseCounts`, `stemCounts` | written beside `aliasCounts` for the both-sides check and never called by anything, from the PR that added them onward. `aliasCounts` is what the check uses |
| `ocr-fields-lib.mjs` `READERS` | a label-to-reader index whose own comment claimed *"used by an extractor"*. Never was. The readers it indexed are all used individually and stay |

`no export is named nowhere else` now fails the smoke run, so the next one is
caught rather than accumulating. Each removal leaves a comment saying what stood
there and how many lines reviving it costs.

### Deliberate stopping points

**The catalog editor has no general delete.** Rows are created and corrected by
hand; the only deletion is the one a merge performs. Deliberate — see
[`docs/plans/04-catalog-edit-ui.md`](plans/04-catalog-edit-ui.md).

**Part of the gear catalog is still name-only stubs.** A class import creates
a stub row for every equipment id it cannot find, so the catalog holds a row
per name any class has ever mentioned. Production carried 157 of them; 33 were
orphaned by later class corrections and referenced by nothing at all, and
`retire-orphan-gear-stubs.sql` drops those.

That retirement partly failed open: its "referenced by nothing" guard matched
only fixed `item_id:` citations, and 20 of the 33 were still cited inside
choice-group `from:` lists by eight live classes (class audit F2, 2026-08-25).
`zzz-resolve-choice-group-gear.sql` restores the four with book entries on
this machine as real rows, restores the Warlock's Triax pump weapon as a stub
(its stats are in Triax & The NGR), and rewrites the category citations to
enumerate real slugs. The smoke test now parses every published class and
resolves its referenced gear — choice lists included — against the gear table,
so a retire or a rename can no longer fail open this way.

The count went 123 — 78 by fixing the ones that were the wrong SHAPE and
pricing the ones a web reference could settle. **What is left is left for a
reason**, and the reasons differ:

- **About a dozen pieces of named hardware** — the Juicer's bio-comp, drug
  harness and flex plate armor, the Techno-Wizard converted weapons, the
  archaic M.D.C. armor of the pantheon, the optic helmet. Their stats appear
  to exist only in books. What the open web returns for them is forum
  argument with contradictory numbers and no citable page.
- **Four rows that name a CATEGORY, not an item** — `submachine-gun`,
  `musical-instrument`, `basic-provisions`, `lesser-rune-weapon`. These are the
  same defect [Starting gear the class leaves open](wizard-and-sheet.md#starting-gear-the-class-leaves-open)
  describes, and they cannot be fixed the same way yet: a choice is only an
  improvement if its options exist, and the catalog holds no sub-machine gun,
  no rune weapon and no instrument to offer. Import the equipment chapter
  first, then convert them.
- **A long tail of ordinary objects** — clothing, traveling clothes, food
  rations, mirrors, gloves, sleeping bags. No reachable source prices them,
  and for food there is a reason: pricing for food and drink is absent from
  most of the books outright. A class grants "a week's food rations" as a line
  of text and no page says what a week costs.

None of it blocks play. A stub is a real row with a real name that a
character can hold; it simply has no weight or price yet. Inventing either
would be inventing a rule — see [A row can say where it came from](../README.md#a-row-can-say-where-it-came-from).

A handful are neither: categories the importer emitted as ids before choice
groups existed. `energy-pistol` and `vibro-blade` were fixed by
[`retire-gear-placeholders.sql`](../db/retire-gear-placeholders.sql) and
`energy-rifle` by [`fix-shifter-energy-rifle.sql`](../db/fix-shifter-energy-rifle.sql).
Still outstanding, each needing the book rather than a guess: `submachine-gun`
(shifter), `musical-instrument` (mystic), `lesser-rune-weapon` and
`basic-provisions` (godling). Each is a character starting play holding
something that does not exist, so they are worth clearing - but a `from:` list
invented rather than read is the failure the import rules exist to prevent.

This list named **seven** until the three that could be settled were:
`mdc-body-armor`, `robe-or-cape` and `pen-or-pencil` are gone, and their classes
were corrected in the same pass rather than left pointing at a redirect. That
every cited id still resolves is now a regression invariant rather than a
sentence, because a list of names in prose is exactly the shape that goes
stale.

**A gear choice must enumerate its options.** `{ choose, from }` takes an
explicit list of slugs, because gear's `category` (weapon/armor/vehicle/gear) is
far too coarse to express "any energy pistol". So importing a book with new
pistols does not automatically widen the classes that offer one — the `from`
list has to be extended by hand. Tagging gear would fix this properly; it was
deferred as a larger change than the problem currently warrants. See
[Starting gear the class leaves open](wizard-and-sheet.md#starting-gear-the-class-leaves-open).

**A vehicle row in `gear` is lossy, and that is a decision rather than an
oversight.** `gear` holds one `mdc`, one `damage`, one `range`, one `payload`.
A Palladium vessel prints M.D.C. **by location** — main body, engines, turrets,
sensors, each with its own destruction rules — a numbered list of five to eight
weapon systems, crew and passenger capacity separately, and speed in three
regimes. Stored as `gear`, most of that entry has nowhere to go.

Measured on production 2026-09-03: of **36** rows with `category = 'vehicle'`,
**24** carry their per-location breakdown as prose inside `description`, and
**4** cram more than one weapon system into `damage`. So `mdc` on a vehicle row
is the **main body alone** — a Glitter Boy's arms and legs are not in it — and
the rest is present but unreadable, sitting in prose no code parses.

**The 25 vessels Phase World prints are deliberately not imported at all**, and
its survey says so in its extraction plan. The one exception is the Noro Mystic
Warrior's `Psionic Power Armor`, imported because a class is *issued* it and the
sheet was wrong without it.

**Why there is no `vehicles` table and no JSON `systems` column.** Both were
considered and neither is built, because nothing in the app does anything with a
starship: re-checked 2026-09-03, no table and no column anywhere in 40 tables
names a vehicle, vessel or ship. A JSON column nothing reads is the
silent-storage failure `class-import` warns about, and a nine-place table for a
feature nobody has asked for is worse. **Reopen this the moment something asks**
— the 24 rows whose breakdown already sits in prose are the backfill it would
start from. `BOOK-INGEST-AUDIT.md` `F3` carries the full reasoning and the
options.

**Migrations are still applied by hand.** `schema_migrations` records what has
run where and the smoke test checks it, but applying a migration is still a
manual `wrangler d1 execute` per environment. That is a deliberate stopping
point, not an oversight — see [`docs/plans/01-migration-tracking.md`](plans/01-migration-tracking.md).

### What the importers cannot read, and cannot express

**Extraction reads well; naming is the real friction.** Importing the Rifts
skill chapter (pp. 26–34, 9 pages, ~93s of model time) produced 80 new skills
with **no column-splicing at all** — every note read coherently, and spot-checks
matched the book (`Intelligence 32%/+4`, `Sniper 0%`, `Medical Doctor 60%/50%`
captured as a note). Earlier runs did show a secondary percentage split into its
own entry and a skill read as 0% where the catalog had 30%, so the review step
still earns its place — but the failure mode that actually cost time was
**names**, not numbers: ten skills already existed under different spellings.
See [Merging duplicate catalog rows](catalog.md#merging-duplicate-catalog-rows).

**A field the prompt does not mention is a field that never arrives.** `variants`
shipped as schema and the importer was never told about it, so the first class
with age stages came back with **both stat blocks dropped** — no attribute dice,
no hit points, no P.P.E. The skills and psionics were perfect, which is exactly
what made it look like a good extraction. The same shape bit `bonuses`: the
prompt named no keys, so the model invented plausible ones (`roll_with_punch`,
`pull_punch`, `magic`) that nothing read and which therefore did nothing at all.
Two of those have since become real — `roll` and `pull_punch` — because actual
classes needed them, but they were invented before they were implemented, which
is the point: a bonus written for a key `derive.js` does not expose is silent.

A smoke check now pins the prompt against `derive.js`'s real key list and
asserts it documents each schema block, because neither failure is visible in
the output — you only notice by going looking for a number that should be there.

**Pool formulas are prose as often as arithmetic.** `rollPoolFormula` originally
understood bare dice and `P.E. + dice`, and three of the five formulas on one
real page returned NULL — which meant a character built from that class had no
hit points, no P.P.E. and no I.S.P. It now reads dice and an attribute in either
order, for any of the eight attributes, and falls back to the *leading* dice
expression when the formula is a qualified sentence
(`3D4x100+1000 when in serpent form, only 3D4x100 in humanoid form`), leaving
the qualification to the prose that carries it. A formula with no numbers in it
still returns null rather than guessing.

It also reads an attribute the book **multiplies** — `P.E. x 10`, `P.E. x 12`,
`P.E. x 3 plus 2D6 per level`. Supernatural and mega-damage races state their
pools that way as a matter of course, and both failure modes were live: a
formula that was only a multiplied attribute returned NULL, and one that also
had dice **silently dropped the multiplier**, so a Godling written
`P.E. x 3 plus 2D6 per level` rolled `P.E. + 2D6` — a third of the right number
and entirely plausible-looking. The silent-wrong half was the urgent one; a NULL
pool at least shows up as an empty field.

The multiplier is read only where it sits directly against the attribute, so an
`x N` belonging to the dice stays with the dice: in `M.E. number plus 1D6x10`
the ×10 multiplies the die, and mistaking it for the attribute's would put the
pool an order of magnitude out.

**A flat constant on top of dice AND an attribute is not expressible.** The
grammar is *dice plus an attribute* — there is no third term, and a constant
written into the formula string is silently dropped rather than rejected. The
Stone Master prints two P.P.E. formulas, and the non-Atlantean one is
*"the P.E. attribute times two plus 30 points"*: written as
`P.E. x2 + 30 + 2d6 per level` it rolled `36 + 2d6` at P.E. 18, thirty points
short and perfectly plausible.

Flat terms are **pool bonuses**, which are added to whatever the formula rolls:

```yaml
ppe_base: "P.E. x2 + 2d6 per level"
bonuses: { pools: { ppe: 30 } }
```

`bonuses` is variant-overridable, so a class whose flat term differs per variant
puts it on the variant — which is exactly how the Stone Master's two formulas
and its Atlantean-only tattoo bonus are modelled.

Do not bulk-accept a new book's first run. Read the prose, not just the figures —
a spliced column produces a description that reads fluently and is wrong.

### Sizes and names that were argued and kept

**The gear catalog's table is `gear`, its API route is `/items`.** The table was
renamed away from `items` to stay clear of MediaVault's `media_items`; the route
was deliberately left alone, since both the wizard and the sheet call it and the
blast radius was not worth end-to-end naming purity. `character_items` and its
`item_id` column keep their names too — only the catalog table was ambiguous.

**Catalog lists are deliberately unbounded.** `characters`, `campaigns` and
`journal` take `limit` and `offset` (default 200, max 500) and report a `total`.
`classes`, `catalogs` and `items` do not: the wizard boots by fetching all three
and renders a picker from each, so a truncated response would silently hide
valid choices rather than showing fewer rows. Those are bounded by book content;
the others grow with play.

Unbounded is not un-cached. `/classes` — the heaviest of the three, ~750KB of
parsed markdown — sends an `ETag` built from one aggregate over
`imported_classes` (publish, edit, retire and restore all stamp `updated_at`),
so between imports a warm boot revalidates to an empty 304 and the browser
serves its own copy. The GM dashboard does not even revalidate the full list
any more: it only ever turns a `class_id` into a label, and `?names=1` serves
exactly that, read off the table with no parsing.

**The page scripts are long, and deliberately not split.**

| file | lines | |
|---|---|---|
| `app.js` | ~3,565 | the wizard; the largest file in the app |
| `sheet.js` | ~2,285 | |
| `js/parser.js` | ~2,225 | **third** largest, and not a page script at all |
| `catalog.js` | ~800 | |
| `campaign.js` | ~685 | |
| `dashboard.js` | ~140 | |

**A smoke check now holds these to 25%**, because the previous two sets of
figures both went stale in the same way. The set before this one said `app.js`
was "roughly 1,900" when it was 2,950 — 55% out — and called `parser.js` the
*second* largest file when `sheet.js` sat between them. That has since become
true by a different route: `parser.js` overtook `sheet.js` on the psionics merge
and the supersede rule (BOOK-INGEST-AUDIT.md F10 and F11), and the ordering
check is what said so. **It has since reversed back**: `sheet.js` passed
`parser.js` again on the grants work, and the same check caught it. Three
reorderings in this table's short life is the argument for holding the claim
with a test rather than with prose. The set before THAT had
drifted 80% on `sheet.js` while claiming a 20% tolerance. Twice is a pattern, and
prose that says "treat these as orders of magnitude" is not a tolerance, it is an
apology for not having one.

Each page script drives one page and each does several jobs. Splitting was
considered and rejected: there is no build step, so there is no bundler —
splitting means more `<script>` tags, hand-managed load order, and the
classic-script/module distinction to keep straight. The cost is real and the
benefit is aesthetic. That case was argued when `sheet.js` was around 900 lines
and it has since more than doubled, so it is worth re-examining rather than
inheriting.

**That cost is a fact about CLASSIC scripts, and it stopped covering the whole
table.** Measured 2026-09-02: `index.html` loads `app.js` as `type="module"`, it
already pulls modules out of `js/` with `import`, and every entry point its
generated `onclick` markup reaches is exposed through one explicit
`Object.assign(window, …)` at the foot of the file. Splitting **that** file
costs no new `<script>` tag and no hand-managed load order, so the case for
leaving it whole has to be made on some other ground. `sheet.js` and the other
apps' page scripts are classic scripts, and the paragraph above applies to them
in full — which is why the two halves of this table are no longer one decision.

A smoke check holds both halves, for the same reason the figures above are
pinned: this paragraph previously recommended a file that had been deleted
weeks earlier, and nothing failed.

**Whichever file is opened first, cut along the seam the file already marks** —
a step the player passes through once, whose renderer is contiguous and which
nothing outside it calls. Naming today's cleanest one here is how the last
recommendation rotted, so it is deliberately not named.

### Two traps outside the app itself

**Passing SQL files to `wrangler d1 execute` on Windows can mangle non-ASCII.**
Importing 80 skills wrote `Chemistry — Analytical` into production as
`Chemistry â€" Analytical` — the em-dash was mis-decoded somewhere between the
UTF-8 file and D1. Only the two rows containing an em-dash were affected. If a
statement must carry a non-ASCII character, build it with `char(8212)` and
friends rather than embedding the literal, and **compare name sets between
environments afterwards** rather than trusting row counts, which matched
perfectly while two names were wrong.

**FilamentForge pins `claude-sonnet-4-20250514`**, which returned
`404 not_found_error` on the API key used locally. Unrelated to this app, but it
shares the proxy — worth confirming the production key can reach that model.
