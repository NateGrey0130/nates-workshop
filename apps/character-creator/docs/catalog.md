# The catalog

How catalog rows are shaped, filtered, matched and merged.

Part of the [character creator](../README.md) documentation.

---

## Which system a catalog row belongs to


**Skills and psionic powers are deliberately cross-system.** Rifts and Palladium
Fantasy share a multiverse — rifts open onto the Palladium world — so a campaign
can legitimately hold both, and a skill or a psychic power is not bound to the
book it was first printed in. Both catalogs are left untagged on purpose, which
the pickers already read as "every system".

**Do not tag them from `source_book`.** It looks like an obvious cleanup and it
is wrong: eighty skills carry a Rifts source book, and roughly half of those are
Carpentry, Sniper, First Aid, Hunting, Horsemanship, Locksmith and Lore — Faerie.
Tagging by source would strip them from Palladium characters, including skills
the Long Bowman's own O.C.C. list grants.

Untagging the psionics is also what makes a major psionic's "eight powers from
one category" possible in Palladium at all: the largest category visible there
held six.

**Gear is the exception and stays tagged.** A laser rifle turning up in a
medieval realm is an event in play, not something every character picks off the
starting-equipment list.
Every catalog row can now say which game system it is for, and an import session
says it once for the whole book rather than per page.

**A mundane row that both worlds have is `both`, and the classes are what find
them.** Clothing, gloves, a uniform, field rations, a riding horse, a hatchet
and a skinning knife were all in the catalog tagged `rifts`, because a Rifts
book was imported first — and the sheet loads its catalog as
`items?system=<campaign>`, which returns NULL, that system, or `both`. So the
Knight, who is granted clothing, gloves and a riding horse, held three items
whose names its own sheet could not resolve.
[`db/fix-pf-armor-and-cross-system-gear.sql`](../db/fix-pf-armor-and-cross-system-gear.sql)
moves those seven to `both`. This is not a licence to reclassify on sight: the
trigger is a class in the *other* system granting the row outright, which is a
concrete claim that both worlds have the thing. The cost is that `cost` is
credits in Rifts and gold in Palladium Fantasy, and a `both` row has one column
for it — recorded in that script rather than papered over.

**Nothing used to set it.** `gear.system` and `skills.systems` existed, but only
the *class* importer's stub creation wrote them, from the class being imported.
So the 34 items from the first real gear import landed NULL while the stubs
around them said `rifts`, and `/items?system=rifts` — which matched only `rifts`
or `both` — hid every one of them from the character sheet while the wizard
showed all 74. Spells and psionic powers had no system column at all, which is a
real modelling gap: Palladium Fantasy and Rifts have substantially different
spell lists.

| Catalog | Column | Shape |
|---|---|---|
| skills | `systems` | JSON array — `["rifts"]` |
| spells, psionics, gear | `system` | one of `rifts`, `palladium-fantasy`, `both` |

**NULL means unrestricted, everywhere.** That is how `skills.systems` has always
read, and it is the honest answer when the operator does not know or the book
covers both — `both` and *unset* both store NULL rather than inventing a
restriction.

Starting an import asks which system the book is for. Every row confirmed out of
that session inherits it, with two deliberate limits:

- **Stamped on INSERT only.** An update is a correction to a row's numbers from
  a book; silently reclassifying which system an existing row belongs to is a
  much larger claim, and not one you asked for.
- **The book wins over the session.** If extraction produced the column itself,
  what the page actually said is kept.

The wizard filters spells and psionic powers by the build's system, the same way
it already filtered skills. Rows already sitting at NULL can be classified with
[`db/backfill-gear-system.sql`](../db/backfill-gear-system.sql), which infers from
the source book, only touches rows that are still NULL, and leaves anything it
cannot recognise alone rather than guessing.

---

## Two name matchers, on purpose

`scripts/catalog-match-lib.mjs` and
`functions/api/character-creator/_lib/catalog-merge.js` both normalise catalog
names and both decide whether two names are the same thing. **They must not be
unified**, and the reason is not historical accident:

| | `catalog-merge.js` | `catalog-match-lib.mjs` |
|---|---|---|
| used by | the merge UI, to **suggest** | the import tooling, to **act** |
| tuned | generous | strict |
| a false positive costs | a glance | a corrupted catalog |
| ambiguity | scored and ranked | refused |

`catalog-merge.js` says so itself: *"Deliberately generous - a false suggestion
costs a glance, a missed duplicate costs a wrong catalog."* That is exactly
right for a human-reviewed list and exactly wrong for an unattended import,
where the generous reading is what collapsed `Bio-Regenerate (self)` onto
`Bio-Regeneration (Super)` and produced confident corrections to rows that were
already right.

