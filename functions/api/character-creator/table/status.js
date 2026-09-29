// GET /api/character-creator/table/status - ?campaign_id= -> is a table open, and did it close itself while idle.
// The handler is shared (functions/api/_lib/table-room.js); the D1 answers are
// this game's own (../_lib/table.js).

import { tableRoutes } from '../../_lib/table-room.js';
import * as palladium from '../_lib/table.js';

export const onRequestGet = (context) => tableRoutes(palladium).status(context);
