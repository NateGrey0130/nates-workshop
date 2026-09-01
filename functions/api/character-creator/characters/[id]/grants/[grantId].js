// DELETE /api/character-creator/characters/:id/grants/:grantId — take a grant
//        back. Owner or G.M., and logged.
//
// G.M.-only removal was considered and rejected in plan 19: adding is already
// open, so a G.M.-only retraction would protect the record from everyone
// except the person most likely to want it gone, while turning every typo into
// a message to the G.M. The trail carries the weight instead — a removal
// writes a play_event exactly as an add does, so a grant that appeared and
// vanished between sessions is still legible after the row is gone.
//
// The row goes for good rather than being soft-deleted. A grant is current
// state, and a withdrawn ruling is not like a stash item that left the party;
// keeping withdrawn rows in the table that decides current effects is one
// forgotten filter away from a bonus coming back from the dead.

import { json, requireCharacter } from '../../../_lib/auth.js';
import { loadCharacter } from '../../../_lib/character-json.js';
import { grantEventStatement } from '../../../_lib/grants.js';

export async function onRequestDelete({ request, env, params }) {
  const guard = await requireCharacter(request, env, params.id);
  if (guard.res) return guard.res;
  const { email } = guard;

  // Scoped to the character in the path, so a grant id from another sheet is a
  // 404 rather than a cross-character delete.
  const grant = await env.DB.prepare(
    'SELECT id, kind, name, reason FROM character_grants WHERE id = ? AND character_id = ?'
  ).bind(params.grantId, params.id).first();
  if (!grant) return json({ error: 'Grant not found' }, 404);

  if (grant.kind !== 'skill') {
    return json({ error: `${grant.kind} grants are not implemented yet` }, 400);
  }

  const character = await loadCharacter(env, params.id, ['id', 'skills']);
  const skills = Array.isArray(character.skills) ? character.skills : [];

  // Exactly one entry, matched on the grant's own name among the gm-typed
  // rows. A filter without the flag would remove a skill the player earned
  // that happens to share the name.
  let removed = false;
  const kept = skills.filter((s) => {
    if (removed) return true;
    if (s?.type === 'gm' && String(s.name).toLowerCase() === String(grant.name).toLowerCase()) {
      removed = true;
      return false;
    }
    return true;
  });

  await env.DB.batch([
    env.DB.prepare('DELETE FROM character_grants WHERE id = ?').bind(grant.id),
    env.DB.prepare("UPDATE characters SET skills = ?, updated_at = datetime('now') WHERE id = ?")
      .bind(JSON.stringify(kept), params.id),
    grantEventStatement(env, params.id, email, `removed granted skill: ${grant.name}`),
  ]);

  // Reported rather than assumed. A grant row whose skill was already gone from
  // the sheet is not an error, but it is a fact worth returning: it means the
  // two had drifted, and only the caller can say whether that matters.
  return json({ ok: true, skills: kept, removed_from_sheet: removed });
}
