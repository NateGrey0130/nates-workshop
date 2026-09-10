# Campaign log, NPCs and play mode

Everything that happens at the table rather than during creation.

Part of the [character creator](../README.md) documentation.

---

## Anyone at the table can write the log

`journal_entries` existed and was reachable only from a character sheet, and
only the G.M. could write a campaign-level entry. There was no campaign-level
place to read the log, no search over it, and nothing tracking what the party
held together.

[`campaign.html`](../campaign.html) is the campaign's own page: the note feed with
a composer, the search box with an **Ask** button beside it, the party stash and
the currency ledger.

### Membership is not a table

A person may read and write a campaign's notes if they are its **G.M.** or they
**own a character assigned to it**. That is a query, not a schema:

```sql
SELECT 1 FROM characters WHERE campaign_id = ? AND player_email = ? LIMIT 1
```

There is no `campaign_members` table, deliberately. Owning a character in a
campaign is what being a player *is*, so an invite list would be a second and
weaker statement of the same fact, kept in sync by hand. Rejected alongside it:
a join code, which lets anyone with site access into any campaign they have the
code for.

The cost is real and accepted: **a spectator, or a player between characters,
cannot post.** When that bites, an invite list can be added inside
`campaignAccess()` and nothing else has to learn about it — that function is the
only thing that knows the rule, which is what makes the decision reversible.