The shared primitive is small - lowercase, drop parentheticals, fold `&` -
and the policies built on it are opposites. Unifying them would mean one of the
two silently changing behaviour, and the merge UI's behaviour is pinned by the
smoke test while the import's is pinned by 21 cases drawn from real failures.

## The catalog field config

`js/catalog-fields.js` is one declarative description of every editable catalog,
imported by both the browser and the Workers runtime. It is the single place that
knows what a row looks like:

- the catalog editor builds its table and its row form from `fields`
- `catalogs/rows` validates and coerces against `fields`, and **builds its SQL
  from the config rather than from anything a caller sent** — a caller names a
  catalog key, never a table or a column
- the PDF importers build their extraction prompts and review tables from it

Adding a column means adding it in one place. Two details that are easy to miss:

- **`blankAs` mirrors a `NOT NULL DEFAULT` in the schema**, and its absence is
  just as meaningful: a nullable number the book does not state stays `NULL`,
  because "this item has no A.R." and "this item has A.R. 0" are different
  claims and the sheet renders the second one. `skills.base`,
  `skills.per_level`, `spells.level`, `spells.ppe` and `psionic_powers.isp` are
  all `NOT NULL DEFAULT 0`, so an empty form field has to coerce to `0`, not
  `NULL`. Without it the insert fails a constraint.
- **`allowOther` on a `select`** keeps a stored value that is not one of the
  options selectable, instead of silently rewriting it. Psionic categories use
  it, because a later book may add one the core four do not cover.

`gear` is the odd catalog: unique on `slug` rather than `name`, and it has no
`source` column. Both facts live in the config.

Editing or hand-creating a row sets `source = 'manual'` where the table has that
column, so a later import can tell curated data from extracted data — the
importers default a curated row to *ignore*.

### What a list row shows

Four columns, chosen **per row** rather than per catalog: the first four fields
that row actually fills, in config order. Gear is the reason. A rifle, a suit of
armour and a backpack have almost disjoint useful columns, so no fixed set of
four can serve all three — the old rule took the first four fields and dropped
the blanks *among them*, which for gear meant slug, system, category and weight
on every row, while cost, damage, A.R. and M.D.C. never appeared at all.

Three details that make it read well:

- **The unique key is rendered separately**, not counted in the four. On gear
  that is the slug, which is identity rather than a statistic, and letting it
  take a slot cost every weapon its damage column.
- **`0` is not empty.** A skill's `base` of 0 means non-percentile (W.P.s, hand
  to hand) — a fact about the skill, not a missing value. A `systems` of NULL
  *is* skipped, because it means "both" and is true of nearly every row.
- **Long values are clipped to 48 characters.** Books write damage as a
  sentence; the JA-11's runs to 140 and would swallow the row it is summarising.

The upshot is that a row says only what it knows. The seeded psionic powers have
no range, duration or `min_tier` at all, so they show category and I.S.P. and
stop — and `min_tier` will appear on its own the first time a book states one.

---

## A category restriction may name a skill from elsewhere

The catalog files each skill under exactly one category. The books do not: they
file a skill under whichever category a given class spends its pick from, so
*"Espionage: Wilderness Survival only"* is an ordinary line about a skill the
catalog calls Wilderness.

`categoryAllows` used to find the entry matching the skill's catalog category
first, so the name never matched and the restriction did nothing. Ten classes
named a skill this way; for eight it was harmless, because the skill was
reachable through another category the class also granted. **The two Elemental
Fusionists lost Writing and Lore: Cattle & Animals outright** — the books grant
them and the wizard would not offer them.

An `only` entry now matches **by name, whatever category the catalog files the
skill under**, which is what the book means: you may spend a pick from that
category on this skill.

It is **bounded by the class also listing the skill's real category**. Without
that bound an `only` entry would reach a skill from a category the class never
granted at all, which is wider than any book says. Every real case clears it:
a class naming a skill under a neighbouring category grants that neighbour too,
which is checked across all eleven.

"Lists the category" is deliberately not "that category's own restriction admits
the skill". Both Elemental Fusionists grant Technical with an `only` list that
does not carry Writing and name it under Communications instead — requiring both
would refuse the very skill this exists to reach. The more specific statement,
the one naming the skill, wins.

Everything else is unchanged — an `only` list still refuses a name it does not
carry, and a category the class never granted is still refused.

**`except` deliberately does not work this way.** An `except` naming a skill
from another category still excludes nothing, because the skill was never
offered in that category to begin with. Making it grant would be the opposite of
what an exclusion is for.

