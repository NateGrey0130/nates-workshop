// What every endpoint stands on and none of them is about: D1's hundred-bind
// ceiling, the Access token check and the Claude spend log behind it, and
// paging.
//
// Four sections lifted out of smoke.mjs whole on 2026-10-10. They were two
// runs there, not one - the bind sections sat some 3,000 lines above the
// other two - and they are together here because they are one subject. They
// now run at the position the bind sections held. No section reads state
// another one leaves, so the order between them and their old neighbours was
// never load-bearing.
//
// `paging` and the three bindings of `_lib/sql-chunk.js` are used here and
// nowhere else in the suite. The body moved verbatim, apart from the two
// `import()` paths, which are one directory deeper from here.

import { readFileSync, readdirSync } from 'node:fs';
import { join } from 'node:path';
import { paging } from '../../../../functions/api/character-creator/_lib/paging.js';
import { chunks, D1_MAX_BINDS, BIND_CHUNK } from '../../../../functions/api/character-creator/_lib/sql-chunk.js';
import { jsonWithEtag } from '../../../../functions/api/character-creator/_lib/etag.js';
import { requireMember } from '../../../../functions/api/character-creator/_lib/auth.js';
import { once } from '../../../../functions/api/character-creator/_lib/once.js';
import { loadCharacterClass } from '../../../../functions/api/character-creator/_lib/class-loader.js';
import { appDir, repoRoot, check, section, wantSection } from '../harness.mjs';

const SECTIONS = ['SQL bind chunking', 'No query binds an unbounded list', 'Access JWT verification',
  'The browser Claude proxy forwards only the fields it checked',
  'A person is limited to 100 Claude calls a day', 'Paging',
  'One revalidating answer, one member guard', 'A load made once per request',
  'A deleted character is read by nothing', 'A deleted campaign is read by nothing',
  'A transfer is refused before the database is read', 'Client error reporting'];

