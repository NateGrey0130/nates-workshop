# MediaVault — sharing one vault, read-only: design menu

A feature menu, findings `V1`…`V7`, to be taken one at a time. **Nothing here is
built and nothing here is approved as a whole** — taking the shape is not taking
the findings, and each one is a separate decision and a separate PR.

**Read each finding's own note for its state.** This header carries scope and
method only. `BULK-AUDIT.md`'s header records what happens when a summary of
per-finding state lives up here: two statements three lines apart disagreed from
the moment the second was written.

**The prefix is `V`, and deliberately not `S`.**
`apps/character-creator/CLASS-AUDIT.md` numbers its schema items `S1`…`S9` — as
bullets under `## Schema-can-now-express`, not as headings — so a second menu
putting `S` in a heading would make a bare `S3` name neither. No menu in this
tree uses `V`. Cite these from outside this file as `SHARE-AUDIT V3`, per
`audit-menu` → *Which is why a finding reference names its menu*.

**Investigated 2026-09-08** against `110e52f`. Written from a design
conversation with Nate the same day, in which five questions were put to him and
answered. Those answers are scope, not proposals, and the findings below assume
them.

## What Nate settled, 2026-09-08

| | |
|---|---|
| **Who the viewer is** | someone already on the site's Access allow list. The share lives entirely **inside** the login wall |
| **Who manages the grants** | the vault's **owner**, self-serve — which makes it a table rather than configuration |
| **What the viewer sees** | the **whole record**, `location` and `notes` included. No field projection |
| **Where the candidates come from** | a **closed picker** — the modal offers only addresses that can actually sign in |
| **How the allow list is maintained** | by Nate, by hand, in the Zero Trust dashboard, as it is today. A user who wants someone added asks him first |

### Two options were declined, with reasons, so they are not re-proposed

**A link anyone could open (no Access session).** It needs a second Access
application with a Bypass policy — the destination cap is **five per
application** and *Pick 3 Cut 5 (public)* has spent all five
(`GET /accounts/{id}/access/apps` through the `cloudflare-api` MCP plugin,
2026-09-08). It is dashboard-only work: the `CLOUDFLARE_API_TOKEN` cannot reach
Access at all, and the plugin **reads** Access but its writes return
`10405: Method not allowed for this authentication scheme` (`CLAUDE.md` → *Three
credentials*). It would also add a second public route to
`PUBLIC_PATHS` in `functions/api/_middleware.js`, which
`apps/pick3cut5/test/smoke.mjs:241` asserts contains **no entry without a
matching file under `functions/api/pick3cut5/`** — so it turns another app's
suite red until that derivation is generalised. Not a reason it cannot be done;
a reason it is a different and larger decision than the one taken here.

**Reading the Access allow list live from a Function.** It is the only option
that cannot go stale, and it was declined because it puts a standing
account-scoped Cloudflare API credential inside the Pages deployment to serve a
five-address list that changes about twice a year. `V4` carries what was taken
instead, and what that costs.

## How this was verified

Everything below was measured on **2026-09-08** unless it says otherwise.

- **Source** — `functions/api/media-vault/*.js`, `_lib/common.js`,
  `functions/api/_middleware.js`, `functions/api/_lib/access.js`,
  `apps/media-vault/{index.html,app.js,README.md}`,
  `apps/media-vault/test/smoke.mjs`,
  `apps/character-creator/test/checks/documented-counts.mjs`,
  `apps/character-creator/sheet.js`, `db/schema.sql`. Line numbers are from
  `110e52f` and are the thing most likely to have moved by the time a finding is
  taken.
- **Production D1**, read-only aggregate:
  `node scripts/q.mjs --remote "SELECT user_email, count(*) … FROM media_items GROUP BY user_email"`
  → `lillcreeper@gmail.com` **3,637 rows**, `nathanrapert@gmail.com` **2**,
  ~625 KB of text and cover URLs across both.
- **Cloudflare Access**, read-only through the `cloudflare-api` MCP plugin:
  `/accounts/{id}/access/apps` and `…/policies`. Three applications; the
  site-wide *Friends Only* allow policy names **five** addresses.
