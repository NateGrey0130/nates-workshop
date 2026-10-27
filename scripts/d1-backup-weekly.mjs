// The scheduled half of d1-backup.mjs: all three databases, one dated folder,
// a rotation, and a record of how it went.
//
//   node scripts/d1-backup-weekly.mjs                     back up, to the default root
//   node scripts/d1-backup-weekly.mjs D:\elsewhere        back up, to another root
//   node scripts/d1-backup-weekly.mjs --check [<root>]    how old is the newest good one
//
// Each run writes <root>\<YYYY-MM-DD>\<palladium|marvel|tools>\<table>.json by
// running d1-backup.mjs once per database, --remote unless --local is passed.
// The root defaults to C:\Users\natha\Backups\nates-workshop and must be
// OUTSIDE the repo: the repo is public, and a backup is everyone's campaign
// notes. The script refuses a root inside it.
//
// A run that backed up every table of every database writes COMPLETE.json in
// its dated folder, and only then deletes dated folders past the newest KEEP.
// A run with any failure deletes nothing, so a broken week never rotates a
// good one away. Either way it writes <root>\last-run.json: the date, each
// database's exit status, table count and row count, and the run's own exit.
// Each database's console output is kept beside its folder as <db>.log,
// because a scheduled task's console goes nowhere.
//
// WHY --check EXISTS. d1-backup.mjs used to say "manual on purpose: a scheduled
// export that quietly stops is worse than a documented one somebody runs,
// because the first kind is believed." That objection is real, and this is the
// answer to it rather than a dismissal of it: --check reads the newest
// COMPLETE.json, prints its age, and exits 1 when it is older than MAX_AGE_DAYS
// or there is none. A schedule that stopped, a PC that was off all week, a
// token that expired - each shows up as an age, not as silence. SETUP.md ->
// "The weekly D1 backup" says where to run it.
//
// R2. After the databases, each --remote run mirrors the MEDIA bucket
// (nates-workshop-media, the NPC portraits) into <root>\r2\nates-workshop-media\
// through R2's S3-compatible API: it lists every key and downloads only the
// ones not already on disk at the same size. It is one growing copy, not a
// dated one, and it NEVER deletes a local file, so an object deleted from the
// bucket stays here. It reads the bucket and does nothing else: GET only, no
// write, no delete, and it never touches the bucket's public-access setting.
// CLOUDFLARE_API_TOKEN cannot reach R2 (docs/cloudflare-credentials.md), so it
// signs its own requests (SigV4, below, no SDK) with a read-only R2 token from
// R2_BACKUP_ACCESS_KEY_ID and R2_BACKUP_SECRET_ACCESS_KEY, and the account from
// CLOUDFLARE_ACCOUNT_ID, all User-scope. Their values are never printed or
// written anywhere. Its counts go into last-run.json under "r2". The mirror
// has no say in the rotation, which concerns the dated D1 folders only, but a
// failed mirror makes the run exit 1 and makes --check exit 1.
import { spawnSync } from 'node:child_process';
import { createHash, createHmac } from 'node:crypto';
import { existsSync, mkdirSync, readdirSync, readFileSync, renameSync, rmSync, statSync, writeFileSync } from 'node:fs';
import { dirname, join, relative, resolve, isAbsolute } from 'node:path';
import { repoRoot } from './d1-query-lib.mjs';

const DEFAULT_ROOT = 'C:\\Users\\natha\\Backups\\nates-workshop';
const GROUPS = ['palladium', 'marvel', 'tools'];
const KEEP = 8;
const MAX_AGE_DAYS = 8;
const DATED = /^\d{4}-\d{2}-\d{2}$/;
const R2_BUCKET = 'nates-workshop-media';
const R2_PARALLEL = 4;
const EMPTY_SHA256 = createHash('sha256').update('').digest('hex');

const args = process.argv.slice(2);
const check = args.includes('--check');
const target = args.includes('--local') ? '--local' : '--remote';
const root = resolve(args.find((a) => !a.startsWith('--')) ?? DEFAULT_ROOT);

const rel = relative(resolve(repoRoot), root);
if (!rel || (!rel.startsWith('..') && !isAbsolute(rel))) {
  console.error(`refusing ${root}: it is inside the repo, and the repo is public. Back up outside it.`);
  process.exit(2);
}

