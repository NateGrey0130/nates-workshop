# Prompt — G.M. grants in the character creator

Paste everything below the line into a fresh session.

---

The monorepo is at `C:\Users\natha\Projects\nates-apps`. Sessions start in
`Downloads`, so the repo's `CLAUDE.md` does not auto-load — read it before you
touch D1 or wrangler. Load the `ship-pr` skill before the first commit and the
`audit-menu` skill before the first outcome note.

## What we are building

A character can acquire skills, spells, psionic powers, abilities and stat
changes that **no class schedule granted**. The G.M. hands these out at the
table, usually verbally, and there is currently nowhere for them to go. Build
the interface and the workflow for them.

Four decisions are already made. Implement these, do not re-litigate them:

1. **Scope is everything.** Skills, spells, psionic powers, abilities, the
   attributes, the pool maxima (H.P., S.D.C., M.D.C., P.P.E., I.S.P.), and the
   combat and save bonuses.
2. **Both shapes.** A named grant ("you gain Boxing") lands on the sheet
   directly. A choice ("pick one Physical skill") banks something the player
   spends later through a picker. Both models already exist in the code — see
   below — and the point is to reuse them, not to invent a third.
3. **Permanent until removed.** No expiry, no suspend toggle, no durations.
   "For this session only" is the G.M. deleting it afterwards.
4. **The player enters it on their own sheet.** The G.M. says it out loud at
   the table; the player types it in. So this is **not** a G.M.-only feature and
   must not be gated to the G.M. The existing owner-or-G.M. guard
   (`requireCharacter`) is the right one.

Because anyone who can write the character can grant, **integrity comes from
the record, not from a permission wall**: every grant stores who added it, when,
and a reason, and it is visibly labelled as a grant everywhere it appears. A
grant that renders indistinguishably from a class skill is a failure of this
feature even if every number is right.

## Step one: write the plan, in its own PR

`apps/character-creator/docs/plans/` is the house format and
`docs/plans/README.md` explains what a plan is for. Plans 13–16 were written as
specifications ahead of the work; this is the same. Write
`docs/plans/19-gm-grants.md`, add its row to that README's table, and open a PR
with **no code in it**.

The plan must record the alternatives you rejected and why, because that
directory's whole value is the rejections. It must also settle, explicitly, the
five problems named under "What will bite you" below — a plan that leaves any of
them to implementation time has not done its job.

Then stop. I will read it before you write code.

## Then implement, one PR per slice

Propose the slices in the plan; I expect roughly:

- schema + endpoints, no UI, provable by `regression.mjs`
- named grants for skills / spells / psionics / abilities, on the sheet
- the stat half (attributes, pools, combat, saves)
- the choice half, folded into the existing picker
- docs

**One PR per slice. Merge on a separate word from me — opening a PR is not
permission to merge it.** Standing approval does not exist here; ask each time.

## What I found reading the code, which you must verify before trusting

I read this today and I am confident about it, but every line number and count
below is the kind of thing that goes stale between the reading and the writing.
**Check each claim against the tree before you build on it**, and lead your plan
with anything I got wrong. Assume at least one of these is already false.

### There is already a G.M. grant mechanism, and it is half of this feature

`functions/api/character-creator/characters/[id].js` has a `gm_abilities` branch
in `onRequestPatch`. It writes `{ name, gm: true }` objects into the `abilities`
JSON array, replacing only the gm-flagged subset and carrying the player's own
picks through untouched. `sheet.js` drives it with `addGmPower()` /
`removeGmPower()` / `gmPowerNames()`, and the README's field table documents the
shape.

It is guarded by `requireCharacter`, which allows the owner **or** the campaign
G.M. — so a player can already add one to their own character. Under decision 4
that is correct rather than a bug. Do not tighten it.

This mechanism should be **folded into the new one**, not left beside it. Two
ways to record a G.M.-given power is exactly the drift this repo keeps writing
comments about. Migrating the existing `{name, gm:true}` entries is part of the
work; say in the plan how, and whether any exist in production before you
assume the migration is a no-op.

### What is writable after creation, and what is not

`PATCHABLE` is `hp_current`, `sdc_current`, `mdc_current`, `ppe_current`,
`isp_current`, `notes`. `JSON_SECTIONS` is `bio`, `combat`, `saves`, `armor`.

So `combat` and `saves` are **already** freely writable by owner-or-G.M. today —
that half of decision 1 may be less about new capability than about making an
edit legible as a grant. Meanwhile `attributes`, `skills`, `powers` and every
`*_max` column have **no write path at all** outside creation and level-confirm.
That asymmetry is the shape of the work.

### The attribute funnel already exists — use it, do not fight it

`apps/character-creator/js/derive.js` keeps class bonuses **out** of the stored
attribute deliberately, and everything derived reads through one function,
`effective(attrs, bonuses)`. Its comment names three layers: the attribute
tables, what the class grants, and whatever a human typed. A granted +2 P.S.
belongs as a contributor to the `bonuses.attributes` block, **not** as a
mutation of `characters.attributes` — mutating it destroys the provenance the
whole file was built to preserve. `classBonuses` groups are `attributes`,
`combat`, `saves`, plus `attribute_minimums` floors.

