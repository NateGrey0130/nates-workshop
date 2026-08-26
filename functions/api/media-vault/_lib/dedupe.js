// Finding the repeats in a library, without ever deciding on the user's behalf
// that two rows are the same thing.
//
// Nothing in MediaVault's import paths has ever checked whether an item was
// already there. CSV import mints a fresh UUID per row and inserts
// unconditionally, so re-importing an export duplicates the whole library; the
// ISBN paste dedupes within one run and never looks at what is already stored.
// `source_id` is the field that could settle it — a normalised ISBN, or
// `tmdb:movie:1234` — and it is empty on all but a handful of rows, because it
// was added long after the rows were.
//
// So the only key available is the migration's: lowercased title plus type.
// That is deliberate rather than convenient. An item planMigration would have
// skipped as already-present is exactly the item this should flag, and the two
// agreeing means a user never sees one of them contradict the other.
//
// THE KEY IS NOT SUFFICIENT AND THIS CODE ASSUMES IT IS NOT. One title can
// honestly appear twice — two physical copies on different shelves — and one
// title can be two different works entirely: Candyman (1992) and Candyman
// (2021) share a title, a type, and nothing else. Measured against the live
// library, three of eight sampled title+type groups whose authors disagreed
// were separate works. A scanner that merged those would be a data-loss bug
// wearing a feature's clothes, so this one sorts groups into three piles and
// hands the only pile that needs judging to the person who can judge it.
//
// THE MERGE RULE: a field that disagrees is only a problem when BOTH sides have
// something to say. Empty-versus-filled is not a disagreement, it is the merge
// doing its job. A non-empty value is never overwritten — the same rule
// `enrichFills` follows in app.js, for the same reason.

import { ITEM_FIELDS, mergeKey } from './common.js';

// Everything a merge can carry from a losing row into a blank on the survivor.
// `type` and `title` are absent because they are the key: rows that disagreed
// about either are not in the same group to begin with.
export const DUP_MERGE_FIELDS = ['format', 'author', 'actors', 'producers', 'genre', 'series', 'location', 'cover', 'notes', 'source_id'];

// The subset where two different non-empty values mean "these are probably not
// the same thing" — the group stops being safe and arrives unticked.
//
// `genre` and `cover` are deliberately NOT here, and they are the two fields
// that disagree most. Genre strings come from whichever lookup happened to run
// and differ constantly without meaning anything; covers were written wrong in
// bulk for months by the carry-over bug (ISBN audit F3), so an existing cover
// is not evidence either. Requiring those to match would move 309 more groups
// of the live library into the review pile to no purpose. Every other field
// disagreeing is a real signal, including `source_id` — two different ids is
// the one piece of positive proof this data can offer that two rows are
// different works, and it will get stronger as the backfill fills it in.
export const DUP_BLOCKING_FIELDS = ['format', 'author', 'actors', 'producers', 'series', 'location', 'notes', 'source_id'];

// Conflicts first. The safe piles run to hundreds of groups in a real library,
// and a decision that needs the user's eyes must not be the thing they have to
// scroll past everything else to find.
const DUP_TIER_ORDER = { conflict: 0, mergeable: 1, identical: 2 };

// The row that keeps its identity: the earliest, so `addedAt` still answers
// "when did this enter the library". The id tie-break is not cosmetic — CSV
// import stamps one `Date.now()` across every row it creates, so a whole
// import shares a millisecond, and without a second term the survivor would
// depend on the order the database happened to return.
export function dupSurvivor(rows) {
  return rows.slice().sort((a, b) =>
    (a.addedAt || 0) - (b.addedAt || 0) || String(a.id).localeCompare(String(b.id)))[0];
}

// Case and surrounding space are noise here: 'Dune' and 'dune ' are one value.
// Two spellings that differ by more than that — 'Hamilton Wright Mabie' versus
// 'Mr Hamilton Wright Mabie' — are two values, and that is correct even though
// they are the same person. This cannot tell an honorific from a different
// author, so it declines to guess and lets the group be reviewed.
function dupDistinct(values) {
  const out = [];
  for (const raw of values) {
    const v = String(raw || '').trim();
    if (v && !out.some((x) => x.toLowerCase() === v.toLowerCase())) out.push(v);
  }
  return out;
}

// Not exported: planDedupe is the only caller, and the smoke test reaches every
// property of this through it. An export nothing imports is what the repo-wide
// guard in the character creator's suite exists to catch.
function dupGroup(rows) {
  const survivor = dupSurvivor(rows);
  const fills = {};
  const conflicts = [];
  for (const f of DUP_MERGE_FIELDS) {
    const values = dupDistinct(rows.map((r) => r[f]));
    if (values.length > 1 && DUP_BLOCKING_FIELDS.includes(f)) {
      conflicts.push({ field: f, values });
    }
    // A fill only ever lands in a blank. Where the survivor already has a
    // value it keeps it, conflict or not — which is what makes ticking a
    // conflicting group safe to offer at all: the worst it can do is discard
    // the losing rows, never rewrite the surviving one.
    if (!String(survivor[f] || '').trim() && values.length) fills[f] = values[0];
  }
  // Byte-identical across every field, title casing included — the only tier
  // where the losing rows provably carry nothing at all.
  const identical = rows.every((r) => ITEM_FIELDS.every((f) => (r[f] || '') === (survivor[f] || '')));
  const tier = conflicts.length ? 'conflict' : identical ? 'identical' : 'mergeable';
  return {
    key: mergeKey(survivor),
    tier,
    title: survivor.title,
    type: survivor.type,
    survivorId: survivor.id,
    loserIds: rows.filter((r) => r !== survivor).map((r) => r.id),
    fills,
    conflicts,
    // Conflicts arrive unticked, exactly as a guessed enrich match does. The
    // tick is what makes a judgement call trustworthy, and nothing is written
    // without one.
    include: tier !== 'conflict',
  };
}

// items: the caller's whole library. Returns only the groups with more than one
// member — a library with no repeats returns an empty list, not a report of
// every single-item group.
//
// Rows are named by id rather than sent back whole: the client already holds
// every one of them, and echoing ~1,300 full rows to describe 630 groups is a
// payload that says nothing the caller did not send.
export function planDedupe(items) {
  const byKey = new Map();
  for (const it of items) {
    const key = mergeKey(it);
    const bucket = byKey.get(key);
    if (bucket) bucket.push(it);
    else byKey.set(key, [it]);
  }

  const groups = [];
  for (const rows of byKey.values()) {
    if (rows.length > 1) groups.push(dupGroup(rows));
  }
  groups.sort((a, b) =>
    DUP_TIER_ORDER[a.tier] - DUP_TIER_ORDER[b.tier]
    || a.title.localeCompare(b.title)
    || a.type.localeCompare(b.type));

  return {
    scanned: items.length,
    groups,
    // What a full accept would remove. Never the group count: a group of three
    // gives up two rows, and reporting 630 where 662 rows will go is the kind
    // of off-by-a-pile a user only discovers afterwards.
    removable: groups.reduce((n, g) => n + g.loserIds.length, 0),
  };
}
