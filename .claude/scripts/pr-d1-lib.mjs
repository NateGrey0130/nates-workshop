// pr-d1-lib.mjs - the pure part of pr-d1-applied.mjs: which of a pull
// request's paths are D1 files, how `d1-apply.mjs --check` answered for them,
// and the one line the script prints. No git, no gh, no wrangler here, so
// apps/character-creator/test/checks/plan-tick-verdict.mjs drives it with
// shaped file lists and shaped --check output.
//
// What counts as a D1 file is every .sql that `ship-pr` -> *The ordering rule*
// applies before a merge: a migration in db/migrations/ (palladium), in
// db/migrations/marvel/ or db/migrations/tools/, and a data script directly in
// apps/character-creator/db/. The schema files (db/schema*.sql,
// db/seed-catalogs.sql) are rebuild sources, never applied to production one
// by one, and a skill's reference .sql is an example.
//
// Whether a file is RECORDED is not decided here. That is `d1-apply.mjs
// --check`, which asks the target's schema_migrations and data_script_runs;
// this module only reads what it printed.

const RULES = [
  { db: 'marvel', rx: /^db\/migrations\/marvel\/[^/]+\.sql$/ },
  { db: 'tools', rx: /^db\/migrations\/tools\/[^/]+\.sql$/ },
  { db: 'palladium', rx: /^db\/migrations\/[^/]+\.sql$/ },
  { db: 'palladium', rx: /^apps\/character-creator\/db\/[^/]+\.sql$/ },
];

// The repo-relative paths `gh pr diff --name-only` printed, grouped by the
// database each goes to, in the order given. A path with a backslash is
// normalised first, so a Windows-shaped list reads the same.
export function d1FilesByDb(paths) {
  const out = new Map();
  for (const raw of paths) {
    const p = String(raw).trim().replace(/\\/g, '/');
    if (!p) continue;
    const rule = RULES.find((r) => r.rx.test(p));
    if (!rule) continue;
    if (!out.has(rule.db)) out.set(rule.db, []);
    if (!out.get(rule.db).includes(p)) out.get(rule.db).push(p);
  }
  return out;
}

const base = (p) => String(p).split(/[\\/]/).pop();

// What one `d1-apply.mjs --check --remote [--db <db>] <files>` run said.
// Returns { recorded, unrecorded, localOnly } as basenames, or { error } when
// the run cannot be read as an answer: a non-zero exit, no plan printed, a
// target whose ledger could not be read, or a file the plan does not list.
export function parseCheck({ status, stdout = '', stderr = '' }, files) {
  const text = `${stdout}\n${stderr}`;
  const localOnly = [...text.matchAll(/^skipping (.+?) [-—] marked local-only/gm)].map((m) => base(m[1]));
  if (/nothing left to apply: every file given is local-only/.test(text)) {
    return { recorded: [], unrecorded: [], localOnly };
  }
  const firstError = (text.split('\n').find((l) => /d1-apply:|NUMBER TAKEN|PRE-FLIGHT FAILED/.test(l)) || '').trim();
  if (status !== 0) return { error: `d1-apply --check exited ${status}${firstError ? `: ${firstError}` : ''}` };
  const lines = stdout.split('\n');
  const at = lines.findIndex((l) => /^--check: \d+ file\(s\) would be applied to /.test(l));
  if (at === -1) return { error: 'd1-apply --check printed no plan' };
  if (/could not read which files this target has recorded/.test(stdout)) {
    return { error: 'd1-apply --check could not read which files the target has recorded' };
  }
  const listed = new Map();
  for (const l of lines.slice(at + 1)) {
    const m = /^ {2}(\S.*?)(\s+<- ALREADY RECORDED on this target)?\s*$/.exec(l);
    if (!m) { if (listed.size) break; continue; }
    listed.set(base(m[1]), Boolean(m[2]));
  }
  const recorded = [];
  const unrecorded = [];
  for (const f of files.map(base)) {
    if (localOnly.includes(f)) continue;
    if (!listed.has(f)) return { error: `d1-apply --check did not list ${f}` };
    (listed.get(f) ? recorded : unrecorded).push(f);
  }
  return { recorded, unrecorded, localOnly };
}

// One line and an exit code for the whole pull request. `results` is a list
// of { db, files, parsed } (parsed from parseCheck), or empty for a pull
// request with no D1 files. Any error is exit 2: an unread answer is not a pass.
export function verdict(results) {
  if (!results.length) return { code: 0, line: 'NO D1 FILES' };
  const errors = results.filter((r) => r.parsed.error);
  if (errors.length) return { code: 2, line: `D1 UNREADABLE ${errors.map((r) => `${r.db}: ${r.parsed.error}`).join('; ')}` };
  const tag = (r, f) => (r.db === 'palladium' ? f : `${f} (${r.db})`);
  const missing = results.flatMap((r) => r.parsed.unrecorded.map((f) => tag(r, f)));
  if (missing.length) return { code: 1, line: `D1 NOT APPLIED ${missing.join(' ')}` };
  const applied = results.flatMap((r) => r.parsed.recorded.map((f) => tag(r, f)));
  if (!applied.length) return { code: 0, line: 'NO D1 FILES (every one is local-only)' };
  return { code: 0, line: `D1 APPLIED ${applied.join(' ')}` };
}
