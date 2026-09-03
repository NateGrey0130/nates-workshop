# Pick 3 Cut 5 — a party game about spending a budget you cannot get back

Eight items arrive one at a time. You have three keeps and five cuts, and every
pick is final, so the last few items decide themselves — run out of keeps and
the rest of the round is cuts whether you like them or not. Play it in a room
with friends over a WebSocket, or on your own against the same generator. The
categories are anything you can type, and Claude builds the list.

Part of Nate's Workshop, and the one app in it that is **deliberately outside
the login wall**: a friend with a room code needs no Cloudflare Access account.
The room code is the only barrier, on purpose. That trade is what most of the
operational care around this app is protecting.

**Two servers, not one.** A Pages project cannot define a Durable Object class,
and a room is a Durable Object, so the game server lives in
`workers/pick3cut5-room/` and deploys separately from the site. Merging does
not ship it. See `SETUP.md` → *Pick 3 Cut 5 and the second Worker* for the
deploy order, the second Anthropic key, and the four Access destinations the
app needs — all four of which are dashboard-only and none of which this README
can change.

---

## Where everything lives

```
apps/pick3cut5/
├── index.html            Lobby, round, and final screens in one page
├── styles.css            Loaded after /shared/styles.css
├── app.js                Everything the page does, one plain script —
│                         including soloForced(), the client's own copy of the
│                         budget rule (see "The rule that lives twice")
├── AUDIT.md              Findings menu, taken one at a time
└── test/
    ├── smoke.mjs         Derives the public paths from index.html and pins
    │                     them against SETUP.md and the middleware
    └── game.mjs          Walks every reachable round; proves the server's
                          budget rules and the client's copy still agree

functions/api/pick3cut5/
├── room.js               POST create a room, GET upgrade to a WebSocket
└── solo.js               POST solo generation — a thin proxy, on purpose

workers/pick3cut5-room/   The standalone Worker. Deploys on its own.
├── src/index.js          Routes /room, /ws, /solo/generate
├── src/room.js           The Durable Object: seats, picks, reveals, timers
├── src/generate.js       The three-step category pipeline
├── src/anthropic.js      The Worker's own Claude client; writes claude_usage
└── src/rules.js          The budget rules as pure arithmetic, so they can be
                          tested without a Durable Object

functions/api/_middleware.js   PUBLIC_PATHS — the code half of the bypass;
                          exact paths, not a prefix, since 2026-09-02
```

The shared framework rules apply: the app is registered in `apps/manifest.json`
and loads `/shared/styles.css` then its own. It uses `/shared/js/ui.js`
(`escHtml`) but **not** `/shared/js/api.js` — generation goes through the
Worker, not the site's `/api/claude` proxy, because Pages Functions cannot use
the `ratelimit` binding this endpoint needs.

## The rule that lives twice

`forcedChoice(keepsLeft, cutsLeft, remaining)` in `workers/pick3cut5-room/src/rules.js`
is four lines of arithmetic that decide when a player has no say left:

| condition | forced |
|---|---|
| no keeps left | cut |
| no cuts left | keep |
| keeps left equals items remaining | keep |
| cuts left equals items remaining | cut |

`soloForced()` in `app.js` reimplements it, because solo mode has no server to
ask and the page loads classic scripts rather than modules. **That duplication
is the most dangerous thing about this app's design** — a divergence would be
invisible until a solo player's budget failed to add up, which is exactly the
kind of bug nobody reports as a bug.

It is checked rather than commented on. `test/game.mjs` extracts the client's
function from `app.js`, walks every reachable state, and fails if the two ever
disagree. Change one copy without the other and the test says so.

## API surface

Everything here is reachable without an Access session — see the bypass list in
`functions/api/_middleware.js`.

| Route | What it does |
|---|---|
| `POST /api/pick3cut5/room` | Create a room; returns a four-character code |
| `GET /api/pick3cut5/room?code=XXXX` | WebSocket upgrade into that room |
| `POST /api/pick3cut5/solo` | Solo generation; proxies to the Worker |

Room codes are four characters from an alphabet with no `O`, `0`, `I` or `1`.
The code is validated in `room.js` **and** in the Worker: the code is the
Durable Object's name, and a name is created by being asked for, so an
unvalidated code would let anyone spin up unlimited empty objects by typing
garbage.

No game state touches D1 — rooms live and die in Durable Object memory. The
only thing this app writes to the database is `claude_usage` metering, and
those writes are fail-open, so a missing table can never break a round.

## Local dev, including two clients against one room

Two terminals, both from the repo root. The Worker first:

```bash
npx wrangler dev --config workers/pick3cut5-room/wrangler.jsonc
```

Then the Pages site, told where to find it:

```bash
npx wrangler pages dev . --do P3C5_ROOM=Room@pick3cut5-room --service PICK3CUT5=pick3cut5-room
```

Open `http://localhost:8788/apps/pick3cut5/`. The middleware exempts localhost,
so no Access is involved either way.

**Testing multiple players against one room** is the part worth writing down.
Seats are held by *name*, not by socket, so two tabs entering the same name
fight over one seat — the newer one wins and the older is closed on purpose.
For a real multi-client test:

- Open the host tab, start a party, note the four-character code.
- Open each additional player in a **separate browser profile or a private
  window**, not just another tab. Ordinary tabs share nothing that matters
  here, so plain tabs work too as long as **every player uses a different
  name** — that is the actual requirement.
