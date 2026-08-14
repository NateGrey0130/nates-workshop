// POST /api/character-creator/import/skills/extract — admin only.
// Body: { pdf_base64, category?, source_book?, systems?, hints?, model? }
//
// Extracts many skills from a book's skill chapter and classifies each against
// the existing catalog, so the review step can ask what to do about duplicates.
// Writes nothing.

import { requireAdmin, json, readJson } from '../../_lib/auth.js';
import { validateClaudeRequest, callAnthropic } from '../../../_lib/claude-client.js';
import { SYSTEM_PROMPT, buildUserPrompt } from '../../_lib/skill-prompt.js';

const DEFAULT_MODEL = 'claude-sonnet-5';
const ALLOWED_MODELS = ['claude-sonnet-5', 'claude-opus-5'];
const LOOKUP_BATCH = 50;

function stripFences(text) {
  const t = text.trim();
  const fenced = t.match(/^```(?:json)?\s*\n([\s\S]*?)\n```$/);
  return (fenced ? fenced[1] : t).trim();
}

const int = (v) => {
  const n = parseInt(v, 10);
  return Number.isFinite(n) && n >= 0 ? n : 0;
};

// Keeps only well-formed rows; a malformed element should not sink the batch.
function normalise(raw) {
  const rows = [];
  for (const r of Array.isArray(raw) ? raw : []) {
    const name = typeof r?.name === 'string' ? r.name.trim().replace(/:$/, '') : '';
    if (!name || name.length > 120) continue;
    rows.push({
      name,
      category: typeof r.category === 'string' ? r.category.trim() : null,
      base: int(r.base),
      per_level: int(r.per_level),
      note: typeof r.note === 'string' && r.note.trim() ? r.note.trim() : null,
    });
  }
  return rows;
}

export async function onRequestPost({ request, env }) {
  const guard = requireAdmin(request, env);
  if (guard.res) return guard.res;

  const b = await readJson(request);
  if (!b?.pdf_base64) return json({ error: 'pdf_base64 is required' }, 400);
  const model = ALLOWED_MODELS.includes(b.model) ? b.model : DEFAULT_MODEL;
  if (!env.ANTHROPIC_API_KEY) return json({ error: 'API key not configured on server' }, 500);

  const claudeRequest = {
    model,
    max_tokens: 16000,
    system: SYSTEM_PROMPT,
    messages: [{
      role: 'user',
      content: [
        { type: 'document', source: { type: 'base64', media_type: 'application/pdf', data: b.pdf_base64 } },
        { type: 'text', text: buildUserPrompt({
          category: b.category, sourceBook: b.source_book, systems: b.systems, hints: b.hints,
        }) },
      ],
    }],
  };
  const invalid = validateClaudeRequest(claudeRequest);
  if (invalid) return json({ error: 'Built an invalid extraction request: ' + invalid }, 400);

  const upstream = await callAnthropic(claudeRequest, env);
  let payload;
  try { payload = JSON.parse(upstream.text); }
  catch { return json({ error: `Anthropic returned a non-JSON response (status ${upstream.status})`, body_preview: upstream.text.slice(0, 300) }, 502); }
  if (upstream.status !== 200) {
    return json({ error: 'Extraction call failed: ' + (payload.error?.message || `status ${upstream.status}`) }, 502);
  }

  const blocks = Array.isArray(payload.content) ? payload.content : [];
  const text = blocks.filter((c) => c.type === 'text').map((c) => c.text).join('\n').trim();
  if (!text) {
    return json({
      error: 'Extraction produced no usable text',
      diagnostics: { stop_reason: payload.stop_reason ?? null, block_types: blocks.map((c) => c.type), usage: payload.usage ?? null },
    }, 502);
  }

  let parsed;
  try { parsed = JSON.parse(stripFences(text)); }
  catch { return json({ error: 'Model did not return valid JSON', body_preview: text.slice(0, 400) }, 502); }

  const rows = normalise(parsed);
  if (!rows.length) return json({ error: 'No skills found on those pages', rows: [], usage: payload.usage ?? null });

  // Classify against the catalog so the UI can ask about duplicates.
  const existing = new Map();
  const names = rows.map((r) => r.name);
  for (let i = 0; i < names.length; i += LOOKUP_BATCH) {
    const batch = names.slice(i, i + LOOKUP_BATCH);
    const { results } = await env.DB
      .prepare(`SELECT name, category, base, per_level, source, source_book, note FROM skills
                WHERE name COLLATE NOCASE IN (${batch.map(() => '?').join(',')})`)
      .bind(...batch).all();
    for (const r of results) existing.set(r.name.toLowerCase(), r);
  }

  const classified = rows.map((r) => {
    const match = existing.get(r.name.toLowerCase()) || null;
    if (!match) return { ...r, status: 'new', existing: null, differs: false };
    const differs = match.base !== r.base || match.per_level !== r.per_level;
    // A stub is a name the class importer created with no numbers — exactly what
    // this importer exists to fill in, so default it to update.
    const isStub = match.source === 'import' && match.base === 0 && match.per_level === 0;
    return {
      ...r,
      status: 'duplicate',
      existing: match,
      differs,
      is_stub: isStub,
      suggested: isStub ? 'update' : (differs ? 'ignore' : 'ignore'),
    };
  });

  return json({
    rows: classified,
    counts: {
      total: classified.length,
      new: classified.filter((r) => r.status === 'new').length,
      duplicates: classified.filter((r) => r.status === 'duplicate').length,
      stubs: classified.filter((r) => r.is_stub).length,
    },
    source_book: b.source_book ?? null,
    usage: payload.usage ?? null,
    model,
  });
}
