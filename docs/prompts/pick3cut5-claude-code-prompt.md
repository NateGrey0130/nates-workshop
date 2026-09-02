# Build: Pick 3 Cut 5 (Nate's Workshop)

## Repo context

This is `nates-workshop`, a Cloudflare-hosted suite of personal apps. Apps live at `/apps/<name>/index.html`, each self-contained. Serverless code lives in `functions/`. The rest of the site sits behind Cloudflare Zero Trust.

Read the existing repo before writing anything. Match the file layout, naming, and visual language of the apps already there (MediaVault, FilamentForge, Spool Scout).

## The game

Someone types a category. Claude generates 8 items. Players never see the list. Items are revealed **one at a time**, and on each one every player commits to keep or cut before knowing what's coming next.

Each player has a budget of **3 keeps and 5 cuts** across the 8 items.

There is no score and no winner. The tension is spending a keep on item 2 and then watching something better show up at item 6. The argument is the product. Do not add points, streaks, or leaderboards.

## Round flow

1. Host enters a category.
2. DO calls Anthropic once, gets 8 items, and **shuffles them server-side**. Critical: models tend to list the most famous entry first, which would make item 1 an automatic keep for everyone and flatten the game.
3. Players ready up in the lobby.
4. **Item is revealed alone.** Every player privately chooses keep or cut.
5. When all have chosen, all choices **flip simultaneously**.
6. **Summary screen**: each player's remaining keeps and cuts, plus their running list of keeps so far.
7. Every player taps accept. Next item reveals. Repeat through item 8.
8. **Final screen**: everyone's final 3 side by side. Nothing else. No stats, no commentary, no vote.

### Hidden information is a real constraint

The client must never receive an unrevealed item. Not in the initial payload, not preloaded, not hidden in the DOM. The full list lives in DO memory only and items are pushed one at a time. Anyone with devtools open would otherwise see the whole game.

## Forced picks

A player's budget can run out or exactly fill the remaining items. When either happens, the rest of their choices are made automatically:

- `keeps_remaining == 0` → every remaining item is auto-cut
- `cuts_remaining == 0` → every remaining item is auto-keep
- `keeps_remaining == items_remaining` → every remaining item is auto-keep
- `cuts_remaining == items_remaining` → every remaining item is auto-cut

Auto-picks still consume budget, so the math always lands on exactly 3 and 5.

**Even when every player is fully forced, keep revealing each remaining item normally.** Auto-picks flip publicly along with everyone else's. Watching someone get locked into keeping something terrible is the best moment in the game, so do not skip ahead to the final screen.

Auto-picks must be **visually distinct** on the flip, labeled clearly ("auto-cut", not "cut"), and should land last in the reveal stagger.

## Timers, drops, and stalls

Accept-gating every player means one distracted person freezes eight screens. Escape hatches:

- **Pick phase timer.** Default 60 seconds. On expiry, auto-pick for anyone who hasn't chosen.
- **Accept phase timer.** Default 30 seconds. On expiry, auto-accept and advance.
- Both durations configurable by the host in the lobby.
- **Player disconnects**: auto-pick on their behalf and keep the game moving. Hold their seat and their board so they can rejoin with the same name and pick up where they left off.

**Open decision for you to make and tell me about:** when a timeout or disconnect forces an auto-pick and the player still has *both* keeps and cuts available, which does it choose? My instinct is cut, since it preserves their keeps for later and is the less committal option. Push back if you see a better rule.

## Two modes

**Party** — real-time rooms, everything above.

**Solo** — same blind sequential flow, no room, no socket, no accept gates. Type a category, get revealed items one at a time, spend your 3 and 5, see your final board. All local state plus a generation call.

## Stack

- Cloudflare Pages + Pages Functions
- One Durable Object per room, using the WebSocket Hibernation API
- No D1, no KV, no R2. All game state lives in DO memory and dies with the room.
- Anthropic API key stays server-side. It must never reach the client.
- Vanilla HTML/CSS/JS, single file per app, consistent with the rest of the Workshop. No build step, no framework.

