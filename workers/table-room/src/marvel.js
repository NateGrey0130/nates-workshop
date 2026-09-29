// The Marvel app's own Universal Table and rank ladder, loaded once for the
// room's FEAT rolls. Its own module so dice.js stays pure and takes the table
// as an argument. Wrangler bundles the JSON; Node reads it through the import
// attribute, which is how workers/table-room/test/room.mjs loads the real room.

import ranks from '../../../apps/marvel-heroes/data/ranks.json' with { type: 'json' };
import universal from '../../../apps/marvel-heroes/data/universal.json' with { type: 'json' };
import { makeFeat } from '../../../apps/marvel-heroes/js/feat.js';

export const feat = makeFeat(ranks, universal);
