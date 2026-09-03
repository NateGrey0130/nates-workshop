# Pick 3 Cut 5 — outstanding items, 2026-08-24

> **`F12` is OPEN.** `F11` was taken 2026-09-03; everything else here is closed,
> re-verified on 2026-09-02: `F1`–`F10` and `T1`–`T11`. **`F12` was opened while
> filing `F11` and is the stronger of the two** — `F11` guarded the HTML door,
> and `F12` is the one a stylesheet walks through.
>
> **Two that misread.** The eleven `T` items are **bold paragraph leads**, not
> headings — `**T1. … — PASSED.**` under `## T — paths that have never run` — so
> a scan walking `###` never sees them. And `T6`'s entire outcome lives in its
> own heading (*"DID NOT TRIGGER, AND THAT IS THE FINDING"*) with no note
> beneath it saying so.
>
> `F6` reads *"**Not now**, as recommended"* and `F10` *"**Not code** — nothing
> to implement"*. Both are closed. A grep for `Taken` finds neither, and that
> already produced one withdrawn finding in `DOCS-AUDIT.md` (`D5`).

Written at the end of the build session that shipped the app, against `main` @
`601d45f`. Everything below is either a path that has **never run**, a decision
deliberately deferred, or a proposal. Nothing here is a known-broken behaviour:
what was found broken during the session was fixed and merged (#249–#254).

Verification basis for the "verified" column throughout: three full solo rounds
and two full two-player party rounds played against **production**, plus the
targeted checks named per item. Both smoke suites and the new Access suite pass
on `main` (58 + 1,270 + 23 checks).

## What is actually proven

Exercised live, in production, end to end:

- A full round in both modes, budget landing on exactly 3 keeps and 5 cuts
- **Hidden information** — a 35-message audit of one round's client stream: only
  already-revealed items ever crossed the wire, no `items`, `reserve` or
  prefetched list, `pick_progress` carrying counts only
- **Forced picks** — cascades in both directions, revealed one at a time rather
  than skipped, `auto-cut` / `auto-keep` distinct from `timed out`
- **Pick-timer expiry** — auto-pick defaulting to cut, labelled `timeout`
- **The swap** — host and non-host, refund of a committed pick, refund of a
  budget-forced pick, one-per-player-per-item, refusal after the flip, stale
  category falling through instead of serving the wrong list
- **Prefetch** — 57 ms (party) / 109 ms (solo) to first item, lobby attempts
  ignored, changing the category falling through to a normal generation
- **Generation** — all three classifications measured (3 s taste, 3 s static
  fact, 99 s time-sensitive; the last rejected 2 of 12 candidates)
- **Reconnect** — a room wedged 220 s past its deadline walked forward through
  six missed items on the next message and landed correctly on the final screen
- **Access posture** — app and its two shared assets reachable unauthenticated;
  `/`, `/api/claude`, `/shared/js/api.js`, `/apps/character-creator/` still gated

---

## T — paths that have never run

**RUN 2026-08-24.** Outcomes recorded against each. Nine of the eleven were
exercised for real; the two that were not are marked and say why.

The headline is T6: the "category is running out" path is far harder to reach
than it looks, because a generator asked for eight fresh items pads rather than
admits defeat. Everything else passed.

**T1. More than two players. — PASSED.** A full twelve-player room played eight
items. Twelve flips on every item; auto-picks landed last at full size exactly
as at two (`mmmmmmmmmmAA`); a thirteenth join was refused with *"This room is
full (12 players)"*. Every player finished 0k/0c with **exactly three keeps**,
including two who never touched their phones and got there on timeouts alone.

Original note: The cap is 12; every round played had 2. The
reveal stagger, the flip ordering, the summary board layout and the
accept-gating were all designed for a full room and have only ever rendered
two rows. *Cheapest real fix: play one six-person round.*

**T2. Host disconnect and promotion. — PASSED.** Ana (host) dropped; her seat
was held as `[away]`, **Bo** — the longest-connected remaining player — was
promoted, and a third player was still refused host actions.

Original note: `promoteHost()` picks the
longest-connected remaining player. Never triggered. The seat-holding and
rejoin path around it **is** proven — a reconnect under the same name resumed
a wedged room correctly — but the host handover itself has not run.

**T3. Kick. — PASSED.** The newly promoted host kicked Dev; the seat was
removed and Dev's socket closed with policy code `4403`.

Original note: `onKick` closes the target's socket, removes the seat, and can
complete a phase by removing the last holdout. Never called.

**T4. Room self-destruct. — PASSED.** A one-player room, socket closed, left
strictly alone. At **6.0 minutes** a rejoin got close code `4404` and
*"No room with that code. It may have expired."* with `fatal: true` — the alarm
fired, `deleteAll()` ran, and the browser gets a clean message rather than a
failed upgrade.

Worth knowing: an earlier attempt failed because my own probe rejoined at the
2-minute mark and **reset the clock**, which is the timer working correctly.
Anyone re-testing this must leave the room untouched for the full five minutes.

Original note: The 5-minute alarm after the last socket closes,
and the `deleteAll()` behind it. Never waited out. Worth noting this is the
only path that deletes anything.

**T5. Replay of the same category. — PASSED.** Three generations of one
category in one room. Two captured rounds produced **16 items, 16 unique, zero
overlap** — the code-side exclusion filter holds.

Original note: The used-items set, the exclusion list,
the growing candidate ask, and the per-category verification cache are all
implemented and none has run twice on one category in one room. This is a
meaningful gap: the exclusion logic is the part most likely to be subtly wrong,
because models ignore exclusion lists and the code-side hard filter is the only
real guarantee.

**T6. A category running dry. — DID NOT TRIGGER, AND THAT IS THE FINDING.**

"Beatles studio albums" is a finite set of thirteen. Two rounds in one room
served **sixteen** items. Round one was eight legitimate albums; round two
padded with *Beatles '65*, *The Early Beatles* and *Hey Jude* (US compilations)
plus *Long Tall Sally* and *Beatles for Sale No. 2* (EPs). Not one is a studio
album.

So the generator does not run dry — it invents adjacent-but-wrong entries, and
`survivors.length < 8` only fires when VERIFICATION culls them. Verification is
skipped for a category that is factual but not time-sensitive, which is exactly
what this one is. On a finite factual category the honest advice is to tick
*double-check this list*; the swap and the on-demand check are the backstop when
nobody does. Recorded in `generate.js` next to the check itself.

**T7. The caps. — REPLAY CAP PASSED; ROUND CAP STILL UNTESTED.**

Three full rounds of one category in one room, then a fourth attempt:

| attempt | result |
|---|---|
| 4th replay, same category | refused — *"You have replayed that category enough times - the list gets thin. Pick a new one."* |
| different category, same room | allowed, generated normally |
| another immediately after | *"A round is already running."* |

The **20-second cooldown** is confirmed only indirectly: every driver in this
session had to sleep 21s between generations or the next `start_round` failed.
The **30-round cap** is still untested and would need thirty real generations to
reach; it is three lines and the same shape as the replay cap above.

**T8. The solo rate limiter in production. — PASSED, with a caveat worth
keeping.** 24 requests down a single connection gave **9 allowed / 15 denied**,
matching the configured 8-per-minute.

It took three attempts to see it, and the two failures are the useful part:
sequential HTTPS round-trips to production are slow enough that ~16 of them span
more than the 60-second window, and **parallel** requests each open their own
connection, spread across colos, where the limiter is eventually consistent and
a burst leaks well past the nominal number. It caps a sustained rate; it does
not hard-stop a burst. Recorded in `index.js`.

**T9. Real phones. — DONE.** Both halves, on an iPhone, 2026-08-24.

**The backgrounding case works.** A party round, phone locked mid-round,
unlocked: the socket dropped (iOS does background it), the reconnect banner
appeared and counted through its attempts, and the session came back. That is
the failure this audit called the most likely real-world one, and the answer is
that the client's four-attempt reconnect and the server holding the seat by name
between them handle it.

Two things that follow from it being *normal* rather than exceptional: the
reconnect banner is user-facing copy that real players will actually read, and
seat-holding is load-bearing rather than a nicety — without it every screen lock
would cost a player their board.

Not separately confirmed, and only observable if the lock outlasts the pick
timer: whether `catchUpDeadline()` walked missed deadlines forward, or whether
the round simply had not moved. Either way the room was not wedged.

**The rendering half** was a solo round, and it played well. That covers the rendering half: the mobile-first layout in
real Safari, thumb reach on actual hardware, the sticky budget bar under real
browser chrome, and the reveal-pick-flip rhythm on a device rather than an
emulated 375px viewport.

Note for anyone reading this later: solo mode never opens a WebSocket, so a
solo round on a phone proves the layout and nothing about the socket. The two
halves had to be tested separately, and were.

Still not exercised on a phone: the room code read from across an actual room.

Original note: The app is mobile-first and has only ever rendered in an
emulated 375 px viewport. Thumb reach, the sticky budget bar under a real
browser chrome, and iOS Safari's WebSocket behaviour on backgrounding are all
unknown. **The backgrounding question is the substantive one** — a phone that
sleeps mid-round is the single most likely real-world failure, and the
catch-up-on-message fix was written for exactly that shape of problem without
ever being tested against it.

**T10. Screen reader and keyboard-only. — PARTIALLY RUN.**

Verified: focus ring renders (amber, 2.7px) on a genuinely focused element;
every input, checkbox and icon button is labelled; the live region carries
`role="status"` + `aria-live="polite"`; the `prefers-reduced-motion` rule
exists; no negative tabindex traps.

**One real gap found and fixed:** the three disclosure tiles had no
`aria-expanded` until first pressed, so a screen reader would announce three
buttons with no indication they open anything. They now carry
`aria-expanded="false"` and `aria-controls` at rest.

NOT verified: actual Tab traversal and Enter/Space activation — the browser
pane does not deliver those keys to the page (a `keydown` listener recorded
nothing), so this is a tooling limit rather than an app result. And no screen
reader was run.

Original note: `aria-live` announcements, focus
rings, and `prefers-reduced-motion` are all implemented; none has been driven
by an actual assistive tech.

**T11. Concurrent rooms. — PASSED.** Two rooms ran rounds simultaneously with
different codes, different categories and independent timers (180s vs 25s), and
neither saw the other's players.

---

## F — proposals

### F1. The app cannot be reviewed on a preview deployment

> **Not taken — option 2.** Previews stay gated.
>
> Reversed after costing it out. The fix is a second Access application scoped
> to `*.nates-workshop.pages.dev` (a wildcard needs its own app, since four more
> destinations would exceed the five-per-app cap), and it would make **every**
> preview of the whole site public on those four paths — including a generation
> endpoint per live preview, each reachable by anyone who guesses a deployment
> hash. That is a permanent widening of the site's exposure to buy a
> convenience on a game played by a handful of friends.
>
> The rule instead: **this app is verified on production immediately after
> merge**, which is what has actually happened every time. It is weaker than a
> preview and it is honest about being weaker — the `/shared` bug reached
> production precisely because "the route answers" was mistaken for "the page
> works", and `apps/pick3cut5/test/smoke.mjs --remote` is the check that closes
> that gap regardless of where it runs.

The Access bypass application targets `nates-workshop.pages.dev`. A preview
deploys to `<hash>.nates-workshop.pages.dev`, which that application does not
match — and the auto-created preview-access application gates it. So party mode
on a PR preview will send an unauthenticated player to the login wall, and an
authenticated one past it.

Consequence: **the normal review workflow cannot exercise this app.** Every
verification this session was either local or against production after merging,
which is precisely the gap that let the `/shared` bug reach production.

Options, roughly in order of how much I like them:
1. Add `*.nates-workshop.pages.dev` destinations to the bypass app — simple,
   but it makes every preview of the whole site public on those paths.
2. Accept it, and make "verify on production immediately after merge" the
   documented rule (it is already what happens).
3. Custom domain for production, leaving `pages.dev` for previews, and scope
   the bypass to the custom domain.

Not obviously worth solving on its own; worth solving as part of F6.

### F2. There are no tests for the game logic

> **Taken.** `workers/pick3cut5-room/src/rules.js` extracts the budget rules as
> pure arithmetic; `apps/pick3cut5/test/game.mjs` walks all 56 reachable rounds,
> proves every one lands on 3 and 5, and lifts `soloForced()` out of app.js to
> compare both implementations across all 192 states. Proven to fail by
> diverging the client copy.
>
> It also turned up something the audit did not know: **two of the brief's four
> forced-pick rules can never fire** under a consistent budget — `keeps ===
> remaining` implies `cuts === 0`, which the first rule already caught. They are
> defence against an inconsistent budget, which is why the comparison runs over
> the full grid rather than the reachable one.

The new smoke suite covers Access posture and three structural hidden-info
guards. It does **not** cover the budget arithmetic, the four forced-pick rules,
the swap refund, or the phase machine. Every one of those was verified by hand
this session and none is pinned.

The forced-pick rules exist in two places — `forcedChoice()` on the server and
`soloForced()` in the client — with a comment saying the server's copy is the
real one. Nothing enforces that they agree. A divergence would be invisible
until a solo player's budget didn't add up.

Proposal: a `test/game.mjs` that imports the pure functions and asserts the
budget lands on 3/5 across every reachable pick sequence, that the two
`forced` implementations agree on all reachable states, and that a swap refund
restores exactly what it spent. No network, no wrangler — the FilamentForge
smoke test is the model.

**This is the item I would take first.** It is the only one that makes the next
change to this app safe.

### F3. Spend on this app is invisible

> **Taken.** `DB` bound to the Worker for metering only; one `claude_usage` row
> per model call, null email, endpoint `pick3cut5-party` / `pick3cut5-solo`.
> Verified: one solo generation writes two rows (classify on Haiku, generate on
> Sonnet 5) with real token counts. The fail-open contract proved itself by
> accident — the table did not exist in the Worker's local D1, the write was
> swallowed, and generation still returned in 4.3 s.

Deliberate — you said no database and I followed it. The consequence is worth
restating plainly: this Worker writes no `claude_usage` rows, so the query in
SETUP.md under *Who is spending the Anthropic key* silently excludes the one
generation path a stranger can reach. The rate limiters and room caps bound the
damage; nothing reports it.

Proposal: bind `DB` to the Worker read-only-in-spirit and call the existing
`recordUsage()` fail-open. Roughly 15 lines. Game state stays in DO memory, so
the non-goal stays true in the sense you meant it.

### F4. The Anthropic key lives in two places

> **Not taken** — no clean fix while the Durable Object is a separate Worker.
> Dissolves with F6 whenever that happens. Documented in SETUP.md.

Pages secret + Worker secret. Rotation is a two-place job and nothing checks
they match; a stale Worker key surfaces as `502 The list service is having a
moment` with the real reason only in the Worker log.

No clean fix while the DO is a separate Worker — it is a direct consequence of
the architecture. Mitigations: document it harder (done), or F6.

### F5. Make the app self-contained and drop the `/shared` dependency

> **Not taken.** The Access smoke test already catches the failure this would
> prevent, and the brief asked the app to match the Workshop's palette.

The bug that broke production for its whole audience was: a public page loading
gated assets. The Access destinations fix the symptom. Inlining `escHtml` and
the handful of design tokens the app uses would remove the class of bug
entirely, free two of the five Access destination slots, and make the public
app independent of files that might later contain something that should not be
public.

Cost: the app's look drifts from the rest of the Workshop as `shared/styles.css`
evolves, against your brief's "match the existing palette and type scale". The
smoke test now catches the drift-in-the-other-direction, which weakens the case
for doing this.

Genuinely balanced. I lean **no** on the strength of the test existing, but it
is a real option and it is the only one that makes the failure impossible
rather than merely detected.

### F6. Fold the Worker back in (the Pages → Workers migration)

> **Not now**, as recommended. `docs/pages-to-workers-migration.md` stands.
>
> **Confirmed on hold, 2026-08-25.** The trigger is unchanged: the day a
> second app wants a Durable Object, this stops being optional.

`docs/pages-to-workers-migration.md` covers this. Doing it would dissolve F1
(previews), F4 (two secrets), and the separate deploy step, and would let solo
generation use the native rate-limit binding directly instead of proxying.

My recommendation has not changed: **not as a prerequisite for anything.** The
day a second app wants a Durable Object, this stops being optional.

### F7. Verification is off for static factual categories

> **Taken.** A *double-check this list* toggle on all four category inputs,
> carried through `start_round`, the prefetch, and the solo endpoint. A prefetch
> built without the check cannot satisfy a request that asked for it.
> Verified: `best road trip snacks` — a taste category that normally skips
> verification entirely — ran `verify: 4356 ms` with the box ticked.

The 70 s → 3 s win came from gating verification on `time_sensitive`. The cost
is real and was observed twice in one round: *Four Rooms* (an anthology with
four directors) and *True Romance* (written by him, directed by Tony Scott)
both reached the table as "Quentin Tarantino films".

The swap caught both, which is the trade working as designed. But it depends on
someone at the table knowing. A room that does not know plays a wrong list.

Proposal, if this bothers you in play: a host toggle in the lobby — *check this
one* — that forces verification for a category the room cares about being
right. Opt-in, so the default stays fast.

### F8. The shuffle can bury a category's best entries

> **Not taken.** Reverting the shuffle reintroduces the fame-ordering the brief
> called out as the thing that flattens the game. Revisit after playing it with
> people, which is the only place the answer lives.

Observed live: a *Quentin Tarantino films* round where **Jackie Brown never
appeared**, with two spares still sitting in the reserve at the final screen. A
player held a keep for it across all eight items for nothing.

This is arguably correct — the game deals 8 of 12+ and the tension is the point.
But with a deep category it means the round can simply omit the entries the
argument was going to be about. Worth deciding whether that is a feature.

If it is not: bias the 8 toward the front of the verified list rather than
shuffling the whole pool, and keep the shuffle only for ordering. That
reintroduces exactly the fame-ordering problem the shuffle was added to solve,
so I would leave it alone unless it annoys you in play.

### F9. Swap history disappears

> **Taken.** A single line under the final boards: *Ana called out ~~Four
> Rooms~~ at item 3*. Rejected items were all revealed before replacement, so
> it leaks nothing.

The callout banner shows the current item's swap and clears on the next reveal.
The final screen shows three keeps and nothing else — per the brief, correctly.

But "Bo called out True Romance" is one of the better things that happens in a
round, and it is gone by the time anyone looks at the boards. A single line
under the final boards — *2 items swapped* with the names — would cost nothing
and violates the "no stats, no commentary" rule only in the letter.

Your call; the brief is explicit and I would not add it unasked.

### F10. The wedge fix is insurance of unknown necessity

> **Not code** — nothing to implement. Recorded here so the next reader treats
> `catchUpDeadline()` as unproven insurance rather than a fix for a known
> production bug.

`catchUpDeadline()` walks missed deadlines forward on every message. It was
written after a local hot-reload lost an alarm, and it demonstrably recovers a
room stuck 220 seconds past its deadline.

I do not know whether a **production** Durable Object can lose an alarm the same
way. If it cannot, this is dead code on the hot path — one timestamp comparison
per message, so the cost is nil, but it is unproven insurance and should be
described that way rather than as a fix for a known production bug.

---

### F11. The "external assets are fonts only" check has passed vacuously since the fonts came off the CDN

**Filed 2026-09-03 from `META-AUDIT` `A5`, which is the only reason it has a
number.** It was found during the `SETUP.md` v2 rewrite on 2026-09-02, recorded
in `SETUP-v2-CHANGES.md`'s decisions paragraph as *"filed for a separate PR"*,
and never filed. It sat in a sentence with no heading and no number, under a
header that correctly said everything numbered was closed, for a day.

`apps/pick3cut5/test/smoke.mjs` derives what must be public by reading
`index.html`, and asserts:

```js
check('external assets are fonts only',
  external.every((r) => r.startsWith('https://fonts.googleapis.com/')), …);
```

`external` is the `<script src>` / `<link href>` refs matching `^https?://`.
**There are none.** The fonts were self-hosted into `shared/fonts/` during the
Rust & Ash work, so the array is empty and `[].every(…)` is `true`. The check
passes without comparing anything, and would keep passing if the assertion were
inverted.

**Measured 2026-09-03** by running the file's own regex over `index.html`: 5
refs, **0 external**. `shared/fonts/` holds `saira-variable.woff2` and
`ibm-plex-sans-variable.woff2`, so the self-hosting is real and this is not a
regression waiting to be noticed — it is a guard that stopped guarding when the
thing it guarded went away.

**What it was for still matters.** A `<link>` back to a font CDN would put an
unauthenticated third-party request on the one page outside the Access wall, and
nothing else in this suite would say so.

**Proposal, and it is a judgement call rather than a mechanism.** Two options,
and this finding does not pick one:

- **(a) Assert the invariant that is actually true**: `external.length === 0`,
  with a message naming what a non-zero means — a dependency the Access
  destinations do not cover. This is the anti-vacuous-pass shape `DOCS-AUDIT-2`
  `D1` and `REPO-AUDIT` `G8` both landed on, and it fails the moment a CDN
  `<link>` returns.
- **(b) Delete it.** The check has no live subject; `F12` below is the gap that
  does.

**Do not read (a) as covering the CSS path.** It does not, and `F12` is why.

**Posture: one check, no exit-code change beyond what the suite already does,
and no change to what is public.** This is a test finding, not an Access change.

**Evidence:** the file's own regex run over `apps/pick3cut5/index.html`,
2026-09-03 — 5 refs, 0 external; `ls shared/fonts`; `smoke.mjs:87-89` read the
same day. The history is **reported by** `SETUP-v2-CHANGES.md` and
`docs/prompts/setup-v2-rewrite-prompt.md`, which flagged it out of scope and said
to file it separately.

**Taken, 2026-09-03 (PR #653) as option (a). Posture held: one check, no exit
code moved beyond what the suite already does, and nothing about what is public
changed.** Smoke 47 → **47** — one assertion replaced, not added.

The check now reads *"index.html fetches nothing from a third party"* and asserts
`external.length === 0`. Its failure message names the URL and says what a
non-zero means: **an unauthenticated request from the one page outside Access.**

**Option (b), deletion, was rejected on `F12`'s account.** `F12` needs a home for
the external-CSS half, and deleting this check would mean re-adding it one PR
later. Recording the reason because the finding deliberately picked neither.

**Proved by making it fail, which is the only way this one could be proved** — it
had passed every run since the fonts were self-hosted while comparing nothing.
Injecting a `<link>` to a font CDN into `index.html`:

| | on the injected regression | on the real page |
|---|---|---|
| the old predicate | **PASSES** — the CDN link is exactly what it allowed | passes vacuously, nothing compared |
| the new predicate | **FAILS**, naming the URL | passes, having asserted the invariant |

`SMOKE TEST FAILED (1 of 47 checks)` on the injection, `PASSED (47)` after
restoring `index.html` — confirmed unchanged by `git diff`. **The old check would
have waved through the precise regression it was written to catch**, which is
worth more than the vacuity: it was not merely silent, it was permissive.

**One correction to this finding's own evidence line.** It says *"5 refs, 0
external"*. The test's regex matches `<script>` and `<link>` only and finds
**4**; the fifth was `<a href="/">`, which the file's own comment excludes on
purpose — counting a navigation as a dependency would demand a bypass that must
never exist. My count used a looser pattern than the "file's own regex" I claimed.
**`0 external` is right either way and is the half the finding rests on.**

**Deliberately still true after this PR: the check is HTML-only**, and its
comment says so and points at `F12`. A `url()` inside a stylesheet has no tag and
never enters `external`.

---

### F12. A stylesheet that fetches a font from a third-party CDN is invisible to both halves of the derivation — and a protocol-relative one is read as same-origin

**Opened 2026-09-03 while filing `F11`**, by checking a claim `META-AUDIT` `A5`
made in passing and finding it false. `A5` said fixing `F11` *"would have caught
`REDESIGN-AUDIT` `N6`'s CSS-fetched font."* **It would not**, and the reason is a
gap worth more than `F11`.

The derivation has two halves and an external CSS request falls between them:

| | sees a `<link>` to a CDN | sees `url(https://cdn/…)` inside a stylesheet |
|---|---|---|
| §1 the HTML scan | **yes** — that is `F11`'s check | no — there is no tag |
| §1b the CSS scan | n/a | **no** — its regex requires a leading `/` |

§1b closed the gap `R7`/`N6` walked through, which was a **same-origin** font
loaded from CSS. It matches `url\(\s*['"]?(\/[^'")\s]+)…\)`, and the leading `/`
is load-bearing: an absolute third-party URL never matches.

**Proved by running the regex, 2026-09-03**, rather than read off the source:

| in a stylesheet | result |
|---|---|
| `url(/shared/fonts/saira-variable.woff2)` | matched |
| `url(https://fonts.gstatic.com/s/saira/v1/x.woff2)` | **not seen** |
| `url(//fonts.gstatic.com/x.woff2)` | **matched as `//fonts.gstatic.com/x.woff2`** |

**The third row is the worse half and was not expected.** A protocol-relative
url() matches, and is then treated as a same-origin absolute path: it is folded
into `requiredPublic` by directory, so the derived list would demand an Access
destination for `//fonts.gstatic.com`. That is a **wrong answer rather than a
missing one**, and this app has five destinations with none spare.

**Why this is the version that matters.** `F11`'s check guards a door the fonts
already left. This one is the door they would come back through: the Rust & Ash
work moved fonts into CSS, so a future `@font-face` pointing at a CDN is the
realistic regression, and the suite is silent on it in one direction and wrong in
the other.

**Nothing is broken today.** Measured 2026-09-03: the stylesheets the page loads
reference `shared/fonts/` only, `requiredPublic` derives correctly, and
`smoke.mjs` and `smoke.mjs --remote` both pass. This is a blind spot, not a live
fault.

**Proposal.** Extend §1b to collect **every** `url()` target, not only those
starting `/`, then split them: same-origin absolute paths feed `requiredPublic`
as now; anything with a scheme or a leading `//` is an **external** CSS request
and joins whatever `F11` decides about external HTML refs. One assertion covering
both doors rather than one per door.

**Posture: extend the derivation, change nothing about what is public, and add no
Access destination.** If the two findings are taken together the assertion should
be one check over both sources; if `F11` is taken alone, it must not be worded as
though it covers CSS.

**Evidence:** the regex run against three synthetic stylesheet lines,
2026-09-03 (table above); `apps/pick3cut5/test/smoke.mjs` §1 and §1b read the
same day; `node apps/pick3cut5/test/smoke.mjs` green before and after filing.

---

## Not doing, unless you say otherwise

Recorded so they are decisions rather than omissions:

- Scoring, streaks, leaderboards, game history, saved category packs — the
  brief's non-goals, honoured
- Accounts of any kind; the room code remains the only barrier
- Prefetch on the solo path beyond 3 per session, because it shares the public
  endpoint's per-IP budget
- Any general-purpose `/api/claude` exposure for this app
