// scripts/deploy-sweep.mjs says whether a merged commit shipped, and its verdict
// is only worth reading if it cannot call a shipped commit lost or a lost one
// shipped. The decision lives in scripts/deploy-sweep-lib.mjs and is driven here
// with rows shaped like the check-run query's answers, newest first.
//
// The case that started this: 3c83fbd (#1890, 2026-10-20) had no check-suites
// from any app, so it had no Pages check-run at all, and the sweep printed it as
// DID NOT DEPLOY for a week while the next commit, a1829149, deployed and
// production held #1890's rows. Supersession was applied to a PENDING commit and
// not to a MISSING one.

import { check, section, wantSection } from '../harness.mjs';
import { classify } from '../../../../scripts/deploy-sweep-lib.mjs';

const SECTIONS = ['deploy-sweep.mjs: a commit a later build carried is not lost'];

export function run() {
  if (!SECTIONS.some(wantSection)) return;

  section('deploy-sweep.mjs: a commit a later build carried is not lost');
  {
    const ok = (sha) => ({ sha, conclusions: 'Cloudflare Pages=success@2026-10-20T10:00:00Z' });
    const none = (sha) => ({ sha, conclusions: '' });
    const failed = (sha) => ({ sha, conclusions: 'Cloudflare Pages=failure@2026-10-20T10:00:00Z' });
    const shas = (list) => list.map((c) => c.sha).join();

    const gap = classify([ok('new'), none('gap'), ok('old')]);
    check('a commit with no check-run, under a later success, is superseded',
      shas(gap.supersededMissing) === 'gap' && gap.bad.length === 0, shas(gap.bad));
    check('and it names the nearest later success as the carrier',
      gap.supersededMissing[0]?.by.sha === 'new');
    check('the successes around it are still counted', gap.ok === 2, String(gap.ok));

    const tip = classify([none('tip'), ok('old')]);
    check('a commit with no check-run and nothing newer deployed is still bad',
      shas(tip.bad) === 'tip' && tip.supersededMissing.length === 0, shas(tip.bad));

    const behind = classify([failed('new'), none('gap'), ok('old')]);
    check('a newer FAILURE does not carry it: the older success is behind, not after',
      shas(behind.bad) === 'new,gap' && behind.supersededMissing.length === 0, shas(behind.bad));

    const outage = classify([ok('new'), failed('f1'), failed('f2'), ok('old')]);
    check('a commit that concluded failure stays bad whatever came after it',
      shas(outage.bad) === 'f1,f2', shas(outage.bad));

    const err = classify([ok('new'), { sha: 'x', error: 'HTTP 502' }]);
    check('an unreadable query stays bad and says so',
      shas(err.bad) === 'x' && /unreadable: HTTP 502/.test(err.bad[0].why), err.bad[0]?.why);

    const pend = (sha) => ({ sha, conclusions: 'Cloudflare Pages=pending@2026-10-20T09:00:00Z' });
    const now = Date.parse('2026-10-20T12:00:00Z');
    const mix = classify([ok('new'), pend('skipped'), none('gap')], now);
    check('pending under a success is still superseded, beside a missing one',
      shas(mix.superseded) === 'skipped' && shas(mix.supersededMissing) === 'gap' && mix.bad.length === 0);
    const wedged = classify([pend('wedged'), ok('old')], now);
    check('a pending commit nothing newer carried is stalled, not superseded',
      shas(wedged.stalled) === 'wedged' && wedged.superseded.length === 0);
  }
}
