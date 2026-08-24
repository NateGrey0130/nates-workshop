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
- [A fighting style is a level schedule](#a-fighting-style-is-a-level-schedule)
- [Language and Literacy: Other, once per language](#language-and-literacy-other-once-per-language)
- [A printed bonus is not a base](#a-printed-bonus-is-not-a-base)
- [Enchantments](#enchantments)
  - [Languages of choice come from languages](#languages-of-choice-come-from-languages)
- [Level-up skill picks](#level-up-skill-picks)
- [Starting above level 1](#starting-above-level-1)
  - [What the levels are allowed to change](#what-the-levels-are-allowed-to-change)
  - [Per-level spells are not in the data](#per-level-spells-are-not-in-the-data)
- [The race is chosen first](#the-race-is-chosen-first)
  - [A roll can now miss a minimum](#a-roll-can-now-miss-a-minimum)
  - [Two class fields, not one](#two-class-fields-not-one)
  - [A draft stores its step as an index](#a-draft-stores-its-step-as-an-index)
- [A race and an occupation together](#a-race-and-an-occupation-together)
  - [The fourteen Palladium player races](#the-fourteen-palladium-player-races)
- [One place composes a class](#one-place-composes-a-class)
- [Hit points and S.D.C. come from the core rules](#hit-points-and-sdc-come-from-the-core-rules)
- [Classes that come in stages](#classes-that-come-in-stages)
  - [Changing stage](#changing-stage)
- [Powers the player chooses](#powers-the-player-chooses)
- [What a class grants mechanically](#what-a-class-grants-mechanically)
  - [The review step](#the-review-step)
- [Which system a catalog row belongs to](#which-system-a-catalog-row-belongs-to)
- [Filtering the catalog pickers](#filtering-the-catalog-pickers)
- [Two tabs cannot overwrite each other](#two-tabs-cannot-overwrite-each-other)
- [Unfinished builds are saved](#unfinished-builds-are-saved)
- [Starting gear the class leaves open](#starting-gear-the-class-leaves-open)
- [Psychic tiers](#psychic-tiers)
- [A blocked step says why](#a-blocked-step-says-why)
- [How the sheet updates](#how-the-sheet-updates)
- [Anyone at the table can write the log](#anyone-at-the-table-can-write-the-log)
  - [Membership is not a table](#membership-is-not-a-table)
  - [Search is free, asking costs a call](#search-is-free-asking-costs-a-call)
  - [The stash is an inventory the party owns](#the-stash-is-an-inventory-the-party-owns)
- [Who the campaign has met](#who-the-campaign-has-met)
  - [Two ways in, and only one of them guesses](#two-ways-in-and-only-one-of-them-guesses)
  - [Portraits, and the site's first bucket](#portraits-and-the-sites-first-bucket)
- [Play mode](#play-mode)
- [Server-side rule enforcement](#server-side-rule-enforcement)
- [The catalog field config](#the-catalog-field-config)
  - [What a list row shows](#what-a-list-row-shows)
- [A category restriction may name a skill from elsewhere](#a-category-restriction-may-name-a-skill-from-elsewhere)
- [A skill can grant more than a percentage](#a-skill-can-grant-more-than-a-percentage)
  - [Where they are applied](#where-they-are-applied)
- [A row can say where it came from](#a-row-can-say-where-it-came-from)
- [Merging duplicate catalog rows](#merging-duplicate-catalog-rows)
  - [Retired keys keep resolving](#retired-keys-keep-resolving)
- [The PDF importers](#the-pdf-importers)
  - [Class importer](#class-importer)
  - [Skill importer](#skill-importer)
  - [Spell importer](#spell-importer)
  - [Psionic importer](#psionic-importer)
  - [Gear importer](#gear-importer)
- [Checking a class before it lands](#checking-a-class-before-it-lands)
  - [Unmodelled keys](#unmodelled-keys)
- [Local development](#local-development)
- [Production configuration](#production-configuration)
  - [One database, and the case for keeping it that way](#one-database-and-the-case-for-keeping-it-that-way)
  - [Standing up a new environment](#standing-up-a-new-environment)
  - [The migration convention](#the-migration-convention)
  - [Data scripts](#data-scripts)
- [Known limitations and refactor candidates](#known-limitations-and-refactor-candidates)

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
├── import.html / import.js   Admin-only PDF import — Class, Skills, Spells,
│                             Psionics, Gear tabs
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
│                             hand (classic script — import.js is one)
├── js/class-blocks.js        Rewrites ONE frontmatter block in place, so the
│                             structured editors cannot disturb the rest of the
│                             file (classic script)
├── js/language-skills.js  The "once per language" rule for BOTH families (ES
│                             module — the server validator imports it, and the
│                             sheet reads its globalThis mirror via a module tag)
├── db/*.sql                  One-shot SQL. NOT migrations — these change rows,
│                             not schema. See Data scripts below
├── docs/rules-audit.md       Where each implemented rule comes from, by page
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

Twenty-seven tables in one shared D1 database (`nates-workshop-media`, bound as `DB`),
and one R2 bucket (`MEDIA`, same name) for the only binary this app stores.
`media_items` belongs to MediaVault and `schema_migrations` is database
bookkeeping shared by both; the rest are this app.

**Character data**

| Table | Notes |
|---|---|
| `campaigns` | Top-level container. `gm_email` owns it. `gm_notes` is GM-only and stripped from non-GM API responses. `open` (default 1) is the join gate: 0 means only the GM and existing members may create a character in it — see [Membership is not a table](#membership-is-not-a-table). |
| `characters` | See below — several JSON columns. `class_variant` names which `variants` entry the character is; NULL means the class as written. `occ_class_id` is the O.C.C. taken alongside an R.C.C.; NULL means none. |
| `enchantments` | What an alchemist can put into a weapon or a suit of armour, one row per property the book names. `cost` is the low end and `cost_note` the formula — *"2,000 gold per 20 S.D.C., 200 max on heavy armour"* is an arithmetic rule, not a number. `bonuses` is the **same JSON block** `skills.bonuses` uses, validated through the same `validateBonuses`, so `derive.js` needs no new cases. `limits` is what a picker has to act on: the Thunder Hammer is blunt weapons only. |
| `character_items` | Inventory join. `item_id` NULL means a freeform item (`custom_name` required). `removed_at` NULL means currently held — removals are soft, so history survives. `enchantments` is a JSON array of `enchantments.slug`, on the **instance** rather than the catalog row. |
| `journal_entries` | `character_id` NULL means a campaign-level entry. |
| `level_history` | One row per confirmed level-up; `changes` is a JSON diff of what was actually applied. |
| `pending_skill_picks` | Skill picks a level-up granted and nobody has spent yet. One row per **grant**, not per pick, so "2 picks from level 3" stays itemised. `categories` is copied from the class at level-up time — the class can change later, what you were granted cannot. |
| `pending_power_picks` | The same for spells and psionic powers. `spell_levels` is the cap the granting level carried, copied for the same reason — a Ley Line Walker's level-4 pair stays capped at spell level 4 however the class is later re-imported. |
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
| `skills` | `base` 0 means non-percentile (W.P.s, hand to hand). `systems` is a JSON array; NULL means both. `note` carries oddities like `40%/30% climb/rappel`. `bonuses` applies always; `level_bonuses` is a per-level schedule — see [A fighting style is a level schedule](#a-fighting-style-is-a-level-schedule). |
| `spells` | `system` NULL means unrestricted. name, level, ppe, plus a stat block (range, duration, damage, saving throw, area of effect, casting time, description). The stat block is TEXT — books write "100 feet per level" as often as a number. |
| `psionic_powers` | name, category (Healing/Physical/Sensitive/Super), isp, plus range, duration, saving throw and description — the same field names spells use. `min_tier` is the psychic tier a book states is required; NULL means no restriction beyond the category. `variant_note` carries what an older book states instead — the later book is authoritative (RUE over the Book of Magic, either over Palladium Fantasy) and the losing number is kept rather than discarded. |

Every catalog carries `source_book`, so an entry's provenance is visible and
the same skill from two books can coexist under distinguished names.

`skills`, `spells` and `psionic_powers` also carry `source` (`seed` \| `import`),
and a stub the class importer created is spotted by that plus zeroed numbers.
**`gear` has no `source` column.** It never did, so its stub marker is the
description instead: rows created by a class import open with `STUB —`, and a
row edited by hand loses the prefix and correctly stops counting as one. The
four `isStub` rules live together in `_lib/import-engine.js`; gear's is the
odd one out and the comment there says why.

Data scripts that create such a row must build that em-dash with
`'STUB ' || char(8212) || ' ...'` rather than embedding it, or the marker
arrives as mojibake and the row is a stub nothing can find.

**Working state** — not content, and not a character

| Table | Notes |
|---|---|
| `character_drafts` | One unfinished wizard build per person, `UNIQUE (owner_email)`. `state` is the build as JSON — deliberately not the catalogs it was built against. Its own table rather than a `draft` status on `characters`; see [Unfinished builds are saved](#unfinished-builds-are-saved). |
| `catalog_redirects` | Where a retired key went. Written when a merge deletes a row or a key is renamed by hand, so class markdown citing the old slug or name keeps resolving. Polymorphic by design — `catalog` names which table `to_id` points into — so there is no foreign key. See [Retired keys keep resolving](#retired-keys-keep-resolving). |
| `import_sessions` | One resumable catalog import. `catalog` is which of the four it feeds, `system` is stamped on every row the session confirms, `closed_at` NULL means still open. |
| `import_staged` | Rows one page range extracted, held until confirmed. `payload` is the extracted row as JSON, `match_name` the catalog row it duplicates, `action` the `insert` / `update` / `ignore` decision, `confirmed_at` NULL means still pending. Cascades from its session. |
| `play_events` | Play mode's action log, append-only. `payload` is JSON — a note, and `{from, to}` changes for undo. `undone_at` NULL means the event stands; undo marks, never deletes. Commentary, not a ledger: the character row stays the source of truth and nothing replays events |
| `data_script_runs` | Which `apps/character-creator/db/*.sql` data scripts have run here, and when. One row per **run**, not per file — those scripts guard every statement, so one is safe to re-run and safe to run early, and an applied-once flag would record a deliberate no-op as done. `note` non-NULL means the run was asserted rather than observed. See [Data scripts](#data-scripts). |

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
  - { item_id: "ns-turbo-cyclone", qty: 1 }          # qty may be a roll: "1d6"
  - { choose: 1, label: "energy pistol", qty: 1, from: ["ng-33-northern-gun-laser-pistol", "wilk-s-320-laser-pistol"] }
psionics:
  type: "major"               # minor | major | master
  isp_base: "1d4x10+20"
  powers: ["Sixth Sense"]     # powers the class automatically knows
  powers_starting: 3          # how many the player picks
  powers_from: ["Mind Block", "See Aura", ...]   # the exact list to pick FROM
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
| `campaigns` | GET / POST | List (`?system=`, `?limit=`, `?offset=`), each row carrying `can_join` for THIS caller; create (caller becomes GM) |
| `campaigns/[id]` | GET / PATCH | Details (`gm_notes` stripped for non-GM, and `is_member`); edit `gm_notes` and the `open` join gate, **GM only** |
| `campaigns/[id]/search` | GET | FTS5 search over the campaign's notes (`?q=`, `?author=`, `?since=`). Free and instant — this is what runs as you type |
| `campaigns/[id]/ask` | POST | `{question}` → a written answer over the notes, stash and ledger, citing the entries it used. One model call per press; see [Search is free, asking costs a call](#search-is-free-asking-costs-a-call) |
| `campaigns/[id]/items` | GET / POST | The party stash (`?include_removed=1` for history); add a catalog or freeform item |
| `campaigns/[id]/items/[itemId]` | PATCH / DELETE / POST | qty/notes; soft remove; **POST claims it onto a character's sheet in one batch** |
| `campaigns/[id]/currency` | GET / POST | Balances and the ledger behind them; append a signed entry |
| `journal/[entryId]` | PATCH / DELETE | Edit or delete one entry — the author, or the GM. A body edit **reconciles its `@mentions`** |
| `campaigns/[id]/npcs` | GET / POST | The dossier roster (`?status=`, `?faction=`, `?q=`), with a mention count; create one by hand |
| `campaigns/[id]/npcs/[npcId]` | GET / PATCH / DELETE | The dossier **and every entry that mentions them, oldest first**; edit; delete (the notes are untouched) |
| `campaigns/[id]/npcs/[npcId]/portrait` | GET / POST / DELETE | Stream, upload (raw `image/*` body, 5MB) and remove. **Never a public bucket URL** — every read goes through the membership check |
| `campaigns/[id]/npcs/sweep` | POST | Propose the people nobody tagged. `?accept=1` creates the dossier a proposal named; `?dismiss=1` stops offering that name |
| `draft` | GET / PUT / DELETE | The caller's own unfinished wizard build. No id in the route — a draft belongs to a person, not a collection. One each. **PUT states the version it is replacing** in `expect_updated_at` and is refused 409 otherwise; see [Two tabs cannot overwrite each other](#two-tabs-cannot-overwrite-each-other) |
| `characters` | GET / POST | List (`?campaign_id=`, `?limit=`, `?offset=`); create at level 1 — **validated against the class rules**, and refused 403 in a closed campaign unless the caller is its GM or already a member |
| `characters/[id]` | GET / PATCH | Sheet + inventory, with `can_write` / `is_gm`; edit pools, notes, and the bio/combat/saves/armor sections. Also returns `skill_level_notes` and `weapon_bonuses` — what a skill grants that is not a summable number; see [A fighting style is a level schedule](#a-fighting-style-is-a-level-schedule) |
| `characters/[id]/items` | POST | Add inventory row (catalog slug or freeform) |
| `characters/[id]/items/[itemId]` | PATCH / DELETE | qty/equipped/notes; soft remove |
| `characters/[id]/xp` | POST | `{delta}` or `{total}`; returns a proposed level-up diff |
| `characters/[id]/power-picks` | GET / POST | Spell and psionic grants banked at a level-up, and spending them. Each carries the spell-level cap the granting level came with, so a re-import between banking and spending cannot change what was granted |
| `characters/[id]/variant` | POST | Owner/GM. `{to_variant}` proposes a change of stage; add `confirm: true` with the accepted attributes and pools to apply it |
| `characters/[id]/level-confirm` | POST | Apply a confirmed diff, write `level_history`. `picks` spends granted skill picks; unspent ones are banked. Validated |
| `characters/[id]/picks` | GET / POST | Owner/GM to spend. Unspent skill picks; POST applies some. Validated |
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

## House rules and derived values

Palladium has no single answer for these, so the app invents one. Each is
overridable.

| Rule | Default | Override |
|---|---|---|
| Point-buy curve | All attributes start at 8, 40-point pool, +1 costs 1 point to 15 then 2 points to 18, cap 18, floor 3, refunds below 8 | — |
| Attribute rolls | Book rule, not a house rule — see below | `attribute_dice` |
| XP table | Shared 15-level curve: 0, 2000, 4000, 8000, 16000, 25000, 35000, 50000, 70000, 95000, 125000, 160000, 200000, 250000, 300000. **Every Palladium O.C.C. now overrides it** — see below | `xp_table: [...]` |
| Psionic starting powers | Book rule for a rolled psychic (minor 2; major 8 from one category or 6 from three). A class states its own; master 8 and Super are class-only | `psionics.powers_starting`, `psionics.categories_allowed` |
| Save vs psionic attack | 10+ for a Master Psionic, 12+ for minor and major psychics, 15+ for everyone else | override `saves.psionics_target` on the character |
| Skills gained on level-up | Start at the catalog's base percentage — a skill learned at level 6 is still new | `skills.occ_related_skills.schedule` |
| Skill percentage cap | 98% — book rule (p.22), applied at creation and on level-up | — |

### Experience is the occupation's, not the race's

Palladium Fantasy printed 336 prints **15 experience charts, 15 levels each**,
and names them by O.C.C. — *Knight & Noble*, *Thief & Merchant*. All 25
Palladium O.C.C.s in the catalog now carry their own, with nothing left over:
the two names on that page without a row here are the Monk, which is
`warrior-monk`, and the Goblin Cobbler, which is not imported.

`xp_table` stores the **lower bound** of each level's band, which is what
`levelForXp` compares against — the printed *"2,181-4,360"* for level 2 becomes
`2181`.

**The fourteen R.C.C.s get nothing, and that is correct rather than missing.** A
race has no experience table, because experience comes from what you do. That is
precisely why an occupation's table has to survive composition: `combineClasses`
carries a named list of keys forward from the occupation, and `xp_table` was not
on it, so since #210 a Knight's chart was dropped on **every Palladium
character** while the race's absence won. A race that *does* state a curve still
wins — a dragon's is the dragon's.

**This is fidelity, not a bug fix.** The house-rule default sits inside the
book's range at every level: at 15 the book spans 290,001 (Vagabond) to 370,201
(Witch) and the default is 300,000. Nobody was levelling at the wrong speed —
they were levelling at the average speed instead of their own class's. The
spread is a 28% difference between the two classes that most deserve to differ.

**The Warlock is the exception.** The catalog's `warlock` is the *Rifts* Book of
Magic printing and carries `system: rifts`, so a Palladium chart in its
frontmatter would apply a Palladium number to a Rifts row. It takes the figures
as a **delta**, in the same `## Palladium Fantasy` section that already records
its money and its armour.

Regression pins the shape over the whole catalog rather than a list of ids, so a
new Palladium O.C.C. arriving without a chart fails there rather than quietly
levelling on the house rule.

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
[`test/smoke.mjs`](test/smoke.mjs) `Attribute bonus chart`, which asserts the printed values.

The rows deliberately disagree with one another, and that is the point:

| Attribute | Drives | Shape of the row |
|---|---|---|
| P.P. | strike, parry, dodge | +1 per **two** points from 16 |
| P.S. | damage bonus | +1 per point from 16 |
| P.E. | vs poison, drugs, disease, spell/ritual magic, curses, faerie magic, pain, illusionary magic | +1 per **two** points |
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
Possession, horror factor, pain, illusionary magic, mind control, curses, faerie
magic and disease are not on the chart at all; each borrows the row for its own
attribute. Every one of them exists because a real class or race grants a bonus
to it, and **until there is a key the bonus reaches nothing** - it parses, it
stores, and it renders nowhere. The last two arrived with the Palladium Fantasy
player races: goblins and hob-goblins are +1 to save vs faerie magic, gnomes +1
and troglodytes +2 to save vs poison and disease.

`sheet.js` declares the labels for all of them **once**, in `SAVE_FIELDS`, and
play mode's roll buttons are `SAVE_FIELDS` minus the one percentile row rather
than a second list. There were two lists, and they had drifted: the sheet printed
thirteen saves and play mode offered eight buttons, so a Juicer's +6 vs mind
control was on the sheet and unrollable at the table. A smoke check now fails if
`derive.saves()` produces a key nothing prints, if a label names a key derive
does not produce, or if the list is declared twice.

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

## A fighting style is a level schedule

`bonuses` (migration 023) applies **whole, at every level**. That is right for
Boxing — +1 attack per melee, +2 parry and dodge, +2 P.S. — and wrong for every
Hand to Hand skill in the book, which Rifts Ultimate Edition p.347 prints as a
level-by-level table and states plainly are **accumulative**: a 5th level
Expert has levels 1 through 5, not level 5 alone.

So the entire mechanical payload of the five Hand to Hand skills had nowhere
to live, and was simply absent — `base` 0, `per_level` 0, no bonuses, no note.
Picking a fighting style changed nothing about how the character fought.

`level_bonuses` is a JSON array, one entry per level that grants something:

```json
[{"level": 1, "combat": {"attacks_base": 4, "pull_punch": 2, "roll": 2}},
 {"level": 2, "combat": {"parry": 2, "dodge": 2}},
 {"level": 3, "note": "Kick attack does 1D8 points of damage."}]
```

`combat`, `saves` and `attributes` are the same groups `bonuses` uses, and
everything at or below the character's level is summed.

### Three rules this shape had to earn

- **`attacks_base` sets; everything else adds.** The books state a starting
  number outright — "starts with four attacks per melee round" — so adding it to
  the derived base of 2 would give a first level Expert six. It is also the
  one key taken as a **maximum** rather than a sum, so a character holding two
  fighting styles fights at the better one instead of adding them together.
- **What is not a number goes in `note`.** "Karate Kick (2D6 damage)", "Death
  blow on a Natural 20", and the Assassin's bonuses that apply only to guns or
  thrown weapons. A conditional bonus in `combat` would apply unconditionally,
  which is the same reason Fencing carries its bonuses as a note.
- **A level of `null` grants nothing.** That is deliberately different from
  level 1: a caller that cannot say how experienced the character is should not
  silently hand out first level bonuses.

### Where it reaches the character

`bonusesFromSkills(rows, level)` folds the schedule into the same bonuses block
everything downstream already reads, so the sheet's combat numbers pick it up
with no further help. The notes cannot be summed, so the sheet endpoint returns
them separately as `skill_level_notes` and the Combat box lists them — without
that, a 7th level Expert's numbers would be right while the four moves earned
along the way went unmentioned.

`disarm`, `entangle`, `body_flip` and `automatic_dodge` joined the combat block
for this. `combat` and `saves` are open sets on purpose, so no validator
changed — only `derive.js`, which now knows what to call them.

### A W.P. bonus applies only with that weapon

Every numeric Weapon Proficiency bonus is **conditional**. p.326:

> ...hand to hand combat bonuses to strike and parry **whenever that particular
> type of weapon is used**.

Written into `combat` the way a Hand to Hand schedule is, a character with five
W.P.s would swing their **bare fists** at +5 to strike — and it would read as a
lucky roll rather than a bug. So an entry may carry `applies_when`:

```json
{"level": 1, "applies_when": "with a sword", "combat": {"strike": 1}}
```

`bonusesFromSkills` **skips** those entries entirely. `skillConditionalBonuses`
totals them instead, one row per skill and condition, and the sheet lists them
beside the combat block rather than inside it — a player needs both numbers,
and needs to know which is which.

One skill can carry several conditions: a sword swung and a sword thrown are
different bonuses and the book lists them apart, so collapsing them would
quietly add a throwing bonus to melee. An energy weapon's aimed-shot (+3) and
burst (+1) bonuses are level-independent and stack on top of its level ladder,
so those are separate conditions too.

### The merge that was called off

`W.P. Automatic Pistol`, `W.P. Revolver` and `W.P. Automatic and
Semi-automatic Rifles` look like older-edition names for what RUE folds into
`W.P. Handguns` and `W.P. Rifles`, and were one step away from being merged
into them with `catalog_redirects`.

**They are not the same skills.** Each carries its own bonuses, and the
Revolver's aimed shot is **+4** where every other modern handgun proficiency
gives +3. Merging would have deleted that difference from every character who
had taken the skill, with nothing left to recover it from. The smoke test now
asserts the two numbers stay apart, so the merge cannot happen by accident.

The lesson generalises: a name that looks like an old spelling of another is
not evidence that the rows say the same thing. Read both entries first.

**Two W.P.s still have no bonuses**, both with a note but no schedule:
`W.P. Bolt Action Rifle` ("Hunting and sniping rifles") and `W.P. Heavy`
("Machineguns, bazookas, LAWS, and mortars"). RUE has entries whose scope
matches each closely, but after the Revolver, assuming equivalence from a
matching description is exactly the mistake to avoid twice.

---

### Still missing

The book's table for a character with **no** Hand to Hand training (one attack
at level 1, a second at 3, a third at 9) is not modelled — `derive.js`
starts everyone at 2 attacks and takes no level. Only a character with no
fighting skill at all is affected.

---

## Language and Literacy: Other, once per language

"Language: Other" is the skill list's escape hatch: one catalog row standing
in for every language the books never print. A character takes it **once per
language** — Language: English, Language: Spanish, Language: Orc — each a
separate skill named for what it is, all advancing on the Other row's numbers
(50% +5/lvl). No catalog row per language exists or is wanted: the character's
denormalized skill rows carry the name and the percentages, which is exactly
what they were built for.

**"Literacy: Other" is the same row for reading rather than speaking** (30%
+5/lvl, filed under Communications), and the rule is now stated **per family**
rather than per row, so both behave identically everywhere. See
[Literacy is the second family](#literacy-is-the-second-family).

The rule lives in [`js/language-skills.js`](js/language-skills.js) and has
**five** consumers that must agree — the wizard's related/secondary picker, the
wizard's **choice-group** control, the sheet's claim/level-up picker, the
server's pick validator, and the server's level-up pick resolver:

- **In the wizard**, the Language: Other row prompts for the language instead
  of toggling, and never reads as already-taken, so it can be taken again.
  Each named language renders as its own checked row and un-picks
  individually. Duplicates are refused by name; class category gates apply
  unchanged (the row is Technical).
- **In an `occ_skills` choice group** it does the same — and for a long time it
  did not, because a group is a different control with its own toggle. There
  the same row was a plain checkbox, so *"two languages of choice"* produced a
  character holding one skill named, literally, `Language: Other`. Two Priests
  of Light in production are carrying exactly that. See
  [Languages of choice come from languages](#languages-of-choice-come-from-languages).
- **At level-up and claim time**, choosing Language: Other in a pick dropdown
  sprouts a "Which language?" input; the composed name is what submits. A
  blank language waits unspent, like any blank row.
- **Server-side**, a pick named "Language: X" that misses the catalog resolves
  to the Other row — the numbers still come from the catalog, so a caller
  cannot invent a percentage — with the language kept in the stored name.

The resolution rule everywhere: exact catalog hit first, and only a **miss**
in the `Language:` or `Literacy:` family falls back to **its own** family's
Other row. So Language: Dragonese, which has its own catalog row, resolves to
its own numbers, and a Literacy pick is never satisfied by a spoken language.
The smoke test pins the name-composition rules.

---

### Languages of choice come from languages

Thirty-three classes said *"two languages of choice"* — one, three, whatever
their book gives — and offered a whole skill **category** instead. Every one has
been narrowed to the repeatable `Language: Other` row.

| | classes | what the pick offered |
|---|---|---|
| via `Technical` | 7 | ~60 skills, languages among them |
| via `Communications` | 25 | 17 skills, **no ordinary language at all** |
| split in two | 1 | the Diabolist, below |

**The Communications twenty-five are the ones that mattered.**
`Language: Other` is filed under **Technical**. The only language row in
Communications is `Language: All (magical)`, which is a magical ability rather
than a language anybody learns. So a Ley Line Rifter's two languages could only
be spent on Radio: Basic, Cryptography or Surveillance — the class could not
grant a single language through its language pick.

The Technical seven were merely too wide, and nobody spent a pick on Gemology.
What they *did* do is instructive: two Priests of Light in production hold
`Language: Mongolian`, a Rifts-world language on a Palladium class, offered only
because it happens to sit in Technical.

#### The defect underneath was in the wizard, not the data

`Language: Other` is taken **once per language** and stored under the language's
own name. The related/secondary picker has always known that. **An `occ_skills`
choice group is a separate control and did not** — there the row was a plain
checkbox, so ticking it gave the character a placeholder instead of a name. Both
Priests of Light are carrying a skill called, literally, `Language: Other`.

Three things had to change together, and the third is the one that would have
been silent:

1. **`js/parser.js`** — a group may ask for more picks than its `from` list is
   long when the list carries a repeatable row. Without that, *"three languages
   of choice"* cannot be written down at all. The exemption is narrow: an
   ordinary over-asking list still errors.
2. **`app.js` `toggleGroupPick`** — prompts for the language, the way
   `toggleSkill` already did. The named picks render as their own rows so they
   can be un-picked.
3. **`app.js` `resolveSkill`** — falls back to the Other row's numbers for a
   name in the `Language:` family, the same resolution rule `skillsAtLevelOne`
   applies to related and secondary picks. A named language has no catalog row
   **by design**, so without this a group-picked `Language: Elven` saved at
   **0% +0/lvl**: a language the class granted, on the sheet, worth nothing and
   never advancing.

`_lib/validate-character.js` counts a named language toward a group offering the
Other row. It is advisory either way, but a Knight who took the two languages his
book grants was reading as having taken none.

#### Two numbers were wrong on the same lines

Rewriting a line while leaving a known-wrong number on it would be worse, so
these were corrected in the same script and named in its header. Both are the
printed percentage read wrong, and in both the class's own note records the
book's figure:

- **Cyber-Doc** — `base: 20, per_level: 0`. The printed *"+20%"* is a bonus on
  the Other row's 50%, not a flat 20% frozen for fifteen levels. Now `bonus: 20`,
  so the language resolves at 70% +5/lvl.
- **Vagabond** — no bonus at all, where the note said *"(+15%)"*. Now `bonus: 15`.

Every sibling class writes this as `bonus`; these two were the outliers.

#### The Diabolist was split by the limit this removed

Its book line is three languages of choice. A choice group could not ask for
more options than it listed, so it was written as `choose: 2` plus `choose: 1`,
with a note saying exactly why. That note described a limitation that no longer
exists — so the split and its explanation are both gone and the three languages
are one group again.

**One thing the shape still cannot hold**, stated in its own note rather than
dropped: the Headhunter Techno-Warrior's line is *"three languages of choice,
**or** one other language and two Lore skills"*. A choice group picks from one
pool, so it offers the three languages and the note carries the alternative.

**No character lost anything.** This narrows what may be *chosen*, not what has
been; the four production characters built on these classes keep every skill
they hold.

---

### Literacy is the second family

The same check, run on literacy. `Literacy: Other` was the only member of its
family with **no rule at all** — it was treated as one ordinary skill — so a
Wizard *"literate in two languages of choice"* spent both picks and ended up
literate in "Other". Six classes, and the shapes differ:

| class | was | now |
|---|---|---|
| Rogue Scholar | the whole `Communications` **category**, 17 skills | pick 3, +30% |
| Diabolist | a from-list of 4 **generic** Literacy rows | pick 2, +20% |
| Summoner | same | pick 2, +20% |
| Wizard | same | pick 2, +15% |
| Shifter | `Literacy: Other` granted as a **fixed** skill, base 50 | pick 1, +20% |
| Warlock | same, base 40 | pick 1, +10% |

The Rogue Scholar is the language defect exactly. The middle three were better
and still wrong: the four rows on offer — `Literacy`, `Literacy: Native
Language`, `Literacy: Dragonese/Elven`, `Literacy: Other` — are all generic, so
two picks bought nothing named. The last two **granted the placeholder**, which
is a pick that was never offered; both of their own notes say *"of choice"* in
so many words.

**No number changed in the six.** Every group keeps its own `choose` and
`bonus`, and the two fixed grants became a pick at the bonus their base already
encoded — the Shifter's 50 is the catalog's 30 plus its printed 20, the
Warlock's 40 is 30 plus 10. Only the **name** changes, from `Literacy: Other`
to the language the player picks.

#### Generalising the rule was most of the work

[`js/language-skills.js`](js/language-skills.js) went from a Language-only API
to a per-**family** one: `isFamilyName`, `isRepeatableRow`, `otherRowFor`,
`familySkillName`, `promptFor`. `isLanguageName` and `languageSkillName` are
gone — generalising left them with no callers, which is what the smoke test's
dead-export check exists to catch. Eleven call sites across `app.js`,
`sheet.js`, `parser.js`, `_lib/validate-character.js` and `_lib/skill-picks.js`
now name a family rather than a row, and the prompt asks *"Which written
language?"* when it should.

#### The Stone Master was granting nothing at all

Found by the same sweep, a different defect, fixed in the same script:

- **`Literacy: Dragonese/Elf`** — no such catalog row and **no redirect**, so
  the skill resolved to nothing. The row is spelled `Dragonese/Elven`.
- **`Language: American`** — `base: 0, per_level: 0`, so it sat on the sheet at
  0% and stayed there for fifteen levels. It has no catalog row of its own,
  which is precisely what the Language family's Other row is for: 50% +5/lvl.

Both are pinned by regression now: **every fixed skill must resolve to real
numbers** (a catalog row, a redirect, or its own stated base), and **no
Language or Literacy skill may sit at 0%**.

This sweep also turned up **68 fixed skills sitting below their catalog base**,
which needed the books open one class at a time. See
[A printed bonus is not a base](#a-printed-bonus-is-not-a-base).

---

### A printed bonus is not a base

An O.C.C. skill list writes a fixed percentage two ways, and they mean opposite
things:

| printed | means |
|---|---|
| `Language: Native Tongue at 96%.` | the figure **is** the percentage |
| `Chemistry (+10%)` | ten points **on top of** Chemistry's own 30% |

Both were stored the same way, as `base`. So the Cyber-Doc — a surgeon —
diagnosed at **Computer Operation 5%** where any passer-by has 40%, and the
SAMAS Pilot drove at **Automobile 15%** against a catalog row of 60%. Not a
small bonus: a crippling floor, on exactly the skills the class exists to be
good at.

**48 skills across six classes** now carry `bonus` instead, which
`resolveSkill` has always summed onto the catalog row — the app supported this
the whole time; only the data and the validator disagreed.

| class | skills | source |
|---|---|---|
| Cyber-Doc | 10 | RUE p.90 |
| Rogue Scholar | 10 | RUE p.94 |
| Wilderness Scout | 9 | RUE p.99 |
| Coalition SAMAS Pilot | 8 | RUE p.233 |
| Stone Master | 6 | Book of Magic p.224 |
| Vagabond | 5 | RUE p.97 |

Dropping `per_level` alongside `base` matters too: the SAMAS Pilot's Automobile
carried `+5`/level where the catalog row is `+2`.

#### Read as images, not as OCR

Rifts Ultimate Edition has no text layer. The OCR cache is good for *locating* a
section and not for transcribing one — it had merged the SAMAS Pilot's skill
list with the Coalition Grunt's column beside it, which would have written six
wrong numbers. Every page here was rendered and read as an image instead, and
the generator refuses to rewrite a line whose stored number does not already
equal the printed bonus.

#### What was checked and deliberately left alone

15 rows still sit below their catalog base, and every one is what its book
prints:

- **Twelve `Language: Native Tongue` rows at 88–97%.** The Vagabond really does
  speak at 88% and the Mystic at 97%; the catalog's generic 98% is not what
  those classes get. Each now carries the page it came from, because eight of
  them carried nothing and every audit re-derived the same answer from the same
  scans — which is the work a note exists to prevent.
- **The Noble's Horsemanship: General at 35%/+5.** The O.C.C. block prints it
  with no bonus at all — the 35 is the *Palladium Fantasy* skill's own number,
  a cross-system difference its note already records.
- **The Warrior Monk's Begging at 20%/+3.** Palladium Fantasy prints, in so many
  words, *"Base Skill: 20%+3% per level of experience."*
- **The Vagabond's Begging at 10%.** Printed `Begging (10%)` — no plus, where
  every sibling line has one. Kept as a base, but its `per_level: 0` was dropped
  so it advances at the catalog's +3 instead of freezing for fifteen levels.

The Chiang-Ku hatchling was a different defect found by the same sweep: the
adult knows all domestic skills at 80%, which is right, but the hatchling
variant lowered five of them to a flat 25, which is nobody's number. Dragons &
Gods p.22 says hatchling skills *"start at first level proficiency"*, and the
override's Advanced Math already read that way at the catalog's own 45. The five
domestic rows now do too.

Three regression invariants hold the line: a `bonus` may never sit on a name the
catalog does not have (it would resolve to **0**, not to the bonus), **no fixed
skill may sit under its catalog base without a note explaining why**, and that
rule asserts it actually compared rows rather than passing vacuously.

The middle one used to exempt the `Language:` and `Literacy:` families outright.
That exemption did nothing useful — the check already skips names the catalog
does not hold, and a native tongue *does* have a catalog row — so all it achieved
was hiding twelve rows that really are below the line. It is gone, and the rule
is now simply: **below the line, say why.**

---

## Enchantments

**What an alchemist puts INTO an object, as opposed to the object.** Palladium
Fantasy draws three families the same way — a property with a price and a cap,
instilled into ordinary gear:

| family | count | printed | cap |
|---|---|---|---|
| `armor` | 11 features | 249 | four to a suit |
| `weapon` | 21 properties | 249-250 | three to a weapon |
| `charm` | 30 powers | 253 | three to a ring, bracelet or medallion |

*"Cloak of Armor, 20,000 gold"* is a **gear row**. *"+1 A.R., 4,000 gold"* is
**not**: it is a modifier that can sit on any of the armour rows the catalog
already has, and a row per combination of every feature with every suit is not
a catalog, it is a combinatorial explosion.

The charm family is the one worth reading the book for. It is easy to take those
thirty as finished items — a Ring of Chameleon, a Medallion of Teleport — and
the page says otherwise: *"The following magic effects can be **placed in**
rings, bracelets, charms, and medallions,"* three powers to an item.

### The array is on the instance

`character_items.enchantments` is a JSON array of slugs on the **inventory
row**, not a flag on `gear`. One long sword in a party of four can be the Demon
Slayer while the other three stay ordinary, and no other shape can say that.

### Bonuses reuse the block that already exists

`enchantments.bonuses` is the **same JSON block** `skills.bonuses` and a class's
`bonuses:` use, validated through the same `validateBonuses`. That is not a
convenience — it is why this was affordable: *Invisible Weapon: +3 initiative,
+2 strike and parry* is `{"combat":{"initiative":3,"strike":2,"parry":2}}` and
`derive.js` needed **no new cases**, exactly as it needed none when skills
learned to grant bonuses.

Seven of the 62 carry one. Dice are stored **as dice** — the Thunder Hammer's
extra 2D6 is `"2d6"`, not a 2 — which the group has accepted since the
Godling's *"+1D4 on initiative"* made it a hard parse error.

**The rest stay prose, deliberately.** Three fireballs a day, double damage to
demons, teleport three times daily: a number would be a lie about what the book
grants. Two more are prose for a different reason — Protection from Circles and
from Witches are real `+1`s with **no save to land on**, since the sheet's save
block covers spell magic, ritual magic, wards, psionics and horror factor. A
bonus on a key nothing renders is stored, ignored, and indistinguishable from
one that works, so both the generator and regression **refuse** a save key the
sheet cannot show.

### The rules live on the server

`PATCH /characters/:id/items/:itemId` takes the whole array and checks it, because
the sheet is not the only caller and a stored slug that resolves to nothing
renders as a slug forever:

- an armour feature needs armour and a weapon property needs a weapon;
- a charm power may go in anything **except** a weapon, which the book states
  outright;
- one item may not mix two families;
- the cap comes from `max_per_item` **on the row**, not from a constant — four
  features fit in a suit and a fifth is refused.

A freeform item (`item_id` NULL) has no category to check against, so the family
rule is skipped rather than guessed at: a GM who writes in "silver signet ring"
should be able to enchant it. The cap still applies.

### The armour table, all sixteen rows of it

Printed 270 prints **sixteen** types of armour and the catalog held **five**, so
a Palladium character could buy soft leather, hard leather, studded leather,
chain mail or scale mail and nothing else — no cloth, no padding, no splint, no
plate, and not one of the half suits, which is most of what a poor character or
a heavily armoured one would actually wear. All sixteen are there now, plus the
three leather half suits the prose beneath the table gives.

The five that were already there are a **check on the reading** rather than just
data: they come from the same table, and the generator refuses to run if any of
them has drifted from the printed figures. All five matched.

**Three half suits keep no price.** The table prices the metal ones; the leather
half suits appear only in the prose — *"half suit of Soft Leather has 10 S.D.C.
& A.R. 6"* — with no figure, and a number there would be invented. The same
prose says a half suit of padded, quilt or cloth *"isn't worthwhile"*, so none
is imported.

**Shields are on printed 60**, under W.P. Shield, not in the armour table. The
catalog had the small wood-and-leather one and mentioned the metal-plated
version inside its own description; all five are now rows.

### Seven Rifts armour rows were the same suit twice

Each pair was one row imported from Rifts Ultimate Edition p.261-270 and one
older row whose `source_book` read *"Web reference (not book-verified)"*. On the
four full-suit pairs the M.D.C. and the weight agree exactly — 95/24, 70/21,
35/13, 50/11 — which is what makes them duplicates rather than four suits that
happen to share a shape. The book-verified row is the keeper every time.

**The Crusader pair disagreed on price**, 55,000 against 40,000. That one is not
a tidy-up: one of those numbers was wrong and the catalog offered both.

**The three Dead Boy rows are a different shape.** Two were one-line stubs with
no M.D.C. and no cost, standing beside full rows that had both. The third was
not a suit at all — *"Dead Boy" Body Armor (Black Market)* had no M.D.C. and its
description said outright that it was a price. Printed 261 puts that price under
*"Features Common to All Dead Boy Armor"*, so it belongs to **both** suits and is
now a `cost_note` on each rather than an item somebody could wear.

**One redirect already pointed at a row being retired.** `dead-boy-body-armor`
resolved to the CA-2 *stub*, so it is re-pointed first — a retired key resolving
to a row that no longer exists is the one failure `catalog_redirects` exists to
prevent, and regression now checks it over the whole catalog.

**Checked and found distinct**, so left alone: the Bushman Trooper (90 M.D.C.
against the composite's 60 — a separate model, not another printing), the
Huntsman and Juicer Assassin plate (both 45 M.D.C. and everything else different),
and `cyber-armor`, which two characters are wearing.

### The items themselves are gear

The other half of printed 249-267. The enchantments are what an alchemist puts
INTO an object; **175 finished items** are the objects he sells over the
counter, and those are ordinary `gear` rows.

| section | rows | section | rows |
|---|---|---|---|
| Magic potions | 28 | Faerie foods | 28 |
| Miscellaneous components | 28 | Herblore drugs | 17 |
| Poisons and toxins | 12 | Magic fabrics | 11 |
| Other articles | 11 | Bandages and make-up | 10 |
| Crystals and stones | 9 | Magic powders | 8 |
| Magic fumes | 7 | Guardian stones | 3 |
| Magic armour, finished suits | 3 | | |

**The three magic suits go in as armour**, not as an undifferentiated `magic`
row: the page prints an A.R. and an S.D.C. for each, and those columns exist —
Cloak of Armor at A.R. 14 / S.D.C. 50, Cloak of Protection at 12 / 50, Leather
of Iron at 15 / 60. Everything else is `category = 'magic'`.

`cost` holds the low end and `cost_note` the rest, which most of these need: the
book prices in ranges far more often than in figures, and four different ways —
a range (*"20,000-40,000 gold"*), an open end (*"700,000+"*), a per-unit rate
(*"80 gold per foot"*), and a band. **Faerie foods are priced by band**, which
their own preamble states: 500-1,500 for the recreational ones, 2,000-10,000 for
the debilitating. They are prefixed *Faerie* because the catalog already sells an
ordinary goose.

**One item has no price and keeps none.** The Crystal Ball is *"considered
priceless and sells for millions"*, and a number there would be invented.

#### Reading prose, not a table

These entries are paragraphs with a price somewhere inside. An extractor found
the boundaries; three classes of error had to be corrected by reading the page,
and all three are pinned:

- **A price wrapped across a line.** `20,000-
30,000` rejoins as the single
  number **2,000,030,000** if the de-hyphenation that fixes a broken *word* is
  let near a number. The Fright Wig and the Chaser crystal both read that way.
- **A longer entry labels its own parts** — `Duration:`, `A.R.:`, `Cost:` — and
  each looks exactly like the start of a new item. The Cape of Dimensions' 700,000
  gold was attributed to an item called *"Use Limits"*.
- **The first price in an entry is not its price.** The Cape mentions 25,000 gold
  to repair a tear long before its own cost line.

### What is deliberately not modelled

- **Rune and holy weapons** are *generated* from a tier and a table of powers
  rather than listed. Importing them would invent about forty items the book
  does not print.
- **Curses** are effects applied to a person or an object, with no price and no
  weight — closer to a spell than to a sword.
- **Transformable weapons** are a kind of weapon rather than a property, and the
  book says outright that one *"cannot have any other magic properties"*.
- **Duration and frequency** stay in the description. *"20 melees, twice daily"*
  is two numbers and a unit; three columns used by one family of one book, with
  nowhere on the sheet to put them, would be worse than a sentence.

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

## Starting above level 1

A player joining an established party used to have to be built at 1 and levelled
up five times through the XP endpoint, one confirmation at a time, inventing the
XP the character never earned to get there.

The wizard now asks for a **starting level** on the Race step, 1 to whatever the
class's own XP table caps at. Above 1, an **Advancement** step appears after
Powers.

**It is not a second system.** `buildProposal(character, cls, toLevel)` already
computed the whole diff for a span of levels, and by the end of the Powers step
the level-1 character is complete — which is exactly the input that function
takes. So starting at level 6 is *build at 1, then run the engine the live
level-up already uses*. That is why `js/leveling.js` moved into the app: the
browser cannot import anything under `functions/`, and
`_lib/leveling.js` now re-exports it so every server import is unchanged. Same
arrangement as `js/dice.js`, and for the same reason.

**One proposal per level, not one for the span.** The step runs the engine once
for each level gained, which is what makes a single level re-rollable — open
level 4, re-roll its dice, and every other level stays exactly as it stands.
Each level's growth is independent of the running total (the proposal reports
`from`/`to` and only the difference is kept), so every call starts from the
level-1 character.

The step opens on the summary — total pool growth, all skill picks, all spell
and psionic picks — with a collapsed section per level underneath. A player who
wants six levels resolved in one click gets that; one who wants to roll each
level's hit points separately gets that too.

### What the levels are allowed to change

| | |
|---|---|
| pool maxima | **rolled**, per level, from the class's `per level` formula |
| skills held since level 1 | advanced by `per_level × levels gained`, capped at 98% |
| skills picked with a grant | **not** advanced — a skill learned at level 5 is new, and starts at its catalog base |
| skill picks left blank | banked in `pending_skill_picks`, shown unspent on the sheet |
| XP | set to the level's own threshold, server-side |
| starting gear and money | **unchanged** |

**Gear and money do not scale, deliberately.** The books do not rule on what a
veteran owns, so any multiplier would be an invented rule and what a level-6
character has is a table conversation. Do not quietly add a per-level allowance.

**XP is not sent by the client.** The server reads `xpTableFor(cls)` and sets XP
to `thresholdFor(table, level)`, so the level and the XP beside it cannot
disagree. A level-6 character left at 0 XP reads as under-levelled to the XP
endpoint, and the very next award proposes a level-up it has already had.

**The server does not trust the pick count.** The wizard sends `picks_spent`;
the create endpoint recomputes the allowance with `skillGrantsFor(cls, 1, level)`
and banks the remainder, consuming from the earliest grant first — the same rule
a live level-up follows, now shared as `remainingGrants()` so the two cannot
drift. The character is also validated at **the level being created**, not at 1,
because the related and secondary allowances grow with level and judging a
level-6 character against a level-1 allowance refuses skills its class granted.

`validate-character.js` warns `xp_below_level` when a character above level 1
has less XP than its level needs. Hand-edited data and a G.M. levelling someone
by hand both produce it legitimately, so it is a warning and never a violation —
and the admin audit had to start selecting `xp` and passing it, because a
warning nothing hands the number to is a warning that never fires.

### Per-level spells are not in the data

`magic.spells_starting` and `psionics.powers_starting` are **level-1 counts**.
Until this change nothing in a class definition said what is learned per level —
only skills had a `schedule`. The books do state it, so the honest answer for a
class that has not been re-imported is *not recorded*, which is a different
answer from *none*:

```yaml
magic:
  spells_starting: 6
  spells_per_level: 2                                  # a flat rule
  # or, when the book varies it:
  spells_schedule: [{ level: 2, count: 2 }, { level: 3, count: 3 }]
psionics:
  powers_per_level: 1
  powers_schedule: [{ level: 4, count: 2 }]
```

`spellGrantsFor` and `psionicGrantsFor` return three distinguishable states:
`applicable: false` (the class has no magic at all), `unknown: true` (it has
magic and states no per-level rule), and a list of grants itemised by the level
that earned each. The Advancement step prints the difference — a class stating
nothing says so and offers nothing, rather than showing an empty list that reads
as *this class learns nothing at level 4*.

A schedule is the **complete** statement when present and a flat `*_per_level`
is ignored alongside it. Two keys that combine is a rule nobody remembers
correctly six months later.

**How many is not the same question as which.** The Ley Line Walker learns *"2
additional spells per level of experience, equal to or lower than their current
level of experience, starting at level 2"* — a cap that tracks the character
rather than a list, and one that **disagrees with the starting selection on
purpose**: a fresh walker picks twelve spells from `spell_levels_allowed:
[1,2,3,4]`, and the two it gains at level 2 may only be spell levels 1–2.

```yaml
magic:
  spells_starting: 12
  spell_levels_allowed: [1, 2, 3, 4]              # the starting twelve
  spells_per_level: 2
  spells_per_level_levels: up_to_character_level  # the per-level pair
```

`spells_per_level_levels` takes `up_to_character_level` or an explicit list, and
falls back to `spell_levels_allowed` when absent — so it costs nothing for a
class whose per-level picks are not capped this way.

**A schedule entry may override all of it**, because some books vary the cap per
level rather than by one rule. The Mystic (RUE p.119) is the case that forced
it: four spells at level 2 from spell levels 1–3, three at level 3 from 1–4,
then two per level from its own level downward. The first two are the
character's level **plus one** and the rest are the character's level, which no
single rule expresses.

```yaml
magic:
  spells_starting: 8
  spell_levels_allowed: [1, 2]
  spells_per_level_levels: up_to_character_level   # what entries without one use
  spells_schedule:
    - { level: 2, count: 4, spell_levels: [1, 2, 3] }
    - { level: 3, count: 3, spell_levels: [1, 2, 3, 4] }
    - { level: 4, count: 2 }
    # … every level, to the class's cap
```

An entry's own `spell_levels` wins; entries lacking one fall back to the
class-wide rule. And because a schedule is a finite list, **"and each additional
level of experience" has to be written out** — to 15, the default XP table's
cap. A class with a shorter `xp_table` simply never reaches the tail.

### Several grants can share a level, and a rule can be unenforceable

The Shifter needed both. It gains **three** spells at every level from level two,
and they do not come from the same place:

> Starting at level two, the Shifter can choose one spell from the following
> list plus one Protection or Summoning spell also in this list: *[34 named
> spells]* … and any Summoning spell that may be desired, excluding weather
> summoning. In addition, the Shifter can select one non-dimension related or
> control based spell, but they are limited to spells equal to or less than the
> Shifter's current level of experience.

So the **level alone stopped identifying a grant**. Entries sharing a level are
told apart by `slot`, and everything that keys a grant — the room accounting, the
banking, the pick payload — keys on level *and* slot.

```yaml
magic:
  spells_per_level_from: ["Banishment", "Charm", …]   # declared ONCE
  spells_per_level_levels: up_to_character_level
  spells_schedule:
    - { level: 2, count: 2, from_list: true, note: "One of these two must be a Protection or Summoning spell" }
    - { level: 2, count: 1, note: "Not dimension-related or control-based" }
```

`from_list` points at a list declared once rather than repeated on every entry.
It takes two forms, because a class can have one list or several:

| | |
|---|---|
| `from_list: true` | the class's single list, `spells_per_level_from` — the Shifter |
| `from_list: "A"` | one of several, from a `spell_lists` map — the Ley Line Rifter, which learns *"one spell (pick one) from each list"* every level |

Repeating a thirty-four name list on every entry would put it in the class
definition fourteen times and make one correction fourteen edits. **A slot
bounded by a named list is not also bounded by a spell level** — the list is the
restriction. A `from_list` naming a list that does not exist restricts nothing
rather than everything, which is the safer direction to fail.

**Modelled as two grants, not three**, because the difference between the book's
first two is a restriction nothing can check.

#### The lists outran the catalog, until the book was read

Both classes named spells the catalog never had: the Rifter's List A resolved
**3 of 17** and its List B 13 of 21, the Shifter's list 19 of 34. One chapter —
Rift & Ley Line Magic — accounted for nearly all of it.
`add-book-of-magic-rift-spells.sql` added the 72 spells behind that gap, read
out of the Book of Magic with the app's own importer, and all three lists now
resolve in full.

**A spell description does not print its level.** The book states that only in
the section heading a spell is listed under, so importing description pages
returned level 0 for **69 of 84** spells — and a level-0 spell matches no
`spell_levels` filter, so confirming those would have added rows the pickers
could never offer. That is what an import that looks like it worked looks like.
The level comes from the book's own master by-level index (pp. 89-92) instead,
and a spell that index could not place was left out rather than guessed at.

**Three independent readings had to agree** before anything landed: each spell's
own stat block, the cost the master index prints beside the name, and the cost
the class page prints in parentheses. Where the Shifter's class page disagreed —
`Influence the Beast` at 20 against 12, `Tame Beast` at 30 against 60 — the
description and the index agreed with each other, so the class page is the
outlier and the stat block won.

#### The whole Invocation list, and what supplying the level did not fix

`add-book-of-magic-invocations.sql` adds **108 spells** — every Invocation in
the book the catalog did not already hold, levels 2 through 15 plus the Spells
of Legend. A Ley Line Walker's picker went from 203 of the book's 311 listed
invocations to all of them.

Knowing the level does not come from the description, this import supplied it:
one request per **level section**, each carrying its own level, so no batch could
straddle a boundary. That was necessary and **not sufficient**. The book's
`Level N` headings sit *partway down a page*, so the first page of every batch
still carries the tail of the previous level — and those spells were stamped
with the new batch's level. **Thirteen rows came back exactly one level too
high**, `Sonic Blast`, `Wards` and `Wall of the Weird` among them, every one of
them looking completely ordinary.

So the rule is sharper than "supply the level": **the index is the authority and
the page position is not**. Every row was corrected against the master by-level
index, which states each spell's level in one place regardless of where its
description falls.

`Rift Teleportation` shows the mechanism at its clearest. Its stat block starts
on p143 and its `P.P.E.: Two Hundred` line falls on p144, so the Level Twelve
batch saw only the tail and produced a *second* row — conflated name, wrong
level, no cost at all — for a spell the catalog already had.

**Parsing that index took three passes, and the first two were quietly wrong.**
Worth recording, because each failure produced a plausible-looking answer:

| pass | what it did | how it showed |
|---|---|---|
| linear text | read the page as a text stream | levels one and two came back **empty**; `Blinding Flash` and `Globe of Daylight` filed under level three. It is set in three columns and the stream does not follow them — so read it geometrically, bucketing by x and sorting by y |
| strict names | allowed only letters in a name | silently dropped every `Summon & Control ...` entry and every name carrying its own parenthetical, like `Doppleganger (Superior) (1,000)` |
| strict costs | required a cost to be numeric | rejected `(l)` — an OCR'd 1 — along with `(400 to 1000+)` and `(1,600 or Special)` |

The finished index holds **311** entries and every staged row matched one. Costs
agreed on **108 of 108** between each spell's own stat block and the index.

#### A restriction the catalog cannot enforce is stated, not dropped

A spell row carries a name, a level, a cost and a stat block — **no category and
no tag**. So *"non-dimension related or control based"*, *"Protection or
Summoning"* and *"any Summoning spell"* have nothing to filter on. Classifying
three hundred spells by reading their names would be exactly the guessing
[the import rules forbid](#known-limitations-and-refactor-candidates).

`note` carries the rule to where the choice is made, and the picker says plainly
that it cannot check it. That is the **skill-category posture, not the
psychic-tier one**: a rule the app cannot verify is one it should be honest
about rather than silently drop or silently enforce wrongly.

**The named list is enforced**, server-side as well as in the picker. It used
to be **15 of the Shifter's 34 spells that were not in the catalog** — the
dimensional ones the class is built around (`Close Rift`, `D-Step`, `Rift to
Limbo`, `Time Hole`…), from a chapter nobody had imported. They stayed in the
list on purpose, because a picker should name what it cannot find rather than
silently shrink, and they lit up the day `add-book-of-magic-rift-spells.sql`
arrived. **All 34 resolve now**, as do the Ley Line Rifter's 17 and 21.

That behaviour is still the point, even with nothing currently missing: a list
naming a spell the catalog lacks is a visible gap, not a shorter list.

Three of the 34 use the catalog's spelling rather than the book's, checked before
the list was written: `Control **&** Enslave Entity`, `De**si**ccate the
Supernatural` (the page misspells it), and `**Air:** Phantom Mount`.

#### Six spell levels RUE overrides, and an index that took three tries to read

`fix-rue-spell-levels.sql` corrects **six levels and one P.P.E. floor** against
RUE, which came out after the Book of Magic and overrides it.

All six level rows already carried `source_book = 'Rifts Ultimate Edition'`, and
all six were **exactly one level too high** — the same signature as the thirteen
rows the Book of Magic import got wrong, and the same cause: level headings sit
*partway down a page*, so the first page of an extraction batch carries the tail
of the previous level and those rows get stamped with the new batch's number.

| spell | catalog | RUE index | RUE description section |
|---|---|---|---|
| Teleport: Lesser | 7 | **6** | 6 |
| Tongues | 7 | **6** | 6 |
| Words of Truth | 7 | **6** | 6 |
| Sickness | 9 | **8** | 8 |
| Spoil | 9 | **8** | 8 |
| Wisps of Confusion | 9 | **8** | 8 |

`Manipulate Objects` stored `ppe = 0` with the note `2 per 5 lbs`. The book
prints *"P.P.E.: Varies; two P.P.E. per five pounds"* and the index prints
`2+`. **A stored 0 reads as free at the table** and also matches the stub
heuristic; `ppe` holds the minimum and `ppe_note` carries the schedule.

**Nothing was added.** The index listed five spells the catalog appeared to
lack and all five were the same spell under a different spelling — the diff
manufactured them by comparing raw names: `Animate/Control Dead` =
`Animate and Control Dead`, `Power Weapons` = `Power Weapon`,
`Summon & Control Canine` = `Summon and Control Canines`, `Control/Enslave
Entity` = `Control & Enslave Entity`, `Swim as a Fish` = `Swim as a Fish
(lesser)`. They keep the catalog's spelling: renaming would break every class
definition citing the current name, and citations are matched **in the browser**,
where `catalog_redirects` are not sent.

**The probes were wrong before the parser was.** Four spells came out at a level
that contradicted what I expected — `Carpet of Adhesion` 4 not 5, `Magic Net` 4
not 7, `Circle of Flame` 5 not 6, `Constrain Being` 7 not 10. Checking each
against its description section showed RUE agreeing with itself both times. The
expectations came from another edition. A probe that fails is a question, not a
verdict.

#### The Palladium invocation list, and the 57 nobody could reach

Two scripts, and the second is the one that mattered more.

`add-pf-invocations.sql` adds the **27** spells the Palladium Fantasy main book
prints and the catalog did not hold. `retag-pf-spells-both.sql` moves **57**
that were already there from `system = 'rifts'` to `both`.

**A Palladium Wizard could reach 98 of the 182 spells its own book lists.**
`inSystem()` offers a catalog row when its system is NULL, `both`, or the
build's own, and every spell imported from a Rifts book carries `rifts` — so a
spell in *both* books was invisible to the Palladium half of the app. This is
the same defect
[`fix-pf-armor-and-cross-system-gear.sql`](db/fix-pf-armor-and-cross-system-gear.sql)
fixed for gear, where the Knight held clothing, gloves and a riding horse its
own sheet could not resolve. The trigger there was *"a class in the other system
grants the row outright"*; here it is stronger — the other system's core book
prints the spell by name, with a level and a cost the catalog already agrees
with.

The damage was worst exactly where a caster earns it. **Every spell from level
ten up was on that list bar one**, so a Palladium Wizard reaching tenth level
was offered almost nothing new: Mystic Portal, Summon Shadow Beast, Anti-Magic
Cloud, Create Golem, Resurrection, Dimensional Portal and all four Spells of
Legend were filed as Rifts-only. Nothing is taken away by the fix — `both` is a
superset of `rifts`, so every Rifts character still sees every one of them.

**No OCR and no model call.** The PDF carries a real text layer, so both tables
and all 27 descriptions were read geometrically with
[`scripts/read-columns.py`](../../scripts/read-columns.py). The whole import cost
nothing but reading.

**The book ships two authority tables and they check each other.** An
alphabetical list by level (printed 187), which is the only place a level is
stated at all, and an alphabetical list by page (printed 188), which repeats
every cost. Parsed side by side they disagree on exactly **two costs out of
182** — See the Invisible (4 or 6) and Curse: Phobia (40 or 50) — and neither is
in this batch. Every imported row also has a **third** reading: the P.P.E. line
in its own stat block, usually spelled out in words there, *Twenty-Five* against
the index's 25. 27 of 27 agree.

**Two false gaps, both naming.** `catalog-diff.mjs` reported 29 missing and two
were not: *Swim as a Fish* is the catalog's `Swim as a Fish (lesser)`, and
*Invulnerability: Limited* is the catalog's `Invulnerability` — same level and
same cost in both cases, and the description page heads the second
*"Invulnerability (limited)"* where the index adds a colon. Three more looked
like near matches and are genuinely different spells: `Animate Object` against
the Warlock's `Earth: Animate Object`, `Circle of Concealment` against
`Concealment`, and `Time Capsule` (Touch, 30 P.P.E., preserves objects) against
the Rifts `Ley Line Time Capsule` (15).

**Nothing to record from the disagreements**, which is the result worth stating
plainly. `catalog-diff` reported 21 rows whose stored value differs from the
book. Fourteen already carry the Palladium figure in `variant_note` from
[`add-palladium-variants.sql`](db/add-palladium-variants.sql); four are costs
the book qualifies and the catalog already explains in `ppe_note`; and four are
Spells of Legend, which the catalog stores at level 15 with a note saying so.
The later book still wins and **no stored number changed.**

**One page argues with the index, and the index won.** Exactly six description
blocks state a level of their own, and five of them are the book's own Spells of
Legend. The sixth is *The Finger of Lictalon*, headed *"Level: Spell of Legend"*
on printed 211 while the by-level index files it under Level Eleven. Three
things point the other way from its own page: the index puts it at eleven, the
Spells of Legend list does not name it, and its 150 P.P.E. sits with the level
elevens rather than the 1000-5000 of the legends. It is stored at eleven and its
`variant_note` records the losing reading rather than discarding it.

**The Druid is why this was worth doing now.** Its `level_progression` names
sixteen abilities as prose, and six of the wizard spells among them had no
catalog row of any spelling before this import — Faerie Speak, Control the
Beasts, Summon and Control Canines, Witch Bottle, Faeries' Dance and Monster
Insect. Three more were there under a different spelling, which is worse than
absent: the class page tells a player they gain *Faerie's Dance* at ninth level,
and typing that into the picker finds nothing.
[`fix-druid-spell-names.sql`](db/fix-druid-spell-names.sql) aligns those three.
All thirteen wizard spells the Druid names now resolve.

**Eight of its sixteen do not, and should not.** Healing Touch, Kindle Flame,
Prophecy, Divination, Phoenix Healing, Protection Charm, Weather Control and
Communication are **Druidic magic powers** with their own descriptions on the
Druid's own pages, not wizard spells. Kindle Flame is the one that reads like an
oversight and is not: printed 76 gives it a full description, and the level four
line does not say *"as the wizard spells"* the way levels 2, 5 and 7 do.

#### Four spells the catalog held twice

`fix-duplicate-spell-rows.sql` removes four duplicate rows. **They were not
found by looking.** The new matcher refused to match RUE's `Summon & Control
Canine` because two catalog rows claimed the alias, and that refusal to guess
exposed a duplicate nobody had noticed. Scanning every catalog the same way —
group by name with parentheticals and connectives dropped, then require the
identifying fields to agree — found three more. All four are in `spells`;
skills, gear and psionic_powers are clean.

Every pair was settled against a book, not against which name looked nicer:

| kept | removed | why |
|---|---|---|
| `Fear` | `Fear (Horror Factor: 16)` | RUE's index prints the name plainly as **Fear**, level 2, 5 P.P.E. The stat detail was baked into the name by the importer |
| `Summon and Control Canines` | `Summon & Control Canines` | same spell imported once from each book; the Book of Magic copy carries **no description** |
| `Circle of Travel` | `Circle of Travel (Ritual)` | the Book of Magic master index lists it **once**, and the word "Ritual" appears nowhere on those index pages |
| `Transformation` | `Transformation (Ritual)` | same |

The `(Ritual)` rows had the same level, the same P.P.E., no description, and a
P.P.E. note saying the same thing in different words. They are an import
artifact, not a second spell.

Two safety checks ran first. **No class cites any of the eight names** — and the
first attempt at that check looked for YAML list items and returned zero for
everything, which would have read as "safe" for entirely the wrong reason.
Classes cite spells as an inline `Name (cost), Name (cost)` run; the corrected
check was probed against a name known to be cited before its zeros were
believed. **No character holds any of them** in its powers JSON.

The script matches **by name, never by id**: row ids differ between the local
and remote databases — `Fear (Horror Factor: 16)` is #37 locally and #29 in
production — so an id here would delete the wrong spell in one of them.

#### The import tooling, and the mistakes that paid for it

Four pieces, each built because the same class of error kept producing
confident wrong answers.

**`scripts/catalog-match-lib.mjs` — matching a book's names to the catalog's.**
Nearly every wrong import answer came from here:

| import | first answer | truth |
|---|---|---|
| psionics missing | 21 | 16 |
| psionics wrong category | 23 | 0 |
| spells missing | 5 | 0 |
| gear | "136 additive" | 27 collided |

Two failure modes, opposite directions. **Too strict invents gaps** — `Commune
with Spirits` and `Commune with Spirit` are one power, and importing the "gap"
duplicates it. **Too loose invents corrections** — RUE prints `Bio-Regenerate
(self)` *and* `Bio-Regeneration (Super)`, so stripping the parenthetical
collapses them onto one row and generates confident fixes to rows that were
already right.

The rule that survives both: **exact match first, and a relaxed match only when
it is unambiguous on BOTH sides**. Everything else is reported with its nearest
candidate and decided by a person. `nearest()` is advisory and must stay that
way — `Telekinetic Push`/`Punch` are distance 2 and are different powers, while
`Animate/Control Dead`/`Animate and Control Dead` are distance 4 and are the
same spell.

**`vocabularyWarnings()` catches the 22-of-23 case.** When one substitution
accounts for nearly all of a field's disagreements, that is a naming convention,
not N corrections. It fires on `Super-Psionics -> Super` (29 of 30) and stays
silent on the six genuine RUE spell-level corrections, which spread across two
different substitutions. Both behaviours are pinned in the smoke test.

**`scripts/catalog-diff.mjs`** puts that behind a CLI and prints four buckets —
disagree / missing / matched / extra — plus the vocabulary warning at the top.

```bash
node scripts/catalog-diff.mjs --table psionic_powers \
     --entries .cache/books/rue/psionics.json --compare category,isp
```

**`scripts/ocr-book.py` — OCR a scanned book once, properly.** Every setting in
it was learned by getting it wrong:

| setting | why |
|---|---|
| `--psm 3`, not `6` | at psm 6 Tesseract welds columns: `Level Two  Magic Shield (6)  Distant Voice (10)` arrives as one line |
| TSV always, beside the text | reading an index in reading order needs word geometry; the first pass saved text only and two pages had to be re-OCR'd mid-task |
| `--user-words` | Tesseract reads `I.S.P.` as `LS.P.`; a strict pattern found **10** stat blocks in a chapter that has **86** |
| 500 dpi for index pages | the authority tables are set in the smallest type in the book |
| normalise once, at ingest | `$.D.C.`/`[.S.P.`/`fect` are properties of the scan, not of today's import — fixing them per-import is how an unbounded `fect`->`feet` turned "effectively" into "effeetively" |

`.txt` is normalised, `.raw.txt` is what Tesseract actually said, `tsv/` carries
the geometry. **The cache is gitignored on purpose**: it is the full text of a
book Palladium still sells. Regenerate it, do not commit it.

```bash
python scripts/ocr-book.py "path/to/Book.pdf" --slug rue --tables 167,200-202 --dpi-tables 500
```

**A citation guard in `drift-check`.** Every psionic power claimed
`source_book = 'Rifts Ultimate Edition'` and twelve appeared nowhere in that
book. drift-check asks whether the repo can rebuild the database; this asks
whether the database is telling the truth about where it came from.

**Advisory, and it does not touch the exit code.** Run against a complete cache
for the first time it reported 40 problems, and the shape of its mistakes is the
useful part:

- 18 skills were flagged because the guard expanded `&` to "and" while the
  book text had the `&` deleted — `Motorcycles & Snowmobiles` became
  `motorcycles and snowmobiles` against a book holding `motorcycles snowmobiles`.
- **35 of the rest were gear, and gear is now excluded.** A gear name here is
  reworded prose, not a heading the book prints: the catalog says `"Dead Boy"
  Body Armor CA-2 (Light)` where RUE says *"CA-2 Light Body Armor"*, and `Light
  Mdc Body Armor` where the book says *"light M.D.C. body armor"*. Both are in
  the book. A check that cries wolf 35 times is worse than no check.

Left over: 422 rows checked, **4 worth a look** — four `W.P.` skills whose
component words appear in RUE but never as a skill heading. That is the right
kind of output for an advisory: a question, not a verdict. Whether a citation is
right is a different question from whether the repo can rebuild the database,
and wiring it into the exit code would fail every run over a name the book
spells differently, which is how a useful check gets ignored.

It runs only when the book's OCR cache is **complete** — a partial cache once
accused four gear rows whose pages simply had not been OCR'd yet, so it reads
the expected page count from the manifest and skips otherwise.

**`.claude/agents/book-reconcile.md`** is a second reader for the reconcile
pass, and deliberately has no write tools. It exists because the failures worth
catching all look ordinary from inside the parse — most sharply when four spell
probes "failed" and the book was right both times while my expectations came
from a different edition. **A failed probe is a question, not a verdict.**

#### The RUE psionics gap, and a diff that lied twice

`add-rue-psionics-gap.sql` adds the **16 psionic powers** Rifts Ultimate
Edition defines that the catalog did not carry, and corrects two I.S.P. costs.

The authority is the **Psionic checklist on printed p164**, which states every
power's name, category and I.S.P. cost in one place — the psionics equivalent
of the Book of Magic's master index. Every row was then read a second time from
its own stat block on printed pp.165-184. All sixteen agree.

The first diff of that checklist against the catalog reported **21 missing and
23 wrong categories**. Both numbers were mostly noise, and applying either
would have done damage.

**The catalog's category vocabulary is `Healing` / `Physical` / `Sensitive` /
`Super`. RUE's section heading reads "Super-Psionics".** That one word
accounted for **22 of the 23** category "errors". Rewriting them would have
moved 22 rows to a category value nothing else in the app uses, breaking every
picker that filters on it. Alias the heading; do not import it.

**A parenthetical qualifier is part of a power's identity.** RUE prints
`Bio-Regenerate (self)` *and* `Bio-Regeneration (Super)`; `Telekinesis` *and*
`Telekinesis (Super)`. Matching on names with the parenthetical stripped
collapsed each pair onto a single catalog row and produced three I.S.P.
"corrections" and two category "corrections" **to rows that were already
right**. The same stripping is what made three more look missing when they were
present under a different spelling:

| RUE prints | catalog holds |
|---|---|
| Bio-Regenerate (self) | Bio-Regeneration |
| Impervious to Poison | Impervious to Poison/Toxin |
| Commune with Spirits | Commune with Spirit |

So the match is **exact first**, and a stripped match is accepted only when it
is unambiguous *on both sides*. Anything left over is reported with its nearest
candidate and judged by eye — `Telekinetic Push` and `Telekinetic Punch` are two
characters apart and are different powers.

Two costs RUE genuinely overrides, each confirmed by both readings:

| power | catalog | RUE checklist | RUE stat block |
|---|---|---|---|
| Commune with Spirit | 8 | 6 | 6 |
| Sense Dimensional Anomaly | 6 | 4 | 4 |

Descriptions come from the book's own OCR'd text rather than a re-extraction —
it costs nothing and cannot invent anything. What it *can* do is carry OCR
damage, so the cleanup is an explicit table. Two defects it introduced before
being caught: an unbounded `fect`->`feet` rule turned "effectively" into
"effeetively", and the last power's block, having no following heading, ran off
the end of the chapter and swallowed the opening of the Magic section — 9,706
characters of description for a power that needs 2,677.

**OCR reads `I.S.P.` as `LS.P.` on most of these pages.** A strict pattern found
10 stat blocks in a chapter that has 86. Any pattern matching a psionic cost
line has to accept `I`, `L`, `l` and `1` as the first character.

#### Twelve rows claimed a citation the book does not support

All 94 psionic powers carried `source_book = 'Rifts Ultimate Edition'`. **Twelve
of them do not appear in that book at all** - not on the checklist, and nowhere
in the text of any of its 382 pages: `Attack Disease`, `Transfer I.S.P.`,
`Teleport Object`, `Commune with Animals`, `Dispel Spirits`,
`Advanced Trance State`, `Catatonic Strike`, `Cure Insanity`,
`Induce Nightmare`, `Insert Memory`, `Invisible Haze`, `Mental Illusion`.

They came from `add-rue-psionics-batch.sql`, an earlier extraction. The chapter
OCR'd completely - printed pp.165-184 each carry 3.7-7.5 KB - so this is not a
gap in the reading. The citation is simply wrong.

`fix-unverified-psionic-provenance.sql` sets those twelve to `source_book NULL`.
**It does not delete them.** Several are real Palladium powers from World Book
12: Psyscape, which RUE's own checklist page points at, so the content is worth
keeping and only the citation is false. Nor are they retagged *to* Psyscape:
that book is not in hand, and a guess is what created this. NULL is the honest
value.

Three tests were tried before one was trusted:

| test | absent | verdict |
|---|---|---|
| whole name | 13 | too strict - RUE prints `Commune with Spirits`, catalog holds `Commune with Spirit` |
| any distinctive word present | 7 | far too generous - `Catatonic Strike` matched on "strike", and "catatonic" appears on an insanity table 200 pages away |
| **whole name, parenthetical dropped, plural-tolerant** | **12** | used - the parenthetical must go or `Object Read (Psychometry)` reads as absent when RUE lists plain `Object Read` |

### A psionic grant can name its categories, and they replace the class's

Same shape, different subject, and the Mystic needed both halves — which is why
it is the class worth designing against. Bullet 4 of the same page:

> Select three additional psychic abilities from the **Sensitive** category and
> another two from the **Healer** category. At levels four and eight the Mystic
> can select one additional ability from the **Super** category.

```yaml
psionics:
  type: major
  powers_starting: 5
  categories_allowed: ["Sensitive", "Healing"]
  powers_schedule:
    - { level: 4, count: 1, categories: ["Super"] }
    - { level: 8, count: 1, categories: ["Super"] }
```

**A grant's categories REPLACE the class's rather than narrowing them**, and
that is the whole point rather than a convenience. Every catalogued power has a
NULL `min_tier`, so the per-power tier gate never fires and **tier is enforced
by category**: Super is master-only because non-masters are not offered it. A
grant naming Super *is* the book granting a major psychic an exception, so
intersecting it with the class's own categories would throw the exception away
and leave an empty picker.

Which also means **the psionic picker is per grant**, as the spell picker
already was. It used to be one batched set, on the reasoning that no book states
which level a given power had to be learned at. The Mystic states exactly that.

`pending_power_picks.categories` carries it for a banked grant, copied at grant
time for the same reason `spell_levels` is.

**Which is why the spell picker is per grant, not one batched set.** Each level's
spells are chosen from the levels *that* level allows, the way skill picks are
already chosen from the categories their grant allows. Batching them would
quietly let the level-2 pair be filled with level-4 spells. Psionic powers stay
batched: no book states which level a given power had to be learned at.

The cap is **enforced, not advised** — an out-of-cap spell is not in the list at
all. A spell's level is a mechanical rule like a psychic tier, not a table
judgement like a skill category, and the app already draws that line.

"starting at level 2" needs no key: a per-level grant is earned for every level
above the first, which is levels 2 upward by definition.

`extraction-prompt.js` names all four keys, because
[a field the prompt does not mention is a field that never arrives](#known-limitations-and-refactor-candidates) —
`variants` shipped as schema the prompt was never told about and the first class
with age stages came back with both stat blocks dropped.

### The live level-up grants them too

The sheet's level-up panel offers the spells and powers the crossed levels earn,
one select per slot, grouped by the level that granted it — because for spells
the levels a slot may draw from belong to *that* grant. Crossing two levels at
once caps each pair separately.

Unspent slots **bank into `pending_power_picks`**, the same as skill picks, for
the same reason: levelling up is never blocked on choosing, so a grant nobody
spent has to go somewhere or the spells that level earned vanish silently.

The cap is enforced **server-side**, not only in the picker. `resolvePowerPicks`
checks every pick against the grant it claims — that such a grant exists, that
it has room, that the power is not already known, that it is in the catalog, and
that a spell's level is inside that grant's cap. A rejected pick fails the whole
level-up with a sentence saying which and why, rather than being dropped.

One trap worth recording: `loadCharacter` does not join `campaigns`, so the
system filter on the catalog lookup read `character.campaign_system` and got
`undefined` — a silent no-op that would have let a Rifts caster learn a
Palladium-only spell. The system is fetched explicitly now.

---

## The race is chosen first

The wizard's order follows how a character is actually made: you are a dragon,
you roll to find out what kind of dragon, and then you decide what the dragon
studied.

```
System → Race → Attributes → Occupation → Skills → Equipment → Powers → (Advancement) → Details → Review
```

Advancement appears only when the starting level is above 1 — see
[Starting above level 1](#starting-above-level-1); at level 1 the stepper
walks past it.

The **Race** step is a briefing rather than a row in a list. Before committing,
the player reads what the R.C.C. grants: the attribute dice it will roll per
attribute, the pool formulas as formulas, the bonuses, the psionic tier (or
`psionics_allowed: false`, which is a statement and looks like an absence), the
skills it already knows, and whether an occupation is normally taken alongside
it. All of that used to be first visible a step later, after the choice had been
made and the dice were already rolling.

**The bonuses line names all four groups**, `pools` included. It listed
attributes, combat and saves only, and a **pool bonus does not appear in the
`Pools` line either** — that line prints the pool's own FORMULA, and a class
that adds to another's roll rather than replacing it states no formula at all.
So the Troll's +40 S.D.C., the single most distinctive number on its page, was
shown nowhere on the step that exists to show it. Fifteen of the sixty-one
classes published before the races grant a pool bonus, so this was never only a
race problem. A smoke check now fails if the briefing stops reading one of the
four groups.

**The list still holds every class for the system.** An O.C.C. taken as the
primary class is a human character and always was. When that happens the
Occupation step does not apply and is greyed in the stepper rather than removed,
so the numbering stays the same between two characters side by side.

`stepApplies(i)` decides, and `seekStep` walks past a step that does not apply
from either direction. A predicate rather than a hard-coded skip, because
`render()` also consults it — a resumed draft, or an ability dropped after the
fact, can otherwise land on a step that stopped making sense.

### A roll can now miss a minimum

Attribute minimums come from **both** classes, the stricter of each. Rolling
before the occupation is chosen therefore admits a state the old order could not
reach: a stat block that fails the O.C.C. the player then wants.

The Occupation step names the attribute and the number missed by, and offers to
**re-roll that attribute alone**, with the race's dice for it. Whatever it comes
up as, it stands — including a second failure, which may be re-rolled again only
if the player chooses to.

Three alternatives were rejected on purpose:

- **Re-rolling the whole stat block** throws away good rolls to fix one bad one.
- **Auto-raising to the minimum**, which several books instruct, would leave a
  number on the sheet that no dice produced. The app's posture is that every
  number came from somewhere.
- **Offering a choice between re-rolling and raising** is two mechanisms where
  one will do.

**It is never a refusal.** A player may decline and continue with the minimum
unmet; `validate-character.js` warns on save and the admin audit lists it under
*worth a look*, which is the existing doctrine for occupations rather than a
stricter rule invented for the same class of problem.

Each re-roll is recorded and posted as a `roll` play event once the character
exists — the events API already defines that kind as a pure record with no state
change. A number that came from a second attempt should not sit on the sheet
looking like what the dice said first.

### Two class fields, not one

`S.rcc` is what the player **picked**: raw, unresolved, still carrying its
variants and choose-groups, which is what the Race step's pickers read. `S.cls`
is what the character **is**: variant applied, occupation composed in, abilities
folded in.

It used to be one field that `confirmClass` overwrote in place. That was fine
while both halves were chosen on the same step and is not any more — adding an
occupation two steps later has to re-compose from the original, and a composed
class has already lost the halves.

`S.raceCls` is the third: the race alone, composed. It exists because **its dice
bonuses were rolled and read on the Attributes step**, and choosing an occupation
afterwards must not re-roll a number the player has already seen. So the two
sets of rolls are held apart — `S.attrBonuses` for the race, `S.occAttrBonuses`
for the occupation — and `rolledAll()` is the only thing that sees them summed.
Changing occupation re-rolls its half and leaves the race's alone.

### A draft stores its step as an index

Which means changing `STEPS` silently re-points every draft in flight. Drafts
carry `steps_version`; version 1 is the eight-step list with one combined Class
step, version 2 split Class into Race and Occupation (nine steps), and
version 3 — the list above — inserted Advancement after Powers.

`migrateDraft()` maps an old index forward, one insertion per version, so the
migrations **chain**: a version-1 draft runs through both. Only the steps
**after** an inserted step move — for 1→2, System (0), Class→Race (1) and
Attributes (2) keep their index and Skills onward shift by one; for 2→3,
everything up to Powers keeps its index and Details and Review shift by one.
A draft stopped on the old Class step resumes on Race, which is right — it had
not committed to an occupation in any way the new step could trust. The resume
*offer* reads the migrated index too, or it would name the wrong step in the
sentence asking you to resume.

The smoke test pins the list, the version and the mapping together, because each
is only correct with respect to the others.

---

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

**The pairing is the normal structure, not an extra.** A player picks a race and
then an occupation, and the wizard says so: the picker is labelled *normally
required* for a race that needs one and *optional for this race* otherwise,
rather than a flat "optional" for all. Both exceptions are real and both still
work - an O.C.C. alone is a human character and shows no race picker at all, and
a race that grants its own skills stands on its own.

**Which races need one is inferred, not declared.** `needsOccupation(cls)` is
true for an R.C.C. granting no related and no secondary skills: it offers the
player nothing to *choose*. Fixed skills deliberately do not count - a Chiang-Ku
has twenty-four of them and still nothing chosen, which is exactly the gap an
O.C.C. fills. Measured against the published classes, that marks the Demigod
(nothing at all) and the Chiang-Ku (body skills only), and leaves the Godling
(8 related, 5 secondary) and the Dragon Hatchling (6 related) alone.

Inferred rather than declared because the skill counts already say it and no
stored class needs editing - and it is only safe because **the answer is always
a warning and never a refusal.** A wrong guess costs a dismissible note. The
warning appears in the wizard beside the picker, and `validate-character.js`
raises `no_occupation` so it also reaches the save path and the
[character audit](#server-side-rule-enforcement), where it lands under *worth a
look* rather than *would be refused on save*.

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

### The fourteen Palladium player races

Until this import the catalog held **one** Palladium R.C.C. — the Chiang-Ku
Dragon — and four R.C.C.s in total. Every Palladium occupation that had been
imported was therefore an occupation with nothing underneath it: the wizard
picks a race first, and the only race a Palladium character could be was a
dragon. The fourteen races on printed 288-312 are what the rest of that book
assumes.

| race | printed | racial S.D.C. | psionics | O.C.C.s the page allows |
|---|---|---|---|---|
| Human | 288 | — | standard | any |
| Elf | 290 | +10 | standard | any |
| Dwarf | 292 | +15 | standard | any **except magic** |
| Gnome | 294 | — | **none** | magic, clergy or optional, plus ranger, mercenary, soldier, thief, assassin |
| Troglodyte | 295 | +10 | **none** | mercenary, soldier, thief, assassin, monk, vagabond |
| Kobold | 297 | +5 | standard | any except long bowman, knight, palladin |
| Goblin | 299 | +5 | standard | assassin, thief, mercenary, soldier, black priest, witch, vagabond, occasional psychic |
| Hob-Goblin | 300 | — | **none** | assassin, thief, mercenary, soldier, black priest, witch, vagabond |
| Orc | 302 | +10 | **none** | mercenary, soldier, assassin, thief, black priest, witch, vagabond |
| Ogre | 304 | +20 | **none** | any |
| Troll | 306 | +40 | **none** | any except psychic P.C.C.s and illusionist |
| Changeling | 308 | — | standard | any |
| Wolfen | 310 | +20 | standard | any |
| Coyle | 312 | +10 | standard | any |

**A race's S.D.C. is a pool BONUS, not `sdc_base`.** This is the one decision
the whole batch turns on. Ten of the fourteen pages state a number, and every
one of them states it the same way — *"10 plus those gained from O.C.C.s and
physical skills"* — and printed 18 says so outright: *"Some non-human races and
O.C.C.s also get special S.D.C. bonuses. All S.D.C. points/bonuses are
cumulative."*

Written as `sdc_base` it would have been silently wrong, because
`combineClasses` gives the **race's** pool precedence over the occupation's: a
Troll Knight would carry 40 S.D.C. instead of 40 + 3D6. Written as
`bonuses.pools.sdc` it is summed across both halves by `sumBonusGroups`, exactly
as the Stone Master's flat P.P.E. term is. The same reading covers the four
races whose page says *"only those gained from O.C.C.s and physical skills"* —
they state no bonus at all, and the occupation's roll stands alone.

Because no race states `sdc_base`, all fourteen need an entry in
`CORE_SDC_BY_CLASS`, and all fourteen are `1D6`. **A race is never a man of
arms** — the job decides that, and `withCorePools` looks the occupation up
first — so those entries fire only for a race played with no occupation at all,
where printed 18's third bucket, *"practitioners of magic, scholars and all
others"*, is the one that applies.

**Every one of the fourteen needs an occupation, and `needsOccupation()` says so
without being told.** It is true for an R.C.C. granting no related and no
secondary skills, and a Palladium race grants neither — those come from the
O.C.C. That was already the rule; the races are the first classes where it is
the normal case rather than the exception.

**Hit points are transcribed rather than defaulted.** Every race page prints
*"P.E. +1D6 per level of experience"*, which is identical to the core rule
`compose.js` would have supplied. It is written into the class anyway, because
the page states it and the class file records what the page says.

**Six races state `psionics_allowed: false`** — gnome, troglodyte, hob-goblin,
orc, ogre and troll — which is the first use of that key by any published class.
It skips the Random Psionics Table entirely. The hob-goblin is the case worth
reading twice: it can never *have* psychic powers **and** is +1 to save against
them, which is not a contradiction and is the clearest demonstration that the
two are different fields.

#### What a race states that the app cannot yet hold

Three things, all recorded as prose and all listed in the affected classes'
`extraction_notes`:

- **A race-level per-skill percentage bonus.** *"Add a bonus of +5% to the
  following skills (this is in addition to O.C.C. bonuses): general repair,
  masonry, carpentry, …"* modifies skills the **occupation** grants. `occ_skills`
  *grants* a skill; `skill_overrides` only restates one the class already grants;
  `skills.bonuses` is a catalog-row property shared by every class. None of the
  three expresses "+5% to it if you have it". Four races are affected — dwarf
  (eleven skills plus any Military skill), gnome (nine), kobold (three) and
  changeling (Disguise). **The ogre's is different and IS modelled**: its page
  *grants* Recognize Weapon Quality, Falconry and Animal Husbandry outright, so
  those are `occ_skills` at the catalog base plus the printed bonus.
- **A horror factor the creature projects.** Six races have one — ogre 10,
  changeling 10, Coyle 11, troll 12, Wolfen 12, troglodyte 13 when enraged.
  `saves.horror_factor` is the bonus for *resisting* one; there is no field for
  *having* one. Recorded in `natural_abilities`.
- **Racial percentile abilities.** Underground Tunneling, Underground
  Architecture, Underground Sense of Direction, Track Blood Scent and Recognize
  Scent of Others all behave exactly like skills — a base percentage rising per
  level — but they belong to no catalog category and are granted rather than
  chosen, so filing them as catalog skills would make them pickable by anyone as
  a secondary skill. They are `natural_abilities` with their numbers stated,
  which is the Chiang-Ku's precedent.

Two saves the races needed did **not** stay prose. `faerie_magic` and `disease`
became real keys, because a bonus written for a key `derive.js` does not expose
reaches nothing at all — see
[House rules and derived values](#house-rules-and-derived-values).

#### Deliberately not imported

**The Goblin Cobbler** (printed 302), an "Optional R.C.C." — a goblin is one on
a percentile roll of 1-15. It has metamorphosis at will, six faerie spells cast
twice per 24 hours at third-level strength, +1 to save vs all magic, +1 vs
possession, +3 vs horror factor, and +10% to three crafts. It is **not** a
`variants` entry: `VARIANT_OVERRIDES` admits `attribute_dice`,
`attribute_requirements`, the pool bases, `bonuses` and `skill_overrides`, and
the Cobbler's whole substance is a `magic` block and an abilities block. It
needs either a widened variant or a second class, and that is a decision rather
than a transcription. Recorded in the goblin's `extraction_notes` and GM notes.

**Demons, deevils and the other creatures of magic** (printed 313 onward) are
out of scope for this pass — they are monsters the GM runs, not races a player
picks, and they are a much larger body of stat blocks.

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
`hp_max` NULL. Fifty-three of seventy-six published classes state no hit point
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

## The sheet is tabbed on screen and whole on paper

The sheet ran 4105px on desktop and 6316px on a tablet - about six screens -
with 104 inputs in one column of scroll. It is now six tabs: **Vitals, Skills,
Powers, Gear, Bio, Notes**, each 1.1-2.2 tablet screens.

**Tabs are a screen affordance only.** There is no such thing as a hidden tab on
paper, so the print block dissolves the panels rather than revealing them
one at a time:

```css
@media print {
  .tabbar   { display: none !important; }
  .tabpanel { display: contents !important; }
}
```

`display: contents` removes the section wrappers from layout entirely, so every
grid inside them lays out exactly as it did before tabs existed. Revealing the
panels with `display: block` would have worked too and would have changed every
row's layout; this way the printed sheet is the one that was already tuned.

Two things fell out of measuring rather than guessing:

**The header was the real problem, not the length.** 467px of mostly-blank
background fields - race, true name, occupation, sex, family origin, insanity,
birth order, disposition - was the entire first tablet screen. Tabs alone did
not fix it: the sheet still opened showing no game data, and the tab bar sat
*below the fold*, so the tabs did not even announce themselves. The background
fields moved to their own tab; identity you check constantly stays pinned above
the bar. **This was invisible in the DOM metrics and obvious in the first
screenshot.**

**Powers and Equipment shared a two-column grid** and were the two largest
blocks, 1166px together. They are separate tabs now, so on paper they stack full
width - the one intentional change to printed layout, and it gives the
five-column equipment table room it never had at half width.

Switching tabs toggles classes rather than re-rendering: a re-render rebuilds
every input on the sheet, and the one thing a tab press must never cost a player
is a half-typed note. The active tab persists per character and reads from the
URL hash, so a link ending `#gear` opens on gear; a `hashchange` listener covers
the same-document case, where nothing reloads. `replaceState`, not `pushState` -
Back should leave the sheet for the character list, not walk tab history.

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
├── drift-check.mjs         Repo vs live database: migrations, data scripts,
│                           tables, columns, classes, and an advisory citation
│                           check against a cached book
├── catalog-match-lib.mjs   Matching a book's names to the catalog's. Exact
│                           first; a relaxed match only when unambiguous on
│                           BOTH sides. See below - do NOT merge this with
│                           catalog-merge.js
├── catalog-diff.mjs        That, behind a CLI: disagree / missing / matched /
│                           extra, plus the vocabulary warning
├── repo-vs-live.mjs        Can the repo rebuild the live catalog, row for row?
│                           Builds from scratch and diffs NAMES, not counts
├── ocr-book.py             OCR a scanned sourcebook into .cache/books/<slug>/
│                           at --psm 3, with geometry and a Palladium wordlist
├── ocr-fields-lib.mjs      Typed readers for the numbers OCR gets confidently
│                           wrong - `Ibs`, `18.000`, `LS.P.` See below
├── palladium-words.txt     That wordlist. Committed; the OCR output is not
├── read-columns.py         The text-layer twin of `ocr-book.py --psm 3`: read a
│                           multi-column page in READING order, from a PDF that
│                           HAS a text layer. Columns found by gap, not by an
│                           assumed count
├── parse-pf-spell-index.mjs        The Palladium Fantasy book's two spell
│                           authority tables, reconciled against each other
├── parse-pf-spell-descriptions.mjs Stat block and prose for named spells out of
│                           the same book's description pages
├── class-check.mjs         One class file, against the parser the app uses
├── class-check-lib.mjs     Its pure half, so the smoke test can call it
├── q.mjs                   One ad-hoc question to D1, from a shell. The
│                           alternative kept being a throwaway `node -e` that
│                           got the Windows quoting wrong a new way each time
└── sql-statements.mjs      Splitting SQL for wrangler, which truncates a
                            --command at the first newline
```

**The table is pinned by the smoke test.** `read-columns.py` and
`ocr-fields-lib.mjs` both lived here undocumented for several PRs - the first
arrived with the Knight import and is now the whole basis of every Palladium
Fantasy extraction. A file map that quietly stops being a map is worse than
none, so a check fails on a script this list does not name and on a name that
no longer exists.

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

## Twenty gear prices, and why the first fix missed them

`fix-rue-gear-prices.sql` corrects **sixteen costs**, records **three** ranges
that were right but undocumented, and prices one item that had none.

**Thirteen rows held the HIGH end of a printed range** - the same bug migration
032 exists for. They survived the first fix because
`backfill-gear-cost-notes.sql` was deliberately guarded on the stored cost
*already being the low end*: every row that had the high end was skipped **by
design**, and so stayed wrong. A guard that narrow protects the rows it
understands and quietly abandons the ones it does not.

| | catalog | book |
|---|---|---|
| `Sunglasses (fancy or light adjusting)` | 300 | **100**-300 |
| `Cross/Crucifix (silver; 8-12 inches)` | 400 | **200**-400 |
| `Gas Mask (larger than human)` | 120 | **80**-120 |
| `Machete with canvas sheath` | 100 | **40**-100 |
| … nine more | | |

**Two were simply wrong.** `Blanket (Heavy)` at 6 against the book's 20, and
`Blanket (Light)` at 4 against 10. No range, no note - transposed somewhere.

**One is a page-break error, and the worst kind.** `NG-101 Rail Gun` carried
**70,000**, which is the **NG-202's** price on the following line: the NG-101's
block starts on printed p270 and its `Black Market Cost` falls on p271. A row
straddling a page break usually loses a value; this one gained the neighbour's.

**Four price lines were invisible to the parser** because OCR read `cr.` as
`er.` - `Knapsack`, `Knife, Large`, `Machete`, `Mallet (small)`,
`Mechanical Pencil` and `Sunglasses or Goggles (cheap)`. Three of those were
wrong and three merely undocumented. Any pattern reading prices out of this
book has to accept `er` for `cr`.

### Three rows deliberately left alone

- `Hammer (tool)` carries 7 against the book's *"Hammer (average, metal):
  10-20 cr."* The catalog also holds `Small Hammer` at 10 and `Small Mallet` at
  2, and a price alone cannot say which row the book's entry is.
- `Canteen` carries 20, which looked wrong until the page showed **three**
  canteens priced separately - Aluminum 30, Plastic 20, 2 M.D.C. 2200. The
  catalog holds the plastic one and is right.
- `Spike` carries 3 against *"Spikes (6, iron): 6 cr."* - a pack of six, not one
  spike. Different granularity, not a different price.

## The OCR is confidently wrong, which is why tuning it does not help

The obvious response to bad OCR is a better scan. Measured over four pages whose
errors are known, it barely moves:

| setting | price-unit misreads | l/I confusions |
|---|---|---|
| 300 dpi (current) | 7 | 15 |
| 500 dpi | 6 | 12 |
| 600 dpi | 5 | 14 |
| `--oem 1` (LSTM only) | **no change at all** | |
| greyscale + unsharp mask | 7 | 12 |

The reason is in the confidence column. Tesseract reads **`Ibs` at 91-94** and
**`18.000` at 93-97**. It is not hesitating, and it has no reason to: `Ibs` and
`18.000` are perfectly plausible strings. Nothing tells an OCR engine that
Palladium does not price things in thousandths of a credit.

Only **1.3%** of words in the book score under 70, and **none of the known
misreads are among them** - so filtering on confidence finds nothing either.

**So the leverage is not in the scan. It is in knowing what a field is allowed
to be.** Two places now do:

`scripts/ocr-book.py` repairs the systematic confusions **once, at ingest**, and
only where context makes them unambiguous:

- `20-100 er.` is a price. All 14 occurrences follow a digit and no real word
  does - a bare `er`->`cr` would wreck "her" and "player".
- `18.000` is eighteen thousand. Guarded to **exactly three digits**, because
  this book writes measurements as `1.8 m` and `0.9 m` and never to three
  places - and prints `130.101 - 180,200` as one range using both separators.

Re-running it took **zero** occurrences of both, and left all 30 instances of
`0.9 m` intact.

`--renormalise` re-applies the table to the cached `.raw.txt` **without running
Tesseract again**: seconds instead of 25 minutes, so improving a rule is cheap.

`scripts/ocr-fields-lib.mjs` holds the typed readers - `money`, `weightLbs`,
`dice`, `isMegaDamage` - for what context cannot settle in bulk. They **refuse
rather than guess**: `dice('Varies with missile type')` is `null`, not zero,
because a damage field that cannot be read is a note. Twenty-two cases are
pinned in the smoke test, every string taken verbatim off a page.

## RUE cannot fill the gear stubs, and that is the answer

78 gear rows are class-import stubs. The obvious next step is to fill them from
the equipment chapter, and it does not work - not because the matching is hard,
but because **the names describe different things**.

RUE's general-equipment price list holds **48** real entries. Matched against
the stubs with the catalog matcher, **zero** pair up. (That measurement was taken
over 79; one has been retired since, and
[Known limitations](#known-limitations-and-refactor-candidates) has said 78 for
a while — this paragraph was the half that did not get updated.) The near misses show
why:

| stub | nearest priced entry |
|---|---|
| `Air Filter And Gas Mask` | `Air Filter (12, disposable)` **and** `Gas Mask (human-size)` - two entries |
| `Fishing Line And Hooks` | `Fishing Line, per 50 feet (15 m)` - hooks are not priced |
| `Medical Kit` | the book has a *Medical Equipment* section, not a kit |
| `Sack`, `Tweezers`, `Cord` | not priced anywhere in the book |

The stub names were invented by the class importer out of an O.C.C.'s equipment
prose - "a sack", "tweezers", "an air filter and gas mask". They are
descriptions of things a character carries, not entries in the book's
catalogue, and the book never prices most of them.

**So filling them is a judgement call per item, not an import.** Deciding that
`Air Filter And Gas Mask` costs 55 because two separate entries cost 5 and 50 is
a reasonable house rule and it is *not* what the book says. That distinction is
the whole reason `source_book` exists.

A search of the whole book for each stub name is in the session notes: 22 appear
somewhere in the equipment chapter, 42 appear only in O.C.C. equipment lists
elsewhere - **a mention, not a definition** - and the rest not at all.

## A gear price is often a range, not a number

RUE prices much of its common gear as a range, and the loss is not cosmetic:

```
Belt, Utility (military style):   3-5 cr.
Knife, Large (does 1D6 S.D.C.): 20-100 cr.
Knife, Small (does 1D4 S.D.C.): 15-75 cr.
```

`cost` held one integer and the rest was dropped at import. **The equipment
import then stored the HIGH end of every range it met** — 8 times out of 8 —
while every pre-existing catalog row sat at the LOW end. Because nothing
recorded that a choice had been made, the inconsistency was invisible: `Knife,
Small` came out dearer than `Knife, Large`, and three rows were nearly
"corrected" to prices RUE already agreed with at the other end of the range.

So `cost` holds the **low end** — the number the sheet does arithmetic with,
exactly as `spells.ppe` holds a variable cost's minimum and `ppe_note` carries
the schedule — and `cost_note` carries the range or qualifier verbatim.

The extraction prompt asks for both halves. It used to say *"if a cost is a
range or varies, omit cost and put the wording in description"*, and the model
did neither reliably; there was nowhere for a range to go, so it guessed a
number instead.

**A stored 75 that came from 15-75 is indistinguishable from a flat 75.** That
is the whole reason the column exists.

## A Military Occupational Specialty adds a skill package

RUE gives several classes an MOS: *"Select one of the following areas of
specialty. Gains all skills under that MOS."* The Coalition Technical Officer
offers seven, the Merc Soldier seven and the Robot Pilot two.

The last two were prose for a long time. Both shipped carrying a note saying an
MOS was *"a package choice the schema cannot express"* and that the skills
should be added *"by hand on the sheet"* — true when they were written, and
untrue from the moment `skills.mos` landed for the Technical Officer. The cost
of leaving it was not documentation: a Merc Soldier was **seven** skills short
of what the book gives every one of them and a Robot Pilot **eight**, including
Robot Combat: Basic and Robot Combat Elite, which are the entire point of that
class.

```yaml
skills:
  mos:
    choose: 1
    note: "Every skill under it is granted in addition to the O.C.C. skills."
    options:
      - id: "robotics"
        name: "Robotics MOS"
        skills:
          - { name: "Robot Electronics", base: 50, per_level: 5 }
          - { choose: 2, categories: ["Mechanical", "Electrical"], bonus: 10 }
```

**It is not a variant, and that distinction is the whole reason it exists.** A
variant **replaces** what the class says, and `VARIANT_OVERRIDES` excludes the
skills block on purpose — `skill_overrides` restating a percentage on a skill
the class already grants is a much smaller power than swapping a skill list. An
MOS **adds**: the Technical Officer's own page says the character gets its O.C.C.
skills *"plus the MOS skills chosen previously"*.

So `applyMos()` appends the chosen option's entries to `occ_skills` rather than
replacing them, and it runs on the **composed** class rather than on the
occupation slot — a character with no racial class carries their O.C.C. in the
`rcc` slot, so attaching it to `occ` worked for a D-Bee Technical Officer and
not for a human one. `combineClasses` carries `skills.mos` across the merge for
the same reason: it rebuilds `skills` wholesale, and without that a Technical
Officer taken alongside a racial class silently lost every specialty.

**An option's entries are the same shape as `occ_skills`** — fixed skills and
choice groups — so both go through `validateSkillEntries()`. Two validators for
one shape is the pair that drifts.

`characters.mos` stores which one, by id, parallel to `class_variant`. The
granted skills are already in `skills`, but which package produced them is not
recoverable from that, so the sheet could not show it and a re-derive could not
reproduce it.

**Unchosen is a warning, not a violation.** A class offering an MOS with none
picked is missing a whole skill package and nothing else would mention it; an id
no option carries means the class was edited under a saved character. Both are
reported where a human sees them, and neither blocks a save — the same reasoning
`no_occupation` uses.

### Two things that cost time here

**The parser wants list items indented deeper than their key.** Standard YAML
accepts either, and the minimal `parseYaml` in this repo returns `null` for the
same-indent form:

```yaml
skills:          # this parses to null
- { name: "X" }

skills:          # this parses
  - { name: "X" }
```

Every MOS option reported "grants no skills", which was true of what the parser
had produced.

**The Technical Officer's page had to be re-read in column order.** Tesseract's
own page segmentation spliced the two columns together and produced
`Medic MOS: computer, tool kit if applicable` — the left column's heading
running straight into the right column's equipment list. Read that way the class
has five specialties; read in column order it has **seven**. See
`.claude/skills/book-survey/reference/read-columns.py`.

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

#### A bonus here only reaches a character who took the ability

`applyAbilities` folds in the bonuses of abilities that were **chosen** — it
returns the class untouched when nothing was. So a `bonuses` block on an ability
no choice group offers is never granted automatically; it applies only if a
player picks it or a G.M. types the name in.

That makes it the wrong home for something *every* character of the class has.
The Stone Master's Marks of Heritage were written that way — +12 P.P.E. and +20
S.D.C. on a plain ability — and no Stone Master ever received either. It parsed
clean, it read as mechanical, and it did nothing. Bonuses every character gets
belong on the class's own `bonuses`, or on the **variant** when only some
characters qualify: the Marks are True Atlantean only, so that is where they
went.

The parser now warns on it, and no other shipped class trips the warning. It is
a warning rather than an error because a G.M. really can assign such an ability
by name, so the block is reachable — just never on its own.

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

**An ability may demand an occupation.** The Godling's Magic Powers grants
"all the abilities of a practitioner of magic - pick one: Ley Line Walker,
Shifter, Mystic or Warlock (or Necromancer if evil)". `occ_options` on the
ability definition names those practitioners as **class ids**; choosing the
ability turns the class step's occupation picker into a required choice
narrowed to that list, and the pick lands in `occ_class_id` - the existing
race+occupation composition carries everything from there, which also means
the occupation's related/secondary allowances replace the class's own (the
composition table's normal rule, stated in the picker). Ids not yet in the
catalog are listed disabled rather than hidden, so the day Shifter is
imported nothing needs editing. Dropping the ability releases the slot.
`abilityOccOptions()` in `parser.js` is the one shared reading; the
validator warns (`ability_occ`, never a violation) when a character holds
such an ability with no matching occupation. The second take of a repeatable
ability cannot compose a second occupation - one slot exists - so it stays
what `on_repeat` prose says it is, a G.M. matter.

**Each class states its own list**, even when the book prints one list and
points several classes at it. A mechanism that resolved one class's options out
of another (`from_class`, PR #80) existed briefly and was removed: its only
intended user was the Demigod, and pointing it at the Godling made one class's
powers depend on another's lifecycle — a printing convenience mistaken for a
relationship. Recoverable from git if a genuinely shared list ever appears.

`applyAbilities` runs inside [`js/compose.js`](js/compose.js) as step 3 of 4 —
after race and occupation are one, because an ability is chosen for the
character rather than contributed by either half, and before any rolled psionic
tier, so an ability that makes you a master psychic is what a rolled tier has to
beat. What the character holds is on `abilities_taken`, as opposed to
`special_abilities`, which is what the class *offers*.

## What a class grants mechanically

`natural_abilities` and `level_progression.grants` are the book's own wording,
and display-only: the sheet lists natural abilities beside the chosen powers,
and the wizard's class detail shows them to a player still deciding. (`special_abilities` used to belong on that list too; since
[Powers the player chooses](#powers-the-player-chooses), a named ability may
carry `bonuses` of its own, validated through the same path a class's are.) So a Dragon's *"+2 to P.S."* and *"+1
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
Those are rolled once when the class is confirmed and stored — attribute dice
in `attribute_bonuses`, combat and save dice in `rolled_bonuses` — see
[House rules and derived values](#house-rules-and-derived-values).
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

**A mundane row that both worlds have is `both`, and the classes are what find
them.** Clothing, gloves, a uniform, field rations, a riding horse, a hatchet
and a skinning knife were all in the catalog tagged `rifts`, because a Rifts
book was imported first — and the sheet loads its catalog as
`items?system=<campaign>`, which returns NULL, that system, or `both`. So the
Knight, who is granted clothing, gloves and a riding horse, held three items
whose names its own sheet could not resolve.
[`db/fix-pf-armor-and-cross-system-gear.sql`](db/fix-pf-armor-and-cross-system-gear.sql)
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

## Two tabs cannot overwrite each other

There is one draft per person, so every `PUT /draft` is a replace. That is fine
until something else is building at the same time — a second tab, or a script
driving the wizard — at which point the last write silently won and the other
build was gone with no error anywhere.

So a PUT says which version it believes it is replacing:

```json
{ "expect_updated_at": "2026-08-20 09:55:43", "step": 3, "state": {} }
```

| The caller claims | The row is | Result |
|---|---|---|
| `null` ("I expect no draft") | absent | created |
| `null` | present | **409** |
| a timestamp | that timestamp | replaced |
| a timestamp | anything else | **409** |

Each branch is a **single guarded statement** — `INSERT … ON CONFLICT DO NOTHING`
or `UPDATE … WHERE updated_at = ?`. Reading the row and then writing it would
leave exactly the gap this exists to close.

The 409 body carries `current`, so a client can say what took the draft over
rather than only that something failed. The wizard tracks the version it holds,
carries it forward from each save's response, and on a conflict **stops
autosaving** and says so in the stepper. Stopping matters: retrying would either
fail forever or, once it re-read, clobber the other build after all. Work already
on screen is untouched — you can finish and save it, or reload to take theirs.

Deleting a draft clears the tracked version, so the next build creates rather
than claiming a row that no longer exists.

---

## Unfinished builds are saved

The wizard is ten steps and step 3 **rolls**. A refresh, a stray back-gesture
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

**Where a tier comes from:** the class (`psionics.type`), an ability the player
chose (folded into that same slot before any roll), or the character
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

**Elemental spells are named with their sphere.** `Air: Cloud of Steam`,
`Fire: Fire Bolt`, `Earth: Wall of Stone`. That prefix is load-bearing,
not decoration: `spells.name` is UNIQUE and the four elemental lists collide
both with the Invocation rows already in the catalog (Blinding Flash, Globe
of Daylight, Fire Bolt and Darkness are all both) **and with each other** —
Cloud of Steam is an Air 1st at 4 P.P.E., a Fire 4th at 10, and a Water 1st
at 10. A dozen more repeat across spheres at different levels and costs. The
prefix also gives the Warlock a workflow the schema cannot: the spell picker
filters by name substring, so typing `Fire:` narrows it to that Warlock's
own sphere. Water prints Calm Waters twice, so its 8th level version is
stored as `Water: Calm Waters (greater)`.

**A class may name the exact powers its picks come from.** `psionics.powers_from`
is a list of power names, and the Burster is why: its entry prints seventeen
named minor powers and says "select three". A named list is **more specific
than a category gate, so it replaces it** — exactly as a skill choice-group's
`from` list does, rather than narrowing within the categories. A name the
catalog does not carry is **reported** under the picker rather than silently
shrinking the list, the same reasoning the skill cross-reference uses. The tier
gate still applies on top, so a book that names a power above the character's
tier still says so.

**Powers a class grants outright now reach the character.** `psionics.powers`
and `magic.spells` name what the class simply knows — the Mind Melter's four
automatic powers, the Shifter's twenty spells. The wizard used to save only
what the player *picked*, so those were listed by the class and held by
nobody. They are now written into the character ahead of the picks, and a pick
that duplicates one is dropped so the list stays a set.

**Save vs psionic attack** has a target as well as a bonus, and the books give
**three** of them, not two: a non-psychic needs 15+, a minor **or** major psychic
12+, and a Master Psionic only 10+ (Palladium Fantasy printed 48; Rifts Ultimate
Edition p.65, p.142 and p.185 agree). Non-psychics are on the list because they
get attacked by psionics too and still need a number to roll against.
`deriveSaves()` originally returned only the M.E. bonus and no target at all, and
the first target it grew read `meetsTier(tier, 'major') ? 12 : 15` — one of the
three right, a minor psychic handed the non-psychic's number and a master handed
the major's. `PSIONIC_SAVE_BY_TIER` is keyed by tier rather than compared through
a threshold, because minor and major share a number and master breaks away from
both, which no single threshold expresses. It is overridable like every other
derived value.

---

## A blocked step says why

Four wizard steps gate their primary button: **Race** (a variant or a power
still to choose), **Attributes** (a value missing, a class minimum unmet, or
point-buy overspent), **Occupation** (an ability that names practitioners with
none chosen) and **Equipment** (an unresolved gear choice).

Each renders the reason as a `.nav-why` span **between Back and the primary
button**, and the race step also scrolls the outstanding picker into view. The
reason and the disabled state come from ONE function per step — `classBlock()`
and its equivalents — so they cannot disagree.

**A missed attribute minimum is deliberately NOT one of them.** It warns and
offers a re-roll on the Occupation step; see
[The race is chosen first](#the-race-is-chosen-first). A greyed button with no reason,
or a reason beside a live button, are each worse than either alone.

This exists because a disabled button was the entire explanation. Picking a Ley
Line Walker greyed the primary action with no visible cause, and the requirement
(choose a power) rendered below the fold. Reported as "nothing happens".

**Adding a fourth gated step means adding its reason too.** The pattern is one
function returning the sentence, the button deriving `disabled` from it, and
`.nav-why` in the nav row — which is also the only ordering that wraps onto its
own line under 620px.

Separately, `shared/styles.css` dims any `:disabled` button to 0.45 and sets
`cursor: not-allowed`. Nothing styled that before, so a button you could not
press was pixel-identical to one you could, in all three workshop apps.

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

## Anyone at the table can write the log

`journal_entries` existed and was reachable only from a character sheet, and
only the G.M. could write a campaign-level entry. There was no campaign-level
place to read the log, no search over it, and nothing tracking what the party
held together.

[`campaign.html`](campaign.html) is the campaign's own page: the note feed with
a composer, the search box with an **Ask** button beside it, the party stash and
the currency ledger.

### Membership is not a table

A person may read and write a campaign's notes if they are its **G.M.** or they
**own a character assigned to it**. That is a query, not a schema:

```sql
SELECT 1 FROM characters WHERE campaign_id = ? AND player_email = ? LIMIT 1
```

There is no `campaign_members` table, deliberately. Owning a character in a
campaign is what being a player *is*, so an invite list would be a second and
weaker statement of the same fact, kept in sync by hand. Rejected alongside it:
a join code, which lets anyone with site access into any campaign they have the
code for.

The cost is real and accepted: **a spectator, or a player between characters,
cannot post.** When that bites, an invite list can be added inside
`campaignAccess()` and nothing else has to learn about it — that function is the
only thing that knows the rule, which is what makes the decision reversible.

**Joining is creating a character, and the GM holds the door.** Because
membership is "owns a character here", an ungated `POST /characters` was an
ungated door onto the campaign's notes, stash and ledger — anyone on the site
could pull up a chair (the audit's F1). `campaigns.open` (migration 037)
defaults to that open table for every campaign that exists; a GM who unticks
**Open to new characters** on the dashboard closes it, and the create endpoint
then refuses anyone who is not the GM or already a member. Who counts as a
member stays `campaignAccess()`'s question. The wizard's campaign picker shows
a closed campaign **disabled with the reason**, the barred-occupation pattern —
a player looking for their table should learn it is closed, not that it does
not exist — and the server refuses regardless, because a disabled `<option>` is
a hint and not a rule.

Three permissions, not one:

| | who |
|---|---|
| read and write notes, stash, ledger | any **member** (`canWrite`) |
| edit or delete one entry | its **author**, or the G.M. |
| `gm_notes` on the campaign | the **G.M.** alone (`isGm`) |

Everyone in a campaign writing notes is one thing; any of them rewriting each
other's account of a session is another, so the G.M. keeps the moderator's key
because somebody has to have it.

**Widening `canWrite` widened something else.** `campaigns/[id]`'s PATCH checked
`canWrite` back when that meant "the G.M.", so the moment membership widened it,
every player could edit the campaign's `gm_notes` — the one pre-existing secret
in an app that had just decided it has none. That endpoint checks `isGm` now.
Anything else that reaches for `canWrite` should be read the same way: it is a
different question than it used to be.

**Reads are member-gated here, which is narrower than the rest of the app**,
where any authenticated friend may read a character sheet. A sheet being
readable and a table's session notes being readable are different things.

**There are no G.M.-only notes and no hidden fields**, decided explicitly rather
than by omission: a G.M. keeping secrets keeps them outside the app. That is
load-bearing — it means the search index and the ask endpoint need no visibility
filtering at all beyond "is this person in this campaign". Adding secrets later
means auditing every one of those paths, so it is worth re-opening deliberately
rather than drifting into.

### Search is free, asking costs a call

Two mechanisms, one box. Typing searches; a button asks.

- **Search** is SQLite **FTS5** over titles and bodies — instant, free, runs
  debounced as you type, and returns a highlighted snippet so a result says
  *why* it matched.
- **Ask** sends the best-ranked entries to Claude and returns a written answer
  **citing the entries it used**, resolved from `[#id]` back to rows the page
  links to. One deliberate press, one model call.

Rejected: keyword-only, which cannot answer *"what did the baron want from
us?"* — the actual question people ask; and routing every query through the
model, which is slow and paid for what `LIKE` would have answered.

Three things this got wrong first:

- **A human's query is not an FTS5 query.** `the baron's men` is a syntax error,
  not a search: FTS5 reads the apostrophe as syntax. Every run of word
  characters becomes one quoted term instead, which is both what a person means
  and injection-proof. The last term gets a trailing `*`, so results narrow
  while the word is still being typed.
- **`snippet()` returns markup, and the text around a match is a note somebody
  typed.** Asking for `<mark>` means building HTML out of user input; escaping
  it client-side escapes the marks with it. So the delimiters are U+0001 and
  U+0002 — two characters no keyboard produces — and the client escapes first
  and swaps them for tags after.
- **A question is not a search, and AND-ing it retrieves nothing.** The search
  box wants every word to appear, because that is how a list narrows as you
  type. An ask does not: *"what did the baron's men want, and do we still have
  the rune sword?"* with every term required matches no entry ever written. The
  endpoint retrieved nothing, handed the model an empty context, and got back a
  perfectly correct *"the notes do not record it"* — **a failure that looks
  exactly like the feature working.** `toMatchQuery` takes `{ join: 'OR' }` for
  the ask path and lets `bm25` do the ranking.
- **A question with no searchable words retrieves nothing either.** *"What
  happened last time?"* matches on no keyword and is exactly what people ask, so
  a question that yields no terms falls back to the most recent entries.

**What Ask may read:** the campaign's notes, the party stash and the currency
ledger — *"do we still have the rune sword"* and *"how much have we spent"* are
the same kind of question living in different tables. **Not** the party's
character sheets, decided explicitly: sheet questions are answered by looking at
the sheet, and five full characters would dominate the prompt.

Retrieval is the same FTS5 index the search box uses. A campaign's notes are a
small corpus and ranked keyword matching is adequate context for it; embeddings
would add a store, a backfill and a re-embed-on-edit path for a retrieval
problem that is not yet hard.

The system prompt states that the notes are **data, not instructions** — they
are written by other people, and an entry recording that *"the merchant told us
to ignore our previous orders"* is a thing a character said.

### The stash is an inventory the party owns

`campaign_items` is `character_items`' shape with a `campaign_id`: real gear
catalog rows, freeform items allowed, tied to the journal entry that explains
the acquisition, and **soft-deleted** — *what did we used to have* is a question
a party asks and a `DELETE` cannot answer.

**Claiming an item onto a sheet is one batch.** The two halves are the same fact
stated twice: an item that left the stash without arriving on a sheet is
destroyed, and one that arrived without leaving has been duplicated. Neither is
visible in the result, which is what makes it worth a batch rather than two
awaits. Only the character's owner or the G.M. may claim for it — otherwise a
member could push party loot onto someone else's sheet, which is a table
argument the app should not be able to start.

Rejected: a stash with no transfers (two places to edit for one object, and they
drift within a session), and a free-form shared text block (no history when
someone deletes a line, which is exactly when history matters).

**Currency is a ledger, not a number.** The balance is `SUM(delta)`, so no
stored total can disagree with its own history. Entries are appended and never
updated; a mistake is corrected by an opposing entry that says so. A zero delta
is refused — an entry that changes nothing is either a mistake or a note, and
there is a notes feature for the second one. Currency names are lower-cased on
the way in, because `Credits` and `credits ` are the same pile of money and two
balances for one currency is the failure a ledger exists to prevent.

**Deleting a note is a hard delete**, unlike the stash's soft one. A note is
somebody's writing and *unsend* should mean it; keeping a tombstone of what a
player asked to remove is the opposite of what they asked for. The FTS index
follows via its trigger, and `campaign_items.journal_entry_id` is
`ON DELETE SET NULL`, so an item keeps its place and simply stops pointing at an
explanation that no longer exists.

---

## Who the campaign has met

The people a campaign meets lived in prose scattered across entries. Three
sessions later nobody could say who the merchant in Kingsdale was, whether he
was still alive, or what the party promised him.

A dossier is **campaign-scoped** and structured: name, aliases, faction,
disposition toward the party, status, a description, a portrait, and an
auto-maintained list of every entry that mentions them. Structured because the
fields are what make the roster filterable and what let the
[ask endpoint](#search-is-free-asking-costs-a-call) answer *"who is Kevik and
can we trust him?"* without re-reading prose.

Rejected: **global NPCs shared across campaigns** — right only if the campaigns
share a world, and it leaks what one table knows into another's dossier; and a
**single free-form prose block**, which is less to build and leaves nothing to
sort or filter by.

### Two ways in, and only one of them guesses

**`@Name` in a note is the primary path** — deterministic, free, instant, and
under the writer's control. It creates a dossier on first mention rather than
offering to: the writer already committed by typing the `@`, and a confirmation
step there means the note posts with a dangling reference while somebody
decides. A dossier made this way holds only a name, which is exactly what is
known about it.

What the pattern does and does not match is the whole contract:

| | |
|---|---|
| `@Kevik` | one person |
| `@Lord Coake` | one person — stopping at the space would link to a Lord nobody has met |
| `@Lord Coake And Then` | still `Lord Coake`; three words starts swallowing sentences |
| `@Kevik,` `@Kevik.` | the same person as `@Kevik` |
| `@Kevik` `@kevik` `@KEVIK` | one person, one dossier |
| `@guard` | nothing — a description is not a name |
| `email me @ the place` | nothing |

`UNIQUE (campaign_id, name COLLATE NOCASE)` is what makes that resolve to a
person rather than three near-identical rows nobody merges. Mentions are stored
as **plain `@Name` text in the body, not as ids**, so the note stays readable
text that survives a rename and reads correctly in a plain-text export;
resolution happens against the name index at write time.

**Editing a note reconciles its mentions.** A body edited to remove a name stops
listing that entry under that NPC — a mention list that only ever grows is one
that lies about the current text. Only the mentions a *person* typed are
reconciled; a link the sweep made is the model's reading of an entry that never
contained an `@`, and rewriting the body must not silently delete it.

**The sweep is the safety net, not the mechanism.** A button reads the entries
nobody has swept and proposes the named people nobody tagged. **A proposal is
not a dossier**: accepting one is a second, explicit click. Rejected: an
automatic scan on every save, which costs a model call per note and will
confidently turn *"the guard"* into a person until somebody stops it; and
mention-only, which captures nothing when the table forgets, which is every
table.

Four rules the sweep earns its keep by:

- **A dismissed name stays dismissed.** Without `npc_proposals_dismissed` the
  next sweep proposes *the guard* again, and the one after that, and the button
  becomes noise. Verified: a name dismissed once was not re-proposed even when a
  brand-new note named it again.
- **Entries are marked swept only after a successful response.** One marked by a
  call that never returned is one nobody will ever look at again.
- **Ids come back through a model and then a client**, so they are filtered
  against what was actually sent and re-checked against the campaign on accept.
  A mention pointing at another table's note would leak that note into a dossier.
- **A link the model made is marked `source: 'ai'`**, and the dossier says so.
  Same instinct as `override: true` on an out-of-category skill pick: a decision
  made by software should be visible as one.

### Portraits, and the site's first bucket

`wrangler.jsonc` binds R2 as **`MEDIA`**, named for the site rather than for the
app that needed it first — MediaVault stores cover art as text today and
filament-forge already reads file bytes, so the second and third users exist.

Rejected: **base64 data URIs in D1** (rows cap near 1MB, the database is shared
with every other app on the site, and "thumbnails only" is a rule nobody
remembers in six months); and **external URLs** (nothing behind the Access wall,
and the image breaks when the host does).

**Nothing is ever served from a public bucket URL.** The whole site sits behind
Access and an unauthenticated image endpoint would be the one hole in it, so
every read goes through a Function that checks membership first — a campaign's
portraits are as private as its notes.

Four things that are not obvious:

- **The type is an allowlist**, because it decides what is stored *and* what the
  GET hands a browser later. Anything not on the list is something the response
  would be serving without knowing what it is.
- **The row is written before the old object is deleted.** The other order can
  leave a dossier pointing at an object that no longer exists; this one can at
  worst orphan an object nobody points at, which costs storage rather than a
  broken portrait.
- **The key carries a uuid**, so every upload is a new key and the response can
  be cached hard — `private, max-age=31536000, immutable`. Private because this
  is behind Access and must not sit in a shared cache.
- **But the URL is stable**, so an immutable cache would show the first portrait
  forever. The page busts it with the **object key**. `updated_at` was the
  obvious choice and is wrong twice: it contains a space, which does not belong
  in a URL unencoded, and it changes when somebody edits the faction field —
  re-fetching an image that did not change.

---

## Play mode

The sheet through an **action-first lens**, shaped for a phone or tablet at
the table: `sheet.html?play=1`, toggled by the header button. Same page, same
data, same endpoints — `render()` branches to `renderPlay()` and nothing else
changes, which is the whole design: a separate play page would duplicate the
sheet's load/compose/derive/permissions plumbing for a different layout.

What it offers (phase 1 of four):

- **Pool cards** with big current/max numbers and quick +/− at a selectable
  amount, plus a **Damage** button applying the book's flow: M.D.C. beings
  take it on M.D.C., everyone else runs S.D.C. down first with the remainder
  reaching H.P. Nothing clamps — negative H.P. is a real state (coma), and a
  G.M. may allow over-maximum. Armour is deliberately not in the cascade:
  which armour absorbed a hit is a table decision.
- **Every derived number is a tappable roll.** Skills roll d100 against the
  percentage; saves and combat bonuses roll d20 + bonus, against a target
  where one is derived (the psionic save) and bonus-only where the book
  leaves the target to the G.M. Rolls are **advisory** — the app shows the
  die, the table decides what it means — and play mode enforces no rule the
  sheet lens leaves to a human.
- **Powers** keep their ⚡ spend buttons; in play mode the deduction updates
  in place rather than refetching the sheet.
- **Weapon cards** (phase 2): an equipped catalog weapon becomes an attack
  card — strike roll, damage roll off the **leading dice** of the gear row's
  damage string (the full string is displayed; "1D6 (small), 2D6 (large)" rolls
  the 1D6 and the table adjudicates the rest), and an ammo counter when the
  payload states a capacity. Ammo lives in the inventory row's **notes** as
  `ammo 7/10` — visible on the sheet lens, editable by hand, no schema
  change. Unequipped weapons are listed, not carded; equipping is the sheet
  lens's job. The dice evaluator reaches this classic-script page the same way
  language-skills does: `js/dice.js` installs a `globalThis.diceRoll` mirror
  via a module tag.
- The last result sits in a **fixed thumb-zone bar**; every roll is kept as a
  structured object in `C.rollLog` (capped at 50), the exact shape a future
  `play_events` row will take.

Writes ride the existing PATCH optimistically, with revert-and-alert on
failure. Read-only visitors can still roll — rolls write nothing.

**The event log (phase 3).** Every state-changing play action goes through
`characters/[id]/events`, which applies the change and records it in one
batch; rolls persist as pure records (read-only visitors' rolls stay local).
Events are **commentary, not a ledger** — the character row stays the source
of truth, and nothing replays events to derive state, because replaying is
how a log inherits every consistency bug forever. What the log buys:

- **↶ Undo** reverses the latest not-undone event that carries changes —
  "take back the last thing", deliberately never a history editor, because
  undoing an older event under newer ones is ambiguous arithmetic. The
  undone row stays, marked, as part of what happened.
- **✎ End session** summarises events since the last recap marker — damage
  taken, powers by name, shots, rolls with pass/fail counts — and posts it
  to the journal as a plain-text entry a human can edit, then drops the
  next marker.
- A **who-did-what trail** (`actor_email`) for the sheet a G.M. and a
  player share mid-session.

**The melee counter and rest (phase 4).** The round/attack counter reads the
derived attacks-per-melee and is deliberately client-only ephemera — a round
in progress is not character data. **Rest** applies rate × hours per pool as
one undoable event, clamped at each pool's max. The rates are **the
table's own**, typed in and remembered per character on the device: the
books' recovery pages are not yet in the rules audit, and this app does not
ship an uncited number for a table to silently trust. When those pages are
audited, cited defaults belong in `js/rules.js`.

Deliberately out of scope at any phase: party-wide initiative (the
dashboard's altitude) and automated combat resolution (the hand-to-hand
tables are not modelled, and the README already says so).

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

**Chosen abilities get the same boundary.** The pick count (`ability_count`) and
repeatability (`ability_repeat`) are violations — a five-power Godling or a
doubled non-repeatable power has no legitimate path — while a power the class
no longer offers only warns (`ability_unknown`), because a class edit is not the
player's fault. A `{ name, gm: true }` entry is the abilities' `override: true`:
a power the G.M. assigned by hand (the Demigod's *"most have ONE extra power,
similar to that of the godly father or mother"*), exempt from the count and the
offered list, counted only for repeats — holding a power twice is holding it
twice, whoever granted the second. It still grants its bonuses through
`applyAbilities`, which tags it `gm` for the sheet.

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

#### D1 binds 100 parameters per statement

Measured against the real binding rather than assumed:

```
binds  100  ok
binds  101  FAIL: D1_ERROR: too many SQL variables at offset 221
```

Any query building `IN (?,?,...)` from a list that grows with user data has a
hard ceiling. Four files already carried a private `LOOKUP_BATCH = 50` for this
reason; the ones that did not are where it broke.
[`_lib/sql-chunk.js`](../../functions/api/character-creator/_lib/sql-chunk.js)
now holds the constant and the helper in one place, and the smoke test fails any
of those six files that stops using it.

**The worst instance ran after the write, not before it.** `markConfirmed`
builds `WHERE id IN (?,?,...)` from every pending row in a session, and it runs
*after* `applyDecisions` has already committed the catalog inserts. Confirming
108 spells therefore:

1. inserted all 108 — the write itself was fine, each `INSERT` binds about 14
2. threw on the bookkeeping statement, 313 ids in one `IN`
3. returned a **500 that read as total failure**
4. left every row still pending, so the next confirm tried to insert all 108
   again and reported them as `A row with that name already exists`

The write and the bookkeeping disagreed, and the bookkeeping is what the next
run reads. `applyDecisions` says *"All-or-nothing: nothing was written"* in its
error path — true of the batch it guards, and not true of the endpoint the
caller is actually talking to.

It was found only because the half-written rows carried a `NULL system` that the
data script being generated alongside them never produces. Had both paths agreed
on that column, the partial write would have been invisible.

The regression test seeds 150 staged rows and confirms them through the real
endpoint. Under the unchunked code, the telling check is the one that **passes**
— `the catalog really grew by 150` — beside four that fail.

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

**Apply that one on its own, not through a glob.** It is the only data script
that is not re-runnable — its inserts are unguarded and a second pass fails on
`gear.slug` — and `d1-apply.mjs` stops at the first failure, so
`--local apps/character-creator/db/*.sql` against an already-seeded database
dies on `seed-dev.sql` and never reaches `untag-cross-system.sql`, the only file
that sorts after it. Under `--remote` the question does not arise: the file's
`-- local-only` marker makes the glob skip it.

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

**Apply migrations and data scripts through `scripts/d1-apply.mjs`** rather
than raw wrangler commands:

```bash
node scripts/d1-apply.mjs --remote db/migrations/021-spell-ppe-note.sql apps/character-creator/db/backfill-spell-ppe-notes.sql
```

It encodes what the raw commands kept re-learning: the target is explicit
(no default database, because an accidental `--remote` is the costly
direction); every file is pre-checked for CR and non-ASCII bytes before
anything runs (both have changed production bytes before); files apply in
the order given and the run stops at the first failure, so a migration
always lands before the backfill that needs it; each file's trailing
verification SELECTs are printed; and remote runs start with a throwaway
`wrangler whoami`, which absorbs the expired-OAuth-token failure
(`Authentication error [code: 10000]`) that an interactive login hits on
its first call after idle. A `CLOUDFLARE_API_TOKEN` environment variable
(scoped to Account -> D1 -> Edit) removes that failure mode entirely and is
the recommended setup; the warm-up is then redundant but harmless.

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
| `020-psionic-isp-note.sql` | `isp_note` on `psionic_powers` — the cost schedule when a power's I.S.P. is not one number; `isp` keeps the minimum the use button deducts |
| `021-spell-ppe-note.sql` | `ppe_note` on `spells` — the same variable-cost shape as 020, for spells; `ppe` keeps the minimum the use button deducts |
| `022-play-events.sql` | `play_events` — play mode's append-only action log: undo, the who-did-what trail, and the session recap boundary |
| `023-skill-bonuses.sql` | `skills.bonuses` — what a skill grants beyond its percentage, in a class's `bonuses:` shape. Boxing is +1 attack per melee and +2 P.S. |
| `024-data-script-runs.sql` | `data_script_runs` — which data scripts have run against this database. The same question `schema_migrations` answers for migrations, for the 55 scripts that answer it nowhere |
| `030-power-pick-slots.sql` | `pending_power_picks.slot`, `.from_names` and `.note` — several grants can share a level with different restrictions. The Shifter gains two spells from a named list and one of any kind at every level; `slot` tells them apart, and `note` carries a restriction the catalog cannot check |
| `031-character-mos.sql` | `characters.mos` — which Military Occupational Specialty a character took. RUE gives several classes an MOS ("select one area of specialty, gain all skills under that MOS"); the skills land in `skills` like any other, but which specialty was chosen has to be remembered rather than inferred back out of the skill list |
| `032-gear-cost-note.sql` | `gear.cost_note` — what a price will not fit in one integer. RUE prices much of its common gear as a **range** (`Belt, Utility: 3-5 cr.`) and sometimes qualifies it instead (`double for gold`). `cost` holds the range’s LOW end, the way `spells.ppe` holds a variable cost’s minimum, and `cost_note` carries the wording verbatim |
| `033-variant-note.sql` | `spells.variant_note` and `psionic_powers.variant_note` — what an OLDER book prints instead. Not `ppe_note`: the wizard treats the mere presence of that column as "this cost varies" and renders `7+ P.P.E.`, so a cross-book note there would make fourteen fixed-cost spells look variable |
| `037-campaign-open.sql` | `open` on `campaigns` — the join gate. Joining a campaign IS creating a character in it (membership is "owns a character here"), so an ungated create was an ungated door onto the campaign's notes, stash and ledger. 1, the default every existing campaign keeps, is the open table; 0 admits only the GM and existing members. Enforced by `POST /characters`, toggled on the GM dashboard |
| `036-enchantments-charm.sql` | `enchantments.applies_to` gains **charm** — a third family, and the book draws it the same way as the other two: *"The following magic effects can be **placed in** rings, bracelets, charms, and medallions"*, three powers to an item. Thirty of them, printed 253. SQLite cannot alter a `CHECK`, so the table is rebuilt and the rows copied by named column |
| `035-enchantments.sql` | `enchantments`, and `character_items.enchantments` — what an alchemist puts INTO a sword, as opposed to a sword. Printed 249-250 sells three finished suits and then **32 properties** that go into ordinary gear, four to a suit and three to a weapon, cumulatively. The JSON array is on the **instance**: one long sword in a party of four can be the Demon Slayer while the other three stay ordinary |
| `034-gear-sdc.sql` | `gear.sdc` — Structural Damage Capacity, which the book calls one of the **two** attributes of armour alongside A.R. (printed 270). The rules spend it: damage subtracts from it, at half S.D.C. the A.R. drops two points, at zero the armour is gone. All six Palladium suits kept it in free-text `description`, where no sheet and no arithmetic can reach it. Never the `1D6 S.D.C.` a knife *deals*, which is `damage` |
| `029-power-pick-categories.sql` | `pending_power_picks.categories` — a banked PSIONIC grant's own category list. The Mystic gains a **Super** power at levels 4 and 8, a category a major psychic cannot otherwise take, so the restriction belongs to the grant rather than to the class |
| `028-pending-power-picks.sql` | `pending_power_picks` — the spells and psionic powers a level-up granted and nobody chose. `pending_skill_picks` with a different subject; `spell_levels` carries the cap the granting level came with, because that cap belongs to the grant rather than to the character |
| `027-npc-dossiers.sql` | `npcs`, `npc_mentions`, `npc_sweeps` and `npc_proposals_dismissed`. **The first migration whose feature also needs a bucket** — R2 `MEDIA` must exist before the deploy that binds it |
| `026-campaign-notes.sql` | `journal_fts` and its three triggers, plus `campaign_items` and `campaign_currency`. The FTS table is external-content, so the triggers are not optional — without them the index silently stops matching anything written after the migration ran |
| `025-skill-level-bonuses.sql` | `skills.level_bonuses` — what a skill grants **at each level**, summed up to the character's. The Hand to Hand tables are level-by-level and accumulative, which the flat `bonuses` column cannot express; entries may carry `applies_when` for a W.P. bonus that needs that weapon in hand |

### One database, and the case for keeping it that way

Every app in the monorepo shares one D1, `nates-workshop-media`, bound as `DB`.
That reads like a thing to fix, so here are the numbers it should be judged
against — read off production, not estimated.

| | |
|---|---|
| database size | **2.65 MB** of D1's 10 GB — 0.03% |
| tables | 31 |
| rows, everything | **4,420** |
| of which `media_items` (MediaVault) | 2,082 |
| the five catalogs together | 1,901 |
| characters, live | **8** |
| the largest table this app owns | `gear`, 844 rows |

**The two halves already have zero overlap.** `functions/api/media.js` is the only
D1 consumer outside `functions/api/character-creator/`, it touches exactly one
table, and nothing under `character-creator/` reads it. There is no join to
break. Of 33 migrations, **one** mentions `media_items` — `004-items-to-gear.sql`,
and only because renaming `items` to `gear` had to stay clear of it.

**So a split is possible and is not worth it.** The single risk it removes is one
app's migration disturbing another, which has never happened and has one file of
surface area. What it costs is concrete and recurring: a second binding, a second
entry in `wrangler.jsonc`, and a second target for every one of `d1-apply.mjs`,
`drift-check.mjs`, `repo-vs-live.mjs`, `q.mjs` and the regression harness — five
tools that each take one database name today. `schema_migrations` and
`data_script_runs` would have to be split or duplicated, and the smoke test's
migration-state checks with them.

**What would change the answer**, so this is a decision rather than a habit:

- a second app growing real tables — `media_items` is one table with one index
  and no migrations of its own;
- either half approaching a size where the 10 GB limit or a row-scan matters,
  which at 2.65 MB is three orders of magnitude away;
- any need to give one app a different retention, backup or access posture from
  the other.

**Nothing is unindexed that matters, and adding indexes would be cargo cult.**
The five catalogs are read *whole* by `/catalogs` and `/items` — that is
deliberate, see [Catalog lists are deliberately
unbounded](#known-limitations-and-refactor-candidates) — so a full scan is the
query plan, and 844 rows is the largest scan in the app. Every hot filter that
is not a full read is already covered: `characters` by campaign and by player,
`character_items` by character, `journal_entries` by campaign and by character,
`play_events` and both pending-pick tables by character, `npcs` by campaign,
`imported_classes` by status and by `deleted_at`, and `catalog_redirects` by
`(catalog, from_key)` through its own `UNIQUE`.

**Referential integrity is clean.** Fifteen orphan checks — every foreign key in
the app, plus `characters.class_id` and `occ_class_id`, which are slugs rather
than real references and so could rot silently — return **zero**. No character
drafts abandoned, no soft-deleted classes, no unpublished ones, no open import
sessions.

The two counts that are not zero are both known and deliberate: **78 gear rows
still marked `STUB`**, which is the figure
[Known limitations](#known-limitations-and-refactor-candidates) explains and
defends, and **52 skills with no `source_book`**, which are seed rows that
predate the column.

### Checking the live database against the repo

```bash
node scripts/drift-check.mjs --remote
```

Read-only, so it is safe to point at production. It compares five things:

| | |
|---|---|
| migration files | vs `schema_migrations` |
| data scripts | vs `data_script_runs` |
| tables in `schema.sql` | vs `sqlite_master` |
| columns in `schema.sql` | vs the live `CREATE` text |
| published classes | vs a class a data script can recreate |

**The smoke test and the regression test cannot see production.** Smoke proves
the repo is internally consistent; regression proves a database built *from* the
repo works. The gap between them is where the expensive mistakes live, and the
first run of this check found two that had been sitting there for weeks:

**Two classes existed only in production.** `chiang-ku-dragon` and `juicer`
predate the data-script convention — they were imported through the UI, and
every correction since is a `fix-*.sql` that *patches a row nothing in the repo
creates*. `schema.sql` plus the data scripts rebuilt **24 of 26** published
classes. Had production been lost, those two definitions were not in git at all.
`add-chiang-ku-dragon-class.sql` and `add-juicer-class.sql` close it, exported
from the live rows; a fresh build now reaches 26 and both come out byte-identical
to production.

**A run record that asserted something untrue.**
`backfill-data-script-runs.sql` swept `seed-dev.sql` in with everything else, so
production recorded a local-only script as having run there. Nothing was
actually seeded — checked before fixing — but the row is the exact lie
`data_script_runs` exists to prevent. `fix-seed-dev-run-record.sql` removes the
asserted row and leaves any genuinely observed one alone.

Two facts about `wrangler` are baked into the script because both cost an hour:
`--file` over `--remote` returns a **summary** row rather than query results, so
every count comes back as 1; and `execFileSync` with `shell: true` does not
quote the arguments it joins, while without a shell Node refuses to spawn
`npx.cmd` on Windows at all.

**Prose counts drift silently.** The README claimed *"Sixteen of twenty-five
published classes state no hit point formula"* when the answer was eighteen of
twenty-six — stale before the Stone Master, not because of it — and still
described 15 of the Shifter's 34 spells as missing from the catalog seventy
lines after the section saying all three lists resolve in full. Both are now
pinned by the regression test, which is the only place that can count them,
because the class definitions live in D1 rather than in the repo.

### Standing up a new environment

Verified end to end; the counts below are what a clean run produces.

```bash
node scripts/d1-apply.mjs --remote db/schema.sql
node scripts/d1-apply.mjs --remote db/seed-catalogs.sql
node scripts/d1-apply.mjs --remote apps/character-creator/db/*.sql
```

The glob is expanded by `d1-apply.mjs` itself, sorted — PowerShell does not
expand globs for native commands, so the same line works in either shell. It
prints `skipping ... marked local-only` for `seed-dev.sql`, which inserts a test
campaign and character and must never reach production. That exclusion is the
file's own `-- local-only` marker, not a list kept in the script, so a new
local-only script is protected as soon as it says so.

| After | Rows |
|---|---|
| classes (published, live) | 76 |
| skills | 324 |
| spells | 570 |
| psionic powers | 101 |
| gear | 844 |

**These are pinned by `test/regression.mjs`**, which is the only thing that can
honestly check them: it builds a database from nothing under a scratch directory
and asks the running worker what it serves. The previous version of this table
claimed 23/231/366/52/407 and was verified by nothing - three paragraphs after
the note above about prose counts drifting silently.

### The rebuild did not match production, and nothing was watching

Pinning those counts immediately found that two of them disagreed with
production, in opposite directions. Both are fixed; the story is kept because
the cause will recur.

**Six psionic powers.** A clean run produced 107 against production's 101, and
the extra six were not new content - they were the OLD HALF of six merges
somebody performed through the catalog editor, which writes straight to D1:

| the repo still created | production kept |
|---|---|
| `Bio-Manipulation` | `Bio-Manipulation (the evil eye)` |
| `Bio-Regenerate (self)` | `Bio-Regeneration` |
| `Levitation (psionic)` | `Levitation` |
| `Nightvision (psionic)` | `Nightvision` |
| `Object Read` | `Object Read (Psychometry)` |
| `Telekinesis (minor)` | `Telekinesis` |

**One of those six was already supposed to be fixed.**
`merge-bio-regenerate-duplicate.sql` has been in the repo for weeks doing
nothing, and the reason is **filename order**: it sorts under `m`, while every
surviving row is created by `restore-psionics-missing-from-repo.sql` under `r`.
Running first, its guards correctly found no survivor to merge into and it did
nothing - silently, because doing nothing is exactly what a guarded script does
when its precondition is absent. `zz-merge-psionic-duplicates.sql` supersedes
it and sorts last, the same fix `zz-canonicalise-class-skill-names.sql` needed.

Three of the retired names are cited by class definitions - `Bio-Manipulation`
by the Combat Cyborg, `Object Read` by the Cyber-Knight and Techno-Wizard - and
are deliberately **not** rewritten. That is what `catalog_redirects` are for,
and rewriting a class's markdown to match a catalog rename loses the book's own
wording.

**Seven gear rows**, hidden inside a difference of one. Four existed only in
production (`Huntsman Armor`, `Air Filter And Gas Mask`, `Hovercycle`,
`Light Mdc Body Armor`) - class-import stubs the importer wrote straight to D1.
Three existed only in the repo, generic stubs production had superseded with
specific rows (`Sunglasses Or Tinted Goggles` against production's `Sunglasses`
*and* `Tinted Goggles`). **Counts alone would have called that a one-row
problem.**

### `scripts/repo-vs-live.mjs`

The guard that should have existed. `drift-check` compares *bookkeeping* -
which migrations and data scripts have run - and every script here was recorded
in both places while the rows differed. It demands that every published **class**
be creatable from the repo, and nothing made the same demand of catalog rows.

```bash
node scripts/repo-vs-live.mjs              # all five catalogs
node scripts/repo-vs-live.mjs --table gear
```

It builds from the repo into a scratch database and diffs the **names** against
live, because counts are not enough. Exits non-zero on any difference and
prints which direction each is:

- **ONLY LIVE** - added through the app and never written back. Export it into a
  data script, the way `restore-*.sql` did.
- **ONLY REPO** - merged or renamed away in the app while the repo still creates
  the old row. `zz-merge-psionic-duplicates.sql` is the shape: move redirects,
  add a forwarding one, then delete.

This is the third time rows added through the UI have diverged from the repo.
The first two were found by hand.

**Do not run the migrations on a new database.** This is the part that looks
wrong and is not: `db/schema.sql` already contains every column the migrations
add, so on a fresh database **the ALTER-based majority of them fail** —
`duplicate column name: bio`, `no such table: items`, and so on; only the pure
`CREATE TABLE IF NOT EXISTS` migrations run clean. They exist to bring an EXISTING
database forward, and `schema.sql` records all 24 as applied the moment it runs,
guarded on the schema feature each one adds. A fresh database is current
immediately and says so.

So the two directions never mix:

| | new database | existing database |
|---|---|---|
| `db/schema.sql` | **yes** — creates everything, records every migration | yes — harmless, and how you backfill the records |
| `db/migrations/*.sql` | **no** — the ALTERs error | yes — the ones it has not had, in order |
| `db/seed-catalogs.sql` | yes | no — it seeds the ORIGINAL three classes |
| `apps/character-creator/db/*.sql` | yes — the corrections on top | as needed; the log says which have run |

`seed-catalogs.sql` seeds the three classes **as originally written, not as the
rules audit corrected them**, which is why the data scripts follow it rather
than being optional. Apply them in filename order; every one guards itself, so
a script whose moment has not come does nothing and can be re-run later.

Then confirm, rather than trusting the exit codes:

```sh
npx wrangler d1 execute DB --remote --command \
  "SELECT (SELECT count(*) FROM schema_migrations) AS migrations,
          (SELECT count(*) FROM imported_classes WHERE status='published') AS classes,
          (SELECT count(*) FROM skills) AS skills,
          (SELECT count(*) FROM data_script_runs) AS script_runs;"
```

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
- **A migration that adds a column must add it to `schema.sql`'s `CREATE` too.**
  The two are not alternatives: the migration brings an existing database
  forward, the `CREATE` is what a brand-new one gets. Skipping the second half
  is invisible until someone builds a fresh environment. It has happened —
  `020` and `021` added `isp_note` / `ppe_note`, neither reached `schema.sql`,
  and the documented local-dev recipe produced a database whose very first API
  call (`/catalogs`, which selects both) failed.
- The smoke test fails if a file in `db/migrations/` has no matching row, or if a
  recorded row has no matching file. It separately fails if a migrated column is
  missing from `schema.sql`'s `CREATE`, if a migration has no seed line there, or
  if a seed line is unguarded — those read the files rather than the database,
  because the database check cannot see any of it. The local database has had the
  migrations applied to it by hand, so it reports itself current however wrong
  `schema.sql` is.

Running `db/schema.sql` against an already-current database is therefore how you
backfill the records — no separate backfill migration is needed.

### Data scripts

`apps/character-creator/db/*.sql` are a different thing from `db/migrations/`
and are easy to mistake for them. A migration changes **schema**; these change
**rows**, and are run by hand per environment as needed.

They used to be tracked nowhere, which left "has production had the Juicer
correction?" answerable only by querying the rows it writes and inferring —
the same guessing game `schema_migrations` was created to end. Migration 024
added `data_script_runs` and every script now ends by writing itself into it.

| Kind | Files | What they are |
|---|---|---|
| Dev seed | `seed-dev.sql` | Optional local character/campaign rows. Never applied to production |
| Run tracking | `backfill-data-script-runs.sql` | One-time, optional, and an **assertion**: records every script that had already been applied before `data_script_runs` existed, stamped with a note saying the run was asserted rather than observed. Guarded per filename, so it cannot double-record a script that has genuinely run since |
| Data cleanup | `estimate-*.sql`, `backfill-*.sql`, `rename-*.sql`, `merge-*.sql`, `retag-*.sql`, `retire-gear-placeholders.sql`, `retire-leather-armor-placeholder.sql`, `retire-orphan-gear-stubs.sql`, `untag-cross-system.sql` | One-off corrections to rows an earlier import or data script got wrong or left NULL. A `rename-*` also leaves a `catalog_redirects` row, so class markdown citing the old key keeps resolving. A `retag-*` changes which system a row belongs to, never what it is — `retag-pf-spells-both.sql` moves 57 spells the Palladium Fantasy book prints from `rifts` to `both` |
| Class corrections | `fix-*.sql`, `apply-*.sql`, `long-bowman-money.sql`, `ley-line-walker-spells-per-level.sql`, `mystic-spells-per-level.sql`, `shifter-spells-per-level.sql`, `ley-line-rifter-spells-per-level.sql`, `record-warlock-palladium-deltas.sql` | The rules audit's output: stored class definitions rewritten against the books, and class data written for a schema feature the day it landed. The Ley Line Walker one is the first to fill `spells_per_level` — the format gained the key before any class carried it, so every caster read as "not recorded" until a book was opened |
| Additions | `add-*.sql` | Something the book gives that the database never had — a catalog row, a whole-table batch extracted from page scans (`add-pf-weapons-batch`, `add-pf-equipment-batch`, the RUE spell and psionics batches), or a whole class. A missing skill named in an `only` restriction narrows its category to nothing, which is usually how one gets noticed. A class goes in this way only when the import tool cannot be reached: production sits behind Cloudflare Access, so a hand-transcribed class is applied by script instead |
| Repo rescue | `restore-*.sql` | Rows that existed **only in production**. The catalog editor and the importer's confirm step both write straight to D1, so nothing in git created what they added: a database built from the repo came up 75 skills, 36 psionic powers and 58 gear rows short, and every class citing one had a dead reference. Exported from the live rows and guarded on the key, so on production they find everything present and do nothing — it is a fresh environment that needs them. Named `restore-` rather than `add-` **for ordering**: an `add-` file sorts before `rename-skills-to-rue.sql`, which would insert the post-rename name, leave the rename's guard to find its target taken, and end up holding both |
| Ordering-sensitive | `zz-*.sql` | Applied in filename order like everything else, which is exactly the problem: **filename order is not the order things were actually run**. `fix-class-skill-names-to-rue.sql` was applied to production by hand, last, so it won; in a repo build it sorts under `f` and three scripts after it (`fix-dead-skill-restrictions`, `fix-dragon-hatchling`, `fix-juicer-rue-edition`) wrote the pre-RUE skill names back. Production was right and a fresh build was wrong, and only the regression restriction audit caught it. Editing those three would break the rule that an applied script is never edited, so the alternative is to sort after all of them — and `zz-` is the only prefix that guarantees it |

Three conventions hold across all of them, with one stated exception: the
dev seed is a different kind of file and follows only the third. Its inserts
are unguarded and re-applying it fails on `gear.slug`, which is the right
behaviour for a file whose whole job is to put known rows into an empty
local database.

- **Every statement guards itself**, so a script is safe to run twice and safe
  to run *early*. `retire-gear-placeholders.sql` is the clearest case — it does
  nothing at all until the options it rewrites toward exist, and its closing
  `SELECT` reports what it did and what it is still waiting for. See
  [Starting gear the class leaves open](#starting-gear-the-class-leaves-open).
- **Each one opens with the book and page it is correcting against**, because a
  script that rewrites a class is a claim about a source, and six months later
  the citation is the only way to check it.
- **Each one ends by recording its own run**:
  `INSERT INTO data_script_runs (filename) VALUES ('<this-file>.sql');`
  One row per **run**, not per file, and deliberately not keyed on the
  filename — because of the guard convention above. A script that ran early
  and correctly did nothing has still run, and an applied-once flag would
  record that no-op as done and hide that the real work never happened.
  `retire-gear-placeholders.sql` is exactly that case. The smoke test fails if
  a script has no footer, or if a copy-pasted one names a different file —
  which logs the wrong script and looks entirely fine.

What an environment has had run, and when:

```sh
npx wrangler d1 execute DB --remote --command \
  "SELECT filename, count(*) AS runs, max(run_at) AS last_run,
          max(note) AS asserted FROM data_script_runs
    GROUP BY filename ORDER BY last_run DESC;"
```

A script on disk with no row there has never been run against that database.

**The reverse is not fine, and this paragraph used to say it was.** It read
*"a data script may be deleted once its correction is folded into the class it
rewrote, and the log keeps the record that it ran"* — and
[`scripts/drift-check.mjs`](../../scripts/drift-check.mjs) reports a recorded
filename with no file as `RUN BUT NO FILE`, which is a **problem**, not an
advisory: the run prints `DRIFT FOUND` and exits 1. Two documents, one saying
delete freely and the other failing the build for it.

The tool is right and the sentence was wrong, for a reason deeper than the exit
code. **A correction is never "folded into the class it rewrote"**, because a
`fix-*.sql` does a guarded `replace()` against markdown living in D1 — its
effect is in the database and nowhere else. The repo can only rebuild that
database by running the script again, which is exactly what
[`repo-vs-live.mjs`](../../scripts/repo-vs-live.mjs) checks. Delete the file and
a rebuilt environment silently comes up with the pre-fix class.

So: **a data script is as permanent as a migration once applied.** The only
difference is that it changes rows rather than schema. If one truly becomes
redundant — because a later script overwrites the same text unconditionally —
the honest move is a header comment saying so, not a deletion. Nothing in 171
scripts has met that bar.

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

  **`--command` fights PowerShell over double quotes.** PowerShell has no
  backslash escaping, so `\"` inside a double-quoted `--command` does not
  escape anything — the string ends early and the rest word-splits into
  arguments wrangler rejects. That bites hardest on exactly the queries most
  worth running remotely, because class markdown cites gear as
  `item_id: "slug"` with real double quotes in it.

  Build them in SQL instead, the same way `char(8212)` already handles the
  em-dash: `instr(markdown, 'item_id: ' || char(34) || 'energy-rifle' ||
  char(34))`. The command then carries no inner double quote at all.

  **`scripts/d1-apply.mjs` is not affected** and needs none of this: it spawns
  wrangler with a real argv array and no shell, so a statement passes through
  untouched however it is quoted. The trap is only for a `--command` typed at
  a PowerShell prompt.

  **Reading a result set back is easier as a file than as terminal output.**
  `--json | Out-File -Encoding utf8 out.json` gives you something to parse
  rather than something to transcribe. Slugs are the reason: `ng-l5-northern-
  gun-laser-rifle` reads as `ng-15-` in most terminal fonts, and a `from:`
  list naming a slug that does not exist is worse than the placeholder it
  replaces.

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

The planned PRs and the two shipped proposals are recorded under
[`docs/plans/`](docs/plans/README.md) with their design decisions and rejected
alternatives. The rules audit against the source books — the class-data
corrections and the schema work that came out of them — is in
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
| `occ_group` | the 25 Palladium O.C.C.s | one of `clergy`, `men-of-arms`, `optional`, `magic`, `psychic` |
| `occ_restrictions` | the 8 restricted races | `only: [...]` **or** `except: [...]`, never both |

Entries are class ids or `group:<name>`. **Groups are the point.** *"A dwarf may
take any O.C.C. except magic"* is a rule about a group; written as a list of the
four magic classes the catalog holds today it would silently stop covering the
fifth — and a restriction that quietly stops restricting is worse than none,
because nothing says it happened.

The groups are the **book's own**, taken from the section each class is printed
in: Clergy, Men of Arms (78-95), Optional O.C.C.s (96), the Ways of Magic (100)
and Psychic Character Classes (156).

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

Seven O.C.C.s carry a hard bar, all of them human-only:

| class | the book's line |
|---|---|
| Juicer | 95% human (p.81) |
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

Both directions are checked in the same two places, and either may refuse: the
picker filters on both, and the server runs both on create.

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

**The catalog editor has no general delete.** Rows are created and corrected by
hand; the only deletion is the one a merge performs. Deliberate — see
[`docs/plans/04-catalog-edit-ui.md`](docs/plans/04-catalog-edit-ui.md).

**Part of the gear catalog is still name-only stubs.** A class import creates
a stub row for every equipment id it cannot find, so the catalog holds a row
per name any class has ever mentioned. Production carried 157 of them; 33 were
orphaned by later class corrections and referenced by nothing at all, and
`retire-orphan-gear-stubs.sql` drops those.

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
  same defect [Starting gear the class leaves open](#starting-gear-the-class-leaves-open)
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
would be inventing a rule — see [A row can say where it came from](#a-row-can-say-where-it-came-from).

A handful are neither: categories the importer emitted as ids before choice
groups existed. `energy-pistol` and `vibro-blade` were fixed by
[`retire-gear-placeholders.sql`](db/retire-gear-placeholders.sql) and
`energy-rifle` by [`fix-shifter-energy-rifle.sql`](db/fix-shifter-energy-rifle.sql).
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

**The page scripts are long, and deliberately not split.**

| file | lines | |
|---|---|---|
| `app.js` | ~3,000 | the wizard; the largest file in the app |
| `sheet.js` | ~2,000 | |
| `js/parser.js` | ~1,600 | **third** largest, and not a page script at all |
| `import.js` | ~950 | |
| `catalog.js` | ~700 | |
| `campaign.js` | ~640 | |
| `dashboard.js` | ~110 | |

**A smoke check now holds these to 25%**, because the previous two sets of
figures both went stale in the same way. The set before this one said `app.js`
was "roughly 1,900" when it was 2,950 — 55% out — and called `parser.js` the
*second* largest file when `sheet.js` sits between them. The set before THAT had
drifted 80% on `sheet.js` while claiming a 20% tolerance. Twice is a pattern, and
prose that says "treat these as orders of magnitude" is not a tolerance, it is an
apology for not having one.

Each page script drives one page and each does several jobs. Splitting was
considered and rejected: there is no build step, so there is no bundler —
splitting means more `<script>` tags, hand-managed load order, and the
classic-script/module distinction to keep straight. The cost is real and the
benefit is aesthetic. That case was argued when `sheet.js` was around 900 lines
and it has since more than doubled, so it is worth re-examining rather than
inheriting. `import.js` remains the clearest seam, since its class, skills and
session-based flows share a page and almost no logic.

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
