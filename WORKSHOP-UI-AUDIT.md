# WORKSHOP-UI-AUDIT.md — the interface, across apps

> **Nothing is open on this menu, as of 2026-09-10.** Read each finding's own
> heading for its state; this line does not name them and does not count them.
>
> **This menu's prefix is `W`, and nothing else in the tree uses it.** Ten letters
> were already taken as `##`/`###` finding prefixes when this file was written —
> `A`, `B`, `C`, `D`, `F`, `G`, `M`, `N`, `R`, `V` — plus `S` and `T`, which are
> **not headings at all**: `CLASS-AUDIT`'s `S` items are bullets and
> `pick3cut5/AUDIT`'s `T` items are bold paragraph leads, so a `###` scan does not
> see either family. `W` was chosen so a bare `W1` names this file and only this
> file. Re-walk that census with the command in the `audit-menu` skill rather than
> trusting this sentence.
>
> **Findings are `### W1 — high — …`** — severity word in the heading, `###` level,
> numbered most severe first. Numbering and severity happen to agree here; when a
> later finding outranks an earlier one, severity wins the order and the number
> stays where it was issued.

Written 2026-09-10 against `origin/main` at `004e5c1`, served from
`wrangler pages dev --port 8795` — **not** 8788, which belongs to another worktree.
Both findings were measured on a rendered page at that commit, after PR #891
(Bench), #911 (`UI-AUDIT` F36) and #913 (`UI-AUDIT` F37), all three of which moved
`shared/styles.css` on the same day. Take findings one at a time.

---

## Scope, and why this file is at the repo root

**Interface work that spans more than one app, or that belongs to an app with no UI
menu of its own.** `audit-menu` → *Where a new menu goes* puts anything crossing
app boundaries at the root and anything scoped to exactly one app in that app's
directory.

`apps/character-creator/UI-AUDIT.md` covers the character creator and stays the
place for it — `W`-numbered findings are not a second home for that app's
interface. What has had no home until now is the other three apps and the landing
page.

**`W1` was handed here explicitly, and that is the reason this file exists at all.**
`apps/media-vault/SHARE-AUDIT.md:446-453` records the bulk-bar defect, states that
it is *"named rather than filed"*, and says it
<!-- claim-ok: quoting SHARE-AUDIT's own deferral, cited by line above -->
*"belongs to whoever next opens a UI menu for this app"*. This is that file.
`audit-menu` → *A deferral is work* is the rule that sentence was written against.

**MediaVault already has three menus and none of them fits.**
`apps/media-vault/BULK-AUDIT.md` (`B1`–`B9`) is about what bulk edit *does* —
what it selects, what it may set, what it deletes. `ISBN-AUDIT.md` is lookup.
`SHARE-AUDIT.md` is sharing, and it is the one that declined `W1` on scope
grounds. None of the three is about how a control lays out on a phone.

---

## Method

Both findings were rendered, not reasoned. `W1` was measured in a real viewport at
390×844 with `getBoundingClientRect`; `W2` was counted from the shipped tree with
an explicit definition of what counts, stated in the finding because the obvious
looser definition inflates it by roughly double.

**What this menu has NOT looked at**, so its silence is not read as coverage: the
character creator (it has its own menu), any surface reached only by clicking
through a flow, print media, and every state other than first render — no modal,
no error state, no populated-at-scale view. Two findings is what one pass over the
landing screens produced, not a survey.

---

## Findings

### W1 — high — MediaVault's bulk bar is 68px wider than a phone, clips its own Apply button, and covers 177px of the library before anyone has selected anything

**Measured 2026-09-10 at 390×844, select mode OFF** — that is, in the state a
visitor gets by opening the app and doing nothing:

| | |
|---|---|
| `position` | `fixed`, `bottom: -80px` |
| box | `left: 16`, `right: **458**`, width **442px** in a **390px** viewport |
| overflow past the right edge | **68px** |
| height | **257px** |
| top edge | **667** in an 844px viewport — **177px of the library permanently covered** |
| `max-width` | `none` |
| `white-space` | `nowrap` |
| buttons clipped | **3 of 10** — `📺 Series` at right 437, `📀 Physical` at 393, and **`Apply` at 435** |
| `document.scrollWidth` | **390** — equal to `clientWidth` |