export async function run() {
  if (!SECTIONS.some(wantSection)) return;

// ---------- D1 binds 100 parameters per statement, and no more ----------
// Measured against the real binding, not assumed:
//   binds 100 -> ok, binds 101 -> D1_ERROR: too many SQL variables
//
// So any query building `IN (?,?,...)` from a list that grows with user data
// has to chunk. Four files already did, privately; the ones that did not are
// where it broke - `markConfirmed` runs AFTER the catalog write, so exceeding
// the limit there left 108 spells inserted, none marked confirmed, and a 500
// that read as though nothing had happened.
section('SQL bind chunking');
{
  const big = Array.from({ length: 313 }, (_, i) => i);

  check('the ceiling is recorded as the measured 100', D1_MAX_BINDS === 100);
  check('and the chunk size leaves room for a query\'s own binds',
    BIND_CHUNK < D1_MAX_BINDS);

  const parts = chunks(big);
  check('a long list is split', parts.length === Math.ceil(313 / BIND_CHUNK));
  check('no chunk can exceed the ceiling',
    parts.every((p) => p.length <= D1_MAX_BINDS));
  check('nothing is lost or duplicated',
    parts.flat().length === 313 && new Set(parts.flat()).size === 313);
  check('and order is preserved', parts.flat().every((v, i) => v === i));

  check('an empty list yields no chunks at all', chunks([]).length === 0);
  check('a short list yields exactly one', chunks([1, 2, 3]).length === 1);
  // A caller passing something silly must not produce a chunk over the ceiling.
  check('an oversized chunk size is clamped to the ceiling',
    chunks(big, 5000).every((p) => p.length <= D1_MAX_BINDS));
  check('a zero chunk size still makes progress rather than looping forever',
    chunks([1, 2, 3], 0).flat().length === 3);
}

// Every place that builds placeholders from a list must chunk. A new one added
// without chunking is the same bug again, and it only shows up once someone's
// data gets big - a level-fifteen caster, a long session note, a full import.
section('No query binds an unbounded list');
{
  const files = [
    '_lib/power-picks.js', '_lib/skill-picks.js',
    '_lib/mentions.js', '_lib/skill-bonuses.js', 'campaigns/[id]/npcs/sweep.js',
  ];
  for (const f of files) {
    const src = readFileSync(join(repoRoot, 'functions', 'api', 'character-creator', f), 'utf8');
    const usesHelper = /sql-chunk\.js/.test(src);
    check(f + ' imports the chunking helper', usesHelper);
    // The giveaway shape: placeholders built straight from the caller's list
    // rather than from a chunk of it.
    const unbounded = /(?:names|ids)\.map\(\(\) => '\?'\)/.test(src);
    check(f + ' builds no placeholder list from an unchunked array', !unbounded,
      unbounded ? 'found names.map / ids.map building placeholders' : '');
  }
}

// ---------- 1c5. Access JWT verification and Claude spend logging ----------
// The audit's F4 and F3. The verifier is a pure function of (token, keys,
// options), which is what lets this section sign real tokens with WebCrypto
// and prove every refusal path — no network, no Access team. The wiring is
// pinned as source, because the load-bearing properties (pass-through when
// unconfigured; metering that cannot break the call it measures) are exactly
// the kind that vanish silently in a refactor.
section('Access JWT verification');
{
  const { verifyAccessJwt } = await import('../../../../functions/api/_lib/access-jwt.js');
  const b64u = (buf) => Buffer.from(buf).toString('base64url');
  const enc = (obj) => b64u(JSON.stringify(obj));
  const { publicKey, privateKey } = await crypto.subtle.generateKey(
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256', modulusLength: 2048,
      publicExponent: new Uint8Array([1, 0, 1]) },
    true, ['sign', 'verify']);
  const jwk = { ...(await crypto.subtle.exportKey('jwk', publicKey)), kid: 'test-key', use: 'sig' };
  const now = Math.floor(Date.now() / 1000);
  const sign = async (payload, header = { alg: 'RS256', kid: 'test-key' }) => {
    const input = enc(header) + '.' + enc(payload);
    const sig = await crypto.subtle.sign('RSASSA-PKCS1-v1_5', privateKey,
      new TextEncoder().encode(input));
    return input + '.' + b64u(sig);
  };
  const claims = { aud: ['site-aud'], email: 'nate@example.com', exp: now + 300, iat: now };
  const good = await sign(claims);

  const ok = await verifyAccessJwt(good, [jwk], { aud: 'site-aud' });
  check('a valid token verifies and yields its email',
    ok.ok === true && ok.email === 'nate@example.com', JSON.stringify(ok));
  check('an expired token is refused',
    !(await verifyAccessJwt(await sign({ ...claims, exp: now - 3600 }), [jwk], { aud: 'site-aud' })).ok);
  check('the wrong audience is refused',
    !(await verifyAccessJwt(good, [jwk], { aud: 'some-other-app' })).ok);
  check('a tampered payload fails the signature, not the parse', (await verifyAccessJwt(
    good.replace(/\.[^.]+\./, '.' + enc({ ...claims, email: 'gm@example.com' }) + '.'),
    [jwk], { aud: 'site-aud' })).reason === 'signature does not verify');
  check('alg none dies before any key is consulted', (await verifyAccessJwt(
    enc({ alg: 'none', kid: 'test-key' }) + '.' + enc(claims) + '.',
    [jwk], { aud: 'site-aud' })).reason.startsWith('unsupported algorithm'));
  check('a token signed by a rotated-away key is refused',
    !(await verifyAccessJwt(await sign(claims, { alg: 'RS256', kid: 'rotated-away' }), [jwk], { aud: 'site-aud' })).ok);
  check('a token with no email claim is refused',
    (await verifyAccessJwt(await sign({ ...claims, email: undefined }), [jwk], { aud: 'site-aud' })).reason === 'no email claim');
  check('every refusal carries a readable reason', await (async () => {
    const bad = [
      await verifyAccessJwt('not-a-jwt', [jwk], { aud: 'site-aud' }),
      await verifyAccessJwt(good, [], { aud: 'site-aud' }),
      await verifyAccessJwt(good, [jwk], { aud: 'other' }),
    ];
    return bad.every((r) => r.ok === false && typeof r.reason === 'string' && r.reason.trim());
  })());

  const fnDir = join(appDir, '..', '..', 'functions', 'api');
  const mw = readFileSync(join(fnDir, '_middleware.js'), 'utf8');
  check('the middleware passes through when unconfigured — the original posture',
    /if \(!domain \|\| !aud\) return next\(\)/.test(mw));
  check('and requires the token identity to match the header everything reads',
    /Cf-Access-Authenticated-User-Email/.test(mw));
  // The arming vars live in wrangler.jsonc, so pages dev reads them too — and
  // local dev has no Access to mint a token. Without the exemption, arming
  // production bricks every local run, including this suite's sibling.
  check('and exempts localhost, where no Access exists to mint a token',
    /localhost/.test(mw) && /127\.0\.0\.1/.test(mw));
  // Armed is a statement the repo makes, so pin it: both vars present in
  // wrangler.jsonc, or the middleware silently returns to header-trust and
  // nothing says so.
  const wranglerCfg = readFileSync(join(appDir, '..', '..', 'wrangler.jsonc'), 'utf8');
  check('wrangler.jsonc arms the middleware with both variables',
    /"ACCESS_TEAM_DOMAIN":\s*"[^"]+\.cloudflareaccess\.com"/.test(wranglerCfg)
    && /"ACCESS_AUD":\s*"[0-9a-f]{64}"/.test(wranglerCfg));

  const client = readFileSync(join(fnDir, '_lib', 'claude-client.js'), 'utf8');
  check('usage recording is fail-open, so metering cannot break the call',
    /export async function recordUsage/.test(client)
    && /never the caller's problem/.test(client));
  const proxy = readFileSync(join(fnDir, 'claude.js'), 'utf8');
  check('the proxy records who spent the key',
    /recordUsage\(/.test(proxy) && /getAccessEmail\(request\)/.test(proxy));
  const askSrc = readFileSync(join(fnDir, 'character-creator', 'campaigns', '[id]', 'ask.js'), 'utf8');
  check('and so does the campaign Ask', /recordUsage\(/.test(askSrc));

  // What a call COST, not only its tokens (INGESTION-AUDIT F35, migration 077).
  // Run against a fake D1 rather than read as text: the row is the contract.
  {
    const { recordUsage } = await import('../../../../functions/api/_lib/claude-client.js');
    const rows = [];
    const env = { DB: { prepare: (sql) => ({ bind: (...args) => ({ run: async () => rows.push({ sql, args }) }) }) } };
    const reply = (usage) => ({ status: 200, text: JSON.stringify({ model: 'm', usage }) });
    await recordUsage(env, { email: 'a@b', endpoint: 'proxy', model: 'm',
      upstream: reply({ input_tokens: 100, output_tokens: 7, cache_creation_input_tokens: 900, cache_read_input_tokens: 4000 }) });
    await recordUsage(env, { email: 'a@b', endpoint: 'proxy', model: 'm',
      upstream: reply({ input_tokens: 100, output_tokens: 7 }) });
    const [cached, plain] = rows.map((r) => r.args);
    check('a cached call records its total input and the split beside it',
      /cache_write_tokens, cache_read_tokens/.test(rows[0]?.sql || '')
        && cached?.[3] === 5000 && cached?.[6] === 900 && cached?.[7] === 4000);
    check('and a call with no cache records NULL for both, not zero',
      plain?.[3] === 100 && plain?.[6] === null && plain?.[7] === null);
    const extractor = readFileSync(join(repoRoot, 'scripts', 'extract-class.mjs'), 'utf8');
    check('the extractor writes the same two columns',
      /cache_write_tokens, cache_read_tokens\) `/.test(extractor));
  }

  // Every remaining Claude call. Extraction sends a whole PDF page and is the
  // most expensive call in the repo; it was also the only one with no number
  // attached, which made "what did this book cost" unanswerable while the
  // table to answer it had existed since migration 038.
  //
  // Pinned by counting callAnthropic against recordUsage across functions/,
  // rather than by naming today's files: a new endpoint that calls the model
  // and forgets to meter it is exactly the regression this is for, and a list
  // of filenames would not see it.
  const claudeCalls = [];
  const walkFns = (dir) => {
    for (const e of readdirSync(dir, { withFileTypes: true })) {
      const full = join(dir, e.name);
      if (e.isDirectory()) { walkFns(full); continue; }
      if (!e.name.endsWith('.js')) continue;
      const src = readFileSync(full, 'utf8');
      if (/\bawait callAnthropic\(/.test(src)) {
        claudeCalls.push({ file: full.slice(fnDir.length + 1), metered: /\brecordUsage\(/.test(src) });
      }
    }
  };
  walkFns(fnDir);
  // The floor was five while the importer contributed its own routes. Those
  // are gone and extraction runs from scripts/ now, so functions/ holds three
  // callers: the proxy, campaign-ask and the NPC sweep. The floor is a guard
  // against the sweep silently matching NOTHING, not a target - if it ever
  // reads zero the check has stopped checking.
  check('every file in functions/ that calls the model also meters it',
    claudeCalls.length >= 3 && claudeCalls.every((c) => c.metered),
    claudeCalls.filter((c) => !c.metered).map((c) => c.file).join(', ') || `${claudeCalls.length} found`);

  // The labels are the whole point of the table - an endpoint column full of
  // `import` tells you nothing about what the tokens went to.
  //
  // EXTRACTION LEFT functions/ WITH THE IN-APP IMPORTER. It runs from
  // scripts/extract-class.mjs now, so these checks FOLLOW it rather than
  // being deleted with the routes: what F7 shipped is that extraction is
  // metered and says what it extracted, and that is still worth pinning.
  const extractor = readFileSync(join(repoRoot, 'scripts', 'extract-class.mjs'), 'utf8');
  check('the class extractor labels its spend',
    /'cc-extract-class'/.test(extractor));

  // Metered BEFORE the reply is parsed. A truncated or refused extraction has
  // already spent the input tokens for a whole page, and a run that cost money
  // and produced nothing is the run most worth having a number for. The INSERT
  // is what is positioned, not the first mention of the table: that is a
  // comment on line 10, so an indexOf on the bare word was always below the
  // die() and never read the code.
  const meterBeforeParse = (src) => {
    const at = src.indexOf('INSERT INTO claude_usage');
    const dieAt = src.indexOf('if (!payload) die(');
    return at !== -1 && dieAt !== -1 && at < dieAt;
  };
  check('a failed extraction is still recorded, because the tokens were still spent',
    meterBeforeParse(extractor),
    'the claude_usage INSERT in scripts/extract-class.mjs is missing or sits below the non-JSON die()');

  // Both places used to say the admin importers were deliberately unlogged,
  // and both now explain that they no longer are. So this pins the CURRENT
  // claim rather than the absence of the old one — a check that greps for the
  // stale phrase fails on the correction that quotes it, which is a trap this
  // repo has walked into before.
  const setupSrc = readFileSync(join(appDir, '..', '..', 'SETUP.md'), 'utf8');
  check('SETUP.md states that every Claude call in functions/ is metered',
    /Every Claude call in `functions\/` writes one row to\s*\r?\n?`claude_usage`/.test(setupSrc));
  check('and names the endpoints it can be read by',
    /cc-extract-class/.test(setupSrc) && /cc-npc-sweep/.test(setupSrc));
}

// ---------- The browser proxy forwards only the fields it checked ----------
// functions/api/claude.js used to forward `{ ...body }`, so a browser could put
// `tools`, `thinking` or anything else on the shared key unchecked. The route
// is driven here with a stubbed fetch, and the body that would have gone to
// Anthropic is what is read. The server callers build their own requests and
// send `thinking` on purpose; callAnthropic must keep passing it.
section('The browser Claude proxy forwards only the fields it checked');
{
  const { onRequestPost } = await import('../../../../functions/api/claude.js');
  const { callAnthropic } = await import('../../../../functions/api/_lib/claude-client.js');
  const realFetch = globalThis.fetch;
  let sent;
  globalThis.fetch = async (_url, init) => {
    sent = JSON.parse(init.body);
    return new Response('{"content":[]}', { status: 200 });
  };
  const env = { ANTHROPIC_API_KEY: 'test-key' };
  const post = async (body) => {
    sent = undefined;
    const res = await onRequestPost({ env, request: new Request('http://local/api/claude', {
      method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) }) });
    return { status: res.status, error: res.status === 400 ? (await res.json()).error : null };
  };
  const base = { model: 'claude-sonnet-5', max_tokens: 100, system: 's',
    messages: [{ role: 'user', content: 'hi' }] };
  try {
    // The shape apps/city-creator/city.js sends.
    const city = { ...base, output_config: { effort: 'low',
      format: { type: 'json_schema', schema: { type: 'object' } } } };
    const ok = await post(city);
    check('a city-creator-shaped body is forwarded with exactly its own keys',
      ok.status === 200 && sent
        && JSON.stringify(Object.keys(sent).sort()) === JSON.stringify(Object.keys(city).sort())
        && JSON.stringify(sent.output_config) === JSON.stringify(city.output_config),
      `status ${ok.status}, sent ${sent ? Object.keys(sent).join(',') : 'nothing'}`);

    for (const [key, value] of [['tools', [{ name: 't', input_schema: { type: 'object' } }]],
      ['thinking', { type: 'enabled', budget_tokens: 9000 }], ['metadata', { user_id: 'x' }]]) {
      const r = await post({ ...base, [key]: value });
      check(`\`${key}\` is refused 400 by name, and nothing is sent`,
        r.status === 400 && sent === undefined && String(r.error).includes(key),
        `status ${r.status}, error ${r.error}, sent ${sent ? 'yes' : 'no'}`);
    }

    for (const [label, oc] of [
      ['an unknown effort', { effort: 'max' }],
      ['an unknown key inside it', { effort: 'low', task_budget: 5 }],
      ['a format that is not json_schema', { format: { type: 'text' } }],
      ['a json_schema format with no schema object', { format: { type: 'json_schema', schema: 'x' } }],
      ['a non-object', 'low']]) {
      const r = await post({ ...base, output_config: oc });
      check(`output_config with ${label} is refused 400`,
        r.status === 400 && sent === undefined && /output_config/.test(String(r.error)),
        `status ${r.status}, error ${r.error}`);
    }

    sent = undefined;
    await callAnthropic({ ...base, thinking: { type: 'disabled' } }, env);
    check('a server-side callAnthropic call still sends its `thinking`',
      sent?.thinking?.type === 'disabled', JSON.stringify(sent?.thinking));
  } finally {
    globalThis.fetch = realFetch;
  }
}

