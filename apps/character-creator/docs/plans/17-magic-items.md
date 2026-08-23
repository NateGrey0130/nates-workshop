# 17 — Enchanted items, and why `gear` cannot hold one

**Status: PROPOSAL. Nothing here is built.** Written against the Palladium
Fantasy main book, printed 245-269, with the counts read off the pages rather
than estimated.

---

## The shape of the problem

`gear` has no notion of an enchanted item. That is the easy sentence, and it is
not the interesting one. The interesting one is that **most of what these pages
sell is not an item at all.**

The book's Magic Armor and Magic Weapons sections list **three** finished
suits and **thirty-three** *properties* that an alchemist puts INTO an ordinary
suit or blade, cumulatively, up to four per suit of armour and three per weapon,
with the price adding up as you go. A Cloak of Armor is a row. "+1 A.R., 4,000
gold" is not — it is a modifier that can sit on any of the twenty-four armour
rows the catalog already has.

So this is not "add a `magic` flag to gear". It is a decision about whether the
app models **enchantments as a thing a character's item carries**, and that
decision is what the rest of the numbers below should be read against.

---

## What is actually on the pages

Counted from a geometric read of printed 245-269 (`read-columns.py`, PDF pages
247-271). Method: a line beginning `Name:` inside each section, with field
labels (`Cost:`, `Note:`, `Duration:` …) excluded, then hand-checked per
section. Where a count is soft, it says so.

| printed | section | rows | shape |
|---|---|---|---|
| 249 | Magic armour, finished suits | **3** | Cloak of Armor, Cloak of Protection, Leather of Iron |
| 249 | Magic armour **features** | **11** | modifiers, max 4 per suit, cost cumulative |
| 249-250 | Magic weapon **properties** | **21** | modifiers, max 3 per weapon, cost cumulative |
| 250 | Transformable weapons | 1 rule | not an item list |
| 250-252 | Rune weapons | **3 tiers** + power tables | Lesser / Greater / Greatest, generated not listed |
| 252 | Holy weapons | 1 rule + a power list | generated, not listed |
| 253 | Rings, bracelets, charms, medallions | **29** | finished items with a price |
| 253 | Potions | **28** | finished items, single dose |
| 254 | Powders and fumes | **16** | finished items, sold by the ounce |
| 255 | Crystals and stones | **9** | finished items |
| 256 | Guardian stones | **3 types** | statues; priced as a class, not per row |
| 257-258 | Fabrics and make-up | **23** | finished items |
| 259 | Other articles of magic | **~30** | two blocks; finished items |
| 260 | Faerie foods | **28** | Beets, Squash, Sloe Wine, Cinnamon Sticks … |
| 261 | Miscellaneous magic components | **28** | Dragon bones, Unicorn horn, Quicksilver … |
| 262-263 | Curses (optional) | **20** effects | not items; things done TO an item or person |
| 264 | Poisons | **12** | Hemlock, Nightshade, Dragon's venom, four contact poisons |
| 265-267 | Herblore: drugs and herbal potions | **~19** | finished items |

**Roughly 210 priced rows and about 33 modifiers**, against a `gear` table
that currently holds 658.

Three of those groups are not inventory at all and should be said out loud
before anyone counts them as work:

- **Curses** are effects applied to a person or an object. They have no price
  and no weight; they are closer to a spell than to a sword.
- **Rune weapons and holy weapons** are *generated*, not listed. The book gives
  a tier, a table of powers and a roll. Importing them as rows would be
  inventing about forty items the book does not print.
- **Guardian stones** are priced per type, not per statue.

---

## What `gear` cannot hold today

Concrete, and each one blocks a specific line on those pages.

**1. There is no `sdc` column.** `gear` has `ar` and `mdc`; Palladium armour is
rated A.R. plus **S.D.C.**, and every one of the 24 armour rows currently keeps
its S.D.C. **in the free-text description**:

```
hard-leather   AR=11  mdc=NULL   "Full suit of hard leather. A.R. 11, 30 S.D.C. …"
```

That is already a gap, independent of magic. It becomes blocking here because
the single most-used armour feature on printed 249 is *"Magic S.D.C.: 2,000 gold
per 20 points, to a 200 maximum for heavy armour and 100 for leather and
chain"* — a number that adds to a number the schema does not have.

**2. There is no way to say "this instance is enchanted".** `character_items`
carries `item_id`, `qty`, `equipped`, `notes` and a `custom_name`. Two characters
holding `long-sword` hold the same row. An enchantment belongs to **one sword**,
not to the catalog entry for long swords.

**3. `cost` is one integer, and these prices are ranges and formulas.**
`cost_note` exists for the text, which covers "3,000-8,000 gold". It does not
cover *"20,000 base, plus 10,000 per 50 S.D.C. to a maximum of 250"*, which is
an arithmetic rule.

**4. `system` is a single tag and these are Palladium-only** — which is fine,
and is the one thing that already works.

---

## Three ways to do it

### A. Rows only, no enchantment model — **smallest**

Import the ~210 finished items as ordinary `gear` rows with
`category = 'magic'`, prices in `cost`, everything else in `description`. Skip
the 33 modifiers, the rune and holy weapons, and the curses entirely.

