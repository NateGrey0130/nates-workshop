// The only place this Worker talks to the Anthropic API.
//
// Deliberately NOT shared with functions/api/_lib/claude-client.js. That file
// is bundled into the Pages project and carries the whole site's guardrails
// (model allowlist, 15MB document blocks, D1 usage metering). This Worker needs
// almost none of it and needs one thing that file has never done: server-side
// web search. Reaching across the Pages/Worker bundle boundary for a relative
// import would couple two deploy units that ship separately, so the small
// duplication below is the cheaper of the two costs.
//
// The key never reaches a browser. Party generation runs inside the Durable
// Object; solo generation runs in this Worker's fetch handler. Neither path
// returns anything to the client but finished strings.

const API_URL = 'https://api.anthropic.com/v1/messages';

// Server-side web search. The _20260209 variant carries dynamic filtering and
// needs Opus 4.6+ / Sonnet 4.6+ — which is exactly why the classifier below
// runs on Haiku and never searches: Haiku 4.5 cannot use this tool at all.
export const WEB_SEARCH_TOOL = { type: 'web_search_20260209', name: 'web_search', max_uses: 6 };

// Latency lever. These calls are mechanical - list some names, check some
// names - and neither needs deep reasoning, so a lower effort trims real time
// off a pipeline whose whole problem is that it is slow.
//
// NOT set for the classifier. `output_config.effort` is model-gated and Haiku
// 4.5 rejects it outright with `400 This model does not support the effort
// parameter` - which is exactly what it did the first time this ran. The
// classifier is a 300-token call on the small model; there was nothing to
// gain there anyway.
//
// The retry below covers the same mistake being made again through the model
// env vars, which are configuration and can be pointed at anything.
const EFFORT = { generate: 'medium', verify: 'medium' };

const EFFORT_UNSUPPORTED = /does not support the effort parameter/i;

export class AnthropicError extends Error {}

/**
 * One `claude_usage` row per model call — the same table and shape the Pages
 * proxy writes, so the spend query in SETUP.md sees this app too.
 *
 * This is the only path in the Workshop a stranger can make spend money, which
 * is exactly why it should not be the one path that reports nothing. `email` is
 * null because there is no identity here by design; `endpoint` is what
 * distinguishes these rows.
 *
 * DELIBERATELY DUPLICATED rather than imported from
 * functions/api/_lib/claude-client.js. That file belongs to the Pages bundle
 * and this Worker ships on its own schedule; a relative import across that
 * boundary would couple two deploy units for six columns.
 *
 * Fail-open, and it must stay that way: metering that can break the call it
 * measures — an unmigrated environment, a D1 hiccup — would turn a reporting
 * gap into a broken game.
 */
export async function recordUsage(env, { endpoint, model, upstream }) {
  try {
    if (!env?.DB) return;
    let usage = null;
    let servedModel = model ?? null;
    try {
      const payload = JSON.parse(upstream?.text ?? '');
      usage = payload?.usage ?? null;
      servedModel = payload?.model ?? servedModel;
    } catch { /* an upstream error body is still a recorded attempt */ }
    await env.DB.prepare(
      `INSERT INTO claude_usage (email, endpoint, model, input_tokens, output_tokens, status)
       VALUES (?, ?, ?, ?, ?, ?)`
    ).bind(null, endpoint, servedModel,
      Number.isFinite(usage?.input_tokens) ? usage.input_tokens : null,
      Number.isFinite(usage?.output_tokens) ? usage.output_tokens : null,
      upstream?.status ?? null).run();
  } catch { /* see above — never the caller's problem */ }
}

/**
 * One Messages API call, with server-tool pause_turn handled.
 *
 * Web search runs as a server-side tool: results come back as content blocks in
 * the same response, and a long search can end a turn with stop_reason
 * "pause_turn" rather than "end_turn". That is not an error and not a refusal -
 * it means "ask me again with what you have so far". Not resuming it is the
 * classic way to get a half-finished list that parses fine and is simply short.
 */
