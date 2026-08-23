# 18 — Experience tables by O.C.C.

**Status: PROPOSAL. Nothing here is built.** Written against the Palladium
Fantasy main book, printed 336, with every number read off the page.

---

## The headline: this needs no schema at all

`js/leveling.js` has carried the override since it was written:

```js
// Default XP table is a house rule — Palladium's ~20 per-class charts are
// content work for later. A class file can override it without any schema
// change by adding frontmatter `xp_table: [0, 2100, ...]`
```

`xpTableFor(cls)` returns `cls.xp_table` when it is a valid ascending array of
numbers, and the default otherwise. It is read by **six** call sites already —
`characters.js`, `characters/[id]/xp.js`, `characters/[id]/level-confirm.js`,
`_lib/validate-character.js`, and the wizard twice — and the smoke test already
pins the override. There is nothing to migrate, nothing to add to `schema.sql`,
and no README data-model row. **The five places the `schema-change` skill names
do not apply**, because no column is being added.

That is the whole answer to "where does this data live". It lives in the class
markdown, like everything else about a class.

Two small things are in the way, and neither is a schema change.

---

## Blocker 1: an occupation's `xp_table` is silently dropped

`combineClasses` starts `const out = { ...rcc }` and then carries a named list
of keys forward from the occupation when the race has no opinion:

```js
for (const key of ['attribute_dice', 'hit_points_base', 'sdc_base', 'mdc_base',
                   'ppe_base', 'starting_money']) { … }
```

`xp_table` is not on that list. Measured, not assumed:

```
occupation xp_table survives composition: undefined
race       xp_table survives:             [0,1,2]
xpTableFor(composed)[1] = 2000     ← the house-rule default, not the Knight's
```

**This is the wrong way round for every character in the system.** Palladium's
tables are named by O.C.C. — *Knight & Noble*, *Thief & Merchant* — and a race
has none, because experience comes from what you do. Since #210 every Palladium
character is a race plus an occupation, so a Knight's table would be dropped
on **every single one of them** while the Human R.C.C.'s absent table won.

The fix is one entry in that array, and it is the *right* entry: XP belongs to
the job for exactly the reason S.D.C. does, and `withCorePools` already spells
that reasoning out for the men-of-arms roll.

`app.js:808` and `:821` are a second site: they call
`xpTableFor(applyVariant(S.rcc, S.variant))` — the **race** — to size the
starting-level picker, rather than the composed class. Same fix, different file.

## Blocker 2: `xp_table` is not in `KNOWN_KEYS`

So the first class to use it is reported `UNMODELLED` by `class-check`, and the
instruction attached to that report is *delete the key or change the app* —
both wrong for a key that has worked since it was written. This is the same
false alarm `psionics_allowed` gave when the races landed, fixed the same way:
one line in `scripts/class-check-lib.mjs`.

---

## The data: 15 tables, 15 levels each, 225 numbers

Printed 336. Every table runs level 1 to 15, and the app's cap is already 15.

| # | table as printed | classes in the catalog |
|---|---|---|
| 1 | Assassin & Diabolist | `assassin`, `diabolist` |
| 2 | Mercenary Warrior | `mercenary-fighter` |
| 3 | Monk & Summoner | `warrior-monk`, `summoner` |
| 4 | Thief & Merchant | `thief`, `merchant` |
| 5 | Soldier & Scholar | `soldier`, `scholar` |
| 6 | Knight & Noble | `knight`, `noble` |
| 7 | Palladin | `palladin` |
| 8 | Long Bowman & Squire | `long-bowman`, `squire` |
| 9 | Priest (Light & Dark) | `priest-of-light`, `priest-of-darkness` |
| 10 | Psi-Mystic & Warlock | `psi-mystic` (and see the Warlock note) |
| 11 | Witch | `witch` |
| 12 | Ranger, Psi-Healer & Psychic Sensitive | `ranger`, `psi-healer`, `psychic-sensitive` |
| 13 | Druid & Cobbler | `druid` (the Cobbler is not imported) |
| 14 | Vagabond/Peasant/Farmer | `vagabond-peasant` |
| 15 | Mind Mage & Wizard | `mind-mage`, `wizard` |

