// POST /api/marvel-heroes/table/close - close the table (GM only) and save its feed to the campaign.
// The handler is shared (functions/api/_lib/table-room.js); the D1 answers are
// this game's own (../_lib/table.js).

import { tableRoutes } from '../../_lib/table-room.js';
import * as marvel from '../_lib/table.js';

export const onRequestPost = (context) => tableRoutes(marvel).close(context);
