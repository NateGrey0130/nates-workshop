// GET /api/character-creator/table/join - ?code=&as= -> WebSocket to the room, with the role D1 decided.
// The handler is shared (functions/api/_lib/table-room.js); the D1 answers are
// this game's own (../_lib/table.js).

import { tableRoutes } from '../../_lib/table-room.js';
import * as palladium from '../_lib/table.js';

export const onRequestGet = (context) => tableRoutes(palladium).join(context);
