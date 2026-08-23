// Pull the stat block and description for named spells out of the Palladium
// Fantasy main book's Wizard Spell Descriptions, printed 189-218.
//
//   python scripts/read-columns.py "<book>.pdf" 191 220 > desc.txt
//   node scripts/parse-pf-spell-descriptions.mjs desc.txt index.json out.json
//
// Every entry has the same shape: a heading line carrying the spell's name,
// then some subset of Range / Duration / Saving Throw / Limitations / Damage /
// P.P.E., then prose until the next heading.
//
// The heading is found by looking BACKWARDS from each `Range:` line rather than
// by trying to recognise a title, which is the thing that cannot be done
// reliably: a title is just a short line, and so is the last line of the
// previous paragraph. Anchoring on the field that is always there and always
// spelled the same way removes the guess.
//
// The names come from the INDEX, not from the headings - the index is the
// authority, and a heading is set differently often enough to matter
// ("Invulnerability (limited)" against the index's "Invulnerability: Limited").
import { readFileSync, writeFileSync } from 'node:fs';

const [descPath, indexPath, outPath, namesPath] = process.argv.slice(2);
// A newline-delimited file rather than argv: these names carry spaces,
// ampersands and apostrophes, and passing them through a shell mangles all
// three.
const lines = readFileSync(descPath, 'utf8').split('\n').map((l) => l.replace(/\r$/, '').trim());
const index = JSON.parse(readFileSync(indexPath, 'utf8'));
const want = namesPath
  ? readFileSync(namesPath, 'utf8').split(/\r?\n/).map((l) => l.trim()).filter(Boolean)
  : [];

const norm = (s) => String(s).toLowerCase().replace(/&/g, 'and')
  .replace(/[^a-z0-9 ]+/g, ' ').replace(/\s+/g, ' ').trim();

// `Level:` appears only on the Spells of Legend, the entries that sit outside
// the numbered ladder and say so on their own page. It has to be here or the
// walk back to the heading stops on it and calls it the title - which is
// exactly what happened to The Finger of Lictalon and Metamorphosis: Dragon,
// the only two blocks that failed to match.
const FIELD = /^(Level|Range|Duration|Saving Throw|Savings Throw|Limitations|Damage|Area of Effect|Casting Time|Weight|P\.?\s?P\.?\s?E\.?)\s*:\s*(.*)$/i;
const PAGE = /^\d{1,3}$/;

// Every block starts at a `Range:` line. Walk up from it for the heading:
// the nearest preceding non-empty line that is not itself a field and not a
// bare page number.
const blocks = [];
for (let i = 0; i < lines.length; i++) {
  if (!/^Range\s*:/i.test(lines[i])) continue;
  let h = i - 1;
  while (h >= 0 && (!lines[h] || FIELD.test(lines[h]) || PAGE.test(lines[h])
                    || /^=+ p\d+ =+$/.test(lines[h]))) h--;
  if (h < 0) continue;
  blocks.push({ heading: lines[h], start: i, headingLine: h });
}
// Each block ends where the next one's heading begins.
for (let b = 0; b < blocks.length; b++) {
  blocks[b].end = b + 1 < blocks.length ? blocks[b + 1].headingLine : lines.length;
}

// The stat block runs from the heading to the P.P.E. line, and everything after
// that is prose. Anchoring the END on P.P.E. rather than on "the first line
// that does not look like a field value" is what makes wrapped values safe: a
// Saving Throw running to four lines, as Immobilize's does, used to start the
// prose early and then read the P.P.E. line itself as prose.
function readBlock(b) {
  const fields = {};
  const prose = [];
  let current = null;
  let inBlock = true;
  for (let i = b.headingLine + 1; i < b.end; i++) {
    const line = lines[i];
    if (!line || PAGE.test(line) || /^=+ p\d+ =+$/.test(line)) continue;
    // The description pages carry the by-level SECTION HEADINGS too, sitting
    // between one spell's prose and the next spell's title. Left in, they get
    // welded onto the end of whichever description precedes them - Ventriloquism
    // ended "...at a 90% proficiency. Level Two".
    // Some carry a run of decorative glyphs after the words, which is why this
    // allows a non-word tail rather than anchoring on the heading alone:
    // X-Ray Vision's description ended "...one foot of metal. Level Eight" plus
    // seven ornaments.
    if (/^Level (One|Two|Three|Four|Five|Six|Seven|Eight|Nine|Ten|Eleven|Twelve|Thirteen|Fourteen|Fifteen)\W*$/i.test(line)) continue;
    if (/^Spells? of Legend\W*$/i.test(line)) continue;
    if (inBlock) {
      const m = FIELD.exec(line);
      if (m) {
        let key = m[1].toLowerCase().replace(/[^a-z]/g, '');
        if (key === 'savingsthrow') key = 'savingthrow';
        fields[key] = m[2].trim();
        current = key;
        // A P.P.E. value is always short and always last in the block.
        if (key === 'ppe') inBlock = false;
        continue;
      }
      if (current) { fields[current] += ' ' + line; continue; }
    }
    prose.push(line);
  }
  // The text layer keeps the hyphen a word was broken across at the end of a
  // column line. It has to be undone in the FIELD values too, not only in the
  // prose: a wrapped Duration came out "one year per level of expe- rience".
  const dehyphen = (s) => s.replace(/(\w)-\s+(\w)/g, '$1$2').replace(/\s+/g, ' ').trim();
  for (const k of Object.keys(fields)) fields[k] = dehyphen(fields[k]);
  const description = dehyphen(prose.join(' '));
  return { fields, description };
}

