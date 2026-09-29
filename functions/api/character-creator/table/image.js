// /api/character-creator/table/image - GET ?code=&kind=&id= -> the picture on the table, to someone at it. Otherwise 404.
// The handler is shared (functions/api/_lib/table-room.js); the D1 answers are
// this game's own (../_lib/table.js). Who may have a picture is the room's
// rule, in workers/table-room/src/showing.js.

import { tableRoutes } from '../../_lib/table-room.js';
import * as palladium from '../_lib/table.js';

export const onRequestGet = (context) => tableRoutes(palladium).image(context);