- **Production HTTP**, unauthenticated `curl`, used only to settle the declined
  fork above.
- **No writes of any kind were made**, to D1, to Access, or to the repo beyond
  this file.

## V1 — high — `media_shares`, and the six places a new table lands

The grant is a row: who is sharing, with whom, since when.

**Proposal.** Add `media_shares (owner_email, viewer_email, created_at)`, primary
key on the pair. Owner-side endpoints in one new file, all of them scoped to the
caller the way every existing statement is — `GET` returns
`{ sharedByMe, sharedWithMe, candidates }`, `POST { email }` grants,
`DELETE ?email=` revokes. **Posture: additive.** No existing endpoint changes
behaviour, no existing column moves, and a MediaVault user who never opens the
Share modal cannot tell the difference.

Name it `media_shares`, not `mv_shares`. `apps/character-creator/README.md:182`
states the rule — *"this app's tables are unprefixed, so anything another app
adds must not be"* — and `media_` is already the prefix its sibling `media_items`
carries.

**Revocation is a delete, and it takes effect on the viewer's next request.**
Whatever is already painted on their screen survives until they reload, because
the client holds the whole library in memory. Say that in the modal rather than
pretending otherwise — it is the same honest contract the bulk-delete undo toast
already makes about its buffer (`apps/media-vault/README.md` → *Undoing a bulk
delete*).

**The six places**, from the `schema-change` skill. Steps 6–8 of its nine are
character-creator-specific — a catalog's field config, `catalogs.js`, and
`_lib/character-json.js` — and none applies to this table:

1. `db/migrations/050-media-shares.sql`, ending by recording itself
2. the `CREATE TABLE IF NOT EXISTS` in `db/schema.sql`
3. the **guarded** seed row in `db/schema.sql`, guarded on the table existing
4. the migration table in `apps/character-creator/docs/operations.md`
5. the data model in `apps/media-vault/README.md`
6. `apps/character-creator/README.md:182` — *"Thirty-six tables in one shared D1
   database"* → thirty-seven, spelled as a word and parsed back out of the prose
   by `apps/character-creator/test/checks/documented-counts.mjs:160`

Step 6 is what catches the others; `V5` is the part of it that is not obvious.

**Evidence.** Read `db/schema.sql`, `apps/character-creator/README.md:182`, and
`.claude/skills/schema-change/SKILL.md`, 2026-09-08. The migration number `050`
is the next free one after `049-spell-same-spell-as.sql` **as of that day** and
is the single most likely thing here to be stale — check `ls db/migrations`
before writing it.

**Confidence: high** on the table and the six places, both read rather than
recalled. **Medium on the endpoint shape**, which nobody has built against;
writing `shares.js` is what would raise it.

**Ongoing cost.** One more table in every `schema.sql` read, one more row in the
migration table, and a table count that a future table has to move again. The
count is already pinned by a test, so it cannot rot silently.

