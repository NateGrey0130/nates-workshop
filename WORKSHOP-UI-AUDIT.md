# WORKSHOP-UI-AUDIT.md — the interface, across apps

> **Since 2026-09-16 the closed findings live in `WORKSHOP-UI-AUDIT.closed.md`**, moved
> there verbatim with their headings, numbering and notes; this file keeps a
> one-line pointer per moved finding where its heading was, and holds in full
> every finding whose own section records no outcome. The closed file is a
> record like this one, and the `*AUDIT*.md` glob reaches both.

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

- **W1** — high — MediaVault's bulk bar is 68px wider than a phone, clips its own Apply button, and covers 177px of the library before anyone has selected anything — Taken, 2026-09-10 (PR #915). Posture held: one app stylesheet, no markup change, — full text in `WORKSHOP-UI-AUDIT.closed.md` under its own `### W1` heading.

- **W2** — medium — The whole workshop's icon layer is the operating system's emoji font, and the repo contains no icon of its own — Adjusted 2026-09-10 (PR #916). The `Confidence` field above did its job, and the — full text in `WORKSHOP-UI-AUDIT.closed.md` under its own `### W2` heading.

- **W3** — low — The bulk bar takes 42% of a phone viewport while select mode is on — Taken, 2026-09-10 (PR #918). The shape is Nate's, because this finding offered — full text in `WORKSHOP-UI-AUDIT.closed.md` under its own `### W3` heading.

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
