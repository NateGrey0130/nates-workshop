-- Revised Heroes Unlimited - its bestiary and its notable NPCs.
-- 2 creatures (migration 074) and 0 notable NPCs (migration 072),
-- with their attacks in stat_attacks (migration 073).
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~083-heroes-unlimited-golem-and-zombies.sql
--
-- Written by scripts/bestiary-sql.mjs from 1 worker file(s). Every
-- creature row passes creatureFormulaGaps, every value is printable ASCII,
-- and an 8-word shingle check of the prose fields against the book's cached text finds no copied run.

INSERT INTO creatures (slug, name, category, system, playable, alignment, attributes, hp, sdc, mdc, ppe, isp, pools_note, ar, horror_factor, combat, bonuses_note, skills_note, natural_abilities, magic, psionics, size, weight, life_span, habitat, allies, enemies, occ_note, description, source_book) VALUES
('golem-heroes-unlimited', 'Golem', 'construct', 'heroes-unlimited', 0, NULL, '{"IQ":"8","PS":"25","PP":"20","Spd":"12"}', NULL, '130', NULL, NULL, NULL, 'One row for both kinds; the stored figures are the STONE golem (A.R. 14, S.D.C. 130, Spd 12). An IRON golem has A.R. 17, S.D.C. 200 and Spd 10, with I.Q. 8, P.S. 25, P.P. 20 and all bonuses unchanged. Only I.Q., P.S., P.P. and Spd are printed; no hit points are given. Each hour in moonlight restores 20 S.D.C.', 14, NULL, '{"parry":3,"dodge":3,"damage":10}', '+10 to damage, +3 to parry/dodge, +2 vs magic. Attacks per melee and unarmed damage dice are not printed.', NULL, 'Unaffected by psionic mental attacks, by ordinary or magical toxins, by sleep, charm and mesmerism effects, by negate magic, and by fire or cold. Moonlight repairs it. It has no feelings or wants of its own and acts only on its maker''s orders.', 'Made with the Create Golem power circle (permanent, no saving throw): a clay figure with two onyx eyes and an iron heart is turned to stone or iron and woken with a drop of the maker''s blood, permanently costing the maker six S.D.C. The work takes 18 consecutive hours.', NULL, 'Any size up to 18 ft tall', NULL, NULL, NULL, 'Its creator only', NULL, NULL, 'A stone or iron humanoid animated by a sorcerer''s power circle, in effect a giant mystic robot that obeys nobody but the mage who made it. Only anarchist or evil mystics build them.', 'Revised Heroes Unlimited p.107'),
('zombies-heroes-unlimited', 'Zombies', 'undead', 'heroes-unlimited', 0, NULL, '{"IQ":"4","PS":"20","Spd":"8"}', NULL, NULL, NULL, NULL, NULL, 'Both pools scale with the creating mage and are not rollable formulas, so neither is stored: Hit Points are 1D6 per level of the spell caster, and S.D.C. is 20 + 10 per level of the mage. Only I.Q., P.S. and Spd are printed. All hit points and S.D.C. regenerate within 48 hours.', 15, NULL, '{"attacks":2,"damage":5}', '2 attacks per melee; +5 to damage; +3 on all saving throws vs magic and psionics. Fire and cold do half damage. Normal weapons do no damage: only silver, holy and magic weapons can harm it.', 'Understands only very simple and explicit commands.', 'Fearless undead that ignore charms, mesmerism and hypnotic suggestion, take half damage from fire and cold and none from ordinary weapons. A slain zombie gets back up within 48 hours unless its head is cut off and buried apart from the body, or an exorcism is performed.', 'Made with the Create Zombies power circle (permanent, no saving throw) from a corpse no more than 6 hours dead, in a graveyard on a night of the full moon; the process takes about six hours. A mage can create and control a total of 3 zombies per level of experience.', NULL, NULL, NULL, NULL, NULL, 'Its creator only', NULL, NULL, 'A fresh corpse raised by necromantic circle magic into a damned, dim-witted servant that answers only to the caster who raised it, typically worked as slave labor or massed into an undead army. Only anarchist or evil mystics make them.', 'Revised Heroes Unlimited p.107');

INSERT INTO stat_attacks (owner_kind, owner_slug, name, damage, is_mega_damage, range, note, sort) VALUES
('creature', 'zombies-heroes-unlimited', 'Unarmed Attack', '1D6', 0, 'melee', 'or by weapon; +5 to damage', 0);

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'all 2 creatures are in' AS assertion, count(*) AS got, 2 AS want
  FROM creatures WHERE slug IN ('golem-heroes-unlimited', 'zombies-heroes-unlimited');
SELECT 'and 0 of them are playable' AS assertion, count(*) AS got, 0 AS want
  FROM creatures WHERE playable = 1 AND slug IN ('golem-heroes-unlimited', 'zombies-heroes-unlimited');
SELECT 'the creatures carry 1 attacks' AS assertion, count(*) AS got, 1 AS want
  FROM stat_attacks WHERE owner_kind = 'creature' AND owner_slug IN ('golem-heroes-unlimited', 'zombies-heroes-unlimited');

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~083-heroes-unlimited-golem-and-zombies.sql');
