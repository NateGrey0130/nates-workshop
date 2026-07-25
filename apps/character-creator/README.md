# Character Creator — Palladium Fantasy & Rifts

Character builder + campaign journal. Spec: `rifts-character-creator-spec.md`.
**Status: all 7 build phases complete.** Remaining work is content
(more RCC/OCC markdown files, fuller skill/item/spell catalogs, per-class XP tables).

## Layout

```
apps/character-creator/
├── index.html              Creation wizard: system → class (browse/guided) → attributes → skills → equipment → powers → review/save
├── sheet.html              Character sheet: stats/skills/powers/inventory/journal, edits for owner+GM, print/PDF via @media print
├── dashboard.html          GM dashboard: roster, GM notes (GM-only), campaign journal feed
├── js/parser.js            RCC/OCC markdown parser (browser + Node + Functions)
├── data/classes/           One markdown file per RCC/OCC + index.json manifest
├── data/skills.json        Minimal skill catalog (name/category/base %) — expand as content work
├── data/spells.json        Minimal spell catalog (name/level/ppe) — expand as content work
├── data/psionics.json      Minimal psionic catalog (name/category/isp) — expand as content work
├── migrations/             D1 schema (0001) + deletable test rows (0002)
├── wrangler.toml           Local dev/migrations only — prod config is in the dashboard
└── test/smoke.mjs          Phase 1 smoke test

functions/api/character-creator/
├── _lib/auth.js            Reads the Zero Trust identity header (no new auth)
├── me.js                   GET /api/character-creator/me
├── classes.js              GET /api/character-creator/classes?system=&category=
├── campaigns.js            GET/POST /api/character-creator/campaigns
├── campaigns/[id].js       GET (gm_notes stripped for non-GM) · PATCH gm_notes (GM only)
├── items.js                GET /api/character-creator/items?system=
├── characters.js           GET list · POST save at level 1
├── characters/[id].js      GET sheet (+can_write/is_gm) · PATCH current stats/notes
├── characters/[id]/items.js        POST add inventory row (catalog slug or freeform)
├── characters/[id]/items/[itemId].js  PATCH qty/equipped/notes · DELETE (sets removed_at)
├── characters/[id]/xp.js           POST {delta|total} — updates XP, returns proposed level-up diff
├── characters/[id]/level-confirm.js  POST — applies confirmed/tweaked diff + logs level_history
└── journal.js              GET by campaign (+character filter) · POST entry

Leveling (`_lib/leveling.js`): default XP curve (house rule, level cap 15) used by
every class until a class file adds a cumulative `xp_table: [...]` frontmatter
override — no schema change needed. Pools grow on level-up only when their formula
has an explicit per-level dice ("P.E. + 1d6 per level"); skills advance by their
stored per_level × levels gained, capped at 98%.

Write permissions (in `_lib/auth.js`): reads are open to any authenticated friend;
writes require `characterAccess` (owner or campaign GM) or `campaignAccess` (GM only
for campaign-level journal entries). Every write endpoint uses these helpers.
```

## Adding a class

Drop a new `.md` file in `data/classes/` (copy an existing one for the schema)
and add its filename to `index.json`. Frontmatter drives creation/leveling;
`## Lore` and `## GM Notes` body sections are display-only.

## One-time production setup (Cloudflare dashboard)

1. **D1**: Workers & Pages → D1 → Create database → name it `character-creator-db`.
2. Pages project → Settings → Functions → **D1 database bindings** → add binding
   `DB` → `character-creator-db`. (Same dashboard-config pattern as `ANTHROPIC_API_KEY`.)
3. Copy the database ID into `wrangler.toml`, then apply migrations:
   ```
   cd apps/character-creator
   npx wrangler d1 migrations apply DB --remote
   ```
   `0002_test_rows.sql` is throwaway seed data — delete it before real campaigns start.

Auth is the existing site-wide Zero Trust gate; functions read the caller's
identity from the `Cf-Access-Authenticated-User-Email` header.

## Smoke test / local dev

```
node apps/character-creator/test/smoke.mjs   # parser + local D1 migration
# from repo root — serves site + functions + the same local D1 the migrations target:
npx wrangler pages dev . --d1 DB=00000000-0000-0000-0000-000000000000 --persist-to apps/character-creator/.wrangler/state
```
