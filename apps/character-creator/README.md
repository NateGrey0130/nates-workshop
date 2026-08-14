# Character Creator — Palladium Fantasy & Rifts

A persistent, multi-campaign character creator and journal. Build a character
through a guided wizard, keep a running session log, level up semi-automatically,
print a sheet laid out after the official form, and import classes and skills
straight out of a sourcebook PDF.

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
├── import.html / import.js   Admin-only PDF import — Class and Skills tabs
├── styles.css                All four pages, layered on /shared/styles.css
├── js/parser.js              RCC/OCC markdown parser (ES module — also used by the API)
├── js/dice.js                Dice evaluator (ES module — also used by the API)
├── js/derive.js              Attribute tables → combat bonuses, saves, percentages
│                             (classic script; both the wizard and the sheet use it)
├── db/seed-dev.sql           Optional local-dev seed rows; never applied to production
└── test/
    ├── smoke.mjs             Parser + schema smoke test
    └── fixtures/*.md         Three real class files, parser test input only

functions/api/
├── _lib/access.js            Cloudflare Access identity + admin check (site-wide)
├── _lib/claude-client.js     The only place that calls the Anthropic API
├── claude.js                 HTTP proxy over claude-client, for browser callers
└── character-creator/
    ├── _lib/auth.js          Owner/GM/admin authorization, readJson
    ├── _lib/catalog.js       Cross-reference an import; create catalog stubs
    ├── _lib/class-loader.js  Resolve a class_id to parsed frontmatter
    ├── _lib/class-store.js   Read/write stored classes; per-isolate parse cache
    ├── _lib/extraction-prompt.js  Class import prompt
    ├── _lib/skill-prompt.js  Skill chapter import prompt
    ├── _lib/leveling.js      XP curve + level-up diff
    └── (endpoints — see API surface below)

db/
├── schema.sql                All tables, every statement IF NOT EXISTS
├── seed-catalogs.sql         One-time move of the original static content into D1
└── migrations/               One-shot ALTERs; see Production configuration
```

Three modules are imported by both the browser and the Workers runtime:
`js/parser.js`, `js/dice.js`, and `_lib/*`. That is why `app.js` is loaded as
`<script type="module">` while the other three pages are classic scripts — and
why inline handlers in the wizard need explicit `window` exposure (see the
`Object.assign(window, …)` block at the bottom of `app.js`).

`js/derive.js` is deliberately a *classic* script rather than a module, so the
sheet's plain script can use it without converting the whole file.

---

## Data model

Eleven tables in one shared D1 database (`nates-workshop-media`, bound as `DB`).
`media_items` belongs to MediaVault; the rest are this app.

**Character data**

| Table | Notes |
|---|---|
| `campaigns` | Top-level container. `gm_email` owns it. `gm_notes` is GM-only and stripped from non-GM API responses. |
| `characters` | See below — several JSON columns. |
| `character_items` | Inventory join. `item_id` NULL means a freeform item (`custom_name` required). `removed_at` NULL means currently held — removals are soft, so history survives. |
| `journal_entries` | `character_id` NULL means a campaign-level entry. |
| `level_history` | One row per confirmed level-up; `changes` is a JSON diff of what was actually applied. |

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
| `imported_classes` | Class definitions as markdown. `status` is `draft` or `published`; only published classes appear in the app. |
| `items` | Gear catalog. `slug` is what `equipment_starting[].item_id` references. |
| `skills` | `base` 0 means non-percentile (W.P.s, hand to hand). `systems` is a JSON array; NULL means both. `note` carries oddities like `40%/30% climb/rappel`. |
| `spells` | name, level, ppe. |
| `psionic_powers` | name, category (Healing/Physical/Sensitive/Super), isp. |

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
`note`, `restrictions`, `side_effects`, `extraction_notes`,
`level_progression[].grants`, and `occ_related_skills.schedule`.

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
| `classes` | GET | Published classes, parsed. `?system=` `?category=` |
| `catalogs` | GET | Skills, spells, psionic powers in one call |
| `items` | GET | Gear catalog. `?system=` |
| `campaigns` | GET / POST | List; create (caller becomes GM) |
| `campaigns/[id]` | GET / PATCH | Details (`gm_notes` stripped for non-GM); edit `gm_notes` |
| `characters` | GET / POST | List (`?campaign_id=`); create at level 1 |
| `characters/[id]` | GET / PATCH | Sheet + inventory, with `can_write` / `is_gm`; edit pools, notes, and the bio/combat/saves/armor sections |
| `characters/[id]/items` | POST | Add inventory row (catalog slug or freeform) |
| `characters/[id]/items/[itemId]` | PATCH / DELETE | qty/equipped/notes; soft remove |
| `characters/[id]/xp` | POST | `{delta}` or `{total}`; returns a proposed level-up diff |
| `characters/[id]/level-confirm` | POST | Apply a confirmed diff, write `level_history` |
| `journal` | GET / POST | By campaign; `?character_id=` and `?include_campaign=1`, `?limit=` |
| `import/extract` | POST | Admin. PDF → class markdown; autosaves a draft |
| `import/recheck` | POST | Admin. Re-parse edited markdown, no API spend |
| `import/confirm` | POST | Admin. Publish class + create catalog stubs |
| `import/stored` | GET / DELETE | Admin. List/fetch/delete stored classes |
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

## The PDF importers

Both live on `import.html`, admin only, behind Class / Skills tabs. Both send
the PDF to Claude as a **document attachment**, never as extracted text:
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

In the Rifts core book the skill chapter is roughly **pp. 26–34**, about one or
two categories a page. Two pages yielded 33 skills in ~28 seconds.

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

`db/migrations/*.sql` are **one-shot** and cannot be made idempotent, because
SQLite has no `ADD COLUMN IF NOT EXISTS`. Run each once per environment; a
re-run failing with "duplicate column name" means it is already applied. Check
first with `SELECT name FROM pragma_table_info('characters')`.

| Migration | Adds |
|---|---|
| `001-character-detail.sql` | `bio`, `combat`, `saves`, `armor` on `characters` |
| `002-catalog-provenance.sql` | `source_book` + `note` on `skills`; `source_book` on `spells`, `psionic_powers` |

Merging to `main` is the deploy — Pages auto-deploys, no CI, no build command.
Cloudflare Access fronts the whole site with the path left blank, so every route
including `/api/*` is covered; there is no Access policy-as-code in the repo.

Verify anything applied to production by querying it back, not by trusting an
exit code — `wrangler d1 execute` has been observed reporting a non-zero exit on
a fully successful run.

---

## Known limitations and refactor candidates

Honest list, roughly by value.

**Staged skill picks are stored but never prompted.** `occ_related_skills.schedule`
records that a class grants extra picks at levels 3/6/9/12, and the level-up flow
ignores it — it computes pool and percentage diffs and surfaces `grants` as text.
Wiring this in means the level-up proposal needs a skill-picker step. This remains
the biggest gap between what the data says and what the app does.

**Catalogs are thin, and only skills can be imported.** 19 spells and 26 psionic
powers are all hand-seeded; there is no spell or psionic importer, and no item
importer. Every item in production is a stub created by a class import, so gear
has names but no weight, cost, or stats. A spell importer is the largest of these
— hundreds of entries across many levels, so several page ranges and several
calls.

**No UI for editing catalog rows.** Only the importers write them. A single wrong
percentage currently needs a re-import or SQL.

**Class deletion is permanent.** When classes lived in files, a commit could
override a bad row. Now D1 is the only source and deletes are hard. A `deleted_at`
soft-delete column would restore the safety net.

**Migrations are half-solved.** `schema.sql` re-runs safely for additive changes;
`db/migrations/` handles ALTERs but is manual, unordered, and has no record of
what has been applied to which environment. A third migration would justify a
`schema_migrations` table.

**Rule enforcement is client-side.** Skill counts, category restrictions, and
attribute minimums are enforced in the wizard; the server validates shape,
ownership, and campaign existence only. Fine for a friends-only app behind
Access, but it is not a boundary.

**Extraction is good, not infallible.** Observed on real pages: a skill's
secondary percentage split into its own entry, and a skill read as 0% where the
catalog had 30%. Both are defensible readings of a dense page — which is why both
importers end in a review step. Do not bulk-accept a new book's first run.

**The sheet re-renders wholly on every edit.** Fine at this scale; targeted
updates would be a real refactor. Editing state is preserved across the
re-renders that add or remove armor, but that is a patch rather than a fix.

**`items` is a generic name in a shared database.** It sits alongside MediaVault's
`media_items`. No collision today, but it is the most likely future one.

**No pagination.** The journal endpoint takes a `limit` (default 200), but
character, campaign, item and catalog lists are unbounded. Fine at friends scale.

**FilamentForge pins `claude-sonnet-4-20250514`**, which returned
`404 not_found_error` on the API key used locally. Unrelated to this app, but it
shares the proxy — worth confirming the production key can reach that model.