/** Dated folders under root, newest first. */
function datedFolders() {
  if (!existsSync(root)) return [];
  return readdirSync(root, { withFileTypes: true })
    .filter((d) => d.isDirectory() && DATED.test(d.name))
    .map((d) => d.name)
    .sort()
    .reverse();
}

if (check) {
  const newest = datedFolders().find((d) => existsSync(join(root, d, 'COMPLETE.json')));
  if (existsSync(join(root, 'last-run.json'))) {
    const last = JSON.parse(readFileSync(join(root, 'last-run.json'), 'utf8'));
    console.log(`last run: ${last.date} (${last.target}), exit ${last.exit}`);
  } else {
    console.log('last run: none recorded');
  }
  const r2 = existsSync(join(root, 'last-run.json'))
    ? JSON.parse(readFileSync(join(root, 'last-run.json'), 'utf8')).r2
    : undefined;
  let r2Failed = false;
  if (!r2) {
    console.log('R2 mirror: not recorded on the last run.');
  } else if (r2.skipped) {
    console.log(`R2 mirror: skipped on the last run (${r2.skipped}).`);
  } else if (r2.exit !== 0) {
    console.log(`R2 mirror: FAILED on the last run: ${r2.error ?? `${r2.failed} key(s) not copied`}.`);
    r2Failed = true;
  } else {
    console.log(`R2 mirror: ${r2.objects} objects listed, ${r2.downloaded} downloaded, ${r2.present} already present.`);
  }
  if (!newest) {
    console.log(`NO COMPLETE BACKUP under ${root}.`);
    process.exit(1);
  }
  const done = JSON.parse(readFileSync(join(root, newest, 'COMPLETE.json'), 'utf8'));
  const days = (Date.now() - Date.parse(done.finishedAt)) / 86_400_000;
  const line = `newest complete backup: ${newest}, ${days.toFixed(1)} days old`;
  if (days > MAX_AGE_DAYS) {
    console.log(`${line}. STALE: older than ${MAX_AGE_DAYS} days, so the weekly run has stopped.`);
    process.exit(1);
  }
  console.log(`${line}. OK.`);
  process.exit(r2Failed ? 1 : 0);
}

// ---------------------------------------------------------------- R2 mirror

