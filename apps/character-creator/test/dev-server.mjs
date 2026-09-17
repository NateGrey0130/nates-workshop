// Booting `wrangler pages dev` for a suite, and PROVING the server that answers
// is the one this run spawned.
//
// Both regression.mjs and play-flow.mjs used to take a fixed port (8799 and
// 8797), spawn wrangler on it, and poll /me until it answered 200. Nothing
// asked whether the port was already taken or who answered. On 2026-09-16 a
// regression run in one worktree left a workerd listening on 127.0.0.1:8799;
// a later run from another worktree built its own scratch database, spawned
// wrangler on the same port, and its poll got a 200 from the FOREIGN server. It
// printed "ok the worker answers on port 8799" and went on to report that other
// tree's catalog counts (321 classes against a README saying 318) and a block
// of Talent FAILs, all of which read exactly like a real regression.
//
// WHY NOTHING FAILED TO BIND, measured 2026-09-17 on this machine: when the
// holder is a workerd, the second wrangler's workerd binds 127.0.0.1:8799 TOO -
// netstat lists both as LISTENING - its wrangler stays up, and connections keep
// reaching the OLDER server. (Against a plain Node listener wrangler does exit 1
// after ~4s, saying only "The Workers runtime failed to start", to stdio:
// 'ignore'.) So "the child is still alive" proves nothing in the real case, and
// neither does a 200.
//
// So three things here, each closing a different gap:
//
//   1. freePort() asks the OS for a port nobody holds, so two worktrees running
//      a suite at once no longer compete for one number at all. A fixed port
//      can still be pinned with an environment variable.
//   2. refuseIfTaken() checks the port before spawning, and when it is held
//      names the process holding it - and that process's parents, because the
//      listener is a workerd whose wrangler PARENT carries the --persist-to
//      that says which run it belongs to.
//   3. waitForOwnServer() does not accept "something answered 200". It asks
//      for a marker row this run wrote into its own scratch database - a draft
//      owned by an address containing a per-run nonce - and only that proves
//      the answering server reads THIS database. It also stops early when the
//      spawned wrangler exits (the Node-listener case) or when something
//      answers without the marker for ten seconds (the workerd case).
//
// (1) and (2) make a collision unlikely; (3) is the one that makes it
// impossible to MISREAD, which is what the incident actually cost.

import net from 'node:net';
import { spawnSync } from 'node:child_process';
import { randomUUID } from 'node:crypto';

// A port the OS has just confirmed nothing is bound to. There is a window
// between closing this probe and wrangler binding it; refuseIfTaken() and the
// marker in waitForOwnServer() are what cover that window.
export async function freePort() {
  const srv = net.createServer();
  await new Promise((resolve, reject) => {
    srv.once('error', reject);
    srv.listen(0, '127.0.0.1', resolve);
  });
  const { port } = srv.address();
  await new Promise((r) => srv.close(r));
  return port;
}

// The port to use: `envName` when it is set (a person pinning a known port, or
// a test proving the refusal below), otherwise one the OS hands out.
export async function choosePort(envName) {
  const pinned = process.env[envName];
  if (pinned) {
    const n = Number(pinned);
    if (!Number.isInteger(n) || n < 1 || n > 65535) {
      throw new Error(`${envName}=${pinned} is not a port number`);
    }
    return n;
  }
  return freePort();
}

// Both halves, because they fail differently: a listener on 127.0.0.1 accepts
// the connect (and would answer our fetches), and a listener bound some other
// way can still refuse our bind. The connect half is the one that matters for
// a workerd holder, which does not refuse a second workerd's bind at all.
async function portTaken(port) {
  const accepts = await new Promise((resolve) => {
    const sock = net.connect({ port, host: '127.0.0.1' });
    const done = (v) => { sock.destroy(); resolve(v); };
    sock.setTimeout(1500, () => done(false));
    sock.once('connect', () => done(true));
    sock.once('error', () => done(false));
  });
  if (accepts) return true;
  return new Promise((resolve) => {
    const srv = net.createServer();
    srv.once('error', () => resolve(true));
    srv.listen(port, '127.0.0.1', () => srv.close(() => resolve(false)));
  });
}

