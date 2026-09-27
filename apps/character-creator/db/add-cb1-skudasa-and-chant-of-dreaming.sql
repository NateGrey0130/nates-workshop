-- Rifts Conversion Book One, batch 4 catalog rows: Hand to Hand: Skudasa
-- (printed 100-101) and the Chant of Dreaming (printed 107).
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-cb1-skudasa-and-chant-of-dreaming.sql
--
-- It SORTS BEFORE the class scripts that grant these rows by name -
-- add-rifts-gosai-assassin-class.sql and add-rifts-quorian-oneiromancer-class.sql -
-- so a clean rebuild creates the rows first. Checked with the class-import
-- sort command on 2026-09-26.
--
-- HAND TO HAND: SKUDASA is a Physical row in the shape of the other five Hand
-- to Hand rows: base 0, per_level 0, the fifteen-level table in level_bonuses.
-- It is named Hand to Hand: <style> so js/hand-to-hand.js counts it as a
-- style and it replaces rather than stacks. systems is ["rifts"], the
-- Commando's shape. The book says ONLY the Gosai Assassin may take it; the
-- note says so, as the catalog's other exclusive skills do ("Exclusive to the
-- Rogue Scholar O.C.C."), and the Gosai Assassin's own hand_to_hand block
-- sells no other style. A class that states no Hand to Hand price is still
-- offered it by the picker - nothing enforces a skill's exclusivity.
--
-- THE CHANT OF DREAMING is a spell row at level 0 with no tradition, the shape
-- Wormwood's class-specific prayers take (add-wormwood-prayers.sql): the book
-- gives it no spell level, and the Oneiromancer grants it by name through
-- magic.spells, so level 0 gates nothing and no level-gated pick reaches it.
-- Its success ratio has no column and is in the description.
--
-- ON CONFLICT (name) DO UPDATE, so a re-run rewrites the same values.
-- Pure ASCII with LF endings on purpose - see PR #101.

INSERT INTO skills (name, category, base, per_level, systems, source, source_book, note, level_bonuses)
VALUES ('Hand to Hand: Skudasa', 'Physical', 0, 0, '["rifts"]', 'import', 'Rifts Conversion Book One p.100-101', 'Exclusive to the Gosai Assassin R.C.C. (rifts-gosai-assassin): the book says only it may take this style. A cross between Martial Arts and Assassin combat training with a special emphasis on clawing and kicking attacks, built on the Gosai''s own claws (2D6) and pop kick (4D6, two melee actions), which level 5 raises.', '[{"level":1,"combat":{"attacks_base":2,"strike":2}},{"level":2,"combat":{"parry":3,"dodge":3,"pull_punch":2,"roll":2}},{"level":3,"note":"All styles of kick attacks and their corresponding damage."},{"level":4,"combat":{"attacks":1,"initiative":1}},{"level":5,"note":"Claw attacks increase to 3D6 damage, and the pop kick to 5D6."},{"level":6,"note":"Critical Strike on an unmodified roll of 17, 18, 19 or 20."},{"level":7,"note":"Hand and foot claws may be used as paired weapons, as per W.P. Paired Weapons, and can parry swords and other hand-held weapons."},{"level":8,"combat":{"initiative":1,"pull_punch":2},"note":"Leap attack."},{"level":9,"combat":{"attacks":1}},{"level":10,"combat":{"parry":2,"dodge":2}},{"level":11,"combat":{"initiative":1},"note":"Body throw/flip."},{"level":12,"note":"Death blow on an unmodified roll of 20 (if desired)."},{"level":13,"combat":{"damage_bonus":2}},{"level":14,"combat":{"attacks":1}},{"level":15,"combat":{"strike":2,"disarm":2}}]')
ON CONFLICT (name) DO UPDATE SET
       category = excluded.category,
       base = excluded.base,
       per_level = excluded.per_level,
       systems = excluded.systems,
       source = excluded.source,
       source_book = excluded.source_book,
       note = excluded.note,
       level_bonuses = excluded.level_bonuses;

INSERT INTO spells
  (name, level, ppe, ppe_note, variant_note, source, source_book, system, range, duration, damage, saving_throw, area_of_effect, casting_time, description)
VALUES
  ('Chant of Dreaming', 0, 20, NULL, NULL, 'import', 'Rifts Conversion Book One p.107', 'rifts', 'Self, or other by touch.', 'The dream usually lasts about ten minutes.', NULL, 'Standard for others; none for the shaman.', NULL, '2D4 minutes of chanting, whether in a ceremony or by a single shaman.', 'A Shamanistic chant of the Quorian Oneiromancer. A dream comes to the subject the next time he or she falls asleep: vivid and lucid, the dreamer able to interact with it and remember all of it. It may be set in an imaginary place - a childhood home, a forest glen, a mythical castle - or somewhere the dreamer has been or may one day go, and usually the dreamer can converse with a person or creature he knows or instantly recognizes (a relative, a dead ancestor, a mythic figure) and ask about the future and himself, receiving answers and advice. Far from infallible, such dreams usually hold valuable hints, portents and suggestions. The dream has no real bearing on future reality, but the dreamer comes away with a positive, even euphoric, feeling that it is significant. The recipient grows sleepy after the chant and may fall asleep at once, and however disturbing the dream, gets the benefit of a full night''s sleep even if woken fifteen minutes later. Success Ratio: 30% +5% per level of experience. P.P.E.: 20 for Oneiromancers.')
ON CONFLICT (name) DO UPDATE SET
       level = excluded.level,
       ppe = excluded.ppe,
       ppe_note = excluded.ppe_note,
       variant_note = excluded.variant_note,
       source = excluded.source,
       source_book = excluded.source_book,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description;

-- Read the result back rather than trusting the exit code. d1-apply enforces
-- every row shaped assertion / got / want.
SELECT 'skudasa: fifteen levels, two attacks at level one' AS assertion,
       (SELECT json_array_length(level_bonuses) || '/' || json_extract(level_bonuses, '$[0].combat.attacks_base') FROM skills WHERE name = 'Hand to Hand: Skudasa') AS got,
       '15/2' AS want;
SELECT 'chant of dreaming: level 0, 20 P.P.E.' AS assertion,
       (SELECT level || '/' || ppe FROM spells WHERE name = 'Chant of Dreaming') AS got,
       '0/20' AS want;

-- Records this run.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-cb1-skudasa-and-chant-of-dreaming.sql');