const byName = new Map();
for (const b of blocks) byName.set(norm(b.heading), b);

const wantSet = new Set(want.map(norm));
const targets = want.length ? index.filter((e) => wantSet.has(norm(e.name))) : index;
const notInIndex = want.filter((n) => !index.some((e) => norm(e.name) === norm(n)));
if (notInIndex.length) console.log(`NOT IN THE INDEX AT ALL: ${notInIndex.join(', ')}`);
const out = [];
const unmatched = [];
for (const e of targets) {
  let b = byName.get(norm(e.name));
  // The heading is often set differently from the index entry. Fall back to a
  // heading that STARTS with the index name, or whose words are a subset -
  // "Invulnerability (limited)" for "Invulnerability: Limited". Reported either
  // way, because a fallback that fires silently is how a wrong block gets
  // attached to a right name.
  let via = 'exact';
  if (!b) {
    const n = norm(e.name);
    let cand = [...byName.entries()].filter(([k]) => k.startsWith(n) || n.startsWith(k));
    // Last resort: a heading that CONTAINS the index name - "The Finger of
    // Lictalon" for "Finger of Lictalon". Only when exactly one does, and
    // always reported.
    if (!cand.length) cand = [...byName.entries()].filter(([k]) => k.includes(n));
    if (cand.length === 1) { b = cand[0][1]; via = `heading "${b.heading}"`; }
  }
  if (!b) { unmatched.push(e.name); continue; }
  const { fields, description } = readBlock(b);
  out.push({ name: e.name, level: e.level, ppe: e.ppe, page: e.page, heading: b.heading, via,
    level_on_page: fields.level ?? null,
    range: fields.range ?? null, duration: fields.duration ?? null,
    saving_throw: fields.savingthrow ?? null, damage: fields.damage ?? null,
    area_of_effect: fields.areaofeffect ?? null, casting_time: fields.castingtime ?? null,
    limitations: fields.limitations ?? null, ppe_in_block: fields.ppe ?? null,
    description });
}

console.log(`blocks found: ${blocks.length}   requested: ${targets.length}   matched: ${out.length}`);
if (unmatched.length) console.log(`NO DESCRIPTION BLOCK: ${unmatched.join(', ')}`);
const viaFallback = out.filter((o) => o.via !== 'exact');
if (viaFallback.length) {
  console.log(`\nmatched through a differently-set heading (${viaFallback.length}):`);
  for (const o of viaFallback) console.log(`  ${o.name}  <-  ${o.via}`);
}
const thin = out.filter((o) => !o.description || o.description.length < 60);
if (thin.length) console.log(`\nTHIN OR EMPTY DESCRIPTION: ${thin.map((o) => o.name).join(', ')}`);
const noPpe = out.filter((o) => !o.ppe_in_block);
if (noPpe.length) console.log(`\nNO P.P.E. LINE IN THE BLOCK: ${noPpe.map((o) => o.name).join(', ')}`);

// The index is the authority on level and page position is not - but a page
// that STATES a level is a second independent reading, and where the two
// differ somebody is wrong and it is worth finding out who.
const levelFight = out.filter((o) => o.level_on_page
  && !(o.level === 'legend' && /legend/i.test(o.level_on_page))
  && !new RegExp('\\b' + o.level + '\\b', 'i').test(o.level_on_page));
if (levelFight.length) {
  console.log(`\nTHE PAGE STATES A LEVEL AND THE INDEX DISAGREES (${levelFight.length}):`);
  for (const o of levelFight) {
    console.log(`  ${o.name}: index says ${o.level}, printed ${o.page} says "${o.level_on_page}"`);
  }
}

writeFileSync(outPath, JSON.stringify(out, null, 1));
console.log(`\nwrote ${out.length} to ${outPath}`);
