---
name: pick3cut5
description: Change Pick 3 Cut 5 without breaking it for the people it is public for. Use when touching apps/pick3cut5/, workers/pick3cut5-room/, shared/ assets that app loads, any Access policy or bypass path, or the party-mode Durable Object. Covers why a merge does not deploy the Worker, why the app is verified on production rather than a preview, and the asset the bypass keeps forgetting.
---

# Pick 3 Cut 5

The only part of this site that is **public**, and the only component a merge
does not deploy. Both facts break things quietly, and both have.

Every rule here is an incident. Three of the four reached production.

## The wall is the whole problem

The site sits behind Cloudflare Access. This app is the one thing outside it, via
`PUBLIC_PREFIXES` in `functions/api/_middleware.js` and a set of Access bypass
destinations on the Pages project.

**The bypass is a list of paths, not a list of pages.** A page is not one path:
it is its HTML plus everything that HTML pulls in.

The app shipped bypassed on its own two routes and **not** on
`/shared/styles.css` or `/shared/js/ui.js`. Every friend with a room code got an
unstyled page in Times New Roman and `escHtml is not defined` at the first flip
— while `curl /apps/pick3cut5/` returned **200 the whole time**, and local dev,
which has no Access at all, played perfectly.

**A 200 on the route proves the route, not the page.** Verify a public page by
loading it with **no Access session** and checking its dependencies resolved.
Computed `body` background and `typeof escHtml` are the two-second version.

### The derivation cannot see what CSS asks for

`apps/pick3cut5/test/smoke.mjs` derives the paths that must be public by reading
`index.html`. **It reads HTML only**, so an asset referenced from inside a
stylesheet — a font, a background image — is invisible to it and will 302 for
every unauthenticated player. That is `REDESIGN-AUDIT` N6.

So when a change adds anything a stylesheet fetches, `curl` it against
production yourself before merging. The test will not.

### An Access app allows five destinations, and they are spent

Four are in use plus `shared/fonts`. **A new public asset may not fit**, which
turns "add a destination" into a design decision rather than a chore. Check
before promising anything is public.

### A path under the prefix that no function claims answers 200

`PUBLIC_PREFIXES` is **prefix-matched** and calls `next()`. Where no function
matches, Pages' static handler answers with the landing page:

```
GET /api/pick3cut5/zzz-not-a-route  ->  200  text/html   (index.html)
```

That is why the smoke test checks **content type** rather than status. It also
means a probe under that prefix cannot tell "route exists" from "route does
not" — the same confusion `/shared/` already caused once.

## A merge does not deploy the Worker

Party mode needs a Durable Object per room, and **a Pages project cannot define
a DO class** — only bind to one exported from a standalone Worker, with
`script_name` on the binding. So the room server is `workers/pick3cut5-room/`
and deploys by hand:

```bash
npx wrangler deploy --config workers/pick3cut5-room/wrangler.jsonc
```

**Order matters and nothing enforces it.** The Worker must exist *before* the
Pages deploy that binds it. Backwards, party mode answers 503 while the rest of
the site looks completely fine.

It produces **no check-run**, so `ship-pr` step 9 is silent about it by
construction. `node scripts/deploy-sweep.mjs` compares the newest commit touching
that directory against the live deployment's timestamp — but **a timestamp cannot
tell you whether the change mattered**, so read the diff it names and then either
deploy or decide not to. Do not silence it.

**Its secret is separate.** The Worker holds its own copy of the Anthropic key;
the Pages secret does not reach it. Rotating means rotating in **both** places.

It writes `claude_usage` rows for metering — null email by design, endpoint
`pick3cut5-party` or `pick3cut5-solo`, two or three rows per generation
depending on whether verification ran. Writes are fail-open, so a D1 hiccup can
never break a round. **No game state touches D1**; rooms live and die in DO
memory.

## It cannot be played on a preview, so production IS the check

Previews are gated by their own Access policy and the bypass does not follow the
app onto them. A PR preview cannot be played. This app is verified **on
production, immediately after merge**:

```bash
node apps/pick3cut5/test/smoke.mjs --remote
```

It fetches the app and its assets with **no Access session** and confirms the
rest of the site is still walled — the thing a browser tab you are logged into
cannot tell you. Run it on any change to this app, to `shared/`, or to an Access
policy.

`node apps/pick3cut5/test/game.mjs` walks all reachable rounds and proves the
server's budget rules and the client's copy of them still agree.

## Two local servers, in order

Party mode needs the Worker running too, or both bindings resolve to nothing and
it answers 503:

1. `pick3cut5-room` (port 8799)
2. then `nates-apps+pick3cut5`

Both are in `.claude/launch.json`. If 8788 is taken, it is another worktree —
use an escape hatch and see the **`verify-ui`** skill.

## Before you call it done

- production fetched with **no Access session**, and the page's dependencies
  confirmed resolved — not just a 200 on the route
- anything a stylesheet fetches curled against production by hand
- `apps/pick3cut5/test/smoke.mjs --remote` green
- if `workers/pick3cut5-room/` changed: deployed by hand, and the deploy sweep's
  timestamp gap read rather than silenced
