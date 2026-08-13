# Character Creator — Palladium Fantasy & Rifts

A persistent, multi-campaign character creator and journal. Build a character
through a guided wizard, keep a running session log, level up semi-automatically,
print a sheet, and import new classes straight out of a sourcebook PDF.

Part of Nate's Workshop. Cloudflare Pages + D1, behind the site-wide Cloudflare
Access gate. No build step, no framework, no dependencies.

---

## Contents

- [Where everything lives](#where-everything-lives)
- [Data model](#data-model)
- [Class definition format](#class-definition-format)
- [API surface](#api-surface)
- [Permissions](#permissions)
- [House rules](#house-rules)
- [The PDF import tool](#the-pdf-import-tool)
- [Local development](#local-development)
- [Production configuration](#production-configuration)
- [Known limitations and refactor candidates](#known-limitations-and-refactor-candidates)

---

## Where everything lives

Everything the app reads at runtime is in D1. There are no static content files
— adding a class, a skill, a spell, or an item needs no commit and no redeploy.

```
apps/character-creator/
├── index.html / app.js       Creation wizard (7 steps). app.js is an ES module.
├── sheet.html / sheet.js     Character sheet: stats, inventory, journal, level-up, print
├── dashboard.html / dashboard.js  GM dashboard: roster, GM notes, campaign journal
├── import.html / import.js   Admin-only PDF class import
├── styles.css                All four pages, layered on /shared/styles.css
├── js/parser.js              RCC/OCC markdown parser (ES module — also used by the API)
├── js/dice.js                Dice evaluator (ES module — also used by the API)
├── db/seed-dev.sql           Optional local-dev seed rows; never applied to production
└── test/
    ├── smoke.mjs             Parser + schema smoke test
    └── fixtures/*.md         Three real class files, parser test input only

functions/api/
├── _lib/access.js            Cloudflare Access identity + admin check (site-wide)
├── _lib/claude-client.js     The only place that calls the Anthropic API
├── claude.js                 HTTP proxy over claude-client, for browser callers
└── character-creator/
    ├── _lib/auth.js          Owner/GM/admin authorization
    ├── _lib/catalog.js       Cross-reference an extracted class; create catalog stubs
    ├── _lib/class-loader.js  Resolve a class_id to parsed frontmatter
    ├── _lib/class-store.js   Read/write stored classes
    ├── _lib/extraction-prompt.js  The import prompt
    ├── _lib/leveling.js      XP curve + level-up diff
    └── (endpoints — see API surface below)

db/
├── schema.sql                All tables, every statement IF NOT EXISTS
└── seed-catalogs.sql         One-time move of the original static content into D1
```

Two modules are imported by both the browser and the Workers runtime:
`js/parser.js` and `js/dice.js`. That is why `app.js` is loaded as
`<script type="module">` while the other three pages are classic scripts — and
why inline `onclick` handlers in the wizard need explicit `window` exposure (see
the `Object.assign(window, …)` block at the bottom of `app.js`).

---

## Data model

Eleven tables in one shared D1 database (`nates-workshop-media`, bound as `DB`).
`media_items` belongs to MediaVault; the rest are this app.

**Character data**

| Table | Notes |
|---|---|
| `campaigns` | Top-level container. `gm_email` owns it. `gm_notes` is GM-only and stripped from non-GM API responses. |
| `characters` | `attributes`, `skills`, `powers` are JSON columns. Paired `*_max` / `*_current` for hp, sdc, mdc, ppe, isp. `class_id` references a class slug. |
| `character_items` | Inventory join. `item_id` NULL means a freeform item (`custom_name` required). `removed_at` NULL means currently held — removals are soft, so history survives. |
| `journal_entries` | `character_id` NULL means a campaign-level entry. |
| `level_history` | One row per confirmed level-up; `changes` is a JSON diff of what was actually applied. |

**Content catalogs** — all editable at runtime

| Table | Notes |
|---|---|
| `imported_classes` | Class definitions as markdown. `status` is `draft` or `published`; only published classes appear in the app. |
| `items` | Shared gear catalog. `slug` is what `equipment_starting[].item_id` references. |
| `skills` | `base` 0 means non-percentile (W.P.s, hand to hand). `systems` is a JSON array; NULL means both. |
| `spells` | name, level, ppe. |
| `psionic_powers` | name, category (Healing/Physical/Sensitive/Super), isp. |

Rows created by the import tool carry `source = 'import'` (or a `STUB —` prefix
in `items.description`), so incomplete entries are easy to find later.

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
`note`, `restrictions`, `side_effects`, `extraction_notes`, `level_progression[].grants`,
and `occ_related_skills.schedule`.

The parser supports a YAML subset: nested maps, block and inline sequences,
inline objects, and `|` / `>` block scalars. Blank lines inside a block scalar
collapse, and `#` inside unquoted text is treated as a comment.

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
| `characters/[id]` | GET / PATCH | Sheet + inventory, with `can_write` / `is_gm`; edit current pools and notes |
| `characters/[id]/items` | POST | Add inventory row (catalog slug or freeform) |
| `characters/[id]/items/[itemId]` | PATCH / DELETE | qty/equipped/notes; soft remove |
| `characters/[id]/xp` | POST | `{delta}` or `{total}`; returns a proposed level-up diff |
| `characters/[id]/level-confirm` | POST | Apply a confirmed diff, write `level_history` |
| `journal` | GET / POST | By campaign (`?character_id=` filter); create entry |
| `import/extract` | POST | Admin. PDF → class markdown; autosaves a draft |
| `import/recheck` | POST | Admin. Re-parse edited markdown, no API spend |
| `import/confirm` | POST | Admin. Publish class + create catalog stubs |
| `import/stored` | GET / DELETE | Admin. List/fetch/delete stored classes |

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
   environment variable and **fails closed** when unset. Admin gates the entire
   import feature, which touches the global catalogs rather than one campaign.

Clients hide controls they cannot use, but the server enforces independently —
the UI check is a convenience, never the boundary.

---

## House rules

Palladium has no single answer for these, so the app invents one. Each is
overridable per class without a schema change.

| Rule | Default | Override |
|---|---|---|
| Point-buy curve | All attributes start at 8, 40-point pool, +1 costs 1 point to 15 then 2 points to 18, cap 18, floor 3, refunds below 8 | — |
| Attribute rolls | 3d6, plus one bonus d6 on an exceptional 16+ | `attribute_dice` |
| XP table | Shared 15-level curve: 0, 2000, 4000, 8000, 16000, 25000, 35000, 50000, 70000, 95000, 125000, 160000, 200000, 250000, 300000 | `xp_table: [...]` |
| Psionic starting powers | minor 2, major 6, master 8; Super category is master-only | `psionics.powers_starting`, `psionics.categories_allowed` |
| Skill percentage cap | 98% | — |

Skills omitting `base` fall back to the catalog value — sourcebook class pages
state the *bonus*, with the base living in the skill table.

---

## The PDF import tool

Admin-only, at `import.html`.

1. **Upload** a page range covering exactly one class.
2. **Extract** — the PDF is sent to Claude as a document attachment. This is
   deliberate: layout-preserving text extraction splices neighbouring columns
   together mid-line on two-column sourcebook pages, destroying the column
   boundary before extraction starts. Do not add a text pre-pass.
3. **Autosave** — the result is stored as a `draft` the instant it parses, so a
   closed tab never loses an extraction.
4. **Review** — the whole markdown file in one editable block, with
   `extraction_notes` surfaced in a banner and missing catalog references listed.
   `recheck` re-validates edits without spending another call.
5. **Confirm** — publishes the class (live immediately) and creates stub rows in
   every catalog it references, with categories inferred from names.

Server-side callers use `_lib/claude-client.js` **directly**. Never reach the
proxy by fetching the site's own `/api/claude` URL: in production Access
intercepts the subrequest and returns the login page as HTML, which surfaces as
a confusing empty-response error.

---

## Local development

Run from the repo root. There is no build step.

```bash
npx wrangler d1 execute DB --local --file db/schema.sql
npx wrangler d1 execute DB --local --file db/seed-catalogs.sql
npx wrangler pages dev
```

Optional character/campaign test rows:

```bash
npx wrangler d1 execute DB --local --file apps/character-creator/db/seed-dev.sql
```

Smoke test (parser + schema):

```bash
node apps/character-creator/test/smoke.mjs
```

Copy `.dev.vars.example` to `.dev.vars` and set `ANTHROPIC_API_KEY` and
`ADMIN_EMAIL=dev@localhost` to exercise the import tool locally. `.dev.vars` is
gitignored. To test owner/GM rules, send an explicit
`Cf-Access-Authenticated-User-Email` header.

---

## Production configuration

Set in the Cloudflare Pages dashboard, not in the repo:

- `ANTHROPIC_API_KEY` — encrypted secret, used by the proxy and the import tool.
- `ADMIN_EMAIL` — the single email allowed to use the import tool. Fails closed.

Schema and catalog changes are applied by hand before the deploy that needs them:

```bash
npx wrangler d1 execute nates-workshop-media --remote --file db/schema.sql
npx wrangler d1 execute nates-workshop-media --remote --file db/seed-catalogs.sql
```

Merging to `main` is the deploy — Pages auto-deploys, no CI, no build command.
Cloudflare Access fronts the whole site with the path left blank, so every route
including `/api/*` is covered; there is no Access policy-as-code in the repo.

---

## Known limitations and refactor candidates

Honest list, roughly by value.

**Staged skill picks are stored but never prompted.** `occ_related_skills.schedule`
records that a class grants extra picks at levels 3/6/9/12, and the level-up flow
ignores it — it computes pool and percentage diffs and surfaces `grants` as text.
Wiring this in means the level-up proposal needs a skill-picker step, which is the
single biggest gap between what the data says and what the app does.

**Class deletion is permanent.** When classes lived in files, a commit could
override a bad row. Now D1 is the only source and deletes are hard. A `deleted_at`
soft-delete column would restore the safety net, but adding it to an existing table
needs a non-idempotent `ALTER`, so it wants a real migration story rather than
another append to `schema.sql`.

**Migrations are a single idempotent file.** `schema.sql` re-runs safely because
every statement is `IF NOT EXISTS`, which works well for additive changes and not
at all for altering or dropping. The first genuine column change will force the
question.

**Rule enforcement is client-side.** Skill counts, category restrictions, and
attribute minimums are enforced in the wizard; the server validates shape,
ownership, and campaign existence only. Fine for a friends-only app behind Access,
but it is not a boundary.

**Catalogs are thin, and stubs are thinner.** 48 skills, 19 spells, 26 psionic
powers, seeded from what the first three classes needed. Import-created stubs have
a name and an inferred category but zero percentages and costs, so a character
built on a freshly imported class will show 0% skills until someone fills them in.
There is no UI for editing catalog rows — only the import tool writes them.

**`items` is a generic name in a shared database.** It sits alongside MediaVault's
`media_items`. No collision today, but it is the most likely future one.

**Two dice evaluators existed once; one remains.** `js/dice.js` is canonical and
shared with the server. Worth checking any new code does not reintroduce a copy.

**The sheet does not show `side_effects`.** It renders in class browsing only,
because the sheet never loads class frontmatter — it would need an extra fetch for
a display-only field.

**No pagination anywhere.** Journal feeds cap at 20 entries on the dashboard and
are unbounded on the sheet; character and campaign lists are unbounded. Fine at
friends scale.

**FilamentForge pins `claude-sonnet-4-20250514`**, which returned
`404 not_found_error` on the API key used locally. Unrelated to this app, but it
shares the proxy — worth confirming the production key can reach that model.