export async function callClaude(env, { model, system, prompt, maxTokens, search, effort, endpoint }) {
  if (!env.ANTHROPIC_API_KEY) throw new AnthropicError('ANTHROPIC_API_KEY is not set on this Worker');

  const messages = [{ role: 'user', content: prompt }];
  const tools = search ? [WEB_SEARCH_TOOL] : undefined;
  let useEffort = Boolean(effort && EFFORT[effort]);

  // Three passes is enough for any search this small; the cap exists so a
  // pathological pause_turn loop cannot bill indefinitely.
  for (let attempt = 0; attempt < 3; attempt++) {
    const body = {
      model,
      max_tokens: maxTokens,
      system,
      messages,
      ...(tools ? { tools } : {}),
      ...(useEffort ? { output_config: { effort: EFFORT[effort] } } : {}),
    };

    const res = await fetch(API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': env.ANTHROPIC_API_KEY,
        'anthropic-version': '2023-06-01',
      },
      body: JSON.stringify(body),
    });

    const text = await res.text();

    // Recorded before any branch below, so a refusal, a 400 and a pause_turn
    // are all billed to somebody in the table. Every one of them cost money.
    await recordUsage(env, { endpoint: endpoint ?? 'pick3cut5', model, upstream: { status: res.status, text } });

    if (!res.ok) {
      let detail = text.slice(0, 300);
      try { detail = JSON.parse(text)?.error?.message ?? detail; } catch { /* raw body it is */ }

      // Effort is a latency optimisation, not a requirement. A model that
      // refuses it should still answer the question, so drop it and retry once
      // rather than failing a whole round over a tuning parameter.
      if (res.status === 400 && useEffort && EFFORT_UNSUPPORTED.test(detail)) {
        console.warn(`effort rejected by ${model}; retrying without it`);
        useEffort = false;
        continue;
      }

      throw new AnthropicError(`Anthropic ${res.status}: ${detail}`);
    }

    let payload;
    try { payload = JSON.parse(text); } catch {
      throw new AnthropicError('Anthropic returned a body that was not JSON');
    }

    // A refusal is an HTTP 200 with content that will not parse as a list. Say
    // so plainly rather than letting it surface as "malformed JSON".
    if (payload.stop_reason === 'refusal') {
      throw new AnthropicError('The model declined to answer for this category');
    }

    if (payload.stop_reason === 'pause_turn') {
      messages.push({ role: 'assistant', content: payload.content });
      continue;
    }

    return joinText(payload);
  }

  throw new AnthropicError('Web search did not settle after three passes');
}

// Server tools interleave their own result blocks into content. Only the text
// blocks are the model talking; everything else is search machinery.
function joinText(payload) {
  return (payload.content ?? [])
    .filter((b) => b?.type === 'text')
    .map((b) => b.text)
    .join('')
    .trim();
}

/**
 * Parse a JSON value out of a model response, one retry's worth of leniency
 * built in. The prompts all say "no markdown fences" and the models mostly
 * listen; this exists for the times they do not, so a stray ```json costs
 * nothing instead of costing a whole regeneration.
 */
export function parseJson(raw, expect) {
  const cleaned = raw.replace(/^\s*```(?:json)?\s*/i, '').replace(/\s*```\s*$/, '').trim();
  const open = expect === 'array' ? '[' : '{';
  const close = expect === 'array' ? ']' : '}';

  let candidate = cleaned;
  if (!candidate.startsWith(open)) {
    const start = candidate.indexOf(open);
    const end = candidate.lastIndexOf(close);
    if (start === -1 || end === -1 || end < start) return null;
    candidate = candidate.slice(start, end + 1);
  }

  try {
    const value = JSON.parse(candidate);
    if (expect === 'array' && !Array.isArray(value)) return null;
    if (expect === 'object' && (typeof value !== 'object' || value === null || Array.isArray(value))) return null;
    return value;
  } catch {
    return null;
  }
}