// ---------- 100 Claude calls per person in any 24 hours ----------
// Nate, 2026-10-12: calls, per person, rolling, every status counted; Nate
// exempt; fail-open when the count fails. Run against `claude_usage` as
// db/schema.sql creates it, in node:sqlite, so the window is SQLite's own
// datetime() arithmetic and not a stand-in's idea of it.
section('A person is limited to 100 Claude calls a day');
{
  const { refuseOverCallLimit, CALL_LIMIT } = await import('../../../../functions/api/_lib/claude-client.js');
  const { DatabaseSync } = await import('node:sqlite');
  const schema = readFileSync(join(repoRoot, 'db', 'schema.sql'), 'utf8');
  const create = schema.match(/CREATE TABLE IF NOT EXISTS claude_usage \([\s\S]*?\n\);/)?.[0];
  check('db/schema.sql still creates claude_usage where this section reads it', !!create);
  const fresh = () => {
    const sqlite = new DatabaseSync(':memory:');
    sqlite.exec(create || '');
    const DB = { prepare: (sql) => {
      const st = sqlite.prepare(sql);
      return { bind: (...args) => ({ first: async () => st.get(...args) ?? null }) };
    } };
    // `ago` is an SQLite modifier such as '-5 minutes'.
    const add = (email, count, ago = (i) => `-${i} minutes`) => {
      const ins = sqlite.prepare(`INSERT INTO claude_usage (email, endpoint, status, created_at)
                                  VALUES (?, 'proxy', 200, datetime('now', ?))`);
      for (let i = 1; i <= count; i++) ins.run(email, ago(i));
    };
    return { sqlite, DB, add };
  };
  const who = 'friend@example.com';
  const limit = (env, email = who) => refuseOverCallLimit(env, email);
  const hm = (ms) => new Date(ms).toISOString().replace('T', ' ').slice(0, 16);
  const utc = (s) => Date.parse(s.replace(' ', 'T') + 'Z');

  check('the limit is 100', CALL_LIMIT === 100, String(CALL_LIMIT));

  {
    const { DB, add } = fresh();
    add(who, 99);
    add('someone-else@example.com', 150);
    check('99 calls in the last day: the 100th is allowed, and nobody else\'s calls count',
      (await limit({ DB })) === null);
  }

  {
    const { sqlite, DB, add } = fresh();
    add(who, 100);
    const oldest = sqlite.prepare('SELECT min(created_at) AS t FROM claude_usage').get().t;
    const freesAt = utc(oldest) + 24 * 3600 * 1000;
    const res = await limit({ DB });
    const body = res ? await res.json() : {};
    const retry = Number(res?.headers.get('Retry-After'));
    check('100 calls: the next is refused with a 429',
      res?.status === 429, String(res?.status));
    check('saying in { error } when the oldest call ages out, which is when the next frees up',
      typeof body.error === 'string' && body.error.includes(hm(freesAt) + ' UTC'), body.error);
    check('with Retry-After in seconds to that same time',
      Math.abs(retry - (freesAt - Date.now()) / 1000) < 10, `${retry} vs ${Math.round((freesAt - Date.now()) / 1000)}`);
  }

  {
    const { sqlite, DB, add } = fresh();
    add(who, 105);
    // Five past the limit (a burst the in-flight rows let through): the call
    // that brings it back under is the SIXTH oldest's, not the oldest's.
    const sixth = sqlite.prepare('SELECT created_at AS t FROM claude_usage ORDER BY created_at, id LIMIT 1 OFFSET 5').get().t;
    const body = await (await limit({ DB }))?.json();
    check('past the limit, the time given is when the count falls back under it',
      !!body?.error?.includes(hm(utc(sixth) + 24 * 3600 * 1000) + ' UTC'), body?.error);
  }

  {
    const { DB, add } = fresh();
    add(who, 99);
    add(who, 50, (i) => `-${24 * 60 + i} minutes`);
    check('calls older than 24 hours are not counted', (await limit({ DB })) === null);
  }

  {
    const { DB, add } = fresh();
    add(who, 300);
    add(null, 300);   // production holds rows with no email, from local runs and the Worker
    check('the admin email is never refused, in any case',
      (await limit({ DB, ADMIN_EMAIL: 'Friend@Example.com' })) === null);
    check('and a call with no email (local dev) is never refused',
      (await limit({ DB }, null)) === null && (await limit({ DB }, '')) === null);
    const throwing = { prepare: () => { throw new Error('no such table: claude_usage'); } };
    check('a count that throws lets the call through (fail-open)',
      (await limit({ DB: throwing })) === null);
    check('and so does an environment with no DB binding', (await limit({})) === null);
  }

  // Every file that calls the model asks the limit FIRST. Counted across
  // functions/ the same way the metering check above is, so a new caller that
  // forgets is caught without this list naming it.
  const unasked = [];
  let callers = 0;
  const walk = (dir) => {
    for (const e of readdirSync(dir, { withFileTypes: true })) {
      const full = join(dir, e.name);
      if (e.isDirectory()) { walk(full); continue; }
      if (!e.name.endsWith('.js')) continue;
      const src = readFileSync(full, 'utf8');
      const call = src.search(/\bawait callAnthropic\(/);
      if (call === -1) continue;
      callers++;
      const ask = src.search(/\bawait refuseOverCallLimit\(/);
      if (ask === -1 || ask > call) unasked.push(full.slice(fnDir.length + 1));
    }
  };
  const fnDir = join(appDir, '..', '..', 'functions', 'api');
  walk(fnDir);
  check('every file in functions/ that calls the model asks the limit before it does',
    callers >= 4 && unasked.length === 0, unasked.join(', ') || `${callers} found`);
}

// ---------- 1d. Paging ----------
// A stray query string must not turn a list endpoint into a 400, so anything
// nonsensical falls back to the default rather than erroring.
section('Paging');
const pageOf = (qs) => paging(new Request('https://x/list' + qs));
check('defaults with no parameters', (() => {
  const p = pageOf('');
  return p.limit === 200 && p.offset === 0;
})());
check('honours a sensible limit and offset', (() => {
  const p = pageOf('?limit=50&offset=100');
  return p.limit === 50 && p.offset === 100;
})());
check('clamps an oversized limit to the maximum', pageOf('?limit=99999').limit === 500);
check('a negative or zero limit falls back to the default',
  pageOf('?limit=-1').limit === 200 && pageOf('?limit=0').limit === 200);
check('a non-numeric limit falls back to the default', pageOf('?limit=abc').limit === 200);
check('a negative offset floors at zero', pageOf('?offset=-5').offset === 0);

// ---------- One revalidating answer, one member guard ----------
// Three things every route did for itself until 2026-10-10. Four catalog
// routes ended in the same eight lines of body-hash ETag; seven member-only
// GETs each re-tested membership and re-typed the refusal; two character
// routes re-typed requireCharacter. Run here, then held as source so the next
// route reaches for the helper.
section('One revalidating answer, one member guard');
{
  const ask = (tag) => new Request('https://x/catalogs', tag ? { headers: { 'If-None-Match': tag } } : {});
  const first = await jsonWithEtag(ask(), '{"gear":[]}', 'catalogs');
  const tag = first.headers.get('ETag');
  check('a first answer carries the body, a weak tag and store-but-ask',
    first.status === 200 && await first.clone().text() === '{"gear":[]}'
    && /^W\/"catalogs-[0-9a-f]{16}"$/.test(tag) && first.headers.get('Cache-Control') === 'private, no-cache'
    && first.headers.get('Content-Type') === 'application/json', tag);
  // The tag is the one these routes produced before the helper, byte for byte,
  // so a browser holding one from last week still revalidates against it.
  const old = await (async (body) => {
    const digest = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(body));
    return `W/"catalogs-${[...new Uint8Array(digest, 0, 8)].map((b) => b.toString(16).padStart(2, '0')).join('')}"`;
  })('{"gear":[]}');
  check('and the tag is the one the routes wrote out by hand', tag === old, `${tag} vs ${old}`);
  const again = await jsonWithEtag(ask(tag), '{"gear":[]}', 'catalogs');
  check('the same body asked for again is an empty 304 with the same tag',
    again.status === 304 && await again.text() === '' && again.headers.get('ETag') === tag);
  const changed = await jsonWithEtag(ask(tag), '{"gear":[1]}', 'catalogs');
  check('a changed body is sent whole', changed.status === 200 && changed.headers.get('ETag') !== tag);
  const other = await jsonWithEtag(ask(tag), '{"gear":[]}', 'codex-gear');
  check('and the same bytes under another label do not 304 into each other',
    other.status === 200 && other.headers.get('ETag') !== tag);

  // requireMember against a stand-in database: who is asking decides.
  const db = (gm, members) => ({ prepare: (sql) => ({ bind: (...b) => ({ first: async () => (
    /FROM campaigns/.test(sql) ? (b[0] === 7 ? { id: 7, gm_email: gm } : null)
      : (members.includes(b[1]) ? { n: 1 } : null)) }) }) });
  const as = (email) => new Request('https://x/', email
    ? { headers: { 'Cf-Access-Authenticated-User-Email': email } } : {});
  const env = { DB: db('gm@x', ['player@x']) };
  const who = async (email, id = 7) => {
    const g = await requireMember(as(email), env, id);
    return g.res ? g.res.status : 'in';
  };
  check('the G.M. and a player with a character are let in',
    await who('gm@x') === 'in' && await who('player@x') === 'in');
  check('a stranger is refused, a missing campaign is not found, and nobody is unauthorised',
    await who('stranger@x') === 403 && await who('gm@x', 8) === 404 && await who(null) === 401,
    JSON.stringify([await who('stranger@x'), await who('gm@x', 8), await who(null)]));
  const refusal = await (await requireMember(as('stranger@x'), env, 7)).res.json();
  check('with the sentence the seven handlers each used to type',
    refusal.error === 'Only the GM or a player with a character in this campaign can do that', refusal.error);

  const fnRoot = join(repoRoot, 'functions', 'api', 'character-creator');
  const walk = (dir) => readdirSync(dir, { withFileTypes: true }).flatMap((e) =>
    (e.isDirectory() ? walk(join(dir, e.name)) : e.name.endsWith('.js') ? [join(dir, e.name)] : []));
  const routes = walk(fnRoot).map((f) => ({ f: f.slice(fnRoot.length + 1).replace(/\\/g, '/'), src: readFileSync(f, 'utf8') }));
  check('the routes are found', routes.length > 60, String(routes.length));
  const ownHash = routes.filter((r) => r.f !== '_lib/etag.js' && /crypto\.subtle\.digest/.test(r.src) && /ETag/.test(r.src));
  check('no route hashes its own body into an ETag', ownHash.length === 0, ownHash.map((r) => r.f).join(', '));
  const usesHelper = routes.filter((r) => r.f !== '_lib/etag.js' && /jsonWithEtag\(request, body, /.test(r.src))
    .map((r) => r.f).sort();
  check('four routes answer through the helper',
    usesHelper.join() === 'catalogs.js,catalogs/traits.js,codex.js,items.js', usesHelper.join());
  const retyped = routes.filter((r) => r.f !== '_lib/auth.js'
    && (r.src.match(/Only the GM or a player with a character in this campaign can do that/g) || []).length
    && /write: false \}\);\s+if \(guard\.res\) return guard\.res;\s+(?:\/\/[^\n]*\s+)*if \(!guard\.access\.isMember\)/.test(r.src));
  check('no read re-tests membership after asking for a read guard', retyped.length === 0, retyped.map((r) => r.f).join(', '));
  const ownGuard = routes.filter((r) => r.f.startsWith('characters/[id]/') && /characterAccess\(/.test(r.src)).map((r) => r.f);
  // stash.js reads the character row itself and calls isHiddenNpc, which
  // _lib/auth.js names as one of three deliberate exceptions.
  check('and the item and vessel routes go through requireCharacter',
    ownGuard.join() === 'characters/[id]/items/[itemId]/stash.js', ownGuard.join());
}

// ---------- A load made once per request ----------
// Rolling several NPCs is createCharacter called in a loop, and each call read
// the campaign, both class rows, the race-and-occupation verdict and every
// skill's category again. A roster read the class of every second-form holder
// again. Counted here against a stand-in database that answers the class
// query from a fixture and counts how often it was asked.
section('A load made once per request');
{
  let n = 0;
  const once1 = await once(null, 'k', async () => ++n);
  const once2 = await once(null, 'k', async () => ++n);
  check('with no cache every call loads for itself', once1 === 1 && once2 === 2);
  const loads = new Map();
  const a = once(loads, 'k', async () => ++n);
  const b = once(loads, 'k', async () => ++n);
  check('with one, two askers share a single load, even before it answers',
    a === b && await a === 3 && await b === 3 && n === 3);
  check('and a different key is a different load', await once(loads, 'other', async () => ++n) === 4);

  const markdown = readFileSync(join(appDir, 'test', 'fixtures', 'cyber-knight.md'), 'utf8');
  const asked = [];
  const env = { DB: { prepare: (sql) => ({ bind: (...binds) => ({
    first: async () => { asked.push(sql); return /FROM imported_classes WHERE class_id = \?/.test(sql)
      ? { class_id: binds[0], status: 'published', markdown } : null; },
    all: async () => { asked.push(sql); return { results: [] }; },
  }) }) } };
  const sheet = (id) => ({ id, class_id: 'cyber-knight', class_variant: null, skills: [] });
  const alone1 = await loadCharacterClass(env, 'https://x/', sheet(1));
  const alone2 = await loadCharacterClass(env, 'https://x/', sheet(2));
  const classReads = () => asked.filter((q) => /FROM imported_classes/.test(q)).length;
  check('two characters of one class read it twice when nothing is shared',
    classReads() === 2 && alone1?.name === 'Cyber-Knight' && alone2?.name === 'Cyber-Knight', String(classReads()));
  asked.length = 0;
  const shared = new Map();
  const one = await loadCharacterClass(env, 'https://x/', sheet(1), { loads: shared });
  const two = await loadCharacterClass(env, 'https://x/', sheet(2), { loads: shared });
  check('and once when the request shares its loads', classReads() === 1, String(classReads()));
  // The row is shared; what each caller composes from it is its own.
  check('each still gets its own composed class, equal and not the same object',
    one !== two && JSON.stringify(one) === JSON.stringify(two) && JSON.stringify(one) === JSON.stringify(alone1));

  const fnRoot = join(repoRoot, 'functions', 'api', 'character-creator');
  const gen = readFileSync(join(fnRoot, 'campaigns', '[id]', 'npcs', 'generate.js'), 'utf8');
  const chars = readFileSync(join(fnRoot, 'characters.js'), 'utf8');
  check('the NPC roll makes one cache outside its loop and hands it to every create',
    /const loads = new Map\(\);\s+for \(let i = 0; i < count; i\+\+\) \{/.test(gen)
    && /\{ kind: 'npc', bankPowers: bank, loads \}/.test(gen));
  check('createCharacter reads the campaign, the class, the verdict and the categories through it',
    /once\(loads, 'campaign:' \+ b\.campaign_id/.test(chars) && /\}, \{ loads \}\);/.test(chars)
    && /occRestrictionOnce\(env, b\.class_id, occId, loads\)/.test(chars)
    && /once\(loads, 'skill-categories', \(\) => loadSkillCategories\(env\)\)/.test(chars));
  check('and the roster shares one across its second-form holders',
    /const loads = new Map\(\);\s+const held = await selectInChunks/.test(chars)
    && /loadCharacterClass\(env, request\.url, row, \{ loads \}\)/.test(chars));
  // An isolate outlives a request: a cache at module level would serve a class
  // edited since.
  const libOnce = readFileSync(join(fnRoot, '_lib', 'once.js'), 'utf8');
  check('the cache is the caller\'s, never the module\'s',
    !/^(?:const|let|var)\s+\w+\s*=\s*new (?:Map|WeakMap)/m.test(libOnce));
}

// ---------- A deleted character is read by nothing ----------
// Since migration 091 the character DELETE sets `characters.deleted_at` and
// leaves the row, so a mistaken delete can be put back. That is only a delete
// if every read skips the row, and there is no helper that does it: each
// query says `deleted_at IS NULL` itself, as `imported_classes` is read. So
// every SQL string under functions/ that reads FROM or JOINs `characters` has
// to say `deleted_at`, or be on the short list below with its reason. A new
// read that forgets is the bug this section exists for: its deleted character
// would come back in a list, a count or a membership.
//
// Read as STRING LITERALS, not lines: a FROM whose table is on the next line
// is one string, and a comment naming the table is no string at all.
//
// The reader, the walk and the exceptions are shared with the campaign
// section below, which runs the same sweep over `campaigns`.
let literalsOf, fnLiterals, CHARACTER_EXCEPTIONS;
section('A deleted character is read by nothing');
{
  // Every string and template literal in a JS file, comments skipped. A
  // template's `${...}` is read through, nested strings and all, so its text
  // is the whole literal as written.
  literalsOf = (src) => {
    const out = [];
    const regexAhead = (i) => {
      let j = i - 1;
      while (j >= 0 && /\s/.test(src[j])) j--;
      return j < 0 || /[(,=:[!&|?{};]/.test(src[j]) || /\breturn$/.test(src.slice(Math.max(0, j - 6), j + 1));
    };
    const skipRegex = (i) => {
      let k = i + 1, inClass = false;
      while (k < src.length && src[k] !== '\n') {
        if (src[k] === '\\') { k += 2; continue; }
        if (src[k] === '[') inClass = true;
        else if (src[k] === ']') inClass = false;
        else if (src[k] === '/' && !inClass) return k + 1;
        k++;
      }
      return k;
    };
    const skipString = (i) => {
      const q = src[i];
      let k = i + 1;
      while (k < src.length && src[k] !== q) k += src[k] === '\\' ? 2 : 1;
      return k + 1;
    };
    let skipTemplate;
    const skipCode = (i) => {
      let depth = 0, k = i;
      while (k < src.length) {
        const c = src[k];
        if (c === '/' && src[k + 1] === '/') { const e = src.indexOf('\n', k); k = e < 0 ? src.length : e; continue; }
        if (c === '/' && src[k + 1] === '*') { k = src.indexOf('*/', k + 2) + 2; continue; }
        if (c === '/' && regexAhead(k)) { k = skipRegex(k); continue; }
        if (c === "'" || c === '"') { k = skipString(k); continue; }
        if (c === '`') { k = skipTemplate(k); continue; }
        if (c === '{') depth++;
        if (c === '}') { if (depth === 0) return k + 1; depth--; }
        k++;
      }
      return k;
    };
    skipTemplate = (i) => {
      let k = i + 1;
      while (k < src.length && src[k] !== '`') {
        if (src[k] === '\\') { k += 2; continue; }
        if (src[k] === '$' && src[k + 1] === '{') { k = skipCode(k + 2); continue; }
        k++;
      }
      return k + 1;
    };
    for (let i = 0; i < src.length;) {
      const c = src[i];
      if (c === '/' && src[i + 1] === '/') { const e = src.indexOf('\n', i); i = e < 0 ? src.length : e; continue; }
      if (c === '/' && src[i + 1] === '*') { i = src.indexOf('*/', i + 2) + 2; continue; }
      if (c === '/' && regexAhead(i)) { i = skipRegex(i); continue; }
      if (c === "'" || c === '"' || c === '`') {
        const end = c === '`' ? skipTemplate(i) : skipString(i);
        out.push({ line: src.slice(0, i).split('\n').length, text: src.slice(i, end) });
        i = end;
        continue;
      }
      i++;
    }
    return out;
  };

  // The reads that see a deleted character ON PURPOSE, each with its reason.
  // `has` is a piece of the statement, unique within its file.
  const EXCEPTIONS = CHARACTER_EXCEPTIONS = [
    { file: '_lib/catalog-merge.js', has: 'AS payload FROM characters',
      why: 'a catalog merge rewrites every stored character, so one put back by SQL holds no name the merge removed' },
    { file: 'characters.js', has: 'DELETE FROM characters',
      why: 'a cleanup delete of the row this request just wrote, hard by ruling (2026-10-12)' },
    { file: '_lib/npc-snapshot.js', has: 'DELETE FROM characters', count: 2,
      why: 'the half-copied restore and the move to the NPC library, both hard by ruling (2026-10-12)' },
    { file: 'npc-library/[id]/transfer.js', has: 'DELETE FROM characters',
      why: 'a library transfer that lost the race for its entry takes back the row it just wrote, as the restore does' },
    { file: 'campaigns/[id]/items.js', has: 'AS claimed_by_name',
      why: 'the stash history names a claimant deleted since, by ruling (2026-10-19); it reads the name only' },
  ];

  const fnDir = join(repoRoot, 'functions');
  const walk = (dir) => readdirSync(dir, { withFileTypes: true }).flatMap((e) =>
    e.isDirectory() ? walk(join(dir, e.name)) : e.name.endsWith('.js') ? [join(dir, e.name)] : []);
  const READ = /\b(?:FROM|JOIN)\s+characters\b/gi;
  const sites = [], missing = [];
  const used = new Map(EXCEPTIONS.map((x) => [x, 0]));
  fnLiterals = walk(fnDir).flatMap((path) => {
    const rel = path.slice(fnDir.length + 1).replace(/\\/g, '/').replace(/^api\/character-creator\//, '');
    return literalsOf(readFileSync(path, 'utf8')).map((lit) => ({ rel, ...lit }));
  });
  for (const lit of fnLiterals) {
    const { rel } = lit;
    {
      const reads = (lit.text.match(READ) || []).length;
      if (!reads) continue;
      sites.push(`${rel}:${lit.line}`);
      const excused = EXCEPTIONS.find((x) => x.file === rel && lit.text.includes(x.has));
      if (excused) { used.set(excused, used.get(excused) + 1); continue; }
      const says = (lit.text.match(/\bdeleted_at\b/g) || []).length;
      if (says < reads) missing.push(`${rel}:${lit.line}`);
    }
  }

  // The reader has to be reading, or every check below passes on nothing.
  check('the sweep finds the reads of characters under functions/', sites.length >= 40,
    `${sites.length} sites`);
  check('and every one says deleted_at or is a named exception', missing.length === 0,
    missing.join(', '));
  const stale = EXCEPTIONS.filter((x) => used.get(x) !== (x.count ?? 1));
  check('and every exception still names a read that is there', stale.length === 0,
    stale.map((x) => `${x.file} "${x.has}" matched ${used.get(x)}`).join('; '));

  // The DELETE itself: the column set, the row kept, the journal left alone.
  const route = readFileSync(join(fnDir, 'api', 'character-creator', 'characters', '[id].js'), 'utf8');
  const del = route.slice(route.indexOf('export async function onRequestDelete'));
  check('the character DELETE sets deleted_at', /UPDATE characters SET deleted_at = datetime\('now'\)/.test(del));
  check('and removes no row and detaches no journal entry',
    !/DELETE FROM characters/.test(del) && !/journal_entries/.test(del));

  // The sheet's roster asks before that DELETE, and what it asks has to be
  // what the route now does: the character is hidden, not gone, and comes back
  // only by SQL (Nate, 2026-10-12), and nothing it claimed from the stash goes
  // back there - no cascade fires, so the item stays in its inventory.
  const sheet = readFileSync(join(repoRoot, 'apps', 'character-sheet', 'sheet.js'), 'utf8');
  const ask = sheet.slice(sheet.indexOf('async function deleteFromRoster'),
    sheet.indexOf('// ─── changing stage ───'));
  check('the roster\'s delete prompt says it hides the character and only Nate can restore it',
    ask.includes('hides them from everyone') && ask.includes('Only Nate can restore them'), ask.slice(0, 400));
  check('and no longer says it cannot be undone, or that a claimed item returns to the stash',
    ask.length > 0 && !/cannot be undone/i.test(ask) && !/returns to it/.test(ask));
}

// ---------- A deleted campaign is read by nothing ----------
// The same sweep over `campaigns`, since migration 092 made the campaign
// DELETE set `campaigns.deleted_at` and leave the row, its children and its
// pictures. A character in a deleted campaign keeps its own `deleted_at` NULL
// and is hidden WITH the campaign, so a statement that reads both tables -
// `FROM characters JOIN campaigns` - has to say `deleted_at` once for each:
// the character's, and the campaign's. A character read that is a named
// exception above needs no `deleted_at` here either.
section('A deleted campaign is read by nothing');
{
  // The reads that see a deleted campaign ON PURPOSE. Each only reads the
  // game of a campaign the request has already been let into: through
  // characterAccess (which refuses a character in a deleted campaign) or
  // requireCampaign (which refuses the campaign). Filtering one could only
  // turn a known game into none, and no game is a permissive catalog.
  const GATED = 'the game of a campaign this request\'s guard already found live';
  const EXCEPTIONS = [
    { file: 'characters/[id]/level-confirm.js', has: 'SELECT system FROM campaigns WHERE id = ?', why: GATED },
    { file: 'characters/[id]/power-picks.js', has: 'SELECT system FROM campaigns WHERE id = ?', why: GATED },
    { file: '_lib/skill-bonuses.js', has: 'SELECT system FROM campaigns WHERE id = ?', why: GATED },
    { file: '_lib/system-bases.js', has: 'SELECT campaigns.system AS system', why: GATED },
    { file: '_lib/npc-snapshot.js', has: 'SELECT campaigns.system FROM characters JOIN campaigns', why: GATED },
    { file: 'npc-library/[id]/pull.js', has: 'SELECT system FROM campaigns WHERE id = ?', why: GATED },
    { file: 'npc-library/[id]/transfer.js', has: 'SELECT system FROM campaigns WHERE id = ?', why: GATED },
    { file: 'campaigns/[id]/npcs/generate.js', has: 'SELECT id, system FROM campaigns WHERE id = ?', why: GATED },
  ];

  const READ = /\b(?:FROM|JOIN)\s+campaigns\b/gi;
  const CHAR_READ = /\b(?:FROM|JOIN)\s+characters\b/gi;
  const sites = [], missing = [];
  const used = new Map(EXCEPTIONS.map((x) => [x, 0]));
  for (const lit of fnLiterals) {
    const reads = (lit.text.match(READ) || []).length;
    if (!reads) continue;
    sites.push(`${lit.rel}:${lit.line}`);
    const excused = EXCEPTIONS.find((x) => x.file === lit.rel && lit.text.includes(x.has));
    if (excused) { used.set(excused, used.get(excused) + 1); continue; }
    const charExcused = CHARACTER_EXCEPTIONS.some((x) => x.file === lit.rel && lit.text.includes(x.has));
    const charReads = charExcused ? 0 : (lit.text.match(CHAR_READ) || []).length;
    const says = (lit.text.match(/\bdeleted_at\b/g) || []).length;
    if (says < reads + charReads) missing.push(`${lit.rel}:${lit.line}`);
  }

  check('the sweep finds the reads of campaigns under functions/', sites.length >= 18,
    `${sites.length} sites`);
  check('and every one says deleted_at, once per table it reads, or is a named exception',
    missing.length === 0, missing.join(', '));
  const stale = EXCEPTIONS.filter((x) => used.get(x) !== (x.count ?? 1));
  check('and every exception still names a read that is there', stale.length === 0,
    stale.map((x) => `${x.file} "${x.has}" matched ${used.get(x)}`).join('; '));

  // The DELETE itself: the column set, the row kept, the bucket untouched
  // (Nate, 2026-10-12: a deleted campaign keeps its pictures).
  const route = readFileSync(join(repoRoot, 'functions', 'api', 'character-creator', 'campaigns', '[id].js'), 'utf8');
  const del = route.slice(route.indexOf('export async function onRequestDelete'));
  check('the campaign DELETE sets deleted_at', /UPDATE campaigns SET deleted_at = datetime\('now'\)/.test(del));
  check('and removes no row and deletes nothing from the bucket',
    !/DELETE\s+FROM\s+campaigns/i.test(del) && !/\bMEDIA\b/.test(del) && !/\.delete\(/.test(del));

  // The G.M. dashboard asks before that DELETE, and what it asks has to be
  // what the route now does (Nate, 2026-10-19: "hides it from everyone; only
  // Nate can restore it"). The typed name and the 409's list of players stay.
  const dash = readFileSync(join(repoRoot, 'apps', 'gm-tools', 'dashboard.js'), 'utf8');
  const ask = dash.slice(dash.indexOf('async function deleteCampaign'), dash.indexOf('if (!campaignId)'));
  check('the dashboard\'s delete prompt says it hides the campaign and only Nate can restore it',
    ask.includes('from everyone') && ask.includes('Only Nate can restore it'), ask.slice(0, 400));
  check('and no longer says it cannot be undone', ask.length > 0 && !/cannot be undone/i.test(ask));
  check('and still asks for the name typed, and names the players a 409 lists',
    ask.includes('Type the campaign\'s name to confirm') && ask.includes('typed.trim() !== name')
      && ask.includes('err.detail?.characters'));
}

// ---------- A G.M.'s character transfer (_lib/transfer.js) ----------
// The list of who may receive a character is MV_SHARE_CANDIDATES, and unset
// means nobody. regression boots its server with the list set, so the unset
// case is here: each route is called as a function with a database that fails
// the check if it is touched at all, which is also the proof that an address
// off the list is refused before anything is read or written.
section('A transfer is refused before the database is read');
{
  const { onRequestGet: candidatesGet } = await import('../../../../functions/api/character-creator/transfer-candidates.js');
  const { onRequestPost: sheetPost } = await import('../../../../functions/api/character-creator/characters/[id]/transfer.js');
  const { onRequestPost: libraryPost } = await import('../../../../functions/api/character-creator/npc-library/[id]/transfer.js');
  let touched = 0;
  const DB = new Proxy({}, { get: () => () => { touched++; throw new Error('the database was read'); } });
  const unset = { DB }, listed = { DB, MV_SHARE_CANDIDATES: 'Dev@Localhost, friend@example.com' };
  const post = (path, body) => new Request(`http://localhost/api/character-creator${path}`,
    { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });
  // A handler that reached the database throws, and that is a FAIL line, not a crash.
  const call = async (handler, ctx) => {
    try { const res = await handler(ctx); return { status: res.status, body: await res.json() }; }
    catch (e) { return { status: 'threw', body: { error: e.message } }; }
  };

  const none = await call(candidatesGet, { request: new Request('http://localhost/x'), env: unset });
  check('with the list unset, the picker offers nobody', none.status === 200 && Array.isArray(none.body.candidates)
    && none.body.candidates.length === 0, JSON.stringify(none));
  const some = await call(candidatesGet, { request: new Request('http://localhost/x'), env: listed });
  check('and with it set, everyone on it but the caller, whatever the case',
    JSON.stringify(some.body.candidates) === '["friend@example.com"]', JSON.stringify(some));

  const refusals = [
    ['a sheet, list unset', await call(sheetPost, { request: post('/characters/1/transfer', { to_email: 'friend@example.com' }), env: unset, params: { id: '1' } })],
    ['a library entry, list unset', await call(libraryPost, { request: post('/npc-library/1/transfer', { to_email: 'friend@example.com', campaign_id: 1 }), env: unset, params: { id: '1' } })],
    ['a sheet, address off the list', await call(sheetPost, { request: post('/characters/1/transfer', { to_email: 'stranger@example.com' }), env: listed, params: { id: '1' } })],
    ['a library entry, address off the list', await call(libraryPost, { request: post('/npc-library/1/transfer', { to_email: 'stranger@example.com', campaign_id: 1 }), env: listed, params: { id: '1' } })],
  ];
  for (const [what, r] of refusals) {
    check(`${what}: refused with not_a_candidate`, r.status === 403 && r.body.code === 'not_a_candidate', JSON.stringify(r));
  }
  const unsetMsg = (await call(sheetPost, { request: post('/characters/1/transfer', { to_email: 'friend@example.com' }), env: unset, params: { id: '1' } })).body.error;
  check('and the unset list says which knob is wrong', /MV_SHARE_CANDIDATES is unset/.test(unsetMsg || ''), unsetMsg);
  check('and none of them touched the database', touched === 0, `${touched} reads`);
}

// ---------- A page's own errors reach the server, and not too many ----------
// shared/js/client-errors.js listens for `error` and `unhandledrejection` and
// posts to functions/api/client-error.js, which logs one console.error line.
// Both are driven here, not read as text: the client runs in a vm context
// with a stubbed window and fetch, and the route is called directly with a
// stubbed console.error.
section('Client error reporting');
{
  const { runInNewContext } = await import('node:vm');
  const clientSrc = readFileSync(join(repoRoot, 'shared', 'js', 'client-errors.js'), 'utf8');
  // A fresh page load: its own listeners, its own fetch.
  const load = (fetchImpl) => {
    const listeners = {};
    const posts = [];
    const win = {
      location: { href: 'http://localhost/apps/codex/' },
      navigator: { userAgent: 'smoke' },
      addEventListener: (type, fn) => { listeners[type] = fn; },
      fetch: (url, init) => { posts.push({ url, init }); return fetchImpl(); },
    };
    win.window = win;
    runInNewContext(clientSrc, win);
    const fire = (type, event) => {
      try { listeners[type](event); return null; } catch (e) { return e; }
    };
    return { listeners, posts, fire, win };
  };
  const ok = () => Promise.resolve({ status: 204 });

  const page = load(ok);
  check('the client listens for both error and unhandledrejection',
    typeof page.listeners.error === 'function' && typeof page.listeners.unhandledrejection === 'function',
    Object.keys(page.listeners).join(', ') || 'no listeners');
  page.fire('error', { message: 'boom', filename: '/apps/codex/codex.js', lineno: 12, colno: 3,
    error: { message: 'boom', stack: 'Error: boom\n' + 'x'.repeat(5000) } });
  const first = page.posts[0] && JSON.parse(page.posts[0].init.body);
  check('one error is one POST to /api/client-error with keepalive',
    page.posts.length === 1 && page.posts[0].url === '/api/client-error' && page.posts[0].init.keepalive === true,
    JSON.stringify(page.posts.map((p) => p.url)));
  check('and it carries the seven fields, the stack cut to 2 KB',
    first && first.message === 'boom' && first.source === '/apps/codex/codex.js' && first.line === 12
      && first.col === 3 && first.page === 'http://localhost/apps/codex/' && first.ua === 'smoke'
      && first.stack.length === 2048,
    JSON.stringify(first && { ...first, stack: first.stack.length }));
  page.fire('error', { message: 'boom', error: { message: 'boom' } });
  check('the same message twice is reported once', page.posts.length === 1, `${page.posts.length} posts`);
  for (let i = 0; i < 9; i++) page.fire('error', { message: `distinct ${i}` });
  check('and a page load sends at most five', page.posts.length === 5, `${page.posts.length} posts`);

  const rej = load(ok);
  rej.fire('unhandledrejection', { reason: new Error('nope') });
  rej.fire('unhandledrejection', { reason: 'plain string' });
  const rejMsgs = rej.posts.map((p) => JSON.parse(p.init.body).message);
  check('a rejection is reported with its reason, Error or not',
    JSON.stringify(rejMsgs) === JSON.stringify(['Unhandled rejection: nope', 'Unhandled rejection: plain string']),
    JSON.stringify(rejMsgs));

  // The reporter must never be the next error. A fetch that throws on the
  // call, and one whose promise rejects, are both swallowed.
  const throwing = load(() => { throw new Error('fetch is gone'); });
  const thrown = throwing.fire('error', { message: 'a' });
  let unhandled = 0;
  const onUnhandled = () => { unhandled += 1; };
  process.on('unhandledRejection', onUnhandled);
  const rejecting = load(() => Promise.reject(new Error('offline')));
  const thrown2 = rejecting.fire('error', { message: 'b' });
  const thrown3 = rejecting.fire('unhandledrejection', { get reason() { throw new Error('hostile'); } });
  const thrown4 = rejecting.fire('error', null);
  await new Promise((r) => setTimeout(r, 20));
  process.off('unhandledRejection', onUnhandled);
  check('a fetch that throws or rejects, and a hostile event, never throw out of the handler',
    !thrown && !thrown2 && !thrown3 && !thrown4 && unhandled === 0,
    `${[thrown, thrown2, thrown3, thrown4].filter(Boolean).map((e) => e.message).join('; ')}; ${unhandled} unhandled`);

  // The endpoint.
  const route = await import('../../../../functions/api/client-error.js');
  const logged = [];
  const realError = console.error;
  // console.error is stubbed only for the call, so a FAIL line the harness
  // prints is never swallowed into `logged`.
  const send = async (body, email = 'friend@example.com') => {
    console.error = (...args) => { logged.push(args.join(' ')); };
    try {
      return await route.onRequestPost({ request: new Request('http://localhost/api/client-error', {
        method: 'POST', headers: { 'Content-Type': 'application/json', 'Cf-Access-Authenticated-User-Email': email },
        body: typeof body === 'string' ? body : JSON.stringify(body) }) });
    } finally {
      console.error = realError;
    }
  };
  try {
    route.resetRateLimit();
    const res = await send({ message: 'boom', source: 's.js', line: 4, col: 2, stack: 'Error: boom\n  at f', page: '/apps/codex/', ua: 'u' });
    check('a report answers 204', res.status === 204, `status ${res.status}`);
    check('and logs exactly one line naming the person and the message',
      logged.length === 1 && !logged[0].includes('\n') && logged[0].startsWith('client-error ')
        && logged[0].includes('"email":"friend@example.com"') && logged[0].includes('"message":"boom"'),
      JSON.stringify(logged));

    logged.length = 0;
    const huge = 'y'.repeat(1000);
    await send({ message: huge, source: huge, page: huge, ua: huge, stack: 'z'.repeat(3000).slice(0, 3000), line: 1e12, col: -5 });
    const rec = logged[0] ? JSON.parse(logged[0].slice('client-error '.length)) : {};
    check('every field is capped on the server too',
      rec.message?.length === route.CAPS.message && rec.source?.length === route.CAPS.source
        && rec.page?.length === route.CAPS.page && rec.ua?.length === route.CAPS.ua
        && rec.stack?.length === route.CAPS.stack && rec.line === 1e9 && rec.col === 0,
      JSON.stringify({ m: rec.message?.length, s: rec.source?.length, p: rec.page?.length, u: rec.ua?.length, st: rec.stack?.length, l: rec.line, c: rec.col }));
    const longMail = await send({ message: 'm' }, 'a'.repeat(500) + '@example.com');
    check('the email too', longMail.status === 204
      && JSON.parse(logged.at(-1).slice('client-error '.length)).email.length === route.CAPS.email);

    const big = await send('{"message":"' + 'q'.repeat(route.MAX_BODY) + '"}');
    const notJson = await send('not json');
    check('an oversized body is 413 and a non-JSON one 400, neither logged',
      big.status === 413 && notJson.status === 400 && logged.length === 2, `${big.status} ${notJson.status}, ${logged.length} lines`);

    route.resetRateLimit();
    logged.length = 0;
    const statuses = [];
    for (let i = 0; i < route.RATE_LIMIT + 3; i++) statuses.push((await send({ message: `n${i}` }, 'loop@example.com')).status);
    const other = await send({ message: 'other person' }, 'other@example.com');
    check(`one person is cut off after ${route.RATE_LIMIT} a minute, with nothing logged past it`,
      statuses.slice(0, route.RATE_LIMIT).every((s) => s === 204)
        && statuses.slice(route.RATE_LIMIT).every((s) => s === 429) && logged.length === route.RATE_LIMIT + 1,
      `${statuses.join(',')}; ${logged.length} lines`);
    check('and another person is not', other.status === 204, `status ${other.status}`);
  } finally {
    console.error = realError;
    route.resetRateLimit();
  }

  // Which pages load it. Row 6a of the 2026-10-26 plan loads it on every page
  // that loads shared/js/ui.js except Pick 3 Cut 5 (see the client's header);
  // it must come first, so it is listening before the other scripts run.
  const appsDir = join(repoRoot, 'apps');
  const pages = [];
  for (const app of readdirSync(appsDir, { withFileTypes: true })) {
    if (!app.isDirectory()) continue;
    for (const f of readdirSync(join(appsDir, app.name))) {
      if (!f.endsWith('.html')) continue;
      const html = readFileSync(join(appsDir, app.name, f), 'utf8');
      if (/<script src="\/shared\/js\/ui\.js"><\/script>/.test(html)) pages.push({ path: `${app.name}/${f}`, html });
    }
  }
  const firstScript = (html) => (html.match(/<script\b[^>]*\bsrc="([^"]+)"/) || [])[1];
  const missing = pages.filter((p) => p.path !== 'pick3cut5/index.html'
    && firstScript(p.html) !== '/shared/js/client-errors.js').map((p) => p.path);
  check('every ui.js page but Pick 3 Cut 5 loads client-errors.js as its first script',
    pages.length >= 11 && missing.length === 0, missing.join(', ') || `${pages.length} pages`);
  const p3 = pages.find((p) => p.path === 'pick3cut5/index.html');
  check('and Pick 3 Cut 5 does not, because it would need a sixth Access bypass',
    p3 && !p3.html.includes('client-errors.js'));
}

}