**All 25 Palladium O.C.C.s in the catalog are covered, with nothing left over.**
The two names in the book with no row are the Monk — which is `warrior-monk`
here — and the Goblin Cobbler, which is not imported (see the goblin's
extraction notes).

**The fourteen R.C.C.s get nothing**, and that is correct rather than missing:
a race has no experience table, which is precisely why blocker 1 matters.

**The Warlock is the one judgement call.** The catalog's `warlock` is the Rifts
Book of Magic printing and carries `system = 'rifts'`. Giving it the Palladium
table would be applying a Palladium number to a Rifts row. It should get the
Palladium figures recorded as a **delta**, the way
`record-warlock-palladium-deltas.sql` already records its money and armour —
not an `xp_table`.

### What the book says against what the app does

The house rule is *good*. This is worth knowing before anyone treats the import
as a correction:

| level | book's range across the 15 tables | `DEFAULT_XP_TABLE` | |
|---|---|---|---|
| 2 | 1,801 – 2,401 | 2,000 | inside |
| 5 | 11,001 – 17,921 | 16,000 | inside |
| 10 | 74,001 – 100,501 | 95,000 | inside |
| 15 | 290,001 – 370,201 | 300,000 | inside |

**The default sits inside the book's range at every level checked.** So this is
a fidelity improvement, not a bug fix: nobody is levelling at the wrong speed
today, they are levelling at the average speed instead of their class's.

The spread is real though. A Vagabond reaches level 15 at 290,001 and a Witch
at 370,201 — a 28% difference, and the two classes that most deserve to differ.

### Extraction

Read from the text layer with `read-columns.py`, PDF page 338. Three known
artefacts, all cosmetic and all in the same shape the spell index had:

- `Vagabond/Peasant/Farmel` — a mis-set final *r*.
- `14272,881-324,880` — a missing space between the level and the number.
- A stray `t` between two tables.

`xp_table` stores the **lower bound** of each level's band, which is what
`levelForXp` compares against, so the *"0,000-2,180"* row for level 1 becomes
`0` and level 2's *"2,181-4,360"* becomes `2181`.

---

## What it would take

| step | file | size |
|---|---|---|
| carry `xp_table` through composition | `js/parser.js` — one array entry | 1 line |
| compose before sizing the level picker | `app.js` ×2 | 2 lines |
| stop the false UNMODELLED report | `scripts/class-check-lib.mjs` | 1 line |
| pin all three | `test/smoke.mjs` | one section |
| the numbers | one `add-pf-xp-tables.sql`, 25 guarded `UPDATE`s appending `xp_table:` to each class's frontmatter | 225 numbers |
| the Warlock's delta | append to its `## Palladium Fantasy` section | a paragraph |
| README | a paragraph under **House rules and derived values**, replacing the sentence that calls the per-class charts "content work for later" | |

**No migration. No `schema.sql` change. No new column. No UI change** — the
wizard's XP display and the sheet's level-up bar already read whatever
`xpTableFor` returns.

### One ordering hazard worth naming now

An `add-pf-xp-tables.sql` that rewrites class markdown must sort **after** every
script that writes those same rows. `add-` sorts before `fix-`, `apply-`,
`record-` and `zz-`, so a clean rebuild would append the table and then have
three later scripts overwrite the class it landed on. The file wants an
`apply-` or `zz-` prefix, and the choice should be checked against a sorted
listing before it is named — this is the trap that cost `fix-long-bowman-armor`
its whole effect.

---

## Recommendation

**Do it, and do the two blockers first as their own change.** Both are one-line
fixes to code that already exists, both are wrong today independently of whether
the tables are ever imported, and blocker 1 in particular means the feature as
shipped does not work for the only system it is needed in.

Then the tables themselves are a single data script and no schema at all — much
the cheapest of the two proposals in this pair.