- The join link the lobby copies (`…/apps/pick3cut5/?room=CODE`) prefills the
  code, which saves typing it eight times.
- Phones on the same LAN can reach it via `--ip 0.0.0.0` on `pages dev` and
  your machine's LAN address; that is the only way to test what the game
  actually feels like.

To watch the forced-pick and timeout paths without playing eight items
honestly: set the pick timer to its 10-second minimum in the lobby, then leave
one tab alone. To reach a forced cascade fast, spend all three keeps on items
one through three.

Solo mode needs only these two servers — no room, no socket.

## How long a round takes to build, and why

Verification runs **only for time-sensitive categories**, and that is the whole
latency story. Measured:

| category | verifiable | time-sensitive | verify | total |
|---|---|---|---|---|
| `worst pizza toppings` | no | no | skipped | ~3s |
| `Quentin Tarantino films` | yes | no | skipped | ~3s |
| `current NFL starting quarterbacks` | yes | yes | ~68s | ~99s |

The decaying-fact problem — someone listed as active who retired years ago —
only exists where a currency constraint does, so a static category pays
nothing. Where it does run it earns it: that NFL round rejected 2 of 12.

The final screen is dead time — everyone is arguing about each other's boards —
so typing the next category there **prefetches** its list in the background,
debounced 1.5s. Pressing *Go again* on that same category then starts the round
with no generating screen at all: measured at **57ms** in party mode and
**109ms** in solo.

## Two ways to challenge an item, and what each costs

Measured in production, per generation:

| | cost | who | when |
|---|---|---|---|
| Swap — *"I know this is wrong"* | free | any player | before the flip |
| Check — *"I think this might be"* | **~$0.075** | **host only**, 2 per round | before the flip |
| Whole-list verify toggle | **~$0.19** | host, at generation | before the round |

The surprise is that a single check is only about two and a half times cheaper
than verifying all twelve candidates, not ten — web search RESULTS dominate the
context, so looking one thing up still drags back 20,000+ tokens. Per item it is
roughly five times *worse* than batching. The saving is that on most rounds
nobody doubts anything and it costs nothing at all.

That is also why checks are capped at two: a third would cost more than simply
verifying the whole list, at which point the host should tick the box instead.

A failed check swaps the item on the same terms as a call-out, refunds anyone
already committed to it, and shows the reason — *"written by Tarantino but
directed by Tony Scott"*.

Every category input also carries a **double-check this list** toggle. The
default gate for verification is time-sensitivity alone; ticking the box forces
it for a static category the room wants right — `Quentin Tarantino films` served
*True Romance* and *Four Rooms* in testing, and a table that does not know Tony
Scott directed the first has no way to catch it. A prefetch built without the
check cannot satisfy a request that asked for it.

Both modes cap prefetch, and solo's cap is tighter for a reason:

| | party | solo |
|---|---|---|
| who | host only | the player |
| in flight | 1 | 1 |
| lifetime cap | 5 per room | 3 per session |
| also gated by | round cap, replay cap, **not** the 20s cooldown | the public endpoint's 8/60s per-IP limit |

Party prefetches deliberately do **not** consume the 20-second generation
cooldown — charging a speculative call to it meant a host who changed their
mind was told to wait for a call they never asked for. Solo's cap is lower
because it goes through the public rate-limited endpoint, and a household
sharing one wifi shares that budget; spending it on lists nobody asked for
would make the button the player *did* press fail.

Changing the category after a prefetch is safe in both modes: the status line
hides and *Go again* falls through to a normal generation rather than serving
the stale list.

What is given up is the plausible invention in a static category, and the
**in-round swap** is the backstop. Any player can press *That's wrong — swap
it* before the flip; the item is replaced from a reserve of already-filtered
spares with no API call, every pick already recorded against it is refunded
(including budget-forced ones), and the same item number is revealed again.
Three swaps per round, one per player per item. Worth testing against
`Quentin Tarantino films`, which reliably offers *Natural Born Killers* or
*True Romance* — written by him, directed by someone else.

## Tests

Run from anywhere:

```bash
node apps/pick3cut5/test/smoke.mjs
node apps/pick3cut5/test/game.mjs
```

`smoke.mjs` exists because of one bug. The app shipped with a bypass on
`/apps/pick3cut5/*` and `/api/pick3cut5/*` and was broken for every
unauthenticated player for hours: `index.html` also loads `/shared/styles.css`
and `/shared/js/ui.js`, neither of which was bypassed, so a friend with a room
code got an unstyled page and `escHtml is not defined` froze the game at the
first flip — while `curl /apps/pick3cut5/` returned 200 the whole time. Nothing
caught it, because the routes that were checked were the routes that worked and
local dev has no Access at all. So the test **derives** the required public
paths from `index.html` rather than listing them, and fails if the source and
the runbook disagree. Add a script tag and it names the file and the dashboard
change it needs.

`game.mjs` walks every reachable round and asserts the budget invariant after
each simulated pick, which is what proves the client's copy of the rules still
matches the server's.

After anything that touches what this app loads, or any Access policy:

```bash
node apps/pick3cut5/test/smoke.mjs --remote
```

That one fetches the app and its assets from production with **no** Access
session and checks the rest of the site is still gated. It is the only check
that can catch the bug it was written for, and a browser tab you are logged
into cannot tell you the same thing.
