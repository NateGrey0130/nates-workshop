// The half of deploy-sweep.mjs that decides, kept apart so a test can drive it.
// The script itself asks git and GitHub; this only reads what they said.
//
// A row is one first-parent commit, NEWEST FIRST, with what the Pages check-run
// query returned for it:
//   { sha, conclusions }   "Cloudflare Pages=success@<start>" joined by commas,
//                          or '' when the commit has no Pages check-run at all
//   { sha, error }         the query itself failed
//
// SUPERSEDED IS NOT STUCK, and not MISSING either. A Pages build publishes the
// whole repo root at its commit, so a commit with a NEWER success has shipped
// whatever its own check-run says - pending forever (a skipped deployment) or
// absent (3c83fbd on 2026-10-26: no check-suites from any app at all, and the
// next commit a1829149 deployed). Only the pending case was treated that way;
// a missing check-run printed DID NOT DEPLOY for a commit that was on the site.
//
// WHAT STAYS BAD: a commit that CONCLUDED failure, an unreadable query, and a
// missing or pending commit with nothing newer that succeeded. Supersession
// only ever quietens a commit a later build carried, so it cannot hide an
// outage: the August outage's 65 commits concluded `failure`, and a wedged
// build blocks the queue so nothing behind it succeeds.
export const STALLED_MINS = 10;

export function classify(rows, now = Date.now()) {
  const bad = [];
  const pending = [];
  const missing = [];
  const deployed = new Set();
  let ok = 0;

  for (const [idx, row] of rows.entries()) {
    const c = { ...row, idx };
    if (row.error) {
      bad.push({ ...c, why: `check-runs unreadable: ${row.error}` });
      continue;
    }
    const conclusions = row.conclusions || '';
    if (!conclusions) {
      missing.push({ ...c, why: 'no check-runs at all - the deploy never started' });
      continue;
    }
    if (conclusions.includes('=pending')) {
      const started = conclusions.match(/=pending@([^,]+)/)?.[1];
      const mins = started ? Math.floor((now - Date.parse(started)) / 60000) : null;
      pending.push({ ...c, why: conclusions, mins });
      continue;
    }
    if (conclusions.includes('=success') && !/=(failure|cancelled|timed_out|action_required)/.test(conclusions)) {
      deployed.add(idx);
      ok += 1;
      continue;
    }
    bad.push({ ...c, why: conclusions });
  }

  // The NEAREST later success, not the newest: the build that first carried
  // this commit's content onto the site.
  const supersededBy = (c) => {
    for (let j = c.idx - 1; j >= 0; j -= 1) if (deployed.has(j)) return rows[j];
    return null;
  };

  const superseded = [];
  const stalled = [];
  const building = [];
  for (const c of pending) {
    const by = supersededBy(c);
    if (by) superseded.push({ ...c, by });
    else if (c.mins !== null && c.mins >= STALLED_MINS) stalled.push(c);
    else building.push(c);
  }
  // A missing check-run is a failure to start, not a build in flight, so it has
  // no "building" or "stalled" state: carried by a later success, or bad.
  const supersededMissing = [];
  for (const c of missing) {
    const by = supersededBy(c);
    if (by) supersededMissing.push({ ...c, by });
    else bad.push(c);
  }
  bad.sort((a, b) => a.idx - b.idx);

  return { bad, superseded, supersededMissing, stalled, building, ok };
}
