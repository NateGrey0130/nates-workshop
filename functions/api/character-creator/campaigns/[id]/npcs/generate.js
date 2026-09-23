// POST /api/character-creator/campaigns/:id/npcs/generate — roll statted NPCs.
//
// Body: { class_id, class_variant?, occ_class_id?, occ_class_variant?,
//         level? (default 1), count? (1-10, default 1), name?,
//         name_theme?, name_gender?, name_shape? }
// G.M. only. Returns 201 { npcs: [{ id, name, level, picks_pending, powers_banked }] }.
//
// ── Names ──
// `name` is one name for the batch: "Guard" rolls "Guard 1", "Guard 2". Send
// `name_theme` instead (shared/js/namegen.js) and every NPC gets a name of its
// own from that theme, none already used in this campaign and none twice in
// the batch. The names are chosen BEFORE anything is written, so a theme that
// cannot name the whole batch is a 422 with its reason and no NPCs - the rule
// every generator here keeps: refuse, never pad. Neither sent, the class name
// and level stand in, as before.
//
// Phase 1 of the NPC / bestiary work (migration 070). The dice and the choices
// are js/npc-generate.js, a pure module a test sweeps across every published
// class; the WRITE is createCharacter() from characters.js, the path a player's
// character takes. So an NPC is validated against its class exactly as a PC
// is, and banked exactly as one is - the only differences are that `kind` is
// 'npc' and the owner is the G.M.
//
// ── Refusals, not guesses ──
// A class this cannot build legally is a 422 naming what stopped it - a skill
// category that runs dry, a race that needs an occupation, a class feature the
// generator does not choose yet. Nate's decision (2026-09-17): an NPC holding a
// wrong skill looks exactly like one holding a right one, so the generator
// refuses where every other generator here would pad. `code` says which kind of
// refusal; the message says exactly which class and what.
//
// ── Powers are banked ──
// Spells, psionics and Talents the class lets the NPC CHOOSE land in
// pending_power_picks, where the sheet's banked-picks panel spends them under
// every list and level rule the validator knows. Powers the class GRANTS are
// held from the start, as the wizard holds them. The response says how many
// were banked, so the G.M. knows to spend them.

import { json, readJson, requireCampaign } from '../../../_lib/auth.js';
import { loadClass, loadTotems } from '../../../_lib/class-loader.js';
import { loadSystemBases, applySystemBases } from '../../../_lib/system-bases.js';
import { loadPowerCatalog, powerGrantsFor } from '../../../_lib/power-picks.js';
import { createCharacter } from '../../../characters.js';
import { composeClass } from '../../../../../../apps/character-creator/js/compose.js';
import { needsOccupation, occAllowedForRace, raceAllowedForOcc } from '../../../../../../apps/character-creator/js/parser.js';
import { xpTableFor } from '../../../../../../apps/character-creator/js/leveling.js';
import { generateNpc, chooseClassOptions, skillsNamedByClasses, NpcGap }
  from '../../../../../../apps/character-creator/js/npc-generate.js';
import { generateNames, NameGenError } from '../../../../../../shared/js/namegen.js';
import { usedNames } from '../../../_lib/names.js';
// A classic script, not a module: importing it installs `globalThis.derive`,
// the attribute chart the I.Q. skill bonus and the dice bonuses read. Same
// arrangement the smoke and regression tests use to load it.
import '../../../../../../apps/character-creator/js/derive.js';

const MAX_COUNT = 10;

const gapResponse = (e) => json({ error: e.message, code: e.code, detail: e.detail }, 422);
const str = (v) => (typeof v === 'string' && v.trim() ? v.trim() : null);