Two separate defects share one rule at `apps/media-vault/styles.css:844-878`.

**The parked position is a magic number that stopped being true.** `bottom: -80px`
hides a bar 80px tall. At 390px this bar wraps to five rows and is **257px** tall,
so 177px of it never leaves the screen. The comment at `:847-850` records the last
time this rule was calibrated — against a *width* problem, at desktop — and the
height was not revisited.

**The overflow is a missing `max-width`, and the rule twenty lines above has one.**
`.undo-toast` at `:819-841` is the same shape of floating element and carries
`max-width: calc(100vw - 32px)`, which computes to **358px** at this width.
`.bulk-bar` carries `max-width: none`. With `width: fit-content` and
`white-space: nowrap` it sizes to its content and runs off the edge, and
`body { overflow-x: hidden }` in `shared/styles.css` suppresses the scrollbar that
would otherwise reveal it — which is why `document.scrollWidth` still reads 390 and
nothing looks wrong to a check that only asks whether the page scrolls sideways.

**Why the clipped `Apply` is the sharp end.** The three type buttons are a choice a
user could make differently. `Apply` is the button that commits the edit, and at
390px it sits 45px past the right edge with no way to reach it — no scroll, no
wrap, no overflow affordance. A phone user can select rows, choose a field, type a
value, and then not be able to save it.

**Proposal:** two declarations, both in `apps/media-vault/styles.css`.

1. Replace the magic parked offset with a transform: `transform: translateY(calc(100% + 28px))`
   at rest and `translateY(0)` on `.visible`, so the bar hides at whatever height it
   wraps to and the number stops needing maintenance.
2. Give it the same clamp its sibling already has — `max-width: calc(100vw - 32px)` —
   and drop `white-space: nowrap` below 640px so the groups wrap instead of
   overflowing.

**Posture: one app stylesheet, no markup change, no JS, no new token.** This is a
layout fix, not a redesign of bulk edit: what the bar *does* belongs to
`apps/media-vault/BULK-AUDIT.md` `B1`–`B9`, read 2026-09-10, and stays there.

**Verification for whoever takes it:** at 390×844 with select mode off,
`bulkBar.getBoundingClientRect().top` must be `>= innerHeight`. With select mode
on, every button's `right` must be `<= innerWidth`. Both are one line in the
console and neither is visible to the smoke suite.

**Evidence:** `getBoundingClientRect` on the live element at 390×844,
2026-09-10, `wrangler pages dev --port 8795` at `004e5c1`; rule line numbers read
the same day from a 1300-line `apps/media-vault/styles.css`.

**Confidence:** high on every number above — all were read off a rendered page,
twice, and the two figures `SHARE-AUDIT` recorded independently on 2026-09-05
(the bar peeking above the bottom edge, worse at mobile) point the same way.
**Medium on the fix.** The `translateY` half is standard and low-risk; the
`white-space` half is a guess at where the groups should wrap, and nobody has
looked at what five wrapped rows do to the *desktop* layout. Rendering the
proposed rule at 390, 768 and 1440 before merging is what would raise it.

**Ongoing cost:** none. It removes a hand-calibrated constant rather than adding
one, which is the half of this that stops recurring.

---