// Who is listening on `port`, in words, best effort. Windows: netstat for the
// PID, then the process and up to three parents with their command lines.
// Elsewhere: `ss -ltnp`, which is what the CI runner has.
export function portOwner(port) {
  try {
    if (process.platform === 'win32') {
      const ns = spawnSync('netstat', ['-ano', '-p', 'TCP'], { encoding: 'utf8' });
      const pids = [...new Set((ns.stdout || '').split(/\r?\n/)
        .map((l) => l.trim().split(/\s+/))
        .filter((f) => f[0] === 'TCP' && f[3] === 'LISTENING' && f[1].endsWith(':' + port))
        .map((f) => Number(f[4])))];
      if (pids.length === 0) return 'no LISTENING row in netstat (the holder may have just exited)';
      const ps = `
        foreach ($p in @(${pids.join(',')})) {
          $id = $p; $depth = 0
          while ($id -and $depth -lt 4) {
            $proc = Get-CimInstance Win32_Process -Filter "ProcessId=$id"
            if (-not $proc) { break }
            $cmd = if ($proc.CommandLine) { $proc.CommandLine } else { '' }
            if ($cmd.Length -gt 400) { $cmd = $cmd.Substring(0, 400) + '...' }
            Write-Output ((' ' * (2 * $depth)) + 'pid ' + $proc.ProcessId + ' ' + $proc.Name + ': ' + $cmd)
            $id = $proc.ParentProcessId; $depth++
          }
        }`;
      const r = spawnSync('powershell', ['-NoProfile', '-NonInteractive', '-Command', ps], { encoding: 'utf8' });
      // trimEnd per line: PowerShell pads its output to the console width.
      return (r.stdout || '').split(/\r?\n/).map((l) => l.trimEnd()).join('\n').trim()
        || `pid ${pids.join(', ')} (could not read its command line)`;
    }
    const r = spawnSync('ss', ['-ltnpH', `sport = :${port}`], { encoding: 'utf8' });
    return (r.stdout || '').trim() || 'unknown (ss printed nothing)';
  } catch (e) {
    return 'unknown (' + e.message + ')';
  }
}

// Throws, with the owner named, when the port is not ours to take. The caller
// turns that into its own FAILED line and a non-zero exit.
export async function refuseIfTaken(port) {
  if (!(await portTaken(port))) return;
  throw new Error(`port ${port} is already in use - refusing to start, because the suite `
    + `would test whatever answers there instead of the database it builds.\n`
    + `  Held by:\n${portOwner(port).replace(/^/gm, '    ')}\n`
    + `  If that is a stale wrangler/workerd from an earlier run, kill it (taskkill /PID <pid> /T /F).`);
}

// A per-run identity. `sql` goes at the end of the bootstrap; the draft it
// writes is owned by an address nobody else ever uses, so no check that reads
// the caller's own draft - or anyone else's - can see it.
export function runMarker() {
  const nonce = randomUUID();
  const email = `run-${nonce}@suite-marker.invalid`;
  return {
    nonce,
    email,
    sql: `INSERT INTO character_drafts (owner_email, char_name, state) VALUES ('${email}', '${nonce}', '{}');\n`,
  };
}

// Resolves { ok: true } only once `base`/draft, asked as the marker's owner,
// returns the marker's nonce - i.e. the answering server reads this run's
// database. Resolves { ok: false, why } the moment the spawned child exits, when
// something answers WITHOUT the marker for longer than a boot could explain,
// or at the deadline.
export async function waitForOwnServer({ base, child, marker, port, ms = 90000 }) {
  let exited = null;
  if (child.exitCode !== null) exited = child.exitCode;
  child.once('exit', (code, signal) => { exited = code ?? signal ?? 'unknown'; });

  const started = Date.now();
  let foreignSince = null;
  while (Date.now() - started < ms) {
    if (exited !== null) {
      return { ok: false, why: `the wrangler this run spawned exited (${exited}) before serving its own database`
        + (await portTaken(port) ? `; port ${port} is held by:\n${portOwner(port).replace(/^/gm, '    ')}` : '') };
    }
    let r = null;
    try {
      r = await fetch(`${base}/draft`, { headers: { 'Cf-Access-Authenticated-User-Email': marker.email } });
    } catch { /* nothing listening yet */ }
    if (r) {
      const body = await r.json().catch(() => null);
      if (r.ok && body?.draft?.char_name === marker.nonce) return { ok: true };
      // ANY answer without the marker, not only a 200: a foreign server over a
      // database with no schema answers this route with a 500. Our own server
      // reads a database that already holds the marker, so it cannot answer
      // without it except for a moment while it boots - hence the grace.
      // Measured 2026-09-17: with a real workerd holding the port, the wrangler
      // this run spawned does NOT exit, so the child check above never fires
      // and this is the branch that catches the incident.
      foreignSince ??= Date.now();
      if (Date.now() - foreignSince > 10000) {
        return { ok: false, why: `a server answers on port ${port} (HTTP ${r.status}) but does NOT serve this run's `
          + `database (marker ${marker.nonce} missing) - it is someone else's.\n  Held by:\n`
          + portOwner(port).replace(/^/gm, '    ') };
      }
    }
    await new Promise((r) => setTimeout(r, 700));
  }
  return { ok: false, why: `timed out after ${ms / 1000}s waiting for ${base}/draft to serve this run's marker` };
}
