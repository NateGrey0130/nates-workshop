// The Table — the room Worker.
//
// It exists only to export the TableRoom Durable Object: a Pages project can
// bind to a Durable Object but cannot define one, which is why Pick 3 Cut 5's
// room is a Worker of its own too (the root wrangler.jsonc says so at length).
//
// NOTHING REACHES IT BUT THE PAGES BINDING. `workers_dev` is off and there is
// no route, so the only way to a room is `env.TABLE_ROOM` in a Pages Function
// - and every one of those sits behind Cloudflare Access and has checked the
// campaign in D1 before it calls. That is what lets the room trust the
// identity headers the join route puts on a socket. This handler answers
// anything that arrives some other way with a 404.
//
// A MERGE DOES NOT DEPLOY IT. Deploy with `node scripts/deploy-table-room.mjs`,
// which records the commit it was built from, and BEFORE the Pages deploy that
// first binds it.

import { TableRoom } from './room.js';

export { TableRoom };

export default {
  async fetch() {
    return new Response('Not found', { status: 404 });
  },
};