**Taken, 2026-09-10 (PR #915). Posture held: one app stylesheet, no markup change,
no JS, no new token.** Four declarations in `apps/media-vault/styles.css`.

**The Proposal as written did not work, and `audit-premise-auditor` measured that
before anything was edited.** Both halves applied together still left `Apply` — the
button this finding was written about — off-screen at 390. Corrections, in the order
they matter:

**1. The two proposed declarations do not reach the blocker.** Measured at 390×844,
each half applied separately through the CSSOM:

| variant | box width | buttons past 390 |
|---|---|---|
| shipped | 442 | 3 — Series, Physical, **Apply** |
| `max-width` only | 358 | 2 — Series, **Apply** |
| `white-space: normal` only | 438 | 3 |
| **both, i.e. the Proposal** | 358 | **1 — `Apply`** |

`.bulk-group` is a `nowrap` flex row and `.bulk-field-input` was `width: 170px`, so
the field group's min-content is **396px** against 358px of available width. Nothing
set on the *bar* can shrink a child that will not wrap. The Proposal needed a third
declaration and did not have one.

**2. Of the two halves proposed, `max-width` is load-bearing and `white-space` is
nearly not** — 442→358 against 442→438. This finding presented them as a pair.

**3. The transform half would have silently killed the slide-in.**
`transition: bottom 0.3s cubic-bezier(0.34, 1.56, 0.64, 1)` animates nothing once
`bottom` is static. Measured with the park changed and the transition left alone:
**zero frames of motion across 166ms** — the bar snapped. The finding never mentions
the transition. It now reads `transition: transform`, and the bounce is intact.

**4. The defect is not phone-only, and the heading under-scopes it.** The bar is
never 80px tall at any width, so `bottom: -80px` never fully parked it: **34px**
showing at 1440, **91px** at 768, **177px** at 390. The transform fixes all three.
`SHARE-AUDIT`'s independently recorded *"roughly 38px … at viewport heights near
<!-- claim-ok: quoting SHARE-AUDIT, cited at :446-453 in the Scope section above -->
860"* matches the 34px measured at 900.

**5. This finding's own medium-confidence worry was unfounded** — dropping `nowrap`
costs nothing at 768 or 1440; both render identical to shipped. So the *"below 640px"*
media query the Proposal asked for buys nothing and was not written.

**6. Two small ones.** `.undo-toast` is at `:818-839`, not `:819-841`. And the
`document.scrollWidth` in the table above evaluates to `undefined` — the 390 is
correct for `document.documentElement.scrollWidth`.

**The route taken, and the one refused.** Two third declarations reach zero clipped.
`.bulk-group { flex-wrap: wrap }` does — **and it reverses an explicit written
decision**: the comment at `apps/media-vault/styles.css:897-900`, the markup comment
at `apps/media-vault/index.html:438-441`, and the assertions at
`apps/media-vault/test/smoke.mjs:275-289` all exist to keep a label with its controls,
and measured, it puts `Change type to →` on a line away from its buttons. Refused.
Narrowing `.bulk-field-input` from 170px to **100px** reaches zero clipped with the
groups intact, and the comment at `:906-913` defends a **fixed** width rather than
that number, so its reasoning survives.

**Verified at all three widths, after the change:**

| | parked, select OFF | in use, select ON |
|---|---|---|
| 390×844 | top 844 = viewport, **0px showing** (was 177) | 358×354, **0 clipped** (was 3) |
| 768×1024 | **0px showing** (was 91) | 736×167, 0 clipped |
| 1440×900 | **0px showing** (was 34) | 1408×114, 0 clipped |

Slide-in at 390: **19 distinct positions**, overshoot to 425 past a settled 462 — the
bounce is preserved. Four smoke suites pass; the assertions at `smoke.mjs:275-289` are
markup-shape and a CSS-only change cannot reach them.

**One consequence, stated rather than buried: the bar is now 354px tall at 390 in use,
up from 257.** That is not a regression — it is content that was previously off-screen
now being on it — but it is 42% of the viewport while select mode is on. Filed as `W3`
below rather than left in this note.

---


### W2 — medium — The whole workshop's icon layer is the operating system's emoji font, and the repo contains no icon of its own

**Counted 2026-09-10 across the shipped tree** — `apps/`, `shared/` and
`index.html`, excluding tests and docs:

| | |
|---|---|
| colour-emoji occurrences | **136** |
| distinct colour-emoji glyphs | **51** |
| `.svg` files in the shipped tree | **0** |
| inline `<svg>` markup | **0** |

By surface: media-vault 49, filament-forge 36, character-creator 35, pick3cut5 9,
`apps/manifest.json` 5 (which paints the landing page's five cards), `_template` 1,
`shared/` 1. The most repeated are `📚`×14, `🎲`×11, `🎬`×11, `✅`×8, `⚡`×8.

**What is deliberately NOT counted, because conflating the two roughly doubles the
number and the second kind is not a problem.** A further **100 occurrences of 13
distinct monochrome glyphs** — `→ ← ✕ ✓ ✔ ✗ ✏ ✎ ↳ ↻ ↶ ❄ ✂` — render as text in
`currentColor`, obey the palette, and are ordinary typography here (`← workshop`,
`Details →`, a `✕` close). They are not part of this finding. The count that
matters is the 136 that render from a colour font.

**Why it matters, in this repo specifically.** Three properties, none of which is
a matter of taste:

- **They ignore the palette.** `shared/styles.css` argues its accent hue to a
  degree and its contrast ratios to two decimals. A colour emoji is painted by the
  font, so `📀` is the most saturated thing on a page whose greens were chosen at
  188° rather than 166° to avoid a collision measured at dE00 13.2.
- **They are three different pictures.** The same button renders in Segoe UI Emoji
  on the Windows machine this is built on, Apple Color Emoji on a friend's iPhone
  at the table, and Noto on Android. The site is behind Access and its audience is
  a handful of people on mixed devices.
- **The repo self-hosts two variable fonts to avoid two third-party requests**, and
  documents that decision at length in `shared/styles.css`. The icon layer is
  outsourced to whatever font the reader's OS ships.

**Proposal:** a single inline SVG sprite at `shared/icons/sprite.svg`, `stroke:
currentColor`, 1.5px stroke, 20px box, referenced with `<use>`. Twenty or so
symbols will cover most of the 51, because the distinct glyphs collapse hard once
synonyms are merged — the set contains several pairs meaning the same thing. Start
with the two highest-visibility surfaces: the landing page's five cards (which
means `apps/manifest.json` grows an icon name instead of a glyph) and MediaVault's
toolbar. **Keep emoji where it is content rather than chrome** — a die face in a
roll log is arguably content.

**Posture: additive and incremental. No token change, no layout change, and NOT a
single sweeping replacement.** A per-surface migration that can stop half-done
without leaving the app inconsistent, because half the value is in the first two
surfaces.

**Evidence:** counted 2026-09-10 with a script over `apps/`, `shared/` and
`index.html`, using `\p{Emoji_Presentation}` plus `\p{Extended_Pictographic}` +
U+FE0F for the colour set, and a separate expression for the monochrome set;
`.svg` and inline `<svg>` counted over the same tree. The definition is stated
above because it is the whole argument for the number.

**Confidence:** high on the counts and on the absence of any SVG. **Low on "twenty
symbols will cover it"** — nobody has done the merge, and the real number is
whatever falls out of grouping 51 glyphs by meaning. Doing that grouping on paper
first is what would raise it, and it is an hour. **This is the field to read before
scoping the work**, because the proposal's size depends entirely on it.

**Ongoing cost:** a sprite file to keep current, and a convention for adding an
icon that does not exist yet — the first real design-system artefact in the repo
beyond tokens. Against that, it removes a per-platform rendering difference that
nothing can test for. **Worth stating plainly: this is the only finding in this
menu that costs more forever than it costs once.**

---

**Adjusted 2026-09-10 (PR #916). The `Confidence` field above did its job, and the
answer went the wrong way. RE-SCOPED to the five landing-page cards; the full
replacement is now recommended against.**

This finding shipped with one low-confidence claim — *"twenty or so symbols will
<!-- claim-ok: quoting this finding's own Proposal, four paragraphs above -->
cover most of the 51, because the distinct glyphs collapse hard once synonyms are
merged"* — and named the work that would settle it: group the glyphs by meaning
on paper first, about an hour. That grouping has now been done, against every
occurrence in context.

**The set does not collapse. It slightly expands.** Three pairs genuinely merge:

| merge | evidence |
|---|---|
| `⭐` + `💾` → **save** | `⭐ Save` ×5 in filament-forge against `💾 Save character` / `Save GM notes` / `Save to My Filaments` |
| `📜` + `📄` → **document** | `📜 Open full sheet`, `📄 Sheet`, `📄 CSV file` |
| `📋` + `🕐` → **history** | `📋 History` and `🕐 Recent History`, both filament-forge |

**And four glyphs carry more than one meaning, which costs five symbols back:**

| glyph | meanings |
|---|---|
| `💾` | save ×4 — **and `💾 Digital`**, media-vault's digital-format button |
| `📋` | `📋 History` — **and** `📋 Copy` / `Copy to Clipboard` |
| `🎯` | `🎯 Strike` in combat — **and** `🎯 Print Intent` |
| `✨` | AI action (`Ask`, `Sweep the notes`, `Fill blanks`) — **and** `✨ N unspent powers` — **and** `✨ Quality`, one of filament-forge's three print intents |

**51 glyphs − 3 merges + 5 extra symbols = about 53.** The Proposal's "twenty or
so" is wrong by more than 2.5×, and wrong in the direction that matters.

**The structural reason: 29 of the 51 glyphs are used exactly once** — 57% of the
set — and 37 are used twice or fewer. A set that is mostly singletons has no
redundancy to squeeze.

**Nor can most of the benefit be bought cheaply.** Coverage of all 133 rendered
occurrences by the top N glyphs: 5 → 38%, 10 → 58%, 20 → **76%**, 51 → 100%. A long
flat tail rather than a short head. Twenty symbols leaves a quarter of the uses on
emoji, and a half-drawn, half-emoji system is worse than either pure one — which is
the risk the Ongoing cost line above already named.

**Three occurrences are structurally unconvertible.** `📍`, `📚` and `🏷️` sit inside
`<option>` elements at `apps/media-vault/index.html:458-460`, whose content model is
text-only. SVG cannot go there without replacing the control.

**`filament-forge` alone accounts for 25 of the 51**, and 14 of those are
settings-section headers used exactly once each — `🌡️` temperature, `📏` layers,
`🔲` infill, `❄️` cooling, `🏗️` support, `📎` adhesion and the rest. That is a domain
vocabulary for 3D-printing parameters, not interface chrome, and drawing it is a
different project from replacing an icon layer.

**The count in the table above is three too high.** It reads 136 colour-emoji
occurrences; **133 render**. The other three are prose inside CSS comments —
`apps/character-creator/styles.css:1025` and `:1577`, `apps/media-vault/styles.css:538`
— and never reach a screen. The distinct-glyph count of 51 is unaffected, because all
three glyphs also appear in markup.

**And this finding's own "first step" was 21 symbols, not a handful.** The Proposal
says to start with the landing page's five cards and media-vault's toolbar. The hub
is 5 — but `apps/media-vault/index.html` carries **17** distinct glyphs, so that
starting point is 21: larger than the number the same paragraph claims would cover
the whole job.

---

**RE-SCOPED PROPOSAL, superseding the one above: the five landing-page cards, and
nothing else.**

`🧵` `📀` `🎲` `✂️` `🔧` — the five app icons in `apps/manifest.json`, which the hub
renders into its cards. Five symbols, one meaning each, no splits, no merges.

Why this survives when the full replacement does not:

- **It is the front door** — the first surface anyone sees, and the one where a
  per-platform rendering difference is most visible.
- **It is a closed set.** It changes only when an app is added, which is rare and
  already touches that file.
- **It needs no convention and no system.** Five drawings in one file is not an icon
  language; there is no "what do we do when the icon does not exist" question,
  because the set is enumerated by `apps/manifest.json` itself.
- **Its ongoing cost is therefore near zero**, which is the whole reason the original
  Proposal's Ongoing cost paragraph does not apply to it.

**Posture: additive, one closed set, no shared convention, no sprite discipline.**
Explicitly NOT the start of an icon system, and explicitly not a precedent for the
other 46 glyphs.

**The full replacement is recommended against**, on the evidence above: ~53 symbols
spanning combat verbs, media types and 3D-printing parameters, a permanent tax on
every future feature, three occurrences that cannot be converted at all, and nothing
in the repo able to test any of it for consistency. `audit-menu` says a proposal
whose ongoing cost exceeds its impact should recommend declining itself. For the
full version, this one now does.

**Severity is unchanged at medium.** It describes the observation — that the whole
workshop's icon layer is the OS emoji font — which is as true as it was. Only the
proposal got smaller.

**Evidence:** every occurrence extracted with its surrounding line and grouped by
meaning, 2026-09-10, at `origin/main` `c07fef8`; coverage curve and per-surface
counts computed over the same extraction; the `<option>` content model checked
against the markup at the three cited lines.

---

**Taken, 2026-09-10 (PR #917), as re-scoped. Posture held: additive, one closed set,
no shared convention, no sprite discipline.** The five landing-page cards carry drawn
SVG; the other 46 glyphs are untouched.

**Mechanism: the SVG lives in `apps/manifest.json`, in the `icon` field it replaces.**
The alternative — an icon *name* plus a lookup in `index.html` — was rejected on one
measured ground: `SETUP.md:879` promises that adding an app means editing the manifest
and that **"The dashboard renders its cards from the manifest — no HTML edits"**. A
<!-- claim-ok: quoting SETUP.md, cited by line number in the same sentence -->
lookup keyed by name breaks that for every future app. Keeping the markup in the data
file keeps the promise true. SVG attributes are single-quoted, which is valid HTML and
means no `\"` escaping inside JSON, so the manifest stays readable.

**That rests on one deliberate inconsistency, and it is now asserted rather than**
**hoped for.** `icon` is the only manifest field `index.html` does not pass through
`esc()`. Escaping it would print SVG source as text on all five cards, and nothing
else would look wrong. Three checks were added to the *front door* section of
`apps/character-creator/test/checks/rendered-ui.mjs`: that every card icon is drawn
markup, that the renderer still does not escape it, and that `name` and `description`
still are. **All three were made to fail first** — reverting one icon to an emoji,
wrapping `app.icon` in `esc()`, and stripping `esc()` from `app.name` each failed
exactly one check and no others.

**Five things `audit-premise-auditor` found before the edit.**

**1. A constraint I was budgeting for does not exist.** `apps/pick3cut5/test/smoke.mjs`
reads its OWN shell — `readFileSync(join(appDir, 'index.html'))`, `appDir` not
`repoRoot` — so nothing done to the hub can reach it. **And the comment at
`index.html:11-14` said the opposite**, claiming that test derives its list "from this
very head". Wrong about the file it sits in. Corrected in this PR, since the file was
already open and the claim is exactly the shape this repo loses to.

**2. A constraint that IS real, and rules out one mechanism.** The Access bypass is at
**5 of 5** destinations (`apps/pick3cut5/test/smoke.mjs:64`, `MAX_ACCESS_DESTINATIONS`),
and that suite scans `url()` inside every absolute stylesheet the app loads — including
`shared/styles.css`. **Any sprite or icon asset referenced by `url()` from `shared/`
would fail CI immediately.** The original full-sprite proposal would have hit this.

**3. The `no box-shadow` check reads the raw file, comments included.** So a comment
in `index.html` explaining an icon shadow decision **fails CI**, while
`filter: drop-shadow()` **passes** — the check cannot protect the rule it exists for.
Recorded here rather than fixed: it is not this finding's subject, and no comment
written for this change needed the phrase.

**4. `aria-hidden` is not neutral.** The emoji is part of each card link's accessible
name today — measured through `Accessibility.getFullAXTree` as
`link: "🧵 FilamentForge AI-powered…"`. The drawn icons carry `aria-hidden="true"`, so
that name is now `link: "FilamentForge AI-powered…"`. A screen reader stops announcing
a glyph name before every app. That is an improvement and it is a **decision**, not a
mechanical carry-over. The precedent followed is `apps/pick3cut5/index.html:133`, the
one existing `aria-hidden` in the repo, on a decorative spinner; `UI-AUDIT` `F22` is
the other side of the same line — glyph-only *buttons* got names rather than hiding.

**5. A dormant rule went live.** `index.html:209` —
`.card-soon h2, .card-soon .card-icon { color: var(--text-sub) }` — has never affected
the icon, because a colour emoji ignores `color` (proven: the five glyphs render
identically at `#FF0000`). With `stroke: currentColor` it now applies: measured after
the change, the four live cards stroke `rgb(226,233,229)` and the *soon* card
`rgb(147,162,157)`. Almost certainly what whoever wrote that line intended, and it had
never fired.

**`apps/_template/manifest-entry.example.json` was updated too**, because `SETUP.md`
names it as the source for a new app's manifest entry. Without it, app six arrives as
the one emoji card among six. That is the sixth glyph the Adjusted note above set
aside, and it cost one line.

**Verified:** five inline SVGs at 28×28 inside the unchanged 56×56 tint box; no
horizontal overflow at 390; no emoji left anywhere in the rendered hub;
`font-size: 36px` removed from `.card-icon`, which sized a glyph and now sizes nothing.
Four smoke suites pass — the character-creator suite at **1813** checks, up from 1810 by
the three added here.

**Still open on this menu: nothing from W2.** The other 46 glyphs stay as they are, by
the Adjusted note's recommendation, and this change is explicitly not a precedent for
converting them.

---

### W3 — low — The bulk bar takes 42% of a phone viewport while select mode is on

**Filed 2026-09-10 while taking `W1`, from measurements made during it.**

With every control now reachable, the bar measures **358×354 at 390×844** — five
wrapped rows, 42% of the viewport, over the library it is acting on. Before `W1` it
was 257px, but only because three controls were off-screen; the height is the honest
cost of fitting them.

At 768 it is 167px and at 1440 it is 114px, so this is a phone-shaped problem only.

**Proposal:** none offered, deliberately — this is a design decision rather than a
defect, and the shapes that would fix it differ in kind. A bottom sheet that the user
opens, a disclosure that keeps the field form collapsed until wanted, and a
two-row layout that drops the labels below 640px are all plausible and none is
obviously right. **Posture: undecided. This finding exists to hold the measurement,
not to prescribe.**

**Evidence:** `getBoundingClientRect` at 390×844, 768×1024 and 1440×900 through CDP
device emulation, 2026-09-10, on `apps/media-vault/styles.css` as `W1` left it.

**Confidence:** high on the numbers. **Low on whether it is worth fixing at all** —
nobody has used bulk edit on a phone and said it was a problem, and 42% of the screen
for the control surface of an action in progress may simply be correct. Someone
actually editing a few rows on a phone is what would settle it, and that is cheaper
than any of the three fixes.

**Ongoing cost:** whichever shape is chosen becomes a second layout to maintain for
this bar. **A proposal whose ongoing cost exceeds its impact should recommend
declining itself, and this one might: the measurement is worth having, the change may
not be.**

---

**Taken, 2026-09-10 (PR #918). The shape is Nate's, because this finding offered
none** — its posture was *undecided*. Of the four put to him — a disclosure, a bottom
sheet, declining, or shrinking the sticky header instead — he chose the disclosure. On
a phone the type, format and field groups fold behind a toggle; the count, Select all,
Fill blanks, Delete and Cancel stay visible. The change lives in
`apps/media-vault/index.html`, `styles.css`, `app.js` and `test/smoke.mjs`.

**Re-measuring before choosing corrected this finding in two ways.** It said the bar
takes 42% of the viewport and stopped there. **The sticky header takes another 23%**
— 197px, because it wraps six controls at 390 — and the finding never measured it.
And the problem is specific to **grid view**: while selecting, the library showed
**0.77 of a card** but **5.5 list rows**, so list view was usable before this change
and grid view never showed a whole item. At the top of the page it was worse — the
first card showed **60px** (an earlier figure of 76 included the grid's 16px padding).
**The scrolled figures are arithmetic, not a scrolled measurement:** bar top minus the
sticky header's bottom. The local library is one item and cannot scroll.

**Mechanism: a button with `aria-expanded`, a wrapper, and a few lines of JS — not
`<details>`.** Keeping `<details>` open on desktop needs `::details-content`,
and where that is unsupported a closed `<details>` hides its content in a way CSS
cannot override, so desktop would lose the change controls entirely. On an audience of
mixed devices that is not a risk worth a saved function. The open state is the
toggle's `aria-expanded` and nothing else; the stylesheet reads it with an
adjacent-sibling rule, so the screen and the screen reader cannot disagree. It is set
in the markup at rest, which is the trap `apps/pick3cut5/AUDIT.md:203-205` records.

**Phone-only, at the app's existing 768px breakpoint** rather than the 640px this
finding named — no new breakpoint value. At 1440, `display: contents` dissolves the
wrapper and the bar is the same 114px it was.

**Verified in headless Chrome over CDP, 2026-09-10** — the in-app pane reported the
bar parked while its own screenshot showed it up, because it does not advance a CSS
transition until something forces a paint:

| | folded | open | before |
|---|---|---|---|
| 390×844 | **106px** — 1.49 cards / 10.7 rows of library | 358px — 0.76 cards / 5.4 rows | 354px — 0.77 cards / 5.5 rows |
| 768×1024 | **61px** | 167px | 167px |
| 1440×900 | 114px, toggle hidden | 114px | 114px |

Delete on screen in every state at every width, nothing off-screen, every select-mode
entry starts folded, the bar still parks fully hidden (W1), and the slide-in still
animates — 18 distinct positions with the overshoot intact.

**The open state costs almost nothing, which is not what I first wrote.** My first
draft of the stylesheet comment said the open bar was taller than before because the
toggle takes a row of its own. Measured, it shares the first row with the count and
Select all: **358px against 354**. The premise audit's 366px came from a prototype where
the toggle did take its own row. The comment was corrected before commit.

**Six things `audit-premise-auditor` found before the edit.**

1. **The fourth group holds three buttons, not two.** `smoke.mjs` called it "the two
   actions"; Fill blanks joined it fifty minutes after that comment was written, the
   same day. It stays visible with Delete and Cancel — it costs no height, since the
   folded bar is two rows either way — and the check's wording is corrected.
2. **An always-visible Cancel already existed.** The sticky header's
   `#btnSelectMode` becomes "✕ Cancel" in select mode, and Escape exits too. The
   bar's own Cancel is a second copy; left alone, since removing it changes behaviour
   and was not asked for.
3. **The smoke check could not see inside a wrapper, and a classless one hid an
   orphaned label from it** — measured. It scanned the bar's direct children at two
   spaces of indent. It is rewritten to the intent — every label sits inside a group,
   wherever that group is — plus three more: four groups, the fold never holds the
   delete group, and the toggle carries `aria-expanded` at rest. **All four were made
   to fail first**, each failing alone: an orphaned label, a fifth group, a delete
   control inside the fold, and the toggle losing `aria-expanded`.
4. **W1's outcome note no longer holds on one point.** It says a CSS-only change
   cannot reach these smoke assertions. This change adds markup, so it does; the note
   is left standing as the record of the day it was written.
5. **A stale comment inside the `.bulk-bar` rule** said the bar "is centred with a
   translate". The block above it already recorded removing the translate. Corrected
   to past tense.
6. **The 1440 bar is two rows, not one** — Fill blanks, Delete and Cancel wrap. No
   effect on scope; desktop needs no fold.

**One thing measured and deliberately not filed.** The 197px sticky header is now the
largest single element on a phone in select mode. Shrinking it was the fourth option
put to Nate and he chose the bar instead, so it is recorded here, with its number, so
nobody measures it from scratch — and not given a finding he did not ask for.

**MediaVault's suite is 211 checks**, up from 209: two replaced, four added.

---

## Not carried forward, and why

Recorded so the same material does not get re-proposed from the same pass.

- **The character creator's interface** is `apps/character-creator/UI-AUDIT.md`'s
  subject, not this file's, however much a cross-app pass turns up there.
- **`apps/media-vault/styles.css:41`** pins `.btn-primary:hover` to a hardcoded
  `#c86a2e`, a rust literal surviving a verdigris scheme. It was seen while taking
  `UI-AUDIT` F34 and deliberately not filed: it measures 5.11 against
  `--bg-primary`, so it is stale rather than broken, and a finding whose whole
  content is "this hex should be a token" is not worth a number on its own. It
  belongs to whichever change next touches that block.
- **What bulk edit does** — what it selects, what it may set, what it deletes — is
  `BULK-AUDIT`'s, and `W1` is scoped to layout for that reason.