`sheet.js` builds that bonuses object in more than one place (I saw three,
around lines 703 and 994–1009). Find them all; a fourth layer added to two of
three sites is a number that disagrees with itself between tabs.

### Pools are the opposite case, and this is the trap

`hp_max` and friends are scalar columns, and `onRequestPatch` **clamps every
current value against the stored max**. So if a granted +20 S.D.C. is derived on
read rather than written to the column, the player cannot fill it — the clamp
reads the un-granted column and silently caps them. Pools probably have to write
the column and keep the grant as history, which makes them behave differently
from attributes. Whatever you choose, say in the plan why the two differ,
because a reader will otherwise assume one of them is a mistake.

### The validator will reject a granted skill unless you exempt it

`_lib/validate-character.js` counts `type === 'related'` and
`type === 'secondary'` against `relatedAllowance()` / `secondaryAllowance()`,
and applies the class's category restrictions to related skills only. `occ` is
counted by neither. There is an `override` flag that skips the category check
and means "a human allowed this".

Four call sites run it: character create, `level-confirm.js`, `picks.js`, and
`admin/audit.js`. A granted skill that is not exempt does not merely fail to
save — it makes the character fail validation on **every later write** and show
up in the admin audit as broken. It also has a `powers` check that already
exempts class-auto-granted powers; granted spells need the same treatment or
the identical problem appears there.

### A new skill type is invisible until you fix both render sites

`sheet.js` hardcodes `['occ', 'related', 'secondary']` twice — once for the play
lens (~line 752) and once for the sheet lens (~lines 1263–1265). A skill stored
with a fourth type is written, saved, advanced correctly, and **never appears on
screen**. There is also a level-up diff row that prints `s.type` raw.

### Level-up already advances a granted skill for free

`js/leveling.js` advances every skill with a `pct` and a `per_level`, with no
regard for its type. So a granted skill improves on level-up without you doing
anything — confirm this is what we want and say so, rather than discovering it.

### The precedents to copy

- **Pending grants**: `pending_skill_picks` and `pending_power_picks`, with
  their `insertGrantStatements` / `claimStatements` helpers and the spending
  routes `characters/[id]/picks.js` and `characters/[id]/power-picks.js`. The
  choice half of this feature is probably a `source` column on those two tables
  plus a reason, not a third table — but note that `picks.js` re-validates the
  merged skills, so a G.M.-granted choice spent as a related skill will trip
  the allowance ceiling unless the exemption above lands first. **These two
  problems are the same problem; solve them together.**
- **A revocable record with provenance**: `campaign_items` — `added_by`,
  `added_at`, `removed_at`, `removed_by`, and a link to the journal entry that
  explains it.
- **Commentary rather than a ledger**: `play_events`. Read its header comment
  before deciding whether grants are events or rows; the distinction it draws
  is the one you are about to make.

### Housekeeping that is easy to miss

- Migrations run to `042-skill-base-formula.sql`. Yours is 043. Schema changes
  are applied to production **before** the merge that needs them, and `.sql` is
  pinned to LF by `.gitattributes` while the rest of the repo is CRLF.
- `characters/[id].js`'s DELETE handler carries a comment listing everything
  that goes with a deleted character. A new table needs its `ON DELETE CASCADE`
  **and** a line in that comment.
- The README's API-surface table needs a row per new route; its pinned counts
  are enforced by the smoke test, not by discipline.
- `docs/known-limitations.md` and `docs/house-rules.md` are both places this
  feature changes a stated truth. Check whether either says a G.M. cannot do
  something you are about to make possible.

## Verification

- The merge gate is the flagless `node apps/character-creator/test/smoke.mjs`.
  A `--section` run prints `PARTIAL` and does not count. Run the full one after
  writing any outcome note, not before.
- Anything touching an endpoint, the schema or a data script gets
  `node apps/character-creator/test/regression.mjs`. Give it a long timeout —
  it exceeds the two-minute default.
- `node scripts/drift-check.mjs --remote` before merging as well as after.
- **Drive anything visible in a browser.** Use the `nates-apps-8793` entry in
  `C:\Users\natha\Downloads\.claude\launch.json`; port 8788 belongs to another
  worktree and serves stale data. Screenshot it — metrics have said a control
  worked while the screenshot showed it below the fold.
- Print matters for the sheet. A print change needs a real print render:
  `chrome.exe --headless=new --disable-gpu --no-pdf-header-footer
  --virtual-time-budget=20000 --print-to-pdf="<ABSOLUTE Windows path>" "<url>"`,
  read back with `pymupdf`.
- Probe data goes in **local** D1 and comes back out. Snapshot before, restore
  after, and check `character_drafts` at the end.
- A merge commit on `origin/main` proves nothing about what is live. Confirm the
  Pages deploy and then ask production.
- Do not `sed -i` a repo file — it strips CRLF across the whole file and the
  obvious grep check reports clean anyway.

## Posture

Log and label, do not block. A grant is a record of a table's decision, so
nothing here should refuse a number a human insisted on — the validator's
`override` flag is the model. Where a grant would break a class rule, the app
says so and stores it anyway.

If a slice cannot be finished safely, leave its PR open, say why, and stop.
Out-of-scope discoveries become numbered findings in the appropriate audit
file — never fixes smuggled into this feature's PRs.
