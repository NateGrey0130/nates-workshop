// MediaVault smoke test: the migration planner, the item sanitizer, the
// structural guarantee that no endpoint can replace a whole library again,
// and the claims this app's README makes — so none of them can quietly stop
// being true.
//
// Run from anywhere:  node apps/media-vault/test/smoke.mjs
//
// The harness is the character creator's: section/check/summary are app-
// agnostic, and a second copy would drift from the first.

import { readFileSync, readdirSync, existsSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { section, check, summary } from '../../character-creator/test/harness.mjs';
import {
  ITEM_FIELDS, MAX_ITEMS, MAX_FIELD_LEN, sanitizeItem, rowToItem,
  normalizeIsbn, isIsbnShape, looksLikeIsbn, isbnCheckDigitValid,
} from '../../../functions/api/media-vault/_lib/common.js';
import { mergeKey, planMigration } from '../../../functions/api/media-vault/migrate.js';

const appDir = join(dirname(fileURLToPath(import.meta.url)), '..');
const repoRoot = join(appDir, '..', '..');
const apiDir = join(repoRoot, 'functions', 'api', 'media-vault');
const readme = readFileSync(join(appDir, 'README.md'), 'utf8');
const appSrc = readFileSync(join(appDir, 'app.js'), 'utf8');
const schema = readFileSync(join(repoRoot, 'db', 'schema.sql'), 'utf8');
const commonSrc = readFileSync(join(apiDir, '_lib', 'common.js'), 'utf8');

const endpointFiles = ['items.js', 'migrate.js', 'lookup.js',
  join('items', 'bulk.js'), join('items', 'bulk-update.js'), join('items', 'bulk-delete.js')];
const endpointSrc = Object.fromEntries(
  endpointFiles.map((f) => [f.replace(/\\/g, '/'), readFileSync(join(apiDir, f), 'utf8')]));
const allEndpointSrc = Object.values(endpointSrc).join('\n');

// A deterministic stand-in for crypto.randomUUID, so a re-id is provable.
let idCounter = 0;
const fakeId = () => 'fresh-' + (++idCounter);
const item = (over = {}) => sanitizeItem({
  id: 'i1', title: 'A Title', type: 'audiobook', format: 'digital', addedAt: 1, ...over,
});
const row = (over = {}) => ({ item_id: 'c1', title: 'A Title', type: 'audiobook', ...over });

// ---------- 1. The migration planner ----------
// This is the one place in the app where a bug silently loses or resurrects a
// user's collection, so it is tested as logic rather than through a database.
section('The migration planner');

check('title and type together make the key, lowercased',
  mergeKey({ title: 'Dune', type: 'movie' }) === 'dune|movie');
check('a missing title does not throw',
  mergeKey({ type: 'movie' }) === '|movie');

{
  const p = planMigration([row({ title: 'Dune', type: 'movie' })],
    [item({ id: 'l1', title: 'DUNE', type: 'movie' })], fakeId);
  check('an item already in the cloud is skipped, whatever its case',
    p.skipped === 1 && p.toInsert.length === 0);
}
{
  const p = planMigration([row({ title: 'Dune', type: 'movie' })],
    [item({ id: 'l1', title: 'Dune', type: 'audiobook' })], fakeId);
  check('the same title in another type is a different item, and lands',
    p.skipped === 0 && p.toInsert.length === 1);
}
{
  const p = planMigration([], [item({ id: 'l1', title: 'Dune' }), item({ id: 'l2', title: 'dune' })], fakeId);
  check('the batch dedupes against itself, not just against the cloud',
    p.toInsert.length === 1 && p.skipped === 1);
}
{
  // An id that a cloud row already owns must not UPSERT over that row: it
  // belongs to a different title, and overwriting it would be the data loss
  // this whole change exists to end.
  const cloud = [row({ item_id: 'shared', title: 'Cloud Title' })];
  const local = item({ id: 'shared', title: 'Local Title' });
  const p = planMigration(cloud, [local], fakeId);
  check('a local id colliding with a cloud row gets a fresh id',
    p.toInsert.length === 1 && p.toInsert[0].id === 'fresh-1');
  check('and the colliding item keeps its own title',
    p.toInsert[0].title === 'Local Title');
  check('and the caller’s item object is not mutated',
    local.id === 'shared');
}
{
  const p = planMigration([], [], fakeId);
  check('an empty local library plans nothing', p.toInsert.length === 0 && p.skipped === 0);
}
{
  // Idempotence is what makes "retry on the next load" safe.
  const cloud = [row({ item_id: 'c1', title: 'Kept', type: 'movie' })];
  const local = [item({ id: 'l1', title: 'New', type: 'movie' })];
  const first = planMigration(cloud, local, fakeId);
  const after = [...cloud, ...first.toInsert.map((i) => ({ item_id: i.id, title: i.title, type: i.type }))];
  const second = planMigration(after, local, fakeId);
  check('replanning after a successful migration inserts nothing',
    first.toInsert.length === 1 && second.toInsert.length === 0 && second.skipped === 1);
}
{
  const cloud = Array.from({ length: MAX_ITEMS }, (_, i) => row({ item_id: 'c' + i, title: 't' + i }));
  const p = planMigration(cloud, [item({ id: 'l1', title: 'One More' })], fakeId);
  check('a migration that would cross the cap is flagged, not silently truncated',
    p.overCap === true && p.toInsert.length === 1);
  check('and a migration that fits is not flagged',
    planMigration([row()], [item({ id: 'l1', title: 'Other' })], fakeId).overCap === false);
}

// ---------- 2. The item sanitizer ----------
section('The item sanitizer');

check('a non-object is refused', sanitizeItem(null) === null && sanitizeItem('x') === null);
check('an item without a string id is refused', sanitizeItem({ title: 'T' }) === null);
check('an absurdly long id is refused',
  sanitizeItem({ id: 'x'.repeat(101), title: 'T' }) === null);
check('a blank title is refused',
  sanitizeItem({ id: 'a', title: '   ' }) === null);
{
  const clean = sanitizeItem({ id: 'a', title: 'T' });
  check('a bare item gets the documented defaults',
    clean.type === 'audiobook' && clean.format === 'digital');
  check('and every documented field exists as a string',
    ITEM_FIELDS.every((f) => typeof clean[f] === 'string'));
  check('and a missing addedAt becomes a number',
    Number.isFinite(clean.addedAt));
}
check('a non-numeric addedAt does not survive as one',
  Number.isFinite(sanitizeItem({ id: 'a', title: 'T', addedAt: 'soon' }).addedAt));
check('an over-long field is truncated rather than rejected',
  sanitizeItem({ id: 'a', title: 'T', notes: 'n'.repeat(MAX_FIELD_LEN + 50) }).notes.length === MAX_FIELD_LEN);
check('a non-string field becomes an empty string, not the word',
  sanitizeItem({ id: 'a', title: 'T', genre: 42 }).genre === '');
{
  const stored = {
    item_id: 'a', type: 'movie', format: 'physical', title: 'T', author: 'A',
    actors: 'B', producers: 'C', genre: 'D', series: 'E', location: 'F',
    cover: 'G', notes: 'H', added_at: 7,
  };
  const out = rowToItem(stored);
  check('a row round-trips out of the database with its id and stamp renamed',
    out.id === 'a' && out.addedAt === 7);
  check('and carries every item field',
    ITEM_FIELDS.every((f) => out[f] === stored[f]));
}

// ---------- 3. No endpoint can replace a library ----------
// The bug this app was rebuilt to fix was a whole-library replace. These are
// structural checks: they fail if one comes back, however it is spelled.
section('No endpoint replaces a library');

{
  const deletes = [...allEndpointSrc.matchAll(/DELETE FROM media_items[^`'"]*/g)].map((m) => m[0]);
  check('every delete statement names item_id',
    deletes.length > 0 && deletes.every((d) => d.includes('item_id')),
    deletes.filter((d) => !d.includes('item_id')).join(' | '));
}
check('no endpoint handles PUT at all',
  !allEndpointSrc.includes('onRequestPut'));
check('the old whole-library endpoint is gone',
  !existsSync(join(repoRoot, 'functions', 'api', 'media.js')));
check('and nothing still calls its path',
  !appSrc.includes("'/api/media'") && !appSrc.includes('"/api/media"'));
{
  const chunked = ['items/bulk.js', 'items/bulk-update.js', 'items/bulk-delete.js'];
  const readmeChunk = Number((readme.match(/chunked at \*\*(\d+)\*\* ids/) || [])[1]);
  check('the README states the id-chunk size', Number.isFinite(readmeChunk) && readmeChunk > 0);
  check('and every bulk endpoint chunks its id list at that size',
    chunked.every((f) => new RegExp('i \\+= ' + readmeChunk).test(endpointSrc[f])
      && new RegExp('slice\\(i, i \\+ ' + readmeChunk + '\\)').test(endpointSrc[f])));
}
{
  const wl = endpointSrc['items/bulk-update.js'];
  const fields = [...wl.matchAll(/^  ([a-z]+): \[/gm)].map((m) => m[1]);
  check('bulk-update settable fields are exactly type and format',
    JSON.stringify(fields) === '["type","format"]', fields.join(','));
  check('and each is checked against a value whitelist',
    wl.includes('SETTABLE[f].includes(set[f])'));
}

// ---------- 4. What the app talks to ----------
section('What the app talks to');

{
  const external = [...new Set([...appSrc.matchAll(/https?:\/\/([^/'"`\s]+)/g)].map((m) => m[1]))];
  check('no external origin appears in the app at all',
    external.length === 0, external.join(', '));
}
check('no API key is hardcoded in the app',
  !/['"][0-9a-f]{32}['"]/.test(appSrc));
check('the TMDB key is read from the environment, not the source',
  endpointSrc['lookup.js'].includes('env.TMDB_API_KEY')
  && !/['"][0-9a-f]{32}['"]/.test(endpointSrc['lookup.js']));
{
  const writes = [...appSrc.matchAll(/localStorage\.setItem\(/g)];
  check('the app never writes library data to localStorage', writes.length === 0);
  const keys = [...new Set([...appSrc.matchAll(/localStorage\.\w+\(\s*'([^']+)'/g)].map((m) => m[1]))];
  check('the only localStorage key it names is the one it is retiring',
    JSON.stringify(keys) === '["mv_library"]', keys.join(','));
  check('and it removes that key rather than keeping it in step',
    appSrc.includes("localStorage.removeItem('mv_library')"));
}
{
  const calls = [...new Set([...appSrc.matchAll(/['"`](\/api\/[a-z0-9-]+(?:\/[a-z0-9-]+)*)/g)].map((m) => m[1]))];
  check('every API path the app calls is its own',
    calls.length > 0 && calls.every((c) => c.startsWith('/api/media-vault/')), calls.join(' '));
}

// ---------- 5. The README's claims ----------
section('The README’s claims');

{
  const onDisk = [];
  const walk = (dir, prefix) => {
    for (const e of readdirSync(dir, { withFileTypes: true })) {
      if (e.isDirectory()) { if (e.name !== '_lib') walk(join(dir, e.name), prefix + e.name + '/'); }
      else if (e.name.endsWith('.js')) onDisk.push(prefix + e.name);
    }
  };
  walk(apiDir, '');
  check('the file map lists every endpoint file that exists',
    onDisk.every((f) => readme.includes(f.split('/').pop())), onDisk.join(' '));
  check('and the endpoint files are exactly the six documented',
    onDisk.length === 6, onDisk.join(' '));
}
{
  const documented = [...readme.matchAll(/^\| `([a-z-]+)` \| (?:OpenLibrary|TMDB) \|/gm)].map((m) => m[1]);
  const implemented = [...endpointSrc['lookup.js'].matchAll(/case '([a-z-]+)':/g)].map((m) => m[1]);
  check('the README documents every lookup mode the proxy implements',
    implemented.length === 6
    && JSON.stringify([...documented].sort()) === JSON.stringify([...implemented].sort()),
    `readme: ${documented.join(',')} code: ${implemented.join(',')}`);
}
{
  const cap = readme.match(/\*\*(\d+) items per user\*\*/);
  check('the README states the per-user item cap', !!cap);
  check('and it matches the endpoint constant',
    cap && Number(cap[1]) === MAX_ITEMS,
    cap ? `README ${cap[1]}, code ${MAX_ITEMS}` : '');
  const field = readme.match(/(\d+) characters per\s+field/);
  check('the README states the per-field cap', !!field);
  check('and it matches the endpoint constant',
    field && Number(field[1]) === MAX_FIELD_LEN,
    field ? `README ${field[1]}, code ${MAX_FIELD_LEN}` : '');
}
{
  const cols = (schema.match(/CREATE TABLE IF NOT EXISTS media_items \(([\s\S]*?)\n\);/) || [])[1];
  check('media_items still exists in schema.sql', !!cols);
  const names = cols.split('\n')
    .map((l) => (l.trim().match(/^([a-z_]+)/) || [])[1])
    .filter((w) => w && w !== 'PRIMARY');
  check('every item field the sanitizer produces is a column',
    ITEM_FIELDS.every((f) => names.includes(f)), names.join(','));
  check('and the README names every one of them',
    ITEM_FIELDS.every((f) => readme.includes('`' + f + '`')));
  check('the README names the key the table is scoped by',
    readme.includes('`(user_email, item_id)`') && names.includes('user_email'));
  check('the README explains why the table is not prefixed',
    /not\*\* prefixed/.test(readme) && readme.includes('ff_'));
}
check('the proxy does not repeat the prefix its callers already add',
  !/error: 'Lookup failed/.test(endpointSrc['lookup.js'])
  && appSrc.includes("'Lookup failed: ' + err.message"));
check('the README names the secret the lookup proxy needs',
  readme.includes('`TMDB_API_KEY`'));
check('and describes both failure modes the code distinguishes',
  readme.includes('503') && endpointSrc['lookup.js'].includes('503')
  && endpointSrc['lookup.js'].includes('TMDB rejected the API key'));
check('the README documents the localStorage key being retired',
  readme.includes('`mv_library`'));
check('the README names the pure planner the migration turns on',
  readme.includes('`planMigration`'));
check('the README says how to run this test',
  readme.includes('node apps/media-vault/test/smoke.mjs'));

// ---------- 6. ISBN input ----------
// The gate this replaced was `/^\d{10,13}$/`, which rejected every ISBN-10
// ending in X — about one book in eleven — and accepted 11- and 12-digit
// strings that are not ISBNs at all. It lived in two files and the client's
// copy decided routing, so the same input could be searched for as a film.
// These are the properties that made it wrong, pinned so it cannot come back.
section('ISBN input');

check('an ISBN-10 whose check digit is X is a valid shape',
  isIsbnShape('043935806X') && isIsbnShape('052562483X'));
check('an all-digit ISBN-10 and ISBN-13 still are',
  isIsbnShape('0743273567') && isIsbnShape('9780743273565') && isIsbnShape('9798465662277'));
check('a length that is not an ISBN in any scheme is refused',
  !isIsbnShape('12345678901') && !isIsbnShape('978074327356') && !isIsbnShape('12345'));
check('X is refused where only a digit belongs',
  !isIsbnShape('978074327356X') && !isIsbnShape('04393X806X'));
check('the normaliser upper-cases, because OpenLibrary answers ISBN:…X and not ISBN:…x',
  normalizeIsbn('0-439-35806-x') === '043935806X'
  && normalizeIsbn(' 978 0 06 112008 4 ') === '9780061120084');
check('and it survives a missing value rather than throwing',
  normalizeIsbn(null) === '' && normalizeIsbn(undefined) === '');
{
  // Everything a publisher's page, a retailer listing or a spreadsheet puts
  // between the digits. Each of these came back "Invalid ISBN" before.
  const pasted = [
    '978–0–06–112008–4',  // en dashes
    '978‑0‑06‑112008‑4',  // non-breaking hyphens
    'ISBN 978-0-06-112008-4',                 // a pasted label
    'ISBN: 9780061120084',                    // and with a colon
    '9780061120084.',                         // a sentence's full stop
    '9780061120084​',                    // a zero-width space
    '978 0 06 112008 4',  // non-breaking spaces
  ];
  check('every way a real page writes an ISBN normalises to the same thirteen digits',
    pasted.every((p) => normalizeIsbn(p) === '9780061120084'),
    pasted.filter((p) => normalizeIsbn(p) !== '9780061120084').map((p) => JSON.stringify(p)).join(' '));
}
{
  check('a correct check digit is accepted, X and 13-digit alike',
    ['043935806X', '052562483X', '054792822X', '0743273567', '9780743273565',
      '9780061120084', '9798465662277', '9780262033848'].every(isbnCheckDigitValid));
  check('a single mistyped digit is caught',
    !isbnCheckDigitValid('9780743273566') && !isbnCheckDigitValid('0439358061'));
  check('and something that is not an ISBN at all is not "valid"',
    !isbnCheckDigitValid('978074327356') && !isbnCheckDigitValid('12345678901')
    && !isbnCheckDigitValid(''));
}
{
  // Routing, where the alternative is a film search. The Apollo case is the
  // one that matters: its digits alone normalise to a ten-character string
  // that isIsbnShape happily accepts.
  check('an attempt at an ISBN routes to the ISBN path however it was written',
    ['043935806X', '0-439-35806-x', '978–0–06–112008–4',
      'ISBN 978-0-06-112008-4', '978074327356', '12345678901'].every(looksLikeIsbn));
  check('and a film title does not, even one made mostly of digits',
    !['Blade Runner', '1984', 'Apollo 13 1995 1080p', 'The Matrix', 'Malcolm X',
      'Se7en', ''].some(looksLikeIsbn));
}
{
  // app.js has no module loader, so it carries its own copy of every rule it
  // needs. Copies of one rule drift; this is where that has to fail.
  //
  // NOTE: an earlier version of this section asserted the SHAPE test was not
  // duplicated into the client. That was right while the proxy owned every
  // ISBN message, and became wrong the moment the client had to tell "not an
  // ISBN" apart from "check digit wrong" before making a request. Pin the
  // copies against each other instead of forbidding them.
  const grab = (name, src) =>
    (src.match(new RegExp(`function ${name}\\((\\w+)\\) \\{\\r?\\n([\\s\\S]*?)\\r?\\n\\}`)) || [])[0];
  for (const name of ['normalizeIsbn', 'isIsbnShape', 'looksLikeIsbn', 'isbnCheckDigitValid']) {
    const inProxy = grab(name, commonSrc);
    const inApp = grab(name, appSrc);
    check(`${name} is defined once in the proxy and copied byte-for-byte into app.js`,
      !!inProxy && !!inApp && inProxy === inApp,
      !inProxy ? 'missing from common.js' : !inApp ? 'missing from app.js' : 'the two copies differ');
  }
}
check('the proxy rejects a malformed ISBN by saying what it wanted',
  /10- or 13-digit ISBN/.test(endpointSrc['lookup.js'])
  && !endpointSrc['lookup.js'].includes("'Invalid ISBN'"));
check('but the proxy does NOT check the digit — that answer belongs to the client',
  !endpointSrc['lookup.js'].includes('isbnCheckDigitValid')
  && appSrc.includes('isbnCheckDigitValid('));
{
  // The pasted-list feature reuses what exists. If it ever grows an endpoint
  // of its own, the two checks in section 5 fail as well — this one names why.
  check('paste-add calls the lookup mode and the bulk endpoint that already exist',
    appSrc.includes("mode=isbn") && appSrc.includes("'/api/media-vault/items/bulk'"));
  const cap = appSrc.match(/const ISBN_PASTE_MAX = (\d+);/);
  check('a single paste-add run is capped, and the cap is a number the README states',
    !!cap && readme.includes(`up to **${cap[1]}**`), cap ? `code ${cap[1]}` : 'no cap found');
  check('and the run reports what it left out rather than truncating silently',
    appSrc.includes('leaving ${over} out'));
}

process.exit(summary() === 0 ? 0 : 1);