- **Schema:** one new `category` value. Strictly speaking *no migration at all* —
  `category` is free text with a suggested list in `catalog-fields.js`.
- **Cost:** one data script, one line in the field config, one README section.
- **What it buys:** a character can hold a Potion of Healing and it shows on the
  sheet with its price and description.
- **What it does not:** the armour and weapon halves of the chapter, which are
  the parts a player actually asks for. No sword is ever +1.

### B. Rows plus an enchantment table — **the honest middle**

A. plus a way to say that *this* sword has *these* properties.

```sql
-- 034-enchantments.sql
CREATE TABLE IF NOT EXISTS enchantments (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  slug         TEXT UNIQUE,          -- 'additional-damage', 'noiseless'
  name         TEXT NOT NULL,
  applies_to   TEXT NOT NULL,        -- 'weapon' | 'armor'
  cost         INTEGER,              -- gold, at its low end
  cost_note    TEXT,                 -- 'per 20 S.D.C., 200 max on heavy armour'
  max_per_item INTEGER,              -- 3 for weapons, 4 for armour
  bonuses      TEXT,                 -- the SAME JSON shape skills.bonuses uses
  description  TEXT,
  system       TEXT,
  source_book  TEXT
);

ALTER TABLE character_items ADD COLUMN enchantments TEXT;  -- JSON array of slugs
```

The second half is the point. `character_items.enchantments` is a JSON array on
the **instance**, so one long sword in a party of four can be the Demon Slayer
and the other three stay ordinary.

`bonuses` reuses the block `skills.bonuses` already stores and
`validateBonuses()` already checks — flat numbers in `combat` and `saves`. That
is not a convenience, it is the whole reason this is affordable: *Invisible
Weapon: +3 initiative, +2 strike and parry* is
`{"combat":{"initiative":3,"strike":2,"parry":2}}` and `derive.js` needs no new
cases, exactly as it needed none when skills learned to grant bonuses.

**The five places, per the `schema-change` skill:**

| # | Where | What |
|---|---|---|
| 1 | `db/migrations/034-enchantments.sql` | `CREATE TABLE enchantments`, `ALTER TABLE character_items ADD COLUMN enchantments TEXT`, then its own `schema_migrations` row |
| 2 | `db/schema.sql` | the same `CREATE TABLE`, and `enchantments TEXT` inline on `character_items` |
| 3 | `db/schema.sql` seeding block | `INSERT OR IGNORE … WHERE EXISTS (SELECT 1 FROM pragma_table_info('character_items') WHERE name = 'enchantments')` — guarded on the **column**, because a fresh database creates the table and skips the ALTER |
| 4 | README migration table | one row |
| 5 | README data model | a row for `enchantments`, the new `character_items` column, **and the table count moves 26 → 27** — the smoke test checks that number against `schema.sql` |

**Beyond the five**, because this is a table and not only a column:

- `js/catalog-fields.js` — a sixth catalog, which gets the editor, the write
  endpoints and the importer for free. This is the file that makes a new catalog
  cheap and the reason B is not much worse than A.
- `functions/api/character-creator/catalogs.js` — one more `SELECT`.
- `functions/api/character-creator/_lib/character-json.js` — decode the new JSON
  column with the right empty value (`[]`, not `null`).
- `sheet.js` — the weapon cards and armour slots, which already read `ar`,
  `damage` and `mdc`, need to fold the instance's enchantments in. **This is the
  real work**, and it is where a bad decision would show.
- `js/derive.js` — nothing, if `bonuses` is reused. Everything, if it is not.

**UI surface:** two places, and only two.
1. The sheet's Gear tab: an item row gains an "enchantments" affordance, listing
   what it carries and what that adds. Read-only for a player; the GM adds one.
2. The catalog editor: `enchantments` appears as a sixth catalog automatically,
   generated from the field config the same way the other five are.

The wizard needs **nothing**. No class grants an enchanted item at creation —
the Godling's `lesser-rune-weapon` is a name-only stub and would stay one.

### C. Model the rune and holy weapons too — **not recommended**

The generation tables are three pages and produce items no page lists. It is a
generator, not a catalog, and it should be a separate decision taken after B has
proved itself. Recorded here so that "we skipped rune weapons" reads as a
choice.

---

## The Alchemist itself

**Out of scope, and it should stay out.** The book says so in its first
sentence: *"The alchemist is a non-playing character class (N.P.C.), meaning
that it is not an O.C.C. available to players."* It also requires being a sixth
level Wizard, sixth level Diabolist **and** third level Summoner first — a
multi-class prerequisite the app has no model for and should not grow one for a
class no player can take.

The items are a different question from the class, and the answer differs: the
items are the point of those pages, and the class is the shopkeeper who sells
them. `catalog.html` already exists for a GM to add a row by hand, and NPC
dossiers already exist for the shopkeeper.

---

## Recommendation

**B, minus the curses, rune weapons and holy weapons.** Roughly 210 rows and 33
enchantments, one migration, one new catalog, and real work in `sheet.js`.

**But do the `sdc` column first, on its own.** It is a one-column migration that
fixes something already broken for 24 existing armour rows, it is independently
useful, and it is a prerequisite for the single most-used armour feature in the
chapter. Shipping it separately also means the enchantment work does not have to
argue about it.

Nothing in A or B changes a stored number for any existing character.
