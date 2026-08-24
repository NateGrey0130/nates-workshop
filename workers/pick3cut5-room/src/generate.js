// The three-step generation pipeline: classify, generate, verify.
//
// A bad list ruins the round, and the specific failure that motivated all of
// this is a knowledge-cutoff failure, not a prompting one - players served as
// "currently active" who retired years ago. No amount of prompt tightening
// fixes that; only web search does. So the shape here is: decide whether the
// category is checkable, generate wide, then check with a SEPARATE call.
//
// Separate is load-bearing. A model asked to generate and self-check in one
// pass rubber-stamps its own output - it has already decided these twelve are
// right, and asking it in the same breath whether they are right gets you
// twelve yeses. The verifier is given the list cold, with no memory of having
// written it.

import { callClaude, parseJson, AnthropicError } from './anthropic.js';
import { ITEMS_PER_ROUND } from './rules.js';

// Re-exported rather than redeclared: two constants named the same thing that
// could drift apart is the exact failure rules.js exists to prevent.
export { ITEMS_PER_ROUND } from './rules.js';
export class GenerationError extends Error {}

// Fold "Scump", "scump", and "Scump (Seth Abner)" onto one key so a replay
// cannot serve back a name it already used wearing different punctuation.
export function normalize(str) {
  return String(str)
    .toLowerCase()
    .replace(/\([^)]*\)/g, ' ')      // trailing parenthetical alias
    .replace(/[‘’]/g, "'") // smart quotes arrive from search results
    .replace(/[^a-z0-9' ]+/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

// Runs before any API call. A category that cannot be spent money on should
// not spend money finding that out.
export function validateCategory(raw) {
  if (typeof raw !== 'string') return { error: 'Enter a category.' };
  const category = raw.replace(/[\r\n\t]+/g, ' ').replace(/\s+/g, ' ').trim();
  if (!category) return { error: 'Enter a category.' };
  if (category.length > 60) return { error: 'Keep the category under 60 characters.' };
  if (!/[a-zA-Z]/.test(category)) return { error: 'That category needs some actual words.' };
  if (!/^[\w\s'&,.\-/()!?:+]+$/.test(category)) return { error: 'Letters, numbers and basic punctuation only.' };
  return { category };
}

/**
 * Step 1 - classify. One cheap fast call on the small model, no web search.
 *
 * This is the gate that keeps web search off the expensive path: search is the
 * priciest part of the pipeline and most categories ("worst pizza toppings")
 * have no fact to check. Running this on Haiku is not only a cost choice - the
 * current web search tool needs a 4.6-or-later model, so the classifier
 * physically cannot search even if something asked it to.
 */
export async function classify(env, category, endpoint) {
  const system = 'You classify party-game categories. Reply with a single JSON object and nothing else. '
    + 'No markdown fences, no preamble.';

  const prompt = `Category: "${category}"

Return exactly this JSON object:
{
  "verifiable": boolean,
  "time_sensitive": boolean,
  "viable": boolean,
  "reason": string
}

verifiable: true when membership is an objective, checkable fact - rosters, filmographies, discographies, records, release dates, championships, published lists. false when it is a matter of taste or opinion, like "best pizza toppings" or "worst movie tropes".

time_sensitive: true when the category contains or implies a currency constraint - words like current, active, this season, 2026, still playing, on a roster, in office, reigning. If in doubt, true.

viable: can this category yield at least 8 distinct items a room of people would recognise? false only when it is too narrow, too obscure, incoherent, or not really a category at all.

viable is INDEPENDENT of verifiable. A pure matter of taste is perfectly viable - this is a party game and arguing about opinions is the point. Never answer false to viable merely because a category is subjective, unrankable, or has no correct answer.

Worked examples:
- "worst pizza toppings" -> verifiable false, time_sensitive false, viable TRUE
- "current Premier League managers" -> verifiable true, time_sensitive true, viable true
- "Tarantino films" -> verifiable true, time_sensitive false, viable true
- "my cousin Dave's moods" -> viable false, nobody outside one family knows these

reason: one short sentence, shown to a player, ONLY when viable is false. Otherwise "".`;

  const raw = await callClaude(env, {
    model: env.P3C5_MODEL_CLASSIFY,
    endpoint,
    system,
    prompt,
    maxTokens: 300,
    search: false,
    // No effort setting: it is model-gated and the small model rejects it
    // outright. See the EFFORT note in anthropic.js.
  });

  const parsed = parseJson(raw, 'object');
  if (!parsed) throw new GenerationError('Could not read the category check. Try again.');

  return {
    verifiable: parsed.verifiable === true,
    time_sensitive: parsed.time_sensitive === true,
    viable: parsed.viable !== false,
    reason: typeof parsed.reason === 'string' ? parsed.reason.slice(0, 160) : '',
  };
}

/**
 * Step 2 - generate candidates.
 *
 * Asks for more than it needs. The overage absorbs verification failures and
 * exclusion-list drops without a retry loop, and a retry loop here is the
 * expensive thing: it is a second search-enabled call on the critical path
 * while eight people watch a spinner.
 */
export async function generateCandidates(env, category, klass, { want, exclude, endpoint }) {
  const search = klass.verifiable || klass.time_sensitive;

  const system = 'You generate item lists for a party game. Return ONLY a JSON array of strings. '
    + 'No markdown fences, no preamble, no numbering, no commentary, no ranking.';

  const excludeBlock = exclude.length
    ? `\n\nThese have already been used in this room and must NOT appear again:\n${exclude.map((e) => `- ${e}`).join('\n')}`
    : '';

  const currency = klass.time_sensitive
    ? '\n\nThis category has a currency constraint. Use web search to confirm present-day status before including anyone or anything. Do not rely on what you remember being true.'
    : '';

  const prompt = `Category: "${category}"

Return a JSON array of exactly ${want} strings.

What makes this list good:
- Every item genuinely belongs in the category. This matters more than anything else below.
- Mix obvious, undeniable entries with genuinely debatable middle-tier ones. Players get 3 keeps and 5 cuts, so the list only works if some cuts actually hurt. A list of twelve all-timers is a bad list; so is a list of twelve nobodies.
- Items are specific and recognisable to someone who knows this category.
- Use the most common name for each item. No explanatory parentheticals, no nicknames in quotes.

Do NOT order by quality, fame, or ranking. Deliberately scatter the strongest and weakest entries through the array.${currency}${excludeBlock}

Return only the JSON array.`;

  const raw = await callClaude(env, {
    model: env.P3C5_MODEL_GENERATE,
    endpoint,
    system,
    prompt,
    maxTokens: 4000,
    search,
    effort: 'generate',
  });

  const parsed = parseJson(raw, 'array');
  if (!parsed) return null;
  return parsed.filter((s) => typeof s === 'string' && s.trim()).map((s) => s.trim().slice(0, 80));
}

/**
 * Step 3 - verify. Skipped entirely when the category is a matter of taste,
 * because taste has no false positives: nobody's favourite pizza topping is
 * factually wrong.
 */
export async function verifyCandidates(env, category, candidates, endpoint) {
  const system = 'You fact-check candidate entries for a category. Return ONLY a JSON array of objects. '
    + 'No markdown fences, no preamble.';

  const prompt = `Category: "${category}"

Candidates:
${candidates.map((c, i) => `${i + 1}. ${c}`).join('\n')}

For each candidate, decide whether it genuinely belongs in this category right now. Use web search. Be specifically suspicious of:
- Status claims that decay: active, current, signed, in office, still running, reigning, on the roster. Someone who was true two years ago may not be true today.
- Attribution to the wrong person, team, studio, label, or year.
- Things that sound plausible and do not actually exist.

Assume nothing on this list is correct until you have checked it. It was written by a different model that could not verify its own work.

Return a JSON array with one object per candidate, in the same order:
[{"item": "<the candidate string, copied exactly>", "verdict": "pass" | "fail", "reason": "<one short line, only when the verdict is fail>"}]

Return only the JSON array.`;

  const raw = await callClaude(env, {
    model: env.P3C5_MODEL_VERIFY,
    endpoint,
    system,
    prompt,
    maxTokens: 4000,
    search: true,
    effort: 'verify',
  });

  const parsed = parseJson(raw, 'array');
  if (!parsed) return null;

  const byItem = new Map();
  for (const row of parsed) {
    if (!row || typeof row.item !== 'string') continue;
    byItem.set(normalize(row.item), {
      pass: row.verdict === 'pass',
      reason: typeof row.reason === 'string' ? row.reason.slice(0, 120) : '',
    });
  }
  return byItem;
}

/**
 * The whole pipeline, start to finish.
 *
 * `cache` is the room's per-category verification memory and is mutated in
 * place: a replay of the same category should not pay to re-check names it has
 * already checked. `exclude` is the room's used-items list for this category.
 *
 * `onProgress` gets a human-readable line for the loading screen. "Checking
 * these are current" is worth waiting through in a way that a spinner is not,
 * and this pipeline takes long enough that the difference matters.
 */
export async function runPipeline(env, category, { exclude = [], cache = new Map(), onProgress = () => {}, endpoint = 'pick3cut5', forceVerify = false } = {}) {
  // Step timings go to the log because this pipeline's cost is measured in
  // seconds of eight people staring at a spinner, and "it feels slow" is not
  // something you can tune against. `observability` is on for this.
  const t0 = Date.now();
  const timings = {};
  const lap = (step, from) => { timings[step] = Date.now() - from; return Date.now(); };

  onProgress('Sizing up the category');
  const klass = await classify(env, category, endpoint);
  let mark = lap('classify', t0);

  if (!klass.viable) {
    throw new GenerationError(klass.reason || 'That category will not fill eight items. Try another.');
  }

  const excludeSet = new Set(exclude.map(normalize));

  // Grow the ask with the exclusion list. After two replays you are excluding
  // 16 items and twelve candidates will not clear eight survivors.
  const want = Math.min(30, 12 + excludeSet.size);

  onProgress(klass.time_sensitive || forceVerify ? 'Looking up who actually qualifies' : 'Building the list');

  let candidates = await generateCandidates(env, category, klass, { want, exclude, endpoint });
  if (!candidates) {
    // One retry, then a clean error. Malformed JSON twice in a row is a real
    // problem, not a blip, and a third attempt just spends more money on it.
    candidates = await generateCandidates(env, category, klass, { want, exclude, endpoint });
    if (!candidates) throw new GenerationError('The list came back unreadable twice. Try a different category.');
  }
  mark = lap('generate', mark);

  // Hard-filter against the exclusion list in code. The prompt asks nicely and
  // models routinely ignore it, especially as the list grows - the prompt is a
  // hint and THIS is the guarantee. Also dedupes within the response itself,
  // which models do to themselves surprisingly often.
  const seen = new Set();
  let fresh = [];
  for (const item of candidates) {
    const key = normalize(item);
    if (!key || excludeSet.has(key) || seen.has(key)) continue;
    seen.add(key);
    fresh.push(item);
  }

  // Verification is gated on time_sensitive, NOT on verifiable.
  //
  // It used to run for anything checkable, and it cost 38 of the 70 seconds a
  // fact category took. The failure it was built for is the decaying one - a
  // player listed as active who retired two years ago - and that failure only
  // exists where a currency constraint does. "Tarantino films" was true when
  // the model learned it and is still true now; paying half a minute to
  // re-confirm it bought nothing.
  //
  // What is given up: the hallucinated-but-plausible entry in a static
  // category. Generation still searches the web for anything `verifiable`, so
  // that is grounded rather than unguarded - and the in-round flag is the
  // backstop for whatever slips through. See flagItem() in room.js.
  // forceVerify is the host's "double-check this list" toggle. The default gate
  // is time-sensitivity alone, because that is where the decaying-fact failure
  // lives; this is the escape hatch for a room that cares about a STATIC
  // category being right - "Tarantino films" served True Romance twice in
  // testing, and a table that does not know Tony Scott directed it has no way
  // to catch that. Opt-in, so the fast path stays the default.
  let survivors = fresh;
  if (klass.time_sensitive || forceVerify) {
    const unchecked = fresh.filter((item) => !cache.has(normalize(item)));

    if (unchecked.length) {
      onProgress('Checking these are current');
      let verdicts = await verifyCandidates(env, category, unchecked, endpoint);
      if (!verdicts) verdicts = await verifyCandidates(env, category, unchecked, endpoint);
      if (!verdicts) throw new GenerationError('The fact check came back unreadable. Try again.');

      for (const item of unchecked) {
        const key = normalize(item);
        // A candidate the verifier silently dropped is not a pass. Treat a
        // missing verdict as a fail: the overage is there to absorb exactly
        // this, and the alternative is shipping an unchecked name.
        cache.set(key, verdicts.get(key) ?? { pass: false, reason: 'not returned by the fact check' });
      }
    }

    survivors = fresh.filter((item) => cache.get(normalize(item))?.pass);
    mark = lap('verify', mark);
  }

  console.log('pick3cut5 pipeline', JSON.stringify({
    category,
    verifiable: klass.verifiable,
    time_sensitive: klass.time_sensitive,
    forceVerify,
    asked: want,
    returned: candidates.length,
    fresh: fresh.length,
    survived: survivors.length,
    ms: { ...timings, total: Date.now() - t0 },
  }));

  // TESTED 2026-08-24, AND THIS PATH IS HARDER TO REACH THAN IT LOOKS.
  //
  // "Beatles studio albums" is a finite set of thirteen. Two rounds in one room
  // produced SIXTEEN items rather than running dry: the second round padded
  // with Beatles '65, The Early Beatles and Hey Jude (US compilations), plus
  // Long Tall Sally and Beatles for Sale No. 2 (EPs). None is a studio album.
  //
  // So a generator asked for eight fresh items will almost always return
  // eight - inventing adjacent-but-wrong entries rather than admitting the
  // category is exhausted - and `survivors.length < 8` fires only when
  // VERIFICATION culls them, which is skipped for a category that is factual
  // but not time-sensitive. On a finite factual category the honest advice is
  // to tick "double-check this list"; the in-round swap and check are the
  // backstop when nobody does.
  if (survivors.length < ITEMS_PER_ROUND) {
    const err = new GenerationError(
      excludeSet.size
        ? `This category is running out - only ${survivors.length} new item${survivors.length === 1 ? '' : 's'} left. Try a new category.`
        : `Only ${survivors.length} of those held up to checking. Try a different category.`
    );
    err.exhausted = true;
    err.survivors = survivors.length;
    throw err;
  }

  // Shuffle ALL survivors, THEN split. Models put the most famous entry first
  // almost every time, and an automatic keep on item 1 flattens the whole
  // round - nobody argues about the obvious one.
  //
  // Shuffling before the split rather than after also matters now that the
  // tail is the replacement reserve: slicing first would make every reserve
  // item come from the bottom of whatever ordering the model produced despite
  // being told not to rank, so a flagged item would reliably be swapped for
  // something weaker.
  const pool = shuffle(survivors);

  return {
    items: pool.slice(0, ITEMS_PER_ROUND),
    // Spares for in-round replacement, already through the same filtering and
    // (where it ran) the same verification. Swapping from here is instant -
    // no API call while eight people wait.
    reserve: pool.slice(ITEMS_PER_ROUND),
    classification: klass,
  };
}

// Fisher-Yates on crypto randomness. sort(() => Math.random() - 0.5) is biased
// and the bias here would be visible: it barely moves the first element, which
// is the exact element that most needs moving.
export function shuffle(list) {
  const out = [...list];
  for (let i = out.length - 1; i > 0; i--) {
    const j = crypto.getRandomValues(new Uint32Array(1))[0] % (i + 1);
    [out[i], out[j]] = [out[j], out[i]];
  }
  return out;
}

export { AnthropicError };

/**
 * Check ONE item, on demand, because somebody at the table doubts it.
 *
 * MEASURED, and not what I expected. A full twelve-candidate verification is
 * ~57,000 input tokens / ~$0.19. A single-item check is ~20,000-27,000 input
 * tokens / ~$0.075 — because the search RESULTS dominate the context, and
 * searching for one thing still drags back twenty thousand tokens of pages.
 *
 * So per item this is roughly five times WORSE than batching, and the saving
 * comes entirely from not doing it. Two checks cost $0.15 against $0.19 for
 * verifying everything; a third would cost more than the whole list. That is
 * why the cap is two, and it is the real argument for this feature: on most
 * rounds nobody doubts anything and it costs nothing at all, where the
 * whole-list toggle costs $0.19 every single time it is ticked.
 *
 * It is also the better-aimed spend. The pipeline cannot tell that Tony Scott
 * directed True Romance; a room that knows films can, instantly and for free.
 * All this does is settle the cases where they suspect rather than know.
 */
export async function verifyOne(env, category, item, endpoint) {
  const system = 'You fact-check a single claim. Reply with one JSON object and nothing else. '
    + 'No markdown fences, no preamble.';

  const prompt = `Category: "${category}"
Claimed member: "${item}"

Does this genuinely belong in that category? Use web search to check rather than relying on memory.

Be specifically suspicious of:
- Status that decays: active, current, signed, in office, still running, reigning
- Attribution to the wrong person, team, studio, label, director or year
- Things that sound right and do not exist
- Near misses: someone who WROTE a film but did not direct it, a band member who
  joined later, an anthology one contributor is being credited for

Return exactly:
{"verdict": "pass" | "fail", "reason": "<one short line a player will read; required when the verdict is fail>"}`;

  const raw = await callClaude(env, {
    model: env.P3C5_MODEL_VERIFY,
    endpoint,
    system,
    prompt,
    maxTokens: 1500,
    search: true,
    effort: 'verify',
  });

  const parsed = parseJson(raw, 'object');
  // An unreadable answer is NOT a failure of the item. Saying "could not check"
  // and leaving the item alone is honest; swapping on a parse error would let a
  // flaky response quietly rewrite the round.
  if (!parsed) return null;
  return {
    pass: parsed.verdict === 'pass',
    reason: typeof parsed.reason === 'string' ? parsed.reason.slice(0, 160) : '',
  };
}
