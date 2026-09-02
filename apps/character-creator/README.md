# Character Creator — Palladium Fantasy & Rifts

A persistent, multi-campaign character creator and journal. Build a character
through a guided wizard, keep a running session log, level up semi-automatically,
print a sheet laid out after the official form, and import classes, skills,
spells, psionic powers and gear straight out of a sourcebook PDF.

Part of Nate's Workshop. Cloudflare Pages + D1, behind the site-wide Cloudflare
Access gate. No build step, no framework, no dependencies.

---

## Contents

The reference a reader needs first is here. Everything else is one file per subject,
under [`docs/`](docs/).

| file | what it answers |
|---|---|
| [`docs/house-rules.md`](docs/house-rules.md) | Where a number the books do not settle comes from, and the class key that overrides it. |
| [`docs/leveling.md`](docs/leveling.md) | What a class gains as it levels: fighting-style schedules, skill picks, staged classes, chosen powers, and the psychic tiers that gate them. |
| [`docs/starting-above-level-1.md`](docs/starting-above-level-1.md) | Building a character that begins at level 5 by replaying the level-up engine. |
| [`docs/spell-and-psionic-imports.md`](docs/spell-and-psionic-imports.md) | The catalog gaps per-level spell and psionic grants uncovered, and what closing them cost. |
| [`docs/race-and-occupation.md`](docs/race-and-occupation.md) | The R.C.C.-first wizard, how a race and an occupation compose, and the MOS packages that sit on top of an O.C.C. |
| [`docs/language-and-enchantments.md`](docs/language-and-enchantments.md) | Two rule families the catalog models as data rather than as code. |
| [`docs/wizard-and-sheet.md`](docs/wizard-and-sheet.md) | How the ten-step wizard and the character sheet behave: tabs, pickers, drafts, blocked steps, and what the server refuses to take on trust. |
| [`docs/campaign-and-play.md`](docs/campaign-and-play.md) | Everything that happens at the table rather than during creation. |
| [`docs/catalog.md`](docs/catalog.md) | How catalog rows are shaped, filtered, matched and merged. |
| [`docs/importing-from-pdfs.md`](docs/importing-from-pdfs.md) | How a book becomes catalog rows now: cache, survey, extract or transcribe, check, data script. The in-app importer it used to describe was retired unused. |
| [`docs/operations.md`](docs/operations.md) | Bindings, the one-database decision, migrations, data scripts, and how to check that the live database still matches the repo. |
| [`docs/known-limitations.md`](docs/known-limitations.md) | The honest list, roughly by value. |
| [`docs/rules-audit.md`](docs/rules-audit.md) | Where each implemented rule comes from, by printed page. |
| [`docs/surveys/`](docs/surveys/) | One file per cached sourcebook: its offset, inventory, authority pages, catalog diff and per-PR ledger. Facts about each book; no prose from it. |
| [`docs/plans/`](docs/plans/README.md) | Design decisions and rejected alternatives, per planned PR. |

In this file:

