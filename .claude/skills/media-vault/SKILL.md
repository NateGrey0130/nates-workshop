---
name: media-vault
description: Change MediaVault without widening who can read whose library. Use when touching apps/media-vault/, functions/api/media-vault/, the media_items or media_shares tables, sharing, ISBN lookup, bulk edit or CSV import. Covers the one endpoint that returns rows the caller does not own, what the structural checks can and cannot prove about that, the two case conventions on one join, and why the production library is not test data.
---

# MediaVault

> **What pins this file:** its frontmatter and every repo path it names, by
> `apps/character-creator/test/checks/environment.mjs`; every absolute path it
> names, by `apps/character-creator/test/checks/instruction-paths.mjs`.
>
> **The prose is pinned by nothing** — read an undated claim here as true on
> the day it was written.

A personal library, private by default, behind the site-wide Access gate.
`apps/media-vault/README.md` is unusually complete on *what is where* — read it
for the map. This page is the part that is not in it: what breaks, and which
mistakes are quiet.

**Everything here is one invariant.** A media library is private until its owner
says otherwise. A character is shared with a table; this is not.

## The invariant, and what the checks actually prove

Two structural checks in `apps/media-vault/test/smoke.mjs` hold the line:

1. **Every `SELECT`, `UPDATE` and `DELETE` against `media_items` carries
   `user_email = ?`.** Restricted to those three verbs on purpose — the shared
   upsert is an `INSERT ... ON CONFLICT` with no `WHERE` at all, because its
   scoping is the column it inserts. A predicate demanding the clause of *every*
   statement would flag the one statement behind every write in the app.
2. **Exactly one endpoint reads both `media_items` and `media_shares`, and it is
   `functions/api/media-vault/vault.js`.** A second file matching that shape
   means somewhere else has learned to serve another person's library.

**Neither check can prove the caller's own email is the one bound.** That is
positional — decided by `bindUpsert` and by the argument order at each `.bind()`
— and no reading of source text sees it. So when you touch a bind, the checks
will stay green through a mistake. Read the argument order yourself.

**`vault.js` is read-only by construction**, not by a check somebody has to
remember: it makes one kind of statement and exports only `onRequestGet`, so a
`POST` to that path is answered 405 by the router.

**The two columns it joins carry two case conventions**, and mixing them up is
the likeliest bug in the app: `media_shares.owner_email` is stored **exactly** as
the identity header gave it, because that is what `media_items.user_email`
holds and the two are joined; `viewer_email` is stored **lowercased**, because it
is compared against a different request's identity. Match the caller lowercased,
bind the owner verbatim.

**A sibling app made the opposite choice deliberately.** The character creator's
`[id]` route keeps an open read for any authenticated friend in the same file as
its owner-only writes. That is live and documented, not an oversight — do not
"fix" one to match the other.

## The bug this app was rebuilt to end

There was a `PUT` that replaced a whole library. It is gone, and three checks
keep it gone: **no endpoint handles `PUT` at all**, every delete statement names
`item_id`, and the old whole-library endpoint's file must not exist with nothing
still calling its path.

If a change of yours wants to write a library in one statement, that is the
shape those checks exist to refuse. Chunk it instead — the bulk endpoints cut id
lists at **90** per statement because D1 caps bound parameters, and the README
states that number where the suite reads it back.

## The endpoint list is derived from disk, and that was bought

The suite walks `functions/api/media-vault/` rather than listing it. It listed
seven endpoints until 2026-09-08, and the day an eighth landed — `shares.js` —
the structural checks above silently stopped reading the new file and the suite
passed. **If you add an endpoint, it is covered automatically. Do not
reintroduce a list.**

## Testing it, and the data you are testing against

```bash
node apps/media-vault/test/smoke.mjs
```

It uses the character creator's harness, on purpose — a second copy would drift.
Everything it does is text and pure functions: the migration planner, the
sanitizer, the duplicate scanner, the ISBN rules, the structural checks, and the
README's own claims.

**On localhost every caller is the same person.** `getUserEmail()` falls back to
`dev@localhost` when the host is `localhost` or `127.0.0.1`, the same fallback
the other apps use. So a local server cannot exercise sharing by identity alone —
two identities is the one thing local cannot give you, and the sharing paths are
the ones where being wrong costs the most.

**The production library is a real person's, and it is not Nate's.** Thousands of
items belong to a friend of his; Nate's own account held three. Treat every
destructive path — bulk delete, bulk retype, the duplicate merge, the migration —
as touching someone's actual collection, and exercise them locally against local
rows. `ship-pr`'s rule about production applies with more force here than
anywhere else in the repo: read, do not click.

## Its three menus, and their prefixes

`ISBN-AUDIT.md` (`F1`–`F10`), `BULK-AUDIT.md` (`B1`–`B9`) and `SHARE-AUDIT.md`
(`V1`–`V7`) all live under `apps/media-vault/`, each with its closed findings
beside it in a `.closed.md`. **The share menu numbers `V`, deliberately not
`S`** — the character creator's class menu already numbers schema items `S1`–`S9`,
and a bare `S3` would then name neither.

Read each finding's own note for its state; none of the three headers is a
reliable summary, and `BULK-AUDIT.md` says why — two statements three lines apart
disagreed from the moment the second was written. Use `audit-menu`, and `take`
when one is taken.