const rfc3986 = (s) => encodeURIComponent(s)
  .replace(/[!'()*]/g, (c) => `%${c.charCodeAt(0).toString(16).toUpperCase()}`);
const hmac = (key, data) => createHmac('sha256', key).update(data).digest();

/** One signed GET against the bucket. `key` undefined lists; a string fetches that object. */
async function r2Get(creds, key, query = {}) {
  const host = `${creds.account}.r2.cloudflarestorage.com`;
  const path = `/${R2_BUCKET}/${key === undefined ? '' : key.split('/').map(rfc3986).join('/')}`;
  const qs = Object.keys(query).sort().map((k) => `${rfc3986(k)}=${rfc3986(query[k])}`).join('&');
  const amzDate = new Date().toISOString().replace(/[:-]|\.\d{3}/g, '');
  const scope = `${amzDate.slice(0, 8)}/auto/s3/aws4_request`;
  const signedHeaders = 'host;x-amz-content-sha256;x-amz-date';
  const canonical = ['GET', path, qs,
    `host:${host}\nx-amz-content-sha256:${EMPTY_SHA256}\nx-amz-date:${amzDate}\n`,
    signedHeaders, EMPTY_SHA256].join('\n');
  const toSign = ['AWS4-HMAC-SHA256', amzDate, scope,
    createHash('sha256').update(canonical).digest('hex')].join('\n');
  let k = hmac(`AWS4${creds.secret}`, amzDate.slice(0, 8));
  for (const part of ['auto', 's3', 'aws4_request']) k = hmac(k, part);
  const signature = createHmac('sha256', k).update(toSign).digest('hex');
  const res = await fetch(`https://${host}${path}${qs ? `?${qs}` : ''}`, {
    headers: {
      'x-amz-date': amzDate,
      'x-amz-content-sha256': EMPTY_SHA256,
      authorization: `AWS4-HMAC-SHA256 Credential=${creds.id}/${scope}, SignedHeaders=${signedHeaders}, Signature=${signature}`,
    },
  });
  if (!res.ok) {
    // Only the error code: an S3 error body can echo the access key id.
    const code = /<Code>([^<]*)<\/Code>/.exec(await res.text())?.[1] ?? 'no code';
    throw new Error(`HTTP ${res.status} ${code}`);
  }
  return res;
}

const unxml = (s) => s
  .replace(/&#x([0-9a-f]+);/gi, (_, h) => String.fromCodePoint(parseInt(h, 16)))
  .replace(/&#(\d+);/g, (_, d) => String.fromCodePoint(Number(d)))
  .replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&quot;/g, '"').replace(/&apos;/g, "'")
  .replace(/&amp;/g, '&');

/** Every key in the bucket with its size, through ListObjectsV2's pages. */
async function r2List(creds) {
  const objects = [];
  let token;
  do {
    const query = { 'list-type': '2', 'max-keys': '1000' };
    if (token) query['continuation-token'] = token;
    const xml = await (await r2Get(creds, undefined, query)).text();
    for (const [, body] of xml.matchAll(/<Contents>([\s\S]*?)<\/Contents>/g)) {
      objects.push({
        key: unxml(/<Key>([\s\S]*?)<\/Key>/.exec(body)[1]),
        size: Number(/<Size>(\d+)<\/Size>/.exec(body)[1]),
      });
    }
    token = /<IsTruncated>true<\/IsTruncated>/.test(xml)
      ? unxml(/<NextContinuationToken>([\s\S]*?)<\/NextContinuationToken>/.exec(xml)[1])
      : undefined;
  } while (token);
  return objects;
}

/** A key's file under the mirror, or null when Windows cannot hold it as a path. */
function localPath(mirror, key) {
  const parts = key.split('/');
  const bad = (p) => !p || p === '.' || p === '..' || /[<>:"\\|?*\x00-\x1f]/.test(p) || /[. ]$/.test(p);
  return parts.some(bad) ? null : join(mirror, ...parts);
}

async function mirrorR2() {
  const creds = {
    id: process.env.R2_BACKUP_ACCESS_KEY_ID,
    secret: process.env.R2_BACKUP_SECRET_ACCESS_KEY,
    account: process.env.CLOUDFLARE_ACCOUNT_ID,
  };
  const mirror = join(root, 'r2', R2_BUCKET);
  const result = { bucket: R2_BUCKET, mirror, exit: 1, objects: 0, bytes: 0, present: 0, downloaded: 0, failed: 0 };
  const missing = ['R2_BACKUP_ACCESS_KEY_ID', 'R2_BACKUP_SECRET_ACCESS_KEY', 'CLOUDFLARE_ACCOUNT_ID']
    .filter((n) => !process.env[n]);
  if (missing.length) {
    result.error = `not set in this process: ${missing.join(', ')}`;
    return result;
  }
  let objects;
  try {
    objects = await r2List(creds);
  } catch (e) {
    result.error = `listing the bucket: ${e.message}`;
    return result;
  }
  result.objects = objects.length;
  result.bytes = objects.reduce((n, o) => n + o.size, 0);
  const failures = [];
  const todo = [];
  for (const o of objects) {
    const file = localPath(mirror, o.key);
    if (!file) failures.push({ key: o.key, reason: 'not a path Windows can hold' });
    else if (existsSync(file) && statSync(file).size === o.size) result.present += 1;
    else todo.push({ ...o, file });
  }
  let next = 0;
  async function worker() {
    while (next < todo.length) {
      const o = todo[next++];
      try {
        const body = Buffer.from(await (await r2Get(creds, o.key)).arrayBuffer());
        if (body.length !== o.size) throw new Error(`got ${body.length} bytes, listed ${o.size}`);
        mkdirSync(dirname(o.file), { recursive: true });
        writeFileSync(`${o.file}.part`, body);
        renameSync(`${o.file}.part`, o.file);
        result.downloaded += 1;
      } catch (e) {
        failures.push({ key: o.key, reason: e.message });
      }
    }
  }
  await Promise.all(Array.from({ length: R2_PARALLEL }, worker));
  result.failed = failures.length;
  if (failures.length) result.failures = failures.slice(0, 20);
  result.exit = failures.length ? 1 : 0;
  return result;
}

// The local date, not UTC: the folder name is what Nate looks for on disk.
const now = new Date();
const date = [now.getFullYear(), now.getMonth() + 1, now.getDate()]
  .map((n) => String(n).padStart(2, '0')).join('-');
const dayDir = join(root, date);
// The run writes into <date>.partial, which no rotation or --check counts, and
// it becomes <date> only when every database succeeded. So a second run on
// the same day that fails leaves the first one's good folder alone, and a
// table dropped since the first run cannot survive as a stale file.
const workDir = join(root, `${date}.partial`);
rmSync(workDir, { recursive: true, force: true });
mkdirSync(workDir, { recursive: true });

const results = {};
for (const group of GROUPS) {
  const dir = join(workDir, group);
  const r = spawnSync(process.execPath,
    [join(repoRoot, 'scripts', 'd1-backup.mjs'), dir, target, '--db', group],
    { cwd: repoRoot, encoding: 'utf8', maxBuffer: 64 * 1024 * 1024 });
  const out = (r.stdout || '') + (r.stderr || '');
  process.stdout.write(out);
  writeFileSync(join(workDir, `${group}.log`), out, 'utf8');
  let tables = 0;
  let rows = 0;
  if (existsSync(dir)) {
    for (const f of readdirSync(dir).filter((n) => n.endsWith('.json'))) {
      tables += 1;
      rows += JSON.parse(readFileSync(join(dir, f), 'utf8')).length;
    }
  }
  results[group] = { exit: r.status ?? 1, tables, rows };
}

const ok = GROUPS.every((g) => results[g].exit === 0);
// R2 has no local copy to read, so a --local run (a test of the D1 half) skips it.
const r2 = target === '--remote' ? await mirrorR2() : { skipped: 'a --local run' };
const r2ok = !!r2.skipped || r2.exit === 0;
const record = {
  date, finishedAt: new Date().toISOString(), target, root,
  exit: ok && r2ok ? 0 : 1, databases: results, r2,
};

const deleted = [];
if (ok) {
  rmSync(dayDir, { recursive: true, force: true });
  renameSync(workDir, dayDir);
  writeFileSync(join(dayDir, 'COMPLETE.json'), JSON.stringify(record, null, 2), 'utf8');
  const partials = readdirSync(root).filter((n) => /^\d{4}-\d{2}-\d{2}\.partial$/.test(n));
  for (const old of [...datedFolders().slice(KEEP), ...partials]) {
    rmSync(join(root, old), { recursive: true, force: true });
    deleted.push(old);
  }
}
record.deleted = deleted;
writeFileSync(join(root, 'last-run.json'), JSON.stringify(record, null, 2), 'utf8');

console.log(`\nweekly backup ${date} -> ${ok ? dayDir : workDir}`);
for (const g of GROUPS) {
  const r = results[g];
  console.log(`  ${g.padEnd(10)} exit ${r.exit}  ${String(r.tables).padStart(3)} tables  ${String(r.rows).padStart(7)} rows`);
}
if (ok) {
  console.log(`  Complete. Kept the newest ${KEEP}; deleted ${deleted.length ? deleted.join(', ') : 'nothing'}.\n`);
} else {
  console.log(`  INCOMPLETE. Nothing rotated or replaced. Its <db>.log files are in ${date}.partial.\n`);
}
if (r2.skipped) {
  console.log(`  R2 mirror skipped: ${r2.skipped}.\n`);
} else {
  console.log(`  R2 ${R2_BUCKET} -> ${r2.mirror}`);
  console.log(`  ${r2.objects} objects listed (${r2.bytes} bytes), ${r2.downloaded} downloaded, ${r2.present} already present, ${r2.failed} failed`);
  if (r2.error) console.log(`  R2 MIRROR FAILED: ${r2.error}`);
  for (const f of r2.failures ?? []) console.log(`  R2 not copied: ${f.key}: ${f.reason}`);
  console.log('');
}
// exitCode, not exit(): process.exit() while fetch's sockets are closing
// aborts node on Windows (a libuv assertion in async.c, exit 127), and that
// was measured here on the first real run.
process.exitCode = ok && r2ok ? 0 : 1;
