// Pulling statements out of a .sql file, well enough to replay the read-backs.
//
// Its own module rather than a helper inside d1-apply.mjs so the smoke test can
// import it. d1-apply.mjs runs its work at the top level, so importing it to
// test one function would apply migrations as a side effect.

// Runs of whitespace collapsed to one space, but ONLY outside string literals.
//
// This is not cosmetic. `wrangler d1 execute --command` truncates its argument
// at the first newline and reports the remainder as `incomplete input:
// SQLITE_ERROR`, which reads like malformed SQL rather than a mangled argument.
// Every verification SELECT in this repo is written across several lines, so
// every one of them failed that way.
//
// Literal-aware because collapsing blindly would rewrite the data a query
// matches on: `instr(markdown, 'item_id: "energy-rifle"')` must keep its exact
// spacing, and a literal holding two spaces or a newline would otherwise be
// silently altered into a query that finds nothing.
export function collapseWhitespace(sql) {
  let out = '';
  let inStr = false;
  let pendingSpace = false;
  for (let i = 0; i < sql.length; i++) {
    const c = sql[i];
    if (inStr) {
      out += c;
      if (c === "'") {
        if (sql[i + 1] === "'") out += sql[++i];
        else inStr = false;
      }
      continue;
    }
    if (c === "'") {
      if (pendingSpace) { out += ' '; pendingSpace = false; }
      inStr = true;
      out += c;
      continue;
    }
    if (/\s/.test(c)) { pendingSpace = out.length > 0; continue; }
    if (pendingSpace) { out += ' '; pendingSpace = false; }
    out += c;
  }
  return out;
}

// Line comments removed, outside string literals only. Used by d1-apply's
// pre-flight, which cares about non-ASCII that will REACH THE DATABASE - an
// em-dash in a comment is mangled harmlessly, one in a value is corruption.
export function stripComments(sql) {
  let out = '';
  let inStr = false;
  for (let i = 0; i < sql.length; i++) {
    const c = sql[i];
    if (inStr) {
      out += c;
      if (c === "'") {
        if (sql[i + 1] === "'") out += sql[++i];
        else inStr = false;
      }
      continue;
    }
    if (c === '-' && sql[i + 1] === '-') {
      while (i < sql.length && sql[i] !== '\n') i++;
      out += '\n';
      continue;
    }
    if (c === "'") inStr = true;
    out += c;
  }
  return out;
}

// Top-level statements, split on semicolons that are not inside a string
// literal. SQL escapes a quote by doubling it, which falls out of the state
// machine for free. Line comments are stripped first, outside literals only.
export function statements(sql) {
  const out = [];
  let cur = '';
  let inStr = false;
  for (let i = 0; i < sql.length; i++) {
    const c = sql[i];
    if (inStr) {
      cur += c;
      if (c === "'") {
        if (sql[i + 1] === "'") cur += sql[++i];
        else inStr = false;
      }
      continue;
    }
    if (c === '-' && sql[i + 1] === '-') {          // line comment, outside a literal
      while (i < sql.length && sql[i] !== '\n') i++;
      cur += '\n';
      continue;
    }
    if (c === "'") { inStr = true; cur += c; continue; }
    if (c === ';') { out.push(cur); cur = ''; continue; }
    cur += c;
  }
  out.push(cur);
  return out.map((t) => t.trim()).filter(Boolean);
}

// The statements that BEGIN with SELECT: a script's own verification read-backs.
// A SELECT inside an UPDATE's guard is part of that UPDATE and is not one of
// these — re-running it alone would be meaningless.
//
// Returned single-line and semicolon-terminated, ready to hand to --command.
export function trailingSelects(sql) {
  return statements(sql)
    .filter((t) => /^select\b/i.test(t))
    .map((t) => collapseWhitespace(t) + ';');
}