**Joining is creating a character, and the GM holds the door.** Because
membership is "owns a character here", an ungated `POST /characters` was an
ungated door onto the campaign's notes, stash and ledger — anyone on the site
could pull up a chair (the audit's F1). `campaigns.open` (migration 037)
defaults to that open table for every campaign that exists; a GM who unticks
**Open to new characters** on the dashboard closes it, and the create endpoint
then refuses anyone who is not the GM or already a member. Who counts as a
member stays `campaignAccess()`'s question. The wizard's campaign picker shows
a closed campaign **disabled with the reason**, the barred-occupation pattern —
a player looking for their table should learn it is closed, not that it does
not exist — and the server refuses regardless, because a disabled `<option>` is
a hint and not a rule.

Three permissions, not one:

| | who |
|---|---|
| read and write notes, stash, ledger | any **member** (`canWrite`) |
| edit or delete one entry | its **author**, or the G.M. |
| `gm_notes` on the campaign | the **G.M.** alone (`isGm`) |

Everyone in a campaign writing notes is one thing; any of them rewriting each
other's account of a session is another, so the G.M. keeps the moderator's key
because somebody has to have it.

**Widening `canWrite` widened something else.** `campaigns/[id]`'s PATCH checked
`canWrite` back when that meant "the G.M.", so the moment membership widened it,
every player could edit the campaign's `gm_notes` — the one pre-existing secret
in an app that had just decided it has none. That endpoint checks `isGm` now.
Anything else that reaches for `canWrite` should be read the same way: it is a
different question than it used to be.

**Reads are member-gated here, which is narrower than the rest of the app**,
where any authenticated friend may read a character sheet. A sheet being
readable and a table's session notes being readable are different things.

**There are no G.M.-only notes and no hidden fields**, decided explicitly rather
than by omission: a G.M. keeping secrets keeps them outside the app. That is
load-bearing — it means the search index and the ask endpoint need no visibility
filtering at all beyond "is this person in this campaign". Adding secrets later
means auditing every one of those paths, so it is worth re-opening deliberately
rather than drifting into.

### Search is free, asking costs a call

Two mechanisms, one box. Typing searches; a button asks.

- **Search** is SQLite **FTS5** over titles and bodies — instant, free, runs
  debounced as you type, and returns a highlighted snippet so a result says
  *why* it matched.
- **Ask** sends the best-ranked entries to Claude and returns a written answer
  **citing the entries it used**, resolved from `[#id]` back to rows the page
  links to. One deliberate press, one model call.

Rejected: keyword-only, which cannot answer *"what did the baron want from
us?"* — the actual question people ask; and routing every query through the
model, which is slow and paid for what `LIKE` would have answered.

Three things this got wrong first:

- **A human's query is not an FTS5 query.** `the baron's men` is a syntax error,
  not a search: FTS5 reads the apostrophe as syntax. Every run of word
  characters becomes one quoted term instead, which is both what a person means
  and injection-proof. The last term gets a trailing `*`, so results narrow
  while the word is still being typed.
- **`snippet()` returns markup, and the text around a match is a note somebody
  typed.** Asking for `<mark>` means building HTML out of user input; escaping
  it client-side escapes the marks with it. So the delimiters are U+0001 and
  U+0002 — two characters no keyboard produces — and the client escapes first
  and swaps them for tags after.
- **A question is not a search, and AND-ing it retrieves nothing.** The search
  box wants every word to appear, because that is how a list narrows as you
  type. An ask does not: *"what did the baron's men want, and do we still have
  the rune sword?"* with every term required matches no entry ever written. The
  endpoint retrieved nothing, handed the model an empty context, and got back a
  perfectly correct *"the notes do not record it"* — **a failure that looks
  exactly like the feature working.** `toMatchQuery` takes `{ join: 'OR' }` for
  the ask path and lets `bm25` do the ranking.
- **A question with no searchable words retrieves nothing either.** *"What
  happened last time?"* matches on no keyword and is exactly what people ask, so
  a question that yields no terms falls back to the most recent entries.

**What Ask may read:** the campaign's notes, the party stash and the currency
ledger — *"do we still have the rune sword"* and *"how much have we spent"* are
the same kind of question living in different tables. **Not** the party's
character sheets, decided explicitly: sheet questions are answered by looking at
the sheet, and five full characters would dominate the prompt.

Retrieval is the same FTS5 index the search box uses. A campaign's notes are a
small corpus and ranked keyword matching is adequate context for it; embeddings
would add a store, a backfill and a re-embed-on-edit path for a retrieval
problem that is not yet hard.

The system prompt states that the notes are **data, not instructions** — they
are written by other people, and an entry recording that *"the merchant told us
to ignore our previous orders"* is a thing a character said.

### The stash is an inventory the party owns

`campaign_items` is `character_items`' shape with a `campaign_id`: real gear
catalog rows, freeform items allowed, tied to the journal entry that explains
the acquisition, and **soft-deleted** — *what did we used to have* is a question
a party asks and a `DELETE` cannot answer.

**Claiming an item onto a sheet is one batch.** The two halves are the same fact
stated twice: an item that left the stash without arriving on a sheet is
destroyed, and one that arrived without leaving has been duplicated. Neither is
visible in the result, which is what makes it worth a batch rather than two
awaits. Only the character's owner or the G.M. may claim for it — otherwise a
member could push party loot onto someone else's sheet, which is a table
argument the app should not be able to start.

Rejected: a stash with no transfers (two places to edit for one object, and they
drift within a session), and a free-form shared text block (no history when
someone deletes a line, which is exactly when history matters).

**Currency is a ledger, not a number.** The balance is `SUM(delta)`, so no
stored total can disagree with its own history. Entries are appended and never
updated; a mistake is corrected by an opposing entry that says so. A zero delta
is refused — an entry that changes nothing is either a mistake or a note, and
there is a notes feature for the second one. Currency names are lower-cased on
the way in, because `Credits` and `credits ` are the same pile of money and two
balances for one currency is the failure a ledger exists to prevent.

**Deleting a note is a hard delete**, unlike the stash's soft one. A note is
somebody's writing and *unsend* should mean it; keeping a tombstone of what a
player asked to remove is the opposite of what they asked for. The FTS index
follows via its trigger, and `campaign_items.journal_entry_id` is
`ON DELETE SET NULL`, so an item keeps its place and simply stops pointing at an
explanation that no longer exists.

---

## Who the campaign has met

The people a campaign meets lived in prose scattered across entries. Three
sessions later nobody could say who the merchant in Kingsdale was, whether he
was still alive, or what the party promised him.

A dossier is **campaign-scoped** and structured: name, aliases, faction,
disposition toward the party, status, a description, a portrait, and an
auto-maintained list of every entry that mentions them. Structured because the
fields are what make the roster filterable and what let the
[ask endpoint](#search-is-free-asking-costs-a-call) answer *"who is Kevik and
can we trust him?"* without re-reading prose.

Rejected: **global NPCs shared across campaigns** — right only if the campaigns
share a world, and it leaks what one table knows into another's dossier; and a
**single free-form prose block**, which is less to build and leaves nothing to
sort or filter by.

### Two ways in, and only one of them guesses

**`@Name` in a note is the primary path** — deterministic, free, instant, and
under the writer's control. It creates a dossier on first mention rather than
offering to: the writer already committed by typing the `@`, and a confirmation
step there means the note posts with a dangling reference while somebody
decides. A dossier made this way holds only a name, which is exactly what is
known about it.

What the pattern does and does not match is the whole contract:

| | |
|---|---|
| `@Kevik` | one person |
| `@Lord Coake` | one person — stopping at the space would link to a Lord nobody has met |
| `@Lord Coake And Then` | still `Lord Coake`; three words starts swallowing sentences |
| `@Kevik,` `@Kevik.` | the same person as `@Kevik` |
| `@Kevik` `@kevik` `@KEVIK` | one person, one dossier |
| `@guard` | nothing — a description is not a name |
| `email me @ the place` | nothing |

`UNIQUE (campaign_id, name COLLATE NOCASE)` is what makes that resolve to a
person rather than three near-identical rows nobody merges. Mentions are stored
as **plain `@Name` text in the body, not as ids**, so the note stays readable
text that survives a rename and reads correctly in a plain-text export;
resolution happens against the name index at write time.

**Editing a note reconciles its mentions.** A body edited to remove a name stops
listing that entry under that NPC — a mention list that only ever grows is one
that lies about the current text. Only the mentions a *person* typed are
reconciled; a link the sweep made is the model's reading of an entry that never
contained an `@`, and rewriting the body must not silently delete it.

**The sweep is the safety net, not the mechanism.** A button reads the entries
nobody has swept and proposes the named people nobody tagged. **A proposal is
not a dossier**: accepting one is a second, explicit click. Rejected: an
automatic scan on every save, which costs a model call per note and will
confidently turn *"the guard"* into a person until somebody stops it; and
mention-only, which captures nothing when the table forgets, which is every
table.

Four rules the sweep earns its keep by:

- **A dismissed name stays dismissed.** Without `npc_proposals_dismissed` the
  next sweep proposes *the guard* again, and the one after that, and the button
  becomes noise. Verified: a name dismissed once was not re-proposed even when a
  brand-new note named it again.
- **Entries are marked swept only after a successful response.** One marked by a
  call that never returned is one nobody will ever look at again.
- **Ids come back through a model and then a client**, so they are filtered
  against what was actually sent and re-checked against the campaign on accept.
  A mention pointing at another table's note would leak that note into a dossier.
- **A link the model made is marked `source: 'ai'`**, and the dossier says so.
  Same instinct as `override: true` on an out-of-category skill pick: a decision
  made by software should be visible as one.

### Portraits, and the site's first bucket

`wrangler.jsonc` binds R2 as **`MEDIA`**, named for the site rather than for the
app that needed it first — MediaVault stores cover art as text today and
filament-forge already reads file bytes, so the second and third users exist.

Rejected: **base64 data URIs in D1** (rows cap near 1MB, the database is shared
with every other app on the site, and "thumbnails only" is a rule nobody
remembers in six months); and **external URLs** (nothing behind the Access wall,
and the image breaks when the host does).

**Nothing is ever served from a public bucket URL.** The whole site sits behind
Access and an unauthenticated image endpoint would be the one hole in it, so
every read goes through a Function that checks membership first — a campaign's
portraits are as private as its notes.

Four things that are not obvious:

- **The type is an allowlist**, because it decides what is stored *and* what the
  GET hands a browser later. Anything not on the list is something the response
  would be serving without knowing what it is.
- **The row is written before the old object is deleted.** The other order can
  leave a dossier pointing at an object that no longer exists; this one can at
  worst orphan an object nobody points at, which costs storage rather than a
  broken portrait.
- **The key carries a uuid**, so every upload is a new key and the response can
  be cached hard — `private, max-age=31536000, immutable`. Private because this
  is behind Access and must not sit in a shared cache.
- **But the URL is stable**, so an immutable cache would show the first portrait
  forever. The page busts it with the **object key**. `updated_at` was the
  obvious choice and is wrong twice: it contains a space, which does not belong
  in a URL unencoded, and it changes when somebody edits the faction field —
  re-fetching an image that did not change.

---

## Play mode

The sheet through an **action-first lens**, shaped for a phone or tablet at
the table: `sheet.html?play=1`, toggled by the header button. Same page, same
data, same endpoints, and **one render** — the sheet draws the play controls
and the roll buttons every time, `togglePlay()` flips `body.play-mode`, and
CSS reveals them. That is the whole design, and it is two decisions rather
than one. A separate play *page* would duplicate the sheet's
load/compose/derive/permissions plumbing for a different layout. A separate
render *path* — which this was, `renderPlay()` being the function it used to
call — duplicates that plumbing inside one file, where the drift is silent
instead of obvious: the two paths drew the same pools and disagreed, once.
The class flip also means switching modes no longer rebuilds every input, so
it can no longer eat a half-typed note. `test/checks/rendered-ui.mjs` pins all
of it — no `renderPlay()`, no branch on the mode in `render()`, and no
`render()` inside `togglePlay()`.

What it offers (phase 1 of four):

- **Pool cards** with big current/max numbers and quick +/− at a selectable
  amount, plus a **Damage** button applying the book's flow: M.D.C. beings
  take it on M.D.C., everyone else runs S.D.C. down first with the remainder
  reaching H.P. Nothing clamps — negative H.P. is a real state (coma), and a
  G.M. may allow over-maximum. Armour is still not in the cascade, because
  which armour absorbed a hit is a table decision — and since UI-AUDIT F40 the
  table makes it on a **Hit to** picker beside Damage: the body, each armour
  piece, each vessel location. Armour stops at 0 and *offers* what it could not
  absorb to the body (**Apply N to body** on the roll bar) rather than applying
  it; a vessel location goes below zero, as its own route has always allowed.
  Both go through the events route, so both undo and queue.
- **Every derived number is a tappable roll.** Skills roll d100 against the
  percentage; saves and combat bonuses roll d20 + bonus, against a target
  where one is derived (the psionic save) and bonus-only where the book
  leaves the target to the G.M. Rolls are **advisory** — the app shows the
  die, the table decides what it means — and play mode enforces no rule the
  sheet lens leaves to a human.
- **A bare percentile**, on its own row in the control strip. A G.M. asks for
  one by name several times a session — "give me a percentile" — and every
  other d100 here is attached to a skill's own percentage, so the roll asked
  for most often was the one roll the app had no button for. No bonus and no
  target: the roll bar prints the number alone and the session log records it
  without a verdict, because there was nothing to pass or fail against. Its
  row is separate from the amount strip because that strip is gated on write
  access and is arithmetic against this character's pools; a roll is neither.
- **Powers** keep their ⚡ spend buttons; in play mode the deduction updates
  in place rather than refetching the sheet.
- **Weapon cards** (phase 2): an equipped catalog weapon becomes an attack
  card — strike roll, damage roll off the **leading dice** of the gear row's
  damage string (the full string is displayed; "1D6 (small), 2D6 (large)" rolls
  the 1D6 and the table adjudicates the rest), and an ammo counter when the
  payload states a capacity. Ammo lives in the inventory row's **notes** as
  `ammo 7/10` — visible on the sheet lens, editable by hand, no schema
  change. Unequipped weapons are listed with a **Draw** button that equips one
  without leaving play mode (UI-AUDIT F45). The dice evaluator reaches this
  classic-script page the same way
  language-skills does: `js/dice.js` installs a `globalThis.diceRoll` mirror
  via a module tag.
- The last result sits in a **fixed thumb-zone bar**; every roll is kept as a
  structured object in `C.rollLog` (capped at 50) — the shape phase 3's
  `play_events` row was then built to take. The bar opens the last ten
  (UI-AUDIT F44).

Writes are **optimistic**: the DOM moves first and rolls back with an alert if
the server refuses. Phase 3 moved play mode's writes off the sheet's PATCH and
onto the events endpoint below, and the optimism did not change. Read-only
visitors can still roll — their rolls stay local and write nothing.

**The event log (phase 3).** Every state-changing play action goes through
`characters/[id]/events`, which applies the change and records it in one
batch; rolls persist as pure records (read-only visitors' rolls stay local).
Events are **commentary, not a ledger** — the character row stays the source
of truth, and nothing replays events to derive state, because replaying is
how a log inherits every consistency bug forever. What the log buys:

- **↶ Undo** reverses the latest not-undone event that carries changes —
  "take back the last thing", deliberately never a history editor, because
  undoing an older event under newer ones is ambiguous arithmetic. The
  undone row stays, marked, as part of what happened.
- **✎ End session** summarises events since the last recap marker — damage
  taken, powers by name, shots, rolls with pass/fail counts — and posts it
  to the journal as a plain-text entry a human can edit, then drops the
  next marker.
- A **who-did-what trail** (`actor_email`) for the sheet a G.M. and a
  player share mid-session.

**The melee counter and rest (phase 4).** The round/attack counter reads the
derived attacks-per-melee and is deliberately client-only ephemera — a round
in progress is not character data. **Rest** applies rate × hours per pool as
one undoable event, clamped at each pool's max. The rates are **the
table's own**, typed in and remembered per character on the device: the
books' recovery pages are not yet in the rules audit, and this app does not
ship an uncited number for a table to silently trust. When those pages are
audited, cited defaults belong in `js/rules.js`.

### A change that could not be sent waits in a queue

The table's wi-fi drops mid-fight and the +/− buttons keep working. What
happens next is `js/play-queue.js`, and the name matters: **this is a queue,
not offline support.** It survives a network drop and a reload while the tab
is open. Nothing here serves the page, so closing the tab with no connection
means the sheet will not load at all next time — that needs a service worker,
which on a site that deploys on every merge brings a cache-invalidation
problem of its own and is deliberately out of scope.

**Every play write that changes state queues now.** They arrived one at a time,
each after noticing that a dropped connection quietly ate it, and the list is
worth reading as a table rather than a sentence because the interesting column
is what happens when the send *fails*:

| the write | on a refusal | on a drop |
|---|---|---|
| pool +/− | reverts | **queues** |
| **Damage** | reverts | **queues** — one entry, both pools |
| **a hit on armour or a vessel location** | reverts | **queues** — replayed unguarded, like ammo (UI-AUDIT F40) |
| **rest** | reverts | **queues** — every pool it recovered, in one entry |
| **a power spend** | reverts | **queues** |
| **ammo** | reverts | **queues** as an item change carrying no pools |
| a roll | — | stands on screen, and **says** it was not logged |

Two of those rows are less obvious than they look. **A power spend had to
become optimistic first:** it used to await the write before deducting, which
made it the one play action a drop swallowed in silence — the spell was cast,
the table moved on, and the sheet still showed the P.P.E. unspent. You cannot
queue a change you never applied locally.

**And ammo replays UNGUARDED.** The guard is per pool: the endpoint compares
each numeric `from` and refuses if it moved. `character_items.notes` has no
such check — online either, today — so a replayed ammo write overwrites
whatever the notes say when it lands. Queueing does not introduce that; it
stretches the window from milliseconds to however long the wi-fi is out. The
alternative was losing the shots a player fired offline, which is worse and far
likelier than somebody hand-editing that row's notes mid-fight. Guarding a text
field would also need a conflict UI that two numeric halves cannot express.

**A roll is deliberately not queued.** It carries no state change, the die was
already seen at the table, and queueing every tap of an offline fight would
fill the queue with commentary. What it does instead is stop failing silently —
see below.

**One press is one entry is one event.** A Damage that spills out of S.D.C.
into H.P. moves two pools, so an entry carries a **field map** rather than one
value. Split into two entries it would put two rows in the log, let undo take
back half a hit, and make the session recap count one blow as two. An entry
queued before that map existed still replays as the single-pool change it was:
IndexedDB outlives a deploy, so the flush has to read both shapes rather than
dropping the older one.

**A refusal and a silence are different things**, and the whole design hangs
off telling them apart:

| the error | what it means | what happens |
|---|---|---|
| `err.status` is set | the server answered and said no | rolls back and alerts, exactly as before there was a queue |
| `err.status` is `undefined` | the request never arrived | the change **stands on screen** and joins the queue |

A browser that refuses IndexedDB — a private window, site data blocked —
falls back to rolling back. `playQueue.available()` answers false, and the
caller behaves as it did before the queue existed rather than erroring.

**IndexedDB rather than `localStorage`**, for two reasons that are both about
this app specifically: it is asynchronous, so a long fight's worth of queued
entries cannot jank the thumb-sized buttons that write them; and
`localStorage` is a per-origin string budget shared with every other app in
this workshop, which is the wrong place for a store whose length is decided by
how long the wi-fi is out. The object store is keyed by an `autoIncrement`
`seq`, which is where the queue's order comes from.

**Order is the contract.** Two adjustments to one pool only compose if they
are replayed in the sequence they were made, so `flushQueue()` is a serial
loop and never a `Promise.all`. It runs on the `online` event, and again from
`load()` — a tab reopened after a drop has a queue and no `online` event
coming.

**Guarded replay, per field.** A change queued during a spell offline may be
replaying onto a pool somebody else has moved, and applying its `to` blindly
would silently discard their change — which is the failure the queue exists
not to make worse. So the replay sets `guard: true` on the events POST, and
the endpoint puts `field IS ?` for each pool's `from` into the `UPDATE`'s
`WHERE`. `from` had always been sent, validated and never used; `guard` is
what finally reads it, opt-in so every existing caller keeps the behaviour it
has.

Guarded **per field rather than per row**: two people touching different pools
are not in conflict, and a row-level check would call that a clash. The check
also runs *before* the batch, because a batch that applies nothing still
inserts the event and would leave a log entry for a change that never
happened.

**A conflict is a choice, not a merge.** The 409 carries both sides — `mine`,
`theirs` and the `base` they diverged from — and the flush **stops there**:
the entries behind it are built on a value that is no longer true, and
replaying them would compound the divergence rather than resolve it. The pool
card splits into two finger-sized halves, yours and theirs, the player picks,
and the flush resumes.

**One press can clash on two pools** — a Damage that reached H.P. while
somebody else was healing — so each pool gets its own choice, and the press is
not sent until the last of them is answered. An answered card stops offering
the choice immediately, and its answer waits with the others; sending half an
answered Damage would be the very split the entry shape exists to prevent.
When the last answer lands the whole press goes as **one** event, rebased on
what the server holds now: a pool the player answered is based on `theirs`, a
pool nobody moved keeps the `from` it was queued with, because its guard
matched and that *is* what the server holds. A field that ends where it
already sits is dropped, which is what makes "theirs" free — choosing it
writes nothing.

**The trap this repo keeps rediscovering: Access answers with HTML.** A replay
that lands on the login page comes back as a page, `api()` answers `{}` for a
body it cannot parse, and the replay looks exactly like success — which would
eat the queue silently. The response's `event_id` is the proof that our API
answered and not the wall; without one, the flush stops and says to sign in
again.

**A roll that could not be logged says so.** This was a bare `console.warn`,
which is not a place a player looks — so a whole fight's rolls could be missing
from the end-of-session recap with nothing on screen having said anything. The
count now sits beside the waiting changes: *"3 rolls not logged"*. It only ever
grows within a session, deliberately, because a roll that did not log is
**gone** rather than pending, and clearing the notice when the network came
back would hide exactly the loss it exists to report.

A counter near the pools says how many are waiting, and says something
different when a conflict is holding the line. `test/checks/rendered-ui.mjs` →
*Changes that could not be sent* pins the decisions above — including the
honest-word one: the module has to keep saying what it does **not** promise,
or the check fails.

**Those are text checks, and `test/play-flow.mjs` is the one that runs the
thing.** It loads the real `sheet.js` — and the seven scripts the page loads
before it — into a `node:vm` context, points its `fetch` at a real
`wrangler pages dev` over a database built from nothing, and drives
`quickDamage()`, `flushQueue()` and `resolveConflict()` for real, asserting
against the rows that come back. It is what proves the half-answered press
sends nothing and the resolved write is rebased, neither of which a regex can
see. A separate command like `regression.mjs`, because it boots wrangler, and
reporting-only in CI. Its own header carries the three things it does **not**
prove: the DOM is a stub, the queue store is a fake, and it is not a merge
gate.

The dashboard's altitude did gain the G.M.'s own controls (UI-AUDIT F46): each
roster row carries its pools with − and +, a Damage running the same
`derive.damageCascade` the sheet does, and ↶ for that character's last change,
all through that character's events route; a toolbar awards XP to the whole
party through each character's XP route, reporting any level-up it proposes.

Deliberately out of scope at any phase: party-wide initiative (the
dashboard's altitude) and automated combat resolution (the hand-to-hand
tables are not modelled, and the README already says so).

---
