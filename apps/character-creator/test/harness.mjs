// The character creator's half of the test harness: where the app is, and
// where its moved pages live.
//
// Everything a check records a result with - section, check, summary,
// wantSection, filtered, repoRoot - lives in shared/test/harness.mjs since the
// codebase split into groups (groups.json), and is re-exported here so no
// module under test/checks/ had to change when it moved. Import it from here
// in this app's suites; every other app imports the shared file directly.

import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

export { repoRoot, filtered, wantSection, section, check, summary } from '../../../shared/test/harness.mjs';

export const appDir = join(dirname(fileURLToPath(import.meta.url)), '..');

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
