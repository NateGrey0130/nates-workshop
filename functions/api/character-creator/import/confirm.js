// POST /api/character-creator/import/confirm — admin only.
// Body: { markdown }
//
// Re-parses the (possibly hand-edited) markdown, inserts stub rows for any
// referenced items that don't exist yet — the only live write in this feature —
// and returns ready-to-merge JSON snippets for the static catalogs. The class
// markdown itself is never written anywhere: it's copied out and committed.

import { requireAdmin, json } from '../_lib/auth.js';
import { crossReference, buildSnippets } from '../_lib/catalog.js';
import { publish } from '../_lib/class-store.js';
import { parseClassMarkdown } from '../../../../apps/character-creator/js/parser.js';

const titleize = (slug) => String(slug)
  .split('-')
  .map((w) => (w ? w[0].toUpperCase() + w.slice(1) : w))
  .join(' ');

export async function onRequestPost({ request, env }) {
  const guard = requireAdmin(request, env);
  if (guard.res) return guard.res;

  const b = await request.json().catch(() => null);
  if (!b?.markdown) return json({ error: 'markdown is required' }, 400);

  const parsed = parseClassMarkdown(b.markdown);
  if (!parsed.data) return json({ error: 'Could not parse markdown: ' + parsed.errors.join('; ') }, 400);
  if (!parsed.ok) return json({ error: 'Fix these before confirming: ' + parsed.errors.join('; '), errors: parsed.errors }, 400);

  const missing = await crossReference(env, request.url, parsed.data);

  // Item stubs go live immediately — name/slug only, everything else left for
  // a human to fill in later.
  const inserted = [];
  if (missing.items.length) {
    const system = parsed.data.system === 'palladium-fantasy' ? 'palladium-fantasy' : 'rifts';
    await env.DB.batch(missing.items.map((slug) =>
      env.DB.prepare(
        `INSERT INTO items (slug, name, system, category, description, source_book)
         VALUES (?, ?, ?, NULL, ?, ?)`
      ).bind(slug, titleize(slug), system, 'STUB — created by class import, needs stats', parsed.data.source_book ?? null)
    ));
    inserted.push(...missing.items.map((slug) => ({ slug, name: titleize(slug) })));
  }

  // Publishing makes the class live immediately — no redeploy, no commit.
  await publish(env, {
    classId: parsed.data.id,
    name: parsed.data.name,
    system: parsed.data.system,
    markdown: b.markdown,
    email: guard.email,
  });

  return json({
    class_id: parsed.data.id,
    published: true,
    inserted_items: inserted,
    snippets: buildSnippets(missing),
    missing,
  });
}
