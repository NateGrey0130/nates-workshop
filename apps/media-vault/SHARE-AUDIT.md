# MediaVault — sharing one vault, read-only: design menu

> **Since 2026-09-16 the closed findings live in `SHARE-AUDIT.closed.md`**, moved
> there verbatim with their headings, numbering and notes; this file keeps a
> one-line pointer per moved finding where its heading was, and holds in full
> every finding whose own section records no outcome. The closed file is a
> record like this one, and the `*AUDIT*.md` glob reaches both.

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

**Adjusted 2026-09-09.** The credential half of the paragraph above has been
overtaken, and it is left standing because this file is a record of what was
known on 2026-09-08. `CLAUDE.md` -> *Three credentials* now splits the plugin's
Access reach **per endpoint** rather than per product: a reusable-policy
`DELETE` returned `202` and removed a real policy that day, verified by reading
the account's policies back afterwards, while the application `PATCH` cited
above is still refused. Creating and updating a policy were not tested. PR #877.

**That reopens neither declined option, and this note is not an invitation to
re-propose one.** The link-anyone-could-open option was declined on the
destination cap and on the second public route it would add; the live-read
option was declined on the cost of a standing account-scoped credential sitting
in the deployment. Both reasons are about a **read** and about what the
deployment would have to hold. A write succeeding changes neither.

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

- **V1** — high — `media_shares`, and the six places a new table lands — Taken, 2026-09-08 (PR #841). Posture held: additive. No existing — full text in `SHARE-AUDIT.closed.md` under its own `## V1` heading.

- **V2** — high — exactly one endpoint reads rows it does not own — Taken, 2026-09-08 (PR #842). Posture held: a structural guarantee, not a — full text in `SHARE-AUDIT.closed.md` under its own `## V2` heading.

- **V3** — medium — the client asks the server whether it may write — Taken, 2026-09-08 (PR #844). Posture held: the server is the authority; — full text in `SHARE-AUDIT.closed.md` under its own `## V3` heading.

- **V4** — high — the picker is a mirror, and the server must re-check it — Taken, 2026-09-08 (PR #843). Posture held: fail closed. An address that — full text in `SHARE-AUDIT.closed.md` under its own `## V4` heading.

- **V5** — medium — a new MediaVault table reds the character creator's suite — Taken, 2026-09-08 (PR #840). Posture held: an existing exemption widened, — full text in `SHARE-AUDIT.closed.md` under its own `## V5` heading.

- **V6** — low — SETUP.md gains a twin step, and nothing in CI can watch it — Taken, 2026-09-08 (PR #845). Posture held: documentation only. No check, — full text in `SHARE-AUDIT.closed.md` under its own `## V6` heading.

- **V7** — low — what a viewer may take away — Taken, 2026-09-08 (PR #846). Posture held: a default, not a — full text in `SHARE-AUDIT.closed.md` under its own `## V7` heading.

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

- **V8** — medium — the allow policy holds seven addresses, the mirror holds an unknown number, and nothing can compare them — Taken as option A, 2026-09-12 (PR #982), on Nate's word. Posture held: one — full text in `SHARE-AUDIT.closed.md` under its own `## V8` heading.
