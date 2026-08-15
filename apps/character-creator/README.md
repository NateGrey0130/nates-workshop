# Character Creator — Palladium Fantasy & Rifts

A persistent, multi-campaign character creator and journal. Build a character
through a guided wizard, keep a running session log, level up semi-automatically,
print a sheet laid out after the official form, and import classes, skills,
spells, psionic powers and gear straight out of a sourcebook PDF.

Part of Nate's Workshop. Cloudflare Pages + D1, behind the site-wide Cloudflare
Access gate. No build step, no framework, no dependencies.

---

## Contents

- [Where everything lives](#where-everything-lives)
- [Data model](#data-model)
- [Class definition format](#class-definition-format)
- [API surface](#api-surface)
- [Permissions](#permissions)
- [House rules and derived values](#house-rules-and-derived-values)
- [Level-up skill picks](#level-up-skill-picks)
- [Starting gear the class leaves open](#starting-gear-the-class-leaves-open)
- [Psychic tiers](#psychic-tiers)
- [How the sheet updates](#how-the-sheet-updates)
- [Server-side rule enforcement](#server-side-rule-enforcement)
- [The catalog field config](#the-catalog-field-config)
- [Merging duplicate catalog rows](#merging-duplicate-catalog-rows)
  - [Retired keys keep resolving](#retired-keys-keep-resolving)
- [The PDF importers](#the-pdf-importers)
- [Local development](#local-development)
- [Production configuration](#production-configuration)
- [Known limitations and refactor candidates](#known-limitations-and-refactor-candidates)

---

## Where everything lives

Everything the app reads at runtime is in D1. There are no static content files
— adding a class, a skill, a spell, or an item needs no commit and no redeploy.

```
apps/character-creator/
├── index.html / app.js       Creation wizard (8 steps). app.js is an ES module.
├── sheet.html / sheet.js     Character sheet, laid out after the printed Rifts sheet
├── dashboard.html / dashboard.js  GM dashboard: roster, GM notes, campaign journal
├── import.html / import.js   Admin-only PDF import — Class, Skills, Spells,
│                             Psionics, Gear tabs
├── catalog.html / catalog.js Admin-only catalog editor, generated from the
│                             field config. catalog.js is an ES module.
├── styles.css                All five pages, layered on /shared/styles.css
├── js/parser.js              RCC/OCC markdown parser (ES module — also used by the API)
├── js/dice.js                Dice evaluator (ES module — also used by the API)
├── js/catalog-fields.js      What every catalog row looks like (ES module — the
│                             editor, the write endpoints and the importers all
│                             build themselves from it)
├── js/derive.js              Attribute tables → combat bonuses, saves, percentages
│                             (classic script; both the wizard and the sheet use it)
├── db/seed-dev.sql           Optional local-dev seed rows; never applied to production
└── test/
    ├── smoke.mjs             Parser + schema + migration-state smoke test
    └── fixtures/*.md         Three real class files, parser test input only

functions/api/
├── _lib/access.js            Cloudflare Access identity + admin check (site-wide)
├── _lib/claude-client.js     The only place that calls the Anthropic API
├── claude.js                 HTTP proxy over claude-client, for browser callers
└── character-creator/
    ├── _lib/auth.js          Owner/GM/admin authorization, readJson
    ├── _lib/character-json.js  Decoding the character JSON columns, with the
    │                         right empty value per column
    ├── _lib/catalog.js       Cross-reference an import; create catalog stubs
    ├── _lib/class-loader.js  Resolve a class_id to parsed frontmatter
    ├── _lib/class-store.js   Read/write stored classes; per-isolate parse cache
    ├── _lib/extraction-prompt.js  Class import prompt
    ├── _lib/import-engine.js  Shared catalog-import pipeline: extract,
    │                         normalise, classify duplicates, batch-confirm
    ├── _lib/import-sessions.js  Resumable imports: sessions + staged rows
    ├── _lib/session-import.js  The session-based import endpoints, minus
    │                         the catalog — spells, psionics and gear share them
    ├── _lib/skill-prompt.js  Skill chapter import prompt
    ├── _lib/spell-prompt.js  Spell chapter import prompt
    ├── _lib/psionic-prompt.js  Psionics chapter import prompt
    ├── _lib/gear-prompt.js   Equipment chapter import prompt
    ├── _lib/paging.js        limit/offset + total, for the lists that grow
    ├── _lib/skill-picks.js   Spending granted skill picks, shared by the
    │                         level-up flow and the sheet
    ├── _lib/validate-character.js  The class rules, checked server-side
    ├── _lib/catalog-merge.js  Near-duplicate detection and merging
    ├── _lib/leveling.js      XP curve + level-up diff
    └── (endpoints — see API surface below)

db/
├── schema.sql                All tables, every statement IF NOT EXISTS.
│                             Also seeds schema_migrations, guarded per feature.
├── seed-catalogs.sql         One-time move of the original static content into D1
└── migrations/               One-shot ALTERs, each recording itself in
                              schema_migrations; see Production configuration
```

Three modules are imported by both the browser and the Workers runtime:
`js/parser.js`, `js/dice.js` and `js/catalog-fields.js`. That is why `app.js` and
`catalog.js` are loaded as `<script type="module">` while the other pages are
classic scripts — and why inline handlers in the wizard need explicit `window`
exposure (see the `Object.assign(window, …)` block at the bottom of `app.js`).
`catalog.js` avoids the problem entirely by binding with `addEventListener`.

`js/derive.js` is deliberately a *classic* script rather than a module, so the
sheet's plain script can use it without converting the whole file.

---

## Data model

Sixteen tables in one shared D1 database (`nates-workshop-media`, bound as `DB`).
`media_items` belongs to MediaVault and `schema_migrations` is database
bookkeeping shared by both; the rest are this app.

**Character data**

| Table | Notes |
|---|---|
| `campaigns` | Top-level container. `gm_email` owns it. `gm_notes` is GM-only and stripped from non-GM API responses. |
| `characters` | See below — several JSON columns. |
| `character_items` | Inventory join. `item_id` NULL means a freeform item (`custom_name` required). `removed_at` NULL means currently held — removals are soft, so history survives. |
| `journal_entries` | `character_id` NULL means a campaign-level entry. |
| `level_history` | One row per confirmed level-up; `changes` is a JSON diff of what was actually applied. |
| `pending_skill_picks` | Skill picks a level-up granted and nobody has spent yet. One row per **grant**, not per pick, so "2 picks from level 3" stays itemised. `categories` is copied from the class at level-up time — the class can change later, what you were granted cannot. |

`characters` stores seven JSON columns rather than a very wide table:

| Column | Shape |
|---|---|
| `attributes` | `{ "IQ": 12, "ME": 14, … }` |
| `skills` | `[{ name, category, pct, per_level, type: "occ"\|"related"\|"secondary" }]` |
| `powers` | `[{ type: "spell"\|"psionic", name, level?, category?, cost }]` |
| `bio` | race, alignment, age, height, sentiments, native languages … |
| `combat` | attacks, initiative, strike, parry, dodge, punches — **overrides only** |
| `saves` | save vs magic, psionics, poison, insanity … — **overrides only** |
| `armor` | `[{ name, ar, mdc_current, mdc_max, weight, cost, prowl }]` |

`combat` and `saves` hold **only what a human typed**. A missing or blank key
falls back to the value derived from the attributes, so nothing goes stale when
an attribute changes. Paired `*_max` / `*_current` columns cover hp, sdc, mdc,
ppe and isp.

**Content catalogs** — all editable at runtime

| Table | Notes |
|---|---|
| `imported_classes` | Class definitions as markdown. `status` is `draft` or `published`; only published classes appear in the app. `deleted_at` NULL means live — retiring a published class hides it from the pickers without destroying it, and drafts are still deleted outright. |
| `gear` | Gear catalog. `slug` is what `equipment_starting[].item_id` references. Carries a stat block — damage, is_mega_damage, range, payload, rate_of_fire, ar, mdc — null wherever it does not apply, so one table covers weapons, armour and general kit. Named `gear`, not `items`, to stay clear of MediaVault's `media_items`. |
| `skills` | `base` 0 means non-percentile (W.P.s, hand to hand). `systems` is a JSON array; NULL means both. `note` carries oddities like `40%/30% climb/rappel`. |
| `spells` | name, level, ppe, plus a stat block (range, duration, damage, saving throw, area of effect, casting time, description). The stat block is TEXT — books write "100 feet per level" as often as a number. |
| `psionic_powers` | name, category (Healing/Physical/Sensitive/Super), isp, plus range, duration, saving throw and description — the same field names spells use. `min_tier` is the psychic tier a book states is required; NULL means no restriction beyond the category. |

| `catalog_redirects` | Where a retired key went. Written when a merge deletes a row or a key is renamed by hand, so class markdown citing the old slug or name keeps resolving. Polymorphic by design — `catalog` names which table `to_id` points into — so there is no foreign key. See [Retired keys keep resolving](#retired-keys-keep-resolving). |

All catalogs carry `source` (`seed` \| `import`) and `source_book`, so an entry's
provenance is visible and the same skill from two books can coexist under
distinguished names. Rows created as stubs by the class importer have zeroed
numbers — the skill importer exists to fill them in.

---

## Class definition format

A class is a markdown file: YAML frontmatter for structured data, body prose for
display. Stored in `imported_classes.markdown`, parsed by `js/parser.js`.

```yaml
---
id: cyber-knight              # kebab-case slug, required
name: Cyber-Knight            # required
system: rifts                 # rifts | palladium-fantasy, required
source_book: rifts-core       # required
category: occ                 # rcc | occ, required
attribute_requirements:       # minimums, OCC style
  ME: 12
attribute_dice:               # racial rolls, RCC style
  PS: "4d6+12"
hit_points_base: "P.E. + 1d6 per level"
sdc_base: 30
mdc_base: "1d4x100"
ppe_base: "1d6 x10"
skills:
  occ_skills:
    - { name: "Radio: Basic", base: 40, per_level: 5 }
    - { choose: 2, from: ["Pilot: Hovercycle", "Pilot: Truck"], base: 45, per_level: 5 }
    - { choose: 2, categories: ["Pilot"], base: 45, per_level: 5 }
    - { name: "Hand to Hand: Expert", note: "May swap for Martial Arts at a cost." }
  occ_related_skills:
    count: 6
    categories: ["Physical", "Espionage"]
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }]
  secondary_skills:
    count: 2
equipment_starting:
  - { item_id: "ns-turbo-cyclone", qty: 1 }
  - { choose: 1, label: "energy pistol", qty: 1, from: ["ng-33-northern-gun-laser-pistol", "wilk-s-320-laser-pistol"] }
psionics:
  type: "major"               # minor | major | master
  isp_base: "1d4x10+20"
  powers: ["Sixth Sense"]     # powers the class automatically knows
magic:
  type: "innate"
  spells_starting: 6
  spell_levels_allowed: [1, 2]
  spells: ["Globe of Daylight"]   # only if the book names specific spells
special_abilities:
  - { name: "Psi-Sword", description: "..." }
level_progression:
  - { level: 2, grants: ["+1 attack per melee"] }
restrictions: ["..."]
side_effects: "Free text — substantial drawback mechanics. Display only."
extraction_notes: "Free text — anything the importer could not map cleanly."
---

## Lore
Free prose, shown when browsing a class and on the sheet.

## GM Notes
Optional, table-specific advice.
```

**Skill entry shapes.** An entry with a `name` is a fixed skill; adding `choose: N`
means it is taken N times. An entry *without* a name is a choice-group — "pick N"
— using either an enumerated `from` list or `categories` resolved against the
skill catalog. Any entry may carry a free-text `note`.

**Omit what does not apply.** An absent field means "not applicable". Do not
encode absence as `"none"` or a note.

**Advisory-only fields**, captured for display and never mechanically enforced:
`note`, `restrictions`, `side_effects`, `extraction_notes`, and
`level_progression[].grants`.

`occ_related_skills.schedule` **is** enforced: crossing one of its levels grants
that many extra skill picks. See [Level-up skill picks](#level-up-skill-picks).

The parser supports a YAML subset: nested maps, block and inline sequences,
inline objects, and `|` / `>` block scalars. Block-scalar bodies are taken raw,
so prose containing `#` survives; blank lines become paragraph breaks. A `#`
only starts a comment at line start or after whitespace.

---

## API surface

All under `/api/character-creator/`. Reads are open to any authenticated user;
writes are gated (see [Permissions](#permissions)).

| Endpoint | Method | Purpose |
|---|---|---|
| `me` | GET | Caller's email and `is_admin` |
| `classes` | GET | Published classes, parsed. `?system=` `?category=` `?include_retired=1` |
| `catalogs` | GET | Skills, spells, psionic powers in one call — trimmed projection the wizard boots on |
| `catalogs/rows` | GET / POST / PATCH | Admin. Whole rows for one catalog (`?catalog=`), create, and update (`&id=`). No delete |
| `catalogs/duplicates` | GET / POST | Admin. Suggested duplicate pairs for a catalog; POST merges two rows |
| `catalogs/redirects` | GET / DELETE | Admin. Retired keys and where they resolve (`?catalog=`); DELETE stops forwarding one (`&id=`). No POST — redirects are written by merges and renames |
| `items` | GET | Gear catalog (table is `gear`), plus retired slugs as `redirects`. `?system=` |
| `campaigns` | GET / POST | List (`?system=`, `?limit=`, `?offset=`); create (caller becomes GM) |
| `campaigns/[id]` | GET / PATCH | Details (`gm_notes` stripped for non-GM); edit `gm_notes` |
| `characters` | GET / POST | List (`?campaign_id=`, `?limit=`, `?offset=`); create at level 1 — **validated against the class rules** |
| `characters/[id]` | GET / PATCH | Sheet + inventory, with `can_write` / `is_gm`; edit pools, notes, and the bio/combat/saves/armor sections |
| `characters/[id]/items` | POST | Add inventory row (catalog slug or freeform) |
| `characters/[id]/items/[itemId]` | PATCH / DELETE | qty/equipped/notes; soft remove |
| `characters/[id]/xp` | POST | `{delta}` or `{total}`; returns a proposed level-up diff |
| `characters/[id]/level-confirm` | POST | Apply a confirmed diff, write `level_history`. `picks` spends granted skill picks; unspent ones are banked. Validated |
| `characters/[id]/picks` | GET / POST | Owner/GM to spend. Unspent skill picks; POST applies some. Validated |
| `admin/audit` | GET | Admin, read-only. Which existing characters break their class rules |
| `journal` | GET / POST | By campaign; `?character_id=`, `?include_campaign=1`, `?limit=`, `?offset=` |
| `import/extract` | POST | Admin. PDF → class markdown; autosaves a draft |
| `import/recheck` | POST | Admin. Re-parse edited markdown, no API spend |
| `import/confirm` | POST | Admin. Publish class + create catalog stubs |
| `import/sessions` | GET / POST | Admin. Resumable catalog imports: list (`?catalog=`), fetch one with its staged rows (`?id=`), create, close |
| `import/spells/extract` `import/psionics/extract` `import/gear/extract` | POST | Admin. One page range into a session; stages, writes no catalog rows |
| `import/spells/confirm` `import/psionics/confirm` `import/gear/confirm` | POST | Admin. Applies a session's pending rows as one batch |
| `import/stored` | GET / DELETE / POST | Admin. List (`?retired=1`), fetch, retire-or-delete, and POST to restore |
| `import/skills/extract` | POST | Admin. PDF → many skills, each classified against the catalog |
| `import/skills/confirm` | POST | Admin. Apply per-skill insert/update/ignore decisions |

Also at the site level: `/api/claude` (Anthropic proxy, allowlisted models) and
`/api/media` (MediaVault).

---

## Permissions

Three layers, all built on one identity read.

1. **Identity** — `_lib/access.js` `getAccessEmail()` reads the
   `Cf-Access-Authenticated-User-Email` header that Cloudflare Access injects.
   This is the only place that header is parsed. On localhost, where Access is
   not in front of the app, `_lib/auth.js` falls back to `dev@localhost`.
2. **Owner / GM** — `characterAccess()` allows a character's `player_email` or
   its campaign's `gm_email`; `campaignAccess()` is GM-only. Reads stay open to
   any authenticated user; only writes are gated. `campaigns.gm_notes` is the
   single read exception and is stripped server-side.
3. **Admin** — `isAdminEmail()` compares the identity against the `ADMIN_EMAIL`
   environment variable and **fails closed** when unset. Admin gates both
   importers, which touch global catalogs rather than one campaign.

Clients hide controls they cannot use, but the server enforces independently —
the UI check is a convenience, never the boundary.

---

## House rules and derived values

Palladium has no single answer for these, so the app invents one. Each is
overridable.

| Rule | Default | Override |
|---|---|---|
| Point-buy curve | All attributes start at 8, 40-point pool, +1 costs 1 point to 15 then 2 points to 18, cap 18, floor 3, refunds below 8 | — |
| Attribute rolls | 3d6, plus one bonus d6 on an exceptional 16+ | `attribute_dice` |
| XP table | Shared 15-level curve: 0, 2000, 4000, 8000, 16000, 25000, 35000, 50000, 70000, 95000, 125000, 160000, 200000, 250000, 300000 | `xp_table: [...]` |
| Psionic starting powers | minor 2, major 6, master 8; Super is master-only | `psionics.powers_starting`, `psionics.categories_allowed` |
| Save vs psionic attack | 12+ for Major and Master psychics, 15+ for everyone else | override `saves.psionics_target` on the character |
| Skills gained on level-up | Start at the catalog's base percentage — a skill learned at level 6 is still new | `skills.occ_related_skills.schedule` |
| Skill percentage cap | 98% | — |

**Attribute-derived values** (`js/derive.js`) follow the standard Palladium
pattern — a bonus applies from 16 up, one point per point above 15:

| Attribute | Drives |
|---|---|
| P.P. | strike, parry, dodge |
| P.S. | damage bonus |
| P.E. | vs poison, drugs, spell/ritual magic, pain; coma/death at 2% a point |
| M.E. | vs psionics, insanity, possession, horror factor |
| M.A. | invoke trust/intimidate — 40% at 16, +5% a point |
| P.B. | charm/impress — 30% at 16, +5% a point |
| Spd | running distance, Spd × 5 yards per melee |

Every derived value shows on the sheet as a placeholder on a dashed input;
typing overrides it and the field stops being marked derived. **Blank means "use
the table."** Attacks per melee beyond the base 2, and knockout/critical
thresholds, are deliberately *not* derived — they come from Hand to Hand tables
this app does not model, so they are plain editable fields.

Skills omitting `base` fall back to the catalog value — sourcebook class pages
state the *bonus*, with the base living in the skill table.

---

## Level-up skill picks

`skills.occ_related_skills.schedule` says a class grants extra skill picks at
certain levels — `[{ level: 3, count: 2 }, { level: 6, count: 1 }]`. Crossing
those levels now hands them over.

1. **The proposal lists them**, itemised by the level that earned each one. A
   jump from 2 to 7 collects both the level-3 and the level-6 grants; every
   threshold crossed counts, not just the highest.
2. **Choosing is optional.** Leave a slot blank and the pick is banked in
   `pending_skill_picks`. Levelling up is never blocked on picking a skill,
   which matters when it happens mid-session.
3. **The sheet shows what is unspent** until it is spent, and
   `characters/[id]/picks` applies it whenever the player comes back.

Two rules worth knowing:

- **A picked skill starts at the catalog's base percentage.** A skill learned at
  level 6 is new; it does not arrive back-dated with per-level bonuses.
- **The picker filters to the categories the grant allows**, with a toggle to
  show everything. Picking outside the allowed categories is permitted and
  **recorded as `override: true`** on the skill — so a human decision is visible
  as one, rather than looking like the rules permitted it. This differs on
  purpose from the psionic tier rules, where out-of-tier powers are simply not
  selectable: skill categories get bent at the table, psychic tiers do not.

Spending consumes the oldest grant first, and a grant only partly spent stays
pending with its count reduced — so two picks earned at level 3 can be taken one
at a time. Both paths write the skills and the claim in a single batch, because
a pick that consumed its grant without landing on the sheet would be lost.

---

## Starting gear the class leaves open

Books routinely say *"one energy pistol of choice"*. `equipment_starting` only
held fixed `item_id`s, so the importer wrote the **category** as if it were an
item — `energy-pistol`, `vibro-blade` — and the class importer dutifully created
a stub catalog row for each. Those rows are not items. No book entry will ever
match them, so they sat in the catalog with no stats and the character held a
weapon that does not exist.

An entry may now be a **choice**, the same idea `occ_skills` already used:

```yaml
equipment_starting:
  - { item_id: "back-pack", qty: 1 }
  - { choose: 1, label: "energy pistol", qty: 1,
      from: ["ng-33-northern-gun-laser-pistol", "wilk-s-320-laser-pistol"] }
```

- `from` enumerates **item slugs**. There is no `categories` flavour, unlike
  skills: gear's `category` is weapon/armor/vehicle/gear, far too coarse to mean
  "any energy pistol". The cost is that a new book's pistols must be added to
  the classes that offer the choice.
- `label` is what the player is choosing, shown above the options.
- **Every option must exist in the catalog** — cross-reference collects them all
  and stubs any that are missing, on the same reasoning skill groups use: any
  one of them could be the option actually picked.
- The wizard **will not advance** until every choice is resolved. Starting gear
  is finite and the book intends the character to have it, so an unresolved
  choice is an oversight, not a deliberate omission. (Unspent *skill* picks are
  banked instead — they are earned over time and often deliberately deferred.)
- Extraction emits these from the book's own wording (`of choice`,
  `one of the following`), and is told explicitly not to invent a placeholder
  item to stand for a category.

Retiring the placeholders that already existed is a one-off per environment:
[`db/retire-gear-placeholders.sql`](db/retire-gear-placeholders.sql). It
converts affected inventory rows to freeform lines — the placeholder was never
a real item, so naming it as text is the truthful representation — rewrites the
Juicer's two placeholders into choices, and drops the rows.

**Every statement guards itself**, which matters because a choice is only an
improvement if its options exist. An environment whose catalog is still
seed-only would otherwise have two bad references replaced by nine, and the next
class import would stub every one of them. So each rewrite requires its own
options to be present, and a placeholder is only dropped once no live class
still cites it. That makes the script safe to run **early** as well as twice: in
an environment that has not imported the equipment chapter it does nothing at
all, and the closing `SELECT` reports what it did and what it is still waiting
for (`options_available_of_8`). Re-run it after that import and it completes.

---

## Psychic tiers

Minor, Major and Master differ in three ways, and only the third is new.

**What already worked:** the character's tier comes from class frontmatter
(`psionics.type`), starting power counts are minor 2 / major 6 / master 8, and
Super psionics are Master-only through `psionics.categories_allowed`. That is a
**category** gate.

**What this adds** is a **per-power** gate. `psionic_powers.min_tier` records the
tier a book states for an individual power, and the picker will not offer one
above the character's tier. The two gates are not the same: a book can put a
Major-only power in Physical or Sensitive, which a Minor psychic can otherwise
reach — and that is the only case where the per-power gate does anything the
category gate does not.

- **`NULL` means no restriction beyond the category**, which is the overwhelming
  majority of rows and the behaviour that existed before. Books state tier at the
  category level far more often than per power.
- **Gated powers are counted, not listed.** "2 more powers need a higher psychic
  tier than minor" — so a short list reads as a rule rather than a gap in the
  catalog.
- **There is no override.** This differs deliberately from the level-up skill
  picker, where an out-of-category pick is allowed and flagged: skill categories
  get bent at the table, psychic tiers do not.
- **A power a character already holds is never taken away.** The gate applies to
  choosing, not to having, consistent with every other rule decision here.
- A class with no `psionics` block has no tier, so nothing is gated.

`derive.meetsTier(has, needs)` is the only place the ordering is written down.
Compare through it rather than comparing tier strings.

**Save vs psionic attack** now has a target as well as a bonus: 12+ for Major and
Master psychics, 15+ for everyone else — non-psychics included, since they get
attacked by psionics too. `deriveSaves()` previously returned only the M.E. bonus
and no number to roll against. It is overridable like every other derived value.

---

## How the sheet updates

Most of the sheet re-renders wholly — on load, on save, on a level-up, on
switching character. That is deliberate: correctness over cleverness.

Three paths update in place instead, because they used to destroy work:

| Path | What it does |
|---|---|
| Add armour | appends one slot to `#armor-list` |
| Remove armour | removes that slot, then renumbers the rest |
| Inventory add / remove / qty / equipped | refreshes `#inv-rows` only |

**Why it matters.** The section inputs (bio, combat, saves, armour) are only
read back at Save, by `collectSections()`. A full re-render rebuilt them from
stored state, so anything typed and not yet saved vanished. Armour add/remove
used to work around that with a `keepEdits()` call that copied the DOM into
state first — a patch every new interactive block had to remember to join in on.

The inventory paths were worse: they called `load()`, which **refetches the
character and replaces state wholesale**, so `keepEdits()` could not have helped
even if they had used it. Adding an item silently discarded your typing.

Now nothing else is touched, so unsaved edits simply survive — the DOM is the
source of truth for them until Save reads it back. `keepEdits()` is gone.

**If you add another in-place path**, remember `collectSections()` reads
`data-armor` as an array index. Removing a slot has to renumber the ones after
it, or the saved array acquires a hole.

---

## Server-side rule enforcement

The wizard has always enforced skill counts, categories and attribute minimums.
`_lib/validate-character.js` now re-checks them on every write that can change
skills — character create, level-confirm, and spending banked picks. The wizard's
checks are a convenience that avoids a round trip; this is the boundary.

**Deliberately narrow.** It checks what a player *chooses*, and returns a
structured `violations` list with a 422 rather than a flat message.

Four things that are not obvious and were each learned the hard way:

- **The fixed `occ_skills` list is not checked.** It is not a choice, so a
  mismatch means the class was edited or re-imported since the character was
  built — not the player's fault, and not something that should block their save.
- **The related-skill allowance grows with level**, by the grants in
  `occ_related_skills.schedule`. Without that, anyone who levelled up and spent a
  pick reads as over their limit.
- **A stored skill row is not a reliable source of category.** The wizard writes
  `category: "Class"` on every O.C.C. skill, so the validator resolves categories
  from the skills catalog and only falls back to the stored value.
- **Choice groups warn, they never block.** A character does not record *which*
  group a skill was taken for, so a skill the class also grants by name in the
  same category is indistinguishable from a chosen one. Counting by category both
  over- and under-counts, and refusing a save on an approximation would be worse
  than the gap it closes.

A skill marked `override: true` by the level-up picker is legal by definition —
that flag means a human decided it.

**Existing characters are not retro-validated.** They keep loading and saving
whatever state they are in; `admin/audit` reports which ones break a rule so you
can decide case by case. It is read-only and modifies nothing.

A character whose class cannot be resolved — retired, deleted, or no longer
parsing — **skips validation and saves normally**. Refusing would strand a
character whose class an admin retired, which is exactly what class soft-delete
was built to avoid. The audit lists those separately as unvalidatable.

---

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
separators and bracketed qualifiers, then suggests pairs. Nothing merges
automatically; you confirm each one, seeing both rows' numbers side by side.

Results are grouped by confidence, because the tiers are **not** equally
trustworthy. Measured against the real 138-row catalog:

| Group | What it means | Precision |
|---|---|---|
| Same name, different punctuation | identical once normalised | no false positives |
| Same words, reordered or inflected | `Basic Math` / `Mathematics — Basic` | no false positives |
| One name contains the other | `Laser` / `Laser Communications` | **~40%** — read these |

That last group is unavoidably ambiguous: `Chemistry` / `Chemistry — Analytical`
and `Demolitions` / `Demolitions Disposal` look identical to it and are genuinely
different skills. It is a judgement aid, not an oracle.

**What a merge does** differs by catalog, because references do:

- **Skills, spells, psionics** are referenced *by name* inside characters' JSON
  columns, so every character holding the losing name is rewritten. A character
  holding **both** names has them collapsed into one, or the validator would
  then flag it as a duplicate skill.
- **Gear** is referenced *by id* through `character_items.item_id`, so that
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

## The PDF importers

Both live on `import.html`, admin only, behind Class / Skills tabs.

The **catalog** importers (skills today; spells, psionics and gear to come) share
one pipeline in `_lib/import-engine.js` — extract, normalise, classify against
the catalog, batch-confirm — with the per-catalog differences in `IMPORT_SPECS`
and the columns coming from the field config. A fix there is a fix for all of
them rather than the same fix four times. The **class** importer is a different
shape (one class, markdown out) and stays on its own path.

Both send the PDF to Claude as a **document attachment**, never as extracted text:
layout-preserving text extraction splices neighbouring columns together mid-line
on two-column sourcebook pages, destroying the column boundary before extraction
starts. Do not add a text pre-pass.

Server-side callers use `_lib/claude-client.js` **directly**. Never reach the
proxy by fetching the site's own `/api/claude` URL: in production Access
intercepts the subrequest and returns the login page as HTML, which surfaces as
a confusing empty-response error.

### Class importer

1. **Upload** a page range covering exactly one class.
2. **Extract** — returns the whole class as markdown.
3. **Autosave** — stored as a `draft` the instant it parses, so a closed tab
   never loses an extraction.
4. **Review** — the markdown in one editable block, `extraction_notes` in a
   banner, missing catalog references listed. `recheck` re-validates edits with
   no further API spend.
5. **Confirm** — publishes the class (live immediately) and creates stub rows
   for anything it references.

#### Retiring a class

Deleting a **published** class retires it: `deleted_at` is stamped, and it
vanishes from the creation wizard, the extraction prompt's examples, and the
saved-imports list. It does **not** vanish from anything that resolves a class a
character already has — `getStored()` and therefore the sheet, the GM dashboard's
roster labels, and the XP and level-up endpoints all deliberately ignore
`deleted_at`. The sheet shows a "Retired class" advisory so the state is visible
rather than mysterious.

Retired classes live behind a **Retired (n)** toggle in the saved-imports panel,
where a Restore button undoes it. There is no permanent delete for a retired
class, by design.

Deleting a **draft** is still a real delete — a draft is an in-progress
extraction, usually one being cleared on purpose, and keeping every discarded
attempt would turn the retired list into noise.

### Skill importer

1. **Upload** a page range from a skill chapter, with an optional source-book
   label and category.
2. **Extract** — returns many skills as JSON, each classified as new or a
   duplicate, with the catalog's current numbers shown alongside the book's.
3. **Review** — duplicates offer **update** / **keep both** / **ignore**.
   A duplicate that is an empty stub defaults to *update*; any other duplicate
   defaults to *ignore*, so curated numbers are never silently overwritten.
   "Keep both" needs a distinguishing name, defaulting to `<name> (<book>)`.
4. **Confirm** — applied as one batch. Names claimed twice in a single import
   are reported as conflicts rather than failing the whole run.

A reply that hits the output ceiling is **rejected, not staged**. Half a page
saved as though it were the whole page is worse than a failure, because you
would confirm it without knowing the tail was missing. Narrow the page range.

In the Rifts core book the skill chapter is roughly **pp. 26–34**, about one or
two categories a page. Two pages yielded 33 skills in ~28 seconds.

### Spell importer

A spell chapter is hundreds of entries across many pages and does not fit one
sitting, so spell imports run inside a **session**:

1. **Start an import**, naming it and optionally labelling the source book.
2. **Feed it a page range at a time.** Each extraction is staged in the database
   the moment it parses, so a closed tab costs nothing — the model call is the
   expensive part and it is what gets saved.
3. **Review the pending list**, which accumulates across ranges. Duplicates
   default the same way skills do: a bare stub to *update*, anything curated to
   *ignore*.
4. **Import the batch.** The session stays open for the next range.

Two behaviours worth knowing:

- **A row that collides stays pending.** If an insert clashes with a name
  already in the catalog, it is reported and left in the list so you can give it
  a distinguishing name and retry, rather than being silently dropped.
- **An update whose target has vanished is reported, not swallowed.** A
  duplicate is staged with the catalog row it matched; if that row is renamed
  before you confirm, the `UPDATE` would match nothing and succeed silently. The
  engine checks first and reports it as a conflict, so the row stays pending and
  can be retried as an insert instead of disappearing with a success message.
- **Staging a page range is one batch**, so it is all-or-nothing like confirming
  one. A range yielding more than 300 rows is refused as too wide to have been
  read reliably.
- **Re-submitting a range you already did is harmless.** Names already staged in
  that session are skipped rather than duplicated.

Keep page ranges small. Spell entries carry a stat block plus prose, so they are
much longer than skill entries, and a reply that overruns the output ceiling is
rejected rather than half-saved.

### Psionic importer

The same session flow as spells — `_lib/session-import.js` is shared, and the
two endpoint files are three lines each. Psionic powers take the **same field
names as spells** (`range`, `duration`, `saving_throw`, `description`) so the
sheet can render both through one code path.

Two things are specific to psionics:

- **`min_tier`** records the psychic tier a book says a power requires. It is
  filled in **only when the entry itself states one**. Books state tier access
  at the *category* level far more often than per power ("Super Psionics are
  Master only"), so most rows legitimately have none, and the prompt is written
  to make saying nothing the easy answer. **NULL means no restriction beyond the
  power's category** — today's behaviour. Nothing enforces this column yet.
- **Unknown categories and tiers are flagged, never rejected.** A supplement
  that adds a category the core four do not cover must still be importable, so
  an unrecognised value imports with a ⚠ against it rather than failing. The
  same applies to a tier outside minor/major/master.

### Gear importer

Same session flow again. Two things are specific to gear.

**It is the only catalog matched on two fields.** Gear is unique on `slug`, and
every existing row is a stub created by a class import, keyed on the `item_id`
that class markdown referenced. The importer derives a slug from the book's item
name and matches on that first, then falls back to the display name — because a
stub stored as `ns-turbo-cyclone` will not match the slug that "NG-Turbo
Cyclone" produces, and **a missed match means a second row while characters keep
pointing at the empty one**. A fallback match is flagged in review so it is
visible rather than assumed.

**Gear has no `source` column**, so a stub is recognised by the marker the class
importer writes — `STUB — created by class import, needs stats`. A row edited by
hand no longer carries it and correctly stops counting as a stub.

Filling in a stub is an `UPDATE` in place, so `gear.id` never changes and
inventory rows keep resolving.

An equipment chapter is the hardest extraction of the four: weapon tables,
armour tables and prose gear descriptions share a page with entirely different
shapes. Most fields apply to only some kinds, and the prompt leans on omitting
rather than guessing — a backpack legitimately has nothing but weight, cost and
a description.

---

## Local development

Run from the repo root. There is no build step.

```bash
npx wrangler d1 execute DB --local --file db/schema.sql
npx wrangler d1 execute DB --local --file db/seed-catalogs.sql
npx wrangler pages dev
```

A database created before the `db/migrations/` files existed also needs those,
once each — see [Production configuration](#production-configuration).

Optional character/campaign test rows:

```bash
npx wrangler d1 execute DB --local --file apps/character-creator/db/seed-dev.sql
```

Smoke test (parser + schema):

```bash
node apps/character-creator/test/smoke.mjs
```

Copy `.dev.vars.example` to `.dev.vars` and set `ANTHROPIC_API_KEY` and
`ADMIN_EMAIL=dev@localhost` to exercise the importers locally. `.dev.vars` is
gitignored. To test owner/GM rules, send an explicit
`Cf-Access-Authenticated-User-Email` header.

---

## Production configuration

Set in the Cloudflare Pages dashboard, not in the repo:

- `ANTHROPIC_API_KEY` — encrypted secret, used by the proxy and both importers.
- `ADMIN_EMAIL` — the single email allowed to import. Fails closed.

**Schema changes are applied by hand, before the deploy that needs them.**
`db/schema.sql` is safe to re-run — every statement is `IF NOT EXISTS`:

```bash
npx wrangler d1 execute nates-workshop-media --remote --file db/schema.sql
```

Content written this way is **not** safe for non-ASCII on Windows — see the
em-dash note in [Known limitations](#known-limitations-and-refactor-candidates).
Schema files are pure ASCII, so this applies to data loads, not migrations.

`db/migrations/*.sql` are **one-shot** and cannot be made idempotent, because
SQLite has no `ADD COLUMN IF NOT EXISTS`. Run each once per environment, in
filename order.

**Ask the database what it has had applied** rather than inferring it from
columns:

```bash
npx wrangler d1 execute nates-workshop-media --remote --command "SELECT filename, applied_at FROM schema_migrations ORDER BY filename"
```

| Migration | Adds |
|---|---|
| `001-character-detail.sql` | `bio`, `combat`, `saves`, `armor` on `characters` |
| `002-catalog-provenance.sql` | `source_book` + `note` on `skills`; `source_book` on `spells`, `psionic_powers` |
| `003-class-soft-delete.sql` | `deleted_at` on `imported_classes` |
| `004-items-to-gear.sql` | renames `items` to `gear`. **Not additive** — apply immediately before the matching deploy, not ahead of it |
| `005-spell-detail.sql` | range, duration, damage, saving_throw, area_of_effect, casting_time, description on `spells` |
| `006-import-sessions.sql` | `import_sessions` + `import_staged` |
| `007-psionic-detail.sql` | range, duration, saving_throw, description, min_tier on `psionic_powers` |
| `008-gear-detail.sql` | gear stat block; **drops the `stats` JSON blob**, which was empty in every row |
| `009-pending-skill-picks.sql` | `pending_skill_picks` |

### The migration convention

- Filenames are `NNN-kebab-description.sql`, applied in ascending order.
- Every migration **ends by recording itself**:
  `INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('NNN-….sql');`
- Migrations are **never edited after being applied anywhere**. A mistake gets a
  new numbered file.
- `db/schema.sql` also seeds `schema_migrations`, because a database created from
  it already contains every column the migrations add and is current the moment
  it exists. **Each seeded row is guarded by the schema feature its migration
  adds** — on an existing database every `CREATE` in `schema.sql` is skipped, so
  an unguarded insert would mark an old, un-migrated database as migrated, which
  is exactly the lie this table exists to prevent. Add a guarded line to that
  block whenever you add a migration.
- The smoke test fails if a file in `db/migrations/` has no matching row, or if a
  recorded row has no matching file.

Running `db/schema.sql` against an already-current database is therefore how you
backfill the records — no separate backfill migration is needed.

Merging to `main` is the deploy — Pages auto-deploys, no CI, no build command.
Cloudflare Access fronts the whole site with the path left blank, so every route
including `/api/*` is covered; there is no Access policy-as-code in the repo.

Verify anything applied to production by querying it back, not by trusting an
exit code — `wrangler d1 execute` has been observed reporting a non-zero exit on
a fully successful run.

---

## Known limitations and refactor candidates

Honest list, roughly by value.

Most of these are planned out as twelve PRs under
[`docs/plans/`](docs/plans/README.md), with the design decisions and the
rejected alternatives recorded per PR.

**The catalog editor has no general delete.** Rows are created and corrected by
hand; the only deletion is the one a merge performs. Deliberate — see
[`docs/plans/04-catalog-edit-ui.md`](docs/plans/04-catalog-edit-ui.md).

**A gear choice must enumerate its options.** `{ choose, from }` takes an
explicit list of slugs, because gear's `category` (weapon/armor/vehicle/gear) is
far too coarse to express "any energy pistol". So importing a book with new
pistols does not automatically widen the classes that offer one — the `from`
list has to be extended by hand. Tagging gear would fix this properly; it was
deferred as a larger change than the problem currently warrants. See
[Starting gear the class leaves open](#starting-gear-the-class-leaves-open).

**Migrations are still applied by hand.** `schema_migrations` records what has
run where and the smoke test checks it, but applying a migration is still a
manual `wrangler d1 execute` per environment. That is a deliberate stopping
point, not an oversight — see [`docs/plans/01-migration-tracking.md`](docs/plans/01-migration-tracking.md).

**Extraction reads well; naming is the real friction.** Importing the Rifts
skill chapter (pp. 26–34, 9 pages, ~93s of model time) produced 80 new skills
with **no column-splicing at all** — every note read coherently, and spot-checks
matched the book (`Intelligence 32%/+4`, `Sniper 0%`, `Medical Doctor 60%/50%`
captured as a note). Earlier runs did show a secondary percentage split into its
own entry and a skill read as 0% where the catalog had 30%, so the review step
still earns its place — but the failure mode that actually cost time was
**names**, not numbers: ten skills already existed under different spellings.
See [Merging duplicate catalog rows](#merging-duplicate-catalog-rows).

Do not bulk-accept a new book's first run. Read the prose, not just the figures —
a spliced column produces a description that reads fluently and is wrong.

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

**The three page scripts are long, and deliberately not split.** `app.js` (~800
lines), `import.js` (~720) and `sheet.js` (~650) each drive one page and each
does several jobs. Splitting was considered and rejected: there is no build step,
so there is no bundler — splitting means more `<script>` tags, hand-managed load
order, and the classic-script/module distinction to keep straight. The cost is
real and the benefit is aesthetic. `import.js` is the clearest seam if this is
ever revisited, since its class, skills and session-based flows share a page and
almost no logic.

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
