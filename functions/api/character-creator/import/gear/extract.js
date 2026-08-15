// POST /api/character-creator/import/gear/extract — admin only.
// Body: { session_id, pdf_base64, page_range?, category?, hints?, model? }
//
// One page range of an equipment chapter into an open session. Stages what
// comes back; writes nothing to the gear catalog. See _lib/session-import.js.

import * as prompt from '../../_lib/gear-prompt.js';
import { handleSessionExtract } from '../../_lib/session-import.js';

export const onRequestPost = ({ request, env }) =>
  handleSessionExtract(request, env, 'gear', prompt, (b) => ({ category: b.category }));
