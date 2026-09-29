// /api/character-creator/table/show - POST { campaign_id, kind, id } -> { shown }. GM only: puts a picture on the table.
// The handler is shared (functions/api/_lib/table-room.js); the D1 answers are
// this game's own (../_lib/table.js). Who may have a picture is the room's
// rule, in workers/table-room/src/showing.js.

import { tableRoutes } from '../../_lib/table-room.js';
import * as palladium from '../_lib/table.js';

export const onRequestPost = (context) => tableRoutes(palladium).show(context);
