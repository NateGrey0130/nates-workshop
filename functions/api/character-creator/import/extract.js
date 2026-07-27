// POST /api/character-creator/import/extract — admin only.
// Body: { pdf_base64, filename?, model?, hints? }
//
// Sends the PDF itself to Claude through the existing /api/claude proxy (see
// the import spec: pre-extracted text splices two-column layouts together and
// makes this worse). Extraction only — nothing is written anywhere here.

import { requireAdmin, json } from '../_lib/auth.js';
import { crossReference } from '../_lib/catalog.js';
import { SYSTEM_PROMPT, buildUserPrompt } from '../_lib/extraction-prompt.js';
import { parseClassMarkdown } from '../../../../apps/character-creator/js/parser.js';

const CLASSES_PATH = '/apps/character-creator/data/classes/';
// One OCC and one RCC, so the model sees both shapes.
const EXAMPLE_FILES = ['cyber-knight.md', 'dragon-hatchling.md'];
const DEFAULT_MODEL = 'claude-sonnet-5';
const ALLOWED_MODELS = ['claude-sonnet-5', 'claude-opus-5'];

// Claude occasionally wraps the file in a fence despite instructions.
function stripFences(text) {
  const t = text.trim();
  const fenced = t.match(/^```(?:markdown|md|yaml)?\s*\n([\s\S]*?)\n```$/);
  return (fenced ? fenced[1] : t).trim();
}

// Observed failure mode: the frontmatter opens with `---` but is never closed,
// running straight into the first `##` body heading. Deterministic repair —
// only fires when there is exactly one delimiter and a heading to close before.
function repairFrontmatter(md) {
  if (!md.startsWith('---')) return md;
  const lines = md.split('\n');
  const delims = lines.reduce((acc, l, idx) => (l.trim() === '---' ? [...acc, idx] : acc), []);
  if (delims.length !== 1 || delims[0] !== 0) return md;
  const heading = lines.findIndex((l) => /^##\s/.test(l));
  if (heading < 1) return md;
  lines.splice(heading, 0, '---', '');
  return lines.join('\n');
}

export async function onRequestPost({ request, env }) {
  const guard = requireAdmin(request, env);
  if (guard.res) return guard.res;

  const b = await request.json().catch(() => null);
  if (!b?.pdf_base64) return json({ error: 'pdf_base64 is required' }, 400);
  const model = ALLOWED_MODELS.includes(b.model) ? b.model : DEFAULT_MODEL;

  const examples = [];
  for (const file of EXAMPLE_FILES) {
    const res = await env.ASSETS.fetch(new URL(CLASSES_PATH + file, request.url));
    if (res.ok) examples.push({ name: file, text: (await res.text()).trim() });
  }
  if (!examples.length) return json({ error: 'Could not load any example class files' }, 500);

  const proxyRes = await fetch(new URL('/api/claude', request.url), {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      model,
      max_tokens: 12000,
      system: SYSTEM_PROMPT,
      messages: [{
        role: 'user',
        content: [
          { type: 'document', source: { type: 'base64', media_type: 'application/pdf', data: b.pdf_base64 } },
          { type: 'text', text: buildUserPrompt(examples, b.hints) },
        ],
      }],
    }),
  });

  const payload = await proxyRes.json().catch(() => ({}));
  if (!proxyRes.ok) {
    const detail = payload.error?.message || payload.error || `proxy returned ${proxyRes.status}`;
    return json({ error: 'Extraction call failed: ' + detail }, 502);
  }
  const text = (payload.content || []).filter((c) => c.type === 'text').map((c) => c.text).join('\n').trim();
  if (!text) return json({ error: 'Model returned no text', raw: payload }, 502);

  const markdown = repairFrontmatter(stripFences(text));
  const parsed = parseClassMarkdown(markdown);
  const missing = parsed.data ? await crossReference(env, request.url, parsed.data) : { items: [], skills: [], spells: [], psionics: [] };

  return json({
    markdown,
    ok: parsed.ok,
    errors: parsed.errors,
    warnings: parsed.warnings,
    extraction_notes: parsed.data?.extraction_notes ?? null,
    class_id: parsed.data?.id ?? null,
    missing,
    usage: payload.usage ?? null,
    model,
  });
}
