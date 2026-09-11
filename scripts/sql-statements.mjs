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

// D1 refuses an expression tree deeper than 100 ("Expression tree is too large
// (maximum depth 100)"). Measured on local D1, 2026-09-11: `length(` + a
// 98-link `'a' || 'a' || ...` chain + `)` runs; 99 links fail. A left-
// associative `||` chain is one level per link, and every call or parenthesis
// around it adds one - so the estimate is the longest chain plus the nesting
// it sits in, and 99 is the most D1 accepts.
//
// It is an ESTIMATE, not a parser: the chain resets at a comma, at a
// parenthesis boundary, and at a keyword or comparison, which is where a chain
// ends in the SQL this repo writes. It exists because the failure is late and
// looks like bad data - BOOK-INGEST-AUDIT F59's first script wrote a 70-line
// block as 'a' || char(10) || 'b' || ... and D1 refused it only at apply time.
// The fix for a long text is ONE literal and one replace():
//   replace('line one~~line two~~line three', '~~', char(10))
export const D1_MAX_EXPR_DEPTH = 99;

const CHAIN_BREAKERS = new Set(['and', 'or', 'where', 'set', 'when', 'then', 'else',
  'end', 'from', 'select', 'values', 'is', 'not', 'in', 'like', 'as', 'on', 'by',
  'case', 'group', 'order', 'having', 'limit', 'into', 'insert', 'update', 'delete']);

export function expressionDepth(stmt) {
  const links = [0];
  let depth = 0;
  let max = 0;
  for (let i = 0; i < stmt.length; i++) {
    const c = stmt[i];
    if (c === "'") {                               // skip a string literal whole
      for (i++; i < stmt.length; i++) {
        if (stmt[i] === "'") { if (stmt[i + 1] === "'") i++; else break; }
      }
      continue;
    }
    if (c === '-' && stmt[i + 1] === '-') {        // and a line comment
      while (i < stmt.length && stmt[i] !== '\n') i++;
      continue;
    }
    if (c === '(') { depth++; links[depth] = 0; continue; }
    if (c === ')') { links[depth] = 0; depth = Math.max(0, depth - 1); continue; }
    if (c === '|' && stmt[i + 1] === '|') {
      i++;
      links[depth] = (links[depth] || 0) + 1;
      max = Math.max(max, links[depth] + depth);
      continue;
    }
    if (c === ',' || c === '=' || c === '<' || c === '>' || c === '!') { links[depth] = 0; continue; }
    if (/[A-Za-z_]/.test(c)) {
      let j = i;
      while (j < stmt.length && /[A-Za-z0-9_]/.test(stmt[j])) j++;
      if (CHAIN_BREAKERS.has(stmt.slice(i, j).toLowerCase())) links[depth] = 0;
      i = j - 1;
    }
  }
  return max;
}

// EVERY statement, single-line and semicolon-terminated: trailingSelects()
// without the SELECT filter. `q.mjs --batch` hands these to ONE --command
// invocation, so the single-line property is load-bearing here for the same
// reason it is there — --command truncates at the first newline and calls the
// remainder `incomplete input`.
export function batchStatements(sql) {
  return statements(sql).map((t) => collapseWhitespace(t) + ';');
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
