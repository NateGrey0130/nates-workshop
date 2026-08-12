// POST /api/character-creator/import/extract — admin only.
// Body: { pdf_base64, filename?, model?, hints? }
//
// Sends the PDF itself to Claude through the existing /api/claude proxy (see
// the import spec: pre-extracted text splices two-column layouts together and
// makes this worse). Extraction only — nothing is written anywhere here.

import { requireAdmin, json } from '../_lib/auth.js';
import { crossReference } from '../_lib/catalog.js';
import { SYSTEM_PROMPT, buildUserPrompt } from '../_lib/extraction-prompt.js';
import { validateClaudeRequest, callAnthropic } from '../../_lib/claude-client.js';
import { saveDraft } from '../_lib/class-store.js';
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

  if (!env.ANTHROPIC_API_KEY) return json({ error: 'API key not configured on server' }, 500);

  // Calls the shared client directly. Fetching this site's own /api/claude
  // would be intercepted by Cloudflare Access in production and return the
  // login page as HTML.
  const claudeRequest = {
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
  };
  const invalid = validateClaudeRequest(claudeRequest);
  if (invalid) return json({ error: 'Built an invalid extraction request: ' + invalid }, 400);

  const upstream = await callAnthropic(claudeRequest, env);
  let payload;
  try {
    payload = JSON.parse(upstream.text);
  } catch {
    return json({
      error: `Anthropic returned a non-JSON response (status ${upstream.status})`,
      body_preview: upstream.text.slice(0, 300),
    }, 502);
  }
  if (upstream.status !== 200) {
    const detail = payload.error?.message || payload.error || `status ${upstream.status}`;
    return json({ error: 'Extraction call failed: ' + detail, status: upstream.status }, 502);
  }
  const blocks = Array.isArray(payload.content) ? payload.content : [];
  const text = blocks.filter((c) => c.type === 'text').map((c) => c.text).join('\n').trim();
  if (!text) {
    // Several genuinely different failures land here — an empty content array,
    // content with no text block (e.g. only thinking), or a truncated response.
    // Report which one it was instead of a generic "no text".
    const diag = {
      stop_reason: payload.stop_reason ?? null,
      stop_sequence: payload.stop_sequence ?? null,
      block_types: blocks.map((c) => c.type),
      block_count: blocks.length,
      usage: payload.usage ?? null,
      api_error: payload.error ?? null,
      model: payload.model ?? model,
    };
    const why = diag.stop_reason === 'max_tokens'
      ? `ran out of output budget (stop_reason=max_tokens, ${diag.usage?.output_tokens ?? '?'} tokens produced)`
      : blocks.length === 0
        ? 'the response contained no content blocks at all'
        : `the response had only ${diag.block_types.join(', ')} block(s) and no text`;
    return json({ error: `Extraction produced no usable text — ${why}`, diagnostics: diag }, 502);
  }

  const markdown = repairFrontmatter(stripFences(text));
  const parsed = parseClassMarkdown(markdown);
  const missing = parsed.data ? await crossReference(env, request.url, parsed.data) : { items: [], skills: [], spells: [], psionics: [] };

  // Autosave immediately: an extraction costs a real API call, and losing it to
  // a closed tab is the difference between a saved draft and paying again.
  let autosaved = false;
  if (parsed.data?.id) {
    try {
      await saveDraft(env, {
        classId: parsed.data.id,
        name: parsed.data.name,
        system: parsed.data.system,
        markdown,
        email: guard.email,
      });
      autosaved = true;
    } catch (err) {
      console.error('Draft autosave failed:', err.message);
    }
  }

  return json({
    markdown,
    autosaved,
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
