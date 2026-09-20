// The bits every group of checks needs: where the repo is, how to record a
// result, and how a section announces itself.
//
// Its own file so a check file can import it without importing every other
// check file. Node has native ESM, so this costs nothing at runtime - the
// no-build-step rule that keeps the PAGE scripts in one piece each does not
// apply to a script only Node ever loads.

import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

export const appDir = join(dirname(fileURLToPath(import.meta.url)), '..');
export const repoRoot = join(appDir, '..', '..');

// WHERE THE PAGES LIVE, since the five apps got their own URLs.
//
// The suite reads the shipped files as text, so every check naming a page
// knows a path. Four pages moved out of apps/character-creator on 2026-09-19 -
// the sheet to character-sheet, the codex and its admin editor to codex, the
// notes to campaign, the dashboard to gm-tools - while the ENGINE (js/) stayed
// put, because the Pages Functions import those modules by path.
//
// This map is the one place that knows, so a check can keep asking for
// 'sheet.js' by the name the app calls it. The alternative was ~70 call sites
// each carrying a directory, and the next move touching all of them again.
const MOVED = {
  'sheet.js': ['character-sheet', 'sheet.js'],
  'sheet.html': ['character-sheet', 'index.html'],
  'codex.js': ['codex', 'codex.js'],
  'codex.html': ['codex', 'index.html'],
  'catalog.js': ['codex', 'catalog.js'],
  'catalog.html': ['codex', 'catalog.html'],
  'campaign.js': ['campaign', 'campaign.js'],
  'campaign.html': ['campaign', 'index.html'],
  'dashboard.js': ['gm-tools', 'dashboard.js'],
  'dashboard.html': ['gm-tools', 'index.html'],
};

/** The file a page name means today: appPath('sheet.js'), appPath('index.html'). */
export function appPath(name) {
  const moved = MOVED[name];
  return moved ? join(appDir, '..', ...moved) : join(appDir, name);
}

// The other four apps' own directories. A check that sweeps "every page
// script" used to be a readdir of appDir and silently covered four fewer
// files the moment they moved - the parse check stopped opening sheet.js, and
// said nothing, which is precisely the hole that check exists to close.
export const siblingAppDirs = [...new Set(Object.values(MOVED).map(([slug]) => slug))]
  .map((slug) => join(appDir, '..', slug));

let failures = 0;
let checks = 0;
let current = null;
const sections = [];

// --section <name> runs only the sections whose names contain <name> -
// case-insensitive, repeatable, comma-separated. The fast path between edits
// (F2 of EFFICIENCY-AUDIT.md): the wrangler-backed environment half gates
// itself on wantSection and is skipped entirely when no filter asks for it.
// The merge gate stays the FLAGLESS run, and a partial run labels its summary
// line PARTIAL so its output cannot pass for the gate's. A filter matching
// nothing is a failure, not a quiet green: the likeliest cause is a typo. The
// next likeliest used to be a checks module whose declared section list had
// drifted - rendered-ui.mjs announced two sections its list did not carry
// until 2026-09-17 - and since then the flagless run reads every module's
// list against its section() calls (smoke.mjs, 'The checks modules declare
// the sections they run'), so on a green main a no-match is the typo.
const filters = [];
for (let i = 2; i < process.argv.length; i++) {
  if (process.argv[i] === '--section' && process.argv[i + 1]) {
    for (const part of process.argv[++i].split(',')) {
      const f = part.trim().toLowerCase();
      if (f) filters.push(f);
    }
  }
}
export const filtered = filters.length > 0;

export function wantSection(name) {
  return !filtered || filters.some((f) => name.toLowerCase().includes(f));
}

// A section announces what it covers. It used to be a bare console.log with a
// hand-maintained number - [1c25l], [1c11b] - and the numbering had stopped
// matching execution order in nine places, so it asserted something false about
// the file it was labelling. The name was always the real identifier.
export function section(name) {
  current = { name, checks: 0, failures: 0, active: wantSection(name) };
  if (!current.active) return;
  sections.push(current);
  console.log('\n' + name);
}

export function check(label, cond, detail) {
  if (current && !current.active) return;
  checks++;
  if (current) current.checks++;
  if (cond) {
    console.log('  ok  ' + label);
  } else {
    failures++;
    if (current) current.failures++;
    console.error('  FAIL ' + label + (detail ? ' \u2014 ' + detail : ''));
  }
}

// Named so a failure can say WHICH group it was in, which a flat list of 768
// results cannot.
export function summary() {
  if (filtered && sections.length === 0) {
    console.error('\nno section matched --section ' + filters.join(', '));
    return 1;
  }
  if (failures) {
    console.error('\nfailing sections:');
    for (const s of sections.filter((x) => x.failures)) {
      console.error('  ' + s.name + ' \u2014 ' + s.failures + ' of ' + s.checks);
    }
  }
  const note = filtered
    ? ` \u2014 --section ${filters.join(', ')}; the merge gate is the flagless run`
    : '';
  console.log(failures === 0
    ? `\n${filtered ? 'PARTIAL SMOKE PASSED' : 'SMOKE TEST PASSED'} (${checks} checks in ${sections.length} sections)${note}`
    : `\n${filtered ? 'PARTIAL SMOKE FAILED' : 'SMOKE TEST FAILED'} (${failures} of ${checks} checks)${note}`);
  return failures;
}
