// POST /api/character-creator/import/confirm — admin only.
// Body: { markdown }
//
// Re-parses the (possibly hand-edited) markdown, publishes the class so it is
// live in the app immediately, and creates stub rows for anything it references
// that does not exist yet. Every catalog lives in D1, so nothing here needs a
// redeploy or a manual copy-paste step.

import { requireAdmin, json } from '../_lib/auth.js';
import { crossReference, buildStubStatements } from '../_lib/catalog.js';
import { publishStatement } from '../_lib/class-store.js';
import { parseClassMarkdown } from '../../../../apps/character-creator/js/parser.js';

export async function onRequestPost({ request, env }) {
  const guard = requireAdmin(request, env);
  if (guard.res) return guard.res;

  const b = await request.json().catch(() => null);
  if (!b?.markdown) return json({ error: 'markdown is required' }, 400);

  const parsed = parseClassMarkdown(b.markdown);
  if (!parsed.data) return json({ error: 'Could not parse markdown: ' + parsed.errors.join('; ') }, 400);
  if (!parsed.ok) return json({ error: 'Fix these before confirming: ' + parsed.errors.join('; '), errors: parsed.errors }, 400);

  const missing = await crossReference(env, request.url, parsed.data);
  const { created, statements } = buildStubStatements(env, missing, {
    system: parsed.data.system === 'palladium-fantasy' ? 'palladium-fantasy' : 'rifts',
    sourceBook: parsed.data.source_book,
  });

  // Stubs and the class itself go in one batch — a failure part-way through
  // must not leave orphaned catalog rows referenced by no class.
  await env.DB.batch([
    ...statements,
    publishStatement(env, {
      classId: parsed.data.id,
      name: parsed.data.name,
      system: parsed.data.system,
      markdown: b.markdown,
      email: guard.email,
    }),
  ]);

  return json({
    class_id: parsed.data.id,
    published: true,
    created,
    missing,
  });
}
