# Plan 20 — Reading what a power does

Written 2026-09-05, before any of it was built. A decision document in the shape
of plans 13–16 and 19, not a record of something that shipped.

Part of the [character creator](../../README.md) documentation.

---

## The recommendation

**Descriptions for the powers a character actually holds ride with the
character, and render inline in the Powers tab. The full catalogs stay out of
the boot payload, and browsing what you do not have is a separate read-only
codex page.** The dividing line is not a taste in interfaces, it is who pays the
bytes: every description a character holds costs **4.4 KB gzipped in the worst
case on production today**, against **72.4 KB** for shipping all of them to
everyone on every load. Inline expansion at the table is therefore nearly free
and needs no round trip on a bad connection; the codex is where the other 691
rows live, fetched only by someone who went looking. The two are not a
compromise between the options — they are the same feature split at the point
where the cost changes by a factor of sixteen.

## What was measured

Production D1 (`nates-workshop-media`), 2026-09-05, dumped with
`wrangler d1 execute --remote --json` and sized by serialising the exact shape
`functions/api/character-creator/catalogs.js` returns. Gzip is level 6; Brotli is
listed because Cloudflare negotiates it and it is what most of these responses
will actually travel as.

### The boot payload, `/api/character-creator/catalogs`

| | raw | gzip | brotli |
|---|---|---|---|
| today, no descriptions | 208.3 KB | **25.1 KB** | 20.4 KB |
| + spell & psionic descriptions | 422.6 KB | **97.5 KB** | 78.8 KB |
| + first-sentence teasers only | 253.9 KB | **38.2 KB** | 31.1 KB |

**The headline number in the brief was raw bytes and it overstates the cost by
about three times.** The real question is +72.4 KB gzipped — but that is a
**288% increase**, so the payload almost quadruples. Both halves of that
sentence matter: the absolute number is smaller than feared and the multiple is
worse than it sounds.

What the current 25.1 KB is made of:

| catalog | raw | gzip |
|---|---|---|
| skills | 91.5 KB | 10.3 KB |
| spells | 77.5 KB | 9.5 KB |
| psionics | 17.2 KB | 2.0 KB |
| enchantments | 22.0 KB | 3.7 KB |

**Nothing caches this endpoint.** `catalogs.js:45` calls `json()` with no headers
of its own, so the response carries `Content-Type` and nothing else — no
`Cache-Control`, no `ETag`, no `Last-Modified`. There is no `_headers` file in
the repo, `functions/api/_middleware.js` does not touch response headers, and
`js/api.js` adds no client-side cache. `sheet.js:112` requests it on every sheet
load and `app.js:3536` on every wizard boot, so whatever this payload weighs, it
weighs that much every single time.

**That is a fact about this endpoint, not about the app, and the difference
matters to the options below.** `json()` takes a third `headers` argument
(`auth.js:22`), and `classes.js:46-48` already uses it to send a weak `ETag` with
`Cache-Control: private, no-cache` and answer `If-None-Match` with a `304` — a
pattern pinned by `regression.mjs:174-177` and documented in the README. A
validator on `/catalogs` is therefore a scoped change with a working template
forty lines away, and it would turn most of these loads into `304`s. Every
figure below is the cost **as the endpoint behaves today**; see the rejected
options, where this is the one thing that could reopen them.

### One description, fetched on demand

545 rows carry description text. Serialised as `{name, description}`:

- median **228 B**, p90 **1,036 B**, max **3,226 B**
- a single-row response gzips to roughly 424 B — at this size compression has no
  dictionary to work with, so assume the raw number

### Descriptions for the powers one character holds

This is the measurement the recommendation turns on. Every character on
production, with the description text for its own powers packed as
`{name, description}`:

| character | powers | with text | raw | gzip |
|---|---|---|---|---|
| 1212 | 21 | 21 | 10,699 B | **4,437 B** |
| Donald | 13 | 13 | 8,753 B | **3,619 B** |
| 123456 | 6 | 6 | 982 B | 482 B |
| 1111 | 0 | 0 | — | — |

Mean 10 powers per character. **The worst case on production is 4.4 KB
gzipped** — an 18% increase on a sheet load that already carries 25.1 KB of
catalogs, against 288% for the whole corpus.

### The enchantments precedent, which does not carry the weight put on it

`catalogs.js` ships enchantment descriptions and justified it by the catalog
being small; migration 036 doubled the row count and nobody noticed. That has
been read as evidence the boot budget has room. Measured, the growth from 32
rows to 62 was **+1,673 bytes gzipped**. It is not evidence about +72.4 KB —
the thing nobody noticed was **43 times smaller** than the thing being argued
for. The precedent supports shipping a few kilobytes of description text
without ceremony, which is exactly what the recommendation does, and it says
nothing about shipping seventy.

## The options

