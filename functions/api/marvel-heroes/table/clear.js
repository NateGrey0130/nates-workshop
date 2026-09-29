// /api/marvel-heroes/table/clear - POST { campaign_id } -> { shown: null }. GM only: takes the picture down.
// The handler is shared (functions/api/_lib/table-room.js); the D1 answers are
// this game's own (../_lib/table.js). Who may have a picture is the room's
// rule, in workers/table-room/src/showing.js.

import { tableRoutes } from '../../_lib/table-room.js';
import * as marvel from '../_lib/table.js';

export const onRequestPost = (context) => tableRoutes(marvel).clear(context);
