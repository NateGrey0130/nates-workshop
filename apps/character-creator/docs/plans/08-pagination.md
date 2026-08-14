# PR 8 — List pagination

## Problem

The journal endpoint takes a `limit` (default 200). Character, campaign, gear,
and catalog lists are unbounded. Fine at friends scale today — and the three
importers in PRs 5–7 are specifically designed to grow the catalogs from tens of
rows to hundreds.

## Decision

**Limit plus offset, matching the journal's existing pattern.** Consistent with
what is already there and trivial to implement.

Rejected: cursor/keyset pagination, correct under concurrent inserts but overkill
here. Also rejected as the primary answer: raising caps with a total count, and
server-side search instead of paging.

Server-side filtering is genuinely more useful than page controls for a
400-spell catalog — but PR 4 already builds client-side filtering over the
catalog tables, so this PR's job is to bound the responses, not to replace that.

## Work

Apply a uniform convention across list endpoints:

- Accept `limit` and `offset` query parameters.
- Default `limit` to 200, clamp to a maximum of 500. A caller asking for more
  gets the maximum, not an error.
- Return `{ results, total, limit, offset }` rather than a bare array, so the UI
  can show "showing 200 of 412".
- Reject a negative or non-numeric `limit`/`offset` by falling back to defaults.

Endpoints to cover:

- `functions/api/character-creator/characters.js`
- the campaigns list
- `functions/api/character-creator/items.js` (`gear` by now)
- `functions/api/character-creator/catalogs.js`

**`catalogs.js` needs care.** The wizard boots on it and expects the whole
catalog in one response — that is why it exists as one endpoint rather than
three. Changing its shape breaks `app.js`. Either keep the boot response
unpaginated and paginate only the admin read routes PR 4 adds, or update `app.js`
in the same PR to fetch through. **Keeping the boot path unpaginated is the safer
choice**, and if the catalogs grow past what is reasonable to send at boot, that
is a real change to how the wizard loads and deserves its own PR.

Update every caller that assumes a bare array. Grep for `.json()` destructuring
on these endpoints in `app.js`, `sheet.js`, and the GM dashboard.

## Acceptance

- Each covered endpoint honours `limit` and `offset` and returns a correct
  `total`.
- `limit=99999` returns 500 rows, not an error.
- `limit=-1` and `limit=abc` fall back to the default.
- The wizard still boots with a full catalog.
- The sheet, GM dashboard, and character list all still render.
- `node apps/character-creator/test/smoke.mjs` passes.

## Out of scope

Cursor pagination, server-side search, infinite scroll, and changing how the
wizard loads catalogs at boot.
