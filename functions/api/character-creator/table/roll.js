// POST /api/character-creator/table/roll - a character sheet roll, carried to the table while seated.
// The handler is shared (functions/api/_lib/table-room.js); the D1 answers are
// this game's own (../_lib/table.js).

import { tableRoutes } from '../../_lib/table-room.js';
import * as palladium from '../_lib/table.js';

export const onRequestPost = (context) => tableRoutes(palladium).roll(context);