| # | Option | Cost | Verdict |
|---|---|---|---|
| 1 | Full descriptions in the boot payload | +72.4 KB gzip, every load, uncached today | **No.** Quadruples a payload nothing caches, to deliver 691 rows a player will never open. **Conditional:** an `ETag` would turn most loads into `304`s and make this arguable — but the first load on each device still pays it |
| 2 | First-sentence teasers at boot | +13.1 KB gzip (+52%) | **No**, but the closest rival. Pays on every load for a summary that is wrong for the powers whose text is a table of ranges |
| 3 | Lazy per-row fetch on expand | ~228 B median per lookup | **No** as the primary path. Cheap, but it is a network round trip at the moment of use, at a table, on someone's house wifi |
| 4 | **Descriptions for held powers, with the character** | **+4.4 KB gzip worst case** | **Yes.** Recommended |
| 5 | A read-only codex page | one 74.5 KB gzip fetch, cacheable, only when opened | **Yes, as the second half.** For browsing what you do not have |
| 6 | Modal or bottom sheet over the sheet | same bytes as 4 | **No.** Covers the numbers being read off; see below |

**Why 4 rather than 3.** They cost nearly the same bytes; they differ in *when*.
Option 3 spends its round trip at the instant of use, which is the one moment the
connection may not be there. Option 4 spends it on a load that already happened.

**Why 4 rather than 6.** The sheet is tabbed now (`TAB_IDS` at `sheet.js:1061`,
panel at `sheet.js:1583`), and the Powers tab is already a single-purpose screen.
An overlay covering a screen that holds nothing but powers buys nothing and costs
the P.P.E. strip, which is sticky and is what a player checks while deciding
whether to cast. Expansion in place is the smaller change and the better one.
`.skill-note` (`sheet.js:1165`) is the existing precedent for a second row
carrying prose under a first, and `styles.css:1418-1420` already forces those
notes visible on paper with `break-after: avoid` on the row above them — so the
print question below has a worked answer in the same stylesheet.

**Why the codex is not `catalog.html` unlocked.** `catalogs/rows.js` is
`requireAdmin` at the route, and its own header explains it is admin-gated
because it writes. Making the *page* read-only leaves an editor's shape — tabs
per catalog, duplicate review, redirect lists, an audit panel — in front of a
player who wanted to look up Fire Bolt. A codex is a different page against a new
read-only route, and the shared thing is `js/catalog-fields.js`, which already
drives the editor, the write endpoints and the importers from one config.

## Name resolution: the audit the brief asked for

Stored powers are name-keyed snapshots with no catalog id, so every option here
joins on name. Measured across all four characters on production:

- **40 stored power rows. 40 resolve directly against the catalog. Zero needed
  `catalog_redirects`, and zero failed.**
- The same pass over stored skills: 120 rows, **5 that a naive name lookup
  misses, across 4 distinct names** — `Language: Elven` (×2), `Language:
  Northern`, `Language: Southern`, `Language: Wolfen`.

**The power result is clean and the sample is too small to be reassurance.** Four
characters, 40 rows, one campaign. It says the mechanism works today; it does not
say it survives a rename, and `catalog_redirects` exists because renames happen.
Whatever ships should resolve through redirects from the first commit rather than
adding them after the first miss.

**The query this needs already exists.** `loadPowerCatalog(env, names, system)`
in `functions/api/character-creator/_lib/power-picks.js:194` loads held power
names against `spells` and `psionic_powers` with `name COLLATE NOCASE IN (…)`,
chunked around D1's 100-parameter limit — which is the case a caster holding a
hundred spells would otherwise walk straight into. The recommended option is
mostly a projection change plus a call to that.

**The skill result is smaller than it first looked, and it is a lesson about the
audit rather than about the catalog.** The `skills` catalog *does* hold language
rows — 18 of them, `Language: Dragonese` through `Language: Trade Six`. The four
names above are instances of the `Language: Other` escape hatch, where a player
types a language the books do not enumerate, and **the repo already ships the
resolver**: `otherRowFor()` in `js/language-skills.js` maps `Language: Elven` to
the real `Language: Other` row, and nine call sites across `app.js`, `sheet.js`
and three `_lib` modules already use it. My audit pass did not, which is why it
reported five misses.

So the true statement is narrow: **a lookup that joins on the stored name alone
misses escape-hatch members, and the fix is to call the function the rest of the
app already calls.** What survives for a skills description feature is milder
and worth writing down anyway — `Language: Other` is one row, so every language
a player invents would show the same generic text.

## Coverage: where the 29% gap is actually felt

430 of 607 spells carry description text — but of the **40 powers characters
actually hold, 40 have text. Every one.** The gap is entirely in spells nobody
has taken.

That reverses the ordering question in the brief. Inline descriptions for held
powers can ship **now**, complete, with no empty panels. It is the **codex** that
would show 177 blanks, because browsing is the only place the missing rows are
reachable. So the backfill gates option 5 and does not gate option 4.

## What each option does on paper

The print block dissolves the tabs rather than revealing them
(`.tabpanel { display: contents }`, `docs/wizard-and-sheet.md`), so an inline
description added to the Powers panel **prints by default** unless something
stops it. Donald's 13 powers carry 8,753 characters of prose — roughly 1,400
words, about three extra pages on a sheet that currently fits on a few.

