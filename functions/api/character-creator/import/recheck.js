// POST /api/character-creator/import/recheck — admin only.
// Re-parses edited markdown and re-runs the catalog cross-reference without
// spending another extraction call. Writes nothing.

import { requireAdmin, json } from '../_lib/auth.js';
import { crossReference } from '../_lib/catalog.js';
import { parseClassMarkdown } from '../../../../apps/character-creator/js/parser.js';

export async function onRequestPost({ request, env }) {
  const guard = requireAdmin(request, env);
  if (guard.res) return guard.res;

  const b = await request.json().catch(() => null);
  if (!b?.markdown) return json({ error: 'markdown is required' }, 400);

  const parsed = parseClassMarkdown(b.markdown);
  const missing = parsed.data
    ? await crossReference(env, request.url, parsed.data)
    : { items: [], skills: [], spells: [], psionics: [] };

  return json({
    ok: parsed.ok,
    errors: parsed.errors,
    warnings: parsed.warnings,
    extraction_notes: parsed.data?.extraction_notes ?? null,
    class_id: parsed.data?.id ?? null,
    missing,
  });
}
