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
- [A race and an occupation together](#a-race-and-an-occupation-together)
- [One place composes a class](#one-place-composes-a-class)
- [Classes that come in stages](#classes-that-come-in-stages)
  - [Changing stage](#changing-stage)
- [Powers the player chooses](#powers-the-player-chooses)
- [A power list several classes share](#a-power-list-several-classes-share)
- [What a class grants mechanically](#what-a-class-grants-mechanically)
  - [The review step](#the-review-step)
- [Which system a catalog row belongs to](#which-system-a-catalog-row-belongs-to)
- [Filtering the catalog pickers](#filtering-the-catalog-pickers)
- [Unfinished builds are saved](#unfinished-builds-are-saved)
- [Starting gear the class leaves open](#starting-gear-the-class-leaves-open)
- [Psychic tiers](#psychic-tiers)
- [How the sheet updates](#how-the-sheet-updates)
- [Server-side rule enforcement](#server-side-rule-enforcement)
- [The catalog field config](#the-catalog-field-config)
  - [What a list row shows](#what-a-list-row-shows)
- [Merging duplicate catalog rows](#merging-duplicate-catalog-rows)
  - [Retired keys keep resolving](#retired-keys-keep-resolving)
- [The PDF importers](#the-pdf-importers)
  - [Class importer](#class-importer)
  - [Skill importer](#skill-importer)
  - [Spell importer](#spell-importer)
  - [Psionic importer](#psionic-importer)
  - [Gear importer](#gear-importer)
- [Local development](#local-development)
- [Production configuration](#production-configuration)
  - [The migration convention](#the-migration-convention)
  - [Data scripts](#data-scripts)
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
├── js/rules.js               Closed lists the book fixes — the seven alignments,
│                             the currency names, the nine background tables
│                             (classic script, same reason as derive.js)
├── js/psionics.js            Step 3: the Random Psionics Table, the tier rules,
│                             and folding a rolled tier into a class (ES module —
│                             the Workers runtime needs it too)
├── js/compose.js             The ONE place a character's classes become the
│                             thing it is played as (ES module)
├── js/api.js                 The one HTTP helper for all five pages, and
│                             errorDetails() (classic script)
├── js/picker.js              Catalog picker filtering — matching, the filter
│                             input, and caret restore (classic script, same
│                             reason as derive.js)
├── js/class-template.js      Annotated OCC/RCC skeletons for writing a class by
│                             hand (classic script — import.js is one)
├── js/class-blocks.js        Rewrites ONE frontmatter block in place, so the
│                             structured editors cannot disturb the rest of the
│                             file (classic script)
├── db/*.sql                  One-shot SQL. NOT migrations — these change rows,
│                             not schema. See Data scripts below
├── docs/rules-audit.md       Where each implemented rule comes from, by page
├── docs/plans/               The twelve original PRs, with their rejected
│                             alternatives
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
    ├── _lib/catalog-redirects.js  Retired catalog keys keep resolving to their
    │                         replacement, so an old class file still loads
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

`js/derive.js`, `js/picker.js` and `js/api.js` are deliberately *classic*
scripts rather than modules, so the plain-script pages can use them without
converting the whole file. `js/api.js` is loaded by all five pages and defines
`api()` and `errorDetails()`; there used to be five copies of `api()` in three
variants, which is a nuisance while they agree and a bug when they do not — the
wizard and the sheet learned to carry a failed response's `violations` through
to the reader while the catalog editor and importer kept throwing that half
away, so the same 422 explained itself on one page and said
*"Request failed (422)"* on another.

`jsonReq` is deliberately **not** shared: the sheet's takes `(method, body)` and
the importer's takes `(body)` and always posts.

---

## Data model

Seventeen tables in one shared D1 database (`nates-workshop-media`, bound as `DB`).
`media_items` belongs to MediaVault and `schema_migrations` is database
bookkeeping shared by both; the rest are this app.

**Character data**

| Table | Notes |
|---|---|
| `campaigns` | Top-level container. `gm_email` owns it. `gm_notes` is GM-only and stripped from non-GM API responses. |
| `characters` | See below — several JSON columns. `class_variant` names which `variants` entry the character is; NULL means the class as written. `occ_class_id` is the O.C.C. taken alongside an R.C.C.; NULL means none. |
| `character_items` | Inventory join. `item_id` NULL means a freeform item (`custom_name` required). `removed_at` NULL means currently held — removals are soft, so history survives. |
| `journal_entries` | `character_id` NULL means a campaign-level entry. |
| `level_history` | One row per confirmed level-up; `changes` is a JSON diff of what was actually applied. |
| `pending_skill_picks` | Skill picks a level-up granted and nobody has spent yet. One row per **grant**, not per pick, so "2 picks from level 3" stays itemised. `categories` is copied from the class at level-up time — the class can change later, what you were granted cannot. |

`characters` stores ten JSON columns rather than a very wide table — the list
lives in `_lib/character-json.js` as `CHARACTER_JSON_COLUMNS`:

| Column | Shape |
|---|---|
| `attributes` | `{ "IQ": 12, "ME": 14, … }` |
| `attribute_bonuses` | `{ "PS": 3 }` — what a class's **dice** attribute bonuses rolled, kept because a roll cannot be re-run per render |
| `rolled_bonuses` | `{ "combat": { "initiative": 3 } }` — the same, for a class's **dice** combat and save bonuses |
| `skills` | `[{ name, category, pct, per_level, type: "occ"\|"related"\|"secondary" }]` |
| `powers` | `[{ type: "spell"\|"psionic", name, level?, category?, cost }]` |
| `abilities` | `["Super-Tough", "Shape Shifter", "Shape Shifter"]` — powers chosen from a class's list. A list, not a set: **duplicates are meaningful** |
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
| `spells` | `system` NULL means unrestricted. name, level, ppe, plus a stat block (range, duration, damage, saving throw, area of effect, casting time, description). The stat block is TEXT — books write "100 feet per level" as often as a number. |
| `psionic_powers` | name, category (Healing/Physical/Sensitive/Super), isp, plus range, duration, saving throw and description — the same field names spells use. `min_tier` is the psychic tier a book states is required; NULL means no restriction beyond the category. |

All catalogs carry `source` (`seed` \| `import`) and `source_book`, so an entry's
provenance is visible and the same skill from two books can coexist under
distinguished names. Rows created as stubs by the class importer have zeroed
numbers — the skill importer exists to fill them in.

**Working state** — not content, and not a character

| Table | Notes |
|---|---|
| `character_drafts` | One unfinished wizard build per person, `UNIQUE (owner_email)`. `state` is the build as JSON — deliberately not the catalogs it was built against. Its own table rather than a `draft` status on `characters`; see [Unfinished builds are saved](#unfinished-builds-are-saved). |
| `catalog_redirects` | Where a retired key went. Written when a merge deletes a row or a key is renamed by hand, so class markdown citing the old slug or name keeps resolving. Polymorphic by design — `catalog` names which table `to_id` points into — so there is no foreign key. See [Retired keys keep resolving](#retired-keys-keep-resolving). |
| `import_sessions` | One resumable catalog import. `catalog` is which of the four it feeds, `system` is stamped on every row the session confirms, `closed_at` NULL means still open. |
| `import_staged` | Rows one page range extracted, held until confirmed. `payload` is the extracted row as JSON, `match_name` the catalog row it duplicates, `action` the `insert` / `update` / `ignore` decision, `confirmed_at` NULL means still pending. Cascades from its session. |

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
    # A category is a plain string (any skill in it) or an object narrowing it.
    # `only` and `except` are mutually exclusive — setting both is an error.
    categories:
      - "Physical"
      - { name: "Espionage", only: ["Escape Artist"] }
      - { name: "Science", except: ["Anthropology"] }
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }]
  secondary_skills:
    count: 2
    schedule: [{ level: 4, count: 1 }]   # secondary grants schedule too
starting_money: "2d6x10"      # a formula or a flat number; coin only
equipment_starting:
  - { item_id: "ns-turbo-cyclone", qty: 1 }
  - { choose: 1, label: "energy pistol", qty: 1, from: ["ng-33-northern-gun-laser-pistol", "wilk-s-320-laser-pistol"] }
psionics:
  type: "major"               # minor | major | master
  isp_base: "1d4x10+20"
  powers: ["Sixth Sense"]     # powers the class automatically knows
# psionics_allowed: false     # a race with NO psychic potential (troll, orc);
                              # skips the Random Psionics Table entirely
magic:
  type: "innate"
  spells_starting: 6
  spell_levels_allowed: [1, 2]
  spells: ["Globe of Daylight"]   # only if the book names specific spells
special_abilities:
  - { name: "Psi-Sword", description: "..." }
  # An ability the player CHOOSES may carry what it grants, and may be
  # repeatable with a different second-take meaning. See the section below.
  - name: "Super-Tough"
    description: "Add 1D6 to P.E. and 3D4x10 to M.D.C."
    bonuses: { attributes: { PE: "1d6" }, pools: { mdc: "3d4x10" } }
  - { choose: 3, from: ["Psi-Sword", "Super-Tough"] }   # or from_class: godling
bonuses:                      # mechanical grants — see the section below
  pools: { ppe: "4d6" }              # ADDED to a pool's own formula; dice or flat
  attributes: { PS: 2, PE: "1d4" }   # a flat number OR dice
  attribute_minimums: { PS: 22 }     # a floor applied AFTER the bonus lands.
                                     # NOT attribute_requirements, which gates
                                     # whether the class may be taken at all
  combat: { attacks: 1 }
  at_level: [{ level: 5, combat: { attacks: 1 } }]
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
| `catalogs/duplicates` | GET / POST | Admin. Suggested duplicate pairs for a catalog; POST merges two rows. `?counts_only=1` returns just the per-tier counts, for the badge |
| `catalogs/redirects` | GET / DELETE | Admin. Retired keys and where they resolve (`?catalog=`); DELETE stops forwarding one (`&id=`). No POST — redirects are written by merges and renames |
| `items` | GET | Gear catalog (table is `gear`), plus retired slugs as `redirects`. `?system=` — a NULL system is unrestricted, matching how `skills.systems` reads |
| `campaigns` | GET / POST | List (`?system=`, `?limit=`, `?offset=`); create (caller becomes GM) |
| `campaigns/[id]` | GET / PATCH | Details (`gm_notes` stripped for non-GM); edit `gm_notes` |
| `draft` | GET / PUT / DELETE | The caller's own unfinished wizard build. No id in the route — a draft belongs to a person, not a collection. One each; PUT upserts |
| `characters` | GET / POST | List (`?campaign_id=`, `?limit=`, `?offset=`); create at level 1 — **validated against the class rules** |
| `characters/[id]` | GET / PATCH | Sheet + inventory, with `can_write` / `is_gm`; edit pools, notes, and the bio/combat/saves/armor sections |
| `characters/[id]/items` | POST | Add inventory row (catalog slug or freeform) |
| `characters/[id]/items/[itemId]` | PATCH / DELETE | qty/equipped/notes; soft remove |
| `characters/[id]/xp` | POST | `{delta}` or `{total}`; returns a proposed level-up diff |
| `characters/[id]/variant` | POST | Owner/GM. `{to_variant}` proposes a change of stage; add `confirm: true` with the accepted attributes and pools to apply it |
| `characters/[id]/level-confirm` | POST | Apply a confirmed diff, write `level_history`. `picks` spends granted skill picks; unspent ones are banked. Validated |
| `characters/[id]/picks` | GET / POST | Owner/GM to spend. Unspent skill picks; POST applies some. Validated |
| `admin/audit` | GET | Admin, read-only. Which existing characters break their class rules |
| `journal` | GET / POST | By campaign; `?character_id=`, `?include_campaign=1`, `?limit=`, `?offset=` |
| `import/extract` | POST | Admin. PDF → class markdown; autosaves a draft |
| `import/recheck` | POST | Admin. Re-parse edited markdown, no API spend. Returns the parsed frontmatter as `data` for the structured editors |
| `import/confirm` | POST | Admin. Publish class + create catalog stubs |
| `import/sessions` | GET / POST | Admin. Resumable catalog imports: list (`?catalog=`), fetch one with its staged rows (`?id=`), create, close. `system` on create is stamped on every row the session imports |
| `import/spells/extract` `import/psionics/extract` `import/gear/extract` | POST | Admin. One page range into a session; stages, writes no catalog rows |
| `import/spells/confirm` `import/psionics/confirm` `import/gear/confirm` | POST | Admin. Applies a session's pending rows as one batch |
| `import/stored` | GET / PUT / DELETE / POST | Admin. List (`?retired=1`), fetch, PUT saves `{markdown}` as a draft, retire-or-delete, and POST to restore |
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
| Attribute rolls | Book rule, not a house rule — see below | `attribute_dice` |
| XP table | Shared 15-level curve: 0, 2000, 4000, 8000, 16000, 25000, 35000, 50000, 70000, 95000, 125000, 160000, 200000, 250000, 300000 | `xp_table: [...]` |
| Psionic starting powers | Book rule for a rolled psychic (minor 2; major 8 from one category or 6 from three). A class states its own; master 8 and Super are class-only | `psionics.powers_starting`, `psionics.categories_allowed` |
| Save vs psionic attack | 12+ for Major and Master psychics, 15+ for everyone else | override `saves.psionics_target` on the character |
| Skills gained on level-up | Start at the catalog's base percentage — a skill learned at level 6 is still new | `skills.occ_related_skills.schedule` |
| Skill percentage cap | 98% — book rule (p.22), applied at creation and on level-up | — |

**Starting money** (p.22) is `starting_money` on the class — a formula string
like `"2d6x10"` or a flat number — rolled through the same `rollPoolFormula` the
pools use, so Review's Reroll button covers it. It lands in the character's
`bio` rather than a column, because it is a running number the player edits.
Labelled Gold in Palladium Fantasy and Credits in Rifts, from
`rules.currencyLabel()`; an unknown system gets the neutral "Money".

The book gives a character its O.C.C. equipment list **and** a sum of coin, so
nothing is deducted from the other — the gear step is unchanged and the purse is
simply recorded. Only coin goes in `starting_money`; saleable goods and
artifacts belong in `equipment_starting`.

**A choice group may carry a bonus rather than a base.** `base` states the
percentage outright; `bonus` adds to whatever each pick's own base is. A group
spanning a category needs the second — "three languages of choice at +30%"
cannot be one number, because the members start at different percentages.
Setting both is an error. A skill with no percentage (a W.P.) stays at zero,
exactly as the I.Q. bonus already works.

**Secondary skills can arrive on a schedule**, like related ones. A grant
records which kind it is, because the two are not interchangeable: related picks
are bounded by the class's categories and secondary picks are not. The call
sites keep them apart, or one unrestricted secondary grant would unrestrict the
related picks with it. A pick inside the categories spends a related slot; one
outside spends a secondary slot and is stored as a secondary skill.

**A related-skill category may be restricted.** Books state limits per
category — "Espionage: Escape Artist only", "Physical: any except Acrobatics,
Gymnastics and Wrestling", "Medical: none" — and a bare category name offered
all of it. An entry is now either a plain string, meaning any, or an object:

```yaml
categories:
  - "Wilderness"
  - { name: "Espionage", only: ["Escape Artist"] }
  - { name: "Physical", except: ["Acrobatics", "Gymnastics"] }
```

Setting both `only` and `except` is an error rather than a guess. A forbidden
skill is **never offered**, rather than offered and rejected on save; the
server-side validator enforces the same rule as a backstop, through the same
`categoryAllows()` helper, so the picker and the validator cannot disagree about
what is legal.

Naming a skill the catalog does not hold yet is harmless: an `except` for a
missing skill excludes nothing, and an `only` narrows the category to what does
exist, so the restriction is already right for the day it is imported.

**But the two fail in opposite directions, and the importer now says so.**
`categoryAllows` compares literal names, so an unmatched `except` fails **open**
— the class goes on offering a skill the book forbids — while an unmatched
`only` fails closed. A not-yet-imported skill and a name the catalog simply
spells differently are indistinguishable, and the second is the common case: the
Godling R.C.C. bars robots, power armor and cybernetics, which this catalog
calls `Robots and Power Armor`, `Robot Combat: Basic` and `M.D. in Cybernetics`,
so all three exclusions quietly did nothing. The cross-reference now reports
every restriction name that matches no catalog row, on the review step beside
the missing-reference lists. It is a warning, not a refusal — the
forward-compatible case above is still legitimate.

Redirects are deliberately **not** consulted for this check, though they are for
missing references. A merged-away name still resolves as a *reference*, but
`categoryAllows` does a literal comparison, so a redirect does not save a
restriction and reporting it as fine would misdescribe what the picker does.

**A bonus may be dice, in any group.** Some books state one as a roll rather than a
number — the Cyber-Knight adds +1D4 to five attributes, the Juicer +2D6 to P.S.
and +2D4x10 to Spd. `bonuses.attributes` accepts either, and
`bonuses.attribute_minimums` expresses a guaranteed floor ("minimum P.S. is 22;
if lower, adjust up"), applied *after* the bonus lands. That is deliberately not
`attribute_requirements`, which gates whether the class may be taken at all.

The dice belong to the class and the result belongs to the character
(`attribute_bonuses`, migration 016), because a roll cannot be re-evaluated on
every render.

**Combat and save bonuses take dice too**, and for the same reason land in a
stored column (`rolled_bonuses`, migration 019). They were flat-only on the
assumption that books always print them that way — the Godling's *"+1D4 on
initiative"* is the counter-example, and it was a hard parse error rather than
something the format could hold. Attributes keep their own column: 016 predates
this, its flat shape is read directly in several places, and rewriting stored
rows for tidiness would be a poor trade. It is rolled when the class is confirmed, so the Attributes step
can show it beside the roll it modifies, and re-rolled only by Review's Reroll
button — walking to a later step used to re-roll it silently, which changed a
number the player had already read.

**The background tables are rollable** (p.32–33). Nine percentile tables —
birth order, weight, height, age, disposition, land of origin, environment,
family background and racial bias — every one of them optional, with nothing
derived from the result.

Each field the book has a table for gets a die beside it, and one button rolls
everything still blank, so a name and age already decided survive. The Age
table's "double it for an elf, dwarf or changeling" is a checkbox rather than
something detected from the race field, which is free text.

Four of the nine had no bio field and now do; all nine store in the same `bio`
blob, so there is no migration.

**A variant may restate a skill's percentage.** `skill_overrides` names skills
the class already grants and changes only their `base` and `per_level` — a
Chiang-Ku hatchling starts its advanced math and domestic skills at first-level
proficiency where the adult has them at 96% and 80%. Naming a skill the class
does **not** grant is an error, not a way to add one, so the rule that a variant
cannot restructure the skill list still holds.

**A rolled major psionic pays for it.** The starting related-skill count is
halved, rounding down; secondary skills are untouched, as the book says. This
wizard asks for skills before powers where the book asks in the other order, so
rolling major trims any picks already made beyond the new allowance and says how
many went. A psychic O.C.C. never rolls and never pays. A class may also declare
`psionics_allowed: false` — troll and orc have no psychic potential at all —
which skips Step 3 entirely.

**Psionics can be rolled for** (p.20–21). A class granting no psychic powers
sends the character to the Random Psionics Table — 01-09 major, 10-25 minor,
26-00 none, so three quarters of characters get nothing and that is the ordinary
result. Rolling can never reach **master**, which comes only from a psychic
O.C.C.; a class that already declares psionics does not roll at all, because the
book offers the two routes as alternatives rather than as things that stack.

A minor psychic takes 2 powers from one category; a major takes 8 from one or 6
from any of the three, and picks which. I.S.P. is M.E. + 2d6 (minor) or M.E. +
4d6 (major), growing 1d6 or 1d6+1 an experience level.

The tier belongs to the **character**, not the class — `psychic_tier` and
`psychic_shape`, migration 015. `withRolledPsionics()` folds it into the
class-shaped object, so the save target, the power gating and the level-up
growth all keep reading `cls.psionics` exactly as they do for a Mind Mage.
Exactly one place applies it, because exactly one place composes a class — see
[One place composes a class](#one-place-composes-a-class). It did not start that
way, and the missed call site is the bug that caused the refactor.

**Alignment is required** and closed (p.23). Seven values in three groups —
Good (Principled, Scrupulous), Selfish (Unprincipled, Anarchist) and Evil
(Miscreant, Aberrant, Diabolic) — with deliberately **no neutral**; the book
spends a paragraph ruling it out. The list lives in `js/rules.js`.

The wizard will not save a character without one. It is *not* enforced
server-side, because a character created before the field existed has none and
rejecting its updates would make it uneditable until somebody guessed what it
used to be. The sheet offers the picker, marks a missing alignment, and saves
either way — and a value that is not one of the seven is preserved rather than
dropped, so opening such a character cannot erase what it had.

**Exceptional attribute rolls** (`js/dice.js`, p.14) are the book's, not ours. A
3d6 attribute rolling 16, 17 or 18 earns one extra 1d6; if that die is a six it
earns **one** more, and the chain stops there however the second lands. A 2d6
attribute earns its extra die on a 12. Nothing else does — 4d6, 5d6 and 6d6 are
excluded by name however high they roll, and pools the book does not mention get
nothing rather than an invented threshold.

The threshold reads the **dice**, not the total: a race written `3d6+6` is
exceptional when its dice show 16, not when the total reaches it — otherwise a
below-average roll of 10 would earn a reward reserved for the top of the range.

A class that spells out its own `3d6` now behaves identically to one that says
nothing. It used to not: stating the dice took a branch that skipped the bonus
die entirely, so the same 3d6 produced different characters depending on how the
class happened to be written. The wizard shows the working (`3d6 18 ·
exceptional +6, +4`) because an unexplained 28 off a 3d6 reads as a bug.

**Attribute-derived values** (`js/derive.js`) come from the Attribute Bonus
Chart on p.16, transcribed row by row — see
[`docs/rules-audit.md`](docs/rules-audit.md) for the full table and
[`test/smoke.mjs`](test/smoke.mjs) `[1c17]`, which asserts the printed values.

The rows deliberately disagree with one another, and that is the point:

| Attribute | Drives | Shape of the row |
|---|---|---|
| P.P. | strike, parry, dodge | +1 per **two** points from 16 |
| P.S. | damage bonus | +1 per point from 16 |
| P.E. | vs poison, drugs, spell/ritual magic, pain, illusionary magic | +1 per **two** points |
| P.E. | coma/death | +4% at 16, +5% at 17, then +2% a point |
| M.E. | vs psionics, possession, horror factor, mind control | +1 per **two** points |
| M.E. | vs insanity | +1 per two to 19, then +1 a point |
| M.A. | invoke trust/intimidate | 40% at 16, +5% a point, flattening after 24 |
| P.B. | charm/impress | 30% at 16, +5% a point, flattening after 26 |
| I.Q. | one-time bonus to every skill percentage | +2% at 16, +1% a point |
| Spd | running distance, Spd × 5 yards per melee | no bonus at any value |

Only P.S. and Spd match the `v - 15` this file used to apply to everything.
Parry, dodge, strike and three saves were roughly **double** the printed value,
M.A. and P.B. climbed past 100%, and the I.Q. row was missing outright.

Two house rules where the book stops: rows **continue past 30** on the step they
end on, since the chart ends there and dragons do not, and the two percentile
rows are **capped at 98%**, matching the skill ceiling. The flat rows are
bonuses added to a roll rather than percentages, so the cap does not reach them.
Possession, horror factor and pain are not on the chart at all; each borrows the
row for its own attribute.

`iq_skill_bonus_pct` is exposed by `derive.bio()` and applied to every skill at
creation — see **The I.Q. bonus** below for what that means and what it skips.

Every derived value shows on the sheet as a placeholder on a dashed input;
typing overrides it and the field stops being marked derived. **Blank means "use
the table."** Attacks per melee beyond the base 2, and knockout/critical
thresholds, are deliberately *not* derived — they come from Hand to Hand tables
this app does not model, so they are plain editable fields.

Skills omitting `base` fall back to the catalog value — sourcebook class pages
state the *bonus*, with the base living in the skill table.

**The I.Q. bonus** (p.22) is a one-time addition to every skill percentage, made
at creation and never again. It reaches secondary skills too: the book's "no
skill bonuses are applicable" is about the bonus printed in parentheses on the
O.C.C. page — the same sentence limits that one to related selections — while
the I.Q. bonus is a separate paragraph about the character. Skills with no
percentage at all (W.P.s, hand to hand) stay at zero.

`pct` remains the true current percentage, because level-up increments it and
the sheet prints it; each skill also carries `iq_bonus` recording how much of it
came from I.Q., so 39% is distinguishable from a skill whose base genuinely is
39. The sheet shows it inline after the name.

**Secondary skills are no longer frozen.** The wizard used to write
`per_level: 0` on every one of them, which is right about the O.C.C. bonus and
wrong about everything else — the book says plainly that *all* skills increase
with experience. A level 10 character's hobby skills sat at their level 1
values. They now carry the catalog's real per-level step.

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

## A race and an occupation together

Palladium characters routinely have both. A Chiang-Ku Dragon who studies wizardry
is a dragon **and** a wizard, and the two contribute different halves: the race
sets the body, the occupation sets what was learned. This is also why a racial
class legitimately grants **no** related or secondary skills — those come
entirely from the O.C.C., so an R.C.C.-only character correctly has none.

A character carries `class_id` (+ `class_variant`) for the race and
`occ_class_id` (+ `occ_class_variant`) for the occupation. Both optional halves;
every character created before this has `occ_class_id` NULL and behaves exactly
as it did.

`combineClasses(rcc, occ)` composes them into **one class-shaped object**, the
same trick `applyVariant` uses a layer down. Callers do not reach for it
directly: [`js/compose.js`](js/compose.js) is the single place that knows the
whole order — variant, then race + occupation, then any rolled psionics — and
every site goes through it. See
[One place composes a class](#one-place-composes-a-class). The validator, the level-up diff,
`derive`'s bonuses and the sheet all read `cls.skills`, `cls.bonuses` and the
pool bases as before — none of them knows a character can have two classes.

| | comes from |
|---|---|
| attribute dice, pool formulas | the **race** |
| attribute minimums | **both** — the stricter of each |
| fixed skills | **both**, a shared skill held once at the higher base |
| related & secondary allowances | the **occupation** |
| bonuses | **both** — flat numbers summed, dice collected (see below) |
| psionics | the **stronger tier** |
| magic | the **occupation** |
| equipment, abilities, level progression | **both** |

Three rules earned by getting them wrong first:

- **A pool the race does not mention falls through to the occupation** — but an
  M.D.C. race keeps no hit points. Silence means "not applicable" for a creature
  that tracks M.D.C. and "no opinion" for one that simply omits the line.
- **A skill both classes grant is held once**, at the higher base. Concatenating
  blindly produced a character holding Wilderness Survival twice, which the
  validator correctly refused to save. Choice-groups are *not* collapsed — they
  have no identity to match on, so "pick 3 Science" from each class is six picks.
- **The audit and the stage-change endpoint compose too.** Judging a Chiang-Ku
  Wizard against the dragon alone reports every skill its occupation grants as a
  violation.
- **A dice bonus cannot be summed, so it is collected.** A race granting
  `+1d4 P.S.` and an occupation granting `+2d6` means both are rolled; there is
  no single expression that says so, so the merged value is `["1d4", "2d6"]` and
  each rolls. Flat numbers still add, and a mixed list keeps both halves.

  This is the shape of a bug that was live: the merge copied the second class's
  values **only when they were numbers**, so every dice bonus arriving from the
  *occupation* was silently dropped. Any R.C.C. composed with the Cyber-Knight
  lost all five of its `+1D4`s, and nothing reported it. The same collect rule
  now applies within one class, where a level-1 dice bonus and an `at_level` one
  for the same attribute used to overwrite each other.

---

## One place composes a class

Turning a character's classes into the thing it is played as takes three steps,
and the order matters:

1. **apply each class's variant** — a Dragon hatchling is not an adult
2. **compose race with occupation** — into one class-shaped object
3. **fold in rolled psionics** — a tier the character rolled, not one the class declared

Six places did this by hand: the class loader, the sheet's endpoint, the
stage-change endpoint, the admin audit, and the wizard twice. They agreed only
by luck, and each time a step was added, all six had to learn it.

Adding the O.C.C. step meant touching all six. Adding the psionics step meant
touching all six again — and **one was missed**, so the sheet showed a rolled
major psychic a save target of 15 where the level-up path correctly had 12. That
bug is why [`js/compose.js`](js/compose.js) exists.

```js
composeClass({ rcc, occ, character })
```

What still differs per caller is how a class is **fetched** — some await D1, the
audit reads a preloaded map, the sheet's endpoint tolerates a retired class, the
wizard has them in memory. That part is genuinely different and stays at the call
site. What is identical everywhere is what to do once you have them.

A smoke check fails the build if any source file calls `combineClasses(`
directly, because that is what re-implementing the sequence looks like. It scans
every page script, every module under `js/`, and every function, exempting only
the two files the sequence is built from: `parser.js`, which declares
`combineClasses`, and `compose.js`, which is the one legitimate caller.

## Classes that come in stages

Several RCCs are not one statblock but several. A Dragon is a hatchling, then
young, then adult — sharing lore, natural abilities and skills, differing in
attribute dice, M.D.C. and what the class grants. Four unrelated class files
means maintaining the shared 90% four times and watching it drift.

```yaml
mdc_base: "1d4x100"
variants:
  - id: hatchling
    name: "Dragon Hatchling (Great Horned)"
    starting_money: 100
    # Restates the percentage of a skill the class ALREADY grants. It cannot
    # add or remove one — naming an ungranted skill is an error.
    skill_overrides:
      - { name: "Mathematics: Advanced", base: 45, per_level: 5 }
  - id: adult
    name: "Adult Dragon (Great Horned)"
    attribute_dice: { PS: "4d6+30" }
    mdc_base: "1d6x1000"
    bonuses:
      attributes: { PS: 4 }
      combat: { attacks: 3 }
```

A variant may override **only** the keys in `VARIANT_OVERRIDES`: `attribute_dice`,
`attribute_requirements`, the four pool bases (`hit_points_base`, `sdc_base`,
`mdc_base`, `ppe_base`), `starting_money`, `bonuses`, and `skill_overrides`.
Skills, abilities, lore and equipment stay shared on purpose: a variant that
could override anything is not a variant, it is a second class wearing the
first one's name, and the inheritance would obscure rather than explain.
Setting anything else warns and is ignored.

Note what the last two are *not*. `starting_money` is there because a stage of a
creature may be richer than another; `skill_overrides` restates the percentage
of a skill the class **already grants** and cannot add or remove one — a much
smaller power than overriding the skills block, which stays forbidden. See
[A variant may restate a skill's percentage](#house-rules-and-derived-values).

**`attribute_dice` and `attribute_requirements` merge per key; everything else
replaces.** Those two are flat maps of independent per-attribute values, so a
variant naming one attribute is saying something about that attribute and
nothing about the other seven — replacing them wholesale left an adult dragon
that overrode only P.S. rolling a plain 3d6 for I.Q. A scalar like `mdc_base`
has nothing to merge, and `bonuses` is nested deeply enough that merging would
raise "which half won" on every key: a variant's bonuses *are* its bonuses, and
a variant that states none inherits the class's.

The character records `class_variant` alongside `class_id`; NULL means the class
as written, which is right for every class with no variants. It is its own
column rather than encoded into `class_id`, because every reader of `class_id`
would otherwise have to know to split it, and the ones that forgot would
silently fail to resolve the class.

**Resolution happens in one place**, `loadClass(env, url, classId, variantId)`,
so no caller has to remember that a hatchling and an adult have different pools.
The sheet gets its class already resolved from `characters/:id` — `applyVariant`
lives in `parser.js`, a module, and `sheet.js` is a classic script that cannot
import one. Doing it server-side keeps a single implementation rather than a
second copy that drifts, and removed a whole `/classes` request from the sheet.

The wizard asks which stage after the class is chosen, and will not continue
until one is picked: a Dragon is always some particular age, and defaulting to
the first stage would be choosing for you.

### Changing stage

A hatchling grows up. The **Stage** box on the sheet proposes the change and
applies nothing until it is confirmed — the same two-step a level-up uses, and
for the same reason: the rolls are the point, and a roll you did not watch
happen is a roll you cannot trust.

- **Only what the new stage actually sets is offered.** An attribute whose dice
  the stage does not change is left alone entirely, rather than being re-rolled
  because something else about the creature changed.
- **Each attribute is kept or taken individually.** Ticking *keep* holds the
  number you already had, so a dragon can grow into its body without losing the
  mind it was played with.
- **Pools roll new maxima and current moves by the same amount**, exactly as a
  level-up treats them. Growing up neither heals the damage the character was
  carrying nor leaves it on a hatchling's current with an adult's maximum — a
  creature 40 M.D.C. down stays 40 down.
- **The new stage's rules are checked before it applies.** Its
  `attribute_requirements` may differ, and a character that would not meet them
  is refused rather than arriving there quietly.
- **It is recorded in `level_history`** with `from_level` equal to `to_level`:
  the character did not gain a level, it became something else.

Owner or GM, like every other stat-changing control on the sheet.

---

## Powers the player chooses

`special_abilities` was display-only: the Godling's *"Select THREE powers from
the following"* parsed clean and was never offered. A named ability may now carry
what it grants, and the class asks for the picks.

```yaml
special_abilities:
  - name: "Super-Tough"
    description: "Add 1D6 to P.E. and 3D4x10 to M.D.C."
    bonuses: { attributes: { PE: "1d6" }, pools: { mdc: "3d4x10" } }
  - name: "Shape Shifter"
    description: "Change at will into one animal."
    repeatable: true
    on_repeat: "Can shape shift into ANY type of normal animal."
  - { choose: 3, from: ["Super-Tough", "Shape Shifter", ...] }
```

**Three grant keys, not the variant override set:** `bonuses`, `psionics`,
`magic`. That is what the Godling's eleven powers actually need, and an ability
that could restate `attribute_dice` or `starting_money` is not an ability, it is
a second class wearing one's name. A fragment's `bonuses` block is validated
through exactly the same path a class's own bonuses take, so an ability cannot
express a bonus a class could not.

M.D.C. arrives as a pool **bonus** rather than an override, which is why pool
bonuses had to exist first: Super-Tough adds to whatever the class already rolls
rather than replacing the formula.

**Chosen on the class step, not a step of its own.** An ability can add to
attributes and pools, and both are rolled on the two steps after it — choosing
later would re-roll numbers the player had already read. The step will not
advance until every pick is made, the same rule unresolved gear choices follow
and for the same reason: the book intends the character to have them. Unspent
*skill* picks are still banked instead, because those are earned over time.

**Duplicates are meaningful.** Shape Shifter and Magic Powers can each be taken
twice, and the book gives the second take a different meaning rather than a
doubled one — *"can shape shift into ANY type of normal animal"*, not twice the
animals. So `abilities` is a JSON **array**, `repeatable` gates whether a second
pick is offered, and `on_repeat` is the prose that says what the second one
bought. The bonuses do apply again, which is the only honest arithmetic reading;
the powers the books mark repeatable happen to carry no bonuses at all.

**A pick nothing defines is still recorded**, marked as granting nothing. It was
a real choice the player made, and dropping it would leave the sheet disagreeing
with what they picked. An option no definition covers is a warning, not an error
— books routinely name a power they describe only in prose.

Psionics uses the **stronger tier wins** rule composition already uses, so an
ability cannot make a Master psychic weaker.

`applyAbilities` runs inside [`js/compose.js`](js/compose.js) as step 3 of 4 —
after race and occupation are one, because an ability is chosen for the
character rather than contributed by either half, and before any rolled psionic
tier, so an ability that makes you a master psychic is what a rolled tier has to
beat. What the character holds is on `abilities_taken`, as opposed to
`special_abilities`, which is what the class *offers*.

## A power list several classes share

Books reuse one list across a family of classes and say so outright. The
Demigod's entry reads *"select any ONE power from those listed under godling"*
(Rifts, Pantheons of the Megaverse p.17), and a God draws on the same eleven
again. Writing them out per class is the drift `variants` exists to avoid, so a
choice group may name the class that holds the list instead:

```yaml
special_abilities:
  - { choose: 1, from_class: godling }
```

The count comes from the **referring** class — the Godling picks three of its own
eleven, the Demigod one — and what is pulled is the referenced class's choice
**options**, not its whole `special_abilities` array. A class may also list fixed
abilities as prose, and those are its own.

**One hop, deliberately.** A referenced list may not itself be a reference. That
is what makes a cycle impossible rather than something to detect, and it is what
the books do: every class in a family points at the same printed list, never at
each other in a chain.

**An unresolvable reference is left exactly as written**, never emptied. The
class still loads and the entry still says what it meant. `crossReference`
reports it on the review step, beside the missing-reference lists, with the
reason — no class with that id, that class does not parse, or that class lists
no options to share.

**A retired class is a valid target and is not reported.** Retiring hides a class
from the pickers; it does not unwrite the list printed in it. `getStored`
already ignores `deleted_at`, and `loadPublished` looks retired classes up
separately so a reference resolves even when the class itself is excluded from
what it returns.

Resolution happens over the **whole set** in `loadPublished`, after the parse
cache rather than inside it: caching a resolved class would mean editing the
Godling's list left every class referencing it holding the old one, since only
the Godling's own cache entry is invalidated. `loadClass` resolves a single
class with one extra lookup, and only when it actually references something.

**Nothing chooses between the options yet.** The list is recorded, resolved and
shown; making a chosen ability mechanical — the fragments that would carry
`bonuses` and pool overrides — is separate work. Parsing a choice group says so
as a warning rather than letting the shape read as though it works.

## What a class grants mechanically

`natural_abilities`, `special_abilities` and `level_progression.grants` are the
book's own wording, and display-only. So a Dragon's *"+2 to P.S."* and *"+1
attack per melee at level 5"* were prose that nothing could act on — and no
amount of typing them by hand would change that, because there was nowhere for
a number to go.

`bonuses` is that place:

```yaml
bonuses:
  attributes: { PS: 2 }
  combat: { attacks: 1, strike: 2 }
  saves: { spell_magic: 2 }
  at_level:
    - { level: 5, combat: { attacks: 1 } }
```

**Three layers, in order:** the attribute tables, then what the class grants,
then whatever a human typed — which still wins, exactly as overrides always
have. A GM ruling beats a computed number.

**A flat attribute bonus is never stored on the character.** `attributes` keeps
the numbers that were actually rolled, and the class's `+2` is added on the way
past. That keeps every number's provenance visible, at the cost of one rule:
**nothing may read a raw attribute for a derived value** — it goes through
`derive.effective(attrs, bonuses)` instead. Miss that and a bonus becomes
decorative: P.S. 24 gives a damage bonus of 9, and the class's +2 has to reach
11 or it has done nothing.

The sheet shows one number and explains it on hover — *"+2 from attributes, +1
from Juicer"* — with a dotted underline marking the values a class contributed
to. `derive.parts()` produces that split.

A bonus stated as **dice** is the one exception, and it has to be: a roll cannot
be re-evaluated on every render without changing the number under the player.
Those are rolled once when the class is confirmed and stored as
`attribute_bonuses` — see [House rules and derived values](#house-rules-and-derived-values).
`derive.classBonuses(cls, level, rolled)` takes them as its third argument and
folds them in beside the flat ones, so everything downstream sees one bonus set
and does not care which kind it was.

**A pool bonus is added to a pool's own formula.** Books write pools three ways,
and only two had a shape. `mdc_base: "P.E. x 10"` states the pool outright, and
omitting a pool lets it fall through to the occupation — but the Demigod says
*"P.P.E.: As per the appropriate O.C.C., plus 4D6"*, which is fallthrough **and**
a modifier. Written as a formula it parsed to NULL and the character had no
P.P.E. at all; omitted, it lost the 4D6. Transcribing the page faithfully was
strictly worse than saying nothing.

```yaml
bonuses:
  pools: { ppe: "4d6", isp: "4d6" }   # and leave ppe_base absent
```

Four things follow from pools being rolled once rather than derived per render:

- **It is the only bonus group that takes dice as well as a number.** Combat and
  save bonuses are always printed flat; a pool bonus is usually a roll.
- **It is rolled with the base and folded into the stored `*_max`.** Nothing is
  re-evaluated later, because a dice bonus read at render time would move the
  character's maximum under them — the same reason `attribute_bonuses` is stored.
- **A bonus cannot conjure a pool the class does not have.** A null base stays
  null. That is the rule that keeps an M.D.C. race from acquiring hit points,
  applied to bonuses.
- **`at_level` does not take one**, and says so rather than ignoring it. Per-level
  growth belongs in the formula (`"P.E. x 5 plus 2D6 per level"`), which is where
  `perLevelDiceOf` already reads it from.

When two classes both grant one, the bonuses are **collected, not summed** — two
dice expressions have no arithmetic sum, so `["4d6", "2d6"]` means both are
rolled. Flat numbers still add. This is deliberately not the merge the other
bonus groups use: theirs drops any non-numeric value, which silently loses a
dice bonus coming from the **occupation** half of a composition.

`at_level` bonuses accumulate and apply the moment the level is reached, because
`classBonuses` is read at render time; nothing further is written to the
character. They appear in the level-up proposal so the change is announced
rather than simply happening.

Extraction fills this in from flat numeric statements, and is told explicitly to
leave **conditional** bonuses as prose — *"+2 to strike when flying"* would
otherwise be applied unconditionally.

### The review step

Attributes and pools sit side by side as two aligned columns; every list —
skills, equipment, spells, psionic powers — runs **down** in columns of fifteen
rather than wrapping across as one dot-separated paragraph. Spells and psionics
are separate sections, and a section with nothing in it is omitted rather than
shown empty.

A Chiang-Ku Hatchling arrives with 34 skills. As prose that was unreadable, and
it hid the thing that mattered: the same skill appearing twice.

**A choice-group never offers a skill the class already grants.** A category
group offers the whole category, which includes skills the class hands out
outright — the Chiang-Ku grants Advanced Math and Art as fixed skills and then
offers Science and Technical. Picking one listed the skill twice and the save
was refused for a duplicate, with no indication of which one. Already-held
skills are now dropped from the options rather than shown disabled: it is not a
choice you might make, it is one you already have.

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
[`db/backfill-gear-system.sql`](db/backfill-gear-system.sql), which infers from
the source book, only touches rows that are still NULL, and leaves anything it
cannot recognise alone rather than guessing.

---

## Filtering the catalog pickers

Every picker used to render its whole catalog: 74 gear rows in two places, 128
skills in a native `<select>`. Spells and psionics looked fine only because
those chapters have not been imported — they are pre-filtered by level and tier,
which hides the problem right up until a spell chapter lands.

All six now carry a filter box with a live count (`12 of 128`), backed by
[`js/picker.js`](js/picker.js):

| Surface | Control underneath |
|---|---|
| Wizard — add from item catalog | `<select>`, narrowed |
| Wizard — related / secondary skills | checkbox list |
| Wizard — spells, psionics | checkbox list |
| Sheet — add inventory | `<select>`, narrowed |
| Sheet — spend level-up skill picks | N `<select>`s over one shared pool |

The control varies because the task does — "add one item" and "pick 6 of these"
want different things. What is shared is the matching and the input.

- **Matching is name, category and source book**, all terms required, order
  irrelevant: `wilderness rifts` narrows, it does not widen. Fields the row does
  **not** display are deliberately not searched — a hit whose reason is
  invisible reads as a bug.
- **Enter takes a lone match.** Type until one row remains and press Enter; with
  several matches it does nothing rather than guessing.
- **An already-chosen row stays visible** even when the filter excludes it,
  or narrowing the list would look like it had un-picked something.
- **`picker.js` is a classic script**, like `js/derive.js`, because the wizard is
  a module and the sheet is a plain script and both need it.

`Picker.wire()` restores the caret after re-render. Both pages rebuild by
replacing `innerHTML`, so an input loses focus and drops the caret to the end
mid-keystroke; the catalog editor had already hand-rolled the fix, and this puts
it in one place.

**Level-up picks are now held in state, not read off the DOM at submit time.**
They were collected from the `<select>`s only when you pressed the button, so
any re-render in between discarded them — the "show all skills" checkbox already
did that. A filter that re-renders on every keystroke would have done it
constantly.

---

## Unfinished builds are saved

The wizard is eight steps and step 3 **rolls**. A refresh, a stray back-gesture
or a closed tab used to lose all of it — and a roll is the one thing you cannot
honestly redo: you either accept different numbers or re-roll until you like
them.

The build now autosaves to `character_drafts`, debounced ~1.5s off `render()`,
which already runs after every mutation. Returning to the wizard offers
**resume or discard** rather than dropping you into step 4 of a half-finished
character with no explanation.

Four things worth knowing:

- **Its own table, not a `draft` status on `characters`.** A half-built
  character has no name, no campaign and possibly no attributes. Putting one in
  `characters` would mean every list, the dashboard, the audit and the validator
  filtering out rows they must never treat as real — forever, to serve a state
  that lasts minutes. The wizard's state is not a character shape either: it
  carries which roll method was used per attribute, which choice-group options
  are ticked, and how far through the steps you are.
- **An allowlist, not a copy of the state.** `DRAFT_KEYS` in `app.js` names the
  build itself. The wizard's state also holds the class, skill, spell and gear
  catalogs, which are large, shared, and stale the moment they are written down.
  A real draft is ~1.5 KB.
- **The class is stored as an id and re-resolved on restore**, so an edited
  class definition takes effect instead of being shadowed by the draft. A draft
  naming a class that no longer resolves is discarded rather than half-applied.
  Gear choice *options* are re-derived for the same reason — only which options
  you **ticked** is persisted.
- **The unload warning waits for the rolls.** Before that, "losing" the draft
  costs two clicks; a browser dialog on every exit would be noise. It also stops
  once the character is saved.

One draft per person, enforced by `UNIQUE (owner_email)` — saving is an upsert.
Discarding is idempotent, and a draft that cannot be parsed is reported as
absent rather than partially restored.

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

**Where a tier comes from:** either the class (`psionics.type`) or the character
(`psychic_tier`, rolled on the Random Psionics Table — see
[Psionics can be rolled for](#house-rules-and-derived-values)). `composeClass()`
folds a rolled tier into the class-shaped object, so everything below applies
the same either way.

Starting power counts are minor 2 / major 6 / master 8 when a class states the
tier, and a class may override with `psionics.powers_starting`. A *rolled* tier
uses the book's own counts instead: 2 for a minor, and 8-from-one-category or
6-from-any for a major. Super psionics are Master-only through
`psionics.categories_allowed`, which is a **category** gate.

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
- A class with no `psionics` block has no tier of its own — but its character
  may still have rolled one, and then the gate applies normally. A class that
  sets `psionics_allowed: false` has no tier and never will.

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

It is the **Audit characters** button on the catalog page, above the catalog
tabs rather than in the per-catalog toolbar — it reports characters against the
classes they were built from, so nothing about it changes when you switch tabs.
This is the feedback loop for the class corrections in
[Data scripts](#data-scripts): every `fix-*.sql` that rewrites a class against
the book can retroactively put an existing character out of step with it, and
this is the only thing that says which. It splits **would be refused on save**
from **worth a look**, because only violations block — a character carrying
warnings alone is legal, and listing the two together would send you to fix
something that is already correct.

The endpoint existed with no caller for some time, which is why a smoke check
now asserts a page script calls it. Routed and documented is not the same as
reachable, and an endpoint nobody can run is exercised by nothing.

A character whose class cannot be resolved — retired, deleted, or no longer
parsing — **skips validation and saves normally**. Refusing would strand a
character whose class an admin retired, which is exactly what class soft-delete
was built to avoid. The audit lists those separately as unvalidatable.

**A rejected save says which rule broke.** The endpoints return a `violations`
array where every entry carries a readable `message`, and both pages now print
them — the wizard as a list under the failure, the sheet inline. They used to be
thrown away, so a failed save read *"This character breaks its class rules"* and
nothing else: true, and useless for working out what to change.

```
Save failed: This character breaks its class rules
  • ME is 3, below the class minimum of 12
  • MA is 3, below the class minimum of 12
  • 7 related skills, but this class allows 6 at level 1
```

A smoke check asserts every violation the validator can emit carries a message,
so a new rule cannot ship as an unexplained refusal.

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

They all live on `import.html`, admin only, behind five tabs: **Classes**,
**Skills**, **Spells**, **Psionics** and **Gear**. The last three are built from
`SESSION_CATALOGS` in `import.js`, so adding a sixth is a config entry rather
than a new tab.

The **catalog** importers — skills, spells, psionics and gear — share
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

#### Writing a class by hand

Not every class is best got out of a PDF. An RCC with several age stages is
quicker to write than to extract and correct, and until recently there was no
way into the markdown editor without running an extraction first.

**+ Write one by hand** in the saved-imports panel asks for a name, whether it
is an O.C.C. or an R.C.C., a system and a source book, then opens the editor on
an annotated skeleton. The **Re-check** button re-parses and re-runs the catalog
cross-reference for free, so you can iterate against the validator without
spending an API call; **Confirm** publishes exactly as it does for an extraction.

Two things make the template worth having over an empty file:

- **It parses on arrival**, with no errors and no warnings. A template that
  failed validation the moment it was created would teach you nothing about
  which of your own edits broke it — which is why all five fields the parser
  requires are asked for up front rather than left blank.
- **The awkward blocks are shown commented**: `variants`, `bonuses`, skill
  choice-groups and gear choices. Those are the shapes nobody remembers, and
  they are the reason writing a class by hand is worth supporting at all.

#### Structured editors for the two awkward blocks

`bonuses` and `variants` get real UI above the markdown; nothing else does. They
are the shapes nobody remembers, and everything else in the frontmatter is
either obvious or prose.

The markdown stays visible and stays the source of truth. Editing a block
rewrites **only that block**, in place, so you can watch exactly what changed:

- **Bonuses are a flat table** of *(level, group, key, value)*. A bonuses block
  really is a list of those tuples — `at_level` is the same thing with a level
  attached — so one small table covers both, instead of a nested editor per
  group and another inside every `at_level` entry. Leave the level blank for a
  bonus the class has from the start.
- **Variants show id and name.** Their overrides (`attribute_dice`, the pool
  bases, per-variant `bonuses`) are edited in the markdown, and **survive a
  save**, because each block is rebuilt from its *parsed* value rather than from
  what the form displays.
- **A commented-out example is replaced, not duplicated.** The template ships
  `# variants:` as a worked example; appending a real block beside it would make
  the file appear to define the same key twice.

Comments *inside* an edited block do not survive — it is rebuilt from structure.
That is the right way round: the blocks worth a form are structure, and the
blocks worth comments are the ones this never touches. Regenerating the whole
frontmatter instead would have been simpler and would have destroyed every
comment in the file, which is most of what makes a hand-written class
approachable.

`import/recheck` returns the parsed frontmatter as `data`, so the editors can
read `bonuses` and `variants` without a YAML parser of their own — `import.js`
is a classic script and `parser.js` is a module it cannot import.

There are two templates rather than one, because an R.C.C. and an O.C.C. are
genuinely different shapes — a race rolls its attributes from racial dice and
usually has M.D.C., a character class has attribute *minimums* and hit points.
One template covering both would be half wrong whichever you were writing.

It is saved as a draft immediately, like an extraction, so a closed tab cannot
lose it. `PUT import/stored` is deliberately more permissive than confirm: a
draft only has to **parse**, not validate, because half-written is a draft's
normal state and refusing to save one until it is correct would lose exactly the
work most worth keeping. It will not overwrite a **published** class — that is
what Confirm is for, and Confirm runs the cross-reference and full validation
this skips.

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

Four behaviours worth knowing:

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
  power's category.** The column *is* enforced: the picker filters through
  `derive.meetsTier()` and will not offer a power above the character's tier —
  see [Psychic tiers](#psychic-tiers).
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

The app is served at <http://localhost:8788/apps/character-creator/> — the path
mirrors the repo layout, because `pages_build_output_dir` is the repo root and
nothing rewrites it. `/character-creator/` is *not* the URL; it silently returns
the workshop landing page, since Pages falls back to the root `index.html` for
paths it cannot match.

A database created before the `db/migrations/` files existed also needs those,
once each — see [Production configuration](#production-configuration).

**`seed-catalogs.sql` seeds the three classes as they were originally written,
not as the rules audit corrected them.** The corrections live in
`apps/character-creator/db/fix-*.sql` and `apply-*.sql` and have to be applied on
top, or you are developing against class definitions the audit found wrong — see
[Data scripts](#data-scripts). Each guards on the text it replaces, so applying
them to an already-corrected database does nothing.

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
| `010-catalog-redirects.sql` | `catalog_redirects` — where a retired key forwards to |
| `011-character-drafts.sql` | `character_drafts` — one unfinished wizard build per person |
| `012-catalog-system.sql` | `system` on `spells` and `psionic_powers`; `system` on `import_sessions` |
| `013-character-variant.sql` | `class_variant` on `characters` |
| `014-character-occ.sql` | `occ_class_id` + `occ_class_variant` on `characters` |
| `015-character-psychic-tier.sql` | `psychic_tier` + `psychic_shape` on `characters` — a tier the character **rolled** |
| `016-character-attribute-bonuses.sql` | `attribute_bonuses` on `characters` — what a class's **dice** bonuses came up |
| `017-pick-kind.sql` | `kind` on `pending_skill_picks`, so a scheduled grant records whether it was related or secondary |
| `018-character-abilities.sql` | `abilities` on `characters` — the powers a player chose from a class's choice group |
| `019-character-rolled-bonuses.sql` | `rolled_bonuses` on `characters` — what a class's **dice** combat and save bonuses came up |

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

### Data scripts

`apps/character-creator/db/*.sql` are a different thing from `db/migrations/`
and are easy to mistake for them. A migration changes **schema** and is tracked
in `schema_migrations`; these change **rows**, are tracked nowhere, and are run
by hand once per environment as needed.

| Kind | Files | What they are |
|---|---|---|
| Dev seed | `seed-dev.sql` | Optional local character/campaign rows. Never applied to production |
| Data cleanup | `backfill-gear-system.sql`, `backfill-skill-provenance.sql`, `retire-gear-placeholders.sql`, `untag-cross-system.sql` | One-off corrections to rows an earlier import or data script got wrong or left NULL |
| Class corrections | `fix-*.sql`, `apply-*.sql`, `long-bowman-money.sql` | The rules audit's output: stored class definitions rewritten against the books, and class data written for a schema feature the day it landed |
| Catalog additions | `add-*.sql` | A row the book grants that the catalog never had. Usually found because a class cites it — a missing skill named in an `only` restriction narrows its category to nothing |

Two conventions hold across all of them, and both matter more here than in a
migration, because nothing records that one has run:

- **Every statement guards itself**, so a script is safe to run twice and safe
  to run *early*. `retire-gear-placeholders.sql` is the clearest case — it does
  nothing at all until the options it rewrites toward exist, and its closing
  `SELECT` reports what it did and what it is still waiting for. See
  [Starting gear the class leaves open](#starting-gear-the-class-leaves-open).
- **Each one opens with the book and page it is correcting against**, because a
  script that rewrites a class is a claim about a source, and six months later
  the citation is the only way to check it.

The audit that produced most of them is [`docs/rules-audit.md`](docs/rules-audit.md).

Merging to `main` is the deploy — Pages auto-deploys, no CI, no build command.
Cloudflare Access fronts the whole site with the path left blank, so every route
including `/api/*` is covered; there is no Access policy-as-code in the repo.

Verify anything applied to production by querying it back, not by trusting an
exit code — `wrangler d1 execute` has been observed reporting a non-zero exit on
a fully successful run. Twice now, in different disguises:

- a plain non-zero exit on a run that fully applied
- `Authentication error [code: 10000]` from `--remote --file`. `--file` does not
  run your SQL over the query API: it uploads the file, triggers D1's separate
  **import** endpoint, then polls it. That endpoint is the unreliable part —
  the same command, same token, minutes apart, has both **succeeded while
  printing this error** (011, which had fully landed) and **genuinely failed**
  (012, which had not applied at all). The message is auth-shaped either way and
  sends you off checking credentials that are working fine.

  **Prefer `--command` for remote migrations.** It goes over the query API,
  takes multiple statements separated by `;`, and has not failed. Use `--file`
  locally, where none of this applies.

The check that settles it, every time:

```sh
npx wrangler d1 execute DB --remote --command \
  "SELECT name FROM sqlite_master WHERE name='<your_table>';
   SELECT filename FROM schema_migrations ORDER BY filename;"
```

`sqlite_master` and `schema_migrations` are authoritative. `pragma_table_info`
is not — over `--remote` it has returned stale replica data mid-migration.
Migrations are safe to re-run regardless (`IF NOT EXISTS` plus
`INSERT OR IGNORE`), so the cost of checking first is nothing.

---

## Known limitations and refactor candidates

Honest list, roughly by value.

The original twelve PRs are recorded under
[`docs/plans/`](docs/plans/README.md) with their design decisions and rejected
alternatives. Everything since — the rules audit against the source books, the
class-data corrections and the schema work that came out of them — is in
[`docs/rules-audit.md`](docs/rules-audit.md).

The one refactor candidate that had earned itself is done: six places composed a
class by hand and now none do. See
[One place composes a class](#one-place-composes-a-class).

**An R.C.C. with no related or secondary skills is correct, not a gap.** Those
come from the O.C.C. a character takes alongside its race, so `relatedAllowance`
returning 0 for the Chiang-Ku Dragon is the right answer rather than a missed
extraction. Listed here only so it is not "fixed" — see
[A race and an occupation together](#a-race-and-an-occupation-together) for how
the O.C.C. half is now carried.

**Nothing restricts which O.C.C. a race may take.** The picker offers every
occupation in the system, and the books do not: plenty of races are barred from
particular classes, and some classes are open only to one race. A character the
books forbid saves cleanly here. Left unenforced deliberately for now — the
restrictions live in prose rather than in any field the importer extracts, so
enforcing them means first deciding where that data lives. Worth revisiting once
there are enough O.C.C.s for the rule to bite; with one Palladium O.C.C. in the
catalog there is currently very little to restrict.

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

**The three page scripts are long, and deliberately not split.** `app.js` is
roughly 1,600 lines, `import.js` and `sheet.js` roughly 900 each — treat those
as orders of magnitude, not figures, since they move with every change and the
last written-down set had drifted by 20%. Each drives one page and each does
several jobs. Splitting was considered and rejected: there is no build step,
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
