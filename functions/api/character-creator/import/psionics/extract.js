// POST /api/character-creator/import/psionics/extract — admin only.
// Body: { session_id, pdf_base64, page_range?, category?, hints?, model? }
//
// One page range of a psionics chapter into an open session. Stages what comes
// back; writes nothing to the catalog. See _lib/session-import.js.

import * as prompt from '../../_lib/psionic-prompt.js';
import { handleSessionExtract } from '../../_lib/session-import.js';

export const onRequestPost = ({ request, env }) =>
  handleSessionExtract(request, env, 'psionics', prompt, (b) => ({ category: b.category }));
