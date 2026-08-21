// GET  /api/character-creator/campaigns/:id/currency — balances and the ledger
//      behind them. Members only.
// POST /api/character-creator/campaigns/:id/currency —
//      { currency, delta, reason?, journal_entry_id? }
//
// A ledger, not a number. The balance is SUM(delta), so there is no stored
// total that can disagree with its own history, and "where did the four
// thousand credits go" is answerable by reading rows rather than by remembering.
// Nothing here updates a row; entries are appended, and a mistake is corrected
// by an opposing entry that says so.

import { json, readJson, requireCampaign } from '../../_lib/auth.js';
import { entryInCampaign } from './items.js';

export async function onRequestGet({ request, env, params }) {
  const guard = await requireCampaign(request, env, params.id, { write: false });
  if (guard.res) return guard.res;
  if (!guard.access.isMember) {
    return json({ error: 'Only the GM or a player with a character in this campaign can do that' }, 403);
  }

  const limit = Math.min(Number(new URL(request.url).searchParams.get('limit')) || 100, 500);
  const [balances, ledger] = await env.DB.batch([
    env.DB.prepare(
      `SELECT currency, SUM(delta) AS balance, count(*) AS entries
       FROM campaign_currency WHERE campaign_id = ? GROUP BY currency ORDER BY currency`
    ).bind(params.id),
    env.DB.prepare(
      `SELECT id, currency, delta, reason, journal_entry_id, created_by, created_at
       FROM campaign_currency WHERE campaign_id = ?
       ORDER BY created_at DESC, id DESC LIMIT ?`
    ).bind(params.id, limit),
  ]);

  return json({ balances: balances.results ?? [], ledger: ledger.results ?? [] });
}

export async function onRequestPost({ request, env, params }) {
  const guard = await requireCampaign(request, env, params.id);
  if (guard.res) return guard.res;

  const b = await readJson(request);
  if (!b) return json({ error: 'Invalid JSON body' }, 400);

  // Free text, and trimmed to one spelling: 'Credits' and 'credits ' are the
  // same pile of money, and two balances for one currency is the failure a
  // ledger exists to prevent.
  const currency = typeof b.currency === 'string' ? b.currency.trim().toLowerCase() : '';
  if (!currency) return json({ error: 'currency is required (e.g. "credits", "gold")' }, 400);
  if (currency.length > 40) return json({ error: 'currency name is too long' }, 400);

  // Zero is refused rather than stored: an entry that changes nothing is either
  // a mistake or a note, and there is a notes feature for the second one.
  const delta = Number(b.delta);
  if (!Number.isFinite(delta) || Math.trunc(delta) === 0) {
    return json({ error: 'delta must be a non-zero number — negative to spend' }, 400);
  }

  const entryId = await entryInCampaign(env, b.journal_entry_id, params.id);
  const row = await env.DB.prepare(
    `INSERT INTO campaign_currency (campaign_id, currency, delta, reason, journal_entry_id, created_by)
     VALUES (?, ?, ?, ?, ?, ?) RETURNING *`
  ).bind(params.id, currency, Math.trunc(delta), b.reason ?? null, entryId, guard.email).first();

  const balance = await env.DB.prepare(
    'SELECT SUM(delta) AS balance FROM campaign_currency WHERE campaign_id = ? AND currency = ?'
  ).bind(params.id, currency).first();

  return json({ entry: row, balance: balance?.balance ?? 0 }, 201);
}
