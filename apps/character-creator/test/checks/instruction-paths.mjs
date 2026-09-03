// Every absolute Windows path in the INSTRUCTION layer resolves on this machine.
//
// DOCS-AUDIT-2.md D1. A move gets recorded where it happens and rots where it is
// pointed at: on 2026-09-02 the working directory moved, four separate findings
// recorded it, and four instruction files still named the old path hours later.
// No finding owned "every sentence in the instruction layer that names an
// absolute path", so nothing walked from the move to the sentences naming it.
//
// The cost is asymmetric, which is why this is a gate rather than a report. A
// stale path in an audit file is history. A stale path in a SKILL is an
// instruction, and one of the four told a session that a permission existed
// after it had been revoked.
//
// NOT a grep for the old directory name. The point is to catch the NEXT move.
//
// ── extraction is the hard part, and it is not what D1 expected ──────────────
//
// D1 anticipated the difficulty being an exemption rule for deliberately
// historical paths. Measured 2026-09-03, that problem does not arise: nothing
// in the instruction layer names a path that fails to resolve, so there is
// nothing to exempt and no exemption machinery is built here. D1's own posture
// forbids an allowlist of known-dead paths, and this check has none.
//
// What actually breaks a naive version is reading the path out of prose:
//
//   * `C:\Program Files\Git\cmd` contains a SPACE. A whitespace-delimited regex
//     truncates it to `C:\Program`, which never resolves - so the naive check
//     reports four false failures in SETUP.md alone.
//   * `"...\.claude\skills\$s"` is a PowerShell loop variable inside a fenced
//     example in SETUP.md, not a path at all.
//
// A whitespace-delimited regex was measured at a 100% false-positive rate on
// this corpus: five reported failures, all five spurious. So paths are read out
// of INLINE CODE SPANS and QUOTED STRINGS, which is how this repo writes them
// and which gives a delimiter that survives a space; and any span carrying a
// shell variable or a <placeholder> is skipped as a template rather than
// resolved.
//
// The templated skip is narrower than the "exempt fenced blocks" rule D1
// sketched, and covers the one fenced-block path that exists today. If a real
// path is ever written outside a span it is invisible here - a miss, not a false
// failure, which is the right direction for a gate to fail in.

import { readFileSync, readdirSync, existsSync, statSync } from 'node:fs';
import { join } from 'node:path';
import { repoRoot, check, section, wantSection } from '../harness.mjs';

const SECTIONS = ['Instruction-layer paths'];

// The instruction layer, exactly as D1 scopes it.
const ROOTS = ['CLAUDE.md', 'SETUP.md', '.claude/skills', '.claude/agents'];
const READABLE = /\.(md|json|ps1|mjs|js)$/i;

// Inline code, then double-quoted strings. Both survive a space in a path.
const SPANS = [/`([^`\n]+)`/g, /"([^"\n]+)"/g];
const ABSOLUTE = /^[A-Za-z]:\\/;
// $s, $env:USERPROFILE, %APPDATA%, <slug> - a template, not a location.
const TEMPLATED = /\$|%[A-Za-z_]+%|<[A-Za-z]/;

function walk(rel, out = []) {
  const full = join(repoRoot, rel);
  if (!existsSync(full)) return out;
  if (statSync(full).isFile()) { out.push(rel); return out; }
  for (const entry of readdirSync(full)) walk(`${rel}/${entry}`, out);
  return out;
}

export function run() {
  if (!SECTIONS.some(wantSection)) return;

  section('Instruction-layer paths');

  const files = ROOTS.flatMap((r) => walk(r)).filter((f) => READABLE.test(f));
  // A vacuous pass is the failure mode to fear here: if the walk stops finding
  // files, every assertion below passes and the check reports nothing wrong.
  check('the instruction layer is readable', files.length >= 10,
    `${files.length} file(s) under ${ROOTS.join(', ')}`);

  const found = [];
  for (const file of files) {
    readFileSync(join(repoRoot, file), 'utf8').split(/\r?\n/).forEach((line, i) => {
      for (const re of SPANS) {
        re.lastIndex = 0;
        let m;
        while ((m = re.exec(line)) !== null) {
          const path = m[1].trim().replace(/[.,;:]+$/, '');
          if (!ABSOLUTE.test(path)) continue;
          found.push({ file, line: i + 1, path, templated: TEMPLATED.test(path) });
        }
      }
    });
  }

  const real = found.filter((h) => !h.templated);
  // Same reason as above: if extraction silently stops working, `dead` is empty
  // and the gate below passes while checking nothing.
  check('absolute paths are still being extracted', real.length >= 8,
    `${real.length} checkable, ${found.length - real.length} templated and skipped`);

  // ── the one check in the suite that cannot run on another platform ─────────
  //
  // REPO-AUDIT.md G8. This assertion IS `existsSync` against a `C:\` path, so
  // all eleven are dead on a Linux runner and the check reports failures that
  // mean nothing about the repo. That makes it the only thing standing between
  // this suite and CI - established by measurement after G8's premise that a
  // bare clone fails turned out to be FALSE: a fresh clone with no `.wrangler`
  // and no `.cache` passes all 1662 checks on this machine.
  //
  // The platform is the probe, and it is deliberately NOT a flag. The flagless
  // run here is the merge gate and must keep resolving every path; a
  // `--portable` flag would be a way to opt out of that and still quote the
  // result as the gate.
  //
  // The skip sits AFTER the two guards above on purpose. Both assert that
  // extraction still works, both touch no filesystem, and they are the only
  // defence against this check passing while reading nothing - the failure mode
  // this file's own header names twice. Skipping the section wholesale off
  // Windows would take them with it and turn a foreign platform into exactly
  // that vacuous pass. As written, Linux still proves the paths are being
  // FOUND and only declines to say whether they exist.
  //
  // Consistent with the doctrine stated at the top of this file: a miss, not a
  // false failure, is the right direction for a gate to fail in.
  if (process.platform !== 'win32') {
    check(`absolute paths are not resolved on ${process.platform}`, true,
      `${real.length} Windows path(s) extracted, left unresolved - this assertion is Windows-only`);
    return;
  }

  const dead = real.filter((h) => !existsSync(h.path));
  check('every absolute path in the instruction layer resolves', dead.length === 0,
    dead.length
      ? dead.map((d) => `${d.file}:${d.line} ${d.path}`).join('; ')
      : `${real.length} path(s) checked, all resolve`);
}