**Verify before you architect:** confirm whether Cloudflare Pages Functions can host a Durable Object *class* or only bind to one. Historically Pages could only bind to a DO exported from a separate Worker. If that's still the case, either (a) deploy the DO as its own small Worker and bind it from Pages, or (b) move this app to a Worker with static assets. Tell me which you picked and why before you build.

## Room lifecycle

- Host creates a room, gets a 4-character uppercase code. Exclude ambiguous characters: no O, 0, I, 1.
- Room code is the DO name. No lookup table needed.
- Players join with code plus a display name. Max 12 players.
- Host controls: start round, force-advance, adjust timers, kick player.
- If the host disconnects, promote the longest-connected player.
- Room self-destructs via DO alarm 5 minutes after the last socket closes.
- After the final screen, host can start a new category with the same players.

## State machine

`lobby` → `generating` → `revealing` → `picking` → `flipping` → `summary` → (loop back to `revealing` for items 2 through 8) → `final`

## Protocol

Define the message contract explicitly in a comment block at the top of the DO file.

Client → server: `join`, `ready`, `start_round`, `submit_pick`, `accept`, `force_advance`, `set_timers`, `kick`, `leave`

Server → client: `state`, `item_revealed`, `pick_progress`, `flip`, `summary`, `final`, `error`

The server broadcasts a **full state snapshot** on every change rather than deltas, minus any unrevealed items. Rooms are tiny and this removes an entire class of desync bug. Client renders from the snapshot only and holds no authoritative state of its own. All budget math happens server-side; the client's copy is display only.

`pick_progress` reports *how many* players have chosen, never *what* they chose.

## Generation

A bad list ruins the round. The previous version of this game served items that did not actually qualify for the category, including people who had retired years earlier being listed as currently active. That is a knowledge cutoff problem, not a prompting problem, and it needs web search to fix.

Generation is a **three-step pipeline**, all inside the DO.

### Step 1: Classify the category

One cheap fast call. Given the category string, return JSON with:

- `verifiable`: is membership in this category an objective fact (rosters, filmographies, records, release dates, championships) or a matter of taste (best pizza toppings, worst movie tropes)?
- `time_sensitive`: does the category contain or imply a currency constraint? Words like current, active, this season, 2026, still playing, on a roster. This flag forces web search regardless of anything else.
- `viable`: can this category plausibly yield 8 distinct well-known items at all?

If `viable` is false, error out immediately with a message the UI can show. Do not burn the generation call.

### Step 2: Generate candidates

Ask for **12 candidates, not 8**. The overage absorbs verification failures and exclusion-list drops without a retry loop.

System prompt: return only a JSON array of strings. No markdown fences, no preamble, no numbering, no ranking.

Ask for a deliberate mix of obvious keeps and genuinely debatable middle-tier entries, so the cuts actually hurt. Items should be specific and recognizable to someone who knows the category. Explicitly instruct the model not to order by quality.

If `verifiable` or `time_sensitive` is true, enable the web search tool on this call.

### Step 3: Verify

Skip entirely if `verifiable` is false. Taste has no false positives.

Otherwise: a separate call, with web search enabled, given the category and the 12 candidates. For each candidate it returns `pass` or `fail` plus a one-line reason on failure.

This must be a **separate call from generation**. A model asked to generate and self-check in one pass will rubber-stamp its own output.

Instruct it to be specifically suspicious of:
- Status claims that decay (active, current, signed, in office, still running)
- Attribution to the wrong person, team, studio, or year
- Things that sound right but do not exist

Keep the first 8 that pass, then shuffle. If fewer than 8 survive, run one more generation round excluding everything already seen, then error cleanly rather than shipping a padded list.

Cache verification results per item per category inside the room so replays do not re-verify the same names.