One change covers the wizard's picker, the server-side validator and the
level-up pick check, because all three call `categoryAllows` — the pair that
drifted once already.

`class-check` reports three shapes, and it VERIFIES the bound rather than
assuming it:

| Section | Meaning |
|---|---|
| `cross-category` | An `only` naming the skill, and the class lists its real category. Works. Shown so it reads as deliberate rather than as a typo. |
| `unreachable` | An `only` naming the skill where the class does **not** list its real category. The class grants a skill nobody can take. A real defect. |
| `no-op except` | An `except` naming a skill from another category. Excludes nothing. Harmless, but the category is probably wrong. |

The bound is checked **within the same skill group**: a category granted only to
`secondary_skills` does not make an `occ_related_skills` restriction reachable.

None of the three sets the exit code, for the same reason the missing-row
restrictions do not - they are findings about the books, not a file the parser
rejects.

---

## A skill can grant more than a percentage

Physical skills are not only percentile. Boxing is *"+1 attack per melee, +2
parry & dodge, +1 roll, +2 P.S., +3D6 S.D.C."*; Wrestling, Body Building,
Running, Athletics, Acrobatics and Gymnastics all print bonuses of the same
kind. The catalog had nowhere to put them, so a character who took Boxing gained
nothing from it — of 22 Physical rows exactly one recorded its bonuses, as free
text in `note`, which nothing reads.

`skills.bonuses` holds them, in **the same JSON shape a class's `bonuses:` block
uses**, validated through the same `validateBonuses()`:

```json
{ "attributes": { "PS": 2 }, "combat": { "attacks": 1, "parry": 2, "dodge": 2, "roll": 1 } }
```

Sharing the validator is the point: a skill cannot express a bonus a class
could not, so `derive.js` needs no new cases and `combat`/`saves` stay the open
sets they already are — `roll` needed no schema change.

**Dice values and `pools` are refused for a skill**, unlike for a class. A class
rolls its dice bonuses once at creation and stores what they came up
(`attribute_bonuses`, `rolled_bonuses`); a skill can be taken at any level, so
there is no equivalent moment. Accepting them would store Boxing's *+3D6 S.D.C.*
and silently never apply it, which is the failure this column exists to end.
They stay in `note` until skill dice are rolled at acquisition.

### Where they are applied

`composeClass()` folds them in **last**, after the two classes are one and after
chosen abilities — a skill's bonus is neither class's, and an ability granting
bonuses of its own must not be able to read one. The merge is `sumBonusGroups`,
the same function that merges an R.C.C. with an O.C.C., so a class and a skill
both granting +2 P.S. give +4 rather than one quietly winning.

`skillRows` is optional and **null means "this caller does not know the
character's skills"**, which is deliberately different from an empty array
meaning "it has none": the first leaves the composed class untouched. The rows
come from `_lib/skill-bonuses.js`, which resolves through `catalog_redirects`
for the same reason class markdown does — without it, merging two catalog rows
would strip the survivor's bonuses from every character holding the old name.

Wired at the two paths that produce a character's numbers: the sheet endpoint
(`characters/[id].js`) and `loadCharacterClass()` in `_lib/class-loader.js`,
which the XP, level-up, picks, variant and create endpoints all go through.

The wizard is a third path and works differently. `composeClass()` runs on the
**Class** step, before a single skill is chosen, so there is nothing to fold in
at that point. `skillBonusClass()` in `app.js` does it at read time instead,
taking the held skills from `takenNames()` — the same source the pickers use, so
a skill counted here is exactly one the wizard shows as taken. `/catalogs`
returns the `bonuses` column for that reason.

The Attributes step names the source, because once skills fold into the same
block *"+2 from Glitter Boy"* is a lie whenever the +2 is Boxing's. It reads
`from <class>`, `from skills taken`, or `from <class> + skills taken`.

The **sheet** does the same, for attributes and for the combat and save
tooltips. `derive.parts()` takes an optional class-only bonuses block and
reports `from_class` and `from_skills` separately; omit it and everything lands
in `from_class`, which is what every caller did before skills could grant
anything. The endpoint sends `class_bonuses` alongside `bonuses` by composing
twice, because the two halves cannot be recovered from the total.

```
# OF ATTACKS   +2 from attributes, +1 from Cyber-Knight, +1 from skills taken
PARRY          +2 from skills taken
```

**One case blurs, and only the attribution.** Where a class grants an attribute
as DICE and a skill grants the same attribute FLAT, the two merge into one list
and are rolled together into `attribute_bonuses` — by design, so the flat half
is not lost (see `diceBonuses`). The stored roll then carries both, and nothing
downstream can say which part was the skill's, so the chip credits the class.
The TOTAL is right; only the label is imprecise, and only there. Separating them
would mean counting the flat half outside the roll, which would double-count it
for every character whose stored roll already includes it. Combat and save
bonuses are unaffected — those keys are flat on both sides.