**Taken, 2026-09-08 (PR #841).** Posture held: **additive**. No existing
endpoint changed, no existing column moved, and `media_items` is untouched —
`db/schema.sql`'s diff is one `CREATE TABLE`, one index and one guarded seed row.

**Two of this finding's own premises were false, and both were the *claim about
another file* shape this menu's own header warns about.** Found by the
`audit-premise-auditor` pass before scoping, and corrected in the work rather
than in the finding above, because these files are records:

<!-- claim-ok: quoting the two premises this note corrects -->

| the finding said | what was true |
|---|---|
| place 1: `db/migrations/050-media-shares.sql` | **`050` was already taken** by `050-catalog-pair-dismissals.sql`, merged 13:26 on 2026-09-08 — six hours *before* this menu was written, and an ancestor of the `110e52f` baseline it names. Shipped as `051-media-shares.sql`. Nothing in the suite checks migration-number uniqueness, and filename order is execution order, so a second `050-` would have been silently wrong |
| place 6: *"Thirty-six tables … → thirty-seven"* | `apps/character-creator/README.md:182` already said **Thirty-seven**. The edit was thirty-seven → **thirty-eight**. Following the finding literally would have written a no-op and failed `documented-counts.mjs` |

Both errors point the same way: **the menu was written against a tree one merge
older than the one it claims.** The line number in place 6 was right; only the
quoted words were wrong, which is exactly the shape that gets believed.

**A third correction, to `V5`.** `notOurs` is at `documented-counts.mjs:205`,
not `:204`.

**The endpoint was built and exercised, which is what the Confidence line
asked for.** `wrangler pages dev` on port **8803** (not 8788 — another worktree
listens there), local D1 with `051` applied, fifteen calls against
`/api/media-vault/shares`:

- a grant appears in the owner's `sharedByMe` and the viewer's `sharedWithMe`,
  read back under two different identities via `Cf-Access-Authenticated-User-Email`
- `Friend@Example.com` is stored and returned as `friend@example.com`
- a second identical POST leaves **one** row — the pair key makes it idempotent
- self-share, a malformed address and an empty body are each refused 400
- `DELETE ?email=FRIEND@example.com` revokes the lowercased row, and both sides
  read empty afterwards

**One branch was untested until it was noticed, and it is worth recording why.**
Sharing with yourself first returned *"Needs an email address to share with"*
rather than *"That is your own library"*: local dev's identity is
`dev@localhost`, which has no dot after the `@` and fails the shape test before
the self-check runs. The branch was then exercised under a real-shaped identity
and is correct, case-insensitively. **The consequence for anyone testing locally
is that `dev@localhost` cannot be granted to at all** — use a header identity.

**Two departures from the finding as written, both declared rather than
silent:**

- **`candidates` is not in the GET yet.** The finding's proposal names
  `{ sharedByMe, sharedWithMe, candidates }`. `candidates` is `V4`'s entire
  subject and `V4` is later in the running order, so it arrives with `V4`
  rather than being invented here.
- **A cap of 50 grants per owner was added**, which the finding does not
  mention. Until `V4` closes the list, POST accepts any address of email shape,
  and an uncapped write endpoint is the kind of thing that is cheap now and
  awkward later. It is a ceiling rather than a policy — the real bound is `V4`'s
  picker, which will offer four addresses.

**An unexpected check caught a real defect.** `MAX_SHARES` was first written as
an `export`, and *"no export is named nowhere else"* failed it —
`functions/api/media-vault/shares.js: MAX_SHARES - import it, un-export it, or
delete it`. Un-exported.

**Applied to production BEFORE the merge**, per `ship-pr`'s ordering rule, and
verified by asking production rather than by reading an exit code:
`media_shares` exists in `sqlite_master`, `schema_migrations` holds
`051-media-shares.sql` at `2026-09-09 01:21:52`, the table has **0 rows**, and
`node scripts/drift-check.mjs --remote` prints `NO DRIFT`.

## V2 — high — exactly one endpoint reads rows it does not own

**This is the finding to read carefully.** Every statement in MediaVault today
binds the caller's own email, and a share is the first code that does not.

**Proposal.** Put the cross-user read in its own file — `vault.js`, `GET ?owner=`
— rather than adding a parameter to `items.js`. Then add the check the split
pays for: **every `media_items` statement outside `vault.js` binds
`user_email = ?` to the caller**, asserted in
`apps/media-vault/test/smoke.mjs`. **Posture: a structural guarantee, not a
runtime gate.** It refuses a shape at test time; it adds nothing to the request
path.

The alternative — `items.js` `GET ?vault=` — costs no new file and therefore does
not move the endpoint-count pin. It is rejected on the ground that it puts a
cross-user read inside the file whose entire purpose is caller-scoping, next to
the guarantees the suite already protects there.

**What it costs at the pin:** `apps/media-vault/test/smoke.mjs:464` asserts *"the
endpoint files are exactly the seven documented"* (`onDisk.length === 7`), and
`:462` asserts the README's file map names every one. Two files takes it to
**nine** — one number, two README rows, both deliberate.

**The read itself is trivial**, because Nate settled that a viewer sees the whole
record: it is the statement at `functions/api/media-vault/items.js:16` —
`SELECT * FROM media_items WHERE user_email = ? ORDER BY added_at` — with a
different email bound, mapped by `rowToItem` at `_lib/common.js:125`. No
projection, no field allowlist, no second row shape.

**Evidence.** Verified by reading, 2026-09-08 — `items.js` (`bindUpsert(…, email,
…)`, `DELETE … WHERE user_email = ? AND item_id = ?`), `items/bulk.js:45`,
`items/bulk-update.js:96`, `items/bulk-delete.js:33`, `duplicates.js:26`. All
five bind the caller's email. Endpoint count and README-map assertions read at
`test/smoke.mjs:462-465`.

**Confidence: high.** The five call sites were read individually rather than
grepped for a pattern. What would lower it: a sixth write path added between now
and this being taken — the proposed check is also what would catch that.

**Ongoing cost.** One assertion that has to understand what a caller-scoped
statement looks like, and will need editing the first time a legitimate endpoint
does something it does not recognise. Cheap, and it fails closed and loudly.

**Taken, 2026-09-08 (PR #842).** Posture held: **a structural guarantee, not a
runtime gate** — both new checks live in the smoke test and nothing was added to
the request path.

**The check this finding is for could not have worked as described, because the
list it would have read was already stale.** `apps/media-vault/test/smoke.mjs`
built its endpoint sources from a **hardcoded array of seven filenames**, and
`V1` added `shares.js` without adding it there. So the structural checks that
already existed — *"every delete statement names item_id"*, *"no endpoint
handles PUT at all"* — silently stopped covering the newest file, and the suite
passed. A V2 check hung on that array would have proved nothing about the two
files it was written for. **The array is now derived from disk**, which is the
defect and the fix in one line.

`_lib` was excluded from that walk as well, and holds two of the app's ten
`media_items` statements, so the new check reads `_lib/common.js` too.

**Both checks were proved by making them fail**, not by watching them pass:

| injected defect | what fired |
|---|---|
| `WHERE user_email = ?` removed from `duplicates.js`'s SELECT | `FAIL … scoped to one user — SELECT * FROM media_items ORDER BY added_at` |
| a `media_shares` statement added to `items.js` | `FAIL … exactly one endpoint reads rows it does not own — items.js, vault.js` |

Both injections were reverted; the diff contains neither.

**The first run of the second check was wrong, and the reason is worth keeping.**
It reported **both** `shares.js` and `vault.js`, because `shares.js` carries a
*comment* mentioning `media_items`. A check reading prose is reading the wrong
thing, so both checks now run against comment-stripped source — whole-line `//`
and `/* */` only, because a naive `//.*` eats the `https://` in `lookup.js`.

**What these checks CANNOT do, stated in the README rather than implied.**
Neither proves the *caller's* email is the one bound: that is positional, decided
by the argument order in each `.bind()`, and invisible to any reading of source
text. They prove no statement can touch every user's rows, and that the surface
able to serve another person's library is one file long.

**Verified against a running server**, not just read: `wrangler pages dev` on
port **8804**, three identities, nine calls. A viewer with no grant gets `403`;
the owner grants; the viewer reads the full record including `location` and
`notes`; a stranger still gets `403`; the owner revokes and the viewer gets
`403` again. `POST /api/media-vault/vault` answers **405** — the file exports
only `onRequestGet`, so read-only is the router's answer rather than a check
somebody maintains.

**The hazard `V3` exists for was demonstrated rather than argued.** A viewer who
POSTs an item while looking at someone else's library gets `{"ok":true}` and the
row lands in **their own** vault: the owner's library still read 2 items, the
viewer's own read 1, titled *"Accidental Add"*. Nothing is corrupted and nothing
warns — which is exactly why `V3` hides the write controls.

**Three corrections to this finding's own text**, from the premise pass:

<!-- claim-ok: quoting the premises this note corrects -->

- It says *"All five bind the caller's email"* and rests its **high confidence**
  on *"The five call sites were read individually"*. There are **seven files and
  ten statements** — `migrate.js:73` and two in `_lib/common.js` are not listed.
  The conclusion holds for all ten; the count behind the confidence did not.
- *"Two files takes it to **nine**"* — `V1` had already moved the pin to eight,
  so this was **one** file and **one** README row, not two.
- Every line number it cites (`items.js:16`, `items/bulk.js:45`,
  `items/bulk-update.js:96`, `items/bulk-delete.js:33`, `duplicates.js:26`,
  `_lib/common.js:125`, `smoke.mjs:462`, `:464`) is still exact.

**A live counter-precedent, recorded because the subject grep found it and the
finding does not mention it.** `functions/api/character-creator/characters/[id].js:2`
— *"Reads are open to any authenticated friend"* — keeps an open cross-user read
in the **same file** as its owner-only writes, guarded by a helper with a write
flag. That is the shape `V2` rejects, shipped and documented, in the same repo.
It does not overturn the split here (a character is shared with a table; a media
library is shared with nobody until a row says so), but a reader should know the
opposite decision exists rather than discovering it.

**One piece of documented rot fixed in passing**, because it describes the very
check this finding moves: `apps/media-vault/README.md` said the suite asserts
*"exactly the six documented"* endpoint files. It had said six against a test
asserting seven since before this menu was written. Nothing parses that
sentence, which is why it rotted.

## V3 — medium — the client asks the server whether it may write

**Hiding buttons is not read-only, and this repo already knows the better
pattern.**

**Proposal.** The shared read returns `can_write: false` alongside the items, and
the client gates on that one flag rather than on which URL it thinks it is at.
**Posture: the server is the authority; the client renders what it is told.**

`apps/character-creator/sheet.js` is the working precedent: `C.canWrite` is set
from the server's own answer at `sheet.js:96` (`C.canWrite = res.can_write`), is
read throughout the render (`179`, `268`, `640`, `1125`, `2304`…), and a viewer
gets a visible `read-only` tag at `sheet.js:1422` rather than a page that looks
editable and refuses.

What must go inert in view mode: **+ Add Item, Import, Duplicates, Select and the
whole bulk bar, and Edit/Delete inside the detail modal**, plus the undo window
that hangs off bulk delete.

**The hazard this is really guarding against is not data loss.** A viewer cannot
damage the owner's vault — `V2`'s evidence is that every write binds the
*caller's* email — so the worst case runs the other way: a viewer who clicks
*+ Add Item* while looking at someone else's library silently writes a row into
**their own** vault. Nothing errors and nothing warns. The header must therefore
say whose vault is on screen; the user pill currently shows the signed-in
address (`apps/media-vault/index.html:38-41`), which is precisely the wrong
answer in this mode.

**Evidence.** `sheet.js` line numbers read 2026-09-08. **A correction worth
recording:** `apps/character-creator/REDESIGN-AUDIT.md:47` cites this same
pattern at `sheet.js:922`, `:994` and `:1089` under the path
`apps/character-creator/js/sheet.js`. **That path does not exist** — the file is
`apps/character-creator/sheet.js`, there is a different `js/sheet-layout.js`, and
the line numbers have all moved. The substance of that claim held; its
coordinates did not. Re-read before citing it.

**Confidence: high** that the pattern exists and is live. **Low on the list of
controls above being complete** — it was assembled from `index.html`'s header and
toolbar, not from walking all 2,282 lines of `app.js`. Walking the click handlers
is what would raise it, and is work for whoever takes this.

**Ongoing cost.** Every control added to MediaVault from then on has to decide
whether it survives view mode. That is a real tax and there is no check for it;
a control that forgets fails in the safe direction (it appears, and writes to the
viewer's own vault) which is exactly the failure this finding is about.

## V4 — high — the picker is a mirror, and the server must re-check it

Nate's question — *can the share options only list emails in the allow list?* —
removes a failure mode rather than labelling one, and it changes the design.

**Proposal.** A Pages environment variable, `MV_SHARE_CANDIDATES`, holding the
same addresses as the *Friends Only* Access policy. `shares.js` reads it
server-side and returns the candidates minus the caller and minus anyone already
granted. The Share modal is a **checklist with no free-text field**.
**Posture: fail closed.** An address that is not a candidate cannot be granted.

**The `POST` must re-check the list.** A picker is UI; if the grant endpoint
accepts any address it is handed, the closed picker is decorative. This is the
half of the finding most likely to be skipped, because the modal will look
finished without it.

**Why a mirror beats free text.** An earlier draft of this design had free-text
entry plus a *pending* badge for addresses that had never signed in. That is
strictly worse: it lets an owner grant to someone who **cannot** sign in, and
produces a share that silently never works — the recipient hits the login wall,
gets no code, and nothing on either screen explains why. A stale mirror fails the
other way: the person Nate just added does not appear, the owner asks him, he
updates the variable. **The gap is visible, harmless, and self-announcing.**

**One consequence worth deciding rather than discovering:** the picker hands any
signed-in user the list of every address allowed on the site. Among five friends
who all know each other that is nothing. It is written down here so it is a
decision.

**Evidence.** The five addresses in the allow policy were read from
`GET /accounts/{id}/access/apps/{app}/policies` through the `cloudflare-api` MCP
plugin, 2026-09-08. That the plugin cannot **write** Access is `CLAUDE.md`'s,
re-tested there 2026-09-05. **Not measured:** anything about how a Function reads
a Pages environment variable — that is ordinary and was not exercised.

**Confidence: high** on the mechanism. **Medium on it being the right trade
forever** — it is right at five addresses and wrong at fifty, and the upgrade is
the live API read recorded as declined at the top of this file.

**Ongoing cost.** A second copy of dashboard configuration, maintained by hand,
forever. It is the same shape `SETUP.md` already maintains for the pick3cut5
Access destinations — and unlike those, **nothing in CI can check this one**.
See `V6`.

**Taken, 2026-09-08 (PR #843).** Posture held: **fail closed**. An address that
is not a candidate cannot be granted, and an unset variable means **nobody**
rather than everybody.

**The finding said "a Pages environment variable" and this repo has two kinds,
with a rule between them — so it went to Nate.** `wrangler.jsonc`'s own comment
and `SETUP.md` both say plain, non-secret variables live in the wrangler config
and the dashboard holds only secrets. A list of friends' addresses is not a
secret, so the stated rule pointed at `wrangler.jsonc` — **and this repository
is public.** Measured before asking: `nathanrapert@` and `lillcreeper@` already
appear in tracked files, but `raewise@`, `vincewise@` and `warwood69@` appear
**nowhere**, so following the convention would newly publish three people's
addresses, permanently and in git history, on their behalf.

**Nate chose the Pages dashboard**, 2026-09-08. `SETUP.md` records the departure
and why, beside the variable.

**And the convention it departs from was already not true.** Read back from the
project that day through the `cloudflare-api` MCP plugin, production holds three
`secret_text` values (`ANTHROPIC_API_KEY`, `ADMIN_EMAIL`, `TMDB_API_KEY`) **and
two `plain_text` ones** — `ACCESS_TEAM_DOMAIN` and `ACCESS_AUD` — while
`SETUP.md` said the dashboard held the encrypted secrets *"and nothing else"*
and that those two lived in `wrangler.jsonc` **rather than** the dashboard. They
live in both. Corrected in place, in this PR, because the sentence sat directly
beside the new variable and would otherwise have contradicted it.

**A false claim this menu put into shipped code has been corrected.** `V1`'s
`shares.js` and the MediaVault README both said no Pages Function can read the
Access allow list, citing `CLAUDE.md` → *Three credentials*. **`CLAUDE.md` says
no such thing** — that table is about which credential an agent on Nate's
machine should reach for, and this menu's own header says the live read was
declined **on cost**, not as impossible. Both sentences now say declined-on-cost
and name what the cost is.

**Three checks added, two of them proved by making them fail:**

| injected defect | what fired |
|---|---|
| the candidate re-check deleted from `POST` | `FAIL and the grant endpoint re-checks it before inserting a row` |
| an address hardcoded in `shares.js` | `FAIL the share candidate list is read from the environment, not the source` |

The re-check assertion compares **positions** — `shareCandidates(` must appear
before `INSERT INTO media_shares` inside `onRequestPost` — because a substring
test cannot see order, and a gate that runs after the insert is not a gate.

**Exercised against a running server**, both ways. With the variable set
(`viewer@example.com, second@example.com`): the picker offered both, granting
one removed it from the offer, and a grant to `outsider@example.com` was refused
with *"That address cannot sign in to the Workshop…"*. With it unset: candidates
came back `[]` and a grant was refused naming the variable.

**One behaviour worth stating because it is a decision, not an accident:** an
unset variable refuses **new** grants and leaves **existing** ones working. A
missing piece of configuration must not silently revoke shares somebody already
made.

**What was left to `V6`**, deliberately: the twin-step prose in `SETUP.md`'s
*Access (the login wall)* section, and the statement that nothing checks the two
lists agree. This PR documents the **variable**; `V6` documents the **habit**.

**Not done, and not by oversight: the variable was not set in production.**
Writing it means a `PATCH` on the project's `deployment_configs`, and if that
replaces the env-var map rather than merging it, the three `secret_text` values
are gone — they cannot be read back, so `TMDB_API_KEY` and `ANTHROPIC_API_KEY`
would have to be re-issued. That is not a risk worth taking to save a paste.
**Until Nate sets it, sharing is inert on production** — which is what fail
closed means, and why it is the right default.

## V5 — medium — a new MediaVault table reds the character creator's suite

The surprise in `V1`'s step 6, filed separately because it is a change to
**another app's test** and should be its own decision.

**Proposal.** `apps/character-creator/test/checks/documented-counts.mjs:204`
holds `const notOurs = ['media_items', 'schema_migrations', 'claude_usage']` and
exempts one prefix, `ff_`, at `:211`. Its check *"every table has a row in a
data-model table"* therefore fails for `media_shares`: it is not named in that
README, not in `notOurs`, and does not start with `ff_`. Generalise the
exemption to a `media_` prefix, the way `ff_` already works, rather than adding
one more string to a hardcoded list. **Posture: widen an existing exemption; add
no new check and move no exit code.**

**Evidence.** Read at `documented-counts.mjs:200-216`, 2026-09-08. **Not run** —
no table has been created, so the failure is predicted from the code rather than
observed. Creating the table on a branch and running
`node apps/character-creator/test/regression.mjs` is what would turn this from
predicted to seen, and whoever takes `V1` will see it whether they want to or
not.

**Confidence: medium**, and that is entirely the *not run* above. The reading is
unambiguous; the prediction is still a prediction.

**Ongoing cost.** None. It removes a hardcoded list entry that the next
MediaVault table would have needed as well.

**Taken, 2026-09-08 (PR #840).** Posture held: an existing exemption widened,
**no new check and no exit code moved** — the check count in that section is 35
before and after.

**Taken FIRST, ahead of `V1`, and the running order changed because of it.** Nate
approved `V1` → `V5`; `documented-counts.mjs` runs inside
`apps/character-creator/test/smoke.mjs` (imported at `smoke.mjs:394`, called at
`:6078`), which is the flagless run `ship-pr` names as the merge gate. Taking
`V1` first would therefore have merged a red gate and left it red until this
landed. Both findings are unchanged; only the order moved.

**The prediction is now an observation, which is what this finding asked for.**
V5 recorded its evidence as *not run*. It has been run: a `media_shares` `CREATE`
appended to `db/schema.sql`, then
`node apps/character-creator/test/smoke.mjs --section "Documented counts"`.

| | before this change | after |
|---|---|---|
| `every table has a row in a data-model table` | **FAIL — `media_shares`** | ok |
| `and it matches schema.sql` | FAIL — README says Thirty-seven (37), schema has 38 | FAIL, unchanged |

The second row is **`V1`'s place 6 and is deliberately left failing here** — this
finding widens an exemption and does not touch a count. The injected table was
reverted; `db/schema.sql` is byte-identical to `main` in this PR.

**One correction to this finding's own text.** `notOurs` is at
`documented-counts.mjs:205`, not `:204` as the Evidence paragraph says. The
`ff_` exemption at `:211` was right. Found by the `audit-premise-auditor` pass
before scoping, and recorded rather than edited into the finding above, because
these files are records.

**What was NOT done, and why.** No check that the README disclaims the `media_`
prefix, mirroring *"and the `ff_` prefix is disclaimed"*. The posture says *add
no new check*, and a new one would have been a second thing to satisfy in the
same breath as widening the first. `V1` is what puts `media_` in that README's
prose.

## V6 — low — SETUP.md gains a twin step, and nothing in CI can watch it

**Proposal.** In `SETUP.md`'s *Access (the login wall)* section, record that
adding an address to the *Friends Only* policy has a twin: updating
`MV_SHARE_CANDIDATES`. And record, in the same paragraph, that **nothing checks
the two agree**. **Posture: documentation only. No check, no gate.**

**Why no check, stated so it is not proposed again.** The pick3cut5 bypass is
verifiable from outside because it is a *behaviour*:
`node apps/pick3cut5/test/smoke.mjs --remote` fetches a URL with no session and
sees a 200 or a 302. **There is no request that reveals who is on an email allow
list**, so there is no equivalent here. The drift is caught by a person, or by an
agent with the `cloudflare-api` plugin — which is a few seconds' work, and is how
the five addresses in this file were read.

**Evidence.** The `--remote` behaviour check is
`apps/pick3cut5/test/smoke.mjs:396-444`, read 2026-09-08. The absence of an
Access read path from any test here is **inferred** from the credential facts in
`CLAUDE.md` — the environment token cannot reach Access, and no test imports the
MCP plugin — not from an exhaustive search of the suites.

**Confidence: medium**, held down by that inference. Grepping every test for an
Access API call would raise it.

**Ongoing cost.** One paragraph, and the honesty that its subject is unenforced.

## V7 — low — what a viewer may take away

**Proposal.** Default **Export off** in view mode, and make it a flag rather than
a deletion so it can be turned back on. **Posture: a default, not a
prohibition.**

Nate settled that a viewer sees `location` and `notes`, so showing them is not in
question. Export is a different question wearing the same clothes: it converts
*look at* into *keep a copy of*, including where every physical item lives. That
may well be fine between the people involved — it is his call, and this finding
exists so it is made rather than inherited from whichever buttons happened to
survive `V3`.

**Evidence.** `exportCSV()` at `apps/media-vault/app.js:1223` writes every field
of the in-memory `library` array; read 2026-09-08. **Not measured:** anything
about what the people involved actually want.

**Confidence: low, and it is a preference rather than a fact.** Nate answering
raises it to certain.

**Ongoing cost.** One flag.

## Deferred deliberately, so nobody looks for a finding

**A link the owner can send is not filed as work.** Once grants live server-side,
the viewer signs in and the shared vault is simply *there*, in a switcher, with
nothing to send. A `?vault=` shortcut would still work and can be added whenever
someone wants it; it is not needed for the feature to function, and it is the
only part of the original request — *"share a read-only link"* — that the chosen
design makes unnecessary rather than implements.

**Deriving candidates from who has signed in** — `SELECT DISTINCT user_email FROM
media_items` — is dropped, not deferred. It needs no mirror and no credential,
and it cannot list the person Nate has just added on request, who is precisely
the person a share is being set up for.

**This menu’s own row in the `audit-menu` shape table was filed with it.**
That skill asks for it in the PR that creates the file, and warns that *“the
row that is missing has twice been the reader’s own”* — so this paragraph named
the row while no PR existed, and the PR that first committed this file added it
to `.claude/skills/audit-menu/SKILL.md`, beside the other `apps/media-vault`
rows. The row records the `V` prefix and the `##` heading level this file uses.