**Recommendation: descriptions are hidden in print by default**, with the option
of a deliberate "print with descriptions" pass for a player who wants a paper
reference. A character sheet is a control panel on paper and a spell reference is
a different document.

**This is the one part of the plan that must not be implemented from this
paragraph.** Per `verify-ui` §4, print behaviour here is rendered through
headless Chrome and looked at, never read off the stylesheet — a previous finding
predicted a table would split without its header and the render showed the
browser default already handled it. The rule above is a design intent; the page
count is arithmetic from character counts, not a measured render.

## Skills and enchantments

**Skills: defer, and do not add a `description` column yet.** The column is not
free — `schema-change` puts it in five places — and the argument for deferring is
*not* that there is nothing to show. `skills.note` holds 17,442 characters across
the 132 rows that have one, **averaging 132 characters each**: short, but real
prose rather than the fragment the boot projection implies, and already shipped
to the client today. The reason to wait is that nobody has decided what a skill
description *is* — the book's paragraph, or the conditions attached to the
percentile — and a column cut before that question is answered will be filled
with whichever the first importer happened to grab.

An earlier draft of this plan put that average at 47 characters. That was the
same 17,442 divided by all 345 skills rather than by the 132 with a note, and it
made the corpus look 2.8× thinner than it is. The defer still stands; the
argument that it rested on does not.

**Enchantments: nothing to do.** They already ship `description` to the client and
the sheet already needs it to render an enchanted item. They are listed here so
the answer is on the record.

## The 177 spells with no description

All 177 are `Rifts Book of Magic`, printed pages 93–159, each row already
carrying its page citation. The backfill is cheaper than it looks and the reason
is in `scripts/books.json`: `bom` was **re-cached 2026-08-28 from the PDF's text
layer, all 360 pages**, median 5,411 characters per page, `page_offset` 1. There
is no OCR pass to run and no page-hunting — printed 93–159 is file pages 94–160,
and the book's own *Index of Rifts Magic* (printed 348–352) is the authority
table giving every spell a name, cost and page to reconcile against.

The plan:

1. Slice the cached text for printed 93–159 and extract `{name, description}`
   pairs against the existing rows, matched by name and page. `book-extract-worker`
   is the right shape for the extraction; the range is one contiguous run rather
   than a whole-book survey, so it does not need `book-survey` again.
2. **Reconcile before writing**, with `book-reconcile`. This is prose, not
   figures, and `docs/known-limitations.md` states the failure mode exactly: a
   spliced column *"produces a description that reads fluently and is wrong"*.
   A two-column page whose halves interleave produces exactly that, and nothing
   downstream will ever flag it.
3. Two or three data scripts split by page range, each recording itself in
   `data_script_runs`. They are `UPDATE`s to disjoint rows so order among them
   does not matter — but **filename order is execution order**, so name them to
   sort after any existing `fix-` that touches spells.
4. `UPDATE`s add no rows, so **no test-pinned README count should move**. Confirm
   that with the flagless smoke run rather than assuming it.

**Sequence: after option 4 ships, before option 5.** Option 4 is complete today;
the codex is what exposes the gap.

## What I deliberately did not propose

- **A `spell_descriptions` table.** The text belongs on the row it describes;
  a second table buys a narrower boot projection that a projection already buys.
- **Client-side caching of the full corpus in `localStorage`.** It would work,
  and it moves a 74.5 KB decision into a place with no eviction policy and no
  version. If the corpus is worth caching, it is worth an `ETag` on the endpoint.
- **An `ETag` on `/catalogs`.** It is the highest-value change this measurement
  turned up, it is cheap, and it is deliberately not bundled here: it is a
  behaviour change to a shared endpoint, and a documentation PR is the wrong
  place to hide one. `classes.js:46-48` is the template. **Take it first if any
  of this is going to be built** — it does not alter the recommendation, whose
  4.4 KB is paid on a request that has to happen anyway, but it is the one thing
  that would make options 1 and 2 arguable again, and it should be measured
  rather than assumed to.
- **Descriptions in the wizard's pickers.** The wizard is where a player chooses
  a spell, so it is the obvious next surface. It is also the one place the full
  corpus genuinely is needed, and it reopens the boot-payload question this plan
  closes. Deliberately out of scope; see option 5, which is where a chooser
  should link.
- **Gear and weapons**, which the brief excluded.

## What is NOT verified

Stated plainly, because a DOM-based assessment reported as confirmation is how
the tab bar shipped below the fold:

- **Nothing was rendered.** No browser, no screenshots at 768px or desktop, no
  print render. This plan contains no visual verification of any kind.
- **The per-option layout claims are design intent**, not measurements — in
  particular that an expanded description reads well in the Powers tab on a
  tablet, and the three-page print estimate.
- **The name-resolution audit is complete but tiny** — four characters.
- The byte measurements are of serialised payloads, not of responses observed
  over the wire; they do not include HTTP framing, and the endpoint was not
  fetched (it sits behind Access).
