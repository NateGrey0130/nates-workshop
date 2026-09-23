# PRODUCT.md — Nate's Workshop

Written 2026-09-20, from Nate's own answers during P5. **Product truth only** —
what this is and who uses it. Every visual decision lives in `DESIGN.md`.

**Nothing pins this file.** No test reads it and no script derives it, so treat
a sentence here the way `claim-audit` says to treat any undated prose: as true
on the day it was written. Where a claim is checkable, the check is named.

## What it is

Small apps behind one Cloudflare Access wall and one deploy.
`apps/manifest.json` is the list, and the only count worth trusting; the hub at
`/` is the tile grid. The visual systems are in `DESIGN.md`.

Five of them are one product in five jobs — the RPG suite, split on 2026-09-19:

| app | the job |
|---|---|
| Character Creator | build a character, step by step |
| Character Sheet | **play** one |
| Codex | look a rule up |
| Campaign | what happened, what the party carries |
| GM Tools | run the table |

The others are unrelated: FilamentForge (3D print settings), MediaVault
(a media library), Pick 3 Cut 5 (a party game, and the only public one), and
Marvel Heroes (a hero generator for a different RPG, TSR's MARVEL SUPER HEROES,
built from the *Ultimate Powers Book* and kept apart from the Palladium apps on
purpose).

## Who uses it

**Nate**, who is the GM, and a small number of friends he adds by hand to a
Cloudflare Access policy. There is no sign-up, no public account, no growth
goal. MediaVault's library belongs to one of those friends rather than to Nate.

That is the whole audience, and it is the reason several normal product
instincts are wrong here: there is no onboarding to optimise, no funnel, and no
reason to explain the game to a newcomer. Everyone who reaches a page already
knows what a W.P. is.

## The scene the Character Sheet is used in

Established with Nate, 2026-09-20:

- **Both the sheet and Play mode, switching constantly.** Not one or the other.
  The switching itself is a problem to design against, not a habit to support.
- **Whatever device is to hand, and it varies by session** — phone, tablet,
  laptop. All three have to be genuinely good; none is the "real" one.
- **At a table, mid-session, under time pressure**, with other people waiting.
  A thing that takes four screens of scrolling to find costs the table its
  attention, not just the player's patience.

## What the product is not allowed to do

- **Invent a rule.** The catalog holds what the books print. Where a book is
  silent the app is silent; `book-survey` and `class-import` carry the long
  version, and it is the most-enforced rule in the repo.
- **Decide what happened at the table.** The app records; the GM adjudicates.
  Saving throws are overridable, pools are steppable, and a roll is a record
  rather than a ruling.
- **Lose a half-typed note.** Switching a tab toggles classes rather than
  re-rendering, for exactly this reason.

## Constraints that are not preferences

- **No build step, no dependencies, no `package.json`.** Plain HTML, CSS and
  classic scripts. Merging to `main` IS the deploy.
- **Cloudflare Pages**, which is why there is no image resizing and no rate
  limiting binding — see `docs/pages-to-workers-migration.md`.
- **Everything is behind Access** except Pick 3 Cut 5's bypass paths.
