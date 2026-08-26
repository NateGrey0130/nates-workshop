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
  ITEM_FIELDS, MAX_ITEMS, MAX_FIELD_LEN, sanitizeItem, rowToItem, UPSERT_SQL,
  normalizeIsbn, isIsbnShape, looksLikeIsbn, isbnCheckDigitValid,
} from '../../../functions/api/media-vault/_lib/common.js';
import { mergeKey, planMigration } from '../../../functions/api/media-vault/migrate.js';
import {
  planDedupe, dupSurvivor, DUP_MERGE_FIELDS, DUP_BLOCKING_FIELDS,
} from '../../../functions/api/media-vault/_lib/dedupe.js';

const appDir = join(dirname(fileURLToPath(import.meta.url)), '..');
const repoRoot = join(appDir, '..', '..');
const apiDir = join(repoRoot, 'functions', 'api', 'media-vault');
const readme = readFileSync(join(appDir, 'README.md'), 'utf8');
const appSrc = readFileSync(join(appDir, 'app.js'), 'utf8');
const schema = readFileSync(join(repoRoot, 'db', 'schema.sql'), 'utf8');
const commonSrc = readFileSync(join(apiDir, '_lib', 'common.js'), 'utf8');

const endpointFiles = ['items.js', 'migrate.js', 'lookup.js', 'duplicates.js',
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
  // The whitelist allowed `format` from the day it was written and the bulk bar
  // offered only `type`, so the capability sat unreachable. Both are wired now;
  // this fails if one is dropped from the bar while the server still takes it.
  const html = readFileSync(join(appDir, 'index.html'), 'utf8');
  const wired = [...html.matchAll(/bulkChange(Type|Format)\('([a-z]+)'\)/g)]
    .map((m) => m[1].toLowerCase() + ':' + m[2]);
  check('every value the server will bulk-set has a button in the bulk bar',
    ['type:audiobook', 'type:movie', 'type:series', 'format:digital', 'format:physical']
      .every((v) => wired.includes(v)), wired.join(' '));
  check('and both bulk edits go through one function rather than two copies',
    /async function bulkSet\(/.test(appSrc)
    && /return bulkSet\(\{ type/.test(appSrc) && /return bulkSet\(\{ format/.test(appSrc));

  // The client's list of text fields and the server's must agree. The server
  // is the one that enforces it, so a client offering a fourth would produce a
  // 400 the user cannot act on — and a server field the client never offers is
  // the exact way `format` sat unreachable for months.
  const clientText = [...appSrc.matchAll(/^  ([a-z]+): '([a-z]+)',$/gm)]
    .filter((m) => m[1] === m[2]).map((m) => m[1]);
  const serverText = [...endpointSrc['items/bulk-update.js']
    .matchAll(/^  ([a-z]+): \{ text: true \}/gm)].map((m) => m[1]);
  check('every free-text field the server accepts is offered by the picker, and none beyond',
    serverText.length > 0
    && JSON.stringify(clientText.slice().sort()) === JSON.stringify(serverText.slice().sort()),
    `client ${clientText.join(',')} vs server ${serverText.join(',')}`);
  // Scoped to the picker's own <select>. Read across the whole document this
  // collected every option in the app — the search-field chooser, the sort
  // order, the type and format selects in the add form — and compared 18
  // values against 3.
  const pickerBlock = (html.match(/<select[^>]*id="bulkField"[\s\S]*?<\/select>/) || [''])[0];
  const picker = [...pickerBlock.matchAll(/<option value="([a-z]+)"/g)].map((m) => m[1]);
  check('and the picker in the markup offers exactly those',
    !!pickerBlock && JSON.stringify(picker.slice().sort()) === JSON.stringify(serverText.slice().sort()),
    picker.join(',') || 'no #bulkField select found');
  check('Apply is reachable by the Enter key as well as the button',
    /onkeydown="if\(event\.key==='Enter'\)bulkSetField\(\)"/.test(html)
    && html.includes('onclick="bulkSetField()"'));

  // The bar wraps — it has to, or it runs off both edges — and a bare label is
  // a flex child like any other, so it wraps away from the buttons it
  // introduces. Measured at 768px before this: the three "Change … to →"
  // labels sat on a line of their own. Every label and its controls are one
  // child now, and each direct child of the bar must be a group, a divider, or
  // one of the two standalone controls.
  const bar = (html.match(/<div class="bulk-bar"[\s\S]*?\n<\/div>/) || [''])[0];
  const barChildren = [...bar.matchAll(/^  <(\w+)[^>]*class="([^"]+)"/gm)].map((m) => m[2].split(' ')[0]);
  check('every control on the bulk bar is inside a group, a divider, or standalone by design',
    barChildren.length > 0
    && barChildren.every((c) => ['bulk-group', 'bulk-bar-divider', 'bulk-bar-count', 'bulk-select-all'].includes(c)),
    barChildren.join(' '));
  check('and the four groups are the type buttons, the format buttons, the field form and the two actions',
    (bar.match(/class="bulk-group"/g) || []).length === 4);
}
{
  const declOf = (name) => {
    const at = appSrc.indexOf('function ' + name + '(');
    if (at < 0) return '';
    const m = /\r?\n\}/.exec(appSrc.slice(at));
    return m ? appSrc.slice(at, at + m.index + m[0].length) : appSrc.slice(at);
  };
  // A blank box is easy to press Apply on by accident, so clearing a field
  // across a selection has to announce itself as clearing.
  check('clearing a field asks a different question from setting one',
    /Clear the \$\{label\} on \$\{plural\(n\)\}\?/.test(appSrc)
    && /Set the \$\{label\} on \$\{plural\(n\)\} to/.test(appSrc));
  check('and the question is built from the count at confirm time, not baked in early',
    /confirm\(question\(selectedIds\.size\)\)/.test(appSrc)
    && /bulkSet\(set, question\)/.test(appSrc));
  check('the value is trimmed before it is quoted back, so the dialog matches the write',
    declOf('bulkSetField').includes('input.value.trim()'));
  check('and the box is emptied afterwards, whether or not the write happened',
    /await bulkSet\(\{ \[field\]: value \}, question\);\r?\n[\s\S]{0,400}?input\.value = '';\r?\n\}/
      .test(declOf('bulkSetField')));
}
{
  // ─── source_id, and the five ways a column silently stops round-tripping ───
  // It records where a row came from, so a re-lookup can be exact rather than a
  // guess. Every check here guards a path that would drop it WITHOUT FAILING
  // ANYTHING — which is the whole hazard: nothing breaks, the column just goes
  // quietly empty and the re-lookup it exists for degrades back to guessing.
  const html = readFileSync(join(appDir, 'index.html'), 'utf8');
  const declOf = (name) => {
    const at = appSrc.indexOf('function ' + name + '(');
    if (at < 0) return '';
    const m = /\r?\n\}/.exec(appSrc.slice(at));
    return m ? appSrc.slice(at, at + m.index + m[0].length) : appSrc.slice(at);
  };
  check('source_id is an item field, so the sanitizer, row mapper and upsert all carry it',
    ITEM_FIELDS.includes('source_id'));
  // Named in three places, and all three matter: the INSERT column list, the
  // ON CONFLICT assignment (without which an UPDATE would leave the old value
  // — invisible until a re-lookup used a stale id), and the binding.
  check('the upsert names it in the insert, the conflict update and the bindings',
    /\(user_email, item_id,[^)]*\bsource_id\b/.test(UPSERT_SQL)
    && UPSERT_SQL.includes('source_id = excluded.source_id')
    && commonSrc.includes('it.source_id'));
  check('and the bound parameter count still matches the columns it lists',
    (UPSERT_SQL.match(/\?/g) || []).length
      === UPSERT_SQL.slice(UPSERT_SQL.indexOf('(') + 1, UPSERT_SQL.indexOf(')')).split(',').length,
    `${(UPSERT_SQL.match(/\?/g) || []).length} placeholders`);
  check('rowToItem reads the column back out, or a GET would return it undefined',
    /source_id: row\.source_id,/.test(commonSrc));

  check('the form has a hidden input for it',
    /<input type="hidden" id="sourceId">/.test(html));
  // Two callers, one with a source id and one deliberately without: an ISBN
  // lookup knows the number, a title search does not and must not invent one.
  check('the ISBN lookup stores the NORMALISED number, not the raw typing',
    appSrc.includes('fillBookFields(result.book, result.isbn)'));
  check('and a title-or-author search stores nothing, because it has nothing exact',
    /function fillBookFields\(book, sourceId = ''\)/.test(appSrc)
    && declOf('selectBookResult').includes('fillBookFields(book)'));
  check('selecting a TMDB result stores a prefixed id that says which lookup to re-run',
    /sourceId'\)\.value = `tmdb:\$\{mediaType\}:\$\{tmdbId\}`/.test(appSrc));
  check('the paste-add path carries each row’s own ISBN',
    appSrc.includes('bookToItem(r.book, r.isbn)')
    && appSrc.includes('bookToItem(result.book, result.isbn)'));

  // The four quiet erasures. Each of these once had, or would have had, no
  // symptom at all beyond the column going empty.
  check('saving reads the hidden input rather than defaulting it away',
    declOf('saveItem').includes("source_id: document.getElementById('sourceId').value.trim()"));
  check('opening an item for edit carries it back INTO the form',
    declOf('editItem').includes("document.getElementById('sourceId').value = item.source_id"));
  check('a fresh lookup clears it, so one book cannot inherit another’s source',
    /'coverUrl', 'sourceId'\]/.test(declOf('clearForm')));
  check('and a CSV round trip keeps it, on both the way out and the way back',
    /'notes', 'source_id'\]/.test(declOf('exportCSV'))
    && declOf('importCSV').includes("source_id: obj.source_id"));

  // Whitespace-flattened, because the phrase this looks for straddles a hard
  // line wrap in the README and `includes` does not care that the prose is the
  // same — it just quietly fails.
  const readmeFlat = readme.replace(/\s+/g, ' ');
  check('the README states the column, what writes it, and what deliberately does not',
    readmeFlat.includes('`source_id` is where the row came from')
    && readmeFlat.includes('twelve item fields')
    && readmeFlat.includes('leaves it **empty on purpose**')
    && readmeFlat.includes('carried through the edit form, the CSV export and the CSV import'));
}
{
  // ─── Filling in the blanks ───
  // This feature writes to rows the user has already curated, from a source
  // that is sometimes a GUESS. Every check here guards one of the rules that
  // makes that safe; without them it is a bulk overwrite with a friendly name.
  const html = readFileSync(join(appDir, 'index.html'), 'utf8');
  const declOf = (name) => {
    const at = appSrc.indexOf('function ' + name + '(');
    if (at < 0) return '';
    const m = /\r?\n\}/.exec(appSrc.slice(at));
    return m ? appSrc.slice(at, at + m.index + m[0].length) : appSrc.slice(at);
  };
  const fields = (appSrc.match(/const ENRICH_FIELDS = \[([^\]]*)\]/) || [])[1] || '';

  // The rule everything else rests on. `title` here would rewrite a
  // hand-corrected title from a fuzzy search — data loss wearing a feature's
  // clothes — and `notes`, `location` and `series` are the user's alone.
  check('only cover, author and genre can be filled — never title, notes, location or series',
    /'cover', 'author', 'genre'/.test(fields)
    && !/title|notes|location|series|format|type/.test(fields), fields.trim());
  const fills = declOf('enrichFills');
  check('a field that already has something is skipped',
    /if \(row\[f\] && !\(f === 'cover' && replaceCovers\)\) continue;/.test(fills));
  check('and the ONLY exception is covers, behind an opt-in that starts off',
    /<input type="checkbox" id="enrichReplaceCovers">/.test(html)
    && declOf('openEnrichModal').includes("getElementById('enrichReplaceCovers').checked = false"));
  check('a source id is filled but never replaced, so a guess cannot overwrite an exact one',
    /if \(found\.sourceId && !row\.source_id\)/.test(fills));

  // Exact vs guessed. The tick is what makes a guess trustworthy.
  check('an exact match arrives ticked and a guessed one does not',
    /entry\.include = entry\.status === 'filled' && entry\.exact;/.test(declOf('runEnrich')));
  check('and only a row with something to write can be ticked at all',
    declOf('toggleEnrichRow').includes("r.status !== 'filled'")
    && declOf('commitEnrich').includes('r.include && r.fills'));
  check('exactness means a source id this app recognises, not merely a non-empty one',
    declOf('openEnrichModal').includes('isIsbnShape(item.source_id) || isTmdbSource(item.source_id)'));

  // The loop: capped, cancellable, one write at the end.
  const cap = Number((appSrc.match(/const ENRICH_MAX = (\d+);/) || [])[1]);
  check('a run is capped, and the cap is stated rather than silently truncating',
    cap > 0 && declOf('openEnrichModal').includes('.slice(0, ENRICH_MAX)')
    && declOf('openEnrichModal').includes('left out of this run'), String(cap));
  check('the loop runs in the browser and can be stopped, like the ISBN paste',
    declOf('runEnrich').includes('if (!enrichRunning) break;')
    && declOf('runEnrich').includes("textContent = 'Stop'"));
  check('one item failing upstream does not end the run',
    /catch \(err\) \{[\s\S]*?entry\.status = 'failed';/.test(declOf('runEnrich')));
  check('and every change lands in ONE transactional write, or none of it does',
    (declOf('commitEnrich').match(/apiFetch\(/g) || []).length === 1
    && declOf('commitEnrich').includes("'/api/media-vault/items/bulk'"));
  // items/bulk upserts the WHOLE row, so a partial object would blank every
  // column left out of it.
  check('the written row is the current one overlaid, not a partial object',
    /\{ \.\.\.row, \.\.\.r\.fills \}/.test(declOf('commitEnrich')));
  check('failures are named afterwards, and re-running them is just re-selecting them',
    declOf('commitEnrich').includes('nothing about them was changed'));

  check('the README states the never-overwrite rule and the cap',
    readme.includes('never overwrites a non-empty field')
    && readme.includes(`up to **${cap}**`)
    && readme.includes('arrive unticked'));
}
{
  // The whitelist used to be `field: [allowed, values]`, which cannot express a
  // field like `location` — there is no list of every shelf a person owns. It
  // carries a KIND now, and these checks moved with it rather than being
  // deleted: the enumerated fields must still be enumerated, and the text
  // fields must still be a closed set.
  const wl = endpointSrc['items/bulk-update.js'];
  const enumerated = [...wl.matchAll(/^  ([a-z]+): \{ values: \[/gm)].map((m) => m[1]);
  const text = [...wl.matchAll(/^  ([a-z]+): \{ text: true \}/gm)].map((m) => m[1]);
  check('bulk-update still enumerates the values of exactly type and format',
    JSON.stringify(enumerated) === '["type","format"]', enumerated.join(','));
  check('and those two are still checked against that list, not merely typed',
    wl.includes('rule.values.includes(set[f])'));
  check('the free-text fields are exactly location, series and genre',
    JSON.stringify(text) === '["location","series","genre"]', text.join(','));
  // The whole reason the other eight columns are not here. Setting every
  // selected row's title to one string has no use that is not a mistake.
  check('and nothing destructive is bulk-settable — no title, author, cover or notes',
    !['title', 'author', 'cover', 'notes'].some((f) => enumerated.includes(f) || text.includes(f)));
  check('a text field is validated as a string rather than against a value list',
    wl.includes("typeof set[f] !== 'string'"));
  // Clearing a location across a selection is a legitimate bulk edit, so the
  // validator must not reject the empty string — nothing here may test for it.
  check('and a blank value is allowed through, because clearing is a real edit',
    !/set\[f\]\s*===\s*''/.test(wl) && !/!set\[f\]\.trim\(\)/.test(wl));
  check('bulk-set text is trimmed before it is stored',
    /function cleanText\(v\) \{\r?\n\s+return v\.trim\(\)\.slice\(0, MAX_FIELD_LEN\);/.test(wl)
    && wl.includes('cleanText(set[f])'));

  // D1 binds one parameter per field, one for the email, and one per id in the
  // chunk, against a documented ceiling of 100. This is the arithmetic that
  // stops a sixth and a seventh field being added without anyone noticing the
  // chunk size has to come down with them.
  const chunk = Number((wl.match(/i \+= (\d+)/) || [])[1]);
  const worst = enumerated.length + text.length + 1 + chunk;
  check('setting every settable field at once still fits D1’s 100 bound parameters',
    Number.isFinite(chunk) && worst <= 100,
    `${enumerated.length + text.length} fields + 1 email + ${chunk} ids = ${worst}`);
  check('and the README states that sum, and the same field list',
    readme.includes(`${enumerated.length + text.length} + 1 + ${chunk}`)
    && [...enumerated, ...text].every((f) => new RegExp('^\\| `' + f + '` \\|', 'm').test(readme)),
    `README should say ${enumerated.length + text.length} + 1 + ${chunk}`);
  check('and it names what is deliberately NOT settable',
    /`title`, `author`, `cover` and `notes` are absent/.test(readme));
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
  check('and the endpoint files are exactly the seven documented',
    onDisk.length === 7, onDisk.join(' '));
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
{
  // OpenLibrary answers 200-with-an-empty-body while it is struggling, and that
  // is byte-for-byte how it answers for a book it has never catalogued — so the
  // one thing this endpoint most needs to tell apart, it could not tell apart
  // at all. It now asks twice. These pins are what stops "twice" drifting back
  // to once, or on to five, and what stops the retry ever making things worse.
  const src = endpointSrc['lookup.js'];
  const msOf = (name) => Number((src.match(new RegExp('const ' + name + ' = (\\d+);')) || [])[1]);
  const primary = msOf('ISBN_LOOKUP_MS');
  const delay = msOf('ISBN_RETRY_DELAY_MS');
  const retry = msOf('ISBN_RETRY_MS');
  const body = (src.match(/async function olSecondOpinion[\s\S]*?\r?\n\}/) || [''])[0];
  const inner = body.split('\n').slice(1).join('\n');

  check('the primary ISBN call is bounded, so a hung upstream is named rather than opaque',
    /fetchJson\(url, ISBN_LOOKUP_MS\)/.test(src) && /AbortSignal\.timeout\(timeoutMs\)/.test(src));
  check('an empty answer is asked again exactly once',
    (src.match(/olSecondOpinion\(/g) || []).length === 2);
  check('and the retry can neither loop nor call itself',
    !!body && !/\b(for|while)\b/.test(body) && !inner.includes('olSecondOpinion('));
  check('every failing path out of the retry returns null, so it can only turn a no into a yes',
    /if \(!res\.ok\) return null;/.test(body) && /catch \{\r?\n\s+return null;/.test(body));
  check('the retry is bounded too, on a tighter budget than the call it follows',
    /AbortSignal\.timeout\(ISBN_RETRY_MS\)/.test(body) && retry > 0 && retry < primary);
  // 21s is not arbitrary: it is the longest this endpoint was measured taking
  // before any retry existed. A second retry would put it back over.
  check('and the worst case stays under the 21s this endpoint was already measured taking',
    primary > 0 && delay > 0 && primary + delay + retry < 21000,
    `${primary} + ${delay} + ${retry} = ${primary + delay + retry}ms`);
  check('the client no longer tells the user to do the retry the proxy now does',
    !appSrc.includes('worth one retry') && appSrc.includes('returned nothing for it twice'));
  check('and the README’s "asks twice" and ten seconds are the numbers in the code',
    readme.includes('**asks twice**') && readme.includes('at **ten seconds**')
    && primary === 10000, `README says ten seconds; ISBN_LOOKUP_MS is ${primary}`);
}
{
  // The bulk bar is fixed-position, so nothing stops it floating over a page
  // that has no checkboxes on it. Leaving the library has to end select mode —
  // not merely hide the bar, which would restore it, still armed, on the way
  // back.
  check('leaving the library ends select mode rather than hiding the bar',
    /if \(!isLibrary && selectMode\) setSelectMode\(false\);/.test(appSrc));
  check('and every entry to select mode goes through one setter',
    /function setSelectMode\(on\)/.test(appSrc)
    && (appSrc.match(/^\s+selectMode = /gm) || []).length === 1);

  // ─── The Stats screen has no selection, deliberately ───
  // A decision, pinned so it cannot be undone by someone being helpful. The
  // ranked lists show AGGREGATES — "Brandon Sanderson · 47" — so a checkbox
  // beside one would mean selecting 47 rows the user is not looking at: the
  // off-screen-selection hazard by DESIGN rather than by accident. The lists
  // also cap at 50 entries, so any selection built from them would silently
  // miss the tail.
  //
  // The capability already exists in two clicks and does not need rebuilding:
  // a ranked row calls jumpToSearch, which lands in a filtered library view,
  // and Select All there already spans the whole filter.
  const statsHtml = readFileSync(join(appDir, 'index.html'), 'utf8');
  const statsBlock = (statsHtml.match(/<div[^>]*id="statsPage"[\s\S]*?\n<\/div>/) || [''])[0];
  check('the Stats page markup has no checkboxes, and that is a decision not an omission',
    !!statsBlock && !statsBlock.includes('type="checkbox"'));
  {
    const declOf = (name) => {
      const at = appSrc.indexOf('function ' + name + '(');
      if (at < 0) return '';
      const m = /\r?\n\}/.exec(appSrc.slice(at));
      return m ? appSrc.slice(at, at + m.index + m[0].length) : appSrc.slice(at);
    };
    const rendered = declOf('renderStats') + declOf('renderRankedList');
    check('and neither stats renderer emits one, or reads the selection at all',
      rendered.length > 0 && !/checkbox/i.test(rendered) && !rendered.includes('selectedIds'));
    // The call, with its paren, and the function it names. A bare substring
    // test passed happily when the call was renamed to `jumpToSearchDisabled`.
    check('a ranked row still routes to the filtered library, which is where selection lives',
      declOf('renderRankedList').includes('jumpToSearch(')
      && /function jumpToSearch\(/.test(appSrc));
  }
  check('and the README records the reasoning, so the decision outlives whoever made it',
    readme.includes('The Stats screen has no selection'));
}
{
  // A selection that survives a view change can be acted on while its items
  // are off screen: select everything, filter to Movies, and Delete still
  // targeted the lot. Both paths that change what is shown have to prune it.
  const declOf = (name) => {
    const at = appSrc.indexOf('function ' + name + '(');
    return at < 0 ? '' : appSrc.slice(at, at + 500);
  };
  check('changing the type filter prunes the selection to what is shown',
    declOf('setFilter').includes('pruneSelectionToView();'));
  check('and so does typing in the search box',
    declOf('resetPageAndRender').includes('pruneSelectionToView();'));
  check('and pruning refreshes the bar, so the Select All label cannot go stale',
    declOf('pruneSelectionToView').includes('updateBulkBar();'));
}
{
  // Select All spans the whole filter, not the visible page. That is the
  // asked-for behaviour and it was invisible: one click could put thousands
  // into a selection while twenty rows were on screen.
  const declOf = (name) => {
    const at = appSrc.indexOf('function ' + name + '(');
    return at < 0 ? '' : appSrc.slice(at, at + 900);
  };
  check('the page slice has one definition that the bar and the render share',
    /function getPageView\(/.test(appSrc)
    && declOf('renderLibrary').includes('getPageView()')
    && declOf('updateBulkBar').includes('getPageView()'));
  check('the bulk bar says how many of the selection are off the page',
    appSrc.includes('not on this page'));
  check('and the Select All button names how many it would take',
    /Select all \$\{inFilter\.length\}/.test(appSrc)
    && /Deselect all \$\{inFilter\.length\}/.test(appSrc));
  const threshold = appSrc.match(/const TYPE_TO_DELETE_ABOVE = (\d+);/);
  check('a big delete asks for the number to be typed, not just an OK',
    !!threshold && declOf('bulkDelete').includes('TYPE_TO_DELETE_ABOVE')
    && declOf('bulkDelete').includes('prompt('), threshold ? threshold[1] : 'no threshold');
}
{
  // A bulk delete has no undo on the server and never will: there is no
  // deleted_at column and no trash table. The whole safety net is the copy the
  // client already holds, so these are the properties that make it a net.
  // Bounded by the function's own closing brace rather than by a character
  // count. The fixed 2000-char window this replaced had a hole that pointed
  // the wrong way: a pattern falling outside it gives indexOf -1, and the
  // ordering test below reads `-1 < n` as TRUE — so the check could go on
  // passing while the property it guards was broken. It also failed for the
  // honest reason the moment the function grew past the window.
  const declOf = (name) => {
    const at = appSrc.indexOf('function ' + name + '(');
    if (at < 0) return '';
    const m = /\r?\n\}/.exec(appSrc.slice(at));
    return m ? appSrc.slice(at, at + m.index + m[0].length) : appSrc.slice(at);
  };
  {
    const bd = declOf('bulkDelete');
    const capture = bd.indexOf('library.filter((item) => selectedIds.has(item.id))');
    const destroy = bd.indexOf('library = library.filter');
    check('the deleted rows are captured before the array that held them is filtered',
      capture >= 0 && destroy >= 0 && capture < destroy,
      capture < 0 ? 'the capture is gone' : destroy < 0 ? 'the filter is gone' : 'the capture happens after it');
  }
  check('and the restore goes through the upsert endpoint that round-trips ids',
    declOf('undoBulkDelete').includes("'/api/media-vault/items/bulk'"));
  check('the undo buffer never reaches localStorage',
    !/undo/i.test(appSrc.slice(appSrc.indexOf('migrateLocalIfNeeded')).slice(0, 1200))
    && !/localStorage/.test(declOf('undoBulkDelete') + declOf('offerUndo') + declOf('cancelUndo')));
  const window_ = appSrc.match(/const UNDO_WINDOW_SECONDS = (\d+);/);
  check('the window is a stated number of seconds', !!window_,
    window_ ? window_[1] : 'not found');
  check('and the toast admits that leaving the page finishes the delete',
    appSrc.includes('Closing this page will finish the delete'));
  check('a failed restore keeps the buffer for one retry, then names what was lost',
    declOf('undoBulkDelete').includes('undoFailures >= 2')
    && declOf('undoBulkDelete').includes('items are gone'));
  check('the README states the undo window and that a reload finishes the delete',
    /\*\*10 seconds\*\*/.test(readme)
    && readme.includes('Closing this page will')
    && readme.includes('memory only'));

  // The server counts the rows it really changed. Throwing that number away
  // and rewriting the client's copy regardless is how a screen goes quietly
  // wrong, which is the one failure this app was rebuilt to end.
  check('apiWrite hands the response body back instead of a bare true',
    /const body = await fn\(\);/.test(declOf('apiWrite'))
    && /return body == null \? true : body;/.test(declOf('apiWrite')));
  // The compatibility hinge. Without it an endpoint answering 200 with no body
  // reads as a failure at all eight call sites, aborting a write that worked.
  check('and a success can never come back falsy, whatever the endpoint answers',
    !declOf('apiWrite').includes('return body;'));
  check('the two endpoints that measure their own work are both compared against',
    declOf('bulkSet').includes('agreesWithServer(res, ids.length)')
    && declOf('bulkDelete').includes('agreesWithServer(res, ids.length)'));
  check('a disagreement re-reads the library rather than alerting',
    declOf('agreesWithServer').includes("apiFetch('/api/media-vault/items')")
    && declOf('agreesWithServer').includes('library = data.items;')
    && !declOf('agreesWithServer').includes('alert('));
  // The one that matters: `removed` names rows the server says it did not
  // delete, so restoring it would resurrect what another tab threw away.
  check('and a short delete count withdraws the undo instead of offering it',
    /if \(!await agreesWithServer\(res, ids\.length\)\) \{[\s\S]*?return;\r?\n  \}/.test(declOf('bulkDelete'))
    && declOf('bulkDelete').indexOf('agreesWithServer')
       < declOf('bulkDelete').indexOf('offerUndo(removed)'));
  check('the paths whose count is only an echo of the request are left alone',
    !declOf('undoBulkDelete').includes('agreesWithServer')
    && /count` is an echo/.test(appSrc));
  check('and the README says both that the counts are compared and that Undo is withdrawn',
    readme.includes('fewer rows than it named')
    && readme.includes('withdraws the Undo')
    && readme.includes('echo of the request'));
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
  // The modal's own Cancel sits beside this button. Two adjacent controls
  // reading 'Cancel' and doing different things is a coin toss for the user.
  check('the in-flight stop control is not a second button called Cancel',
    appSrc.includes("lookupBtn.textContent = 'Stop'")
    && !/lookupBtn\.textContent = 'Cancel'/.test(appSrc));
}

// ---------- 7. The duplicate scanner ----------
// The library it was written against holds 662 rows that share a title and a
// type with another row. Three of eight sampled author-disagreeing groups were
// separate works — Candyman (1992) and Candyman (2021), two unrelated novels
// called Burned — so the property that matters most here is not how much it
// finds. It is what it refuses to decide.
section('The duplicate scanner');

{
  const p = planDedupe([
    item({ id: 'a', title: 'Dune', type: 'movie' }),
    item({ id: 'b', title: 'Dune', type: 'audiobook' }),
    item({ id: 'c', title: 'Solaris', type: 'movie' }),
  ]);
  check('a library with nothing repeated produces no groups at all',
    p.groups.length === 0 && p.removable === 0);
  check('and the paperback and the audiobook of one title are not a repeat',
    p.scanned === 3);
}
{
  const rows = [
    item({ id: 'a', title: 'Dune', type: 'movie', addedAt: 20 }),
    item({ id: 'b', title: 'DUNE', type: 'movie', addedAt: 10 }),
  ];
  const g = planDedupe(rows).groups[0];
  check('a title differing only in case is the same group',
    !!g && g.loserIds.length === 1);
  check('and it is keyed exactly as the migration keys it, so the two can never disagree',
    g.key === mergeKey({ title: 'Dune', type: 'movie' }));
  check('the earliest row survives, so addedAt still answers when this entered the library',
    g.survivorId === 'b' && g.loserIds[0] === 'a');
}
{
  // CSV import stamps one Date.now() across every row it creates, so a whole
  // import shares a millisecond. Without the id tie-break the survivor would be
  // whichever row the database happened to return first.
  const tied = [
    item({ id: 'zz', title: 'Dune', type: 'movie', addedAt: 5 }),
    item({ id: 'aa', title: 'Dune', type: 'movie', addedAt: 5 }),
  ];
  check('rows added in the same millisecond still pick one survivor, deterministically',
    dupSurvivor(tied).id === 'aa' && dupSurvivor(tied.slice().reverse()).id === 'aa');
}
{
  const g = planDedupe([
    item({ id: 'a', title: 'Dune', type: 'movie', author: 'Villeneuve', addedAt: 1 }),
    item({ id: 'b', title: 'Dune', type: 'movie', author: 'Villeneuve', addedAt: 2 }),
  ]).groups[0];
  check('a byte-identical pair is marked identical and fills nothing',
    g.tier === 'identical' && Object.keys(g.fills).length === 0 && g.include);
}
{
  const g = planDedupe([
    item({ id: 'a', title: 'Dune', type: 'movie', author: 'Villeneuve', addedAt: 1 }),
    item({ id: 'b', title: 'Dune', type: 'movie', genre: 'Sci-Fi', cover: 'http://x/y.jpg', addedAt: 2 }),
  ]).groups[0];
  check('empty-versus-filled is not a disagreement, it is the merge doing its job',
    g.tier === 'mergeable' && g.include && g.conflicts.length === 0);
  check('and the blanks on the survivor are filled from the row that is about to go',
    g.fills.genre === 'Sci-Fi' && g.fills.cover === 'http://x/y.jpg');
  check('while a field the survivor already answered is never rewritten',
    !('author' in g.fills));
}
{
  // The one this feature exists to get right.
  const g = planDedupe([
    item({ id: 'a', title: 'Candyman', type: 'movie', author: 'Bernard Rose', addedAt: 1 }),
    item({ id: 'b', title: 'Candyman', type: 'movie', author: 'Nia DaCosta', addedAt: 2 }),
  ]).groups[0];
  check('two works that share a title and a type are flagged, never merged',
    g.tier === 'conflict' && g.include === false);
  check('and the group names the field and quotes BOTH values, because that is the decision',
    g.conflicts.length === 1 && g.conflicts[0].field === 'author'
    && g.conflicts[0].values.join(' vs ') === 'Bernard Rose vs Nia DaCosta');
}
{
  // Ticking a conflicting group is allowed — it is the user's call — and even
  // then the surviving row cannot lose anything it already said.
  const g = planDedupe([
    item({ id: 'a', title: 'Candyman', type: 'movie', author: 'Bernard Rose', addedAt: 1 }),
    item({ id: 'b', title: 'Candyman', type: 'movie', author: 'Nia DaCosta', genre: 'Horror', addedAt: 2 }),
  ]).groups[0];
  check('accepting a conflict can only discard the losing rows, never rewrite the surviving one',
    !('author' in g.fills) && g.fills.genre === 'Horror');
}
{
  const g = planDedupe([
    item({ id: 'a', title: 'Dune', type: 'movie', author: 'Hamilton Wright Mabie', addedAt: 1 }),
    item({ id: 'b', title: 'Dune', type: 'movie', author: 'hamilton wright mabie ', addedAt: 2 }),
  ]).groups[0];
  check('case and stray space are not a disagreement between two spellings of one name',
    g.tier === 'mergeable' && g.conflicts.length === 0);
}
{
  const noisy = planDedupe([
    item({ id: 'a', title: 'Dune', type: 'movie', genre: 'Sci-Fi', cover: 'a.jpg', addedAt: 1 }),
    item({ id: 'b', title: 'Dune', type: 'movie', genre: 'Adventure', cover: 'b.jpg', addedAt: 2 }),
  ]).groups[0];
  check('genre and cover disagreeing does NOT make a group need review',
    noisy.tier === 'mergeable' && noisy.include && noisy.conflicts.length === 0);
  check('and the survivor keeps its own genre and cover rather than taking the other',
    Object.keys(noisy.fills).length === 0);

  const sourced = planDedupe([
    item({ id: 'a', title: 'Candyman', type: 'movie', source_id: 'tmdb:movie:9529', addedAt: 1 }),
    item({ id: 'b', title: 'Candyman', type: 'movie', source_id: 'tmdb:movie:505262', addedAt: 2 }),
  ]).groups[0];
  check('but two different source ids are the strongest proof there is that these differ',
    sourced.tier === 'conflict' && !sourced.include);
}
{
  const p = planDedupe([
    item({ id: 'a', title: 'Deadpool', type: 'movie', addedAt: 1 }),
    item({ id: 'b', title: 'Deadpool', type: 'movie', addedAt: 2 }),
    item({ id: 'c', title: 'Deadpool', type: 'movie', addedAt: 3 }),
  ]);
  check('a group of three gives up two rows',
    p.groups.length === 1 && p.groups[0].loserIds.length === 2);
  check('and the count reported is rows, not groups — the number the user is about to lose',
    p.removable === 2);
}
{
  const p = planDedupe([
    item({ id: 'a', title: 'Zebra', type: 'movie', addedAt: 1 }),
    item({ id: 'b', title: 'Zebra', type: 'movie', addedAt: 2 }),
    item({ id: 'c', title: 'Apple', type: 'movie', author: 'One', addedAt: 1 }),
    item({ id: 'd', title: 'Apple', type: 'movie', author: 'Two', addedAt: 2 }),
  ]);
  check('conflicts sort to the top, so the decisions are not below hundreds of safe rows',
    p.groups[0].tier === 'conflict' && p.groups[0].title === 'Apple');
}
{
  check('the two field lists agree about what a merge may carry',
    DUP_BLOCKING_FIELDS.every((f) => DUP_MERGE_FIELDS.includes(f)),
    DUP_BLOCKING_FIELDS.filter((f) => !DUP_MERGE_FIELDS.includes(f)).join(','));
  check('and neither list contains the fields that ARE the key',
    !DUP_MERGE_FIELDS.includes('title') && !DUP_MERGE_FIELDS.includes('type'));
  check('genre and cover are the only fields a merge treats as noise',
    DUP_MERGE_FIELDS.filter((f) => !DUP_BLOCKING_FIELDS.includes(f)).join(',') === 'genre,cover');
  check('the rule is defined once rather than copied into the client',
    !appSrc.includes('DUP_BLOCKING_FIELDS') && !/function planDedupe\(/.test(appSrc));
}
{
  // The scanner finds and explains. Applying a group goes through the two
  // endpoints that already exist, already batch as transactions and already
  // feed the undo buffer — a second way to delete rows in bulk is exactly what
  // this app was rebuilt to stop having.
  const src = endpointSrc['duplicates.js'];
  check('the scan endpoint only ever reads',
    !/DELETE|INSERT|UPDATE/.test(src) && !src.includes('onRequestPost')
    && !src.includes('onRequestDelete') && src.includes('onRequestGet'));
  check('and it decides in the pure planner rather than in the handler',
    src.includes('planDedupe') && src.includes('_lib/dedupe.js'));
}
{
  const declOf = (name) => {
    const at = appSrc.indexOf('function ' + name + '(');
    if (at < 0) return '';
    const m = /\r?\n\}/.exec(appSrc.slice(at));
    return m ? appSrc.slice(at, at + m.index + m[0].length) : appSrc.slice(at);
  };
  const cd = declOf('commitDuplicates');
  check('the client applies a group through the endpoints that already exist',
    cd.includes("'/api/media-vault/items/bulk'")
    && cd.includes("'/api/media-vault/items/bulk-delete'"));
  // THE ORDERING BUG THIS EXISTS TO CATCH: delete first and a failure between
  // the two calls destroys the only copy of every field the merge was carrying.
  check('and it writes the merged survivors BEFORE deleting the rows they inherit from',
    cd.indexOf("items/bulk'") >= 0
    && cd.indexOf("items/bulk'") < cd.indexOf('items/bulk-delete'));
  check('the undo buffer carries the survivor as it was before the merge, not just the deletions',
    cd.includes('restore.push({ ...survivor })') && cd.includes('restore.push(...losers)'));
  check('a short delete count withdraws the undo here too',
    cd.includes('agreesWithServer(res, ids.length)')
    && cd.indexOf('agreesWithServer') < cd.indexOf('offerUndo('));
  check('and the toast says what really happened rather than borrowing the delete sentence',
    cd.includes('offerUndo(restore,') && /Merged \$\{chosen\.length\}/.test(cd));
  // Caught by driving it rather than by reading it: the buffer stopped being
  // "rows that are gone" the moment a merge put an EDITED row in it, and a
  // blind push then held the same id twice — a duplicate of the thing the user
  // had just finished de-duplicating.
  check('the restore replaces by id and appends only what is genuinely missing',
    declOf('undoBulkDelete').includes('library.map((i) => back.get(i.id) || i)')
    && !/library\.push\(\.\.\.rows\);/.test(appSrc));
  check('the head count is rebuilt on every tick, so it cannot lag the checkbox',
    declOf('toggleDupGroup').includes('renderDuplicateResults()'));
  check('a group naming a row this tab no longer holds is dropped before it can be rendered',
    declOf('runDuplicateScan').includes('library.some((i) => i.id === g.survivorId)'));
  check('nothing is written by opening the scanner',
    !declOf('runDuplicateScan').includes('apiWrite'));
}
{
  check('the README documents the scanner and the key it groups by',
    readme.includes('`/api/media-vault/duplicates`') && readme.includes('`planDedupe`'));
  check('and says plainly that a shared title is not proof of a duplicate',
    readme.includes('Candyman'));
  check('the README names the two fields a merge treats as noise',
    /`genre` and `cover`/.test(readme));
  check('and states that the merge never overwrites a value that is already there',
    readme.includes('never overwrites'));
}

process.exit(summary() === 0 ? 0 : 1);
