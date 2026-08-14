// POST /api/character-creator/import/spells/extract — admin only.
// Body: { session_id, pdf_base64, page_range?, level?, hints?, model? }
//
// One page range of a spell chapter into an open session. Stages what comes
// back; writes nothing to the spells catalog. See _lib/session-import.js.

import * as prompt from '../../_lib/spell-prompt.js';
import { handleSessionExtract } from '../../_lib/session-import.js';

export const onRequestPost = ({ request, env }) =>
  handleSessionExtract(request, env, 'spells', prompt, (b) => ({ level: b.level }));
