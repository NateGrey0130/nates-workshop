#!/usr/bin/env node
// Deploy workers/table-room - The Table's live game room - always recording
// which commit it was built from.
//
//   node scripts/deploy-table-room.mjs
//   node scripts/deploy-table-room.mjs --dry-run      # build, print bindings, deploy nothing
//   node scripts/deploy-table-room.mjs --allow-dirty  # records <sha>-dirty; you almost never want this
//
// A MERGE DOES NOT DEPLOY THIS WORKER, exactly as for Pick 3 Cut 5's room. The
// Pages project binds it by script_name (the root wrangler.jsonc), so it must
// be deployed BEFORE the first merge that binds it, and again after any merge
// that changes workers/table-room/. `node scripts/deploy-sweep.mjs` names it
// when main has moved past what is live.
//
// A deploy restarts the Durable Objects. The rooms keep their feeds - they live
// in each object's storage, not its memory - but every connected screen drops
// and has to rejoin with the same code.
//
// The procedure and why it refuses a dirty tree: deploy-worker-lib.mjs.

import { deployWorker } from './deploy-worker-lib.mjs';

deployWorker({ workerDir: 'workers/table-room', script: 'deploy-table-room.mjs' });
