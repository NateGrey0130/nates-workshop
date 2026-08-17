# PR 12 — Psionic tier rules

> **Delivered** in [#28](https://github.com/NateGrey0130/nates-workshop/pull/28). This file is the record of why, not a to-do.

> **Since delivered.** Two things below are no longer true, and both changed on
> purpose during the [rules audit](../rules-audit.md) against the source books:
>
> - **A tier no longer only comes from the class.** A character may *roll* one on
>   the Random Psionics Table (p.20), stored as `psychic_tier` on the character
>   and folded into the class-shaped object by
>   [`js/compose.js`](../../js/compose.js). "What already works" below describes
>   the state before that, so read it as history, not as the current shape.
> - **Tier-differentiated I.S.P. growth per level was rejected here and has
>   since been built** — minor gains `+1d6` a level, major `+1d6+1`. The
>   rejection was scope control for this PR, not a standing decision, and the
>   plan said so ("a reasonable follow-up on its own"). It is *not* an instance
>   of quietly re-adding a rejected choice.

Makes Minor, Major, and Master psychic tiers mechanically real: they gate which
powers a character may choose, and they change what you roll to save against
psionic attack.

Depends on [PR 6](06-psionic-importer.md). **This PR cannot be meaningfully
built or tested until at least one real psionic import has populated `min_tier`
on some rows.** Built against an all-NULL column, the enforcement is either a
no-op or it breaks the picker, and neither outcome tells you whether the code is
right.

## What already works — do not rebuild it

Three tier behaviours exist and are not in scope:

- The character's tier lives in class frontmatter as
  `psionics.type: minor | major | master`.
- Starting power counts by tier — minor 2, major 6, master 8 — with a
  `psionics.powers_starting` override.
- Super psionics gated to Master through `psionics.categories_allowed`.

`app.js` step 5 already reads `cls.psionics` and filters the picker by allowed
categories. This PR adds a second filter beside that one; it does not replace it.

## Decisions

**Out-of-tier powers are not selectable.** Hard block — the picker does not offer
them. No override toggle, no advisory-and-allow.

Note this deliberately differs from [PR 9](09-levelup-skill-picker.md), where
out-of-category skill picks are filtered by default but can be overridden with a
flag. That difference is intentional: skill category restrictions are frequently
bent at the table, psionic tier access is not.

**A NULL `min_tier` imposes no restriction** beyond the power's category — the
behaviour that exists today. Only an explicitly stated tier narrows access.

**The tier-based save target is included.** In Rifts, Major and Master psychics
save vs psionic attack at 12+ where everyone else needs 15+. `deriveSaves()`
currently returns `psionics: me` — the M.E. bonus alone, with no target number at
all — so the sheet cannot show what you actually need to roll.

Rejected: adding tier-differentiated ISP growth per level. It would pull the
leveling code into this PR; it is a reasonable follow-up on its own.

## Work

**Resolving a character's tier.** The picker reads it from the class today. Check
whether the character's tier is durable — a character whose class is soft-deleted
by [PR 2](02-class-soft-delete.md) still resolves through `getStored`, so this
probably holds. If it does not, persist the tier on the character at creation
rather than resolving it live, and say so in the PR. Do not leave it ambiguous.

Tier ordering is `minor < major < master`. Put that comparison in one helper —
a `TIERS` array with an index lookup — and use it in every place that asks
"does this character meet this requirement?". Do not compare tier strings
inline in two different files.

**Picker filtering** — `app.js` step 5:

- Alongside the existing category filter, exclude any power whose `min_tier`
  exceeds the character's tier.
- Show the count of powers hidden by tier, so an empty-looking category reads as
  a rule rather than a bug: *"3 powers require Master."* Visible but not
  selectable is better than silently absent.
- The catalog is fetched at boot through `catalogs.js`, whose projection is
  currently `name, category, isp`. **It must return `min_tier` too**, or the
  client has nothing to filter on. This is a one-field addition to the boot
  response, not a shape change.

**Save target** — `js/derive.js`:

- `deriveSaves()` gains a psionic save *target*, distinct from the existing M.E.
  bonus. The tier is an input, so the signature changes — it currently takes
  `attrs` only. Every caller must be updated; `derive.js` is a classic script
  exposing a global `derive`, used by both the sheet and the wizard.
- Non-psychics and Minor psychics: 15+. Major and Master: 12+.
- The existing `merge()` semantics hold — a stored value wins, a blank falls back
  to the derived one. The new target must participate in that, not bypass it.
- The sheet's saving-throw block renders the target beside the bonus.

**Catalog edit UI** — `min_tier` is already in the field config from PR 6, so the
edit UI picks it up with no work here. Worth confirming it renders as a
constrained choice of minor / major / master rather than a free-text box.

## Acceptance

- A Minor psychic's picker does not offer a power whose `min_tier` is `major`,
  and cannot be made to select one.
- A Master psychic sees every power their categories allow.
- A power with NULL `min_tier` is selectable by every tier whose category access
  permits it — no existing character's available choices change.
- Hidden-by-tier powers are surfaced as a count, not silently dropped.
- The boot catalog response includes `min_tier`.
- A Major psychic's sheet shows a psionic save target of 12; a non-psychic shows
  15; a hand-entered override still wins; clearing the override falls back to the
  derived value.
- Every `deriveSaves()` caller is updated — no caller passing the old argument
  list.
- Print layout still renders the saving-throw block correctly.
- `node apps/character-creator/test/smoke.mjs` passes, extended to cover tier
  comparison and the save target.

## Out of scope

ISP growth per level by tier, gaining new powers on level-up, per-class power
lists beyond `categories_allowed`, and backfilling `min_tier` on the seeded
powers — that is hand work through the catalog edit UI, by design.