export async function onRequestPost({ request, env, params }) {
  const guard = await requireCampaign(request, env, params.id, { gm: true });
  if (guard.res) return guard.res;

  const b = await readJson(request);
  if (!b) return json({ error: 'Invalid JSON body' }, 400);
  const classId = str(b.class_id);
  if (!classId) return json({ error: 'Missing required field: class_id' }, 400);
  const variant = str(b.class_variant);
  const occId = str(b.occ_class_id);
  const occVariant = str(b.occ_class_variant);
  const count = Math.max(1, Math.min(MAX_COUNT, Number.isFinite(Number(b.count)) ? Math.trunc(Number(b.count)) : 1));

  // One name per NPC from a theme, all of them chosen before the first write.
  let themed = null;
  const theme = str(b.name_theme);
  if (theme) {
    if (str(b.name)) return json({ error: 'Send name or name_theme, not both' }, 400);
    let res;
    try {
      res = generateNames({ theme, kind: 'person', gender: str(b.name_gender) || 'any',
        shape: str(b.name_shape), count, exclude: await usedNames(env, params.id) });
    } catch (e) {
      if (e instanceof NameGenError) return json({ error: e.message }, 400);
      throw e;
    }
    if (res.names.length < count) {
      return json({ error: `Could not name all ${count}: ${res.reason}`, code: 'names_exhausted',
        detail: { wanted: count, available: res.names.length } }, 422);
    }
    themed = res.names;
  }

  const campaign = await env.DB.prepare('SELECT id, system FROM campaigns WHERE id = ?').bind(params.id).first();
  const system = campaign?.system ?? null;

  const rcc = await loadClass(env, request.url, classId, variant);
  if (!rcc) return json({ error: `No published class called ${classId}` }, 404);
  const occ = occId ? await loadClass(env, request.url, occId, occVariant) : null;
  if (occId && !occ) return json({ error: `No published class called ${occId}` }, 404);

  // A race whose book entry grants no related or secondary skills is built
  // WITH an occupation - the wizard asks for one - and the G.M. is the one to
  // choose it. Refused rather than picked at random: which occupation an NPC
  // has is the most important thing about them.
  if (!occ && needsOccupation(rcc)) {
    return gapResponse(new NpcGap('needs_occupation',
      `${rcc.name || classId} is a race that takes an occupation - choose one with occ_class_id`));
  }
  if (occ && occId !== classId) {
    const byRace = occAllowedForRace(rcc, occ);
    const verdict = byRace.allowed ? raceAllowedForOcc(occ, rcc) : byRace;
    if (!verdict.allowed) return json({ error: verdict.reason }, 400);
  }

  const [rawSkills, overrides, totems, gameClasses] = await Promise.all([
    env.DB.prepare('SELECT name, category, base, base_formula, per_level, systems FROM skills').all(),
    loadSystemBases(env, system),
    loadTotems(env),
    // This game's own classes, read only for the skill names they quote - see
    // skillsNamedByClasses for why the catalog cannot say which game a skill
    // belongs to, and why a random pick prefers these.
    system ? env.DB.prepare(
      "SELECT markdown FROM imported_classes WHERE status = 'published' AND deleted_at IS NULL AND system = ?"
    ).bind(system).all() : Promise.resolve({ results: [] }),
  ]);
  const catalog = applySystemBases(rawSkills.results || [], overrides);
  const totemRows = [...totems.values()];
  const gameSkills = system
    ? skillsNamedByClasses((gameClasses.results || []).map((r) => r.markdown), catalog) : null;

  const made = [];
  for (let i = 0; i < count; i++) {
    let chosen, cls, body;
    try {
      const first = composeClass({ rcc, occ, character: {} });
      chosen = chooseClassOptions(first, { totems: totemRows });
      const totemRow = chosen.totem ? totems.get(chosen.totem) ?? null : null;
      cls = composeClass({ rcc, occ, totem: totemRow,
        character: { mos: chosen.mos, abilities: chosen.abilities, totem: chosen.totem } });
      const maxLevel = xpTableFor(cls).length || 1;
      const level = Math.max(1, Math.min(maxLevel,
        Number.isFinite(Number(b.level)) ? Math.trunc(Number(b.level)) : 1));
      const grantedNames = [...(cls.magic?.spells || []), ...(cls.psionics?.powers || []),
        ...(cls.super_abilities?.abilities || []), ...(cls.talents?.talents || [])]
        .filter((n) => typeof n === 'string' && n.trim()).map((n) => n.trim());
      const powerCatalog = grantedNames.length ? await loadPowerCatalog(env, grantedNames, system) : null;
      const base = str(b.name);
      body = generateNpc({
        cls, level, catalog, derive: globalThis.derive, system, chosen, powerCatalog, gameSkills,
        name: themed ? themed[i] : base ? (count > 1 ? `${base} ${i + 1}` : base) : null,
      });
    } catch (e) {
      if (e instanceof NpcGap) {
        // Anything already made in this request stays made and is reported:
        // a refusal on the fourth of six is a fact about the fourth.
        if (made.length) return json({ npcs: made, refused: { error: e.message, code: e.code } }, 201);
        return gapResponse(e);
      }
      throw e;
    }

    // What the levels above one earn in powers, resolved at each level by the
    // function a live level-up uses. Talent PURCHASES are createCharacter's own.
    const levelPowers = body.level > 1
      ? powerGrantsFor(cls, 1, body.level).filter((g) => g.kind !== 'talent_purchase') : [];
    const bank = [...body.banked_powers, ...levelPowers];
    const { banked_powers: _omit, ...payload } = body;

    const res = await createCharacter(env, request, guard.email, {
      ...payload,
      campaign_id: Number(params.id), class_id: classId, class_variant: variant,
      occ_class_id: occId, occ_class_variant: occVariant,
    }, { kind: 'npc', bankPowers: bank });

    if (res.status !== 201) {
      // The generator and the validator disagreeing is a bug in the generator,
      // and saying so is the point of running one through the other.
      return json({ error: 'The generated NPC broke its class rules - this is a generator bug',
                    npcs: made, ...res.body }, res.status === 422 ? 500 : res.status);
    }
    made.push({ id: res.body.id, name: body.name, level: res.body.level,
                picks_pending: res.body.picks_pending, powers_banked: bank.reduce((n, g) => n + (g.count || 1), 0) });
  }
  return json({ npcs: made }, 201);
}
