// The Palladium Sourcebooks page's list (apps/sourcebooks/palladium/books.json)
// is what scripts/sourcebooks.mjs builds from the surveys today.
//
// A book PR moves its survey's Status and Rows lines, and nothing else would
// notice that the committed list no longer says so: the page reads the file,
// not the surveys. So a fresh build is compared with the committed file, and a
// stale one fails here, in the book's own group's suite. The Marvel list is
// held the same way by the Marvel suite.

import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { repoRoot, check, section, wantSection } from '../harness.mjs';
import { buildPalladium, stale } from '../../../../scripts/sourcebooks.mjs';

// Declared so a --section run can skip the module without reading it.
const SECTIONS = ['Sourcebooks: the Palladium list is the surveys\' own'];

export function run() {
  if (!SECTIONS.some(wantSection)) return;

  section('Sourcebooks: the Palladium list is the surveys\' own');

  const list = buildPalladium();
  const slugs = list.books.map((b) => b.slug);
  // The filter, on books whose status is known and will not move: an excluded
  // book and a backfilled one, so a filter that kept everything or dropped a
  // status cannot pass by finding nothing to compare.
  check('the list keeps a backfilled book (bom) and leaves an excluded one out (powers-unlimited-2)',
    slugs.includes('bom') && !slugs.includes('powers-unlimited-2'), slugs.join());
  check('every listed book is imported or backfilled, with a title and a count',
    list.books.length > 0 && list.books.every((b) => ['imported', 'backfilled'].includes(b.status) && b.title && b.total > 0),
    list.books.filter((b) => !b.total).map((b) => b.slug).join());
  const why = stale('palladium');
  check('apps/sourcebooks/palladium/books.json is a fresh build (run node scripts/sourcebooks.mjs after a book PR moves a survey)',
    why === null, why || '');
  const manifest = JSON.parse(readFileSync(join(repoRoot, 'apps', 'manifest.json'), 'utf8'));
  const tile = manifest.apps.find((a) => a.slug === 'sourcebooks/palladium');
  check('the hub has a live Sourcebooks tile in the Palladium section',
    tile?.status === 'live' && tile.group === 'palladium' && /^<svg /.test(tile.icon || ''), JSON.stringify(tile?.group));
}