---

## Merging duplicate catalog rows

The importers dedupe on an **exact** name. That is the right default and it
misses a whole class of real duplicate — importing the Rifts skill chapter
(pp. 26–34) produced **ten** pairs it could not see, because the book and the
hand-seeded catalog name the same skill differently:

```
Skin and Prepare Animal Hides  /  Skin & Prepare Animal Hides
Lore — Demons and Monsters     /  Lore: Demons & Monsters
Mathematics — Basic            /  Basic Math
Tracking                       /  Tracking (people)
Laser                          /  Laser Communications
```

**Find duplicates** in the catalog editor normalises punctuation, ampersands,
separators, spacing and bracketed qualifiers, then suggests pairs. Nothing
merges automatically; you confirm each one, seeing both rows' numbers side by
side.

The button carries a **count badge**, fetched whenever a catalog loads, so a
duplicate surfaces without anyone thinking to look. It counts only the two
trustworthy tiers — a badge including the loose one would never reach zero, and
a badge that never reaches zero teaches you to ignore it. The looser number is
in the tooltip.

Results are grouped by confidence, because the tiers are **not** equally
trustworthy. Measured against the real 138-row catalog:

| Group | What it means | Precision |
|---|---|---|
| Same name, different punctuation *or spacing* | identical once normalised | no false positives |
| Same words, reordered or inflected | `Basic Math` / `Mathematics — Basic` | no false positives |
| One name contains the other | `Laser` / `Laser Communications` | **~40%** — read these |

That last group is unavoidably ambiguous: `Chemistry` / `Chemistry — Analytical`
and `Demolitions` / `Demolitions Disposal` look identical to it and are genuinely
different skills. It is a judgement aid, not an oracle.

Spacing was added to the top tier after `Back Pack` / `Backpack` turned up in the
real gear catalog scoring **0.75** — filed in the loosest group, which is where a
genuine duplicate goes to be ignored, and below the threshold the badge counts.
Two names identical once spaces are removed are not similar names; they are one
name typed two ways.

**What a merge does** differs by catalog, because references do:

- **Skills, spells, psionics** are referenced *by name* inside characters' JSON
  columns, so every character holding the losing name is rewritten. A character
  holding **both** names has them collapsed into one, or the validator would
  then flag it as a duplicate skill.
- **Gear** is referenced *by slug* through `character_items.gear_slug` - it was
  by id until migration 046 - so that
  foreign key is repointed instead.
- The losing row is then deleted, all in one batch.

**Class definitions are reported, never rewritten.** Class markdown is
frontmatter plus prose, and a blind string replace would hit lore text as
readily as a skill list — so a merge tells you which classes still mention the
old name and leaves the edit to you in the importer.

### Retired keys keep resolving

Reporting alone was not enough, and the way it failed is worth knowing.

Class markdown cites gear by **slug** in `equipment_starting[].item_id`, and
skills, spells and psionics by **name**. Merging away a row those cite left the
citation pointing at a key that no longer existed — and nothing raised an error:

| What you did next | What actually happened |
|---|---|
| Built a character from that class | the item degraded to a bare custom line, no stats |
| Re-imported that class | the stub the merge deleted came straight back |

Both quietly undo the merge. Found the first time it mattered: merging the
hand-seeded `ja-11-energy-rifle` stub into the book's real JA-11 entry
repointed both characters correctly, while the Juicer went on naming the
deleted slug.

So a merge now leaves a **redirect** — a row in `catalog_redirects` saying where
the key went — and the two places that resolve a key fall through to it:

- `crossReference()` treats a redirecting key as **found**, so no stub is created
- the wizard's `findItem()` resolves starting gear through it

Renaming a key by hand in the catalog editor records one too, for the same
reason: it breaks exactly the same citations a merge does.

Three properties worth knowing:

- **A redirect claims its key.** Creating a row with a key that redirects is
  refused with a 409 naming the target — otherwise the new row would silently
  shadow the forwarding address, which is the ambiguity this exists to remove.
- **Chains collapse.** Merging a row that other redirects point at moves them
  onto the survivor, so nothing dangles at the first hop.
- **They are listed and removable** on the catalog page's **Redirects** panel.
  Removing one frees the key and breaks any citation still relying on it.

Keys are matched case-insensitively (`COLLATE NOCASE`), matching every other key
comparison in the app; a merge never files a redirect for a key the surviving
row already answers to.

---
