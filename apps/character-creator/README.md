# Character Creator — Palladium Fantasy & Rifts

Character builder + campaign journal. Spec: `rifts-character-creator-spec.md`.
**Status: all 7 build phases complete**, conformed to the shared workshop framework.
Remaining work is content (more RCC/OCC markdown files, fuller skill/item/spell
catalogs, per-class XP tables).

## Layout

```
apps/character-creator/
├── index.html / app.js       Creation wizard: system → class → attributes → skills → equipment → powers → review
├── sheet.html / sheet.js     Character sheet: stats, inventory, journal, level-up, print/PDF
├── dashboard.html / dashboard.js  GM dashboard: roster, GM notes, campaign journal
├── styles.css                App styles (all three pages) on top of /shared/styles.css
├── js/parser.js              RCC/OCC markdown parser (ES module — also imported by the API)
├── js/dice.js                Dice evaluator (ES module — also imported by the API)
├── data/classes/             One markdown file per RCC/OCC + index.json manifest
├── data/skills.json          Skill catalog (name/category/base %)
├── data/spells.json          Spell catalog (name/level/ppe)
├── data/psionics.json        Psionic catalog (name/category/isp)
├── db/seed-dev.sql           Optional local-dev seed rows (never applied to production)
└── test/smoke.mjs            Parser + schema smoke test

functions/api/character-creator/
├── _lib/auth.js              Owner/GM authorization (identity via functions/api/_lib/access.js)
├── _lib/class-loader.js      Resolves a class_id slug to parsed frontmatter
├── _lib/leveling.js          XP curve + level-up diff calculation
├── me.js                     GET the caller's identity
├── classes.js                GET parsed RCC/OCC definitions
├── campaigns.js              GET list · POST create
├── campaigns/[id].js         GET (gm_notes stripped for non-GM) · PATCH gm_notes (GM only)
├── items.js                  GET shared gear catalog
├── characters.js             GET list · POST save at level 1
├── characters/[id].js        GET sheet (+can_write/is_gm) · PATCH current stats/notes
├── characters/[id]/items.js  POST add inventory row
├── characters/[id]/items/[itemId].js  PATCH qty/equipped/notes · DELETE (soft, sets removed_at)
├── characters/[id]/xp.js     POST {delta|total} — updates XP, returns proposed level-up diff
├── characters/[id]/level-confirm.js  POST — applies confirmed diff + logs level_history
└── journal.js                GET by campaign (+character filter) · POST entry
```

Storage lives in the shared workshop D1 database (`nates-workshop-media`, bound as
`DB` in the root `wrangler.jsonc`); the six tables are defined in `db/schema.sql`
alongside MediaVault's.

## Local dev

One binding, one local database, run from the repo root:

```bash
npx wrangler d1 execute DB --local --file db/schema.sql
```

```bash
npx wrangler pages dev
```

Optional seed rows for a non-empty local DB:

```bash
npx wrangler d1 execute DB --local --file apps/character-creator/db/seed-dev.sql
```

Local dev has no Cloudflare Access in front of it, so `_lib/auth.js` falls back to
`dev@localhost` on localhost. To exercise owner/GM rules, send an explicit
`Cf-Access-Authenticated-User-Email` header.

Smoke test (parser + schema):

```bash
node apps/character-creator/test/smoke.mjs
```

## Adding a class

Drop a new `.md` file in `data/classes/` (copy an existing one for the schema) and
add its filename to `index.json`. Frontmatter drives creation and leveling;
`## Lore` and `## GM Notes` body sections are display-only.

## House rules

Palladium has no single answer for these, so the app invents one and lets a class
file override it without a schema change:

| Rule | Default | Per-class override |
|---|---|---|
| Point-buy curve | 8 base, 40 pts, +1 costs 1 pt to 15 / 2 pts to 18, cap 18, floor 3 | — |
| XP table | shared 15-level curve in `_lib/leveling.js` | `xp_table: [...]` frontmatter |
| Psionic starting powers | minor 2, major 6, master 8; Super is master-only | `psionics.powers_starting` / `psionics.categories_allowed` |
| Attribute rolls | 3d6, bonus d6 on 16+ | `attribute_dice` frontmatter |

## Framework notes

- `app.js` is loaded as `<script type="module">` (the other two pages are classic
  scripts) so the wizard can import `js/dice.js` — the same module the server-side
  leveling code uses. Inline `onclick` handlers therefore need explicit
  `window` exposure; see the `Object.assign(window, …)` block at the bottom of `app.js`.
- `/shared/js/ui.js` provides `escHtml()`, used throughout. `/shared/js/api.js` is
  not loaded — its only helper is the Claude proxy wrapper, which this app doesn't use.
