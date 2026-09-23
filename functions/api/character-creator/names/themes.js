// GET /api/character-creator/names/themes?system=
// Any signed-in user. The name themes a game can use - its own and the generic
// ones - with their tags, the kinds of name each makes and the shapes its
// people take, plus the maps that choose a starting theme: class to theme,
// game to theme, and game to places theme.
//
// No word lists: they are the generator's business, and a list request
// (campaigns/:id/names) is how a page gets names.

import { getUserEmail, unauthorized, json } from '../_lib/auth.js';
import { themeSummaries, CLASS_THEMES, SYSTEM_THEMES, PLACE_THEMES, KINDS, KIND_LABELS, GENDERS,
  SHAPES, SHAPE_LABELS, MAX_COUNT } from '../../../../shared/js/namegen.js';

export async function onRequestGet({ request }) {
  if (!getUserEmail(request)) return unauthorized();
  const system = new URL(request.url).searchParams.get('system') || null;
  return json({
    themes: themeSummaries(system),
    class_themes: CLASS_THEMES,
    system_themes: SYSTEM_THEMES,
    place_themes: PLACE_THEMES,
    kinds: KINDS.map((k) => ({ id: k, label: KIND_LABELS[k] })),
    genders: GENDERS,
    shapes: SHAPES.map((s) => ({ id: s, label: SHAPE_LABELS[s] })),
    max_count: MAX_COUNT,
  });
}
