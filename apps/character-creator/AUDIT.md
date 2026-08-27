# Character creator — audit, 2026-08-23

Read-only investigation of `apps/character-creator/**`,
`functions/api/character-creator/**`, the character-creator tables in
`db/schema.sql`, the shared code it depends on (`shared/`,
`functions/api/_lib/`, `functions/api/claude.js`), and every in-scope document.
Verified against the code as of `main` @ `6ada3ee`, against production D1 where
a count was claimed (`--remote`, per the repo's own rule), and against a clean
run of both test suites: **smoke 1,220 checks passed, regression 192 checks
passed** on this machine before any change was made.

**All fourteen items are closed**, re-verified against the tree on 2026-08-26.
D1–D6 and C1–C2 were fixed in the PR that produced this audit and are recorded
under *Fixed in this PR*, each with its own `**Fix**:` line; F1–F5 were taken on
2026-08-24 and carry `**Taken**` notes below; F6 is an information item whose
verdict is *keep it*, with no action ever proposed.

> **Read that paragraph before grepping this file for open work.** Two separate
> scans have now reported D1–D6 and C1–C2 as outstanding, because the outcome of
> a finding fixed in its own PR is a `**Fix**:` line under a section heading
> rather than a `**Taken**` bullet under the finding. The same trap in a
> different shape sits in `apps/media-vault/ISBN-AUDIT.md`, where F7's *first*
> outcome bullet says **Held** and its second, further down, says **Taken**. An
> outcome here is prose, and prose has to be read.

> **The character-creator README was split on 2026-08-26** (PR #309) into an
> 827-line spine plus eleven topic files under `apps/character-creator/docs/`.
> No section was renamed, so every section *name* below still resolves — but
> the `README.md:NNN` line numbers and file paths in this document are as of
> the audit date above, and several sections cited here now live in `docs/`.
> Find one by name rather than by number:
>
> ```bash
> node scripts/readme-section.mjs "Server-side rule enforcement"
> ```
>
> It searches README.md and every `docs/*.md`, and prints the file and the line
> range.

## The audit brief itself was stale, and that is the first finding

The request described the app as it stood several refactors ago. None of this
is a defect in the code — it is recorded so the next audit starts from reality:

- **There are no static catalogs.** `skills.json` / `spells.json` /
  `psionics.json` do not exist; the catalogs live in D1 (`skills`, `spells`,
  `psionic_powers`, `gear`, `enchantments`), seeded once by
  `db/seed-catalogs.sql` and grown by the importers.
- **There are no class markdown files in the repo.** Class definitions live in
  `imported_classes.markdown` in D1; the repo recreates them through
  `apps/character-creator/db/add-*-class.sql` data scripts, and
  `scripts/repo-vs-live.mjs` proves it can.
- **"Six character-creator tables" is now twenty-five** (plus MediaVault's
  `media_items` and the shared `schema_migrations`), with a 36-file migration
  history under `db/migrations/`.
- **The `items` rename already happened.** Migration `004-items-to-gear.sql`
  renamed the table to `gear` in the app's first roadmap (PR #17), precisely
  for the collision-with-`media_items` reason the brief raises. The API route
  stayed `/items` deliberately; `docs/known-limitations.md` → *Known
  limitations* records the trade. Nothing to decide — closed years of PRs ago.
- **Server-side rule enforcement exists** (`_lib/validate-character.js`,
  `_lib/skill-picks.js`, `_lib/power-picks.js`, race/O.C.C. restrictions on
  create). The gap the brief describes has narrowed to a deliberate,
  documented residue — quantified in finding F2.
- `seed-dev.sql` exists at `apps/character-creator/db/seed-dev.sql`, carries
  the `-- local-only` marker, and the documented local-dev recipe works — the
  regression suite builds a database from nothing with exactly those files and
  drives the real endpoints.

## Category verdicts in one line each

- **Documentation accuracy**: good overall — most counts are pinned by the
  test suite and two prior claim-audit passes cleaned the big lies. Six real
  drifts found, all small, all fixed in this PR (D1–D6).
- **Database health**: clean. Sensible cascades, guarded migration seeding,
  index coverage matches the actual query patterns at the actual scale
  (~4.4K rows total); no N+1, no JSON column being filtered in SQL. Nothing to
  fix.
- **Code structure**: the deduplication the README claims is real (one
  `api()`, one `escHtml`, shared dice/leveling/compose modules, shared auth
  guards, one import engine). Dead code is held at zero by a smoke check. Two
  small consistency gaps fixed (C1, C2).
- **Security/auth**: every one of the 46 endpoints carries the right guard —
  no exceptions found. The remaining exposure is design posture, not bugs;
  flagged as proposals (F1–F4).

---

## Fixed in this PR

### D1 — low — README describes five pages; the app has six

- **Doc says**: "styles.css — All five pages", "js/api.js — The one HTTP
  helper for all five pages", "`js/api.js` is loaded by all five pages"
  (README.md:100, 119, 199); the *Where everything lives* file map lists
  `index`/`sheet`/`dashboard`/`import`/`catalog` and no campaign page; the
  page-script size table has no `campaign.js` row.
- **Code does**: `campaign.html` + `campaign.js` (643 lines) shipped with the
  campaign-notes PR and loads `js/api.js` like the rest (campaign.html:32).
- **Which is right**: the code. The campaign page is fully documented in its
  own README section — only the inventory prose never learned it exists.
- **Impact**: the size table is pinned by a smoke check that verifies only the
  rows *present*, so `campaign.js` could drift unboundedly; the file map is
  the first thing a newcomer reads.
- **Fix**: six pages, file-map entries, and a `campaign.js` row in the size
  table (which the existing 25% smoke check then pins automatically).

### D2 — low — "18 of the 24 migrations fail on a fresh database" is doubly stale

- **Doc says**: README.md:4996 and `.claude/skills/schema-change/SKILL.md:81`
  both say "18 of the 24".
- **Code does**: `db/migrations/` holds **36** files; classifying each first
  executable statement, **26 of 36** fail on a schema.sql-built database (the
  ALTERs and the `items` rename; the pure `CREATE TABLE IF NOT EXISTS` ones
  and 036's table rebuild pass).
- **Which is right**: neither number matters — this is exactly the
  count-in-prose shape the claim-audit skill warns about, gone stale twice
  (24→36 silently). Nothing recomputes it.
- **Fix**: reworded both places to state the *mechanism* without a pinnable
  count: the ALTER-based majority fail (`duplicate column name: bio`,
  `no such table: items`); only the pure-CREATE migrations pass.

### D3 — low — the wizard-step prose stopped at steps version 2

- **Doc says**: the step diagram (README.md:2076) shows nine steps ending
  `… Powers → Details → Review`, and "version 1 is the eight-step list …
  version 2 is the nine above" (README.md:2159) reads as current.
- **Code does**: `app.js:29` has ten steps with **Advancement** after Powers,
  and `STEPS_VERSION = 3` with a chained 2→3 draft migration (app.js:372–392).
- **Which is right**: the code; the *Starting above level 1* section even
  documents the Advancement step — only the diagram and the draft-version
  paragraph predate it.
- **Fix**: diagram shows Advancement (marked as appearing only above level 1),
  and the draft-version paragraph records version 3.

### D4 — low — plans README contradicts itself about what shipped

- **Doc says**: "Four plans written in an interview on 2026-08-20 and **not
  yet built**" (docs/plans/README.md:54) — directly above a table marking all
  four **built**.
- **Which is right**: the table; PRs #13–#16-era work is merged and the app
  README documents all four features.
- **Fix**: the sentence now says they were written as specifications and have
  all since shipped.

### D5 — low — SETUP.md's project tree is stale in two ways

- **Doc says**: the `.claude/skills/` listing names three skills
  (SETUP.md:54–56); and the R2 paragraph plus its two commands sit *inside*
  the project-structure code fence (SETUP.md:72–82), so prose renders as code.
- **Code does**: five skills exist (`book-survey` and `claim-audit` missing
  from the tree — the latter being the one this very task needed).
- **Fix**: all five listed; fence closed after the tree, R2 note moved out
  with its commands in their own block.

### D6 — low — the file map still calls `docs/plans/` "the twelve original PRs"

- **Doc says**: README.md:136 ("The twelve original PRs, with their rejected
  alternatives"); §Known limitations repeats "the original twelve".
- **Code does**: the directory holds 18 plans plus two shipped proposals; its
  own README covers all of them.
- **Fix**: described as the planned PRs and proposals, with the twelve-first
  history left to the plans README, which tells it correctly.

### C1 — low — four write endpoints 500 on a malformed JSON body

- **What's wrong**: `_lib/auth.js` provides `readJson()` so a bad body is a
  400, and most write endpoints use it — but four call `request.json()` bare:
  `characters/[id]/xp.js:16`, `characters/[id]/level-confirm.js:32`,
  `characters/[id]/items.js:12`, `characters/[id]/items/[itemId].js:82`.
- **Impact**: a malformed body (or an empty POST from a curl probe) surfaces
  as an opaque 500 instead of the "Invalid JSON body" 400 every sibling
  endpoint returns. Cosmetic in practice, but it is the one inconsistency in
  an otherwise uniform error-handling story.
- **Fix**: all four now use `readJson()` and return the standard 400.

### C2 — low — the parser's worst authoring trap failed with a misleading error

- **What's wrong**: the hand-rolled YAML subset reads inline `[...]` / `{...}`
  values on one line only. A flow list wrapped across lines
  (`from: [` … `]`) parses the `[` as a scalar string and the following lines
  as structure, and the eventual error (`equipment_starting entries must be
  objects`, or similar) points nowhere near the cause. This has burned real
  class-authoring sessions (it is memorialised in the class-import workflow),
  and 15 more Palladium O.C.C. transcriptions are queued to hit it.
- **Fix**: `scripts/class-check-lib.mjs` gains `unclosedFlowLines()` — a lint
  that names the exact frontmatter line that opens a bracket it never closes —
  and `class-check.mjs` prints it as a warning with the two accepted rewrites
  (one line, or a block sequence). Checker-only: zero runtime code changed,
  behaviour pinned by new smoke checks, and verified clean against all 76
  published classes in production.

---

## Flagged, not fixed — decisions that are yours

### F1 — medium — creating a character in a campaign is how you join it, and nothing gates it

- **What**: membership is (correctly, per the documented design) "GM or owns a
  character in the campaign" (`_lib/auth.js:115`). But
  `POST /characters` checks only that the campaign *exists*
  (characters.js:73) — any authenticated person can create a character in any
  campaign, and from that moment reads and writes its notes, stash, ledger
  and NPC dossiers, uploads portraits, and appears on the GM's roster.
- **Impact**: on a friends-only site behind Access this is arguably the
  intended "pull up a chair" model, and the wizard's campaign picker already
  offers every campaign to everyone. But it means a GM has no say over who is
  in their campaign, and the member-gating on campaign notes (deliberately
  narrower than the rest of the app) is one self-service INSERT away from not
  gating anything.
- **Proposal**: either bless the current model in the README's Permissions
  section in so many words ("anyone on the site may join any campaign by
  making a character in it"), or add a GM-controlled gate — the cleanest is a
  `campaigns.open` flag defaulting to today's behaviour, checked only in
  `POST /characters`, so `campaignAccess()` stays the single place that knows
  what membership is. Not done here because it changes who-can-do-what, which
  is not an auditor's call.
- **Taken, 2026-08-24**: migration `037-campaign-open.sql` adds
  `campaigns.open` (default 1 — every existing campaign stays an open table).
  `POST /characters` refuses a closed campaign to anyone but the GM and
  existing members, through `campaignAccess()`; the GM dashboard carries the
  toggle, and the wizard's picker shows a closed campaign disabled with the
  reason. Regression pins the refusal, both allow paths, and that the toggle
  is GM-only.

### F2 — medium — what a crafted request can still write, quantified

The brief asked what the client-trust gap actually allows. After PR #26 and
its successors, the honest inventory — all of it requiring owner-or-GM rights
on the character, so the blast radius is *your own character* (or your
campaign's, if you are its GM), never someone else's:

- **Pools**: create and level-confirm accept any numeric maxima
  (characters.js:170, level-confirm.js:47–57) — the dice are rolled
  client-side by design. Play events set any current value
  (events.js:52–58).
- **Skill percentages**: level-confirm accepts arbitrary `pct` for existing
  skills (level-confirm.js:61–70). New picks are the exception — they resolve
  against the catalog server-side, so a pick cannot invent numbers.
- **Powers at creation**: the `powers` array on create is stored unvalidated
  (characters.js:168) — counts, spell levels and named-list membership are
  enforced only for *level-up* picks (`resolvePowerPicks`). A crafted create
  can know every spell in the book at level 1.
- **Attributes**: minimums are enforced (validate-character.js:167–170);
  maxima/point-buy are not, so IQ 30 at creation passes.
- **Rolled bonuses**: `attribute_bonuses` / `rolled_bonuses` are stored as
  claimed (characters.js:166–167) — "my dice came up maximal, every time".

What this can *not* do: touch another player's character, another campaign's
data, any catalog row, or produce a 500/injection — every write is
parameterised, JSON-stringified, and shape-checked. The remaining trust is
about game-fairness among friends, exactly as `docs/wizard-and-sheet.md` →
*Server-side rule enforcement* frames it ("deliberately narrow — it checks
what a player
chooses"). `docs/plans/10-server-rule-enforcement.md` already records why
choice-groups can't be checked in principle.

- **Proposal**: if this ever matters (strangers on the site), the highest
  leverage additions in order: validate creation-time powers through the same
  `resolvePowerPicks` machinery; recompute pool maxima server-side from the
  class formulas with a tolerance for GM overrides; cap attributes at the
  book's roll ceiling per attribute-dice. Each is a real project; none is a
  doc fix. The admin audit endpoint is the right home for a first read-only
  pass.
- **Taken, 2026-08-24**: all three, in the proposed order and posture.
  Creation-time powers are **violations** (counts against starting + climbed
  grants, spell-level caps, psionic categories, named lists, catalog and
  system membership; auto-granted powers exempt, ambiguous grant attribution
  never guessed at). Pool maxima are bounded by `poolFormulaBounds` — the same
  parse walk the roll takes with every die pinned to its extremes — and
  attributes by `attributeCeiling`, exceptional chain included; both are
  **warnings**, since a class re-import or a table ruling can explain them,
  and both surface in `admin/audit`, which now receives powers, pools and each
  campaign's system. The audit's composition also now decodes the character
  first, so ability-granted pool bonuses fold in rather than reading as out of
  range. `docs/wizard-and-sheet.md` → *Server-side rule enforcement* carries
  the full rules.
- **Follow-up taken, 2026-08-24 — the pool hard cap**, with the proposal's own
  "tolerance for GM overrides" as the design: at creation,
  `pool_out_of_range` is a **violation for any creator who is not the
  campaign's GM** (`enforcePools` in the validator; the create endpoint sets
  it from the verified caller vs `gm_email`). The GM keeps the warning — a
  ruling beats a computed number, and transcribing a long-running character
  faithfully is that case. The audit stays advisory (no retro-validation) and
  level-confirm's sanctioned tweaks are untouched. Attribute ceilings remain
  warnings for everyone: Manual entry exists for numbers a table decided.

### F3 — low — `/api/claude` is an unmetered spend endpoint for every authenticated friend

- **What**: `functions/api/claude.js` checks no identity at all — Access is
  the only gate. Any logged-in friend can POST up to 50 messages × 20 PDF
  blocks (~15MB each) to `claude-opus-5` at 16K max tokens per call, in a
  loop.
- **Impact**: not a data risk (the key never leaves the server; the model
  allowlist and token ceiling hold) — a billing one, bounded by how much you
  trust the ≤50 people on the Access list.
- **Why not fixed**: `claude.js` / `claude-client.js` are shared code —
  FilamentForge and MediaVault call this proxy, and any change to its
  gating/limits alters their behaviour. Out of scope by your own rule.
  **Blast radius of any future change**: FilamentForge's generate flow and
  MediaVault's lookups both break if the proxy grows an auth requirement
  their pages don't send; a per-email daily token budget inside
  `claude-client.js` would be invisible to them until the day it triggers.
- **Proposal**: if you want a belt: log `usage` per email (one D1 table, one
  INSERT in the proxy), alert on it, and only then decide whether a hard cap
  is worth the shared-code churn.
- **Taken, 2026-08-24**: the log half, as proposed — no cap. `claude_usage`
  (migration 038) records email, endpoint, model, tokens and upstream status
  for every proxy call and every campaign Ask; the admin importers stay
  unlogged because they are already gated to one email. Written **fail-open**
  inside `claude-client.js`, so metering can never break the call it measures
  — which is the property that keeps FilamentForge and MediaVault
  behaviourally untouched. The reading query lives in SETUP.md.
- **Superseded in part, 2026-08-27** (INGESTION-AUDIT F7, PR #347): the
  importers are no longer unlogged. Gating them to one email answered who may
  spend the key; it never answered what was spent, and a class extraction
  sends a whole PDF page — the most expensive call in the repo, and the only
  one with no number on it. Every Claude call in `functions/` meters now
  (`cc-import-class`, `cc-import-<catalog>`, `cc-npc-sweep`), still fail-open
  and still with no cap. The rest of this note stands.

### F4 — low — identity is a trusted header, not a verified JWT (accepted posture, worth stating once)

- **What**: `getAccessEmail()` reads `Cf-Access-Authenticated-User-Email`
  (access.js:8–10) and `getUserEmail()` falls back to `dev@localhost` only
  when the request hostname is literally `localhost`/`127.0.0.1`
  (auth.js:10–11). In production that fallback is unreachable — Cloudflare
  routes by Host, and Access fronts every route including `/api/*` — and
  Access strips/injects the header itself, so it cannot be spoofed *through*
  the front door.
- **Residual**: the guarantee is entirely Access's. If the Access application
  is ever disabled, mis-scoped after a domain change, or a route is exempted,
  every endpoint trusts a client-suppliable header with no second check.
  Cloudflare's own recommendation for defence-in-depth is validating the
  `Cf-Access-Jwt-Assertion` JWT against the team's public keys.
- **Proposal**: fine to accept for this site (SETUP.md already documents the
  posture); if you ever add a custom domain or loosen the Access app, JWT
  validation in `access.js` is a one-file change — it is the single place the
  header is read, which is the design paying off.
- **Taken, 2026-08-24**, with one refinement on the proposal: verification
  lives in Pages middleware (`functions/api/_middleware.js` +
  `_lib/access-jwt.js`) rather than inside `getAccessEmail()`, because the
  header read is synchronous in 46 endpoints and JWT verification is not —
  the middleware verifies once per `/api/*` request and requires the token's
  email claim to match the header everything downstream reads. **Opt-in**:
  pass-through until `ACCESS_TEAM_DOMAIN` and `ACCESS_AUD` are both set
  (SETUP.md says where to find them), so the deploy is a no-op until the
  dashboard half is done. Signing keys are cached per isolate with
  stale-on-failure; configured-but-unverifiable is a 503 naming the fix, never
  a silent fall-back to header-trust. The verifier is a pure function and the
  smoke suite signs real tokens to prove every refusal path.
- **Armed, 2026-08-24**: `ACCESS_TEAM_DOMAIN` and `ACCESS_AUD` live in
  `wrangler.jsonc` `vars` — this project manages plain variables through its
  wrangler config, and neither value is a secret (the AUD rides in every
  login redirect URL). The middleware gained a `localhost` exemption, the
  `dev@localhost` precedent, because local dev reads the same vars with no
  Access to mint a token. Arming also closed a hole noticed on the way:
  **preview deployments sit outside Access** with production bindings and a
  client-suppliable identity header — armed, their `/api/*` refuses
  everything, proven live against a preview URL before the merge. Preview
  deployments built *before* this change still carried the old pass-through
  code at public branch-alias URLs — closed later the same day by the
  **Restrict previews** toggle in the Pages settings, which puts every
  preview URL (old deployments included) behind a Cloudflare Access policy at
  the edge; verified by probing three previously-public preview URLs, all now
  302 to the Access login. That policy is auto-created and separate from the
  site's Friends Only policy — a friend who ever needs to see a preview needs
  adding there, in Zero Trust.

### F5 — low — `/classes` ships ~750KB of parsed class markdown on every boot

- **What**: 76 published classes total 747,934 bytes of markdown in
  production; `GET /classes` returns all of them parsed (lore and GM-notes
  prose included), with no cache headers, and three pages fetch it on load.
  The wizard genuinely needs the full data; the **GM dashboard** fetches all
  of it to build an id→name map for a five-row roster
  (dashboard.js:20, 26).
- **Impact**: modest — Cloudflare compresses it to roughly a fifth on the
  wire, and this is a friends-scale app. It is the single heaviest response
  in the app and grows with every imported class.
- **Proposal**: cheapest first: an `ETag` from `max(updated_at)` over
  published classes (one query, saves the whole body on every warm load);
  independently, a `?names=1` projection for the dashboard. Neither is done
  here — both change response semantics for shared endpoints, and the current
  cost doesn't force it.
- **Taken, 2026-08-24**: both halves, as proposed. `/classes` sends a weak
  `ETag` over `count + max(updated_at)` of published classes with
  `Cache-Control: private, no-cache`, so a warm boot revalidates to an empty
  304 — the browser's fetch handles If-None-Match transparently, so `api()`
  needed no change. `?names=1` serves `{ id, name }` off the table with no
  parsing (retired included, since its one job is labels), and the GM
  dashboard now uses it. Regression pins the validator, the 304 round-trip,
  and that the projection covers every published class.

### F6 — info — the YAML parser's no-deps trade is still the right one, with eyes open

The brief asked directly. Verdict: keep it. The subset parser is ~200 lines
(parser.js:1033–1242), documents its own limitations in-code, and is held by
the heaviest test coverage in the repo (the smoke suite pins parsing,
composition and every class in the fixture corpus; regression re-parses all
76 live classes). A real YAML dependency would remove two authoring traps —
multi-line flow lists (now linted, C2) and same-indent block lists (README
documents it; the parser returns `null` for the form standard YAML accepts) —
at the price of the first dependency in a zero-dependency repo, a build
question for the browser/Workers dual use, and behavioural drift risk across
76 stored classes whose exact current parse *is* the contract. The traps are
authoring-time and now both loudly diagnosed; the parser itself has not been
the source of a shipped data defect in the audit trail.

## Verification for this PR

- `node apps/character-creator/test/smoke.mjs` — passes (existing checks plus
  the new `unclosedFlowLines` section).
- `node apps/character-creator/test/regression.mjs` — passes; also proves the
  documented fresh-environment recipe end to end.
- Manual browser pass against local dev per the brief: character created
  through the wizard, sheet loaded, journal entry written, inventory added
  and removed, XP → level-up confirmed, GM dashboard rendered.
- No schema change, no data script, no shared-code behaviour change, no new
  environment variable.
