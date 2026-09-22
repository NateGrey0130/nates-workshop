# Nate's Workshop

Tools, toys, and experiments — built with Claude.

A personal site of small apps sharing one Cloudflare Pages project, one D1
database and one R2 bucket. Plain HTML, JS and CSS: **no build step, no
framework, no dependencies, no `package.json`.**

The site sits behind Cloudflare Access, so the deployed URL will redirect you to
a login you almost certainly cannot pass. The code is all here.

## The apps

Five of them are the RPG suite, which shares one stylesheet and one app
switcher. The character creator was split into them on 2026-09-19; the engine
they all load still lives under `apps/character-creator/js/`.

| | |
|---|---|
| [`apps/character-creator/`](apps/character-creator/) | Build a character, step by step — [its own README](apps/character-creator/README.md) is the deepest documentation in the repo, and its `js/` is the engine behind the four below |
| [`apps/character-sheet/`](apps/character-sheet/) | The sheet you play from |
| [`apps/codex/`](apps/codex/) | Everything the books print, and the editor behind it |
| [`apps/campaign/`](apps/campaign/) | Session notes, the shared stash, the ledger |
| [`apps/gm-tools/`](apps/gm-tools/) | The party roster, pools, and NPCs rolled from the books |

And three that stand alone:

| | |
|---|---|
| [`apps/filament-forge/`](apps/filament-forge/) | 3D print settings engine |
| [`apps/media-vault/`](apps/media-vault/) | Personal audiobook and film library |
| [`apps/pick3cut5/`](apps/pick3cut5/) | Party game, playable in a shared room — the only public one |

**What each app *is* lives in [`apps/manifest.json`](apps/manifest.json)**, which
the landing page reads at runtime. That file is the source; these tables are only
a map, and deliberately do not repeat it. Adding one is the `app-suite` skill.

**This table described four apps while eight were live**, for two days after the
split. Nothing pins this file — no check reads it, which is not true of any app's
own README — so it is corrected by hand or not at all.

## How it ships

**Merging to `main` is the deploy.** Cloudflare Pages publishes the repo root,
and there is no build step between the two. A GitHub ruleset requires a pull
request, so `main` does not take a direct push, and **since 2026-09-16 three
checks must be green before the merge button works** — `smoke`, `menus` and
`regression`. `play-flow` and the Pages deploy report only.

This paragraph said the suites **could not** block a merge, for the five days
after they started doing so. Ask the ruleset rather than this line:
`gh api repos/NateGrey0130/nates-workshop/rulesets/22209348`.

Schema and data changes are applied to the live database *before* the merge that
needs them, never after. That ordering is the single most important thing to
know before touching this repo.

## Where to look

| file | what it answers |
|---|---|
| [`CLAUDE.md`](CLAUDE.md) | Working *in* the repo: the skills, Cloudflare auth, applying migrations, why the permission allowlist has the gaps it has |
| [`SETUP.md`](SETUP.md) | How the deployment is configured, and what to touch when adding to it |
| [`apps/character-creator/README.md`](apps/character-creator/README.md) | The largest app, its data model and conventions |
| `*-AUDIT.md` | Findings menus. Each is a dated record of one investigation, with numbered findings taken one at a time. They are **records, not documentation** — a number in one was true on the day it was measured |

The audit menus are also where work is tracked.

## A note on the game data

The character creator's catalog is transcribed from Palladium Books sourcebooks
for personal use at one table. This project is unaffiliated with and unendorsed
by Palladium Books, and the rules text it stores belongs to them.

**The code here is MIT licensed. That licence does not extend to the game
content** — [`LICENSE`](LICENSE) is the licence, [`NOTICE`](NOTICE) is what it
does and does not cover.
