// POST /api/character-creator/import/gear/confirm — admin only.
// Body: { session_id, overrides?: [{ id, action, resolved_name? }] }
//
// Applies the session's pending staged rows to the gear catalog as one batch.
// The session stays open afterwards, so more page ranges can follow.
// See _lib/session-import.js.

import { handleSessionConfirm } from '../../_lib/session-import.js';

export const onRequestPost = ({ request, env }) => handleSessionConfirm(request, env, 'gear');
