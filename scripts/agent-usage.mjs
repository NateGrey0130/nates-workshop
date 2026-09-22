// Which subagent has been spawned how often, from this machine's session
// transcripts. SKILL-AUDIT F52.
//
//   node scripts/agent-usage.mjs                       every agent, all time
//   node scripts/agent-usage.mjs --since 2026-09-04    from a date, inclusive
//   node scripts/agent-usage.mjs --until 2026-09-20    to a date, inclusive
//   node scripts/agent-usage.mjs --projects <dir>      another transcript root
//
// IT READS NOTHING IN THIS REPO, and nothing gates on it. The transcripts live
// under the user's ~/.claude/projects, outside the repo and absent on a CI
// runner, so this is a script you run rather than a check: no exit code, no
// workflow, no section in a suite. It exists because the same measurement has
// now been hand-built three times - EFFICIENCY-AUDIT on 2026-08-25, a
// general-purpose agent on 2026-09-11, and the subagent retrospective on
// 2026-09-22 - and two of the three got a counting rule wrong.
//
// THE TWO RULES, both measured 2026-09-22, both cheap to get backwards:
//
// - THE BLOCK IS NAMED `Agent`. A scan matching `Task` - which is what the
//   retrospective's own method line said - returns ZERO on this corpus. Both
//   names are matched below, because the name has changed once already and a
//   scan that silently returns nothing is the worst shape available.
// - DEDUPE BY THE BLOCK ID, and know what it is worth. For tool_use blocks the
//   duplication is small: 382 raw against 373 distinct on 2026-09-22, 1.02x.
//   The ~1.9x double-log EFFICIENCY-AUDIT measured is a DIFFERENT object -
//   assistant `usage` records, deduped by `message.id`. Dedupe agent calls by
//   `message.id` and you lose every second call in a turn that spawned two.
//
// The ratio is printed on every run so the next reader can see what the dedupe
// actually bought rather than taking either number on trust.

import { createReadStream, existsSync, readdirSync, statSync } from 'node:fs';
import { join } from 'node:path';
import { createInterface } from 'node:readline';
import { homedir } from 'node:os';

const arg = (name, fallback) => {
  const i = process.argv.indexOf(name);
  return i === -1 ? fallback : process.argv[i + 1];
};

const root = arg('--projects', join(homedir(), '.claude', 'projects'));
const since = arg('--since', null);
const until = arg('--until', null);

if (!existsSync(root)) {
  console.log(`no transcript directory at ${root}`);
  console.log('This machine keeps them under ~/.claude/projects; pass --projects to look elsewhere.');
  process.exit(0);
}

// Recursive: a session's own subagent transcripts live in a `subagents/`
// directory beside it, and a spawn recorded there is still a spawn. A flat
// listing of the Downloads key returns 150 files where the tree holds 518.
const files = [];
(function walk(dir) {
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    const full = join(dir, entry.name);
    if (entry.isDirectory()) walk(full);
    else if (entry.name.endsWith('.jsonl')) files.push(full);
  }
})(root);

const seen = new Map();
let raw = 0;

for (const file of files) {
  const rl = createInterface({ input: createReadStream(file), crlfDelay: Infinity });
  for await (const line of rl) {
    if (!line.includes('subagent_type')) continue;
    let record;
    try { record = JSON.parse(line); } catch { continue; }
    const content = record?.message?.content;
    if (!Array.isArray(content)) continue;
    for (const block of content) {
      if (block?.type !== 'tool_use') continue;
      if (block.name !== 'Agent' && block.name !== 'Task') continue;
      const agent = block?.input?.subagent_type;
      if (typeof agent !== 'string') continue;
      raw += 1;
      const day = (record.timestamp || '').slice(0, 10);
      if (since && day && day < since) continue;
      if (until && day && day > until) continue;
      if (!seen.has(block.id)) seen.set(block.id, { agent, day });
    }
  }
}

const byAgent = new Map();
for (const { agent, day } of seen.values()) {
  const row = byAgent.get(agent) || { calls: 0, first: '', last: '' };
  row.calls += 1;
  if (day) {
    if (!row.first || day < row.first) row.first = day;
    if (!row.last || day > row.last) row.last = day;
  }
  byAgent.set(agent, row);
}

const window = [since && `since ${since}`, until && `until ${until}`].filter(Boolean).join(', ');
console.log(`${files.length} transcript files under ${root}${window ? ` (${window})` : ''}`);
console.log(`${seen.size} distinct agent calls, ${raw} blocks raw — ${(raw / (seen.size || 1)).toFixed(3)}x\n`);

const rows = [...byAgent.entries()].sort((a, b) => b[1].calls - a[1].calls);
const width = Math.max(5, ...rows.map(([name]) => name.length));
for (const [name, row] of rows) {
  console.log(`${String(row.calls).padStart(5)}  ${name.padEnd(width)}  ${row.first} -> ${row.last}`);
}
if (rows.length === 0) console.log('no agent calls in that window');
