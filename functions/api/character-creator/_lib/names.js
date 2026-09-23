// What the name endpoints share: the names a campaign already uses, and the
// reading of a name request. The generator itself is shared/js/namegen.js, a
// pure module the browser can load too; this is only the server's half.

import { MAX_COUNT } from '../../../../shared/js/namegen.js';

// Every name the campaign already has: its dossiers (npcs) and its characters,
// players' and the G.M.'s NPCs alike. A generated list excludes all of them,
// so "a new name" means new to this table and not only new to this list.
//
// Read on the server on purpose - a G.M.-only request, so the NPC rows that
// isHiddenNpc keeps from players never leave it except as names NOT chosen.
export async function usedNames(env, campaignId) {
  const { results } = await env.DB.prepare(
    'SELECT name FROM npcs WHERE campaign_id = ?1 UNION SELECT name FROM characters WHERE campaign_id = ?1'
  ).bind(campaignId).all();
  return (results || []).map((r) => r.name).filter(Boolean);
}

// The query string of a list request, in the shape generateNames() takes.
// `avoid` repeats (?avoid=A&avoid=B) because a name may hold a comma; it is the
// chips already on screen, so "Generate new list" never offers them twice.
export function readNameQuery(url) {
  const q = new URL(url).searchParams;
  const n = Number(q.get('count'));
  return {
    theme: q.get('theme') || '',
    kind: q.get('kind') || 'person',
    gender: q.get('gender') || 'any',
    shape: q.get('shape') || null,
    count: Number.isFinite(n) && n > 0 ? Math.min(MAX_COUNT, Math.trunc(n)) : 6,
    avoid: q.getAll('avoid').map((s) => s.trim()).filter(Boolean).slice(0, 200),
  };
}
