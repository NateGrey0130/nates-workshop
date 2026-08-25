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
// nothing is a failure, not a quiet green: the likeliest cause is a typo, and
// the next likeliest is a checks module whose declared section list drifted.
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
