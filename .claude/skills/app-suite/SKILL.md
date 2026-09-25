---
name: app-suite
description: Add an app to Nate's Workshop, or change the hub, the app switcher or the shared header. Use when creating a new app, editing apps/manifest.json, touching shared/js/appnav.js or the landing page, splitting an app in two, or asking why a new app does not appear on the hub. Covers what makes a directory a URL, the one manifest field that must not be escaped, which apps share a stylesheet, and the app whose icons are missing on purpose.
---

# The app suite

> **What pins this file:** its frontmatter and every repo path it names, by
> `apps/character-creator/test/checks/environment.mjs`; every absolute path it
> names, by `apps/character-creator/test/checks/instruction-paths.mjs`.
>
> **The prose is pinned by nothing** — read an undated claim here as true on
> the day it was written.

**A directory under `apps/` is a URL.** Cloudflare Pages publishes the repo root
with no build step, so `apps/<slug>/index.html` is live at `/apps/<slug>/` the
moment the merge deploys. There is no routing table, no registration, nothing to
configure — which is why the failure mode here is never "the URL 404s" and
always "the app works and nothing points at it".

Everything below is one of the places that pointing happens.

## Starting one

`apps/_template/` is the start: `index.html`, `app.js`, `styles.css` and
`apps/_template/manifest-entry.example.json`. Copy the directory, then do the
three things the template cannot do for you.

**1. Add the manifest entry.** `apps/manifest.json` is what the hub reads at
runtime, and it is **the source of what an app is** — the root `README.md` says
so and deliberately does not repeat the descriptions. An entry is `slug`,
`name`, `group`, `icon`, `description`, `status`.

- `group` is an `id` from the manifest's top-level `groups` list, which is the
  hub's sections in order. The template's example says `other`; a Palladium or
  Marvel app needs its own. One that names no declared group still renders, in
  the last section, and `rendered-ui.mjs` fails on it.
- **`groups.json` must own the new directories, in the matching group** — the
  app's `apps/<slug>/`, its `functions/api/<slug>/`, and any table it creates.
  The manifest's `other` is `tools` there. `node scripts/groups.mjs --check`
  fails on a path with no owner and on a tile whose manifest group disagrees,
  and CI decides which suites a change runs from that owner (`CLAUDE.md` →
  *Three groups*).

- `status` of `live` **and** a slug makes the card a link. Anything else renders
  as a non-link card, which is how the `slug: null` "More Coming Soon" tile
  works.
- **`icon` is the one field the renderer does not escape**, and that is
  deliberate: it holds inline SVG, so escaping it would print markup as text on
  every card. `name`, `description` and `status` stay escaped because they are
  the fields a person types. Both halves are asserted in
  `apps/character-creator/test/checks/rendered-ui.mjs`, so a well-meant "fix"
  fails rather than shipping. **Do not add an emoji glyph** — a check requires
  every icon to start with `<svg`.

**2. Decide which visual system it is in**, which is decided entirely by which
stylesheets the page links. `shared/styles.css` alone gives Ley Verdigris;
`shared/styles.css` then `apps/character-creator/styles.css` gives Board &
Tissue, because the second file redeclares every token. `verify-ui` and
`DESIGN.md` have the rule and the trap in it.

**3. Decide whether it joins the RPG suite.** If it does, it loads
`shared/js/appnav.js` and marks itself with `data-appnav` — the switcher and the
context chip, shared by the five RPG pages so that a character or campaign
carried in the URL survives moving between them. `rendered-ui.mjs` checks each of
the five has its own page carrying that attribute and a live tile with an icon.
A standalone app (FilamentForge, MediaVault, Pick 3 Cut 5) links neither.

## Access, and the one app outside it

**A new app is private by default and that needs no work.** The whole site sits
behind Cloudflare Access; the exception is Pick 3 Cut 5, which is public through
an exact-path list.

**So do not copy Pick 3 Cut 5's `<head>`.** It deliberately carries **no icon
links at all** — its Access bypass is a list of exact paths, all five
destination slots are in use, and `apps/pick3cut5/test/smoke.mjs` derives the
list from that very head, so an icon link there would demand a sixth slot that
does not exist. The template's head carries the icon links and a comment saying
why that app does not. Anything touching that app or its assets is the
`pick3cut5` skill's business, and an asset is not the same thing as a page.

## Splitting an app in two

This happened on 2026-09-19 — the character creator became five apps — and the
shape is worth copying because the expensive parts were not the obvious ones.

- **The engine does not have to move.** `apps/character-creator/js/` stayed put
  and the new apps load its modules by absolute path, because the Pages
  Functions import them by path too. Only the page entry points moved.
- **Leave a stub at every old URL, and make it carry the query string.** The old
  pages are redirects that pass `location.search` and `location.hash` through,
  because `?id=` is the character — a bookmark, a link in someone's notes, or a
  sheet URL sent to a player still resolves there. A `<meta refresh>` cannot do
  this; it holds one URL fixed at write time. `rendered-ui.mjs` checks the stubs
  keep the query string.
- **Do navigation first.** The switcher shipped pointing at the old URLs, so the
  boundaries were judged before anything was paid for, and the split changed
  hrefs and nothing else.
- **Anything reading "the app's files" needs telling.** The test harness grew
  `appPath()` and `siblingAppDirs` for exactly this, and a sweep that was a
  `readdir` of one directory silently covered four fewer files. See
  `test-suite`.

## What "added" means

- the directory exists with an `index.html`, and it loads in a browser at its
  own URL — see `verify-ui`, and check the app is yours before trusting the page
- `apps/manifest.json` has its entry, with an `<svg` icon and the status you
  meant
- `groups.json` owns its directories and tables, and `groups.mjs --check` passes
- the stylesheets it links are the visual system you intended, checked by
  looking rather than by reading the file list
- if it is in the RPG suite: `shared/js/appnav.js` is loaded and the page
  carries `data-appnav`
- if it replaces or moves an existing URL: a stub is left behind that carries
  the query string
- the root `README.md`'s map mentions it — nothing pins that file, which is how
  it came to describe four apps while eight were live
