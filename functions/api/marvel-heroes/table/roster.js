// GET /api/marvel-heroes/table/roster?campaign_id= - who the GM may add to
// initiative, with each one's Agility and Talents from D1 (GM only).
// The handler is shared (functions/api/_lib/table-room.js); the D1 answers are
// this game's own (../_lib/table.js).

import { tableRoutes } from '../../_lib/table-room.js';
import * as marvel from '../_lib/table.js';

export const onRequestGet = (context) => tableRoutes(marvel).roster(context);