### Replay: same category, new list

Players can rerun a category they already played. The new list must exclude everything already used.

- The room keeps a used-items set keyed by normalized category string (lowercased, trimmed, punctuation stripped).
- Pass the exclusion list into the generation prompt, **and then hard-filter the response against it in code**. Models routinely ignore exclusion lists, especially long ones. The programmatic filter is the actual guarantee; the prompt is a hint.
- Normalize when comparing, so "Scump" and "scump" and "Scump (Seth Abner)" collapse to one entry.
- Grow the candidate ask as the exclusion list grows. After two replays you are excluding 16 items and 12 candidates will not be enough.
- Categories run dry. When fewer than 8 fresh verified items come back, say so plainly: "This category is running out, only 5 new items left." Offer a new category rather than repeating.

### Other handling

- Malformed JSON at any step → one retry, then a clean error state
- Category empty or nonsense → reject before any API call
- Model strings go in environment variables, not hardcoded

### Latency tradeoff, your call

Three calls plus web search means roughly 10 to 20 seconds between a host submitting a category and the first item appearing, versus about 3 seconds for a single unverified call. In a live party game that is a noticeable dead spot.

Default to the full pipeline, because a wrong list is worse than a slow one. Mitigate the wait rather than cutting the verification:

- Run classification while the host is still typing, debounced
- Show what is actually happening in the loading state. "Checking these are current" is worth waiting through in a way that a spinner is not.
- Prefetch the next category's list during the final screen if the host has already entered one

## Access and abuse

Add a Cloudflare Access **bypass** policy for `/apps/pick3cut5/*` and its API routes. Everything else in the Workshop stays gated. The room code is the only barrier for party mode.

That makes a generation path publicly reachable, which is a real cost risk. Guardrails:

- Party mode generation happens only inside the DO. No public general-purpose `/api/claude` for this app.
- Solo mode needs a public generation endpoint. Put it behind Cloudflare Turnstile or a per-IP rate limit, your call, but say which.
- One generation per room per 20 seconds. Note that one "generation" is now up to three calls plus web search, so this limit matters more than it did.
- Max 30 rounds per room lifetime.
- Cap replays of a single category at 3. Past that the exclusion list makes results poor anyway.
- Web search is the expensive part. Only enable it when the classifier flags `verifiable` or `time_sensitive`.
- Category input capped at 60 characters, newlines stripped, basic charset validation before it reaches the model.
- Cap `max_tokens` tightly. Eight short strings needs very little.

## Interface

Mobile first. This is played on phones in a living room.

- The reveal of each item is the heartbeat of the game. One item, large, alone on screen. Give it a beat before the keep/cut buttons become active so nobody fat-fingers it.
- Keep and cut are two big thumb-reachable targets. No precision required, no confirm dialog.
- The flip is the payoff. Stagger players in, land auto-picks last.
- Remaining budget must be glanceable at all times. A player deciding on item 5 needs to know they have 1 keep left without hunting for it.
- Room code readable from across a room.
- Timers visible but not stressful. No aggressive countdown sounds.
- Respect `prefers-reduced-motion`.
- Visible keyboard focus states.
- Match the Workshop's existing dark palette and type scale rather than inventing a new identity.

Copy should be plain and active. Buttons say what happens: "Keep it" and "Cut it", not "Submit".

## Deliverables

1. `apps/pick3cut5/index.html`
2. The Durable Object class, wherever your architecture decision puts it
3. Solo-mode generation endpoint
4. `wrangler.toml` changes with the DO binding and migration
5. Workshop `index.html`: flip the Pick 3 Cut 5 card from "soon" to live
6. README section covering local dev with `wrangler pages dev` and how to test multiple clients against one room

## Non-goals

No accounts, no game history, no saved category packs, no scoring, no leaderboard, no database. If you find yourself wanting one of these, stop and ask instead of adding it.
