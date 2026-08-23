// End-to-end regression: real HTTP against real endpoints, against a D1 built
// from nothing.
//
// smoke.mjs proves the machinery is correct — the parser, the dice, the
// composition rules, the schema. It has never proved that a REQUEST works. Both
// bugs that reached production this week lived in that gap: a fresh database
// missing two columns, and a wizard step whose result rendered off-screen. The
// first would have been caught here on the first run.
//
//   node apps/character-creator/test/regression.mjs
//
// Isolated on purpose. It builds its own D1 under a scratch --persist-to
// directory and deletes it afterwards, so it never sees your dev data and a
// failed run cannot leave debris in it. Nothing here talks to production.
//
// Slow relative to smoke.mjs — it boots wrangler and waits for a port — so it
// is a separate command rather than another section of the smoke test.

import { spawn, spawnSync } from 'node:child_process';
import { readFileSync, writeFileSync, rmSync, mkdtempSync, readdirSync, existsSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { tmpdir } from 'node:os';

const testDir = dirname(fileURLToPath(import.meta.url));
const appDir = join(testDir, '..');
const repoRoot = join(appDir, '..', '..');
const PORT = 8799;                       // not 8788, so a dev server can stay up
const BASE = `http://127.0.0.1:${PORT}/api/character-creator`;

let failures = 0;
let checks = 0;
function check(label, cond, detail = '') {
  checks++;
  if (cond) {
    console.log('  ok  ' + label);
  } else {
    failures++;
    const why = detail && typeof detail === 'object' ? JSON.stringify(detail) : String(detail ?? '');
    console.log('  FAIL ' + label + (why ? ' — ' + why.slice(0, 260) : ''));
  }
}

// ── the scratch database ────────────────────────────────────────────────────
const state = mkdtempSync(join(tmpdir(), 'cc-regression-'));
let server = null;

function cleanup() {
  if (server && !server.killed) {
    try { process.platform === 'win32' ? spawnSync('taskkill', ['/pid', server.pid, '/T', '/F']) : server.kill('SIGTERM'); }
    catch { /* already gone */ }
  }
  try { rmSync(state, { recursive: true, force: true }); } catch { /* best effort */ }
}
process.on('exit', cleanup);
process.on('SIGINT', () => { cleanup(); process.exit(130); });

function wrangler(args) {
  return spawnSync('npx', ['wrangler', ...args], {
    cwd: repoRoot, shell: true, encoding: 'utf8', timeout: 180000,
  });
}

// wrangler paints its errors with ANSI colour and wraps them in a box; a check
// detail wants the sentence, not the artwork.
function cleanErr(text) {
  const raw = String(text || '');
  const lines = raw.replace(/\u001b\[[0-9;]*m/g, '').split('\n')
    .map((l) => l.replace(/[^\x20-\x7e]/g, '').trim())
    .filter((l) => /error/i.test(l) && l.length > 8);
  return (lines.join(' | ') || raw.trim()).slice(0, 300) || 'no output';
}

console.log('[1/8] Building a database from nothing');

// One concatenated file rather than 60 wrangler invocations: each costs seconds,
// and the point is to prove the SQL composes, not to time the CLI.
const parts = [
  readFileSync(join(repoRoot, 'db', 'schema.sql'), 'utf8'),
  readFileSync(join(repoRoot, 'db', 'seed-catalogs.sql'), 'utf8'),
];
const dataDir = join(appDir, 'db');
for (const f of readdirSync(dataDir).filter((x) => x.endsWith('.sql')).sort()) {
  const sql = readFileSync(join(dataDir, f), 'utf8');
  if (/^--\s*local-only\b/m.test(sql)) continue;      // seed-dev: unguarded inserts
  parts.push(sql);
}
const bootstrap = join(state, 'bootstrap.sql');
writeFileSync(bootstrap, parts.join('\n;\n'), 'utf8');

const applied = wrangler(['d1', 'execute', 'DB', '--local', '--persist-to', state, '--file', bootstrap]);
check('schema + catalogs + data scripts apply to an empty database',
  applied.status === 0, (applied.stderr || applied.stdout || '').slice(-400));
if (applied.status !== 0) { console.log('\nREGRESSION FAILED (cannot build a database)'); process.exit(1); }

// ── boot the worker ─────────────────────────────────────────────────────────
console.log('\n[2/8] Booting the app');
server = spawn('npx', ['wrangler', 'pages', 'dev', '--port', String(PORT),
  '--persist-to', state, '--show-interactive-dev-session', 'false',
  '--binding', 'ADMIN_EMAIL=dev@localhost'],
  { cwd: repoRoot, shell: true, stdio: 'ignore' });

async function waitForBoot(ms = 90000) {
  const started = Date.now();
  while (Date.now() - started < ms) {
    try {
      const r = await fetch(`${BASE}/me`);
      if (r.ok) return true;
    } catch { /* not up yet */ }
    await new Promise((r) => setTimeout(r, 700));
  }
  return false;
}
const booted = await waitForBoot();
check('the worker answers on port ' + PORT, booted, 'timed out waiting for /me');
if (!booted) { console.log('\nREGRESSION FAILED (worker never came up)'); process.exit(1); }

// ── helpers ─────────────────────────────────────────────────────────────────
async function api(method, path, body) {
  const res = await fetch(BASE + path, {
    method,
    headers: body ? { 'Content-Type': 'application/json' } : undefined,
    body: body ? JSON.stringify(body) : undefined,
  });
  let payload = null;
  const text = await res.text();
  try { payload = JSON.parse(text); } catch { payload = { raw: text.slice(0, 200) }; }
  return { status: res.status, body: payload };
}

// ── the boot calls ──────────────────────────────────────────────────────────
console.log('\n[3/8] What the wizard loads on start');
const me = await api('GET', '/me');
check('/me identifies the caller', me.status === 200 && !!me.body.email, me.body);

const classes = await api('GET', '/classes');
check('/classes returns published classes', classes.status === 200 && classes.body.classes.length > 0, classes.body);
check('and none of them failed to parse',
  !(classes.body.failures || []).length, JSON.stringify(classes.body.failures || []).slice(0, 200));

// This is the call a fresh database used to 500 on: it selects ppe_note and
// isp_note, the two columns that never made it into schema.sql.
const catalogs = await api('GET', '/catalogs');
check('/catalogs answers on a database built only from schema.sql',
  catalogs.status === 200, catalogs.body);
check('and carries skills, spells and psionics',
  catalogs.status === 200 && catalogs.body.skills?.length > 0
  && catalogs.body.spells?.length > 0 && catalogs.body.psionics?.length > 0,
  Object.keys(catalogs.body || {}));

const items = await api('GET', '/items');
check('/items returns the gear catalog', items.status === 200 && items.body.items.length > 0, items.body);

// ── the README's clean-run counts ───────────────────────────────────────────
// The README prints a table of what "a clean run produces", and until now
// nothing checked it: every number in it was stale - 23 classes against 39,
// 366 spells against 542 - three paragraphs below its own warning that prose
// counts drift silently.
//
// This is the only place that can honestly check it. smoke.mjs never builds a
// full database and drift-check talks to an environment somebody has been
// using; here the database was built from schema + seed + every data script,
// minutes ago, from nothing.
const README = readFileSync(join(appDir, 'README.md'), 'utf8');
// Anchor to the clean-run table, not to the whole README: matching
// "spells" anywhere found "| spells missing | 5 | 0 |" in the
// import-tooling section and asserted the catalog held five. Labels are
// escaped because one of them contains parentheses.
const TABLE = (README.split('| After | Rows |')[1] || '').split('\n\n')[0];
const documented = (label) => {
  const lit = label.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const m = new RegExp('^\\|\\s*' + lit + '[^|]*\\|\\s*(\\d+)\\s*\\|', 'm').exec(TABLE);
  return m ? Number(m[1]) : null;
};
const actual = {
  'classes (published, live)': classes.body.classes.length,
  skills: catalogs.body.skills.length,
  spells: catalogs.body.spells.length,
  'psionic powers': catalogs.body.psionics.length,
  gear: items.body.items.length,
};
for (const [label, got] of Object.entries(actual)) {
  const want = documented(label);
  check(`README clean-run count for ${label}`, want === got,
    want === null ? `no row for "${label}" in the README table`
                  : `README says ${want}, a clean run produced ${got}`);
}


// ── a character, end to end ─────────────────────────────────────────────────
console.log('\n[4/8] Creating a campaign and a character');
const camp = await api('POST', '/campaigns', { name: 'Regression Run', system: 'rifts' });
check('a campaign is created', camp.status === 201 || camp.status === 200, camp.body);
const campaignId = camp.body.id ?? camp.body.campaign?.id;
check('and it has an id', !!campaignId, camp.body);

// Pick a class with no variant, no ability choices and no O.C.C. requirement,
// so the payload stays about the endpoint rather than about class rules.
const cls = classes.body.classes.find((c) => c.id === 'cyber-knight')
  || classes.body.classes.find((c) => !(c.variants || []).length && c.system === 'rifts');
check('a test class is available', !!cls, 'no usable class in /classes');

const attrs = { IQ: 16, ME: 16, MA: 16, PS: 16, PP: 16, PE: 16, PB: 16, Spd: 16 };
const occSkills = (cls.skills?.occ_skills || []).map((s) => ({
  name: typeof s === 'string' ? s : s.name, category: 'Class', type: 'occ', pct: 40, per_level: 5,
})).filter((s) => s.name);

const made = await api('POST', '/characters', {
  campaign_id: campaignId, name: 'Regression Character', class_id: cls.id,
  attributes: attrs, skills: occSkills, abilities: [],
  pools: { hp: 30, sdc: 40, ppe: 20, isp: 0 },
  bio: { alignment: 'Principled' },
});
check('a character is created and passes server validation',
  made.status === 201, JSON.stringify(made.body).slice(0, 300));
const charId = made.body.id;

const sheet = await api('GET', `/characters/${charId}`);
check('its sheet loads', sheet.status === 200 && sheet.body.character?.id === charId, sheet.body);

// A fighting style is a level schedule (RUE p.347), and the only proof that
// matters is the number the sheet actually serves. Every piece has to line up -
// the column exists, the data script ran, the loader selects it, compose passes
// the level, derive treats attacks_base as a floor - and any one of them failing
// looks like a character who simply fights slightly worse.
const h2hChar = await api('POST', '/characters', {
  campaign_id: campaignId, name: 'Trained Fighter', class_id: cls.id, level: 1,
  attributes: attrs, skills: [{ name: 'Hand to Hand: Expert', pct: 0, per_level: 0, type: 'occ' }],
  abilities: [],
});
if (h2hChar.status === 200 || h2hChar.status === 201) {
  const id = h2hChar.body.id;
  const s1 = await api('GET', `/characters/${id}`);
  const notes1 = s1.body.skill_level_notes || [];
  check('a first level Expert is served four attacks per melee',
    s1.body.character?.combat?.attacks === 4 || s1.body.class?.bonuses?.combat?.attacks_base === 4,
    JSON.stringify({ combat: s1.body.character?.combat, bonuses: s1.body.class?.bonuses?.combat }));
  check('and the moves the level grants come back as text',
    notes1.length > 0 && notes1.every((n) => n.level <= 1), JSON.stringify(notes1));

  globalThis.__h2hId = id;
  globalThis.__h2hNotes1 = notes1.length;
} else {
  check('a character can be created with a Hand to Hand skill', false, h2hChar.body);
}
check('and reports write permission for its owner', sheet.body.can_write === true, sheet.body.can_write);

// the guard folded into requireCharacter, on a real request
const missing = await api('GET', '/characters/99999999');
check('a character that does not exist is a 404, not a 403', missing.status === 404, missing.status);

// ── inventory ───────────────────────────────────────────────────────────────
console.log('\n[5/8] Inventory, XP, level-up, picks, play');
// By SLUG, not id — the catalog exposes ids but this endpoint keys on the slug,
// because class markdown cites gear that way and one spelling is enough.
const gearRow = items.body.items.find((i) => i.slug) || items.body.items[0];
const added = await api('POST', `/characters/${charId}/items`, { slug: gearRow.slug, qty: 2 });
check('gear is added to the inventory', added.status === 201 || added.status === 200, added.body);
const itemId = added.body.id ?? added.body.item?.id;

const badSlug = await api('POST', `/characters/${charId}/items`, { slug: 'no-such-item-anywhere', qty: 1 });
check('an unknown gear slug is refused', badSlug.status === 400, badSlug.body);
const noRef = await api('POST', `/characters/${charId}/items`, { qty: 1 });
check('an item with neither slug nor custom_name is refused', noRef.status === 400, noRef.body);
const freeform = await api('POST', `/characters/${charId}/items`, { custom_name: 'A thing from play', qty: 1 });
check('a freeform item is accepted', freeform.status === 201, freeform.body);

if (itemId) {
  const patched = await api('PATCH', `/characters/${charId}/items/${itemId}`, { qty: 3, equipped: true });
  check('an inventory row can be updated', patched.status === 200, patched.body);
  const removed = await api('DELETE', `/characters/${charId}/items/${itemId}`);
  check('and soft-removed', removed.status === 200, removed.body);
  const after = await api('GET', `/characters/${charId}`);
  const stillThere = (after.body.items || []).some((i) => i.id === itemId && !i.removed_at);
  check('a removed row leaves the active inventory', !stillThere);
}

// ── xp and levelling ────────────────────────────────────────────────────────
const xp = await api('POST', `/characters/${charId}/xp`, { total: 100000 });
check('XP can be set', xp.status === 200, xp.body);
check('crossing a threshold returns a PROPOSAL rather than applying it',
  !!xp.body.proposal, JSON.stringify(xp.body).slice(0, 200));

if (xp.body.proposal) {
  const target = xp.body.proposal.to_level ?? xp.body.level + 1;
  const confirmed = await api('POST', `/characters/${charId}/level-confirm`, {
    to_level: target, picks: [],
  });
  check('a level-up can be confirmed', confirmed.status === 200, JSON.stringify(confirmed.body).slice(0, 250));
  const levelled = await api('GET', `/characters/${charId}`);
  check('and the character is actually at the new level',
    levelled.body.character.level === target,
    'level is ' + levelled.body.character?.level + ', expected ' + target);
}

const picks = await api('GET', `/characters/${charId}/picks`);
check('pending skill picks are listed', picks.status === 200 && Array.isArray(picks.body.pending), picks.body);

// The same fighting style, read at a level the character actually reached.
// Creation is always level 1 (by design), so this drives the real xp and
// level-confirm path - which is also the path that would break if compose
// stopped passing the level through.
if (globalThis.__h2hId) {
  const id = globalThis.__h2hId;
  const gain = await api('POST', `/characters/${id}/xp`, { total: 100000 });
  const target = gain.body?.proposal?.to_level ?? null;
  if (target && target >= 4) {
    await api('POST', `/characters/${id}/level-confirm`, { to_level: target, picks: [] });
    const after = await api('GET', `/characters/${id}`);
    const b = after.body.class?.bonuses?.combat || {};
    // The Expert gains its second attack at level 4 and +2 strike at 3, so any
    // level past 4 must show more than the level 1 grant did.
    check('a levelled Expert has accumulated more of the table',
      after.body.character.level === target && (b.attacks ?? 0) >= 1 && (b.strike ?? 0) >= 2,
      'level ' + after.body.character?.level + ' ' + JSON.stringify(b));
    check('and has more moves to read than at level 1',
      (after.body.skill_level_notes || []).length > globalThis.__h2hNotes1,
      (after.body.skill_level_notes || []).length + ' vs ' + globalThis.__h2hNotes1);
  } else {
    check('the Hand to Hand character can be levelled', false, JSON.stringify(gain.body).slice(0, 200));
  }
}


// ── play mode ───────────────────────────────────────────────────────────────
const before = await api('GET', `/characters/${charId}`);
const hpBefore = before.body.character.hp_current;
const ev = await api('POST', `/characters/${charId}/events`, {
  kind: 'damage', note: 'regression hit',
  changes: { character: { hp_current: { from: hpBefore, to: hpBefore - 5 } } },
});
check('a play event applies and records in one call', ev.status === 200 || ev.status === 201, ev.body);
const afterHit = await api('GET', `/characters/${charId}`);
check('the pool actually moved', afterHit.body.character.hp_current === hpBefore - 5,
  'hp is ' + afterHit.body.character.hp_current + ', expected ' + (hpBefore - 5));

const undone = await api('POST', `/characters/${charId}/events/undo`);
check('the latest event can be undone', undone.status === 200, undone.body);
const restored = await api('GET', `/characters/${charId}`);
check('and the pool is restored', restored.body.character.hp_current === hpBefore,
  'hp is ' + restored.body.character.hp_current + ', expected ' + hpBefore);

const events = await api('GET', `/characters/${charId}/events`);
check('the event log still holds the undone event',
  events.status === 200 && events.body.events.some((e) => e.undone_at), events.body.events?.length);

// ── journal, draft, lists, admin ────────────────────────────────────────────
console.log('\n[6/8] Journal, drafts, lists, admin');
const entry = await api('POST', '/journal', { character_id: charId, title: 'Session 1', body: 'It happened.' });
check('a journal entry is written', entry.status === 201 || entry.status === 200, entry.body);
const journal = await api('GET', `/journal?campaign_id=${campaignId}`);
check('and read back', journal.status === 200 && journal.body.entries.length > 0, journal.body);
check('journal paging reports its shape',
  typeof journal.body.total === 'number' && typeof journal.body.limit === 'number', journal.body);

// A draft is one row per person, so every PUT is a replace. The guard is what
// stops a second tab - or a script driving the wizard - silently discarding a
// build in progress.
const draftPut = await api('PUT', '/draft', {
  system: 'rifts', class_id: cls.id, step: 2, state: { x: 1 }, expect_updated_at: null });
check('a wizard draft is created when none exists', draftPut.status === 200 || draftPut.status === 201, draftPut.body);
check('and the save reports the new version', !!draftPut.body.updated_at, draftPut.body);
const draftGet = await api('GET', '/draft');
check('and it reads back', draftGet.status === 200 && !!draftGet.body.draft, draftGet.body);

// The case that cost a real draft: a caller that does not say which version
// it is replacing must not be allowed to replace anything.
const blind = await api('PUT', '/draft', { system: 'rifts', class_id: cls.id, step: 9, state: { clobbered: true } });
check('a PUT claiming no version is REFUSED when a draft exists', blind.status === 409, blind.status);
check('and the refusal says what is there now',
  blind.status === 409 && !!blind.body.conflict && !!blind.body.current, blind.body);

const stale = await api('PUT', '/draft', {
  system: 'rifts', class_id: cls.id, step: 9, state: { clobbered: true },
  expect_updated_at: '1999-01-01 00:00:00' });
check('a PUT claiming a STALE version is refused', stale.status === 409, stale.status);

const survived = await api('GET', '/draft');
check('and neither refusal changed the stored draft',
  survived.body.draft?.step === 2 && survived.body.draft?.state?.x === 1,
  survived.body.draft);

const correct = await api('PUT', '/draft', {
  system: 'rifts', class_id: cls.id, step: 4, state: { x: 2 },
  expect_updated_at: survived.body.draft.updated_at });
check('a PUT claiming the CURRENT version succeeds', correct.status === 200, correct.body);
const moved = await api('GET', '/draft');
check('and it actually replaced the draft', moved.body.draft?.step === 4, moved.body.draft);

const draftDel = await api('DELETE', '/draft');
check('a draft can be deleted', draftDel.status === 200, draftDel.body);
check('leaving none', (await api('GET', '/draft')).body.draft === null);
const afterDelete = await api('PUT', '/draft', {
  system: 'rifts', class_id: cls.id, step: 1, state: { fresh: true }, expect_updated_at: null });
check('and a fresh build can then create one again', afterDelete.status === 200, afterDelete.body);
await api('DELETE', '/draft');

const list = await api('GET', `/characters?campaign_id=${campaignId}`);
check('the character list is paged', list.status === 200 && typeof list.body.total === 'number', list.body);
const nonsense = await api('GET', '/characters?limit=banana');
check('a nonsense limit falls back rather than 400ing',
  nonsense.status === 200 && nonsense.body.limit === 200, nonsense.body.limit);

const audit = await api('GET', '/admin/audit');
check('the admin audit runs', audit.status === 200, audit.body);
check('and finds no rule-breaking characters in a fresh database',
  audit.status === 200 && (audit.body.characters || []).length === 0,
  JSON.stringify(audit.body).slice(0, 200));

// -- confirming an import bigger than one statement can bind ----------------
// D1 takes at most 100 bound parameters per statement. `markConfirmed` built
// `WHERE id IN (?,?,...)` from EVERY pending row, so a session with more than a
// hundred blew the limit - and it runs AFTER the catalog write has landed. The
// live failure inserted 108 spells, marked none of them, and returned a 500
// that read as total failure. The rows stayed pending, so a retry would have
// tried to insert all 108 a second time.
//
// 150 rows, driven through the real endpoint against a real D1. Under the old
// code the first check here fails.
console.log('\n' + '[7/8] An import too big for one statement');
{
  const N = 150;
  const stagedRows = Array.from({ length: N }, (_, i) => {
    const payload = JSON.stringify({
      name: 'Regression Spell ' + i, level: (i % 15) + 1, ppe: i + 1,
      ppe_note: null, range: 'Self', duration: 'Instant', damage: null,
      saving_throw: 'None', area_of_effect: null, casting_time: null, description: null,
    }).replace(/'/g, "''");
    return 'INSERT INTO import_staged (session_id, page_range, payload, action) VALUES '
      + "((SELECT id FROM import_sessions WHERE name = 'regression-bulk'), 'pp.1-2', '"
      + payload + "', 'insert');";
  });
  const seedFile = join(state, 'bulk-import.sql');
  writeFileSync(seedFile, [
    "INSERT INTO import_sessions (catalog, name, source_book, system, created_by) VALUES "
      + "('spells', 'regression-bulk', 'Regression Book', 'rifts', 'dev@localhost');",
    ...stagedRows,
  ].join('\n'), 'utf8');
  const seeded = wrangler(['d1', 'execute', 'DB', '--local', '--persist-to', state, '--file', seedFile]);
  check(N + ' staged rows seeded', seeded.status === 0,
    (seeded.stderr || seeded.stdout || '').slice(-300));

  const sess = await api('GET', '/import/sessions?catalog=spells');
  const session = (sess.body.sessions || []).find((x) => x.name === 'regression-bulk');
  check('the bulk session is listed', !!session, JSON.stringify(sess.body).slice(0, 200));

  if (session) {
    const before = await api('GET', '/catalogs');
    const countBefore = (before.body.spells || []).length;

    const confirmed = await api('POST', '/import/spells/confirm', { session_id: session.id });
    check('confirming 150 rows succeeds', confirmed.status === 200,
      JSON.stringify(confirmed.body).slice(0, 300));
    check('and reports all 150 inserted',
      confirmed.body && confirmed.body.counts && confirmed.body.counts.inserted === N,
      JSON.stringify(confirmed.body && confirmed.body.counts));
    // The half that used to be skipped silently: the write landed, the
    // bookkeeping did not.
    check('and marks all 150 confirmed, not just the first hundred',
      confirmed.body && confirmed.body.confirmed === N,
      String(confirmed.body && confirmed.body.confirmed));
    check('leaving nothing pending',
      confirmed.body && confirmed.body.still_pending === 0,
      String(confirmed.body && confirmed.body.still_pending));

    const after = await api('GET', '/catalogs');
    check('the catalog really grew by 150',
      (after.body.spells || []).length === countBefore + N,
      countBefore + ' -> ' + (after.body.spells || []).length);

    // A second confirm must find nothing rather than a pile of UNIQUE
    // conflicts, which is only true if the first one recorded what it did.
    const again = await api('POST', '/import/spells/confirm', { session_id: session.id });
    check('a second confirm has nothing left to do', again.status === 400,
      JSON.stringify(again.body).slice(0, 200));
  }
}

// -- the README's countable claims, against the database ---------------------
// Prose does not get recounted when a class is added or a chapter is imported.
// Both of these had already drifted before anyone noticed.
console.log('\n' + '[8/8] Checks that only a database can make');
{
  const readme = readFileSync(join(appDir, 'README.md'), 'utf8');
  const WORDS = {
    one: 1, two: 2, three: 3, four: 4, five: 5, six: 6, seven: 7, eight: 8,
    nine: 9, ten: 10, eleven: 11, twelve: 12, thirteen: 13, fourteen: 14,
    fifteen: 15, sixteen: 16, seventeen: 17, eighteen: 18, nineteen: 19,
    twenty: 20, thirty: 30, forty: 40, fifty: 50, sixty: 60, seventy: 70,
    eighty: 80, ninety: 90,
  };
  // Hyphenated compounds sum their parts, so "thirty-seven" does not have to be
  // listed and neither does the next count. Listing each compound means the
  // list goes stale exactly when the number changes - which is the moment this
  // check is supposed to fire.
  const word = (w) => {
    const parts = String(w).toLowerCase().split('-');
    if (!parts.every((p) => p in WORDS)) return undefined;
    return parts.reduce((n, p) => n + WORDS[p], 0);
  };

  const { parseClassMarkdown } = await import(
    pathToFileURL(join(appDir, 'js', 'parser.js')).href);

  const listed = await api('GET', '/classes');
  const classes = (listed.body.classes || []);
  check('the class list is readable for counting', classes.length > 0, listed.body);

  // An M.D.C. being tracks M.D.C. INSTEAD of hit points, so its silence is a
  // statement and the core-rules default deliberately skips it.
  let silent = 0;
  for (const c of classes) {
    if (c.mdc_base != null) continue;
    if (c.hit_points_base == null) silent++;
  }

  const claim = readme.match(/([A-Za-z-]+) of ([A-Za-z-]+) published classes state no hit point/);
  check('the README still states the hit-point-silence count', !!claim,
    'the sentence changed shape');
  if (claim) {
    check('and the number of published classes matches the database',
      word(claim[2]) === classes.length,
      'README says ' + claim[2] + ' (' + word(claim[2]) + '), database has ' + classes.length);
    check('and the count of classes stating no hit point formula matches',
      word(claim[1]) === silent,
      'README says ' + claim[1] + ' (' + word(claim[1]) + '), database has ' + silent);
  }

  // Every named spell list must still resolve, or the README's "all 34 resolve
  // now" becomes the next stale claim.
  const catalogs = await api('GET', '/catalogs');
  const norm = (x) => String(x).toLowerCase().replace(/&/g, 'and')
    .replace(/[^a-z0-9 ]+/g, ' ').replace(/\s+/g, ' ').trim();
  const haveSpell = new Set((catalogs.body.spells || []).map((r) => norm(r.name)));

  let unresolved = [];
  for (const id of ['shifter', 'ley-line-rifter']) {
    const one = await api('GET', '/classes?class_id=' + id);
    const md = (one.body.classes || []).find((c) => c.id === id);
    const cls = md || classes.find((c) => c.id === id);
    if (!cls || !cls.magic) continue;
    const lists = { ...(cls.magic.spell_lists || {}) };
    if (cls.magic.spells_per_level_from) lists.single = cls.magic.spells_per_level_from;
    for (const [listName, list] of Object.entries(lists)) {
      for (const n of list) if (!haveSpell.has(norm(n))) unresolved.push(id + '/' + listName + ': ' + n);
    }
  }
  check('every named spell list resolves against the catalog',
    unresolved.length === 0, unresolved.slice(0, 6).join('; '));

  // -- every only/except name must match a real skill row --------------------
  //
  // js/parser.js matches a restriction against the skill name as a raw
  // normalised string, and it runs in the BROWSER, where catalog_redirects is
  // not available - catalogs.js never sends it. So a restriction naming a row
  // that does not exist fails silently, in whichever direction is worse:
  //
  //   except: ["X"]  ->  excludes nothing, the class grants MORE than the book
  //   only:   ["X"]  ->  narrows to nothing, the class grants nothing
  //
  // The Shifter shipped that way: it excluded "Military: Jet Fighters" while
  // the catalog row was "Jet Fighters", so the exclusion excluded nothing and
  // the Shifter could take a skill the book denies it. Nothing reported it.
  const skillNames = new Set((catalogs.body.skills || []).map((r) => norm(r.name)));
  const dead = [];
  for (const c of classes) {
    const groups = [
      ...(c.skills?.occ_skills || []),
      c.skills?.occ_related_skills,
      c.skills?.secondary_skills,
    ].filter(Boolean);
    // Restrictions ride on the CATEGORY entries as well as the group: a
    // category is either a plain string or an object carrying only/except.
    const entries = [];
    for (const g of groups) {
      entries.push(g);
      for (const cat of (Array.isArray(g.categories) ? g.categories : [])) {
        if (cat && typeof cat === 'object') entries.push(cat);
      }
    }
    for (const e of entries) {
      for (const key of ['only', 'except']) {
        for (const n of (Array.isArray(e[key]) ? e[key] : [])) {
          if (!skillNames.has(norm(n))) dead.push(`${c.id} ${key}: "${n}"`);
        }
      }
    }
  }

  // Two are deliberate and documented: the Priest of Light names W.P. Siege and
  // W.P. Large Axes ahead of those rows existing, and says so in its own note.
  // They activate by themselves when the rows arrive. The audit floor is two,
  // not zero - so this pins the NAMES, not just the count, and a third dead
  // restriction fails the run.
  //
  // It was three. W.P. Lance was the third, and add-knight-class.sql created
  // that row - so the placeholder did exactly what the note said it would and
  // stopped being dead. The floor comes down with it: leaving it at three would
  // mean the suite went red for a placeholder resolving, which is the outcome
  // the design was aiming at.
  const ALLOWED = new Set(['W.P. Siege', 'W.P. Large Axes']);
  const unexpected = dead.filter((d) => ![...ALLOWED].some((a) => d.includes(`"${a}"`)));
  check('every skill restriction names a skill that exists',
    unexpected.length === 0, unexpected.slice(0, 8).join('; '));
  check('and the two documented placeholders are still the only exceptions',
    dead.length === unexpected.length + 2,
    `${dead.length} dead, ${unexpected.length} unexpected`);

  // -- who has an MOS, and how many packages ---------------------------------
  //
  // A count in a comment goes stale silently, and both written records of this
  // one were wrong at once: parser.js said the Technical Officer offered five
  // where it offers seven, and the README said the Robot Pilot offered two
  // where it had NONE - it carried its packages as GM prose plus a note saying
  // the schema could not hold them, which it could.
  //
  // This lives here rather than in smoke.mjs because the answer is a property
  // of the COMPOSED class, and the Merc Soldier's and Robot Pilot's arrive by
  // correction rather than at import: no single file has the answer.
  const MOS_PACKAGES = {
    'coalition-technical-officer': 7,
    'merc-soldier': 7,
    'robot-pilot': 2,
  };
  for (const [id, want] of Object.entries(MOS_PACKAGES)) {
    const cls = classes.find((c) => c.id === id);
    check(`${id} still exists`, !!cls);
    const opts = cls?.skills?.mos?.options;
    check(`and offers ${want} MOS packages`, Array.isArray(opts) && opts.length === want,
      `found ${opts ? opts.length : 'no mos block'}`);
    // Every package has to grant something, or choosing it is a no-op the
    // player cannot tell apart from choosing nothing.
    check('and every one of them grants at least one skill',
      (opts || []).every((o) => Array.isArray(o.skills) && o.skills.length > 0),
      (opts || []).filter((o) => !o.skills?.length).map((o) => o.id).join(', '));
  }
  // Nothing else may claim an MOS the list does not know about.
  const withMos = classes.filter((c) => c.skills?.mos).map((c) => c.id).sort();
  check('and no other class has one',
    withMos.join() === Object.keys(MOS_PACKAGES).sort().join(),
    'classes with an MOS: ' + withMos.join(', '));

  // -- languages of choice come from languages ------------------------------
  //
  // Seven classes said "two languages of choice" and offered the whole
  // Technical category - about sixty skills - because the repeatable
  // Language: Other row only behaved repeatably on the related/secondary
  // picker. They now offer that row and nothing else.
  // Stated as an INVARIANT over every class rather than a list of ids, because
  // the list was the thing that was wrong: the defect was reported as seven
  // classes and was thirty-two. Seven offered the whole Technical category,
  // which is merely too wide. Twenty-five offered Communications, which does
  // not contain `Language: Other` at all - it is filed under Technical - so
  // those classes could not grant a single ordinary language.
  const ABOUT_LANGUAGES = /^Language: Other,|languages? of choice|additional [Ll]anguages/;
  // A LITERACY pick reads the same way in prose - "literate in two languages of
  // choice" - and is a different thing: Literacy, Literacy: Other and the rest
  // are real catalog rows, so those groups are enumerated correctly already.
  const isLiteracy = (e) => /^Literate/i.test(e.note || '')
    || (Array.isArray(e.from) && e.from.every((n) => /^Literacy/.test(n)));
  const languageGroups = [];
  for (const c of classes) {
    for (const e of (c.skills?.occ_skills || [])) {
      if (!e || e.name || !ABOUT_LANGUAGES.test(e.note || '') || isLiteracy(e)) continue;
      languageGroups.push({ id: c.id, e });
    }
  }
  check('the language picks are still there to check', languageGroups.length >= 30,
    `found ${languageGroups.length}`);

  const viaCategory = languageGroups.filter(({ e }) => Array.isArray(e.categories));
  check('no class offers a CATEGORY for a language pick', viaCategory.length === 0,
    viaCategory.map((x) => x.id).join(', '));

  const notFromTheRow = languageGroups.filter(({ e }) =>
    !Array.isArray(e.from) || !e.from.includes('Language: Other'));
  check('and every one of them offers the repeatable language row',
    notFromTheRow.length === 0, notFromTheRow.map((x) => x.id).join(', '));

  // The bonus is what makes the pick worth taking, and losing one in the
  // rewrite would be silent because the row still resolves. Two classes had
  // none to begin with and gained the figure their own note recorded.
  const noBonus = languageGroups.filter(({ e }) => !(typeof e.bonus === 'number' && e.bonus > 0));
  check('and every one keeps a positive bonus', noBonus.length === 0,
    noBonus.map((x) => x.id).join(', '));

  // A language must never be FIXED at a flat percentage: it resolves off the
  // Other row's 50% +5/lvl, and `base` would freeze it. The Cyber-Doc read the
  // printed "+20%" as `base: 20, per_level: 0` - a language stuck at 20% for
  // fifteen levels.
  const frozen = languageGroups.filter(({ e }) => e.base !== undefined || e.per_level === 0);
  check('and none is frozen at a flat percentage', frozen.length === 0,
    frozen.map((x) => `${x.id} base=${x.e.base} per_level=${x.e.per_level}`).join(', '));

  // Spot-check the three shapes end to end.
  for (const [id, want] of Object.entries({ knight: 2, 'chiang-ku-dragon': 3, 'cyber-doc': 1 })) {
    const g = languageGroups.find((x) => x.id === id)?.e;
    check(`${id} asks for ${want} language(s)`, g?.choose === want, `asks for ${g?.choose}`);
  }

  // -- and the same for LITERACY ---------------------------------------------
  //
  // The second family, and the one that had no rule at all: `Literacy: Other`
  // is the same escape hatch for reading rather than speaking, and was treated
  // as one ordinary skill. So a Wizard "literate in two languages of choice"
  // picked twice from four generic rows and ended up literate in "Other".
  const literacyGroups = [];
  const literacyFixed = [];
  for (const c of classes) {
    for (const e of (c.skills?.occ_skills || [])) {
      if (!e) continue;
      if (e.name === 'Literacy: Other') literacyFixed.push(c.id);
      if (e.name) continue;
      const about = /^Literate/i.test(e.note || '') || /^Literacy: Other,/.test(e.note || '')
        || (Array.isArray(e.from) && e.from.some((n) => /^Literacy/.test(n)));
      if (about) literacyGroups.push({ id: c.id, e });
    }
  }
  check('the literacy picks are still there to check', literacyGroups.length >= 6,
    `found ${literacyGroups.length}`);

  const litViaCategory = literacyGroups.filter(({ e }) => Array.isArray(e.categories));
  check('no class offers a CATEGORY for a literacy pick', litViaCategory.length === 0,
    litViaCategory.map((x) => x.id).join(', '));

  const litNotFromRow = literacyGroups.filter(({ e }) =>
    !Array.isArray(e.from) || !e.from.includes('Literacy: Other'));
  check('and every literacy pick offers the repeatable row',
    litNotFromRow.length === 0, litNotFromRow.map((x) => x.id).join(', '));

  // A grant of the placeholder is a pick that was never offered: the character
  // ends up holding a skill named, literally, "Literacy: Other".
  check('no class GRANTS the placeholder row as a fixed skill',
    literacyFixed.length === 0, literacyFixed.join(', '));

  // -- every fixed skill a class names must exist -----------------------------
  //
  // The Stone Master cited "Literacy: Dragonese/Elf" - no such row, no redirect
  // - so the skill resolved to nothing, and "Language: American" sat at base 0
  // per_level 0, frozen at 0% for fifteen levels. A name in one of the two
  // families is exempt: those resolve off their family's Other row BY DESIGN
  // and are the whole reason the families exist.
  const catalogNames = new Set((catalogs.body.skills || []).map((r) => r.name));
  // A RENAME deliberately leaves class markdown alone and records a redirect
  // instead, so a name with no row is not automatically dead - the Glitter Boy
  // still cites both pre-rename Robot Combat spellings on purpose. /catalogs
  // never sends redirects, so this asks the scratch database, which the test
  // owns.
  // `wrangler()` spawns with shell: true, so an argument with spaces has to
  // carry its own quotes - every other caller here passes --file, which has
  // none, and an unquoted SQL string arrives as a dozen unknown arguments.
  const redirectRows = wrangler(['d1', 'execute', 'DB', '--local', '--persist-to', state, '--json',
    '--command', `"SELECT from_key FROM catalog_redirects WHERE catalog = 'skills'"`]);
  let redirected = new Set();
  let redirectErr = '';
  try {
    const out = redirectRows.stdout || '';
    // wrangler prefixes its own log line - "[string] [d1, execute, ...]" - so the
    // first "[" in the output is NOT the JSON. Take the first one that parses.
    let parsed = null;
    for (let at = out.indexOf('['); at >= 0 && !parsed; at = out.indexOf('[', at + 1)) {
      try {
        const v = JSON.parse(out.slice(at));
        if (Array.isArray(v)) parsed = v;
      } catch { /* not the array; keep looking */ }
    }
    if (!parsed) throw new Error(cleanErr(redirectRows.stderr || out));
    redirected = new Set(parsed.flatMap((b) => b.results || []).map((r) => r.from_key));
  } catch (e) { redirectErr = e.message; }
  check('the redirect table is readable', redirected.size > 0,
    redirectErr || 'query ran but returned no skill redirects');

  const isFamily = (n) => /^(Language|Literacy):\s*\S/.test(n);
  const resolves = (n) => catalogNames.has(n) || isFamily(n) || redirected.has(n);
  const deadFixed = [];
  const frozenAtZero = [];
  const bonusOnNothing = [];
  for (const c of classes) {
    for (const e of (c.skills?.occ_skills || [])) {
      if (!e?.name) continue;
      if (!resolves(e.name)) {
        // A class-specific skill the catalog never got still resolves IF the
        // class states its own numbers; what cannot resolve is a name with
        // neither a row, a redirect, nor a base.
        if (typeof e.base !== 'number') deadFixed.push(`${c.id}: ${e.name}`);
      }
      if (isFamily(e.name) && e.base === 0) frozenAtZero.push(`${c.id}: ${e.name}`);
      // A `bonus` is meaningless without a row to add it to. `resolveSkill`
      // sums it onto the catalog base, so a bonus on a name the catalog does
      // not have does not fall back to the bonus - it falls to ZERO, which is
      // worse than the wrong number it replaced.
      if (e.bonus !== undefined && !resolves(e.name)) {
        bonusOnNothing.push(`${c.id}: ${e.name}`);
      }
    }
  }
  check('no fixed skill puts a bonus on a name the catalog does not have',
    bonusOnNothing.length === 0, bonusOnNothing.join(', '));

  // -- a printed BONUS is never stored as the BASE ----------------------------
  //
  // "Chemistry (+10%)" means ten points on top of Chemistry's own 30%, not a
  // Chemistry of 10%. Storing the second for the first put 48 skills across six
  // classes BELOW the catalog row they are supposed to excel at - the Cyber-Doc
  // diagnosing at Computer Operation 5% where any passer-by has 40%.
  //
  // Written over every class rather than the six, so a new import inherits it.
  // A below-base fixed skill is legitimate when the book prints a flat figure -
  // "Language: Native Tongue at 88%", the Warrior Monk's "Base Skill: 20%" - so
  // the rule is not "never below base"; it is that such a row must SAY SO, in a
  // note or by being one of the two language families. What must never happen
  // again is a bare number sitting under the catalog with nothing to explain it.
  const catalogByName = new Map((catalogs.body.skills || []).map((r) => [r.name, r]));
  const unexplainedBelowBase = [];
  let compared = 0;
  for (const c of classes) {
    for (const e of (c.skills?.occ_skills || [])) {
      if (!e?.name || typeof e.base !== 'number') continue;
      const row = catalogByName.get(e.name);
      if (!row) continue;
      compared += 1;
      if (e.base >= row.base) continue;
      if (isFamily(e.name) || (e.note && e.note.trim())) continue;
      unexplainedBelowBase.push(`${c.id}: ${e.name} ${e.base} < ${row.base}`);
    }
  }
  // A rule that silently compares nothing passes forever. This one has hundreds
  // of rows to look at; if a rename or a shape change ever leaves it with none,
  // the failure should be the missing comparison, not the empty result.
  check('the below-base rule actually compared fixed skills against the catalog',
    compared > 200, `compared ${compared}`);
  check('no fixed skill sits under its catalog base without saying why',
    unexplainedBelowBase.length === 0, unexplainedBelowBase.join(', '));
  check('every fixed skill resolves to real numbers',
    deadFixed.length === 0, deadFixed.join(', '));
  check('and no language or literacy skill is pinned to 0%',
    frozenAtZero.length === 0, frozenAtZero.join(', '));

  // -- every Palladium O.C.C. levels on its own chart -------------------------
  //
  // Palladium Fantasy printed 336: 15 tables, 15 levels each. `xp_table` stores
  // the LOWER bound of each band, which is what `levelForXp` compares against.
  //
  // The shape is checked over the whole catalog rather than a list of 25 ids,
  // so a new Palladium O.C.C. arriving without a chart is a failure here rather
  // than a character quietly levelling on the house-rule default.
  const pfOcc = classes.filter((c) => c.system === 'palladium-fantasy' && c.category === 'occ');
  const rccs = classes.filter((c) => c.category === 'rcc');
  check('the Palladium O.C.C.s are still there to check', pfOcc.length >= 25, `${pfOcc.length}`);

  const noTable = pfOcc.filter((c) => !Array.isArray(c.xp_table));
  check('every Palladium O.C.C. has its own experience table',
    noTable.length === 0, noTable.map((c) => c.id).join(', '));

  const misshapen = pfOcc.filter((c) => {
    const t = c.xp_table;
    return !Array.isArray(t) || t.length !== 15 || t[0] !== 0
      || t.some((n, i) => !Number.isInteger(n) || (i > 0 && n <= t[i - 1]));
  });
  check('and each is 15 levels, starting at 0, strictly rising',
    misshapen.length === 0, misshapen.map((c) => c.id).join(', '));

  // A race has no experience table, because experience comes from what you do.
  // This is the invariant the composition fix in #222 depends on being true.
  const rccWithTable = rccs.filter((c) => c.xp_table !== undefined);
  check('and no R.C.C. carries one', rccWithTable.length === 0,
    rccWithTable.map((c) => c.id).join(', '));

  // The pairs the book prints together must stay together - "Knight & Noble" is
  // one chart, and two classes drifting apart means a transcription went wrong.
  for (const [a, b] of [['knight', 'noble'], ['thief', 'merchant'],
    ['mind-mage', 'wizard'], ['priest-of-light', 'priest-of-darkness']]) {
    const ta = classes.find((c) => c.id === a)?.xp_table;
    const tb = classes.find((c) => c.id === b)?.xp_table;
    check(`${a} and ${b} share the chart the book prints for both`,
      JSON.stringify(ta) === JSON.stringify(tb) && Array.isArray(ta));
  }

  // The Warlock's row is the Rifts printing, so its Palladium figures belong in
  // its delta section and NOT in its frontmatter.
  const warlock = classes.find((c) => c.id === 'warlock');
  check('the Warlock takes its Palladium experience as a delta, not a table',
    warlock && warlock.xp_table === undefined,
    JSON.stringify(warlock?.xp_table));
}

// ---------- gear.sdc ----------
// The book calls A.R. and S.D.C. the TWO attributes of armour (printed 270),
// and the rules spend the second: damage subtracts from it, at half S.D.C. the
// A.R. drops two points. It lived in free-text `description` until migration
// 034, where no arithmetic could reach it.
//
// `/items` projects only the fields the pickers render, so this asks the
// scratch database - the same way the redirect check does.
{
  const q = (sql) => {
    const r = wrangler(['d1', 'execute', 'DB', '--local', '--persist-to', state, '--json',
      '--command', `"${sql}"`]);
    const out = r.stdout || '';
    for (let at = out.indexOf('['); at >= 0; at = out.indexOf('[', at + 1)) {
      try { const v = JSON.parse(out.slice(at)); if (Array.isArray(v)) return v.flatMap((b) => b.results || []); }
      catch { /* wrangler's own log line opens with a bracket too */ }
    }
    throw new Error(cleanErr(r.stderr || out));
  };

  let rows = [];
  let err = '';
  try { rows = q('SELECT slug, category, system, ar, sdc, mdc, damage FROM gear'); }
  catch (e) { err = e.message; }
  check('gear is readable and has an sdc column', rows.length > 0, err || 'no rows');

  // The Types of Armor table, printed 270, plus the shield from printed 60.
  const BOOK = { 'soft-leather': 20, 'hard-leather': 30, 'studded-leather': 38,
    'chain-mail': 44, 'scale-mail': 75, 'small-shield': 30 };
  const wrong = Object.entries(BOOK)
    .map(([slug, want]) => [slug, want, rows.find((r) => r.slug === slug)?.sdc])
    .filter(([, want, got]) => got !== want);
  check('every Palladium armour row carries the S.D.C. its book prints',
    wrong.length === 0, wrong.map(([s, w, g]) => `${s} want ${w} got ${g}`).join(', '));

  const pfArmourEmpty = rows.filter((r) => r.category === 'armor'
    && r.system === 'palladium-fantasy' && r.sdc == null);
  check('and none of them is still empty', pfArmourEmpty.length === 0,
    pfArmourEmpty.map((r) => r.slug).join(', '));

  // A suit has one scale or the other. (A row that CONFLATES two products can
  // legitimately carry both - polarized goggles are 15 S.D.C. ordinary and
  // 1 M.D.C. high-impact - which is why this is scoped to armour.)
  const bothScales = rows.filter((r) => r.category === 'armor' && r.sdc != null && r.mdc != null);
  check('no armour row carries both an S.D.C. and an M.D.C.',
    bothScales.length === 0, bothScales.map((r) => r.slug).join(', '));

  // The trap this column invites. "Does 1D6 S.D.C." on a knife is DAMAGE, and a
  // regex over descriptions would file it as durability - a knife that can
  // absorb six points of punishment because it deals six.
  const damageAsSdc = rows.filter((r) => r.sdc != null && /\dD\d/.test(r.damage || ''));
  check('and no weapon was given its own damage as durability',
    damageAsSdc.length === 0, damageAsSdc.map((r) => `${r.slug} sdc=${r.sdc} damage=${r.damage}`).join(', '));

  check('the importer can write the column',
    /'ar', 'sdc', 'mdc'/.test(readFileSync(join(repoRoot, 'functions', 'api', 'character-creator',
      '_lib', 'import-engine.js'), 'utf8')),
    'gear.extractFields omits sdc, so every future import drops it back into prose');
}

console.log('\n' + (failures === 0
  ? `REGRESSION PASSED (${checks} checks)`
  : `REGRESSION FAILED (${failures} of ${checks} checks)`));
cleanup();
process.exit(failures === 0 ? 0 : 1);
