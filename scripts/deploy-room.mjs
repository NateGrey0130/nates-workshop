#!/usr/bin/env node
// Deploy workers/pick3cut5-room, always recording which commit it was built
// from.
//
//   node scripts/deploy-room.mjs
//   node scripts/deploy-room.mjs --dry-run      # build, print bindings, deploy nothing
//   node scripts/deploy-room.mjs --allow-dirty  # see below; you almost never want this
//
// WHY THIS EXISTS AND IS NOT ONE MORE SENTENCE IN THE SKILL. The `pick3cut5`
// skill already said, in bold, that `--var GIT_SHA:$(git rev-parse HEAD)` is
// "not optional decoration". The 2026-09-02 hand deploy omitted it anyway, and
// for six days `deploy-sweep.mjs` could only compare timestamps and said so on
// every run. A flag you retype from prose is a flag you forget; a command that
// cannot omit it is not. This is the same move `ocr-book.py` made for the book
// caches, and the disposition `INGESTION-AUDIT` F15 reached about skill prose
// that is really a procedure.
//
// WHAT THE SHA BUYS. `deploy-sweep.mjs` reads the binding back off the live
// Worker and answers "is it stale" with `git log <deployed>..origin/main --
// workers/pick3cut5-room`, which is empty or it is not. Without it the sweep
// falls back to comparing a commit timestamp against a deploy timestamp, which
// cannot tell whether the change mattered. `REPO-AUDIT.md` G15.
//
// WHY A DIRTY TREE IS REFUSED. The sha is a claim about what is running. Deploy
// with uncommitted changes under the worker directory and the binding names a
// commit whose content is NOT what shipped - and the sweep then reports "up to
// date, nothing has touched it since that commit", confidently and wrongly.
// That is worse than the absent binding this script exists to prevent: an
// absent one makes the sweep say it is guessing. `--allow-dirty` records
// `<sha>-dirty`, which is not a commit, so the sweep's own unknown-commit
// branch fires and says the live build cannot be placed. It never reports
// "up to date" off a dirty deploy.
//
// THE BODY LIVES IN deploy-worker-lib.mjs since The Table's room became the
// second Worker deployed this way (scripts/deploy-table-room.mjs). One copy of
// the refusal and the stamp, two one-line callers.
//
// It does NOT verify the binding afterwards. `node scripts/deploy-sweep.mjs`
// already reads it back from the API, and a check that lives in one place is
// the one that stays true.

import { deployWorker } from './deploy-worker-lib.mjs';

deployWorker({ workerDir: 'workers/pick3cut5-room', script: 'deploy-room.mjs' });