- [Where everything lives](#where-everything-lives)
- [Data model](#data-model)
- [Class definition format](#class-definition-format)
- [API surface](#api-surface)
- [Permissions](#permissions)
- [One place composes a class](#one-place-composes-a-class)
- [Hit points and S.D.C. come from the core rules](#hit-points-and-sdc-come-from-the-core-rules)
- [The scripts at the repo root](#the-scripts-at-the-repo-root)
- [A row can say where it came from](#a-row-can-say-where-it-came-from)
- [Local development](#local-development)

---

## Where everything lives

Everything the app reads at runtime is in D1. There are no static content files
— adding a class, a skill, a spell, or an item needs no commit and no redeploy.

```
apps/character-creator/
├── index.html / app.js       Creation wizard (10 steps). app.js is an ES module.
├── sheet.html / sheet.js     Character sheet, laid out after the printed Rifts sheet
├── dashboard.html / dashboard.js  GM dashboard: roster, GM notes, campaign journal
├── campaign.html / campaign.js  Campaign notes: the log with search and Ask,
│                             the party stash and the currency ledger
├── catalog.html / catalog.js Admin-only catalog editor, generated from the
│                             field config. catalog.js is an ES module.
├── styles.css                All six pages, layered on /shared/styles.css
├── js/parser.js              RCC/OCC markdown parser (ES module — also used by the API)
├── js/dice.js                Dice evaluator (ES module — also used by the API)
├── js/leveling.js            XP curve and the level-up diff (ES module — the API
│                             re-exports it; the wizard builds characters that
│                             start above level 1 from the same engine)
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
├── js/api.js                 The one HTTP helper for all six pages, and
│                             errorDetails() (classic script)
│   (also loaded by every page: /shared/js/ui.js, for escHtml — see below)
├── js/picker.js              Catalog picker filtering — matching, the filter
│                             input, and caret restore (classic script, same
│                             reason as derive.js)
├── js/class-template.js      Annotated OCC/RCC skeletons for writing a class by
│                             hand. Printed by scripts/new-class.mjs; a classic
│                             script because the page that used to load it was
│                             one
├── js/language-skills.js  The "once per language" rule for BOTH families (ES
│                             module — the server validator imports it, and the
│                             sheet reads its globalThis mirror via a module tag)
├── db/*.sql                  One-shot SQL. NOT migrations — these change rows,
│                             not schema. See Data scripts below
├── docs/rules-audit.md       Where each implemented rule comes from, by page
├── docs/surveys/<slug>.md    One per cached book — the survey the book-survey
│                             skill writes and a fresh session boots from.
│                             Tracked on purpose; the OCR caches are not
├── docs/plans/               The planned PRs and shipped proposals, with
│                             their rejected alternatives
└── test/
    ├── smoke.mjs             The runner, and the rules half of the checks
    ├── harness.mjs           check(), section(), the counters and the summary
    ├── checks/
    │   ├── environment.mjs   D1 schema, schema.sql self-sufficiency, data-script
    │   │                     conventions, documentation claims, migration state
    │   └── catalog-data.mjs  Core pools, the Hand to Hand and W.P. level
    │                         schedules, spell text, gear shape, provenance
    ├── regression.mjs        End-to-end: builds a throwaway D1, boots the
    │                         worker, drives the real endpoints over HTTP
    └── fixtures/*.md         Three real class files, parser test input only

functions/api/
├── _lib/access.js            Cloudflare Access identity + admin check (site-wide)
├── _lib/claude-client.js     The only place that calls the Anthropic API
├── claude.js                 HTTP proxy over claude-client, for browser callers
└── character-creator/
    ├── _lib/auth.js          Owner/GM/admin authorization, readJson
    ├── _lib/character-json.js  Decoding the character JSON columns, with the
    │                         right empty value per column
    ├── _lib/catalog.js       Cross-reference a class draft; create catalog stubs
    ├── _lib/catalog-redirects.js  Retired catalog keys keep resolving to their
    │                         replacement, so an old class file still loads
    ├── _lib/class-loader.js  Resolve a class_id to parsed frontmatter
    ├── _lib/class-store.js   Read stored classes; per-isolate parse cache. The
    │                         write half went with the in-app importer
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

Six modules are imported by both the browser and the Workers runtime:
`js/parser.js`, `js/dice.js`, `js/catalog-fields.js`, `js/compose.js`, and
`js/psionics.js` (transitively, through compose), and `js/language-skills.js`. That is why `app.js` and
`catalog.js` are loaded as `<script type="module">` while the other pages are
classic scripts — and why inline handlers in the wizard need explicit `window`
exposure (see the `Object.assign(window, …)` block at the bottom of `app.js`).
`catalog.js` avoids the problem entirely by binding with `addEventListener`.

`js/derive.js`, `js/picker.js` and `js/api.js` are deliberately *classic*
scripts rather than modules, so the plain-script pages can use them without
converting the whole file. `js/api.js` is loaded by all six pages and defines
`api()` and `errorDetails()`; there used to be five copies of `api()` in three
variants, which is a nuisance while they agree and a bug when they do not — the
wizard and the sheet learned to carry a failed response's `violations` through
to the reader while the catalog editor and importer kept throwing that half
away, so the same 422 explained itself on one page and said
*"Request failed (422)"* on another.

`jsonReq` is deliberately **not** shared: the sheet's takes `(method, body)` and
the importer's takes `(body)` and always posts.

**Every page also loads `/shared/js/ui.js` first**, and this app uses exactly one
thing from it: `escHtml`, which is the escaper behind almost every template
literal here. It is a workshop-wide file rather than this app's, so changing it
touches MediaVault and FilamentForge too — they use its `openModal` /
`closeModal` / `copyWithFeedback`, which this app does not.

---

## Data model

Thirty-three tables in one shared D1 database (`nates-workshop-media`, bound as `DB`),
and one R2 bucket (`MEDIA`, same name) for the only binary this app stores.
`media_items` belongs to MediaVault, and the six tables prefixed `ff_` belong
to FilamentForge — that prefix is the collision boundary, because this app's
tables are unprefixed, so anything another app adds must not be. `claude_usage`
is the site's Claude-spend log (written fail-open by the `/api/claude` proxy
and the campaign Ask — see SETUP.md for the query), and `schema_migrations` is
database bookkeeping shared by all; the rest are this app.

**Character data**

| Table | Notes |
|---|---|
| `campaigns` | Top-level container. `gm_email` owns it. `gm_notes` is GM-only and stripped from non-GM API responses. `open` (default 1) is the join gate: 0 means only the GM and existing members may create a character in it — see [Membership is not a table](docs/campaign-and-play.md#membership-is-not-a-table). |
| `characters` | See below — several JSON columns. `class_variant` names which `variants` entry the character is; NULL means the class as written. `occ_class_id` is the O.C.C. taken alongside an R.C.C.; NULL means none. |
| `enchantments` | What an alchemist can put into a weapon or a suit of armour, one row per property the book names. `cost` is the low end and `cost_note` the formula — *"2,000 gold per 20 S.D.C., 200 max on heavy armour"* is an arithmetic rule, not a number. `bonuses` is the **same JSON block** `skills.bonuses` uses, validated through the same `validateBonuses`, so `derive.js` needs no new cases. `limits` is what a picker has to act on: the Thunder Hammer is blunt weapons only. |
| `character_items` | Inventory join. `item_id` NULL means a freeform item (`custom_name` required). `removed_at` NULL means currently held — removals are soft, so history survives. `enchantments` is a JSON array of `enchantments.slug`, on the **instance** rather than the catalog row. |
| `journal_entries` | `character_id` NULL means a campaign-level entry. |
| `level_history` | One row per confirmed level-up; `changes` is a JSON diff of what was actually applied. |
| `pending_skill_picks` | Skill picks a level-up granted and nobody has spent yet. One row per **grant**, not per pick, so "2 picks from level 3" stays itemised. `categories` is copied from the class at level-up time — the class can change later, what you were granted cannot. |
| `pending_power_picks` | The same for spells and psionic powers. `spell_levels` is the cap the granting level carried, copied for the same reason — a Ley Line Walker's level-4 pair stays capped at spell level 4 however the class is later re-imported. |
| `character_grants` | What a table handed a character outside its class schedule — skills, and seven more kinds the `CHECK` names but nothing implements yet. The granted SKILL itself lives in `characters.skills` as a `type: 'gm'` entry, because level-up advances that array and a composed row would never improve; this table is its provenance. `reason` is required: the player enters their own grants, so the record is what carries the weight rather than a permission wall. Removal is a hard `DELETE`, logged to `play_events`. |
| `campaign_items` | The party stash: `character_items`' shape, owned by a campaign. `removed_at` NULL means still held; `claimed_by_character_id` says it left for a sheet rather than being spent or lost. |
| `campaign_currency` | Party money as an append-only **ledger**. The balance is `SUM(delta)`, so no stored total can disagree with its own history. `currency` is free text — the two systems use different coin. |
| `journal_fts` | FTS5 index over `journal_entries`. External-content: it holds no copy of the text, and three triggers keep it current. |
| `npcs` | One dossier per person per campaign — `UNIQUE (campaign_id, name COLLATE NOCASE)` is what makes `@Kevik` resolve to a person rather than three rows. `portrait_key` is an R2 object key. |
| `npc_mentions` | Which entries mention whom. `source` is `'mention'` (a person typed `@`) or `'ai'` (the sweep inferred it) — a decision made by software should be visible as one. |
| `npc_sweeps` | Which entries the sweep has already read. Written only after a successful call, so a failed one is retried rather than skipped. |
| `npc_proposals_dismissed` | Names a human has said are not people. Without it the sweep proposes `the guard` again every time and the button becomes noise. |

`characters` stores ten JSON columns rather than a very wide table — the list
lives in `_lib/character-json.js` as `CHARACTER_JSON_COLUMNS`:

| Column | Shape |
|---|---|
| `attributes` | `{ "IQ": 12, "ME": 14, … }` |
| `attribute_bonuses` | `{ "PS": 3 }` — what a class's **dice** attribute bonuses rolled, kept because a roll cannot be re-run per render |
| `rolled_bonuses` | `{ "combat": { "initiative": 3 } }` — the same, for a class's **dice** combat and save bonuses |
| `skills` | `[{ name, category, pct, per_level, type: "occ"\|"related"\|"secondary" }]` — plus `iq_bonus`, and `gained_at_level` / `override` on level-up picks |
| `powers` | `[{ type: "spell"\|"psionic", name, level?, category?, cost, cost_note? }]` — `cost_note` carries a variable-cost schedule; `cost` is the minimum the use button deducts |
| `abilities` | `["Super-Tough", "Shape Shifter", "Shape Shifter"]` — powers chosen from a class's list. A list, not a set: **duplicates are meaningful**. A G.M.-assigned power is an object entry, `{ name, gm: true }` |
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
| `gear` | Gear catalog. `slug` is what `equipment_starting[].item_id` references. Carries a stat block — damage, is_mega_damage, range, payload, rate_of_fire, ar, **sdc**, mdc — null wherever it does not apply, so one table covers weapons, armour and general kit. `sdc` is what the object TAKES before it breaks; `damage` is what it deals, and "1D6 S.D.C." on a knife is the second. `source_book` may say [not book-verified](#a-row-can-say-where-it-came-from). Named `gear`, not `items`, to stay clear of MediaVault's `media_items`. |
| `skills` | `base` 0 means non-percentile (W.P.s, hand to hand). `base_formula` overrides it with an attribute-derived percentage such as `PP*5`, for a book that states one that way; `base` stays the fallback. `systems` is a JSON array; NULL means both. `note` carries oddities like `40%/30% climb/rappel`. `bonuses` applies always; `level_bonuses` is a per-level schedule — see [A fighting style is a level schedule](docs/leveling.md#a-fighting-style-is-a-level-schedule). |
| `spells` | `system` NULL means unrestricted. name, level, ppe, plus a stat block (range, duration, damage, saving throw, area of effect, casting time, description). The stat block is TEXT — books write "100 feet per level" as often as a number. |
| `psionic_powers` | name, category (Healing/Physical/Sensitive/Super), isp, plus range, duration, saving throw and description — the same field names spells use. `min_tier` is the psychic tier a book states is required; NULL means no restriction beyond the category. `variant_note` carries what an older book states instead — the later book is authoritative (RUE over the Book of Magic, either over Palladium Fantasy) and the losing number is kept rather than discarded. |

Every catalog carries `source_book`, so an entry's provenance is visible and
the same skill from two books can coexist under distinguished names. The
session importers compose it **per row** — the session's book label resolved
through `scripts/books.json`, plus that row's own page range normalised to
`p.N-M` — because one session covers many ranges, and a book with no pages on
it is a row neither `class-check --field-sources` nor
`scripts/source-coverage.mjs` can trace back to a printed page.

`skills`, `spells` and `psionic_powers` also carry `source` (`seed` \| `import`),
and a stub the class importer created is spotted by that plus zeroed numbers.
**`gear` has no `source` column.** It never did, so its stub marker is the
description instead: rows created by a class import open with `STUB —` (today
that means a data script, and `class-check` generates the SQL), and a
row edited by hand loses the prefix and correctly stops counting as one. The four `isStub` rules lived together in
`_lib/import-engine.js`, which went with the in-app importer; the marker is
what survives it, and `scripts/source-coverage.mjs` is what still counts them.

Data scripts that create such a row must build that em-dash with
`'STUB ' || char(8212) || ' ...'` rather than embedding it, or the marker
arrives as mojibake and the row is a stub nothing can find.

**Working state** — not content, and not a character

| Table | Notes |
|---|---|
| `character_drafts` | One unfinished wizard build per person, `UNIQUE (owner_email)`. `state` is the build as JSON — deliberately not the catalogs it was built against. Its own table rather than a `draft` status on `characters`; see [Unfinished builds are saved](docs/wizard-and-sheet.md#unfinished-builds-are-saved). |
| `catalog_redirects` | Where a retired key went. Written when a merge deletes a row or a key is renamed by hand, so class markdown citing the old slug or name keeps resolving. Polymorphic by design — `catalog` names which table `to_id` points into — so there is no foreign key. See [Retired keys keep resolving](docs/catalog.md#retired-keys-keep-resolving). |
| `play_events` | Play mode's action log, append-only. `payload` is JSON — a note, and `{from, to}` changes for undo. `undone_at` NULL means the event stands; undo marks, never deletes. Commentary, not a ledger: the character row stays the source of truth and nothing replays events |
| `data_script_runs` | Which `apps/character-creator/db/*.sql` data scripts have run here, and when. One row per **run**, not per file — those scripts guard every statement, so one is safe to re-run and safe to run early, and an applied-once flag would record a deliberate no-op as done. `note` non-NULL means the run was asserted rather than observed. See [Data scripts](docs/operations.md#data-scripts). |

---

## Class definition format

A class is a markdown file: YAML frontmatter for structured data, body prose for
display. Stored in `imported_classes.markdown`, parsed by `js/parser.js`.

```yaml
---
id: cyber-knight              # kebab-case slug, required
name: Cyber-Knight            # required
system: rifts                 # rifts | palladium-fantasy, required
source_book: Rifts Ultimate Edition p.61-66   # required; the book as printed
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
    # `bonus` is the percentage the page prints beside the category and may
    # accompany either of them.
    categories:
      - "Physical"
      - { name: "Espionage", only: ["Escape Artist"] }
      - { name: "Science", except: ["Anthropology"] }
      - { name: "Technical", bonus: 10 }
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }]
    # A FLOOR per category, spent out of `count` above rather than on top of it.
    # An entry names one category or a list satisfied by any of them.
    minimums:
      - { count: 2, category: "Espionage" }
  secondary_skills:
    count: 2
    schedule: [{ level: 4, count: 1 }]   # secondary grants schedule too
starting_money: "2d6x10"      # a formula or a flat number; coin only
equipment_starting:
  - { item_id: "ns-turbo-cyclone", qty: 1 }          # qty may be a roll: "1d6"
  - { choose: 1, label: "energy pistol", qty: 1, from: ["ng-33-northern-gun-laser-pistol", "wilk-s-320-laser-pistol"] }
psionics:
  type: "major"               # minor | major | master
  isp_base: "1d4x10+20"
  powers: ["Sixth Sense"]     # powers the class automatically knows
  powers_starting: 3          # how many the player picks, IN TOTAL
  powers_from: ["Mind Block", "See Aura", ...]   # the exact list to pick FROM
  # A book may SPLIT the starting pick across restrictions rather than give one
  # open count - the Delphi Juicer's "3 Physical + 1 Super". The counts must sum
  # to powers_starting, which stays the total. A group naming no categories (or
  # no `from`) inherits the block's; one that names its own REPLACES them, the
  # same rule a level-up grant follows.
  powers_starting_groups:
    - { count: 3, categories: ["Physical"] }
    - { count: 1, categories: ["Super"] }
# psionics_allowed: false     # a race with NO psychic potential (troll, orc);
                              # skips the Random Psionics Table entirely
magic:
  type: "innate"
  spells_starting: 6
  spell_levels_allowed: [1, 2]
  spells_from: ["Air: Stop Wind", ...]  # the exact list the starting pick draws
                                        # from; REPLACES spell_levels_allowed,
                                        # exactly as powers_from replaces the
                                        # category gate
  spells_starting_groups:               # the same split, for spells
    - { count: 1, from: ["Air: Stop Wind", ...] }
  spells: ["Globe of Daylight"]   # only if the book names specific spells
special_abilities:
  - { name: "Psi-Sword", description: "..." }
  # An ability the player CHOOSES may carry what it grants, and may be
  # repeatable with a different second-take meaning. See the section below.
  - name: "Super-Tough"
    description: "Add 1D6 to P.E. and 3D4x10 to M.D.C."
    bonuses: { attributes: { PE: "1d6" }, pools: { mdc: "3d4x10" } }
  - { choose: 3, from: ["Psi-Sword", "Super-Tough"] }
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
that many extra skill picks. See [Level-up skill picks](docs/leveling.md#level-up-skill-picks).

`supersedes_race: true` on an O.C.C. **is** enforced: composition is
race-primary by default, and this inverts it for a class whose book says the
character stops being what it was. Pools, `starting_money` and `xp_table` become
the occupation's, its `occ_skills` replace the race's rather than unioning, and
`attribute_dice` are compared per attribute and the higher kept. The
Cosmo-Knight is the only class that carries it. See
[Race and occupation](docs/race-and-occupation.md).

`occ_related_skills.minimums` **is** enforced. It is the only floor in the block
- `count`, `categories`, `only` and `except` are all ceilings - and it exists
because eight classes across four books print a rule like *"select 8 other
skills, but at least two must be selected from espionage and two from rogue
skills"*. The wizard shows a running total per floor; the server refuses a
character that can NO LONGER reach one, rather than one that has not reached it
yet, so a half-built character still saves.

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
| `classes` | GET | Published classes, parsed. `?system=` `?category=` `?include_retired=1`; `?names=1` is the id→name label projection (unfiltered, retired included). Sends an `ETag`, so a warm boot revalidates to an empty 304 instead of re-downloading ~750KB of markdown |
| `catalogs` | GET | Skills, spells, psionic powers in one call — trimmed projection the wizard boots on |
| `catalogs/rows` | GET / POST / PATCH | Admin. Whole rows for one catalog (`?catalog=`), create, and update (`&id=`). No delete |
| `catalogs/duplicates` | GET / POST | Admin. Suggested duplicate pairs for a catalog; POST merges two rows. `?counts_only=1` returns just the per-tier counts, for the badge |
| `catalogs/redirects` | GET / DELETE | Admin. Retired keys and where they resolve (`?catalog=`); DELETE stops forwarding one (`&id=`). No POST — redirects are written by merges and renames |
| `items` | GET | Gear catalog (table is `gear`), plus retired slugs as `redirects`. `?system=` — a NULL system is unrestricted, matching how `skills.systems` reads |
| `campaigns` | GET / POST | List (`?system=`, `?limit=`, `?offset=`), each row carrying `can_join` for THIS caller; create (caller becomes GM) |
| `campaigns/[id]` | GET / PATCH | Details (`gm_notes` stripped for non-GM, and `is_member`); edit `gm_notes` and the `open` join gate, **GM only** |
| `campaigns/[id]/search` | GET | FTS5 search over the campaign's notes (`?q=`, `?author=`, `?since=`). Free and instant — this is what runs as you type |
| `campaigns/[id]/ask` | POST | `{question}` → a written answer over the notes, stash and ledger, citing the entries it used. One model call per press; see [Search is free, asking costs a call](docs/campaign-and-play.md#search-is-free-asking-costs-a-call) |
| `campaigns/[id]/items` | GET / POST | The party stash (`?include_removed=1` for history); add a catalog or freeform item |
| `campaigns/[id]/items/[itemId]` | PATCH / DELETE / POST | qty/notes; soft remove; **POST claims it onto a character's sheet in one batch** |
| `campaigns/[id]/currency` | GET / POST | Balances and the ledger behind them; append a signed entry |
| `journal/[entryId]` | PATCH / DELETE | Edit or delete one entry — the author, or the GM. A body edit **reconciles its `@mentions`** |
| `campaigns/[id]/npcs` | GET / POST | The dossier roster (`?status=`, `?faction=`, `?q=`), with a mention count; create one by hand |
| `campaigns/[id]/npcs/[npcId]` | GET / PATCH / DELETE | The dossier **and every entry that mentions them, oldest first**; edit; delete (the notes are untouched) |
| `campaigns/[id]/npcs/[npcId]/portrait` | GET / POST / DELETE | Stream, upload (raw `image/*` body, 5MB) and remove. **Never a public bucket URL** — every read goes through the membership check |
| `campaigns/[id]/npcs/sweep` | POST | Propose the people nobody tagged. `?accept=1` creates the dossier a proposal named; `?dismiss=1` stops offering that name |
| `draft` | GET / PUT / DELETE | The caller's own unfinished wizard build. No id in the route — a draft belongs to a person, not a collection. One each. **PUT states the version it is replacing** in `expect_updated_at` and is refused 409 otherwise; see [Two tabs cannot overwrite each other](docs/wizard-and-sheet.md#two-tabs-cannot-overwrite-each-other) |
| `characters` | GET / POST | List (`?campaign_id=`, `?limit=`, `?offset=`); create at the starting level — **validated against the class rules, creation-time powers included, pool maxima capped to the class formulas for non-GM creators** — and refused 403 in a closed campaign unless the caller is its GM or already a member |
| `characters/[id]` | GET / PATCH / DELETE | Sheet + inventory, with `can_write` / `is_gm`; edit pools, notes, and the bio/combat/saves/armor sections. Also returns `skill_level_notes` and `weapon_bonuses` — what a skill grants that is not a summable number; see [A fighting style is a level schedule](docs/leveling.md#a-fighting-style-is-a-level-schedule). DELETE removes the character — owner or GM — and **keeps their journal entries**, detaching them to campaign-level first rather than letting the foreign key cascade a player's posts out of a log everyone reads |
| `characters/[id]/items` | POST | Add inventory row (catalog slug or freeform) |
| `characters/[id]/items/[itemId]` | PATCH / DELETE | qty/equipped/notes; soft remove |
| `characters/[id]/xp` | POST | `{delta}` or `{total}`; returns a proposed level-up diff |
| `characters/[id]/power-picks` | GET / POST | Spell and psionic grants banked at a level-up, and spending them. Each carries the spell-level cap the granting level came with, so a re-import between banking and spending cannot change what was granted |
| `characters/[id]/variant` | POST | Owner/GM. `{to_variant}` proposes a change of stage; add `confirm: true` with the accepted attributes and pools to apply it |
| `characters/[id]/level-confirm` | POST | Apply a confirmed diff, write `level_history`. `picks` spends granted skill picks; unspent ones are banked. Validated |
| `characters/[id]/picks` | GET / POST | Owner/GM to spend. Unspent skill picks; POST applies some. Validated |
| `characters/[id]/grants` | GET / POST | What a table handed this character outside its class schedule, and adding one. Owner **or** G.M., deliberately — the G.M. says the grant out loud and the player types it in. `{kind, name, reason}`; `reason` is required. Only `kind: 'skill'` is live. A granted skill lands in `characters.skills` as `type: 'gm'`, which every class-allowance and category check ignores by construction |
| `characters/[id]/grants/[grantId]` | DELETE | Take a grant back. Owner or G.M., and logged to `play_events`. The row goes for good — a grant is current state, not a ledger |
| `characters/[id]/events` | GET / POST | Play events. GET lists recent (`?since=`, `?limit=`); POST applies a play action and records it in one batch — `{kind, note, changes}` with absolute from/to values. Rolls carry no changes and are pure records |
| `characters/[id]/events/undo` | POST | Owner/GM. Reverses the **latest** not-undone event that carries changes and stamps `undone_at` — "take back the last thing", never a history editor |
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
`/api/media-vault/*` (MediaVault).

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

   Endpoints reach it through **`requireCharacter(request, env, id)`**, which
   returns `{ res }` to return or `{ email, access }` to use — the same shape
   `requireAdmin()` uses. Pass `{ write: false }` for a read. Every handler
   under `characters/[id]` previously opened with the same five lines, and the
   order within them is load-bearing: **404 before 403**, so probing ids cannot
   distinguish a character that is not yours from one that does not exist.
   That is precisely the kind of detail that goes wrong on the ninth copy.
3. **Admin** — `isAdminEmail()` compares the identity against the `ADMIN_EMAIL`
   environment variable and **fails closed** when unset. Admin gates both
   importers, which touch global catalogs rather than one campaign.

Clients hide controls they cannot use, but the server enforces independently —
the UI check is a convenience, never the boundary.

---

## One place composes a class

Turning a character's classes into the thing it is played as takes four steps,
and the order matters:

1. **apply each class's variant** — a Dragon hatchling is not an adult
2. **compose race with occupation** — into one class-shaped object
3. **fold in chosen abilities** — powers the player picked from a class's list
4. **fold in rolled psionics** — a tier the character rolled, not one the class declared

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

## Hit points and S.D.C. come from the core rules

Most class pages print neither. That is not an omission — p.18 states both
once, for every character, and a class page only speaks up when its O.C.C.
differs from the standard:

| | base |
|---|---|
| hit points | the **P.E. attribute** plus 1D6, and another 1D6 per level |
| S.D.C. | **3D6** for men of arms, **1D6** for practitioners of magic, scholars and everyone else |

The app used to read that silence as "this character has none" and store
`hp_max` NULL. Seventy-seven of one-hundred-and-sixty published classes state no hit point
formula, so this was the common path, not an edge case — two Priests of Light
reached production with no hit points and no S.D.C., and nothing on the sheet
suggested anything was missing.

So [`js/compose.js`](js/compose.js) fills both in when a class states neither.
A class that states its own formula always wins; the default only fills a gap,
and an M.D.C. being is left alone because it tracks M.D.C. **instead** — there,
silence really is the statement.

### Which classes are men of arms

Nothing in the class data records the book's O.C.C. grouping — `category` only
separates O.C.C. from R.C.C. — so it lives in `CORE_SDC_BY_CLASS` in the same
file, read off the section headings in the book.

The **occupation** decides it, not the race: what makes a character a man of
arms is the job, so a dragon that took a Merc Soldier rolls the soldier's 3D6.

A class that states no S.D.C. and is missing from that table gets **no S.D.C.
at all** rather than a guessed 1D6, which would quietly under-roll every new
man of arms. The smoke test fails on any such class, so adding one forces the
decision instead of hiding it. Adding a class that prints its own formula
needs no entry.

Characters already saved without pools were repaired by
[`db/backfill-core-pools.sql`](db/backfill-core-pools.sql), which rolls them
the way the wizard would have at creation. It skips M.D.C. beings, anyone
above level 1 ("+1D6 per level" needs one die per level, which a single
UPDATE cannot express), and any class it cannot classify.

---

## The scripts at the repo root

The README's file map covers `apps/character-creator/`. These live one level up
because they are not app code - they talk to D1, to books, or to the repo
itself.

```
scripts/
├── d1-apply.mjs            Apply .sql to --local or --remote, in sorted order.
│                           Refuses non-ASCII and honours `-- local-only`
├── d1-query-lib.mjs        One statement, one line, rows back. The banner-skip
│                           and buffer size that every caller needs
├── d1-backup.mjs           One JSON file per table, on disk, because
│                           `wrangler d1 export` REFUSES this database — one
│                           fts5 virtual table makes the whole of it
│                           un-exportable. Derives what to skip rather than
│                           naming it. Manual; see docs/operations.md Recovery
├── ofd-refresh.mjs         Snapshot the Open Filament Database into ff_brands
│                           and ff_filaments — FilamentForge's catalog. The app
│                           reads the snapshot; only this script talks to OFD
├── ofd-refresh-lib.mjs     Its deterministic half — CSV in, ASCII SQL out —
│                           so FilamentForge's smoke test can run it
├── audit-citations.mjs     Which published classes cite which audit finding, and
│                           which of those passages describe an app LIMIT that a
│                           taken finding may have lifted. Parses no outcome
│                           notes and sets no exit code, deliberately
├── drift-check.mjs         Repo vs live database: migrations, data scripts,
│                           tables, columns, classes, and an advisory citation
│                           check against every cached book books.json knows
├── deploy-sweep.mjs        Did anything merged actually SHIP? Walks the last
│                           twenty merge commits on origin/main and names any
│                           whose Pages check-run is not success, or that has
│                           no check-run at all. Report only, no exit code -
│                           65 consecutive merges once failed with a perfectly
│                           clear signal nobody read
├── catalog-match-lib.mjs   Matching a book's names to the catalog's. Exact
│                           first; a relaxed match only when unambiguous on
│                           BOTH sides. See below - do NOT merge this with
│                           catalog-merge.js
├── catalog-diff.mjs        That, behind a CLI: disagree / missing / matched /
│                           extra, plus the vocabulary warning
├── repo-vs-live.mjs        Can the repo rebuild the live catalog, row for row?
│                           Builds from scratch and diffs the NAMES, then every
│                           COLUMN of the rows whose names match. A missing or
│                           extra row exits 1; a wrong VALUE is reported and
│                           exits 0, because the value comparison began life
│                           with 413 findings
├── rebuild-local.mjs       The same build in ~20 seconds instead of an hour,
│                           one file at a time so a failure names its file.
│                           node:sqlite, not workerd - a DEVELOPMENT tool;
│                           repo-vs-live.mjs stays the authority
├── trace-row.mjs           Replay a rebuild and print every file that changes
│                           ONE row. Finds the guard that matched nothing
│                           because an earlier script renamed its string
├── source-coverage.mjs     Can what SHIPPED still be traced back to a cached
│                           page? Every class and catalog row bucketed
│                           traceable / not-a-book / no-source-book /
│                           no-page-range / unknown-book / not-cached /
│                           outside-cache, plus the importer stub backlog.
│                           Advisory, always exits 0 - the caches are
│                           gitignored and a clean clone traces nothing.
│                           --values asks the NEXT question: is the number
│                           printed on the page the row cites? Gear
│                           numerics only, and every miss is classed late /
│                           early / absent, because a short citation on an
│                           entry that straddles a page break is a different
│                           defect from a wrong value
├── source-coverage-lib.mjs Its pure half: one source_book string in, one
│                           bucket out, so the smoke test pins the bucketing
│                           against a fixture and never against live caches
├── source-book-lib.mjs     Composing the `source_book` a row is written
│                           with: the book resolved through books.json
│                           rather than taken verbatim, the pages
│                           normalised to `p.N-M`. Lived under
│                           `functions/_lib/` until its JSON import broke
│                           every production deploy for two days - Pages
│                           compiles every file under functions/, and its
│                           esbuild cannot read an import attribute. It
│                           had no route calling it by then; see its header
├── ocr-book.py             Cache a sourcebook into .cache/books/<slug>/ - the ONE
│                           front door, either kind of book. A text layer is
│                           detected and read through read-columns.py (no OCR,
│                           no cost); a scan is rendered and OCR'd at --psm 3
│                           with geometry and a Palladium wordlist. --probe
│                           says which it is and writes nothing
├── ocr-fields-lib.mjs      Typed readers for the numbers OCR gets confidently
│                           wrong - `Ibs`, `18.000`, `LS.P.` See below
├── palladium-words.txt     That wordlist. Committed; the OCR output is not
├── read-columns.py         Read a multi-column page in READING order, from a
│                           PDF that HAS a text layer. Columns found by gap,
│                           not by an assumed count. A CLI for reading a page
│                           range straight out of a PDF, and the reader
│                           `ocr-book.py` imports for its text-layer path -
│                           imported, never copied
├── parse-pf-spell-index.mjs        The Palladium Fantasy book's two spell
│                           authority tables, reconciled against each other
├── parse-pf-spell-descriptions.mjs Stat block and prose for named spells out of
│                           the same book's description pages
├── class-check.mjs         One class file, against the parser the app uses
├── class-check-lib.mjs     Its pure half, so the smoke test can call it
├── new-class.mjs           A commented starting point for writing a class BY
│                           HAND, occ or rcc. The template it prints is the one
│                           the retired importer carried; this is its front
│                           door. Everything it prints parses as-is, so
│                           class-check is clean before you write a word
├── extract-class.mjs       One class out of a cached book, into a DRAFT .md.
│                           The backend half of what import.html used to do:
│                           printed page range in, cached OCR text (not a PDF
│                           slice) to the model, markdown out, metered to
│                           claude_usage. REFUSES a page whose cached text is
│                           a few bytes - that is a full-page illustration,
│                           and sending it is how a class loses a third of
│                           itself. Drafts only; class-check is the next step
├── extraction-prompt.mjs   The class extraction prompt, and the schema it
│                           documents. Two system prompts: one for a PDF page
│                           image, one for cached text whose columns are
│                           ALREADY resolved and must not be re-ordered
├── books.json              The book registry: one entry per sourcebook the
│                           catalog cites, keyed by its .cache/books slug. The
│                           canonical title, every OTHER spelling production
│                           actually contains, the source PDF, the last printed
│                           folio and the printed-to-cache page offset. The last
│                           two gate the citation check: a cache shorter than
│                           the BOOK is not consulted, whatever its PDF held
├── books-lib.mjs           Reading it, and cacheCoverage - is this cache long
│                           enough to be believed? The title matching is in
│                           class-check-lib.mjs, which stays free of file I/O
├── readme-section.mjs      One section of this README by heading, bounded by
│                           the next heading of ANY depth; no arguments prints
│                           the heading index. The alternative kept being the
│                           whole file, which is working memory nobody needs
├── q.mjs                   One ad-hoc question to D1, from a shell. The
│                           alternative kept being a throwaway `node -e` that
│                           got the Windows quoting wrong a new way each time.
│                           `--batch file.sql` runs many statements in ONE
│                           wrangler invocation, numbered results back
└── sql-statements.mjs      Splitting SQL for wrangler, which truncates a
                            --command at the first newline
```

**The table is pinned by the smoke test.** `read-columns.py` and
`ocr-fields-lib.mjs` both lived here undocumented for several PRs - the first
arrived with the Knight import and is now the whole basis of every Palladium
Fantasy extraction. A file map that quietly stops being a map is worse than
none, so a check fails on a script this list does not name and on a name that
no longer exists.

## A row can say where it came from

`source_book` normally names a book and a page. Forty gear rows instead say:

```
Web reference (not book-verified)
```

That is not a placeholder waiting to be tidied. It is the honest value, and
it exists because the alternative was worse: naming a page nobody checked.

The reason is a near miss. The first stat block found for the Glitter Boy gave
820 M.D.C. and a 40 million credit price, and was only obviously wrong because
that page declared itself homebrew. The official figure is 770. Nothing about
the numbers themselves said which was which.

So the rule for anything transcribed from the open web:

- **`source_book` says the source was the web**, in those words, so a reader
  can tell a checked row from an unchecked one at a glance and a book
  correction knows what it is overwriting.
- **Uncertainty goes in `description`**, where a player reads it, not into a
  number that then looks like fact. The Dog Pack riot armor says its M.D.C. is
  for one pattern and that others differ; the air filter says two sources
  disagree on its price; the small mallet says its figures are a claw
  hammer's, because no mallet is priced anywhere findable.
- **A range stays a range.** Where a source gives one, the column holds the low
  end and the description gives the span. A backpack is "100 to 200 credits",
  and writing 100 alone would read as precision the source does not have.
- **What cannot be confirmed is left a stub.** Clothing, traveling clothes and
  food rations are still unpriced because no Rifts pricing for them exists on
  the open web — food and drink pricing is absent from most of the books
  outright. Inventing a number there would be inventing a rule.

Every data script that writes web-sourced values says so in its header too, so
the provenance survives in `db/` as well as in the row.

### A third tier, for what nothing publishes

Some things have no published price anywhere. The equipment chapter prices
no clothing — its alphabetical list runs straight from Cigarettes to Compass
to Cross/Crucifix — and no food at all. The open web has none either, and what
it offers for Palladium Fantasy is a generic fantasy list in gold that only
"references Palladium as a baseline", or pages that declare themselves
fan-made.

Those rows carry:

```
Estimate - no published price found
```

Grep for it to find every value in the catalog that **no source stands
behind**. A stub with no price cannot be bought at a table; a marked
estimate can, and is replaced the moment a real page turns up.

**Only things that cannot change a roll are estimated.** No estimated row
carries M.D.C., damage or an armour rating, and the smoke test enforces it.
A guessed price is a shopping inconvenience; a guessed damage die decides
fights and is indistinguishable from a real one once it is in the table. So
the weapons, the armour, the Juicer's drug harness and the Techno-Wizard
weapons stay stubs until a book says otherwise.

Weight is left NULL on estimated rows for the same reason. Cost at least has
the book's own scale to anchor against — a bedroll is 30 credits, a heavy
blanket 20 — but a weight would be invention with nothing behind it, and
encumbrance is what it would quietly affect.

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

**8788 is a convention, not a reservation, and a second checkout makes it a
trap.** Three separate audits found it already listening and moved to another
port: `UI-AUDIT.md` (*"which belongs to another worktree"*), `BULK-AUDIT.md`
(ran on 8801), `ISBN-AUDIT.md` (*"already listening, owned by another
process"*). The failure is not the collision — `pages dev` says plainly that the
port is taken. It is what happens when you *do* get 8788 and it is serving
**another worktree's** code: the page loads, it looks like your app, and it is
not. Verification then passes against something you did not write.

So before trusting anything you see there, confirm the page carries a string
your branch added. A screenshot proves nothing about which checkout produced it.

A database created before the `db/migrations/` files existed also needs those,
once each — see [Production configuration](docs/operations.md#production-configuration).

**`seed-catalogs.sql` seeds the three classes as they were originally written,
not as the rules audit corrected them.** The corrections live in
`apps/character-creator/db/fix-*.sql` and `apply-*.sql` and have to be applied on
top, or you are developing against class definitions the audit found wrong — see
[Data scripts](docs/operations.md#data-scripts). Each guards on the text it replaces, so applying
them to an already-corrected database does nothing.

Optional character/campaign test rows:

```bash
npx wrangler d1 execute DB --local --file apps/character-creator/db/seed-dev.sql
```

**Apply that one with plain `wrangler`, as above — not through `d1-apply.mjs`.**
That script skips any file carrying the `-- local-only` marker on **both**
targets, printing the skip, whether the file arrived through a glob or was
named outright.

The `--remote` half has always been true and protects production. The `--local`
half is newer and protects the RUN: `seed-dev.sql`'s inserts are unguarded, it
sorts 264th of 295, and the gear row it inserts has already been created by an
earlier script by the time a glob reaches it — so it fails on the FIRST pass
from an empty database, not on a second. `d1-apply.mjs` stops at the first
failure, so that one file used to strand the **31** that sort after it:
`untag-cross-system.sql` and every `zz-`, `zzz-` and `zzzz-` correction in the
repo. See [REBUILD-AUDIT.md](REBUILD-AUDIT.md) F1.

Smoke test (parser + schema):

```bash
node apps/character-creator/test/smoke.mjs
```

End-to-end regression — slower, and the one that exercises **requests**:

```bash
node apps/character-creator/test/regression.mjs
```

It builds its own D1 in a scratch `--persist-to` directory from `schema.sql`,
`seed-catalogs.sql` and every data script, boots `wrangler pages dev` on port
**8799** so your own dev server can stay up, then drives the real endpoints:
the wizard's boot calls, a campaign, a validated character, inventory (added,
updated, soft-removed, and the refusals), XP crossing a threshold, a confirmed
level-up, play events with an undo, journal, drafts, paging and the admin audit.
It deletes the scratch database afterwards and never touches yours.

**This is the layer `smoke.mjs` does not cover.** That suite proves the parser,
the dice and the composition rules are right, which is not the same as proving a
request works. The fresh-database bug — two columns missing from `schema.sql`,
so `/catalogs` 500'd — passed every one of its 768 checks and would have failed
here on the first run.

Copy `.dev.vars.example` to `.dev.vars` and set `ANTHROPIC_API_KEY` and
`ADMIN_EMAIL=dev@localhost` to exercise the importers locally. `.dev.vars` is
gitignored. To test owner/GM rules, send an explicit
`Cf-Access-Authenticated-User-Email` header.

### Checking a class before it lands

Most classes are not extracted through `import.html` at all — they are
transcribed by hand from page scans into a `db/add-*-class.sql` data script,
because the scans have no text layer and a class with several stages is quicker
to write than to extract and correct.

That path had no validator. The frontmatter contract lived in `js/parser.js` and
the catalog cross-reference lived on the server, so writing a class by hand
meant applying the script to find out whether it was right:

```bash
node scripts/class-check.mjs draft.md
node scripts/class-check.mjs apps/character-creator/db/add-mystic-class.sql
```

It parses through `parseClassMarkdown` and cross-references through
`crossReference` — the same two functions `import/recheck` and Confirm use, not
reimplementations. A checker that agreed with the app *most* of the time would
be worse than none: you would iterate against it, get a clean run, and still
fail on Confirm.

Given a `.sql` file it reads the markdown back out of the `imported_classes`
INSERT, so the artifact that actually ships is the one checked, and it repeats
d1-apply's ASCII/CRLF pre-flight early — at apply time those findings mean
coming back to the file cold. It prints the stub SQL for missing catalog rows in
the form the data script wants, with the `char(8212)` splice already in place.

`--remote` checks against production, `--no-catalog` skips D1 entirely. Unlike
`d1-apply.mjs` it defaults its target (`--local`), because that script refuses to
guess only where an accidental `--remote` would *write*.

#### `--field-sources`

The free-text fields — `starting_money` and the equipment prose — are the
fields no test pins, and both on-record transcription errors were the same
shape: a value read from a paragraph that continued past a page break the
reading stopped at (fixed in PR #280). `--field-sources` traces those fields
back to the page-addressed OCR cache under `.cache/books/<slug>/txt/` and
prints the lines each value was drawn from — and whenever a source span ends
near the bottom of its page, the first lines of the *following* page, which is
where the missing half of a broken paragraph lives. Entirely offline and
deterministic; it skips the D1 catalog pass.

The cached book is matched from `source_book` — first against
`scripts/books.json`, which lists each book's canonical title and every other
spelling production actually contains, then by the two older heuristics (the
slug as an initialism of the title, or the manifest's PDF name). `--book
<slug>` overrides. A registered book with no cache here resolves to *nothing*
rather than to the nearest-looking cache. The page window
comes from the title's `p.N-M` suffix, and the printed-page → PDF-page offset
is READ, not re-derived: `--offset <n>`, then `scripts/books.json` (which
answers per printed page, because `pf`'s offset is +1 for printed 1-16 and +2
after), then the cache manifest, then a majority vote over the bare page numbers
the pages show, then 0 — and it prints which. A disagreement between what is
recorded and what the pages vote is advisory: it is the signature of a re-cached
book or a page duplicated in the scan, and it never changes the exit code. When the window
matches nothing, it names the strongest-matching pages elsewhere in the book,
which is what a wrong offset looks like from inside the window. It reads best
right after transcribing: seeing a neighbouring class's Money paragraph beside
the one you used is exactly the check that the figure came from the right stat
block.

**Errors and pre-flight failures set the exit code; warnings and unmodelled keys
do not.** They are judgement calls, and a script that exited non-zero on them
would train you to stop reading the output.

#### Unmodelled keys

A top-level frontmatter key the app does not read parses cleanly, stores
cleanly, and then does nothing at all — which is how a class ships looking
complete. The checker lists any key outside `KNOWN_KEYS` in
`scripts/class-check-lib.mjs` under `UNMODELLED`.

It is a decision, not a defect, and both answers are legitimate: move the
mechanic into the body as prose so the class can ship now, or model it —
`parser.js`, `validate-character.js`, `compose.js`, the wizard, the sheet, a
smoke case, and `KNOWN_KEYS`. The Godling's occupation-demanding Magic Powers
and the staged-R.C.C. `variants` block both started as exactly this shape.

The smoke test asserts every shipped class comes back with no unmodelled key, so
`KNOWN_KEYS` going stale fails loudly rather than turning the check into noise.

---
