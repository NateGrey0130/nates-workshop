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

// A section announces what it covers. It used to be a bare console.log with a
// hand-maintained number - [1c25l], [1c11b] - and the numbering had stopped
// matching execution order in nine places, so it asserted something false about
// the file it was labelling. The name was always the real identifier.
export function section(name) {
  current = { name, checks: 0, failures: 0 };
  sections.push(current);
  console.log('\n' + name);
}

export function check(label, cond, detail) {
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
  if (failures) {
    console.error('\nfailing sections:');
    for (const s of sections.filter((x) => x.failures)) {
      console.error('  ' + s.name + ' \u2014 ' + s.failures + ' of ' + s.checks);
    }
  }
  console.log(failures === 0
    ? `\nSMOKE TEST PASSED (${checks} checks in ${sections.length} sections)`
    : `\nSMOKE TEST FAILED (${failures} of ${checks} checks)`);
  return failures;
}
