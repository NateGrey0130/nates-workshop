// GET /api/marvel-heroes/table/access - ?code= -> which roles and characters this person has at that table.
// The handler is shared (functions/api/_lib/table-room.js); the D1 answers are
// this game's own (../_lib/table.js).

import { tableRoutes } from '../../_lib/table-room.js';
import * as marvel from '../_lib/table.js';

export const onRequestGet = (context) => tableRoutes(marvel).access(context);
