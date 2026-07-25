// Phase 1 smoke test: (1) the RCC/OCC markdown files parse correctly,
// (2) the D1 schema migrates cleanly into a local D1 instance.
// Run from anywhere:  node apps/character-creator/test/smoke.mjs

import { readFileSync, writeFileSync, rmSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { parseClassMarkdown } from '../js/parser.js';

const appDir = join(dirname(fileURLToPath(import.meta.url)), '..');
let failures = 0;

function check(label, cond, detail) {
  if (cond) {
    console.log('  ok  ' + label);
  } else {
    failures++;
    console.error('  FAIL ' + label + (detail ? ' — ' + detail : ''));
  }
}

function parseFile(name) {
  return parseClassMarkdown(readFileSync(join(appDir, 'data', 'classes', name), 'utf8'));
}

// ---------- 1. Parser ----------
console.log('\n[1/2] Parser');

const ck = parseFile('cyber-knight.md');
check('cyber-knight parses', ck.ok, JSON.stringify(ck.errors));
check('cyber-knight core fields', ck.data.id === 'cyber-knight' && ck.data.system === 'rifts' && ck.data.category === 'occ');
check('attribute_requirements map', ck.data.attribute_requirements?.ME === 12 && ck.data.attribute_requirements?.MA === 12);
check('occ_skills inline objects', ck.data.skills?.occ_skills?.length === 7 && ck.data.skills.occ_skills[0].name === 'Radio: Basic' && ck.data.skills.occ_skills[0].base === 40);
check('occ_related_skills count/categories', ck.data.skills?.occ_related_skills?.count === 6 && ck.data.skills.occ_related_skills.categories.includes('Espionage'));
check('equipment_starting', ck.data.equipment_starting?.length === 3 && ck.data.equipment_starting[0].item_id === 'ns-turbo-cyclone');
check('psionics block', ck.data.psionics?.type === 'major' && ck.data.psionics?.isp_base === '1d4x10+20');
check('special_abilities block-form list', ck.data.special_abilities?.length === 2 && ck.data.special_abilities[0].name === 'Psi-Sword');
check('level_progression', ck.data.level_progression?.length === 3 && ck.data.level_progression[2].grants.length === 2);
check('lore + gm_notes sections', !!ck.data.lore?.includes('Cyber-Knights') && !!ck.data.gm_notes?.includes('Code of Chivalry'));

const lb = parseFile('long-bowman.md');
check('long-bowman parses', lb.ok, JSON.stringify(lb.errors));
check('palladium-fantasy system', lb.data.system === 'palladium-fantasy' && lb.data.category === 'occ');
check('secondary_skills count', lb.data.skills?.secondary_skills?.count === 4);

const dh = parseFile('dragon-hatchling.md');
check('dragon-hatchling parses', dh.ok, JSON.stringify(dh.errors));
check('rcc category', dh.data.category === 'rcc');
check('attribute_dice map', dh.data.attribute_dice?.PS === '4d6+12');
check('mdc_base + magic block', dh.data.mdc_base === '1d4x100' && dh.data.magic?.spell_levels_allowed?.length === 2);
check('natural_abilities', dh.data.natural_abilities?.length === 4);
check('restrictions scalar list', dh.data.restrictions?.length === 2);

// Invalid input must be rejected, not silently accepted.
const bad = parseClassMarkdown('---\nname: Nameless\nsystem: gurps\ncategory: occ\n---\nbody');
check('invalid file rejected', !bad.ok && bad.errors.some((e) => e.includes('id')) && bad.errors.some((e) => e.includes('system')));
const noFm = parseClassMarkdown('# just markdown, no frontmatter');
check('missing frontmatter rejected', !noFm.ok);

// ---------- 2. D1 migration ----------
console.log('\n[2/2] D1 migration (local)');

function wrangler(args) {
  return spawnSync('npx', ['wrangler', ...args], { cwd: appDir, shell: true, encoding: 'utf8', timeout: 120000 });
}

const apply = wrangler(['d1', 'migrations', 'apply', 'DB', '--local']);
check('migrations apply cleanly', apply.status === 0, (apply.stderr || apply.stdout || '').slice(-500));

// SQL goes through a temp file — a quoted --command string doesn't survive the Windows shell.
const checkSql = join(appDir, 'test', '.smoke-check.sql');
writeFileSync(checkSql,
  "SELECT (SELECT count(*) FROM sqlite_master WHERE type='table' AND name IN ('campaigns','characters','journal_entries','level_history','items','character_items')) AS tables, (SELECT count(*) FROM characters JOIN campaigns ON characters.campaign_id = campaigns.id JOIN character_items ON character_items.character_id = characters.id JOIN items ON items.id = character_items.item_id) AS joined;\n");
const query = wrangler(['d1', 'execute', 'DB', '--local', '--json', '--file', checkSql]);
rmSync(checkSql, { force: true });
let row = null;
try { row = JSON.parse(query.stdout)[0].results[0]; } catch { /* fall through to checks */ }
check('all 6 tables exist', row?.tables === 6, query.stdout?.slice(-300));
check('test rows join across tables', row?.joined === 1);

console.log(failures === 0 ? '\nSMOKE TEST PASSED' : `\nSMOKE TEST FAILED (${failures} failure(s))`);
process.exit(failures === 0 ? 0 : 1);
