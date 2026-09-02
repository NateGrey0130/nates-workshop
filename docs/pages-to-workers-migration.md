# Moving Nate's Workshop from Pages to Workers

**Status: written up, not taken.** Nothing in the repo depends on this
document. It exists because Pick 3 Cut 5 forced the question and the answer
deserved more than a sentence in a PR description.

*Verified against Cloudflare docs on 2026-08-24.*

---

## Why the question came up

Pick 3 Cut 5 needs one Durable Object per room. Cloudflare Pages **cannot
define a Durable Object class** — the docs say so in two places, and Pages DO
bindings additionally require a `script_name` key that Workers treat as
optional:

> You must create a Durable Object Worker and bind it to your Pages project
> using the Cloudflare dashboard or your Pages project's Wrangler
> configuration file. You cannot create and deploy a Durable Object within a
> Pages project.

So there were exactly two options: a standalone Worker bound from Pages, or
move the whole site to a Worker with static assets. We took the first. This
describes the second.

## What the site would actually gain

Not theory — these map onto things already worked around by hand in this repo.

| Gain | Workers | Pages | Why it matters here |
|---|:--:|:--:|---|
| **Durable Objects inline** | ✅ | 🟡 | No second Worker, no `script_name`, no separate deploy step. "Merging is the deploy" becomes true again. |
| **Rate Limiting binding** | ✅ | ❌ | The correct guardrail for a public generation endpoint. Its absence on Pages is *why* `/solo/generate` lives in the Worker instead of next to the other API routes. |
| **`wrangler dev --remote`** | ✅ | ❌ | `CLAUDE.md` says "`--local` is not a mirror of production. It accumulates. Ask production." Remote dev attacks that at the root instead of documenting around it. |
| **Workers Logs, Logpush, Tail Workers, source maps** | ✅ | ❌ | Today, debugging the Access JWT middleware or the Anthropic proxy in production means real-time tail only — nothing retained, nothing queryable, no stack traces worth reading. |
| **Cron Triggers** | ✅ | ❌ | `ofd-refresh.mjs`, `drift-check.mjs`, and `repo-vs-live.mjs` are all run by hand today. |
| **Queue consumers** | ✅ | ❌ | The character creator's book imports, OCR extracts, and `npcs/sweep` are long-running LLM jobs currently squeezed into a request lifetime. |
| **Gradual deployments** | ✅ | ❌ | Every merge is currently all-or-nothing across the whole site. |
| **Image Resizing binding** | ✅ | ❌ | NPC portraits are served out of R2 at full size. |

Cloudflare's own posture is worth reading plainly: the Pages docs now open with
a banner asking *"Are you sure you want to use Pages?"*, and the Workers
best-practices guide says new features and optimizations are focused on
Workers. Pages is not deprecated and continues to work — it is simply where
nothing new lands.

## What it would cost

### 1. The build step (the real one)

`functions/api/**` is roughly fifty files that route themselves by filename.
Workers has no file-based routing. Two ways out:

- `npx wrangler pages functions build --outdir=./dist/worker/` compiles the
  existing tree into a single Worker. It works, and it means this repo acquires
  a **build step** — against a `CLAUDE.md` that opens with "Plain HTML/JS/CSS,
  zero dependencies, no build step. There is no `package.json`."
- Hand-write a router. No build step, but fifty routes to wire and a new class
  of bug (a route that silently stops matching) in a codebase that currently
  cannot have one.

This is a cultural cost more than a technical one, and it is the biggest single
reason not to do this casually.

### 2. The hostname changes

`nates-workshop.pages.dev` becomes a `workers.dev` subdomain. That is not
cosmetic:

- The Access application is bound to the hostname. It needs recreating.
- A new Access app means a **new AUD tag**, which means updating `ACCESS_AUD`
  in `wrangler.jsonc`.
- The preview-access policy (Pages → Settings → Preview access, turned on
  2026-08-24) has no direct equivalent; Workers protects preview URLs through
  a separately configured Access application.
- The order matters. Deploy the Worker with the old `ACCESS_AUD` still set and
  every `/api/*` route 403s; deploy with the vars removed and the site is
  briefly unwalled. Neither is catastrophic for a few minutes, but only one of
  them is safe, and it is the first.

