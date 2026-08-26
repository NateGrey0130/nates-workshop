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
data, same endpoints — `render()` branches to `renderPlay()` and nothing else
changes, which is the whole design: a separate play page would duplicate the
sheet's load/compose/derive/permissions plumbing for a different layout.

What it offers (phase 1 of four):

- **Pool cards** with big current/max numbers and quick +/− at a selectable
  amount, plus a **Damage** button applying the book's flow: M.D.C. beings
  take it on M.D.C., everyone else runs S.D.C. down first with the remainder
  reaching H.P. Nothing clamps — negative H.P. is a real state (coma), and a
  G.M. may allow over-maximum. Armour is deliberately not in the cascade:
  which armour absorbed a hit is a table decision.
- **Every derived number is a tappable roll.** Skills roll d100 against the
  percentage; saves and combat bonuses roll d20 + bonus, against a target
  where one is derived (the psionic save) and bonus-only where the book
  leaves the target to the G.M. Rolls are **advisory** — the app shows the
  die, the table decides what it means — and play mode enforces no rule the
  sheet lens leaves to a human.
- **Powers** keep their ⚡ spend buttons; in play mode the deduction updates
  in place rather than refetching the sheet.
- **Weapon cards** (phase 2): an equipped catalog weapon becomes an attack
  card — strike roll, damage roll off the **leading dice** of the gear row's
  damage string (the full string is displayed; "1D6 (small), 2D6 (large)" rolls
  the 1D6 and the table adjudicates the rest), and an ammo counter when the
  payload states a capacity. Ammo lives in the inventory row's **notes** as
  `ammo 7/10` — visible on the sheet lens, editable by hand, no schema
  change. Unequipped weapons are listed, not carded; equipping is the sheet
  lens's job. The dice evaluator reaches this classic-script page the same way
  language-skills does: `js/dice.js` installs a `globalThis.diceRoll` mirror
  via a module tag.
- The last result sits in a **fixed thumb-zone bar**; every roll is kept as a
  structured object in `C.rollLog` (capped at 50), the exact shape a future
  `play_events` row will take.

Writes ride the existing PATCH optimistically, with revert-and-alert on
failure. Read-only visitors can still roll — rolls write nothing.

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

Deliberately out of scope at any phase: party-wide initiative (the
dashboard's altitude) and automated combat resolution (the hand-to-hand
tables are not modelled, and the README already says so).

---
