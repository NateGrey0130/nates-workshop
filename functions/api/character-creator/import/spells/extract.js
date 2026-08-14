// POST /api/character-creator/import/spells/extract — admin only.
// Body: { session_id, pdf_base64, page_range?, level?, hints?, model? }
//
// Extracts one page range of a spell chapter into an open session. Classifies
// each spell against the catalog and stages the result, so a closed tab costs
// nothing — the extraction is the expensive part and it is saved the moment it
// parses. Writes nothing to the spells catalog itself.

import { requireAdmin, json, readJson } from '../../_lib/auth.js';
import { SYSTEM_PROMPT, buildUserPrompt } from '../../_lib/spell-prompt.js';
import {
  getImportSpec, extractRows, normaliseRows, classifyRows, countRows,
  DEFAULT_MODEL, ALLOWED_MODELS,
} from '../../_lib/import-engine.js';
import { getSession, stageRows, getStaged } from '../../_lib/import-sessions.js';

export async function onRequestPost({ request, env }) {
  const guard = requireAdmin(request, env);
  if (guard.res) return guard.res;

  const b = await readJson(request);
  if (!b?.pdf_base64) return json({ error: 'pdf_base64 is required' }, 400);

  const sessionId = parseInt(b.session_id, 10);
  if (!Number.isFinite(sessionId)) return json({ error: 'session_id is required' }, 400);
  const session = await getSession(env, sessionId);
  if (!session) return json({ error: 'No session with that id' }, 404);
  if (session.catalog !== 'spells') return json({ error: 'That session is not a spell import' }, 400);
  if (session.closed_at) return json({ error: 'That session is closed' }, 409);

  const model = ALLOWED_MODELS.includes(b.model) ? b.model : DEFAULT_MODEL;
  const spec = getImportSpec('spells');

  const result = await extractRows(env, spec, {
    pdfBase64: b.pdf_base64,
    model,
    systemPrompt: SYSTEM_PROMPT,
    userPrompt: buildUserPrompt({
      sourceBook: session.source_book, level: b.level, hints: b.hints,
    }),
  });
  if (result.error) return json({ error: result.error, ...(result.extra || {}) }, result.status);

  const rows = normaliseRows(spec, result.rows);
  if (!rows.length) {
    return json({ error: 'No spells found on those pages', staged: 0, usage: result.usage });
  }

  const classified = await classifyRows(env, spec, rows);
  // Re-submitting a range you already did is a normal mistake on a long import,
  // so names already staged in this session are skipped rather than duplicated.
  const { staged, skipped } = await stageRows(env, sessionId, b.page_range ?? null, classified, 'spells');

  return json({
    ok: true,
    staged,
    skipped,
    counts: countRows(classified),
    pending: (await getStaged(env, sessionId)).length,
    usage: result.usage,
    model,
  });
}
