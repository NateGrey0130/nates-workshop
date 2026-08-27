// POST /api/character-creator/import/skills/extract — admin only.
// Body: { pdf_base64, category?, source_book?, systems?, hints?, model? }
//
// Extracts many skills from a book's skill chapter and classifies each against
// the existing catalog, so the review step can ask what to do about duplicates.
// Writes nothing.
//
// The pipeline lives in _lib/import-engine.js; this endpoint supplies the skill
// prompt and the response shape.

import { requireAdmin, json, readJson } from '../../_lib/auth.js';
import { SYSTEM_PROMPT, buildUserPrompt } from '../../_lib/skill-prompt.js';
import {
  getImportSpec, extractRows, normaliseRows, classifyRows, countRows,
  DEFAULT_MODEL, ALLOWED_MODELS,
} from '../../_lib/import-engine.js';

export async function onRequestPost({ request, env }) {
  const guard = requireAdmin(request, env);
  if (guard.res) return guard.res;

  const b = await readJson(request);
  if (!b?.pdf_base64) return json({ error: 'pdf_base64 is required' }, 400);
  const model = ALLOWED_MODELS.includes(b.model) ? b.model : DEFAULT_MODEL;

  const spec = getImportSpec('skills');
  const result = await extractRows(env, spec, {
    pdfBase64: b.pdf_base64,
    model,
    systemPrompt: SYSTEM_PROMPT,
    userPrompt: buildUserPrompt({
      category: b.category, sourceBook: b.source_book, systems: b.systems, hints: b.hints,
    }),
    email: guard.email,
  });
  if (result.error) return json({ error: result.error, ...(result.extra || {}) }, result.status);

  const rows = normaliseRows(spec, result.rows);
  if (!rows.length) return json({ error: 'No skills found on those pages', rows: [], usage: result.usage });

  const classified = await classifyRows(env, spec, rows);

  return json({
    rows: classified,
    counts: countRows(classified),
    source_book: b.source_book ?? null,
    usage: result.usage,
    model,
  });
}
