// Class tags: the vocabulary in js/parser.js, the validator's refusals, the
// derived half, the backfill script's review table and data script, and the
// two places the wizard depends on the vocabulary's ids by spelling (the
// guided quiz's answers and the filter box's searched field).

import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { DatabaseSync } from 'node:sqlite';
import { appDir, check, section, wantSection } from '../harness.mjs';
import { CLASS_TAGS, MAX_AUTHORED_TAGS, classTags, suggestClassTags, parseClassMarkdown } from '../../js/parser.js';
import { reviewTable, parseReview, emitSql } from '../../../../scripts/class-tags-lib.mjs';

// Declared so a --section run can skip the module without reading it.
const SECTIONS = ['Class tags'];

const md = (extra = '', category = 'occ') =>
  `---\nid: x\nname: X\nsystem: rifts\nsource_book: B\ncategory: ${category}\n${extra}---\n\n## Lore\n\nA class.\n`;

export function run() {
  if (!SECTIONS.some(wantSection)) return;

  section('Class tags');

  // ── the vocabulary ──
  const ids = CLASS_TAGS.map((t) => t.id);
  check('every class tag id is unique', new Set(ids).size === ids.length);
  check('every class tag id is kebab-case', ids.every((id) => /^[a-z][a-z-]*$/.test(id)), ids.join(', '));
  check('every class tag has a label, a hint and a kind',
    CLASS_TAGS.every((t) => t.label && t.hint && ['derived', 'authored'].includes(t.kind)));
  check('the derived tags are exactly the four with a rule',
    CLASS_TAGS.filter((t) => t.kind === 'derived').map((t) => t.id).join(',')
      === 'magic,psionics,mega-damage,horror-factor');

  // ── the derived half ──
  check('a magic block derives magic', classTags({ magic: { type: 'spell' } }).includes('magic'));
  check('magic type none derives nothing', !classTags({ magic: { type: 'none' } }).includes('magic'));
  check('a psionics block derives psionics', classTags({ psionics: { type: 'minor' } }).includes('psionics'));
  check('mdc_base derives mega-damage', classTags({ mdc_base: '1d6x10' }).includes('mega-damage'));
  check('horror_factor derives horror-factor', classTags({ horror_factor: 12 }).includes('horror-factor'));
  check('a class with none of those derives no tag', classTags({ name: 'Vagabond' }).length === 0);
  check('classTags returns vocabulary order and drops ids it does not know',
    classTags({ tags: ['stealth', 'nonsense', 'combat'], magic: { type: 'spell' } }).join(',') === 'magic,combat,stealth');
  check('a derived id written on a class with no block for it counts',
    classTags({ tags: ['magic'] }).includes('magic'));
  // A block on a variant is one the class can have: the dragons state their
  // horror factor per age stage, and nothing at the top.
  check('a variant\'s block derives the tag',
    classTags({ variants: [{ id: 'hatchling' }, { id: 'adult', horror_factor: 14 }] }).includes('horror-factor')
      && classTags({ variants: [{ id: 'full', mdc_base: '300' }] }).includes('mega-damage'));

  // ── the validator ──
  // A refusal here is a class MISSING from production's picker (class-store.js
  // drops a class that fails to parse), which is why --emit checks first.
  const v = (extra) => parseClassMarkdown(md(extra));
  check('tags: a valid list parses clean', v('tags: [stealth, wilderness]\n').errors.length === 0
    && v('tags: [stealth, wilderness]\n').data.tags.join(',') === 'stealth,wilderness');
  check('tags: an unknown tag is refused', v('tags: [stealthy]\n').errors.some((e) => e.includes('stealthy')));
  check('tags: a derived tag its own block already derives is refused',
    v('tags: [magic]\nmagic: { type: "spell" }\n').errors.some((e) => e.includes('already derive')));
  check('tags: a derived tag a variant already derives is refused',
    v('tags: [horror-factor]\nvariants:\n  - { id: adult, name: Adult, horror_factor: 12 }\n').errors.some((e) => e.includes('already derive')));
  check('tags: a derived tag on a class with no block for it warns and parses',
    v('tags: [magic]\n').ok && v('tags: [magic]\n').warnings.some((w) => w.includes('no block')));
  check('tags: a scalar is refused', v('tags: stealth\n').errors.some((e) => e.includes('one-line list')));
  check(`tags: more than ${MAX_AUTHORED_TAGS} warns and still parses`,
    v('tags: [combat, ranged, stealth, scholar, tech]\n').ok
      && v('tags: [combat, ranged, stealth, scholar, tech]\n').warnings.some((w) => w.includes('fewer')));
  check('tags: a repeated tag warns', v('tags: [combat, combat]\n').warnings.some((w) => w.includes('twice')));

  // ── suggestions ──
  const sug = suggestClassTags({ name: 'City Rat', category: 'occ', occ_group: 'men-of-arms' });
  check('suggestions are authored tags only',
    sug.every((t) => CLASS_TAGS.find((x) => x.id === t)?.kind === 'authored'), sug.join(','));
  check('a men-of-arms O.C.C. is suggested combat', sug.includes('combat'));
  check('beginner is never suggested', !suggestClassTags({ name: 'Beginner Vagabond', category: 'occ' }).includes('beginner'));

  // ── the backfill script's review table and data script ──
  const classes = [
    { id: 'aaa', name: 'A', category: 'occ', source_book: 'B p.1', occ_group: 'men-of-arms' },
    { id: 'bbb', name: 'B', category: 'rcc', source_book: 'B p.2', tags: ['flyer'], mdc_base: '1d6' },
  ];
  const table = reviewTable(classes, { system: 'rifts' });
  const back = parseReview(table);
  check('a review table reads back without errors', back.errors.length === 0, back.errors.join('; '));
  check('a review table shows a class\'s own tags over a guess',
    back.rows.find((r) => r.class_id === 'bbb')?.tags.join(',') === 'flyer');
  check('the derived column carries the derived tags', /\| bbb \|.*\| mega-damage \| flyer \|/.test(table));
  check('a review table naming a tag its derived column holds is refused',
    parseReview(table.replace(/\| flyer \|$/m, '| flyer, mega-damage |')).errors.some((e) => e.includes('mega-damage')));
  check('a review table may name a derived tag its derived column lacks',
    parseReview(table.replace(/\| flyer \|$/m, '| flyer, magic |')).errors.length === 0);
  check('a review table over the limit is refused',
    parseReview(table.replace(/\| flyer \|$/m, '| flyer, combat, ranged, stealth, scholar |')).errors.length > 0);
  let threw = false;
  try { emitSql(back.rows, { filename: 'fix-class-tags-rifts.sql' }); } catch { threw = true; }
  check('a class-tags script must be a tilde script', threw);

  // The emitted SQL, run against a real SQLite: the line lands after category,
  // the class re-parses with the tags, a second run is a no-op, and the
  // script's own read-back assertion holds.
  const sql = emitSql(back.rows, { filename: '~999-class-tags-rifts.sql', system: 'rifts' });
  const db = new DatabaseSync(':memory:');
  db.exec('CREATE TABLE imported_classes (class_id TEXT, markdown TEXT, updated_at TEXT);'
    + 'CREATE TABLE data_script_runs (filename TEXT);');
  const ins = db.prepare('INSERT INTO imported_classes (class_id, markdown) VALUES (?, ?)');
  ins.run('aaa', md('occ_group: men-of-arms\n').replace('id: x', 'id: aaa'));
  ins.run('bbb', md('', 'rcc').replace('id: x', 'id: bbb'));
  const readback = () => db.prepare(sql.slice(sql.indexOf('SELECT'), sql.indexOf(';', sql.indexOf('SELECT')) + 1)).get();
  db.exec(sql);
  const after = db.prepare("SELECT markdown FROM imported_classes WHERE class_id = 'aaa'").get().markdown;
  check('the emitted script puts tags right after category',
    after.includes('\ncategory: occ\ntags: [combat]\n'), after.slice(0, 120));
  check('the tagged class re-parses with its tags',
    parseClassMarkdown(after).data?.tags?.join(',') === 'combat' && parseClassMarkdown(after).errors.length === 0);
  const rb = readback();
  check('the emitted script\'s read-back holds', String(rb?.got) === String(rb?.want), JSON.stringify(rb));
  db.exec(sql.replace(/INSERT INTO data_script_runs[^;]*;/, ''));
  const twice = db.prepare("SELECT markdown FROM imported_classes WHERE class_id = 'aaa'").get().markdown;
  check('the emitted script is a no-op on a second run', twice === after);

  // ── the wizard's dependencies on the ids ──
  const app = readFileSync(join(appDir, 'app.js'), 'utf8');
  const quiz = app.slice(app.indexOf('const QUIZ = ['), app.indexOf('];', app.indexOf('const QUIZ = [')));
  const answerLines = quiz.split('\n').filter((l) => /q: 'How do you want|q: 'What else/.test(l));
  const answers = answerLines.flatMap((l) => [...l.matchAll(/\['([a-z-]+)', '/g)].map((m) => m[1]));
  check('the guided quiz has its two tag questions', answerLines.length === 2 && answers.length >= 8, answers.join(','));
  check('every guided-quiz tag answer is a class tag id', answers.every((a) => ids.includes(a)),
    answers.filter((a) => !ids.includes(a)).join(', '));
  check('a resumed draft\'s quiz answers are validated', /S\.quiz = validQuiz\(S\.quiz\);/.test(app));
  const picker = readFileSync(join(appDir, 'js', 'picker.js'), 'utf8');
  check('the filter box searches _tag_text, and the wizard writes it',
    /FIELDS = \[[^\]]*'_tag_text'/.test(picker) && app.includes('c._tag_text = classTags(c)'));
}