A custom domain would make this a non-issue permanently, and is worth doing
**before** any migration rather than during one.

### 3. Middleware ordering flips

Pages runs Functions before static assets. Workers serves static assets first.
`functions/api/_middleware.js` — the JWT verification from audit F4 — would
need `run_worker_first` scoped to `/api/*` to keep behaving as it does now.
Getting this wrong fails open, which is the bad direction.

### 4. Smaller ones

- Branch deploy controls are 🟡 and custom branch aliases are still pending on
  Workers; the preview story is slightly worse than Pages' today.
- Pages Plugins and `_routes.json` have no direct translation (this repo uses
  neither).
- `_headers` and `_redirects` work natively on Workers (this repo uses
  neither).

## Rough shape of the work

1. **First, and separately: put a custom domain on the Pages site.** It makes
   the hostname change a non-event later, and it is valuable on its own.
2. Add `assets.directory` and `main` to a Worker config; drop
   `pages_build_output_dir`.
3. Decide the routing question above and land it — this is the bulk of it.
4. Move `functions/api/_middleware.js` behind `run_worker_first` for `/api/*`.
5. Fold `workers/pick3cut5-room/` back into the main Worker: the `Room` class
   exports inline, both Pages bindings collapse into a plain DO binding, and
   the separate deploy step and separate `ANTHROPIC_API_KEY` both disappear.
6. Recreate the Access application, capture the new AUD, update
   `wrangler.jsonc`.
7. Set up Workers Builds to deploy on push to `main`, replacing the Pages Git
   integration.
8. Turn on `observability`, and only then start deleting the workarounds this
   document lists as gains.

Steps 5 through 8 are the payoff. Steps 1 through 4 are the tax.

## Recommendation

**Not as a prerequisite for anything.** The gains are real but none of them are
urgent, and every one of them is still available later at the same price.

The moment to do it is when one of these becomes true:

- A second app wants a Durable Object, and the "one standalone Worker per
  feature" pattern starts multiplying deploy steps.
- Something in production breaks in a way that real-time tail cannot explain,
  and the missing observability costs an evening.
- A scheduled job is genuinely wanted rather than merely imagined.

Until then, the standalone Worker is a contained cost: one extra deploy
command, documented in SETUP.md, touching one app.

## Revisited 2026-09-01

**The recommendation above stands. This section is here so the argument is on
record as predating a failure it did not anticipate.**

Everything above was written on 2026-08-24, when the cost/benefit was drawn
between Pages' present-day conveniences and Workers' unused capabilities. Three
days later a Pages-specific build failure happened for real: a JSON import
written the way Node requires it (`with { type: 'json' }`) parsed under the
wrangler this repo runs and did not parse under the 3.114.17 the Pages build
image ships, so every deploy from `d5280fe` (2026-08-27) failed silently until
PR #399 restored it on 2026-08-30. Merges kept landing on `main` and none of
them reached production. The mechanism is written up in SETUP.md under *When
the merge does not deploy*.

Two of the gains in the table above turn out to describe exactly that outage —
Workers Builds surfaces a build failure as a build failure, and Workers Logs
would have made the gap between "merged" and "serving" visible rather than
inferable. So the table understated its own case: **"Merging is the deploy"
becomes true again** was written about the second deploy command for
`pick3cut5-room`, and it also covers a deploy that silently does not happen.

It is still not enough to move. The failure has a guard now
(`apps/character-creator/test/checks/environment.mjs` §9) and a verification
step in the `ship-pr` skill, both of which cost a fraction of the build step
this migration would introduce — and the build step is still the cultural
objection that *What it would cost* leads with. The trigger conditions above are
unchanged.

One correction to how they are phrased, though. The second trigger says
"something in production breaks in a way that real-time tail cannot explain."
This broke in a way real-time tail could not have *noticed*: there was nothing
to tail. The site served every request correctly, from code four days old. If
that trigger is ever read as a threshold, it should be read to include this —
a deploy that does not happen is a production failure with no signal on the
request path at all.
